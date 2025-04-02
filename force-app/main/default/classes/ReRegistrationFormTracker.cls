/**
 * @File Name          : ReRegistrationFormTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 02-20-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    14/3/2020   @BK     Initial Version
**/
@isTest (seeAllData=false)
public class ReRegistrationFormTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {}
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '[{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockIII implements HttpCalloutMock {
        RestMockIII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"results":[{"address_components":[{"long_name":"400071","short_name":"400071","types":["postal_code"]},{"long_name":"Mumbai","short_name":"Mumbai","types":["locality","political"]},{"long_name":"Mumbai Suburban","short_name":"Mumbai Suburban","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Mumbai, Maharashtra 400071, India","geometry":{"bounds":{"northeast":{"lat":19.0655906,"lng":72.9148502},"southwest":{"lat":18.9954075,"lng":72.8821864}},"location":{"lat":19.0521122,"lng":72.900668},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.0655906,"lng":72.9148502},"southwest":{"lat":18.9954075,"lng":72.8821864}}},"place_id":"ChIJSRSq41fP5zsR4Pem72Pkgv0","postcode_localities":["Chedda Nagar","Chembur","Kurla","Kurla","Trombay"],"types":["postal_code"]}],"status":"OK"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.CreateICAndUser(nmGenericTracker.CreateCenter('Mumbai'));
        nm_EligiblityCriteria__c objEc = createElegibilityCriteria('Post Graduate Diploma Programs');
        // nmGenericTracker.SetCalender('July',System.today(),System.today(),System.Today().year());
        setCalender('July',System.today(),System.today(),System.Today().year(),'Admission','1','Post Graduate Diploma Programs');
        setCalender('July',System.today(),System.today(),System.Today().year(),'Re-Registration','2','Post Graduate Diploma Programs');
        setCalender('July',System.today(),System.today(),System.Today().year(),'Re-Registration','3','Post Graduate Diploma Programs');
        nmGenericTracker.CreateDiplomaProgram();
        createElegibilityCriteria('Diploma Programs');
        
        nmSerialNo__c objSerialNo = nmGenericTracker.InsertSerialNo();
        nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        nm_StudentProgram__c objStudentprg = createStudentProgram(objAccount);
        Opportunity objOPP = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Pending Payment','2','Post Graduate Diploma Programs',objAccount,'PGAllSemFee-Considered');

        Product2 registrationproduct = nmGenericTracker.CreateRegistrationProduct(objOPP );     
        nmGenericTracker.CreatePriceBookEntry(registrationproduct,1200);
        nmGenericTracker.CreateOpportunityLineItem(objOPP);
        nmGenericTracker.CreateWorkExperienceForAccount(objAccount);
        
        createprogramChangeRequest(objOPP,objAccount.nm_Program__c);
        insertInvalidProgram(objAccount.Id);
        insertProduct('Program Change Fee',2000.00,objAccount.nm_Tagged_Pricebook__c,null,null);
        insertProduct('Semester II',20000.00,objAccount.nm_Tagged_Pricebook__c,objAccount.nm_Program__c,'2');
        insertProduct('Semester III',20000.00,objAccount.nm_Tagged_Pricebook__c,objAccount.nm_Program__c,'3');
    }

    @isTest
    static void unitTest1() {
        Account objAccount = [SELECT id,nm_Centers__c FROM Account LIMIT 1];
        nm_EligiblityCriteria__c objEc = [SELECT id FROM nm_EligiblityCriteria__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            // Test.setMock(HttpCalloutMock.class, new RestMockIII());

            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
            
            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.chooseProgram = 'Post Graduate Diploma Programs';
            objForm.address.postalcode = '400071';
            objForm.strSelectedEligiblity = objEc.Id;
            objForm.getSelfLearningMaterial();
            objForm.getShippingOption();
            objForm.updateAddressDetails();
            objForm.logout();
            // objForm.getUniversityList();
            objForm.getGraduationDegreeMode();
            objForm.getBachelorsDegreeName();
            objForm.AddExperience();
            objForm.RemoveExperience();
            objForm.getWorkExpTimeList();
            objForm.yearsEligibility = 2;
            objForm.getWorkExpTimeList();
            objForm.callValidate();
        Test.stopTest();
    }

  

    @isTest
    static void unitTest11() {

        Account objAccount = [SELECT id,nm_Centers__c FROM Account LIMIT 1];
        nm_EligiblityCriteria__c objEc = [SELECT id FROM nm_EligiblityCriteria__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockIII());

        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        ApexPages.currentPage().getParameters().put('target','RegForm');
        ApexPages.currentPage().getParameters().put('IC','true');
        ApexPages.currentPage().getParameters().put('calendarSession','July');
        ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
        

        ReRegistrationForm objForm = new ReRegistrationForm();
        objForm.chooseProgram = 'Post Graduate Diploma Programs';
        objForm.address.postalcode = '400071';
        objForm.strSelectedEligiblity = objEc.Id;
        objForm.updateAddressDetails();
        Test.stopTest();

    }

    @isTest
    static void unitTest2() {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        nm_EligiblityCriteria__c objEc = [SELECT Id FROM nm_EligiblityCriteria__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
            
            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.chooseProgram = 'Post Graduate Diploma Programs';
            objForm.enableUpdateQualification = true;
            objForm.strSelectedEligiblity = objEc.Id;
            objForm.objAccount.SLF__c = 'Send to my shipping address';
            objForm.address.addressChoice = 'Yes';
            objForm.save();
            objForm.totalPayFee = 1;
            objForm.goPayment();
            objForm.markCloseWon();
        Test.stopTest();
    }


    @isTest
    static void unitTest3() {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        Test.startTest();
            setCalender('January',System.today(),System.today(),System.Today().year(),'Re-Registration','2','Post Graduate Diploma Programs');
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','January');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
            
            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.createNewOpportunity();
           // insert objForm.lstOpportunity;
            objForm.goPayment();
            // objForm.markCloseWon();
        Test.stopTest();
    }

    @isTest
    static void unitTest4() {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        nm_EligiblityCriteria__c objEc = [SELECT Id FROM nm_EligiblityCriteria__c LIMIT 1];

        Test.startTest();

            List<IC_Change_Request__c> lstProgramChange = [SELECT Id FROM IC_Change_Request__c WHERE Student__c =: objAccount.Id AND Status__c='New'];
            if(lstProgramChange.size() > 0) {
                delete lstProgramChange;
            }

            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
            
            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.chooseProgram = 'Post Graduate Diploma Programs';
            objForm.enableUpdateQualification = true;
            objForm.strSelectedEligiblity = objEc.Id;
            objForm.objAccount.SLF__c = 'Send to my shipping address';
            objForm.address.addressChoice = 'Yes';
            objForm.changeProgram = 'Yes';
            objForm.save();
        Test.stopTest();
    }

    @isTest
    static void unitTest5() {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));
            
            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.address.postalCode = '0';
            objForm.validateRequest();
            objForm.address.postalCode = '400071';
            objForm.checkIfProgramIsEligible = false;
            objForm.strSelectedProg = '';
            objForm.validateRequest();
        Test.stopTest();
    }

    @isTest
    static void unitTest6() {
        Account objAccount = [SELECT id,nm_Centers__r.OwnerId FROM Account LIMIT 1];
        nm_EligiblityCriteria__c objEc = [SELECT Id FROM nm_EligiblityCriteria__c WHERE nm_Program__c='Diploma Programs' LIMIT 1];
        List<IC_Change_Request__c> lstIcChangeRequest = [SELECT id FROM IC_Change_Request__c];
        nm_Program__c objProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Diploma Programs' LIMIT 1];
        // User objUser  = [SELECT id FROM USER WHERE Email = 'lcdelhi@testorg.com' LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));

            delete lstIcChangeRequest;

            User objUser = new User(id=objAccount.nm_Centers__r.OwnerId);
            objUser.Email = 'lcdelhi@testorg.com';
            update objUser;

            ReRegistrationForm objForm = new ReRegistrationForm();

            Boolean isCreated = objForm.createNewOpportunity();
          //  insert objForm.lstOpportunity;

            objForm.chooseProgram = 'Diploma Programs';
            objForm.enableUpdateQualification = true;
            objForm.strSelectedEligiblity = objEc.Id;
            objForm.objAccount.SLF__c = 'Send to my shipping address';
            objForm.address.addressChoice = 'Yes';
            objForm.changeProgram = 'Yes';
            // if(isCreated) {
            //     objForm.insertServiceChangeRequest('yes','Program Change',objProgram.Id,objEc.Id);
            // }
            objForm.save();
            objForm.goPayment();
        //    objForm.insertServiceChangeRequest('No','Program Change',objProgram.id,objForm.strSelectedEligiblity);
        Test.stopTest();
    }

    @isTest
    static void unitTest7() {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));

            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.objAccount.SLF__c = 'Send to my shipping address';
            objForm.address.addressChoice = 'Yes';
            objForm.changeProgram = 'No';
            objForm.save();
        Test.stopTest();
    }

    @isTest
    static void unitTest8() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            String response = ReRegistrationForm.getCSAvailability('test','1');
        Test.stopTest();
    }

    @isTest
    static void unitTest9() {
        Test.startTest();
            Account objAccount = [SELECT id FROM Account LIMIT 1];
            List<Opportunity> lstOPP = [SELECT id,nm_Program__r.Specialisation__c,nm_Semester__c,Elective_Subject_Name__c FROM Opportunity WHERE AccountId=:objAccount.Id];
            String objOppID = lstOPP[0].Id;
            delete lstOPP;
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            ApexPages.currentPage().getParameters().put('target','RegForm');
            ApexPages.currentPage().getParameters().put('oppPcId',objOppID);
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('calendarSession','July');
            ApexPages.currentPage().getParameters().put('calendarSessionYear',String.valueOf(System.Today().year()));

            ReRegistrationForm objForm = new ReRegistrationForm();
            objForm.lstOpportunity = lstOPP;
            objForm.checkForElectiveProgram();
        Test.stopTest();
    }

    public static void insertInvalidProgram(String accountId) {
        Account objAccount = [SELECT id,nm_Program__r.Name FROM Account WHERE Id=:accountId];
        List<nm_InvalidProgram__c> lstOFInvalidPrograms = new List<nm_InvalidProgram__c>();
        for (Integer i = 4; i > 1; i--) {
            nm_InvalidProgram__c objInvalidProgram = new nm_InvalidProgram__c();
            objInvalidProgram.ProgramName__c = objAccount.nm_Program__r.Name;
            objInvalidProgram.Semester__c = String.valueOf(i);
            lstOFInvalidPrograms.add(objInvalidProgram);
        }
        insert lstOFInvalidPrograms;
    }

    public static nm_StudentProgram__c createStudentProgram(Account objAccount) {
        nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
        objSP.nm_Student__c =objAccount.id;
        //objSP.nm_EligiblityCriteria__c =objEc.id;
        objSP.nm_FeesPaidofSemester__c = 1;
        objSP.nm_Program__c = objAccount.nm_Program__c;
        insert objSP;
        return objSP;  
    }

    public static void insertProduct(String productName, Decimal productPrice, String taggedPriceBook, String programId, String semester) {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = productName;
        if(String.isNotBlank(programId)) {
            product2.nm_Program__c = programId;
            product2.nm_Semester__c = semester;
        }
        product2.isActive = true;
        insert product2;

        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product2.Id, UnitPrice = productPrice, IsActive = true);
        insert standardPriceBookEntry;

        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = taggedPriceBook, Product2Id = product2.Id, UnitPrice = productPrice, IsActive = true);
        insert objPriceBookEntry;
    }

    public static IC_Change_Request__c createprogramChangeRequest(Opportunity opps, String programId){
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        objCR.Status__c='New';
        objCR.Student__c= opps.AccountID;
        objCR.Opportunity__c=opps.id;
        objCR.nm_TypeofRequest__c='Program Change';
        objCR.nm_Reson__c='test test';
        objCR.New_Program__c = programId;
        objCR.nm_Reason_for_Change_of_Program__c ='better oppos';
        insert objCR;
        return objCR;
    }

    public static Calender__c setCalender(string session,date startDate,date endDate, Decimal year,String category,String sem,String chooseProgram) {
        Calender__c  objCalender = new Calender__c();
        objCalender.Session__c = session;
        objCalender.Session_Start_Date__c = startDate;
        objCalender.Session_End_Date__c = endDate;
        objCalender.Year__c = year;
        objCalender.Category__c = category;
        objCalender.nm_Semester__c = sem;
        objCalender.nm_Type__c = chooseProgram;
        insert objCalender;
        return objCalender;
    } 

    public static nm_EligiblityCriteria__c createElegibilityCriteria(String chooseProgram) {
        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor degree';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c= null ;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c = chooseProgram;
        objEc.Graduation_Required__c = false;
        objEc.Mandatory_Document_list__c = '10th Marksheet';
        insert objEc;
        return objEc;
    }
}