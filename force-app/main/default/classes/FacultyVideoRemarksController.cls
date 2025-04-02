/**
 * @description       : 
 * @author            : @Suyog
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : @vickysahu
**/
public without sharing class FacultyVideoRemarksController {
    public String recordId {get; set;}
    public String remark {get; set;}
    public String videoId { get; set; }
    public String generatedEmbeddedLink { get; set; }
    public String embeddedRemark { get; set; }
    public Async_Shoot_Post_Production__c asyncShootPostObject {get;set;}
    public String facultyRemarks {get; set;}
    public Boolean showSuccess {get;set;}
    public String existingRemark {get; set;}
    public String existingRemarkV1 {get; set;}
    public String learnOC {get; set;}
    public String learnOb {get; set;}
    public String topics {get; set;}
    public String subTopics {get; set;}
    public String mappingStatus {get; set;}
    public Boolean isYoutube { get; set;}
    public String internalRemark { get; set;}
    public String errorMsg {get; set;}

    public FacultyVideoRemarksController() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        remark = ApexPages.currentPage().getParameters().get('remark');
        embeddedRemark = '';
        facultyRemarks = '';
        internalRemark = '';
        asyncShootPostObject = null;
        showSuccess = false;
        existingRemark = '';
        existingRemarkV1 = '';
        String url = reviewLink();
        generatedEmbeddedLink = getId(url);
        errorMsg = '';
    }

    public String getId(String url) {
        String regExp = '^(?:https?:\\/\\/(?:www\\.)?youtu\\.be\\/|https?:\\/\\/www\\.youtube\\.com\\/embed\\/|https?:\\/\\/www\\.youtube\\.com\\/v\\/|https?:\\/\\/www\\.youtube\\.com\\/u\\/\\w+\\/|https?:\\/\\/www\\.youtube\\.com\\/watch\\?v=|https?:\\/\\/www\\.youtube\\.com\\/&v=)([^#\\&\\?]+)';
        Pattern pattern = Pattern.compile(regExp);
        Matcher matcher = pattern.matcher(url);
        isYoutube = false;

        if (matcher.find() && matcher.group(1).length() == 11) {
            isYoutube = true;
            videoId = matcher.group(1);
            return 'https://www.youtube.com/embed/' + videoId;
        } else {
            videoId = 'error';
            return url;
        }
    }

    public String reviewLink() {
        List<Async_Shoot_Post_Production__c> lstAsyncShoot = [SELECT Id,Name,Post_Production_Status__c,Internal_Video_Remarks__c,Topics_Covered__c,SubTopics__c,Learning_Objectives__c,Learning_Outcomes__c,Video_Link_Version_1__c,Faculty_Remarks_for_Edit_Version_1__c,Video_Link_Version_2__c,Faculty_Remarks_for_Edit_Version_2__c,Video_Link_Version_3__c,Subject__c,Program__c,Mapping_Status__c FROM Async_Shoot_Post_Production__c WHERE Id = :recordId];
        if(lstAsyncShoot.size() > 0) {
            asyncShootPostObject = lstAsyncShoot[0];
            String videoLink = remark == '1' ? asyncShootPostObject.Video_Link_Version_1__c : remark == '2' ? asyncShootPostObject.Video_Link_Version_2__c : 'error';
            if(String.isNotBlank(videoLink) && videoLink != 'error') {
                String fieldKey = 'Faculty_Remarks_for_Edit_Version_'+remark+'__c';
                existingRemark = (String)asyncShootPostObject.get(fieldKey);
                if(remark == '2') {
                    existingRemarkV1 = asyncShootPostObject.Faculty_Remarks_for_Edit_Version_1__c;
                }
                learnOb = asyncShootPostObject.Learning_Objectives__c;
                learnOc = asyncShootPostObject.Learning_Outcomes__c;
                topics = asyncShootPostObject.Topics_Covered__c;
                subTopics = asyncShootPostObject.SubTopics__c;
                mappingStatus = asyncShootPostObject.Mapping_Status__c;
                internalRemark = asyncShootPostObject.Internal_Video_Remarks__c;
            }
            return videoLink;
        }
        return 'error';
    }

    public PageReference submitRemark() {
        try {
            system.debug('topics==>'+topics);
            if(String.isNotBlank(facultyRemarks) && asyncShootPostObject!=null) {
                if(!isTOCMapped()) {
                    return null;
                }
                String msg = getMessageForFieldChange(asyncShootPostObject, topics, subTopics, mappingStatus);
                String fieldKey = 'Faculty_Remarks_for_Edit_Version_'+remark+'__c';
                existingRemark = String.isNotBlank(existingRemark) ? existingRemark + '' +msg+ ''+ facultyRemarks : msg + facultyRemarks;
                system.debug('msg --> ' + msg);
                system.debug('existingRemark --> ' + existingRemark);
                asyncShootPostObject.put(fieldKey, existingRemark);
                asyncShootPostObject.Post_Production_Status__c = 'Faculty Comments Shared with Production';
                if(string.isNotBlank(learnOb)) {
                    asyncShootPostObject.Learning_Objectives__c=learnOb;
                }
                if(string.isNotBlank(learnOc)) {
                    asyncShootPostObject.Learning_Outcomes__c=learnOc;
                }
                asyncShootPostObject.Topics_Covered__c = topics;
                asyncShootPostObject.SubTopics__c = subTopics;
                asyncShootPostObject.Mapping_Status__c = mappingStatus;
                update asyncShootPostObject;
                showSuccess = true;
                system.debug('showSuccess==>'+showSuccess);
            }
        } catch (Exception error) {
            System.debug('error ==>'+error.getMessage());
        }
        return null;
    }

    public String getMessageForFieldChange(Async_Shoot_Post_Production__c objAsync, String topics, String subTopics, String mappingStatus) {
        String message = '';
        List<String> lstMessage = new List<String>();
        if (objAsync.Topics_Covered__c != topics) {
            lstMessage.add('Topics');
        }
        if (objAsync.SubTopics__c != subTopics) {
            lstMessage.add('SubTopic');
        }
        if (objAsync.Mapping_Status__c != mappingStatus) {
            lstMessage.add('Mapping Status');
        }
        if (lstMessage.size() >0) {
            message = String.join( lstMessage, ' AND ' ) + ' are changed';
            return ' <p style="color:red;">'+message+'</p> ';
        } else {
            return '';
        }
    }

    public Boolean isTOCMapped() {
        List<AsyncTOCLink__c> lst = [SELECT id FROM AsyncTOCLink__c WHERE Async_Shoot_Post_Production__c=:recordId];
        if(lst.size() > 0 || String.isNotBlank(mappingStatus)) {
            errorMsg = '';
            return true;
        }
        errorMsg = 'Kindly Map TOC or Set TOC Mapping Status';
        return false;
    }
}