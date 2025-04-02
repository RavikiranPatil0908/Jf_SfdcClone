// This Class is used for Connect call between Salesrep and student, 
// and insert call information as Activity history in salesforce
// ---------------------------------------------------------------------------------------------
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        5-Feb-2014      Neeraj Chauhan            Initial Version
// ---------------------------------------------------------------------------------------------
public class nmConnectCall
{
    public string strWhoId{get;set;}
    //Customer number entered by vf page
    public string strCustomerName{get;set;}
    public string strCustomerNumber{get;set;}
    //Caller info
    public string strCallerNumber{get;set;}
    public string strVirtualNumber{get;set;}    
    //Global Properties
    public string strSID{get;set;}
    public string strToken{get;set;}
    //Property to enable disable detail section
    public boolean isDisabled{get;set;}
    public Task callSummary{get;set;}
    public string strCallStatus{get;set;}
    //Property to store type of parent (lead/contact)
    public string strType{get;set;}
    //Property to use in case of person account only to redirect to account
    public string strPAccountId{get;set;}
    //Property to show details of lead
    public Lead objShowLead {get;set;}
    
    //Constructure
    public nmConnectCall()
    {
        objShowLead = new Lead();
        strWhoId = ApexPages.currentPage().getParameters().get('id');
        strType = ApexPages.currentPage().getParameters().get('type');
        
        if(strWhoId != null && strType != null)
        {
            if(strType == 'lead')
            {
                List<Lead> lstLead = [select Id, Name, MobilePhone from Lead where id =: strWhoId];
                
                if(lstLead != null && lstLead.size() > 0)
                {
                    strCustomerName = lstLead[0].Name;
                    strCustomerNumber = lstLead[0].MobilePhone;                
                }
                
                string strQuery = 'select nm_InformationCenter__r.Name, nm_EligiblityCriteria__r.Name, nm_Program__r.Name';
            
                Map<String, Schema.SObjectField> M = Schema.SObjectType.Lead.fields.getMap();
                
                for(string fName : m.keyset())
                {
                    strQuery = strQuery + ',' + fName;  
                }  
                                             
                strQuery = strQuery + ' from Lead where id = \'' + strWhoId + '\'';
                system.debug('query' + strQuery);
                objShowLead = Database.query(strQuery);
            }
            else
            {
                List<Contact> lstPersonContact = [select Id, Name, MobilePhone from Contact where Accountid =: strWhoId];
            
                if(lstPersonContact != null && lstPersonContact.size() > 0)
                {
                    strPAccountId = strWhoId;
                    strWhoId = lstPersonContact[0].Id;
                    strCustomerName = lstPersonContact[0].Name;
                    strCustomerNumber = lstPersonContact[0].MobilePhone;                
                }
            }
        }
        
        
        /*strSID = 'saasforce1';
        strToken = 'cdb4aee266a56633e985567f0344f21ce6c6e3a6';
        strVirtualNumber = '09223183143';
        strCallerNumber = '07838215694';*/
        
        strSID = nmCommon.getConfigSettings('nm_ExotelSID__c');
        strToken = nmCommon.getConfigSettings('nm_ExotelToken__c');
        strVirtualNumber = nmCommon.getConfigSettings('nm_ExotelVirtualNumber__c');
        System.debug('**config'+strSID);
        strCallerNumber = CallerNumber();
        
        isDisabled = true;
        callSummary = new Task();
        strCallStatus = '';
        
    }
    
    public string CallerNumber()
    {
            //this line commented by Sumit Banarji please validate the code and remove commented lines
            List<User> lstUser = [select id, Phone from user where id=: userinfo.getUserid()];
            
            if(lstUser != null && lstUser.size() > 0)
            {
                
                return lstUser[0].Phone;
                 
            }
            
            /*List<Lead> lstLead = [select id, owner.phone from lead where id =: ApexPages.currentPage().getParameters().get('id')];
            if(lstLead != null && lstLead.size() > 0)
            {
                
                return lstLead[0].owner.phone;
                 
            }*/
            
            
            return null;
    }
    
