/**
 * @File Name          : nmOpportunityTriggerHandlerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 11-26-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/24/2019   shubhranshu     Initial Version
**/
@istest (SeeAllData=false)
public class nmOpportunityTriggerHandlerTracker {
   
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
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
        insert new GrayQuestAPI__c(Client_id__c = 'test1', Client_Secret__c = 'test2',Grayquest_APILink__c ='www.google.com',API_KEY__c='test3',Name='GrayQuestLoanData',Slug__c='test4');
        insert new ZestMoneyAPI__c(client_id__c='test1',client_secret__c='test2',scope__c='test3',Authentication_API__c ='www.google.com',grant_type__c='test3',Name='Loan Application Data');
       nmSerialNo__c objSerial = new nmSerialNo__c();
        objSerial.nm_MaxGenratedNo__c=122355;
        objSerial.nm_name__c= 'Reference Number';
        insert objSerial;
        

        insert new nm_Courses__c(Name = 'Financial Institutions & Markets', Elective__c = 'Finance', Student_Zone_Course_Id__c = 224, Semester__c = 5);
        

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');      

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = objopp.nm_Program__c;
        product2.nm_Semester__c = '6';
        product2.isActive = true;
        insert product2;
        insert new nm_Courses__c(Name = 'Financial Institutions & Markets', Elective__c = 'Finance', Student_Zone_Course_Id__c = 456, nm_Semester__c = product2.Id, Semester__c = 6);
        OpportunityLineItem objLineItem = CreateOpportunityLineItem(objopp);
        nm_Payment__c   objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        //  Opportunity objopp2 = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won - Re-registration Pending','2',objAccount,'admission');

        nmGenericTracker.SetCalender('January',system.today(),system.today(),2017);        
        // nm_Payment__c   objPaymnt = nmGenericTracker.CreatePaymentRecordForOpportunity(objopp ,'Zest-DownPayment');      
        // IC_Change_Request__c objICChange = nmGenericTracker.CreateICChangeRequest(objopp );
        //  IC_Change_Request__c  objICChange2 = nmGenericTracker.CreateprogramChangeRequest(objopp );
         
        objopp.Opportunity_Status__c ='Hot';
        objopp.CourseList__c ='586,847,985';
        objopp.Opportunity_Description__c ='Arranging funds within a week or 10 days';
        objopp.History_Tracking__c  ='gres';
        objopp.Elective_Subject_Name__c  ='Financial Institutions & Markets';
        update objopp;
       
