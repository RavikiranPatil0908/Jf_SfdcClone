/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 25-01-2025
 * @last modified by  : @BK
**/
public without sharing class AgentService {
    
    // Main method to filter available agents
    public static Set<Id> filterVoiceCallActive(Map<String, Id> mapOfOzontelIdVsAgentId) {
        Set<Id> availableAgents = new Set<Id>();
        Set<String> allAgentNames = new Set<String>(mapOfOzontelIdVsAgentId.keySet());  // Set of agent names from the input map

        // Make the API call and get the response
        String responseBody = makeApiCall();
        
        // If the response is valid, process it and filter the agents
        if (responseBody != null) {
            Map<String, String> agentOzontelIdToStatus = getAgentStatusFromResponse(responseBody);
            availableAgents = filterAgentsFromResponse(agentOzontelIdToStatus, mapOfOzontelIdVsAgentId);
        }

        // Return available agents or fallback to the input map
        return availableAgents.isEmpty() ? new Set<Id>(mapOfOzontelIdVsAgentId.values()) : availableAgents;
    }
    
    // Makes the API call and returns the response body
    private static String makeApiCall() {
        String jsonString = '{ "userName": "nmims_2" }';
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/getAgentLogins');
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('apiKey', System.Label.OzontelAPIKey); 
        req.setHeader('accept', 'application/json');
        req.setBody(jsonString);
        
        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                return resp.getBody();
            }
        } catch (Exception e) {
            System.debug('Callout Exception: ' + e.getMessage());
        }
        
        return null;  // Return null if an error occurs or no valid response
    }

    // Extract agent ozontel Id and their statuses from the API response
    private static Map<String, String> getAgentStatusFromResponse(String responseBody) {
        Map<String, String> agentOzontelIdToStatus = new Map<String, String>();
        try {
            OzontelResponsePayload responseWrapper = OzontelResponsePayload.parse(responseBody);
            if (responseWrapper.status == 'success' && responseWrapper.data != null && !responseWrapper.data.isEmpty()) {
                for (OzontelResponsePayload.AgentData payload : responseWrapper.data) {
                    agentOzontelIdToStatus.put(payload.AgentId, payload.AgentState);
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing response: ' + e.getMessage());
        }
        return agentOzontelIdToStatus;
    }

    // Filters available agents based on the agent ozontel Id and status in the response
    private static Set<Id> filterAgentsFromResponse(Map<String, String> agentOzontelIdToStatus, Map<String, Id> mapOfOzontelIdVsAgentId) {
        Set<Id> availableAgents = new Set<Id>();
        
        for (String agentOzontelId : mapOfOzontelIdVsAgentId.keySet()) {
            if (agentOzontelIdToStatus.containsKey(agentOzontelId)) {
                // Agent exists in API response; Check their status
                String agentState = agentOzontelIdToStatus.get(agentOzontelId);
                if (isAgentAvailable(agentState)) {
                    availableAgents.add(mapOfOzontelIdVsAgentId.get(agentOzontelId));
                }
            } else {
                // Agent not in API response; Always include
                availableAgents.add(mapOfOzontelIdVsAgentId.get(agentOzontelId));
            }
        }
        
        return availableAgents;
    }

    // Determines if an agent is available based on their state
    private static Boolean isAgentAvailable(String agentState) {
        // Check if the agent state is neither "Busy" nor "ACW" (After Call Work)
        return agentState != 'Busy' && agentState != 'BUSY';
    }
}