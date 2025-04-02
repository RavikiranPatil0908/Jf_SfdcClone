/**
 * @File Name          : nmOnlinePaymentTracker.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-09-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    29/3/2019, 1:16:18 PM   Balakrishnan     Initial Version
**/
@istest(SeeAllData=true)
public class nmOnlinePaymentTracker {
    public static testmethod void PaymentRequestCreater()
    {
      SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
      objSystemConfiguration.name='test';
      objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
      objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
      objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
      objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
      insert objSystemConfiguration;
          
      nmOnlinePayment objnmOnline=new nmOnlinePayment();
      objnmOnline.strPortalId = '9000640';
      objnmOnline.TranTrackid='qwsqwsqws1213';
      objnmOnline.TranAmount='123123';
      objnmOnline.strPaymentType='ADSasA12313';
      objnmOnline.strPaymentType='ASDASD123123';
      objnmOnline.strEmailId='CHANDU80089@gmail.com';
      objnmOnline.strMobileNumber='234324324';
      objnmOnline.MakePayment();
      objnmOnline.createtBillDeskRequest();
      objnmOnline.createHDFCDeskRequest();
      objnmOnline.createPayTMRequest();
      objnmOnline.createRazorPayOrderRequest();
      objnmOnline.createICICIOrderRequest();
      //objnmOnline.createPayPalRequest();
    }
}