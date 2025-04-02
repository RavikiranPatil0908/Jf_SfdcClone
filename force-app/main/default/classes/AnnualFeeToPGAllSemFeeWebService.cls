global class AnnualFeeToPGAllSemFeeWebService {
    webService Static String deleteRecord(String lstIds, String objType) {
        System.debug('lstIds ---> ' + lstIds);
        System.debug('objType ---> ' + objType);
        List<String> listIds = lstIds.split(',');
        if(listIds.size() > 0) {
            System.debug('listIds ---> ' + listIds);
            String strng = '';
            for(String str : listIds) {
                strng = strng + '\'' + str + '\',' ;
            }
            strng = strng.contains(',') ? strng.substring(0, strng.length() -1) : strng;
            system.debug('strng ----> ' + strng);
            try {
                String query = 'SELECT Id ';
                query += 'FROM ' + objType + ' ';
                query += 'WHERE Id IN (' + strng + ') ' ;
                query += 'LIMIT 1';
                system.debug('query ---> ' + query);
                List<SObject> listToRemove = Database.query(query);
                System.debug(listToRemove);
                delete listToRemove;
                return 'success';
            } catch(DmlException e) {
                return e.getMessage();
            }
        }
        return 'No record To delete';
    }
}