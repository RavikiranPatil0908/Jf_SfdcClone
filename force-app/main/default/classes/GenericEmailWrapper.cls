global class GenericEmailWrapper {
    @auraEnabled public String status;
    @auraEnabled public List<Responsedata> response;

    public class Responsedata {
        @auraEnabled public String parentId;
        @auraEnabled public String createdDate;
        @auraEnabled public String subject;
        @auraEnabled public String fromEmailId;
        @auraEnabled public String mailId;
        @auraEnabled public String body;
        // @AuraEnabled public String fromAddress = '';
        // @AuraEnabled public String toAddress = '';
    }

    public static GenericEmailWrapper parse(String json) {
        return ((GenericEmailWrapper) System.JSON.deserialize(json, GenericEmailWrapper.class));
    }
}