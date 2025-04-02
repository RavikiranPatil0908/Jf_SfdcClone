/**
 * @File Name          : ConnectToRestServiceTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 12-12-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    8/31/2019   shubhranshu     Initial Version
**/
@isTest(SeeAllData=true)
public class ConnectToRestServiceTracker
{
    public static Connecto__c connectTo;
    public static nm_UserMapping__c objMap; 
    public static nm_Centers__c objcenter;
     
    @isTest 
    static void unitTest1() {
        
        System.RestContext.request = new RestRequest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request.params.put('numberOfStudent','9988747670');
        RestContext.request.params.put('currentLocation','Mumbai');
        req.requestURI = 'https://services/apexrest/connecttoenquiry/';  
        req.httpMethod = 'GET';
        Test.StartTest();
        String result = ConnectToRestService.connectToEnquiry();
        Test.StopTest();
    }

    @isTest 
    static void unitTest2() {
        System.RestContext.request = new RestRequest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request.params.put('mobileNumber','9988747670');
        RestContext.request.params.put('currentLocation','Mumbai');
        RestContext.request.params.put('agencyName','Test');
        RestContext.request.params.put('emailId','mumbai123@gmail.com');
        req.requestURI = 'https://services/apexrest/connecttoenquiry/';  
        req.httpMethod = 'POST';
        Test.StartTest();
        String result = ConnectToRestService.connectToEnquiry('9988747670','Mumbai','mumbai123@gmail.com',null,'test323');
        result = ConnectToRestService.connectToEnquiry('9988747670','Mumbai','mumbai123@gmail.com',null,'test323');
        Test.StopTest();
    }

}