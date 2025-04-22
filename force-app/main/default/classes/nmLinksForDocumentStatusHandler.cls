/**
 * @File Name          : nmLinksForDocumentStatusHandler.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 22--04--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    8/16/2019, 12:06:20 PM   shubhranshu     Initial Version
**/
public without sharing class nmLinksForDocumentStatusHandler{
    
    public static boolean IsAfterInsertRunOnce = false;
    public static boolean IsAfterUpdateRunOnce = false;
    public static boolean IsBeforeInsertRunOnce = false;
    public static boolean IsBeforeUpdateRunOnce = false;
    

    public nmLinksForDocumentStatusHandler(){
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queriedxc  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' +  Limits.getLimitFutureCalls());
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param list<nm_LinksForDocuments__c> triggerNew
    * @param map<id, nm_LinksForDocuments__c> triggerOldMap
    * @return void
    */
    public void BeforeInsert(list<nm_LinksForDocuments__c> triggerNew, map<id,nm_LinksForDocuments__c> triggerOldMap){
        if(IsBeforeInsertRunOnce ){
            return;
        }
        IsBeforeInsertRunOnce = true;
    }
    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param List<nm_LinksForDocuments__c> triggerNew
    * @param Map<id, nm_LinksForDocuments__c> mapofNewDoc
    * @return void
    */
    public void AfterInsert(List<nm_LinksForDocuments__c> triggerNew, Map<id, nm_LinksForDocuments__c> mapofNewDoc){
        if(IsAfterInsertRunOnce){
            return;
        }
        
        IsAfterInsertRunOnce = true;
        System.debug('triggerNew '+triggerNew);
        excuteUpdateStudentStatus(triggerNew);
       // callFindabilityWebService(triggerNew);
    }
   
   /**
   * @description
   * @author shubhranshu | 8/20/2019
   * @param list<nm_LinksForDocuments__c> triggerNew
   * @param map<id, nm_LinksForDocuments__c> triggerOldMap
   * @return void
   */
   public void BeforeUpdate(list<nm_LinksForDocuments__c> triggerNew, map<id,nm_LinksForDocuments__c> triggerOldMap){
        if(IsBeforeUpdateRunOnce ){
            return;
        }
        
        IsBeforeUpdateRunOnce = true;
    } 
    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param List<nm_LinksForDocuments__c> triggerNew
    * @param Map<id, nm_LinksForDocuments__c> mapOfOldDoc
    * @return void
    */
    public void AfterUpdate(List<nm_LinksForDocuments__c> triggerNew,  Map<id, nm_LinksForDocuments__c> mapOfOldDoc){
        if(IsAfterUpdateRunOnce ){
            return;
        }
        
        IsAfterUpdateRunOnce = true;
        excuteUpdateStudentStatus(triggerNew);
         //callFindabilityWebService(triggerNew,mapOfOldDoc);
     }

    /**
    * @description 
    * @author @BK | 01-27-2022 
    * @param lstDoc 
    **/
    public void excuteUpdateStudentStatus(List<nm_LinksForDocuments__c> lstDoc){
        System.debug('lstDoc----->'+lstDoc);
        List<Account> lstofNewAccount = new List<Account>();
        List<Account> lstofNewAccounts = new List<Account>();
        Set<Id> setOfAccIds = new Set<Id>();
        set<Id> setOfAccountIds = new Set<Id>();
        if(lstDoc.size() > 0){
            // to allow Confirmed students to update the status.
            Set<String> setOfStudentNoAllowUpdate = getSetOfStudentsAllowToUpdate(lstDoc);
            for(nm_LinksForDocuments__c linksForDocuments: lstDoc) {
                Id accId = linksForDocuments.nm_Account__c;
                System.debug('accId '+accId);
                System.debug('StudentStatus '+linksForDocuments.StudentStatus__c);
                System.debug('Student_Number '+linksForDocuments.Student_Number__c);
                System.debug('nm_URLforDocuments__c '+linksForDocuments.nm_URLforDocuments__c +'nm_URLforIncorrectDocuments__c '+linksForDocuments.nm_URLforIncorrectDocuments__c);
                if( (!IsNullOrEmpty(linksForDocuments.nm_URLforDocuments__c) || !IsNullOrEmpty(linksForDocuments.nm_URLforIncorrectDocuments__c)) && !linksForDocuments.StudentStatus__c.contains('Confirmed')
                    && !linksForDocuments.StudentStatus__c.contains('Cancel') && !linksForDocuments.StudentStatus__c.contains('Closed') && !linksForDocuments.StudentStatus__c.contains('Rejected')
                    && !linksForDocuments.StudentStatus__c.contains('De-Registered') && !linksForDocuments.Student_Inactive__c && (linksForDocuments.Student_Number__c == null || linksForDocuments.Student_Number__c == '' || 
                    setOfStudentNoAllowUpdate.contains(linksForDocuments.Student_Number__c)) ) {
                    setOfAccIds.add(accId);
                }

                // if(linksForDocuments.StudentStatus__c.contains('Confirmed') && (linksForDocuments.Student_Number__c != null || linksForDocuments.Student_Number__c != '')) {
                //     System.debug('linksForDocuments.StudentStatus__c:::::::: '+linksForDocuments.Student_Number__c);
                //     setOfAccountIds.add(accId);
                // }
            }

            // if(setOfAccountIds.size() > 0 ){
            //     String lstAccQuery = getQueryAllFieldSql('Account','Id IN: setOfAccountIds',null);
            //     lstofNewAccount = Database.query(lstAccQuery);
            //     System.debug('lstofNewAccount '+lstofNewAccount);
            //     for (Account lstAcc :lstofNewAccount ) {
            //         if(lstAcc.Provisional_With_Hold__c == true) {
            //           lstofNewAccounts.add(lstAcc);
            //         }
            //     }
            //     UpdateProvisionalWithHoldFlagOnAccount(lstofNewAccount);
            // }
            
            if(setOfAccIds.size() > 0 ) {
              
                String lstAccQuery = getQueryAllFieldSql('Account','Id IN: setOfAccIds',null);
                lstofNewAccount = Database.query(lstAccQuery);
                System.debug('lstofNewAccount '+lstofNewAccount);
                UpdateDocumentSubmittedStatusOnAccount(lstofNewAccount);
            }
        }
    }
      
    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param List<Account> lstAccount
    * @return void
    */
    public void UpdateDocumentSubmittedStatusOnAccount(List<Account> lstAccount){

        System.debug('Enter and check for UpdateDocumentSubmittedStatusOnAccount');
        Map<String, Set<String>> MapOfAccountIdVsSetOfMandatoryDocs = new Map<String, Set<String>>();
        Map<String, Set<String>> MapOfAccountIdVsSetOfSubmittedDocs = new Map<String, Set<String>>();
        Map<String, List<nm_LinksForDocuments__c>> MapOfAccountIdVslstDocs = new Map<String, List<nm_LinksForDocuments__c>>();
        Map<String, String> MapOfAccountIdVsCriteriaId = new Map<String, String>();
        Map<String, DocumentWrapper> MapOfAccountIdVsDocWrapper = new Map<String, DocumentWrapper>();
        Map<String, Boolean> MapOfAccountIdVsValidDocs = new Map<String, Boolean>();
        Map<String, Boolean> MapOfAccountIdVsValidSubmittedDocs = new Map<String, Boolean>();
        List<Account> lstAccountToUpdate = new List<Account>();
        Map<String,List<nm_WorkExperience__c>> getMapAccIdVsWk = getMapAccIdVsWk(lstAccount);

        for(Account objAccount : lstAccount) {
            if(objAccount.nm_StudentStatus__c != 'Confirmed') {
                // put mandatory Document According to Criteria 
                Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>();
                String criteriaId = objAccount.nm_EligiblityCriteria__c;
                if(String.isNotBlank(criteriaId)) {
                    getMapAccIdVsWk.containsKey(objAccount.Id);
                    mandatoryDocumentForCurrentCriteria = getMandatoryDocuments(objAccount, getMapAccIdVsWk.containsKey(objAccount.Id) ? getMapAccIdVsWk.get(objAccount.Id) : new List<nm_WorkExperience__c>());
                    MapOfAccountIdVsSetOfMandatoryDocs.put(objAccount.id,mandatoryDocumentForCurrentCriteria);
                    MapOfAccountIdVsCriteriaId.put(objAccount.id, criteriaId);
                } else {
                    mandatoryDocumentForCurrentCriteria = new Set<String>{'Photo ID proof','Student Photograph'};
                }
                // Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>{'Photo ID proof','Student Photograph'};
                // // setOfAccountId.add(objAccount.id);
                // String criteriaId = objAccount.nm_EligiblityCriteria__c;
                // // put mandatory Document According to Criteria 
                // if(String.isNotBlank(criteriaId)){
                //     mandatoryDocumentForCurrentCriteria.addAll(getMandatoryDocuments(objAccount, getMapAccIdVsWk.containsKey(objAccount.Id) ? getMapAccIdVsWk.get(objAccount.Id) : new List<nm_WorkExperience__c>()));
                //     MapOfAccountIdVsSetOfMandatoryDocs.put(objAccount.id,mandatoryDocumentForCurrentCriteria);
                //     MapOfAccountIdVsCriteriaId.put(objAccount.id, criteriaId);
                // }
            } 
        }
        System.debug('Size Of Accounts with Mandatory Docs ==>'+MapOfAccountIdVsSetOfMandatoryDocs.size());
        //fetch all document Already Inserted for current Account 
        List<nm_LinksForDocuments__c> lstDocs = [SELECT id,nm_DocumentName__c,nm_Account__c,nm_AccountEmail__c,
            nm_DocumentLink__c,Documents_Submited_Date__c,nm_Lead__c,linkID__c,Links_For_Documents_Lead__c,
            nm_ReasonforDisapprove__c,Registration_No__c,Sample__c,nm_Status__c,nm_URLforDocuments__c FROM nm_LinksForDocuments__c WHERE nm_Account__c IN :MapOfAccountIdVsSetOfMandatoryDocs.keySet()];

        for (nm_LinksForDocuments__c objDocs : lstDocs) {
            List<nm_LinksForDocuments__c> lstDocuments = MapOfAccountIdVslstDocs.containsKey(objDocs.nm_Account__c) 
                ? MapOfAccountIdVslstDocs.get(objDocs.nm_Account__c)
                : new List<nm_LinksForDocuments__c>();
                lstDocuments.add(objDocs);
            MapOfAccountIdVslstDocs.put(objDocs.nm_Account__c,lstDocuments);
        }
        
        for (String AccountId : MapOfAccountIdVslstDocs.keySet()) {
            List<nm_LinksForDocuments__c> lstDocuments = MapOfAccountIdVslstDocs.get(AccountId);
            if(lstDocuments.size() > 0) {
                System.debug('lstDocuments--->'+lstDocuments);
                String criteriaId = MapOfAccountIdVsCriteriaId.get(AccountId);
                Set<String> mandatoryDocumentForCurrentCriteria = MapOfAccountIdVsSetOfMandatoryDocs.get(AccountId);
                DocumentWrapper objWrap = getListOfDocuments(lstDocuments, mandatoryDocumentForCurrentCriteria, criteriaId);
                if(objWrap != null) {
                    Boolean IsvalidDocuments = ValidateDocumentsEligibilityCriteriaWise(criteriaId ,objWrap.documentLink,objWrap.documentStatus,mandatoryDocumentForCurrentCriteria,objWrap.setOfAllDocumentSubmitted);
                    Boolean isvalidSubmiited = SubmittedDocumentsEligibilityCriteriaWise(criteriaId ,objWrap.documentLink,objWrap.documentStatus,mandatoryDocumentForCurrentCriteria,objWrap.setOfAllDocumentSubmitted);
                    MapOfAccountIdVsDocWrapper.put(AccountId, objWrap);
                    MapOfAccountIdVsValidDocs.put(AccountId,IsvalidDocuments);
                    MapOfAccountIdVsValidSubmittedDocs.put(AccountId,isvalidSubmiited);
                }
            }
        }

        if(lstAccount.size() > 0) {
            lstAccountToUpdate = updateAccountStatus(lstAccount,MapOfAccountIdVsDocWrapper,MapOfAccountIdVsSetOfMandatoryDocs,MapOfAccountIdVsValidSubmittedDocs,MapOfAccountIdVsValidDocs);
        }
        
        //update Document Status on Account
        if(lstAccountToUpdate.size() > 0)
        {   
            try{
                update lstAccountToUpdate;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }

    /**
    * @description 
    * @author @BK | 09-08-2024 
    * @param Account objAccount 
    * @param List<nm_WorkExperience__c> lstWk 
    * @return Set<String> 
    **/
    public Set<String> getMandatoryDocuments(Account objAccount, List<nm_WorkExperience__c> lstWk) {
        GetMandatoryDocuments documentHanlder = new GetMandatoryDocuments();
        GetMandatoryDocuments.StudentStatus objStatus = new GetMandatoryDocuments.StudentStatus();
        objStatus.chooseProgram = objAccount.Program_Type__c;
        objStatus.eligibilityCriteria = objAccount.Eligibility_Criteria_Ref__c;
        objStatus.isDefencePersonnel = objAccount.nm_DefencePersonnel__c;
        objStatus.relationship = objAccount.nm_Relationship__c;
        objStatus.studentProgram = objAccount.nmStudent_Program__c;
        objStatus.hscStatus = objAccount.HSC_status__c;
        objStatus.diplomaStatus = objAccount.Diploma_status__c;
        objStatus.isLateral = objAccount.Is_Lateral__c;
        objStatus.isIndian = objAccount.nm_Nationality__c == 'Indian' ? true : false;
        objStatus.recordId = null;
        objStatus.objectType = 'Account';
        objStatus.lstWk = lstWk;
        objStatus.castCertificateDocument = objAccount.nm_Category__c;
        return documentHanlder.getMandatoryDocumentsName(objStatus);
    }

    /**
    * @description  Documents Re-upload After Status is Confirmed and provisionalwithHold flag is True
    * @author @Ravi | 10-17-2024 
    * @param newAccounts 
    * @param oldAccountMap 
    **/
   public void UpdateLinksForDocumentsProvisionalWithHoldAccount(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {  
    System.debug('Call ProvisionalWithHold');
    Set<Id> accountIdsToUpdate = new Set<Id>();
    Map<String, List<nm_WorkExperience__c>> getMapAccIdVsWk = getMapAccIdVsWk(newAccounts);
    Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>();
    try {   
        for (Account acc : newAccounts) {   
            Account oldAcc = oldAccountMap.get(acc.Id);
            if (acc.nm_StudentStatus__c == 'Confirmed' && acc.Provisional_With_Hold__c == true) {
                //check mandatory Documents
                // mandatoryDocumentForCurrentCriteria = getMandatoryDocuments(acc,getMapAccIdVsWk.containsKey(acc.Id) ? getMapAccIdVsWk.get(acc.Id) : new List<nm_WorkExperience__c>());
                accountIdsToUpdate.add(acc.Id);
            }
        }
        // Query related document links if there are accounts to update
        if (!accountIdsToUpdate.isEmpty()) {
            List<nm_LinksForDocuments__c> docLinksToUpdate = [SELECT Id, nm_DocumentName__c, nm_Status__c, nm_URLforDocuments__c,Document_Upload_Mode__c,Old_Document_Upload_Mode__c FROM nm_LinksForDocuments__c WHERE 
            nm_URLforDocuments__c !=null AND (NOT nm_DocumentName__c LIKE 'Work Experience Certificate%') AND Document_Upload_Mode__c = 'Upload Self-Attested Now' AND nm_Account__c IN :accountIdsToUpdate ];
            for (nm_LinksForDocuments__c docLink : docLinksToUpdate) {
                // if (mandatoryDocumentForCurrentCriteria.contains(docLink.nm_DocumentName__c)) {
                    docLink.nm_Old_URL_for_Documents__c = docLink.nm_URLforDocuments__c;
                    docLink.nm_Old_Status__c = docLink.nm_Status__c;
                    docLink.Old_Document_Upload_Mode__c=docLink.Document_Upload_Mode__c;
                    docLink.nm_URLforDocuments__c = null;
                    docLink.nm_Status__c = null;
                    docLink.Document_Upload_Mode__c = null;
                // }
            }
            // Perform update if there are documents to update
            if (!docLinksToUpdate.isEmpty()) {
                update docLinksToUpdate;
            }
        }
    } catch(DmlException e){
        System.debug(e.getMessage());
    }
}


    // /**
    // * @description Make the flag false if all mandatory documents are submitted.
    // * @author @Ravi | 10-19-2024
    // * @param lstAccount - List of accounts to be processed.
    // **/
    // public void UpdateProvisionalWithHoldFlagOnAccount(List<Account> lstAccount) {
      
    //     System.debug('lstAccount::::::::::'+lstAccount);
    //         Map<String, Set<String>> MapOfAccountIdVsSetOfMandatoryDocs = new Map<String, Set<String>>();
    //         Map<String, List<nm_WorkExperience__c>> getMapAccIdVsWk = getMapAccIdVsWk(lstAccount);
    //         Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>();
    //         Map<String, List<nm_LinksForDocuments__c>> MapOfAccountIdVslstDocs = new Map<String, List<nm_LinksForDocuments__c>>();
    //         List<Account> lstAccountsForUpdate = new List<Account>();

    //         // Iterate through accounts and get mandatory documents
    //         for (Account objAccount : lstAccount) {
    //             mandatoryDocumentForCurrentCriteria = getMandatoryDocuments( objAccount, getMapAccIdVsWk.containsKey(objAccount.Id) ? getMapAccIdVsWk.get(objAccount.Id): new List<nm_WorkExperience__c>());
    //             System.debug('mandatoryDocumentForCurrentCriteria:::::::::::::'+mandatoryDocumentForCurrentCriteria.size());
    //             MapOfAccountIdVsSetOfMandatoryDocs.put(objAccount.Id, mandatoryDocumentForCurrentCriteria);
    //         }
    //         // Fetch the documents related to the accounts
    //         List<nm_LinksForDocuments__c> lstDocs = [ SELECT Id, nm_DocumentName__c, nm_Account__c, nm_AccountEmail__c, nm_DocumentLink__c,Documents_Submited_Date__c, nm_Lead__c, linkID__c, Links_For_Documents_Lead__c, 
    //                                                          Registration_No__c, Sample__c, nm_Status__c, nm_URLforDocuments__c   
    //                                                          FROM nm_LinksForDocuments__c WHERE nm_Account__c IN :MapOfAccountIdVsSetOfMandatoryDocs.keySet()];
            
    //        System.debug('lstDocs:::::::'+lstDocs.size() + ':::::::::'+lstDocs);    
    //        List<nm_LinksForDocuments__c> lstOfMandatoryDocs = new List<nm_LinksForDocuments__c>();                                      
    //         for (nm_LinksForDocuments__c objDocs : lstDocs) {        
    //             System.debug('objDocs.nm_DocumentName__c:::::::'+objDocs.nm_DocumentName__c);     
    //             if(mandatoryDocumentForCurrentCriteria.contains(objDocs.nm_DocumentName__c)) {
    //                 lstOfMandatoryDocs.add(objDocs);
    //                 System.debug('lstDocuments size'+lstOfMandatoryDocs.size());
    //             }
    //             //  List<nm_LinksForDocuments__c> lstDocuments = MapOfAccountIdVslstDocs.containsKey(objDocs.nm_Account__c) ? MapOfAccountIdVslstDocs.get(objDocs.nm_Account__c) : new List<nm_LinksForDocuments__c>();
    //             MapOfAccountIdVslstDocs.put(objDocs.nm_Account__c, lstOfMandatoryDocs);
    //         }
    //         for (String AccountId : MapOfAccountIdVslstDocs.keySet()) {
    //             List<nm_LinksForDocuments__c> lstDocuments= MapOfAccountIdVslstDocs.get(AccountId);
    //             System.debug('lstDocuments::::::'+lstDocuments.size()+''+lstDocuments);
    //             if (lstDocuments.size() > 0) {
    //                 Integer sizeOfDocList = lstDocuments.size();
    //                 Integer count = 0;
    //                 for (nm_LinksForDocuments__c objDocs : lstDocuments) {
    //                     if (objDocs.nm_URLforDocuments__c != null && (objDocs.nm_Status__c == 'Approved' || objDocs.nm_Status__c == 'Provisional')) {
    //                         count++;
    //                     }
    //                 }
    //                 System.debug('count::::::'+count+'sizeOfDocList'+sizeOfDocList);
    //                 //  update the account flag
    //                 if (count == sizeOfDocList) {
    //                     Account objAcc = [SELECT Id, Provisional_With_Hold__c FROM Account WHERE Id = :AccountId];
    //                     objAcc.Provisional_With_Hold__c = false;
    //                     lstAccountsForUpdate.add(objAcc);
    //                 }
    //             }
    //         }
    //                 if (lstAccountsForUpdate.size() > 0) {
    //                     update lstAccountsForUpdate;
    //                 }
    //     }



    /**
    * @description 
    * @author @BK | 01-27-2022 
    * @param objAccount 
    * @return Set<String> 
    **/
    // public Set<String> getMandatoryDocuments(Account objAccount, List<nm_WorkExperience__c> lstWk) {
    //     Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>();
    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('Bachelor')  || objAccount.Eligibility_Criteria_Ref__c.contains('Graduation'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Degree Mark Sheet');
    //     }
        
    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('HSC') && objAccount.nm_ChooseaProgram__c != 'Bachelor Programs')
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('12th Mark Sheet');
    //     }

    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('HSC') && objAccount.nm_ChooseaProgram__c == 'Bachelor Programs' && (objAccount.HSC_status__c == 'Appeared' || objAccount.HSC_status__c == 'Pending')){
    //         mandatoryDocumentForCurrentCriteria.add('11th Marksheet');
    //         mandatoryDocumentForCurrentCriteria.add('12th Mark Sheet');  
    //     }else if(objAccount.Eligibility_Criteria_Ref__c.contains('HSC') && objAccount.nm_ChooseaProgram__c == 'Bachelor Programs' && objAccount.HSC_status__c == 'Passed'){
    //         mandatoryDocumentForCurrentCriteria.add('12th Mark Sheet');   
    //     }

    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('SSC'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('10th Mark Sheet');
    //     }
    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('Diploma') && objAccount.nm_ChooseaProgram__c != 'Bachelor Programs')
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Diploma Mark Sheet');
    //     }

    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('Diploma') && objAccount.nm_ChooseaProgram__c == 'Bachelor Programs' && objAccount.Diploma_status__c == 'Appeared'){
    //         mandatoryDocumentForCurrentCriteria.add('Diploma 1st year Marksheet');
    //         mandatoryDocumentForCurrentCriteria.add('Diploma 2nd year Marksheet');
    //     }else if(objAccount.Eligibility_Criteria_Ref__c.contains('Diploma') && objAccount.nm_ChooseaProgram__c == 'Bachelor Programs' && objAccount.Diploma_status__c == 'Passed'){
    //         mandatoryDocumentForCurrentCriteria.add('Diploma Mark Sheet');   
    //     }

    //     if(objAccount.Eligibility_Criteria_Ref__c.containsIgnoreCase('Work') && !objAccount.Eligibility_Criteria_Ref__c.contains('preferably'))
    //     {                            
    //         /*if( objAccount.Eligibility_Criteria_Ref__c.contains('preferably') && objAccount.Work_exp_Score__c>0 && objAccount.Work_exp_Score__c!=null)
    //         {*/
    //             String wkName = '';
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('1') )
    //         {
    //             wkName = 'Work Experience Certificate – 1 years';
    //             // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
    //         }
    //         else if(objAccount.Eligibility_Criteria_Ref__c.contains('2'))
    //         {
    //             wkName = 'Work Experience Certificate – 2 years';
    //             // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
    //         }
    //         else if(objAccount.Eligibility_Criteria_Ref__c.contains('3'))
    //         {
    //             wkName = 'Work Experience Certificate – 3 years';
    //             // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
    //         }
    //         if(String.isNotBlank(wkName))
    //         {
    //             if(lstWk.size() > 0) {
    //                 for (nm_WorkExperience__c objWk : lstWk) {
    //                     System.debug('objWk.Name ---> '  + objWk.Name);
    //                     mandatoryDocumentForCurrentCriteria.add(wkName + '/' +objWk.Name + '/' + (String.isNotBlank(objWk.nm_CompanyName__c) ? objWk.nm_CompanyName__c.left(125) : ''));
    //                 }
    //             } else {
    //                 mandatoryDocumentForCurrentCriteria.add(wkName); 

    //             }
    //         } 
                    
    //             /*}   
    //         else if(!objAccount.Eligibility_Criteria_Ref__c.contains('preferably')){
            
    //             mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate - 2 years');
    //         }*/
        
    //     }   
    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('Professional'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Additional Qualification Certificates');
    //     }           
    //     if(objAccount.nm_DefencePersonnel__c =='Yes')
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Defence Document');
    //     }
    //     if(objAccount.Differently_abled__c =='Yes')
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Differently Abled Document');
    //     }
    //     if(objAccount.Is_Lateral__c && !objAccount.nmStudent_Program__c.startswith('Advance'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('NMIMS Diploma Marksheet');
    //     }
    //     if(objAccount.Is_Lateral__c && objAccount.nmStudent_Program__c.startswith('Advance'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('NMIMS Certificate Program Marksheet');
    //     }
        
    //     if(objAccount.nm_Relationship__c !='Self' && objAccount.nm_DefencePersonnel__c =='Yes')
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Relationship Document');
    //     }

    //     if(objAccount.Eligibility_Criteria_Ref__c.contains('Master'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('Master Degree Mark sheet');
    //     }

    //     if(objAccount.nm_ChooseaProgram__c =='Bachelor Programs' && (objAccount.HSC_status__c == 'Appeared' || objAccount.HSC_status__c == 'Pending'))
    //     {
    //         mandatoryDocumentForCurrentCriteria.add('11th Marksheet');
    //     }
        
    //     return mandatoryDocumentForCurrentCriteria;
    // }

    /**
    * @description 
    * @author @BK | 01-27-2022 
    * @param lstDocuments 
    * @param mandatoryDocs 
    * @param criteriaId 
    * @return DocumentWrapper 
    **/
    public DocumentWrapper getListOfDocuments(List<nm_LinksForDocuments__c> lstDocuments, Set<String> mandatoryDocs, String criteriaId) {

        DocumentWrapper objWarp;
        Map<String,String> docLink = new Map<String,String>();
        Map<String,String> docStatus = new Map<String,String>();
        Set<String> setDisapprovedDocs = new Set<String>();
        Set<String> setProvisionalDocs = new Set<String>();
        Set<String> setApprovedDocs = new Set<String>();
        Set<String> setIncorrectDocs = new Set<String>();
        Set<String> setReSubmittedDocs = new Set<String>();
        Set<String> setInvalidDocs = new Set<String>();
        Set<String> ProMandatoryDocs =new Set<String>();
        set<String> AllSubmittedDocs = new set<String>();
        String ProvisionalReason = '';

        for(nm_LinksForDocuments__c objDoc : lstDocuments) {
            docLink.put(criteriaId+'-'+objDoc.nm_DocumentName__c,objDoc.nm_URLforDocuments__c);
            docStatus.put(criteriaId+'-'+objDoc.nm_DocumentName__c,objDoc.nm_Status__c);
            
            System.debug('objDoc.nm_DocumentName__c ---->'+objDoc.nm_DocumentName__c);
            System.debug('objDoc.nm_URLforDocuments__c ---->'+objDoc.nm_URLforDocuments__c);
            System.debug('objDoc.nm_Status__c ---->'+objDoc.nm_Status__c);
            
            if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c) )
            {
                ProMandatoryDocs.add(objDoc.nm_DocumentName__c);                    
            }
            if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c) && objDoc.nm_ReasonforDisapprove__c != null){
                ProvisionalReason += objDoc.nm_ReasonforDisapprove__c + '\n';
            }
            if('Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c) && String.IsBlank(objDoc.nm_URLforDocuments__c) )
            {
                setIncorrectDocs.add(objDoc.nm_DocumentName__c);                    
            }
            if('Disapproved'.equalsIgnoreCase(objDoc.nm_Status__c) || 'Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c))
            {
                setInvalidDocs.add(objDoc.nm_DocumentName__c);
            }
            if('Disapproved'.equalsIgnoreCase(objDoc.nm_Status__c)){
                setDisapprovedDocs.add(objDoc.nm_DocumentName__c);
            }  
            if('Re-Submited'.equalsIgnoreCase(objDoc.nm_Status__c)  && !String.IsBlank(objDoc.nm_URLforDocuments__c)){
                setReSubmittedDocs.add(objDoc.nm_DocumentName__c);
            }
            if(mandatoryDocs.contains(objDoc.nm_DocumentName__c) && objDoc.nm_Status__c !=null && objDoc.nm_Status__c !='--None--'){
                if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c.trim()) ){
                    setProvisionalDocs.add(objDoc.nm_DocumentName__c);
                }else if('Approved'.equalsIgnoreCase(objDoc.nm_Status__c.trim())){
                    setApprovedDocs.add(objDoc.nm_DocumentName__c);
                }else if('Re-Submited'.equalsIgnoreCase(objDoc.nm_Status__c.trim())){
                    setReSubmittedDocs.add(objDoc.nm_DocumentName__c);
                }else if('Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c.trim()) && !String.IsBlank(objDoc.nm_URLforDocuments__c)){
                    setIncorrectDocs.add(objDoc.nm_DocumentName__c);
                }
            }
            if(!IsNullOrEmpty(objDoc.nm_URLforDocuments__c))
            {
                AllSubmittedDocs.add(objDoc.nm_DocumentName__c);         
            }
        }
        objWarp = new DocumentWrapper(docLink,docStatus,setDisapprovedDocs,setProvisionalDocs,setApprovedDocs,setIncorrectDocs,setReSubmittedDocs,setInvalidDocs,ProMandatoryDocs,AllSubmittedDocs,ProvisionalReason);
        return objWarp;
    }


    /**
    * @description 
    * @author @BK | 01-27-2022 
    * @param lstAccount 
    * @param MapOfAccountIdVsDocWrapper 
    * @param MapOfAccountIdVsSetOfMandatoryDocs 
    * @param MapOfAccountIdVsValidSubmittedDocs 
    * @param MapOfAccountIdVsValidDocs 
    * @return List<Account> 
    **/
    public List<Account> updateAccountStatus (
        List<Account> lstAccount, 
        Map<String, DocumentWrapper> MapOfAccountIdVsDocWrapper, 
        Map<String, Set<String>> MapOfAccountIdVsSetOfMandatoryDocs, 
        Map<String, Boolean> MapOfAccountIdVsValidSubmittedDocs, 
        Map<String, Boolean> MapOfAccountIdVsValidDocs
    ) {
        Boolean validApproved = false;
        List<Account> lstAccountToUpdate = new List<Account>();
        
        for(Account objAccount : lstAccount) {     
            DocumentWrapper objWrap = MapOfAccountIdVsDocWrapper.containsKey(objAccount.id) ? 
                                     MapOfAccountIdVsDocWrapper.get(objAccount.id) : null;
            Integer TotalManadatoryDoc = MapOfAccountIdVsSetOfMandatoryDocs.containsKey(objAccount.id) ? 
                                        MapOfAccountIdVsSetOfMandatoryDocs.get(objAccount.id).size() : 0; 
            Account objAccountToUpdate = new Account(id=objAccount.id);
            if(objAccount.nm_StudentStatus__c != 'Confirmed') {
                Boolean isvalidSubmiited = MapOfAccountIdVsValidSubmittedDocs.get(objAccount.id);
                Boolean IsvalidDocuments = MapOfAccountIdVsValidDocs.get(objAccount.id);
                // DocumentWrapper objWrap = MapOfAccountIdVsDocWrapper.get(objAccount.id);
                // Integer TotalManadatoryDoc = MapOfAccountIdVsSetOfMandatoryDocs.get(objAccount.id).size(); 
                // Account objAccountToUpdate = new Account(id=objAccount.id);
    
                System.debug('IsvalidDocuments---->'+IsvalidDocuments);
                System.debug('isvalidSubmiited ----->'+isvalidSubmiited);
                System.debug('objAccountToUpdate.nm_StudentStatus__c-->'+objAccount.nm_StudentStatus__c);
                System.debug('setOfDisapprovedDocuments--'+objWrap.setOfDisapprovedDocuments.size());
                System.debug('setOfIncorrectDocuments--'+objWrap.setOfIncorrectDocuments.size());
                System.debug('setOfReSubmittedDocuments--'+objWrap.setOfReSubmittedDocuments.size());
                System.debug('setOfProvisionalDocuments--'+objWrap.setOfProvisionalDocuments.size());
                System.debug('setOfApprovedDocuments--'+objWrap.setOfApprovedDocuments.size());
                System.debug('setofProvinalforNonMandatory--'+objWrap.setofProvinalforNonMandatory.size());
                System.debug('Document Submitted Date ==>'+objAccount.nm_DocumentSubmittedDate__c);
                
                Integer TotalApprovedDoc = objWrap.setOfProvisionalDocuments.size() + objWrap.setOfApprovedDocuments.size();
                System.debug('TotalApprovedDoc---->'+TotalApprovedDoc);
                System.debug('TotalManadatoryDoc---->'+TotalManadatoryDoc);
                
                if(TotalApprovedDoc == TotalManadatoryDoc){
                    validApproved =true;
                }else{
                    validApproved=false;
                }
                System.debug('validApproved-->'+validApproved);
                //Single Document dissapproved the status
                if(objWrap.setOfDisapprovedDocuments.size() > 0){  //Single Document dissapproved the status
                    objAccountToUpdate.nm_StudentStatus__c = 'Documents Disapproved';                  
                }else if(objWrap.setOfIncorrectDocuments.size() > 0 ){
                    objAccountToUpdate.nm_StudentStatus__c = 'Documents Incorrect';              
                }else if((objWrap.setOfProvisionalDocuments.size() > 0 || objWrap.setofProvinalforNonMandatory.size()>0)  && objWrap.setOfReSubmittedDocuments.size() == 0 && validApproved && objWrap.setOfIncorrectDocuments.size()==0 && objWrap.setofInvalidDocument.size()==0){
                    if(objAccount.nm_StudentNo__c!=null && objAccount.nm_StudentNo__c!='' && !objAccount.nm_StudentStatus__c.contains('Cancel')) {
                            objAccountToUpdate.nm_StudentStatus__c = 'Confirmed';  
                    } else {
                        objAccountToUpdate.nm_StudentStatus__c = 'Admission Form & Documents Provisional';  
                    }
                    if(!IsNullOrEmpty(objWrap.ProvisionalReason))
                    {
                        objAccountToUpdate.nm_ReasonforProvisionalNoAdmission__c = objWrap.ProvisionalReason;
                    }                   
                    objAccountToUpdate.nm_IsProvisonal__c=true;                 
                }else if(objWrap.setOfApprovedDocuments.size()>0 && validApproved && objWrap.setOfDisapprovedDocuments.size()==0 && objWrap.setofProvinalforNonMandatory.size()==0 && objWrap.setOfIncorrectDocuments.size()==0 && objWrap.setOfReSubmittedDocuments.size()== 0 && objWrap.setofInvalidDocument.size()==0 ){
                    if(objAccount.nm_StudentNo__c!=null && objAccount.nm_StudentNo__c!='' && !objAccount.nm_StudentStatus__c.contains('Cancel') ) {
                        if(objAccount.Provisional_With_Hold__c == true) {
                            objAccountToUpdate.nm_StudentStatus__c = 'Confirmed'; 
                            objAccountToUpdate.Provisional_With_Hold__c = false;
                        } else {
                        objAccountToUpdate.nm_StudentStatus__c = 'Confirmed'; 
                        }
                    } else {
                        objAccountToUpdate.nm_StudentStatus__c = 'Admission form & documents Approved';  
                    }            
                }else if(IsvalidDocuments && objWrap.setOfReSubmittedDocuments.size() >0){ 
                    System.debug('doc resubmitted');
                    if(objAccount.nm_StudentStatus__c!='Documents Re-submitted'){
                        System.debug('triggered For Approved ==> 1');
                        objAccountToUpdate.nm_DocumentSubmittedDate__c = Datetime.now();
                    }
                    objAccountToUpdate.nm_StudentStatus__c = 'Documents Re-submitted';
                }else if(isvalidSubmiited){
                    System.debug('doc submitted');
                    if(objAccount.nm_StudentStatus__c !='Documents Re-submitted'){
                        objAccountToUpdate.nm_StudentStatus__c = 'Admission form & documents submitted';
                    }
                    System.debug('Student Status ==>'+objAccountToUpdate.nm_StudentStatus__c);
                    System.debug('Student Status ==>'+objAccount.nm_StudentStatus__c);
                    if(objAccount.Documnet_submitted_date_on_Lead__c != null) {
                        System.debug('triggered For Approved ==> 2');
                        objAccountToUpdate.nm_DocumentSubmittedDate__c = objAccount.Documnet_submitted_date_on_Lead__c;
                        objAccountToUpdate.Documnet_submitted_date_on_Lead__c = null;
                    } 
                    // else if((objAccount.nm_StudentStatus__c=='Admission form & documents submitted' || objAccount.nm_StudentStatus__c=='Documents Re-submitted') && String.isNotBlank(objAccount.nm_StudentNo__c)) {
                    else if (objAccount.nm_DocumentSubmittedDate__c == null || String.isNotBlank(objAccount.nm_StudentNo__c)) {
                        System.debug('triggered For Approved ==> 3');
                        objAccountToUpdate.nm_DocumentSubmittedDate__c = Datetime.now();
                        System.debug(objAccountToUpdate.nm_StudentStatus__c);
                    } 
                   // objAccount.nm_DocumentSubmittedDate__c == null || objAccount.nm_StudentNo__c!=''
                }else if(!IsvalidDocuments){
                    System.debug('Registered status');
                    objAccountToUpdate.nm_StudentStatus__c = 'Registered';
                }
                lstAccountToUpdate.add(objAccountToUpdate);
                System.debug('Student Status to Update---->'+objAccountToUpdate.nm_StudentStatus__c);  
            }  
            else {
                Integer TotalApprovedDoc = objWrap != null ? objWrap.setOfProvisionalDocuments.size() + objWrap.setOfApprovedDocuments.size() : 0;
                
                if(TotalApprovedDoc == TotalManadatoryDoc) {
                    objAccountToUpdate.Provisional_With_Hold__c = false;
                    lstAccountToUpdate.add(objAccountToUpdate);
                }
            }
        }
        return lstAccountToUpdate;
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String criteriaId
    * @param Map<String, String> documentLink
    * @param Map<String, String> documentStatus
    * @param set<String> mandatoryDocumentForCurrentCriteria
    * @param Set<String> setOfAllDocumentSubmitted
    * @return boolean
    */
    public boolean ValidateDocumentsEligibilityCriteriaWise(String criteriaId,Map<String,String> documentLink,Map<String,String> documentStatus ,set<String> mandatoryDocumentForCurrentCriteria, Set<String> setOfAllDocumentSubmitted){
        System.debug('documentLink key-----'+documentLink.keyset());
        System.debug('document Submitted-----'+setOfAllDocumentSubmitted);
        for(String documentName : mandatoryDocumentForCurrentCriteria)
        {
            System.debug('Document Name---->'+documentName+'------criteriaId ----'+criteriaId );
            System.debug('Document Link----->'+documentLink.get(criteriaId+'-'+documentName));
             System.debug('Document Status----->'+documentStatus.get(criteriaId+'-'+documentName));
            if(documentLink.get(criteriaId+'-'+documentName) == null)
            {
                System.debug('Enter In Loop Of Null Link-->');
                return false;
            }
            
            if(documentStatus.get(criteriaId+'-'+documentName) == 'Disapproved' )
            {
                return false;
            }
            
            if(documentStatus.get(criteriaId+'-'+documentName) == 'Documents incorrect' )
            {
                if(documentLink.get(criteriaId+'-'+documentName) == null)
                {
                    
                    return false;
                }
            }
        }
        
        // allows to Update Student Status to Disapproved if any submitted document is disapproved 
        if(setOfAllDocumentSubmitted.size()>0)
        {
            for(String documentName : setOfAllDocumentSubmitted)
            {
                System.debug('Document Name Submitted---->'+documentName);
                if(documentStatus.get(criteriaId+'-'+documentName) == 'Disapproved' )
                {
                    return false;
                }
            }
        }   
        
        return true;
    }


    /**
    * @description 
      check for admission form and document submitted status
    * @author shubhranshu | 10/15/2019 
    * @param criteriaId 
    * @param documentLink 
    * @param documentStatus 
    * @param mandatoryDocumentForCurrentCriteria 
    * @param setOfAllDocumentSubmitted 
    * @return boolean 
    **/
    public boolean SubmittedDocumentsEligibilityCriteriaWise(String criteriaId,Map<String,String> documentLink,Map<String,String> documentStatus ,set<String> mandatoryDocumentForCurrentCriteria, Set<String> setOfAllDocumentSubmitted){
        
        Set<String> setofmandatoryWithLink = new Set<String>();
        for(String documentName : mandatoryDocumentForCurrentCriteria)
        {   
            System.debug('Document Name in mandatory---->'+documentName+'------criteriaId ----'+criteriaId );
            System.debug('Document Link in mandatory----->'+documentLink.get(criteriaId+'-'+documentName));
            System.debug('Document Status in mandatory----->'+documentStatus.get(criteriaId+'-'+documentName));
            
            if(documentLink.get(criteriaId+'-'+documentName) == null )
            {   
                return false;     
            }else{
                setofmandatoryWithLink.add(documentName);
                System.debug('setofmandatoryWithLink size '+setofmandatoryWithLink.size()+'mandatoryDocumentForCurrentCriteria size '+mandatoryDocumentForCurrentCriteria.size());
                if(setofmandatoryWithLink.size() == mandatoryDocumentForCurrentCriteria.size()){
                    return true;
                }
            }
           
            // if(documentStatus.get(criteriaId+'-'+documentName) != null && documentLink.get(criteriaId+'-'+documentName) != null
            //     && documentStatus.get(criteriaId+'-'+documentName) =='Created' ){
            //     setofmandatoryWithLink.add(documentName);
            //    
            //     if(setofmandatoryWithLink.size() == mandatoryDocumentForCurrentCriteria.size()){
            //         return true;
            //     }
            // }

        }
        
        if(setOfAllDocumentSubmitted.size()>0)
        {
            for(String documentName : setOfAllDocumentSubmitted)
            {   
                System.debug('Document Name in all docs---->'+documentName+'------criteriaId ----'+criteriaId );
                System.debug('Document Link in all docs----->'+documentLink.get(criteriaId+'-'+documentName));
                System.debug('Document Status in all docs----->'+documentStatus.get(criteriaId+'-'+documentName));
                
                if(documentStatus.get(criteriaId+'-'+documentName) != null 
                  && (documentStatus.get(criteriaId+'-'+documentName) == 'Disapproved' || documentStatus.get(criteriaId+'-'+documentName) == 'Documents incorrect' ||
                      documentStatus.get(criteriaId+'-'+documentName) == 'Approved' || documentStatus.get(criteriaId+'-'+documentName) == 'Not Applicable' ||
                     documentStatus.get(criteriaId+'-'+documentName) == 'Re-Submited' || documentStatus.get(criteriaId+'-'+documentName) == 'Admission Form & Documents Provisional' ))
                {   
                   return false;
                }
            }
        }   
        
        return true;
    }


     /**
     * @description
     * @author shubhranshu | 8/20/2019
     * @param list<Account> lstAccount
     * @return void
     */
    public void DocumentCreationOnAccount (list<Account> lstAccount){
        List<nm_LinksForDocuments__c> newAccountDocumentsToInsert = new List<nm_LinksForDocuments__c>();
        //map to store account id against lead id
        map<string,id> mapLeadAccountId = new map<string,id>();
        Id eligiblityId = null;
        for (Account objAccount : lstAccount)
        {   
            eligiblityId = objAccount.nm_EligiblityCriteria__c;
            if(objAccount.nm_LeadId__c != null && objAccount.nm_LeadId__c != ''){
             //   Id LeadId = objAccount.nm_LeadId__c;
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }
        System.debug('KeySet-----'+mapLeadAccountId.keyset());
        //Query to get data of recently converted lead
        list<nm_LinksForDocumentsLead__c> lstLinksForDocumentsLead = ([select id, Name, Lead_Id__c,Work_Experience__c,nm_ReasonforDisapprove__c, nm_URLforDocuments__c,nm_DocumentName__c,
         nm_Account__c ,nm_Status__c, Document_Upload_Mode__c from nm_LinksForDocumentsLead__c  where Lead__c in: mapLeadAccountId.keyset()]); 
                                                        
        
        //Set<Id> accountsToDeleteDocs = new Set<Id>();     
        Set<String> documentinserted = new Set<String>();      
        System.debug('lstLinksForDocumentsLead '+lstLinksForDocumentsLead);

        if(lstLinksForDocumentsLead.size() > 0){
            for(nm_LinksForDocumentsLead__c objDocLead : lstLinksForDocumentsLead){
                Id LeadId = objDocLead.Lead_Id__c;
                Id AccountId = mapLeadAccountId.get(string.valueof(LeadId));
                System.debug('AccountId---'+AccountId);
                System.debug('LeadId-----'+LeadId);
                //Save Lead document in format of Account Document
                nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
                                    
                objDocument.Name = objDocLead.Name;
                objDocument.nm_DocumentName__c = objDocLead.nm_DocumentName__c;
                objDocument.nm_Account__c = AccountId;
                objDocument.nm_URLforDocuments__c = objDocLead.nm_URLforDocuments__c;

                objDocument.Document_Upload_Mode__c= objDocLead.Document_Upload_Mode__c;

                objDocument.nm_Status__c=objDocLead.nm_Status__c;
                if(objDocLead.Work_Experience__c != null) {
                    objDocument.Work_Experience__c = objDocLead.Work_Experience__c;
                }
                objDocument.nm_ReasonforDisapprove__c = objDocLead.nm_ReasonforDisapprove__c;
                newAccountDocumentsToInsert.add(objDocument);
                //To link lead level documents to converted account
                objDocLead.nm_Account__c = AccountId;
                documentinserted.add(objDocument.Name);
            }
        
        
            //Get documents to delete since we are adding them from Lead
            list<nm_LinksForDocuments__c> lstLinksForDocumentsAccount = new List<nm_LinksForDocuments__c>();
           
            if(lstLinksForDocumentsAccount != null && lstLinksForDocumentsAccount.size()> 0){
                try{
                    delete lstLinksForDocumentsAccount;
                    System.debug('lstLinksForDocumentsAccount -->'+lstLinksForDocumentsAccount);
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
            }
            if(newAccountDocumentsToInsert.size() > 0 ){
                try{
                    insert newAccountDocumentsToInsert;
                    System.debug('newAccountDocumentsToInsert -->'+newAccountDocumentsToInsert);
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
            } 
            //To link lead level documents to converted account
            if(lstLinksForDocumentsLead.size() > 0 ){
                try{
                    update lstLinksForDocumentsLead;
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
            }
        
        }else{
            //Document list to insert  
            System.debug('enter to create docs in account level...');
            List<nm_LinksForDocuments__c> lstDocuments = new List<nm_LinksForDocuments__c>();
            //Calling method to get documents list against each criteria
            map<string, set<string>> mapCriteriaDocuments = GetProgrameWiseDocumentsList();
           
            for(Account objAccount : lstAccount)
            {
                Id criteriaId = objAccount.nm_EligiblityCriteria__c;
                if(criteriaId != null)
                {      
                    system.debug(mapCriteriaDocuments.get(criteriaId));        
                    if(mapCriteriaDocuments.get(criteriaId) != null)
                    {
                        //Creating document records to insert.
                        for(string strDocumentName : mapCriteriaDocuments.get(criteriaId))
                        { 
                            nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
                            objDocument.nm_DocumentName__c = strDocumentName;
                            objDocument.Name = strDocumentName;
                            objDocument.nm_Account__c = objAccount.id;
                            lstDocuments.add(objDocument);
                        }
                    }
                }
                   
                if(objAccount.nm_DefencePersonnel__c =='Yes'){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Defence Document', objAccount.id,false);
                    lstDocuments.add(objDoc);
                }
                if(objAccount.Differently_abled__c =='Yes'){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Differently Abled Document', objAccount.id,false);
                    lstDocuments.add(objDoc);
                }

                if(String.isNotBlank(objAccount.nm_Category__c) && objAccount.nm_Category__c != 'General' && PickListHelper.getPickListValuesForAccountCategory().contains(objAccount.nm_Category__c) ){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Caste Certificate Document', objAccount.id,false);
                    lstDocuments.add(objDoc);
                }

                if(objAccount.nm_Relationship__c!=null && objAccount.nm_Relationship__c!='Self' && objAccount.nm_DefencePersonnel__c =='Yes'){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Relationship Document', objAccount.id,false);
                    lstDocuments.add(objDoc);
                }
                
                
                if(objAccount.Is_Lateral__c && !objAccount.nmStudent_Program__c.startsWith('A')){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Diploma Marksheet', objAccount.id,false);
                    lstDocuments.add(objDoc);
                    nm_LinksForDocuments__c objDoc1 = exceptionalDocumentNeedToInsert('NMIMS Diploma Certificate', objAccount.id,false);
                    lstDocuments.add(objDoc1);
                }
                
                if(objAccount.Is_Lateral__c && objAccount.nmStudent_Program__c.startsWith('A')){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Certificate Program Marksheet', objAccount.id,false);
                    lstDocuments.add(objDoc);
                    nm_LinksForDocuments__c objDoc1 = exceptionalDocumentNeedToInsert('NMIMS Certificate Program Completion Certificate', objAccount.id,false);
                    lstDocuments.add(objDoc1);
                }

                if(objAccount.nm_ChooseaProgram__c =='Bachelor Programs' && (objAccount.HSC_status__c == 'Appeared' || objAccount.HSC_status__c == 'Pending')){
                    System.debug('Entered for insertion...');
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('11th Marksheet', objAccount.id,false);
                    lstDocuments.add(objDoc);
                }

                if(objAccount.nm_ChooseaProgram__c =='Bachelor Programs' && objAccount.Diploma_status__c == 'Appeared'){
                    nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Diploma 1st year Marksheet', objAccount.id,false);
                    lstDocuments.add(objDoc);
                    nm_LinksForDocuments__c objDoc1 = exceptionalDocumentNeedToInsert('Diploma 2nd year Marksheet', objAccount.id,false);
                    lstDocuments.add(objDoc1);
                }
            }
            System.debug('lstDocuments size if new doc insert'+lstDocuments.size());
            //Inserting document list
            if(lstDocuments.size() > 0){
                try{
                    insert lstDocuments;
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
            }
               
        }
    }
    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String DocName
    * @param String AccId
    * @return nm_LinksForDocuments__c
    */
    public nm_LinksForDocuments__c exceptionalDocumentNeedToInsert(String DocName, String AccId,Boolean statusUpdate){
        nm_LinksForDocuments__c objNmDoc = new nm_LinksForDocuments__c();
        objNmDoc.Name = DocName;
        objNmDoc.nm_DocumentName__c = DocName;
        objNmDoc.nm_Account__c = AccId;
        if(statusUpdate){
            objNmDoc.nm_Status__c = 'Created';
        }
        return objNmDoc;
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @return map<string, set<string>>
    */
    public map<string, set<string>> GetProgrameWiseDocumentsList(){
        //Map of list of required documents against programe
        map<string, set<string>> mapProgramAndDocuments = new map<string, set<string>>(); 
        //Fetching eligibility criteria for all programs.
        List<nm_EligiblityCriteria__c> lstEligibilityCriteria = [select id, Name, nm_Program__c,
                                                                        nm_Documnetslist__c
                                                                      from nm_EligiblityCriteria__c];
        if(lstEligibilityCriteria != null && lstEligibilityCriteria.size() > 0)
        {
            for(nm_EligiblityCriteria__c objCriteria : lstEligibilityCriteria)
            {
                if(mapProgramAndDocuments.get(objCriteria.Id) == null)
                {
                    mapProgramAndDocuments.put(objCriteria.Id, new set<string>());
                }
                
                //Filling set of documents against each criteria.
                for(string strDocument : objCriteria.nm_Documnetslist__c.split(';'))
                {
                    mapProgramAndDocuments.get(objCriteria.Id).add(strDocument);
                }
            }
        } 
        
        return mapProgramAndDocuments;                                                                     
    }


    public Set<String> getDocWithWorkExperience(Set<String> documentsForNewCriteria, List<nm_WorkExperience__c> lstWorkExperience) {
        Set<String> newDocDriteria = new Set<String>();
        if (lstWorkExperience.size() > 0) {
            if (documentsForNewCriteria.size()> 0) {
                String WkDocName = '';
                for (String docName : documentsForNewCriteria) {
                    if (docName.contains('Work Experience')) {
                        WkDocName = docName;
                    } else {
                        newDocDriteria.add(docName);
                    }
                }
                if (String.isNotBlank(WkDocName)) {
                    for (nm_WorkExperience__c wk : lstWorkExperience) {
                        newDocDriteria.add(WkDocName + '/' + wk.Name  + '/' + wk.nm_CompanyName__c.left(125));
                    }
                }
                return newDocDriteria;
            } else {
                return new Set<String>();
            }
        } else {
            return documentsForNewCriteria;
        }
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param List<Account> lstAccount
    * @param Id criteriaId
    * @param String AccountId
    * @return void
    */
    public void UpdateDocumentsOnAccountForChangeInEligibilityCriteria(List<Account> lstAccount,Id criteriaId,String AccountId){
        // set of existing Document
        Set<string>  existingDocs = new Set<String>(); 
        //Document list to insert  
        List<nm_LinksForDocuments__c> lstDocuments = new List<nm_LinksForDocuments__c>();
        //Document to delete
        List<nm_LinksForDocuments__c> lstDocumentsToDelete = new List<nm_LinksForDocuments__c>();
        set<String> programTypeOfLabel = new Set<String>(new List<String>(System.Label.WorkExpMandatory.split(',')));
        Map<String,Account> mapOfAccIdVsAccount = new Map<String, Account>();
        if (lstAccount.size() > 0) {
            for (Account objAcc : lstAccount) {
                mapOfAccIdVsAccount.put(objAcc.Id, objAcc);
            }
        }
        
        if(lstAccount != null && lstAccount.size() > 0)
        {
            //fetch all document Already Inserted for current Account 
            List<nm_WorkExperience__c> lstWorkExperience = new List<nm_WorkExperience__c>();
            List<nm_LinksForDocuments__c> oldDocuments = [Select id, nm_DocumentName__c, nm_Account__c, nm_AccountEmail__c, nm_DocumentLink__c, Documents_Submited_Date__c, nm_Lead__c, linkID__c, Links_For_Documents_Lead__c, nm_ReasonforDisapprove__c, Registration_No__c, Sample__c, nm_Status__c, nm_URLforDocuments__c from nm_LinksForDocuments__c where nm_Account__c =:AccountId ];
            if (mapOfAccIdVsAccount.containsKey(AccountId)) {
                String programType = mapOfAccIdVsAccount.get(AccountId).Program_Type__c;
                if (String.isNotBlank(programType) && programTypeOfLabel.contains(programType)) {
                    lstWorkExperience = [SELECT Id,Name, nm_CompanyName__c FROM nm_WorkExperience__c WHERE nm_Student__c = :AccountId];
                }
            }
            if(oldDocuments != null && oldDocuments.size() > 0)
            {
                for(nm_LinksForDocuments__c oldDoc : oldDocuments)
                {
                    existingDocs.add(oldDoc.nm_DocumentName__c);
                }
            }
            
            System.debug('existingDocs '+existingDocs);
            //Calling method to get documents list against each criteria
            Map<string, set<string>> mapCriteriaDocuments = GetProgrameWiseDocumentsList();
            //Fetch Document according to new criteria
             Set<string>  documentsForNewCriteriaBeforeWK = mapCriteriaDocuments.containsKey(criteriaId) ? mapCriteriaDocuments.get(criteriaId) : new Set<String>();
             Set<String> documentsForNewCriteria = getDocWithWorkExperience(documentsForNewCriteriaBeforeWK, lstWorkExperience);
             System.debug('documentsForNewCriteria '+documentsForNewCriteria);
            if(criteriaId !=null)
            {
                if(mapCriteriaDocuments.get(criteriaId) != null)
                {  
                   //Creating document records to insert.
                    for(string strDocumentName : documentsForNewCriteria)
                    {
                        if(existingDocs != null && existingDocs.contains(strDocumentName))
                        {
                          //Do not add new document if it is already in system, and use same so that its links are also same
                           continue;
                        }
                        nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
                        objDocument.name = strDocumentName.left(75);
                        objDocument.nm_DocumentName__c = strDocumentName;
                        objDocument.nm_Account__c = AccountId;
                        objDocument.nm_Status__c = 'Created';
                        lstDocuments.add(objDocument);
                    }
                }
            }
            
            // loop to create Additional Required Document 
            for(Account objAcc :lstAccount)
            {
                if(!'Confirmed'.equalsIgnoreCase(objAcc.nm_StudentStatus__c))
                {
                    if(objAcc.nm_DefencePersonnel__c=='Yes')
                    {
                        documentsForNewCriteria.add('Defence Document');
                        if(!existingDocs.contains('Defence Document'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Defence Document', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }       
                    }
                    if(objAcc.Differently_abled__c =='Yes')
                    {
                        documentsForNewCriteria.add('Differently Abled Document');
                        if(!existingDocs.contains('Differently Abled Document'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Differently Abled Document', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }       
                    }

                //System.debug('PickListHelper.getPickListValuesForLeadCategory() :: '+PickListHelper.getPickListValuesForAccountCategory().toString());
                //System.debug('objAcc.nm_Category__c :: '+objAcc.nm_Category__c+' PickListHelper.getPickListValuesForAccountCategory().contains(objAcc.nm_Category__c) :: '+PickListHelper.getPickListValuesForLeadCategory().contains(objAcc.nm_Category__c) );
                
                    if(String.isNotBlank(objAcc.nm_Category__c) && objAcc.nm_Category__c != 'General' && PickListHelper.getPickListValuesForAccountCategory().contains(objAcc.nm_Category__c) )
                    {
                        documentsForNewCriteria.add('Caste Certificate Document');
                        if(!existingDocs.contains('Caste Certificate Document'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Caste Certificate Document', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }       
                    }
                            
                    if(objAcc.nm_Relationship__c!=null && objAcc.nm_Relationship__c!='Self' && objAcc.nm_DefencePersonnel__c =='Yes')
                    {
                        documentsForNewCriteria.add('Relationship Document');
                        if(!existingDocs.contains('Relationship Document'))
                        {   
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Relationship Document', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }        
                    }
                    
                    if(objAcc.Is_Lateral__c && !objAcc.nmStudent_Program__c.startsWith('A') )
                    {
                        documentsForNewCriteria.add('NMIMS Diploma Marksheet');
                        if(!existingDocs.contains('NMIMS Diploma Marksheet'))
                        {   
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Diploma Marksheet', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }        
                    }
                           
                    if(objAcc.Is_Lateral__c && !objAcc.nmStudent_Program__c.startsWith('A') )
                    {
                        documentsForNewCriteria.add('NMIMS Diploma Certificate');
                        if(!existingDocs.contains('NMIMS Diploma Certificate'))
                        {   
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Diploma Certificate', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }        
                    }
                    
                    if(objAcc.Is_Lateral__c && objAcc.nmStudent_Program__c.startsWith('A') )
                    {
                        documentsForNewCriteria.add('NMIMS Certificate Program Completion Certificate');
                        if(!existingDocs.contains('NMIMS Certificate Program Completion Certificate'))
                        {   
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Certificate Program Completion Certificate', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }        
                    }
                    
                    if(objAcc.Is_Lateral__c && objAcc.nmStudent_Program__c.startsWith('A') )
                    {
                        documentsForNewCriteria.add('NMIMS Certificate Program Marksheet');
                        if(!existingDocs.contains('NMIMS Certificate Program Marksheet'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('NMIMS Certificate Program Marksheet', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }        
                    }

                    if(objAcc.nm_ChooseaProgram__c =='Bachelor Programs' && (objAcc.HSC_status__c == 'Appeared' || objAcc.HSC_status__c == 'Pending')){
                        documentsForNewCriteria.add('11th Marksheet');
                        System.debug('Entered for doc insert ...');
                        if(!existingDocs.contains('11th Marksheet'))
                        { 
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('11th Marksheet', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }
                    }

                    if(objAcc.nm_ChooseaProgram__c =='Bachelor Programs' && objAcc.Diploma_status__c == 'Appeared'){
                        documentsForNewCriteria.add('Diploma 1st year Marksheet');
                        if(!existingDocs.contains('Diploma 1st year Marksheet'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Diploma 1st year Marksheet', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }
                    }

                    if(objAcc.nm_ChooseaProgram__c =='Bachelor Programs' && objAcc.Diploma_status__c == 'Appeared'){
                        documentsForNewCriteria.add('Diploma 2nd year Marksheet');
                        if(!existingDocs.contains('Diploma 2nd year Marksheet'))
                        {
                            nm_LinksForDocuments__c objDoc = exceptionalDocumentNeedToInsert('Diploma 2nd year Marksheet', objAcc.id,true);
                            lstDocuments.add(objDoc);
                        }
                    }
                }
            }
            
            // loop to delete non - required document from account
            //Fetch old criteria documents and delete those which are not to be there as per New Criteria
            if(oldDocuments.size() > 0 )
            {
                for(nm_LinksForDocuments__c oldDoc : oldDocuments)
                {
                    string strDocumentName = oldDoc.nm_DocumentName__c;
                    
                    if(!documentsForNewCriteria.contains(strDocumentName))
                    {
                        System.debug('oldDoc ==> ' + oldDoc.nm_URLforDocuments__c);
                        // allowed to Insert Additional Documents
                        if(strDocumentName !=null && strDocumentName !='' && !strDocumentName.contains('Additional') && (String.IsBlank(oldDoc.nm_URLforDocuments__c) || oldDoc.nm_Status__c!='Approved'))
                        {
                            if((oldDoc.nm_DocumentName__c == 'Caste Certificate Document' || oldDoc.nm_DocumentName__c == 'Differently Abled Document') && !String.IsBlank(oldDoc.nm_URLforDocuments__c))
                            {
                                
                            }else{
                                lstDocumentsToDelete.add(oldDoc);
                            }
                            
                        }
                    }
                }
            }
            
            System.debug('---existingDocs---'+existingDocs+'----'+lstDocumentsToDelete+'----lstDocuments----'+lstDocuments);
            //Delete old document list which dont requried as per new criteria   
            if(lstDocumentsToDelete.size() > 0)
            {
                delete lstDocumentsToDelete;
            } 
            
            //Inserting document list
            if(lstDocuments.size() > 0)
            {
                insert lstDocuments;
                // do not run if studnet is already confirmed
                UpdateDocumentSubmittedStatusOnAccount(lstAccount);
                system.debug('lstDocuments.size() '+lstDocuments.size());
            }  
            
        }
    }


    // public void callFindabilityWebService(List<nm_LinksForDocuments__c> listOfLinksForDocuments ,Map<id, nm_LinksForDocuments__c> mapOfOldDoc) {
    //     Set<String> accountIds = new Set<String>();
    //     for(nm_LinksForDocuments__c objLinkForDocument : listOfLinksForDocuments) {
    //         if(objLinkForDocument.Name == 'Photo ID proof' && String.isNotBlank(objLinkForDocument.nm_Account__c)
    //          && objLinkForDocument.nm_URLforDocuments__c!='' && objLinkForDocument.nm_URLforDocuments__c!=null              
    //          && objLinkForDocument.nm_URLforDocuments__c!= mapOfOldDoc.get(objLinkForDocument.id).nm_URLforDocuments__c 
             
    //          ) {
    //             accountIds.add(objLinkForDocument.nm_Account__c);
    //         }
    //     }
    //     if(accountIds.size() > 0) {
    //         CallWebServiceFindability(accountIds);
    //     }
    // }

    // @future
    // public static void CallWebServiceFindability(Set<String> accId) {
    //     if(accId.size() > 0) {
    //         FindabilityWebService.FSPhotoIDMatchAPI(accId.toString());
    //     }
    // }

    /**
    * @description // to allow Confirmed students to update the status.
    * @author @BK | 16/3/2020 
    * @param lstDoc 
    * @return Set<String> 
    **/
    public Set<String> getSetOfStudentsAllowToUpdate(List<nm_LinksForDocuments__c> lstDoc) {
        Set<String> setOfNumber = new Set<String>();
        Set<String> setOfStudentNoAllowUpdate = new Set<String>();

        for(nm_LinksForDocuments__c linksForDocuments: lstDoc) {
            if(linksForDocuments.Student_Number__c!=null && linksForDocuments.Student_Number__c!='') {
                setOfNumber.add(linksForDocuments.Student_Number__c);
            }
        }

        if(setOfNumber.size() > 0) {
            List<IC_Change_Request__c> lstICChangeRequest = [SELECT id,Student_Number__c FROM IC_Change_Request__c WHERE Student_Number__c IN :setOfNumber AND Status__c='New'];
            if(lstICChangeRequest.size() > 0) {
                for(IC_Change_Request__c objIC : lstICChangeRequest) {
                    setOfStudentNoAllowUpdate.add(objIC.Student_Number__c);
                }
            }
        }

        return setOfStudentNoAllowUpdate;
    }

    public Map<String,List<nm_WorkExperience__c>> getMapAccIdVsWk(List<Account> lstAcc) {
        Set<String> setOfAccIds = new Set<String>();
        Map<String,List<nm_WorkExperience__c>> mapAccIdVsWk = new Map<String,List<nm_WorkExperience__c>>();
        for (Account objAcc : lstAcc) {
            Set<String> programOff = new Set<String>(new List<String>(System.Label.WorkExpMandatory.split(',')));
            if(programOff.contains(objAcc.Program_Type__c)) {
                system.debug('programOff --> ' + objAcc.Id);
                setOfAccIds.add(objAcc.Id);
            }
        }
        if(setOfAccIds.size() > 0) {
            List<nm_WorkExperience__c> lstWk = [SELECT Id, Name,nm_Student__r.Id, nm_CompanyName__c From nm_WorkExperience__c WHERE nm_Student__c IN :setOfAccIds];
            system.debug('lstWk --> ' + lstWk);
            if (lstWk.size() > 0) {
                for (nm_WorkExperience__c WK : lstWk) {
                    if(!mapAccIdVsWk.containsKey(WK.nm_Student__r.Id)) {
                        mapAccIdVsWk.put(WK.nm_Student__r.Id, new List<nm_WorkExperience__c>());
                    }
                    List<nm_WorkExperience__c> lstW = mapAccIdVsWk.get(WK.nm_Student__r.Id);
                    lstW.add(WK);
                    mapAccIdVsWk.put(WK.nm_Student__r.Id, lstW);
                }
            }
        }
        return mapAccIdVsWk;
    }

    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String SObjectAPIName
    * @param String conditionString
    * @param String relatedFields
    * @return String
    */
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }


    /**
    * @description
    * @author shubhranshu | 8/20/2019
    * @param String fieldValue
    * @return boolean
    */
    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    } 



    public class DocumentWrapper {
        Map<String,String> documentLink {get;set;}
        Map<String,String> documentStatus {get;set;}
        Set<String> setOfDisapprovedDocuments {get;set;}
        Set<String> setOfProvisionalDocuments {get;set;}
        Set<String> setOfApprovedDocuments {get;set;}
        Set<String> setOfIncorrectDocuments {get;set;}
        Set<String> setOfReSubmittedDocuments {get;set;}
        Set<String> setofInvalidDocument {get;set;}
        Set<String> setofProvinalforNonMandatory {get;set;}
        set<String> setOfAllDocumentSubmitted {get;set;}
        String ProvisionalReason {get;set;}

        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public DocumentWrapper(
            Map<String,String> docLink, 
            Map<String,String> docStatus, 
            Set<String> DisApproveDocs, 
            Set<String> ProvisionalDocs, 
            Set<String> ApproveDocs, 
            Set<String> IncorrectDocs, 
            Set<String> ReSubmit, 
            Set<String> InValidDocs, 
            Set<String> MadatoryDocs, 
            Set<String> AllDocs, 
            String reason) {

            documentLink = docLink;
            documentStatus = docStatus;
            setOfDisapprovedDocuments = DisApproveDocs;
            setOfProvisionalDocuments = ProvisionalDocs;
            setOfApprovedDocuments = ApproveDocs;
            setOfIncorrectDocuments = IncorrectDocs;
            setOfReSubmittedDocuments = ReSubmit;
            setofInvalidDocument = InValidDocs;
            setofProvinalforNonMandatory = MadatoryDocs;
            setOfAllDocumentSubmitted = AllDocs;
            ProvisionalReason = reason;
        }
    }


}