trigger nmStudentProgramTrigger on nm_StudentProgram__c (after update) {

     if(trigger.isafter && trigger.isupdate)
     {
        nmStudentProgramTriggerHandler obj = new nmStudentProgramTriggerHandler();
        obj.AfterUpdate(trigger.new,trigger.oldMap);
        obj.UpdateOppsOnProgChange(trigger.New,trigger.OldMap);
      
     }

}