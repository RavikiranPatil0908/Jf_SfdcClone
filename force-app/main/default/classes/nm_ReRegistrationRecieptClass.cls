/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
**/
// This controller class made for component nmReRegistrationReciept
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        09-April-2014     Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------
public without sharing class nm_ReRegistrationRecieptClass 
{
        //defined to get payment id
        public string strPaymentRequestId {get; set;}
        //defined to use this object to get data in E-mail templete
        public nm_Payment__c objPaymentVar {get;set;}
        public List<nm_Payment__c > listpayment;
        //defined to use as variable name in attachment in E-mail templete 
        public string strVariable {get; set;}
                        
        public nm_ReRegistrationRecieptClass ()
        {
            strPaymentRequestId = ApexPages.currentPage().getParameters().get('id');
            System.debug('&&&'+strPaymentRequestId );
        }
        //Object of Payment with details
        public nm_Payment__c objPayment
        {
            get
            {
                List<aggregateResult> results = [select nm_OpportunityNew__r.Account.id,
                                             max(CreatedDate) Date
                                             from nm_Payment__c
                                             where nm_OpportunityNew__r.Account.id =: strPaymentRequestId
                                             group by nm_OpportunityNew__r.Account.id limit 1];
                                             
                System.debug('@@@'+results);
                datetime dtCreatedDate = (datetime)results[0].get('Date');
                
                listpayment = new List<nm_Payment__c >();   
                nm_Payment__c objPayment1;
                listPayment  = [Select id, nm_OpportunityNew__r.Account.nm_StudentNo__c,
                                nm_OpportunityNew__r.Account.name,
                                nm_OpportunityNew__r.Account.nm_Centers__r.Name,
                                nm_OpportunityNew__r.nm_Program__r.name,
                                nm_TransactionID__c, createdDate, nm_ModeOfPayment__c, nm_RefNo__c, nm_Amount__c, nm_PaymentType__c
                                From nm_Payment__c 
                                where
                                createdDate =: dtCreatedDate AND
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
}