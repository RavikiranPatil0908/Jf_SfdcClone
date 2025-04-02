/**
 * @File Name          : ConnectToRestService.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 12-12-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    8/31/2019   shubhranshu     Initial Version
**/
@RestResource(urlMapping='/connecttoenquiry/*')
global without sharing class ConnectToRestService
{

    @HttpGET
    global static string connectToEnquiry()
    {
        String contactNo = RestContext.request.params.get('numberOfStudent');
        String currentLocation = RestContext.request.params.get('currentLocation');
        String chooseProgram = RestContext.request.params.get('chooseProgram');
        String selectedProgram = RestContext.request.params.get('selectedProgram');
        String fromURL = RestContext.request.params.get('fromURL');
        String agencyName = RestContext.request.params.get('agencyName');
        String agencyPassword = RestContext.request.params.get('agencyPassword');
        String emailId = RestContext.request.params.get('emailId');
        String name = RestContext.request.params.get('name');

        
        if(agencyName !=null && agencyName !='') { 
            List<Agency_Access__c> lstAgency =[select Name,Email__c,Is_Active__c,password__c from Agency_Access__c where Name =:agencyName and password__c =:agencyPassword and Is_Active__c=true];
            if(lstAgency.size() == 0) {
                return 'Error : Agency Name or Password is Wrong.';
            }
        }
        else{
            agencyName = 'Connecto';
        }
        
        Connecto__c objConnect = new Connecto__c(
            Mobile_Number__c = contactNo,
            City__c = currentLocation, 
            Agency_Name__c = agencyName,
            nm_ChooseaProgram__c = chooseProgram,
            Selected_Program__c = selectedProgram,
            From_URL__c = fromURL,
            Email_ID__c = emailId,
            nm_FirstName__c = name
        );
        
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;

        insert objConnect;
        return 'Success : Record Inserted Successfully.' ;
    }

    @HttpPOST
    global static string connectToEnquiry(String mobileNumber,String currentLocation, String emailId, String agencyName,String name)
    {
        System.debug('connectToEnquiry Called ==>');
        System.debug('mobileNumber ==>'+mobileNumber);
        System.debug('currentLocation ==>'+currentLocation);
        System.debug('emailId ==> '+emailId);
        System.debug('agencyName ==>'+agencyName);
        System.debug('name ==>'+name);
        if(String.isBlank(agencyName)) {
            agencyName = 'Connecto';
        }
        Connecto__c[] lstRecords = [SELECT id,Mobile_Number__c,City__c,Email_ID__c,Agency_Name__c,nm_FirstName__c,Status__c FROM Connecto__c WHERE (Mobile_Number__c=:mobileNumber OR Email_ID__c=:emailId) AND CreatedDate=TODAY LIMIT 1];

        if(lstRecords.size() > 0) {
            lstRecords[0].Mobile_Number__c = mobileNumber;
            lstRecords[0].City__c = currentLocation;
            lstRecords[0].Email_ID__c = emailId;
            lstRecords[0].Agency_Name__c = agencyName;
            lstRecords[0].nm_FirstName__c = name;
            lstRecords[0].Status__c = lstRecords[0].Status__c == 'Not Contacted' ? 'Reborn' : lstRecords[0].Status__c;
            System.debug(lstRecords[0]);
        } else {
            Connecto__c objConnect = new Connecto__c(Mobile_Number__c = mobileNumber ,City__c = currentLocation, Email_ID__c = emailId, Agency_Name__c = agencyName,nm_FirstName__c=name);
            lstRecords.add(objConnect);
        }

        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        upsert lstRecords;
        return 'Successfully Inserted';
    }
}