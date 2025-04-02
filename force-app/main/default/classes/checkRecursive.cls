public Class checkRecursive{
    public static integer StopRecurrence {get;set;}
    public static integer StopRecurrenceOnAcc {get;set;}
    public static integer StopRecurrenceOnOpp {get;set;}
    public static integer StopRecurrenceOnLFD {get;set;}
    public static integer StopRecurrenceOnLFDL {get;set;}
    public static integer StopRecurrenceOnLFDM {get;set;}
    public static boolean run = true;
    public static Boolean isRestrationLead=true;
    public static Boolean isUpdateTimeInsertLead=true;
    public static Boolean isUpdateTimeUpdateLead=true; 
    public static Boolean isUpdateTimeUpdate=true;
    public static Boolean isUpdateTimeUpdateComonApproval=true;
    public static Boolean isUpdateTimeDocApproval=true;
    public static Boolean isCaluclateLateFeesPendingAmount=true;
    public static boolean isrecurssiveCheckIchange1=true;
    public static boolean isrecurssiveCheckIchange2=true;
    public static string paymnetLatefeesid='';
    public static boolean isrecurssiveCheckIchangeForAccount=true;
    public static boolean isrecurssiveCheckIchangeForAccountUpdate=true;
    public static boolean isCheckRecurssiveforClosedandClosedOwn=true;
    public static boolean ischeckcanceltrigger=true;
    public static boolean isCheckPaymentoflAtefees=true;
    public static boolean isLatefeesCheck=true;
    public static boolean runbefore = true;
    public static boolean runafter = true;
    
    public static boolean runOnce()
    {
        if(run)
        {
         run=false;
         return true;
        }else
        {
            return run;
        }
    }
    
    public static void resetAll()
    {
         run = true;
    }
    
    // added this method to cover After and Before method separately
    public static boolean runBeforeOnce()
    { 
        if(runbefore)
        {
         runbefore=false;
         return true; 
        }
        else
        {
            return runbefore;
        }
    }
    
    public static boolean runAfterOnce()
    {
        if(runafter)
        {
         runafter=false;
         return true;
        }
        else
        {
            return runafter;
        }
    }
 
}