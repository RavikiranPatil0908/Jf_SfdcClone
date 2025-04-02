@isTest

public class MassleadupdateTracker
{
               
        public static nm_Centers__c objCenter;
        
        
      private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='[{"Message":"Number of pincode(s) found:2","Status":"Success","PostOffice":[{"Name":"Chembur","Description":null,"BranchType":"Head Post Office","DeliveryStatus":"Delivery","Circle":"Maharashtra","District":"Mumbai","Division":"Mumbai  North East","Region":"Mumbai","Block":"NA","State":"Maharashtra","Country":"India","Pincode":"400071"},{"Name":"Sindhi Society","Description":null,"BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Circle":"Maharashtra","District":"Mumbai","Division":"Mumbai  North East","Region":"Mumbai","Block":"NA","State":"Maharashtra","Country":"India","Pincode":"400071"}]}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

     static testMethod void singleUpdateTest2() {
     
   
        nm_Centers__c objCenter = new nm_Centers__c ();
       
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser; 
        
        objCenter = nmGenericTracker.CreateCenter('Mumbai - Muund'); 
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCenter.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
   
       
       
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Lead objLead1 = new Lead();
        Test.startTest();  
         List<Lead> objleadList1 = [SELECT name ,nm_ChooseaProgram__c ,id , nm_InformationCenter__c FROM Lead LIMIT 20];  
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(objleadList1);
        setCtr.setSelected(new Lead[]{objLead1 });
        Massleadupdate controller = new Massleadupdate(setCtr);
        allrows cntrl2 = new allrows();
            
        controller.step1();
        controller.step2(); 
         controller.LeadFieldAction = 'Center';
         controller.Center = objCenter.id; 
         controller.step3();
        controller.step4();
       
        controller.cancel();
        //ontroller.emailId ='phalguni.bhadarka@gmail.com';
        controller.getAllLeadStatus() ;
        controller.getAllCPprofile(); 
        controller.getAllCenter() ;
        controller.getAllCPprofileForCenter() ;
        
        controller.getActionList();
        controller.getStep() ;
        cntrl2.getLeadvalue();

        controller.MassupdateLeadList(objleadList1);

  Test.stopTest();
    }
     static testMethod void singleUpdateTest3() {
        Lead objlead = new Lead();
        List<Lead> objleadList = [SELECT name FROM Lead LIMIT 20];
          
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(objleadList);
        setCtr.setSelected(new Lead[]{objlead});
        Massleadupdate controller = new Massleadupdate(setCtr);
        allrows cntrl2 = new allrows();
        controller.LeadFieldAction = 'Status'; 

        String Status = 'Not Contacted-Old';
        //String LeadFieldAction = 'Status'; 
        //String Center
        //  controller.fieldName='name';
        //  controller.valueToUpdate=value;  
        controller.step1();
        controller.step2(); 
        controller.step4();
        controller.step3();
        controller.cancel();
        controller.getAllLeadStatus() ;
        controller.getAllCPprofile(); 
        controller.getAllCenter() ;
        controller.getActionList();
        controller.getStep() ;
        cntrl2.getLeadvalue();

        controller.MassupdateLeadList(objleadList );


    }
     
}