/**
 * @File Name          : nmRegistrationReceiptTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 6/6/2020, 3:53:24 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    24/1/2020   @BK     Initial Version
**/
@isTest (SeeAllData=false)
private class nmRegistrationReceiptTracker
{
    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
        
        objCustomSeetings3.name='0-1 Week';
        objCustomSeetings3.nm_LCEscalationTime__c='22:45';
        objCustomSeetings3.nm_RemidertoIC__c='22:45';
        objCustomSeetings3.nm_HOEscalationTime__c='20:56';
        objCustomSeetings3.nm_RemidertoHO__c='22:45';
        
        insert objCustomSeetings3;
        
        nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
        
        objCustomSeetings.name='2-4 Months';
        objCustomSeetings.nm_LCEscalationTime__c='20:45';
        objCustomSeetings.nm_RemidertoIC__c='21:45';
        objCustomSeetings.nm_HOEscalationTime__c='20:56';
        objCustomSeetings.nm_RemidertoHO__c='21:45';
        
        insert objCustomSeetings; 
        
        nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
        objCustomSeetings2.name='3-6 Week';
        objCustomSeetings2.nm_LCEscalationTime__c='20:34';
        objCustomSeetings2.nm_RemidertoIC__c='21:45';
        objCustomSeetings2.nm_HOEscalationTime__c='20:56';
        objCustomSeetings2.nm_RemidertoHO__c='21:45';
        insert objCustomSeetings2; 
        
        nm_Holidays__c objHoliday=new nm_Holidays__c();
        objHoliday.Name='Holi';
        objHoliday.nm_Date__c=system.today();
        insert objHoliday;
        
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        insert objSystemConfiguration;

        user usr = [Select id from user limit 1];
        
        nm_UserMapping__c objMap = new nm_UserMapping__c();
        objMap.nm_User__c =usr.id;
         
         
      //  Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
     
       // nm_Centers__c objcenter = new nm_Centers__c();
                 nm_Centers__c objcenter = nmGenericTracker.CreateCenter('Delhi'); 

       /* objcenter.RecordTypeID =rt.id;         
        objCenter.nm_CenterCode__c ='002';
        objCenter.nm_CenterCity__c='Delhi';
        objCenter.nm_City__c='Delhi';
        objCenter.nm_StateProvince__c='Delhi';
        objCenter.nm_Street__c='Laxmi Ngar';
        objCenter.nm_PostalCode__c='110091';         
        insert objCenter;*/
        
        Lead objLead = new Lead();
        objLead.Email='amit.kumasr@saasfocus.com';
        objLead.MobilePhone='9897789876';
        objLead.FirstName='sandy';
        objLead.LastName='babar';
        objLead.nm_BloodGroup__c='B+';
        objLead.nm_Gender__c='male';
       // objLead.nm_FathersName__c='subhash';
        //objLead.nm_MothersName__c='kalpana';
        objLead.nm_StateProvince_P__c='maharashtra';
        objLead.nm_Nationality__c='Indian';
        objLead.nm_Street_P__c='xyz';
        objLead.nm_LocalityName__c='mohitep';
        objLead.nm_SelfLearningMaterial__c='Send to my shipping address';
        objLead.nm_StudentStatus__c='Confirmed'; 
        objLead.nm_NameofBoard__c='CBSE';
        objLead.nm_10thPercentage__c=77.00;
        objLead.nm_NameofBoard__c='ICSC';
        objLead.nm_YearofCompletion__c='2000';
        objLead.nm_NameofSchool__c='nutan';
        objLead.nm_Class12OrDiploma__c='HSC';
        objLead.nm_NameofBoard12__c='LCSC';
        objLead.nm_YearofCompletion12__c='2002';
        objlead.nm_InformationCenter__c =objCenter.id; 
        objLead.nm_NameofSchool12__c='dfg';
        objLead.nm_Stream__c='adw';
        objLead.nm_BachelorsDegreeName__c='Bachelor of Applied Sciences';
        objLead.nm_Specialization__c='gf';
        objLead.nm_NameofUniversity__c='G K university';
        objLead.nm_BachelorsDegreePercentage__c=55.00;
        objLead.nm_GraduationDegreeMode__c='fgc';
        objLead.nm_YearofCollegeCompletion__c='2006';
        objLead.LeadSource='Web';
        // objLead.OwnerId=usr.id;
        insert objLead;
         
