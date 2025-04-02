/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 24-07-2024
 * @last modified by  : @BK
**/
public class SessionUser {
    public SessionUser() {
        this.objType = '';
        this.recordId = null;
        this.mapOfParameters = new Map<String,String>();
        this.startTime = null;
        this.ipAddress = '';
        this.userAgent = '';
        this.isVerified = false;
        this.timeLimit = 0;
    }

    public String objType {get;set;}
    public Id recordId {get;set;}
    public Map<String,String> mapOfParameters {get;set;}
    public DateTime startTime {get;set;}
    public String ipAddress {get;set;}
    public String userAgent {get;set;}
    public Boolean isVerified {get;set;}
    public Integer timeLimit {get;set;}
}