/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
**/
// This controller class made for component nmAdmissionReciept
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        09-April-2014     Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------
public with sharing class nm_AdmissionRecieptClass
{
        //defined to get payment id
        public string strPaymentRequestId {get; set;}
        //defined to use this object to get data in E-mail templete
        public nm_Payment__c objPaymentVar {get;set;}
        public List<nm_Payment__c > listpayment;
         public list<WrapperPayment> lstWrapperPayment{get;set;}
        //defined to use as variable name in attachment in E-mail templete
        public string strVariable {get; set;}
        public boolean paymentmode{get;set;}
        public boolean paymentDD{get;set;}
        public boolean paymentChalana{get;set;}
                        
        public nm_AdmissionRecieptClass()
        {
             lstWrapperPayment = new list<WrapperPayment>();
             strPaymentRequestId = ApexPages.currentPage().getParameters().get('id');
             List<nm_Payment__c > listpaymentdsplay = new List<nm_Payment__c >(); 
             listpaymentdsplay=[Select id,nm_ActualPaymentAmmount__c,nm_DemandDraftNumber__c,nm_TransactionDate__c,nm_ModeOfPayment__c,nm_RefNo__c,nm_TransactionID__c,nm_PaymentType__c
                                from nm_Payment__c
                                where nm_PaymentStatus__c='Payment Made' AND nm_PaymentType__c='Admission'];
             if(listpaymentdsplay.size()>0)
             {
                for(nm_Payment__c objPayment:listpaymentdsplay)
                {
                    if(objPayment.nm_ModeOfPayment__c=='Online')
                    {
                           paymentmode=true;
                           WrapperPayment objWrapper=new WrapperPayment(objPayment.nm_TransactionID__c,objPayment.nm_TransactionDate__c,objPayment.nm_ModeOfPayment__c,objPayment.nm_RefNo__c,objPayment.nm_ActualPaymentAmmount__c);
                           lstWrapperPayment.add(objWrapper);
                    }
                    if(objPayment.nm_ModeOfPayment__c =='Demand Draft'){
                           paymentDD=true;
                           WrapperPayment objWrapper=new WrapperPayment(objPayment.nm_DemandDraftNumber__c,objPayment.nm_TransactionDate__c,objPayment.nm_ModeOfPayment__c,objPayment.nm_RefNo__c,objPayment.nm_ActualPaymentAmmount__c);
                           lstWrapperPayment.add(objWrapper);
                    }
                    if(objPayment.nm_ModeOfPayment__c =='Chalan'){
                           paymentChalana=true;
                           WrapperPayment objWrapper=new WrapperPayment(objPayment.nm_DemandDraftNumber__c,objPayment.nm_TransactionDate__c,objPayment.nm_ModeOfPayment__c,objPayment.nm_RefNo__c,objPayment.nm_ActualPaymentAmmount__c);
                           lstWrapperPayment.add(objWrapper);
                    }
                }
             }
                                
             
        }
        //Object of Payment with details
        public nm_Payment__c objPayment
        {
            get
            {
                
                listpayment = new List<nm_Payment__c >();   
                nm_Payment__c objPayment1;
                listPayment  = [Select id, nm_OpportunityNew__r.Account.nm_StudentNo__c,
                                nm_OpportunityNew__r.Account.nm_RegistrationNumber__c,
                                nm_OpportunityNew__r.Account.name,
                                nm_OpportunityNew__r.Account.nm_Centers__r.Name,
                                nm_OpportunityNew__r.nm_Program__r.name,
                                nm_TransactionID__c, createdDate, nm_ModeOfPayment__c, nm_RefNo__c, nm_Amount__c, nm_PaymentType__c
                                From nm_Payment__c 
                                where
                                id =: strPaymentRequestId limit 1];
                
                system.debug(listPayment);
                                                
                If(listPayment !=null && listPayment.size()>0)
                {
                    objPayment1 = listPayment[0];
                }                             
               return objPayment1;
            }
            set;
        }
        public Class WrapperPayment
        {
            public string TransactionId{get;set;}
            public Date TransactionDate{get;set;}
            public string Mode{get;set;}
            public string RefNo{get;set;}
            public Decimal Amount{get;set;}
            
       
            public WrapperPayment(string TransactionId,Date TransactionDate,string Mode,string RefNo,Decimal Amount)
            {
                this.TransactionId=TransactionId;
                this.TransactionDate=TransactionDate;
                this.Mode=Mode;
                this.RefNo=RefNo;
                this.Amount=Amount;
            }
        }
        
}