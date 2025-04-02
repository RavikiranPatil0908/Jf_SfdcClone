/**
* @author shubhranshu
*/
@isTest
private class RatingController_Tracker {

    /**
     * This is a test method for RatingController
     */

    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
          
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void test_RatingController() {

        Test.startTest();

        RatingController ratingController = new RatingController();

        Test.stopTest();
    }


    /**
     * This is a test method for getQueryAllFieldSql
     */
    static testMethod void test_getQueryAllFieldSql() {

        Test.startTest();

        String SObjectAPIName = 'Student_Rating__c';
        String conditionString = 'nm_RegistrationNumber__c !=null';
        String relatedField = null;
        RatingController ratingController = new RatingController();
        String resultGetQueryAllFieldSql = ratingController.getQueryAllFieldSql(SObjectAPIName,conditionString,relatedField);


        Test.stopTest();
    }


    /**
     * This is a test method for validateApplicantName
     */
    static testMethod void test_validateApplicantName() {

        Test.startTest();

        RatingController ratingController = new RatingController();
        ratingController.validateApplicantName();


        Test.stopTest();

    }


    /**
     * This is a test method for QueryRating
     */
    static testMethod void test_QueryRating() {

        Test.startTest();

        RatingController ratingController = new RatingController();
        ratingController.QueryRating();


        Test.stopTest();
    }


    /**
     * This is a test method for SaveDetail
     */
    static testMethod void test_SaveDetail() {

        Test.startTest();

        RatingController ratingController = new RatingController();
        PageReference resultSaveDetail = ratingController.SaveDetail();


        Test.stopTest();

    }


    /**
     * This is a test method for all
     */
    static testMethod void test_all() {

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Student_Rating__c studRat =new Student_Rating__c();
        studRat.Student__c=objAccount.Id;
        insert studRat;
        ApexPages.currentPage().getParameters().put('RegNo',objAccount.nm_RegistrationNumber__c);
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new RestMock());

        //  test RatingController
        RatingController ratingController = new RatingController();

        //  test validateApplicantName
        ratingController.validateApplicantName();

        //  test QueryRating
        ratingController.QueryRating();

        // test offset
        Double offset = ratingController.offset;

        //  test SaveDetail
        PageReference resultSaveDetail = ratingController.SaveDetail();

        Test.stopTest();

    }


}