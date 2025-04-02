/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-05-2024
 * @last modified by  : @BK
**/
public without sharing class FetchAvailableAgent {
    
    /**
    * @description 
    * @author @BK | 10-05-2024 
    * @param List<OmniChannelRequest> request 
    * @return List<OmniChannelResponse> 
    **/
    @InvocableMethod(label='Fetch Available Agent' description='To get the agent i to create agent work')
    public static List<OmniChannelResponse> getLeastOwnerId(List<OmniChannelRequest> request){
        String caseId = request[0].caseId;
        OmniChannelResponse objWrapper = new OmniChannelResponse();
        List<OmniChannelResponse> lst = new List<OmniChannelResponse>();
        objWrapper.leastOwnerId = null;

        // To check if case is already assigned to someone
        Id userId = getAlreadyOwnerId(caseId);

        // To get the avialable agent and thier capacity
        Map<Id,UserServicePresence> mapOfUserIdVsCurrentStage = new Map<Id,UserServicePresence>();
        List<UserServicePresence> lstUSP = [SELECT Id,ConfiguredCapacity,IsAway,AtCapacityDuration,AverageCapacity,UserId FROM UserServicePresence WHERE IsCurrentState = true AND ServicePresenceStatus.MasterLabel IN ('Available - Cases','Available')];
        if(Test.isRunningTest()) {
            lstUSP = mockData();
        }

        System.debug('Total Capacity ->' + lstUSP.Size());
        for (UserServicePresence obj : lstUSP) {
            mapOfUserIdVsCurrentStage.put(obj.UserId,obj);
        }

        // to check if the avialable agent has the case already assigned to him
        System.debug('Size ==>'+mapOfUserIdVsCurrentStage.size());
        if(userId!=null && mapOfUserIdVsCurrentStage.containsKey(userId)) {
            objWrapper.leastOwnerId = (String)userId;
            lst.add(objWrapper);
            return lst;
        }

        // To get the avialable agents work
        if(!mapOfUserIdVsCurrentStage.isEmpty()) {
            List<AggregateResult> aggrResults = [SELECT UserId, COUNT(Id) rcount FROM AgentWork WHERE AssignedDateTime=TODAY AND UserId IN :mapOfUserIdVsCurrentStage.keySet() GROUP BY UserId ORDER BY COUNT(Id) ASC];
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            for (AggregateResult ar : aggrResults) {
                results.add(ar.getPopulatedFieldsAsMap());
            }
            if(!Test.isRunningTest() && aggrResults.size() > 0) {
                objWrapper.leastOwnerId = getUserId(mapOfUserIdVsCurrentStage.keySet(), results);
            }
            System.debug('User with least records '+objWrapper.leastOwnerId);
        }
        
        lst.add(objWrapper);
        return lst;
    }

    /**
    * @description To check if case is already assigned to someone
    * @author @BK | 10-05-2024 
    * @param String caseId 
    * @return String 
    **/
    public static Id getAlreadyOwnerId(String caseId) {
        if(String.isBlank(caseId)) {
            return null;
        }
        List<AgentWork> lst = [SELECT UserId FROM AgentWork WHERE WorkItemId=:caseId AND AcceptDateTime!=null ORDER BY AcceptDateTime DESC LIMIT 1];
        if(lst.size() > 0) {
            return lst[0].UserId;
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 10-05-2024 
    * @param Set<Id> setOfAvailableUserId 
    * @return String 
    **/
    public static String getUserId(Set<Id> setOfAvailableUserId, List<Map<String, Object>> results) {
        String userId = null;
        Set<Id> setOfUserId = new Set<Id>();
        for (Map<String, Object> obj : results) {
            setOfUserId.add((Id)obj.get('UserId'));
        }
        for (Id mapKey : setOfAvailableUserId) {
            if(!setOfUserId.contains(mapKey)) {
                userId = (String)mapKey;
            }
        }

        if(String.isBlank(userId)) {
            userId = (String)results[0].get('UserId');
        }
        return userId;
    }

    /**
    * @description // To mock data of UserPresence for test class
    * @author @BK | 10-05-2024 
    * @return List<UserServicePresence> 
    **/
    public static List<UserServicePresence> mockData() {
        return new List<UserServicePresence>{
            new UserServicePresence(
                UserId=UserInfo.getUserId()
            )
        };
    }

    // Response
    public class OmniChannelResponse {
        @InvocableVariable(
            label = 'Agent User Id'
            description = 'User Id returned from Least amount of work'
        )
        public String leastOwnerId;
    } 

    //Required Paramters
	public class OmniChannelRequest {
		@InvocableVariable(
            label = 'Case Id'
            description = 'Case Record Id'
            required=true)
		public String caseId;
	}
}