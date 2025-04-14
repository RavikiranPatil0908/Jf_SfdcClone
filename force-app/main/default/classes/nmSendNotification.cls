/**
 * @File Name          : nmSendNotification.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 09--04--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/8/2019, 12:02:17 PM   @BK     Initial Version
**/
global class nmSendNotification
{   
    @AuraEnabled
    WebService static void sendVerificationEmailToStudent(String emailId,String lcemailId,String studentName,String typeOfRecord,String recordId)
    {
        String token = generateToken(6,typeOfRecord,recordId,'Email');
        //String url = service.shorten(System.Label.Site_Url+'nmEmailVerification?id='+recordId+'&type='+typeOfRecord+'&verify=Email');
        String url =System.Label.Site_Url+'V?id='+recordId+'-'+typeOfRecord+'-E-'+token;
        OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailId};
        String[] toBCC = new String[]{};
                        
        mail.setToAddresses(toAddresses);
        
        Lead ObjLead; 
        if (typeOfRecord == 'Lead') {
            ObjLead = [SELECT Id,nm_InformationCenter__r.Name FROM Lead WHERE Id = :recordId];
        }

        if (System.Label.Allow_Bcc == 'Yes') {
            toBCC = System.Label.setBccAdderess.split(',');
            mail.setBccAddresses(toBCC);
        }
        if (String.isNotBlank(lcemailId) && (typeOfRecord !='Lead' || (ObjLead != null && ObjLead.nm_InformationCenter__r.Name != 'Counsellor'))) {
             String[] toCCAddresses = new String[] {lcemailId};
             mail.setCcAddresses(toCCAddresses);
        }
   
        mail.setSubject('NMIMS Email Verification');
        mail.setOrgWideEmailAddressId(owe.id); 
        mail.setReplyTo(owe.Address); 
        System.debug('Url---->'+url + ' ' + lcemailId);
        String messageBody = '<html><p>Dear '+studentName+',</p>'
                                +'<p>Thank you for showing interest in NMIMS Center For Distance And Online Education.</p>'
                                +'<p>Please click <a href="'+url+'" >here</a> to verify your registered email address</p>'
                                +'<p>Thanks and Regards,</p>'
                                +'<p>NMIMS CDOE</p></html>';
        mail.setHtmlBody(messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

        UpdateDateAndTimeOfRequest(recordId,'Success','Email Sent');
    }

    WebService static void sendEmailOTPToStudent(String emailId,String msg,String studentName)
    {
      //String url = service.shorten(System.Label.Site_Url+'nmEmailVerification?id='+recordId+'&type='+typeOfRecord+'&verify=Email');
    
       OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       emailId = emailId.replace('reborn_','');
       String[] toAddresses = new String[] {emailId};                      
       mail.setToAddresses(toAddresses);
       mail.setSubject('Email Verification OTP');
       mail.setOrgWideEmailAddressId(owe.id); 
       mail.setReplyTo(owe.Address); 
    
       String messageBody = '<html><p>Dear '+studentName+',</p>'
                            +'<p>Thank you for showing interest in NMIMS Center For Distance And Online Education.</p>'
                            +'<p>'+msg+'</p>'
                            +'<p>Thanks and Regards,</p>'
                            +'<p>NMIMS CDOE</p></html>';
       mail.setHtmlBody(messageBody);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
     
    }
    webService static void sendSMSToNoResponseStudent(String mobileNumber)
    {
        System.debug('sendSMSToNoResponseStudent SMS-->');
      
      
    //    String NoresponseMsg = '<html>Thank you for enquiring about NMIMS Distance Learning program.Our program advisor tried calling you today but was unable to get through.<br/><br/>'
    //                                          +'Do call us toll-free 18001025136</html>';
        String noResponseMsg = 'Thank you for enquiring with NMIMS CDOE Our Program advisor tried calling you and was unable to get through. Pls call us on 18001025136';
        if(System.Label.Enable_SMS_Service=='Yes'){
            String smsResponse = SMSSenderWebService.sendmGageSMS(mobileNumber,noResponseMsg.stripHtmlTags());
        }
      
    }

    @AuraEnabled
    webService static void sendVerificationSMSToStudent(String mobileNumber,String ProgramName,String RegistrationNo,String displayName,String typeOfRecord,String recordId)
    {
        System.debug('SendMobileNumberVerification SMS-->');
       // web service for Making long url to tiny url 
      /* BitlyService service = new BitlyService(); 
       
       String url = service.shorten(System.Label.Site_Url+'V?id='+recordId+'&type='+typeOfRecord+'&verify=Mobile');
       
       if(url =='' || url ==null)
       {
           url = service.getTinyUrl(System.Label.Site_Url+'V?id='+recordId+'&type='+typeOfRecord+'&verify=Mobile');
       }*/
       String token = generateToken(6,typeOfRecord,recordId,'Mobile');
       String url =System.Label.Site_Url+'V?id='+recordId+'-'+typeOfRecord+'-M-'+token;
       System.debug('url-------->'+url);
        // String mobileNumberVerificationMsg = 'Your '+displayName +' for '+ProgramName+' with SVKM\'s NGASCE is '+RegistrationNo+'. Please click '+url+' to verify your Mobile Number';
        String mobileNumberVerificationMsg = 'Your '+displayName +' for '+ProgramName+' with NMIMS CDOE is '+RegistrationNo+'. Please click '+url+' to verify your Mobile Number';
        if(System.Label.Enable_SMS_Service=='Yes'){
            //Queue class to send sms.
            sendSMS sendSMS = new sendSMS(mobileNumber,mobileNumberVerificationMsg,recordId);
            
            // enqueue the job for processing
        //  if(Limits.getQueueableJobs() > 1) {
                Id jobID = System.enqueueJob(sendSMS);
                System.debug('jobID -->'+jobID);
        // }
        }
    }

    //Need to be activated from lead or account trigger
    @AuraEnabled
    webService static void sendVerificationSMSToStudentForCorporateFrom(String mobileNumber,String ProgramName,String RegistrationNo,String displayName,String typeOfRecord,String recordId)
    {
        System.debug('SendMobileNumberVerification SMS-->');
       // web service for Making long url to tiny url 
      /* BitlyService service = new BitlyService(); 
       
       String url = service.shorten(System.Label.Site_Url+'V?id='+recordId+'&type='+typeOfRecord+'&verify=Mobile');
       
       if(url =='' || url ==null)
       {
           url = service.getTinyUrl(System.Label.Site_Url+'V?id='+recordId+'&type='+typeOfRecord+'&verify=Mobile');
       }*/
       String token = generateToken(6,typeOfRecord,recordId,'Mobile');
       String url =System.Label.Site_Url+'V?id='+recordId+'-'+typeOfRecord+'-M-'+token;
       System.debug('url-------->'+url);
        // String mobileNumberVerificationMsg = 'Your '+displayName +' for '+ProgramName+' with SVKM\'s NGASCE is '+RegistrationNo+'. Please click '+url+' to verify your Mobile Number';
        String mobileNumberVerificationMsg = 'Your '+displayName +' for '+ProgramName+' with NMIMS CDOE is '+RegistrationNo+'. Please click '+url+' to verify your Mobile Number';
            //Queue class to send sms.
            sendSMS sendSMS = new sendSMS(mobileNumber,mobileNumberVerificationMsg,recordId);
            
            // enqueue the job for processing
        //  if(Limits.getQueueableJobs() > 1) {
                Id jobID = System.enqueueJob(sendSMS);
                System.debug('jobID -->'+jobID);
        // }
    }

    webService static void sendSMSToDNDActiveStudent(String mobileNumber,String Name) {

        System.debug('SendSMS SMS-->');
        
        // String mobileNumberDNDMsg = '<html>Dear customer,<br/><br/>The registered number is in DND. If you want to get a call back from our team then please give a missed call to +916366370461.</html>';
        // String mobileNumberDNDMsg = 'Thank you for enquiring with SVKM\'s NMIMS Global Access. Our Program advisor tried calling you and was unable to get through. Pls call us on 18001025136';
        String mobileNumberDNDMsg = 'Thank you for enquiring with NMIMS CDOE Our Program advisor tried calling you and was unable to get through. Pls call us on 18001025136';
        
        if(System.Label.Enable_SMS_Service=='Yes'){
            String smsResponse = SMSSenderWebService.sendmGageSMS(mobileNumber,mobileNumberDNDMsg.stripHtmlTags());

            if(smsResponse !=null && smsResponse!='') {
                String result ='Success';
                System.debug('result -->'+result);
            }
        }
    }
    
    public static void UpdateDateAndTimeOfRequest(String recordId,string response,String typeOfRequest)
    {
        List<Account> lstAcc = [select id,Sms_Status__c,smsSendTime__c,EmailSendTime__c from Account where id=:recordId];
        List<Lead> lstLead = [select id,Sms_Status__c,smsSendTime__c,EmailSendTime__c from Lead where id=:recordId];
        List<Lead> lstLeadToUpdate = new List<Lead>();
        List<Account> lstAccountToUpdate = new List<Account>();
       
       if(lstAcc.size()>0)
        {
            for(Account objAcc : lstAcc)
            {
                if('Email Sent'.equals(typeOfRequest))
                {
                    objAcc.EmailSendTime__c = System.now();
                }
                if('SMS Sent'.equals(typeOfRequest))
                {
                    if('Success'.equalsIgnoreCase(response))
                    {
                        objAcc.smsSendTime__c = System.now();
                        objAcc.Sms_Status__c = response;
                    }else{// capture reason for failure 
                        objAcc.Sms_Status__c = response;
                    } 
                }
                lstAccountToUpdate.add(objAcc);
            }
        }
        
       if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
       if(lstLead.size()>0)
       {
           for(Lead objLead:lstLead)
           {
               if('Email Sent'.equals(typeOfRequest))
               {
                   objLead.EmailSendTime__c = System.now();
               }
               if('SMS Sent'.equals(typeOfRequest))
               {
                   if('Success'.equalsIgnoreCase(response))
                   {
                       objLead.smsSendTime__c = System.now();
                       objLead.Sms_Status__c = response;
                   }
                   else
                   {
                       objLead.Sms_Status__c = response;
                   }
               }
               lstLeadToUpdate.add(objLead);
           }
       }
       if(lstLeadToUpdate.size()>0)
       {
           update lstLeadToUpdate;
       }
                
    }

    /**
    * @description
    * @author @BK | 22/8/2019
    * @param Integer getLength
    * @param String typeOfRecord
    * @param String recordId
    * @param String Mode
    * @return String
    */
    public static String generateToken(Integer getLength,String typeOfRecord,String recordId,String Mode) {
        String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
        Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
        String charString = '0123456789';
        String randomNew = '';
        while (randomNew.length() < getLength) {
            Integer changeInt = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt , changeInt +1);
        }
        System.debug('randomNew-->'+randomNew);

        List<Account> lstAcc = new List<Account>();
        List<Lead> lstLead = new List<Lead>();

        if(typeOfRecord == 'Lead') {
            lstLead = [SELECT id,Email_Verification_Token__c,Mobile_Verification_Token__c FROM Lead WHERE id=:recordId];
        } else {
            lstAcc = [SELECT id,Email_Verification_Token__c,Mobile_Verification_Token__c FROM Account WHERE id=:recordId];
        }
        
        List<Lead> lstLeadToUpdate = new List<Lead>();
        List<Account> lstAccountToUpdate = new List<Account>();

        if(lstLead.size() > 0) {
            Lead objLead = lstLead[0];
            if(Mode == 'Email') {
                objLead.Email_Verification_Token__c = randomNew;
            }else{
                objLead.Mobile_Verification_Token__c = randomNew;
            }
            lstLeadToUpdate.add(objLead);

            if(lstLeadToUpdate.size() > 0) {
                update lstLeadToUpdate;
            }
        }

        if(lstAcc.size() > 0) {
            Account objAccount = lstAcc[0];
            if(Mode == 'Email') {
                objAccount.Email_Verification_Token__c = randomNew;
            }else{
                objAccount.Mobile_Verification_Token__c = randomNew;
            }
            lstAccountToUpdate.add(objAccount);

            if(lstAccountToUpdate.size() > 0) {
                update lstAccountToUpdate;
            }
        }

        return randomNew;
    }

    /**
    * @description QueueableClass
    * @author @BK | 22/8/2019
    * @param String mobileNumber
    * @param String mobileNumberVerificationMsg
    * @param String recordId
    * @return class
    */
    public class sendSMS implements Queueable, Database.AllowsCallouts {

        private String mobileNumber;
        private String mobileNumberVerificationMsg;
        private String recordId;

        public sendSMS(String mobileNumber,String mobileNumberVerificationMsg,String recordId) {
            this.mobileNumber = mobileNumber;
            this.mobileNumberVerificationMsg = mobileNumberVerificationMsg;
            this.recordId = recordId;
        }

        public void execute(QueueableContext context) {
            // update Token on object
            String smsResponse = SMSSenderWebService.sendmGageSMS(mobileNumber,mobileNumberVerificationMsg.stripHtmlTags());
            if(smsResponse !=null && smsResponse!='')
            {
                String result ='Success';
                UpdateDateAndTimeOfRequest(recordId,result,'SMS Sent');   
            }

        }

    }
}