@isTest
private class MergeCourierShipmentControllerTracker
{
    
    static testMethod void singleUpdateTest()
    {
        Dispatch_Order__c o = new Dispatch_Order__c();
        List<Dispatch_Order__c> oppList = [SELECT id,name,Name_Of_Other_Courier_Service__c,
                                           Semester__c,From_Address__c,Address__c,Tracking_Number__c,Program__c
                                           FROM Dispatch_Order__c LIMIT 20];
      
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        setCtr.setSelected(new Dispatch_Order__c[]{o});
        MergeCourierShipmentController controller = new MergeCourierShipmentController(setCtr);
    
        controller.step1();
        controller.step2(); 
        controller.step3();
        controller.step4();
        controller.getStep();

        controller.GenerateIndiaPostPdf();
    }
}