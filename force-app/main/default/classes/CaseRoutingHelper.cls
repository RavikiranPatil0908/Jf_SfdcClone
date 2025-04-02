/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-09-2024
 * @last modified by  : @BK
**/
public class CaseRoutingHelper {
    
    /**
     * Retrieves the case owner ID based on the routing utility and provided case details.
     * 
     * @param utils The utility class that provides case routing methods and related data.
     * @param objCase The case object for which the owner ID needs to be determined.
     * @param mapOfUserVsCount A map that associates user IDs with their respective counts.
     * @param internalTicketCases The record type ID used to identify internal ticket cases.
     * @return The owner ID of the case, or null if an error occurs during processing.
     */
    public static String getCaseOwnerId(CaseRoutingUtility utils, Case objCase, Map<String,Integer> mapOfUserVsCount, String internalTicketCases) {
        try {
            String ownerId = null; // Variable to hold the determined owner ID.
            
            // Determine the subcategory based on the record type ID.
            String subCategory = objCase.RecordTypeId == internalTicketCases ? objCase.InternalSub_Category__c : objCase.sub_categories__c;
            // Generate a unique mapping key using the owner ID and subcategory.
            String mapKey = getMapUniqueKey(objCase.OwnerId, objCase.sub_categories__c, utils);
            // Retrieve the list of user IDs associated with the generated mapping key.
            List<String> lstUserId = utils.objWrapper.caseRotuingMap.get(mapKey);
            
            // If there are multiple user IDs and a count map exists, determine the owner with the lowest count.
            if (!lstUserId.isEmpty() && lstUserId.size() > 1 && !mapOfUserVsCount.isEmpty()) {
                ownerId = getLowestCount(lstUserId, mapOfUserVsCount);
            } else {
                // If there's only one user ID, assign it as the owner ID.
                ownerId = lstUserId.isEmpty() ? null : lstUserId[0];
            }
            return ownerId; // Return the determined owner ID.
        } catch (Exception error) {
            // Log any errors encountered during execution.
            System.debug('error ==>' + error.getMessage());
            System.debug('error ==>' + error.getLineNumber());
            return null; // Return null if an error occurs.
        }
    }

    /**
     * Identifies the user ID with the lowest associated count from a list of user IDs.
     * 
     * @param lstUserId A list of user IDs to evaluate for the lowest count.
     * @param mapOfUserVsCount A map that links user IDs to their respective counts.
     * @return The user ID with the lowest count, or the first missing user ID if no valid IDs are found.
     */
    public static String getLowestCount(List<String> lstUserId, Map<String,Integer> mapOfUserVsCount) {
        String lowKey = mapOfUserVsCount.isEmpty() ? null : new List<String>(mapOfUserVsCount.keySet())[0]; // Initialize lowKey with the first key if the map is not empty.
        String noKey = null; // To track the first missing user ID in the list.

        for (String userId : lstUserId) {
            Id ccUserId = userId; // Cast userId to Id for consistency (if necessary).
            if (mapOfUserVsCount.containsKey(userId)) {
                // Update lowKey if the current user ID has a lower count than the current lowKey.
                lowKey = mapOfUserVsCount.get(userId) < mapOfUserVsCount.get(lowKey) ? userId : lowKey;
            } else {
                // Capture the first user ID that is not found in the count map and break the loop.
                noKey = ccUserId;
                break;
            }
        }
        // Return either the first missing user ID or the user ID with the lowest count.
        return String.isNotBlank(noKey) ? noKey : lowKey;
    }

    /**
     * Updates the count for a specified user ID in the provided map.
     * 
     * @param mapOfUserVsCount The map associating user IDs with their current counts.
     * @param recId The user ID to update the count for.
     * @return The updated map reflecting the incremented count for the specified user ID.
     */
    public static Map<String,Integer> updateMapUserVsCount(Map<String,Integer> mapOfUserVsCount, String recId) {
        // Retrieve the current count for the user ID or initialize it to 0 if not found.
        Integer count = mapOfUserVsCount.containsKey(recId) ? mapOfUserVsCount.get(recId) : 0;
        count++; // Increment the count.
        mapOfUserVsCount.put(recId, count); // Update the map with the new count.
        return mapOfUserVsCount; // Return the updated map.
    }

    /**
     * Constructs a unique key based on the record ID and subcategory for case routing.
     * 
     * @param recId The record ID (owner ID) to use in the unique key.
     * @param subCategory The subcategory associated with the case.
     * @param utils The utility class providing case routing methods and data.
     * @return A unique key based on the mapping, or null if no valid key is found.
     */
    public static String getMapUniqueKey(String recId, String subCategory, CaseRoutingUtility utils) {
        // Get the owner's name based on the record ID.
        String ownerName = utils.objWrapper.mapOfQueueIdVsName.get(recId);
        // Create a unique key combining the subcategory and owner name.
        String uniqueKey = subCategory + '_' + ownerName;
        String uniqueKey2 = 'All_' + ownerName; // Create a general unique key for the owner.
        
        // Return the first matching unique key found in the routing map, or null if none match.
        return utils.objWrapper.caseRotuingMap.containsKey(uniqueKey) ? uniqueKey 
            : (utils.objWrapper.caseRotuingMap.containsKey(uniqueKey2) ? uniqueKey2 : null);
    }
}