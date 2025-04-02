trigger LiveChatTranscrpitEventTrigger on LiveChatTranscriptEvent (after insert,after update) 
{
   if(Trigger.isAfter && Trigger.isInsert)
   {
     LiveChatTranscrpitEventTriggerHandler obj=new LiveChatTranscrpitEventTriggerHandler(); 
     obj.afterinsert(Trigger.new);
   }
   
}