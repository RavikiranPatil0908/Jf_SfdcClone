/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 08-31-2024
 * @last modified by  : @Ravi
**/
@isTest(SeeallData=false)
public class QuickSearchControllerTracker {
    
    
     @testSetup
    public static void setUpData() {
       	Lead lead1 = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        //lead1.Email = 'test123@mail.com';
        //update lead1;
    }
    
    @isTest
    static void doTest(){
        List<Lead> lstLead = [select id,Email,Name from lead limit 1];
        System.debug('lstLead ==>'+lstLead);
        Test.startTest();
        QuickSearchController.SearchResultWrapper sw = new QuickSearchController.SearchResultWrapper(lstLead[0].Id,'Lead',lstLead[0]);
        // QuickSearchController.RecordAccessWrapper sw1 = new QuickSearchController.RecordAccessWrapper('Lead',lstLead[0]);
        List<QuickSearchController.SearchResultWrapper> lst = new List<QuickSearchController.SearchResultWrapper>();
        lst.add(sw);

        QuickSearchController.searchRecords(lstLead[0].Email);
        QuickSearchController.searchRecords(lstLead[0].Name);
        QuickSearchController.checkForRecordAssess(new List<Id>{lstLead[0].Id}, lst);
       
        Test.stopTest();

    }
  
}