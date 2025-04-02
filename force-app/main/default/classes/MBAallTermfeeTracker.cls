/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-26-2021   shubhranshu   Initial Version
**/
@isTest
public class MBAallTermfeeTracker
{   public static  nmSerialNo__c serial; 
    public static  Opportunity objOpp;
    public static  Opportunity objOpp2;
    public static  nm_Payment__c objPayment;
    public static  nm_Program__c objProgram;
    public static  Lead objLead;
    public static  List<Opportunity> opps;
    
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

    static  testmethod  void unitTestForMBAallTermfeeFee()
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
        //nm_StudentStatus__c='Confirmed',
        nm_Tagged_Pricebook__c=objpriceBook.id,
        nm_SerialNo__c=2,
        PersonMobilePhone='8377985662',
        PersonEmail='teste26@gmail.com') ; 
        Test.startTest();
        insert Acc; 
        opps = new List<Opportunity>();
  
        objProgram= new nm_Program__c ();
        objProgram.nm_ProgramCode__c='TestCode';
        objProgram.Name='MBAAF';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c='Degree Programs';
        objProgram.nm_ProgramName__c='MBAAF';
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;   
        objProgram.nmIsActive__c = true ;   
        insert objProgram;
       
        objOpp = new Opportunity();
        objOpp.StageName = 'Closed';
        objOpp.nm_Fee_Type__c = 'MBAallTermfee';
        objOpp.nm_Future_Sems_Created__c = false;  
        objOpp.Accountid = Acc.id;
        objOpp.CloseDate = system.today()+10;
        objOpp.Name = 'testOpp';
        objOpp.nm_Program__c = objProgram.id;
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
        

  
        
          

       
        MBAallTermfee controller=new MBAallTermfee ();
       // controller.getPaymentForOpportunity(objOpp.Id);
       // controller.getNextSemOpportunity(objOpp);
        boolean valid;
       List<Opportunity> lstOpp = [Select Id,Total_Sem__c,nm_Fee_Type__c,Sem__c ,nm_Session__c,PVM__c,nm_Year__c,nm_Semester__c, Name,AccountId,nm_Program2__c,nm_StudentProgram__c,nm_Program__c from Opportunity where Id =: objOpp.Id];
        if(lstOpp.size() > 0){
       // controller.getPaymentForOpportunity(lstOpp[0].Id);
        controller.getNextSemOpportunity(lstOpp[0],0,lstOpp[0].nm_Fee_Type__c);
        }
        List<Opportunity> lstOpp2 = [Select Id,Total_Sem__c,nm_Fee_Type__c,Sem__c ,nm_Session__c,PVM__c,nm_Year__c,nm_Semester__c, Name,AccountId,nm_Program2__c,nm_StudentProgram__c,nm_Program__c from Opportunity where Id =: objOpp.Id];
        if(lstOpp2.size() > 0){
        controller.getNextSemOpportunity(lstOpp2[0],1,lstOpp[0].nm_Fee_Type__c);
        
        }
        
       valid = controller.Validity(date.newinstance(2019,01,01),lstOpp[0],lstOpp2[0]);
        MBAallTermfee.updatefutureSessionyear (lstOpp[0].AccountId,2,'July',2019);
        MBAallTermfee.updatefutureSessionyear (lstOpp[0].AccountId,2,'September',2019);
        MBAallTermfee.updatefutureSessionyear (lstOpp[0].AccountId,2,'April',2019);
        MBAallTermfee.updatefutureSessionyear (lstOpp[0].AccountId,2,'June',2019);
        
        Test.stopTest();

    }


}