        nmGenericTracker.InsertSerialNo();
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Certificate Programs',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        nm_Payment__c objPayment_new = nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Installment');
        nmGenericTracker.CreateLateFeePaymentRecordForOppty(objopp);
        
        Validity_Extension__c objValEx = new Validity_Extension__c();
        objValEx.Batch_Name__c='JUL2015';
        objValEx.Expiry_Date_Of_Program__c='2020';
        objValEx.Mobile_Number__c='242343254326534';
        objValEx.Name_Of_Account__c='Fagu Babu';
        objValEx.Student_Number_Of_Account__c='77115000170';
        objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
        objValEx.Related_Account__c=objAccount.id;
        insert objValEx;

        nm_Centers__c center = nmGenericTracker.CreateCenter('Mumbai');

        Career_Service_Program__c csp = new Career_Service_Program__c();
        csp.Lead__c = objLead.Id;
        csp.Stage__c = 'Payment Done';
        insert csp;
    }

   
    private static testmethod void unit1()
    {  
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment = new nm_Payment__c(); 
            objPayment.nm_PaymentStatus__c = 'Payment approved';
            objPayment.nm_ModeOfPayment__c='Online';
            objPayment.nm_PaymentType__c = 'Additional Charge';
            objPayment.nm_Lead__c =objLead.id;
            insert objPayment; 

            ApexPages.currentPage().getParameters().put('id',objPayment.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }
    private static testmethod void unit2()
    {  
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment1=new nm_Payment__c(); 
            objPayment1.nm_PaymentStatus__c = 'Payment Made';
            objPayment1.nm_ModeOfPayment__c='Online';
            objPayment1.nm_PaymentType__c = 'Installment';
            objPayment1.nm_Lead__c =objLead.id;
            insert objPayment1;

            ApexPages.currentPage().getParameters().put('id',objPayment1.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }
    private static testmethod void unit3()
    {  
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment2=new nm_Payment__c(); 
            objPayment2.nm_PaymentStatus__c = 'Payment approved';
            objPayment2.nm_ModeOfPayment__c='Online';
            objPayment2.nm_PaymentType__c = 'Registration';
            objPayment2.nm_Lead__c =objLead.id;
            insert objPayment2;  
            ApexPages.currentPage().getParameters().put('id',objPayment2.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }
    private static testmethod void unit4()
    {  
        Validity_Extension__c objValEx = [SELECT id FROM Validity_Extension__c LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment2=new nm_Payment__c(); 
            objPayment2.nm_PaymentStatus__c = 'Payment approved';
            objPayment2.nm_ModeOfPayment__c='Online';
            objPayment2.nm_PaymentType__c = 'Validity Extension Fee';
            objPayment2.Validity_Extension__c =objValEx.id;
            insert objPayment2;  
            ApexPages.currentPage().getParameters().put('id',objPayment2.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }

    private static testmethod void unit5()
    {  
        nm_Payment__c objPayment_new = [SELECT id FROM nm_Payment__c WHERE nm_PaymentType__c='Installment' LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objPayment_new.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }

    
    private static testmethod void unit6()
    {  
        nm_Centers__c center = [SELECT id FROM nm_Centers__c LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment2=new nm_Payment__c(); 
            objPayment2.nm_PaymentStatus__c = 'Payment approved';
            objPayment2.nm_ModeOfPayment__c='Online';
            objPayment2.nm_PaymentType__c = 'COMMUNITY LICENSES FEE REGISTRATION';
            objPayment2.AEP__c = center.id;
            insert objPayment2;  
            ApexPages.currentPage().getParameters().put('id',objPayment2.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }

    private static testmethod void unit7()
    {  
        Career_Service_Program__c csp = [SELECT id FROM Career_Service_Program__c LIMIT 1];
        Test.startTest();
            nm_Payment__c objPayment2=new nm_Payment__c(); 
            objPayment2.nm_PaymentStatus__c = 'Payment approved';
            objPayment2.nm_ModeOfPayment__c='Online';
            objPayment2.nm_PaymentType__c = 'CAREER SERVICE';
            objPayment2.CareerServiceProgram__c =csp.id;
            insert objPayment2;  
            ApexPages.currentPage().getParameters().put('id',objPayment2.id);
            nmRegistrationReceipt obj = new nmRegistrationReceipt();
        Test.stopTest();
    
    }
    
}