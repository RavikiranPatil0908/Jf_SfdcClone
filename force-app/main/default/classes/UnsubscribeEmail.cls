// This Class is used as a controller for UnsubscribeEmail page
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        26-Sep-2016      Phalguni          Initial Version
// ---------------------------------------------------------------------------------------------
public class UnsubscribeEmail
{
    //Method to mark email as verified
    public void  UnsubscribeEmailAddress()
    {
        string strLeadId = apexpages.currentpage().getparameters().get('l');
        string strEmail = apexpages.currentpage().getparameters().get('e');
        
        string contactid= apexpages.currentpage().getparameters().get('cid');
        string straEmail = apexpages.currentpage().getparameters().get('ei');
        
        if(strLeadId != null && strLeadId != '' && strEmail != null && strEmail != '')
        {
            List<Lead> lstLead = [select id, nm_IsEmailVerified__c,HasOptedOutOfEmail from lead where id =:strLeadId and email =: strEmail and isConverted = false];
            if(lstLead != null && lstLead.size() > 0)
            {
                lstLead[0].HasOptedOutOfEmail = true;
                update lstLead;
            }
        }
        if(contactid!= null && contactid!= '' && straEmail != null && straEmail != '')
        {
            List<Contact> lstContact = [select id,  HasOptedOutOfEmail from Contact where id =:contactid and Email =:straEmail ];
            if(lstContact!= null && lstContact.size() > 0)
            {
                lstContact[0].HasOptedOutOfEmail = true;
                update lstContact;
            }
        }
    }
     public void  ShownInterest2()
    {
        string strLeadId = apexpages.currentpage().getparameters().get('l');
        string strEmail = apexpages.currentpage().getparameters().get('e');
        
      /*  string contactid= apexpages.currentpage().getparameters().get('cid');
        string straEmail = apexpages.currentpage().getparameters().get('ei');
        */
        if(strLeadId != null && strLeadId != '' && strEmail != null && strEmail != '')
        {
            List<Lead> lstLead = [select id, Status from lead where id =:strLeadId and email =: strEmail and isConverted = false];
            if(lstLead != null && lstLead.size() > 0)
            {
                lstLead[0].Status = 'Reborn';
                update lstLead;
            }
        }
        /*if(contactid!= null && contactid!= '' && straEmail != null && straEmail != '')
        {
            List<Contact> lstContact = [select id,  Shown_Interest__c from Contact where id =:contactid and Email =:straEmail ];
            if(lstContact!= null && lstContact.size() > 0)
            {
                lstContact[0].Shown_Interest__c = true;
                update lstContact;
            }
        }*/
    }
}