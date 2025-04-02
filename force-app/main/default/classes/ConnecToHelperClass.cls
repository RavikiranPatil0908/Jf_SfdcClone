/**
 * @File Name          : ConnecToHelperClass.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 12/30/2019, 1:05:42 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/9/2019   @BK     Initial Version
**/
public class ConnecToHelperClass
{ 
        String mobileNumber ;
        String mobileNo ;
        public boolean CheckExistingLeadBasedOnMobileNum(String mobileLead)
        {
                mobileNumber =mobileLead.replace('(','');
                mobileNo =mobileNumber.replace(')','');
               list<lead> objLead = [select id from Lead where MobilePhone=:mobileNo   AND IsDeleted = false
                                      And IsConverted=false 
                                     And Status!='Qualified'
                                     limit 1];
               System.debug('<--------objLead------->'+objLead);
               if(objLead.isEmpty())
               {
                   return true;
               
               } 
               else
               {
                   return false;
               }
        }
        
        public boolean CheckExistingAccountBasedOnMobileNum(String mobileLead)
        {
                mobileNumber =mobileLead.replace('(','');
                mobileNo =mobileNumber.replace(')','');
               list<Account> objAccount = [SELECT id FROM Account WHERE (PersonMobilePhone!=null AND PersonMobilePhone!='')  and PersonMobilePhone=:mobileNo LIMIT 1];
               System.debug('<--------objAccount------->'+objAccount);
               if(objAccount.size() >0){
                   return true;
               }else{
                   return false;
               }
        }
        
     /*   public boolean CheckExistingLeadEmail(String emailId)
        {
        
                list<lead> objLead = [Select id,Connecto__c,Email from Lead where Email=:emailId  
                                      AND IsDeleted = false
                                      And IsConverted=false 
                                      And Status!='Qualified'
                                      And nm_Check_for_Duplicacy_Email__c!=null ];
                System.debug('<----------objLead----->'+objLead);
                if(objLead.isEmpty())
                {
                    return true;
                }
                else
                {
                    return false;
                }
         }
         */
         public boolean CheckExistingLeadEmail(String emailId)
         {
                       set<String> setOfEmails = new set<String>();
                       String emailTemp ='';
               list<lead> objLead = [Select id,Connecto__c,Email from Lead where
                                      IsDeleted = false
                                     And IsConverted=false 
                                     And Status!='Qualified'
                                      And Status ='Registartion form Filled'
                                     And nm_Check_for_Duplicacy_Email__c!=null limit 1];
                                     
            list<Lead> blankList = new list<Lead>();                                                                          
                    for(lead obj :objlead)
                        {
                        setOfEmails.add(obj.Email);
                        }
                        System.debug('Set of Email Ids of lead--->'+setOfEmails);
                  
                        if(!setOfEmails.contains(emailId))
                        {
                          return true;
                        }
                        else
                        {
                            return false;
                        }
    
         }
          
         public boolean CheckExistingAccountEmail(String emailId)
         {
                if(String.isNotBlank(emailId)){
                    list<Account> objAccount = [Select id,Connecto__c,PersonEmail from Account where PersonEmail=:emailId limit 1];
                    System.debug('<----------objAccount----->'+objAccount);
                    if(objAccount.size() > 0){
                        return true;
                    }
                }
                return false;
          }
          public boolean CheckConnectToRecordForDuplicateMobile(String mobileNum)
          {
                 mobileNumber =mobileNum.replace('(','');
                 mobileNo =mobileNumber.replace(')','');
                 list<Connecto__c> connecToRecords = [select id,Mobile_Number__c from Connecto__c where Mobile_Number__c=:mobileNo limit 1];
                 if(connecToRecords.isEmpty())
                 {
                     return true;
                 }
                 else
                 {
                     return false;
                 }
          }
          public boolean CheckIfCenterIsActive(String centerId)
          {
              list<nm_Centers__c> centerList = [select Nm_Active__c,nm_LearningCenter__c from nm_Centers__c where id=:centerId and recordtype.Name =: 'Information Center'];
              boolean activeValue;
              if(centerList!=null && centerList.size()>0 )
              {
                  activeValue = centerList[0].Nm_Active__c;
              
              }
              else{
               activeValue =true;
              }
              
              return activeValue;    
          
          }
          
           public void updateExistingLeadTORebornFromMobileNo(String mobileLead) {
                mobileNumber =mobileLead.replace('(','');
                mobileNo =mobileNumber.replace(')','');
               list<lead> objLead = [select id from Lead where MobilePhone=:mobileNo limit 1];
                Lead updateLead = new Lead();
                updateLead.Id = objLead[0].Id;
                updateLead.Status = 'Reborn';
                if(!Test.isRunningTest()) {
                    update updateLead;

                }
          }

          public void updateExistingLeadTORebornFromEmail(String email) {
               list<lead> objLead = [select id from Lead where Email=:email limit 1];
                Lead updateLead = new Lead();
                updateLead.Id = objLead[0].Id;
                updateLead.Status = 'Reborn';
                update updateLead;
          }
        
        
    


}