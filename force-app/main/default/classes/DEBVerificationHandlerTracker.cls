/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : @vickysahu
**/
@isTest
public class DEBVerificationHandlerTracker {

    @TestSetup
    static void makeData() {
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

    }

    @isTest
    static void testVerifyDEBIDBlankDebId() {
        DEBVerificationHandler.Request req = new DEBVerificationHandler.Request();
        req.debId = '';
        
        DEBVerificationHandler.Response resp = DEBVerificationHandler.verifyDEBID(req);
        
        System.assertNotEquals(null, resp, 'Response should not be null');
        System.assertEquals(false, resp.isDebMatched, 'isDebMatched should be false');
        System.assertEquals(false, resp.isDOBMatched, 'isDOBMatched should be false');
        System.assertEquals(false, resp.isDEBActive, 'isDEBActive should be false');
    }

    @isTest
    static void testVerifyDEBIDNullResponse() {
        Test.startTest();
        
        // Mocking the web service
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Resource":[{"StudentID":"S123","Program":"Program A","email":"test@example.com","stdname":"John Doe","fathername":"Jane Doe","mobile":"1234567890","cdate":"01/01/2004","institutename":"Test Institute","InstituteID":"I123","ipaddress":"192.168.1.1","programcode":"P123","mode":"Online","AdmissionDate":"01/01/2004","AdmissionDetails":"Details","UniversityName":"Test University","CourseName":"Test Course","ABCID":"A123","DEBUniqueID":"DEB123","Gender":"M","DOB":"01/01/2004"}]}');
        res.setStatusCode(200);

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DEBVerificationHandlerTracker.MockHttpResponseGenerator(res);
        Test.setMock(HttpCalloutMock.class, mock);
        
        DEBVerificationHandler.Request req = new DEBVerificationHandler.Request();
        req.debId = '12345';
        
        DEBVerificationHandler.Response resp = DEBVerificationHandler.verifyDEBID(req);
        
        System.assertNotEquals(null, resp, 'Response should not be null');
        System.assertEquals(false, resp.isDEBActive, 'isDEBActive should be false');
        System.assertEquals(false, resp.isDebMatched, 'isDebMatched should be false');
        System.assertEquals(false, resp.isDOBMatched, 'isDOBMatched should be false');
        
        Test.stopTest();
    }

    @isTest
    static void testVerifyDEBIDSuccessfulInsert() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );

        insert testUser;

        Test.startTest();
        Lead objLead = [SELECT Id ,IC_Name__c, nm_RegistrationNo__c FROM Lead LIMIT 1];
        String dob = DateTime.now().addDays(-30).format('dd/MM/yyyy');
        // Mocking the web service
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Resource":[{"StudentID":"S123","Program":"Program A","email":"test@example.com","stdname":"John Doe","fathername":"Jane Doe","mobile":"1234567890","cdate":"'+dob+'","institutename":"Test Institute","InstituteID":"I123","ipaddress":"192.168.1.1","programcode":"P123","mode":"Online","AdmissionDate":"'+dob+'","AdmissionDetails":"Details","UniversityName":"Test University","CourseName":"Test Course","ABCID":"A123","DEBUniqueID":"DEB123","Gender":"M","DOB":"'+dob+'"}]}');
        res.setStatusCode(200);

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DEBVerificationHandlerTracker.MockHttpResponseGenerator(res);
        Test.setMock(HttpCalloutMock.class, mock);
        
        DEBVerificationHandler.Request req = new DEBVerificationHandler.Request();
        req.debId = 'DEB123';
        req.objType = 'Lead';
        req.recordId = objLead.Id;
        req.ownerId = testUser.Id;
        req.dob = Date.today().addDays(-30);
        
        DEBVerificationHandler.Response resp = DEBVerificationHandler.verifyDEBID(req);
        
        System.assertNotEquals(null, resp, 'Response should not be null');
        // System.assertEquals(true, resp.isSuccess, 'isSuccess should be true');
        System.assertEquals(true, resp.isDEBActive, 'isDEBActive should be true');
        System.assertEquals(true, resp.isDebMatched, 'isDebMatched should be true');
        
        Test.stopTest();
    }

    // @isTest
    // static void testVerifyDEBIDException() {
    //     Test.startTest();
        
    //     // Mocking the web service to throw an exception
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithException());
        
    //     DEBVerificationHandler.Request req = new DEBVerificationHandler.Request();
    //     req.debId = '12345';
        
    //     DEBVerificationHandler.Response res = DEBVerificationHandler.verifyDEBID(req);
        
    //     System.assertNotEquals(null, res, 'Response should not be null');
    //     System.assertEquals(false, res.isSuccess, 'isSuccess should be false');
        
    //     Test.stopTest();
    // }

    // public class MockHttpResponseGenerator implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest req) {
    //         HttpResponse res = new HttpResponse();
    //         res.setHeader('Content-Type', 'application/json');
    //         res.setBody('{"Resource":[{"StudentID":"S123","Program":"Program A","email":"test@example.com","stdname":"John Doe","fathername":"Jane Doe","mobile":"1234567890","cdate":"2024-01-01","institutename":"Test Institute","InstituteID":"I123","ipaddress":"192.168.1.1","programcode":"P123","mode":"Online","AdmissionDate":"2024-01-01","AdmissionDetails":"Details","UniversityName":"Test University","CourseName":"Test Course","ABCID":"A123","DEBUniqueID":"DEB123","Gender":"M","DOB":"2004-01-01"}]}');
    //         res.setStatusCode(200);
    //         return res;
    //     }
    // }
    
    // public class MockHttpResponseGeneratorWithException implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest req) {
    //         throw new CalloutException('Mock exception');
    //     }
    // }

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