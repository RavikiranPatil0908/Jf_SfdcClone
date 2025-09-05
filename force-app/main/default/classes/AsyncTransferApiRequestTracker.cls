/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : @Shailesh
**/
@istest(SeeAllData=false)
public class AsyncTransferApiRequestTracker {
    @testSetup
    public static void setUpData(){
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account objAccount2 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Documents Re-submitted');
        objAccount2.nm_LeadId__c = objLead.Id;
        update objAccount2;
        API_Request__c apiObj = new API_Request__c();
        apiObj.Lead__c = objLead.Id;
        insert apiObj;
    }

    @isTest
    public static void TestMethod1()
    {
        Account objAccount = [select id,nm_LeadId__c from Account limit 1];
        Test.startTest();   
       List<Account> lstAcc = new List<Account>();
  
       lstAcc.add(objAccount);
    //    nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
    //    obj.updateTranferApirequestfromLeadtoAcc(lstAcc);
       System.enqueueJob(new AsyncTransferApiRequest(lstAcc));
       Test.stopTest();
    }
}