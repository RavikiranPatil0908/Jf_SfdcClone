/**
 * @File Name          : SMSSenderWebService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    14/8/2019, 11:39:19 AM   @BK     Initial Version
**/
global class SMSSenderWebService{

    webService static string sendSMSTransactional(String mobileNumber, String msg){
        //String smsBody ='Your study kit is dispatched from NMIMS, for further details kindly refer to your registered email address or call us at 18001025136.';
        //String message = smsBody;
        String password = System.Label.domainaddaSMSPassword;
        System.debug('Password --->'+password);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint('http://sms.domainadda.com/vendorsms/pushsms.aspx');        
        req.setMethod('POST');
        //req.setCompressed(true);
        // old password =Newbuilding@123
        req.setBody('user=NGASCE&password='+password+'&msisdn='+mobileNumber+'&sid=NGASCE&msg='+msg+'&fl=0&gwid=2');
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
            }else{
                result = '{"status" : "ok"}';
            }
            
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return result ;
    }


    webService static string sendSMSPromotional(String mobileNumber, String msg){
        //String smsBody ='NMIMS University tried to get in touch with you but could not succeed. Reach us at  1800 1025 136 to get information about our award winning distance management programs - Team NGASCE';
        //String message = smsBody;
        String password = System.label.domainaddaSMSPassword;
        System.debug('Password --->'+password);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint('http://sms.domainadda.com/vendorsms/pushsms.aspx');        
        req.setMethod('POST');
        //req.setCompressed(true);
        req.setBody('user=NGASCE&password='+password+'&msisdn='+mobileNumber+'&sid=NGASCE&msg='+msg+'&fl=0');
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
            }else{
                result = '{"status" : "ok"}';
            }
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return status;
    }
    webService static string NetcoreSMSTransactional(String mobileNumber, String msg){
        //String smsBody ='Your study kit is dispatched from NMIMS, for further details kindly refer to your registered email address or call us at 18001025136.';
        //String message = smsBody;
        Map<String, String> MapEncode = new Map<String, String> ();
        
        String password = System.Label.BulkSMSpassword;
        String username = System.Label.Username_netcore;
        String URL = System.Label.NetcoreSMSurl;
        mobileNumber ='91'+mobileNumber;
        System.debug('Password --->'+password); 
        
        MapEncode.put('feedid','372884');
        MapEncode.put('username',username);
        MapEncode.put('password',password);
        MapEncode.put('to',mobileNumber);
        MapEncode.put('Text',msg);
        //MapEncode.put('mtype','13');      
        //MapEncode.put('UDH','NMIMS');
        //MapEncode.put('senderid','NMIMS');
      
        URL += '?'+urlEncode(MapEncode);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint(URL);       
        req.setMethod('POST');
        
        //req.setCompressed(true);
        // old password =Newbuilding@123
      //  req.setBody('feedid=372884&username=8082222940&password='+password+'&To='+mobileNumber+'&mtype=13&Text='+msg);
    
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
                 result = xmlparser(result);
                //system.debug(result);
            }else{
                result = '{"status" : "ok"}';
            }  
                  
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return result ;
    }
    
    public static String urlEncode(Map<String, String> vals) {
        String result = '';
        for(String thisKey : vals.keySet()) {
            result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
        }
        return result.removeEnd('&');    
    }
   public static string xmlparser(String result)
    {   String tid='';
        Dom.Document doc = new Dom.Document();
        doc.load(result);
        String value = doc.getRootElement().getAttributeValue('REQID', '');

        Dom.XMLNode rootNode = doc.getRootElement();
        //parseXML(rootNode);
   

        for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {          
            system.debug('node--->'+node);
            String submittedDatetime = node.getAttributeValue('SUBMITDATE', '');
            tid = node.getAttributeValue('TID', '');
            system.debug('tid--->'+tid);
          }
        return tid;
    }
     
    //  public void parseXML(DOM.XMLNode node) {
    //   string code = '';
    //   string error = '';
    //     if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
    //     system.debug(node.getName());
          
    //         if(node.getName()=='CODE')
    //           code =node.getText().trim();
    //         if(node.getName()=='DESC')
    //             error =node.getText().trim();
    //     }
    //      system.debug('code--->'+code);
    //      system.debug('error--->'+error);
    //     for (Dom.XMLNode child: node.getChildElements()) {
    //        // system.debug('child--->'+child);
    //         parseXML(child);
    //     }
    // }
    
   /*  webService static string sendSMSAfterDispatchOrderCreated(String mobileNumber, String msg,string AccountName){
        String smsBody ='<html> Dear '+ AccountName +'<br/><p>Your study kit is dispatched from NMIMS, for further details kindly refer to your registered email address or call us at 18001025136</p></html>';
        msg= smsBody.stripHtmlTags();
        String password = System.Label.domainaddaSMSPassword;
        System.debug('Password --->'+password);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint('http://sms.domainadda.com/vendorsms/pushsms.aspx');        
        req.setMethod('POST');
        //req.setCompressed(true);
        // old password =Newbuilding@123
        req.setBody('user=NGASCE&password='+password+'&msisdn='+mobileNumber+'&sid=NGASCE&msg='+msg+'&fl=0&gwid=2');
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
            }else{
                result = '{"status" : "ok"}';
            }
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return status;
    }*/
    webService static string sendmGageSMS (String mobileNumber, String msg) {
       // String smsBody ='<html> Dear '+ AccountName +'<br/><p>Your study kit is dispatched from NMIMS, for further details kindly refer to your registered email address or call us at 18001025136</p></html>';
        msg= msg.stripHtmlTags();
        String key = System.Label.mGage_APIKey;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint('https://japi.instaalerts.zone/httpapi/QueryStringReceiver?ver=1.0');        
        req.setMethod('POST');     
        req.setBody('&key='+key+'&encrpt=0&dest='+mobileNumber+'&send=NCDOE&text='+msg);
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
            }else{
                result = '{"status" : "ok"}';
            }
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return status;
    }
    
  /* NetCore SMS
   webService static string sendSMSAfterDispatchOrderCreated(String mobileNumber, String msg,string AccountName){
        String smsBody ='<html> Dear '+ AccountName +'<br/><p>Your study kit is dispatched from NMIMS, for further details kindly refer to your registered email address or call us at 18001025136</p></html>';
        msg= smsBody.stripHtmlTags();
              
        Map<String, String> MapEncode = new Map<String, String> ();
        
        String password = System.Label.BulkSMSpassword;
        String username = System.Label.Username_netcore;
        String URL = System.Label.NetcoreSMSurl;
        mobileNumber ='91'+mobileNumber;
        System.debug('Password --->'+password); 
        
        MapEncode.put('feedid','372884');
        MapEncode.put('username',username);
        MapEncode.put('password',password);
        MapEncode.put('to',mobileNumber);
        MapEncode.put('Text',msg);
        
         URL += '?'+urlEncode(MapEncode);

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint(URL);       
        req.setMethod('POST');
        
        System.debug(req);
        String status = '';
        String result = '';
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
                 result = xmlparser(result);
            }else{
                result = '{"status" : "ok"}';
            }
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return status;
    }*/
     webService static string sendSMSAfterDispatchOrderCreated(String mobileNumber, String msg,string AccountName){
        // String smsBody ='Dear '+ AccountName +', your study kit is dispatched by SVKM\'s NGASCE. For further details refer to your regd. email-id or call us at 18001025136';
        String smsBody = 'Dear '+ AccountName +', your study kit is dispatched by NMIMS CDOE. For further details refer to your regd. email-id or call us at 18001025136';
        msg = smsBody;
        
        String key = System.Label.mGage_APIKey;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        System.debug('Message To Be Sent--->'+msg);
        req.setEndpoint('https://japi.instaalerts.zone/httpapi/QueryStringReceiver?ver=1.0');        
        req.setMethod('POST');
        req.setBody('&key='+key+'&encrpt=0&dest='+mobileNumber+'&send=NCDOE&text='+msg);
        System.debug(req);
        String status = '';
        String result = '';
        
       
        try {
        
            if(!System.Test.isRunningTest()){
                res = http.send(req);
                result = res.getBody();
                // result = xmlparser(result);
            }else{
                result = '{"status" : "ok"}';
            }
       
            
           System.debug('Response result --------------->'+result+'<---res---->'+res);
       } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

        return status;
    }
}