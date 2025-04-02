/**
 * @File Name          : UploadStudentProfileDocumentTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 04-05-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    3/7/2019, 6:02:43 PM   @BK      Initial Version
**/
@isTest(SeeAllData=false)
private class UploadStudentProfileDocumentTracker
{
	private class RestMock implements HttpCalloutMock {

		public String method;

		RestMock() {
			method ='';
		}

        public HTTPResponse respond(HTTPRequest req) {

			String fullJson = '{"documentUrl": "http://admissions-ngasce.nmims.edu:4001/StudentProfileDocuments/UyfvJP_77118224281.jpg","message": "successfully document uploaded","status": "success"}';
            if(method == 'failed') {
                fullJson = '{"message": "Kindly attached file to upload","status": "fail"}';
            }else if(method == 'Error') {
				CalloutException e = (CalloutException)CalloutException.class.newInstance();
				e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
				throw e;
			}else if(method == 'caseEmails') {
				fullJson = '[ { "id": "02s0o00001AqNWnAAN", "parentId": "5000o00002ExKFnAAN", "caseNumber": "00114026", "caseStatus": "Closed", "createdById": "00590000002cJsFAAU", "createdDate": "2019-02-24T06:25:55.000Z", "lastModifiedById": "00590000002cJsFAAU", "lastModifiedDate": "2019-02-24T06:25:55.000Z", "systemModstamp": "2019-03-01T06:38:13.000Z", "textBody": "Dear Sir Madam", "htmlBody": "<html>", "subject": "Complaint regarding Revised book of CRM", "fromName": "prts256@gmail.com", "fromAddress": "pradeep tiwari", "toAddress": "ngasce@nmims.edu; ac_newdelhi@nmims.edu; ngasce.exam@nmims.edu", "incoming": false, "hasAttachment": false, "status": "2", "messageDate": "2019-02-24T06:17:08.000Z", "isPrivateDraft": false, "isDeleted": false, "isExternallyVisible": false, "isClientManaged": false, "isTracked": false, "isBounced": false, "success": false, "error": false, "isPrivate": false, "attachments": [ { "id": "4130", "parentId": "02s0o00001AqNWnAAN", "isDeleted": false, "attachmentId": "00P0o00001pdldDEAQ", "name": "Customer_Relationship_Management_-_Session_Plan_eodwH0PlWc.docx", "attachmentBody": "UE==", "bodyLength": "414910", "contentType": "application", "isPrivate": false, "ownerId": "00590000002cJsFAAU" } ] } ]';
			}else if(method == 'caseEmails1') {
                fullJson = '{"status": "Success","message":"Get email logs successfully...!!!","response" : [ { "id": "02s0o00001AqNWnAAN", "parentId": "5000o00002ExKFnAAN", "caseNumber": "00114026", "caseStatus": "Closed", "createdById": "00590000002cJsFAAU", "createdDate": "2019-02-24T06:25:55.000Z", "lastModifiedById": "00590000002cJsFAAU", "lastModifiedDate": "2019-02-24T06:25:55.000Z", "systemModstamp": "2019-03-01T06:38:13.000Z", "textBody": "Dear Sir Madam", "htmlBody": "<html>", "subject": "Complaint regarding Revised book of CRM", "fromName": "prts256@gmail.com", "fromAddress": "pradeep tiwari", "toAddress": "ngasce@nmims.edu; ac_newdelhi@nmims.edu; ngasce.exam@nmims.edu", "incoming": false, "hasAttachment": false, "status": "2", "messageDate": "2019-02-24T06:17:08.000Z", "isPrivateDraft": false, "isDeleted": false, "isExternallyVisible": false, "isClientManaged": false, "isTracked": false, "isBounced": false, "success": false, "error": false, "isPrivate": false, "attachments": [ { "id": "4130", "parentId": "02s0o00001AqNWnAAN", "isDeleted": false, "attachmentId": "00P0o00001pdldDEAQ", "name": "Customer_Relationship_Management_-_Session_Plan_eodwH0PlWc.docx", "attachmentBody": "UE==", "bodyLength": "414910", "contentType": "application", "isPrivate": false, "ownerId": "00590000002cJsFAAU" } ] } ]}';
			}
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
			res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

	public class UnauthorizedEndpointResponse implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			CalloutException e = (CalloutException)CalloutException.class.newInstance();
			e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
			throw e;
		}
	}

