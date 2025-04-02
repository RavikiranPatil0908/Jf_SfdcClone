@isTest

public class MassFedexShipmentControllerTracker
{
    
    static testMethod void singleUpdateTest() {
      Dispatch_Order__c o = new Dispatch_Order__c();
      List<Dispatch_Order__c> oppList = [SELECT id,name FROM Dispatch_Order__c LIMIT 20];
      
      ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
      setCtr.setSelected(new Dispatch_Order__c[]{o});
        MassFedexShipmentController controller = new MassFedexShipmentController(setCtr);
    
    String value = '123test';
    controller.fieldName='name';
    controller.valueToUpdate=value;  
    //controller.convertedFieldData = controller.convertUserInputToFieldData(); 
    controller.step1();
    controller.step2(); 
    controller.step4();
    controller.getStep();
     
    controller.CreateShipmentFedex(oppList );
    controller.FedexShipmentGetMethod('Test');
    
    
      value ='123';
      controller.step3();
      controller.fieldName='amount';
      controller.valueToUpdate=value;  
      controller.step4();
     // controller.step5();
    /*  controller.getLC();
      controller.getmapSkuByNameAndYear();
      controller.getLearingCenterOwner();*/
     
      
  
    }
   
  
}