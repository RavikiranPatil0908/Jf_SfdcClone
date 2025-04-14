/**
 * @description       : Controller for fetching and paginating email logs for Leads, Accounts, and Cases.
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 08--04--2025
 * @last modified by  : @Ravi
 **/
public without sharing class EmailLogsPageController {

    public Id recordId;
    public String objectType;
    public List<Responsedata> lstOfEmails { get; set; }
    public List<Responsedata> paginatedEmails { get; set; }
    public Map<Integer, Responsedata> mapOfkeyVsEmailRecords { get; set; }
    public EmailWrapper wrapper { get; set; }
    public Responsedata emailDetails { get; set; }
    public Integer keyCounter { get; set; }
    public Integer key { get; set; }
    public Boolean isRecordQueried { get; set; }
    public String mapData { get; set; }
    public Integer pageNumber { get; set; }
    public Integer pageSize { get; set; }
    public Integer totalRecords { get; set; }
    public Integer totalPages { get; set; }
    public Integer currentPage { get; set; }
    public Integer counter { get; set; }
    public String regNo { get; set; }

    public EmailLogsPageController() {
        pageNumber = 1;
        currentPage = 1;
        pageSize = 10; 
        paginatedEmails = new List<Responsedata>();
        lstOfEmails = new List<Responsedata>();
        wrapper = new EmailWrapper();
        mapOfkeyVsEmailRecords = new Map<Integer, Responsedata>();
        emailDetails = new Responsedata();
        keyCounter = 1;
        key = 0;
        isRecordQueried = false;
        mapData = '';
        regNo = '';
    }

    /**
     * @description Gets the object type.
     * @return String
     **/
    public String getObjectType() { 
        return objectType; 
    }

    /**
     * @description Sets the object type.
     * @param objectType
     **/
    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    /**
     * @description Gets the record Id.
     * @author @Ravi | 18--02--2025 
     * @return Id
     **/
    public Id getRecordId() {
        return recordId;
    }

    /**
     * @description Sets the record Id and fetches email logs.
     * @author @Ravi | 18--02--2025 
     * @param recordId
     **/
    public void setRecordId(Id recordId) {
        this.recordId = recordId;
        
        if (getObjectType() == 'Lead') {
            List<Lead> leadLst = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c FROM Lead WHERE Id = :recordId LIMIT 1];
            if (!leadLst.isEmpty()) {
                regNo = leadLst[0].nm_RegistrationNo__c;
            }
        } else if (getObjectType() == 'Account') {
            List<Account> accountLst = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c FROM Account WHERE Id = :recordId LIMIT 1];
            if (!accountLst.isEmpty()) {
                regNo = accountLst[0].nm_RegistrationNumber__c;
            }
        }
        if (String.isNotBlank(regNo) && !this.isRecordQueried) {
            lstOfEmails = getEmailLogs(regNo).response;
            totalRecords = lstOfEmails.size();
            totalPages = (Integer) Math.ceil(totalRecords / (Decimal) pageSize);
            mapOfkeyVsEmailRecords.clear();
            applyPagination();
            this.isRecordQueried=true;
            //mapData=JSON.serialize(mapOfkeyVsEmailRecords);
            System.debug('email List ==> Response' + mapData);
        }
    }

    /**
     * @description Applies pagination logic to email logs.
     * @author @Ravi | 19--02--2025 
     **/
    public void applyPagination() {
        mapOfkeyVsEmailRecords.clear();
        paginatedEmails.clear();
        Integer startIdx = (pageNumber - 1) * pageSize;
        Integer endIdx = Math.min(startIdx + pageSize, lstOfEmails.size());
        
        if (startIdx < lstOfEmails.size()) {
            for (Integer i = startIdx; i < endIdx; i++) {
                Responsedata email = lstOfEmails[i];
                email.serialNumber = i + 1;
                paginatedEmails.add(email);
                mapOfkeyVsEmailRecords.put(email.serialNumber, email);
            }
        }
        mapData = JSON.serialize(mapOfkeyVsEmailRecords);
    }

    /**
     * @description Navigates to the next page.
     * @author @Ravi | 19--02--2025 
     **/
    public void nextPage() {
        if (pageNumber < totalPages) {
            currentPage++;
            pageNumber++;
            applyPagination();
        }
    }

    /**
     * @description Navigates to the previous page.
     **/
    public void previousPage() {
        if (pageNumber > 1) {
            pageNumber--;
            currentPage--;
            applyPagination();
        }
    }

    /**
     * @description Fetches email logs from an external API.
     * @author @Ravi | 19--02--2025 
     * @param parentId
     * @return EmailWrapper
     **/
    public EmailWrapper getEmailLogs(String regNumber) {
        Map<String, String> mapOfRequestParam = new Map<String, String>();
        // mapOfRequestParam.put('registrationNumber', regNumber);
        mapOfRequestParam.put('registrationNumber', regNumber);
        String jsonString = JSON.serialize(mapOfRequestParam);
        HttpRequest req = new HttpRequest();
        String EndPoint = System.Label.Student_Zone_Base_Url + 'salesforce-emailLogs/m/getSfdcEmailLog';
        req.setMethod('POST');
        req.setEndpoint(EndPoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonString);
        
        Http http = new Http();
        HttpResponse resp;
        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                return wrapper.parse(resp.getBody());
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return new EmailWrapper();
    }

    public class EmailWrapper {
        public String status { get; set; }
        public List<Responsedata> response { get; set; }
        public EmailWrapper parse(String json) {
            return (EmailWrapper) System.JSON.deserialize(json, EmailWrapper.class);
        }
    }

    public class Responsedata {
        public Integer serialNumber { get; set; }
        public String parentId { get; set; }
        public String registrationNumber {get; set;}
        public String createdDate { get; set; }
        public String subject { get; set; }
        public String fromEmailId { get; set; }
        public String mailId { get; set; }
        public String body { get; set; }
    }
}