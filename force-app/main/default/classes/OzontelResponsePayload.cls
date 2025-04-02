/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 24-01-2025
 * @last modified by  : @BK
**/
public class OzontelResponsePayload {
    public String status { get; set; }
    public String message { get; set; }
    public List<AgentData> data { get; set; }

    public class AgentData {
        public String AgentState { get; set; }
        public String SkillName { get; set; }
        public String Mode { get; set; }
        public String PhoneNumber { get; set; }
        public String AgentId { get; set; }
        public String AgentName { get; set; }
    }

    // Method to parse JSON string into an OzontelResponsePayload object
    public static OzontelResponsePayload parse(String jsonString) {
        return (OzontelResponsePayload) JSON.deserialize(jsonString, OzontelResponsePayload.class);
    }
}