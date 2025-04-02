/**
 * @description       : DigilockerWebService class to handle API interactions with DigiLocker.
 * @author            : @test
 * @group             : 
 * @last modified on  : 11-09-2024
 * @last modified by  : @BK
**/
public class DigilockerWebService {
    
    // Constants for the API endpoints
    private static final String PRODUCTION_URL = 'https://kyc-api.surepass.io';
    private static final String SANDBOX_URL = 'https://sandbox.surepass.io';

    /**
     * @description Generates a DigiLocker OAuth URL where the end user can complete the DigiLocker OAuth process.
     * @param fullName Full name of the user.
     * @param mobile Mobile number of the user.
     * @param userEmail Email address of the user.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerInitializeWrapper Response from the Digilocker initialize API.
     */
    public static DigilockerInitializeWrapper initializeDigilocker(String fullName, String mobile, String userEmail, Id recordId) {
        HttpRequest req = new HttpRequest();
        String baseUrl = getBaseUrl();

        // Setting up the request endpoint and headers
        req.setEndpoint(baseUrl + '/api/v1/digilocker/initialize');
        req.setMethod('POST');
        req.setHeader('authorization', 'Bearer ' + System.Label.DigiLockerToken);
        req.setHeader('content-type', 'application/json');

        // Constructing the JSON body for the POST request
        String jsonBody = '{"data":{' +
                                '"prefill_options":{' +
                                    '"full_name": "' + String.escapeSingleQuotes(fullName) + '",' +
                                    '"mobile_number": "' + String.escapeSingleQuotes(mobile) + '",' +
                                    '"user_email": "' + String.escapeSingleQuotes(userEmail) + '"' +
                                '},' +
                                '"expiry_minutes":20,' +
                                '"send_sms":false,' +
                                '"send_email":false,' +
                                '"verify_phone":false,' +
                                '"verify_email":false,' +
                                '"signup_flow":false,' +
                                '"redirect_url": "'+ String.escapeSingleQuotes(System.Label.Site_Url) + 'EnrollmentForm?nav=document",' +
                                '"state":"test"' +
                            '}}';
        System.debug(jsonBody);
        req.setBody(jsonBody);

        // Handling the API response
        return handleDigilockerInitialize(req, 'InitializeDigilockerAPI', recordId);
    }

    /**
     * @description Retrieves the current status of the OAuth flow for a given client.
     * @param clientId Client ID from the OAuth process.
     * @param recordId Salesforce record ID related to this operation.
     * @return Boolean True if the OAuth status is retrieved successfully, false otherwise.
     */
    public static Boolean getDigilockerOauthStatus(String clientId, Id recordId) {
        HttpRequest req = new HttpRequest();
        String baseUrl = getBaseUrl() + '/api/v1/digilocker/status/' + String.escapeSingleQuotes(clientId);

        // Setting up the request endpoint and headers
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        req.setHeader('authorization', 'Bearer ' + System.Label.DigiLockerToken);
        req.setHeader('content-type', 'application/json');

        // Handling the API response
        return handleDigilockerStatus(req, 'DigilockerOauthStatusAPI', recordId);
    }

    /**
     * @description Fetches a list of issued documents from DigiLocker for a given client.
     * @param clientId Client ID from the OAuth process.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerListDocumentWrapper Response containing the list of documents.
     */
    public static DigilockerListDocumentWrapper getListOfDocument(String clientId, Id recordId) {
        HttpRequest req = new HttpRequest();
        String baseUrl = getBaseUrl() + '/api/v1/digilocker/list-documents/' + String.escapeSingleQuotes(clientId);

        // Setting up the request endpoint and headers
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        req.setHeader('authorization', 'Bearer ' + System.Label.DigiLockerToken);
        req.setHeader('content-type', 'application/json');

        // Handling the API response
        return handleDigilockerListDocument(req, 'DigilockerListOfDocumentAPI', recordId);
    }

    /**
     * @description Downloads a specific document from DigiLocker by passing the file ID.
     * @param clientId Client ID from the OAuth process.
     * @param fileId File ID of the document to be downloaded.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerDocumentDownloadWrapper Response containing the downloaded document data.
     */
    public static DigilockerDocumentDownloadWrapper getDigilockerDownloadedDocument(String clientId, String fileId, Id recordId) {
        HttpRequest req = new HttpRequest();
        String baseUrl = getBaseUrl() + '/api/v1/digilocker/download-document/' + String.escapeSingleQuotes(clientId) + '/' + String.escapeSingleQuotes(fileId);

        // Setting up the request endpoint and headers
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        req.setHeader('authorization', 'Bearer ' + System.Label.DigiLockerToken);
        req.setHeader('content-type', 'application/json');

        // Handling the API response
        return handleDigilockerDownloadedDocument(req, 'DigilockerDownloadedDocumentAPI', recordId);
    }

