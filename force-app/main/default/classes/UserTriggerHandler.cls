public  class UserTriggerHandler {
    List<String> ConId=new List<String>();
    Set<String> MobileNo=new set<String>();
   
    Boolean Mobilecheck=false;
   public void AfterInsert(List<User> triggerNew, map<id, User> mapUserNewMap)
    {
        updateIsPartnerOnContact(triggerNew,'insert',null);

    }
    public void AfterUpdate(List<User> triggerNew, map<id, User> mapUserOldMap)
    {
      updateIsPartnerOnContact(triggerNew,'update',mapUserOldMap);
        //updateMobile(triggerNew,mapUserOldMap);
    } 
   public void updateIsPartnerOnContact(List<User> lstUser,String event,map<id, User> mapUserOldMap) {
        Set<Id> setOfContactIdToUpdateTrue = new Set<Id>();
        Set<Id> setOfContactIdToUpdateFalse = new Set<Id>();
        system.debug('event1==>'+event);
        if(lstUser.size() > 0) {
            system.debug('lstUser.size()==>'+lstUser.size());
            for(User objUser : lstUser) {
                system.debug('objUser.MobilePhone==>'+objUser.MobilePhone);
                 //system.debug('mapUserOldMap.get(objUser.Id).MobilePhone==>'+mapUserOldMap.get(objUser.Id).MobilePhone);
                 if(objUser.MobilePhone!= null)
                 {
                    // If(!Test.isRunningTest())
                    // If(objUser.MobilePhone!= mapUserOldMap.get(objUser.Id).MobilePhone)
                    // {
                    //     System.debug('Mobile Check');
                    //     If(objUser.ContactId!=null)
                    //     {
                    //     ConId.add(objUser.ContactId);
                    //     MobileNo.add(objUser.MobilePhone);
                    //     Mobilecheck=True;
                    //     } 
                    // }
                 }
               if(event=='insert' || (event=='update' && objUser.IsActive != mapUserOldMap.get(objUser.Id).IsActive))
                  {
                   system.debug('event2==>'+event);
                if(String.isNotBlank(objUser.ContactId) ) {
                   
                    if(objUser.IsActive) {
                        setOfContactIdToUpdateTrue.add(objUser.ContactId);
                    } else {
                        setOfContactIdToUpdateFalse.add(objUser.ContactId);
                    }
                  }
                }
            }
        }
  If(Mobilecheck == True)
  {
   updateCon(ConId[0],MobileNo);
  }
        if(setOfContactIdToUpdateTrue.size() > 0) {
           
            updateToIsPartnerUserTrue(setOfContactIdToUpdateTrue);

        }
        if(setOfContactIdToUpdateFalse.size() > 0) {
            updateToIsPartnerUserFalse(setOfContactIdToUpdateFalse);
        }
    }
   @future 
   public static void updateCon(Id conId,Set<String> MobileNo)
    {
        List<Contact> updateConList=new List<Contact>();
        List<Counsellor_Profile__c> updateCpList=new List<Counsellor_Profile__c>();
        system.debug('updateCon called');
      Contact objcontact=[Select id,User_Role__c,Counselor_Profile__c from Contact where Id=:conId];
          system.debug('objcontact==>'+objcontact);  
        String firstNo = new List<String> (MobileNo).get(0);
        objcontact.MobilePhone=firstNo;
        updateConList.add(objcontact);
        system.debug('objcontact.Counselor_Profile__c==>'+objcontact.Counselor_Profile__c);
        If(objcontact.Counselor_Profile__c!=null)
        {
           Counsellor_Profile__c objCp=[select id,MobilePhone__c from Counsellor_Profile__c where id=:objcontact.Counselor_Profile__c] ;
            objCp.MobilePhone__c=firstNo;
            updateCpList.add(objCp);
        }
        
        if(updateConList.size()>0)
        {
            update updateConList;
        }
        
        if(updateCpList.size()>0)
        {
            update updateCpList;
        }
    }
    

    @future
    public static void updateToIsPartnerUserTrue(Set<Id> setOfContact) {
        List<Contact> lstContactToUpdate = new List<Contact>();
        for(Id idOfContactToTrue : setOfContact) {
                Contact objContact = new Contact();
                objContact.Id = idOfContactToTrue;
                objContact.Is_Partner_User__c = true;
                lstContactToUpdate.add(objContact);
            }
            if(lstContactToUpdate.size() > 0) {
                update lstContactToUpdate;
            }
    }
    @future
    public static void updateToIsPartnerUserFalse(Set<Id> setOfContact) {
        List<Contact> lstContactToUpdate = new List<Contact>();
        for(Id idOfContactToTrue : setOfContact) {
                Contact objContact = new Contact();
                objContact.Id = idOfContactToTrue;
                objContact.Is_Partner_User__c = false;
                lstContactToUpdate.add(objContact);
            }
        if(lstContactToUpdate.size() > 0) {
            update lstContactToUpdate;
        }
    }
}