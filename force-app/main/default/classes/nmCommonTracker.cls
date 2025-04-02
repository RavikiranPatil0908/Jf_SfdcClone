@istest
public class nmCommonTracker {
     
    static testMethod void TestMethod1() 
     {
         SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
          objSystemConfiguration.Name ='012213';
          objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
          //objSystemConfiguration.LastModifiedDate=system.today().addMonths(3);
          insert objSystemConfiguration;
          update objSystemConfiguration;
         String test = null; 
        nmCommon objnmCommon=new nmCommon();
        objnmCommon.generateChallan();
        nmCommon.getConfigSettings('nm_BusinessHoursStartTime__c');
        //nmCommon.isNullOrEmpty('test');
        nmCommon.isNull('test');
        nmCommon.isNullOrEmpty(System.today());
        nmCommon.isNullOrEmpty(test);
      nm_SystemConfiguration__c objSystemConfiguration2=new nm_SystemConfiguration__c();
        objSystemConfiguration2.nm_LastGeneratedChalanNumber__c = 1;
        insert objSystemConfiguration2;
        
        nmCommon objnmCommon2 = new nmCommon();
        objnmCommon2.generateChallan();
     }
     
     static testMethod void TestMethod2() 
     {
        nm_SystemConfiguration__c objSystemConfiguration=new nm_SystemConfiguration__c();
        objSystemConfiguration.nm_LastGeneratedChalanNumber__c = 0;
        insert objSystemConfiguration;
        
        nmCommon objnmCommon = new nmCommon();
        objnmCommon.generateChallan();
     }
     
     static testMethod void TestMethod3() 
     {
        nm_SystemConfiguration__c objSystemConfiguration=new nm_SystemConfiguration__c();
        objSystemConfiguration.nm_LastGeneratedChalanNumber__c=1;
        insert objSystemConfiguration;
        
        nmCommon objnmCommon = new nmCommon();
        objnmCommon.generateChallan();
     }
     
     static testMethod void TestMethod4() 
     {
        nm_SystemConfiguration__c objSystemConfiguration=new nm_SystemConfiguration__c();
        objSystemConfiguration.nm_LastGeneratedChalanNumber__c=2;
        insert objSystemConfiguration;
        
        nmCommon objnmCommon = new nmCommon();
        objnmCommon.generateChallan();
     }
     
     static testMethod void TestMethod5() 
     {
        nm_SystemConfiguration__c objSystemConfiguration=new nm_SystemConfiguration__c();
        objSystemConfiguration.nm_LastGeneratedChalanNumber__c=3;
        insert objSystemConfiguration;
        
        nmCommon objnmCommon = new nmCommon();
        objnmCommon.generateChallan();
     }
    
}