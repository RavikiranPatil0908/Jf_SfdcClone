/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : shubhranshu
**/
@istest
public class nmConnectCallTracker {
    static testMethod void TestMethod1() 
     {
         Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center']; 
         nm_Centers__c objCenter = new nm_Centers__c();
             
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
         
         SystemConfiguration__c objSc=new SystemConfiguration__c();
         objSc.Name='test';
         objSc.nm_ExotelSID__c='XCc1231';
         objSc.nm_ExotelToken__c='sdfsf232';
         objSc.nm_ExotelVirtualNumber__c='asdasd22';
         insert objSc;
         Lead objLead = new  Lead();
         objLead.nm_SelectedIC__c ='1';
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Hot';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Certificate Programs';
         //objLead.nm_Program__c = objP.Id;
         //objLead.nm_EligiblityCriteria__c = objEc.Id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='MCA';
         objLead.nm_InformationCenter__c =objcenter.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Walk -in';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=4;
         objLead.nm_RegistrationID__c='a0BN0000001FUdB';
         //objLead.nm_RegistrationNo__c='a0BN0000001FUdB';
         insert objLead;
         
         Task objtas=new Task();
         objtas.ActivityDate = Date.today().addDays(7);
         objtas.Subject='Sample Task';
         objtas.WhoId = objLead.id;
         //objtas.OwnerId = u.id;
         objtas.Status='In Progress';
         insert objtas;
        ApexPages.currentPage().getParameters().put('isFollowUp','True');
       ApexPages.currentPage().getParameters().put('id',objLead.id);
       ApexPages.currentPage().getParameters().put('type','Lead');
       nmConnectCall objnmConnect=new nmConnectCall();
       //objnmConnect.skip=false;
       objnmConnect.ConnectCall();
       objnmConnect.CallerNumber();
       
       
       
      
        //Test.startTest();
      // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
       //HttpResponse res = objnmConnect.sendRequest('test');
       //Test.stopTest();
     // objnmConnect.SaveDetail();
       objnmConnect.CheckCallStatus();
        objnmConnect.BackToLead();
       
     }
     static testMethod void TestMethod2() 
     {
        SystemConfiguration__c objSc=new SystemConfiguration__c();
         objSc.Name='test';
         objSc.nm_ExotelSID__c='XCc1231';
         objSc.nm_ExotelToken__c='sdfsf232';
         objSc.nm_ExotelVirtualNumber__c='asdasd22';
         insert objSc;
         
         Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center']; 
         nm_Centers__c objCenter = new nm_Centers__c();
             
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
         
        Account objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Confirmed';
        objAccount.PersonMobilePhone='9811806436';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonEmail = 'test@test.com';
        insert objAccount;
        
         Lead objLead = new  Lead();
         objLead.nm_SelectedIC__c ='1';
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Hot';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Certificate Programs';
         //objLead.nm_Program__c = objP.Id;
         //objLead.nm_EligiblityCriteria__c = objEc.Id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='MCA';
         objLead.nm_InformationCenter__c =objcenter.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Walk -in';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=3;
         objLead.nm_RegistrationID__c='a0BN0000001FUdB';
         //objLead.nm_RegistrationNo__c='a0BN0000001FUdB';
         insert objLead;
         ApexPages.currentPage().getParameters().put('isFollowUp','True');
       ApexPages.currentPage().getParameters().put('id',objAccount.id);
       ApexPages.currentPage().getParameters().put('type','Account');
       nmConnectCall objnmConnect=new nmConnectCall();
       objnmConnect.isDisabled = true;
       objnmConnect.CallerNumber();
       
       objnmConnect.ConnectCall();
        //Test.startTest();
      // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
       //HttpResponse res = objnmConnect.sendRequest('test');
       //Test.stopTest();
      // objnmConnect.SaveDetail();
        
        
        objnmConnect.CheckCallStatus();
        objnmConnect.BackToLead();
       
     }
     
}