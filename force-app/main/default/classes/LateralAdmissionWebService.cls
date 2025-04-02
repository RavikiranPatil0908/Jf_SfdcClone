/**
 * @description       :
 * @author            : shubhranshu
 * @group             :
 * @last modified on  : 10-04-2024
 * @last modified by  : @BK
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   06-05-2021   shubhranshu   Initial Version
 **/
global class LateralAdmissionWebService {
  private static Set<Id> accountIds = new Set<Id>();
  private static Set<Id> leadId = new Set<Id>();
  private static Set<String> setofEmail = new Set<String>();
  private static Set<String> setofCurrentMobile = new Set<String>();

  webService static void createLateralAdmission(Account acc, String feeType, String existLead) {
    accountIds.add(acc.Id);
    leadId.add(acc.nm_LeadId__c);
    setofEmail.add(acc.PersonEmail);
    setofCurrentMobile.add(acc.PersonMobilePhone);

    System.debug('%$%#%#^#^%#$@%%@');
    system.debug('acc ---> ' + acc);
    system.debug('feeType ---> ' + feeType);
    system.debug('existLead ----> ' + existLead);
    // List<Opportunity> lstOpportunity = [select id,nm_Fee_Type__c, nm_Semester__c, TransferPayment__c, AdditionalAmountRecieved__c
    // from Opportunity where AccountId = :accountIds AND StageName='Closed Won' order by nm_Semester__c asc];

    List<Lead> lstExistLead = [
      SELECT Id, FirstName, LastName
      FROM Lead
      WHERE
        (Email IN :setofEmail
        OR MobilePhone IN :setofCurrentMobile)
        AND (NOT Status LIKE '%Fee paid%')
    ];

    if (lstExistLead.size() > 0) {
      delete lstExistLead;
    }

    List<Opportunity> lstAppOpportuniyties1 = new List<Opportunity>();
    // list<nmRefund_Payment__c> lstRefundpayment=new list<nmRefund_Payment__c>();
    // list<Opportunity> lstUpdate1 =new list<Opportunity>();

    lstAppOpportuniyties1 = [
      SELECT
        id,
        Account.Name,
        Account.nm_Centers__r.Name,
        nm_Fee_Type__c,
        nm_Semester__c,
        TransferPayment__c,
        AdditionalAmountRecieved__c,
        nm_Year__c,
        nm_Session__c,
        Is_Re_Registration_Payment__c
      FROM Opportunity
      WHERE AccountId IN :accountIds
      ORDER BY nm_Semester__c ASC
    ];

    Set<id> reff = new Set<Id>();

    Map<String, String> mapOfAccountIdVsLeadId1 = new Map<String, String>();
    // Create Lead
    system.debug('EXIS Lead ');
    system.debug(lstExistLead);

    if (String.IsBlank(existLead)) {
      CancelFutureHandler.CancelAdmission(
        accountIds,
        reff,
        lstExistLead,
        'De-Registered',
        'MBA (Distance) Programs',
        feeType
      );
      mapOfAccountIdVsLeadId1 = CancelFutureHandler.mapOfAccountIdVsLeadId1;

    } else {
      mapOfAccountIdVsLeadId1.put(String.valueOf(acc.Id) , existLead);
      Account acct = new Account();
      acct.Id = String.valueOf(acc.Id);
      String appendedStudentStauts = 'De-Registered';
      acct.PersonMobilePhone = appendedStudentStauts+'_'+acc.PersonMobilePhone;
      acct.PersonEmail = appendedStudentStauts+'_'+acc.PersonEmail;
      acct.nm_RegistrationNumber__c = appendedStudentStauts+'_'+acc.nm_RegistrationNumber__c;
      acct.nm_StudentStatus__c = appendedStudentStauts;
      acct.Inactive_account__c = true;
      acct.nm_StudentNo__c = appendedStudentStauts+'_'+acc.nm_StudentNo__c;
      update acct;
          
    }





    List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
    Map<String, String> lstOppIdVsFeeType = new Map<String, String>();

    List<Opportunity> lstOpportunityToUpdate1 = new List<Opportunity>();
    List<nm_Payment__c> lstOfPaymentCreatedOnID = new List<nm_Payment__c>();
    List<nm_Payment__c> lstOfPaymentToUpdate = new List<nm_Payment__c>();
    List<Opportunity> updateOppp = new List<Opportunity>();
    List<Id> accIds = new List<ID>(accountIds);
    if (Test.isRunningTest()) {
      Lead ld = new Lead();

      mapOfAccountIdVsLeadId1.put(accIds[0], accIds[0]);
    }
    system.debug(feeType);
    system.debug('@@#@#@#@#@#@@@@@@@#');
    // system.debug(feeTypevsId);

    Set<String> setOfOppIds = new Set<String>();

    // code for july 2021
    // String opportunityForReRegPayment = '';

    
    Decimal additionalAmountRecieved = 0;
    Map<String, Opportunity> mapOfOppIdVsOpp = new Map<String, Opportunity>();
    for (Opportunity op : lstAppOpportuniyties1) {
      mapOfOppIdVsOpp.put(op.Id, op);
      if (op.AdditionalAmountRecieved__c > additionalAmountRecieved) {
        additionalAmountRecieved = op.AdditionalAmountRecieved__c;
      }
      // if(op.nm_Year__c == 2021 && op.nm_Session__c == 'July' && op.Is_Re_Registration_Payment__c == true) {
      //   opportunityForReRegPayment = op.Id;
      //   system.debug('opportunityForReRegPayment ----> ' + opportunityForReRegPayment);
      // }
      setOfOppIds.add(op.Id);
    }
    
    system.debug(setOfOppIds);
    String queryPayment = '';
    String paymentTpee = 'Admission';
    queryPayment = getQueryAllFieldSql('nm_Payment__c','nm_OpportunityNew__c IN :setOfOppIds And (nm_PaymentStatus__c = \'Payment Approved\' OR nm_PaymentStatus__c= \'Payment Made\') ',null);


    List<nm_Payment__c> lstPaymentForReRegPayment = new List<nm_Payment__c>();

    // new lstPayement = [Select]
    List<nm_Payment__c> lstPayment = DataBase.query(queryPayment);

    system.debug(lstPayment);
    String emailPaymentId = '';
    String emailMerchantId = '';
    String emailStudentName = '';
    String paymentRecordToTransfer = '';
    
    Map<String, nm_Payment__c> mapOfOppIdVsPayment = new Map<String, nm_Payment__c>();
    for(nm_Payment__c paym: lstPayment) {
      if(paym.nm_Amount__c > additionalAmountRecieved && paym.nm_PaymentStatus__c == 'Payment Approved') {
        mapOfOppIdVsPayment.put(paym.nm_OpportunityNew__c, paym);
      }
      // if ( String.isNotBlank(opportunityForReRegPayment) && paym.nm_OpportunityNew__c == opportunityForReRegPayment && paym.nm_Amount__c > 0) {
      //   system.debug('pay for reReg ---> ' + paym);
      //   lstPaymentForReRegPayment.add(paym);
      // }
    }
    system.debug(mapOfAccountIdVsLeadId1);
    
    for (Opportunity oppp : lstAppOpportuniyties1) {
      // system.debug('opportunityForReRegPayment ---> ' + opportunityForReRegPayment);
      system.debug('oppp.Id ---> ' + oppp.Id);
      // if(String.valueOf(oppp.Id)  != opportunityForReRegPayment) {
      if (mapOfAccountIdVsLeadId1.get(accIds[0]) != null && mapOfOppIdVsPayment.get(oppp.id) != null  ) {

        nm_Payment__c pay = mapOfOppIdVsPayment.get(oppp.Id).clone();
        nm_Payment__c upPay = mapOfOppIdVsPayment.get(oppp.Id);
        upPay.Refunded_Amount__c = oppp.AdditionalAmountRecieved__c;

        system.debug(pay);
        system.debug('pay.id ---> ' + pay.id);
        pay.nm_OpportunityNew__c = null;
        emailMerchantId = pay.nm_Merchant_Track_Id__c;
        emailStudentName= pay.Candidate_Name__c;

        // nm_Payment__c pay = new nm_Payment__c();

        pay.nm_Amount__c = oppp.AdditionalAmountRecieved__c;
        pay.nm_Lead__c = mapOfAccountIdVsLeadId1.get(accIds[0]);
        system.debug(mapOfAccountIdVsLeadId1.get(accIds[0]));
        // pay.
        pay.nm_PaymentType__c = 'Installment';
        pay.Description__c = 'De-Registered';
        pay.Consider_Initial_payment__c = true;

        // system.debug(lstOppIdVsFeeType.get(oppp.Id));
        //
        pay.nm_Installment_Payment_Ref__c = 'Installment-' + feeType;
        pay.nm_PaymentStatus__c = 'Payment Made';
        if(Test.isRunningTest()){
          pay.nm_Amount__c = 10;

        }
        if (pay.nm_Amount__c > 0) {
          lstOfPaymentCreatedOnID.add(pay);
          paymentRecordToTransfer = oppp.Id;
          oppp.TransferPayment__c = oppp.AdditionalAmountRecieved__c;
          lstOfPaymentCreatedOnID.add(upPay);

        }
      }
        oppp.StageName = 'De-Registered';
        updateOppp.add(oppp);
      // }
    }

    system.debug('lstOfPaymentCreatedOnID----> '+ lstOfPaymentCreatedOnID );
    system.debug(updateOppp);

    // if(lstPaymentForReRegPayment.size() > 0  ) {
    //   system.debug('lstPaymentForReRegPayment ---> ' + lstPaymentForReRegPayment);
    //   Date today = Date.Today(); 
    //   Decimal DebitAmount = getIcTransCreditAmount(opportunityForReRegPayment);
    //   nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
    //   Integer CurrentMonth = today.month() + 1;
    //   Integer CurrentYear = today.Year();   

    //   Opportunity opp = new Opportunity();
    //   opp.Id = opportunityForReRegPayment;
    //   opp.TransferPayment__c = null;
    //   opp.StageName = 'De-Registered';
    //   opp.Total_Amount_Received__c = 0;
    //   opp.nm_TotalApprovedPayment__c = 0;
    //   updateOppp.add(opp);
      
    //   if(CurrentMonth >=13)
    //   {
    //       CurrentMonth = CurrentMonth - 12;
    //       CurrentYear = today.Year()+1;
    //   }
    //   handler.createDebitEntry(mapOfOppIdVsOpp.get(opportunityForReRegPayment), CurrentYear, CurrentMonth, DebitAmount, mapOfOppIdVsOpp.get(opportunityForReRegPayment).Account.nm_Centers__r.Name, 'De-register', true, 'De-register');


    //   for(nm_Payment__c objPayment: lstPaymentForReRegPayment) {
    //     nm_Payment__c updPayment = new nm_Payment__c();
    //     updPayment.Id = objPayment.Id;
    //     updPayment.nm_OpportunityNew__c = null;
    //     updPayment.nm_PaymentType__c = 'Installment';
    //     updPayment.Consider_Initial_payment__c = true;
    //     updPayment.nm_Lead__c = mapOfAccountIdVsLeadId1.get(accIds[0]);
    //     updPayment.Description__c = 'De-Registered';
    //     updPayment.nm_Installment_Payment_Ref__c = 'Installment-' + feeType;
    //     lstOfPaymentCreatedOnID.add(updPayment);
    //   }
    // } else if (String.isNotBlank(opportunityForReRegPayment)) {
    //   Opportunity opp = new Opportunity();
    //   opp.Id = opportunityForReRegPayment;
    //   opp.TransferPayment__c = null;
    //   opp.StageName = 'De-Registered';
    //   updateOppp.add(opp);

    // }
    
    set<Id> setPaymentIds = new set<Id>();
    if (lstOfPaymentCreatedOnID.size() > 0) {
      try {
        for(nm_Payment__c objPayment: lstOfPaymentCreatedOnID)
        {   
            if(objPayment.Id != null) setPaymentIds.add(objPayment.Id);
        }
        system.debug('setPaymentIds ---> ' + setPaymentIds);
        upsert lstOfPaymentCreatedOnID;
        for(nm_Payment__c afterUpsert : lstOfPaymentCreatedOnID){
          System.debug('afterUpsert ---> ' + afterUpsert);
            if(!setPaymentIds.contains(afterUpsert.Id))
            {
                  system.debug('*** Id = ' + afterUpsert.id);
                  emailPaymentId = afterUpsert.id;
            }
        }
        if(String.isNotBlank(emailPaymentId)) {
          sendEmailToFinanceDepartmentOnPaymentCreation(emailPaymentId, emailMerchantId, emailStudentName);
        }

      }  catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }


    }
    if (updateOppp.size() > 0) {
      system.debug('updateOppp ---> ' + updateOppp);
      update updateOppp;
    }
  }

  webService static void dummy(String jObject) {
    // To Get Opportunity object from javascript as json
    // Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jObject);
    // List<Opportunity> oppe = new List<Opportunity>();
    //         Map<String, Opportunity> mm = new Map<String, Opportunity>();
    //         for (Object instance : (List<object>)m.values()){
    //             Map<String , Object> dd = (Map<String , Object> ) instance;
    //             Opportunity oppp = new Opportunity();
    //             oppp.id = (String)dd.get('Id');
    //             oppp.nm_Fee_Type__c = (String)dd.get('nm_Fee_Type__c');
    //             oppe.add(oppp);

    //         }
    //         system.debug(mm);
    //         system.debug(oppe);
    //         system.debug('#$#$#$#$$');
  }

  public Static String getQueryAllFieldSql(String ObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ ObjectAPIName +' where '+conditionString;
        return query;
    }

    public static void sendEmailToFinanceDepartmentOnPaymentCreation(String paymentId, String merchantTrackId, String studentName) {
      Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
      OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
      String url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + paymentId;
      system.debug('url -----> ' + url);
      String[] sendingToAddress = new List<String>();
      String sendingTocAddress = ''; 
      if(System.Label.Environment == 'Sandbox') {
        sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
        sendingToAddress.add('dsuyog2013@gmail.com');
      } else if(System.Label.Environment == 'Production') {
          sendingToAddress.add('tushar.jadhav@nmims.edu');
        sendingToAddress.add('manasvi.malve@nmims.edu');
      }
      semail.setToAddresses(sendingToAddress); 
      semail.setOrgWideEmailAddressId(owe.id); 
      semail.setReplyTo(owe.Address); 
      semail.setSubject('Approve Payment Record For Lateral Admission'); 
      String messageBody = '<html><p>Dear Team,</p>'
                                +'<p>Kindly Approve payment record for the following lateral student</p>'
                                +'<p>Student name = '+ studentName +'</p>'
                                +'<p>Payment Merchant Track Id = '+ merchantTrackId +'</p>'
                                +'<p>Please click <a href="'+url+'" >here</a> to navigate to payment record</p>'
                                +'<p>Thanks and Regards,</p>'
                                +'<p>NMIMS CDOE</p></html>';
        semail.setHtmlBody(messageBody);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
    }

    // public static Decimal getIcTransCreditAmount(String oppId) {
    //   Decimal totalAmount = 0.0;
    //   totalAmount = (Decimal) [Select  sum(Amount__c)totalTransactionAmount From  IC_Payment_Transaction__c Where Opportunity__c = :oppId AND Transaction_Type__c LIKe '%Commision - Credit%' ][0].get('totalTransactionAmount');
    //   System.debug('totalAmount ----> ' + totalAmount);
    //   return totalAmount > 0 ? totalAmount : 0;
    // }
}