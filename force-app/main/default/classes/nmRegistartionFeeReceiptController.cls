public without sharing class nmRegistartionFeeReceiptController
{
public string Paymentid {get;set;}
public string objdate{get;set;}
public nm_Payment__c objPayment{get;set;}
public OpportunityLineItem objOppsLineItem {get;set;}

public boolean paymentDD{get;set;}
public boolean paymentChallan{get;set;}
public String RegistrationNum{get;set;}
public String strName{get;set;}
public string DDNo{get;set;}
public string TransId{get;set;}
public string DDDate{get;set;}
public string TransDate{get;set;}
public String Salutation{get;set;}
public String ICName{get;set;}
public String Program{get;set;}
public String strYear{get;set;}
public String bankname{get;set;}
public String locationbank{get;set;}
public String Session{get;set;}
public String currencyInWords {get;set;}
public string RegistrationNo{get;set;}
public string RegistrationName{get;set;}
public string ProgramChangeFee {get;set;}
public decimal Amount{get;set;}
public String ModeOfPayment{get;set;}
public list<nm_Payment__c> listPayment{get;set;}
public list<OpportunityLineItem> lst{get;set;}
currencytowords ob = new currencytowords();
public list<WrapperRegistration> lstWrapperRegistration{get;set;}

public decimal TotalAmount{get;set;}

  public Class WrapperRegistration
        {
            public string RegistrationName{get;set;}                     
            public Decimal Amount{get;set;}
            
       
            public WrapperRegistration(string RegistrationName,Decimal Amount)
            {
                this.RegistrationName=RegistrationName;             
                this.Amount=Amount;
               
            }
        }
        
      
 public nmRegistartionFeeReceiptController() 
    {  
    RegistrationNum='';
            strName='';
            ICName='';
            Program='';
            strYear='';
            Session='';
            TransId=' ';
            TransDate='';
            currencyInWords = '';
            DDDate='';
            DDNo='';
            RegistrationNo='';
            Amount=0;
            TotalAmount=0;
            ModeOfPayment='';
            
            paymentDD=false;
            paymentChallan=false;
           
            ProgramChangeFee ='';
            
            lstWrapperRegistration =new list<WrapperRegistration>();
            
            listPayment = new List<nm_Payment__c>();
    Paymentid = apexpages.currentpage().getparameters().get('id');
        objdate = apexpages.currentpage().getparameters().get('date');
        
   System.debug('<----------Paymentid-------------->'+Paymentid);
    System.debug('<----------objdate -------------->'+objdate );
   
      
             if(Paymentid != null)
        {
        System.debug('<---------------------listPayment'+listPayment.size());  
                nm_Payment__c objpayment = [select id,nm_Amount__c,nm_SAPDDDate__c,nm_Merchant_Track_Id__c,nm_ModeOfPayment__c,Receipt_Number__c,nm_SAPTransactionDate__c,nm_DemandDraftDate__c,nm_OpportunityNew__c,nm_BankLocation__c,nm_NameoftheBank__c,nm_ActualPaymentAmmount__c,nm_Lead__c,nm_DemandDraftNumber__c,nm_PaymentType__c,nm_PaymentStatus__c,nm_RefNo__c,nm_TransactionDate__c,nm_TransactionID__c
                                   from nm_Payment__c
                                   where id=:Paymentid and nm_PaymentStatus__c ='Payment Approved' limit 1];
               listPayment.add(objpayment);
    System.debug('<--------------Size of ListPayment------------>'+listPayment.size());
               if(listPayment.size()>0)
               {   
                if(objPayment.nm_Amount__c != null){
                Amount= objPayment.nm_Amount__c;
                ModeOfPayment=objPayment.nm_ModeOfPayment__c;
                RegistrationNo=objPayment.Receipt_Number__c;
                 if(objPayment.nm_DemandDraftDate__c!=null)
                {
                   DDNo=objPayment.nm_DemandDraftNumber__c;
                   DDDate=string.valueOf(objPayment.nm_SAPDDDate__c);
                   bankname=objPayment.nm_NameoftheBank__c;
                   locationbank=objPayment.nm_BankLocation__c;
                 }
                 else
                 {
                 DDDate=string.valueOf(objPayment.nm_SAPTransactionDate__c);
                 DDNo=objPayment.nm_Merchant_Track_Id__c;
                 }
               }
                  
                
                     //currencyInWords = ob.convert((long)Math.floor(TotalAmount))+' only';
                         Opportunity objopp=[select id, nm_Semester__c,Academic_Year__c,Account.Salutation, Account.nm_StudentNo__c,Sum__c,Amount,Account.Name, nm_ModeOfPayment__c,Account.nm_Centers__r.nm_LearningCenter__r.Name,nm_Year__c,nm_Session__c,nm_Program__r.Fee_Program__c
                            from Opportunity where id=:listPayment[0].nm_OpportunityNew__c];
                           Set<id> oppsId = new set<id>();
                           oppsId.add(objopp.id);
                       
                         if(objopp !=null)
                         {
                             if(objopp.Account.nm_StudentNo__c !=null)
                             {
                                 RegistrationNum=objopp.Account.nm_StudentNo__c;
                             }
                             if(objopp.Account.Name !=null)
                             {
                                strName=objopp.Account.Name;
                             }
                             if(objopp.Account.nm_Centers__r.nm_LearningCenter__r.Name !=null)
                             {
                                ICName=objopp.Account.nm_Centers__r.nm_LearningCenter__r.Name;
                             }
                             if(objopp.Academic_Year__c!=null)
                             {
                                strYear=String.ValueOf(objopp.Academic_Year__c);
                             }
                             if(objopp.nm_Semester__c !=null)
                             {
                                Session='Semester'+objopp.nm_Semester__c;
                             }
                             if(objopp.nm_Program__r.Fee_Program__c !=null)
                             {
                                Program=objopp.nm_Program__r.Fee_Program__c;
                             }
                               if(objopp.Account.Salutation !=null)
                             {
                                Salutation=objopp.Account.Salutation;
                             }
                            
                            if(objopp.Sum__c!=null)
                             {
                               TotalAmount= objopp.Sum__c;
                         // currencyInWords = ob.convert((long)Math.floor(TotalAmount))+' only';
                             }
                                                    
                         list<OpportunityLineItem> lst=[select product2.id,ProgramName2__c,Product_Name__c,UnitPrice,Quantity,OpportunityId from OpportunityLineItem where OpportunityId in:oppsId and ProgramName2__c='Admission Processing Fee'];
                         System.debug('<-------------- lst------------>'+ lst.size());
                         if(lst.size()>0)
                         {
                         objOppsLineItem = lst[0];
                            if( objOppsLineItem.ProgramName2__c!=null){
                           
                               
                            WrapperRegistration objWrapper=new WrapperRegistration(objOppsLineItem.ProgramName2__c,objOppsLineItem.UnitPrice);
                                lstWrapperRegistration.add(objWrapper);
                                currencyInWords = ('Rupees '+ob.convert((long)Math.floor(objOppsLineItem.UnitPrice))+' only').toUpperCase();
                            }
                            
                          }
                           
                           
                         
                         
                         }
                   }
        }
      }
}