/**
 * @File Name          : StudentMetricsTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 10/3/2019, 3:49:08 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/3/2019   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class StudentMetricsTracker
{   
    public static Account objAccount;
	public static Opportunity objOpp;

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
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
    }
    static testMethod void TestMethod1()
    {   
        Account objAccount = [select Id,sem1NoOfANS__c,sem1NoOfAssignSubmitted__c,sem2NoOfANS__c,sem2NoOfAssignSubmitted__c,sem3NoOfANS__c,sem3NoOfAssignSubmitted__c,
                              sem4NoOfANS__c,sem4NoOfAssignSubmitted__c,totalNoOfANS__c,totalNoOfAssignSubmitted__c from Account limit 1];
        objAccount.sem1NoOfANS__c =1;
        objAccount.sem1NoOfAssignSubmitted__c = 1;
        objAccount.sem2NoOfANS__c = 2;
        objAccount.sem2NoOfAssignSubmitted__c = 3;
        objAccount.sem3NoOfANS__c = 2;
        objAccount.sem3NoOfAssignSubmitted__c = 3;
        objAccount.sem4NoOfANS__c = 4;
        objAccount.sem4NoOfAssignSubmitted__c = 4;
        objAccount.totalNoOfANS__c = 9;
        objAccount.totalNoOfAssignSubmitted__c = 3;
        update objAccount;

        Opportunity objopp= [select Id , nm_Semester__c from Opportunity limit 1];
        objopp.nm_Semester__c ='2';
        update objopp;

        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(objAccount);
        StudentMetrics obj = new StudentMetrics(stdController);
    }
    static testMethod void TestMethod2()
    {
        Account objAccount = [select Id from Account limit 1];
        Opportunity objopp= [select Id , nm_Semester__c from Opportunity limit 1];
        objopp.nm_Semester__c ='3';
        update objopp;
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(objAccount);
        StudentMetrics obj = new StudentMetrics(stdController);
    }
    static testMethod void TestMethod3()
    {
        Account objAccount = [select Id from Account limit 1];
        Opportunity objopp= [select Id , nm_Semester__c from Opportunity limit 1];
        objopp.nm_Semester__c ='4';
        update objopp;
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(objAccount);
        StudentMetrics obj = new StudentMetrics(stdController);
    }
    static testMethod void TestMethod4()
    {
        Account objAccount = [select Id from Account limit 1];
        Opportunity objopp= [select Id , nm_Semester__c from Opportunity limit 1];
        objopp.nm_Semester__c ='1';
        update objopp;
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(objAccount);
        StudentMetrics obj = new StudentMetrics(stdController);
    }
    static testMethod void TestMethod5()
    {
        Account objAccount = [select Id from Account limit 1];
        Opportunity objopp= [select Id , nm_Semester__c from Opportunity limit 1];
        objopp.nm_Semester__c ='1';
        update objopp;
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(objAccount);
        StudentMetrics obj = new StudentMetrics(stdController);
        obj.navigateTo360();
    }
}