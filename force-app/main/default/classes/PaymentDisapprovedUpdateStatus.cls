/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 04-13-2024
 * @last modified by  : @vickysahu
**/
public without sharing class PaymentDisapprovedUpdateStatus {
    public PaymentWrapper objWrapper{get; set;}
    
    public PaymentDisapprovedUpdateStatus() {
    objWrapper = new PaymentWrapper();
    }
    
    public void updateAccountAndOpportunityForDisapprovedPayment(List<nm_Payment__c> lstPayment, Map<id,nm_Payment__c> oldMapPayment) {
        for(nm_Payment__c objPayment : lstPayment) {   
            System.debug('Payment status: -'+objPayment.nm_PaymentStatus__c);
            System.debug('old payment status '+oldMapPayment.get(objPayment.id).nm_PaymentStatus__c);

            if(((objPayment.nm_PaymentStatus__c == 'Payment Disapproved' || objPayment.nm_PaymentStatus__c == 'Process Charge Back')
            && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c == 'Payment Approved'
            && oldMapPayment.get(objPayment.id).nm_PaymentStatus__c != objPayment.nm_PaymentStatus__c 
            && objPayment.nm_OpportunityNew__c != null && objPayment.Opportunity_Stage__c == 'Closed Won' 
            // && lst.contains(objPayment.nm_PaymentType__c) && 
            )) {
                objWrapper.setOppsId.add(objPayment.nm_OpportunityNew__c);
            }            
        }
        createMapOfOpportunityIdAndTotalApprovedPayment();
        updateStudentProgram();
    }

    public void createMapOfOpportunityIdAndTotalApprovedPayment() {
        List<nm_Payment__c> lstOfPayment = [SELECT Id, nm_Amount__c, nm_PaymentType__c, nm_OpportunityNew__c, nm_PaymentStatus__c, nm_ActualPaymentAmmount__c FROM nm_Payment__c WHERE nm_PaymentStatus__c = 'Payment Approved' AND nm_OpportunityNew__c IN :objWrapper.setOppsId];
        for(nm_Payment__c objPayment : lstOfPayment) {
            objWrapper.totalApprovedPayment = objWrapper.mapOfOppidAndTotalAmount.containsKey(objPayment.nm_OpportunityNew__c) ? objWrapper.mapOfOppidAndTotalAmount.get(objPayment.nm_OpportunityNew__c) + objPayment.nm_Amount__c : objPayment.nm_Amount__c;
            objWrapper.mapOfOppidAndTotalAmount.put(objPayment.nm_OpportunityNew__c, objWrapper.totalApprovedPayment);
        }
        createListToUpdateOpportunityStage();
    }

    public void createListToUpdateOpportunityStage() {
        List<Opportunity> lstOpportunity = [SELECT Id, Name, StageName, nm_StudentProgram__c, Account.nm_StudentStatus__c, nm_Semester__c, AccountId, Is_Re_Registration_Payment__c,(SELECT Id, Name, UnitPrice FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :objWrapper.setOppsId];
        for(Opportunity objOpp : lstOpportunity) {
            List<OpportunityLineItem> lstLineItem = objOpp.OpportunityLineItems;
            for(OpportunityLineItem objLineItem : lstLineItem) {
                objWrapper.tolalProductAmount = objWrapper.tolalProductAmount + objLineItem.UnitPrice;
            }
            objWrapper.setSPId.add(objOpp.nm_StudentProgram__c);
            Decimal approvedAmount = objWrapper.mapOfOppidAndTotalAmount.containsKey(objOpp.Id) ? objWrapper.mapOfOppidAndTotalAmount.get(objOpp.Id) : 0;
            if(objWrapper.setOppsId.contains(objOpp.Id) && approvedAmount < objWrapper.tolalProductAmount) {
                objOpp.StageName = 'Pending Payment';
                objWrapper.lstOpportunityUpdate.add(objOpp);
                if(objOpp.Account.nm_StudentStatus__c == 'Confirmed' && !objOpp.Is_Re_Registration_Payment__c) {
                    objWrapper.setAccId.add(objOpp.AccountId);
                }
            }
        }

        if(objWrapper.lstOpportunityUpdate.size() > 0) {
            update objWrapper.lstOpportunityUpdate;
        }
        createListToUpdateAccountStatus();
    }

    public void createListToUpdateAccountStatus() {
        List<Account> lstAccount = [SELECT Id, nm_StudentStatus__c FROM Account WHERE Id IN :objWrapper.setAccId];
        for(Account objAcc : lstAccount) {
            if(objWrapper.setAccId.contains(objAcc.Id)) {
                objAcc.nm_StudentStatus__c = 'Admission form & documents Approved';
                objWrapper.lstAccountUpdate.add(objAcc);
            }
        }
        if(objWrapper.lstAccountUpdate.size() > 0) {
            update objWrapper.lstAccountUpdate;
        }
    }

    public void updateStudentProgram() {
        List<nm_StudentProgram__c> lstStudentProgram = [SELECT Id,Name,nm_IsClosed__c,nm_FeesPaidofSemester__c,Total_sem__c FROM nm_StudentProgram__c WHERE Id IN : objWrapper.setSPId];
        for(nm_StudentProgram__c objSP : lstStudentProgram) {
            if(objSP.nm_FeesPaidofSemester__c > 0) {
                objSP.nm_FeesPaidofSemester__c = objSP.nm_FeesPaidofSemester__c - 1;
                objWrapper.lstStudentProgramUpdate.add(objSP);
            }
        }
        if(objWrapper.lstStudentProgramUpdate.size() > 0 ) {
            update objWrapper.lstStudentProgramUpdate;
        }
    }


    public class PaymentWrapper {
        public set<id> setOppsId {get; set;}
        public set<id> setAccId {get; set;}
        public List<Opportunity> lstOpportunityUpdate {get; set;}
        public List<Account> lstAccountUpdate {get; set;}
        public Map<String,Decimal> mapOfOppidAndTotalAmount {get; set;}
        public Decimal totalApprovedPayment {get; set;}
        public Decimal tolalProductAmount {get; set;}
        public List<nm_StudentProgram__c> lstStudentProgramUpdate {get; set;}
        public set<id> setSPId {get; set;}

        public PaymentWrapper() {
            setOppsId = new set<id>();
            setAccId = new set<id>();
            setSPId = new set<id>();
            lstOpportunityUpdate = new List<Opportunity>();
            lstAccountUpdate = new List<Account>();
            mapOfOppidAndTotalAmount = new Map<String,Decimal>();
            lstStudentProgramUpdate = new List<nm_StudentProgram__c>();
            totalApprovedPayment = 0; 
            tolalProductAmount = 0;
        }
    }
}