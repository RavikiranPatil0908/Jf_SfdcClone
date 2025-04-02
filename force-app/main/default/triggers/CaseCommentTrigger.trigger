trigger CaseCommentTrigger on CaseComment (before update, before delete) {  
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            for(CaseComment caseCmt : Trigger.new){
                if(caseCmt.CreatedDate.addMinutes(10) < System.now()){
                    caseCmt.addError('You can not Update Case Comment.');
                }
            }
        }
    }
    else if(Trigger.isDelete){
        if(Trigger.isBefore){
            String profileName = [Select Id,Name from Profile where Id=:Userinfo.getProfileId()].Name;
            for(CaseComment caseCmt : Trigger.old){
                if(profileName != 'System Administrator' && profileName != 'Super Admin'){
                    caseCmt.addError('You can not Delete Case Comment.');
                }
            } 
        }
    }/*else if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            Map<String, String> ccMap = new Map<String, String>();
            for (CaseComment caseCmt : Trigger.new) {      
                ccMap.put(caseCmt.ParentId, caseCmt.CommentBody);
            }
            List<Case> cmnts = new List<Case>();
            List<Case> cLst = [SELECT Id, recent_Comment__c, Status FROM Case WHERE Id IN :ccMap.keySet()];
            for (Case c : cLst) {
                c.recent_Comment__c = ccMap.get(c.Id);                
                //c.Add_Comment__c = true;
                //c.isOnlyStatus__c = false;            	
                cmnts.add(c);
            }
            update cmnts;
        }
    }*/
    
}