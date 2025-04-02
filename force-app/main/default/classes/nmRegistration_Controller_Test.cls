/**
 * @File Name          : nmRegistration_Controller_Test.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 11-08-2022
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    8/31/2019   shubhranshu     Initial Version
**/

@isTest(SeeAllData=false)
public class nmRegistration_Controller_Test {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='[{"Message":"Number of pincode(s) found:2","Status":"Success","PostOffice":[{"Name":"Chembur Rs","Description":null,"BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Circle":"Maharashtra","District":"Mumbai","Division":"Mumbai  North East","Region":"Mumbai","Block":"NA","State":"Maharashtra","Country":"India","Pincode":"400089"},{"Name":"Tilak Nagar (Mumbai)","Description":null,"BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Circle":"Maharashtra","District":"Mumbai","Division":"Mumbai  North East","Region":"Mumbai","Block":"NA","State":"Maharashtra","Country":"India","Pincode":"400089"}]}]';
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
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai',true);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

        nm_EligiblityCriteria__c objEligibility = nmGenericTracker.CreateElegibilityCriteria();
        objEligibility.Experience_Required_In_Year__c = 2;
        update objEligibility;

        nmGenericTracker.CreateWorkExperienceForLead(objLead);
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        nmGenericTracker.CreateDiplomaStudentProgram(objAccount);
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objLcCen = [SELECT Id FROM nm_Centers__c WHERE Recordtype.Name = 'Learning Center' LIMIT 1 ];

        nm_Centers__c objCen= new nm_Centers__c();

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name='Mumbai-abcd';
        
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = '0021';
        objCen.nm_CenterCity__c = 'Mumbai-abcd';
        objCen.nm_City__c = 'Mumbai-abcd';
        objCen.nm_StateProvince__c = 'Mumbai-abcd';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objcen.Allow_Degree__c = true;
        objcen.Allow_MBA_WX__c = true;
        objcen.ConsumerType__c='Retail';
        insert objCen;

        nm_Centers__c objCen1= new nm_Centers__c();

        objCen1.Nm_Active__c = true;
        objCen1.nm_LearningCenter__c = objLcCen.id;
        objCen1.Name='Mumbai-abcdf';
        objCen1.RecordTypeID = RT.id;         
        objCen1.nm_CenterCode__c = '0024';
        objCen1.nm_CenterCity__c = 'Mumbai-abcdf';
        objCen1.nm_City__c = 'Mumbai-abcdf';
        objCen1.nm_StateProvince__c = 'Mumbai-abcdf';
        objCen1.nm_Street__c = 'Krishna Nagar';
        objCen1.nm_PostalCode__c = '110051'; 
        objCen1.Sync_with_Portal__c =false;
        objcen1.Allow_Degree__c = true;
        objcen1.Allow_MBA_WX__c = true;
        objcen1.ConsumerType__c='Retail';
        insert objCen1;

        Lead_Routing__c objLeadRo = new Lead_Routing__c();
        objLeadRo.Name = 'leadR out';
        objLeadRo.From_Center__c = objCen1.Id;
        objLeadRo.To_Center__c = objCen.Id;
        objLeadRo.Active__c = true;
        insert objLeadRo;

