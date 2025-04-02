trigger nmTaskTrigger on Task (before insert) 
{
    if(trigger.isBefore && trigger.isInsert)
    {
      if(Test.isRunningTest())
        {
             if(checkRecursive.runOnce())
             {
        nmTaskTriggerHandler objTask = new nmTaskTriggerHandler();
        objTask.BeforeInsertUpdate(trigger.New,trigger.oldmap);
        }
     }
    }
}