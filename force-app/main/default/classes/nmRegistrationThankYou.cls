public class nmRegistrationThankYou 
{
    public string strStudentId{get;set;}
    public Boolean isPaymentOfAEPMerchandise {get;set;}
    
    public nmRegistrationThankYou()
    {
        isPaymentOfAEPMerchandise = false;
        strStudentId  = Apexpages.currentPage().getParameters().get('id');
        
        if( Apexpages.currentPage().getParameters().get('PaymentId') != null && Apexpages.currentPage().getParameters().get('PaymentId') != ''){ 
            strStudentId  = Apexpages.currentPage().getParameters().get('PaymentId');
        }

        if(String.isNotBlank(strStudentId)) {
            getPaymentInformation(strStudentId);
        }
        system.debug('isPaymentOfAEPMerchandise ---> ' + isPaymentOfAEPMerchandise);
    }

    public void getPaymentInformation(String paymentId) {
        List<nm_Payment__c> lstPayment = [SELECT Id, nm_PaymentType__c FROM nm_Payment__c WHERE Id = :paymentId LIMIT 1];
        if(lstPayment.size() > 0) {
            if(lstPayment[0].nm_PaymentType__c == 'Tshirt') {
                isPaymentOfAEPMerchandise = true;
            }
        }
    }
}