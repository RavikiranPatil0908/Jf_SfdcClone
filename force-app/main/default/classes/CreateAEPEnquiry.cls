@RestResource(urlMapping = '/CreateAEPEnquiry/*')
global class CreateAEPEnquiry {
   
    global class WapperId {
        public String AEPId { get;set; }
        public String result { get;set; }
        public String message { get;set; }

        public WapperId(String Id, String message, String result) {
            this.AEPId = Id;
            this.message = message;
            this.result = result;
        }
    }
    @HttpPost
    global static WapperId connectToEnquiry(
        string Name,
        string EmailId,
        string MobileNumber,
        String State,
        string City,
        String CapitalAvailable,
        String BusinessToBeCommencedIn
    ) {

       
        String requestString = '{"Name":\"' +
        Name +
        '\", "EmailId":\"' +
        EmailId +
        '\", "Mobile Number":\"' +
        MobileNumber +
        '\", "State":\"' +
        State +
        '\", "City":\"' +
        City +
        CapitalAvailable +
        '\","BusinessToBeCommencedIn":\"' +
        BusinessToBeCommencedIn +
        '\"}';


         AEP_Enquiry__c AepEnq = new AEP_Enquiry__c();
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = requestString;
        String AEPId = '';
        String FirstName ='';
        String LastName = '';

        // if (String.isNotBlank(AEPEnquiryName)) {
        //     WapperId objName = new WapperId('', 'Please Provide Name', 'failed');
        //     return objName;
        // }

        // if (String.isNotBlank(EmailId)) {
        //     WapperId obj = new WapperId('', 'Please Provide Email', 'failed');
        //     return obj;
        // }


        if (String.isNotBlank(Name)) {
            if (Name.length() > 39) {
                List < String > lstFullNameString = Name.split(' ');
                if (lstFullNameString.size() > 1) {
                    List < String > lstFirstName = new List < String > ();
                    List < String > lstLastName = new List < String > ();
                    Integer half = lstFullNameString.size() / 2;
                    for (Integer i = 0; i < lstFullNameString.size(); i++) {
                        if (i < half) {
                            lstFirstName.add(lstFullNameString[i]);
                        } else {
                            lstLastName.add(lstFullNameString[i]);
                        }
                    }
                    FirstName = String.join(lstFirstName, ' ');
                    LastName = String.join(lstLastName, ' ');
                } else {
                    FirstName = Name;
                    LastName = '.';
                }
            } else {
                FirstName = Name;
                LastName = '.';
            }
        }
       
        try {
        AepEnq = new AEP_Enquiry__c( First_Name__c = FirstName, Last_Name__c = LastName, Email_Id__c = EmailId, Mobile_Number__c = MobileNumber, City__c = City, 
        State__c = State, Capital_Avilables_in__c = CapitalAvailable, Business_To_Be_Commenced__c = BusinessToBeCommencedIn);
        system.debug(AepEnq + '@#@#@#@#@#@@');

                List<User> lstUser = [Select id ,Profile.Name,UserRole.Name,State_Alloted__c from user where Profile.Name='Channel Manager'];
                Map<String,String> MapofStatevsUser = new Map<String,String>();
                if(lstUser.size()>0)
                {
                for(User objuser:lstUser )
                {
                if(objuser.State_Alloted__c!=null)
                {
                List<String> lstState= new List<String>();
                lstState =  objuser.State_Alloted__c.split(',');
                for(String States : lstState)
                {
                MapofStatevsUser.put(States,objuser.id);
                }
                }
                }
                system.debug('MapofStatevsUser--->'+MapofStatevsUser);
                }
                if (MapofStatevsUser.containsKey(State)){
                    AepEnq.ownerId = MapofStatevsUser.get(State);
                }       
        insert AepEnq;

        WapperId obj = new WapperId(AepEnq.id, 'Success', 'Success');
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'CreateAEPEnquiry';
            apiReq.API_Name__c='CreateAEPEnquiry';
             apiReq.Success__c = true;
            apiRequestsInsertion(apiReq);
            return obj;
    }
        catch (Exception e) {
        // apiReq.Type_of_Request__c = 'CreateAEPEnquiry';
        // apiReq.API_Name__c = 'CreateAEPEnquiry';
        // apiReq.Success__c = false;
            
			WapperId obj = new WapperId('','Error','Bad Request');
            // apiReq.Response__c = obj.toString();
            // apiRequestsInsertion(apiReq);
            return obj;
    }

}

    public static void apiRequestsInsertion(API_Request__c apiRequest) {
        if (apiRequest != null) {
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

}