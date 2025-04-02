/**
 * @File Name          : SendValidityExpiredReminderMail.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Monikac
 * @Last Modified On   : 06-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/11/2019   @BK     Initial Version
**/
global class SendValidityExpiredReminderMail implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    // Account Mail count can't exced 1000 limit
    global Integer totalMailSentToAccounts = 0;
    global Set<String> alreadyMailSentAccountIds = new Set<String>();
    
    global void execute(SchedulableContext sc) {
        SendValidityExpiredReminderMail b = new SendValidityExpiredReminderMail();
        Database.executebatch(b, 200);
    }

    /**
    * @description 
    * @author @BK | 25/11/2019 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){

        List<String> lstValidPeriod = getExpiryDrive();
        List<String> previousMonths = getPreviousMonthsDrive(6);
        String validtyUptoForDec = lstValidPeriod[0];
        String validtyUptoForJun = lstValidPeriod[1];
        List<String> lstChoosePrograms = new List<String>{'Post Graduate Diploma Programs','Diploma Programs','Certificate Programs','MBA (Distance) Programs','Professional Programs'};
        List<String> lstDrivesAvoid = new List<String>{'January2023','July2023'};
        String chooseProgram = 'Post Graduate Diploma Programs';
        String query = 'SELECT id, PersonContactId, PersonEmail, PersonMobilePhone, nm_AccountEmail__c,ICemailaddress__c,LC_email_id__c';
        query = query + ' FROM Account WHERE nm_StudentStatus__c =\'Confirmed\' AND nm_Drive_Name__c NOT IN :lstDrivesAvoid AND nm_ChooseaProgram__c IN :lstChoosePrograms AND nm_Account_Category__c!=\'Corporate\' AND nm_Centers__r.ConsumerType__c IN (\'Retail\',\'Verizon\')';
        query = query + ' AND Pass_Out__c=false AND nm_Program__r.IsTerm__c=false AND (((ValidUptoR__c=:validtyUptoForDec OR ValidUptoR__c=:validtyUptoForJun) AND (Extend_Validity_upto_Month__c=null OR Extend_Validity_upto_Month__c=\'\') AND Validity_Extension_Count__c=0)';
        query = query + ' OR (Validity_Extension_Count__c=1 AND nm_ChooseaProgram__c=:chooseProgram AND (';
        Integer loopCount = 0;
        Integer lstCount = previousMonths.size();
        String partialQuery = '';
        for (String priorDrive : previousMonths) {
            loopCount++;
            partialQuery = partialQuery + ' Extend_Validity_Upto__c=\''+priorDrive+'\' ';
            if(loopCount < lstCount) {
                partialQuery = partialQuery + ' OR';
            }
        }
        query = query + partialQuery + ')))';
                        
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 25/11/2019 
    * @param bc 
    * @param scope 
    * @return void 
    **/
    global void execute(Database.BatchableContext bc,List<Account> scope){ 
        Integer maxEmailCount = Integer.valueOf(System.Label.Max_Reminder_Per_Day_Mail_Count);

        if(totalMailSentToAccounts < maxEmailCount) {
            Messaging.SingleEmailMessage[] lstMails = new List<Messaging.SingleEmailMessage>();
            // To Query Organisation Details.
            OrgWideEmailAddress owe = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
            // To Query the Email Template.
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'Validity Extension - Compulsory Reminder (12 months)' LIMIT 1];
            //  To Query the tasks for all the emails already sent to the students.
            if(alreadyMailSentAccountIds.size() == 0) {
                List<Task> lstTasks = [SELECT AccountId FROM Task WHERE ActivityDate=THIS_MONTH AND Subject LIKE 'Email: Validity Extension Reminder - NMIMS%' LIMIT 10000];
                for(Task objTask : lstTasks) {
                    alreadyMailSentAccountIds.add(objTask.AccountId);
                }
                System.debug('alreadyMailSentAccountIds 1 ==>'+alreadyMailSentAccountIds.size());
            }
            
            System.debug('alreadyMailSentAccountIds ==>'+alreadyMailSentAccountIds.size());
            List<Account> lstAccountToSendMail = new List<Account>();
            // To filter All the Student for whom already mail sent
            if(alreadyMailSentAccountIds.size() > 0) {
                for (Sobject s : scope) {
                    Account objAccount = (Account)s;
                    Id accountId = s.Id;
                    System.debug('accountId ==>'+accountId);
                    System.debug('alreadyMailSentAccountIds 3==>'+alreadyMailSentAccountIds.contains(accountId));
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
        // Clean Up old Tasks
        Date filterDate = System.today().addMonths(-3);
        filterDate = filterDate.addMonths(1).toStartofMonth().addDays(-1);
        System.debug(filterDate);
        List<Task> lstTasks = [SELECT Id FROM Task WHERE ActivityDate<=:filterDate AND Subject LIKE 'Email: Validity Extension Reminder - NMIMS%' LIMIT 10000];
        if(lstTasks.size() > 0) {
            delete lstTasks;
        }
        System.debug('Finished');
    }

    /**
    * @description 
    * @author @BK | 25/11/2019 
    * @return List<String> 
    **/
    public static List<String> getExpiryDrive() {
        Date myDate = Date.today();
        Date newDate = myDate.addYears(-1);
        Integer findInWhichHalf = myDate.month() / 6; 
        Integer currentYear = myDate.year();
        Integer previousYear = newDate.year();
        String validytUptoForJun = 'Jun '+String.valueOf(previousYear);
        String validityUptoForDec = 'Dec '+String.valueOf(previousYear);
        if(findInWhichHalf > 0) {
            validytUptoForJun = 'Jun '+String.valueOf(currentYear);
        } 
        List<String> lstValidPeriod = new List<String>{validityUptoForDec, validytUptoForJun};
        System.debug('findInWhichHalf ==>'+findInWhichHalf);
        System.debug('validityUptoForDec ==>'+validityUptoForDec);
        System.debug('validytUptoForJun ==>'+validytUptoForJun);
        System.debug('lstValidPeriod ==>'+lstValidPeriod);
        return lstValidPeriod;
    }

    /**
    * @description 
    * @author @BK | 25/11/2019 
    * @param count 
    * @return List<String> 
    **/
    public static List<String> getPreviousMonthsDrive(Integer count) {
        DateTime myDate = Datetime.now();
        List<String> previousMonths = new List<String>();
        for (Integer i = 1; i <= count; i++) {
            DateTime previousMonthDate = myDate.addMonths(i * -1);
            String previousMonthDateVal = previousMonthDate.format('MMMM yyyy');
            previousMonths.add(previousMonthDateVal);
        }
        System.debug('previousMonths ==>'+previousMonths);
        return previousMonths;
    }

    /**
    * @description 
    * @author @BK | 25/11/2019 
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
        // System.debug('message ==>'+message);
        return message;
    }

    private void myCustomFinish() {
        System.debug('finish called');    
    }
}