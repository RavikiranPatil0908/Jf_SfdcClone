@isTest(SeeAllData=true)
public class LiveChatTranscrpitEventTriggerTracker
{
      public static LiveChatTranscript objTanscrpt;
      public static LiveChatTranscriptEvent  objEvent;
 

  static TestMethod void Test1()
  {
        Profile p = [SELECT Id FROM Profile WHERE Name=:'Super Admin' limit 1];
         
        User  u = new User(Alias = 'standt1', Email='standar1duser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standard11user@testorg.com');
        insert u;
        
        
        LiveChatVisitor objVisit=new LiveChatVisitor();
        insert objVisit;
    
        LiveChatTranscript objTanscrpt=new LiveChatTranscript(); 
        objTanscrpt.LiveChatVisitorId=objVisit.id;
        objTanscrpt.Transcript_Events__c='sdsdsd';
        insert objTanscrpt;
        
        LiveChatTranscriptEvent objEvent=new LiveChatTranscriptEvent();
        objEvent.Type='Other';
        objEvent.Time=system.now();
        objEvent.LiveChatTranscriptId=objTanscrpt.id;
        objEvent.AgentId=u.id;
        objEvent.Detail='Test';
        insert objEvent;
        
        LiveChatTranscrpitEventTriggerHandler obj=new LiveChatTranscrpitEventTriggerHandler();
   }
}