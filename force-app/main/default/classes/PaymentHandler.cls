/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : @BK
**/
public class PaymentHandler {

    public String savePaymentResponse(PaymentResponseWrapper objResponse) {
        String page = null;
        try {
            String udf1 = objResponse.udf1;
            String udf2 = objResponse.udf2;
            String udf3 = objResponse.udf3;
            if(String.isNotBlank(udf2) && udf2.contains('_') && udf2.split('_').size() <= 3) {
                udf2 = udf2 + '_false';
            }
            objResponse.udf2 = udf2;
            if (objResponse.transactionDateTime == null) {
                objResponse.transactionDateTime = DateTime.now();
            }
            if (udf3 != 'AepPaymentPage') {
                udf3 = 'NA';
            }
            String paymentFor = udf1.split('_')[0];
            if(String.isNotBlank(objResponse.postPaymentPage) && objResponse.postPaymentPage !='NA') {
                if(!udf1.contains('Additional Charge') && udf3 == 'NA'
                    && !udf1.contains('Late Fees') && !udf1.contains('Validity Extension Fee') 
                    && !udf1.contains('Seminar') && !udf1.contains('Career Service')  
                    && !udf1.contains('Repeat Term') && !udf1.contains('Community Licenses Fee')
                    && !udf1.contains('Inspection Fee')  && !udf1.contains('Tshirt')
                    && !udf1.contains('Entity Change Fee') && !udf1.contains('Coursera')
                    && !udf1.contains('New AEP License Fee')
                    && !udf1.contains('Address Change Fee')  
                    && !udf1.contains('Name Change Fee') 
                    && !udf1.contains('MS License Fee')  
                    && !udf1.contains('Application Fee')  
                    && !udf1.contains('UG And PG License Fee')  
                    && !udf1.contains('UG And PG And MS License Fee')
                    && !udf1.contains('UG And PG And MS Renewal License Fee')
                    && !udf1.contains('Application And ')
                    && !udf1.contains('Live Lectures')){
                    System.debug('udf1------>'+udf1);
                    nmPaymentNew objPay = new nmPaymentNew();
                    objPay.recordId = udf1.split('_')[1];
                    objPay.depositAmount = objResponse.depositAmount;
                    objPay.IsReregistartion = objResponse.IsReregistartion;
                    objPay.opportunityId = objResponse.opportunityId;
                    objPay.getMapOfActiveCalender();
                    objPay.QueryLeadAccountOpportunityAndPaymentRelatedDetails();
                    objPay.findPaymentsMadeUsingOpportunity();
                    objPay.findPaymentsMadeUsingLead();
                    objPay.configurePaymentOption();
                    String strLeadRespons = objPay.MakePaymentAfterResponse(objResponse);
                    System.debug('strLeadRespons ==='+strLeadRespons);
                }else if((paymentFor.contains('Additional Charge') || paymentFor.contains('Late Fees') || paymentFor.contains('Repeat Term')) && udf3 == 'NA') {
                    nmAdditonalChargePaymentController objPayment = new nmAdditonalChargePaymentController();
                    System.debug('udf1------>'+udf1);
                    // for Manually Created Additional Payment 
                    List<nm_Payment__c > lstPayment =[select id from nm_Payment__c where nm_OpportunityNew__c =:objResponse.opportunityId and nm_PaymentType__c = 'Additional Charge' and nm_PaymentStatus__c ='Pending Extra Fees'];
                    if(lstPayment.size() > 0)  {
                        objPayment.recordId = lstPayment[0].id;
                        System.debug('Enter In IF Loop----->');
                    }else{
                        objPayment.recordId = objResponse.opportunityId;
                        System.debug('Enter In Else Loop----->');
                    }
                    objPayment.QueryPaymentOpportunityAndValidityExtensionDetails();
                    objPayment.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
                    objPayment.getMapOfActiveCalender();
                    String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse);
                    // String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse.transactionId, objResponse.modeOfPayment ,objResponse.merchantId, objResponse.BankTXNId, objResponse.status, objResponse.responseDescription, objResponse.responseCode, udf1, objResponse.status,udf2,objResponse.feeChrages,objResponse.tax);
                    System.debug( 'Sumit strLeadRespons: '+ strLeadRespons );
                }else if((udf1.contains('Validity Extension Fee')
                    || udf1.contains('Seminar') 
                    || udf1.contains('Career Service') 
                    || udf1.contains('Repeat Term') 
                    || udf1.contains('Community Licenses Fee') 
                    || udf1.contains('New AEP License Fee')
                    || udf1.contains('Inspection Fee')  
                    || udf1.contains('Entity Change Fee')  
                    || udf1.contains('MS Renewal License Fee')  
                    || udf1.contains('UG And PG Renewal License Fee')   
                    || udf1.contains('Address Change Fee')  
                    || udf1.contains('Name Change Fee')  
                    || udf1.contains('MS License Fee')  
                    || udf1.contains('Application Fee')  
                    || udf1.contains('UG And PG License Fee')
                    || udf1.contains('UG And PG And MS License Fee')
                    || udf1.contains('UG And PG And MS Renewal License Fee')
                    || udf1.contains('Application And ')
                    || udf1.contains('Tshirt')
                    || udf1.contains('Coursera')) && udf3 == 'NA' ){
                    nmAdditonalChargePaymentController objPayment = new nmAdditonalChargePaymentController();
                    System.debug('udf1------>'+udf1);
                    if( udf1.split('_')[0] == 'Tshirt') {
                        objPayment.aepCenId = udf1.split('_')[1];
                        objPayment.QueryAEPMerchandise();
                    } else if(udf1.split('_')[0] == 'Coursera') {
                        objPayment.recordId = udf1.split('_')[1];
                        objPayment.QueryCourseraProduct();
                    } else {
                        objPayment.recordId = udf1.split('_')[1];
                        objPayment.QueryPaymentOpportunityAndValidityExtensionDetails();
                    }
                    objPayment.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
                    objPayment.getMapOfActiveCalender();
                    String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse);
                    // String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse.transactionId, objResponse.modeOfPayment ,objResponse.merchantId, objResponse.BankTXNId, objResponse.status, objResponse.responseDescription, objResponse.responseCode, udf1, objResponse.status, udf2,objResponse.feeChrages,objResponse.tax);
                    System.debug( 'Sumit strLeadRespons: '+ strLeadRespons );
                }else if(paymentFor.contains('Live Lectures') && udf3 == 'NA') { 
                    AdditionalLiveLectures objPayment = new AdditionalLiveLectures();
                    System.debug('udf1[1] ==>'+udf1.split('_')[1]);
                    objPayment.recordId = udf1.split('_')[1];
                    objPayment.QueryAccountOpportunityAndPaymentRelatedDetails();
                    // String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse.transactionId,objResponse.modeOfPayment,objResponse.merchantId,objResponse.BankTXNId,objResponse.status,objResponse.responseDescription,objResponse.responseCode,udf1,objResponse.status, udf2,objResponse.feeChrages,objResponse.tax);
                    String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse);
                    System.debug( 'Sumit strLeadRespons: '+ strLeadRespons );
                } else if(udf3 == 'AepPaymentPage') {
                    AepPaymentController objPayment = new AepPaymentController();
                    objPayment.recordId = udf1.split('_')[1];
                    objPayment.QueryAepLicenseFee();
                    String strLeadRespons = objPayment.MakePaymentAfterResponse(objResponse);
                }
                page = Label.Site_Url+objResponse.postPaymentPage+'?ResTrackId='+objResponse.merchantId;
            } else {
                page = objResponse.paymentResponseUrl+'?ResTrackId='+objResponse.merchantId;
            }
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Message Line No ==>'+error.getLineNumber());
        }
        return page;
    }

    public void dummyData(PaymentResponseWrapper objResponse) {
        if (objResponse.transactionDateTime == null) {
            objResponse.transactionDateTime = Datetime.now();
        }
        system.debug('objResponse --> ' + objResponse);
        system.debug('postPaymentPage --> ' + objResponse.postPaymentPage);
        system.debug('udf1 --> ' + objResponse.udf1);
        system.debug('udf2 --> ' + objResponse.udf2);
        system.debug('gatewayVersion --> ' + objResponse.gatewayVersion);
        system.debug('transactionDateTime --> ' + objResponse.transactionDateTime);
    }



    public class PaymentResponseWrapper {
        public String postPaymentPage {get;set;}
        public String udf1 {get;set;}
        public String udf2 {get;set;}
        public String udf3 {get;set;}
        public Decimal depositAmount {get;set;}
        public Boolean IsReregistartion {get;set;}
        public String opportunityId {get;set;}
        public String paymentResponseUrl {get;set;}
        public String transactionId {get;set;}
        public String modeOfPayment {get;set;}
        public String merchantId {get;set;}
        public String BankTXNId {get;set;}
        public String status {get;set;}
        public String responseDescription {get;set;}
        public String responseCode {get;set;}
        public String detailedGatewayResponse {get;set;}
        public String currencyCode {get;set;}
        public Decimal feeChrages {get;set;}
        public Decimal tax {get;set;}
        public String gatewayVersion {get;set;}
        public DateTime transactionDateTime {get;set;}

        public PaymentResponseWrapper() {
            this.postPaymentPage = postPaymentPage;
            this.udf1 = udf1;
            this.udf2 = udf2;
            this.udf3 = udf3;
            this.depositAmount = 0;
            this.IsReregistartion = IsReregistartion;
            this.opportunityId = opportunityId;
            this.paymentResponseUrl = paymentResponseUrl;
            this.transactionId = transactionId;
            this.modeOfPayment = modeOfPayment;
            this.merchantId = merchantId;
            this.BankTXNId = BankTXNId;
            this.status = status;
            this.responseDescription = responseDescription;
            this.responseCode = responseCode;
            this.detailedGatewayResponse = detailedGatewayResponse;
            this.currencyCode = 'INR'; //default currency has been defined.
            this.feeChrages = 0;
            this.tax = 0;
            this.gatewayVersion = gatewayVersion;
            this.transactionDateTime = transactionDateTime;
        }
    }
}