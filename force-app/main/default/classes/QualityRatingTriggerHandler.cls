/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-01-2025
 * @last modified by  : @BK
**/
public without sharing class QualityRatingTriggerHandler {
    private static boolean isBeforeInsertRunOnce = false; 
    private static boolean isBeforeUpdateRunOnce = false;
    
    public QualityRatingTriggerHandler(){
        logLimits();
    }

    public void beforeInsert(list<Quality_Rating__c> triggerNew, map<id,Quality_Rating__c> triggerOldMap){
        if(isBeforeInsertRunOnce){ 
            return;
        }
      
        isBeforeInsertRunOnce = true;

        QualityRatingCalculation.updateScore(triggerNew,triggerOldMap, false);
    }


    public void beforeUpdate(list<Quality_Rating__c> triggerNew, map<id,Quality_Rating__c> triggerOldMap){
        if(isBeforeUpdateRunOnce){ 
            return;
        }
      
        isBeforeUpdateRunOnce = true;

        QualityRatingCalculation.updateScore(triggerNew,triggerOldMap, true);
    }

    private void logLimits() {
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' + Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried in this Apex code context: ' + Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queried in this Apex code context: ' + Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' + Limits.getLimitDmlStatements());
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' + Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' + Limits.getLimitFutureCalls());
    }
}