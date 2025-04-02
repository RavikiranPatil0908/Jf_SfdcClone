public class CallBackUrlRequestWrapper {
    public String AgentPhoneNumber;
    public String Disposition;
    public String CallerConfAudioFile;
    public String TransferredTo;	
    public String Apikey;
    public String Did;
    public String StartTime;
    public String CallDuration;
    public String EndTime;
    public String ConfDuration;
    public String CustomerStatus;
    public String TimeToAnswer;
    public String monitorUCID;
    public String AgentID;
    public String AgentStatus;
    public String Location;	
    public String FallBackRule;
    public String CampaignStatus;
    public String CallerID;
    public String Duration;
    public String Status;
    public String AgentUniqueID;
    public String UserName;
    public String HangupBy;
    public String AudioFile;
    public String PhoneName;
    public String TransferType;
    public String DialStatus;
    public String CampaignName;
    public String UUI;
    public String AgentName;
    public String Skill;
    public String DialedNumber;
    public String Type;
    public String Comments;

    public Static CallBackUrlRequestWrapper parse(String json) {
            return (CallBackUrlRequestWrapper) System.JSON.deserialize(json, CallBackUrlRequestWrapper.class);
        }

}