    //Method to called by page button to initiate connect call
    public void ConnectCall()
    {
            if(nmCommon.isNullOrEmpty(strSID) || nmCommon.isNullOrEmpty(strToken) || nmCommon.isNullOrEmpty(strVirtualNumber))
            {
                apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 'Please update Exotel System Config Settings.'));                
                return; 
            }
            
            if(nmCommon.isNullOrEmpty(strCallerNumber))
            {
                apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 'Please update your number in IC Users.'));              
                return; 
            }
            
            isDisabled = false;
             system.debug('NRACTRAC::::&&&&&&&&');
            map<string, string> mapResponse = connectCustomerToAgent(strCallerNumber, strCustomerNumber, strVirtualNumber, 'promo', null, null, 'http://dev-nmimsdev.cs6.force.com/nmExotelResponse');
            
            system.debug('NRACTRAC::::'+mapResponse);
            
            callSummary = new Task();
            
            callSummary.ActivityDate = Date.today();
            callSummary.Subject='Call';
            callSummary.WhoId = strWhoId;
            callSummary.OwnerId = UserInfo.getUserId();
            callSummary.Status='Completed';
            callSummary.Exotel_Call_Status__c = 'In Progress...';
            callSummary.Exotel_Sid__c = mapResponse.get('Sid');
            callSummary.From_No__c = mapResponse.get('From');
            callSummary.Phone_Number_Sid__c = mapResponse.get('PhoneNumberSid');
            
            strCallStatus = 'In Progress...';
            
            insert callSummary;
            
            if(strType == 'lead')
            {
                Lead objLead = new Lead(id=strWhoId);
                objLead.nm_LeadContacted__c = 'Yes';
                
                update objLead;
            }
    }
    
    //Method to update comment on Actiovity call
    public pagereference SaveDetail()
    {
        string strIsFollowUp = ApexPages.currentPage().getParameters().get('isFollowUp');
        
        Task objTask = new Task(id=callSummary.id, description=callSummary.description);
        update objTask;
        
        if(strIsFollowUp != null && strIsFollowUp == 'True')
        {
            return new pagereference('/'+objTask.Id+'/e?followup=1&retURL=%2F'+objTask.Id);
        }
        else
        {            
            if(strType == 'lead')
                return new pagereference('/'+strWhoId);
            else
                return new pagereference('/'+strPAccountId);  
        }
    }
    
    //Method to create request body and pass it to httprequest method
    public map<string, string> connectCustomerToAgent(string strFrom, string to, string callerID,
                                              string callType, string timeLimit,
                                              string timeOut, string statusCallback)
    {
        map<string, string> postValues = new map<string, string>();
        postValues.put('From', strFrom);
        postValues.put('To', to);
        postValues.put('CallerID', callerID);
        postValues.put('CallType', callType);
        if (timeLimit != null)
        {
            postValues.put('TimeLimit', timeLimit);
        }
        if (timeOut != null)
        {
            postValues.put('TimeOut', timeOut);
        }

        if (statusCallback != null)
        {
            postValues.put('StatusCallback', statusCallback);
        }

        String postString = '';

        for(string strKey : postValues.keyset())
        {
            if(postValues.get(strKey) !=null)
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
    public HTTPResponse sendRequest(string postString)
    {
        string smsURL = 'https://twilix.exotel.in/v1/Accounts/'+strSID+'/Calls/connect';
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
    
    //Method called by page after every three second to update the status of call on page (Completed/Failed/Busy/No Answer)
    public void CheckCallStatus()
    {
        List<Task> lstTask = [select id, Exotel_Call_Status__c from Task where id =: callSummary.id];
        
        if(lstTask != null && lstTask.size() > 0)
        {
            strCallStatus = lstTask[0].Exotel_Call_Status__c;
        }
    }
    
    //Method to return on detail page
    public pagereference BackToLead()
    {
        if(strType == 'lead')
            return new pagereference('/'+strWhoId);
        else
            return new pagereference('/'+strPAccountId); 
    }
}