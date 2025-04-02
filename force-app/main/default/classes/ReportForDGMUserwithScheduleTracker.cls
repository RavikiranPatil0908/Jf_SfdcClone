@isTest
public class ReportForDGMUserwithScheduleTracker
{

  
 
   static testMethod void test() 
    {
      SetUp();
      Test.StartTest();
      
      ReportForDGMUserwithSchedule instance = new ReportForDGMUserwithSchedule();
      Database.executeBatch(instance,100);
      Test.stopTest();
    } 

    static void SetUp(){
       Agency_Access__c objAgency = new Agency_Access__c();
      objAgency.Agency_Name__c = 'test';
      objAgency.Email__c = 'test@test.com';
      objAgency.EmailIdSet__c = 'test@test.com';
      objAgency.Is_Active__c = true;
      objAgency.password__c = 'test@2022';
      objAgency.Report_Id__c = '00OO0000000LhL7';
      objAgency.ScheduleReport__c = true;
      insert objAgency;
      system.debug('objAgency ==> ' + objAgency);
    }
}