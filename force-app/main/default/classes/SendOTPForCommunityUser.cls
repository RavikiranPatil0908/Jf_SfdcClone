/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-28-2020   @BK      Initial Version
**/
public class SendOTPForCommunityUser {

    //Required Paramters
	public class CommunityActionRequest {
		@InvocableVariable(required=true)
		public String Username;

		@InvocableVariable(required=true)
		public String MobilePhone;

		@InvocableVariable(required=true)
		public String VerificationCode;
	}

    @InvocableMethod(label='Send SMS Otp' description='To send sms otp to community user')
    public static void sendSMSOtp(List<CommunityActionRequest> request){
        calloutmethod(JSON.serialize(request));
    }

    @future (callout=true)
	public static void calloutmethod(String jsonResults){ 
        List<CommunityActionRequest> request = (List<CommunityActionRequest>)JSON.deserialize(jsonResults, List<CommunityActionRequest>.class);
        System.debug('results-->'+request);
        String msg = 'Dear User, The OTP to verify '+request[0].Username+' with SFDC Community login verification by NMIMS CDOE is '+request[0].VerificationCode;
        String mobile = request[0].MobilePhone;
        mobile = mobile.trim();
        String result = SMSSenderWebService.sendmGageSMS(request[0].MobilePhone.right(10),msg);
        System.debug('SMS sent result => '+result);
        if(String.isNotBlank(result) && result.containsIgnoreCase('Statuscode=200')) {
            System.debug('msg sent successfully');
        }
    }
}