/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-05-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class BatchClassForBaseGenerationTracker {

    @TestSetup    
    public static void makeData(){  
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        program.nm_TotalSemesters__c = 4;
        program.Gap_Month__c = 6;
        update program;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Confirmed');
        update objAccount;
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        objopp.nm_Year__c = 2017;
        objopp.nm_Session__c = 'January';
        update objOpp;
        nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
        objSP.nm_Student__c =objAccount.id;
        //objSP.nm_EligiblityCriteria__c =objEc.id;
        objSP.nm_FeesPaidofSemester__c = 1;
        objSP.nm_Program__c = program.id;
        insert objSP;

        List<nm_AdmissionDriveDate__c> lst = new List<nm_AdmissionDriveDate__c>();
        nm_AdmissionDriveDate__c objADD = new nm_AdmissionDriveDate__c();
        objADD.Drive_Month__c ='January';
        objADD.Program_Type__c = 'All';
        objADD.Drive_Year__c = 2024;
        lst.add(objADD);

        nm_AdmissionDriveDate__c objADD1 = new nm_AdmissionDriveDate__c();
        objADD1.Drive_Month__c ='January';
        objADD1.Program_Type__c = 'Semester';
        objADD1.Drive_Year__c = 2024;
        lst.add(objADD1);

        nm_AdmissionDriveDate__c objADD2 = new nm_AdmissionDriveDate__c();
        objADD2.Drive_Month__c ='January';
        objADD2.Program_Type__c = 'Term';
        objADD2.Drive_Year__c = 2024;
        lst.add(objADD2);

        insert lst;
    }


    @isTest 
    static void unitTest1() {
        List<nm_AdmissionDriveDate__c> lst = [SELECT id FROM nm_AdmissionDriveDate__c LIMIT 1];
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration(lst[0].id);
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest2() {
        nm_StudentProgram__c objSP = [SELECT Id, nm_Program__c, nm_Student__c, nextsem__c FROM nm_StudentProgram__c LIMIT 1];
        system.debug('objSP --> ' + objSP);
        List<nm_AdmissionDriveDate__c> lst = [SELECT id FROM nm_AdmissionDriveDate__c WHERE Program_Type__c='All' LIMIT 1];
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration(lst[0].id);
            insert batchClass.getNewOpportunity('2', 'July', 2017, objSP.nm_Student__c, objSP);
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest3() {
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration(null);
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest4() {
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration('test');
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest5() {
        nm_StudentProgram__c objSP = [SELECT Id, nm_Program__c, nm_Student__c, nextsem__c FROM nm_StudentProgram__c LIMIT 1];
        system.debug('objSP --> ' + objSP);
        List<nm_AdmissionDriveDate__c> lst = [SELECT id FROM nm_AdmissionDriveDate__c WHERE Program_Type__c='Semester' LIMIT 1];
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration(lst[0].id);
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest6() {
        nm_StudentProgram__c objSP = [SELECT Id, nm_Program__c, nm_Student__c, nextsem__c FROM nm_StudentProgram__c LIMIT 1];
        system.debug('objSP --> ' + objSP);
        List<nm_AdmissionDriveDate__c> lst = [SELECT id FROM nm_AdmissionDriveDate__c WHERE Program_Type__c='Term' LIMIT 1];
        Test.startTest();
            BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration(lst[0].id);
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    // @isTest 
    // static void unitTest2() {
    //     DateTime startDate = System.now().addDays(-1);
    //     Account objAccount = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
    //     Task objTask = new Task(Subject='Call Scheduling', Status='Connected', Priority='Normal',  WhatId=objAccount.Id, Call_date__c=startDate.date(), Customer_number__c=objAccount.PersonMobilePhone, Actual_Call_Date__c=startDate);
    //     insert objTask;
    //     Test.startTest();
    //         Test.setMock(HttpCalloutMock.class, new RestMock());
    //         BatchClassForBaseGeneration batchClass = new BatchClassForBaseGeneration();
    //         Database.executeBatch(batchClass,200);
    //     Test.stopTest();
    // }
}