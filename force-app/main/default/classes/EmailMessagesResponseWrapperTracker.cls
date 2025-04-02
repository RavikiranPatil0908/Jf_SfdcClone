/**
 * @File Name          : EmailMessagesResponseWrapperTracker.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 23/6/2020, 5:00:23 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@IsTest
public class EmailMessagesResponseWrapperTracker {
	
	static testMethod void testParse() {
		String json = '['+
		'    {'+
		'        \"id\": \"02s0o00001BlnH2AAJ\",'+
		'        \"parentId\": \"5000o00002GgVTqAAN\",'+
		'        \"caseNumber\": \"00103788\",'+
		'        \"caseStatus\": \"Closed\",'+
		'        \"createdById\": \"00590000002cJsFAAU\",'+
		'        \"createdDate\": \"2019-01-02T06:20:17.000Z\",'+
		'        \"lastModifiedById\": \"00590000002cJsFAAU\",'+
		'        \"lastModifiedDate\": \"2019-01-02T06:20:17.000Z\",'+
		'        \"systemModstamp\": \"2019-01-02T06:45:10.000Z\",'+
		'        \"textBody\": \"Dear\",'+
		'        \"htmlBody\": \"<html></html>\",'+
		'        \"subject\": \"Re: Thank You\",'+
		'        \"fromName\": \"rishabh.thakran@gmail.com\",'+
		'        \"fromAddress\": \"Rishabh Thakran\",'+
		'        \"toAddress\": \"ngasce@nmims.edu\",'+
		'        \"ccAddress\": \"LCPune@nmims.edu; ickoregaonpark@nmims.edu\",'+
		'        \"bccAddress\": \"LCPune@nmims.edu; ickoregaonpark@nmims.edu\",'+
		'        \"incoming\": false,'+
		'        \"hasAttachment\": false,'+
		'        \"status\": \"4\",'+
		'        \"messageDate\": \"2019-01-02T06:19:47.000Z\",'+
		'        \"isPrivateDraft\": false,'+
		'        \"isDeleted\": false,'+
		'        \"isExternallyVisible\": false,'+
		'        \"isClientManaged\": false,'+
		'        \"isTracked\": false,'+
		'        \"isBounced\": false,'+
		'        \"success\": false,'+
		'        \"error\": false,'+
		'        \"isPrivate\": false,'+
		'        \"attachments\": ['+
		'            {'+
		'                \"id\": \"4340\",'+
		'                \"parentId\": \"02s0o00001BlnH2AAJ\",'+
		'                \"isDeleted\": false,'+
		'                \"attachmentId\": \"00P0o00001rFpyhEAC\",'+
		'                \"name\": \"Class 12.pdf\",'+
		'                \"attachmentBody\": \"JVBERi0xLjcgCiXi48/\",'+
		'                \"bodyLength\": \"48845\",'+
		'                \"contentType\": \"application/pdf\",'+
		'                \"isPrivate\": false,'+
		'                \"ownerId\": \"00590000002cJsFAAU\"'+
		'            }'+
		'        ]'+
		'    }'+
		']';
		List<EmailMessagesResponseWrapper> obj = EmailMessagesResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}