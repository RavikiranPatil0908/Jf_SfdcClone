@isTest

public class MassCreateDispatchOrderControllerTracker
{
    
    public static Stock_Keeping_Units__c objStock;
    
    static testMethod void singleUpdateTest() {
      Opportunity o = new Opportunity();
      List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
      
      ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
      setCtr.setSelected(new Opportunity[]{o});
        MassCreateDispatchOrderController controller = new MassCreateDispatchOrderController(setCtr);
    
    String value = '123test';
    controller.fieldName='name';
    controller.valueToUpdate=value;  
    //controller.convertedFieldData = controller.convertUserInputToFieldData(); 
    controller.step1();
    controller.step2(); 
    controller.step4();
   // controller.step5();
    controller.getStep();
    controller.InsertDipatchRecords(oppList );
    
    
      value ='123';
      controller.step3();
      controller.fieldName='amount';
      controller.valueToUpdate=value;  
      controller.step4();
     // controller.step5();
      controller.getLC();
      controller.getmapSkuByNameAndYear();
      controller.getLearingCenterOwner();
     
      
  
    }
   
  
}