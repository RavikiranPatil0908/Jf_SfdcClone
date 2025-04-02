public without sharing class Payment_Invoice_Controller{

    public String paymentId {get;set;}
    public String opportunityId {get;set;}
    public String AccountId {get;set;}
    public Opportunity objOpportunity {get;set;}
    public decimal productAmount {get;set;}
    public String productName {get;set;}
    public decimal downPaymentAmount {get;set;}
    public decimal EMIAmount {get;set;}
    public String studentNo {get;set;}
    public String Tenure {get;set;}
    public String studentName {get;set;}
    public String InvoiceNumber {get;set;}
    public decimal loanAmount {get;set;}
    public decimal DP_EMI_ProcessingFee {get;set;}
    public decimal processingFee {get;set;}
    public decimal registrationAmount {get;set;}
    public decimal LateFeeAmount {get;set;}
    
    public Payment_Invoice_Controller(){
        paymentId = '';
        objOpportunity = new Opportunity();
        productAmount = 0;
        productName = '';
        downPaymentAmount = 0;
        EMIAmount = 0;
        LateFeeAmount = 0;
        studentNo = '';
        Tenure = '';
        studentName = '';
        InvoiceNumber = '';
        loanAmount = 0;
        opportunityId = '';
        registrationAmount = 0;
        DP_EMI_ProcessingFee = 0;
        AccountId = '';
        
        paymentId = ApexPages.currentPage().getParameters().get('paymentId');
        
        
        if(paymentId  !=null && paymentId  !=''){
            GetPaymentDetails();
        }
    }
    
    public void GetPaymentDetails(){
        String paymentSql = getQueryAllFieldSql('nm_Payment__c' , ' id =:paymentId ' );
        List<nm_Payment__c> lstPayment = DataBase.query(paymentSql);
        
        if(lstPayment.size()>0){
            for(nm_Payment__c objPayment : lstPayment){
                opportunityId = objPayment.nm_OpportunityNew__c ;
                DP_EMI_ProcessingFee = objPayment.nm_Amount__c;
                InvoiceNumber = objPayment.InvoiceNumber__c;
                productName = objPayment.nm_Installment_Payment_Ref__c.contains('-')? objPayment.nm_Installment_Payment_Ref__c.split('-')[1] : objPayment.nm_Installment_Payment_Ref__c;
                if(opportunityId !=null && opportunityId != ''){
                    QueryOpportunityData();
                }
            }
        }else{
            System.debug('Transaction Failed:No Payment record found with given PaymentId ID:'+paymentId);
        }
    }
    
    public void QueryOpportunityData(){
        String query = getQueryAllFieldSql('Opportunity',' id =:opportunityId');
        String accountQueryString = getQueryAllFieldSql('Account',' id=:AccountId and nm_Centers__c != null');
        
        System.debug('query-->'+query);
        List<Opportunity> lstOpps = (List<Opportunity>) DataBase.query(query);
        if(lstOpps.size()>0){
            objOpportunity = lstOpps[0]; 
            System.debug('opportunity --'+objOpportunity);
            opportunityId = objOpportunity.id;
            AccountId = objOpportunity.AccountId;
            Tenure = objOpportunity.Tenure__c ;
            EMIAmount =  Decimal.valueOf(objOpportunity.EMI_Amount__c );
            loanAmount = Decimal.valueOf(objOpportunity.Loan_Amount__c);
            processingFee = Decimal.valueOf(objOpportunity.Capital_Float_Processing_Fee__c);
            productAmount = objOpportunity.Actual_Amount__c;
            
            List<Account> lstAccount = (List<Account>) DataBase.query(accountQueryString);
            if(lstAccount.size() > 0){
                studentName = lstAccount[0].Salutation +' ' +lstAccount[0].FirstName +' '+lstAccount[0].LastName;
                studentNo = lstAccount[0].nm_StudentNo__c != null ? lstAccount[0].nm_StudentNo__c: lstAccount[0].nm_RegistrationNumber__c;
            }
            
            String paymentSql = getQueryAllFieldSql('nm_Payment__c' , ' nm_OpportunityNew__c  =:opportunityId and (nm_PaymentStatus__c =\'Payment Made\' or nm_PaymentStatus__c = \'Payment Approved\')' );
        
            List<nm_Payment__c> lstPayment = DataBase.query(paymentSql);
            
            if(lstPayment.size()>0){
                for(nm_Payment__c objPayment : lstPayment)
                {
                    if(objPayment.nm_PaymentType__c.contains('Registration')){
                        registrationAmount = objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('Late Fee')){
                        LateFeeAmount = objPayment.nm_Amount__c;
                    }    
                }
            }
            
            //as can't take EMI + Processing fee for 3 months Tenure Month 
            if(Tenure.contains('3')){
                downPaymentAmount = (DP_EMI_ProcessingFee + LateFeeAmount ) - (processingFee);    
            }else{
                downPaymentAmount = (DP_EMI_ProcessingFee + LateFeeAmount ) - (processingFee + EMIAmount);
            }
            
            productAmount = productAmount - registrationAmount;
        }
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
}