public class AsyncTOCLinkTriggerHandler {

    public void AfterInsert(List<AsyncTOCLink__c> triggerNew, map<id, AsyncTOCLink__c> newMap)
    {
        Set<Id> allInsertedIds = newMap.keySet();
        System.debug('AsyncTOCLinkTriggerHandler :: '+allInsertedIds);
        List <AsyncTOCLink__c> tocIds = [select TOC__r.Id__c, Async_Shoot_Post_Production__r.Current_Download_Link__c from AsyncTOCLink__c where Id =: allInsertedIds and Async_Shoot_Post_Production__r.Current_Download_Link__c != ''];
        Set<Integer> data = new Set<Integer>();
        for(AsyncTOCLink__c  Idvalue: tocIds)
        {
            if(String.isNotBlank(Idvalue.TOC__r.Id__c) && Idvalue.Async_Shoot_Post_Production__r.Current_Download_Link__c != null && Idvalue.Async_Shoot_Post_Production__r.Current_Download_Link__c != '') {
                data.add(integer.valueof(Idvalue.TOC__r.Id__c));
            }
        }
        System.debug('AsyncTOCLinkTriggerHandler data  :: '+data);
        if(!data.isEmpty()){
            AsyncTOCLinkPortal.sendTOCIdToPortal(data);
        }   
    }
   
}