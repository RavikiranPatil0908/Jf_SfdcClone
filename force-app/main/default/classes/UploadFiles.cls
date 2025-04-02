/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 18-04-2024
 * @last modified by  : @BK
**/
public without sharing class UploadFiles {

	public class RelatedFile {
        public String pathOnClient;
        public String title;
        public Blob versionData;
    }

    // @AuraEnabled
    // public static boolean uploadFiles(List<Map<String, Object>> files, Id caseId, Id commId){
    //     Boolean isSuccess = false;
    //     List<ContentVersion> relatedDocuments = new List<ContentVersion>();
    //     for (Map<String, Object> file : files) {
    //         String fileJson = JSON.serialize(file);
    //         relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
    //         ContentVersion contentVersionFile = new ContentVersion();
    //         contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
    //         contentVersionFile.Title = relatedDocument.Title;
    //         contentVersionFile.VersionData = relatedDocument.VersionData;
    //         contentVersionFile.FirstPublishLocationId = caseId;
    //         contentVersionFile.Comment_Id__c = commId;
    //         relatedDocuments.add(contentVersionFile);
    //     }
    //     Database.saveResult[] srFiles = Database.insert(relatedDocuments);
    //     for (Database.SaveResult saveResult : srFiles) {
    //         isSuccess = saveResult.isSuccess();
    //     }
        
    //     CaseComment body = [select Id, CommentBody FROM CaseComment WHERE Id= :commId];
        
    //     String cdId = generatePublicLink(commId);
    //     ContentDistribution cd = [SELECT Id, Name, ContentDownloadUrl FROM ContentDistribution WHERE Id= :cdId];
    //     body.CommentBody = body.CommentBody + '<br/>'+ '<a href='+cd.ContentDownloadUrl+'>'+ cd.Name +'</a>';
    //     update body;
        
    //     return isSuccess;
    // }
    
    // public static String generatePublicLink(Id commId){
    //     /* Getting ContentVersion file using ContentDocument Id */
    //     ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Comment_Id__c = :commId][0];
 
    //     /* Creating ContentDistribution record */
    //     ContentDistribution conDis = new ContentDistribution();
    //     conDis.Name = cv.Title;
    //     conDis.ContentVersionId = cv.Id;
    //     conDis.PreferencesAllowViewInBrowser= true;
    //     insert conDis;
        
    //     return conDis.Id;
    // }


    /**
    * @description 
    * @author @BK | 18-04-2024 
    * @param List<Map<String Object>> files 
    * @param Id recordId 
    * @return Boolean 
    **/
    public static Boolean publishFiles(List<Map<String, Object>> files, Id recordId){
        System.debug('Book Order Id'+files);
        Boolean isSuccess = false;
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            RelatedFile relatedDocument = (RelatedFile) JSON.deserialize(fileJson, RelatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.pathOnClient;
            contentVersionFile.Title = relatedDocument.title;
            contentVersionFile.VersionData = relatedDocument.versionData;
            contentVersionFile.FirstPublishLocationId = recordId;
            relatedDocuments.add(contentVersionFile);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
        }
        createContentDistribution(relatedDocuments);
        return isSuccess;
    }

    /**
    * @description 
    * @author @BK | 18-04-2024 
    * @param List<ContentVersion> lstDocs 
    **/
    public static void createContentDistribution(List<ContentVersion> lstDocs) {
        List<ContentDistribution> lstOfDistributionToInsert = new List<ContentDistribution>();
        for (ContentVersion files : lstDocs) {
            ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = files.id;
            newDist.Name = files.Title;
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload=true;
            system.debug('createContentDistribution creted');
            lstOfDistributionToInsert.add(newDist);
        }
        insert lstOfDistributionToInsert;
        System.debug(lstOfDistributionToInsert);
    }
}