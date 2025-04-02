/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 04-13-2024
 * @last modified by  : @vickysahu
**/
public class KitReorderReminderBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public List<Stock__c> lstStock = new List<Stock__c>();

    public void execute(SchedulableContext sc) {
        KitReorderReminderBatchClass b = new KitReorderReminderBatchClass();
        Database.executebatch(b, 200);
    }

    public Database.querylocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Name,Quantity__c,Re_order_Quantity__c,Stock_Keeping_Unit__c,Is_Quantity_Below_Reorder__c,Email_Count__c,Stock_Keeping_Unit__r.Name,IsActive__c FROM Stock__c WHERE IsActive__c = true AND Stock_Keeping_Unit__c != null AND Is_Quantity_Below_Reorder__c = true AND (Email_Count__c < 3 OR Email_Count__c = null)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Stock__c> scope) {
        for(Stock__c objStock : scope) {
            if(objStock.Stock_Keeping_Unit__c != null && objStock.Is_Quantity_Below_Reorder__c == true && objStock.Re_order_Quantity__c != null) { 
                objStock.Email_Count__c = objStock.Email_Count__c == null ? 1 : objStock.Email_Count__c + 1;               
                lstStock.add(objStock);
            } 
        }
        if(lstStock.size() > 0) {
            update lstStock;    
        }
    }

    public void finish(Database.BatchableContext bc) { 
    System.debug('Finish');
        String result = '';
        if(lstStock.size() > 0) {
            result = sendEmailForReminder(lstStock);
            //if(result == 'success') {
                //update lstStock;
            //}
        }
    }

    public String sendEmailForReminder(List<Stock__c> lstStock) {
        String result = '';
        OrgWideEmailAddress owe = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1 ];

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage ();
        string[] bccAddress = System.Label.setBccAdderess.split(',');
        message.setBccAddresses(bccAddress);
        System.debug('bccAddress '+bccAddress);
        string[] toAddress = System.Label.EmailAddressForKitReorderReminder.split(','); 
        message.setToAddresses(toAddress);
        System.debug('toAddress '+toAddress);
        message.setToAddresses(toAddress);
        message.setOrgWideEmailAddressId(owe.id);
        String emailSubject = 'Reminder for Re-order of Kit for Stock objStock.Name';
        String emailTextBody = '<html>'
                                +'<head>'
                                +'<meta charset="UTF-8">'
                                +'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
                                +'<title>Sample Table</title>'
                                +'<style>'
                                +'table {'
                                +'border-collapse: collapse;'
                                +'width: 100%;'
                                +'}'
                                +'th, td {'
                                +'border: 1px solid #dddddd;'
                                +'text-align: left;'
                                +'padding: 8px;'
                                +'}'
                                +'th {'
                                +'background-color: #f2f2f2;'
                                +'}'
                                +'</style>'
                                +'</head>'
                                +'<body>'
                                +'<font face="calibri " size="3">'
                                +'<p>Hello, </p>'
                                +'<p>List of Stock where Quantity is less than Re-ordered Quantity.</p>'
                                +'<table>'
                                +'<thead>'
                                +'<tr>'
                                +'<th>Stock Name</th>'
                                +'<th>Stock Keeping Unit</th>'
                                +'<th>Quantity</th>'
                                +'<th>Re-order Quantity</th>'
                                +'</tr>'
                                +'</thead>'
                                +'<tbody>';

                                for (Stock__c objStock : lstStock) {
                                    emailTextBody += '<tr>';
                                    emailTextBody += '<td><a href="' + System.Label.SalesforceBaseUrl + objStock.Id + '">' + objStock.Name + '</a></td>';
                                    emailTextBody += '<td><a href="' + System.Label.SalesforceBaseUrl + objStock.Stock_Keeping_Unit__c + '">' + objStock.Stock_Keeping_Unit__r.Name + '</a></td>';
                                    emailTextBody += '<td>'+ objStock.Quantity__c +'</td>';
                                    emailTextBody += '<td>'+ objStock.Re_order_Quantity__c +'</td>';
                                    emailTextBody += '</tr>';
                                }

                                emailTextBody += '</tbody>'
                                    +'</table>'
                                    +'<br><span>Thanks & regards, </span><br>'
                                    +'<span>NGA-SCE </span><br>'
                                    +'<span>SVKM’s NMIMS UNIVERSITY</span>'
                                    +'</font>'
                                    +'</body>'
                                    +'</html>';
        message.setSubject(emailSubject);
        message.setHtmlBody(emailTextBody);
    
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                message
            });
            result = 'success';   
        }catch(exception e){
            result = e.getMessage();
            System.debug('error occured '+e.getMessage());
        }
        return result;
    }
}