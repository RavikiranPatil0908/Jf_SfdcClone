/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 28--10--2024
 * @last modified by  : @Ravi
**/
global class CaseController {
  
    /**
    * @description Update the status of a Case and send an alert via a flow
    * @author Ravi | 08-01-2024 
    * @param caseId 
    * @param status 
    * @param comment 
    * @param prevStatus 
    * @return String 
    **/
    @AuraEnabled
    webService static String updateCaseStatus(String caseId, String status, String comment , String prevStatus ) { 
        try {
           
            Map<String, Object> params = new Map<String, Object>();
            params.put('caseId', caseId);
            params.put('status', status);
            params.put('prevStatus', prevStatus);
            params.put('comment', comment);
            params.put('CommentBackup', comment);  
            
            // Invoke the flow
            Flow.Interview.Send_Alert_when_CaseStatus_Updated flow1 = new Flow.Interview.Send_Alert_when_CaseStatus_Updated(params);
            flow1.start();
        
            return 'Success';
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

    /**
    * @description Add a comment to a Case and trigger an alert via a flow
    * @author Ravi | 08-01-2024 
    * @param caseId 
    * @param comment 
    * @return String 
    **/
    @AuraEnabled
    webService static String addComment(String caseId, String comment) {
        try {
         
            Map<String, Object> params = new Map<String, Object>();
            params.put('caseId', caseId);
            params.put('comment', comment);
            params.put('CommentBackup', comment);
            params.put('status', '');  
            
            // Invoke the flow
            Flow.Interview.Send_Alert_when_CaseStatus_Updated flow1 = new Flow.Interview.Send_Alert_when_CaseStatus_Updated(params);
            flow1.start();
            
            return 'Success';
        } catch (Exception e){
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

    /**
    * @description Change the Expected Close Date of a Case and update related fields
    * @author Ravi | 08-01-2024 
    * @param caseId 
    * @param newExpectedCloseDate 
    * @param comment 
    * @return String 
    **/
    @AuraEnabled
    webService static String changeECDDate(String caseId, Date newExpectedCloseDate, String comment) {
        try {
            List<Case> lstCases = [SELECT Id, Count_of_ECD_changed_By_System__c, Count_of_ECD_changed_By_User__c FROM Case WHERE Id = :caseId LIMIT 1];
            if (lstCases.isEmpty()) {
                System.debug('Error: Case not found');
                return null;
            }
            Case caseRecord = lstCases[0];
            caseRecord.Expected_Close_Date__c = newExpectedCloseDate;
            if(!String.isBlank(comment)){
                caseRecord.Case_Comment__c = comment;
                caseRecord.Recent_Comment__c = comment;
            }
            caseRecord.Count_of_ECD_changed_By_User__c = caseRecord.Count_of_ECD_changed_By_User__c + 1;
            update caseRecord;
            return 'Success';
        } catch (Exception e){
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    webService static String changeDetails(String caseId, Date newExpectedCloseDate, String comment, String status, String prevStatus) {
        System.debug('changeDetailsClassic123'+'caseId :: '+caseId+'newExpectedCloseDate :: '+newExpectedCloseDate+'comment :: '+comment+ 'status :: '+status+'prevStatus :: '+prevStatus);
        String msg = '';
        List<Case> lstCases = [SELECT Id, Count_of_ECD_changed_By_System__c, Count_of_ECD_changed_By_User__c , Expected_Close_Date__c FROM Case WHERE Id = :caseId LIMIT 1];
           
        if (lstCases.isEmpty()) {
            return 'Error: Case not found';
        }
        Case caseRecord = lstCases[0];
        //caseRecord.Expected_Close_Date__c = newExpectedCloseDate;
        try {
            // Only comment update
            if (newExpectedCloseDate == caseRecord.Expected_Close_Date__c && status == '') {
                msg = CaseController.addComment(caseId, comment);
            }
            // Only status update
            else if (newExpectedCloseDate == caseRecord.Expected_Close_Date__c && status != '') {
                msg = CaseController.updateCaseStatus(caseId, status, comment, prevStatus);
            }
            // Only ECD update
            else if (newExpectedCloseDate != caseRecord.Expected_Close_Date__c && status == '') {
                msg = CaseController.changeECDDate(caseId, newExpectedCloseDate, comment);
            }
            // Both status and ECD update
            else if (newExpectedCloseDate != caseRecord.Expected_Close_Date__c && status != '') {
                msg = CaseController.updateCaseStatus(caseId, status, comment, prevStatus);
                if (msg == 'Success') {
                    msg = CaseController.changeECDDate(caseId, newExpectedCloseDate, '');
                }
            }
            return msg;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }
}