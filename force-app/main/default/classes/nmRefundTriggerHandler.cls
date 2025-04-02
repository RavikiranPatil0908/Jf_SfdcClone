/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @BK
**/
public class nmRefundTriggerHandler{

    public static boolean IsAfterUpdateRunOnce = false;
    public static Boolean IsBeforeInsertRunOnce = false;

    public void AfterInsert(List<nmRefund_Payment__c> triggerNew, map<id, nmRefund_Payment__c> mapNewMap) {
        changeTotalRefundStatus(triggerNew, mapNewMap, 'INSERT');
    }
    
    public void AfterUpdate(List<nmRefund_Payment__c> triggerNew, map<id, nmRefund_Payment__c> mapRefundOldMap) {
        if(IsAfterUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        IsAfterUpdateRunOnce = true;
        UpdateNEFTDetails(triggerNew, mapRefundOldMap, 'Update');
        ApplicationRejectedUpdateDetails(triggerNew, mapRefundOldMap);
        changeTotalRefundStatus(triggerNew, mapRefundOldMap, 'UPDATE');
    }
    /*   public void BeforeUpdate(List<nmRefund_Payment__c> triggerNew, map<id, nmRefund_Payment__c> mapRefundOldMap)
    {
    }*/
    
    public void BeforeInsert(List<nmRefund_Payment__c> triggerNew, map<id, nmRefund_Payment__c> mapNewMap) {
        if(IsBeforeInsertRunOnce && triggerNew.size() < 25){// checking triggerNew size as data load from dataLoader it shoul be geater than 25 records at time to avoid unProcessing of records greater than 200 records 
            return;
        }
        IsBeforeInsertRunOnce = true;
        UpdateNEFTDetails(triggerNew, mapNewMap, 'Insert');
    }
    
      public void beforeDelete(list<nmRefund_Payment__c> triggerOld){
          for(nmRefund_Payment__c ob:triggerOld)
        {
            if(ob.Status__c=='Payment Refunded' || ob.Status__c=='Refund Submitted to Finance')
             {
                 {
            system.debug('inside b4Delete');
             nmRefund_Payment__c nmRecord = (nmRefund_Payment__c)Trigger.oldMap.get(ob.Id); 
             system.debug('nmRecord==>'+nmRecord);
             nmRecord.addError('Insufficient Rights Can Not Delete');
         }
             }
            
         }
      }
    
    public nmRefundTriggerHandler(){
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queriedxc  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' +  Limits.getLimitFutureCalls());
    }
   /*  public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    } */



    /**
    * @description 
    * @author @BK | 06-03-2023 
    * @param lstRefund 
    * @param mapRefundOldMap 
    * @param activity 
    **/
    public void UpdateNEFTDetails(List<nmRefund_Payment__c>lstRefund, map<id, nmRefund_Payment__c> mapRefundOldMap, String activity) {
        Map<Id,String> mapofIdvsLoanType = new Map<Id,String>();
        Boolean checkIfInsertLoanType = false;
        if(lstRefund.size() > 0) {
            for (nmRefund_Payment__c objRefund:lstRefund ) {
                if(mapRefundOldMap != null && activity.equals('Update')) {
                    if((objRefund.Refund_to_Loan_Provider__c != mapRefundOldMap.get(objRefund.id).Refund_to_Loan_Provider__c && objRefund.Refund_to_Loan_Provider__c && objRefund.Name_of_loan_provider__c !=null) ||
                    (objRefund.Name_of_loan_provider__c!= mapRefundOldMap.get(objRefund.id).Name_of_loan_provider__c && objRefund.Name_of_loan_provider__c !=null && objRefund.Refund_to_Loan_Provider__c)) {
                        mapofIdvsLoanType.put(objRefund.id,objRefund.Name_of_loan_provider__c);
                    }
                } 
                else if(activity.equals('Insert') && objRefund.Refund_to_Loan_Provider__c && String.isNotBlank(objRefund.Name_of_loan_provider__c)) {
                    checkIfInsertLoanType = true;
                }
            }
        }
        if(mapofIdvsLoanType.size() > 0 || checkIfInsertLoanType) {
            List<Loan_Provider_NEFT__mdt> loanProviderList = [select id,Account_Holder_name__c,Account_Number__c,Bank_Location__c,IFSC_Code__c,Name_of_the_Bank__c,DeveloperName from Loan_Provider_NEFT__mdt];
            Map<String,Loan_Provider_NEFT__mdt> mapofLoanProvider = new Map<String,Loan_Provider_NEFT__mdt>();
            if(loanProviderList.size() > 0) {
                for(Loan_Provider_NEFT__mdt objLstLoanProvider : loanProviderList) {
                    mapofLoanProvider.put(objLstLoanProvider.DeveloperName,objLstLoanProvider);
                }
            }

            if(activity.equals('Update')) {
                updateLoanNEFTDetails(mapofIdvsLoanType, mapofLoanProvider);
            } else if(activity.equals('Insert')) {
                for (nmRefund_Payment__c objRefund : lstRefund ) { 
                    if(objRefund.Refund_to_Loan_Provider__c && String.isNotBlank(objRefund.Name_of_loan_provider__c)) {
                        objRefund = setLoanNEFTDetails(objRefund,mapofLoanProvider);
                    }
                }
            }
        }
    }


    /**
    * @description 
    * @author @BK | 06-03-2023 
    * @param mapofIdvsLoanType 
    * @param mapofLoanProvider 
    **/
    public void updateLoanNEFTDetails(Map<Id,String> mapofIdvsLoanType, Map<String,Loan_Provider_NEFT__mdt> mapofLoanProvider) {
        try {
            List<nmRefund_Payment__c> lstRefundtoUpdate = new List<nmRefund_Payment__c> ();
            List<nmRefund_Payment__c> lstRefund = [select id,Account_Number__c,Account_Holder_name__c,IFSC_Code__c,nm_Bank_Location__c,nm_Name_of_the_Bank__c,Name_of_loan_provider__c from nmRefund_Payment__c where id=:mapofIdvsLoanType.keyset()];
            if(lstRefund.size() > 0) {
                System.debug('lstRefund2--->'+lstRefund);
                for(nmRefund_Payment__c objRefundRec :lstRefund) {
                    objRefundRec = setLoanNEFTDetails(objRefundRec,mapofLoanProvider);
                    lstRefundtoUpdate.add(objRefundRec);
                }
            }
            if(lstRefundtoUpdate.size() > 0) {
                update lstRefundtoUpdate;
            }
        } catch (Exception error) {
            System.debug('Error ==>'+error.getMessage());
        }
        
    }

    /**
    * @description : Set Loan NEFT Details
    * @author @BK | 06-03-2023 
    * @param objRefundRec 
    * @param mapofLoanProvider 
    * @return nmRefund_Payment__c 
    **/
    public nmRefund_Payment__c setLoanNEFTDetails(nmRefund_Payment__c objRefundRec, Map<String,Loan_Provider_NEFT__mdt> mapofLoanProvider) {
        objRefundRec.Account_Holder_name__c = mapofLoanProvider.get(objRefundRec.Name_of_loan_provider__c).Account_Holder_name__c;
        objRefundRec.Account_Number__c = mapofLoanProvider.get(objRefundRec.Name_of_loan_provider__c).Account_Number__c;
        objRefundRec.nm_Bank_Location__c = mapofLoanProvider.get(objRefundRec.Name_of_loan_provider__c).Bank_Location__c;
        objRefundRec.nm_Name_of_the_Bank__c = mapofLoanProvider.get(objRefundRec.Name_of_loan_provider__c).Name_of_the_Bank__c;
        objRefundRec.IFSC_Code__c = mapofLoanProvider.get(objRefundRec.Name_of_loan_provider__c).IFSC_Code__c;
        objRefundRec.Relationship__c ='Self';
        return objRefundRec;
    }
    
        public void ApplicationRejectedUpdateDetails(List<nmRefund_Payment__c>lstRefund, map<id, nmRefund_Payment__c> mapRefundOldMap) {
        List<nmRefund_Payment__c> lstRefundUpdate = new List<nmRefund_Payment__c>();
         if(lstRefund.size() > 0) {
            for (nmRefund_Payment__c objRefund:lstRefund ){
                if(mapRefundOldMap != null) {
                    if(objRefund.Status__c != mapRefundOldMap.get(objRefund.id).Status__c &&  String.isNotBlank(objRefund.Status__c) && objRefund.Status__c.contains('Application Rejected'))
                    {
                        if(objRefund.Status__c=='Application Rejected - Invalid Signature')
                        {
                            nmRefund_Payment__c obj = new nmRefund_Payment__c (id = objRefund.id);
                            obj.Signature_Image_Url__c = '';
                            lstRefundUpdate.add(obj);
                        }else if(objRefund.Status__c =='Application Rejected - Invalid Bank Detail')
                        {
                            nmRefund_Payment__c obj1 = new nmRefund_Payment__c (id = objRefund.id);
                            obj1.Account_Holder_name__c ='';
                            obj1.Account_Number__c = '';
                            obj1.nm_Bank_Location__c = '';
                            obj1.nm_Name_of_the_Bank__c = '';
                            obj1.IFSC_Code__c = '';
                            obj1.Relationship__c = '';
                            obj1.Cancel_Cheque_Document_Upload__c='';
                           lstRefundUpdate.add(obj1);

                        }
                    }                   
                }
            }
         
         if(lstRefundUpdate.size()>0)
         {
             update lstRefundUpdate;
         }
}
}

    public void changeTotalRefundStatus(List<nmRefund_Payment__c>lstRefund, map<id, nmRefund_Payment__c> mapRefundOldMap, String activity) {
        system.debug('changeTotalRefundStatus --> ' );
        Map<String, RefundStatusObject> mapOfIdVsLstRefundPay = new Map<String, RefundStatusObject>();
        Set<String> setOfOppId = new Set<String>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        if(lstRefund.size() > 0) {
            for (nmRefund_Payment__c objRefund:lstRefund ){
                if (objRefund.Opportunity__c != null &&(activity == 'INSERT' || (activity == 'UPDATE' && objRefund.nm_Payment_Status__c == 'Payment Refunded' && objRefund.nm_Payment_Status__c != mapRefundOldMap.get(objRefund.Id).nm_Payment_Status__c))) {
                    setOfOppId.add(objRefund.Opportunity__c);
                }
            }
            if (setOfOppId.size() > 0) {
                for(nmRefund_Payment__c objRef : [SELECT Id, nm_Payment_Status__c, Opportunity__c FROM nmRefund_Payment__c WHERE Opportunity__c IN :setOfOppId]) {
                    RefundStatusObject RefundStatusObject = mapOfIdVsLstRefundPay.containsKey(objRef.Opportunity__c) ? mapOfIdVsLstRefundPay.get(objRef.Opportunity__c) : new RefundStatusObject();
                    RefundStatusObject.lstRefPayRecord = RefundStatusObject.lstRefPayRecord + 1;
                    RefundStatusObject.paymentRefundCount = objRef.nm_Payment_Status__c == 'Payment Refunded' ? RefundStatusObject.paymentRefundCount + 1 : RefundStatusObject.paymentRefundCount;
                    mapOfIdVsLstRefundPay.put(objRef.Opportunity__c, RefundStatusObject);
                }
                system.debug('mapOfIdVsLstRefundPay --> ' + JSON.serialize(mapOfIdVsLstRefundPay));
                
                for (String oppId : mapOfIdVsLstRefundPay.keySet()) {
                    RefundStatusObject RefundStatusObject = mapOfIdVsLstRefundPay.get(oppId);
                    system.debug('oppId --> ' + oppId + ' -- '  + JSON.serialize(RefundStatusObject));
                    lstOppToUpdate.add(new Opportunity(Id = oppId, Total_Refund_Status__c = totalRefundStatus(RefundStatusObject.lstRefPayRecord, RefundStatusObject.paymentRefundCount)));
                }
            }
        }
        if(lstOppToUpdate.size() > 0) {
            update lstOppToUpdate;
        }

    }

    public String totalRefundStatus(integer totalRefundRecord, integer payRefundRecord) {
        return payRefundRecord == 0 ? 'Pending' : totalRefundRecord != payRefundRecord ? 'Partial Refunded' :'Refunded';
    }

    public class RefundStatusObject {
        public Integer lstRefPayRecord {get; set;}
        public integer paymentRefundCount {get;set;}

        public RefundStatusObject() {
            this.lstRefPayRecord = 0;
            this.paymentRefundCount = 0;
        }
    }
}