/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
public class DynamicQueryBuilder {

    /**
     * Generates a SOQL query string for the specified SObject with all fields and given conditions.
     *
     * @param sObjectAPIName The API name of the SObject to query.
     * @param conditionString The WHERE clause conditions for the query.
     * @param relatedFields A comma-separated list of additional related fields to include in the query.
     * @return A SOQL query string.
     * @throws IllegalArgumentException if the SObjectAPIName is invalid or null.
     */
    public static String getQueryAllFieldSql(String sObjectAPIName, String conditionString, String relatedFields) {
        if (String.isBlank(sObjectAPIName)) {
            throw new IllegalArgumentException('SObject API name cannot be null or empty.');
        }

        if (String.isBlank(conditionString)) {
            throw new IllegalArgumentException('conditionString cannot be null or empty.');
        }

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if (!schemaMap.containsKey(sObjectAPIName)) {
            throw new IllegalArgumentException('Invalid SObject API name: ' + sObjectAPIName);
        }

        Schema.SObjectType sObjectType = schemaMap.get(sObjectAPIName);
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        if (!String.isBlank(relatedFields)) {
            fieldNames.addAll(relatedFields.split(','));
        }

        String query = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + sObjectAPIName + ' WHERE ' + conditionString;
        return query;
    }
}