        NM_Orgnisation_Based_FormConfiguration__c  objForm = new NM_Orgnisation_Based_FormConfiguration__c();
        objForm.Configuration_Id__c = 'INTERNATIONAL_FORM';
        objForm.Eligiblity__c = 'INTERNATIONAL_FORM';
        objForm.Centers__c = objCen1.Id;
        insert objForm;
    }

    @isTest
    static void testMethod1() {
        Lead objLead = [SELECT Id,nm_StudentImageUrl__c FROM Lead LIMIT 1];
        objLead.nm_StudentImageUrl__c = 'www.google.com';
        update objLead;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objLead.Id);
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();

            objLead.State_Province_Shipping__c ='State';
            update objLead;
            objnmReg.GoToEditTab();
            objnmReg.nextPage();

             // Get List
            objnmReg.getDomicileList();
            objnmReg.getWorkExpTimeList = objnmReg.getWorkExpTimeList();
            objnmReg.getGraduationDegreeMode();
            objnmReg.getLateralOptions = objnmReg.getLateralOptions();
            objnmReg.getAllInformationCenters();
            // objnmReg.getUniversityList = objnmReg.getUniversityList();
            objnmReg.getElegibilityCriteriaList = objnmReg.getElegibilityCriteriaList();
            objnmReg.getProgramsList = objnmReg.getProgramsList();
            objnmReg.calenderCheckForCorporate('B2');
            objnmReg.LeadRouting();

            System.assert(objnmReg.getWorkExpTimeList.size() > 0, 'All the list has been loaded');
        Test.stopTest();
    }

    @isTest
    static void testMethod2() {
        Lead objLead = [SELECT Id,nm_StudentImageUrl__c FROM Lead LIMIT 1];
        objLead.nm_StudentImageUrl__c = 'www.google.com';
        update objLead;
        Account objAccount = [SELECT Id, nm_Program__r.nm_TotalSemesters__c FROM Account LIMIT 1];
        Lead_Routing__c objLeadRo = [SELECT Id FROM Lead_Routing__c LIMIT 1];
        objLeadRo.Choose_a_Program__c = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
       update objLeadRo;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getCountryStateCityFromPostalAPI();
            objnmReg.objLead.Shipping_Address_Choice__c = 'Permanent Address';
            objnmReg.getCountryStateCityFromPostalAPI();
            objnmReg.nextPage();
            objnmReg.markPassout('gfhjfgh', objAccount);
            objnmReg.LeadRouting();

            // String stringDate = '2019-09-28T12:20:20';
            // Datetime formatedDatetime = objnmReg.setStringToDateFormat(stringDate);
            System.assert(objnmReg.CopyPermanantAddressFromTo != null, 'To call postalcode API');
        Test.stopTest();
    }

    @isTest
    static void testMethod3() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
         Lead_Routing__c objLeadRo = [SELECT Id FROM Lead_Routing__c LIMIT 1];
        objLeadRo.Program_Type__c = 'MBA (WX)';
       update objLeadRo;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            Test.setMock(HttpCalloutMock.class, new RestMockIII());
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.objLead = objLead.clone();
            objnmReg.Postalcode = '400071';
            objnmReg.objLead.nm_DateOfBirth__c = System.today().addYears(19);
            objnmReg.objLead.Student_Number_Lateral__c = '77101110007';
            objnmReg.objLead.Shipping_Address_Choice__c = 'Shipping Address';
            objnmReg.CopyPermanantAddressFromTo = 'SameAsShipping';
            objnmReg.getLateralStudentDetailsAPI();
            objnmReg.getGeocodeFromZipCode();
            objnmReg.nextPage();
            objnmReg.LeadRouting();
            System.assert(objnmReg.objLead.Student_Number_Lateral__c != null, 'Lateral student checked');
        Test.stopTest();
    }

    @isTest 
    static void testMethod4() {
        Lead objLead = [SELECT Id,nm_StudentImageUrl__c FROM Lead LIMIT 1];
        objLead.nm_StudentImageUrl__c = 'www.google.com';
        update objLead;
        Lead_Routing__c objLeadRo = [SELECT Id FROM Lead_Routing__c LIMIT 1];
        objLeadRo.Choose_a_Program__c = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        objLeadRo.Program_Type__c = 'MBA (WX)';
       update objLeadRo;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            PageReference pg = objnmReg.GoToConfirmationForm();
            objnmReg.MakePayment();
            objnmReg.AddExperience();
            objnmReg.RemoveExperience();
            objnmReg.LeadRouting();
            objnmReg.FormConfigName = 'INTERNATIONAL_FORM';
            objnmReg.QueryOrgFormConfigData();
            objnmReg.getAllInformationCenters();
            System.assert(pg != null, 'Successfuly redirected after confirmation');
        Test.stopTest();
    }

    @isTest 
    static void testMethod5() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Lead_Routing__c objLeadRo = [SELECT Id FROM Lead_Routing__c LIMIT 1];
        objLeadRo.Agency__c = 'Agency__c';
       update objLeadRo;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('ReLogin','true');
            ApexPages.currentPage().getParameters().put('IsEditFormConfirmation','true');
            ApexPages.currentPage().getParameters().put('IC','true');
            ApexPages.currentPage().getParameters().put('checkForOrgForm','true');
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.GoToConfirmationForm();
            PageReference pg = objnmReg.MakePayment();
            objnmReg.validateFormOnServerSide();
            objnmReg.GotoPrintFormEdit();
            objnmReg.LeadRouting();
            System.assert(pg != null, 'Makepayment has been successfuly called');
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
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.objLead = objLead.clone();
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

            System.assert(objnmReg.objLead.Student_Number_Lateral__c != null, 'A failed response has been covered');
        Test.stopTest();
    }

    @isTest
    static void testMethod7() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            // For the shipping Error message
            objnmReg.objLead.Country_Shipping__c = 'Test';
            objnmReg.objLead.State_Province_Shipping__c = 'Test';
            objnmReg.objLead.Shipping_Street__c = 'Test';
            objnmReg.objLead.Locality_Name_Shipping__c = 'Test';
            objnmReg.showShippingPopup();

            objnmReg.objLead.Locality_Name_Shipping__c = null;
            objnmReg.objLead.Shipping_Street__c = null;
            objnmReg.showShippingPopup();

            objnmReg.objLead.Locality_Name_Shipping__c = 'Test';
            objnmReg.showShippingPopup();

            objnmReg.objLead.Shipping_Street__c = 'Test';
            objnmReg.objLead.Locality_Name_Shipping__c = null;
            objnmReg.showShippingPopup();

            objnmReg.objLead.Country_Shipping__c = 'Other';
            objnmReg.showShippingPopup();

            System.assert(objnmReg.strSecToShow != null, 'Error message has been called');

        Test.stopTest();
    }

    @isTest
    static void testMethod8() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        nm_EligiblityCriteria__c objEligibilty = [SELECT Id FROM nm_EligiblityCriteria__c WHERE Experience_Required_In_Year__c > 0 LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.objLead.nm_EligiblityCriteria__c = objEligibilty.Id;
            objnmReg.getWorkExpTimeList();

            objnmReg.objLead.Reason__c = 'Other';
            Boolean checkWorkExpereince = objnmReg.SaveWorkExp();

            objnmReg.getElegibilityCriteriaList();

            objnmReg.checkICValid();

            // System.assert(checkWorkExpereince, 'Work Expereince has been called');
        Test.stopTest();
    }

    @isTest
    static void testMethod9() {
        Lead objLeadOld = [SELECT Id,nm_InformationCenter__c FROM Lead LIMIT 1];
        Test.startTest();
            
            Lead objLead = new Lead();
            objLead.Salutation = 'Mr.';
            objLead.FirstName = 'Test';
            objLead.LastName = 'Test';
            objLead.Email = 'test@gmail90.com';
            objLead.MobilePhone = '7542132569';
            objLead.nm_DateOfBirth__c = System.today().addYears(-19);
            objLead.nm_ChooseaProgram__c = 'Certificate Programs';
            objLead.nm_InformationCenter__c = objLeadOld.nm_InformationCenter__c;

            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.objLead = objLead;
            objnmReg.validateOTPStatus();
            objnmReg.sendOTP();
            objnmReg.VerifyOTP();
            objnmReg.generateOTPMSG();
            objnmReg.nextPage();
            // System.assert(checkWorkExpereince, 'Work Expereince has been called');
        Test.stopTest();
    }

    @isTest
    static void testMethod10() {
        
        Test.startTest();

            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            objnmReg.LeadRouting();
        Test.stopTest();
    }

    @isTest 
    static void testMethod11() {
        Lead objLead = [SELECT Id,nm_StudentImageUrl__c FROM Lead LIMIT 1];
        Lead_Routing__c objLeadRo = [SELECT Id FROM Lead_Routing__c LIMIT 1];
        objLeadRo.Choose_a_Program__c = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        objLeadRo.Program_Type__c = 'MBA (WX)';
        update objLeadRo;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            nmRegistration_Controller objnmReg = new nmRegistration_Controller();
            PageReference pg = objnmReg.GoToConfirmationForm();
            objnmReg.MakePayment();
            objnmReg.AddExperience();
            objnmReg.RemoveExperience();
            objnmReg.LeadRouting();
        Test.stopTest();
    }
}