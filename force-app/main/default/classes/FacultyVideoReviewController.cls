/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-07-2024
 * @last modified by  : @BK
**/
public without sharing class FacultyVideoReviewController {

    @AuraEnabled
    public static List<AsyncWrapper> getListAsyncRecords(FilterWrapper wrapper) {
        List<AsyncWrapper> lstRecords = new List<AsyncWrapper>();
        List<AsyncWrapper> lstRecordsUnMapped = new List<AsyncWrapper>();
        try {
            // List<Async_Shoot_Post_Production__c> lst = new List<Async_Shoot_Post_Production__c>();
            Map<Id,Async_Shoot_Post_Production__c> mapOfIdVsAsync = new Map<Id,Async_Shoot_Post_Production__c>();
            
            if(String.isNotBlank(wrapper.program) && String.isNotBlank(wrapper.subject)) {
                mapOfIdVsAsync = new Map<Id,Async_Shoot_Post_Production__c>([SELECT Id,Name,Subject__c,Topics_Covered__c,SubTopics__c,Chapter_Name__c,Shoot_Date__c,Program__c,Mapping_Status__c,
                Final_Video_Link__c,Learning_Objectives__c,Learning_Outcomes__c,File_Name_Revised__c,Post_Production_Status__c,Current_Download_Link__c FROM Async_Shoot_Post_Production__c
                WHERE Program__c=:wrapper.program AND Subject__c=:wrapper.subject]);
            } else if(String.isNotBlank(wrapper.search)) {
                mapOfIdVsAsync = new Map<Id,Async_Shoot_Post_Production__c>([SELECT Id,Name,Subject__c,Topics_Covered__c,SubTopics__c,Chapter_Name__c,Shoot_Date__c,Program__c,Mapping_Status__c,
                Final_Video_Link__c,Learning_Objectives__c,Learning_Outcomes__c,File_Name_Revised__c,Post_Production_Status__c,Current_Download_Link__c FROM Async_Shoot_Post_Production__c
                WHERE Program__c LIKE :wrapper.search OR Subject__c LIKE :wrapper.search]);
            } else if(String.isNotBlank(wrapper.recordId)) {
                mapOfIdVsAsync = new Map<Id,Async_Shoot_Post_Production__c>([SELECT Id,Name,Subject__c,Topics_Covered__c,SubTopics__c,Chapter_Name__c,Shoot_Date__c,Program__c,Mapping_Status__c,
                Final_Video_Link__c,Learning_Objectives__c,Learning_Outcomes__c,File_Name_Revised__c,Post_Production_Status__c,Current_Download_Link__c FROM Async_Shoot_Post_Production__c
                WHERE Id = :wrapper.recordId]);
            } else if(wrapper.getPendingList) {
                mapOfIdVsAsync = new Map<Id,Async_Shoot_Post_Production__c>([SELECT Id,Name,Subject__c,Topics_Covered__c,SubTopics__c,Chapter_Name__c,Shoot_Date__c,Program__c,Mapping_Status__c,
                Final_Video_Link__c,Learning_Objectives__c,Learning_Outcomes__c,File_Name_Revised__c,Post_Production_Status__c,Current_Download_Link__c FROM Async_Shoot_Post_Production__c
                WHERE isTOC_Mapped__c = false]);
            }

            Map<Id,List<AsyncTOCLink__c>> lstASyncTOC = new Map<Id,List<AsyncTOCLink__c>>();
            for (AsyncTOCLink__c obj : [SELECT Id,Async_Shoot_Post_Production__c,TOC__c,TOC__r.Topic_Name__c,TOC__r.Unit_Name__c FROM AsyncTOCLink__c WHERE Async_Shoot_Post_Production__c IN :mapOfIdVsAsync.keySet()]) {
                List<AsyncTOCLink__c> lst = lstASyncTOC.containsKey(obj.Async_Shoot_Post_Production__c) ? lstASyncTOC.get(obj.Async_Shoot_Post_Production__c) : new List<AsyncTOCLink__c>();
                lst.add(obj);
                lstASyncTOC.put(obj.Async_Shoot_Post_Production__c,lst);
            }

            for (Async_Shoot_Post_Production__c obj : mapOfIdVsAsync.values()) {
                AsyncWrapper objRecord = new AsyncWrapper();
                objRecord.name = obj.Name;
                objRecord.subject = obj.Subject__c;

                objRecord.dynamicIcon = lstASyncTOC.containsKey(obj.Id) ? 'utility:check' : 'utility:close';
                objRecord.videoTitle = obj.Topics_Covered__c;
                objRecord.videoCoverage = obj.SubTopics__c;
                objRecord.mappingStatus = obj.Mapping_Status__c;
                objRecord.objRecord = obj;

                objRecord.isMapped = 'No';
                if(lstASyncTOC.containsKey(obj.Id)) {
                    List<String> lstOfTopics = new List<String>();
                    for (AsyncTOCLink__c objASL : lstASyncTOC.get(obj.Id)) {
                        String val = String.isNotBlank(objASL.TOC__r.Topic_Name__c) ? objASL.TOC__r.Topic_Name__c : objASL.TOC__r.Unit_Name__c;
                        lstOfTopics.add(val);
                    }
                    objRecord.isMapped = 'Yes (' + String.join(lstOfTopics, ',') + ')';
                }
                else {

                    lstRecordsUnMapped.add(objRecord);

                }
                
                
                lstRecords.add(objRecord);
            }
            if(wrapper.getPendingList){
                return lstRecordsUnMapped;   
            }
            return lstRecords;
        } catch (Exception error) {
            throw new AuraHandledException('No Record Found');
        }
    }

    @AuraEnabled
    public static List<TOCWrapper> getTOCRecords(String subject,String program, Id asyncId){
        List<TOCWrapper> lstRecords = new List<TOCWrapper>();
        try {
            if(String.isBlank(subject) || String.isBlank(program)) {
                throw new AuraHandledException('Invalid Subject');
            }

            if(asyncId==null) {
                throw new AuraHandledException('Parameter missing');
            }

            List<Id> lstOfTOCIds = new List<Id>();
            List<AsyncTOCLink__c> lstTocLink = [SELECT Id,Async_Shoot_Post_Production__c,TOC__c FROM AsyncTOCLink__c WHERE Async_Shoot_Post_Production__c = :asyncId];
            for (AsyncTOCLink__c obj : lstTocLink) {
                lstOfTOCIds.add(obj.TOC__c);
            }

            for (TOC__c obj : [SELECT Id,Block_Name__c,Subject__c,Sub_Topic_Name__c,Topic_Name__c,Unit_Name__c FROM TOC__c WHERE Subject__c=:subject AND Program__c=:program]) {
                TOCWrapper objWrapper = new TOCWrapper();
                objWrapper.blockName = obj.Block_Name__c;
                objWrapper.topicName = obj.Topic_Name__c;
                objWrapper.unitName = obj.Unit_Name__c;
                objWrapper.subTopicName = obj.Sub_Topic_Name__c;
                objWrapper.objRecord = obj;
                objWrapper.mapLabel = lstOfTOCIds.contains(obj.Id) ? 'Un-Link' : 'Map';
                objWrapper.dynamicIcon = objWrapper.mapLabel == 'Map' ? 'utility:edit' : 'utility:unlinked';
                objWrapper.isMapped = objWrapper.mapLabel == 'Map' ? 'No' : 'Yes'; 
                objWrapper.btnVariant = objWrapper.mapLabel == 'Map' ? 'destructive-text' : 'destructive';
                lstRecords.add(objWrapper);
            }
            return lstRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Async_Shoot_Post_Production__c updateAsyncwithTOC(Async_Shoot_Post_Production__c obj) {
        try {
            update obj;
            return obj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateTocWithAsync(Id tocId, Id asyncId, Boolean isInsert) {
        try {
            if(asyncId==null || tocId==null) {
                throw new AuraHandledException('Parameter missing');
            }

            List<AsyncTOCLink__c> lstLinks = [SELECT id FROM AsyncTOCLink__c WHERE TOC__c=:tocId AND Async_Shoot_Post_Production__c=:asyncId];
            if(lstLinks.size() > 0) {
                delete lstLinks;
                updateAsync(asyncId);
                return true;
            }

            // incase no record found just return.
            if(!isInsert) {
                return true;
            }

            AsyncTOCLink__c objLink = new AsyncTOCLink__c(
                TOC__c=tocId,
                Async_Shoot_Post_Production__c=asyncId
            );
            insert objLink;
            updateAsync(asyncId);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @BK | 12-07-2024 
    * @param Id asyncId 
    **/
    public static void updateAsync(Id asyncId) {
        Async_Shoot_Post_Production__c objAsync = new Async_Shoot_Post_Production__c( id=asyncId, isTOC_Mapped__c=false );
        List<AsyncTOCLink__c> lstLinks = [SELECT id FROM AsyncTOCLink__c WHERE Async_Shoot_Post_Production__c=:asyncId];
        if(!lstLinks.isEmpty()) {
            objAsync.isTOC_Mapped__c = true;
        }
        update objAsync;
    }


    public class FilterWrapper {
        @AuraEnabled
        public String program {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String search { get; set; }
        @AuraEnabled
        public String recordId { get; set; }
        @AuraEnabled
        public Boolean getPendingList {get;set;}
    }

    public class AsyncWrapper {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String isMapped {get;set;}
        @AuraEnabled
        public String mappingStatus {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String videoTitle {get;set;}
        @AuraEnabled
        public String videoCoverage {get;set;}
        @AuraEnabled
        public String dynamicIcon {get;set;}
        @AuraEnabled
        public Async_Shoot_Post_Production__c objRecord {get;set;}
    }

    public class TOCWrapper {
        @AuraEnabled
        public String blockName {get;set;}
        @AuraEnabled
        public String unitName {get;set;}
        @AuraEnabled
        public String topicName {get;set;}
        @AuraEnabled
        public String subTopicName {get;set;}
        @AuraEnabled
        public String mapLabel {get;set;}
        @AuraEnabled
        public String isMapped {get;set;}
        @AuraEnabled
        public String btnVariant {get;set;}
        @AuraEnabled
        public String dynamicIcon {get;set;}
        @AuraEnabled
        public TOC__c objRecord {get;set;}
    }
}