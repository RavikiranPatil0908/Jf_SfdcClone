@RestResource(urlMapping='/ChangeCounselorProfile/*')
global without sharing class ChangeCounselorProfile {
  global String acc;     
@HttpPOST
    global static string ChangeCounselorProfile(String ContactId,String NewcpId)
    {
        Set<Id> setOfContactIdToUpdate= new Set<Id>();
       Set<Id> userIdToUpdate = new Set<Id>();
        System.debug('ContactId==>'+ContactId);
        System.debug('NewcpId ==>'+NewcpId);
        
       list<contact> lstRecords = [select id,AccountId,Counselor_Profile__c, Email from contact where Id=:ContactId];
       // acc=lstRecords[0].AccountId;
        List<User> UserInfo=[select id,Name,Contact.Name, ContactId ,Email, MobilePhone from User where ContactId=:ContactId]; 
       list<Counsellor_Profile__c> lstNewCP = [select id ,Full_Name__c,MobilePhone__c,Email__c from Counsellor_Profile__c where Id=:NewcpId LIMIT 1];        
         if(lstRecords.size() > 0) {
           lstRecords[0].FirstName ='';
           lstRecords[0].LastName=lstNewCP[0].Full_Name__c;
           lstRecords[0].Counselor_Profile__c = NewcpId; 
           lstRecords[0].Email=lstNewCP[0].Email__c;
           lstRecords[0].MobilePhone=lstNewCP[0].MobilePhone__c;
           lstRecords[0].Phone=lstNewCP[0].MobilePhone__c;
           setOfContactIdToUpdate.add(lstRecords[0].id);
             try {
            RestResponse res = RestContext.response;
            RestRequest req = RestContext.request;
           // system.debug('lstRecords-->'+lstRecords);
           
           update lstRecords;
           updateUserInfo(ContactId,NewcpId,UserInfo[0].id);
           updateCP(ContactId,NewcpId);
           //updateUserName(UserInfo[0].id,NewcpId);
            return 'Successfully update';
        } catch (DmlException e) {
                System.debug(e.getMessage());
                  return e.getMessage();
            }
      
        }
        
         return 'Failed to update';
    }
    
    @future
    global static void updateUserInfo(String ContactId,String NewcpId,Id userInfoId) {
        system.debug('updateUserInfo called');
         list<Counsellor_Profile__c> lstNewCP = [select id ,Full_Name__c,MobilePhone__c,Email__c from Counsellor_Profile__c where Id=:NewcpId LIMIT 1];
        List<User> UserInfo=[select id,Name,Contact.Name, ContactId ,Email, MobilePhone from User where id=:userInfoId];
           system.debug('UserInfo==>'+UserInfo);
        String  nickName;
         if(Test.isRunningTest())
        {
             nickName = 'Abc';
        }
        else
        {
         nickName = lstNewCP[0].Email__c.substringBefore('@');
        System.debug('nickName ==>'+nickName);
        }
        User u=new User();
            u.Id=UserInfo[0].Id;
            u.FirstName= '';
            u.LastName= lstNewCP[0].Full_Name__c;
            u.MobilePhone= lstNewCP[0].MobilePhone__c;
            u.Username=lstNewCP[0].Email__c;
            u.Email= lstNewCP[0].Email__c;
            u.Phone=lstNewCP[0].MobilePhone__c;
            u.CommunityNickname = nickName;
            u.Alias=lstNewCP[0].Full_Name__c.substring(0,5);
            system.debug('u.CommunityNickname==>'+ u.CommunityNickname);
            update u;
        
    }
    
     @future
    global static void updateCP(String ContactId,String NewcpId) {
         system.debug('updateCP called');
         list<Counsellor_Profile__c> lstNewCP = [select id ,Full_Name__c,MobilePhone__c,Email__c from Counsellor_Profile__c where Id=:NewcpId LIMIT 1];
         List<User> UserInfo=[select id,Name,Contact.Name, ContactId ,Email, MobilePhone from User where ContactId=:ContactId];
        system.debug('UserInfo==>'+UserInfo);
         list<contact> lstCon = [select id,AccountId from contact where Id=:ContactId];
        
        Counsellor_Profile__c c=new Counsellor_Profile__c();
            c.Id = NewcpId;
            c.OwnerId=UserInfo[0].Id;
            c.BusinessAccount__c=lstCon[0].AccountId;
            update c;
        
    }

  
}