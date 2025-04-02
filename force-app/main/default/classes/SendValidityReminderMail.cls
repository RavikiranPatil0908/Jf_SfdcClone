/**
 * @File Name          : SendValidityReminderMail.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Monikac
 * @Last Modified On   : 06-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/11/2019   @BK     Initial Version
**/
global class SendValidityReminderMail implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    // Account Mail count can't exced 1000 limit
    global Integer totalMailSentToAccounts = 0;
    global Set<String> alreadyMailSentAccountIds = new Set<String>();

    global void execute(SchedulableContext sc) {
        SendValidityReminderMail b = new SendValidityReminderMail();
        Database.executebatch(b, 200);
    }

    /**
    * @description 
    * @author @BK | 23/11/2019 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){

        String validtyUpto = getExpiryDrive();
        List<String> choosePrograms = new List<String>{'Post Graduate Diploma Programs','Diploma Programs','Certificate Programs','MBA (Distance) Programs','Professional Programs'};
        List<String> lstDrivesAvoid = new List<String>{'January2023','July2023'};
        String query = 'SELECT id, PersonContactId, PersonEmail, PersonMobilePhone, nm_AccountEmail__c,ICemailaddress__c,LC_email_id__c'
                        +' FROM Account WHERE nm_StudentStatus__c=\'Confirmed\' AND Pass_Out__c=false AND nm_Program__r.IsTerm__c=false AND nm_ChooseaProgram__c IN :choosePrograms'+
                        +' AND (Extend_Validity_upto_Month__c=null OR Extend_Validity_upto_Month__c=\'\') AND nm_Account_Category__c!=\'Corporate\' AND nm_Centers__r.ConsumerType__c IN (\'Retail\',\'Verizon\')' +
                        +' AND ValidUptoR__c=:validtyUpto AND nm_Drive_Name__c NOT IN :lstDrivesAvoid';
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 23/11/2019 
    * @param bc 
    * @param scope 
    * @return void 
    **/
    global void execute(Database.BatchableContext bc,List<Account> scope){
        Integer maxEmailCount = Integer.valueOf(System.Label.Max_Reminder_Per_Day_Mail_Count);

        if(totalMailSentToAccounts < maxEmailCount) {
            Messaging.SingleEmailMessage[] lstMails = new List<Messaging.SingleEmailMessage>();
            // To Query Organisation Details.
            OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS Global Access' LIMIT 1];
            // To Query the Email Template.
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'Program Validity End - Reminder (6 months)' LIMIT 1];
            //  To Query the tasks for all the emails already sent to the students.
            if(alreadyMailSentAccountIds.size() == 0) {
                List<Task> lstTasks = [SELECT AccountId FROM Task WHERE ActivityDate=THIS_MONTH AND Subject LIKE 'Email: Validity Period - NMIMS%' LIMIT 10000];
                if(lstTasks.size() > 0) {
                    for(Task objTask : lstTasks) {
                        alreadyMailSentAccountIds.add(objTask.AccountId);
                    }
                }
                System.debug('alreadyMailSentAccountIds 1==>'+alreadyMailSentAccountIds.size());
            }
            System.debug('alreadyMailSentAccountIds ==>'+alreadyMailSentAccountIds.size());
            List<Account> lstAccountToSendMail = new List<Account>();
            // To filter All the Student for whom already mail sent
            if(alreadyMailSentAccountIds.size() > 0) {
                for (Sobject s : scope) {
                    Account objAccount = (Account)s;
                    Id accountId = s.Id;
                    if(!alreadyMailSentAccountIds.contains(accountId) && totalMailSentToAccounts < maxEmailCount) {
                        lstAccountToSendMail.add(objAccount);
                        totalMailSentToAccounts++;
                    }
                }
            } 
            else {
                for (Sobject s : scope) {
                    if(totalMailSentToAccounts < maxEmailCount) {
                        Account objAccount = (Account)s;
                        lstAccountToSendMail.add(objAccount);
                        totalMailSentToAccounts++;
                    }
                }
            }
            System.debug('totalMailSentToAccounts ==>'+totalMailSentToAccounts);
            System.debug('lstAccountToSendMail ==>'+lstAccountToSendMail);
            if(lstAccountToSendMail.size() > 0) {
                for(Account objAccount : lstAccountToSendMail){
                    System.debug('objaccount ==>'+objAccount);
                    Messaging.SingleEmailMessage message = getEmail(objAccount, emailTemplate);
                    message.setOrgWideEmailAddressId(owe.id);            
                    lstMails.add(message);  
                }

                System.debug('lstMails.size ==>'+lstMails.size());
                if(lstMails.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails, false);
                    for(Messaging.SendEmailResult result: results) {
                        if(!result.isSuccess()) {
                            // render the error somehow
                            System.debug('result ==>'+result);
                            totalMailSentToAccounts--;
                        }
                    }
                }
            }
        } else {
            //We don't want to process further in batch
            //Do finish processing here 
            myCustomFinish();

            //After that abort the Job
            System.abortJob(bc.getJobId()); 
        }
    }

    global void finish(Database.BatchableContext bc){
        Date filterDate = System.today().addMonths(-3);
        filterDate = filterDate.addMonths(1).toStartofMonth().addDays(-1);
        System.debug(filterDate);
        List<Task> lstTasks = [SELECT Id FROM Task WHERE ActivityDate<=:filterDate AND Subject LIKE 'Email: Validity Period - NMIMS%' LIMIT 10000];
        if(lstTasks.size() > 0) {
            delete lstTasks;
        }
        System.debug('Finished');
    }

    /**
    * @description 
    * @author @BK | 23/11/2019 
    * @param objaccount 
    * @param emailTemplate 
    * @return Messaging.SingleEmailMessage 
    **/
    public static Messaging.SingleEmailMessage getEmail(Account objaccount,EmailTemplate emailTemplate) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(objaccount.PersonContactId); 
        message.setReplyTo('ngasce@nmims.edu');
        List<String> toAddresses = new List<String>();
        List<String> toBcc = new List<String>(); 
        toBcc.add(objaccount.ICemailaddress__c);
        toAddresses.add(objaccount.PersonEmail);
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(objaccount.Id); //This is important for the merge fields in template to work
        message.setToAddresses(toAddresses);
        message.setBccAddresses(toBcc); // Changed from setCcAddresses to setBccAddresses
        message.setSaveAsActivity(true);
        System.debug('message ==>'+message);
        return message;
    }

    /**
    * @description 
    * @author @BK | 23/11/2019 
    * @return String 
    **/
    public static String getExpiryDrive() {
        Integer currentYear = System.Today().year();
        Integer findInWhichHalf = System.Today().month() / 6; 
        String validityUpto = 'Jun '+String.valueOf(currentYear);
        if(findInWhichHalf > 0) {
            validityUpto = 'Dec '+String.valueOf(currentYear);
        }
        System.debug('findInWhichHalf ==>'+findInWhichHalf);
        return validityUpto;
    }

    private void myCustomFinish() {
        System.debug('finish called');    
    }


}