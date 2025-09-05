/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 29-04-2025
 * @last modified by  : @Shailesh
**/
public without sharing class AsyncShootandJunctionHelper {
    public AsyncShootandJunctionWrapper getWrapper = new AsyncShootandJunctionWrapper();
    
    public AsyncShootandJunctionHelper(){
        getWrapper = getWrappervalue();

    }
    public  AsyncShootandJunctionWrapper getWrappervalue(){
        
        AsyncShootandJunctionWrapper wrapper = new AsyncShootandJunctionWrapper();
        Map<String, String> tocDataMap = new Map<String, String>(); 
        
                List<TOC__c> tocList = [ SELECT Id, Block_Name__c, Subject__c,Unit_Name__c, Topic_Name__c, Sub_Topic_Name__c, Program__c, Name FROM TOC__c ];

                for (TOC__c obj : tocList) {
                    String mapKey = obj.Block_Name__c ;
                    mapKey += '__&&__'+ obj.Subject__c ;
                    mapKey += '__&&__'+obj.Program__c ;
                    mapKey += '__&&__'+ obj.Unit_Name__c ;
                   mapKey += obj.Topic_Name__c != NULL ? '__&&__'+ obj.Topic_Name__c : '__&&__'+ null;
                   mapKey += obj.Sub_Topic_Name__c != NULL ? '__&&__'+ obj.Sub_Topic_Name__c : '__&&__'+ null;
                    tocDataMap.put(mapKey, obj.id);
                }
                wrapper.getTocDataMap = tocDataMap;
                wrapper.gettocList = tocList;
            return wrapper;
    }
    
    public class AsyncShootandJunctionWrapper{
        public Map<String, String> getTocDataMap {get;set;}
        public List<TOC__c> gettocList {get;set;}
        AsyncShootandJunctionWrapper(){
            getTocDataMap = new Map<String, String>(); 
            gettocList = new List<TOC__c>();
        }
    }
}