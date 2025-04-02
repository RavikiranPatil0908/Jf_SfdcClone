@isTest
public class MakeBookOrKitOrderTracker
{
    
        static testmethod void UnitTest1()
        {
          PageReference pg = new PageReference('/apex/MakeBookOrKitOrder');
         MakeBookOrKitOrderController  obj =new MakeBookOrKitOrderController();
         
         obj.selectedLaunchYearPG= 'JUL2014';
         obj.numberOfRegistrationsPG = 3000;   
         obj.ViewDetail();
         }


}