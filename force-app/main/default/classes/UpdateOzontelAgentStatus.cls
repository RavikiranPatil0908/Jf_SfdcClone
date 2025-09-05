/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : @vickysahu
**/
public without sharing class UpdateOzontelAgentStatus {
    @InvocableMethod(label='Update Agent Status' description='Agent Status update after VVC' category='Ozontel Agent Status')
    public static void callAPIToUpdateStatus(List<FlowInputs> request) {
        if (!System.isFuture()) {
            CallWebService(request[0].ozontelId);
        }
    }

    @future(callout=true)
    public static void callWebService(String ozontelId) {
        //AgentService.changeAgentStatus(ozontelId,'Ready');
        System.debug('comment');  
    }
    
    public class FlowInputs {
        @InvocableVariable(required=true)
         public String ozontelId;
    }
}