    /**
     * @description Handles the API response for initializing DigiLocker.
     * @param req HttpRequest object with the API call details.
     * @param apiName Name of the API being called.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerInitializeWrapper Parsed response object.
     */
    private static DigilockerInitializeWrapper handleDigilockerInitialize(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        DigilockerInitializeWrapper response = new DigilockerInitializeWrapper();
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                response = DigilockerInitializeWrapper.parse(resp.getBody());
                insertAPIRequest(req.getBody(), resp.getBody(), apiName, true, recordId, sObjName);
                return response;
            } else {
                insertAPIRequest(req.getBody(), resp.getBody(), apiName, false, recordId, sObjName);
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' -- ' + e.getLineNumber());
            insertAPIRequest(req.getBody(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName);
        }
        return null;
    }

    /**
     * @description Handles the API response for retrieving OAuth status.
     * @param req HttpRequest object with the API call details.
     * @param apiName Name of the API being called.
     * @param recordId Salesforce record ID related to this operation.
     * @return Boolean True if the status was successfully retrieved, false otherwise.
     */
    private static Boolean handleDigilockerStatus(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                insertAPIRequest(req.getEndpoint(), String.valueOf(resp.getStatusCode()), apiName, true, recordId, sObjName);
                return true;
            } else {
                insertAPIRequest(req.getEndpoint(), String.valueOf(resp.getStatusCode()), apiName, false, recordId, sObjName);
            }
        } catch (Exception e) {
            insertAPIRequest(req.getEndpoint(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName);
        }
        return false;
    }

    /**
     * @description Handles the API response for fetching a list of documents from DigiLocker.
     * @param req HttpRequest object with the API call details.
     * @param apiName Name of the API being called.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerListDocumentWrapper Parsed response object containing the list of documents.
     */
    private static DigilockerListDocumentWrapper handleDigilockerListDocument(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        DigilockerListDocumentWrapper response = new DigilockerListDocumentWrapper();
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                response = DigilockerListDocumentWrapper.parse(resp.getBody());
                insertAPIRequest(req.getEndpoint(), resp.getBody(), apiName, true, recordId, sObjName);
                return response;
            } else {
                insertAPIRequest(req.getEndpoint(), resp.getBody(), apiName, false, recordId, sObjName);
            }
        } catch (Exception e) {
            insertAPIRequest(req.getEndpoint(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName);
        }
        return null;
    }

    /**
     * @description Handles the API response for downloading a specific document from DigiLocker.
     * @param req HttpRequest object with the API call details.
     * @param apiName Name of the API being called.
     * @param recordId Salesforce record ID related to this operation.
     * @return DigilockerDocumentDownloadWrapper Parsed response object containing the downloaded document data.
     */
    private static DigilockerDocumentDownloadWrapper handleDigilockerDownloadedDocument(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        DigilockerDocumentDownloadWrapper response = new DigilockerDocumentDownloadWrapper();
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                response = DigilockerDocumentDownloadWrapper.parse(resp.getBody());
                // insertAPIRequest(req.getEndpoint(), resp.getBody(), apiName, true, recordId, sObjName);
                return response;
            } else {
                // insertAPIRequest(req.getEndpoint(), resp.getBody(), apiName, false, recordId, sObjName);
            }
        } catch (Exception e) {
            // insertAPIRequest(req.getEndpoint(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName);
        }
        return null;
    }

    /**
     * @description Determines the base URL for the API based on the current environment (Sandbox or Production).
     * @return String The base URL to use for API requests.
     */
    private static String getBaseUrl() {
        return system.label.Environment == 'Sandbox' ? SANDBOX_URL : PRODUCTION_URL;
    }

    /**
     * @description Logs API requests and responses into a custom Salesforce object for auditing purposes.
     * @param req The request body or endpoint.
     * @param res The response body or status code.
     * @param apiName The name of the API being logged.
     * @param isSuccess Indicates whether the API call was successful.
     * @param recordId The Salesforce record ID related to this operation.
     * @param sObjName The Salesforce object name derived from the record ID.
     */
    private static void insertAPIRequest(String req, String res, String apiName, Boolean isSuccess, Id recordId, String sObjName) {
        if(!Test.isRunningTest()) {
            APIRequestHandler.insertAPIRequest(req, res, apiName, isSuccess, recordId, sObjName, 'Digilocker');
        }
    }

}