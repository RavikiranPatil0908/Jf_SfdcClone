global class SendEmailForOTP {
    
    WebService static void callEmailAlertFlow(String recordId, String templateId) {
        Map<String,Object> params = new Map<String, Object>();
        params.put('recordId',recordId);
        params.put('templateId',templateId);
        
        Flow.Interview.Send_OTP_To_Login flow1 = new Flow.Interview.Send_OTP_To_Login(params);
        flow1.start();
    }
}