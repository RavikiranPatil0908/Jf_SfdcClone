/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-14-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-03-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class MassProgramTransferBatchTracker {
    
    @testSetup
    public static void setUpData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2021;
        objCal.Session_End_Date__c = system.today()+1;
        insert objCal;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_Year__c = 2021;
        update objLead;


        nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.BookCChargeapplicable__c = true ;
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = 'MBA (Business Management)';
       program.nm_ProgramValidity__c = 4;
       program.nm_TotalSemesters__c = 4;
       program.nm_Type__c = 'MBA (Distance) Programs';
       program.prgst__c ='Jul2019';
       program.PVM__c = 48;
       insert program; 

        // Calender__c objCal2 = new Calender__c();
        // objCal2.Session_Start_Date__c = system.today();
        // objCal2.Session__c = 'January';
        // objCal2.Year__c = 2017;
        // objCal2.Session_End_Date__c = system.today()+1;
        // insert objCal;
    }

    @isTest
    static void unitTest1() {
        Test.startTest();
            MassProgramTransferBatch batchClass = new MassProgramTransferBatch();
            Database.executeBatch(batchClass,50);
        Test.stopTest();
    }
}