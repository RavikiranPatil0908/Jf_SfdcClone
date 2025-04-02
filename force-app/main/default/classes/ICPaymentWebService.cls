global class ICPaymentWebService {
    public static final Integer  FIXED_DEDUCT = Integer.ValueOf(Label.Courier_charge);

    webService static void createICTransactionDebitEntry(Opportunity objOpp, Integer excessYear, Integer excessMonth,Decimal Amount,String InformationCenter,String Narration){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();  
        IC_Payment__c icPayment = getICPayment(String.valueOf(excessYear),String.valueOf(excessMonth),InformationCenter);        
        ip.Amount__c = Amount;
        
        ip.Narration__c = (Narration!='' && Narration!= null) ?  objOpp.Account.Name +' - '+Narration : objOpp.Account.Name + ' - AdjustmentDebit'  ;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(excessYear)+'-'+String.valueOf(excessMonth)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        insert ip;
    }

    webService static void createICTransactionCreditEntry(Opportunity objOpp, Integer excessYear, Integer excessMonth,Decimal Amount,String InformationCenter,String Narration){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();  
        IC_Payment__c icPayment = getICPayment(String.valueOf(excessYear),String.valueOf(excessMonth),InformationCenter);        
        ip.Amount__c = Amount;
        ip.Narration__c = (Narration!='' && Narration!= null) ? objOpp.Account.Name +' - '+Narration : objOpp.Account.Name + ' - Pending Commission';
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(excessYear)+'-'+String.valueOf(excessMonth)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        insert ip;
    }

    public static IC_Payment__c getICPayment(String paymentyear,String paymentmonth, String Center)
    {
        system.debug('paymentyear--->'+paymentyear);
        system.debug('paymentmonth--->'+paymentmonth);
        system.debug('Center--->'+Center);
         
         List<IC_Payment__c> lstofICPayment = [select id,Payment_Month__c,Payment_Year__c,Amount__c,
                                         Centers__c,nm_CenterName__c ,Payment_Due_Date__c
                                         from IC_Payment__c 
                                         where Payment_Year__c =:paymentyear 
                                         and Payment_Month__c =:paymentmonth
                                         and nm_CenterName__c =:Center];       
        if(lstofICPayment.size()>0 )
        {
        System.debug('lstofICPayment.size()--->'+lstofICPayment);
            return lstofICPayment[0];
        }
        else
        {
              IC_Payment__c icPayment = new IC_Payment__c();  
              list<nm_Centers__c>  lstcenterid = [select id, name from nm_Centers__c where name=:Center];          
                icPayment.Amount__c =  FIXED_DEDUCT;
                icPayment.Payment_Month__c = paymentmonth;
                icPayment.Payment_Year__c = paymentyear; 
                icPayment.Payment_Due_Date__c  = Date.ValueOf(String.valueOf(paymentyear)+'-'+String.valueOf(paymentmonth)+'-'+'20 1:00:00');
                icPayment.Centers__c = lstcenterid[0].id;
                insert icPayment;
                System.debug('icPayment--->'+icPayment);
                return icPayment;
        }
       
    }
}