@RestResource(urlMapping='/LeadSquareWebhookAPI/V1.1/*')
global without sharing class LeadSquareWebhookAPI {
    
     @HttpPost
    global static List<MessageWrapper> TrackLeadStage(){
         List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
          try {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('requestString '+requestString);
     //   requestString  = requestString.replace('"number"','"mnumber"');
        LeadSquareWrapper reqWrapper = LeadSquareWrapper.parse(requestString);
        apiReq.Request__c = requestString;
        System.debug(reqWrapper);
        String EmailAddress ='';
        String Mobile ;
       // String Mobile ;
        String LeadStatus='';
        String LeadDescription='';
        String ProspectStage ='';
        
        
        MessageWrapper messageWrapper = null;
         if(String.isNotBlank(reqWrapper.Before.EmailAddress)){
            EmailAddress = String.valueof(reqWrapper.Before.EmailAddress);            
        }else{
            return returnMessage(requestString,'511','EmailAddress is missing.');
        }
         if(reqWrapper.Before.Mobile!=null){
           Mobile = String.valueof(reqWrapper.Before.Mobile);            
        }else{
            return returnMessage(requestString,'510','Mobile is missing.');
        }
        
         if(String.isNotBlank(reqWrapper.After.mx_Lead_Status)){
            LeadStatus = String.valueof(reqWrapper.After.mx_Lead_Status);            
        }else{
            return returnMessage(requestString,'512','LeadStatus is missing.');
        }if(String.isNotBlank(reqWrapper.After.mx_Lead_Description)){
            LeadDescription = String.valueof(reqWrapper.After.mx_Lead_Description);            
        }else{
            return returnMessage(requestString,'513','Lead Description is missing.');
        }
        List<Lead> updateLstLead = new List<Lead>();
       List<Lead> lstLead = new List<Lead>();
     if(EmailAddress!=null || Mobile!=null)
     {
         lstLead = [select id,email,mobilePhone,Status,Lead_Description__c from Lead where (email =:EmailAddress or mobilePhone =:Mobile) and IsConverted=false and GroupName__c='Group 1'];
     }
     
     if(lstLead.size()>0 && LeadStatus!='')
     {
         for( Lead objled : lstLead)
         {
         if(objled.Status!=LeadStatus)
         {
              objled.Status = LeadStatus;
             objled.Next_Follow_up__c= system.now().addMinutes(30);
             if(LeadDescription!=''&& LeadDescription !=null)
             {
               objled.Lead_Description__c= LeadDescription;

             }
             system.debug('objled.id-->'+objled.id);
             updateLstLead.add(objled);
         }
            
         }
     }
     
    if(updateLstLead.size()>0)
    {
           try{
                        update updateLstLead;
                        system.debug('Enter to update');
                        messageWrapper = new MessageWrapper('200','Webhook API Data updated.');
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'LeadSquare';
                        apiReq.API_Name__c='LeadSquareWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'LeadSquare';
                        apiReq.API_Name__c='LeadSquareWebhookAPI';
                        apiReq.Success__c = false;
                    }
    }else{
                return returnMessage(requestString,'505','Error, please try again.');
    } 
      lstmessageWrapper.add(messageWrapper);
            apiRequestsInsertion(apiReq);   
          }catch (Exception error) {
               System.debug(error);
          } 
         
           return lstmessageWrapper;
        
    }
        public static List<MessageWrapper> returnMessage(String requestString, String code, String msg) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'LeadSquare';
        apiReq.API_Name__c='LeadSquareWebhookAPI';
        apiReq.Success__c = false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }
       global class MessageWrapper{
        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
        }
          public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    
}