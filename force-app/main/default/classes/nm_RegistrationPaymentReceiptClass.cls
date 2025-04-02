// This controller class made for component nmRegistrationPaymentReceipt
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        09-April-2014     Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------
public with sharing class nm_RegistrationPaymentReceiptClass 
{
        //defined to get payment id
        public string strLeadRequestId {get; set;}
        //defined to use this object to get data in E-mail templete
        public Lead objLeadVar{get;set;}
        public List<Lead> listLead;
        //defined to use as variable name in attachment in E-mail templete 
        public string strVariable {get; set;}
        
        public nm_RegistrationPaymentReceiptClass ()
        {
            strLeadRequestId = ApexPages.currentPage().getParameters().get('id');
        } 
        //Object of Payment with details
        public lead getobjLead()
        {
            listLead = new List<Lead>();   
            Lead objLead1;
            listLead  = [select id,nm_RegistrationNo__c , name,nm_Session__c,nm_Year__c,nm_Program__r.name, nm_InformationCenter__r.name from Lead where id =: strLeadRequestId limit 1];
                                            
            If(listLead !=null && listLead.size()>0)
            {
                objLead1 =listLead[0];
            }                             
           return objLead1;
        }     
}