/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 09-06-2024
 * @last modified by  : @vickysahu
**/
public class UsercenterByuserId{

    @InvocableMethod(label='getCenterUser' )
    public static List<nm_UserMapping__c> getUserCenterByUserId(List<FlowInputs> inputVariables)
    {
        String uId = inputVariables[0].userId;
        List<nm_UserMapping__c> liObj = new List<nm_UserMapping__c>();
        liObj = [Select id,nm_Centers__r.RecordType.name,nm_Centers__r.Name,nm_Centers__r.Nm_Active__c from nm_UserMapping__c where UserId__c =: uId AND nm_Centers__r.Nm_Active__c=true AND nm_Centers__r.RecordType.Name='Learning Center' limit 1 ];
 
        return liObj;
    }
    public class FlowInputs{
        @InvocableVariable(required=true)
        public String userId;
    }



}