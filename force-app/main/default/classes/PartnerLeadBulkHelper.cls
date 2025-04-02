public without sharing class PartnerLeadBulkHelper {

    public PartnerLeadBulkWrapper getWrapper = new PartnerLeadBulkWrapper();
    
    public PartnerLeadBulkHelper(){
        getWrapper = getWrappervalue();

    }

    public  PartnerLeadBulkWrapper getWrappervalue(){
        
        PartnerLeadBulkWrapper wrapper = new PartnerLeadBulkWrapper();
                Map<String,String> headerMap = new Map<String,String>();
                 
                headerMap.put('First Name', 'First_Name__c');
                headerMap.put('Last Name', 'Last_Name__c');
                headerMap.put('Agency', 'Agency__c');
                headerMap.put('Email', 'Email__c');
                //headerMap.put('Information Center', 'Information_Center__c');//                
                //headerMap.put('Lead Source', 'Lead_Source__c');// default=Partner
                headerMap.put('MOBILEPHONE', 'MOBILEPHONE__c');
                headerMap.put('Choose a Program', 'nm_ChooseaProgram__c');
                
                wrapper.getheaderMap = headerMap;
                
                
            return wrapper;
    }
    
    public class PartnerLeadBulkWrapper{
        public Map<String,String> getheaderMap {get;set;}
       
        PartnerLeadBulkWrapper(){
            getheaderMap = new Map<String,String>();  
        }
    }

}