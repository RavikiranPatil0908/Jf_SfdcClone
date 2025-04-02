/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 11-12-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-12-2020   @BK   Initial Version
**/
public class UpdateSelectionAdmisionDateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<NM_Payment_Form_Configuration__c> lstFormConfigurations = new List<NM_Payment_Form_Configuration__c>();

    public Database.QueryLocator start(Database.BatchableContext bc){ 
        lstFormConfigurations = [SELECT id,Program_Type__c,Payment_Window_EndDate__c,Update_Selection_Admision_Date__c,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c WHERE Update_Selection_Admision_Date__c=true AND Program_Type__c IN ('MBA (WX)','MBA (X)') LIMIT 1];
        String query = '';
        System.debug('Form Configration Size: '+lstFormConfigurations.size());
        if(lstFormConfigurations.size() > 0) {
            String program = lstFormConfigurations[0].Program_Type__c;
            String driveName = lstFormConfigurations[0].Session__c + lstFormConfigurations[0].Current_Admission_Year__c;
            System.debug('driveName ==>'+driveName);
            List<String> status = new List<String>{'Confirmed','Registration Cancelled','De-Registered','Admission Cancelled','Closed Lost','Rejected'};
            query = 'SELECT id,Program_Type__c,Selection_InitialDate__c,Selection_AdmissionDate__c,Interview_status_update_date__c FROM Account WHERE Program_Type__c=:program AND ';
            query = query + 'nm_StudentStatus__c Not IN :status AND Interview_Status__c=\'Selected\' AND nmCaptureOpportuntiyStage__c NOT IN (\'Payment made\', \'Closed Won\', \'Closed\') ';
            query = query + 'AND Interview_status_update_date__c!=null AND Selection_InitialDate__c!=null AND Selection_AdmissionDate__c!=null AND nm_Drive_Name__c=:driveName';
            System.debug('Query = '+query);
        } else {
            query = 'SELECT id,Program_Type__c,Selection_InitialDate__c,Selection_AdmissionDate__c,Interview_status_update_date__c FROM Account LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 11-12-2024 
    * @param Database.BatchableContext bc 
    * @param List<Account> lst 
    **/
    public void execute(Database.BatchableContext bc, List<Account> lst) { 
        System.debug('Account Size: ' + lst.size());
        List<Account> lstOfAccounts = new List<Account>();
    
        if (lst.size() > 0) {
            DateTime ld = lstFormConfigurations[0].Payment_Window_EndDate__c;
            Date endDate = ld.date();
    
            for (Account objAccount : lst) {
                if (updateAccountDates(objAccount, endDate)) {
                    lstOfAccounts.add(objAccount);
                }
            }
    
            if (!lstOfAccounts.isEmpty()) {
                updateAccounts(lstOfAccounts);
            }
        }
    }
    
    private Boolean updateAccountDates(Account objAccount, Date endDate) {
        Boolean checkForChange = false;
    
        Date interviewSelectedDate = objAccount.Interview_status_update_date__c;
        Date lastIntitalDate = interviewSelectedDate.addDays(7);
        Date lastAdmissionDate = interviewSelectedDate.addDays(30);
        Date updateAdmissionEndDate = calculateAdmissionEndDate(lastAdmissionDate, endDate, interviewSelectedDate);
        Date updateSelectionEndDate = calculateSelectionEndDate(lastIntitalDate, endDate, interviewSelectedDate);
    
        // Check for changes and update the record if necessary
        if (updateSelectionEndDate != objAccount.Selection_InitialDate__c) {
            objAccount.Selection_InitialDate__c = updateSelectionEndDate;
            checkForChange = true;
        }
    
        if (updateAdmissionEndDate != objAccount.Selection_AdmissionDate__c) {
            objAccount.Selection_AdmissionDate__c = updateAdmissionEndDate;
            checkForChange = true;
        }
    
        // Update Send Interview Email flag if any changes were made
        if (checkForChange) {
            objAccount.Send_Interview_Selected_Email__c = true;
        }
    
        return checkForChange;
    }
    
    private Date calculateAdmissionEndDate(Date lastAdmissionDate, Date endDate, Date interviewSelectedDate) {
        return lastAdmissionDate < endDate ? interviewSelectedDate : endDate.addDays(-30);
    }
    
    private Date calculateSelectionEndDate(Date lastIntitalDate, Date endDate, Date interviewSelectedDate) {
        return lastIntitalDate < endDate ? interviewSelectedDate : endDate.addDays(-7);
    }
    
    private void updateAccounts(List<Account> lstOfAccounts) {
        try {
            Database.SaveResult[] srList = Database.update(lstOfAccounts, false);
            for (Integer i = 0; i < lstOfAccounts.size(); i++) {
                Database.SaveResult sr = srList[i];
                Account orgRecord = lstOfAccounts[i];
    
                if (sr.isSuccess()) {
                    System.debug('Successfully updated Account. Account ID: ' + sr.getId());
                } else {
                    System.debug('sr.getId() --> ' + orgRecord.id);
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }
    

    public void finish(Database.BatchableContext bc){
        if(lstFormConfigurations.size() > 0) {
            lstFormConfigurations[0].Update_Selection_Admision_Date__c = false;
            update lstFormConfigurations;
        }
        System.debug('finished');
    }
}