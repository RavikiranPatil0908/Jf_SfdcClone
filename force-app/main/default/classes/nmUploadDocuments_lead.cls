/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-10-2024
 * @last modified by  : @BK
**/
public class nmUploadDocuments_lead 
{
    public string leadId{get;set;}
    public string LeadUId{get;set;}
    public string leadName{get;set;}
    public boolean allowed {get;set;}
    public String mode {get;set;}
    public nmUploadDocuments_lead()
    {
        allowed =false;
        leadId = ApexPages.currentPage().getParameters().get('id');
        mode = ApexPages.currentPage().getParameters().get('mode');
        if(String.isBlank(mode)) {
            mode = '';
        } else {
            mode = '&mode=' + EncodingUtil.urlEncode(mode, 'UTF-8');
        }
        if(leadId!= null)
        {
            List<lead> lstlead = [select id, Name,nm_LeadId__c,AllowedToUploadDocument__c from Lead where id =:leadId];
            if(lstlead != null && lstlead.Size() > 0)
            {
                leadName = lstlead[0].Name;
                LeadUId=lstlead[0].nm_LeadId__c;
                if(lstlead[0].AllowedToUploadDocument__c)
                {
                    allowed =true;
                }
            }
        }
    }
}