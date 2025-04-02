@isTest
private class nmIncomingCallPopupTracker
{
     public static Lead objLead;
     public static Account objAccount;
     public static nm_Configure_the_Pages__c configPages;
     public static nm_Holidays__c objHoliday;
     public static nm_UserMapping__c objMap;
     public static nm_Centers__c   objcenter;
     
     private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
     private static testmethod  void unitTest1()
     {
      
        LoadData();     
        Task T = new Task();
        T.Type = 'Email';
        T.Description = '';
        T.Exotel_Sid__c ='test';   
        T.whoId =objLead.id;
        T.call_type__c='Incoming';  
        T.Is_Call_Received__c =false;   
        insert T;
        nmIncomingCallPopup obj =  new nmIncomingCallPopup();
        obj.recordId =T.id;
        obj.ShowIncommingCall();
        obj.MarkChecked();
    
     }
    
    private static testmethod  void unitTest2()
    {
        LoadData();
        Recordtype rt=[select id from Recordtype where sobjectType='Account' AND name ='Person Account']; 
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        /*Account Acc = new Account(
        RecordTypeID=rt.id,
        FirstName='jane',
        LastName='doe',
        PersonEmail = 't@t.com',
        nm_PreStudentNo__c ='77213',
        nm_StudentStatus__c='Confirmed',
        nm_SerialNo__c=2,PersonMobilePhone='9899987898') ; 
        insert Acc; 
        Account acc = new Account();
        acc =  CommonTrackerClass.createAccount(acc); */
        Contact objCon =[select id from contact where AccountId=:objAccount.id limit 1];     
             
        Task T = new Task();
        T.Type = 'Email';
        T.Description = '';
        T.Exotel_Sid__c ='test'; 
        T.whoId =objCon.id;  
        T.call_type__c='Incoming';  
        T.Is_Call_Received__c =false;   
        insert T;
        nmIncomingCallPopup obj =  new nmIncomingCallPopup();
        obj.recordId =T.id;
        obj.ShowIncommingCall();
        obj.MarkChecked();
    
    }
    
    static void LoadData()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
       
    }
  }