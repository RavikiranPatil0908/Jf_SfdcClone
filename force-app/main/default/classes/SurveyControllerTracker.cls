/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-23-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   02-20-2021   @BK   Initial Version
**/
@istest(SeeAllData=false)
public class SurveyControllerTracker {
    
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Contact objContact = new Contact();
        objContact.Account = objAccount;
        objContact.FirstName = 'test';
        objContact.LastName = 'test';
        objContact.Email = objAccount.PersonEmail;
        objContact.MobilePhone = objAccount.PersonMobilePhone;
        insert objContact;

        Counsellor_Profile__c objcounselorprofile = new Counsellor_Profile__c();
        objcounselorprofile.First_Name__c = 'fagu';
        objcounselorprofile.Middle_Name__c = 'dsafdsf';
        objcounselorprofile.Employee_Image_URL__c='www.gmail.com';
        objcounselorprofile.Employee_Sign_URL__c='www.gmail.com';
        insert objcounselorprofile;

        Survey__c objsurve =new Survey__c();
        objsurve.Name='test';
        objsurve.Hide_Survey_Name__c=true;
        objsurve.Submit_Response__c='hvgcdrt';
        objsurve.Survey_Container_CSS__c='hgfytfrtdrt';
        objsurve.Survey_Header__c='gfrtfty';
        objsurve.thankYouLink__c='hgf';
        objsurve.showResponseAfterSubmit__c = true;
        insert objsurve;

        Case c3 =new Case();
        c3.Status= 'New';
        c3.Contact = objContact;   
        c3.Subject ='Book misplaced';
        c3.StudentZone_QueryId__c ='2261';
        c3.SuppliedEmail ='sachin920@gmail.com';
        c3.Description ='Fedex has lost my book';
        insert c3;

        List<Survey_Question__c> lstQus = new List<Survey_Question__c>();
        for(Integer i=0;i<3;i++){
            Survey_Question__c Q1 = new Survey_Question__c();
            Q1.Required__c =true;
            Q1.Name='test';
             Q1.Choices__c='Test';
            Q1.OrderNumber__c=i;
            Q1.Question__c='hgft';
            Q1.Required__c =true;
            Q1.Survey__c=objsurve.id;
            Q1.Type__c='Single Select--Horizontal';
            lstQus.add(Q1);
    
            Survey_Question__c Q2 = new Survey_Question__c();
            Q2.Required__c =true;
            Q2.Name='test';
            Q2.OrderNumber__c=i;
            Q2.Question__c='hgft';
            Q2.Required__c =true;
            Q2.Survey__c=objsurve.id;
            Q2.Choices__c = 'Test';
            Q2.Type__c='Multi-Select--Vertical';
            lstQus.add(Q2);
    
            Survey_Question__c Q3 = new Survey_Question__c();
            Q3.Required__c =true;
            Q3.Name='test';
            Q3.OrderNumber__c=i;
            Q3.Question__c='hgft';
            Q3.Required__c =true;
            Q3.Survey__c=objsurve.id;
            Q3.Choices__c = 'Test';
            Q3.Type__c='Single Select--Vertical';
            lstQus.add(Q3);
    
            Survey_Question__c Q4 = new Survey_Question__c();
            Q4.Required__c =true;
            Q4.Name='test';
            //  Q4.Choices__c='hgftyfty';
            Q4.OrderNumber__c=i;
            Q4.Question__c='hgft';
            Q4.Required__c =true;
            Q4.Survey__c=objsurve.id;
            Q4.Type__c='Free Text';
            lstQus.add(Q4);
        }
        insert lstQus;
    }

    @isTest
    static void unitTest1() {
        Survey__c objsurve = [SELECT id FROM Survey__c LIMIT 1];
        Contact objContact = [SELECT id FROM Contact LIMIT 1];
        Case objCase = [SELECT id FROM Case LIMIT 1];

        Apexpages.currentPage().getParameters().put('id',objsurve.id);  
        Apexpages.currentPage().getParameters().put('caId',objCase.id);
        Apexpages.currentPage().getParameters().put('cId',objContact.id);

        SurveyController controller = new SurveyController();
        for (SurveyController.question q : controller.allQuestions) {
            if(q.renderSelectRadio == 'true') {
                q.selectedOption = '0';
            } else if(q.renderSelectCheckboxes == 'true') {
                q.selectedOptions = new List<String>{'0'};
            } else if(q.renderSelectRow == 'true') {
                q.selectedOption = '0';
            } else if(q.renderFreeText == 'true') {
                q.choices = 'Test';
            }
        }
        
        controller.submitResults();
    }

    @isTest
    static void unitTest2() {
        Survey__c objsurve = [SELECT id FROM Survey__c LIMIT 1];
        Counsellor_Profile__c objprofile = [SELECT id FROM Counsellor_Profile__c LIMIT 1];

        Apexpages.currentPage().getParameters().put('id',objsurve.id);  
        Apexpages.currentPage().getParameters().put('cpid',objprofile.id);

        ExecutiveSurveyController controller = new ExecutiveSurveyController();
        for (SurveyController.question q : controller.allQuestions) {
            if(q.renderSelectRadio == 'true') {
                q.selectedOption = '0';
            } else if(q.renderSelectCheckboxes == 'true') {
                q.selectedOptions = new List<String>{'0'};
            } else if(q.renderSelectRow == 'true') {
                q.selectedOption = '0';
            } else if(q.renderFreeText == 'true') {
                q.choices = 'Test';
            }
        }
        
        controller.saveAndNext();
    }
}