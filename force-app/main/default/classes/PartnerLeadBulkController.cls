/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 08-24-2024
 * @last modified by  : @Ravi
**/
global class PartnerLeadBulkController {
    public Blob csvFileBody { get; set; }
    public String csvAsString { get; set; }
    public String userId = UserInfo.getUserId();

    /**
    * @description 
    * @author Ravi | 08-16-2024 
    * @return List<ReturnVariables> 
    **/
    @InvocableMethod(label='Create IC Record' description='Get Information Center From Login User Information')
    public static List<String> getInformationCenters(List<InputVariables> inputVariables) {
        String Id = inputVariables[0].UserIds;  

        List<nm_UserMapping__c>  IC = [SELECT Id, nm_Centers__c FROM nm_UserMapping__c WHERE UserId__c = :Id LIMIT 1];
        // String informationCenterId = IC[0].nm_Centers__c;
        // System.debug('informationCenterId..'+informationCenterId);
        List<String> informationCenterIds = new List<String>();
        if (!IC.isEmpty()) {
            String informationCenterId = IC[0].nm_Centers__c;
            System.debug('informationCenterId: ' + informationCenterId);
            informationCenterIds.add(informationCenterId);
        } else {
            System.debug('No Information Center found for the given UserId.');
             informationCenterIds.add(null);
        }
        return informationCenterIds;
    }

    public void importCSVFile() {
        try {
            transient String[] csvFileLines = new String[]{};
            transient Map<String, String> headerMap = new Map<String, String>();
            transient Map<String, Integer> mapHeaderCount = new Map<String, Integer>();
            PartnerLeadBulkHelper asyncwrapper = new PartnerLeadBulkHelper();
            String informationCentersId = null;
            
            nm_UserMapping__c userMapping = [SELECT Id, nm_Centers__c FROM nm_UserMapping__c WHERE UserId__c = :userId LIMIT 1];
            informationCentersId = userMapping.nm_Centers__c;

            csvAsString = csvFileBody.toString();
            csvFileBody = null;
            // Split CSV String into lines
            csvFileLines = csvAsString.split('\n');

            if (csvFileLines.size() > 200) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, 'The uploaded CSV file contains more than the allowed maximum records (200).')
                );
                return;
            }

            List<String> lstHeaders = csvFileLines[0].trim().split(',');
            headerMap = asyncwrapper.getWrapper.getheaderMap;

            for (String headervalue : headerMap.keySet()) {
                if (!lstHeaders.contains(headervalue)) {
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.ERROR, 'The uploaded CSV file does not contain the required columns.')
                    );
                    return;
                }
            }

            // Find the column position
            Integer count = 0;
            for (String headerVal : lstHeaders) {
                if (asyncwrapper.getWrapper.getheaderMap.containsKey(headerVal)) {
                    mapHeaderCount.put(headerVal, count);
                    System.debug('headerVal : ' + count + ' :: ' + headerVal);   
                }
                count++;
            }

            List<Partner_Lead__c> csvDataList = new List<Partner_Lead__c>();
            System.debug('mapHeaderCount :: ' + csvFileLines.size() + ' :: ' + mapHeaderCount.size());

            // Iterate CSV file lines and retrieve Stock_Keeping_Units__c ID and Assumption__c value
            if(csvFileLines.size() <= 1 || csvFileLines.size() > 200)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while importing data into Salesforce. Please make sure the input CSV file is correct.');
                ApexPages.addMessage(errorMessage);
                return;
            }
            for (Integer i = 1; i < csvFileLines.size(); i++) {
                String[] csvRecordData = csvFileLines[i].split(',');

                Partner_Lead__c partnerLeadData = new Partner_Lead__c();

                for (String headerkey : asyncwrapper.getWrapper.getheaderMap.keySet()) {
                    if(String.isBlank(csvRecordData[mapHeaderCount.get(headerkey)].trim()) && !headerkey.equalsIgnoreCase('Agency')){
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while importing data into Salesforce. Please make sure the input CSV file is correct.');
                        ApexPages.addMessage(errorMessage);
                        return;
                    }
                    partnerLeadData.put(asyncwrapper.getWrapper.getheaderMap.get(headerkey), String.isBlank(csvRecordData[mapHeaderCount.get(headerkey)].trim()) ? NULL : csvRecordData[mapHeaderCount.get(headerkey)].trim());
                }
                partnerLeadData.put('Information_Center__c', informationCentersId);
                partnerLeadData.put('Lead_Source__c', 'Partner');    
                csvDataList.add(partnerLeadData); 
            }
            
            System.debug('csvDataMap before :' + csvDataList.toString());

            Database.SaveResult[] srList = Database.insert(csvDataList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Partner Lead ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Partner Lead fields that affected this error: ' + err.getFields());
                    }
                }
            }

            // insert csvDataList;

        } catch (Exception e) {
            System.debug('Error 1 is ==> ' + e.getMessage());
            System.debug('Error 2 is ==> ' + e.getLineNumber());

            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while importing data into Salesforce. Please make sure the input CSV file is correct.');
            ApexPages.addMessage(errorMessage);
        }
    }


    global class InputVariables {
        @InvocableVariable
        public String UserIds;         
    }

    // global class ReturnVariables {
    //     @InvocableVariable
    //     public List<String> ICNames;         
    // }
}