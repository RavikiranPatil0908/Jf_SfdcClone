trigger ChangeCaseOwner on Case(before update) 
{ 
    if(checkRecursive.runOnce())
    {  
         checkRecursive.run =false;
    }
    else
    {
         return;
    }
    
    for(Case objCase :trigger.New)
    {
         if(objCase.AssignTo__c!=null && objCase.AssignTo__c!=Trigger.OldMap.get(objCase.id).AssignTo__c)
         { 
            User objUser =[select id from User where Name =:objCase.AssignTo__c];
            objCase.Ownerid=objUser.id;
         }
    }
}