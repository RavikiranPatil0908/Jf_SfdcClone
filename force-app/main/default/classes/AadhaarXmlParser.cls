/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-21-2024
 * @last modified by  : @vickysahu
**/
global class AadhaarXmlParser {

    // Define a wrapper class to return the extracted data
    public class ExtractedData {
        public String pht { get; set; }  // Holds the value of the Pht element
        public String name { get; set; } // Holds the name attribute from the Poi element
        public String dob { get; set; }  // Holds the dob attribute from the Poi element
        public String uid { get; set; }  // Holds the uid attribute from the UidData element
    }

    webService static String fetchImageXml(String url) {
        System.debug('url--->' + url);
        ExtractedData data = fetchAndParseXml(url);
        return data.pht;
    }

    /**
     * Fetches XML data from a given URL and parses it.
     *
     * @param url The URL of the XML file.
     * @return An ExtractedData object containing the parsed values or null if there is an error.
     */
    public static ExtractedData fetchAndParseXml(String url) {
        // Return null if the URL is blank or null
        if (String.isBlank(url)) {
            return null;
        }

        // Fetch XML data from the URL
        String xmlString = fetchXmlFromUrl(url);

        // Parse the XML string and extract the required data
        return parseXmlAttributes(xmlString);
    }

    /**
     * Fetches XML data from a given URL.
     *
     * @param url The URL of the XML file.
     * @return The XML data as a string or null if the request fails.
     */
    private static String fetchXmlFromUrl(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/xml');
        
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('HTTP request failed: ' + e.getMessage());
            return null;
        }

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            System.debug('HTTP response error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            return null;
        }
    }


    /**
     * Parses the provided XML string to extract specific data.
     *
     * @param xmlString The XML string to be parsed.
     * @return An ExtractedData object containing the extracted values or null if parsing fails.
     */
    private static ExtractedData parseXmlAttributes(String xmlString) {
        // Return null if the input XML string is blank or null
        if (String.isBlank(xmlString)) {
            return null;
        }

        // Initialize the ExtractedData object to store the parsed values
        ExtractedData data = new ExtractedData();
        
        try {
            // Create and load the XML document
            Dom.Document doc = new Dom.Document();
            doc.load(xmlString);
            
            // Get the root element of the XML
            Dom.XMLNode root = doc.getRootElement();
            
            // Extract the CertificateData node
            Dom.XMLNode certificateDataNode = getChildElement(root, 'CertificateData');
            if (certificateDataNode == null) { return null; }
            
            // Extract the KycRes node
            Dom.XMLNode kycResNode = getChildElement(certificateDataNode, 'KycRes');
            if (kycResNode == null) { return null; }
            
            // Extract the UidData node
            Dom.XMLNode uidDataNode = getChildElement(kycResNode, 'UidData');
            if (uidDataNode == null) { return null; }
            
            // Extract data from the Poi and Pht elements
            extractPoiData(uidDataNode, data);
            extractPhtData(uidDataNode, data);
        } catch (Exception e) {
            // Log the error message and line number if an exception occurs
            System.debug('Error: ' + e.getMessage());
            System.debug('Error Line Number: ' + e.getLineNumber());
            return null;
        }

        // Return the extracted data
        return data;
    }

    /**
     * Retrieves a child XML element by name from the parent node.
     *
     * @param parentNode The parent XML node.
     * @param childName The name of the child element to retrieve.
     * @return The child XML node, or null if not found.
     */
    private static Dom.XMLNode getChildElement(Dom.XMLNode parentNode, String childName) {
        return parentNode.getChildElement(childName, null);
    }

    /**
     * Extracts the Poi data from the UidData node.
     *
     * @param uidDataNode The UidData XML node.
     * @param data The ExtractedData object to store the extracted values.
     */
    private static void extractPoiData(Dom.XMLNode uidDataNode, ExtractedData data) {
        Dom.XMLNode poiNode = getChildElement(uidDataNode, 'Poi');
        if (poiNode != null) {
            data.uid = uidDataNode.getAttribute('uid', null);
            data.dob = poiNode.getAttribute('dob', null);
            data.name = poiNode.getAttribute('name', null);
        }
    }

    /**
     * Extracts the Pht data from the UidData node.
     *
     * @param uidDataNode The UidData XML node.
     * @param data The ExtractedData object to store the extracted values.
     */
    private static void extractPhtData(Dom.XMLNode uidDataNode, ExtractedData data) {
        Dom.XMLNode phtNode = getChildElement(uidDataNode, 'Pht');
        if (phtNode != null) {
            data.pht = phtNode.getText().trim();
        }
    }
}