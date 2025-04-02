/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : @BK
**/
public class DigilockerDocumentDownloadWrapper {
    
    public Data data;
    public Integer status_code;
    public Boolean success;
    public String message;
    public String message_code;

    public class Data {
        public String download_url;
        public String mime_type;
    }

    
    public static DigilockerDocumentDownloadWrapper parse(String json) {
        return (DigilockerDocumentDownloadWrapper) System.JSON.deserialize(json, DigilockerDocumentDownloadWrapper.class);
    }
}