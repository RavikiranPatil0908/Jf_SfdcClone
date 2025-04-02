public class ContactUserRoleChangeHandler {
    public static boolean IsAfterUpdateRunOnce = false;
    public void AfterUserRoleChange(List<Contact> triggerNew, map<id, Contact> mapContactOldMap)
    {   
        if(IsAfterUpdateRunOnce ){
            return;
        }
        
        IsAfterUpdateRunOnce = true;
        Set<String>  conList = new Set<String>();
        Set<String> MobileNo=new set<String>();
        List<User> updateUser=new List<User>();
        List<User> updateUserMobile=new List<User>();
        List<Counsellor_Profile__c> updateCP=new List<Counsellor_Profile__c>();
        Set<String>ConId= new Set<String>();
        Id CurrentUserId = userinfo.getuserid();
                User objuser = [select Id,ContactId ,UserRole.Name from user where id=:userinfo.getuserid()];
        for (Contact objcon: triggerNew) {
            ConId.add(objcon.Id);
            MobileNo.add(objcon.MobilePhone);
           // system.debug('mapContactOldMap.get(objcon.Id).User_Role__c==>'+mapContactOldMap.get(objcon.Id).User_Role__c);
            //system.debug('objcon.User_Role__c==>'+objcon.User_Role__c);
            
            if( objcon.User_Role__c != mapContactOldMap.get(objcon.Id).User_Role__c){
                //Id CurrentUserId = userinfo.getuserid();
               // User objuser = [select Id,ContactId ,UserRole.Name from user where id=:userinfo.getuserid()];
                System.debug('You can update');
                conList.add(objcon.Id) ;
                
                    If(!Test.isRunningTest())
                    {
                        if(objuser.ContactId!=null )
                        {
                           // Contact objcontact=[Select id,User_Role__c,Counselor_Profile__c from Contact where Id=:objuser.ContactId];
                          //  system.debug('objuser.ContactId==>'+objuser.ContactId);
                            
                            if(!objuser.UserRole.Name.contains('Executive')){
                                // if(mapContactOldMap.get(objcon.Id).User_Role__c!='Executive'){
                                objcon.addError('Only Contacts with Executive Role Can Change UserRole');
                            }
                          
                        }
                        if(objcon.Id == objuser.ContactId ){                                        
                                            
                          objcon.addError('Contact Can not Change its Own UserRole');
                          
                        }                       
                       
                    }
                
            }
            
            
           
        }
        system.debug('conList==>'+conList);
         if(System.IsBatch() == false && System.isFuture() == false){ 
        updateUseRole(conList);
             Contact objcont=[select id,MobilePhone,Counselor_Profile__c from Contact where Id in:ConId];
             system.debug('objcon==>'+objcont);
             String firstNo = new List<String> (MobileNo).get(0);
             system.debug('firstNo==>'+firstNo);
             system.debug('mapContactOldMap.get(objcont.Id).MobilePhone'+mapContactOldMap.get(objcont.Id).MobilePhone);
             if( firstNo!= mapContactOldMap.get(objcont.Id).MobilePhone){
                 system.debug('objcon.MobilePhone==>'+objcont.MobilePhone);
                if(objcont.Counselor_Profile__c!=null)
                {
                Counsellor_Profile__c cp=[select id,MobilePhone__c from Counsellor_Profile__c where id=:objcont.Counselor_Profile__c];
                 cp.MobilePhone__c=firstNo;
                 updateCP.add(cp);
                }
                 User conUser = [select Id,ContactId,MobilePhone from user where ContactId=:objcont.Id];
                 conUser.MobilePhone=firstNo;
                 updateUserMobile.add(conUser);
             }
             if(updateCP.size()>0)
             update updateCP;
              if(updateUserMobile.size()>0)
             update updateUserMobile;
         }
    }
   
     @future (callout=true)
    public static void updateUseRole(Set<String> contactIds){
        List<Contact>  conName = [Select id,Name,AccountID__c,User_Role__c,Account.Name from Contact where Id in :contactIds];
        Map<String,String> mapOfContactcvsRole = new Map<String,String>();
        for(Contact cont:conName){
            String rolename = '';
            if(cont.User_Role__c=='Executive'){
                rolename = cont.Account.Name + ' Partner Executive';
                system.debug('rolename==>'+rolename);
            }else if(cont.User_Role__c=='Manager'){
                rolename = cont.Account.Name + ' Partner Manager';
                system.debug('rolename==>'+rolename);
            }else if(cont.User_Role__c=='User'){
                rolename = cont.Account.Name + ' Partner User';
                system.debug('rolename==>'+rolename);
            }
            if(String.isNotBlank(rolename)){
                mapOfContactcvsRole.put(cont.Id,rolename);
            }
        }
        System.debug('mapOfContactcvsRole '+mapOfContactcvsRole);
        Map<String, String> rolemap = new Map<String, String>();
        system.debug('mapOfContactcvsRole.values()==>'+mapOfContactcvsRole.values());
        List<UserRole> usrList=[SELECT Id,DeveloperName,Name from UserRole where Name IN:mapOfContactcvsRole.values()];
        system.debug('usrList==>'+usrList);
        for(UserRole u:usrList)
        {
            rolemap.put(u.Name,u.Id);
        }
        system.debug('rolemap==>'+rolemap);        
        //Map<Name, UserRole> rolemap = new Map<Name, UserRole>([SELECT Id,DeveloperName,Name from UserRole where Name IN:mapOfContactcvsRole.values()]);
        List<User> UserList = [select  Id,Name,UserRoleId,UserRole.Name,UserRole.Id,ContactId from User where ContactId IN:mapOfContactcvsRole.keySet()];
        List<User> updateuserlst = new List<User>();
        for(User user:UserList){
            if(mapOfContactcvsRole.containsKey(user.ContactId)){
                if(rolemap.containsKey(mapOfContactcvsRole.get(user.ContactId))){
                    user.UserRoleId = rolemap.get(mapOfContactcvsRole.get(user.ContactId));
                    updateuserlst.add(user);
                }
            }
        }
        if(updateuserlst.size()>0){
            try {
                update updateuserlst;
            } catch (DMLException e) {
                System.debug('Error '+e.getMessage());
            }
        }
    }
    

}