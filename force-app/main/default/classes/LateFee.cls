public class LateFee {
    public boolean Isshow {get;set;}
    public nm_Payment__c objPayment {get;set;}
    public boolean IsShowPaymnetMode{get;set;}
    public boolean boolShow{get;set;}
    public String strPaymentId{get;set;}
    public LateFee(ApexPages.StandardController controller) 
    {
       Isshow = false;
       IsShowPaymnetMode=false;
       boolShow=false;
       strPaymentId=ApexPages.currentPage().getParameters().get('id');
       objPayment =new nm_Payment__c(); 
       if(strPaymentId !=null && strPaymentId !='')
       {
            objPayment =[select id,nm_OpportunityNew__c,nm_OpportunityNew__r.StageName,nm_OpportunityNew__r.Accountid,nm_ModeOfPayment__c,nm_DemandDraftNumber__c,nm_NameoftheBank__c,nm_DemandDraftDate__c,nm_BankLocation__c,nm_DispatchDate__c,nm_Amount__c from nm_Payment__c where id=:strPaymentId ];
             
       }
      
    }
     
  
    public void CheckPaymentPanel()
    {
       if(objPayment.nm_ModeOfPayment__c=='Demand Draft'){
           boolShow=true;
          }
          else
          {
                boolShow=false;
          }
    } 
   public pagereference SavePayment()
   {
       /*system.debug('objPayment.nm_ModeOfPayment__c'+objPayment.nm_ModeOfPayment__c);
       if(objPayment.nm_ModeOfPayment__c==null)
       {
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Mode of Payment.'));
           return null;
       }
       if(objPayment.nm_ModeOfPayment__c=='Demand Draft' && (objPayment.nm_DemandDraftNumber__c==null || objPayment.nm_NameoftheBank__c==null || objPayment.nm_DemandDraftDate__c==null || objPayment.nm_BankLocation__c==null || objPayment.nm_DispatchDate__c==null))
       {
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select fill Payment Details.'));
            return null;
       }
       if(objPayment.nm_OpportunityNew__c !=null && objPayment.nm_ModeOfPayment__c=='Demand Draft'){
               Opportunity objUpdate=[select id,StageName from Opportunity where id=:objPayment.nm_OpportunityNew__c];
               list<nm_Payment__c> lsyPaymnet=[select id from nm_Payment__c where nm_PaymentStatus__c='Pending Late Fees' and nm_PaymentType__c='Late Fees' and id !=:strPaymentId];
               if(objUpdate !=null && objUpdate.id !=null)
               {
                   if(objUpdate.StageName=='Pending Payment' && lsyPaymnet.size()==0){
                        objUpdate.StageName='Payment Made';
                    }
                   
               }
               objPayment.nm_PaymentStatus__c='Payment Made';
               update objUpdate;
               update objPayment;
               pagereference pgf=new pagereference('/'+objUpdate.id);
               return pgf;
           }
       if(objPayment.nm_OpportunityNew__c !=null && objPayment.nm_ModeOfPayment__c !='Demand Draft')
       {
            pagereference pgf2=new pagereference('/apex/nmLateFees?&id='+objPayment.nm_OpportunityNew__r.Accountid);
            return pgf2;
       }*/
      return null;
   }  
}