/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : @vickysahu
**/
public class PublicLinkForUploadedFiles {
    @InvocableMethod(label='Create Public link' description='Public Link for uploaded Files' category='Case')
    public static void convertPrivateToPublic(List<FlowInputs> request) {
        if (!System.isFuture()) {
            CallWebService(request[0].recordId);
        }
    }

    @future(callout=true)
    public static void callWebService(String recordId) {
        List<ContentVersion> lstcv = new List<ContentVersion>();
        List<ContentDistribution> lstcd = new List<ContentDistribution>();
        List<ContentDocumentLink> lstDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        System.debug('lstDocumentLinks --->' + JSON.serialize(lstDocumentLinks));

        Set<Id> contentDocumentIds = new Set<Id>();
        if(lstDocumentLinks.size() > 0) {
            for (ContentDocumentLink documentLink : lstDocumentLinks) {
                contentDocumentIds.add(documentLink.ContentDocumentId);
            }
        }
        //Get all content version of case whose ContentDistribution is not Created.
        lstcv = [SELECT Id, Title, VersionData,ContentSize FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND Id NOT IN (SELECT ContentVersionId FROM ContentDistribution)];
        if(lstcv.size() > 0) {
            for(ContentVersion objcv : lstcv) {
                ContentDistribution objcd = new ContentDistribution();
                objcd.ContentVersionId = objcv.Id;
                objcd.PreferencesAllowViewInBrowser = true;
                objcd.PreferencesNotifyOnVisit = false;
                if (objcv.Title.length() > 100) {
                    // Truncate the name if it exceeds 100 characters
                    objcd.name = objcv.Title.substring(0, 100);
                }
                else {
                    objcd.name = objcv.Title;
                }
            
                //to check file size less than 25MB in bytes
                System.debug('objcv.ContentSize---->' + objcv.ContentSize);
                if (objcv.ContentSize < 26214400) {
                    lstcd.add(objcd);
                }
            }
        }
    
        if(lstcd.size() > 0) {
            insert lstcd;
        }
    }

    public class FlowInputs {
        @InvocableVariable(required=true)
        public String recordId;
    }
}