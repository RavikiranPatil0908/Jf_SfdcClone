/**
 * @description       :
 * @author            : @BK
 * @group             :
 * @last modified on  : 02-13-2025
 * @last modified by  : @vickysahu
 **/
@isTest(SeeAllData=false)
public without sharing class GrayQuestWebServiceTracker {
    
    @testSetup
    public static void setUpData() {
        GrayQuestAPI__c objGrayQuestWebService = new GrayQuestAPI__c();
        objGrayQuestWebService.Client_id__c = '177480a5-74f6-4e2b-a37e-5a9656bf8a15';
        objGrayQuestWebService.Client_Secret__c = '310e6146390049cc66e76f66fc8acbba95c359aa';
        objGrayQuestWebService.Grayquest_APILink__c = 'https://graydev.tech/gqpanel/api/erp';
        objGrayQuestWebService.API_KEY__c = '8285617fdf2ef7512b034387d5282dfac0d69853';
        objGrayQuestWebService.Name = 'GrayQuestLoanData';
        objGrayQuestWebService.Slug__c = 'ngasce';
        insert objGrayQuestWebService;
    }

    public class RestMock implements HttpCalloutMock {
        public Integer statusCode;
        RestMock() {
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            // String formDataURL = '{"student_details":{"student_id":"01172206","student_first_name":"Diploma Test"},"notes":{"location":"Delhi - Connaught Place"},"fee_details":{"loan_amount":30000},"customer_id":22634,"customer_details":{"customer_first_name":"Wewe wewe"}}';
            String formDataURL = '{"success":true,"status_code":201,"message":"Application created successfully","data":{"redirect_url":"https://customer.graydev.tech/instant-eligibility?m=8877113011&s=erp&application_id=11998","application_id":11998,"student_id":"01172206"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            //   res.setbody('{"success": 1,"redirect": 1,"redirect_url":"http://graydev.tech/grayquest/redirect-to-grayquest?token=71de985b2ff664d81349a42822dde27b&redirect_to=http://localhost/grayquest/basic_details?application_id=6342","login_token": "71de985b2ff664d81349a42822dde27b""application_id": 6342}');
            return res;
        }
    }

    public class RestMockI implements HttpCalloutMock {
        RestMockI() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":true,"status_code":200,"message":"Application status fetched successfully","data":[{"application_id":11113,"student_id":"07200646186","stage":"Incomplete Application","stage_slug":"lead"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":1,"error":0,"application_id":"10956","message":"Application has been cancelled"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockIII implements HttpCalloutMock {
        RestMockIII() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":true,"status_code":200,"message":"Application approved","data":null}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockIV implements HttpCalloutMock {
        RestMockIV() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":true,"status_code":201,"message":"Customer created successfully","data":{"customer_id":22116}}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockV implements HttpCalloutMock {
        RestMockV() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":true,"status_code":200,"message":"Email Sent Successfully","data":{"user_mobile":"9505898870","user_email":"suyog.deshmukh.ext@nmims.edu","user_name":"Hyderabad - Gachibowli","board":"NA","location":"Hyderabad - Gachibowli","institute_name":"NMIMS","group_name":"Boon Education"}}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockVI implements HttpCalloutMock {
        RestMockVI() {
        }
        public HttpResponse respond(HttpRequest req) {
            String formDataURL = '{"success":false,"status_code":400,"message":"Some Validations have Failed","data":{"customer_id":["required field"]}}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(formDataURL);
            res.setStatusCode(400);
            return res;
        }
    }

    public static HttpResponse getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('POST');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }

    @isTest
    static void createLeadTest() {
        Test.startTest();
        RestMock rest = new RestMock();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.createGQLoanRequest(
            'test',
            '006O0000008HHGV',
            'Lead'
        );
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":true,"status_code":201,"message":"Application created successfully","data":{"redirect_url":"https://customer.graydev.tech/instant-eligibility?m=8877113011&s=erp&application_id=11998","application_id":11998,"student_id":"01172206"}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        Test.stopTest();
    }

    @isTest
    static void createLeadTest2() {
        Test.startTest();
        RestMockVI rest = new RestMockVI();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.createGQLoanRequest(
            'test',
            '006O0000008HHGV',
            'Lead'
        );
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":false,"status_code":400,"message":"Some Validations have Failed","data":{"customer_id":["required field"]}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(400, res.getStatusCode());

        Test.stopTest();
    }

    @isTest
    static void cancelLoanTest() {
        Test.startTest();
        RestMockII rest = new RestMockII();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.cancelLoan('123', '6353', '006O0000008HHGV', 'Lead');
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":1,"error":0,"application_id":"10956","message":"Application has been cancelled"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }

    @isTest
    static void approvedLoanTest() {
        Test.startTest();
        RestMockIII rest = new RestMockIII();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.approvedLoan('1924', '006O0000008HHGV', 'Lead');
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":true,"status_code":200,"message":"Application approved","data":null}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        GrayQuestWebService.checkApplicationStatus(
            '1924',
            'reference_id',
            '006O0000008HHGV',
            'Lead'
        );
        Test.stopTest();
    }

    @isTest
    static void cancelLoanTest2() {
        Test.startTest();
        RestMockVI rest = new RestMockVI();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.cancelLoan('123', '948484', '006O0000008HHGV', 'Lead');
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":false,"status_code":400,"message":"Some Validations have Failed","data":{"customer_id":["required field"]}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(400, res.getStatusCode());
        Test.stopTest();
    }

    @isTest
    static void CreateCustomerTest() {
        Test.startTest();
        RestMockIV rest = new RestMockIV();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.CreateCustomer(
            '9089087865',
            '006O0000008HHGV',
            'Lead'
        );
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":true,"status_code":201,"message":"Customer created successfully","data":{"customer_id":22116}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }

    @isTest
    static void ProductRequestTest() {
        Test.startTest();
        RestMockV rest = new RestMockV();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        Recordtype RT = [
            SELECT id
            FROM Recordtype
            WHERE sobjectType = 'nm_Centers__c' AND name = 'Information Center'
        ];
        nm_Centers__c objCen = new nm_Centers__c();
        nm_Centers__c objLcCen = nmGenericTracker.CreateLearningCenter(
            'Mumbai - Mira Road East'
        );

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name = 'Mumbai';

        objCen.RecordTypeID = RT.id;
        objCen.nm_CenterCode__c = '002';
        objCen.ShareApplicable__c = true;
        objCen.nm_CenterCity__c = 'Pune';
        objCen.nm_City__c = 'Pune';
        objCen.nm_StateProvince__c = 'Pune';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051';
        objCen.Sync_with_Portal__c = false;
        objCen.OwnerId = UserInfo.getUserId();
        objCen.Allow_PG__c = true;
        objCen.Allow_Degree__c = true;
        objCen.Allow_Bachelor__c = true;
        objCen.nm_ChooseaProgram__c = 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c = 'Retail';

        insert objCen;
        GrayQuestWebService.ProductRequest(objCen.id, 'Center');
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":true,"status_code":200,"message":"Email Sent Successfully","data":{"user_mobile":"9505898870","user_email":"suyog.deshmukh.ext@nmims.edu","user_name":"Hyderabad - Gachibowli","board":"NA","location":"Hyderabad - Gachibowli","institute_name":"NMIMS","group_name":"Boon Education"}}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }

    @isTest
    static void checkApplicationStatusTest() {
        Test.startTest();
        RestMockI rest = new RestMockI();
        Test.setMock(HttpCalloutMock.class, rest);
        HttpResponse res = getInfoFromExternalService();
        GrayQuestWebService.checkApplicationStatus(
            '1924',
            'application_id',
            '006O0000008HHGV',
            'Lead'
        );
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"success":true,"status_code":200,"message":"Application status fetched successfully","data":[{"application_id":11113,"student_id":"07200646186","stage":"Incomplete Application","stage_slug":"lead"}]}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        Test.stopTest();
    }
}