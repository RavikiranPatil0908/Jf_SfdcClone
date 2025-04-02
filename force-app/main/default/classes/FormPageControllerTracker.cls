/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 25--03--2025
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class FormPageControllerTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='[{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockII implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"yearOfPassing": "2019","monthOfPassing": "June","program": "Diploma Programs","message": "","status": "Success","sapid": "77101110007"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockIV implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"yearOfPassing": "","monthOfPassing": "","program": "","message": "","status": "fail","sapid": "77119958558"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
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
        nmGenericTracker.InsertSerialNo();
        nm_EligiblityCriteria__c objEligibility = nmGenericTracker.CreateElegibilityCriteria();
        objEligibility.Experience_Required_In_Year__c =2;
        update objEligibility;
        nm_Centers__c objCenter = nmGenericTracker.CreateCenter('Counsellor',true);
        nm_Centers__c objCenter2 = nmGenericTracker.CreateCenter('Counsellor',true);
        objCenter2.RegistrationClosed__c=false;
        objCenter2.Name='Borivali';
        objCenter2.Registration_City__c = 'Mumbai';
        objCenter2.Allow_MBA_X__c = true;
        update objCenter2;
        Lead_Routing__c objRouting = new Lead_Routing__c(Active__c = true,From_Center__c=objCenter.Id, To_Center__c=objCenter2.Id,Choose_a_Program__c='Post Graduate Diploma Programs');
        insert objRouting;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Confirmed');
        objAccount.Pass_Out__c = true;
        objAccount.nm_DateOfBirth__c = System.today().addYears(-21);
        objAccount.nm_StudentNo__c = '77101110007';
        update objAccount;
        nm_Program__c prog = nmGenericTracker.CreateDiplomaProgram();
        Account acc = new Account(FirstName='Test123', LastName='abc', nm_StudentNo__c='77119958556', nm_Program__c=prog.Id, PersonMobilePhone='8652532023',PersonEmail='test@gmail.com' ,nm_DateOfBirth__c = System.today().addYears(-21));
        insert acc;
        Opportunity objOppforMaster = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won', '1', 'Diploma Programs', acc, 'AnnualFee');
       
        List<nm_StudentProgram__c> objStudentProg = [ SELECT id, nm_Student__c, Certificate_Issue__c, Certificate_Issue__r.nm_Type__c, ProgramType__c,nm_Program__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.prgst__c, Certificate_Issue__r.prgst__c
        FROM nm_StudentProgram__c WHERE nm_Student__r.Student_ID__c ='77119958556'];
        objStudentProg[0].Certificate_Issue__c=prog.Id;
        update objStudentProg;

        Account ac = new Account(FirstName='Test1234', LastName='abcd', nm_StudentNo__c='77119958557', nm_Program__c=prog.Id, PersonMobilePhone='8652532024',PersonEmail='test1@gmail.com',Pass_Out__c = true, nm_DateOfBirth__c = System.today().addYears(-21));
        insert ac;
        Account account = new Account(FirstName='Test12', LastName='ab', nm_StudentNo__c='77119958558', nm_Program__c=prog.Id, PersonMobilePhone='8652532025',PersonEmail='test2@gmail.com',Pass_Out__c = false, nm_DateOfBirth__c = System.today().addYears(-21));
        insert account;
        Opportunity objOppforDiploma = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won', '1', 'Diploma Programs', account, 'AnnualFee');
       
        List<nm_StudentProgram__c> objStudentProg2 = [ SELECT id, nm_Student__c, Certificate_Issue__c, Certificate_Issue__r.nm_Type__c, ProgramType__c,nm_Program__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.prgst__c, Certificate_Issue__r.prgst__c
        FROM nm_StudentProgram__c WHERE nm_Student__r.Student_ID__c ='77119958558'];
        objStudentProg2[0].Certificate_Issue__c=prog.Id;
        update objStudentProg2;
        nmGenericTracker.CreateWorkExperienceForAccount(ac);
        nmGenericTracker.CreateDocumentforAccount(ac,'Photo ID proof');
        nmGenericTracker.CreateDocumentforAccount(ac,'Aadhaar Card');
        nmGenericTracker.CreateDiplomaStudentProgram(objAccount);
        University_List__c university = new University_List__c();
        university.Is_Active__c = true;
        university.University_Name__c = 'Indira Gandhi Krishi Vishwavidyalaya';
        university.University_Type__c = 'State University';
        insert university;

    }

    @isTest
    static void testMethod1() {
        Lead objLead = [SELECT Id,Course_Name_Lateral__c,State_Province_Shipping__c FROM Lead LIMIT 1];
        Test.startTest();
        
            //PageReference pageRef = Page.AdmissionForm;
            //Test.setCurrentPage(pageRef);
            //ApexPages.currentPage().getParameters().put('id',objLead.Id);
            FormPageController objnmReg = new FormPageController();
            objnmReg.leadId = objLead.Id;
            objnmReg.setLeadId(objLead.Id);
            Id id = objnmReg.getLeadId();
            objLead.State_Province_Shipping__c ='State';
            objLead.Course_Name_Lateral__c='Certificate in Business Management';
            update objLead;
            Lead objLead2 = [SELECT Id,Course_Name_Lateral__c,State_Province_Shipping__c FROM Lead LIMIT 1];
            objnmReg.setLeadId(objLead2.Id);
            objnmReg.nextPage();
            objnmReg.accountQuery();
            objnmReg.getProgramTypePicklistValues();

            // To initalize the get list option.
            objnmReg.getWorkExpTimeList = new List<SelectOption>();
            objnmReg.getElegibilityCriteriaList = new List<SelectOption>();
            objnmReg.getLateralOptions = new List<SelectOption>();
            objnmReg.getDomicile = new List<SelectOption>();
            // objnmReg.getUniversityList = new List<SelectOption>();
            objnmReg.getProgramsList = new List<SelectOption>();

            // Get List
            objnmReg.getDomicile();
            objnmReg.getWorkExpTimeList();
            //objnmReg.getAllLeadsource();
            //objnmReg.getAllPublication();
            //objnmReg.getGraduationDegreeMode();
           // objnmReg.getLateralOptions();
            objnmReg.getGraduationDegreeModeMBA();
            //objnmReg.getAllInformationCenters();
            //objnmReg.validateOTPStatus();
           // objnmReg.sendOTP();
            //objnmReg.VerifyOTP();
            //objnmReg.generateOTPMSG();
            
            // objnmReg.getUniversityList();
            objnmReg.getElegibilityCriteriaList();
            // objnmReg.getProgramsListForBachelor();
            objnmReg.getSpecializationList();
            objnmReg.calculateAcademicScore();
            objnmReg.SaveWorkExp();
            //objnmReg.getMapOfCenterNameVsCenter();
            AdmissionFormController.getUniversityList();
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FormPageController objnmReg = new FormPageController();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.postalCode = '400071';
            objnmReg.updateAddressDetails();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
            objnmReg.postalCode = '400071';
            objnmReg.updateAddressDetails();
            objnmReg.objLead.Locality__c = 'Urban';
            objnmReg.nextPage();
            objnmReg.getGlobalLocalityOptionValues();
        Test.stopTest();
    }

    @isTest
    static void testMethod3() {
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_ChooseaProgram__c FROM Account WHERE Pass_Out__c = true LIMIT 1];
        Test.startTest();
            // Test.setMock(HttpCalloutMock.class, new RestMockII());
            // PageReference pageRef = Page.AdmissionForm;
            // Test.setCurrentPage(pageRef);
            // RestMockII rest = new RestMockII();
            // rest.method = 'Success';
            FormPageController objnmReg = new FormPageController();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.FirstName = 'Chandra';
            objnmReg.objLead.LastName = 'kumar';
            objnmReg.objLead.nm_ChooseaProgram__c = 'Diploma Programs';
            objnmReg.objLead.Student_Number_Lateral__c = objAccount.nm_StudentNo__c;
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.objLead.Is_Lateral__c = true;
            // objnmReg.getLateralStudentDetailsAPI();
            // objnmReg.nextPage();
        Test.stopTest();
    }

    @isTest 
    static void testMethod4() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        nm_Centers__c objCenter = [SELECT Id, recordtype.Name, Name, Allow_MBA_X__c FROM nm_Centers__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            // PageReference pageRef = Page.AdmissionForm;
            // Test.setCurrentPage(pageRef);
            // ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            // ApexPages.currentPage().getParameters().put('IcRec',objCenter.Id);
            FormPageController objnmReg = new FormPageController();
            objnmReg.GoToConfirmationForm();
            //objnmReg.MakePayment();
            objnmReg.RemoveExperience();
            objnmReg.copyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.copyAddress();
            //objnmReg.getAllInformationCentersOnMBAX();
        Test.stopTest();
    }
    @isTest 
    static void testMethod14() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockIII());
            // PageReference pageRef = Page.AdmissionForm;
            // Test.setCurrentPage(pageRef);
            // ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            FormPageController objnmReg = new FormPageController();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            //  objnmReg.getGeocodeFromZipCode();
            
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
            //  objnmReg.getGeocodeFromZipCode();
           
        Test.stopTest();
    }

    @isTest 
    static void testMethod5() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FormPageController objnmReg = new FormPageController();
            objnmReg.GoToConfirmationForm();
            objnmReg.RemoveExperience();
        Test.stopTest();
    }

    @isTest
    static void testMethod6() {
        Lead objLead = [SELECT Id,nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id, Name, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c,nm_IsEmailVerified__c ,Pass_Out__c FROM Account WHERE nm_StudentNo__c='77119958556' LIMIT 1];

        Test.startTest();
            // ForLateralStudentFailedResponse
            // RestMockII rest = new RestMockII();
            // rest.method = 'Failed';
            Test.setMock(HttpCalloutMock.class,new RestMockII());
            FormPageController objnmReg = new FormPageController();
            objnmReg.objLead = objLead.clone();
            objnmReg.studentNumber='77119958556';
            objnmReg.objLead.FirstName = 'Test123';
            objnmReg.objLead.LastName = 'abc';
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.Student_Number_Lateral__c = '77119958556';
            objnmReg.objLead.Is_Lateral__c = true;
            // objnmReg.getLateralStudentDetailsAPI();
            objAccount.Pass_Out__c =false;
            // objnmReg.getLateralStudentDetailsAPI();
          
            // ForLateralStudentInvalidResponse
            // rest.method = 'Invalid';

            // objnmReg.setStringToDateFormat('Test');
            objnmReg.validateFormOnServerSide();
            objnmReg.objLead.nm_EligiblityCriteria__c = null;
            objnmReg.getWorkExpTimeList();
            objnmReg.addExperience();
        Test.stopTest();
    }

    
    @isTest
    static void testMethod7(){
        Lead objLead = [SELECT Id ,FirstName,LastName,MobilePhone,Email,IC_Name__c,nm_RegistrationNo__c,nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id, Name, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c,nm_IsEmailVerified__c ,Pass_Out__c FROM Account WHERE nm_StudentNo__c='77119958558' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMockIV());
        FormPageController controller = new FormPageController();
            controller.studentNumber='77119958558';
            controller.objLead = objLead.clone();
            controller.objLead.FirstName = 'Test12';
            controller.objLead.LastName = 'ab';
            controller.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            controller.objLead.Student_Number_Lateral__c = '77119958558';
            controller.objLead.Is_Lateral__c = true;
            controller.objLead.MobilePhone ='8652532025';
            controller.objLead.Email ='test2@gmail.com';
            
            controller.getLateralStudentDetailsAPI();   
        Test.stopTest();
    }

    @isTest
    static void testMethod8() {
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c,Pass_Out__c  FROM Account WHERE Pass_Out__c = false LIMIT 1];
        Test.startTest();
            FormPageController objnmReg = new FormPageController();
            objnmReg.setAccountId(objAccount.Id);
            objnmReg.getAccountId();
            objnmReg.setSectionName('PersonalInformationSection');
            objnmReg.getSectionName();
            objnmReg.verifyDEBID();
        Test.stopTest();
    }

    @isTest
    static void testMethod9() {
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        insertDEB(objLead.Id);
        Test.startTest();

            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{' +
                                '"Message": "Data retrival successful.",' +
                                '"Status": "Process Success",' +
                                '"Resource": [' +
                                    '{' +
                                        '"StudentID": "345345",' +
                                        '"Program": "",' +
                                        '"email": "test@gmail.com",' +
                                        '"stdname": "test test",' +
                                        '"fathername": "",' +
                                        '"mobile": "9000000001",' +
                                        '"cdate": "Sep  2 2024  6:34PM",' +
                                        '"institutename": "",' +
                                        '"InstituteID": "",' +
                                        '"ipaddress": "192.000.00.37",' +
                                        '"programcode": "000000027388",' +
                                        '"mode": "",' +
                                        '"AdmissionDate": "",' +
                                        '"AdmissionDetails": "",' +
                                        '"UniversityName": "",' +
                                        '"CourseName": "",' +
                                        '"ABCID": "600000000785",' +
                                        '"DEBUniqueID": "090000000088",' +
                                        '"Gender": "Male",' +
                                        '"DOB": "15/06/1991",' +
                                        '"_list": null' +
                                    '}' +
                                ']' +
                            '}');

            // Mocking the HTTP callout
            HttpCalloutMock mock = new FormPageControllerTracker.MockHttpResponseGenerator(mockResponse);
            Test.setMock(HttpCalloutMock.class, mock);

            FormPageController objnmReg = new FormPageController();
            objnmReg.setLeadId(objLead.Id);
            objnmReg.objLead.DEBID__c = 'test';
            objnmReg.objLead.ABCID__c = 'test';
            objnmReg.verifyDEBID();
        Test.stopTest();
    }

    @isTest
    static void testMethod10() {
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        insertDEB(objLead.Id);
        Test.startTest();

            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(400);
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"Message":"Invalid API Key","Status":"Process Refused"}');

            // Mocking the HTTP callout
            HttpCalloutMock mock = new FormPageControllerTracker.MockHttpResponseGenerator(mockResponse);
            Test.setMock(HttpCalloutMock.class, mock);

            FormPageController objnmReg = new FormPageController();
            objnmReg.setLeadId(objLead.Id);
            objnmReg.objLead.DEBID__c = 'test';
            objnmReg.objLead.ABCID__c = 'test';
            objnmReg.verifyDEBID();
        Test.stopTest();
    }
    
      @isTest
    static void testMethod11(){
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_ChooseaProgram__c FROM Account WHERE Pass_Out__c = true LIMIT 1];
        Test.startTest();
        FormPageController controller = new FormPageController();
        controller.submitForOtp();
        controller.verifyLateralStudentOTP();
        controller.setStudentAsNonLateral();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod12(){
        Lead objLead = [SELECT Id ,FirstName,LastName,MobilePhone,Email,IC_Name__c,nm_RegistrationNo__c, nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id, Name, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c,nm_IsEmailVerified__c ,Pass_Out__c, nm_ChooseaProgram__c FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMockII());
        FormPageController objnmReg = new FormPageController();
            objnmReg.studentNumber='77119958556';
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.FirstName = 'Test123';
            objnmReg.objLead.LastName = 'abc';
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.Student_Number_Lateral__c = '77119958556';
            objnmReg.objLead.Is_Lateral__c = true;
            
           objnmReg.getLateralStudentDetailsAPI();   
        Test.stopTest();
    }
     @isTest
    static void testMethod13(){
        Lead objLead = [SELECT Id ,FirstName,LastName,MobilePhone,Email,IC_Name__c,nm_RegistrationNo__c,nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id,Name, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c,nm_IsEmailVerified__c ,Pass_Out__c FROM Account WHERE Pass_Out__c = true AND nm_StudentNo__c='77119958557' LIMIT 1];
        // List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c,Name,RecordId__c FROM nm_WorkExperience__c WHERE nm_Student__c=:objAccount.Id];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMockII());
        FormPageController controller = new FormPageController();
        LateralDataAssigmentWrapper wrapper = new LateralDataAssigmentWrapper();
            controller.leadId=objLead.Id;
            controller.studentNumber='77119958557';
            controller.objLead = objLead.clone();
            controller.objLead.FirstName = 'Test1234';
            controller.objLead.LastName = 'abcd';
            controller.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            controller.objLead.Student_Number_Lateral__c = '77119958557';
            controller.objLead.Is_Non_Lateral__c = 'No';
            controller.objLead.Lateral_Editable_set__c ='test,test1';
            controller.objLead.Is_Lateral__c = true;
            controller.objLead.MobilePhone ='8652532024';
            controller.objLead.Email ='test1@gmail.com';
            controller.getLateralStudentDetailsAPI();
            controller.queryLateralAccountRecord(objAccount.Id);
            controller.checkLateralDetails();
            wrapper.addLateralStudentWkExperience(objAccount.Id);
            wrapper.populateApporovedDefaultDocs(objAccount.Id);
            
        Test.stopTest();
    }
    
    @isTest
    static void testMethod15(){
        Lead objLead = [SELECT Id ,FirstName,LastName,MobilePhone,Email,IC_Name__c,nm_RegistrationNo__c FROM Lead LIMIT 1];
        Test.startTest();
        FormPageController controller = new FormPageController();
        controller.callValidate();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod16() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];  
        Account objAccount = [SELECT Id FROM Account WHERE Pass_Out__c = true AND nm_StudentNo__c = '77119958557' LIMIT 1];  
        // List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT Id FROM nm_WorkExperience__c WHERE nm_Student__c = :objAccount.Id];  
        Test.startTest();  
        LateralDataAssigmentWrapper wrapper = new LateralDataAssigmentWrapper();  
        wrapper.addLateralStudentWkExperience(objAccount.Id);  
        Test.stopTest();  
    }
    
    
    @isTest
    static void testMethod17(){
         FormPageController controller = new FormPageController();
        controller.getReloadPageBlock();
        controller.setReloadPageBlock('test');
        controller.getIsEditFormConfirmation();
        controller.setIsEditFormConfirmation(true);                        
    }

    @isTest
    static void testMethod18(){
        Account objAccount = [SELECT Id,Name, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c,nm_IsEmailVerified__c ,Pass_Out__c FROM Account WHERE Pass_Out__c = true AND  nm_StudentNo__c='77119958557' LIMIT 1];
        Test.startTest();
        FormPageController controller = new FormPageController();
        controller.updateAsNonLateral();
        controller.setOTPFields(objAccount);
        Test.stopTest();
    }
    
    
    
    

    private static void insertDEB(Id leadId) {
        DEB_Detail__c objDEBDetails = new DEB_Detail__c(
            Student_ID__c = 'test',
            Program__c = 'test',
            Email__c = 'test@gmail.com',
            Student_Name__c = 'test',
            Father_Name__c = 'test',
            Mobile__c = '8822003300',
            DEB_Created_Date__c = 'test',
            Institute_Name__c = 'test',
            Institute_Id__c = 'test',
            IpAddress__c = 'test',
            Program_Code__c = 'test',
            Mode__c = 'test',
            Admission_Date__c = System.today(),
            Admission_Details__c = 'test',
            University_Name__c =  'test',
            Course_Name__c =  'test',
            ABCID__c =  'test',
            DEB_Unique_ID__c =  'test',
            Gender__c =  'test',
            Date_of_Birth__c = System.today(),
            Is_Active__c = true,
            Lead__c = leadId
        );
        insert objDEBDetails;
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse response) {
            mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }

}