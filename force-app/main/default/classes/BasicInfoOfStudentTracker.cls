/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   01-04-2021   shubhranshu   Initial Version
**/
@isTest
public class BasicInfoOfStudentTracker
{           
    public static Referral__c objReferral;
    public static Webinar__c objWebinar;
    public static Youtube_Link__c objYoutubeLink;
     
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
    static testmethod void UnitTest1()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
         
        objWebinar = new Webinar__c ();
        objWebinar.Active__c =TRUE;
        objWebinar.Send_Confirmation_Mail__c =TRUE;
        objWebinar.Event_Date__c =system.today();
        objWebinar.Description__c ='thanks';
        objWebinar.Closure_Messge__c ='thanks';
        objWebinar.Duplicate_Message__c ='thanks';
        objWebinar.Thankyou_Message__c ='thanks';
        objWebinar.Logo__c ='NGA Logo';
        objWebinar.Content__c =' NGA Logo';
        objWebinar.Heading__c ='NGA Logo';
        objWebinar.Page_Title__c ='NGA Logo';
        objWebinar.End_Time__c =   Time.newInstance(1, 2, 3, 4);
        objWebinar.Start_Time__c =  Time.newInstance(4, 2, 3, 4);
      
        insert objWebinar;
       
       objYoutubeLink = new Youtube_Link__c();
       objYoutubeLink.Title__c ='hello';
       objYoutubeLink.Youtube_Link__c ='https://www.youtube.com/embed/EXUnnESRwR8?list=PLWZrAzQzdJHlZzOcOv1IfljS2yZHLrH63';
       objYoutubeLink.Webinar__c = objWebinar.id;
       insert objYoutubeLink;
       
        
        objReferral = new Referral__c();
        objReferral.Name__c ='test';
        objReferral.Email__c = 'sandip@gmail.com';
        objReferral.Mobile_Number__c = '8565987568';
        objReferral.City__c = 'Mumbai';   
        objReferral.Webinar__c = objWebinar.id;     
        insert objReferral;
        
        
        
        apexpages.currentpage().getparameters().put('webinar',objWebinar.id);
        
        BasicInfoOfStudent obj = new BasicInfoOfStudent();
        obj.Save();
        obj.ImageUrl();
        obj.getYoutubeLinks();
        
    }
 
}