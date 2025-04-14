/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08--04--2025
 * @last modified by  : @Ravi
**/
public without sharing class HomePageController {
    public SessionUser objSessionUser { get; set; }
    public String pageBlock { get; set; }
    public Boolean isConfirmed {get;set;}
    public Boolean isValid {get;set;}
    public String redirectUrl {get;set;}
    public String studentno {get;set;}
    public Boolean isInterviewEnabled {get;set;}
    public Id leadId{get; set;}  // GMT tracking 

    public HomePageController() {
        objSessionUser = new SessionUser();
        redirectUrl = '';
        String navParam = ApexPages.currentPage().getParameters().get('nav');
        String navigationParam = String.isNotBlank(navParam) ? navParam.escapeHtml4() : null;
        pageBlock = setPageBlock(navigationParam);
        isConfirmed = false;
        isValid = false;
        studentno = '';
        isInterviewEnabled = false;
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    * @param String navigationParam 
    * @return String 
    **/
    public String setPageBlock(String navigationParam) {
        List<String> lstOfnavParams = new List<String>{'dashboard','payment','form','reviewForm','document','call','ticket','letter','interview','history'};
        if(String.isNotBlank(navigationParam) && lstOfnavParams.contains(navigationParam)) {
            redirectUrl = '?nav='+navigationParam;
            return navigationParam == 'form' ? 'form1' : navigationParam;
        } else  {
            return 'dashboard';
        }
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    **/
    public void queryData() {
        try {
            if (objSessionUser.objType == 'Account') {
                getAccount();
            } else if (objSessionUser.objType == 'Lead') {
                getLead();
            }
        } catch (Exception error) {
            System.debug('Error Message ==>'+ error.getMessage());
            System.debug('Error Message Line no==>'+ error.getLineNumber());
        }
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    **/
    public void getAccount() {
        List<Account> lstAccount = [SELECT Id, nm_StudentStatus__c, nm_StudentNo__c, nm_ProgramType__c, nm_Program__r.Name, Program_Type__c,nm_LeadId__c,send_Interview_registration_mail__c,Interview_Status__c FROM Account WHERE Id=:objSessionUser.recordId LIMIT 1];
        if (lstAccount.size() > 0) {
            Account objAccount = lstAccount[0];
            List<Opportunity> lstOpp = [SELECT Id,nm_Session__c,nm_Year__c,nm_Fee_Type__c,AccountId FROM Opportunity WHERE AccountId=:objAccount.Id LIMIT 1];
            RequestWrapper objWrapper = new RequestWrapper();
            objWrapper.chooseProgram = objAccount.nm_ProgramType__c;
            objWrapper.programType = objAccount.Program_Type__c;
            isInterviewEnabled = objAccount.send_Interview_registration_mail__c && objAccount.Interview_Status__c!='Selected' ? true : false;
            objWrapper.session = lstOpp.size() > 0 ? lstOpp[0].nm_Session__c : '';
            objWrapper.year = lstOpp.size() > 0 ? lstOpp[0].nm_Year__c.intValue() : null;
            studentno = objAccount.nm_StudentNo__c;
            isConfirmed = objAccount.nm_StudentStatus__c == 'Confirmed' && String.isNotBlank(objAccount.nm_StudentNo__c) ? true : false;
            leadId = objAccount.nm_LeadId__c;  // GMT tracking 
        }
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    **/
    public void getLead() {
        List<Lead> lstLead = [SELECT Id,nm_ChooseaProgram__c,nm_Session__c,nm_Year__c,Program_Type__c FROM Lead WHERE Id=:objSessionUser.recordId LIMIT 1];
        if (lstLead.size() > 0) {
            Lead objLead = lstLead[0];
            RequestWrapper objWrapper = new RequestWrapper();
            objWrapper.chooseProgram = objLead.nm_ChooseaProgram__c;
            objWrapper.programType = objLead.Program_Type__c;
            objWrapper.session = objLead.nm_Session__c;
            objWrapper.year = objLead.nm_Year__c.intValue();
            isValid = setValid(objWrapper);
            if(!isValid) {
                update objLead;
            }
            leadId = objLead.Id;  // GMT tracking 
        }
    }


    /**
    * @description 
    * @author @BK | 24-07-2024 
    * @param RequestWrapper objWrapper 
    * @return Boolean 
    **/
    public Boolean setValid(RequestWrapper objWrapper) {
        List<Calender__c> lstCalender = getActiveCalender(objWrapper.chooseProgram,objWrapper.programType);
        if (lstCalender.size() > 0) { 
            return String.isNotBlank(objWrapper.session) && objWrapper.year!=null && objWrapper.session == lstCalender[0].Session__c && objWrapper.year == lstCalender[0].Year__c ? true : false;
        }
        return false;
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    * @param String program 
    * @param String specialization 
    * @return List<Calender__c> 
    **/
    public List<Calender__c> getActiveCalender(String program,String specialization) {
        List<Calender__c> lstCalender = [SELECT Id, Year__c, Specialisation__c, Session_End_Date__c, Session__c, Category__c, Session_Start_Date__c FROM Calender__c WHERE Category__c='Admission' AND nm_Type__c=:program AND Specialisation__c=:specialization AND Session_Start_Date__c <= Today AND Session_End_Date__c >= Today LIMIT 1];
        return lstCalender;
    }

    /**
    * @description 
    * @author @BK | 23-05-2024 
    * @return PageReference 
    **/
    public PageReference validateSession() {
        SessionManager obj = new SessionManager();
        objSessionUser = obj.isSessionAvailable();
        if(!objSessionUser.isVerified) {
            PageReference pgURL = new PageReference('/apex/ApplicationInquiry'+redirectUrl);
            pgURL.setRedirect(true);
            return pgURL;
        }
        if(!isValid) {
            queryData();
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 24-07-2024 
    * @return PageReference 
    **/
    public PageReference logout() {
        SessionManager obj = new SessionManager();
        obj.clearSession();
        PageReference pg = new PageReference('/apex/ApplicationInquiry'+redirectUrl);
        pg.setRedirect(true);
        return pg;
    }

    private class RequestWrapper {
        private String chooseProgram {get; set;}
        private String programType {get; set;} 
        private String session {get; set;} 
        private Integer year {get; set;}

    }
    
}