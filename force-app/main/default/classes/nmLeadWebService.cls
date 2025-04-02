/**
 * @File Name          : nmLeadWebService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 8/31/2019, 11:18:38 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    4/7/2019, 7:28:09 PM   @BK     Initial Version
**/
global class nmLeadWebService 
{
    //public class applicationException extends Exception {}
    webService static void ApprovePayment(String strPaymentId) 
    {
        if(strPaymentId != null && strPaymentId != '')
        {
            nm_Payment__c objPayment = [select id, CreatedDate, nm_ModeOfPayment__c,nm_TransactionDate__c, nm_Lead__r.Email, nm_PaymentStatus__c, nm_PaymentType__c, nm_Lead__c, nm_OpportunityNew__c from nm_Payment__c where id =: strPaymentId];
            Date lateFeeCheck = objPayment.nm_TransactionDate__c;
            //check here payment record is late fees or not.
            system.debug('ABC :' + objPayment.nm_PaymentType__c);
            if(objPayment.nm_PaymentType__c=='Late Fees' && objPayment.nm_PaymentStatus__c=='Payment Made'){
                system.debug('ABC1');    
                 // mayur 8-Aug-2015
                 // Modified to avoid the creation Late Fee record -- when student pays via online before late fee calender start date
                 // and payment is approved within late fee date range
                 objPayment.nm_PaymentStatus__c = 'Payment Approved';       
                 update objPayment;   
            }
            
            if(objPayment.nm_PaymentType__c=='Registration' && objPayment.nm_PaymentStatus__c=='Payment Made' && objPayment.nm_Lead__c==null){
                     
                 nm_Payment__c objPayment1 = [select id, nm_PaymentStatus__c from nm_Payment__c where id =: strPaymentId];
                 objPayment1 .nm_PaymentStatus__c = 'Payment Approved';       
                 update objPayment1 ; 
              }
              else if(objPayment.nm_PaymentType__c=='Installment' && objPayment.nm_PaymentStatus__c=='Payment Made' ){
                   
               // Approve Installment Payment 
                 nm_Payment__c objPayment1 = [select id, nm_PaymentStatus__c from nm_Payment__c where id =: strPaymentId];
                 objPayment1 .nm_PaymentStatus__c = 'Payment Approved';       
                 update objPayment1 ; 
              }
            else if(objPayment.nm_PaymentType__c=='Registration' && objPayment.nm_PaymentStatus__c=='Payment Made'){
                nm_Payment__c objPayment1 = [select id, nm_PaymentStatus__c,nm_Lead__r.Email from nm_Payment__c where id =: strPaymentId];         
                objPayment1.nm_PaymentStatus__c = 'Payment Approved';       
                update objPayment1 ;   
            }
            else if(objPayment.nm_PaymentType__c=='Change of IC' && objPayment.nm_PaymentStatus__c=='Payment Made'){ 
                 nm_Payment__c objPayment1 = [select id, nm_PaymentStatus__c from nm_Payment__c where id =: strPaymentId];
                 objPayment1.nm_PaymentStatus__c = 'Payment Approved';       
                 update objPayment1 ;   
            }
            else if(objPayment.nm_PaymentType__c.contains('Additional Charge') && objPayment.nm_PaymentStatus__c=='Payment Made')
            {
                nm_Payment__c objPayment1 = [select id,nm_OpportunityNew__r.AccountId,nm_OpportunityNew__c, nm_PaymentStatus__c from nm_Payment__c where id =: strPaymentId];
                objPayment1.nm_PaymentStatus__c = 'Payment Approved'; 
                update objPayment1 ;    
            }
            // else if(objPayment.nm_PaymentType__c=='Career Service' && objPayment.nm_PaymentStatus__c=='Payment Made'){ 
            //     nm_Payment__c objPayment1 = [select id, nm_PaymentStatus__c,CareerServiceProgram__c from nm_Payment__c where id =: strPaymentId];
            //     objPayment1.nm_PaymentStatus__c = 'Payment Approved';       
            //     update objPayment1;   
            //     // UpdateCareerServiceStage(objPayment1);
            // }
            else{
                objPayment.nm_PaymentStatus__c = 'Payment Approved';       
                update objPayment;   
            }
           
        }       
    }

    // public static void UpdateCareerServiceStage(nm_Payment__c objPayment) {
    //     if(objPayment != null && objPayment.CareerServiceProgram__c != null) {
    //         String CSProgramId = objPayment.CareerServiceProgram__c;
    //         try {
    //             Career_Service_Program__c objCSProgram = new Career_Service_Program__c(id = CSProgramId);
    //             objCSProgram.Stage__c = 'Payment Done';
    //             update objCSProgram;
    //         } catch (Exception e) {
    //             System.debug('Error -->'+e.getMessage());
    //         }
    //     }
    // }
    
      //This method will update Validity Count on account as well as the change of payment status.
    webservice static void ApprovePaymnetWhenItIsAValidationExtension(String paymentId)
    {
        list<nm_Payment__c> forLateFeePaymnetsList = [select id,nm_PaymentStatus__c,Validity_Extension__r.Related_Account__c from nm_Payment__c where id=:paymentId];
        Date d = date.today();
        set<id> accountIdToUpdate = new set<id>();
        String validityMonth = System.Label.ValidityMonth;
        String validityYear = System.Label.validityYear;
        if(forLateFeePaymnetsList!=null && forLateFeePaymnetsList.size()>0)
        {
            for(nm_Payment__c paymentIterate :forLateFeePaymnetsList)
            {
                paymentIterate.nm_PaymentStatus__c = 'Payment Approved';
                accountIdToUpdate.add(paymentIterate.Validity_Extension__r.Related_Account__c);
                update paymentIterate;
            }
            System.debug('AccountIdToUpdate---->'+accountIdToUpdate);
            list<Account> lstAccount = [select id,Validity_Month__c,Validity_Extension_Count__c,Validity_Year__c,Extend_Validity_Upto_Year__c from Account where id in:accountIdToUpdate];
            System.debug('Value of validity extension---->'+lstAccount);
            for(Account acc:lstAccount)
            {
                System.debug('acc.Validity_Extension_Count__c,Extend_Validity_upto_Month__c before update--->'+acc.Validity_Extension_Count__c);
                
                if(validityMonth!='null'&& validityYear!='null')
                {
                    acc.Extend_Validity_Upto_Year__c = integer.valueOF(validityYear);
                    acc.Extend_Validity_upto_Month__c = validityMonth;
                    acc.Extended_Validity_For_This_Session__c = true;                   
                }
                else if(d.month() >=6 && d.month()<=12)
                {
                   acc.Extend_Validity_upto_Month__c = 'December';
                   if((acc.Validity_Month__c == 'June' && acc.Extended_Validity_For_This_Session__c &&  (acc.Validity_Extension_Count__c==1 || acc.Validity_Extension_Count__c==0)) || (acc.Validity_Month__c == 'December'))
                    {
                        acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c)+1;
                    }
                    else
                    {
                      acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c);
                    }  
                   acc.Extended_Validity_For_This_Session__c = true;
                }
                else if(d.month() >=1 && d.month()<=6)
                {
                    acc.Extend_Validity_upto_Month__c = 'June';
                    
                    if((acc.Validity_Month__c == 'June' && (!acc.Extended_Validity_For_This_Session__c||acc.Extended_Validity_For_This_Session__c) && (acc.Validity_Extension_Count__c==1 || acc.Validity_Extension_Count__c==0)) || (acc.Validity_Month__c == 'December'))
                    {
                        acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c)+1;
                    }
                    else
                    {
                      acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c);
                    }  
                   acc.Extended_Validity_For_This_Session__c = true;
                }
                 acc.Validity_Extension_Count__c = acc.Validity_Extension_Count__c + 1;
                
                update acc;
            }
        }
     }
    
    /*    webservice static void ApprovePaymnetWhenItIsAValidationExtension(String paymentId)
    {
        list<nm_Payment__c> forLateFeePaymnetsList = [select id,nm_PaymentStatus__c,Validity_Extension__r.Related_Account__c from nm_Payment__c where id=:paymentId];
        Date d = date.today();
        set<id> accountIdToUpdate = new set<id>();
        if(forLateFeePaymnetsList!=null && forLateFeePaymnetsList.size()>0)
        {
            for(nm_Payment__c paymentIterate :forLateFeePaymnetsList)
            {
                paymentIterate.nm_PaymentStatus__c = 'Payment Approved';
                accountIdToUpdate.add(paymentIterate.Validity_Extension__r.Related_Account__c);
                update paymentIterate;
            }
            System.debug('AccountIdToUpdate---->'+accountIdToUpdate);
            list<Account> lstAccount = [select id,Validity_Month__c,Validity_Extension_Count__c,Validity_Year__c,Extend_Validity_Upto_Year__c from Account where id in:accountIdToUpdate];
            System.debug('Value of validity extension---->'+lstAccount);
            for(Account acc:lstAccount)
            {
                System.debug('acc.Validity_Extension_Count__c,Extend_Validity_upto_Month__c before update--->'+acc.Validity_Extension_Count__c);
                
                if(d.month() >=6 && d.month()<=12)
                {
                   acc.Extend_Validity_upto_Month__c = 'December';
                   if((acc.Validity_Month__c == 'June' && acc.Extended_Validity_For_This_Session__c &&  (acc.Validity_Extension_Count__c==1 || acc.Validity_Extension_Count__c==0)) || (acc.Validity_Month__c == 'December'))
                    {
                        acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c)+1;
                    }
                    else
                    {
                      acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c);
                    }  
                   acc.Extended_Validity_For_This_Session__c = true;
                }
                else if(d.month() >=1 && d.month()<=6)
                {
                    acc.Extend_Validity_upto_Month__c = 'June';
                    
                    if((acc.Validity_Month__c == 'June' && (!acc.Extended_Validity_For_This_Session__c||acc.Extended_Validity_For_This_Session__c) && (acc.Validity_Extension_Count__c==1 || acc.Validity_Extension_Count__c==0)) || (acc.Validity_Month__c == 'December'))
                    {
                        acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c)+1;
                    }
                    else
                    {
                      acc.Extend_Validity_Upto_Year__c =integer.valueOF(acc.Validity_Year__c);
                    }  
                   acc.Extended_Validity_For_This_Session__c = true;
                }
                 acc.Validity_Extension_Count__c = acc.Validity_Extension_Count__c + 1;
                
                update acc;
            }
        }
     }*/
     /*webservice static void ApprovePaymnetWhenItIsAValidationExtension(String paymentId)
    {
        list<nm_Payment__c> ValidityPaymentList = [select id,nm_PaymentStatus__c,Validity_Extension__r.Related_Account__c from nm_Payment__c where id=:paymentId];
        
        Date datoday = date.today();
        Date ValidityExpiryDate =  Date.today().addDays(180);
        Integer month = ValidityExpiryDate.month();
        Integer year  = ValidityExpiryDate.year();
        set<id> accountIdToUpdate = new set<id>();
        Map<Integer,String> MonthIntegervsString = new Map<Integer,String>();
        
        if( month!=null && month>0)
        {
            MonthIntegervsString.put(01,'January');
            MonthIntegervsString.put(02,'February');
            MonthIntegervsString.put(03,'March');
            MonthIntegervsString.put(04,'April');
            MonthIntegervsString.put(05,'May');
            MonthIntegervsString.put(06,'June');
            MonthIntegervsString.put(07,'July');
            MonthIntegervsString.put(08,'August');
            MonthIntegervsString.put(09,'September');
            MonthIntegervsString.put(10,'October');
            MonthIntegervsString.put(11,'November');
            MonthIntegervsString.put(12,'December');
        }
         
        if(ValidityPaymentList!=null && ValidityPaymentList.size()>0)
        {
            for(nm_Payment__c paymentIterate :ValidityPaymentList)
            {
                paymentIterate.nm_PaymentStatus__c = 'Payment Approved';
                accountIdToUpdate.add(paymentIterate.Validity_Extension__r.Related_Account__c);
                update paymentIterate;
            }
            System.debug('AccountIdToUpdate---->'+accountIdToUpdate);
            list<Account> lstAccount = [select id,Validity_Month__c,Validity_Extension_Count__c,
                                        Validity_Year__c,Extend_Validity_Upto_Year__c
                                        from Account where id in:accountIdToUpdate];
            System.debug('Value of validity extension---->'+lstAccount);
            for(Account acc:lstAccount)
            {
                System.debug('acc.Validity_Extension_Count__c,Extend_Validity_upto_Month__c before update--->'+acc.Validity_Extension_Count__c);
                
                acc.Extend_Validity_upto_Month__c = MonthIntegervsString.get(month);
                acc.Extend_Validity_Upto_Year__c = year;
                acc.Validity_Extension_Count__c = acc.Validity_Extension_Count__c + 1;
                acc.Extended_Validity_For_This_Session__c = true;
                
                update acc;
            }
        }
     }*/
    //this method will update RegistrationPayments and Update IC of Accound and student Program.
    webService static void ApproveReRegistrationAdmissionPayment(String strPaymentId) 
    {
        nm_Payment__c objUpdateRegistrationPaymnets=[select id, CreatedDate, nm_ModeOfPayment__c,nm_TransactionDate__c, nm_OpportunityNew__r.StageName,nm_OpportunityNew__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_StudentProgram__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where  nm_PaymentStatus__c='Payment Made' and id=:strPaymentId];
        
        if(objUpdateRegistrationPaymnets !=null && objUpdateRegistrationPaymnets.id !=null)
        {
            objUpdateRegistrationPaymnets.nm_PaymentStatus__c='Payment Approved';
            update objUpdateRegistrationPaymnets;   
        } 
    }
}