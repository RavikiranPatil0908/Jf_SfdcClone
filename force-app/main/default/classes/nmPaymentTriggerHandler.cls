/**
 * @File Name          : nmPaymentTriggerHandler.cls
 * @Description        : 
 * @Author             : phalguni
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 15-01-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/2/2020   phalguni     Initial Version
**/
// This Class is used as a trigger handler for trigger on Payment
// --------------------------------------------------------------------------------------------- 
// Version#     Date              Author                 Description
// ---------------------------------------------------------------------------------------------
// 1.0       18-April-2014      Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------
public without sharing class nmPaymentTriggerHandler 
{   
    ProductHelper productHelper = new ProductHelper();
    public void BeforeInsert(list<nm_Payment__c> triggerNew) {
        // changeCurrencyISO(triggerNew);
        checkForDuplicateUTR(triggerNew, new map<id,nm_Payment__c>(), 'INSERT');
     }
    
     

    public void afterInsert(list<nm_Payment__c> triggerNew, map<id,nm_Payment__c> triggerOldMap)
    {  
        UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(triggerNew,triggerOldMap,true);
        //Method to insert opportunity stage
        UpdateOpportunityStage(triggerNew,triggerOldMap, false);
        
        GenerateRegistrationReceiptNo(triggerNew,triggerOldMap,false);
        
        calculateAmountReceived(triggerNew,triggerOldMap);
        
     //   updatePaymentTransactionModeInOpp(triggerNew,false);
        updatePaymentStatus(triggerNew);
    }
   
    public void afterUpdate(list<nm_Payment__c> triggerNew, map<id,nm_Payment__c> triggerOldMap)
    {  
        UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(triggerNew,triggerOldMap,false);
        
        //Method to update opportunity stage
        UpdateOpportunityStage(triggerNew,triggerOldMap, true);
  
       // UpdateAccountIncaseofCancellationWithLatefees(triggerNew,triggerOldMap);
        
        GenerateRegistrationReceiptNo(triggerNew,triggerOldMap,true);
        
        calculateAmountReceived(triggerNew,triggerOldMap);   
        
        UpdateCareerServiceStage(triggerNew,triggerOldMap);

        UpdateCourseraStatus(triggerNew,triggerOldMap);

       // updatePaymentTransactionModeInOpp(triggerNew,false);

       // calculateBankCharges(triggerNew,'UPDATE');
        ValidityextensionApproval(triggerNew,triggerOldMap);

        // to update center validity based on the payment approval
        UpdateCenterValidity(triggerNew,triggerOldMap);

        // to update center IC name
        UpdateCenterRequest(triggerNew,triggerOldMap);

        //to update opportunity and account status if payment disApproved
        updateAccountAndOpportunityStage(triggerNew,triggerOldMap);

        //to sync/unsync student from portal
        StudentPortalLoginHandler.StudentStatusChangeFromPayment(triggerNew,triggerOldMap);
    }
    
    public void BeforeUpdate(list<nm_Payment__c> triggerNew, map<id,nm_Payment__c> triggerOldMap){
        checkForDuplicateUTR(triggerNew, triggerOldMap, 'UPDATE');
        updateLookupOnConversion(triggerNew,triggerOldMap);
    }
   /* public void afterDelete(list<nm_Payment__c> triggerOld){
        
        calculateAmountReceived(triggerOld,null);  
        updatePaymentTransactionModeInOpp(triggerOld,true); 
      //  calculateBankCharges(triggerOld,'DELETE'); 
    }*/

    // public void changeCurrencyISO(list<nm_Payment__c> lst) {

    //     for(nm_Payment__c objPayment:lst) {
    //         system.debug('objPayment.Form_Id__c --> ' +objPayment.Form_Id__c);
    //         if(objPayment.Form_Id__c == 'INTERNATIONAL_FORM') {
    //             objPayment.CurrencyIsoCode = 'USD';
    //         }
    //     }
    // }

    public void beforeDelete(List<nm_Payment__c> triggerOld) {
        String uId = UserInfo.getUserId();
        System.debug('uId==>' + uId);

        // Check if the current user is in the 'Head Office' role
        Boolean isHeadOfc = [SELECT COUNT() FROM User WHERE Id = :uId AND UserRole.Name = 'Head Office'] > 0;
        System.debug('isHeadOfc==>' + isHeadOfc);

        if (!isHeadOfc) {
            return;
        }

        for (nm_Payment__c ob : triggerOld) {
            System.debug('triggerOld[0].nm_PaymentStatus__c' + ob.nm_PaymentStatus__c);
            if (ob.nm_PaymentStatus__c != 'Pending Extra Fees') {
                System.debug('inside b4Delete');
                ob.addError('Insufficient Rights Can Not Delete');
            }
        }
    }

    public void UpdateOpportunityStage(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment,boolean isUpdate)
    {
        
        if(lstPayment != null && lstPayment.size() > 0)
        {
            //List opportunity to update their stages
            list<Opportunity> lstOpportunityToUpdate = new list<Opportunity>(); 
            if(!isUpdate)  //This code will Run incase of Insert  and also hanlde Manually Inserted records according to Update Stage 
            {
                set<String> setOfOppsId = new set<String>();
                for(nm_Payment__c objPayment : lstPayment)
                {
                  if(objPayment.nm_OpportunityNew__c !=null)
                  {
                    System.debug('Payment Type---->'+objPayment.nm_PaymentType__c);
                    System.debug('Payment Status---->'+objPayment.nm_PaymentStatus__c);
                    // In order to avoid Updation of Opportunity Stage from CLosed won Re-Registration Pending Payment to Payment Made or Pending Payment 
                    if(objPayment.nm_PaymentStatus__c !='Payment Approved')
                    {
                        setOfOppsId.add(objPayment.nm_OpportunityNew__c );  
                    }
                  }
                }
                
                if(setOfOppsId.size()>0)
                {
                    for(String OppsId : setOfOppsId)
                    {
                       // update Opportunity Stage to Pending Payment or Payment Made or Closed or Closed Won Depends On Pending Payment 
                       productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId,'Payment Made', null, null);
                    }
                }
            }else if(isUpdate)  //This code will Run incase of Update
            {
                set<id> setOppid = new set<id>();

                for(nm_Payment__c objPayment : lstPayment)
                {   
                    System.debug('Payment status: -'+objPayment.nm_PaymentStatus__c);
                    System.debug('old payment status '+oldMapPayment.get(objPayment.id).nm_PaymentStatus__c);
                    if(((objPayment.nm_PaymentType__c =='Late Fees' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Waived Off') 
                        
                        || 
                        (objPayment.nm_PaymentType__c =='Late Fees' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved') 
                        
                        || (objPayment.nm_PaymentType__c =='Late Fees' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Made')) 
                        
                       || (objPayment.nm_PaymentType__c.contains('Additional Charge') // checking contains as IC/Program Change Can be Capture in Payment Type 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')

                        || (objPayment.nm_PaymentType__c.contains('Additional Charge') // checking contains as IC/Program Change Can be Capture in Payment Type 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Made')

                        || (objPayment.nm_PaymentType__c.contains('Live Lectures') 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')
                        
                        || (objPayment.nm_Type__c =='Admission' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')
                        
                        || (objPayment.nm_Type__c =='Admission' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Made')
                        
                        || (objPayment.nm_Type__c =='Installment' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')
                        
                        || (objPayment.nm_Type__c =='Installment' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Made')
                        
                        ||(objPayment.nm_Type__c =='Change of IC' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')

                        ||(objPayment.nm_PaymentType__c.contains('Career Service')
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')
                        
                        ||(objPayment.nm_PaymentType__c =='Repeat Term Fee' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved')
                        
                        ||(objPayment.nm_PaymentType__c =='Coursera' 
                        && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c !=objPayment.nm_PaymentStatus__c 
                        && objPayment.nm_PaymentStatus__c=='Payment Approved'))
                    {
                        if(objPayment.nm_OpportunityNew__c != null)
                        {
                            setOppid.add(objPayment.nm_OpportunityNew__c);
                        }
                    } 
                 
                }
 
                if(setOppid.size()>0)
                {
                    Opportunity objOpp = new Opportunity();
                    for(String OppsId : setOppid)
                    {
                        // update Opportunity Stage to Pending Payment or Payment Made or Closed or Closed Won Depends On Pending Payment 
                        objOpp = productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId,'Payment Approved', null, null);
                    }
                    System.debug('Opportunity in Update Payment --->'+objOpp);
                    // do not check ReReg Payment as Program/IC  Change can be Applicable for Fresh Admission Also 
                    if(objOpp !=null )
                    {
                        //it will update Student Program and IC
                       // ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpp);
                    }
                    
                    
                }else // update Opportunity Stage to disapproved in case of Admission payment is disapproved by finance department 
                {
                    set<String> setOppsId = new set<String>();
                    set<String> setOfIds = new set<String>();
                    for(nm_Payment__c objPayment : lstPayment)
                    {
                        system.debug('<-------------------------------Payment Status(new )---------------->'+objPayment.nm_PaymentStatus__c+'<------------------------------old status------------->'+oldMapPayment.get(objPayment.Id).nm_PaymentStatus__c+'<-----------------Payment Type--------------->'+objPayment.nm_PaymentType__c);
                        if(objPayment.nm_PaymentStatus__c == 'Payment Disapproved' && oldMapPayment.get(objPayment.Id).nm_PaymentStatus__c != 'Payment Disapproved')
                        {
                            if(objPayment.nm_PaymentType__c == 'Admission' && objPayment.nm_OpportunityNew__c != Null)
                            {
                                setOppsId.add(objPayment.nm_OpportunityNew__c);                        
                            }
                        }else if(objPayment.nm_OpportunityNew__c != Null)// update Opportunity Stage to Pending Payment 
                        {
                            // checking Admission Payment is Approved or not in order to avoid cases of updating Opportunity Stage from closedwon-Reregistration pending to Closed won after Fee Receipt export
                            // and also avoid double fire of Trigger
                            if(objPayment.nm_PaymentStatus__c != 'Payment Approved')
                            {
                                setOfIds.add(objPayment.nm_OpportunityNew__c); 
                                                        
                            }
                        }  
                    }
                    
                    // update Opportunity stage to Payment made depending on Pending Payment after Lead convert  
                    if(setOfIds.size()>0)
                    {
                        for(String OppsId : setOfIds)
                        {
                           // update Opportunity Stage to Pending Payment or Payment Made or Closed or Closed Won Depends On Pending Payment 
                           productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId,'Payment Transfer', null, null);
                        }
                    }
                    
                    if(setOppsId.size()>0)
                    {
                        Opportunity objOppsToUpdate = [select Id, StageName from Opportunity where Id IN : setOppsId];
                        objOppsToUpdate.StageName = 'Registration Fee Disapproved By Finance';
                        lstOpportunityToUpdate.add(objOppsToUpdate);
                    }
                }     
            }
            
            if(lstOpportunityToUpdate.size()>0)
            {
                update lstOpportunityToUpdate;
            }
        }
    }

    public void updateAccountAndOpportunityStage(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment) {
        PaymentDisapprovedUpdateStatus objPayment = new PaymentDisapprovedUpdateStatus();
        objPayment.updateAccountAndOpportunityForDisapprovedPayment(lstPayment, oldMapPayment);
    }
    
    public void ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(Opportunity objOpp) 
    {
        list<nm_StudentProgram__c> lstUpdateStudentProgram = new list<nm_StudentProgram__c>();
        list<Account> lstUpdateAccount = new list<Account>();
        
        list<IC_Change_Request__c> lstICR=[select id,Student__c,nm_Reson__c,nm_TypeofRequest__c,New_Program__c,nm_Reason_for_Change_of_Program__c,New_Information_Center__c from IC_Change_Request__c where Student__c=:objOpp.Accountid and  Opportunity__c=:objOpp.id];
        
        if(ObjOpp.nm_StudentProgram__c !=null && ObjOpp.nm_Program__c !=null)
        {
            if(lstICR.size()>0)
            {
                for(IC_Change_Request__c objICChange : lstICR )
                {
                    if(objICChange.nm_TypeofRequest__c=='Program Change' && objICChange.New_Program__c !=null)  
                    {
                        nm_StudentProgram__c objStudentPro=new nm_StudentProgram__c(id=ObjOpp.nm_StudentProgram__c);
                        objStudentPro.nm_PreviousProgram__c=ObjOpp.nm_StudentProgram__r.nm_Program__c;
                        objStudentPro.nm_Program__c=objICChange.New_Program__c;
                        objStudentPro.nm_Reason_for_change_of_student_Program__c=objICChange.nm_Reason_for_Change_of_Program__c;
                        objStudentPro.nm_FeesPaidofSemester__c=Decimal.ValueOf(ObjOpp.nm_Semester__c);
                        lstUpdateStudentProgram.add(objStudentPro);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                    
                    if(objICChange.nm_TypeofRequest__c=='IC Change' && objICChange.New_Information_Center__c !=null && objICChange.Student__c !=null)   
                    {
                        Account objAccountUpdate=new Account(id=objICChange.Student__c);
                        // objAccountUpdate.nm_ReasonForICChange__c= objICChange.nm_Reson__c;
                        objAccountUpdate.nm_Centers__c=objICChange.New_Information_Center__c;
                        objAccountUpdate.OwnerId = getCenterUser(objICChange.New_Information_Center__c);
                        lstUpdateAccount.add(objAccountUpdate);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                }
                
                if(lstUpdateAccount.size()>0)
                {   try{
                         update lstUpdateAccount;
                    }catch(DmlException e){
                        System.debug(e.getMessage());
                    }
                }
                if(lstUpdateStudentProgram.size()>0)
                {   
                    try{
                        update lstUpdateStudentProgram;
                    }catch(DmlException e){
                        System.debug(e.getMessage());
                    }
                }
                if(ObjOpp !=null && lstUpdateStudentProgram.size()>0)
                {
                    ObjOpp.nm_Program__c=lstUpdateStudentProgram[0].nm_Program__c;
                    update ObjOpp;
                }
            }
        }
    }
        public void updatePaymentStatus(list<nm_Payment__c> lstPayment)
        {
            Set<Id> paymentid = new Set<Id>();
            Set<Id> paymentregid = new Set<Id>();
            Set<Id> paymentToApprove = new Set<Id>();
            
            //Set<String> convertLeadPaymentids = new Set<String>();

            Set<Id> validitypaymentid = new Set<Id>();
            Boolean Isregistration = false;
          //  String merchantTrackId = 'default';
            list<nm_Payment__c> listValidityPayment = new list<nm_Payment__c>();
            if(lstPayment.size()>0)
            {
                if('Yes'.equalsIgnoreCase(Label.Auto_Approval)){
                    
                for(nm_Payment__c objPayment : lstPayment)
                {
                    if('Online'.equalsIgnoreCase(objPayment.nm_ModeOfPayment__c)&& 'Payment Made'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c) 
                     && objPayment.nm_Merchant_Track_Id__c!=null && objPayment.nm_PaymentGatewayName__c!=null && !'Live Lectures'.equalsIgnoreCase(objPayment.nm_PaymentType__c) )
                    {
                        if(objPayment.nm_Lead__c!=null && (objPayment.ProgramType_ex__c!=null && (objPayment.ProgramType_ex__c.contains('MBA (WX)') || objPayment.ProgramType_ex__c.equalsIgnoreCase('M.Sc. (AI)'))))
                        {
                           if('Registration'.equalsIgnoreCase(objPayment.nm_PaymentType__c) )
                           {
                                Isregistration =true;
                                paymentregid.add(objPayment.id);
                                //paymentid.add(objPayment.id);
                           }else {
                             paymentid.add(objPayment.id);
                           }
                                                       
                        }
                        else if(objPayment.Validity_Extension__c!=null)
                        {
                          nm_Payment__c objPaymentvs2 = new nm_Payment__c(id = objPayment.id);                          
                          validitypaymentid.add(objPayment.Validity_Extension__c);
                          listValidityPayment.add(objPaymentvs2);  
                        }else if(objPayment.nm_OpportunityNew__c!=null || objPayment.CareerServiceProgram__c!=null || objPayment.Seminar__c!=null) {
                            paymentid.add(objPayment.id);
                       }

                      /* if(objPayment.nm_Lead__c!=null){
                        convertLeadPaymentids.add(objPayment.id);
                       }*/
                       
                    } else if ('Online'.equalsIgnoreCase(objPayment.nm_ModeOfPayment__c)&& 'Payment Made'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c) 
                     && objPayment.nm_Merchant_Track_Id__c!=null && objPayment.nm_PaymentGatewayName__c!=null && String.isNotBlank(objPayment.nm_OpportunityNew__c) && 'Live Lectures'.equalsIgnoreCase(objPayment.nm_PaymentType__c)  ) {
                        paymentToApprove.add(objPayment.id);
                    }
                }
            }
                if(paymentregid.size()>0 && Isregistration)
                {
                    CallwebserviceMassApproval(paymentregid,Isregistration);
                }

                if(paymentToApprove.size() > 0) {
                    callWebserviceToApproveAndSendToStudentzone(paymentToApprove);
                }
               /* if(validitypaymentid.size()>0)
                {
                      If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
                     System.enqueueJob(new ActionOnValityPaymentApproval(validitypaymentid,listValidityPayment));
                 }
                }*/
                /*if(convertLeadPaymentids.size()>0){
                    checkLeadConvert(convertLeadPaymentids);
                }*/
            }
        }
    public void UpdateICChangeStatusForPaymentApproved(Opportunity ObjOpp,IC_Change_Request__c objICChange)
    {
      System.debug('<-------Entered UpdateICCHange method--------->');
        if(objOpp.StageName =='Closed Won')
        {
            objICChange.Status__c ='Approved';
            Update objICChange;
        }                
    }
    
    public string getCenterUser(id centerId)
    {
        nm_UserMapping__c objUserMap = [select id,nm_User__c from nm_UserMapping__c where nm_Centers__c=:centerId];
        return objUserMap.nm_User__c;
    }
    
    public void UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment,boolean IsInsert)
    {
        if(lstPayment !=null && lstpayment.size()>0)
        {
            List<Lead> lstLeadToUpdate = new List<Lead>();
            list<Account> lstAccountUpdate=new list<Account>();
            set<String> setLeadId  = new set<String>();
            List<nm_Payment__c> lstPaymentToTransfer = new List<nm_Payment__c>();
            if(IsInsert)// this code will run in case of Insert call 
            {
              // this will handle Manually Inserted Records at Lead Level
               Map<String,nm_Payment__c> mapOfLeadIdAndPayment = new Map<String,nm_Payment__c>();
               Map<string,nm_Payment__c> mapofAccountIdAndPayment=new Map<String,nm_Payment__c>();
               for(nm_Payment__c objPayment : lstPayment)
                {
                    if(objPayment.nm_Lead__c != null)
                    {
                        mapOfLeadIdAndPayment.put(objPayment.nm_Lead__c,objPayment);
                    }
                    else if(objPayment.nm_OpportunityNew__c!=null)
                    {
                        mapofAccountIdAndPayment.put(objPayment.nm_OpportunityNew__c,objPayment);
                        system.debug('mapofAccountIdAndPayment'+mapofAccountIdAndPayment);
                        
                    }
                }
                
                if(!mapOfLeadIdAndPayment.isEmpty())
                {
                    for(String LeadId : mapOfLeadIdAndPayment.keyset())
                    {
                        nm_Payment__c objPayment = mapOfLeadIdAndPayment.get(LeadId);
                        if(objPayment.nm_PaymentType__c == 'Registration' && objPayment.nm_PaymentStatus__c == 'Payment Made')
                        {
                           Lead objLead = new Lead(id=objPayment.nm_Lead__c);
                           objLead.Status='Registration Fee Paid';
                           objLead.nm_PaymentStatus__c='Payment made';
                           lstLeadToUpdate.add(objLead); 
                        }else if(objPayment.nm_PaymentType__c == 'Admission' && objPayment.nm_PaymentStatus__c == 'Payment Made')
                        {
                           Lead objLead = new Lead(id=objPayment.nm_Lead__c);
                           objLead.Status='Admission Fee Paid';
                           objLead.nm_PaymentStatus__c='Payment made';
                           objLead.Time_stamp_forAddmission_fee_paid__c=system.today();
                           lstLeadToUpdate.add(objLead); 
                        }
                    }
                } 
                else if(!mapofAccountIdAndPayment.isEmpty())
                {
                    system.debug('Enter in mapofAccountIdAndPayment');
                    for(String OppId:mapofAccountIdAndPayment.keyset())
                    {
                         nm_Payment__c objPayment = mapofAccountIdAndPayment.get(OppId);
                          system.debug('Enter in mapofAccountIdAndPayment'+mapofAccountIdAndPayment.get(OppId));
                         
                        if(objPayment.nm_PaymentType__c == 'Admission' && objPayment.nm_PaymentStatus__c == 'Payment Made')
                        {
                            system.debug('Check Payment condition'+objPayment.nm_PaymentType__c+'Check Payment Status'+objPayment.nm_PaymentStatus__c);
                            Account objAcc=new Account(id=objPayment.nm_AccountID__c);
                            system.debug('Check Account'+objAcc);
                            objAcc.TimestampAdmissionfeepaid__c=system.today();
                            lstAccountUpdate.add(objAcc);
                            system.debug('Check list'+lstAccountUpdate.size());
                        }
                    }
                }
                
            }else if(!IsInsert)// this code will run in case of Update call 
            {
                System.debug('Enter in Update---->');
                for(nm_Payment__c objPayment : lstPayment)
                {
                     System.debug('Enter in objPayment lead ---->'+objPayment.nm_Lead__c+'Enter in Payment Type'+objPayment.nm_PaymentType__c+'Enter Payment Status'+objPayment.nm_PaymentStatus__c+'Enter in oldmap value'+oldMapPayment.get(objPayment.id).nm_PaymentStatus__c);
                  //  if(objPayment.nm_Lead__c != null  && objPayment.nm_PaymentType__c == 'Registration' && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.nm_PaymentStatus__c != oldMapPayment.get(objPayment.id).nm_PaymentStatus__c)
                   if((objPayment.nm_Lead__c != null  && objPayment.nm_PaymentType__c == 'Registration' && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.nm_PaymentStatus__c != oldMapPayment.get(objPayment.id).nm_PaymentStatus__c)
                    || 
                    (objPayment.nm_Lead__c != null  && objPayment.nm_PaymentType__c == 'Admission' && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.nm_PaymentStatus__c != oldMapPayment.get(objPayment.id).nm_PaymentStatus__c
                    && objPayment.ProgramType_ex__c=='CPWL'))
                    {
                        setLeadId.add( objPayment.nm_Lead__c );
                         system.debug('Lead id is'+setLeadId);
                        Lead objLead = new Lead(id=objPayment.nm_Lead__c);
                        objLead.nm_LeadContacted__c = 'Yes'; 
                        objLead.nm_PaymentCompleted__c = true;
                        if(objPayment.MobilePhone__c!=null)
                        {
                            objLead.MobilePhone = objPayment.MobilePhone__c.left(10);
                        }
                        if(objPayment.nm_StudentEmail__c!=null)
                        {
                             string stremail = objPayment.nm_StudentEmail__c;
                             stremail = stremail.replace('reborn_','');
                             stremail = stremail.replace('duplicate','');
                             objLead.Email = stremail ;
                         }

                        lstLeadToUpdate.add(objLead);
                    }// update Lead stage in case of Disapproved 
                    else if(objPayment.nm_Lead__c != null  && objPayment.nm_PaymentType__c == 'Registration' && objPayment.nm_PaymentStatus__c == 'Payment Disapproved' && oldMapPayment.get(objPayment.Id).nm_PaymentStatus__c != objPayment.nm_PaymentStatus__c)
                    {
                        Lead objLead = new Lead(id=objPayment.nm_Lead__c);
                        objLead.Status = 'Registration Fee Disapproved By Finance';
                        lstLeadToUpdate.add(objLead);
                    }
                }
            }   
             
            if(lstLeadToUpdate.size()>0)
            {  
                   update lstLeadToUpdate;
            }
            if(lstAccountUpdate.size()>0)
            {
                update lstAccountUpdate;
            }
            //Code to transfer registration payment record to opportunity from lead
            //transer Payment from Lead to Opportunity 
            if(setLeadId.size()>0)
            {
                system.debug(' enter setLeadId is'+setLeadId);
                List<Lead> lstLeadPaymentTransferToOpportunity = [select id, ConvertedAccountId, convertedOpportunityId 
                                                                    ,( select id, nm_PaymentType__c from Payment__r )
                                                                    from Lead where id in: setLeadId and IsConverted =true];
                if(lstLeadPaymentTransferToOpportunity.size()>0)
                {
                   system.debug(' enter lstLeadPaymentTransferToOpportunity is'+lstLeadPaymentTransferToOpportunity);
                    for(Lead objLead : lstLeadPaymentTransferToOpportunity)
                    {
                        if( objLead.ConvertedOpportunityId != null )
                        {
                           for( nm_Payment__c objPayment : objLead.Payment__r )
                            {
                                objPayment.nm_Lead__c = null;
                                objPayment.nm_OpportunityNew__c = objLead.ConvertedOpportunityId;   
                                lstPaymentToTransfer.add(objPayment);
                            }
                        }
                    }
                }
             }   
            
            if(lstPaymentToTransfer.size()>0)
            {
                System.debug('Enter In lopp of Payment Transfer from Lead to Opps------>'+lstPaymentToTransfer);
                update lstPaymentToTransfer;
            }
       }
    }
    
    
    public void UpdateAccountIncaseofCancellationWithLatefees(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment)
    {
        if(checkRecursive.isCheckPaymentoflAtefees)
        {
            checkRecursive.isCheckPaymentoflAtefees=false;
        }
        else
        {
            return;
        }
        
        if(lstPayment.size()>0)
        {
            list<Account> lstAccountUpdate=new list<Account>();
            for(nm_Payment__c objPayment:lstPayment)
            {
                System.debug('objPayment.nm_AccountID__c ---> ' + objPayment.nm_AccountID__c); 
                if(objPayment.nm_AccountID__c !=null)
                {
                    if(objPayment.nm_PaymentType__c=='Late Fees' && objPayment.nm_PaymentStatus__c=='Pending Late Fees') 
                    {
                        Account objAccPendinglatefees=new Account(id=objPayment.nm_AccountID__c);
                        objAccPendinglatefees.Is_Late_fees_pending__c=true;
                        lstAccountUpdate.add(objAccPendinglatefees);
                    }
                    else if(objPayment.nm_PaymentType__c=='Late Fees' && objPayment.nm_PaymentStatus__c=='Payment Made') 
                    {
                        Account objAccPaymentMade=new Account(id=objPayment.nm_AccountID__c);
                        objAccPaymentMade.Is_Late_fees_paid__c=true;
                        objAccPaymentMade.Is_Late_fees_pending__c=false;
                        lstAccountUpdate.add(objAccPaymentMade);
                    }
                    else if(objPayment.nm_PaymentType__c=='Late Fees' && (objPayment.nm_PaymentStatus__c=='Waived Off' || objPayment.nm_PaymentStatus__c=='Payment Approved'))
                    {
                        Account objAccPaymentApprove=new Account(id=objPayment.nm_AccountID__c);
                        objAccPaymentApprove.Is_Late_fees_paid__c=false;
                        objAccPaymentApprove.Is_Late_fees_pending__c=false;
                        lstAccountUpdate.add(objAccPaymentApprove);
                    }
                }   
            }
            if(lstAccountUpdate.size()>0){
                update lstAccountUpdate;
            } 
        }
    }
    
    public void GenerateRegistrationReceiptNo(list<nm_Payment__c> lstPayment,Map<id,nm_Payment__c> oldMap ,boolean isUpdate){
        Long UniqueReceiptNo = null;
        String strPreReceiptNo = string.valueof(System.now().year()).substring(2,4);
        String strPreTextForReceipt = 'SDLR';
        Map<String,Long> mapOfRegistrationPreviousReceiptNo = new Map<String,Long>();
        List<nm_Payment__c> lstReceiptNumberUpdate = new List<nm_Payment__c>();
        System.debug('isUpdate--'+isUpdate);
        if(!isUpdate){
            for(nm_Payment__c objPayment : lstPayment){
                System.debug('objPayment.nm_PaymentType__c '+objPayment.nm_PaymentType__c+'objPayment.nm_PaymentStatus__c '+objPayment.nm_PaymentStatus__c);
                if('Registration'.equalsIgnoreCase(objPayment.nm_PaymentType__c) && 'Payment Made'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c)){
                    if(String.IsBlank(objPayment.Receipt_Number__c)){
                        nm_Payment__c objNewPayment = new nm_Payment__c(id=objPayment.id);
                        UniqueReceiptNo = getMaxReceiptNo(strPreReceiptNo,strPreTextForReceipt,mapOfRegistrationPreviousReceiptNo);
                        UniqueReceiptNo = UniqueReceiptNo + 1;
                        mapOfRegistrationPreviousReceiptNo.put(strPreTextForReceipt,UniqueReceiptNo);
                        objNewPayment.Receipt_Number__c = strPreTextForReceipt+'-'+ UniqueReceiptNo;
                        lstReceiptNumberUpdate.add(objNewPayment);
                    }
                }
            }
        }else{
            for(nm_Payment__c objPayment : lstPayment){
                System.debug('update-->'+ objPayment.nm_PaymentType__c + ' ' + objPayment.nm_PaymentStatus__c + ' ' + oldMap.get(objPayment.id).nm_PaymentStatus__c);
                if('Registration'.equalsIgnoreCase(objPayment.nm_PaymentType__c) && 'Payment Made'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c) && oldMap.get(objPayment.id).nm_PaymentStatus__c != objPayment.nm_PaymentStatus__c){
                    if(String.IsBlank(objPayment.Receipt_Number__c)){
                        nm_Payment__c objNewPayment = new nm_Payment__c(id=objPayment.id);
                        UniqueReceiptNo = getMaxReceiptNo(strPreReceiptNo,strPreTextForReceipt,mapOfRegistrationPreviousReceiptNo);
                        UniqueReceiptNo = UniqueReceiptNo + 1;
                        mapOfRegistrationPreviousReceiptNo.put(strPreTextForReceipt,UniqueReceiptNo);
                        objNewPayment.Receipt_Number__c = strPreTextForReceipt+'-'+ UniqueReceiptNo;
                        lstReceiptNumberUpdate.add(objNewPayment);
                    }
                }
            }
        }
        
        
        // call method to update Receipt Number on Payment Record 
        if(lstReceiptNumberUpdate.size() > 0){
            update lstReceiptNumberUpdate;
        }
    }
    
    public Long getMaxReceiptNo(String strPreReceiptNo , String strPreTextForReceipt,Map<String,Long> mapOfRegistrationPreviousReceiptNo){
         System.debug('mapOfRegistrationPreviousReceiptNo---'+mapOfRegistrationPreviousReceiptNo.keySet());
         // finding Max Receipt Number from Payment
        String maxRegistrationReceiptNo = strPreTextForReceipt+'-'+strPreReceiptNo+'0000000';
        
        List<nm_Payment__c> lstMaxReceipt = [select Receipt_Number__c,id from nm_Payment__c where Receipt_Number__c!='' and Receipt_Number__c Like :(strPreTextForReceipt+'-'+strPreReceiptNo+'%') order by Receipt_Number__c desc limit 1];
        
        if(lstMaxReceipt.size()>0)
        {
            maxRegistrationReceiptNo = lstMaxReceipt[0].Receipt_Number__c;
        }
        system.debug('maxRegistrationReceiptNo--'+maxRegistrationReceiptNo);
        Long UniqueReceiptNo = Long.valueOf(maxRegistrationReceiptNo.split('-')[1]); 
        System.debug('before UniqueReceiptNo---'+UniqueReceiptNo);
        if(!mapOfRegistrationPreviousReceiptNo.IsEmpty()){
            if(mapOfRegistrationPreviousReceiptNo.containsKey(strPreTextForReceipt)){
                UniqueReceiptNo = mapOfRegistrationPreviousReceiptNo.get(strPreTextForReceipt);
            }
        }
        System.debug('after UniqueReceiptNo---'+UniqueReceiptNo);
        return UniqueReceiptNo;
    }
    
    //this method will Update AmountRecived On Opportunity
    public void calculateAmountReceived(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment) {
        List<Opportunity> lstOppUpdate = new List<Opportunity>();
        Set<String> setOfOppsId = getOpportunityIds(lstPayment);
        System.debug('Set OppsId Size In Calculate--->'+setOfOppsId.size());

        if(!setOfOppsId.isEmpty()) {
            Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = productHelper.getOpportunityRelatedPayment(setOfOppsId);
            Map<String,Decimal> mapOfOppsIdVsTotalRefundedAmount = productHelper.getTotalAmountRefunded(setOfOppsId, mapOfOppsIdVsPayments);

            for(String oppsId : setOfOppsId) {
                lstOppUpdate.add(createOpportunityUpdate(oppsId, mapOfOppsIdVsPayments, mapOfOppsIdVsTotalRefundedAmount));
            }
        }
        
        if(!lstOppUpdate.isEmpty()) {
            System.debug('Enter In Opps Update Loop');
            try {
                update lstOppUpdate;   
            } catch (DMLException e) {
                System.debug('Error '+e.getMessage());
            }
        }
    }

    /**
    * @description 
    * @author @BK | 15-01-2025 
    * @param list<nm_Payment__c> lstPayment 
    * @return Set<String> 
    **/
    private Set<String> getOpportunityIds(list<nm_Payment__c> lstPayment) {
        Set<String> setOfOppsId = new set<String>();
        for(nm_Payment__c objPayment : lstPayment) {
            if(objPayment.nm_OpportunityNew__c !=null) {
                setOfOppsId.add(objPayment.nm_OpportunityNew__c);  
            }
        }
        return setOfOppsId;
    }

    /**
    * @description 
    * @author @BK | 15-01-2025 
    * @param String oppsId 
    * @param Map<String List<nm_Payment__c>> mapOfOppsIdVsPayments 
    * @param Map<String Decimal> mapOfOppsIdVsTotalRefundedAmount 
    * @return Opportunity 
    **/
    private Opportunity createOpportunityUpdate(String oppsId, Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments, Map<String,Decimal> mapOfOppsIdVsTotalRefundedAmount) {
        Opportunity objOppUpdate = new Opportunity(id=oppsId);
        objOppUpdate.Total_Amount_Received__c = productHelper.getTotalAmountReceived(oppsId,mapOfOppsIdVsPayments);
        objOppUpdate.nm_TotalApprovedPayment__c = productHelper.getTotalApprovedAmount(oppsId,mapOfOppsIdVsPayments);
        objOppUpdate.WaivedOffAmount__c = productHelper.getTotalAmountWaivedOff(oppsId,mapOfOppsIdVsPayments);
        Decimal totalRefundedAmount = mapOfOppsIdVsTotalRefundedAmount.containsKey(oppsId) ? mapOfOppsIdVsTotalRefundedAmount.get(oppsId) : 0;
        objOppUpdate.RefundInitiatedAmount__c = (objOppUpdate.RefundInitiatedAmount__c != null && objOppUpdate.RefundInitiatedAmount__c > 0) 
                                                ? objOppUpdate.RefundInitiatedAmount__c + totalRefundedAmount 
                                                : totalRefundedAmount;
        return objOppUpdate;
    }

    public static void UpdateCareerServiceStage(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment) {
        list<Career_Service_Program__c> lstCareerServiceProgramUpdate = new list<Career_Service_Program__c>();
        Set<String> setOfCareerServiceProgramId = new Set<String>();
        System.debug('lst Payment Size In Calculate for UpdateCareerServiceStage-->'+lstPayment.size());
        if(lstPayment.size() > 0) { 
            for(nm_Payment__c objPayment : lstPayment) {
                if(objPayment.CareerServiceProgram__c !=null && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved')  {
                    setOfCareerServiceProgramId.add(objPayment.CareerServiceProgram__c);  
                }
            }

            System.debug('Set CareerServiceProgramId Size In Calculate--->'+setOfCareerServiceProgramId.size());
            if(setOfCareerServiceProgramId.size() > 0) {
                for (String CareerServiceProgramId : setOfCareerServiceProgramId) {
                    Career_Service_Program__c objCSProgram = new Career_Service_Program__c(id = CareerServiceProgramId);
                    objCSProgram.Stage__c = 'Payment Done';
                    lstCareerServiceProgramUpdate.add(objCSProgram);
                }
            }

            if(lstCareerServiceProgramUpdate.size() > 0) {
                System.debug('Enter In CareerServiceProgram Update Loop');
                try {
                    update lstCareerServiceProgramUpdate;
                } catch (Exception e) {
                    System.debug('Error -->'+e.getMessage());
                }
            }
        }
    }

    public static void UpdateCourseraStatus(list<nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMapPayment) {
        Set<String> lstOpportunityIds = new Set<String>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for(nm_Payment__c objPayment : lstPayment) {
            if(objPayment.nm_PaymentType__c == 'Coursera' && objPayment.nm_OpportunityNew__c!=null && 
                oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c && objPayment.nm_PaymentStatus__c == 'Payment Approved')  {
                    lstOpportunityIds.add(objPayment.nm_OpportunityNew__c);
            }
        }

        if(lstOpportunityIds.size() > 0) {
            List<Opportunity> lstOpps = [SELECT id,Coursera__c,Account.nm_StudentNo__c,Synced_With_StudentZone__c,Account.nm_StudentStatus__c FROM Opportunity WHERE id=:lstOpportunityIds];
            for(Opportunity objOpp : lstOpps) {
                if(!objOpp.Coursera__c) {
                    objOpp.Coursera__c = true;
                    lstOppToUpdate.add(objOpp);
                }
                
                if(objOpp.Synced_With_StudentZone__c && objOpp.Account.nm_StudentStatus__c == 'Confirmed' && String.isNotBlank(objOpp.Account.nm_StudentNo__c)) {
                    callCourseraAPI(objOpp.Account.nm_StudentNo__c,objOpp.id);
                }
            }

            if(lstOppToUpdate.size() > 0) {
                update lstOppToUpdate;
            }
        }
    }

    /**
    * @description 
      update the payment transaction mode at opportunity level depends upon payment mode
    * @author shubhranshu | 10/1/2019 
    * @param lstPayment 
    * @param flagtoDelete 
    * @return void 
    **/
   /* public void updatePaymentTransactionModeInOpp(list<nm_Payment__c> lstPayment,Boolean flagtoDelete){

        System.debug('flagtoDelete '+flagtoDelete);
        set<String> setOfOppsId = new set<String>();
        Map<Id,List<nm_Payment__c>> mapOfOppIdWithMode = new Map<Id,List<nm_Payment__c>>();
        List<Opportunity> updateLstopp = new List<Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<nm_Payment__c> lstOfAllPayments= new List<nm_Payment__c>();

        if(lstPayment.size()>0){
            System.debug('lstPayment '+lstPayment);
            for(nm_Payment__c objPayment : lstPayment){
                if(objPayment.nm_OpportunityNew__c !=null && objPayment.nm_PaymentType__c !='Registration'
                && (objPayment.nm_PaymentStatus__c=='Payment Made' || objPayment.nm_PaymentStatus__c=='Payment Approved') && objPayment.payment_Transaction_Mode__c != null){
                    setOfOppsId.add(objPayment.nm_OpportunityNew__c); 
                }
            }

            if(setOfOppsId.size()>0){
                lstOpp = [select Id , Transaction_mode_for_all_payments__c from Opportunity where Id IN : setOfOppsId];
                lstOfAllPayments = [select Id , payment_Transaction_Mode__c,nm_OpportunityNew__c from nm_Payment__c where nm_OpportunityNew__c IN :setOfOppsId 
                                    and nm_PaymentType__c !='Registration' and (nm_PaymentStatus__c='Payment Made' OR nm_PaymentStatus__c='Payment Approved') and payment_Transaction_Mode__c != null];
            }

            if(lstOpp.size() >0){
                List<String> lst = new List<String>();
                Set<String> setOfPaymentMode = new Set<String>();
                String payMode = '';
                for(Opportunity opp:lstOpp){

                    for(nm_Payment__c nmpay:lstOfAllPayments){
                        
                        if(nmpay.nm_OpportunityNew__c == opp.Id){
                            setOfPaymentMode.add(nmpay.payment_Transaction_Mode__c);
                            System.debug('setOfPaymentMode '+setOfPaymentMode);
                        }
                    }
                    Boolean checkifnullRemoved = setOfPaymentMode.remove(null);
                    for(String s:setOfPaymentMode) {
                        payMode += (payMode == '' ? '' : ',')+s;
                    }
                    opp.Transaction_mode_for_all_payments__c = payMode;
                    System.debug('Mode to update: '+opp.Transaction_mode_for_all_payments__c);
                    updateLstopp.add(opp);
                }
            }
        }

        if(updateLstopp.size() >0){
            try{
                update updateLstopp;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }*/

    /**
    * @description 
      update the bank charge at opportunity level with respects to payment mode
    * @author shubhranshu | 10/1/2019 
    * @param lstPayment 
    * @param taskToDo 
    * @return void 
    **/
   /* public void calculateBankCharges(List<nm_Payment__c> lstPayment,String taskToDo){
        
        System.debug('taskToDo '+taskToDo);
        Bank_Charges__c bc = Bank_Charges__c.getValues('HDFC_upgrad');
        Bank_Charges__c bc1 = Bank_Charges__c.getValues('Paytm_upgrad');
        
        list<Opportunity> lstOppUpdate = new list<Opportunity>();
        set<String> setOfOppsId = new set<String>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<Id,Decimal> mapOfOppIdVsbankCharges = new Map<Id,Decimal>();
        Decimal calculated_amt = 0.0;
        Decimal bank_charges = 0.0;
        System.debug('lst Payment Size--->'+lstPayment.size());
         
        if(lstPayment.size()>0)
        {
            for(nm_Payment__c objPayment : lstPayment)
            {
              if(objPayment.nm_OpportunityNew__c !=null)
              {
                 setOfOppsId.add(objPayment.nm_OpportunityNew__c);  
              }

              if(objPayment.nm_PaymentGatewayName__c !=null && objPayment.nm_PaymentGatewayName__c.contains('HDFC') && bc != null){
                  
                  calculated_amt = checkPaymentModeAndApplycharegs(objPayment,bc);
                  System.debug('calculated_amt in hdfc '+calculated_amt);

              }else if(objPayment.nm_PaymentGatewayName__c !=null  && objPayment.nm_PaymentGatewayName__c.contains('Paytm') && bc1 != null){
                  
                  calculated_amt = checkPaymentModeAndApplycharegs(objPayment,bc1);
                  System.debug('calculated_amt in paytm '+calculated_amt);
              }
                bank_charges = (calculated_amt * 60)/100;
                mapOfOppIdVsbankCharges.put(objPayment.nm_OpportunityNew__c,bank_charges);
                System.debug('mapOfOppIdVsbankCharges '+mapOfOppIdVsbankCharges);
            }
        }

        if(setOfOppsId.size() >0){
            lstOpp = [select Id , Bank_Charge__c from Opportunity where Id IN : setOfOppsId];
            System.debug('lstOpp '+lstOpp);
            if(lstOpp.size() > 0){
                for(Opportunity opp:lstOpp){
                    if(mapOfOppIdVsbankCharges.containsKey(opp.id)){
                        System.debug('bank charges '+opp.Bank_Charge__c);
                        if(taskToDo == 'DELETE'){
                            opp.Bank_Charge__c = opp.Bank_Charge__c - mapOfOppIdVsbankCharges.get(opp.id);
                        }else{
                            opp.Bank_Charge__c = opp.Bank_Charge__c !=null && opp.Bank_Charge__c >0 ? opp.Bank_Charge__c + mapOfOppIdVsbankCharges.get(opp.id) : mapOfOppIdVsbankCharges.get(opp.id);
                        }
                    }
                    lstOppUpdate.add(opp);
                }
            }
        }

         if(lstOppUpdate.size() >0){
            try{
                update lstOppUpdate;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }*/
    
     /**
     * @description 
       It will approve Validity Payment onInsert
     * @author phalguni | 3/2/2020 
     * @param list<nm_Payment__c> lstPayment 
     * @param map<id nm_Payment__c> oldMapPayment 
     * @return void 
     **/
    public void ValidityextensionApproval(list <nm_Payment__c> lstPayment, map <id, nm_Payment__c> oldMapPayment) {
         set <id> setofValidityId = new set <id> ();
         list <Account> lstAccounttoupdate = new list <Account> ();
         Date d = date.today();

         if (lstPayment.size() > 0) {
            for (nm_Payment__c objPayment: lstPayment) {
                if (objPayment.Validity_Extension__c != null && objPayment.nm_PaymentType__c == 'Validity Extension Fee'
                && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c != objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved') {
                     
                    setofValidityId.add(objPayment.Validity_Extension__c);
                }
            }

            if (setofValidityId.size() > 0) {
                list <Validity_Extension__c> lstValidityExtension = [select id, Name_Of_Account__c,Related_Account__r.Extended_Validity_For_This_Session__c , Related_Account__c, Related_Account__r.Validity_Month__c, Related_Account__r.Validity_Extension_Count__c,
                                                                     Related_Account__r.Validity_Year__c, Related_Account__r.Extend_Validity_Upto_Year__c, Related_Account__r.nm_Program__r.IsTerm__c,Related_Account__r.Validity_End_Date__c
                                                                     from Validity_Extension__c where id = : setofValidityId];
                for (Validity_Extension__c objVE: lstValidityExtension) {
                    if(objVE.Related_Account__r.nm_Program__r.IsTerm__c && objVE.Related_Account__r.Validity_End_Date__c!=null) {
                        Account objAccount = new Account(id = objVE.Related_Account__c);
                        DateTime extendedDate = System.now().addMonths(3);
                        objAccount.Extend_Validity_upto_Month__c = extendedDate.format('MMMM');
                        objAccount.Extend_Validity_Upto_Year__c = Integer.valueOf(extendedDate.format('yyyy'));
                        objAccount.Validity_Extension_Count__c = objVE.Related_Account__r.Validity_Extension_Count__c + 1;
                        lstAccounttoupdate.add(objAccount);
                    } else if(!objVE.Related_Account__r.nm_Program__r.IsTerm__c) {
                        Account objAccount = new Account(id = objVE.Related_Account__c);
                        if (d.month() >= 6 && d.month() <= 12) {
                            objAccount.Extend_Validity_upto_Month__c = 'December';
                            if ((objVE.Related_Account__r.Validity_Month__c == 'June' && objVE.Related_Account__r.Extended_Validity_For_This_Session__c && (objVE.Related_Account__r.Validity_Extension_Count__c == 1 || objVE.Related_Account__r.Validity_Extension_Count__c == 0)) || (objVE.Related_Account__r.Validity_Month__c == 'December')) {
                                objAccount.Extend_Validity_Upto_Year__c = integer.valueOF(objVE.Related_Account__r.Validity_Year__c) + 1;
                            } else {
                                objAccount.Extend_Validity_Upto_Year__c = integer.valueOF(objVE.Related_Account__r.Validity_Year__c);
                            }
                            objAccount.Extended_Validity_For_This_Session__c = true;
                        } else if (d.month() >= 1 && d.month() <= 6) {
                            objAccount.Extend_Validity_upto_Month__c = 'June';

                            if ((objVE.Related_Account__r.Validity_Month__c == 'June' && (!objVE.Related_Account__r.Extended_Validity_For_This_Session__c || objVE.Related_Account__r.Extended_Validity_For_This_Session__c) && (objVE.Related_Account__r.Validity_Extension_Count__c == 1 || objVE.Related_Account__r.Validity_Extension_Count__c == 0)) || (objVE.Related_Account__r.Validity_Month__c == 'December')) {
                                objAccount.Extend_Validity_Upto_Year__c = integer.valueOF(objVE.Related_Account__r.Validity_Year__c) + 1;
                            } else {
                                objAccount.Extend_Validity_Upto_Year__c = integer.valueOF(objVE.Related_Account__r.Validity_Year__c);
                            }
                            objAccount.Extended_Validity_For_This_Session__c = true;
                        }
                        objAccount.Validity_Extension_Count__c = objVE.Related_Account__r.Validity_Extension_Count__c + 1;
                        lstAccounttoupdate.add(objAccount);
                    }
                }
                if (lstAccounttoupdate.size() > 0) {
                    update lstAccounttoupdate;
                }
             }
         }
    }

    /**
    * @description 
    * @author @BK | 09-22-2020 
    **/
    public void UpdateCenterValidity(list <nm_Payment__c> lstPayment, map <id, nm_Payment__c> oldMapPayment) {
        List<String> lstCenterIdOfPGandUG = new List<String>();
        // List<String> lstCenterIdOfUG = new List<String>();
        List<String> lstCenterIdOfMS = new List<String>();
        List<String> lstCenterIdOfMSRenew = new List<String>();
        List<String> lstCenterIdOfPGandUGRenew= new List<String>();
        List<String> lstCenterIdOfPGandUGandMS= new List<String>();
        List<String> lstCenterIdOfPGandUGandMSRenew= new List<String>();

        
        if(lstPayment.size() > 0) {
            for(nm_Payment__c objPayment : lstPayment) {
                if(objPayment.nm_PaymentType__c == 'UG And PG License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfPGandUG.add(objPayment.AEP__c);
                }
                // if(objPayment.nm_PaymentType__c == 'UG License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                // && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                //     lstCenterIdOfUG.add(objPayment.AEP__c);
                // }
                if(objPayment.nm_PaymentType__c == 'MS License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfMS.add(objPayment.AEP__c);
                }

                if(objPayment.nm_PaymentType__c == 'UG And PG Renewal License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfPGandUGRenew.add(objPayment.AEP__c);
                }

                if(objPayment.nm_PaymentType__c == 'MS Renewal License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfMSRenew.add(objPayment.AEP__c);
                }
                if(objPayment.nm_PaymentType__c == 'UG And PG And MS License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfPGandUGandMS.add(objPayment.AEP__c);
                }
                if(objPayment.nm_PaymentType__c == 'UG And PG And MS Renewal License Fee' && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterIdOfPGandUGandMSRenew.add(objPayment.AEP__c);
                }
            }

            if(lstCenterIdOfPGandUG.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From__c,Validity_To__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfPGandUG];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        objCenter.Validity_From__c = System.today();
                        objCenter.Validity_To__c = System.today().addYears(3);
                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }

            // if(lstCenterIdOfUG.size() > 0) {
            //     List<nm_Centers__c> lstCenters = [SELECT id,Validity_From_UG__c,Validity_To_UG__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfUG];
            //     if(lstCenters.size() > 0) {
            //         for(nm_Centers__c objCenter : lstCenters) {
            //             objCenter.Validity_From_UG__c = System.today();
            //             objCenter.Validity_To_UG__c = System.today().addYears(3);
            //         }
            //         try {
            //             update lstCenters;   
            //         } catch (DMLException e) {
            //             System.debug('Error -->'+e.getMessage());
            //         }
            //     }
            // }

            if(lstCenterIdOfMS.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From_MS__c,Validity_To_MS__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfMS];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        objCenter.Validity_From_MS__c = System.today();
                        objCenter.Validity_To_MS__c = System.today().addYears(3);
                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }

            if(lstCenterIdOfPGandUGRenew.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From__c,Validity_To__c,Validity_From_UG__c,
                                                    Validity_To_UG__c,Validity_From_MS__c,Validity_To_MS__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfPGandUGRenew];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        Date validityEndDate = objCenter.Validity_To__c;
                        objCenter.Validity_From__c = validityEndDate;
                        objCenter.Validity_To__c = validityEndDate.addYears(3);

                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }

            if(lstCenterIdOfMSRenew.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From__c,Validity_To__c,Validity_From_UG__c,
                                                    Validity_To_UG__c,Validity_From_MS__c,Validity_To_MS__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfMSRenew];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        Date validityEndDate = objCenter.Validity_To_MS__c;
                        objCenter.Validity_From_MS__c = validityEndDate;
                        objCenter.Validity_To_MS__c = validityEndDate.addYears(3);

                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }

            if(lstCenterIdOfPGandUGandMS.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From_MS__c,Validity_To_MS__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfPGandUGandMS];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        objCenter.Validity_From__c = System.today();
                        objCenter.Validity_To__c = System.today().addYears(3);
                        objCenter.Validity_From_MS__c = System.today();
                        objCenter.Validity_To_MS__c = System.today().addYears(3);
                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }

            if(lstCenterIdOfPGandUGandMSRenew.size() > 0) {
                List<nm_Centers__c> lstCenters = [SELECT id,Validity_From__c,Validity_To__c,Validity_From_UG__c,
                                                    Validity_To_UG__c,Validity_From_MS__c,Validity_To_MS__c FROM nm_Centers__c WHERE id IN :lstCenterIdOfPGandUGandMSRenew];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        Date validityUGAndPGEndDate = objCenter.Validity_To__c;
                        objCenter.Validity_From__c = System.today();
                        objCenter.Validity_To__c = validityUGAndPGEndDate.addYears(3);
                        Date validityMSEndDate = objCenter.Validity_To_MS__c;
                        objCenter.Validity_From_MS__c = System.today();
                        objCenter.Validity_To_MS__c = validityMSEndDate.addYears(3);

                    }
                    try {
                        update lstCenters;   
                    } catch (DMLException e) {
                        System.debug('Error -->'+e.getMessage());
                    }
                }
            }
        }
    }

    // public String validityExpiredCheck(Date Validity_To,Date Validity_To_MS){
    //     Date currentDate = Date.today();
    //     if(Validity_To < Validity_To_MS && Validity_To >= currentDate){
    //         return 'UG And PG';
    //     }
    //     // else if(Validity_To_UG < Validity_To && Validity_To_UG < Validity_To_MS && Validity_To_UG >= currentDate){
    //     //     return 'UG';
    //     // }
    //     else if(Validity_To_MS < Validity_To && Validity_To_MS >= currentDate){
    //         return 'MS';
    //     }
    //     return '';
    // }

    public void UpdateCenterRequest(list <nm_Payment__c> lstPayment, map <id, nm_Payment__c> oldMapPayment) {
        List<String> lstCenterId = new List<String>();
        System.debug('Payment List for AEP Update --> ' + lstPayment);
        if(lstPayment.size() > 0) {
            for(nm_Payment__c objPayment : lstPayment) {
                if((objPayment.nm_PaymentType__c == 'Name Change Fee' || objPayment.nm_PaymentType__c == 'Entity Change Fee' || objPayment.nm_PaymentType__c == 'Address change Fee') && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c!=objPayment.nm_PaymentStatus__c 
                && objPayment.nm_PaymentStatus__c == 'Payment Approved' && objPayment.AEP__c != null)  {
                    lstCenterId.add(objPayment.AEP__c);
                }
            }

            if(lstCenterId.size() > 0) {

                List<AEP_site_inspection__c> lstAEP = new List<AEP_site_inspection__c>();
                Map<Id, AEP_site_inspection__c> myMap = new Map<Id, AEP_site_inspection__c>(); 
                for(AEP_site_inspection__c objCS : [SELECT id,Centers__c,New_IC_Company_Name__c,Entity__c,AEP_Service_Request__c,nm_Street__c,Location_City__c,nm_PostalCode__c,nm_StateProvince__c FROM AEP_site_inspection__c WHERE Centers__c IN :lstCenterId])
                myMap.put(objCS.Centers__c, objCS);

                List<nm_Centers__c> lstCenters = [SELECT id,IC_Company_Name__c,Entity__c,nm_Street__c, nm_City__c,nm_PostalCode__c,nm_StateProvince__c FROM nm_Centers__c WHERE id IN :lstCenterId];
                if(lstCenters.size() > 0) {
                    for(nm_Centers__c objCenter : lstCenters) {
                        AEP_site_inspection__c objASI = myMap.containsKey(objCenter.Id) ? myMap.get(objCenter.Id) : null;
                        if(objASI != null) {
                            if(objASI.AEP_Service_Request__c == 'Name Change') {
                                objCenter.IC_Company_Name__c = objASI.New_IC_Company_Name__c;
                            } else if(objASI.AEP_Service_Request__c == 'Entity Change') {
                                objCenter.Entity__c = objASI.Entity__c;
                            } else if(objASI.AEP_Service_Request__c == 'Address Change') {
                                objCenter.nm_Street__c = objASI.nm_Street__c;
                                objCenter.nm_City__c = objASI.Location_City__c;
                                objCenter.nm_PostalCode__c = objASI.nm_PostalCode__c;
                                if(String.isNotBlank(objASI.nm_StateProvince__c)) {
                                    objCenter.nm_StateProvince__c = objASI.nm_StateProvince__c;  
                                } 
                            }
                            objASI.AEP_Service_Request__c = '';
                            lstAEP.add(objASI);
                        }
                    }
                    if(lstCenters.size() > 0) {
                        update lstCenters;
                    }
                    if(lstAEP.size() > 0) {
                        update lstAEP;
                    }
                }
            }
        }
    }
    
    public class ActionOnValityPaymentApproval implements Queueable {
       
        public Set<Id> setOfValidityId;
        public List<nm_Payment__c> listValidityPayment; 
        
        public ActionOnValityPaymentApproval(Set<Id> setOfValidityId,List<nm_Payment__c>listValidityPayment) {
           
            this.setOfValidityId = setOfValidityId;
            this.listValidityPayment = listValidityPayment;          
        }
        
        public void execute(QueueableContext queCont) {
             List <nm_Payment__c> listPaymentupdate = new List <nm_Payment__c> ();
             if (listValidityPayment.size() > 0) {
                 for (nm_Payment__c objPayment: listValidityPayment) {
                     objPayment.nm_PaymentStatus__c = 'Payment Approved';
                     listPaymentupdate.add(objPayment);
                 }
                 if (listPaymentupdate.size() > 0) {
                     update listPaymentupdate;
                 }
             }
        }
    }
    /**
    * @description 
      calculate the CC,DC,NF .. chargees using payment amount/
    * @author shubhranshu | 10/1/2019 
    * @param payment 
    * @param bc 
    * @return Decimal 
    **/
   /* public Decimal checkPaymentModeAndApplycharegs(nm_Payment__c payment,Bank_Charges__c bc){
        Decimal amt = 0.0;
        System.debug('Bank charges '+bc);
        if(payment.payment_Transaction_Mode__c == 'CC'){    
            amt = (payment.nm_Amount__c * bc.CC__c);
        }else if(payment.payment_Transaction_Mode__c == 'DC'){
            amt = (payment.nm_Amount__c* bc.DC__c);
        }else{
            amt = bc.NB__c;
        }
        return amt; 
    }*/

    @future
    public static void CallwebserviceMassApproval(Set<Id> paymentid ,Boolean Isregistration )
    {
        list<nm_Payment__c> lstAllPayment = new list<nm_Payment__c>();
        list<nm_Payment__c> lstofRegistrationPayment = new list<nm_Payment__c>();
        list<nm_Payment__c> lstofNonRegistrationPayment = new list<nm_Payment__c>();
        
        Map<Id,nm_Payment__c>  mapofRegistrationPayment = new Map<id,nm_Payment__c>([select id, nm_PaymentStatus__c,nm_PaymentType__c,nm_Lead__c,nm_OpportunityNew__c from nm_Payment__c where id =: paymentid ]);
        lstAllPayment = mapofRegistrationPayment.values();
        if(lstAllPayment.size()>0)
        {
            for(nm_Payment__c objPayment: lstAllPayment)
            {
                if('Registration'.equalsIgnoreCase(objPayment.nm_PaymentType__c) && objPayment.nm_Lead__c!=null && Isregistration)
                {
                    objPayment.nm_PaymentStatus__c='Payment Approved';
                    lstofRegistrationPayment.add(objPayment);
                }else if(objPayment.nm_Lead__c!=null && Isregistration ){
                    objPayment.nm_PaymentStatus__c='Payment Approved';
                    lstofNonRegistrationPayment.add(objPayment);
                }else if(objPayment.nm_Lead__c==null ){
                    System.debug('Lastcondition');
                    objPayment.nm_PaymentStatus__c='Payment Approved';
                    lstofNonRegistrationPayment.add(objPayment);
                }
            }
            
            if(lstofRegistrationPayment.size()>0)
            {
                update lstofRegistrationPayment;
            }
            if(lstofNonRegistrationPayment.size()>0)
            {
                update lstofNonRegistrationPayment;
            }
        }
    }

    @future
    public static void callWebserviceToApproveAndSendToStudentzone(Set<Id> paymentid) {
        list<nm_Payment__c> lstAllPayment = new list<nm_Payment__c>();
        list<nm_Payment__c> lstOfPaymentRecordToUpdate = new list<nm_Payment__c>();
        list<Opportunity> lstOfOpportunityRecordToUpdate = new list<Opportunity>();
        
        Map<Id,nm_Payment__c>  mapofPayment = new Map<id,nm_Payment__c>([select id, nm_PaymentStatus__c,nm_PaymentType__c,nm_Merchant_Track_Id__c,nm_Lead__c,nm_PaymentGatewayName__c,nm_OpportunityNew__c from nm_Payment__c where id =: paymentid ]);
        lstAllPayment = mapofPayment.values();
        if(lstAllPayment.size()>0)
        {
            for(nm_Payment__c objPayment: lstAllPayment)
            {
                if('Live Lectures'.equalsIgnoreCase(objPayment.nm_PaymentType__c)
                    && 'Payment Made'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c) 
                    && objPayment.nm_Merchant_Track_Id__c!=null && objPayment.nm_PaymentGatewayName__c!=null
                    &&  String.isBlank(objPayment.nm_Lead__c)  && String.isNotBlank(objPayment.nm_OpportunityNew__c))
                {
                    objPayment.nm_PaymentStatus__c='Payment Approved';
                    lstOfPaymentRecordToUpdate.add(objPayment);
                    Opportunity opp = new Opportunity(Id = objPayment.nm_OpportunityNew__c) ;
                    opp.Update_Course_List_Batch__c = false;
                    lstOfOpportunityRecordToUpdate.add(opp);
                    
                }
            }
            
            if(lstOfPaymentRecordToUpdate.size()>0)
            {
                update lstOfPaymentRecordToUpdate;
                update lstOfOpportunityRecordToUpdate;
                // Database.executeBatch(new SendCourseListBatch());
            }
        }
    }

    @future (callout=true)
    public static void callCourseraAPI(String studentNo,String OppId) { 
        String jsonString = '{"sapId":"'+studentNo.trim()+'"}';
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = jsonString;
        apiReq.Opportunity__c = OppId;
        apiReq.Type_of_Request__c = 'PortalAPI';
        apiReq.API_Name__c = 'CourseraPortalSync';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(System.Label.Backlog_Api+'coursera/m/courseraPortalSync');
        // req.setEndpoint('https://studentzone-ngasce.nmims.edu/coursera/m/courseraPortalSync');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonString);
        req.setTimeout(120000);
        try {
            res = http.send(req);
            String response = res.getBody();
            System.debug('response ==>'+response);
            Map<String,String> mapOfResponse = (Map<String, String>)JSON.deserialize(response, Map<String, String>.class);
            apiReq.Response__c = response;
            if(res.getStatusCode() == 200 && mapOfResponse.containsKey('status') && mapOfResponse.get('status') == 'success'){
                apiReq.Success__c = true;
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            apiReq.Response__c = res.getBody();
        }
        apiRequestsInsertion(apiReq);
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

  /*  @future
    public static void checkLeadConvert(Set<String> paymentId){
        list<nm_Payment__c> lstAllPayment = new list<nm_Payment__c>();
        Map<Id,nm_Payment__c>  mapofRegistrationPayment = new Map<id,nm_Payment__c>([select id, nm_PaymentStatus__c,nm_PaymentType__c,nm_Lead__c,nm_OpportunityNew__c from nm_Payment__c where id =: paymentid ]);
        lstAllPayment = mapofRegistrationPayment.values();
        Map<Id,Id> MapOfPayvsLeadIds = new Map<Id,Id>();
        Set<String> setOfConvertedIds = new Set<String>();
        List<nm_Payment__c> updatePayments = new List<nm_Payment__c>();

        if(lstAllPayment.size()>0){
            for(nm_Payment__c pay:lstAllPayment){
                MapOfPayvsLeadIds.put(pay.Id,pay.nm_Lead__c);
            }
            List<Lead> lstlead = [SELECT id from Lead WHERE id IN:MapOfPayvsLeadIds.values() and IsConverted=true]; 
            if(lstlead.size()>0){
                for(Lead ld:lstlead){
                    setOfConvertedIds.add(ld.id);
                }

                List<Opportunity> lstOpp = [SELECT Id,AccountId, Account.nm_LeadId__c from Opportunity Where Account.nm_LeadId__c=:setOfConvertedIds];
                Map<Id,Id> mapOfLeadIdvsoppIds = new Map<Id,Id>();
                if(lstOpp.size()>0){
                    for(Opportunity opp:lstOpp){
                        mapOfLeadIdvsoppIds.put(opp.Account.nm_LeadId__c,opp.Id);
                    }
                }

                for(nm_Payment__c pay:lstAllPayment){
                    if(mapOfLeadIdvsoppIds.containsKey(pay.nm_Lead__c)){
                        pay.nm_OpportunityNew__c = mapOfLeadIdvsoppIds.get(pay.nm_Lead__c);
                        pay.nm_Lead__c = '';
                        updatePayments.add(pay);
                    }
                }
               
            }

            if(updatePayments.size()>0){
                try{
                    update updatePayments;
                }catch(DMLException e){
                    System.debug('Error:: '+e.getMessage());
                }
            }
        }
        
    }*/

    public void updateLookupOnConversion(List <nm_Payment__c> lstPayment,map<id,nm_Payment__c> oldMap){
        Set<String> setofleadId = new Set<String>();

        if(lstPayment.size()>0){
            for(nm_Payment__c objPayment : lstPayment){
                System.debug('objPayment.nm_PaymentType__c '+objPayment.nm_PaymentType__c+'objPayment.nm_PaymentStatus__c '+objPayment.nm_PaymentStatus__c+' old payment status '+oldMap.get(objPayment.id).nm_PaymentStatus__c+' old lead '+oldMap.get(objPayment.id).nm_Lead__c+' new lead '+objPayment.nm_Lead__c);
                if('Registration'.equalsIgnoreCase(objPayment.nm_PaymentType__c) && 'Payment Approved'.equalsIgnoreCase(objPayment.nm_PaymentStatus__c) && oldMap.get(objPayment.id).nm_PaymentStatus__c == 'Payment Made' && objPayment.nm_Lead__c != null){
                    setofleadId.add(objPayment.nm_Lead__c);
                    // if(oldMap.get(objPayment.id).nm_Lead__c != null)
                    // {
                    //     setofleadId.add(oldMap.get(objPayment.id).nm_Lead__c);
                    // }
                    
                }
            }
            System.debug('setofleadId '+setofleadId);
            if(setofleadId.size()>0){
                DateTime dt = System.now();
                DateTime earlier = dt.addMinutes(-10);
                system.debug('dt '+dt+' earlier '+earlier);
                List<nm_Payment_Initiated__c> lstpayInit = [SELECT ID,nm_Lead__c,nm_Amount__c,nm_ActualPaymentAmmount__c,nm_PaymentStatus__c from nm_Payment_Initiated__c WHERE nm_PaymentStatus__c='Payment Initiated' and nm_PaymentType__c!='Registration' and CreatedDate <:dt and CreatedDate >:earlier and nm_Lead__c IN:setofleadId and nm_Lead__r.nm_ChooseaProgram__c != 'Master Programs'];
                System.debug('lstpayInit '+lstpayInit.size());
                if(lstpayInit.size()>0){

                    for(nm_Payment__c objPayment : lstPayment){
                        nm_Payment__c actualRecord = (nm_Payment__c)Trigger.newMap.get(objPayment.Id); 
                        actualRecord.addError('Another Transaction is in progress, please wait for while...'); 
                    }
                }
            }
        }
    }

    public void checkForDuplicateUTR(List <nm_Payment__c> lstPayment, map<id,nm_Payment__c> oldMap,String activity) {
        set<String> setOfUtrUnique = new Set<String>();
        set<String> setOfOppId = new Set<String>();
        set<String> setOfUTR = new Set<String>();
        set<String> setOfPaymentStatus = new Set<String>{'Payment Approved', 'Payment Made'};
        Map<String, set<String>> mapOfUTRVsSetAccId = new Map<String, set<String>>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        for (nm_Payment__c objPay : lstPayment) {
            if (!objPay.Allow_Duplicate_UTR__c && ((activity == 'INSERT' || (activity == 'UPDATE' && oldMap.containsKey(objPay.Id)&& String.isNotBlank(objPay.nm_Merchant_Track_Id__c) && objPay.nm_Merchant_Track_Id__c != oldMap.get(objPay.Id).nm_Merchant_Track_Id__c  ) ) && String.isNotBlank(objPay.nm_PaymentStatus__c) && setOfPaymentStatus.contains(objPay.nm_PaymentStatus__c) && String.isNotBlank(objPay.nm_Merchant_Track_Id__c) && objPay.nm_ModeOfPayment__c != null && objPay.nm_ModeOfPayment__c.contains('NEFT')) ) {
                setOfOppId.add(objPay.nm_OpportunityNew__c);
                setOfUTR.add(objPay.nm_Merchant_Track_Id__c);
                lstPay.add(objPay);
            }
        }
        if (!setOfOppId.isEmpty()) {
            for (nm_Payment__c obPay : [SELECT Id, nm_PaymentType__c, nm_AccountID__c, nm_Merchant_Track_Id__c, nm_ModeOfPayment__c, nm_OpportunityNew__c FROM nm_Payment__c WHERE (nm_OpportunityNew__c IN :setOfOppId OR nm_Merchant_Track_Id__c IN :setOfUTR) AND nm_OpportunityNew__c != null AND nm_Merchant_Track_Id__c != null  AND (Not nm_PaymentType__c LIKE '%Additional Charge%') AND nm_PaymentStatus__c IN :setOfPaymentStatus]) {
                setOfUtrUnique.add((String.valueOf(obPay.nm_OpportunityNew__c)) + '-' + obPay.nm_Merchant_Track_Id__c + '-' + obPay.nm_PaymentType__c);
                set<String> setUTRVsSetAccId = mapOfUTRVsSetAccId.containsKey(obPay.nm_Merchant_Track_Id__c) ?  mapOfUTRVsSetAccId.get(obPay.nm_Merchant_Track_Id__c) : new set<String>();
                setUTRVsSetAccId.add(obPay.nm_AccountID__c);
                mapOfUTRVsSetAccId.put(obPay.nm_Merchant_Track_Id__c, setUTRVsSetAccId);



            }
            for (nm_Payment__c objPay : lstPay) {
                    
                    if (setOfUtrUnique.contains((String.valueOf(objPay.nm_OpportunityNew__c)) + '-' + objPay.nm_Merchant_Track_Id__c + '-' + objPay.nm_PaymentType__c)) {
                        objPay.addError('Duplicate payment found with same UTR number.');
                    } else if(mapOfUTRVsSetAccId.containsKey(objPay.nm_Merchant_Track_Id__c)) {
                        if (!(mapOfUTRVsSetAccId.get(objPay.nm_Merchant_Track_Id__c)).contains(objPay.nm_AccountID__c)) {
                            objPay.addError('Duplicate payment found with same UTR number on different account.');
                        } else if ((mapOfUTRVsSetAccId.get(objPay.nm_Merchant_Track_Id__c)).contains(objPay.nm_AccountID__c) && objPay.nm_PaymentType__c != 'Admission') {
                            objPay.addError('Duplicate payment found with same UTR number, on different opportunity.');
                        }
                    }

            }

       
        }
    }
}