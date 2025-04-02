/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-11-2024
 * @last modified by  : @BK
**/
trigger SetFileVisibilityForCases on ContentDocumentLink (before insert) {
     for (ContentDocumentLink cdl : Trigger.new) {
          System.debug('========================================================================>');
          System.debug('RecordId ==>'+cdl.Id);
          System.debug('LinkedEntityId ==>'+cdl.LinkedEntityId);
          System.debug('Before visibility ==>'+cdl.visibility);
          if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case') {
               cdl.visibility = 'AllUsers';
               System.debug('Entered If Condition');
          }
          System.debug('After visibility ==>'+cdl.visibility);
     }
}