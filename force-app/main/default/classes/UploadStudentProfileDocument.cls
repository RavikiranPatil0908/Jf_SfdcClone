/**
 * @File Name          : UploadStudentProfileDocument.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-12-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    28/6/2019, 12:48:17 PM   @BK      Initial Version
**/
global class UploadStudentProfileDocument {

	/**
	* @description
	* @author @BK | 29/6/2019
	* @param String attachmentBody
	* @param String file_name
	* @return webservice
	*/
	webservice static String uploadFile(String attachmentBody, String file_name){
        String ProfileImageURL = '';
        
		try {
            if(String.isBlank(attachmentBody)) {
                System.debug('attachmentBody -->'+attachmentBody);
                return null;
            }
            Blob file_body = EncodingUtil.base64Decode(attachmentBody);
            String boundary = '----------------------------741e90d31eff';
            String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
            // GW: Do not prepend footer with \r\n, you'll see why in a moment
            // String footer = '\r\n--'+boundary+'--'; 
            String footer = '--'+boundary+'--';             
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            while(headerEncoded.endsWith('=')) {
                header+=' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            }
            String bodyEncoded = EncodingUtil.base64Encode(file_body);
            // GW: Do not encode footer yet
            // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        
            Blob bodyBlob = null;
            String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
            // GW: replacement section to get rid of padding without corrupting data
            if(last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the \r\n to the Blob, so leave footer as it is.
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
            } else if(last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
                footer = '\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
            } else {
                // Prepend the CR LF to the footer
                footer = '\r\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
            }
        
            HttpRequest req = new HttpRequest();
            String EndPoint = System.Label.DOCUMENT_SERVER + 'uploadStudentProfileDocument';
            // String EndPoint = 'https://studentzone-ngasce.nmims.edu:8090/salesforce/uploadStudentProfileDocument';
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setMethod('POST');
            req.setEndpoint(EndPoint);
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);
        
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String result = res.getBody();
            System.debug('result -->'+result);
            Map<String, Object> mapOfAPIResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
            if(mapOfAPIResponse.get('status') == 'success'){ 
                ProfileImageURL = (String)mapOfAPIResponse.get('documentUrl');
            } else {
                ProfileImageURL = null;
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
			return null;
        }
        return ProfileImageURL;
    }

    /**
    * @description to generate Zoom Links.
    * @author @BK | 28/12/2019 
    * @return void 
    **/
    webservice static void generateZoomLinks() {
        // to execute the Zoom Interview Batch class
        Database.executeBatch(new InterviewScheduleSetZoomLinkBatch());
    }

    /**
    * @description to Update Interview Selection Admision Date of MBA Program.
    * @author @BK | 12-08-2020 
    **/
    webservice static void updateSelectionAdmisionDates() {
        // to Update Interview Selection Admision Date of MBA Program.
        Database.executeBatch(new UpdateSelectionAdmisionDateBatch());
    }

    /**
    * @description 
    * @author @BK | 11/6/2020 
    * @return void 
    **/
    webservice static List<EmailMessagesResponseWrapper> getCaseEmails(String parentId) {
        Map<String,String> mapOfRequestParam = new Map<String,String>();
        mapOfRequestParam.put('parentId', parentId);   ///5000o00002cTOt9AAG
        string jsonString = JSON.serialize(mapOfRequestParam);
        
        HttpRequest req = new HttpRequest();
        String EndPoint = System.Label.Backlog_Api+'salesforce-emailLogs/m/case/getEmailLogsByParentId';  // System.Label.DOCUMENT_SERVER + 'getEmailMessages';
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setEndpoint(EndPoint);
        req.setBody(jsonString);
        req.setTimeout(120000);

        try {
            Http http = new Http();
            HTTPResponse resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Case Email API statusCode = '+statusCode);
            if(statusCode == 200){
                List<EmailMessagesResponseWrapper> lstWrapper = CaseEmailMessagesResponseWrapper.parse(resp.getBody());
                return lstWrapper;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }

    /**
    * @description to create payment record based on payment status
    * @author @BK | 06-24-2022 
    * @param merchantRefNo 
    * @return String 
    **/
    webservice static String createPaymentRecord(String merchantRefNo) {
        try {
            Map<String, nm_Payment_Initiated__c> uniqueMerchantRefNoMap = new Map<String, nm_Payment_Initiated__c>();
            List<nm_Payment_Initiated__c> lstPaymentIntitatedRcd = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c,OrderId__c,Payment_Gateway_Version__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c=:merchantRefNo];
            for (nm_Payment_Initiated__c initiatedPayment : lstPaymentIntitatedRcd) {
                uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment);
            }
            System.debug('uniqueMerchantRefNoMap size'+uniqueMerchantRefNoMap.size());
            if(uniqueMerchantRefNoMap.size() > 0) {
                PaymentCheckHelperClass objHelper = new PaymentCheckHelperClass();
                objHelper.batchExecute(uniqueMerchantRefNoMap);
            }
        } catch (Exception e) {
            System.debug('Error ==>'+e.getMessage());
            return e.getMessage();
        } 
        return 'Success';
    }


    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String recordId 
    **/
    webservice static String callBatchClassForBaseGeneration(String recordId) {
        List<nm_AdmissionDriveDate__c> lst = [SELECT Id,Status__c FROM nm_AdmissionDriveDate__c WHERE id=:recordId LIMIT 1];
        if(lst.size() > 0) {
            // to Update Interview Selection Admision Date of MBA Program.
            BatchClassForBaseGeneration b = new BatchClassForBaseGeneration(recordId); 
            Database.executeBatch(b); 
            lst[0].Status__c = 'Initiated';
            update lst;
            return 'Success';
        }
        return 'Error';
    }
}