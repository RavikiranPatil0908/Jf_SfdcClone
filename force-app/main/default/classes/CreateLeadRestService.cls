/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-01-2024
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/createleadrestservice/*')
global without sharing class CreateLeadRestService
{    
    global class WapperId
    {
        public String LeadId {get;set;}
        public String result {get;set;}
        public String message {get;set;}
        public String url{get;set;}
        public WapperId(String Id,String message,String result)
        {
            this.LeadId=Id;
            this.message=message ;
            this.result =result;
        }
          
        public WapperId(String message,String result)
        {
            this.message=message ;
            this.result =result;
        }
        public WapperId(String url)
        {
            this.url =url;
            
        }
    }
         
    @HttpPost
    global static WapperId connectToEnquiry(String Name,String EmailID,String ContactNo,String Agency,String HighestQualification,decimal AdmissionYear,String CurrentLocation,String CourseIntrestedIn,String AgencyPassword)
    {
        String leadSource='Web';
        String Category='Distance Learning / Correspondence';
        string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
        RestRequest req = RestContext.request;
        String ipAddress = req.remoteAddress;
        WapperId objWapper ;
        List<Agency_Access__c> lstAgency =[select Name,Email__c,Is_Active__c,password__c from Agency_Access__c where Name =:Agency and password__c =:AgencyPassword and Is_Active__c=true];
        if(lstAgency.size()>0)
        {
            Lead objLead = new Lead(LastName=Name,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CurrentLocation,Highest_Qualification__c=HighestQualification,Agency__c=Agency,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress);
            try
            {
                insert objLead;
                objWapper = new WapperId(objLead.id,'Lead Inserted Successfully','Success');
            }
            catch(Exception e)
            {
                objWapper = new WapperId('Unsuccessfull Lead Insert','Failure');
                return objWapper;
            }
        }
        else
        {
           objWapper = new WapperId('Your Credentials are incorrect.','Failure');
           return objWapper;
        }
        return objWapper;  
    }
    
    @HttpGet
    global static void doGet()
    {
        String leadSource='Web';
        String Category='Distance Learning / Correspondence';
        string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
        RestRequest req = RestContext.request;
        String ipAddress = req.remoteAddress;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        system.debug(req);
        system.debug(req.params);
        // system.debug( System.JSON.deserializeUntyped(req));
        
        String EmailID = RestContext.request.params.get('Email');
        String Name = RestContext.request.params.get('Name');
        String ContactNo = RestContext.request.params.get('ContactNo');
        String CourseIntrestedIn = RestContext.request.params.get('CourseIntrestedIn');
        decimal AdmissionYear = 2014;
        String CurrentLocation = RestContext.request.params.get('CurrentLocation');
        String HighestQualification = RestContext.request.params.get('HighestQualification');
        
        Lead objLead = new Lead(LastName=Name,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CurrentLocation,Highest_Qualification__c=HighestQualification,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress);
        try
        {
            insert objLead;
           PageReference page= RedirectToCampaign(); 
           system.debug('page'+page);
           
       
        }
        catch(Exception e)
        {
             RedirectToCampaign(); 
        }
       
    } 
    
    public static PageReference RedirectToCampaign()
    {
       system.debug('Enter in Method');
        PageReference pg = new PageReference('http://distance.nmims.edu/');
        pg.setRedirect(true);
        system.debug('pg'+pg);
        return pg;
       
    } 
}