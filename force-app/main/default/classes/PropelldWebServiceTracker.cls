/**
 * @File Name          : PropelldWebServiceTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 11/4/2020, 2:19:10 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/4/2020   @BK     Initial Version
**/
@isTest(SeeAllData = false)
public class PropelldWebServiceTracker {
    
    public class RestMock implements HttpCalloutMock{
        public Integer statusCode;
        RestMock(){
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Code":0,"Errors":[],"Message":"SUCCESS","PayLoad":{"QuoteId":"91279988-3b69-428e-b94b-ac167a86c4ef","RedirectionUrl":"http://pp.propelld.com/application-creation/quote/91279988-3b69-428e-b94b-ac167a86c4ef"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockII implements HttpCalloutMock{   
        RestMockII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"Code":0,"Errors":[],"Message":"SUCCESS","PayLoad":{"StatusUpdated": true}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }

    @isTest
    static void createNewLoanApplication() {
        Test.startTest();
            RestMock rest = new RestMock();
            Test.setMock(HttpCalloutMock.class,rest );
            PropelldWebService objPropelldWebService = new PropelldWebService();
            objPropelldWebService.createNewLoanApplication('41500','Sachinmohite927@gmail.com','Sachin','Mohite','8652603545','https://ngasce.force.com/PostPaymentPage',6200,'1','006O0000008HHGV','Lead',84000,'1','1');
        Test.stopTest();
    }

    @isTest
    static void updateStatusByQuoteId() {
        Test.startTest();
            RestMockII rest = new RestMockII();
            Test.setMock(HttpCalloutMock.class,rest);
            PropelldWebService objPropelldWebService = new PropelldWebService();
            objPropelldWebService.updateStatusByQuoteId('41500',true,'006O0000008HHGV','Lead');
        Test.stopTest();
    }
    

}