/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 25-10-2024
 * @last modified by  : @BK
**/
global without sharing class FileUploadCaseController {

    webservice static String uploadFile(String fileName, String fileBody, String recordId) {
        try {
            System.debug('Additional Data: ' + recordId);
            // Convert base64 string to Blob
            Blob fileBlob = EncodingUtil.base64Decode(fileBody);
           
            // Create a new ContentVersion
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = fileBlob;
            contentVersion.FirstPublishLocationId = recordId;
            insert contentVersion;
           
            // Log or handle additional data if needed
            System.debug('Additional Data: ' + recordId);
            createContentDistribution(contentVersion);
            return 'File uploaded successfully!';
        } catch (Exception e) {
            return 'Error uploading file: ' + e.getMessage();
            // throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }

    public static void createContentDistribution(ContentVersion files) {
        // ContentDistribution> lstOfDistributionToInsert = new List<ContentDistribution>();
        // for (ContentVersion files : lstDocs) {
            ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = files.id;
            newDist.Name = files.Title;
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload=true;
            system.debug('createContentDistribution creted');
            // lstOfDistributionToInsert.add(newDist);
        // }
        insert newDist;
        System.debug(newDist);
    }
}