/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class MassUpdateCaseController {

public String listOfCaseNumber{get;set;}
public string Description{get;set;}
public List<SelectOption> getOptionList{get;set;}
public List<SelectOption> getSubLists{get;set;}
public List<SelectOption> getStatusLists{get;set;}
public String typeOfUpdate{get;set;}
public String typeOfStatus{get;set;}
public String Subjectcase{get;set;}
public string typeOfsubject{get;set;}
public Boolean IserrorAlreadycalled;

    public MassUpdateCaseController() {
        listOfCaseNumber = '';
        Description = '';
        typeOfStatus = '';
        typeOfUpdate = '';
        Subjectcase = '';
        typeOfsubject = '';
        IserrorAlreadycalled = false;

    }


    public List<SelectOption> getSubLists(){
        List<SelectOption> subOptionList = new List<SelectOption>();
        subOptionList.add(new SelectOption('','-None-'));
        subOptionList.add(new SelectOption('Existing Subject','Existing Subject'));
        subOptionList.add(new SelectOption('New Subject','New Subject'));
    
            return subOptionList;
    
        }

public List<SelectOption> getStatusLists(){
    List<SelectOption> StatusOptionLists = new List<SelectOption>();
    StatusOptionLists.add(new SelectOption('','-None-'));
    StatusOptionLists.add(new SelectOption ('Escalated to IC','Escalated to IC'));
    StatusOptionLists.add(new SelectOption('Escalated to LC','Escalated to LC'));
   
    return StatusOptionLists;
}


    public List<SelectOption> getOptionList(){
        List<SelectOption> OptionList = new List<SelectOption>();
        optionList.add(new SelectOption('','-None-'));
        optionList.add(new SelectOption('On Hold','On Hold'));
        OptionList.add(new SelectOption('Escalated','Escalated'));
        OptionList.add(new SelectOption('Closed','Closed'));
        OptionList.add(new SelectOption('New','New'));
        OptionList.add(new SelectOption('In Progress','In Progress'));
        OptionList.add(new SelectOption('Response Received','Response Received'));
        OptionList.add(new SelectOption('New Case','New Case'));
        OptionList.add(new SelectOption('Re-Open','Re-Open'));
        OptionList.add(new SelectOption('Internal Response Received','Internal Response Received'));
        OptionList.add(new SelectOption('Interested','Interested'));
        OptionList.add(new SelectOption('Not Interested','Not Interested'));
        OptionList.add(new SelectOption('Repeat case','Repeat case'));
        OptionList.add(new SelectOption('Open','Open'));
        OptionList.add(new SelectOption('Assigned','Assigned'));
        OptionList.add(new SelectOption('In Progress(Escalated)','In Progress(Escalated)'));
        OptionList.add(new SelectOption('Invalid Case','Invalid Case'));
        
        return OptionList;
    }

    public void CreateAEPReq(){
        List<Case> lstCases = new List<Case>();
        // List<Case> UpdateCase = new List<Case>();
        System.debug('Selected Value-->'+typeOfUpdate);
        if(listOfCaseNumber!=''){

             List<String> lstcaseNumber = listOfCaseNumber.split(',');
            set<String> SetOfcaseNumber = new set<String>(); 

        for(String lstcase  : lstcaseNumber){
            SetOfcaseNumber.add(lstcase.trim());

        }
        lstCases = [SELECT id,CaseNumber,Case_Id__c,Owner_update__c,Tech_Issue__c,Mass_Email_Case_status__c,status,ContactEmail,SuppliedEmail,Description,Subject,Reference__c FROM Case WHERE  CaseNumber IN :SetOfcaseNumber];
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];

    //    System.debug('listOfCaseNumber-->' +listOfCaseNumber);
    //    System.debug('Description' +Description);

       if(lstCases!=null && lstCases.size()>0){

        List<Case> lstupdateCase = new List<Case>();
        Messaging.SingleEmailMessage[] lstMails = new List<Messaging.SingleEmailMessage>();
        
        for(Case objCase : lstCases) {
            // add address from Case.
             String Subject = objCase.Subject;
            String Description = Description;

            System.debug('typeofsubject==>' +typeOfsubject);
            if(typeOfsubject == 'New Subject'){
            Subject = Subjectcase;
            objCase.New_Subject__c=Subjectcase;
            }
            System.debug('Subject==>' +Subject);
            objCase.Status = typeOfUpdate;

        //     List<String> toAddresses = new List<String>();
        //     toAddresses.add(objCase.SuppliedEmail);
        //     // System.debug('Objcase-->' +objCase);
        //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        // mail.setToAddresses(toAddresses);
        // mail.setWhatId(objCase.Case_Id__c);
        // mail.setOrgWideEmailAddressId(owe.id);
        // mail.setReplyTo('ngasce@nmims.edu');
        // mail.setSubject(Subject);
        // // mail.setSubject(typeOfsub);
        // mail.setPlainTextBody(Description);        
        // mail.setHtmlBody(emailTextBody);
            // objCase.Status= '';
            if(String.isBlank(objCase.Tech_Issue__c)){
                objCase.Tech_Issue__c = 'No';
            }
         objCase.Owner_update__c = true;
         objCase.Mail_Description__c = Description;  
         objCase.Send_Mail__c = true;

          
            // lstMails.add(mail);
        lstupdateCase.add(objCase);

        }

       // if(lstMails.size() > 0) {
           // Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails);
            //if(results[0].success) {
                           // system.debug('Email Send Successfully');
            if(lstupdateCase.size()>0)
            {
                                    system.debug('lstupdateCase--->'+lstupdateCase.size());
            update lstupdateCase;
            }
            //} else {
               // system.debug('Failed to send mail ' + results[0].errors[0].message);
                
            //}
       // }

        }
        if(!isErrorAlreadyCalled) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Records Updated Successfully');
            ApexPages.addMessage(myMsg);

        }

        }
    }

}