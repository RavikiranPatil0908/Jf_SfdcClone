/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-01-2025
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class nmMultipleFeeTracker
{   public static nmSerialNo__c serial;
    public static Account objAccount; 
    public static  Opportunity objOpp;
    public static  Opportunity objOpp2;
    public static  nm_Payment__c objPayment;
    public static nm_Program__c objProgram;
    public static Lead objLead;
    public static List<Opportunity> opps;

    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static  testmethod  void unitTestForMultipleFee()
    {       
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Product2 objProduct = new Product2();
        objProduct = CommonTrackerClass.createProduct(objProduct);
        Pricebook2 objpriceBook;
        objpriceBook =CommonTrackerClass.createPricebook();
        PricebookEntry objPBE;
        string strrecord = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1].id;
        Account Acc = new Account(
        RecordTypeID=strrecord,
        FirstName='jane',
        LastName='doe',
        nm_PreStudentNo__c ='77213',
       // nm_StudentStatus__c='Admission form & documents submitted',
        nm_Tagged_Pricebook__c=objpriceBook.id,
        nm_SerialNo__c=2,
        PersonMobilePhone='8377985662',
        PersonEmail='teste26@gmail.com') ; 
        Test.startTest();
        insert Acc; 
        opps = new List<Opportunity>();
  
        objProgram= new nm_Program__c ();
        objProgram.nm_ProgramCode__c='TestCode';
        objProgram.Name='DSCM';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c='Diploma Programs';
        objProgram.nm_ProgramName__c='DSCM';
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;   
        objProgram.nmIsActive__c = true ;   
        insert objProgram;
       
        objOpp = new Opportunity();
        objOpp.StageName = 'Closed';
        objOpp.nm_Fee_Type__c = 'MultipleSemFee';
        objOpp.nm_Future_Sems_Created__c = false;  
        objOpp.Accountid = Acc.id;
        objOpp.nm_Program__c = objProgram.id;
        objOpp.CloseDate = system.today()+10;
        objOpp.Name = 'testOpp';
        objOpp.nm_Session__c = 'January';
        objOpp.nm_Year__c =2014;
        objOpp.nm_Semester__c = '2';
        
   
        insert objOpp;
   
        objPayment = new nm_Payment__c();
        objPayment.nm_OpportunityNew__c =objOpp.id; 
        objPayment.nm_PaymentType__c ='Admission';
        objPayment.nm_Amount__c = 15500;
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        insert objPayment;
        
        objOpp.StageName = 'Closed Won';
        update objOpp;
        

         objLead = new  Lead();
         objLead.nm_SelectedIC__c ='Mumbai';
         objLead.LastName ='nn';
         objLead.FirstName='mnn';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Reborn';
         objLead.Email='mayurnagaonkar222@gmail.com';
         objLead.MobilePhone ='8377985221';
         objLead.nm_ChooseaProgram__c ='Diploma Programs';
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='MCA';
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Walk -in';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=8;
         objLead.nm_RegistrationID__c='a0BN0000001FUdB';
         insert objLead;
        
         
         nmMultipleFee  controller=new nmMultipleFee  ();
        
        List<Opportunity> lstOpp = [Select Id,nm_Session__c,nm_Year__c,nm_Semester__c, Name,AccountId,nm_StudentProgram__c,nm_Program__c  from Opportunity where Id =: objopp.Id];
        if(lstOpp.size() > 0){
        controller.getPaymentForOpportunity(lstOpp[0].Id);
        controller.getNextSemOpportunity(lstOpp[0]);
        }
        List<Opportunity> lstOpp2 = [Select Id,nm_Session__c,nm_Year__c,nm_Semester__c, Name,AccountId,nm_StudentProgram__c,nm_Program__c  from Opportunity where Id =: objopp.Id];
        if(lstOpp2.size() > 0){
        controller.getNextSemOpportunity(lstOpp2[0]);
        
        }

    }


}