/**
 * @File Name          : Mass_Welcome.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 22-08-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    19/12/2019   @BK     Initial Version
**/
public class Mass_Welcome {
    public string startDate{get;set;}
    public string StudentNumber{get;set;}
    public string endDate{get;set;}
    public string startDT{get;set;}
    public string enddt {get;set;}
    public List<Account> results {get;set;}
    public List<Account> lstToDisplay {get;set;}

    public Mass_Welcome()
    {
        lstToDisplay =new List<Account>();
        results =new List<Account>();
        StudentNumber ='';
        if(ApexPages.currentPage().getParameters().get('studentNo') != Null && ApexPages.currentPage().getParameters().get('studentNo') != ''){
            StudentNumber = ApexPages.currentPage().getParameters().get('studentNo');
            system.debug('StudentNumber --> ' +StudentNumber);


            FindRecordsUsingStudentNo('Download');

            
        }
    }
    public PageReference search() {
        if(StudentNumber == '' || StudentNumber ==null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Student Number should not be empty');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{
            String result = FindRecordsUsingStudentNo('Download');
            if(result !=null)
            {
                return Page.nm_MassWelcomeLetter;
            }
        }
        return null;
    }

    public PageReference find() {
        if(StudentNumber == '' ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Student Number should not be empty');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{
             String result= FindRecordsUsingStudentNo('View');
             System.debug('Size of list --->'+lstToDisplay.size());
              return null;
        }
       
    }
    
    // public static List<Object> slice(List<Object> input, Integer ge, Integer l)
    // {
    // List<Object> output = input.clone();
    // for (Integer i = 0; i < ge; i++) output.remove(0);
    // Integer elements = l - ge;
    // while (output.size() > elements) output.remove(elements);
    // return output;
    // }


   public String FindRecordsUsingStudentNo( String TypeOfRequest)
    {
        // List<String> sliced =StudentNumber.split(',');
        system.debug(StudentNumber);
        List<String> listOfStudentNo =StudentNumber.split(',');
        lstToDisplay.clear();
        results.clear();
    //    system.debug(sliced.size() + ' $$$$$$$ size of sliced $$$$$$$');
    //    System.debug('lst of Student Numbers---->'+sliced );
        
        
        // List<String> listOfStudentNo = (List<String>)slice(sliced, 0, 500);
        
       system.debug(listOfStudentNo.size() + ' ##### size of listOfStudentNo ##########');
        System.debug('lst of Student Numbers---->'+listOfStudentNo.toString()  );
        try {
        results = [select id,nmStudent_Program__c,account.name,nm_StudentNo__c,Ref__c,LC_Name__c,nm_NewPassword__c,Salutation, FirstName,LastName,nm_StudentStatus__c,nm_ChooseaProgram__c,Program_Type__c
        from Account
        where nm_StudentNo__c IN :listOfStudentNo ];
        
        // results = [select id,account.name,nm_StudentNo__c,Ref__c,LC_Name__c,nm_NewPassword__c,Salutation, FirstName,LastName,nm_StudentStatus__c,nm_ChooseaProgram__c,Program_Type__c
        // from Account
        // where nm_StudentNo__c IN :listOfStudentNo LIMIT 500];
        // {
            // results = ;
            if(results.size()>0)
            {
                system.debug(results.toString() + 'resultsss');
                list<String> IdNotInList = new List<String>();
                list<String> lstOfStudentNo = new List<String>();
                list<Account> accountListInOrder = new List<Account>();
                for(Account result: results) {
                    lstOfStudentNo.add(result.nm_StudentNo__c);
                    
                    // for(String i : listOfStudentNo) {
                    //     if (i == result.nm_StudentNo__c) {
                    //         accountListInOrder.add(result);
                    //     }
                    // }
                    // system.debug(result.nm_StudentNo__c + ']]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');
                    // Boolean contain = listOfStudentNo.contains(result.nm_StudentNo__c);
                    // System.debug(contain + 'CONTAIN  ----------------');
                    // if(!contain) {
                    //     IdNotInList.add(result.nm_StudentNo__c);
                    //     system.debug(result.nm_StudentNo__c + 'ID Not in list');
                    //     system.debug('From Rersults ');
                    // }
                }
                for(String ids : listOfStudentNo) {
                    if(!lstOfStudentNo.contains(ids)) {
                        IdNotInList.add(ids);
                        system.debug(ids + 'ID Not in list');
                        system.debug('From Rersults ');
                    }
                    for(Account a: results) {
                        if (ids == a.nm_StudentNo__c) {
                            accountListInOrder.add(a);
                        }
                    }
                }
                
                system.debug(IdNotInList.toString() + 'NOT IN LIST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                // lstToDisplay.addAll(results);
                system.debug(accountListInOrder.toString() + 'ordered list ^^^^^^^^^^^^^^^^^^^');
                lstToDisplay.addAll(accountListInOrder);
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Stuch type Of Student Number Found');
                ApexPages.addMessage(myMsg);
            }
        // }
        // for(String StudentNo :listOfStudentNo)
        // {
        //     results = [select id,account.name,nm_StudentNo__c,Ref__c,LC_Name__c,nm_NewPassword__c,Salutation, FirstName,LastName,nm_StudentStatus__c,nm_ChooseaProgram__c,Program_Type__c
        //     from Account
        //     where nm_StudentNo__c =:StudentNo];
        //     if(results.size()>0)
        //     {
        //         system.debug(results.toString() + 'resultsss');
        //         lstToDisplay.addAll(results);
        //     }
        //     else
        //     {
        //         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Stuch type Of Student Number Found '+StudentNo);
        //         ApexPages.addMessage(myMsg);
        //     }
        // }
        if(TypeOfRequest =='Download' && lstToDisplay.size()>0)
        {
            return 'Page.nm_MassWelcomeLetter';
        }
        else{
            return null;
        }
        }catch(Exception e) {
            system.debug(e.getMessage() + 'NOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
            system.debug('EXECtiiiiiiiiiiiiiiiiiiiiiiiiiion');
            return null;
        }
        
    }    
}