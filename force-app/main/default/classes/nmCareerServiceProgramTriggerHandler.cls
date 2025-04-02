public class nmCareerServiceProgramTriggerHandler {

    public void AfterInsert(List<Career_Service_Program__c> triggerNew, map<id, Career_Service_Program__c> mapCareerNewMap)
    {
                      //  CareerAEPShare(triggerNew,mapCareerNewMap); 

    }
    
     public void AfterUpdate(List<Career_Service_Program__c> triggerNew, map<id, Career_Service_Program__c> mapCareerOldMap)
    {
                CareerAEPShare(triggerNew,mapCareerOldMap); 
                CareerDebitShare(triggerNew,mapCareerOldMap);
    }
    
    public void CareerAEPShare(List<Career_Service_Program__c> lstCareerServiceProgram,map<id, Career_Service_Program__c> CareerOldMap)
    {
        Map<Id,Integer> mapfoCareerServiceProgramVsAmount = new Map<Id,Integer>();
        Map<Id,Career_Service_Program__c> mapOfCareerServiceVsObj = new Map<Id,Career_Service_Program__c>();
       if(lstCareerServiceProgram.size()>0) 
       {
         for (Career_Service_Program__c objcsp:lstCareerServiceProgram) 
         {
             if(objcsp.Stage__c !=CareerOldMap.get(objcsp.id).Stage__c && objcsp.Stage__c=='Payment Done'&& objcsp.Credit_Transaction__c==null)
             {
                 mapOfCareerServiceVsObj.put(objcsp.id,objcsp);
             }
         }  
         if(!mapOfCareerServiceVsObj.isEmpty())
         {
             list<nm_Payment__c> lstpayment = [select id ,nm_Amount__c,nm_ActualPaymentAmmount__c , CareerServiceProgram__c from nm_Payment__c   where nm_PaymentType__c ='Career Service' and (nm_PaymentStatus__c='Payment Made' or nm_PaymentStatus__c='Payment Approved') and CareerServiceProgram__c=:mapOfCareerServiceVsObj.Keyset()];
             
             if(lstpayment.size()>0)
             {
                for(nm_Payment__c objpayment :lstpayment) 
                {
                    mapfoCareerServiceProgramVsAmount.put(objpayment.CareerServiceProgram__c,Integer.valueof(objpayment.nm_Amount__c));
                }
             }
             if(!mapfoCareerServiceProgramVsAmount.IsEmpty())
             {
                 CreatShare(mapfoCareerServiceProgramVsAmount,mapOfCareerServiceVsObj);
             }
             
         }           
       }

    }
    
        public void CreatShare(Map<Id,Integer> mapfoCareerServiceProgramVsAmount,Map<Id,Career_Service_Program__c> mapOfCareerServiceVsObj)
    {   Map<String,String> mapofCareerServiceIDvsICTransaction = new Map<String,String>();
        List<Career_Service_Program__c> lstCSP = new List<Career_Service_Program__c>();
        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;

            if(today.day()  <= 10 ){
             CurrentMonth = today.Month();
            }else{
             CurrentMonth = today.Month() + 1;
            }
            if(CurrentMonth >=13)
            {
                CurrentMonth = CurrentMonth - 12;
                CurrentYear = today.Year()+1;
            }
            
            if(!mapfoCareerServiceProgramVsAmount.IsEmpty())
            {
                nmICPaymentTriggerHandler icpaymenthelper = new nmICPaymentTriggerHandler();
                
                for(String cspid : mapfoCareerServiceProgramVsAmount.keyset())
                {
                IC_Payment__c icPayment = icpaymenthelper.getICPayment(String.valueOf(CurrentYear),String.valueOf(CurrentMonth),mapOfCareerServiceVsObj.get(cspid).IC_Name__c);        
                  IC_Payment_Transaction__c objtrancRecord =  CreateTransactionRecord(icPayment,mapfoCareerServiceProgramVsAmount.get(cspid),cspid,
                    mapOfCareerServiceVsObj.get(cspid).Account__c);
                    mapofCareerServiceIDvsICTransaction.put(cspid,objtrancRecord.id);
                    system.debug('mapofCareerServiceIDvsICTransaction--->'+mapofCareerServiceIDvsICTransaction);
                }
                if(!mapofCareerServiceIDvsICTransaction.IsEmpty())
                {
                    for(String csid : mapofCareerServiceIDvsICTransaction.keySet())
                    {
                        Career_Service_Program__c objcsp = new Career_Service_Program__c(id=csid);
                        objcsp.Credit_Transaction__c= mapofCareerServiceIDvsICTransaction.get(csid);
                        lstCSP.add(objcsp);
                    }
                    
                    if(lstCSP.size()>0)
                    {
                        update lstCSP;
                    }
                }
            }

    }
    
    public IC_Payment_Transaction__c CreateTransactionRecord (IC_Payment__c icPayment, Integer amount,String cspId,String accId)
    {
        Date today = Date.Today(); 
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();        
        ip.Amount__c =  amount*0.25;
        ip.Narration__c = 'Career Service - Adjustment Credit'  ;
        ip.IC_Payment__c = icPayment.Id;   
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = icPayment.Payment_Due_Date__c;
        ip.Date__c = today;
        ip.Account__c = accId;
        ip.Career_Service_Program__c = cspId;
        insert ip;
        return ip;
    }
    public void CareerDebitShare(List<Career_Service_Program__c> lstCareerServiceProgram,map<id, Career_Service_Program__c> CareerOldMap)
    {
        list<IC_Payment_Transaction__c> lstIcpayment = new list<IC_Payment_Transaction__c>();
        Map<Id,IC_Payment_Transaction__c> mapfoCareerServiceProgramVsAmount = new Map<Id,IC_Payment_Transaction__c>();
        Map<Id,Career_Service_Program__c> mapOfCareerServiceVsObj = new Map<Id,Career_Service_Program__c>();

       if(lstCareerServiceProgram.size()>0) 
       {
             for (Career_Service_Program__c objcsp:lstCareerServiceProgram) 
            {
                if(objcsp.Stage__c !=CareerOldMap.get(objcsp.id).Stage__c && objcsp.Stage__c=='Cancelled'&& objcsp.Debit_Transaction__c==null)
                {
                    mapOfCareerServiceVsObj.put(objcsp.id,objcsp);
                }
            }        
                if(!mapOfCareerServiceVsObj.isEmpty())
                {
                    lstIcpayment = [select id ,Amount__c,Transaction_Type__c ,IC_name__c,Account__c,Career_Service_Program__c, Career_Service_Program__r.IC_Name__c from IC_Payment_Transaction__c where Transaction_Type__c ='Admission Commision - Credit' and Career_Service_Program__c=:mapOfCareerServiceVsObj.Keyset()];
                }
                if(lstIcpayment.size()>0)
                {
                    for(IC_Payment_Transaction__c objTransactionType :lstIcpayment)
                    {
                        mapfoCareerServiceProgramVsAmount.put(objTransactionType.Career_Service_Program__c,objTransactionType);
                    }
                }
                if(!mapfoCareerServiceProgramVsAmount.isEmpty())
                {
                    CreatDebitShare(mapfoCareerServiceProgramVsAmount);
                }        
        }
    }
    
    public void CreatDebitShare(Map<Id,IC_Payment_Transaction__c> mapfoCareerServiceProgramVsAmount)
    {  Map<String,String> mapofCareerServiceIDvsICTransaction = new Map<String,String>();
       List<Career_Service_Program__c> lstCSP = new List<Career_Service_Program__c>();

        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;

            if(today.day()  <= 10 ){
             CurrentMonth = today.Month();
            }else{
             CurrentMonth = today.Month() + 1;
            }
            if(CurrentMonth >=13)
            {
                CurrentMonth = CurrentMonth - 12;
                CurrentYear = today.Year()+1;
            }
            
            if(!mapfoCareerServiceProgramVsAmount.IsEmpty())
            {
                nmICPaymentTriggerHandler icpaymenthelper = new nmICPaymentTriggerHandler();
                
                for(String cspid : mapfoCareerServiceProgramVsAmount.keyset())
                {
                    IC_Payment__c icPayment = icpaymenthelper.getICPayment(String.valueOf(CurrentYear),String.valueOf(CurrentMonth),mapfoCareerServiceProgramVsAmount.get(cspid).Career_Service_Program__r.IC_Name__c);        
                  IC_Payment_Transaction__c objDebitentry =  CreateDebitTransactionRecord(icPayment,Integer.valueof(mapfoCareerServiceProgramVsAmount.get(cspid).Amount__c),cspid,mapfoCareerServiceProgramVsAmount.get(cspid).Account__c);
                         mapofCareerServiceIDvsICTransaction.put(cspid,objDebitentry.id);
                    system.debug('mapofCareerServiceIDvsICTransaction--->'+mapofCareerServiceIDvsICTransaction);

                }
                if(!mapofCareerServiceIDvsICTransaction.IsEmpty())
                {
                    for(String csid : mapofCareerServiceIDvsICTransaction.keySet())
                    {
                        Career_Service_Program__c objcsp = new Career_Service_Program__c(id=csid);
                        objcsp.Debit_Transaction__c = mapofCareerServiceIDvsICTransaction.get(csid);
                        lstCSP.add(objcsp);
                    }
                    
                    if(lstCSP.size()>0)
                    {
                        update lstCSP;
                    }
                }
            }
    }
    
    public IC_Payment_Transaction__c CreateDebitTransactionRecord (IC_Payment__c icPayment, Integer amount,String cspId,String accId)
    {
        Date today = Date.Today(); 
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();        
        ip.Amount__c =  amount;
        ip.Narration__c = 'Career Service - Adjustment Debit'  ;
        ip.IC_Payment__c = icPayment.Id;   
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = icPayment.Payment_Due_Date__c;
        ip.Date__c = today;
        ip.Career_Service_Program__c = cspId;
        ip.Account__c = accId;
        insert ip;
        return ip;
    }

}