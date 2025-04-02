/**
 * @File Name          : nmThankYou.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 16/7/2019, 12:38:59 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    16/7/2019, 11:53:28 AM   @BK     Initial Version
**/
public class nmThankYou 
{
    public id idPayment{get;set;}
    public Boolean upGradRegistration {get;set;}
    public Boolean upGradAdmission {get;set;}
    
    public nmThankYou() {
        idPayment = apexpages.currentpage().getparameters().get('PaymentId');
        GetPaymentDetails();
    }

    // To track upgrad payment success 
    public void GetPaymentDetails() {
        upGradRegistration = false;
        upGradAdmission = false;
        if(idPayment != null) {
            List<nm_Payment__c> lstPayment = [SELECT id,IC_Name__c,nm_PaymentType__c,nm_PaymentStatus__c FROM nm_Payment__c WHERE id=:idPayment AND (nm_PaymentStatus__c='Payment Made' OR nm_PaymentStatus__c='Payment Approved')];
            if(lstPayment.size() > 0){
                nm_Payment__c objPayment = lstPayment[0];
                if(objPayment.nm_PaymentType__c == 'Registration' && objPayment.IC_Name__c == 'upGrad') {
                    upGradRegistration = true;
                }

                if((objPayment.nm_PaymentType__c == 'Admission' || objPayment.nm_PaymentType__c.contains('DownPayment')) && objPayment.IC_Name__c == 'upGrad') {
                    upGradAdmission = true;
                }
           }
        }
    }
}