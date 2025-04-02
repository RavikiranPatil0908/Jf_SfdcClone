/**
 * @File Name          : nmEmailVerification.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-02-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/8/2019, 12:34:03 PM   @BK     Initial Version
**/
// This Class is used as a controller for nmEmailVerification page
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        11-Mar-2014      Neeraj Chauhan           Initial Version
// ---------------------------------------------------------------------------------------------
public class nmEmailVerification 
{
    public String recordId {get;set;}// store Lead or Account Id
    public String typeOfRecord {get;set;} //store type Of Record Lead or Account
    public String typeOfVerification {get;set;} // store type of Verification done Email or Mobile 
    public List<Lead> lstLeadToMarkVerified {get;set;}
    public List<Account> lstAccountToMarkVerified {get;set;}
    public String displayMessage {get;set;}
    public String token {get;set;}
    public nmEmailVerification()
    {
        token = '';
       // recordId id|A|M
        String record = Apexpages.Currentpage().getParameters().get('id');
        if(record.contains('-'))
        {
            recordId = record.split('-')[0];
            typeOfRecord = record.split('-')[1];
            typeOfVerification = record.split('-')[2];
            if(record.split('-').size() > 3) {
                token = record.split('-')[3];
            }

        }else
        {
            recordId = record;
            typeOfRecord = Apexpages.Currentpage().getParameters().get('type');
            typeOfVerification = Apexpages.Currentpage().getParameters().get('verify');
        }    
        lstAccountToMarkVerified = new List<Account>();
        lstLeadToMarkVerified = new List<Lead>();
        displayMessage = '';
         
        System.debug('url--->'+typeOfRecord);
    }
    
    //Method to mark email or Mobile as verified
    public void VerifyEmailOrMobileNumber()
    {
        if(recordId !=null && recordId !='' && typeOfRecord !=null && typeOfRecord =='Lead')
        {
            List<Lead> lstLead = [select id, nm_IsEmailVerified__c,Is_Mobile_Verified__c,Mobile_Verification_Token__c,Email_Verification_Token__c from lead where id =:recordId and isConverted = false];
            System.debug('List size of email'+lstLead.size());
            if(typeOfVerification !=null && ( typeOfVerification =='E' || typeOfVerification =='Email')) // verify Email Address
            {
                if(lstLead != null && lstLead.size() > 0)
                {
                    for(Lead objLead : lstLead)
                    {
                        if(!objLead.nm_IsEmailVerified__c)
                        {
                            if(verifyToken(token,objLead.Email_Verification_Token__c)) {
                                objLead.nm_IsEmailVerified__c = true;
                                displayMessage = 'Thank you, your email address is verified.';
                                lstLeadToMarkVerified.add(objLead);
                            } else{
                                displayMessage = 'Your Email Verification link has been expired, Kindly contact your AEP.';
                            }
                        }else
                        {
                            displayMessage = 'Thank you, your email address is already verified.';
                        }
                    }
                }
            }else if(typeOfVerification =='M' || typeOfVerification =='Mobile') // verify Mobile Number
            {
                if(lstLead != null && lstLead.size() > 0)
                {
                    for(Lead objLead : lstLead)
                    {
                        if(!objLead.Is_Mobile_Verified__c)
                        {
                            if(verifyToken(token,objLead.Mobile_Verification_Token__c)) {
                                objLead.Is_Mobile_Verified__c = true;
                                lstLeadToMarkVerified.add(objLead);
                                displayMessage = 'Thank you, your Mobile Number is verified.';
                            }else{
                                displayMessage = 'Your Mobile Verification link has been expired, Kindly contact your AEP.';
                            }
                        }else
                        {
                            displayMessage = 'Thank you, your Mobile Number is already verified.';
                        }
                    }
                }
            }
        }else if(recordId !=null && recordId !='' && typeOfRecord !=null && typeOfRecord =='Account')
        {
            List<Account> lstAccount = [select id, nm_IsEmailVerified__c,Is_Mobile_Verified__c,Mobile_Verification_Token__c,Email_Verification_Token__c from Account where id =:recordId ];
            if(typeOfVerification !=null && ( typeOfVerification =='E' || typeOfVerification =='Email'))
            {
                if(lstAccount!= null && lstAccount.size() > 0)
                {
                    for(Account objAccount : lstAccount)
                    {
                        if(!objAccount.nm_IsEmailVerified__c)
                        {
                            if(verifyToken(token,objAccount.Email_Verification_Token__c)) {
                                objAccount.nm_IsEmailVerified__c = true;
                                displayMessage = 'Thank you, your email address is verified.';
                                lstAccountToMarkVerified.add(objAccount);
                            }else{
                                displayMessage = 'Your Email Verification link has been expired, Kindly contact your AEP.';
                            }
                        }else
                        {
                            displayMessage = 'Thank you, your email address is already verified.';
                        }
                    }
                }
            }else if(typeOfVerification =='M' || typeOfVerification =='Mobile')
            {
                if(lstAccount!= null && lstAccount.size() > 0)
                {
                    for(Account objAccount : lstAccount)
                    {
                        if(!objAccount.Is_Mobile_Verified__c)
                        {
                            if(verifyToken(token,objAccount.Mobile_Verification_Token__c)) {
                                objAccount.Is_Mobile_Verified__c = true;
                                displayMessage = 'Thank you, your Mobile Number is verified.';
                                lstAccountToMarkVerified.add(objAccount);
                            }else{
                                displayMessage = 'Your Email Verification link has been expired, Kindly contact your AEP.';
                            }

                        }else
                        {
                            displayMessage = 'Thank you, your Mobile Number is already verified.';
                        }
                    }
                }
            }
        }
        
        if(lstLeadToMarkVerified.size()>0)
        {
            update lstLeadToMarkVerified;
        }
        
        if(lstAccountToMarkVerified.size()>0)
        {
            update lstAccountToMarkVerified;
        }
    }

    public Boolean verifyToken(String tokenString,String verificationToken) {
        if(String.isBlank(tokenString)) {
            return true;
        } else{
            if(tokenString == verificationToken) {
                return true;
            } else{
                return false;
            }
        }
        return true;
    }
}