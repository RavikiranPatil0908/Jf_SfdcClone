/**
 * @File Name          : nmStudentProgramTriggerHandlerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 10/22/2019, 5:17:38 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/22/2019   shubhranshu     Initial Version
**/
@isTest
public class  nmStudentProgramTriggerHandlerTracker 
{
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_Program__c program;
    public static nm_StudentProgram__c objSP ;
    
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

    @testSetup
    public static void setUpData(){
		Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        program = nmGenericTracker.CreatePGDiplomaProgram();
        nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objSP = nmGenericTracker.CreatePGStudentProgram(objAccount);
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp); 
        
    }

    static testMethod void TestMethod1() 
    {  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
        nm_Program__c prog = [select ID from nm_Program__c limit 1];
        nm_StudentProgram__c studProg = [select ID, nm_Program__c from nm_StudentProgram__c limit 1];
        Account objAccount = [select id, nm_StudentStatus__c , BatchStartD__c from Account limit 1];
        objAccount.BatchStartD__c= Date.today();
        objAccount.nm_StudentStatus__c = 'Confirmed';
        update objAccount;
        Opportunity opp = [Select Id , nm_StudentProgram__c from Opportunity limit 1];
        opp.nm_StudentProgram__c = studProg.id;
        update opp;
        studProg.nm_Program__c = prog.id;
        update studProg;
        Test.StopTest();        
    }

    static testMethod void TestMethod2() 
    {  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
        nm_Program__c prog = [select ID from nm_Program__c limit 1];
        nm_StudentProgram__c studProg = [select ID, nm_Program__c from nm_StudentProgram__c limit 1];
        Opportunity opp = [Select Id , nm_StudentProgram__c from Opportunity limit 1];
        opp.nm_StudentProgram__c = studProg.id;
        update opp;
        studProg.nm_Program__c = prog.id;
        update studProg;
        Test.StopTest();        
    }

    static testMethod void TestMethod3() 
    {  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
        nm_Program__c prog = [select ID from nm_Program__c limit 1];
        nm_StudentProgram__c studProg = [select ID, nm_Program__c from nm_StudentProgram__c limit 1];
        Opportunity opp = [Select Id , nm_StudentProgram__c from Opportunity limit 1];
        opp.nm_StudentProgram__c = studProg.id;
        opp.StageName='Closed Won - Re-registration Pending';
        update opp;
        studProg.nm_Program__c = prog.id;
        update studProg;
        Test.StopTest();        
    }

  
    
}