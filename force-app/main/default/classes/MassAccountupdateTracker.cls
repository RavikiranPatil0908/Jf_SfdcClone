@isTest

public class MassAccountupdateTracker
{
        static testMethod void singleUpdateTest() {
        Account objAccount = new Account();
        List<Account> objAccountList = [SELECT name FROM Account LIMIT 20];
          
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(objAccountList);
        setCtr.setSelected(new Account[]{objAccount});
        MassAccountupdate controller = new MassAccountupdate(setCtr);
        allrows cntrl2 = new allrows();
        controller.AccountFieldAction = 'CPprofile'; 

        String CPprofile = 'Not Contacted-Old';
        controller.step1();
        controller.step2(); 
        controller.step4();
        controller.step3();
        controller.cancel();
       // controller.getAllAccountStatus() ;
        controller.getAllCPprofile(); 
        controller.getAllCenter() ;
        controller.getActionList();
        controller.getStep() ;
      //  cntrl2.getAccountvalue();

        controller.MassupdateAccountList(objAccountList );


    }
}