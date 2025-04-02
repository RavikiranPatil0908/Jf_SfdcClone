public class ValidityExtensionPaymentController 
{
        public Decimal Amount{get;set;}
        public nm_Payment__c objPayment{get;set;}
        public Validity_Extension__c objValidityExtension{get;set;}
        public string Accountid{get;set;}
        public string StudentNumber{get;set;}
        public string ICValue {get;set;}
        public Account objAccount {get;set;}
        
    public ValidityExtensionPaymentController()
    { 
         objValidityExtension=new Validity_Extension__c();
         accountid= ApexPages.currentPage().getParameters().get('id');
         String amountString = ApexPages.currentPage().getParameters().get('extensionFees');
         ICValue =ApexPages.currentPage().getParameters().get('IC');
          objPayment=new  nm_Payment__c();  
    if(amountString!=null && amountString!='')
     
         {
             
             Amount=Decimal.valueOf(amountString);
             StudentNumber=GetStudentNumber(accountid);
             objAccount =[select id,nm_Centers__r.name,nm_Centers__r.nm_City__c from Account where id=:accountid];
         }
    }
    
    public string GetStudentNumber(string accountid)
        {
              
              
          list<Validity_Extension__c> lstValex=[select id,Student_Number_Of_Account__c,Mobile_Number__c,Related_Account__r.PersonEmail,Related_Account__r.PersonMobilePhone from Validity_Extension__c where Related_Account__c=:accountid];
          System.debug('Validity Extended record--->'+lstValex[0]);
          if(lstValex.size()>0)
          {
              objValidityExtension=lstValex[0];
              return objValidityExtension.Student_Number_Of_Account__c;
          }
          else
          {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Such Type Of Record Found');
              ApexPages.addMessage(myMsg); 
               return null;
          }
          return null;
     
        }
       
       public PageReference MakePayment()
         { 
       
           return MakeOnlinePaymentForExtension(Amount);
          
       
         }
       
       public PageReference MakeOnlinePaymentForExtension(decimal amount)
        {
    
         string transactionId = datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
            +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.random() * 1000 );
            
           nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
           objOnlinePayment.TranTrackid = transactionId ;
           objOnlinePayment.strPaymentType = 'Extension Fee';
           objOnlinePayment.TranAmount = string.valueOf(amount);
           objOnlinePayment.strEmailId = objValidityExtension.Related_Account__r.PersonEmail;
           objOnlinePayment.strMobileNumber = objValidityExtension.Related_Account__r.PersonMobilePhone;
           objOnlinePayment.recordId = accountid;
           
           String billDeskRequestMessage = objOnlinePayment.createtBillDeskRequest();
           list<String> messagePart = billDeskRequestMessage.split('\\|');
           for(integer i=0;i<messagePart.size();i++)
           {
           System.debug('Bill Desk Request Message--->'+messagePart[i]);
           }
           SavePayMentBeforeResponse(transactionId,billDeskRequestMessage);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('msg', billDeskRequestMessage);
            return pgURL;
              
    }
       public void SavePaymentBeforeResponse(String tranId,String billDeskMessage)
       {
            list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
            nm_Payment_Initiated__c objPaymentInitiated = new nm_Payment_Initiated__c();
            objPaymentInitiated.nm_PaymentStatus__c = 'Payment Initiated';
            objPaymentInitiated.nm_ModeOfPayment__c = 'Online';
            objPaymentInitiated.nm_TransactionDate__c = Date.today();
            objPaymentInitiated.nm_Merchant_Track_Id__c = tranId;
            objPaymentInitiated.Gateway_Detailed_Request__c = billDeskMessage;
            objPaymentInitiated.nm_Amount__c = Amount;
            objPaymentInitiated.Validity_Extension__c=objValidityExtension.id;
            lstPaymentToInsert.add(objPaymentInitiated);
            if(lstPaymentToInsert.size()>0 && lstPaymentToInsert!=null)
            {
            
                insert lstPaymentToInsert;
            }
            
        }
       
      public PageReference SaveDD()
      
             {
                 nm_Payment__c objPay= new nm_Payment__c();
                 objPay=objPayment.clone();
                 objPay.nm_PaymentType__c = 'Validity Extension Fee';
                 objPay.nm_PaymentStatus__c = 'Payment Made';
                 objPay.nm_ModeOfPayment__c = 'Demand Draft';
                 objPay.nm_ActualPaymentAmmount__c = Amount;
                 objPay.nm_Amount__c =Amount;
                 System.debug('Validity Extension Id Before Insert'+objValidityExtension.id);
                 objPay.Validity_Extension__c = objValidityExtension.id;   
                 try
                 { 
                 insert objPay; 
                 }
                 catch(Exception e)
                 {
                 System.debug('Error catch--->'+e);
                 }
                 return new pageReference(Label.Site_Url+ 'nmRegistrationThankYou?id=' +objPay.id);    
             }
                
    


   }