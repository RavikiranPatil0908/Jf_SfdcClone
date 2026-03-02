/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   20--01--2026   @Ravi   Initial Version
**/
@isTest(SeeAllData=false)
public class MobileAppFormPageAPIHandlerTracker {
  
    @testSetup
    static void setupData() {
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_RegistrationNo__c = '1234567890123';
        update objLead;
        nmGenericTracker.CreateCalender();
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Photo ID proof');
        nm_EligiblityCriteria__c objEligibility = nmGenericTracker.CreateElegibilityCriteria();
        objEligibility.nm_Program__c='MBA (Online) Programs';
        update objEligibility;
    }

    @IsTest

    static void UnitTest1() {

        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        /* Dashboard */
        callAPI('getDashboardDetails', new Map<String, Object>{'recordId' => led.Id });
    }
    @IsTest
    public static void unitTest2(){
          Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
           /* Fetch Lead / Account */
           callAPI('getLeadAccountDetails', new Map<String, Object>{ 'recordId' => led.Id,'registrationNumber' => led.nm_RegistrationNo__c  });
    }

    @IsTest
    public static void UnitTest3() {
         Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
          /* Update Lead */
          Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => led.Id,  'copyPermanantAddressFromTo' => 'Yes','objLead' => led};
          callAPI('updateLead',jsonMap);
    }

    @isTest
    public static void unitTest4(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        /* Confirmation */
        callAPI('goToConfirmationForm', new Map<String, Object>{ 'recordId' => led.Id, 'objLead'=> led});
    }
     
    @isTest
    public static void unitTest5(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        /* Documents */
        callAPI('getDocuments', new Map<String, Object>{ 'recordId' => led.Id });
    }

    @isTest
    public static void unitTest6(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
      /* Picklists */
        callAPI('getpickListvalues', new Map<String, Object>{'recordId' => led.Id });
    }

    @isTest
    public static void unitTest7(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        callAPI('getProgrampickListvalues', new Map<String, Object>{ 'recordId' => led.Id, 'chooseProgram'=> 'MBA (Online) Programs','IsLateral' => false , 'programType'=>'MBA'});
    }

    @isTest
    public static void unitTest8(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        /* Lateral Validation */
        callAPI('validateLateral', new Map<String, Object>{  'recordId' => led.Id, 'SAPId' => '72121234567','chooseProgram'=> 'MBA (Online) Programs' });
    }

    @isTest
    public static void unitTest9(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        Account acc =[SELECT Id FROM Account LIMIT 1];
        callAPI('updateLateralDetails', new Map<String, Object>{ 'recordId' => led.Id, 'accId'=>acc.Id, 'enrolledSem' => '2','oldprogram'=>'Diploma in Marketing Management' });
    }

    @isTest
    public static void unitTest10(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        // /* Non-Lateral */
        callAPI('updateNonLateral', new Map<String, Object>{ 'recordId' => led.Id,'IsLateral'=> false });
    }

    @isTest
    public static void unitTest11(){
        Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
        /* DEB Verification */
        callAPI('verifyDEB', new Map<String, Object>{'recordId' => led.Id, 'debId' => '123456789123', 'isTermAgreed'=> true});
    }

    @isTest
    public static void unitTest21(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
        /* DEB Verification */
        callAPI('verifyDEB', new Map<String, Object>{'recordId' => acc.Id, 'debId' => '123456789123', 'isTermAgreed'=> true});
    }

    @isTest
    public static void unitTest12(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
            // /* Interview */
        callAPI('getInterviewDetails', new Map<String, Object>{ 'recordId' => acc.Id  });
    }

    @isTest
    public static void unitTest13(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
            /* Interview */
            callAPI('getInterviewTimeSlot', new Map<String, Object>{ 'recordId' => acc.Id,'selectedDate' => String.valueOf(Date.today())});
    }

    @isTest
    public static void unitTest18(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
            /* Interview */
            callAPI('getInterviewTimeSlot', new Map<String, Object>{ 'recordId' => acc.Id});
    }

    @isTest
    public static void unitTest14(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
        /* Interview */
        callAPI('saveCallDetails', new Map<String, Object>{ 'recordId' => acc.Id, 'selectedDate' => String.valueOf(Date.today()) , 'selectedTime'=> '9 AM'});
    }

    @isTest
    public static void unitTest15(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
             /* Welcome Letter */
        callAPI('getWelcomeLetter', new Map<String, Object>{'recordId' => acc.Id });
    }

    @isTest
    public static void unitTest16(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
        nm_LinksForDocuments__c linkDoc = [select id,nm_Status__c from nm_LinksForDocuments__c limit 1];
        /* Upload Docs */
        callAPI('uploaddocuments', new Map<String, Object>{ 'recordId' => acc.Id,'documentId' =>linkDoc.id,'uploadMode'=>'Test','documentURL'=>'www.google.com' });

    }

    @isTest
    public static void unitTest17(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
             /* Welcome Letter */
        callAPI('getWelcomeLetter', new Map<String, Object>{'recordId' => null});
    }

    @isTest
    public static void unitTest19(){
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];
            // /* Interview */
        callAPI('getInterviewDetails', new Map<String, Object>{ 'recordId' => null  });
    }

    @IsTest
    public static void UnitTest20() {
         Lead led = [ SELECT Id, nm_RegistrationNo__c FROM Lead LIMIT 1 ];
          /* Update Lead */
          Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => led.Id,  'copyPermanantAddressFromTo' => 'Yes'};
          callAPI('updateLead',jsonMap);
    }


    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res=new HTTPResponse(); 
            res.setHeader('Content-Type','application/x-www-form-urlencoded');
             res.setBody(''); 
             res.setStatusCode(200); return res;
        }
    }

    public static void callAPI(String action, Map<String, Object> body) {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/api/LeadAccountService/' + action;
        req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        MobileAppAPIService.saveData();
        Test.stopTest();
    }
}