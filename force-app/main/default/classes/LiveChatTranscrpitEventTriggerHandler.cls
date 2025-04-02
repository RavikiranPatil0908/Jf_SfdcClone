/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-01-2024
 * @last modified by  : @BK
**/
public class LiveChatTranscrpitEventTriggerHandler {

    public void afterinsert(list < LiveChatTranscriptEvent > lstTranscrpit) {
        UpdateDetailsTranscriptEvent(lstTranscrpit);
    }
    
    public void UpdateDetailsTranscriptEvent(list < LiveChatTranscriptEvent > lstTranscrpit) {
        list < LiveChatTranscript > lstLiveChatTranscript = new list < LiveChatTranscript > ();
        list<LiveChatTranscriptEvent > lstdeleteLiveChatTranscriptEvent =new list<LiveChatTranscriptEvent>();
        if (lstTranscrpit.size() > 0) {

            for (LiveChatTranscriptEvent objTranscript: lstTranscrpit) 
            {   
                //Convert it into Indian Standard Time(dtIST).
                String dtIST = objTranscript.Time.format('yyyy-MM-dd HH:mm:ss', 'IST');
                //lstdeleteLiveChatTranscriptEvent.add(new LiveChatTranscriptEvent(id=objTranscript.id));
                lstdeleteLiveChatTranscriptEvent=[select id,Agent.Name from LiveChatTranscriptEvent  where id=:objTranscript.id];
                LiveChatTranscript obj = [select id,Transcript_Events__c  from LiveChatTranscript  where id=:objTranscript.LiveChatTranscriptID];
                if(''.equals(obj.Transcript_Events__c) || obj.Transcript_Events__c == null){
                    obj.Transcript_Events__c ='Time'+' '+ dtIST+'\n'+'Agent'+' '+lstdeleteLiveChatTranscriptEvent[0].Agent.Name+'\n'+'Type'+' '+objTranscript.Type+'\n'+'Detail'+' '+objTranscript.Detail+'\n';
                }else{
                    obj.Transcript_Events__c +='\n'+'\n'+'Time'+' '+ dtIST+'\n'+'Agent'+' '+lstdeleteLiveChatTranscriptEvent[0].Agent.Name+'\n'+'Type'+' '+objTranscript.Type+'\n'+'Detail'+' '+objTranscript.Detail+'\n';
                } 
                
                lstLiveChatTranscript.add(obj);
                
             }
             
            if (lstLiveChatTranscript.size() > 0) {
                update lstLiveChatTranscript;
               }
               if(lstdeleteLiveChatTranscriptEvent.size()>0)
               {
                  delete lstdeleteLiveChatTranscriptEvent;
               }
            
         }

    }
    
   
}