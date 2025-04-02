/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : @BK
**/
@isTest
public with sharing class GenerateApprovalURL_Test {

    @IsTest
    static void methodName1(){
        
        Test.startTest();
        Case objcase = new Case();
        objcase.nm_Category__c = 'Admissions';
        objcase.sub_categories__c = 'Acknowledgement';
        objcase.StudentZone_QueryId__c ='2261';
        objcase.SuppliedEmail ='sachin920@gmail.com';
        insert objcase;
        // Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(objcase.Id);
        // Approval.process(req1);

        GenerateApprovalURl instance = new GenerateApprovalURl();
        instance.setObjId(objcase.Id);
        instance.getObjId();
        instance.urlStr = '';
        Test.stopTest();
        
    }
}