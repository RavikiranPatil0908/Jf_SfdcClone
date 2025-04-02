trigger updatetime on Lead (after insert,after update,before insert,before update) 
{ 
    list <lead> lstlead = new list<lead>();
    
    //Commented by Sanket and moved to nmLeadTriggerHandler: 17-Sep-2015: 19:22
    /*
    if(Trigger.isAfter && Trigger.isInsert)
    {
      if(checkRecursive.isUpdateTimeInsertLead==true)
      {
          checkRecursive.isUpdateTimeInsertLead=false;
      }
      else
      {
          return;
      }
        for(Lead objlead: trigger.new)
        {
            Lead objNewLead = new Lead(id=objLead.id);
            objNewLead.nm_TimeStamp2__c = objLead.nm_CreatedDatetime__c.format('hh:mm a');
            lstlead.add(objNewLead);
        }
        
        update lstlead;
    }
    
    */
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        if(checkRecursive.isUpdateTimeUpdateLead==true)
        {
           checkRecursive.isUpdateTimeUpdateLead=false; 
        }
        else{
        return;
        }
        for(Lead objlead: trigger.new)
        {
            if(objLead.nm_TimeStamp2__c == null)
            {
                System.debug('**'+objLead.nm_TimeStamp2__c);
                Lead objNewLead = new Lead(id=objLead.id);
                
                objNewLead.nm_TimeStamp2__c = objLead.nm_CreatedDatetime__c.format('hh:mm a');
                lstlead.add(objNewLead);
            }
        }
        if(lstlead.size() > 0)
        {
            update lstlead;
        }
    }/*
    if(Trigger.isBefore && Trigger.isInsert)
    {
     list <lead> lstupdatelead = new list<lead>();
     user objuser = [select id,name from user where UserRole.Name = 'Adminssion Department' limit 1 ];
    if(checkRecursive.runOnce())
        {
            for(lead objlead : trigger.new)
            {
                if(objlead.MobilePhone  == null && objlead.Email == null && objlead.nm_InformationCenter__c == null && objLead.FirstName == null && objlead.nm_Program__c == null)
                {
                    // Lead objNewLead = new Lead(id=objLead.id);
                     objlead.nm_Invalid_Lead__c = true;
                     objLead.ownerId = objUser.id;
                     lstupdatelead.add(objlead);
                     System.debug('Lead invalid field'+objlead.nm_Invalid_Lead__c);
                }
            }
           
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate)
    {
     list <lead> lstupdatelead1 = new list<lead>();
     user objuser = [select id,name from user where UserRole.Name = 'Adminssion Department' limit 1 ];
    if(checkRecursive.runOnce())
        {
            for(lead objlead : trigger.new)
            {
                if(objlead.MobilePhone  == null && objlead.Email == null && objlead.nm_InformationCenter__c == null && objLead.FirstName == null && objlead.nm_Program__c == null)
                {
                    // Lead objNewLead = new Lead(id=objLead.id);
                     objlead.nm_Invalid_Lead__c = true;
                     objLead.ownerId = objUser.id;
                     lstupdatelead1.add(objlead);
                     System.debug('Lead invalid field'+objlead.nm_Invalid_Lead__c);
                }
            }
           
        }
    }*/
}