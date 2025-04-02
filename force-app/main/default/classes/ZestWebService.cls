/**
 * @File Name          : ZestWebService.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 02-09-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/14/2020   shubhranshu     Initial Version
**/
public without sharing class ZestWebService{
    
    public String NonSubventionAuthorization = '';
    public String SubventionAuthorization = '';
    
    public String getAccessToken(Boolean isSubventionScheme){
        System.debug('before this.Authorization  --'+this.NonSubventionAuthorization );
        System.debug('before this.Authorization  --'+this.SubventionAuthorization );
        String Authorization = isSubventionScheme ? this.SubventionAuthorization : this.NonSubventionAuthorization;
        if(String.isBlank(Authorization)) {
            // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
            ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
            
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint(objZest.Authentication_API__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('client_id='+objZest.client_id__c+'&client_secret='+objZest.client_secret__c+'&scope='+objZest.scope__c+'&grant_type='+objZest.grant_type__c);
            System.debug('Request --->'+req.getBody());
            try{
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('Response --->'+resp);
                System.debug('Authentication_API:statusCode = '+statusCode);
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('RESULT ===>'+result);
                    Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                    if(!mapOfResponseParameters.isEmpty()){
                        if(mapOfResponseParameters.containsKey('access_token')){
                            Authorization = String.valueOf(mapOfResponseParameters.get('token_type')) +' '+ String.valueOf(mapOfResponseParameters.get('access_token'));
                        }
                    }
                }
            }catch(Exception e){
                System.debug('Callout Exception Authentication_API :'+e.getMessage());
            }
            if(isSubventionScheme) {
                this.SubventionAuthorization = Authorization;
            } else {
                this.NonSubventionAuthorization = Authorization;
            }
        }
        System.debug('before this.Authorization  --'+this.NonSubventionAuthorization );
        System.debug('before this.Authorization  --'+this.SubventionAuthorization );
        // return Authorization;
        return Test.isRunningTest() ? 'test' : Authorization;
    }
    
    // create Fresh Loan Application Request
    public String createNewLoanApplication(String BasketAmount,String OrderId,String DeliveryPostCode,String EmailAddress, String FullName,String City ,String AddressLine1, String AddressLine2, String MobileNumber 
    ,String CallbackUrlBase , boolean CustomerHasPriorPurchase ,decimal DownpaymentAmount , String Id , String Description ,String Quantity,decimal TotalPrice ,String Category,Boolean isSubventionScheme){
        /*Parameters Passing for Loan Application and Description
        
          BasketAmount :- Total basket amount including delivery and taxes
          OrderId :- Unique order ID
          DeliveryPostCode :- Delivery post code
          ReturnUrl :- URL address to return the customer back from ZestMoney app to merchant site
          ApprovedUrl :- URL of congratulation page that should be shown after successful approval of loan application
          MerchantCustomerId :- Unique customer ID at merchant site
          EmailAddress : -Customer's email id
          FullName :-Customer's full name
          City :-Customer's City
          AddressLine1 :- Customer's address line 1
          AddressLine2 :- Customer's address line 2
          MobileNumber :- Customer's mobile number
          CallbackUrlBase :-Allows merchant to specify a custom callback URL base for getting application status updates and other webhooks
          CustomerHasPriorPurchase :- If customer has prior successful purchase
          DownpaymentAmount :-Down payment amount to take from user.
          Basket :-Basket items. Should contain an array of next 5 parameters
          Id :- Unique item ID
          Description :- Product name
          Quantity :- Quantity. Greated than 0
          TotalPrice :-Total price of all items. Greater than 0
          Category :-Category of the product
        */
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        String ReturnUrl = objZest.ReturnUrl__c;
        String ApprovedUrl = objZest.ApprovedUrl__c;
        String MerchantCustomerId = objZest.client_id__c;
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.LoanApplications_API__c);
        req.setMethod('POST');
        req.setHeader('authorization',Authorization);// set Authorization in All web service 
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        String jsonBody = '{\r\n\t\"BasketAmount\":\"'+BasketAmount+'\",\r\n\t\"OrderId\":\"'+OrderId+'\" , \r\n\t\"DeliveryPostCode\":\"'+DeliveryPostCode+'\" ,\r\n\t\"ReturnUrl\":\"'+ReturnUrl+'" , \r\n\t\"ApprovedUrl\" :\"'+ApprovedUrl+'",\r\n\t\"MerchantCustomerId\" : \"'+MerchantCustomerId+'\" , \r\n\t\"EmailAddress\" : \"'+EmailAddress+'\" ,';
        jsonBody = jsonBody +'\r\n\t\"FullName\" : \"'+FullName+'\" ,\r\n\t\"City\" :\"'+City+'\",\r\n\t\"AddressLine1\" : \"'+AddressLine1+'\" ,\r\n\t\"AddressLine2\" :\"'+AddressLine2+'\", \r\n\t\"MobileNumber\" : \"'+MobileNumber+'\" ,\r\n\t\"CallbackUrlBase\":\"'+CallbackUrlBase+'",\r\n\t\"CustomerHasPriorPurchase\":\"'+CustomerHasPriorPurchase+'",\r\n\t\"DownpaymentAmount\":\"'+DownpaymentAmount+'",';
        jsonBody = jsonBody +'\r\n\t\"Basket\" :\r\n\t\t[\r\n\t\t\t{\r\n\t\t\t\t\"Id\" :\"'+Id+'",\r\n\t\t\t\t\"Description\" : \"'+Description+'\",\r\n\t\t\t\t\"Quantity\" : \"'+Quantity+'\" , \r\n\t\t\t\t\"TotalPrice\":\"'+TotalPrice+'\" ,\r\n\t\t\t\t\"Category\" : \"'+Category+'\"\r\n\t\t\t}\r\n\t\t]\r\n\t}';
                
        req.setBody(jsonBody);
        System.debug('jsonBody---'+jsonBody);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('LoanApplications_API__c:statusCode = '+statusCode);
            if(statusCode == 201){
                String result = resp.getBody();
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                /*
                    sample Out Put for Loan Application
                    // sample output
                    {"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200"}
                */
                if(!mapOfResponseParameters.isEmpty()){
                    for(String key : mapOfResponseParameters.keySet()){
                        System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    }
                }
                return result ;
            }else{
                System.debug('LoanApplications_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
        }
        return null;
    }
    
    // Get application status by order ID
    public String getLoanApplicationStatusByOrderId(String OrderId,Boolean isSubventionScheme){
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.LoanApplications_Status_API__c+OrderId);
        req.setMethod('GET');
        req.setHeader('authorization',Authorization);// set Authorization in All web service 
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('LoanApplications_Status_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('result--'+result);
                
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                /*
                    sample out put getOrder Status by Order Id
                    {"ApplicationId":"dfae5fb8-04e1-440a-9f8e-dc896e1344a5","OrderStatus":"MerchantCancelled","DeliveryPinCode":"400043","BasketAmount":76000.00}
                */
                if(!mapOfResponseParameters.isEmpty()){
                    for(String key : mapOfResponseParameters.keySet()){
                        System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    }
                }
                return result ;
            }else{
                System.debug('LoanApplications_Status_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception LoanApplications_Status_API__c :'+e.getMessage());
        }
        return null;
    }
    
    //The merchant can cancel a loan application, if for whatever reason they don't want to continue with processing this order (for example, if the customer calls merchant's customer service). In order to do so, a merchant's system invokes the cancellation API on Zest Money and the loan application is cancelled, if its not approved already.
    public String CancelledLoanApplicationByOrderId(String OrderId , String ReasonForCancelLoanApplicationRequest,Boolean isSubventionScheme){
        /*Parameters Passing for cancelled Loan Application and Description
            orderid :- Order Id to be cancelled
            CancelLoanApplicationRequest : -Reason for cancellation as string
        */
        
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.Cancellation_API__c+OrderId+'/cancellation');
        req.setMethod('POST');
        req.setHeader('authorization',Authorization);// set Authorization in All web service 
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        
        String jsonBody = '{\r\n\t\"CancelLoanApplicationRequest\" : \"'+ReasonForCancelLoanApplicationRequest+'\"\r\n\t}';
        req.setBody(jsonBody);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Cancellation_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = 'Loan application cancelled';
                System.debug(result);
                return result ;
            }else{
                System.debug('Cancellation_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception Cancellation_API__c :'+e.getMessage());
        }
        return null;
    }
    
    //This is an endpoint on the merchant's end, to which ZestMoney will be sending updates, when order status changes, as it progresses through the application flow.
    public String getUpdatedOrderStatus(String orderno , String applicationid,Boolean isSubventionScheme){
        /*Parameters Passing for update Order Status  as it progresses through the application flow and Description
            orderno : -Unique order ID
            status : - Current loan application status, can be on of these 
                        values:
                        RiskPending - risk decision pending; 
                        MerchantCancelled - loan application was cancelled by the merchant; 
                        TimeoutCancelled - loan application was cancelled by a timeout mechanism (customer did not complete the application in time); 
                        PreAccepted - loan application was pre-accepted by automated risk process; 
                        Declined - loan application was declined; 
                        LoanAgreementAccepted - the customer has signed the loan agreement; 
                        DepositPaid - the customer has either made the downpayment, or chose to pay on delivery (if available); 
                        DocumentsComplete - the customer has uploaded all the required documents; 
                        Approved - loan application has been approved; 
                        Cancelled - loan application has been cancelled; 
                        CustomerCancelled - loan application has been cancelled by the customer; 
                        ApplicationInProgress - loan application is in progress; 
                        BankAccountDetailsComplete - customer has completed his bank account details; 
                        OutOfStock - some of the items in the order are out of stock and the loan application was cancelled;
            key : - Query verification key. It is SHA512 encoded following string orderno|secret key|status. Secret key is provided by ZestMoney.
            loanApprovedAmount :-Loan amount, sent only when the loan application is approved
            isCOD : - True, if customer selected to pay downpayment on delivery. Present only once loan is approved
            amountCollected : -Downpayment amount. Only present when loan application is approved
            emiTerm : -The EMI term (number of months) that the customer has selected. Present only once the loan is approved
        */
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.UpdateOrder_API__c);
        req.setMethod('POST');
        req.setHeader('Authorization',Authorization);// set Authorization in All web service 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('User-Agent','RestSharp/105.2.3.0');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        
        String zestKey = orderno+'|'+objZest.client_secret__c+'|live';
        zestKey = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-512',Blob.valueOf(zestKey))).touppercase();
        System.debug('zestKey--'+zestKey);
        
        String requestBody = 'orderno='+orderno+'&status=live&applicationid='+applicationid+'&key='+zestKey;
        req.setBody(requestBody);
        
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('UpdateOrder_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('result--->'+result);
                return result ;
            }else{
                System.debug('Refunds_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception UpdateOrder_API__c :'+e.getMessage());
        }
        return null;
    }
    
    public String RefundsZestLoan(String RefundId ,String OrderId ,String ReasonCode , boolean IsPartial ,String RefundValue ,String RefundDate,Boolean isSubventionScheme){
        /*Parameters Passing for Refund and Description
            RefundId : -Unique identifier of refund
            OrderId :-  OrderId
            ReasonCode :-Reason of refund ( "DamagedGoods", "GoodsNotReceived", "NotAsDescribed", "GOGW", "PricingChanged", "BuyerRemorse", "Other")
            IsPartial :- true/false value indicating if it is partial refund (false for full refund)
            RefundValue :-Refund amount (required if it is partial refund)
            RefundDate :-Refund date
        */
        
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.Refunds_API__c);
        req.setMethod('POST');
        req.setHeader('Authorization',Authorization);// set Authorization in All web service 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('User-Agent','RestSharp/105.2.3.0');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        
        String jsonBody = '{\r\n\t\"RefundId\": \"'+RefundId+'\" ,\r\n\t\"OrderId\" : \"'+OrderId+'\",\r\n\t\"RefundValue\" : \"'+RefundValue+'\" ,\r\n\t\"ReasonCode\" :\"'+ReasonCode+'\",\r\n\t\"RefundDate\" : \"'+RefundDate+'\",\r\n\t\"IsPartial\" :\"'+IsPartial+'\"\r\n\t}';
        req.setBody(jsonBody);
        System.debug('jsonBoay--'+jsonBody);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Refunds_API__c:statusCode = '+statusCode);
            if(statusCode == 201){
                String result = resp.getBody();
                System.debug('result '+result);
                result = 'Refund Process Successfully';
                return result ;
            }else{
                System.debug('Refunds_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception Refunds_API__c :'+e.getMessage());
        }
        return null;
    }
    
    //Send ZestMoney notification that an order has been delivered to or Refused by customer
    public String getOrderDeliveryReportByOrderId(String orderId, String DeliveryStatus, Boolean isSubventionScheme, String recordId, String recordType){
        API_Request__c apiReq = new API_Request__c();
       /*Parameter for Delivery Report
           DeliveryStatus : -Delivered or Refused by customer
       */
       
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.DeliveryReport_API__c+OrderId);
        req.setMethod('POST');
        req.setHeader('Authorization',Authorization);// set Authorization in All web service 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('User-Agent','RestSharp/105.2.3.0');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        
        String jsonBody = '{\r\n\t\"DeliveryStatus\" : \"'+DeliveryStatus+'\"\r\n\t}';
        req.setBody(jsonBody);
        apiReq.Request__c = jsonBody;
        if(recordType == 'Opportunity'){
            apiReq.Opportunity__c = recordId;
        }else if(recordType == 'Lead'){
            apiReq.Lead__c = recordId;
        }
        apiReq.API_Name__c = 'ZestApprovalAPI';
        apiReq.Type_of_Request__c = 'Zest';
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('DeliveryReport_API__c:statusCode = '+statusCode);
            apiReq.Response__c = resp.getBody();
            if(statusCode == 200){
                apiReq.Success__c = true;
                apiRequestsInsertion(apiReq);
                return 'Order Id Updated';
            }else{
                System.debug('DeliveryReport_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception DeliveryReport_API__c :'+e.getMessage());
        }
        apiRequestsInsertion(apiReq);
        return null;
    }
    
    //Get the EMI values for a product from ZestMoney
    public String getEMIAmountBasedUponLoanAndDownPayment(decimal LoanAmount , decimal DownpaymentAmount,Boolean isSubventionScheme){
        /*Parameters Passing for cancelled Loan Application and Description
            orderid :- Order Id to be cancelled
            CancelLoanApplicationRequest : -Reason for cancellation as string
        */
        
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.EMI_API__c+'?merchantId='+objZest.client_id__c+'&LoanAmount='+LoanAmount+'&DownpaymentAmount='+DownpaymentAmount);
        req.setMethod('GET');
        req.setHeader('Authorization',Authorization);// set Authorization in All web service 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('User-Agent','RestSharp/105.2.3.0');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('EMI_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                if(!mapOfResponseParameters.isEmpty()){
                    for(String key : mapOfResponseParameters.keySet()){
                        System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    }
                }
                return result ;
            }
        }catch(Exception e){
            System.debug('Callout Exception EMI_API__c :'+e.getMessage());
        }
        return null;
    }
    
    //Update an old Order Id with a new Order Id
    public String updateOldOderIdByNewOrderId(String orderId , String newOrderId,Boolean isSubventionScheme){
        ZestMoneyAPI__c objZest = isSubventionScheme ? ZestMoneyAPI__c.getValues('Subvention Application Data') : ZestMoneyAPI__c.getValues('Loan Application Data');
        String Authorization = getAccessToken(isSubventionScheme);
        System.debug('Authorization----'+Authorization);
        // ZestMoneyAPI__c objZest = ZestMoneyAPI__c.getValues('Loan Application Data');
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(objZest.UpdateOrderId_API__c+orderId);
        req.setMethod('PUT');
        req.setHeader('Authorization',Authorization);// set Authorization in All web service 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('User-Agent','RestSharp/105.2.3.0');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        
        String jsonBody = '{\r\n\t\"newOrderId\" :\"'+newOrderId+'\"\r\n\t}';
        req.setBody(jsonBody);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('UpdateOrderId_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
               System.debug('result--->'+result);
               return result ;
            }else{
                System.debug('UpdateOrderId_API__c Error :'+resp.getBody());
            }
        }catch(Exception e){
            System.debug('Callout Exception UpdateOrderId_API__c :'+e.getMessage());
        }
        return null;
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                System.debug('apiRequest ==>'+apiRequest);
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }
}