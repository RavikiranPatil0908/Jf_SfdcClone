@isTest
private class Student_Course_Enrollment_in_BB_Tracker {
    
    static private nm_Program__c objProgram;
    static private Product2 objProduct;
    static private Account objAccount;
    static testMethod void myUnitTest() 
    {
        createProgram();
        createProduct();
        createAccount();
        
       
        String StartDate = '10/05/2014';
        
        String EndDate = '10/12/2014';
        ApexPages.currentpage().getparameters().put('StartDate',StartDate);
        ApexPages.currentpage().getparameters().put('EndDate',EndDate);
        
        Student_Course_Enrollment_in_BB obj = new Student_Course_Enrollment_in_BB();
        obj.getNewLine();
        Student_Course_Enrollment_in_BB.Wrapper obj1 = new Student_Course_Enrollment_in_BB.Wrapper();
        //another class
        String selectedYear = '2014';
        String session = 'July';
         ApexPages.currentpage().getparameters().put('selectedYear',selectedYear);
        ApexPages.currentpage().getparameters().put('session',session);
        Student_Deletion_from_BB objnew = new Student_Deletion_from_BB();
        objnew.getNewLine();
        objnew.GetData();
        
    }
    private static void createProgram()
    {
        objProgram = new nm_Program__c();
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c ='Certificate Programs';
        if( objProgram.nm_ProgramName__c == null)
        {
            objProgram.nm_ProgramName__c='MCA';
        }
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;
        system.assert(objProgram.id != null);       
                                       
    
    }
     private static void createAccount()
    {
        objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Confirmed';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonEmail='test@gmail.com';
        objAccount.PersonEmail = 'test@test.com';
        objAccount.PersonMobilePhone = '0123654789';
          
        insert objAccount;
        system.assert(objAccount.id != null);  
             
    }
    public static void createProduct()
    {       
        objProduct = new Product2();
        objProduct.Name = 'Registration Fee'; 
        objProduct.nm_Program__c=objProgram.id;
        insert objProduct;        
        system.assert(objProduct.id != null);        
        
    }
    
}