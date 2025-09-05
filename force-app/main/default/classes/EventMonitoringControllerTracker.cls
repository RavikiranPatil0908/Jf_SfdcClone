/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 05-06-2025
 * @last modified by  : @Shailesh
**/
@isTest(SeeAllData=false)
public without sharing class EventMonitoringControllerTracker {


     @TestSetup
    static void makeData() {
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('No',false,'Confirmed');
    }

    @isTest
    static void unittest1(){
        List<Lead> lstlead = [Select Id from lead ];
        Lead objLead = lstlead[0];
        Test.startTest();
        EventMonitoringController.insertEventMonitoring(objLead.Id, UserInfo.getUserId(), 'Lead', 'event');
        Test.stopTest();

    }
    @isTest
    static void unittest2(){
        List<Account> lstAccount = [Select Id from Account ];
        Account objAccount = lstAccount[0];
        Test.startTest();
        EventMonitoringController.insertEventMonitoring(objAccount.Id, UserInfo.getUserId(), 'Account', 'event');
        Test.stopTest();

    }

}