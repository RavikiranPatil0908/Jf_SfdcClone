/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : @BK
**/
public class DigilockerInitializeWrapper {
    
    public Data data;
    public Integer status_code;
    public String message_code;
    public String message;
    public Boolean success;

    public class Data {
        public String client_id;
        public String token;
        public String url;
        public Decimal expiry_seconds;
    }

    
    public static DigilockerInitializeWrapper parse(String json) {
        return (DigilockerInitializeWrapper) System.JSON.deserialize(json, DigilockerInitializeWrapper.class);
    }
}