	@TestSetup
	public static void makeData(){
		List<nm_AdmissionDriveDate__c> lst = new List<nm_AdmissionDriveDate__c>();
        nm_AdmissionDriveDate__c objADD = new nm_AdmissionDriveDate__c();
        objADD.Drive_Month__c ='January';
        objADD.Program_Type__c = 'All';
        objADD.Drive_Year__c = 2024;
		objADD.Status__c = 'Created';
        lst.add(objADD);

        nm_AdmissionDriveDate__c objADD1 = new nm_AdmissionDriveDate__c();
        objADD1.Drive_Month__c ='January';
        objADD1.Program_Type__c = 'Semester';
        objADD1.Drive_Year__c = 2024;
		objADD1.Status__c = 'Created';
        lst.add(objADD1);

        nm_AdmissionDriveDate__c objADD2 = new nm_AdmissionDriveDate__c();
        objADD2.Drive_Month__c ='January';
        objADD2.Program_Type__c = 'Term';
        objADD2.Drive_Year__c = 2024;
		objADD2.Status__c = 'Created';
        lst.add(objADD2);
        insert lst;
	}

	@isTest
	static void unitTest1() {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new RestMock());
			// Call the method that invokes a callout
			String imageFile = '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';
			String imageName = 'image.jpg';
			String output = UploadStudentProfileDocument.uploadFile(imageFile,imageName);

			// to call generateZoomLink
			UploadStudentProfileDocument.generateZoomLinks();

			UploadStudentProfileDocument.updateSelectionAdmisionDates();

			// Verify that a fake result is returned
			System.assertNotEquals(null, output, 'Expected value null but returned '+output); 
		Test.stopTest();
	}

	@isTest
	static void unitTest2() {
		Test.startTest();
			RestMock rest = new RestMock();
			rest.method = 'failed';
			Test.setMock(HttpCalloutMock.class, rest);

			// Call the method that invokes a callout
			String imageFile = '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Z';
			String imageName = 'image.jpg';
			String output = UploadStudentProfileDocument.uploadFile(imageFile,imageName);

			// Verify that a fake result is returned
			System.assertEquals(null, output, 'Expected value null but returned '+output); 
		Test.stopTest();
	}

	@isTest
	static void unitTest3() {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());

			// Call the method that invokes a callout
			String imageName = 'image.jpg';
			String imageFile = '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Z';
			String output = UploadStudentProfileDocument.uploadFile(imageFile,imageName);

			// Verify that a fake result is returned
			System.assertEquals(null, output, 'Expected value null but returned '+output);
		Test.stopTest();
	}

	@isTest
	static void unitTest4() {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());

			// Call the method that invokes a callout
			String imageName = 'image.jpg';
			String imageFile = '';
			String output = UploadStudentProfileDocument.uploadFile(imageFile,imageName);

			// Verify that a fake result is returned
			System.assertEquals(null, output, 'Expected value null but returned '+output);
		Test.stopTest();
	}

	@isTest
	static void unitTest5() {
		Test.startTest();
			RestMock rest = new RestMock();
			rest.method = 'caseEmails1';
			Test.setMock(HttpCalloutMock.class, rest);
			// Call the method that invokes a callout
			List<EmailMessagesResponseWrapper> lstWrapper = UploadStudentProfileDocument.getCaseEmails('test');
			System.assertEquals(true, lstWrapper != null && lstWrapper.size() > 0 ? true : false, 'Expected Case Email response but no record found');
		Test.stopTest();
	}

	@isTest
	static void unitTest6() {
		Test.startTest();
			RestMock rest = new RestMock();
			rest.method = 'caseEmails';
			Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
			// Call the method that invokes a callout
			List<EmailMessagesResponseWrapper> lstWrapper = UploadStudentProfileDocument.getCaseEmails('test');
			System.assertEquals(null, lstWrapper, 'Expected empty Wrapper');
		Test.stopTest();
	}


	@isTest
	static void unitTest7() {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new RestMock());
			Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
			String leadId = objLead.id;
			nmGenericTracker.CreatePaymentInitRecords(leadId,'Registration','Lead','12345');
			String response = UploadStudentProfileDocument.createPaymentRecord('12345');
			System.assertEquals('Success', response, 'Failed to return success message');
		Test.stopTest();
	}

	@isTest
	static void unitTest8() {
		List<nm_AdmissionDriveDate__c> lst = [SELECT id FROM nm_AdmissionDriveDate__c LIMIT 1];
		Test.startTest();
			String response = UploadStudentProfileDocument.callBatchClassForBaseGeneration(lst[0].id);
			System.assertEquals('Success', response, 'Failed to return success message');
		Test.stopTest();
	}

	@isTest
	static void unitTest9() {
		Test.startTest();
		String response = UploadStudentProfileDocument.callBatchClassForBaseGeneration(null);
			System.assertEquals('Error', response, 'Failed to return error message');
		Test.stopTest();
	}
}