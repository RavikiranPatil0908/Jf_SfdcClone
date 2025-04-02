/**
 * @File Name          : NMIMS_Registration_Controller_Tracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-01-2023
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    18/3/2019, 5:55:05 PM   Balakrishnan     Initial Version
**/
@isTest(SeeAllData=false)
public class NMIMS_Registration_Controller_Tracker 
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
            String fullJson = '{"yearOfPassing": "2014","monthOfPassing": "June","program": "Post Graduate Diploma in Business Management","message": "","status": "Success","sapid": "77101110007"}';
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
        nmGenericTracker.CreateCenter('Counsellor',true);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        nmGenericTracker.CreateDiplomaStudentProgram(objAccount);
    }

    @isTest
    static void testMethod1() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',objLead.Id);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
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
            objnmReg.getProgramsListForBachelor();
            objnmReg.getSpecializationList();
            objnmReg.calculateAcademicScore();
            objnmReg.SaveWorkExp();
            objnmReg.getMapOfCenterNameVsCenter();
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getCountryStateCityFromPostalAPI();
            
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
            objnmReg.getCountryStateCityFromPostalAPI();
            //objnmReg.getGeocodeFromZipCode();
           // objnmReg.setStringToDateFormat();
            objnmReg.calenderCheckForCorporate('July2022');
            objnmReg.nextPage();
        Test.stopTest();
    }

    @isTest
    static void testMethod3() {
        Lead objLead = [SELECT Id ,IC_Name__c FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(19);
            objnmReg.objLead.Student_Number_Lateral__c = '77101110007';
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getLateralStudentDetailsAPI();
            objnmReg.nextPage();
        Test.stopTest();
    }

    @isTest 
    static void testMethod4() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
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
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
             objnmReg.getGeocodeFromZipCode();
            
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
             objnmReg.getGeocodeFromZipCode();
           
        Test.stopTest();
    }

    @isTest 
    static void testMethod5() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('ReLogin','true');
            ApexPages.currentPage().getParameters().put('fname','test');
            ApexPages.currentPage().getParameters().put('lname','test');
            ApexPages.currentPage().getParameters().put('email','test@gmail.co.in');
            ApexPages.currentPage().getParameters().put('IsEditFormConfirmation','true');
            ApexPages.currentPage().getParameters().put('mobile','7894563210');
            ApexPages.currentPage().getParameters().put('IC','true');
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
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
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.objLead = objLead.clone();
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(19);
            objnmReg.objLead.Student_Number_Lateral__c = '77101110007';
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
        Account objAccount = [SELECT Id,nm_StudentNo__c,nm_StudentStatus__c FROM Account LIMIT 1];
        Test.startTest();
            // objAccount.nm_StudentStatus__c = 'Confirmed';
            update objAccount;
            // ForLateralStudentFailedResponse
            RestMockII rest = new RestMockII();
            rest.method = 'Failed';
            Test.setMock(HttpCalloutMock.class, rest);
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.markPassout(objAccount.nm_StudentNo__c);
        Test.stopTest();
    }

    @isTest
    static void testMethod8() {
        Lead objLeadOld = [SELECT Id,nm_InformationCenter__c,IC_Name__c FROM Lead LIMIT 1];
        Test.startTest();
            
            Lead objLead = new Lead();
            objLead.Salutation = 'Mr.';
            objLead.FirstName = 'Test';
            objLead.LastName = 'Test';
            objLead.Email = 'test@gmail90.com';
            objLead.MobilePhone = '7542132569';
            objLead.nm_DateOfBirth__c = System.today().addYears(-19);
            objLead.nm_ChooseaProgram__c = 'Master Programs';
            objLead.nm_InformationCenter__c = objLeadOld.nm_InformationCenter__c;
            PageReference pageRef = Page.NMIMS_Executive_MBA;
            Test.setCurrentPage(pageRef);
            NMIMS_Registration_Controller objnmReg = new NMIMS_Registration_Controller();
            objnmReg.objLead = objLead;
            objnmReg.objOTP.Otp = '77777';
            objnmReg.objOTP.OtpCode = '77777';
            objnmReg.objOTP.otpSentTime = DateTime.now().getTime() -80;
            objnmReg.VerifyOTP();
            objnmReg.nextPage();
            // System.assert(checkWorkExpereince, 'Work Expereince has been called');
        Test.stopTest();
    }
}