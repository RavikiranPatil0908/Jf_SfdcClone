/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-19-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class PublicLinkForUploadedFilesTracker {

    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
         
        Case caseObj = new Case();  
        caseObj.AccountId = objAccount.Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'Email';  
        insert caseObj;
    
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = caseObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;        
    }

    @isTest
    static void unitTest1() {
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        PublicLinkForUploadedFiles.FlowInputs testFlowInput = new PublicLinkForUploadedFiles.FlowInputs();
        testFlowInput.recordId = objCase.Id;

        List<PublicLinkForUploadedFiles.FlowInputs> testFlowInputsList = new List<PublicLinkForUploadedFiles.FlowInputs>();
        testFlowInputsList.add(testFlowInput);
        Test.startTest();
        PublicLinkForUploadedFiles.convertPrivateToPublic(testFlowInputsList);
        Test.stopTest();
    }
}