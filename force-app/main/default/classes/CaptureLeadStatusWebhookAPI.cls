/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 09-12-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-10-2020   shubhranshu   Initial Version
**/
@RestResource(urlMapping='/getLeadStatus/V.1.0/*')
global class CaptureLeadStatusWebhookAPI {
    
    /**
    * @description 
    to capture the lead status depends on the lead stage passed
    * @author shubhranshu | 09-12-2020 
    * @return List<MessageWrapper> 
    **/
    @HttpPost
    global static List<MessageWrapper> captureLeadStatus(){

        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        String leadId = '';
        String LeadStage = '';
        MessageWrapper messageWrapper = null;

        List<Lead> lstLead;
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        // Reading parametrs from URL
        System.debug('restReq '+restReq.headers.get('consumerkey') +' '+restReq.headers.get('consumersecret'));
        leadId = restReq.params.get('leadId');
        LeadStage = restReq.params.get('LeadStage');
        
        System.debug('leadId '+leadId+' LeadStage '+LeadStage);

        if(String.isBlank(restReq.headers.get('consumerkey')) && String.isBlank(restReq.headers.get('consumersecret'))){
            messageWrapper = new MessageWrapper('501','header is missing.');
            lstmessageWrapper.add(messageWrapper);
            return lstmessageWrapper;
        }else if(restReq.headers.get('consumerkey') == System.Label.mauticWebhookConsumerKey && restReq.headers.get('consumersecret') == System.Label.mauticWebhookConsumerSecret){
            if(String.isNotBlank(leadId) && String.isNotBlank(LeadStage)) {    
                lstLead = [Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                            Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead WHERE Id =:leadId];
            }else{
                messageWrapper = new MessageWrapper('501','Parameter is missing.');
                lstmessageWrapper.add(messageWrapper);
                return lstmessageWrapper;
            }

            List<Lead> updateLst = new List<Lead>();

            if(lstLead.size() >0){
                for(Lead ld:lstLead){
                    if(String.isNotBlank(LeadStage)){    
                        if(LeadStage == '7'){
                            ld.Status_after_7_days__c = ld.Status;
                        } 
                        if(LeadStage == '15'){
                            ld.Status_after_15_days__c = ld.Status; 
                        }
                        if(LeadStage == '30'){
                            ld.Status_after_30_days__c = ld.Status; 
                        }
                        if(LeadStage == '60'){
                            ld.Status_after_60_days__c = ld.Status; 
                        }
                        if(LeadStage == '90'){
                            ld.Status_after_90_days__c = ld.Status; 
                        }
                        if(LeadStage == '180'){
                            ld.Status_after_180_days__c = ld.Status; 
                        }
                    }  
                    updateLst.add(ld);            
                }
            }else{
                messageWrapper = new MessageWrapper('502','Lead not found.');
                lstmessageWrapper.add(messageWrapper);
                return lstmessageWrapper;
            }

            System.debug('updateLst '+updateLst);
            
            if(updateLst.size() >0){
                try {
                    update updateLst;
                    messageWrapper = new MessageWrapper('200','Lead updated successfully.');
                } catch (DMLException e) {
                    System.debug('Error '+e.getMessage());
                    messageWrapper = new MessageWrapper('400','Error ->'+e.getMessage());
                    lstmessageWrapper.add(messageWrapper);
                    return lstmessageWrapper;
                }
            }else{
                messageWrapper = new MessageWrapper('500','Failed to update.');
                lstmessageWrapper.add(messageWrapper);
                return lstmessageWrapper;
            }

        }else{
            messageWrapper = new MessageWrapper('505','Invalid consumerkey or consumersecret.');
            lstmessageWrapper.add(messageWrapper);
            return lstmessageWrapper;
        }
        
        lstmessageWrapper.add(messageWrapper);
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
}