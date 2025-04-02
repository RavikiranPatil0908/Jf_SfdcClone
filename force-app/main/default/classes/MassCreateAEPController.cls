/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-04-2024
 * @last modified by  : @BK
**/
public class MassCreateAEPController {
    public String listOfStudentNumber{get;set;}
    public List<SelectOption> getStatusLists{get;set;}
    public String typeOfStatus{get;set;}
    public String Description{get;set;}
    public String typeofSub{get;set;}
    public Boolean isErrorAlreadyCalled;
    public Set<String> lstFailedRecords;

    public MassCreateAEPController()
    {
        listOfStudentNumber = ''; 
        Description = '';
        typeOfStatus = '';
        typeofSub = '';
        isErrorAlreadyCalled = false;
    }

    public List<SelectOption> getStatusLists(){
        List<SelectOption> StatusOptionLists = new List<SelectOption>();
        StatusOptionLists.add(new SelectOption('','-None-'));
        StatusOptionLists.add(new SelectOption ('Escalated to IC','Escalated to IC'));
        StatusOptionLists.add(new SelectOption('Escalated to LC','Escalated to LC'));
       
        return StatusOptionLists;
    }

        public List<SelectOption> getTypeOptions()
        {

            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','--None--'));
            Schema.DescribeFieldResult fieldResult = AEP_Request__c.Subject__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry p : ple)
                options.add(new SelectOption(p.getLabel(), p.getValue())); 
            return options;

        }

    public void CreateAEPReq(){
        List<Lead> listOfStudents = new List<Lead>();
        List<AEP_Request__c> lstAEPRequestToInsert = new List<AEP_Request__c>();
       List<Account> listOfAccountStudents = new List<Account>();
      

        if(listOfStudentNumber!='')
        {
            List<String> lstOfStudentNumbers = listOfStudentNumber.split(',');
            set<String> setOfStudentNumbers = new set<String>();
            set<String> SetOfAccountStudents = new set<String>();
            List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();

            for (String studentNo : lstOfStudentNumbers) {
                setOfStudentNumbers.add(studentNo.trim());
            }
            System.debug('listStudentNumber==>' +setOfStudentNumbers);
            listOfStudents =[Select id,Name,nm_LCEmailID__c,IsConverted, nm_InformationCenter__c,nm_InformationCenter__r.AEP_email_id__c,nm_RegistrationNo__c from Lead Where IsConverted = false and  nm_RegistrationNo__c IN :setOfStudentNumbers];
           System.debug('listOfAcc==>' +listOfStudents);
            if(listOfStudents!=null && listOfStudents.size()>0){
                for(Lead lstLead : listOfStudents){
                    // If(lstLead.IsConverted == false){
                        AEP_Request__c objAep = new AEP_Request__c();
                        objAep.Lead__c = lstLead.id ;
                         objAep.Subject__c = typeofSub;
                        objAep.Description__c = Description; 
                        objAep.Status__c = typeOfStatus;
                        objAep.AEP__c = lstLead.nm_InformationCenter__c;
                        objAep.IC_email_id__c= lstLead.nm_InformationCenter__r.AEP_email_id__c;
                        lstAEPRequestToInsert.add(objAep); 
                        Messaging.SingleEmailMessage objMssg = new Messaging.SingleEmailMessage ();
                        objMssg = SendEmailMethod(objAep.IC_email_id__c,objAep.Description__c,objAep.Status__c, lstLead.nm_RegistrationNo__c); 
                        lstMails.add(objMssg);        
                    }  
                    // else if( lstLead.IsConverted == true) {
                    //     SetOfAccountStudents.add(lstLead.nm_RegistrationNo__c);

                    // }
                }
            // }
               System.debug('list==>' +SetOfAccountStudents);
                listOfAccountStudents =[Select id,Name,nm_RegistrationNumber__c,nm_Centers__c,ICemailaddress__c from Account Where nm_RegistrationNumber__c IN :setOfStudentNumbers];
                 System.debug('listOfAccountStudents==>' +listOfAccountStudents);
                if(listOfAccountStudents!=null && listOfAccountStudents.size()>0){
                    for(Account lstAccount: listOfAccountStudents){
                        AEP_Request__c objAccAep = new AEP_Request__c();
                        objAccAep.Student__c = lstAccount.id;
                        objAccAep.Subject__c = typeofSub;
                        objAccAep.Description__c = Description;
                        objAccAep.Status__c = typeOfStatus;
                        objAccAep.IC_email_id__c = lstAccount.ICemailaddress__c;
                        objAccAep.AEP__c = lstAccount.nm_Centers__c;
                        lstAEPRequestToInsert.add(objAccAep);
                        Messaging.SingleEmailMessage objMssg = new Messaging.SingleEmailMessage ();
                        objMssg = SendEmailMethod(objAccAep.IC_email_id__c,objAccAep.Description__c,objAccAep.Status__c, lstAccount.nm_RegistrationNumber__c); 
                        lstMails.add(objMssg);
                    }
                }
            if(lstAEPRequestToInsert != null && lstAEPRequestToInsert.size() > 0){
                Insert lstAEPRequestToInsert;
            }



        

        if(!isErrorAlreadyCalled) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Records Updated Successfully');
            ApexPages.addMessage(myMsg);

        }
        if(lstMails.size()>0)
        {
            Messaging.sendEmail(lstMails);
        }
    }    
}
public static Messaging.SingleEmailMessage SendEmailMethod(String SetEmail, String Description ,String typeOfStatus,string registernumber ){
    string subject = 'New AEP Request has been Created for the Registeration Number ' +registernumber;
    string  body = Description;
    string[] address = SetEmail.split(',');
    // String[] sendingToBCCAddress = new List<String>{'mmkhan9969@gmail.com','mohd.masood.ext@nmims.edu'};
    string[] sendingToBCCAddress = System.Label.setBccAdderess.split(',');
    OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
    Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
    Emailwithattch.setSubject(subject);
    Emailwithattch.setBccAddresses(sendingToBCCAddress);
    Emailwithattch.setToaddresses(address);
    Emailwithattch.setPlainTextBody(body);            
    return Emailwithattch;
}

}