        System.debug('Opportunity__r.nm_Program__r.Name'+objopp.nm_Program__r.Name);
        Blob b = Blob.valueOf('Invoice');
        Attachment attach = new Attachment();
        attach.ParentId = objopp.id;      
        attach.body = b;            
        attach.Name = 'Invoice.pdf';      
        attach.OwnerId = UserInfo.getUserId();
        attach.IsPrivate = false;
        insert attach;

    }

    public static OpportunityLineItem CreateOpportunityLineItem(Opportunity objopp)
    {
        Product2 product = nmGenericTracker.CreateSemesterProduct(objopp);
        product.Name ='Career Development';
        update product;
        PriceBookEntry objPriceBookEntry = nmGenericTracker.CreatePriceBookEntry(product,12000);
        OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c =1000;
        insert objLineItem ;
        return objLineItem;
    }
    
    /*public  static testMethod void testFindDuplicateReceiptNumber2()
    {
        nm_Payment__c   objPayment = [select id ,nm_PaymentType__c,nm_PaymentStatus__c  from nm_Payment__c  where nm_PaymentType__c ='Admission' limit 1];
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
        List<nm_Payment__c> newlistpayment = new List<nm_Payment__c> ();
        newlistpayment.add(objPayment);
        Test.startTest();
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.FindDuplicateReceiptNumber('788864525','8798787');
        obj.UpdatePaymentAndSerialNum(newlistpayment,true);
        Test.stopTest();
    }
   
     public  static testMethod void testFindDuplicateReceiptNumber()
    {
        nm_Payment__c   objPayment = [select id ,nm_PaymentType__c,nm_PaymentStatus__c  from nm_Payment__c  where nm_PaymentType__c ='Admission' limit 1];
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
        List<nm_Payment__c> newlistpayment = new List<nm_Payment__c> ();
        newlistpayment.add(objPayment);
        Test.startTest();
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.FindDuplicateReceiptNumber('788854525','878787');
        obj.UpdatePaymentAndSerialNum(newlistpayment,false);
        Test.stopTest();
    }*/
    public static testMethod void testinsertStudentNoVer2()
    {
           Test.setMock(HttpCalloutMock.class, new RestMock());

        Opportunity objopp = [select id,nm_Session__c,nm_Year__c,StageName,nm_Semester__c,
        PVM__c,nm_Program__c,Program_Name__c,Specialisation__c,Total_Sem__c,
        ChooseProgram__c ,AccountID from Opportunity limit 1];
        Map<Id,Opportunity> oldmap= new Map<Id,Opportunity>();
        oldmap.put(objopp.id,objopp);
         Test.startTest();
        List<Opportunity> lstOpp = new List<Opportunity>();
        objopp.StageName = 'Closed Won';
        objopp.Processed__c = true;
        update objopp;
        lstOpp.add(objopp);
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        // obj.insertStudentNoVer2(lstOpp);
        obj.UpdateShare(lstOpp,oldmap);
        obj.getMapOfElectiveVsSubject();
        Test.stopTest();
    }
   
   public static testMethod void testFindDuplicateRefCode()
    {
    Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity objOpps = [select id from Opportunity limit 1];
        /*objAccount.Ref__c = '77216433684';
        update objAccount;*/
        Test.startTest();
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.FindDuplicateRefCode('77216433684');
        nmOpportunityTriggerHandler.updateProgramStatusForStudentOnStudentPortal('77216433684',objAccount.id,'Admission Cancelled');
        Test.stopTest();
       
    }
   
   public static testMethod void testFindDuplicateStudentNo()
    {
        Account objAccount = [select id,nm_LeadId__c from Account  limit 1];
        Opportunity objOpps = [select id,nm_Semester__c,Expiry_Session__c,Expiry_Year__c,nm_StudentProgram__c,nm_Program__c ,nm_Session__c ,nm_Year__c ,AccountId   from Opportunity limit 1];
        Test.startTest();
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        // obj.FindDuplicateStudentNo('77216433684','77216');
        obj.insertopportunity(objOpps,'January','2019');    
        Test.stopTest();
    }

    public static testMethod void testForTerm()
    {
        Opportunity objOpps = [select id,Term_Cleared__c  from Opportunity limit 1];
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<Id,Opportunity> mapofOldopp = new Map<Id,Opportunity>();
        mapofOldopp.put(objOpps.id,objOpps);
        Test.startTest();
        objOpps.Term_Cleared__c= 'No';
        update objOpps;
        lstOpp.add(objOpps);
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.RepeatTerm(lstOpp,mapofOldopp);
        Test.stopTest();
    }
    // public static testMethod void testUpdateICChangeStatusForPaymentApproved(){
    //    Test.setMock(HttpCalloutMock.class, new RestMock());
    //     Opportunity objOpp = [select id ,AccountId ,nm_StudentProgram__c,nm_Program__c,
    //     nm_StudentProgram__r.nm_Program__c,Program_Name__c,ChooseProgram__c,Specialisation__c,nm_Semester__c,
    //     StageName from Opportunity limit 1];
    //     IC_Change_Request__c  objICChange =[select id from IC_Change_Request__c  limit 1];
       
    //     Test.startTest();      
    //     nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
    //     obj.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpp);
    //     obj.UpdateICChangeStatusForPaymentApproved(objOpp,objICChange);
    //     Test.stopTest();
       
     
    // }
    //  public static testMethod void testUpdateprogramChangeStatusForPaymentApproved(){
    //    Test.setMock(HttpCalloutMock.class, new RestMock());
    //     Opportunity objOpp = [select id ,AccountId ,nm_StudentProgram__c,nm_Program__c,Program_Name__c,nm_Semester__c,
    //     nm_StudentProgram__r.nm_Program__c,ChooseProgram__c,
    //     Specialisation__c,StageName from Opportunity limit 1];
    //     IC_Change_Request__c  objICChange2 =[select id from IC_Change_Request__c  limit 1];
       
    //     Test.startTest();      
    //     nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
    //     obj.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpp);
    //     obj.UpdateICChangeStatusForPaymentApproved(objOpp,objICChange2);
    //     Test.stopTest();
    // }
   public static testMethod void testupdateProgramStatusForStudentOnStudentPortal()
    {
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
       Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
       ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
       StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        
        
        Test.startTest();
        
        ObjOpp.Opportunity_Status__c ='Hot';
        ObjOpp.Opportunity_Description__c ='Arranging funds within a week or 10 days';
        ObjOpp.History_Tracking__c  ='gres';
        
        update ObjOpp;
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.Validyear ('May', 2019);
        obj.GetProgram(ObjOpp);
        obj.MaxGenratedNo();
        obj.generatePassword();
  
        nmOpportunityTriggerHandler.updateProgramStatusForStudentOnStudentPortal(objAccount.nm_StudentNo__c,objAccount.id,'Admission Cancelled');
        nmOpportunityTriggerHandler.sendEmailWithAttachments(objopp.id,objAccount.id);
        //nmOpportunityTriggerHandler.CareerServiceProduct(ObjOpp.id,objAccount.id);
        Test.stopTest();
        /*ObjOpp.Opportunity_Status__c ='Hot';
        ObjOpp.Opportunity_Description__c ='Arranging funds within a week or 10 days';
        ObjOpp.History_Tracking__c  ='gres';
        
        update ObjOpp;
        
         ObjOpp.Opportunity_Status__c ='Cold';
        ObjOpp.Opportunity_Description__c ='Job change- Next drive';
        ObjOpp.History_Tracking__c  ='gres';
        
        update ObjOpp;*/
        
    }

    public static testMethod void testForCareerServiceProduct(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        nm_Payment__c pay = nmGenericTracker.CreatePaymentRecordForOpportunityApproved(ObjOpp,'Career Service');
        
        Test.startTest();
        ObjOpp.Career_Service__c ='Career Development';
        ObjOpp.Loan_Type__c='LiquiLoans';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;

        Career_Service_Package__c CP = new Career_Service_Package__c();
        CP.Package_Name__c = ObjOpp.Career_Service__c;
        CP.Group_Name__c ='Normal';
        insert CP;
      nmOpportunityTriggerHandler.UpdatefutureOpportunityCloseWon(objAccount.id,'2');
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='Propelld';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.nm_Session__c = 'April';
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate2(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='LiquiLoans';
        ObjOpp.nm_Session__c = 'September';
        ObjOpp.Loan_Application_Cancelled__c =true;
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate3(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.nm_Session__c = 'June';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate4(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.nm_Session__c = 'October';
        update ObjOpp;
        Test.stopTest();
       
    }
    
    public static testMethod void testForcallLoanStatusUpdate5(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.nm_Session__c = 'December';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate6(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.nm_Session__c = 'March';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate7(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        Test.startTest();
        ObjOpp.Loan_Type__c='GrayQuest';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.nm_Session__c = 'April';
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate8(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='Zest';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.nm_Session__c = 'April';
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate9(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='EzCred';
        ObjOpp.nm_Session__c = 'September';
        ObjOpp.Loan_Application_Cancelled__c =true;
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate10(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='EzCred';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.nm_Session__c = 'April';
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;
        Test.stopTest();
       
    }

    public static testMethod void testForcallLoanStatusUpdate11(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        
        Test.startTest();
        ObjOpp.Loan_Type__c='Avanse';
        ObjOpp.Loan_Approved__c=true;
        ObjOpp.nm_Session__c = 'April';
        ObjOpp.StageName ='Closed Won';
        update ObjOpp;
        Test.stopTest();
       
    }
    

    public static testMethod void testupdatehistorytracking(){
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
       Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,Opportunity_Status__c ,Opportunity_Description__c ,
                                       ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
                                       StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        Map<id, Opportunity> oldmap = new Map<id,Opportunity>();
         
          ObjOpp.Opportunity_Status__c ='Cold';
        ObjOpp.Opportunity_Description__c ='Job change- Next drive';
        update ObjOpp;
       
         oldmap.put(ObjOpp.id,ObjOpp);
         
        Test.startTest();
        ObjOpp.Opportunity_Status__c ='hot';
        ObjOpp.Opportunity_Description__c ='Job chang===e- Next drive';
        List<Opportunity> lstopportunity = new List<Opportunity>();
        lstopportunity.add(ObjOpp);
       
        update lstopportunity;
       nmOpportunityTriggerHandler instance =new  nmOpportunityTriggerHandler();
        instance.historyTrackingOnNextFollow(lstopportunity, oldmap);
        instance.OngoingSessionYear('January',2020);
        instance.OngoingSessionYear('April',2020);
        instance.OngoingSessionYear('July',2020);
        instance.OngoingSessionYear('October',2020);
        instance.OngoingSessionYear('September',2020);        
        instance.OngoingSessionYear('June',2020);
        instance.OngoingSessionYear('March',2020);
        instance.OngoingSessionYear('December',2020);

        
       
       
         Test.stopTest();
    }

    @IsTest
    static void UpdatePaymentAndSerialNumMethod1(){
        
        Test.startTest();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        // Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        nm_Payment__c nmPayment = [SELECT Id FROM nm_Payment__c LIMIT 1];
        nmPayment.Receipt_Number__c = null;
        nmPayment.nm_PaymentType__c = 'Admission';
        nmPayment.nm_PaymentStatus__c = 'Payment Approved';
        update nmPayment;
        lstPay.add(nmPayment);

        nmOpportunityTriggerHandler instance =new  nmOpportunityTriggerHandler();
        instance.UpdatePaymentAndSerialNum(lstPay, false);
        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.UpdatePaymentAndSerialNum(lstPay, true);
        
    }

     @IsTest
    static void UpdatePaymentAndSerialNumMethod2(){
        
        Test.startTest();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        // Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        nm_Payment__c nmPayment = [SELECT Id FROM nm_Payment__c LIMIT 1];
        nmPayment.Receipt_Number__c = null;
        nmPayment.nm_PaymentType__c = 'Admission';
        nmPayment.nm_PaymentStatus__c = 'Payment Approved';
        update nmPayment;
        lstPay.add(nmPayment);

        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.UpdatePaymentAndSerialNum(lstPay, true);
        
    }

    @IsTest
    static void UpdateOpportunityLineItemAfterFeetypeChangeMethod1(){
        
        Test.startTest();
        Map<id, Opportunity> oldmap = new Map<id,Opportunity>();
        List<Opportunity> lstopportunity = new List<Opportunity>();
        Opportunity opp = [SELECT ID, nm_Fee_Type__c,LiveLecturesType__c,CourseList__c, BacklogList__c FROM Opportunity LIMIT 1];
        oldmap.put(opp.Id, opp);
        opp.nm_Fee_Type__c = 'MultipleSemFee';
        opp.LiveLecturesType__c = 'Custom';
        opp.CourseList__c = '12,34,56';
        update opp;
        lstopportunity.add(opp);

        List<String> newValue = new List<String>{'53','58','45'};
        List<String> oldValue = new List<String>{'53','58','45','89'};
        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.UpdateOpportunityLineItemAfterFeetypeChange(lstopportunity, oldmap);
        instance1.checkCourseCountainAreTrue(oldValue, newValue);

        Test.stopTest();
        
    }


    @IsTest
    static void UpdateOpportunityLineItemAfterFeetypeChangeMethod2(){
        
        Test.startTest();
        Map<id, Opportunity> oldmap = new Map<id,Opportunity>();
        List<Opportunity> lstopportunity = new List<Opportunity>();
        Opportunity opp = [SELECT ID, nm_Fee_Type__c,LiveLecturesType__c,CourseList__c, BacklogList__c FROM Opportunity LIMIT 1];
        nm_Payment__c nmPayment = [SELECT Id FROM nm_Payment__c LIMIT 1];
        nmPayment.nm_OpportunityNew__c = opp.Id;
        nmPayment.nm_Merchant_Track_Id__c = '8468454684675464';
        nmPayment.nm_PaymentType__c = 'Live Lectures';
        update nmPayment;

        oldmap.put(opp.Id, opp);
        opp.nm_Fee_Type__c = 'MultipleSemFee';
        opp.LiveLecturesType__c = 'Custom';
        opp.CourseList__c = '';
        update opp;
        lstopportunity.add(opp);

        List<String> oldValue = new List<String>{'53','58','45'};
        List<String> newValue = new List<String>{'53','58','45','89'};

        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.UpdateOpportunityLineItemAfterFeetypeChange(lstopportunity, oldmap);
        instance1.checkCourseCountainAreTrue(oldValue, newValue);

        Test.stopTest();
        
    }


    @IsTest
    static void sendEmailWithAttachmentsMethod1(){
        
        Test.startTest();
        Opportunity opp = [SELECT ID, AccountId, nm_Fee_Type__c,LiveLecturesType__c,CourseList__c, BacklogList__c FROM Opportunity LIMIT 1];
        nm_Payment__c nmPayment = [SELECT Id FROM nm_Payment__c LIMIT 1];
        nmPayment.nm_OpportunityNew__c = opp.Id;
        nmPayment.nm_Merchant_Track_Id__c = '8468454684675464';
        nmPayment.nm_PaymentType__c = 'Zest-DownPayment';
        nmPayment.nm_PaymentStatus__c = 'Payment Made';
        update nmPayment;

        nmOpportunityTriggerHandler.sendEmailWithAttachments(opp.Id, opp.AccountId);

        Test.stopTest();
        
    }


    @IsTest
    static void ApproveReRegistrationAdmissionPaymentAfterPaymnetMadeMethod1(){
        
        Test.startTest();
        Opportunity opp = [SELECT ID, AccountId,nm_Semester__c, nm_Fee_Type__c,LiveLecturesType__c,CourseList__c, BacklogList__c,nm_StudentProgram__c,nm_Program__c FROM Opportunity LIMIT 1];
        nm_Program__c nmProgram = nmGenericTracker.CreateDiplomaProgram();
        opp.CourseList__c = '';
        update opp;
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        objCR.Name = 'Name-dfghfh';
        objCR.Student__c = opp.AccountId;
        objCR.Opportunity__c = opp.Id;
        objCR.nm_TypeofRequest__c = 'Program Change';
        objCR.New_Program__c = nmProgram.Id;
        insert objCR;

        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(opp);

        Test.stopTest();
        
    }

    @IsTest
    static void ApproveReRegistrationAdmissionPaymentAfterPaymnetMadeMethod2(){
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'newUser', Email='newuser12345@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser; 
        nm_Centers__c nmCenter = [SELECT Id From nm_Centers__c LIMIT 1];
        nmCenter.OwnerId = UserInfo.getUserId();
        update nmCenter;
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
      objUserMap.nm_Centers__c=nmCenter.id;
      objUserMap.nm_User__c=UserInfo.getUserId();
      objUserMap.nm_Phone__c='326392156';
    //   objUserMap.nm_Head__c= true;
      insert objUserMap;
        Opportunity opp = [SELECT ID, AccountId,nm_Semester__c, nm_Fee_Type__c,LiveLecturesType__c,CourseList__c, BacklogList__c,nm_StudentProgram__c,nm_Program__c FROM Opportunity LIMIT 1];
        nm_Program__c nmProgram = nmGenericTracker.CreateDiplomaProgram();
        opp.CourseList__c = '';
        update opp;

        Account objAccount = [SELECT Id, OwnerId FROM Account WHERE ID = :opp.AccountId];
        system.debug('objAccount ---> ' + objAccount);
        Account nmAccount = new Account();
        nmAccount.Id = objAccount.Id;
        nmAccount.nm_NameOfCollege__c = 'objAccount.Id';
        // nmAccount.nm_Centers__c = nmCenter.Id;
        // nmAccount.Owner =objUser;
        // nmAccount.OwnerId = UserInfo.getUserId();
        update nmAccount;


        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        objCR.Name = 'Name-dfghfh';
        objCR.Student__c = opp.AccountId;
        objCR.Opportunity__c = opp.Id;
        objCR.nm_TypeofRequest__c = 'IC Change';
        objCR.Status__c = 'Approved';
        objCR.New_Program__c = nmProgram.Id;
        objCR.New_Information_Center__c = nmCenter.Id;
        insert objCR;

        nmOpportunityTriggerHandler instance1 =new  nmOpportunityTriggerHandler();
        instance1.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(opp);

        Test.stopTest();
        
    }

    @IsTest
    static void unitTestOnCaptureLoanStatusChangeDates(){ 
        Test.startTest(); 

            Opportunity opp = [SELECT id,Loan_Order_Id__c,Loan_Approved__c,Loan_Sanctioned__c,Loan_Application_Cancelled__c FROM Opportunity LIMIT 1];
            opp.Loan_Order_Id__c = '123456789';
            opp.Loan_Approved__c = true;
            opp.Loan_Sanctioned__c = true;
            opp.Loan_Application_Cancelled__c = true;
            update opp;
            
        Test.stopTest();
    }

    @isTest
    static void unitTestOnHistoryTrackingOnNextFollow() {
        Opportunity opp = [SELECT id,Opportunity_Status__c,Opportunity_Description__c,No_Of_Attempt__c,History_Tracking__c FROM Opportunity LIMIT 1];
        Test.startTest();
            opp.Opportunity_Status__c = 'Hot';
            opp.Opportunity_Description__c = 'Will Re-register in a week or 10 days';
            opp.Next_Follow_Up_Date_Time__c = System.now().addDays(1);
            opp.No_Of_Attempt__c = null;
            update opp;
            System.assertEquals(true, String.isNotBlank(opp.History_Tracking__c), 'Opportunity not captured the Status update history in the history tracking field.');
        Test.stopTest();
    }
   
}