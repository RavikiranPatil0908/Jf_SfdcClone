trigger ContactUserRoleChange on Contact (Before Update,after update) {
    if(trigger.isBefore  && trigger.isUpdate)
     {    
        ContactUserRoleChangeHandler obj=new ContactUserRoleChangeHandler();
         obj.AfterUserRoleChange(trigger.new, trigger.oldMap);
      
     }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        ContactUserRoleChangeHandler obj=new ContactUserRoleChangeHandler();
        obj.AfterUserRoleChange(trigger.new, trigger.oldMap);
        
    }

}