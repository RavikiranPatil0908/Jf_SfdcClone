/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : @BK
**/
public class SendCallScheduleSMS {
    
    public class CallScheduleActionRequest {
		@InvocableVariable(required=true)
		public DateTime oldCallDateTime;

		@InvocableVariable(required=true)
		public String MobilePhone;

		@InvocableVariable(required=true)
		public DateTime newCallDateTime;

        @InvocableVariable(required=true)
		public String studentName;
	}

    @InvocableMethod(label='Send Call Scheduled SMS' description='To send sms to student on the call scheduled details')
    public static void sendSMSNotification(List<CallScheduleActionRequest> request){
        DateTime newDateTime = request[0].newCallDateTime;
        DateTime oldDateTime = request[0].oldCallDateTime;
        String msg = 'Dear '+ request[0].studentName +', We tried to reach you on '+oldDateTime.format('dd/MM/yyyy')+' at '+oldDateTime.format('h:mm a')+' however were not able to reach you. We will call you back at '+newDateTime.format('h:mm a')+' on '+newDateTime.format('dd/MM/yyyy')+'. Please be available at this time. Thanks and Regards, Team NMIMS CDOE';
        String mobile = request[0].MobilePhone;
        mobile = mobile.trim();
        // Queue
        SendScheduleSMS sendSMS = new SendScheduleSMS(mobile,msg);
        Id jobID = System.enqueueJob(sendSMS);
        System.debug('jobID -->'+jobID);
    }

    // @future (callout=true)
	// public static void calloutmethod(String jsonResults){ 
    //     List<CallScheduleActionRequest> request = (List<CallScheduleActionRequest>)JSON.deserialize(jsonResults, List<CallScheduleActionRequest>.class);
    //     System.debug('results-->'+request);
    //     DateTime newDateTime = request[0].newCallDateTime;
    //     DateTime oldDateTime = request[0].oldCallDateTime;
    //     String msg = 'Dear '+ request[0].studentName +', We tried to reach you on '+oldDateTime.format('dd/MM/yyyy')+' at '+oldDateTime.format('h:mm a')+' however were not able to reach you. We will call you back at '+newDateTime.format('h:mm a')+' on '+newDateTime.format('dd/MM/yyyy')+'. Please be available at this time. Thanks and Regards, Team NGASCE';
    //     String mobile = request[0].MobilePhone;
    //     mobile = mobile.trim();
    //     String result = SMSSenderWebService.sendmGageSMS(request[0].MobilePhone.right(10),msg);
    //     System.debug('SMS sent result => '+result);
    //     if(String.isNotBlank(result) && result.containsIgnoreCase('Statuscode=200')) {
    //         System.debug('msg sent successfully');
    //     }
    // }

    public class SendScheduleSMS implements Queueable, Database.AllowsCallouts {
        private String mobileNumber;
        private String msg;

        public SendScheduleSMS(String mobileNumber,String msg) {
            this.mobileNumber = mobileNumber;
            this.msg = msg;
        }

        public void execute(QueueableContext context) {
            // Call SMS
            String result = SMSSenderWebService.sendmGageSMS(mobileNumber.right(10),msg);
            System.debug('SMS sent result => '+result);
            if(String.isNotBlank(result) && result.containsIgnoreCase('Statuscode=200')) {
                System.debug('msg sent successfully');
            }
        }
    }
}