/**
 * @File Name          : RatingController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-05-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    13/5/2019, 6:43:55 PM   @BK     Initial Version
**/
public without sharing class RatingController{
    public Boolean isValid {get;set;}
    public String applicantName {get;set;}
    public Student_Rating__c objstdrating {get; set;}
    public string accountId {get;set;}
    public Account objAccount {get; set;}
    public String objStdRatingId {get;set;}
    public Boolean onSubmitCheck {get;set;}
    public String errorMessage {get;set;}
    public integer interviewScore {get;set;}
    public String LeadId {get;set;}
    public Date InterviewDate {get;set;}
    public String InterviewDateFormated {get;set;}
    public list<nm_WorkExperience__c> lstWorkExperience {get;set;}
    public Map<String,nm_Program__c> MapOfIdVsProgram {get;set;}
    public String getFirstAccount {get;set;}
    
    public RatingController(){
        isValid = false;
        applicantName = null;
        objstdrating = new Student_Rating__c();
        objStdRatingId = null;
        objAccount = new Account(); 
        onSubmitCheck = false;
        errorMessage = '';
        LeadId = '';
        interviewScore = 0;
        lstWorkExperience = new list<nm_WorkExperience__c>();
        MapOfIdVsProgram = new Map<String,nm_Program__c>();
        // if(ApexPages.currentPage().getParameters().get('RegNo') != null && ApexPages.currentPage().getParameters().get('RegNo') !=''){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RegNo'))){
            applicantName = ApexPages.currentPage().getParameters().get('RegNo');
            if(ApexPages.currentPage().getParameters().get('InterviewDate') != null) {
                InterviewDate = Date.parse(ApexPages.currentPage().getParameters().get('InterviewDate'));
                InterviewDateFormated = ApexPages.currentPage().getParameters().get('InterviewDate');
            }
            validateApplicantName();
        }
        getFirstAccount = getRandomAccountNumberForMBAwx();
    }

    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
    
    public void validateApplicantName(){
        isValid = false;
        System.debug('applicantName--'+applicantName);
        if(String.isNotBlank(applicantName)) {

            String AccountQuery = getQueryAllFieldSql('Account','nm_RegistrationNumber__c =:applicantName and nm_RegistrationNumber__c !=null','Interview_Slot__r.Faculty_name_1__c,nm_Program__r.nm_ProgramName__c');
            List<Account> lstAccount = DataBase.query(AccountQuery);
            if(lstAccount.size() > 0){
                objAccount = lstAccount[0];
                accountId  = objAccount.id;
                objAccount.id = null;
                LeadId = objAccount.nm_LeadId__c;
                isValid = true;
                InterviewDate = InterviewDate==null ? objAccount.Interview_Date__c : InterviewDate;
                if(InterviewDate!=null) {
                    InterviewDateFormated = InterviewDate.day() + '/' + InterviewDate.month() + '/' + InterviewDate.year();
                }
                System.debug('isValid -->'+isValid);
                System.debug('account id------- '+accountId);
                System.debug('submit check-------- '+onSubmitCheck );
                if(String.isNotBlank(accountId) && onSubmitCheck == false && InterviewDate!=null) {
                   System.debug('enter to check');
                    QueryRating();
                }
            }
            
           System.debug('account id'+accountId);
        }
    }

    public void QueryRating() {
        String StRatingQuery = getQueryAllFieldSql('Student_Rating__c','Student__c =:accountId and Interview_Date__c=:InterviewDate and RecordType.Name=\'Rating\'',null);
        List<Student_Rating__c> lststdrating = DataBase.query(StRatingQuery);
        System.debug('lst check '+lststdrating);
        if(lststdrating.size() > 0) {
            objstdrating = lststdrating[0];
            System.debug(objstdrating);
            objStdRatingId = objstdrating.id;
            objstdrating.id = null;
        } 

        lstWorkExperience = [SELECT id,nm_Student__c,nm_TotalMonths__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c FROM nm_WorkExperience__c WHERE nm_Student__c=:accountId];
        for (nm_WorkExperience__c objWXEP : lstWorkExperience) {
            objWXEP.id = null;
        }
        System.debug('---------------------lstWorkExperience---------------');
        System.debug(lstWorkExperience);
        getProgramsList();
    }

    public PageReference SaveDetail(){

        onSubmitCheck = true;
        validateApplicantName();

        if(String.isNotBlank(objStdRatingId)) {
            objstdrating.id = objStdRatingId;
        }
        
        if(isValid == true) {
            objstdrating.Student__c = accountId;
            String AcctId=objstdrating.Student__c;
            objstdrating.Interview_Date__c = objAccount.Interview_Date__c;
            objstdrating.ownerId = objAccount.ownerId;
            System.debug('objstdrating.Student__c-->  '+ objstdrating.Student__c);
            List<Account> lstinterviewscore= [Select id,Interview_Score__c, Interview_Slot__c from Account where Id=: AcctId];
            List<Account> lstupdate = new List<Account> ();
            List<Interview_Slot__c> lstInterviewSlot = new List<Interview_Slot__c>();
            if(lstinterviewscore.size() > 0) {
                lstInterviewSlot = [SELECT Id, Faculty_name_1__c FROM Interview_Slot__c WHERE Id=:lstinterviewscore[0].Interview_Slot__c Limit 1];
            
            }
            if(lstInterviewSlot.size() > 0) {
                objstdrating.Interviewer_Name__c =  lstInterviewSlot[0].Faculty_name_1__c;
            }

            objstdrating.RecordTypeId = Schema.Sobjecttype.Student_Rating__c.getRecordTypeInfosByName().get('Rating').getRecordTypeId();
          
            for(Account acc: lstinterviewscore){
                System.debug('interview score check-----> '+interviewScore);
                acc.Interview_Score__c=interviewScore;

                lstupdate.add(acc);
                System.debug('lstupdate---> '+lstupdate);
            } 
          
            if(lstupdate.size()>0){
                update lstupdate;
            }
            try {
                 
                upsert objstdrating; 
                errorMessage = 'Interview Form is submitted successfully!';
                return null;
            } catch (Exception e) {
                errorMessage = 'Internal error occured. Kindly contact admin.';
                return null;
            }
        }
        errorMessage = 'Invalid registration number.';
        return null;                               
    }

    public void getProgramsList(){
        String chooseProgram = objAccount.nm_ChooseaProgram__c;
        String queryProgram = '';
        System.debug('chooseProgram---------->'+chooseProgram);
        List<nm_Program__c> lstActiveProgram = new List<nm_Program__c>();
        if(chooseProgram == 'Master Programs') {
            String specialisation = objAccount.Program_Type__c;
            lstActiveProgram = [SELECT id,nm_ProgramName__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND Specialisation__c=:specialisation AND nmIsActive__c=true ORDER BY Name ASC];
        }else{
            lstActiveProgram = [SELECT id,nm_ProgramName__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND nmIsActive__c=true ORDER BY Name ASC];
        }
        System.debug('lstActiveProgram--'+lstActiveProgram);
        if(lstActiveProgram.size() > 0){
            for(nm_Program__c objProgram : lstActiveProgram){
                MapOfIdVsProgram.put(objProgram.id,objProgram);
            }
        }
    }

    public Double offset {
        get{
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }
    public String getRandomAccountNumberForMBAwx() {
        List<ProcessInstance> lstProcessInstance =  [SELECT Id, TargetObjectId,ProcessDefinitionId  FROM ProcessInstance WHERE Status = 'Pending'];
        system.debug('lstProcessInstance --> ' + lstProcessInstance );
        List<String> accountIds = new List<String>();
        for(ProcessInstance objProcessInstance : lstProcessInstance) {
            System.debug('objProcessInstance --> ' + objProcessInstance);
            System.debug('objProcessInstance --> ' + objProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName());
            if(objProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName() == 'Account' && objProcessInstance.ProcessDefinitionId == '04aO0000000D5na') {
                accountIds.add(objProcessInstance.TargetObjectId);
            }
        }
        return accountIds.size() > 0 ? accountIds[0] : 'random';
    }
  
}