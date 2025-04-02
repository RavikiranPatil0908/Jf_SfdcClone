@isTest(SeeAllData=false)
public class LeadSquareWebhookAPITracker{
    
     private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    nmGenericTracker.InsertSerialNo();
      Lead  objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Status ='Hot';
        objLead.Lead_Description__c ='Fees too High';
        objLead.Next_Follow_up__c =system.now().addMinutes(30);
         update objLead;
    }
    
        // test method for 500 errorCode : Meta data not matched.
  static testMethod void testTrackLeadSquare(){
              Lead ld=[select id,email,mobilePhone,Status,Lead_Description__c,GroupName__c from Lead limit 1];

    Test.startTest();     
    String myJSON = '{"Before":{"ProspectID":"6ba78830-bd39-435f-8687-460b677f3fb4","ProspectAutoId":"1039","FirstName":"Ringo","LastName":"Starr","EmailAddress":"virkdsingh12@gmail.com","Phone":null,"Mobile":9029085647,"Source":null,"SourceMedium":null,"SourceCampaign":null,"ProspectStage":"Lead","Score":"2","EngagementScore":"0","ProspectActivityName_Max":"Example Custom Activity","ProspectActivityDate_Max":"2018-06-14 12:15:00","OwnerId":"3b1041fb-8374-11e7-8758-0a106ee76b21","ModifiedBy":"3b1041fb-8374-11e7-8758-0a106ee76b21","ModifiedOn":"2018-03-06 06:55:46","LastModifiedOn":"2018-06-14 12:15:35","NotableEvent":"Example Custom Activity","NotableEventdate":"2018-06-14 12:15:00","QualityScore01":"1.67","ConversionReferrerURL":null,"SourceReferrerURL":null,"SourceIPAddress":null,"LeadLastModifiedOn":"2018-06-14 12:15:35","OwnerIdEmailAddress":"virkdsingh@gmail.com","ModifiedByName":"Vir Singh","mx_Lead_Status":"Hot","mx_Lead_Description":"Fees too high"},"After":{"ProspectID":"6ba78830-bd39-435f-8687-460b677f3fb4","ProspectAutoId":"1039","FirstName":"Ringo","LastName":"Starr","EmailAddress":"Ringo@example.com","Phone":null,"Mobile":null,"Source":null,"SourceMedium":null,"SourceCampaign":null,"ProspectStage":"Opportunity","Score":"2","EngagementScore":"0","ProspectActivityName_Max":"Example Custom Activity","ProspectActivityDate_Max":"2018-06-14 12:15:00","OwnerId":"3b1041fb-8374-11e7-8758-0a106ee76b21","ModifiedBy":"3b1041fb-8374-11e7-8758-0a106ee76b21","ModifiedOn":"2018-06-14 12:18:23","LastModifiedOn":"2018-06-14 12:18:24","NotableEvent ":"Modified","NotableEventdate":"2018-06-14 12:18:23","QualityScore01":"1.67","ConversionReferrerURL":null,"SourceReferrerURL":null,"SourceIPAddress":null,"LeadLastModifiedOn":"2018-06-14 12:18:24","OwnerIdEmailAddress":"virkdsingh@gmail.com","ModifiedByName":"Vir Singh","mx_Lead_Status":"Hot","mx_Lead_Description":"Fees too high"}}';
    RequestData(myJSON,'POST');
    LeadSquareWebhookAPI.TrackLeadStage();
    Test.stopTest();
    
  }
  public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/eduvanzTrackLoanApp/V1.1/';
        request.httpMethod=requestMethod;
    request.requestBody = Blob.valueof(myJSON);
    RestContext.request = request;
    RestContext.response = response;
  }

    
}