/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : @vickysahu
**/
global class RefundPaymentWebService {
    webService Static Decimal sendRegfee(String oppsid) {
        system.debug('refund called --> ' + oppsid);
        List<OpportunityLineItem> lstLineItem = new List<OpportunityLineItem>();
        Decimal regfee = 0;
        if(String.isNotBlank(oppsid)){
            lstLineItem = [SELECT id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice FROM OpportunityLineItem WHERE OpportunityId =:oppsid AND Product_Name__c = 'Registration Fee' LIMIT 1];       
            if(lstLineItem.size() > 0){
            regfee = lstLineItem[0].UnitPrice;
            }       
        }
        return regfee;         
    }

    webService Static String deleteDupLead(String email, String mobile){
        String msg = '';
        List<Lead> lstLead = new List<Lead>();
        try {
            if(String.isNotBlank(email) && String.isNotBlank(mobile)){
                lstLead = [SELECT Id, Status FROM Lead WHERE Email = :email AND MobilePhone = :mobile AND IsConverted = false LIMIT 1];

                if (lstLead.size() > 0 && lstLead[0].Status != 'Registration Fee Paid' && lstLead[0].Status != 'Admission Fee Paid') {
                    delete lstLead[0];
                    msg = 'success_';
                } else {
                    if (lstLead.size() == 0) {
                        System.debug('No Lead record found to delete, continuing the process.');
                        msg = 'success_';
                    } else {
                        msg = 'error_You can\'t undo at this stage as payment has been made against the lead record.';
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Internal Error Occurred: ' + e.getMessage());
            msg = 'error_Unable to delete the Lead Record';
        }
        return msg;
    }  
    
    webService Static String deleteRefund(String accountId, String registrationNo){
        String msg = '';
        List<nmRefund_Payment__c> lstRefund = new List<nmRefund_Payment__c>();
        try {
            if(String.isNotBlank(accountId) && String.isNotBlank(registrationNo)){
                lstRefund = [SELECT Id, nm_Payment_Status__c, Type_of_Refund__c, Status__c FROM nmRefund_Payment__c WHERE Account__c =:accountId AND Registration_Number__c =:registrationNo LIMIT 1];

                if (lstRefund.size() > 0 && lstRefund[0].nm_Payment_Status__c != 'Payment Made' && lstRefund[0].Status__c != 'Refund Submitted to Finance' && lstRefund[0].Status__c !='Payment Refunded') {
                    delete lstRefund[0];
                    msg = 'success_';
                } else {
                    if (lstRefund.size() == 0) {
                        System.debug('No Refund found to delete continuing the process.');
                        msg = 'success_';
                    } else {
                        msg = 'error_You can\'t undo at this Stage as Refund has been made aginst the Account.';
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Internal Error Occurred: ' + e.getMessage());
            msg = 'error_Unable to delete the Refund Payment Record';
        }
        return msg;
    }
}