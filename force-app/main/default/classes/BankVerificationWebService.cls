global class BankVerificationWebService {
    webservice static string verifyBankDetailsByCashFree(String accountHolder, String ifscCode, String accountNumber, String refundId) {
        Map<String, Object> responseBodyOfToken = AuthorizationToken.getCashFreeAuthorizationToken('Bank');
        if ((!responseBodyOfToken.isEmpty() && responseBodyOfToken.containsKey('status') && responseBodyOfToken.get('status') == 'success' && responseBodyOfToken.containsKey('token') && String.isNotBlank((String) responseBodyOfToken.get('token')) ) || Test.isRunningTest() ) {
            String BearerAuthToken = (String) responseBodyOfToken.get('token');
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String baseUrl = 'https://payout-api.cashfree.com/';
            String Uri =  (baseUrl+'payout/v1.2/validation/bankDetails?name='+ accountHolder + '&bankAccount=' + accountNumber + '&ifsc=' + ifscCode).replace(' ', '%20');
            req.setEndpoint(Uri);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer '+ BearerAuthToken);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            String resBody = '';
            System.debug('AccountNumberBank ==> ' + accountNumber + ' ifscCodeBank --> ' + ifscCode + ' BearerAuthToken --> '+ BearerAuthToken);
            try {
                // Integer statusCode = 200;
                // resBody = '{"status":"SUCCESS","subCode":"200","message":"Bank Account details verified successfully","accountStatus":"VALID","accountStatusCode":"ACCOUNT_IS_VALID","data":{"nameAtBank":"NISHA JESWANI","refId":"647003964","bankName":"HDFC BANK","utr":"319317281654","city":"MUMBAI","branch":"TULSIANI CHMBRS - NARIMAN PT","micr":0,"nameMatchScore":"0","nameMatchResult":"-"}}';
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                resBody = resp.getBody();
                System.debug('statusCode = '+statusCode);
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                String status = '';
                Boolean isAccountVerified = false;
                if(statusCode == 200) {
                    nmRefund_Payment__c objRfPay = new nmRefund_Payment__c();
                    objRfPay.Id = refundId;
                    objRfPay.Bank_Verification_API_Called__c = true;
                    objRfPay.Bank_Checked_Account_Number__c = accountNumber;
                    objRfPay.Bank_Checked_IFSC__c = ifscCode;
                    Map<String, Object> mapOfParams = (Map<String, Object>) responseBody.get('data');
                    if (!mapOfParams.isEmpty()) {
                        objRfPay.Bank_Checked_Account_Holder_Name__c = (String)mapOfParams.get('nameAtBank');
                        objRfPay.Bank_Checked_refId__c = (String)mapOfParams.get('refId');
                        objRfPay.Bank_Checked_UTR__c = (String)mapOfParams.get('utr');
                        objRfPay.Bank_Name_Match_Score__c = (String)mapOfParams.get('nameMatchScore');
                    }
                    system.debug(resBody);
                    system.debug(responseBody);
                    status = (String)responseBody.get('status');
                    if (status == 'SUCCESS') {
                        String accountStatus = (String)responseBody.get('accountStatus');
                        if (accountStatus == 'VALID') {
                            objRfPay.Bank_Verified__c = 'Yes';
                            isAccountVerified = true;
                        } else {
                            objRfPay.Bank_Verified__c = 'No';
                        }
                    } else {
                        objRfPay.Bank_Verified__c = 'No';
                    }
                    update objRfPay;
                }
                insertAPIRequest(Uri, resBody, 'BankVerification', isAccountVerified, refundId);
                return isAccountVerified ? 'Bank Details Valid' : 'Bank Details InValid' ;
            }catch (Exception e) {
                System.debug(e.getLineNumber() + ' --- '+e.getMessage());
                insertAPIRequest(Uri, resBody + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(), 'BankVerification', false, refundId);
                return 'Something went wrong!!';
            }
        } else {
            insertAPIRequest('Type = Bank', JSON.serialize(responseBodyOfToken), 'CashFreeTokenForSFDC',false, refundId);
        }
        return 'Something went wrong!';
    }

    public static void insertAPIRequest(String req, String res, String typeOfRequest ,Boolean isSuccess, String refundRcId) {
        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = typeOfRequest;
        apiReq.Request__c = req;
        apiReq.Type_of_Request__c = typeOfRequest;
        apiReq.Response__c = res;
        apiReq.Success__c = isSuccess;
        apiReq.Refund_Payment__c = refundRcId;
        insert apiReq;
    }
}