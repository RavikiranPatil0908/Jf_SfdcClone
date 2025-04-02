/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : @vickysahu
**/
public with sharing class InterviewApprovalBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    public List<String> interviewSlotIds = new List<String>();
     public void execute(SchedulableContext sc) {
        InterviewApprovalBatchClass b = new InterviewApprovalBatchClass();
        Database.executebatch(b, 200);
    }

       public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('InterviewApprovalBatchClass Batch Class Started');
        DateTime myDateTime = DateTime.now();

        DateTime last3DayLead = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -5 , 0, 0, 0);
        Date last3Day = last3DayLead.date();

        Date todayDate = Date.today();
        
        String query ='';

        List<String> lstOFApproval = new List<String>{'On Waiting List', 'Approval Pending', 'Absent'};
        if(!Test.isRunningTest()) {

            // query = 'SELECT id, (SELECT Interview_Status__c FROM Accounts__r WHERE Interview_Status__c IN :lstOFApproval ) FROM Interview_Slot__c WHERE Interview_Date__c >= :last3Day AND Interview_Date__c < :todayDate  AND Send_Interview_Batch__c = false AND Program_Type__c = \'MBA (WX)\' AND Id In (SELECT Interview_Slot__c FROM Account) ' ;
            query = 'SELECT id FROM Interview_Slot__c WHERE Interview_Date__c >= :last3Day AND Interview_Date__c < :todayDate  AND Send_Interview_Batch__c = false AND Program_Type__c = \'MBA (WX)\' AND Id In (SELECT Interview_Slot__c FROM Account) ' ;
        } else {
            query = 'SELECT id FROM Interview_Slot__c' ;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {

        for(SObject sc : scope){
            Integer totalNoAccount = 0;
            Integer accountWithStatus = 0;
            List<String> lstOFApproval = new List<String>{'On Waiting List', 'Approval Pending', 'Absent'};
            Interview_Slot__c objInterviewSlot = (Interview_Slot__c)sc;
            List<Account> lstAccounts = [SELECT Id, Interview_Status__c From Account Where Interview_Slot__c = :objInterviewSlot.Id];
            totalNoAccount = lstAccounts.size();
            for(Account objAccount : lstAccounts) {
                if(lstOFApproval.contains(objAccount.Interview_Status__c) ) {
                    accountWithStatus = accountWithStatus + 1;
                }
            }
            if((totalNoAccount == accountWithStatus) && totalNoAccount > 0) {
                sendMail(objInterviewSlot.Id);
                interviewSlotIds.add(objInterviewSlot.Id);
            }
            
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Interview_Slot__c> lstInterviewSlot = new List<Interview_Slot__c>();

        if(interviewSlotIds.size() > 0) {
            for (String id : interviewSlotIds) {
                Interview_Slot__c updateInterviewSlot = new Interview_Slot__c();
                updateInterviewSlot.Id = id;
                updateInterviewSlot.Send_Interview_Batch__c = true;
                lstInterviewSlot.add(updateInterviewSlot);
            }
        }
        if(lstInterviewSlot.size() > 0) {
            update lstInterviewSlot;
        }
    }

    public void sendMail(String InterviewSlotId) {
        List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name ='Inverview Slot Approval' LIMIT 1];
    system.debug(emailTemplates);

    system.debug(UserInfo.getUserId());

    
    List<User> user = new List<User>();
    if(System.Label.Environment == 'Sandbox') {
        user = [Select Id, email From User Where Profile.Name = 'System Administrator' LIMIT 1 ];
      } else if(System.Label.Environment == 'Production') {
          user = [Select Id, email From User Where Email =  'manasvi.malve@nmims.edu' AND Profile.Name = 'Head Office' LIMIT 1 ];
      }
    
    system.debug(user);

    /*
    You’ll need to target your desired user wherever I use UserInfo.getUserId()
    */
    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplates[0].Id,user[0].Id, InterviewSlotId);
    OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
    String[] sendingToCCAddress = new List<String>{'smita.nadkarni@nmims.edu','vicky.sahu.ext@nmims.edu'};
    
    String emailSubject = email.getSubject();
    String emailTextBody = email.getHtmlBody();
    
    email.setTargetObjectId(user[0].Id);
    email.setOrgWideEmailAddressId(owe.id); 
    email.setSubject(emailSubject);
    email.setHtmlBody(emailTextBody);
    email.setCcAddresses(sendingToCCAddress);
    email.saveAsActivity = false;


    Messaging.sendEmail(new List<Messaging.Email>{email});
    }
}