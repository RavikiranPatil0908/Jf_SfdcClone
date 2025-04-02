@RestResource(urlMapping='/callrouterestservice/*')
global without sharing class CallRouteRestService
{
        @HttpGet
        global static String doGet()
        {

            string mobileNumber = RestContext.request.params.get('callerNumber');
            list<Lead> lstLead =[select id,name,MobilePhone,LC_name__c from Lead Where Mobile_No__c =:mobileNumber];
            list<Account> lstAccount =[select id,name,PersonMobilePhone,LC_Name__c from account Where PersonMobilePhone = :mobileNumber];
            if(lstAccount.size()>0)
            {
                String centerId =lstAccount[0].LC_Name__c +':'+' '+ lstAccount[0].name+ ':'+' '+'Y';
                return centerId;
            }
            else if(lstLead.size()>0)
            {
                String centername =lstLead[0].LC_name__c +':'+' '+ lstLead[0].name+':'+' '+ 'N';
                return centername;
            }
            else
            {
                String Error ='Mumbai'+':'+'Unknown';
                return Error;
            }
       
        }
    
}