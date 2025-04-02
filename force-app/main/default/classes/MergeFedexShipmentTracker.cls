@isTest
private class MergeFedexShipmentTracker
{
    
    static testMethod void singleUpdateTest()
    {
        Dispatch_Order__c o = new Dispatch_Order__c();
        List<Dispatch_Order__c> oppList = [SELECT id,name FROM Dispatch_Order__c LIMIT 20];
      
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        setCtr.setSelected(new Dispatch_Order__c[]{o});
        MergeFedexShipmentController controller = new MergeFedexShipmentController(setCtr);
    
        controller.step1();
        controller.step2(); 
        controller.numberOfPage = '1';
        controller.step3();
        controller.step4();
        controller.getStep();

        controller.MergeShipmentFedex(oppList);
    }
}