/*This Trigger can handle Admission cancel and Registration cancel process.
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0       09-may-2015                   chandu              Initial Version
--------------------------------------------------------------------------------------
*/


trigger CancelAdmission on Account(after update) 
{   
    System.debug('CancelAdmission: Started');
    // if(system.isFuture()) return;
    System.debug('CancelAdmission: Flag = '+checkRecursive.ischeckcanceltrigger);
    if(checkRecursive.ischeckcanceltrigger==true)
    {
        checkRecursive.ischeckcanceltrigger=false;
    }
    else
    {
        return;
    }
    set<id> stid=new set<id>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> oppsIds = new Set<Id>();
    Set<string> leadId = new Set<string>();
    Boolean Installmentdone;
    List<Lead>  reverselead = new list<Lead>();
    List<nmRefund_Payment__c> refund = new List<nmRefund_Payment__c>();
    String strEmailid;
    Boolean Dispatchcreated;
    String AccountStage;
    String typerefund;
   System.debug('CancelAdmission: Trigger.new = '+Trigger.new);
    for(Account ac : Trigger.new)
    {
         if((ac.nm_StudentStatus__c=='Admission Cancelled' || ac.nm_StudentStatus__c=='Registration Cancelled') && (!ac.InActiveTrigger__c) && (ac.nm_StudentStatus__c !=trigger.oldMap.get(ac.id).nm_StudentStatus__c)) 
         {
              AccountStage=ac.nm_StudentStatus__c;
              accountIds.add(ac.Id);
              leadId.add(ac.nm_LeadId__c);
         }
               
    }
    System.debug('CancelAdmission: accountIds = '+accountIds);
    if(accountIds.size()>0)
    {
         //List<Deduction_Amount__c> daupdate = new List<Deduction_Amount__c>();
          List<Opportunity> lstAppOpportuniyties = new List<Opportunity>();
          list<Opportunity> lstUpdate=new list<Opportunity>();
          list<nmRefund_Payment__c> lstRefundpayment=new list<nmRefund_Payment__c>();
          //Commented by Sanket 20-Oct-2015, as it seems useless
          //map<String,Opportunity> mapsemWise=new map<String,Opportunity>();
          lstAppOpportuniyties=[select id,nm_InformationCenters__c,Account.PersonEmail,nm_Allowed_Installment__c,IC__c,
                                nm_Program__r.nm_Type__c,Amount,ChooseProgram__c,StageName,nm_Session__c,nm_Semester__c,nm_StudentSession__c,
                                AccountId,Name, Account.nm_Centers__c,Account.Name, Dispatch_Order_For_Student__c,
                                (select id,nm_ModeOfPayment__c,nm_Amount__c,nm_PaymentType__c,
                                nm_PaymentStatus__c from Opportunities__r where nm_PaymentType__c!='Registration') 
                                from Opportunity where AccountId in: accountIds order by nm_Semester__c asc];
          
          list<Opportunity> lstToUpdate=new list<Opportunity>();
          
          //Commented by Sanket 20-Oct-2015, as it seems useless
          /*
          if(lstAppOpportuniyties.size()>0)
          {
             for(Opportunity objOpp:lstAppOpportuniyties)
             {
                mapsemWise.put(objOpp.nm_Semester__c,objOpp);
             }
          }
         */ 
         
          strEmailid=lstAppOpportuniyties[0].Account.PersonEmail;
          Dispatchcreated=lstAppOpportuniyties[0].Dispatch_Order_For_Student__c;
          System.debug('Dispatchcreated'+Dispatchcreated);
          System.debug('lstAppOpportuniyties[0].Dispatch_Order_For_Student__c'+lstAppOpportuniyties[0].Dispatch_Order_For_Student__c);
      if(lstAppOpportuniyties.size()>0)
      {
            //Commented by Sanket 20-Oct-2015, as it seems useless
            //Opportunity objopp=lstAppOpportuniyties[0];
            String StrSemister=lstAppOpportuniyties[0].nm_Semester__c;
            list<nm_Payment__c> lstPayment=new list<nm_Payment__c>();
 
           //Sem 1
           System.debug('AccountStage '+AccountStage );
           system.debug('lstAppOpportuniyties[0].StageName'+lstAppOpportuniyties[0].StageName);
           
            if((lstAppOpportuniyties[0].StageName=='Closed Won' || lstAppOpportuniyties[0].StageName =='Closed'  ||((lstAppOpportuniyties[0].StageName =='Pending Payment' || lstAppOpportuniyties[0].StageName=='Registration Done') && AccountStage =='Registration Cancelled')))
            {
                //Added by Sanket to create IC share debit entries when Admission is cancelled
                nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                Integer intTotalMountTorefund=0;
                Integer Additionalamount=0;
                String Description =AccountStage ;
                
                String ModeofPaymentSem1;
               
                //Commented and changed by Sanket to ensure refund for multiple semester fees paid: 20-Oct-2015
                //lstToUpdate.add(lstAppOpportuniyties[0]);
                lstToUpdate.addAll(lstAppOpportuniyties);
                integer intLatefees=0;
                Installmentdone = false;
                if(lstToUpdate.size()>0)
                {
                    for(opportunity objOpp:lstToUpdate)
                    {
                        oppsIds.add(objOpp.id);                             
                        
                        for(nm_Payment__c objPayment:objOpp.Opportunities__r)
                        {
                            if(objPayment.nm_PaymentStatus__c=='Payment Made' || objPayment.nm_PaymentStatus__c=='Payment Approved')
                            {
                                if((objPayment.nm_PaymentType__c=='Admission' )                             
                                    &&(objPayment.nm_ModeOfPayment__c!='NEFT - Capital Float' || objPayment.nm_ModeOfPayment__c!='NEFT - Zest'))
                                {
                                     ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                     intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                     System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if(objPayment.nm_PaymentType__c.contains('DownPayment'))
                                {
                                     ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                     intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                     System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }                               
                                if(objPayment.nm_PaymentType__c.contains('Additional Charge'))
                                {
                                     ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                     intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                     System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if (objPayment.nm_PaymentType__c == 'Installment' )
                                {
                                    ModeofPaymentSem1=objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    Installmentdone=true;
                                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if(objPayment.nm_PaymentType__c=='Late Fees' )
                                {
                                    intLatefees+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('intLatefees'+intLatefees);
                                } 
                               
                                
                                //Added by Sanket to debit IC share.
                                if(objPayment.nm_PaymentType__c=='Admission' && objOpp.StageName == 'Closed Won' && (objPayment.nm_PaymentStatus__c=='Payment Made' || objPayment.nm_PaymentStatus__c=='Payment Approved'))
                                {
                                   handler.createICShareDebitEntries(objOpp);
                                } 
                            }
                        }
                        
                    }
                }
                 
                
          List<nmRefund_Payment__c> lstrefund = [Select id ,Type_of_Refund__c from nmRefund_Payment__c where (Type_of_Refund__c='Admission Cancellation' or Type_of_Refund__c='Registration Cancellation') and Opportunity__c =:oppsIds Limit 1];
          if(lstrefund.size()>0)
            {
                stid.add(lstrefund[0].id);
            }
          else
          {
              
          
               if(lstAppOpportuniyties[0].StageName=='Closed Won'){
                    lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,intTotalMountTorefund+intLatefees,Dispatchcreated,AccountStage));
                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                    System.debug('intLatefees'+intLatefees);
               }
               //commented for closed cases
               if(lstAppOpportuniyties[0].StageName=='Closed'){
                    Installmentdone=false;
                    lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage));
                     System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                    System.debug('intLatefees'+intLatefees);
               }
                if(lstAppOpportuniyties[0].StageName=='Pending Payment' && Installmentdone==true){
                    lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage));
                     System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                    System.debug('intLatefees'+intLatefees);
               }
              
               
               // Make Record Of Refund For those student whose admission payment is approve but LateFee Pending
               //only for Registration Cancelled 
                if((lstAppOpportuniyties[0].StageName=='Pending Payment' || lstAppOpportuniyties[0].StageName=='Registration Done')  && AccountStage =='Registration Cancelled')
                {
                    lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage));
               }
          }  
            }
            
           if(lstToUpdate.size()>0)
           {
               for(Opportunity objOppUpdat:lstToUpdate)
               {
                    if(objOppUpdat.StageName=='Closed' || ((objOppUpdat.StageName=='Pending Payment' ) || (objOppUpdat.StageName=='Registration Done' ) && AccountStage =='Registration Cancelled'))
                    {
                       objOppUpdat.StageName='Registration Cancelled';                    
                    }
                    else
                    {
                         objOppUpdat.StageName='Admission Cancelled';                       
                    }
               }
           }   
           update lstToUpdate;
       
            
        }
      if(strEmailid !=null && strEmailid !=''){
          list<lead> objLead=[select id from lead where id=:leadId  and isConverted=true];
           if(objLead.size()>0)
           {
               try{
                       delete objLead;
                  }
                 catch(Exception e)
                 {
                 
                 }
           }
      }
     
        if(lstRefundpayment.size()>0)
        {           
              insert lstRefundpayment;
              for(nmRefund_Payment__c objRfPay:lstRefundpayment)
              {
                  stid.add(objRfPay.id);
              }
              
        }
        if(accountIds.size()>0){
          // CancelFutureHandler.CancelAdmission(accountIds,stid);
         }
          
    }
    
    public nmRefund_Payment__c InsertRefundRecord(Opportunity objOpps,String ModeofPaymentSem1,Integer intTotalMountTorefund,Boolean Dispatchcreated,String AccountStage)
    {
        nmRefund_Payment__c objRefundPayment=new nmRefund_Payment__c();
        objRefundPayment.Total_Refund_Amount__c=intTotalMountTorefund;
        objRefundPayment.nm_Payment_Status__c='Refund Initiated';
         // RP.nm_Amount__c=opp.nm_AmountReceived__c;
        objRefundPayment.Account__c=objOpps.Accountid;
        objRefundPayment.Mode_Of_Payment__c=ModeofPaymentSem1;
        objRefundPayment.Instalment_done__c= Installmentdone;
        objRefundPayment.Study_Kit__c= Dispatchcreated;
        objRefundPayment.nm_Information_Center__c=objOpps.nm_InformationCenters__c;
 
        if(AccountStage!='' && AccountStage!=null)
        {
            objRefundPayment.Type_of_Refund__c = AccountStage =='Admission Cancelled'?'Admission Cancellation':'Registration Cancellation';
        }
        
        objRefundPayment.Opportunity__c = objOpps.id;
        
        return objRefundPayment;
    }
   }