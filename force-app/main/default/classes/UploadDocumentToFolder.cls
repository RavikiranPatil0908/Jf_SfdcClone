/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-12-2023
 * @last modified by  : @BK
**/
public without sharing class UploadDocumentToFolder {

    @AuraEnabled
    public static String uploadFile(String attachmentBody, String fileName, String folderName){
        String documentUrl = '';
        String mimeType = resolveMimeType(fileName); 
		try {
            if(String.isBlank(attachmentBody)) {
                System.debug('attachmentBody -->'+attachmentBody);
                return null;
            }
            Blob fileBody = EncodingUtil.base64Decode(attachmentBody);
            String boundary = '----------------------------741e90d31eff';
            String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+fileName+'";\nContent-Type: '+mimeType;
            // GW: Do not prepend footer with \r\n, you'll see why in a moment
            String footer = '--'+boundary+'--';             
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            while(headerEncoded.endsWith('=')) {
                header+=' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            }
            String bodyEncoded = EncodingUtil.base64Encode(fileBody);
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
            String endPoint = System.Label.DOCUMENT_SERVER + 'm/uploadStudentProfileDocumentByteArray?folderName=' + folderName;
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setMethod('PUT');
            req.setEndpoint(endPoint);
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);
        
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String result = res.getBody();
            System.debug('result -->'+result);
            Map<String, Object> mapOfAPIResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
            if(mapOfAPIResponse.get('status') == 'success'){ 
                documentUrl = (String)mapOfAPIResponse.get('documentUrl');
            } else {
                documentUrl = null;
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
			return null;
        }
        return documentUrl;
    }

    private static String resolveMimeType(String fileName) {
        String fileType = String.isNotBlank(fileName) ? fileName.substringAfterLast('.') : 'N/A';
        String mimeType = 'application/octet-stream';      // fallback value
        if (fileType.equalsIgnoreCase('png')) {
            mimeType = 'image/png';
        } else if (fileType.equalsIgnoreCase('jpeg') || fileType.equalsIgnoreCase('jpg')) {
            mimeType = 'image/jpeg';
        } else if (fileType.equalsIgnoreCase('svg')) {
            mimeType = 'image/svg+xml';
        } else if (fileType.equalsIgnoreCase('gif')) {
            mimeType = 'image/gif';
        } else if (fileType.equalsIgnoreCase('pdf')) {
            mimeType = 'application/pdf';
        } else if (fileType.equalsIgnoreCase('doc')) {
            mimeType = 'application/msword';
        } else if (fileType.equalsIgnoreCase('docx')) {
            mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        } else if (fileType.equalsIgnoreCase('ppt')) {
            mimeType = 'application/vnd.ms-powerpoint';
        } else if (fileType.equalsIgnoreCase('pptx')) {
            mimeType = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        } else if (fileType.equalsIgnoreCase('xls')) {
            mimeType = 'application/vnd.ms-excel';
        } else if (fileType.equalsIgnoreCase('xlsx')) {
            mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        } else if (fileType.equalsIgnoreCase('zip')) {
            mimeType = 'application/zip';
        } else if (fileType.equalsIgnoreCase('rar')) {
            mimeType = 'application/vnd.rar';
        }
    
        return mimeType;
    }

}