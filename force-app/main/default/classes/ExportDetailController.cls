public class ExportDetailController {
public string startDate{get;set;}
public string endDate{get;set;}
public string startDT{get;set;}
public List<Lead> lstLead{get;set;}
public string enddt {get;set;}
public integer Total{get;set;}
    public ExportDetailController()
    {
        startDate='';
        endDate='';
        startDT='';
        enddt='';
        Total=0;
        lstLead =new List<Lead>();
    }
    
    public void view()
    {
        System.debug('startdate ----->'+startDT);
        lstLead=[Select id,FirstName,LastName, LeadSource, Agency__c , nm_OtherLeadSources__c,nm_Keyword__c,nm_InformationCenter__c,Status,    nm_InitialLeadSatus__c,Number_of_days_to_get_convert__c,Created_Month__c,
                  CreatedDate,nm_CreatedDatetime__c,Owner.name,nm_Timetakentocontact__c,Description, LC_name__c FROM Lead WHERE LeadSource = 'Web' and Lead_created_date__c>=:Date.valueOf(startDT) and Lead_created_date__c<=:Date.valueOf(enddt) and Agency__c ='DGM'];
        Total=lstLead.size();          
    }
    
    
}