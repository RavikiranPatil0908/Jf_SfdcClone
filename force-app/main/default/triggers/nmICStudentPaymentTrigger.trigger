trigger nmICStudentPaymentTrigger on Account (after update) {

if(checkRecursive.run2==true)
{
    List<Account> accountsToProcess = [select id,Account_Confirm_Date__c,nm_StudentStatus__c,nm_Centers__c from Account where id IN :Trigger.NewMap.KeySet()];

    try
    {
        set<id> setAccountid = new set<id>();
        for(Account objAcc : accountsToProcess)
        {
            setAccountid.add(objAcc.id);
        }
        System.debug(accountsToProcess);
        List<Opportunity> lstOPP = new List<Opportunity>();
        Map<ID,Opportunity> mapOPP = new Map<ID,Opportunity>();
        if(setAccountid.size()>0)
        {
            lstOpp = [select id,BB_Admission_Date__c, nm_Session__c, nm_Year__c from Opportunity where Accountid in :setAccountid];
        }
        set<id> setOpp = new set<id>();
        System.debug('lstOpp+++'+lstOpp.size());
        if(lstOpp.size()>0)
        {
            for(Opportunity obj : lstOpp)
            {  
                setOpp.add(obj.id);
                mapOPP.put(obj.id, obj);
            }
        }
        System.debug('setOpp+++'+setOpp.size());
        if(setOpp.size()>0)
        {

            Map<String,IC_Payment__c> existingICPaymentMap = new Map<String,IC_Payment__c>();
            List<StudentPayment__c> studentPaymentList = new List<StudentPayment__c>();
            List<nm_Payment__c> updatePaymentList = new List<nm_Payment__c>();
            List<String> accntOptyMappingList = new List<String>();
            Map<String, nm_Payment__c> accntOptyIDvsPaymentMap = new Map<String,nm_Payment__c>();

            //Pull Existing payments from students with type as Admission and matching with opportunity of Account updated
            List<nm_Payment__c> paymentsToProcess  = [select 
                id,
                nm_Amount__c,
                nm_AccountID__c,
                Processed__c, 
                nm_OpportunityNew__c,
                nm_BankLocation__c, 
                nm_DemandDraftDate__c, 
                nm_DemandDraftNumber__c , 
                nm_DispatchDate__c , 
                nm_NameoftheBank__c, 
                nm_TransactionDate__c, 
                nm_TransactionID__c 
                from nm_Payment__c where nm_PaymentType__c = 'Admission' AND Processed__c = FALSE
                and nm_OpportunityNew__c in :setOpp] ;

            List<IC_Payment__c> existingICPayments = [select id,Payment_Month__c,Payment_Year__c,Amount__c,Centers__c from IC_Payment__c];


            for(nm_Payment__c n : paymentsToProcess)
            {
                //Add all account ID + Opportunity ID keys in a Map along with its correspondig Payment object
                accntOptyIDvsPaymentMap.put(n.nm_AccountID__c + '/' + n.nm_OpportunityNew__c, n);
                accntOptyMappingList.add(n.nm_AccountID__c + '/' + n.nm_OpportunityNew__c);
            }



            if(!existingICPayments.isEmpty())
            {
                //Put existing IC payment in a map, so that later to decide whether to update a payment or add a new for given Month+Year
                for(IC_Payment__c i : existingICPayments)
                {
                    existingICPaymentMap.put(String.valueOf(i.Centers__c)+i.Payment_Month__c+String.valueof(i.Payment_Year__c),i);
                }
            }

            //Iterate every combination of Account + Opportunity ( One account may have multiple opportunities)
            for(String accntAndOptyId : accntOptyMappingList)
            {

                String accntId = accntAndOptyId.substring(0,accntAndOptyId.indexOf('/'));
                Account a = Trigger.NewMap.get(Id.valueOf(accntId));
                Account oldAccount = Trigger.OldMap.get(Id.valueOf(accntId));

                String optyId = accntAndOptyId.substring(accntAndOptyId.indexOf('/')+1, accntAndOptyId.length());
                Opportunity opty = mapOPP.get(Id.valueOf(optyId));
                //Retrieve Admission MOnth year and Session Month Year. In same admission month year, student can pay for next session 
                String admissionMonthYear = opty.BB_Admission_Date__c;
                String sessionMonth = opty.nm_Session__c.substring(0,3).toUpperCase();
                String sessionMonthYear = sessionMonth+String.valueOf(opty.nm_Year__c);


                system.debug('FOR ENTERED');

                if(a.nm_StudentStatus__c == 'Confirmed')
                {
                    nm_Payment__c payment = accntOptyIDvsPaymentMap.get(accntAndOptyId);

                    Integer firstMonthIncrement = 0;
                    Integer secondMonthIncrement = 1;
                    Integer thirdMonthIncrement = 2;

                    system.debug('CONFIRM STUDENT ENTERED');
                    Integer paymentDate = a.Account_Confirm_Date__c.DAY();
                    if(paymentDate > 10){
                        firstMonthIncrement = 1;
                        secondMonthIncrement = 2;
                        thirdMonthIncrement = 3;
                    }

                    Integer confMonth_0 = a.Account_Confirm_Date__c.MONTH();
                    Integer confMonth = a.Account_Confirm_Date__c.MONTH();
                    Integer confYear  = a.Account_Confirm_Date__c.YEAR();

                    //If payment is for next sem then consider its commision when session starts
                    if(!admissionMonthYear.equalsIgnoreCase(sessionMonthYear)){
                        if('Jul'.equalsIgnoreCase(sessionMonth)){//Pay commision from July
                            confMonth_0 = 7;
                            confMonth = 7;
                        }else{//Pay commision from January
                            confMonth_0 = 1;
                            confMonth = 1;
                        }
                        confYear  = Integer.valueOf(opty.nm_Year__c);
                        //Payment date check of before and after 10 is not applicable.
                        firstMonthIncrement = 0;
                        secondMonthIncrement = 1;
                        thirdMonthIncrement = 2;
                    }

                    

                    Integer confMonth_1,confMonth_2,confYear_1,confYear_2;

                    //Even first payment can go next month
                    if(confMonth + firstMonthIncrement > 12)
                    {
                        confMonth = Math.Mod(confMonth+firstMonthIncrement,12);
                        confYear  = confYear + 1; 
                    }
                    else
                    {
                        confMonth = confMonth + firstMonthIncrement;
                        confYear = confYear;
                    }

                    //Calculate payment month for second comission
                    if(confMonth_0+secondMonthIncrement>12)
                    {
                        confMonth_1 = Math.Mod(confMonth_0+secondMonthIncrement,12);
                        confYear_1  = confYear + 1; 
                    }
                    else
                    {
                        confMonth_1 = confMonth_0 + secondMonthIncrement;
                        confYear_1 = confYear;
                    }

                    //Calculate payment month for third comission
                    if(confMonth_0+thirdMonthIncrement>12)
                    {
                        confMonth_2 = Math.Mod(confMonth_0+thirdMonthIncrement,12);
                        confYear_2  = confYear + 1; 
                    }

                    else
                    {
                        confMonth_2 = confMonth_0 + thirdMonthIncrement;
                        confYear_2 = confYear;
                    }

                    String accountConfirmMonthYear = String.ValueOf(confMonth)+String.ValueOf(confYear);
                    String accountConfirmMonthYear_Two = String.ValueOf(confMonth_1)+String.ValueOf(confYear_1);
                    String accountConfirmMonthYear_Three = String.ValueOf(confMonth_2)+String.ValueOf(confYear_2);


                    system.debug('---CONFIRM MONTH YEAR 1---'+accountConfirmMonthYear);
                    system.debug('---CONFIRM MONTH YEAR 2---'+accountConfirmMonthYear_Two);
                    system.debug('---CONFIRM MONTH YEAR 3 ---'+accountConfirmMonthYear_Three);

                    

                    Double actualPayment_35 = accntOptyIDvsPaymentMap.get(accntAndOptyId).nm_Amount__c * 0.35;

                    //If payment record for an IC for a first Month+Year exists then update amount
                    if(existingICPaymentMap.keyset().contains(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear))
                    {

                        system.debug('IF 1 ENTERED!');

                        IC_Payment__c iOne = existingICPaymentMap.get(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear);
                        iOne.Amount__c += actualPayment_35*0.60;  
                        update iOne; 

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35 * 0.60;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iOne.ID;
                        sp.Percent__c = 60.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;

                        studentPaymentList.add(sp);

                    }
                    //If payment record for an IC for first Month+Year doesn't exists then create a record 
                    else
                    {

                        system.debug('ELSE 1 ENTERED!');       

                        IC_Payment__c iOne = new IC_Payment__c();
                        iOne.Amount__c = actualPayment_35 * 0.60;


                        iOne.Payment_Month__c = String.valueOf(confMonth);
                        iOne.Payment_Year__c = String.valueOf(confYear); 
                        iOne.Payment_Due_Date__c  = Date.ValueOf(String.valueOf(confYear)+'-'+String.valueOf(confMonth)+'-'+'20 1:00:00');
                        iOne.Centers__c = a.nm_Centers__c;

                        insert iOne;

                        existingICPaymentMap.put(String.valueOf(iOne.Centers__c)+iOne.Payment_Month__c+String.valueof(iOne.Payment_Year__c),iOne);

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35 * 0.60;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iOne.ID;
                        sp.Percent__c = 60.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;

                        studentPaymentList.add(sp);

                    }

                    
                    //If payment record for an IC for second Month+Year exists then update amount
                    if(existingICPaymentMap.keyset().contains(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear_Two))
                    {

                        system.debug('IF 2 ENTERED!');                
                        IC_Payment__c iTwo = existingICPaymentMap.get(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear_Two);
                        iTwo.Amount__c += actualPayment_35*0.20;  
                        update iTwo;

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35 * 0.20;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iTwo.ID;
                        sp.Percent__c = 20.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;
                        studentPaymentList.add(sp);

                    }
                    //If payment record for an IC for second Month+Year doesn't exists then create a record 
                    else
                    {
                        system.debug('ELSE 2 ENTERED!');              
                        IC_Payment__c iTwo = new IC_Payment__c();
                        iTwo.Amount__c = actualPayment_35 * 0.20;


                        iTwo.Payment_Year__c = String.valueOf(confYear_1);

                        iTwo.Payment_Month__c = String.valueOf(confMonth_1);
                        iTwo.Payment_Due_Date__c  = Date.ValueOf(String.valueOf(confYear_1)+'-'+String.valueOf(confMonth_1)+'-'+'20 1:00:00');
                        iTwo.Centers__c = a.nm_Centers__c;

                        insert iTwo;

                        existingICPaymentMap.put(String.valueOf(iTwo.Centers__c)+iTwo.Payment_Month__c+String.valueof(iTwo.Payment_Year__c),iTwo);

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35 * 0.20;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iTwo.ID;
                        sp.Percent__c = 20.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;
                        studentPaymentList.add(sp);

                    }

                    //If payment record for an IC for third Month+Year exists then update amount
                    if(existingICPaymentMap.keyset().contains(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear_Three))
                    {

                        system.debug('IF 3 ENTERED!');

                        IC_Payment__c iThree = existingICPaymentMap.get(String.valueOf(a.nm_Centers__c)+accountConfirmMonthYear_Three);
                        iThree.Amount__c += actualPayment_35*0.20;  
                        update iThree;

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35*0.20;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iThree.ID;
                        sp.Percent__c = 20.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;
                        studentPaymentList.add(sp);

                    }
                    //If payment record for an IC for third Month+Year doesn't exists then create a record 
                    else
                    {

                        system.debug('ELSE 3 ENTERED!');       
                        IC_Payment__c iThree = new IC_Payment__c();
                        iThree.Amount__c = actualPayment_35 * 0.20;


                        iThree.Payment_Year__c = String.valueOf(confYear_2) ;  
                        iThree.Payment_Month__c = String.valueOf(confMonth_2);
                        iThree.Payment_Due_Date__c  = Date.ValueOf(String.valueOf(confYear_2)+'-'+String.valueOf(confMonth_2)+'-'+'20 1:00:00');
                        iThree.Centers__c = a.nm_Centers__c;

                        insert iThree;

                        existingICPaymentMap.put(String.valueOf(iThree.Centers__c)+iThree.Payment_Month__c+String.valueof(iThree.Payment_Year__c),iThree);

                        //Link IC Payment with Student
                        StudentPayment__c sp = new StudentPayment__c ();

                        sp.Amount__c = actualPayment_35*0.20;
                        sp.Student__c = a.ID;
                        sp.IC_Payment__c = iThree.ID;
                        sp.Percent__c = 20.0;
                        sp.nm_BankLocation__c = payment.nm_BankLocation__c;
                        sp.nm_DemandDraftDate__c = payment.nm_DemandDraftDate__c;
                        sp.nm_DemandDraftNumber__c = payment.nm_DemandDraftNumber__c;
                        sp.nm_DispatchDate__c = payment.nm_DispatchDate__c;
                        sp.nm_NameoftheBank__c = payment.nm_NameoftheBank__c;
                        sp.nm_TransactionDate__c = payment.nm_TransactionDate__c;
                        sp.nm_TransactionID__c = payment.nm_TransactionID__c;
                        studentPaymentList.add(sp);


                    }

                    
                    payment.processed__c = TRUE;
                    updatePaymentList.add(payment);
                }  
                //ITERATION ENDS
            } 


            if(updatePaymentList.size()>0){
                Database.SaveResult[] srList = Database.update(updatePaymentList, FALSE);
            }

            if(studentPaymentList.size()>0){
                Database.SaveResult[] srList = Database.insert(studentPaymentList, FALSE);
                for (Database.SaveResult sr : srList) 
                {
                    if (sr.isSuccess()) 
                    {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('--SUCCESS--' + sr.getId());
                    }
                    else 
                    {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) 
                        {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('---ERROR IS ---- ' + err.getFields());
                        }
                    }
                }
            }

            
        }
    } // TRY ENDS

    catch(Exception ex)
    {
    
     system.debug('---ERRORS IN THE IC STUDENT PAYMENT TRIGGER ARE---'+ex.getMessage());

        /*
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'kevinkdesai@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(ex.getMessage());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */

    } //CATCH ENDS

    checkRecursive.run2=false;
}
else
{
    return;
}



} //TRIGGER ENDS