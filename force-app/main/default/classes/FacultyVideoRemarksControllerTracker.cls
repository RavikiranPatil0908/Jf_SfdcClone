/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class FacultyVideoRemarksControllerTracker {

    @TestSetup
    static void makeData(){ 
        Async_Shoot_Post_Production__c obj = new Async_Shoot_Post_Production__c();
        obj.Subject__c = 'Business Analytics';
        obj.Chapter_Name__c = 'Test';
        obj.Faculty_Email__c = 'Test@test.com';
        obj.Shoot_Date__c = System.today();
        obj.Faculty_Name__c = 'Anurag Garg';
        obj.Recording_Format__c = 'Zoom';
        obj.Recording_Platform__c = 'Zoom';
        obj.Post_Production_Minutes__c = 10;
        obj.Partner__c = 'Devendra Sharma';
        obj.Editor_Name__c = 'Devendra Sharma';
        obj.Editor_Email_Id__c = 'devendrasuthra750@gmail.com';
        obj.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Video_Link_Version_2__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Program__c = 'UG';
        obj.Internal_Video_Remarks__c = 'test';
        insert obj;
    }

    @isTest
    static void unitTest1() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id FROM Async_Shoot_Post_Production__c LIMIT 1];
        test.startTest();
            ApexPages.currentPage().getParameters().put('recordId',lstPP[0].Id);
            ApexPages.currentPage().getParameters().put('remark','1');
            FacultyVideoRemarksController obj = new FacultyVideoRemarksController();
            obj.facultyRemarks = 'Test';
            obj.mappingStatus = 'No Current mapping in TOC';
            obj.topics = 'test';
            obj.subTopics = 'test';
            obj.learnOb = 'test';
            obj.learnOc = 'test';
            obj.internalRemark = 'test';
            obj.submitRemark();
        test.stopTest();
    }

    @isTest
    static void unitTest2() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Name FROM Async_Shoot_Post_Production__c LIMIT 1];
        test.startTest();
            SendEmailToFaculty.callEmailAlertFlow(lstPP[0].Id,lstPP[0].Name,'1','test@gmail.com','Business Analytics','22/10/2023','test','test','test','test');
        test.stopTest();
    }

    @isTest
    static void unitTest3() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id FROM Async_Shoot_Post_Production__c LIMIT 1];
        test.startTest();
            ApexPages.currentPage().getParameters().put('id',lstPP[0].Id);
            SendFacultyRemarkToEditorController obj = new SendFacultyRemarkToEditorController();
        test.stopTest();
    }

    @isTest
    static void unitTest4() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id FROM Async_Shoot_Post_Production__c LIMIT 1];
        test.startTest();
            ApexPages.currentPage().getParameters().put('recordId',lstPP[0].Id);
            ApexPages.currentPage().getParameters().put('remark','2');
            FacultyVideoRemarksController obj = new FacultyVideoRemarksController();
            obj.facultyRemarks = 'Test';
            obj.submitRemark();
        test.stopTest();
    }
}