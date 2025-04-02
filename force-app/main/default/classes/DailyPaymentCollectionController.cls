/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-05-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-03-2021   @BK   Initial Version
**/
public class DailyPaymentCollectionController {

    public List<nm_Payment__c> lstPayments {get;set;}
    public Decimal totalRecords {get;set;}
    public Decimal totalAmount {get;set;}
    public Map<String,Decimal> mapOfLCVsTotal {get;set;}
    public Set<String> keyValues {get;set;}

    public DailyPaymentCollectionController() {
        lstPayments = new List<nm_Payment__c>();
        totalRecords = 0;
        totalAmount = 0;
        mapOfLCVsTotal = new Map<String,Decimal>();
        keyValues = new Set<String>();
        getPaymentRecords();
    }

    public void getPaymentRecords() {
        List<String> paymentStatus = new List<String>{'Payment Made','Payment Approved'};
        List<String> ICName = new List<String>{'Emerson','Cipla','Bajaj', 'RateGain Travel Technologies Ltd.'};
        List<String> StudentStatus = new List<String>{'Admission Cancelled','Registration Cancelled'};

        lstPayments = [SELECT id,Name,Candidate_Name__c,nm_Lead_Name__c,nm_Lead__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Name,nm_PaymentType__c,
        IC_Name__c,Validity_Extension__c,Validity_Extension__r.Name,nm_ModeOfPayment__c,nm_PaymentGatewayName__c,nm_PaymentStatus__c,LCName__c,
        nm_Amount__c,CreatedBy.Name FROM nm_Payment__c WHERE nm_PaymentStatus__c IN :paymentStatus AND Student_Status__c NOT IN :StudentStatus
        AND IC_Name__c NOT IN :ICName AND Opportunity_Stage__c != 'Closed Won - Re-registration Pending' AND CreatedDate = TODAY ORDER BY LCName__c, IC_Name__c];

        totalRecords = lstPayments.size();
        System.debug('lstPayments.size() ==>'+totalRecords);
        getTotalCount(lstPayments);
    }


    public void getTotalCount(List<nm_Payment__c> lstPayments) {
        decimal total = 0;
        
        for(nm_Payment__c objPayment : lstPayments){
            Decimal totalByLC = 0;
            String key = (objPayment.LCName__c!=null && objPayment.LCName__c!='') ? objPayment.LCName__c : 'Student Portal';
            total = total + objPayment.nm_Amount__c;
            totalByLC = mapOfLCVsTotal.containsKey(key) ? 
            (mapOfLCVsTotal.get(key) + objPayment.nm_Amount__c) 
            : objPayment.nm_Amount__c;
            mapOfLCVsTotal.put(key, totalByLC);
        }

        keyValues = mapOfLCVsTotal.keySet();
        totalAmount = total;
    }

}