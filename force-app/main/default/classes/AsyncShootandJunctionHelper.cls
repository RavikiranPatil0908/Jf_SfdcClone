public without sharing class AsyncShootandJunctionHelper {
    public AsyncShootandJunctionWrapper getWrapper = new AsyncShootandJunctionWrapper();
    
    public AsyncShootandJunctionHelper(){
        getWrapper = getWrappervalue();

    }
    public  AsyncShootandJunctionWrapper getWrappervalue(){
        
        AsyncShootandJunctionWrapper wrapper = new AsyncShootandJunctionWrapper();
        Map<String, String> tocDataMap = new Map<String, String>(); 
        
                List<TOC__c> tocList = [ SELECT Id, Block_Name__c, Subject__c,Unit_Name__c, Topic_Name__c, Sub_Topic_Name__c, Program__c FROM TOC__c ];

                for (TOC__c obj : tocList) {
                    String mapKey = obj.Block_Name__c ;
                    mapKey += '-'+ obj.Subject__c ;
                    mapKey += '-'+obj.Program__c ;
                    mapKey += '-'+ obj.Unit_Name__c ;
                   mapKey += obj.Topic_Name__c != NULL ? '-'+ obj.Topic_Name__c : '-'+ null;
                   mapKey += obj.Sub_Topic_Name__c != NULL ? '-'+ obj.Sub_Topic_Name__c : '-'+ null;
                    tocDataMap.put(mapKey, obj.id);
                }
                wrapper.getTocDataMap = tocDataMap;
            return wrapper;
    }
    
    public class AsyncShootandJunctionWrapper{
        public Map<String, String> getTocDataMap {get;set;}
        AsyncShootandJunctionWrapper(){
            getTocDataMap = new Map<String, String>();  
        }
    }
}