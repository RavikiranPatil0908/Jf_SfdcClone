// This Class is used as a trigger handler for Task trigger
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        04-April-2014      Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------

public with sharing class nmTaskTriggerHandler 
{
  //Method to handle all before insert trigger events
  public void BeforeInsertUpdate(list<Task> triggerNew, map<id,Task> triggerOldMap)
    {
      UpdateTaskOwner(triggerNew);
      
      //DisableReminder(triggerNew);
    }
    
    
    public void UpdateTaskOwner (list<Task> lstTask)
    {
      if(lstTask != null)
      {
        set<id> setLeadID = new set<id>();
        for(Task objTask : lstTask )
        setLeadID.add(objTask.whoId);
        
        map<id,Lead> mapLeadIdOwnerId = new map<id,Lead>([select id, OwnerId from Lead where id in: setLeadID]);
        
        if(mapLeadIdOwnerId != null)
        {
          for(Task objTask : lstTask)
          {
            if(objTask.whoId != null && mapLeadIdOwnerId.get(objTask.whoId) != null)
            objTask.OwnerId = mapLeadIdOwnerId.get(objTask.whoId).OwnerId ;
          }
        }
      }
    }
    
    public void DisableReminder(list<Task> lstTask)
    {
      if(lstTask != null)
      {
        for(Task objTask : lstTask)
        objTask.IsReminderSet = false;
      }
    }
}