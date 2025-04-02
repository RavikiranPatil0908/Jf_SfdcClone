/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-23-2020   shubhranshu   Initial Version
**/
global class AepPaymentRenewalBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    /**
    * @description 
    execute batch
    * @author shubhranshu | 09-23-2020 
    * @param sc 
    **/
    global void execute(SchedulableContext sc) {
        AepPaymentRenewalBatch b = new AepPaymentRenewalBatch();
        Database.executebatch(b, 200);
    }

    /**
    * @description 
    start method
    * @author shubhranshu | 09-23-2020 
    * @param BC 
    * @return Database.querylocator 
    **/
    public Database.querylocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Nm_Active__c,AEP_email_id__c,Center_Name__c,Send_out_Reminder_for_MS__c,Send_out_Reminder__c,Validity_From__c,Validity_To__c,Validity_From_MS__c,Validity_To_MS__c,ID__c from nm_Centers__c Where Nm_Active__c = true and (Send_out_Reminder__c=1 or Send_out_Reminder_for_MS__c=1)';
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    execute method
    * @author shubhranshu | 09-23-2020 
    * @param BC 
    * @param scope 
    **/
    public void execute(Database.BatchableContext BC, List <sObject> scope) {
        List <nm_Centers__c> lst = new List <nm_Centers__c> ();
        for (sObject s: scope) {
            nm_Centers__c center = (nm_Centers__c) s;
            String result = '';
            String result1 = '';

           
            if(center.Send_out_Reminder__c == 1){
               result = sendEmailforReminder(center,'UGAndPG');
               System.debug('result '+result);
            }

            if(center.Send_out_Reminder_for_MS__c == 1){
                result1 = sendEmailforReminder(center,'MS');
                System.debug('result1 '+result1);
            }
        }

    }

    /**
    * @description 
    finish method
    * @author shubhranshu | 09-23-2020 
    * @param BC 
    **/
    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        //mail.setSenderDisplayName('Batch Processing');
        mail.setOrgWideEmailAddressId(owe.id);
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('AEPPaymentRenewalBatch Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    }

    public String sendEmailforReminder(nm_Centers__c center,String type){
        String result = '';
        EmailTemplate emailTemp = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'AEP Payment renewal' LIMIT 1];
        String htmlBody = emailTemp.HtmlValue;
        if(htmlBody.contains('{!nm_Centers__c.Name}')){
            htmlBody = htmlBody.replace('{!nm_Centers__c.Name}', +' '+center.Name);
        }
        if(type == 'UGAndPG'){
            if(htmlBody.contains('{!nm_Centers__c.Validity_To__c}')){
                htmlBody = htmlBody.replace('{!nm_Centers__c.Validity_To__c}', String.valueOf(center.Validity_To__c));
            }
            if(htmlBody.contains('Please <a href="{!$Label.Site_Url}nmAdditonalCharge?id={!nm_Centers__c.ID__c}&pyt=Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ')){
                htmlBody = htmlBody.replace('Please <a href="{!$Label.Site_Url}nmAdditonalCharge?id={!nm_Centers__c.ID__c}&pyt=Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ', 'Please <a href="'+Label.Site_Url+'nmAdditonalCharge?id='+center.ID__c+'&pyt=UG%20And%20PG%20Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ');
            }
        }else if(type == 'MS'){
            if(htmlBody.contains('{!nm_Centers__c.Validity_To__c}')){
                htmlBody = htmlBody.replace('{!nm_Centers__c.Validity_To__c}', String.valueOf(center.Validity_To_MS__c));
            }
            if(htmlBody.contains('Please <a href="{!$Label.Site_Url}nmAdditonalCharge?id={!nm_Centers__c.ID__c}&pyt=Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ')){
                htmlBody = htmlBody.replace('Please <a href="{!$Label.Site_Url}nmAdditonalCharge?id={!nm_Centers__c.ID__c}&pyt=Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ', 'Please <a href="'+Label.Site_Url+'nmAdditonalCharge?id='+center.ID__c+'&pyt=MS%20Renewal%20License%20Fee" style="color: #aa1f24">click here</a> ');
            }
        }
      
      
        System.debug('center '+center);
        System.debug('htmlBody '+htmlBody);
        
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] bccAddress = System.Label.setBccAdderess.split(',');
        email.setBccAddresses(bccAddress);
        System.debug('bccAddress '+bccAddress);
        String[] aepEmail = center.AEP_email_id__c.split(',');
        email.setToAddresses(aepEmail);
        email.setSubject('AEP Payment Renewal: NMIMS CDOE');
        email.setOrgWideEmailAddressId(owe.id);
        email.setHtmlBody(htmlBody);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            result = 'success';
        }catch(exception e){
            result = e.getMessage();
            System.debug('error occured '+e.getMessage());
        }
        return result;
    }
}