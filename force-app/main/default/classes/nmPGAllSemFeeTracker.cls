/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   01-07-2021   shubhranshu   Initial Version
**/
@isTest(SeeAllData=false)
public class nmPGAllSemFeeTracker {

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

    @testSetup
    public static void setUpData() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');

      //  Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        // LeadId = objLead.id;
   //     System.debug('lead id-->'+objLead.id);
     //   nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        // nm_Payment__c objpayment =  nmGenericTracker.CreatePaymentRecords(objLead.id,'Admission','Lead','Admission');
        
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
      //  objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c = system.today();
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'AnnualFee');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objopp);
        Product2 productvs1 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,1);

        nm_Payment__c objPayment = nmGenericTracker.CreatePaymentRecords(objopp.id,'Admission','Opportunity','Admission');
        objPayment.nm_PaymentStatus__c = 'Payment Approved';
        update objPayment;

        objopp.StageName = 'Closed Won';
        update objOpp;

        Product2 product2 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,2);

        // insert Courses
        nm_Courses__c objCourse = new nm_Courses__c();
        objCourse.ConsumerType__c = 'Retail';
        objCourse.IsActive__c = true;
        objCourse.Program_Structure__c = 'Jul2019';
        objCourse.Program__c = objOpp.nm_Program__c;
        objCourse.Semester__c = 2;
        objCourse.nm_Semester__c = product2.id;
        objCourse.Student_Zone_Course_Id__c = 11;
        objCourse.Student_Zone_Program_Code__c = String.valueOf(objCourse.Student_Zone_Course_Id__c);
        objCourse.Student_Zone_Subject_Code__c = objCourse.Student_Zone_Program_Code__c;
        insert objCourse;
    }

    @isTest 
    static void unitTest1() { 
        Test.startTest();
            Account objAccount = [SELECT id,Is_Lateral__c FROM Account LIMIT 1];
            Opportunity objopp = [SELECT id,StageName,LiveLecturesType__c,nm_Future_Sems_Created__c,nm_Program__c,nm_Semester__c FROM Opportunity WHERE nm_Semester__c='2' AND AccountId=:objAccount.id LIMIT 1];
            System.debug('objopp==>'+objopp.nm_Program__c);
            nmGenericTracker.CreateOpportunityLineItemWithLiveLecture(objopp);
            objopp.LiveLecturesType__c = '2SemLecturesFee';
            objopp.nm_Future_Sems_Created__c = true;
            objopp.StageName = 'Closed Won';
            update objopp;
            nmPGAllSemFee controller = new nmPGAllSemFee();
        Test.stopTest();
    }
}