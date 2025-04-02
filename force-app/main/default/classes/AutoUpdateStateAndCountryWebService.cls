/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 20-08-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-27-2020   shubhranshu   Initial Version
**/
global without sharing class AutoUpdateStateAndCountryWebService {

    private static final String BILLING = 'Billing';
    private static final String PERMANENT = 'Permanent';
    private static final String SHIPPING = 'Shipping';
    private static final String ACCOUNT = 'Account';
    private static final String LEAD = 'Lead';

    /**
     * Updates state and country information on an Account record.
     *
     * @param accountId The ID of the Account record to update.
     */
    public static void updateStateAndCountyOnAccount(Id accountId) {
        List<Account> accounts = [SELECT Id, nm_City__c, City_Shipping_Account__c, nm_PostalCode__c, BillingCity, BillingState, BillingCountry, 
                            State_Province_Shipping__c, Country_Shipping__c, Zip_Postal_Code_Shipping__c,
                            nm_StateProvince__c, nm_Country__c, BillingPostalCode
                            FROM Account 
                            WHERE Id = :accountId LIMIT 1];

        if (!accounts.isEmpty()) {
            Account account = accounts[0];
            updateAddressDetails(account.BillingPostalCode, account, BILLING);
            updateAddressDetails(account.nm_PostalCode__c, account, PERMANENT);
            updateAddressDetails(account.Zip_Postal_Code_Shipping__c, account, SHIPPING);

            update account;
        }
    }

    /**
     * Updates state and country information on a Lead record.
     *
     * @param leadId The ID of the Lead record to update.
     */
    public static void updateStateAndCountyOnLead(Id leadId) {
        List<Lead> leads = [SELECT Id, City, nm_City_P__c, Shipping_City__c, nm_PostalCode_P__c, State, Country, State_Province_Shipping__c, 
                     Country_Shipping__c, Zip_Postal_Code_Shipping__c, nm_StateProvince_P__c, nm_Country_P__c, PostalCode
                     FROM Lead 
                     WHERE Id = :leadId LIMIT 1];

        if (!leads.isEmpty()) {
            Lead lead = leads[0];
            updateAddressDetails(lead.PostalCode, lead, BILLING);
            updateAddressDetails(lead.nm_PostalCode_P__c, lead, PERMANENT);
            updateAddressDetails(lead.Zip_Postal_Code_Shipping__c, lead, SHIPPING);

            update lead;
        }
    }

    /**
     * Updates address details on a record based on postal code.
     *
     * @param postalCode The postal code to update.
     * @param record The record to update (Account or Lead).
     * @param type A string indicating the type of address (e.g., 'Billing', 'Shipping').
     */
    private static void updateAddressDetails(String postalCode, Account account, String type) {
        if (String.isNotBlank(postalCode)) {
            Map<String, String> response = fetchAddressDetails(postalCode);

            if ('Success'.equals(response.get('Status'))) {
                applyAddressDetails(account, response, type);
            }
        }
    }

    /**
     * Updates address details on a record based on postal code.
     *
     * @param postalCode The postal code to update.
     * @param record The record to update (Account or Lead).
     * @param type A string indicating the type of address (e.g., 'Billing', 'Shipping').
     */
    private static void updateAddressDetails(String postalCode, Lead lead, String type) {
        if (String.isNotBlank(postalCode)) {
            Map<String, String> response = fetchAddressDetails(postalCode);

            if ('Success'.equals(response.get('Status'))) {
                applyAddressDetails(lead, response, type);
            }
        }
    }

    /**
     * Fetches address details from an external service.
     *
     * @param postalCode The postal code to fetch details for.
     * @return A map containing address details.
     */
    private static Map<String, String> fetchAddressDetails(String postalCode) {
        GeocodeController geocodeController = new GeocodeController();
        GeocodeResult result = geocodeController.processGeocode(postalCode, System.Label.GeoCodeServiceType);

        return parseGeocodeResult(result);
    }

    /**
     * Parses the result from the geocode service into a map.
     *
     * @param result The geocode result to parse.
     * @return A map containing parsed address details.
     */
    private static Map<String, String> parseGeocodeResult(GeocodeResult result) {
        Map<String, String> addressDetails = new Map<String, String>();
        
        addressDetails.put('Country', result.country);
        addressDetails.put('State', result.state);
        addressDetails.put('District', result.city);
        addressDetails.put('Status', result.postalCodeMessage);

        return addressDetails;
    }

    /**
     * Applies address details to an Account record based on the type of address.
     *
     * @param account The Account record to update.
     * @param details The address details to apply.
     * @param type A string indicating the type of address (e.g., 'Billing', 'Shipping').
     */
    private static void applyAddressDetails(Account account, Map<String, String> details, String type) {
        if (BILLING.equals(type)) {
            account.BillingState = details.get('State');
            account.BillingCountry = details.get('Country');
            account.BillingCity = details.get('District');
        } else if (PERMANENT.equals(type)) {
            account.nm_StateProvince__c = details.get('State');
            account.nm_Country__c = details.get('Country');
            account.nm_City__c = details.get('District');
        } else if (SHIPPING.equals(type)) {
            account.State_Province_Shipping__c = details.get('State');
            account.Country_Shipping__c = details.get('Country');
            account.City_Shipping_Account__c = details.get('District');
        }
    }

    /**
     * Applies address details to a Lead record based on the type of address.
     *
     * @param lead The Lead record to update.
     * @param details The address details to apply.
     * @param type A string indicating the type of address (e.g., 'Billing', 'Shipping').
     */
    private static void applyAddressDetails(Lead lead, Map<String, String> details, String type) {
        if (BILLING.equals(type)) {
            lead.State = details.get('State');
            lead.Country = details.get('Country');
            lead.City = details.get('District');
        } else if (PERMANENT.equals(type)) {
            lead.nm_StateProvince_P__c = details.get('State');
            lead.nm_Country_P__c = details.get('Country');
            lead.nm_City_P__c = details.get('District');
        } else if (SHIPPING.equals(type)) {
            lead.State_Province_Shipping__c = details.get('State');
            lead.Country_Shipping__c = details.get('Country');
            lead.Shipping_City__c = details.get('District');
        }
    }

    @AuraEnabled
    webservice static String getToken(String sapId)
    {
        System.debug('sapId ==>'+sapId);
        // generate Time Token
        DateTime myDateTime = DateTime.now();
        Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
        Blob data = Blob.valueOf(sapId+'~'+myDateTime.getTime());
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
        String token = EncodingUtil.base64Encode(encryptedData);
        String urlEncodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
        urlEncodedToken = EncodingUtil.urlDecode(urlEncodedToken, 'UTF-8');
        return urlEncodedToken ;
    }   

    @AuraEnabled(cacheable=true)
    public static String getSapId(String recordId){
        String sapId = '';
        try {
            if(String.isNotBlank(recordId) && recordId.startsWith('500')) {
                sapId = [SELECT Student_Number__c FROM Case WHERE Id=:recordId].Student_Number__c;
            } else if(String.isNotBlank(recordId)) {
                sapId = [SELECT nm_StudentNo__c FROM Account WHERE Id=:recordId].nm_StudentNo__c;
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return sapId;
    }
}