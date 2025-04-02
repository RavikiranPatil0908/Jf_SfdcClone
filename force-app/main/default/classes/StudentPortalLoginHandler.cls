public with sharing class StudentPortalLoginHandler {
    public StudentPortalLoginHandler() {

    }

    // Constants for static values
    private static final String BASE_URL = System.Label.Student_Portal + 'm/updateStudentPortalProgramStatus';
    
    /*
        To deactivate
        https://studentzone-ngasce.nmims.edu/studentportal/m/updateStudentPortalProgramStatus
        {
        "sapid" : "",
        "programStatus":"Program Terminated"
        }
        To Activate

        https://studentzone-ngasce.nmims.edu/studentportal/m/updateStudentPortalProgramStatus
        {
        "sapid" : "",
        "programStatus":"Activate"
        }

        Response on success
        {
        "success": "true",
        "message": "SuccessFully Added!"
        }
*/
    // Utility method to send the email and handle HTTP request

    
    public static void StudentStatusChangeFromPayment(List<nm_Payment__c> triggerNew,map<id,nm_Payment__c> oldMap){
        Set<String> paymentTypelst = new Set<String>{
            'Admission',
            'Installment'
        };
        System.debug('StudentPortalLoginHandler123::: '+ triggerNew);
        if(triggerNew.size() > 0){
            if(triggerNew[0].nm_PaymentStatus__c == 'Payment Disapproved' && oldMap.get(triggerNew[0].Id).nm_PaymentStatus__c != triggerNew[0].nm_PaymentStatus__c && 
            triggerNew[0].Student_Status__c == 'Confirmed' && paymentTypelst.contains(triggerNew[0].nm_PaymentType__c))
            {
                studentstatuschangeRequest(triggerNew[0].nm_OpportunityNew__c, 'Opportunity','Deactivate');
            }
            else if(triggerNew[0].nm_PaymentStatus__c == 'Payment Approved' && oldMap.get(triggerNew[0].Id).nm_PaymentStatus__c != triggerNew[0].nm_PaymentStatus__c && 
             paymentTypelst.contains(triggerNew[0].nm_PaymentType__c)) //triggerNew[0].Student_Status__c == 'Confirmed' &&
            {
                studentstatuschangeRequest(triggerNew[0].nm_OpportunityNew__c, 'Opportunity','Activate');
            }
        }

    }

    public static void studentstatuschangeRequest(String recordvalue, String objtype,String action) {
        String recordId = String.valueOf(recordvalue).substring(0, 15);
        List<Account> userAccount = new List<Account>();
        List<Opportunity> userOppor = new List<Opportunity>();
        String SapId = '';
        // if(objtype == 'Account'){
        //     userAccount = [SELECT Id, nm_StudentNo__c FROM Account WHERE Id =: recordId AND Synced_With_LDAP__c = true ]; //AND nm_StudentStatus__c = 'Confirmed'
        //     if(userAccount.size() > 0 ){
        //         SapId = userAccount[0].nm_StudentNo__c;
        //         if(SapId != null && SapId != '')
        //         {
        //             studentDeactivateorActivateRequest(SapId, action, recordId);
        //         }
        //     }
            
        // }
        // else
         if(objtype == 'Opportunity'){
            userOppor = [SELECT Id, Account.nm_StudentNo__c FROM Opportunity WHERE Opportunity.Id =:recordId AND Synced_With_StudentZone__c = true AND nm_Fee_Type__c IN ('AnnualFee','MultipleSemFee','FullFee','3SemFee','MBAallTermfee','admission')]; //AND Account.nm_StudentStatus__c = 'Confirmed' 
            if(userOppor.size() > 0 ){
                SapId = userOppor[0].Account.nm_StudentNo__c;
                if(SapId != null && SapId != '')
                {
                    studentDeactivateorActivateRequest(SapId, action, recordId);
                }
            }
        }
    }
    @future(callout=true)
    private static void studentDeactivateorActivateRequest(String SapId, String action,String recordId) {

        if(System.label.Environment != 'Production')
        {
            SapId = '77777777168'; 
        }
        // Prepare request body map 
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('sapid', SapId);  // Customize subject if needed
        if(action == 'Deactivate'){
            requestBodyMap.put('programStatus', 'Program Terminated');
        }
        else if(action == 'Activate'){
            requestBodyMap.put('programStatus', 'Activate');
        }

        String requestBody = JSON.serialize(requestBodyMap);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
           if( !Test.isRunningTest()){ //System.label.Environment == 'Production' &&
                response = http.send(req);
           }

                String objectType = getObjectName(recordId);
                // Log response based on status
                String responseBody = response.getBody();
                if (!Test.isRunningTest() && response.getStatusCode() == 200) {
                    APIRequestHandler.insertAPIRequest(requestBody, responseBody, 'updateStudentPortalProgramStatus', true, recordId, objectType, 'PortalAPI');
                } else {
                    APIRequestHandler.insertAPIRequest(requestBody, responseBody, 'updateStudentPortalProgramStatus', false, recordId, objectType, 'PortalAPI');
                    System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                }
            } catch (Exception e) {
                System.debug('Error sending HTTP request: ' + e.getMessage());
            }
    }
    private static String getObjectName(String recordId) {
        try {
            return String.isBlank(recordId) ? null : Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        } catch (Exception error) {
            System.debug('Error Message = '+error.getMessage());
        }
        return null;
    }
}