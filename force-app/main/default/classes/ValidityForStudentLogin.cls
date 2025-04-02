public class ValidityForStudentLogin
{
    
    public String checkValidityForPG(String currentSessionMonth,integer currentSessionYear,integer accountBatchYear,String accountBatchMonth,String feePaidForSemester)
    {
             if(accountBatchMonth == 'Jan')
                {
                        System.debug('Entered accountBatchMonthPGJan');
                        if((currentSessionMonth == 'January'|| currentSessionMonth =='July') &&currentSessionYear<=accountBatchYear+2 &&  (feePaidForSemester=='2' ||feePaidForSemester=='1' || feePaidForSemester=='3'))
                        {
                             return 'RedirectPG';
                        } 
                        else if(currentSessionMonth == 'January' &&  currentSessionYear <=accountBatchYear+3 &&  (feePaidForSemester=='2' || feePaidForSemester=='3'))
                        {
                             return 'RedirectPG';
                        }
                        else if(currentSessionMonth =='July'  &&  currentSessionYear <= accountBatchYear+3 && feePaidForSemester =='3')
                        {
                             return 'RedirectPG';
                        }
                        else
                        {
                            return 'RedirectPG';
                        }
                   
                 }
                else if(accountBatchMonth == 'Jul')
                 {
                        System.debug('Entered accountBatchMonthPGJuly');
                        if(currentSessionMonth =='July' && currentSessionYear<=accountBatchYear+2  && (feePaidForSemester=='1'||feePaidForSemester=='2'||feePaidForSemester=='3'))
                        {
                        
                            return 'RedirectPG';
                        }
                        else if(currentSessionMonth =='January' && currentSessionYear<=accountBatchYear+3  && (feePaidForSemester=='1'||feePaidForSemester=='2'||feePaidForSemester=='3'))  
                        {
                            return 'RedirectPG';
                        }
                       else if(currentSessionMonth =='July' && currentSessionYear<=accountBatchYear+3  && (feePaidForSemester=='2'||feePaidForSemester=='3'))
                       {
                           return 'RedirectPG';
                       } 
                       else if(currentSessionMonth=='January'  && currentSessionYear== accountBatchYear+4 && feePaidForSemester=='3')
                       {
                       
                           return 'RedirectPG';
                       }
                       else
                       {
                       
                           return 'RedirectPG';
                       }
        
                  }
           
       
        return null;
    
    }
    public String checkValidityForPGforLogin(String currentSessionMonth,integer currentSessionYear,integer ValidityExpireYear,String ValidityExpireMonth,String LateralSem)
    {
       Date calendarDate;
        Date expiryDate;
        calendarDate= ConvertDate(currentSessionMonth.left(3),currentSessionYear);
        expiryDate = ConvertDate(ValidityExpireMonth,ValidityExpireYear);
        system.debug('expiryDate--->'+expiryDate);
        system.debug('calendarDate--->'+calendarDate);
        
        if(expiryDate > calendarDate)
        {
             return 'RedirectPG';
        }else{
            return null;
        }
    
    
           /*  if(accountBatchMonth == 'Jan')
                {
                        System.debug('Entered accountBatchMonthPGJan');
                        if(currentSessionMonth == 'July' && currentSessionYear <= ValidityExpireYear && LateralSem !='2' ) 
                        {
                             return 'RedirectPG';
                        } 
                        else if(currentSessionMonth == 'January'  && currentSessionYear <= ValidityExpireYear)
                        {
                             return 'RedirectPG';
                        }
                       else if (currentSessionMonth == 'July' && currentSessionYear < ValidityExpireYear && LateralSem =='2' )
                       {                       
                            return 'RedirectPG';
                       }
                       else 
                       {
                            return 'RedirectPG';
                       }
                   
                 }
                else if(accountBatchMonth == 'Jul')
                 {
                        System.debug('Entered accountBatchMonthPGJuly');
                        if((currentSessionMonth == 'January') && currentSessionYear<=ValidityExpireYear)
                        {
                        
                            return 'RedirectPG';
                        }
                      
                       else if (currentSessionMonth == 'July' && currentSessionYear < ValidityExpireYear && LateralSem !='2')
                        {
                        
                            return 'RedirectPG';
                        }
                        else if (currentSessionMonth == 'July' && currentSessionYear <=ValidityExpireYear && LateralSem =='2')
                        {
                        
                            return 'RedirectPG';
                        }
                      else
                       {
                       
                           return 'RedirectPG';
                       }
        
                  }
           */
       
        return null;
    
    }
    
    public String checkValidityForDiploma(String currentSessionMonth,integer currentSessionYear,integer accountBatchYear,String accountBatchMonth,String feePaidForSemester)
    {
      
                if(accountBatchMonth =='Jan')
                {
                       if((currentSessionMonth =='January'||currentSessionMonth=='July') && currentSessionYear<=accountBatchYear+1 && feePaidForSemester=='1')
                        {
                        
                            return 'RedirectDiploma';
                        }
                        else
                        {
                        
                            return 'RedirectPG';
                        }
                }
                else if(accountBatchMonth =='Jul')
                {
                
                        if(currentSessionMonth =='July' && currentSessionYear<=accountBatchYear+1 && feePaidForSemester=='1')
                        {
                            return 'RedirectDiploma';
                        
                        }
                        else if(currentSessionMonth =='January' && currentSessionYear<=accountBatchYear+2 && feePaidForSemester=='1')
                        {
                            
                            return 'RedirectDiploma';
                        }
                        else
                        {
                            return 'RedirectDiploma';
                        }
                
                }
          
        
        return null;
    
    }
    public Date ConvertDate (String Month,Integer Year)
{
     Date today;
     Date expiry = system.Today();
     Integer month_int; 
     Map<String,Integer> MonthInStringvsInteger = new Map<String,Integer>();
     
       if( Month !=null && Month!='')
        {
            MonthInStringvsInteger.put('Jan',01);
            MonthInStringvsInteger.put('Feb',02);
            MonthInStringvsInteger.put('Mar',03);
            MonthInStringvsInteger.put('Apr',04);
            MonthInStringvsInteger.put('May',05);
            MonthInStringvsInteger.put('Jun',06);
            MonthInStringvsInteger.put('Jul',07);
            MonthInStringvsInteger.put('Aug',08);
            MonthInStringvsInteger.put('Sep',09);
            MonthInStringvsInteger.put('Oct',10);
            MonthInStringvsInteger.put('Nov',11);
            MonthInStringvsInteger.put('Dec',12);
        }   
        
        
        if(!MonthInStringvsInteger.IsEmpty() && MonthInStringvsInteger.get(Month)!=null)
        {
            month_int = MonthInStringvsInteger.get(Month);
        }
        
        if(month_int!=null && Year!=null )
        {
            expiry = date.newinstance(Year,month_int,01);
        }       
        
        return expiry;
    
}
    public string makePaymentAfterResponseForValidityExtension(String transId,String merchantId,String onlinePaymentId,String gateWayResponse,String onlineResponseError,decimal amountToBeInserted,String detailedResponse,String idForInsert)
    {
        list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
        
            system.debug('-----------merchantId------------'+merchantId);
        
            lstPaymentToUpdate = [Select Id, nm_PaymentStatus__c, nm_Lead__c, nm_OpportunityNew__c, nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: merchantId];
        
            system.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
            for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate)
            {
                objpay.nm_PaymentStatus__c = gateWayResponse.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
                objpay.nm_TransactionID__c = transId;
                objpay.Online_Payment_Id__c = onlinePaymentId;
                objpay.nm_PaymentGatewayResponse__c = gateWayResponse;
                objpay.Online_Response_Error__c = onlineResponseError;
                objpay.nm_Error_Code__c = onlineResponseError;
                objpay.Gateway_Detailed_Response__c = detailedResponse;
            }
            
            if(lstPaymentToUpdate.size() > 0 )
            {
                update lstPaymentToUpdate;
            }
            
        list<nm_Payment__c> onlinePaymentToInsert = new list<nm_Payment__c>();
        nm_Payment__c objPayment = new nm_Payment__c();
        objPayment.nm_PaymentStatus__c = gateWayResponse.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c = Date.today();
        objPayment.nm_TransactionID__c = transId;
        objPayment.nm_Merchant_Track_Id__c = merchantId;
        objPayment.Online_Payment_Id__c = onlinePaymentId;
        objPayment.nm_PaymentGatewayResponse__c = gateWayResponse;
        objPayment.Online_Response_Error__c = onlineResponseError;
        objPayment.nm_Amount__c = amountToBeInserted;
         objPayment.nm_ActualPaymentAmmount__c=amountToBeInserted;
        objPayment.Validity_Extension__c = idForInsert;
        objPayment.nm_PaymentType__c ='Validity Extension Fee';
        onlinePaymentToInsert.add(objPayment);
        if(onlinePaymentToInsert.size()>0 && onlinePaymentToInsert!=null)
        {
            insert onlinePaymentToInsert;
        }
        return onlinePaymentToInsert[0].id;
    }
   


}