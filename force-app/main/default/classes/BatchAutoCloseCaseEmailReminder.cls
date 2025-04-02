public class BatchAutoCloseCaseEmailReminder implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query= 'Select Id,CaseNumber,Email_Reminder_DateTime__c,ContactEmail,Tech_Issue__c From Case WHERE Email_Reminder_DateTime__c !=null AND Email_Reminder_DateTime__c >= LAST_N_DAYS:4 AND Email_Reminder_DateTime__c <= YESTERDAY AND Status=\'In Progress\' ';
        System.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> lstCase) { 
        System.debug('lstCase==>'+lstCase);
        Set<Id> studentCaseCommentIds = new Set<Id>();
        List<Case> FirstReminderList=new List<Case>();
        List<Case> SecondReminderList=new List<Case>();
        List<Case> ThirdReminderList=new List<Case>();
        List<Case> FinalUpdateList=new List<Case>();
        List<CaseComment> comList=new List<CaseComment>();
        map<id,Case> casemap = new map<id,Case>();
        
        List<String> caseIds = new List<String>();
        Map<string,CaseComment> mapOfCaseIdVsComment=new Map<string,CaseComment>();
        List<CaseComment> caseCommentList= new List<CaseComment>();
        for(Case c : lstCase) {
            caseIds.add(c.Id);
        }
        
        for(CaseComment comment : [SELECT ParentId,CreatedDate FROM CaseComment WHERE ParentId in:caseIds and CreatedBy.Name='NMIMS Site Guest User' AND CreatedDate >= LAST_N_DAYS:4 order by CreatedDate Desc ] ) {
            Id caseId = comment.ParentId;
            if (!mapOfCaseIdVsComment.containsKey(caseId))
                mapOfCaseIdVsComment.put(caseId, comment);
        }
        
        for(Case c : lstCase) {
            
            CaseComment com=mapOfCaseIdVsComment.containsKey(c.Id)? mapOfCaseIdVsComment.get(c.Id):null;
            system.debug('com==>'+com);
            Datetime dt=System.today();
            dt=dt.addDays(-2);
            system.debug('dt==>'+dt);
            if(c.Email_Reminder_DateTime__c >=dt && c.Email_Reminder_DateTime__c <=System.today() && 
               (com==null || com.CreatedDate < dt ))
            { 
                system.debug('Inside First Reminder');
                Case ob=new Case();
                ob.Id=c.Id;
                ob.FirstReminder__c=True;
                FirstReminderList.add(ob);
            }
            
            Datetime dt1=System.today();
            dt1=dt1.addDays(-3);
            system.debug('dt1==>'+dt1);
            if(c.Email_Reminder_DateTime__c >=dt1 && c.Email_Reminder_DateTime__c <=dt && 
               (com==null || com.CreatedDate < dt1 ))
            {
                system.debug('Inside second Reminder');
                Case ob=new Case();
                ob.Id=c.Id;
                ob.SecondReminder__c=True;
                SecondReminderList.add(ob);
            }
            
            Datetime dt2=System.today();
            dt2=dt2.addDays(-4);
            system.debug('dt2==>'+dt2);
            if(c.Email_Reminder_DateTime__c >=dt2 && c.Email_Reminder_DateTime__c <=dt1 &&
               (com==null || com.CreatedDate < dt2 ))
            {
                system.debug('Inside Third Reminder');
                Case ob=new Case();
                if(String.isBlank(c.Tech_Issue__c))
                {
                 ob.Tech_Issue__c='No';   
                }
                ob.Id=c.Id;
                ob.ThirdReminder__c=True;
                ob.IsAutoClosed__c=True;
                ob.Status='Closed';
                ThirdReminderList.add(ob);
            }
            
        }
        
        for(Case c: ThirdReminderList)
        {
            CaseComment cm=new CaseComment();  
            cm.ParentId=c.Id;
            cm.CommentBody='Since there has been no reply from your end we need to close this case/ticket. In case you have any queries you can raise your query via the ticketing tool by going to Student Support > Connect With Us > My Tickets Or schedule a callback by going to Student Support > Connect With Us > Schedule a Callback.If you are not a student - Please go to our website https://online.nmims.edu/ > Help and Support > Write to Us.';
            comList.add(cm);
        }
        
        If(comList.size()>0)
        {
            insert comList;
        }
        
        
        If(FirstReminderList.size()>0)
        {
            FinalUpdateList.addAll(FirstReminderList);
            
        }
        
        If(SecondReminderList.size()>0)
        {
            FinalUpdateList.addAll(SecondReminderList);
        }
        
        If(ThirdReminderList.size()>0)
        {
            FinalUpdateList.addAll(ThirdReminderList);  
        }
        
        system.debug('FinalUpdateList==>'+FinalUpdateList);
        If(FinalUpdateList.size()>0)
        {
            //put all the values from the list to map. 
            casemap.putall(FinalUpdateList);
            if(casemap.size()>0){
                update casemap.values();
            }
            // update FinalUpdateList;
        }
        
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}