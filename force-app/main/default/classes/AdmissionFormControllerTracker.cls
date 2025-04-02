/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 20-08-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class AdmissionFormControllerTracker 
{
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
        public String method;
        RestMockII() {
            method ='';
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"yearOfPassing": "2014","monthOfPassing": "June","program": "Diploma Programs","message": "","status": "Success","sapid": "77101110007"}';
            if(method == 'Failed') {
                fullJson = '{"status": "Failed"}';
            } else if(method == 'Invalid') {
                fullJson = '{"status": "Invalid"}';
            } else if(method == 'error') {
                fullJson = '{"status": "Error"}';
            }

            HTTPResponse res = new HTTPResponse();
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
        Account acc = new Account(FirstName='Test123', LastName='abc', nm_StudentNo__c='77119958556', nm_Program__c=prog.Id, PersonMobilePhone='8652532023',PersonEmail='test@gmail.com', nm_DateOfBirth__c = System.today().addYears(-21));
        insert acc;
        nmGenericTracker.CreateDiplomaStudentProgram(objAccount);
        University_List__c university = new University_List__c();
        university.Is_Active__c = true;
        university.University_Name__c = 'Indira Gandhi Krishi Vishwavidyalaya';
        university.University_Type__c = 'State University';
        insert university;
    }

    @isTest
    static void testMethod1() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',objLead.Id);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objLead.State_Province_Shipping__c ='State';
            update objLead;
            objnmReg.GoToEditTab();
            objnmReg.nextPage();

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
            objnmReg.getAllLeadsource();
            objnmReg.getAllPublication();
            objnmReg.getGraduationDegreeMode();
            objnmReg.getLateralOptions();
            objnmReg.getGraduationDegreeModeMBA();
            objnmReg.getAllInformationCenters();
            objnmReg.validateOTPStatus();
            objnmReg.sendOTP();
            objnmReg.VerifyOTP();
            objnmReg.generateOTPMSG();
            
            // objnmReg.getUniversityList();
            objnmReg.getElegibilityCriteriaList();
            // objnmReg.getProgramsListForBachelor();
            objnmReg.getSpecializationList();
            objnmReg.calculateAcademicScore();
            objnmReg.SaveWorkExp();
            objnmReg.getMapOfCenterNameVsCenter();
            AdmissionFormController.getUniversityList();
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.updateAddressDetails();
            
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
            objnmReg.updateAddressDetails();
            //objnmReg.updateAddressDetails();
           // objnmReg.setStringToDateFormat();
            objnmReg.calenderCheckForCorporate('July2022');
            objnmReg.nextPage();
        Test.stopTest();
    }

    @isTest
    static void testMethod3() {
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_ChooseaProgram__c FROM Account WHERE Pass_Out__c = true LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            // RestMockII rest = new RestMockII();
            // rest.method = 'Success';
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.FirstName = 'Chandra';
            objnmReg.objLead.LastName = 'kumar';
            objnmReg.objLead.nm_ChooseaProgram__c = 'Diploma Programs';
            objnmReg.objLead.Student_Number_Lateral__c = objAccount.nm_StudentNo__c;
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getLateralStudentDetailsAPI();
            // objnmReg.nextPage();
        Test.stopTest();
    }

    @isTest 
    static void testMethod4() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        nm_Centers__c objCenter = [SELECT Id, recordtype.Name, Name, Allow_MBA_X__c FROM nm_Centers__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('IcRec',objCenter.Id);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.GoToConfirmationForm();
            objnmReg.MakePayment();
            objnmReg.RemoveExperience();
            objnmReg.getAllInformationCentersOnMBAX();
        Test.stopTest();
    }
    @isTest 
    static void testMethod14() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockIII());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
             objnmReg.updateAddressDetails();
            
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
             objnmReg.updateAddressDetails();
           
        Test.stopTest();
    }

    @isTest 
    static void testMethod5() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('ReLogin','true');
            ApexPages.currentPage().getParameters().put('fname','test');
            ApexPages.currentPage().getParameters().put('lname','test');
            ApexPages.currentPage().getParameters().put('email','test@gmail.co.in');
            ApexPages.currentPage().getParameters().put('IsEditFormConfirmation','true');
            ApexPages.currentPage().getParameters().put('mobile','7894563210');
            ApexPages.currentPage().getParameters().put('IC','true');
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.GoToConfirmationForm();
            objnmReg.MakePayment();
            objnmReg.RemoveExperience();
            objnmReg.getAllInformationCentersOnMBAX();
        Test.stopTest();
    }

    @isTest
    static void testMethod6() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            // ForLateralStudentFailedResponse
            RestMockII rest = new RestMockII();
            rest.method = 'Failed';
            Test.setMock(HttpCalloutMock.class, rest);
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.FirstName = 'Test123';
            objnmReg.objLead.LastName = 'abc';
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.Student_Number_Lateral__c = '77119958556';
            objnmReg.getLateralStudentDetailsAPI();
            // ForLateralStudentInvalidResponse
            rest.method = 'Invalid';
            Test.setMock(HttpCalloutMock.class, rest);
            objnmReg.getLateralStudentDetailsAPI();
            // ForLateralStudentErrorResponse
            rest.method = 'error';
            Test.setMock(HttpCalloutMock.class, rest);
            objnmReg.getLateralStudentDetailsAPI();
            // objnmReg.setStringToDateFormat('Test');
            objnmReg.validateFormOnServerSide();
            objnmReg.objLead.nm_EligiblityCriteria__c = null;
            objnmReg.getWorkExpTimeList();
        Test.stopTest();
    }

    @isTest
    static void testMethod7() {
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c,Pass_Out__c  FROM Account WHERE Pass_Out__c = false LIMIT 1];
        Test.startTest();
            RestMockII rest = new RestMockII();
            rest.method = 'Success';
            Test.setMock(HttpCalloutMock.class, rest);
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(-21);
            objnmReg.objLead.FirstName = 'Test123';
            objnmReg.objLead.LastName = 'abc';
            objnmReg.objLead.nm_ChooseaProgram__c = 'Diploma Programs';
            objnmReg.objLead.Student_Number_Lateral__c = objAccount.nm_StudentNo__c;
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getLateralStudentDetailsAPI();
            // objnmReg.nextPage();
        Test.stopTest();
    }

    // @isTest
    // static void testMethod7() {
    //     Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c FROM Account LIMIT 1];
    //     Test.startTest();
    //         // objAccount.nm_StudentStatus__c = 'Confirmed';
    //         update objAccount;
    //         // ForLateralStudentFailedResponse
    //         RestMockII rest = new RestMockII();
    //         rest.method = 'Failed';
    //         Test.setMock(HttpCalloutMock.class, rest);
    //         PageReference pageRef = Page.AdmissionForm;
    //         Test.setCurrentPage(pageRef);
    //         AdmissionFormController objnmReg = new AdmissionFormController();
    //         objnmReg.markPassout('83838738838',objAccount);
    //     Test.stopTest();
    // }

    @isTest
    static void testMethod8() {
        Lead objLeadOld = [SELECT Id,nm_InformationCenter__c,IC_Name__c FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.AdmissionForm;
            Test.setCurrentPage(pageRef);
            // ApexPages.currentPage().getParameters().put('Id',objLeadOld.Id);
            
            Lead objLead = new Lead();
            objLead.Salutation = 'Mr.';
            objLead.FirstName = 'Test';
            objLead.LastName = 'Test';
            objLead.Email = 'test@gmail90.com';
            objLead.MobilePhone = '9284511528';
            objLead.nm_DateOfBirth__c = System.today().addYears(-19);
            objLead.nm_ChooseaProgram__c = 'Master Programs';
            objLead.nm_InformationCenter__c = objLeadOld.nm_InformationCenter__c;
            
            AdmissionFormController objnmReg = new AdmissionFormController();
            objnmReg.objLead = objLead;
            objnmReg.objOTP.Otp = '77777';
            objnmReg.objOTP.OtpCode = '77777';
            objnmReg.objOTP.OtpMode = 'M';
            objnmReg.objOTP.otpSentTime = DateTime.now().getTime() -80;
            objnmReg.VerifyOTP();
            objnmReg.nextPage();
            //incorrect otp
            objnmReg.objOTP.Otp = '77778';
            objnmReg.VerifyOTP();
            //expired
            objnmReg.objOTP.Otp = '77777';
            objnmReg.objOTP.otpSentTime = DateTime.now().getTime() - 200*1000;
            objnmReg.VerifyOTP();
        Test.stopTest();
    }
}