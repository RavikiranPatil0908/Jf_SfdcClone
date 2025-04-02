@isTest
public class SetFileVisibilityForCasesTracker {
    
    @IsTest
    static void methodName1(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
       Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        
      Case caseObj = new Case();  
    caseObj.AccountId = objAccount.Id;
    caseObj.Status = 'New';
    caseObj.Origin = 'Email';
        
        insert caseObj;
        
        Account acct = new Account(Name = 'TEST_ACCT');
insert acct;

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

}