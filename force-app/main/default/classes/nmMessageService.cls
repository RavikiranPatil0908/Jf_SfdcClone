global class nmMessageService
{
    //Global Properties
    static string strSID;
    static string strToken;
    
    WebService static string sendMessage(string strMobileNo, string strBody) 
    {
        /*
        strSID = 'saasforce1';
        strToken = 'cdb4aee266a56633e985567f0344f21ce6c6e3a6';
        */
        
        strSID = nmCommon.getConfigSettings('nm_ExotelSID__c');
        strToken = nmCommon.getConfigSettings('nm_ExotelToken__c');
        string strVirtualNumber = nmCommon.getConfigSettings('nm_ExotelVirtualNumber__c');
        
        system.debug('NRAC::'+strMobileNo);
            
        if(strMobileNo != null && strMobileNo != '')
        {
            strMobileNo = strMobileNo.replace('(','');
            strMobileNo = strMobileNo.replace(')','');
            strMobileNo = strMobileNo.replace(' ','');          
            strMobileNo = strMobileNo.replace('-','');
            system.debug('NRAC::'+strMobileNo);
            
            map<string, string> res = connectCustomerToAgent(strVirtualNumber, strMobileNo, strBody, 'http://dev-nmimsdev.cs6.force.com/nmExotelResponse');
            
            //return 'Sms sent successfully to ' + strMobileNo + '.';
            return 'Success';
        }
        else
        {
            return 'Error: Please update mobile number first.';
        }
    }
    
    //Method to create request body and pass it to httprequest method
    static map<string, string> connectCustomerToAgent(string strFrom, string to, string strBody, string statusCallback)
    {
        map<string, string> postValues = new map<string, string>();
        postValues.put('From', strFrom);
        postValues.put('To', to);        
        postValues.put('Body', strBody);
        
        if (statusCallback != null)
        {
            //postValues.put('StatusCallback', statusCallback);
        }

        String postString = '';

        for(string strKey : postValues.keyset())
        {
            postString += strKey + '=' + EncodingUtil.urlEncode(postValues.get(strKey),'UTF-8') + '&';
        }
        postString = postString.removeEnd('&');
       
        HTTPResponse response = sendRequest(postString);
       
        Dom.Document doc = response.getBodyDocument();        
        //Retrieve the root element for this document.
        Dom.XMLNode parentNode = doc.getRootElement();
        
        map<string, string> mapResponse = new map<string, string>();
        for(Dom.XMLNode callNode : parentNode.getChildElements()) 
        {
            for(Dom.XMLNode callChild : callNode.getChildElements()) 
            {
                mapResponse.put(callChild.getName(), callChild.getText());
            }
        }
        
        return mapResponse;
    }
    
    //Method to make http request and return response
    static HTTPResponse sendRequest(string postString)
    {
        string smsURL = 'https://twilix.exotel.in/v1/Accounts/'+strSID+'/Sms/send';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(smsURL);
        Blob headerValue = Blob.valueOf(strSID + ':' + strToken);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('POST');
        req.setHeader('Content-Length',String.valueof(postString.length()));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody(postString);
          
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        return res;
    }
}