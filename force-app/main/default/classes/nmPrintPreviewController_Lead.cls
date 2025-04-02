public without sharing class nmPrintPreviewController_Lead{
    public string Leadid{get;set;}
    public string AccountId{get;set;}
    public string objdate{get;set;}
    public string city{get;set;}
    public Lead objLead{get;set;}
    public Account objAccount{get;set;}
    public string BatchName{get;set;}
// public list<nm_StudentProgram__c> lststuprogram{get;set;}
    public list<nm_WorkExperience__c> lstworkexpr{get;set;}
    public list<nm_WorkExperience__c> lstworkexprence{get;set;}
    public nmPrintPreviewController_Lead(){
        BatchName='';
        Leadid=apexpages.currentpage().getparameters().get('id');
        objdate=apexpages.currentpage().getparameters().get('date');
        city=apexpages.currentpage().getparameters().get('city');
        lstworkexpr=new  list<nm_WorkExperience__c>();
        try{
            LoadData();
        }
        catch(Exception ex){
            system.debug('NRAC::::'+ex.getMessage());
        }
    }
    public string getQueryAllFieldSql(string SObjectAPIName,string conditionString,string relatedFields){
        Map<string,schema.SObjectType> scemapMap=schema.getGlobalDescribe();
        Map<string,schema.SObjectField> fieldMap=scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<string> fieldNames=new  List<string>(fieldMap.keySet());
        if(relatedFields!=null&&relatedFields!='')fieldNames.add(relatedFields);
        string query='Select '+string.join(fieldNames,',')+' from '+SObjectAPIName+' where '+conditionString;
        return query;
    }
    public void LoadData(){
        System.debug('LeadId--->'+Leadid);
        if(Leadid!=null&&Accountid==null){
            string leadQueryString=getQueryAllFieldSql('Lead',' id=:Leadid','nm_Program__r.Name,nm_EligiblityCriteria__r.Name');
            List<Lead> lstLead=DataBase.query(leadQueryString);
            if(lstLead.size()>0){
                Lead objLeadLocal=lstLead[0];
                objLead=objLeadLocal.clone();
                string leadWrkQueryString=getQueryAllFieldSql('nm_WorkExperience__c','nm_Lead__c=:Leadid',null);
                lstworkexpr=DataBase.query(leadWrkQueryString);
            }
        }
    }
}