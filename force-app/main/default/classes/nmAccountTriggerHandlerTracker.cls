/**
 * @File Name          : nmAccountTriggerHandlerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 29--03--2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/23/2019   shubhranshu     Initial Version
**/
@istest(SeeAllData=false)
public class nmAccountTriggerHandlerTracker{
    
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    public static void setUpData(){
       
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        nmGenericTracker.CreateICAndUser(nmGenericTracker.CreateCenter('Mumbai'));

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);

        // AEP_Request__c objAEPRequest = new  AEP_Request__c(Lead__c=objLead.Id);
        // insert objAEPRequest;

        Student_Rating__c studentRating = new Student_Rating__c();
        studentRating.Question_2_Student_Rating__c = '4';
        studentRating.Question_1_Student_Rating__c = '8';
        studentRating.Question_2_Student_Rating__c = '8';
        studentRating.Question_5_Student_Rating__c = 'Yes';
        studentRating.Question_3_Student_Rating__c = '8';
        studentRating.Question_4_Student_Rating__c = '4';
        studentRating.Q5_text__c = 'objLead.Id';
        studentRating.imageUpload__c = 'www.google.com';
        studentRating.nm_Lead__c = objLead.Id;
        
        insert studentRating;

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        nm_StudentProgram__c objSP = nmGenericTracker.CreatePGStudentProgram(objAccount);

        Account objAccount2 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Documents Re-submitted');
        objAccount2.nm_LeadId__c = objLead.Id;
        update objAccount2;
    
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');

