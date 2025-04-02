public class MassUpdateWelcomeKitController {
public String listOfStudentNumbers{get;set;}
public String typeOfUpdate{get;set;}
public List<SelectOption> getOptionList{get;set;}
public List<SelectOption> getSemesterList{get;set;}
public String semesterValue{get;set;}
public Boolean isErrorAlreadyCalled;
    
    public MassUpdateWelcomeKitController()
    {
         listOfStudentNumbers = ''; 
         semesterValue = '';
         typeOfUpdate = '';  
        isErrorAlreadyCalled = false;
               
    }
    public List<SelectOption> getOptionList()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','-None-'));
        optionList.add(new SelectOption('Hard Copy Recieved','Hard Copy Recieved'));
        optionList.add(new SelectOption('Welcome Kit','Welcome Kit'));
        optionList.add(new SelectOption('Fee Receipt','Fee Receipt'));
        optionList.add(new SelectOption('Letter Of UnderTaking','Letter Of UnderTaking'));
        optionList.add(new SelectOption('Program Change Waive Off','Program Change Waive Off'));
        
        return optionList;
    }
    public List<SelectOption> getSemesterList()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','-None-'));
        optionList.add(new SelectOption('1','Semester 1'));
        optionList.add(new SelectOption('2','Semester 2'));
        optionList.add(new SelectOption('3','Semester 3'));
        optionList.add(new SelectOption('4','Semester 4'));
        return optionList;
    }
    public void UpdateStudentNumber()
    {
        List<Account> listOfStudents = new List<Account>();
        List<Account> listOfStudents2 = new List<Account>();
        List<Account> emptyListOfAccountToUpdate = new List<Account>();
         
        List<Opportunity> emptyListOfOpportunityToUpdate = new List<Opportunity>();
        List<Opportunity> listOfOpportunity = new list<Opportunity>();
        System.debug('Selected Value-->'+typeOfUpdate);
        if(listOfStudentNumbers!='')
        {
            List<String> lstOfStudentNumbers = listOfStudentNumbers.split(',');
            set<String> setOfStudentNumbers = new set<String>();

            for (String studentNo : lstOfStudentNumbers) {
                setOfStudentNumbers.add(studentNo.trim());
            }
            if(typeOfUpdate =='Welcome Kit')
            {
                listOfStudents = [select id,Welcome_Kit_dispatched__c from Account where nm_StudentNo__c in :setOfStudentNumbers];
                if(listOfStudents!=null && listOfStudents.size()>0)
                {
                    for(Account acc :listOfStudents)
                    {
                        acc.Welcome_Kit_dispatched__c = true;
                        emptyListOfAccountToUpdate.add(acc);
                    }
                }
                update emptyListOfAccountToUpdate;
            }
          
             if(typeOfUpdate =='Hard Copy Recieved')
            {
                listOfStudents2 = [select id,Hard_copy_recieved__c from Account where nm_StudentNo__c in :setOfStudentNumbers];
                if(listOfStudents2!=null && listOfStudents2.size()>0)
                {
                    for(Account acc :listOfStudents2)
                    {
                        acc.Hard_copy_recieved__c = true;
                        emptyListOfAccountToUpdate.add(acc);
                    }
                }
                update emptyListOfAccountToUpdate;




           }
            
            else if(typeOfUpdate == 'Fee Receipt')
            {
                listOfOpportunity = [select id,Fee_Receipt_Dispatched__c,Fee_Receipt_Dispatched_Date__c from Opportunity where nm_Semester__c =:semesterValue and Account.nm_StudentNo__c in :setOfStudentNumbers];
                if(listOfOpportunity!=null && listOfOpportunity.size()>0)
                {
                    for(Opportunity o :listOfOpportunity)
                    {
                        o.Fee_Receipt_Dispatched__c = true;
                        o.Fee_Receipt_Dispatched_Date__c = Date.today();
                        emptyListOfOpportunityToUpdate.add(o);
                    } 
                }
                update emptyListOfOpportunityToUpdate;                
            }
            else if(typeOfUpdate =='Letter Of UnderTaking')
            {
                listOfStudents = [select id,Letter_Of_Undertaking__c from Account where nm_StudentNo__c in :setOfStudentNumbers];
                if(listOfStudents!=null && listOfStudents.size()>0)
                {
                    for(Account acc : listOfStudents)
                    {
                        acc.Letter_Of_Undertaking__c = true;
                        emptyListOfAccountToUpdate.add(acc);
                    }
                    update emptyListOfAccountToUpdate;
                }
            
            } else if(typeOfUpdate == 'Program Change Waive Off') {
                listOfStudents = [select id,Welcome_Kit_dispatched__c from Account where nm_StudentNo__c in :setOfStudentNumbers];
                List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                String MyProflieName = PROFILE[0].Name;
                if(MyProflieName == 'Head Office' || MyProflieName == 'System Administrator' ) {
                    if(listOfStudents!=null && listOfStudents.size()>0)
                    {
                        for(Account acc :listOfStudents)
                        {
                            acc.Program_Change_Waive_Off__c	 = true;
                            emptyListOfAccountToUpdate.add(acc);
                        }
                    }
                    update emptyListOfAccountToUpdate;
                } else {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to change Program Change Waive Off');
                    ApexPages.addMessage(myMsg);
                    isErrorAlreadyCalled = true;
                }
            }
        }
        if(!isErrorAlreadyCalled) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Records Updated Successfully');
            ApexPages.addMessage(myMsg);

        }
        
    }
}