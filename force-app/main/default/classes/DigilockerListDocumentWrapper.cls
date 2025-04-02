/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : @BK
**/
public class DigilockerListDocumentWrapper {

    public Data data;
    public Integer status_code;
    public Boolean success;
    public String message;
    public String message_code;

    public class Documents {
        public String file_id;
        public String name;
        public String doc_type;
        public Boolean downloaded;
        public String issuer;
        public String description;
    }

    public class Data {
        public List<Documents> documents;
    }

    
    public static DigilockerListDocumentWrapper parse(String json) {
        return (DigilockerListDocumentWrapper) System.JSON.deserialize(json, DigilockerListDocumentWrapper.class);
    }
}