        nm_Payment__c objPaymnt2 = nmGenericTracker.CreateAdmissionPaymentRecordForLead(objLead);
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);
        nmGenericTracker.CreateWorkExperienceForAccount(objAccount);
        nm_LinksForDocumentsLead__c objLeadDoc = nmGenericTracker.CreatedDocumentForLead(objLead,'Student Photograph');
        nm_LinksForDocuments__c objDoc= nmGenericTracker.CreateDocumentforAccount(objAccount,'Defence Document');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Student Photograph');
        
        // Business account
        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objAccount.nm_Centers__c;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        insert cp;
        
          Task objTask = new Task(Subject='Call Scheduling',Status='Not Started',Priority='Normal',Escalation_Level__c='1',Call_date__c=System.today(),Customer_number__c='8800000000',Student_Name__c='Test',Student_Email__c='test@gmail.com');
        insert objTask;
    }
     public static testMethod void TestMethod1()
    {
        Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
        Test.startTest();   
       List<Account> lstAcc = new List<Account>();
       objAccount.Shipping_Address_Choice__c = 'Shipping Address as Permanent Address';
       lstAcc.add(objAccount);
       nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
       obj.copyAddress(lstAcc);
       obj.IsNullOrEmpty( objAccount.Shipping_Address_Choice__c);
       obj.getMapAllCounsellor();
       obj.getNumberOfDays(DateTime.Now().AddDays(-15),DateTime.Now().AddDays(1) );
       Test.stopTest();
    }
    public static testMethod void TestMethod2()
    {
      
        Account objAccount = [select id,nm_SpouseName__c,LastName,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
        // nm_LinksForDocuments__c  objDoc =[Select id,Name from nm_LinksForDocuments__c where Name ='Student Photograph'  limit 1];
         string url = 'www.google.dom';
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        objAccount.nm_StudentStatus__c='Confirmed';
        
        objAccount.Extend_Validity_upto_Month__c ='June';
        objAccount.Extend_Validity_Upto_Year__c=2014;
        objAccount.nm_StudentNo__c='De-Registered_857858';
        update objAccount;
        nmAccountTriggerHandler.updateProfileonStudentZone(objAccount.id);
        nmAccountTriggerHandler.sendMobileNumberVerificationSMS(objAccount.id);
        nmAccountTriggerHandler.sendEmailVerificationMail(objAccount.id);
        nmAccountTriggerHandler.changeStudentImageLkD(objAccount.id, url);
        Test.stopTest();
    }
 public static testMethod void TestMethod3()
    {
        Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
        Test.startTest();   
        List<Account> lstAcc = new List<Account>();
       objAccount.Shipping_Address_Choice__c = 'Shipping Address as Billing Address';
       lstAcc.add(objAccount);
       objAccount.nm_DefencePersonnel__c ='Yes';
       update objAccount;
       nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
       obj.copyAddress(lstAcc);
     
       Test.stopTest();
    }   
    // test method for program2 changes .
    // public static testMethod void TestMethod4()
    // {
    //     Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
    //     Opportunity objopps = [Select id ,AccountId,nm_Program__c,PVM__c,Total_Sem__c,IsTerm__c ,LiveLecturesType__c,CourseList__c,ConsumerType__c,Program_Structure__c, ChooseProgram__c, Specialisation__c, nm_Fee_Type__c,stageName,Program_Name__c from Opportunity Limit 1];

    //     nm_Program__c prog = [select id ,nm_ProgramName__c from nm_Program__c limit 1];
    //     prog.nm_ProgramName__c= 'MBA(WX) in Marketing Management';
    //     update prog;

    //     Test.startTest();   
    //     Test.setMock(HttpCalloutMock.class, new RestMock());
    //     List<Account> lstAcc = new List<Account>();
    //     lstAcc.add(objAccount);
    //     objAccount.nm_Program2__c = prog.id;
    //     update objAccount;
    //     nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
    //     obj.Callproducthelper(objopps);
    //     obj.GetProgram(objopps);
     
    //     Test.stopTest();
    // }   
    
    public static testMethod void TestMethod7()
    {
        Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' AND nm_StudentStatus__c= 'Documents Re-submitted' limit 1];
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Map<id,Account> oldMap = new Map<id,Account>();
        List<Account> lstAcc = new List<Account>();

        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        oldMap.put(objAccount.id,objAccount);
        objAccount.nm_IsEmailVerified__c = true;
        objAccount.Is_Mobile_Verified__c = true;
        objAccount.nm_StudentStatus__c= 'Admission form & documents submitted';

        update objAccount;
        
        lstAcc.add(objAccount);
        obj.updateWorkExperiance(lstAcc);
        obj.UpdateMobileAndEmailVerifyDateTime(lstAcc,oldMap);
        obj.documentApproval(lstAcc,oldMap);
        Test.stopTest();
        
    }

    public static testMethod void testMethod8(){
        Account objAccount = [SELECT id,nm_Centers__c FROM Account WHERE Name!='Head Office' LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());

            nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai - Andheri');

            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User objUser = new User(Alias = 'new23use', Email='newuser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior12@testorg.com');
            insert objUser; 
                
            nm_UserMapping__c objUserMap= new nm_UserMapping__c();
            objUserMap.nm_Centers__c=objCen.id;
            objUserMap.nm_User__c=objUser.id;
            objUserMap.nm_Phone__c='32639215678';
            objUserMap.nm_Head__c= true;
            insert objUserMap;

            objAccount.nm_Centers__c = objCen.id;
            update objAccount;

        Test.stopTest();
    }

    public static testMethod void testMethod9() {
        Account objAccount = [SELECT id,Interview_Status__c,Program_Type__c,nm_ChooseaProgram__c,nm_Drive_Name__c FROM Account WHERE Name!='Head Office' LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            createPaymentFOrmConfiguration(objAccount.nm_ChooseaProgram__c,'Admission','1');
            objAccount.nm_Drive_Name__c = 'January2019';
            objAccount.Program_Type__c = 'MBA (WX)';
            objAccount.Interview_Status__c = 'Selected';
            update objAccount;

        Test.stopTest();
    }

    // //Create student rating from lead to account
    // public static testMethod void testMethod10()
    // {
    //     Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
    //     Lead objLead = [select id from Lead];
    //     List<Account> lstAccount = new List<Account>();
    //     Test.startTest();   
    //     Test.setMock(HttpCalloutMock.class, new RestMock());
    //     nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
    //     objAccount.nm_LeadId__c = objLead.Id;
    //     update objAccount;
    //     // lstAccount.add(objAccount);

    //     // Student_Rating__c studentRating = new Student_Rating__c();
    //     // studentRating.Question_2_Student_Rating__c = '4';
    //     // studentRating.Student__c = objAccount.Id;
    //     // studentRating.nm_Lead__c = objLead.Id;
    //     // insert studentRating;
        
    //     // obj.updateStudentRating(lstAccount);
    //     Test.stopTest();
    // }
    public static testMethod void testMethod11(){
        Account objAccount = [select id,Shipping_Address_Choice__c,nm_StudentStatus__c from Account where Name!='Head Office' and nm_StudentStatus__c='Documents Re-submitted' limit 1];
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new RestMock());
        objAccount.nm_StudentStatus__c = 'Admission form & documents Approved';
        update objAccount;
        Test.stopTest();
    }

    
    public static testMethod void TestMethod10()
    {
      
        Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
         string url = 'www.google.dom';
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        objAccount.nm_StudentStatus__c='Confirmed';
        objAccount.Extend_Validity_upto_Month__c ='June';
        objAccount.Extend_Validity_Upto_Year__c=2014;
        objAccount.nm_StudentNo__c='De-Registered_857858';
        update objAccount;
        nmAccountTriggerHandler.updateProfileonStudentZone(objAccount.id);
        nmAccountTriggerHandler.sendMobileNumberVerificationSMS(objAccount.id);
        nmAccountTriggerHandler.sendEmailVerificationMail(objAccount.id);
        nmAccountTriggerHandler.changeStudentImageLkD(objAccount.id, url);
        Test.stopTest();
    }

    public static NM_Payment_Form_Configuration__c  createPaymentFOrmConfiguration(String programCategory,String programType,String semester){
        NM_Payment_Form_Configuration__c objpaymentconfig = new NM_Payment_Form_Configuration__c();
        objpaymentconfig.Program_Category__c = programCategory;
        objpaymentconfig.Payment_Type__c =programType;
        objpaymentconfig.Semester__c= semester;
        objpaymentconfig.Current_Admission_Year__c = '2019';
        objpaymentconfig.No_Of_Applicable_Installment__c ='1';
        objpaymentconfig.Registration_Fee__c=1200;
        objpaymentconfig.Program_Type__c='MBA (WX)';
        objpaymentconfig.Reg_No_Allowed_After_End_Date__c = '01723456';
        objpaymentconfig.Capital_Float_AEP_Available__c = 'Mumbai,Pune';
        objpaymentconfig.Show_Registration_Payment_Option__c = true;
        objpaymentconfig.Show_Admission_Payment_Option__c = true;
        objpaymentconfig.ShowInitialAdmissionPayment__c = true;
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(5);
        objpaymentconfig.Initial_Admission_Payment__c = 1200;
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        objpaymentconfig.DownPayment_Amount__c = 5000;
        objpaymentconfig.Session__c = 'January';
        insert objpaymentconfig;
        return objpaymentconfig;
    }
    
    //  public static testMethod void testMethod12() {
    //     // Lead objLead = [SELECT Id FROM Lead LIMIT 1];
    //     List<Account> lstAccount = [SELECT id,nm_LeadId__c FROM Account WHERE Name!='Head Office' AND nm_StudentStatus__c='Documents Re-submitted' LIMIT 1 ];
    //     Test.startTest();
    //         Test.setMock(HttpCalloutMock.class, new RestMock());
    //         nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
    //         obj.updateAEPRequest(lstAccount);
    //     Test.stopTest();
    // }

    @isTest
    static void testMethod13() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,Shipping_Address_Choice__c,nm_StudentStatus__c from Account where Name!='Head Office' and nm_StudentStatus__c='Documents Re-submitted' limit 1];
        Test.startTest();
            insert new Process_Switches__c(SetupOwnerId=UserInfo.getOrganizationId(), Accounts_Process_ByPass__c=true);

            objAccount.nm_StudentStatus__c = 'Admission form & documents Approved';
            update objAccount;

            System.assertEquals('Admission form & documents Approved', objAccount.nm_StudentStatus__c, 'Expected status didn\'t get updated');
        Test.stopTest();
    }

    @isTest 
    static void testMethod14() {
        List<Account> lstAccount = [SELECT id,nm_LeadId__c FROM Account WHERE Name!='Head Office' AND nm_StudentStatus__c='Documents Re-submitted' LIMIT 1];
        Test.startTest();
            insertDEB(lstAccount[0].nm_LeadId__c);
            Test.setMock(HttpCalloutMock.class, new RestMock());
            nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
            // lstAccount[0].nm_LeadId__c = objLead.Id;
            obj.updateDEBDetails(lstAccount);
        Test.stopTest();
    }

    private static void insertDEB(Id leadId) {
        DEB_Detail__c objDEBDetails = new DEB_Detail__c(
            Student_ID__c = 'test',
            Program__c = 'test',
            Email__c = 'test@gmail.com',
            Student_Name__c = 'test',
            Father_Name__c = 'test',
            Mobile__c = '8822003300',
            DEB_Created_Date__c = 'test',
            Institute_Name__c = 'test',
            Institute_Id__c = 'test',
            IpAddress__c = 'test',
            Program_Code__c = 'test',
            Mode__c = 'test',
            Admission_Date__c = System.today(),
            Admission_Details__c = 'test',
            University_Name__c =  'test',
            Course_Name__c =  'test',
            ABCID__c =  'test',
            DEB_Unique_ID__c =  'test',
            Gender__c =  'test',
            Date_of_Birth__c = System.today(),
            Is_Active__c = true,
            Lead__c = leadId
        );
        insert objDEBDetails;
    }
    
     @isTest 
    static void testMethod15(){
        Test.startTest();
          
            Test.setMock(HttpCalloutMock.class, new RestMock());
            nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
            obj.getlstAllProgram();
        Test.stopTest();
    }
    
     @isTest 
    static void testMethod16(){
        Test.startTest();
          
            Test.setMock(HttpCalloutMock.class, new RestMock());
            nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
            obj.getMapOfProgramNameVsProgram();
        Test.stopTest();
    }


    @isTest
    static void TestMethod17(){
       Opportunity objopps = [Select id ,AccountId,nm_Program__c ,PVM__c,Total_Sem__c,IsTerm__c,LiveLecturesType__c,CourseList__c,ConsumerType__c,Program_Structure__c, ChooseProgram__c, Specialisation__c, nm_Fee_Type__c,stageName,Program_Name__c from Opportunity Limit 1];
        Test.startTest();   
       nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
       obj.Callproducthelper(objopps);
       obj.GetProgram(objopps);
       Test.stopTest();
    }
   
    @isTest
    static void testMethod18(){
        List<Account> lstAccount = [SELECT id, nm_ChooseaProgram__c FROM Account WHERE Name !='Head Office' LIMIT 1];
        Test.startTest();
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler(); 
        obj.addAdmissionCordinator(lstAccount);
        Test.stopTest();
    }
    
    @isTest
    static void testMethod19(){
        List<Account> lstAccount = [SELECT id, nm_ChooseaProgram__c,nm_Program__c FROM Account WHERE Name !='Head Office' LIMIT 1];
        Test.startTest();
        nmAccountTriggerHandler.updateAllOpportuinty(lstAccount[0].Id,lstAccount[0].nm_Program__c);
        Test.stopTest();
    }
    
    
}