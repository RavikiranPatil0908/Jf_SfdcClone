public class nmPrintRegistration {
    public Lead objLead {get;set;}
    public Boolean showpage { get; set; }
    public Boolean showAltPage {get;set;}
    public String PDFPlace { get; set; }
    public String PDFDate { get; set; }
    public String icValue  {get;set;}
    public string LeadId { get; set; }
    public String BatchName { get; set; }
    public String ICname { get; set; }
    
    public List<String> lstCities {get;set;}
    
    public nmPrintRegistration()
    {
        objLead = new Lead();
        lstCities = new List<String>();
        showpage = false;
        PDFPlace = '';
        PDFDate = '';
        ICname ='';
        LeadId = Null;
        BatchName = '';
        icValue = ApexPages.currentPage().getParameters().get('IC');
        if(icValue =='' || icValue ==null){
            icValue ='false';
        }
        if(ApexPages.currentPage().getParameters().get('id') != Null && ApexPages.currentPage().getParameters().get('id') != '')
        {
            LeadId = ApexPages.currentPage().getParameters().get('id');
            List<Lead> lstLead = [Select Id, nm_StudentStatus__c, nmm_BatchName__c,IC_Name__c from Lead where id =: LeadId];
            if(lstLead!=null && lstLead.size()>0)
             {
             BatchName = lstLead[0].nmm_BatchName__c;
             ICname  = lstLead[0].IC_Name__c;
             }
          
            
            List<nm_Centers__c> lstCenters = [select Id, nm_City__c from nm_Centers__c where Nm_Active__c = true];
            
            if(lstCenters != Null && lstCenters.size() > 0)
            {
                Set<String> setCities = new Set<String>();
                
                for(nm_Centers__c obj : lstCenters)
                {
                    setCities.add(obj.nm_City__c);    
                }
                
                if(setCities.size() > 0)
                {
                    for(String objstr : setCities)
                    {    
                        lstCities.add(objstr);
                    }
                    lstCities.sort();
                }
            }
        }
    }
   
    
    public void PrintForm()
    {
         
       showPage = true;
    }
    public pageReference MakePayment()
    {
        System.debug('Enter in make payment--->');
        if( LeadId != null && LeadId != '')
        {
            Lead objTempLead = [select Id, Status from Lead where Id =: LeadId];
             if(objTempLead.Status == 'Invalid Lead' || objTempLead.Status == 'Dead')
            {
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sorry ! You are already registered with us for the selected program. Please contact the Information Center.'));
                return Null;
            }
            else
            {
                 PageReference pgURL = new PageReference(System.Label.GoToAdmissionPayment_Url+'id='+ LeadId+'&IC='+icValue );
                pgURL.setRedirect(true);
                return pgURL;
            }
        }
        return null;
    }
   
       
}