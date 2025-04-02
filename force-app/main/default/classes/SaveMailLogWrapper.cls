public class SaveMailLogWrapper {

    public String templateId {get;set;}
    public String type {get;set;}
    public String recordId {get;set;}
    public String parentId {get;set;}
    public String mailId {get;set;}
    public String fromEmailId {get;set;}
    public String mailBody {get;set;}
    public String mailBodytype {get;set;}
    public String mailSubject {get;set;}
    public String registrationNumber {get;set;}
    
    public SaveMailLogWrapper(String templateId,String type,String recordId,String parentId,String mailId,String fromEmailId,String mailBody,String mailBodytype,String mailSubject,String registrationNumber) {
        this.templateId = templateId;
        this.type = type;
        this.recordId = recordId;
        this.parentId = parentId;
        this.mailId = mailId;
        this.fromEmailId = fromEmailId;
        this.mailBody = mailbody;
        this.mailBodytype = mailBodytype;
        this.mailSubject = mailSubject;
        this.registrationNumber = registrationNumber;
        
    }
    
}