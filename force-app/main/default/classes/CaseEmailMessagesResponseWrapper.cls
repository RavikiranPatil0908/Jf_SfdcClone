global class CaseEmailMessagesResponseWrapper  {

    @auraEnabled public String status;
    @auraEnabled public String message;
    @auraEnabled public List<EmailMessagesResponseWrapper> response;
    public static List<EmailMessagesResponseWrapper> parse(String json) {
        return ((CaseEmailMessagesResponseWrapper) System.JSON.deserialize(json, CaseEmailMessagesResponseWrapper.class)).response;
    }
}