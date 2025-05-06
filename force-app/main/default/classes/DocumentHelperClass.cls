/**
 * @File Name          : DocumentHelperClass.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 28--04--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/10/2019, 11:20:41 AM   shubhranshu     Initial Version
**/
public class DocumentHelperClass
{
    //Method to create a map of criteria id and list of documents.
    public map<string, set<string>> GetProgrameWiseDocumentsList(Set<String> setOfEligiblityCriteria)
    {   
        System.debug('enter in GetProgrameWiseDocumentsList');
        //Map of list of required documents against programe
        map<string, set<string>> mapProgramAndDocuments = new map<string, set<string>>(); 
        //Fetching eligibility criteria for all programs.
        List<nm_EligiblityCriteria__c> lstEligibilityCriteria = [select id, Name, nm_Program__c,
                                                                        nm_Documnetslist__c
                                                                      from nm_EligiblityCriteria__c where id IN:setOfEligiblityCriteria];
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
    
    // public void CreateDocumentRecordsOnAccount(List<Account> lstAccount)
    // {
    //     if(lstAccount != null && lstAccount.size() > 0)
    //     {
    //         //Document list to insert  
    //         List<nm_LinksForDocuments__c> lstDocuments = new List<nm_LinksForDocuments__c>();
    //         //Calling method to get documents list against each criteria
    //         map<string, set<string>> mapCriteriaDocuments = GetProgrameWiseDocumentsList();
                    
    //         for(Account objAccount : lstAccount)
    //         {
    //             Id criteriaId = objAccount.nm_EligiblityCriteria__c;
    //             if(criteriaId != null)
    //             {      
    //                 system.debug(mapCriteriaDocuments.get(criteriaId));        
    //                 if(mapCriteriaDocuments.get(criteriaId) != null)
    //                 {
    //                     //Creating document records to insert.
    //                     for(string strDocumentName : mapCriteriaDocuments.get(criteriaId))
    //                     { 
    //                         nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
    //                         objDocument.nm_DocumentName__c = strDocumentName;
    //                         objDocument.Name = strDocumentName;
    //                         objDocument.nm_Account__c = objAccount.id;
    //                         lstDocuments.add(objDocument);
    //                     }
    //                 }
    //             }
                   
    //             if(objAccount.nm_DefencePersonnel__c =='Yes'){
    //                 nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                 objDoc.name = 'Defence Document';
    //                 objDoc.nm_DocumentName__c = 'Defence Document';
    //                 objDoc.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDoc);
    //             }
    //             if(objAccount.nm_Relationship__c!=null && objAccount.nm_Relationship__c!='Self' && objAccount.nm_DefencePersonnel__c =='Yes'){
    //                 nm_LinksForDocuments__c objDocm = new nm_LinksForDocuments__c();
    //                 objDocm.name = 'Relationship Document';
    //                 objDocm.nm_DocumentName__c = 'Relationship Document';
    //                 objDocm.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDocm);
    //             }
                
                
    //             if(objAccount.Is_Lateral__c && !objAccount.nmStudent_Program__c.startsWith('A')){
    //                 nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                 objDoc.name = 'NMIMS Diploma Marksheet';
    //                 objDoc.nm_DocumentName__c = 'NMIMS Diploma Marksheet';
    //                 objDoc.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDoc);
    //             }
                        
                
    //             if(objAccount.Is_Lateral__c && !objAccount.nmStudent_Program__c.startsWith('A')){
    //                 nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                 objDoc.name = 'NMIMS Diploma Certificate';
    //                 objDoc.nm_DocumentName__c = 'NMIMS Diploma Certificate';
    //                 objDoc.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDoc);
    //             }
                
    //             if(objAccount.Is_Lateral__c && objAccount.nmStudent_Program__c.startsWith('A')){
    //                 nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                 objDoc.name = 'NMIMS Certificate Program Marksheet';
    //                 objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Marksheet';
    //                 objDoc.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDoc);
    //             }
    //             if(objAccount.Is_Lateral__c && objAccount.nmStudent_Program__c.startsWith('A')){
    //                 nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                 objDoc.name = 'NMIMS Certificate Program Completion Certificate';
    //                 objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Completion Certificate';
    //                 objDoc.nm_Account__c = objAccount.id;
    //                 lstDocuments.add(objDoc);
    //             }
                
                
                
    //         }
            
    //         //Inserting document list
    //         if(lstDocuments.size() > 0)
    //             insert lstDocuments;
    //     }
    // }  
    
    
    public void CreateDocumentRecordsOnLead(List<Lead> lstLead , Map<string, set<string>> mapCriteriaDocuments)
    {
        if(lstLead != null && lstLead.size() > 0)
        {
            //Document list to insert  
            List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();
           
            // map<string, set<string>> mapCriteriaDocuments = GetProgrameWiseDocumentsList();
                    
            for(Lead objLead : lstLead)
            {
                Id criteriaId = objLead.nm_EligiblityCriteria__c;
                if(criteriaId != null && mapCriteriaDocuments != null)
                {      
                    system.debug(mapCriteriaDocuments.get(criteriaId));        
                    if(mapCriteriaDocuments.get(criteriaId) != null)
                    {
                        //Creating document records to insert.
                        for(string strDocumentName : mapCriteriaDocuments.get(criteriaId))
                        { 
                            nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
                            objDocument.name = strDocumentName;
                            objDocument.nm_DocumentName__c = strDocumentName;
                            objDocument.Lead__c = objLead.id; 
                            lstDocuments.add(objDocument);
                        }
                    }
                }
                   
                if(objLead.Are_you_from_Defence__c =='Yes'){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='Defence Document';
                    objDoc.nm_DocumentName__c='Defence Document';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);
                }
                if(objLead.Differently_abled__c =='Yes'){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='Differently Abled Document';
                    objDoc.nm_DocumentName__c='Differently Abled Document';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);
                }
                //System.debug('PickListHelper.getPickListValuesForLeadCategory() :: '+PickListHelper.getPickListValuesForLeadCategory().toString());
                //System.debug('objLead.nm_Category__c :: '+objLead.nm_Category__c+' PickListHelper.getPickListValuesForLeadCategory().contains(objLead.nm_Category__c) :: '+PickListHelper.getPickListValuesForLeadCategory().contains(objLead.nm_Category__c) );
                if(String.isNotBlank(objLead.nm_Category__c) && objLead.nm_Category__c != 'General' && PickListHelper.getPickListValuesForLeadCategory().contains(objLead.nm_Category__c) ){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='Caste Certificate Document';
                    objDoc.nm_DocumentName__c='Caste Certificate Document';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);
                }
                
                if(objLead.Relationship__c!=null && objLead.Relationship__c!='Self' && objLead.Are_you_from_Defence__c =='Yes'){
                    nm_LinksForDocumentsLead__c objDocm = new nm_LinksForDocumentsLead__c();
                    objDocm.name = 'Relationship Document';
                    objDocm.nm_DocumentName__c = 'Relationship Document';
                    objDocm.Lead__c = objLead.id;  
                    lstDocuments.add(objDocm);
                }
                
                
                // if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c !=null && !objLead.nm_ProgramName__c.StartsWith('A')){
                //     nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //     objDoc.name = 'NMIMS Diploma Marksheet';
                //     objDoc.nm_DocumentName__c = 'NMIMS Diploma Marksheet';
                //     objDoc.Lead__c = objLead.id;  
                //     lstDocuments.add(objDoc);
                // }
                        
                
                // if(objLead.Is_Lateral__c  && objLead.nm_ProgramName__c !=null  && !objLead.nm_ProgramName__c.StartsWith('A')){
                //     nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //     objDoc.name = 'NMIMS Diploma Certificate';
                //     objDoc.nm_DocumentName__c = 'NMIMS Diploma Certificate';
                //     objDoc.Lead__c = objLead.id;  
                //     lstDocuments.add(objDoc);
                // }

                if(objLead.Is_Lateral__c){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='NMIMS Diploma Certificate';
                    objDoc.nm_DocumentName__c='NMIMS Diploma Certificate';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);  
                
                    nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                    objDoct.name ='NMIMS Diploma Marksheet';
                    objDoct.nm_DocumentName__c='NMIMS Diploma Marksheet';
                    objDoct.Lead__c = objLead.id;  
                    lstDocuments.add(objDoct);  
                }
                
                // not in used for as of now comment on 01/07/2020

                // if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c !=null  && objLead.nm_ProgramName__c.StartsWith('A')){
                //     nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //     objDoc.name = 'NMIMS Certificate Program Completion Certificate';
                //     objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Completion Certificate';
                //     objDoc.Lead__c = objLead.id;  
                //     lstDocuments.add(objDoc); 
                // }
                
                // if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c !=null  && objLead.nm_ProgramName__c.StartsWith('A')){
                //     nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //     objDoc.name = 'NMIMS Certificate Program Marksheet';
                //     objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Marksheet';
                //     objDoc.Lead__c = objLead.id;  
                //     lstDocuments.add(objDoc);
                // }
                
                if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs' && (objLead.HSC_status__c == 'Appeared' || objLead.HSC_status__c == 'Pending')){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='11th Marksheet';
                    objDoc.nm_DocumentName__c='11th Marksheet';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);  
                }
                
                if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs' && objLead.Diploma_status__c == 'Appeared'){
                    nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                    objDoc.name ='Diploma 1st year Marksheet';
                    objDoc.nm_DocumentName__c='Diploma 1st year Marksheet';
                    objDoc.Lead__c = objLead.id;  
                    lstDocuments.add(objDoc);  

                    nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                    objDoct.name ='Diploma 2nd year Marksheet';
                    objDoct.nm_DocumentName__c='Diploma 2nd year Marksheet';
                    objDoct.Lead__c = objLead.id;  
                    lstDocuments.add(objDoct);  
                }
            }
            
            //Inserting document list
            if(lstDocuments.size() > 0)
                insert lstDocuments;
        }
    }
    
     //transfer document submitted at Lead level to Account Level 
    public void TransferDocumentFromLeadToAccount (list<Account> lstAccount)
    {
        List<nm_LinksForDocuments__c> newAccountDocumentsToInsert = new List<nm_LinksForDocuments__c>();
        // for old records where aadhaar card not present and also criteria not change then do not delete aadhaar card created by CreateDocumentRecordsOnAccount() method
        boolean AadhaarCardAddedInDocumentList = false;
        //map to store account id against lead id
        map<string,id> mapLeadAccountId = new map<string,id>();
        for (Account objAccount : lstAccount)
        {
            if(objAccount.nm_LeadId__c != null && objAccount.nm_LeadId__c != ''){
             //   Id LeadId = objAccount.nm_LeadId__c;
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }
        System.debug('KeySet-----'+mapLeadAccountId.keyset());
        //Query to get data of recently converted lead
        list<nm_LinksForDocumentsLead__c> lstLinksForDocumentsLead = ([select id, Lead_Id__c,nm_ReasonforDisapprove__c,Work_Experience__c, nm_URLforDocuments__c,nm_DocumentName__c, nm_Account__c ,nm_Status__c from nm_LinksForDocumentsLead__c
                                                        where Lead__c in: mapLeadAccountId.keyset()]); 
                                                        
        
        Set<Id> accountsToDeleteDocs = new Set<Id>();     
        Set<String> documentinserted = new Set<String>();     
        
        System.debug('lstLinksForDocumentsLead '+lstLinksForDocumentsLead);
        if(lstLinksForDocumentsLead != null)
        {
            for(nm_LinksForDocumentsLead__c objDocLead : lstLinksForDocumentsLead)
            {
                Id LeadId = objDocLead.Lead_Id__c;
                Id AccountId = mapLeadAccountId.get(string.valueof(LeadId));
                //Those accounts existing documents should be deleted, which were created by CreateDocumentRecords() method called earlier
                accountsToDeleteDocs.add(AccountId);
                
                if(objDocLead.nm_DocumentName__c =='Aadhaar Card')
                {
                    AadhaarCardAddedInDocumentList = true;
                }
                System.debug('AccountId---'+AccountId);
                System.debug('LeadId-----'+LeadId);
                System.debug('objDocLead.Work_Experience__c-----'+objDocLead.Work_Experience__c);
                //Save Lead document in format of Account Document
                nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
                
                objDocument.Name = objDocLead.nm_DocumentName__c;
                objDocument.nm_DocumentName__c = objDocLead.nm_DocumentName__c;
                objDocument.nm_Account__c = AccountId;
                objDocument.nm_URLforDocuments__c= objDocLead.nm_URLforDocuments__c;
                objDocument.nm_Status__c=objDocLead.nm_Status__c;
                objDocument.nm_ReasonforDisapprove__c = objDocLead.nm_ReasonforDisapprove__c;
                if(objDocLead.Work_Experience__c != null) {
                    objDocument.Work_Experience__c = objDocLead.Work_Experience__c;
                }
                System.debug('objDocument.Work_Experience__c-----'+objDocument.Work_Experience__c);
                newAccountDocumentsToInsert.add(objDocument);
                //To link lead level documents to converted account
                objDocLead.nm_Account__c = AccountId;
                documentinserted.add(objDocument.Name);
            }
        }
        
        //Get documents to delete since we are adding them from Lead
        list<nm_LinksForDocuments__c> lstLinksForDocumentsAccount = new List<nm_LinksForDocuments__c>();
        // for old records where aadhaar card not present and also criteria not change then do not delete aadhaar card created by CreateDocumentRecordsOnAccount() method
        if(AadhaarCardAddedInDocumentList)
        {
            lstLinksForDocumentsAccount = ([select id,nm_Account__c ,nm_DocumentName__c ,Name from nm_LinksForDocuments__c
                                                        where nm_Account__c in: accountsToDeleteDocs and Name=:documentinserted]); 
        }else
        {
            lstLinksForDocumentsAccount = ([select id,nm_Account__c from nm_LinksForDocuments__c
                                                        where nm_Account__c in: accountsToDeleteDocs
                                                        and nm_DocumentName__c !='Aadhaar Card' and Name=:documentinserted]); 
        }
        
        if(lstLinksForDocumentsAccount != null && lstLinksForDocumentsAccount.size()> 0){
            delete lstLinksForDocumentsAccount;
        }
        
        if(newAccountDocumentsToInsert.size() > 0 ){
            insert newAccountDocumentsToInsert;
        }
        
        //To link lead level documents to converted account
        if(lstLinksForDocumentsLead.size() > 0 ){
            update lstLinksForDocumentsLead;
        }
        
            
        }
        
    // public void UpdateDocumentsOnAccountForChangeInEligibilityCriteria(List<Account> lstAccount,Id criteriaId,String AccountId,boolean flag)
    // {
    //     // set of existing Document
    //     Set<string>  existingDocs = new Set<String>(); 
    //     //Document list to insert  
    //     List<nm_LinksForDocuments__c> lstDocuments = new List<nm_LinksForDocuments__c>();
    //     //Document to delete
    //     List<nm_LinksForDocuments__c> lstDocumentsToDelete = new List<nm_LinksForDocuments__c>();
                
    //     if(lstAccount != null && lstAccount.size() > 0)
    //     {
    //         //fetch all document Already Inserted for current Account 
    //         List<nm_LinksForDocuments__c> oldDocuments = [Select id, nm_DocumentName__c, nm_Account__c, nm_AccountEmail__c, nm_DocumentLink__c, Documents_Submited_Date__c, nm_Lead__c, linkID__c, Links_For_Documents_Lead__c, nm_ReasonforDisapprove__c, Registration_No__c, Sample__c, nm_Status__c, nm_URLforDocuments__c from nm_LinksForDocuments__c where nm_Account__c =:AccountId ];
               
    //         if(oldDocuments != null && oldDocuments.size() > 0)
    //         {
    //             for(nm_LinksForDocuments__c oldDoc : oldDocuments)
    //             {
    //                 existingDocs.add(oldDoc.nm_DocumentName__c);
    //             }
    //         }
            
    //         //Calling method to get documents list against each criteria
    //         Map<string, set<string>> mapCriteriaDocuments = GetProgrameWiseDocumentsList();
    //         //Fetch Document according to new criteria
    //          Set<string>  documentsForNewCriteria = mapCriteriaDocuments.get(criteriaId);
    //         if(criteriaId !=null && flag)
    //         {
    //             if(mapCriteriaDocuments.get(criteriaId) != null)
    //             {  
    //                //Creating document records to insert.
    //                 for(string strDocumentName : documentsForNewCriteria)
    //                 {
    //                     if(existingDocs != null && existingDocs.contains(strDocumentName))
    //                     {
    //                       //Do not add new document if it is already in system, and use same so that its links are also same
    //                        continue;
    //                     }
    //                     nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
    //                     objDocument.name = strDocumentName;
    //                     objDocument.nm_DocumentName__c = strDocumentName;
    //                     objDocument.nm_Account__c = AccountId;
    //                     lstDocuments.add(objDocument);
    //                 }
    //             }
    //         }
            
    //         // loop to create Additional Required Document 
    //         for(Account objAcc :lstAccount)
    //         {
    //             if(!'Confirmed'.equalsIgnoreCase(objAcc.nm_StudentStatus__c))
    //             {
    //                 if(objAcc.nm_DefencePersonnel__c =='Yes')
    //                 {
    //                     documentsForNewCriteria.add('Defence Document');
    //                     if(!existingDocs.contains('Defence Document'))
    //                     {
    //                         nm_LinksForDocuments__c objDoc = new nm_LinksForDocuments__c();
    //                         objDoc.name ='Defence Document';
    //                         objDoc.nm_DocumentName__c='Defence Document';
    //                         objDoc.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoc);   
    //                     }       
    //                 }
                            
    //                 if(objAcc.nm_Relationship__c!=null && objAcc.nm_Relationship__c!='Self' && objAcc.nm_DefencePersonnel__c =='Yes')
    //                 {
    //                     documentsForNewCriteria.add('Relationship Document');
    //                     if(!existingDocs.contains('Relationship Document'))
    //                     {
    //                         nm_LinksForDocuments__c objDoct = new nm_LinksForDocuments__c();
    //                         objDoct.name ='Relationship Document';
    //                         objDoct.nm_DocumentName__c='Relationship Document';
    //                         objDoct.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoct);  
    //                     }        
    //                 }
                    
    //                 if(objAcc.Is_Lateral__c && !objAcc.nmStudent_Program__c.startsWith('A') )
    //                 {
    //                     documentsForNewCriteria.add('NMIMS Diploma Marksheet');
    //                     if(!existingDocs.contains('NMIMS Diploma Marksheet'))
    //                     {
    //                         nm_LinksForDocuments__c objDoct = new nm_LinksForDocuments__c();
    //                         objDoct.name ='NMIMS Diploma Marksheet';
    //                         objDoct.nm_DocumentName__c='NMIMS Diploma Marksheet';
    //                         objDoct.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoct);  
    //                     }        
    //                 }
                           
    //                 if(objAcc.Is_Lateral__c && !objAcc.nmStudent_Program__c.startsWith('A') )
    //                 {
    //                     documentsForNewCriteria.add('NMIMS Diploma Certificate');
    //                     if(!existingDocs.contains('NMIMS Diploma Certificate'))
    //                     {
    //                         nm_LinksForDocuments__c objDoct = new nm_LinksForDocuments__c();
    //                         objDoct.name ='NMIMS Diploma Certificate';
    //                         objDoct.nm_DocumentName__c='NMIMS Diploma Certificate';
    //                         objDoct.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoct);  
    //                     }        
    //                 }
                    
    //                 if(objAcc.Is_Lateral__c && objAcc.nmStudent_Program__c.startsWith('A') )
    //                 {
    //                     documentsForNewCriteria.add('NMIMS Certificate Program Completion Certificate');
    //                     if(!existingDocs.contains('NMIMS Certificate Program Completion Certificate'))
    //                     {
    //                         nm_LinksForDocuments__c objDoct = new nm_LinksForDocuments__c();
    //                         objDoct.name ='NMIMS Certificate Program Completion Certificate';
    //                         objDoct.nm_DocumentName__c='NMIMS Certificate Program Completion Certificate';
    //                         objDoct.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoct);  
    //                     }        
    //                 }
                    
    //                 if(objAcc.Is_Lateral__c && objAcc.nmStudent_Program__c.startsWith('A') )
    //                 {
    //                     documentsForNewCriteria.add('NMIMS Certificate Program Marksheet');
    //                     if(!existingDocs.contains('NMIMS Certificate Program Marksheet'))
    //                     {
    //                         nm_LinksForDocuments__c objDoct = new nm_LinksForDocuments__c();
    //                         objDoct.name ='NMIMS Certificate Program Marksheet';
    //                         objDoct.nm_DocumentName__c='NMIMS Certificate Program Marksheet';
    //                         objDoct.nm_Account__c = objAcc.id;  
    //                         lstDocuments.add(objDoct);  
    //                     }        
    //                 }
    //             }
    //         }
            
    //         // loop to delete non - required document from account
    //         //Fetch old criteria documents and delete those which are not to be there as per New Criteria
    //         if(oldDocuments.size() > 0 )
    //         {
    //             for(nm_LinksForDocuments__c oldDoc : oldDocuments)
    //             {
    //                 string strDocumentName = oldDoc.nm_DocumentName__c;
                    
    //                 if(!documentsForNewCriteria.contains(strDocumentName))
    //                 {
    //                    // allowed to Insert Additional Documents
    //                     if(strDocumentName !=null && strDocumentName !='' && !strDocumentName.contains('Additional') && ((oldDoc.nm_URLforDocuments__c =='' ||oldDoc.nm_URLforDocuments__c == null ) || oldDoc.nm_Status__c!='Approved'))
    //                     {
    //                         lstDocumentsToDelete.add(oldDoc);
    //                     }
    //                 }
    //             }
    //         }
            
    //         System.debug('---existingDocs---'+existingDocs+'----'+lstDocumentsToDelete+'----lstDocuments----'+lstDocuments);
    //         //Delete old document list which dont requried as per new criteria   
    //         if(lstDocumentsToDelete.size() > 0)
    //         {
    //             delete lstDocumentsToDelete;
    //         } 
            
    //         //Inserting document list
    //         if(lstDocuments.size() > 0)
    //         {
    //             insert lstDocuments;
    //             system.debug('lstDocuments.size() '+lstDocuments.size());
    //         }  
            
    //     }
    // }

    
    /**
    * @description 
    * to check any documents contains for document insertion purpose
    * @author shubhranshu | 1/7/2020 
    * @param set1 
    * @param set2 
    * @return List<String> 
    **/
    public List<String> checkContains(Set<String> set1 , Set<String> set2){
        List<String> remiansDocs = new List<String>();
        for(String str : set2){
            if(!set1.contains(str)){
               remiansDocs.add(str);
            }
        }
        return remiansDocs;
    }

    /**
    * @description 
    * to check if any documnets to delete for deletion purpose
    * @author shubhranshu | 1/7/2020 
    * @param set1 
    * @param lst 
    * @return List<nm_LinksForDocumentsLead__c> 
    **/
    public List<nm_LinksForDocumentsLead__c> checkDocToDelete(Set<String> set1 , List<nm_LinksForDocumentsLead__c> lst){
        List<nm_LinksForDocumentsLead__c> remiansDocsDelete = new List<nm_LinksForDocumentsLead__c>();
        for(nm_LinksForDocumentsLead__c str : lst){
           if(!set1.contains(str.nm_DocumentName__c) ){ 

                if((str.nm_DocumentName__c == 'Caste Certificate Document' || str.nm_DocumentName__c == 'Differently Abled Document') && str.nm_URLforDocuments__c != ''){

                }else{
                    remiansDocsDelete.add(str);
                }
                
            }
        }
        return remiansDocsDelete;
    }

    /**
    * @description 
    * to check eligiblity criteria and document insertion and deletion
    * @author shubhranshu | 1/7/2020 
    * @param mapCriteriaDocuments 
    * @param mapOfLeadIdvsLead 
    * @return Map<String, List<nm_LinksForDocumentsLead__c>> 
    **/
    public Map<String,List<nm_LinksForDocumentsLead__c>> UpdateDocumentsOnLeadForChangeInEligibilityCriteria(Map<string, set<string>> mapCriteriaDocuments,Map<Id,Lead> mapOfLeadIdvsLead)
    {
        // map of existing Document record
        Map<Id,List<nm_LinksForDocumentsLead__c>> mapOfexistingDocsRecord = new Map<Id, List<nm_LinksForDocumentsLead__c>>();
        // map of existing Documents
        Map<Id,Set<string>> mapOfexistingDocs = new Map<Id, Set<String>>(); 
        //map of Documents to insert and delete
        Map<String,List<nm_LinksForDocumentsLead__c>> mapofDocuments = new Map<String,List<nm_LinksForDocumentsLead__c>>();
        
        List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();
        // List<nm_LinksForDocumentsLead__c> lstDocumentsToDelete = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocumentsLead__c> docNeedToDelete = new List<nm_LinksForDocumentsLead__c>();
        Map<Id,Set<string>> documentsForNewCriteria = new Map<Id,Set<string>>();
        if(mapCriteriaDocuments !=null && mapOfLeadIdvsLead != null)
        {
            //fetch all document Already Inserted for current Lead 
            List<nm_LinksForDocumentsLead__c> oldDocuments = [Select id, nm_DocumentName__c, Lead__c,nm_Account__c,  nm_DocumentLink__c, Documents_Submited_Date__c,  linkID__c, nm_ReasonforDisapprove__c, Registration_No__c,nm_Status__c, nm_URLforDocuments__c from nm_LinksForDocumentsLead__c where Lead__c IN:mapOfLeadIdvsLead.keySet()];
                
            if(oldDocuments != null && oldDocuments.size() > 0)
            {
                for(nm_LinksForDocumentsLead__c oldDoc : oldDocuments)
                {
                    // For Document Name
                    set<String> setOfDocs = mapOfexistingDocs.containsKey(oldDoc.Lead__c) ? mapOfexistingDocs.get(oldDoc.Lead__c) : new set<String>();
                    setOfDocs.add(oldDoc.nm_DocumentName__c);
                    mapOfexistingDocs.put(oldDoc.Lead__c,setOfDocs);

                    // For Document Record
                    List<nm_LinksForDocumentsLead__c> setOfDocsRecord = mapOfexistingDocsRecord.containsKey(oldDoc.Lead__c) ? mapOfexistingDocsRecord.get(oldDoc.Lead__c) : new List<nm_LinksForDocumentsLead__c>();
                    setOfDocsRecord.add(oldDoc);
                    mapOfexistingDocsRecord.put(oldDoc.Lead__c,setOfDocsRecord);
                    
                }
            }
            
            //Fetch Document according to new criteria
            for(Lead objLead :mapOfLeadIdvsLead.values()){
                if(String.isNotBlank(objLead.nm_Category__c) && objLead.nm_Category__c != 'General' && PickListHelper.getPickListValuesForLeadCategory().contains(objLead.nm_Category__c))
                {
                    mapCriteriaDocuments.get(objLead.nm_EligiblityCriteria__c).add('Caste Certificate Document');
                }
                if(objLead.Differently_abled__c == 'Yes')
                {
                    mapCriteriaDocuments.get(objLead.nm_EligiblityCriteria__c).add('Differently Abled Document');
                }
              
                if(String.isNotBlank(objLead.nm_EligiblityCriteria__c)){
                   documentsForNewCriteria.put(objLead.Id,mapCriteriaDocuments.get(objLead.nm_EligiblityCriteria__c));
                }      
            }

            if(documentsForNewCriteria != null){  
                //Creating document records to insert.
                for(string leadId : documentsForNewCriteria.keySet())
                {
                    Set<String> strDocumentName = documentsForNewCriteria.get(leadId) != null ? documentsForNewCriteria.get(leadId) : new Set<String>();
                    Set<String> existDocumentName = mapOfexistingDocs.get(leadId) != null ? mapOfexistingDocs.get(leadId) : new Set<String>();

                    // existing record to delete if it is not eligible for eligible criteria 
                    List<nm_LinksForDocumentsLead__c> existDocumentRecord = mapOfexistingDocsRecord.get(leadId) != null ? mapOfexistingDocsRecord.get(leadId) : new List<nm_LinksForDocumentsLead__c>();
                    //mapOfexistingDocs.get(leadId);

                    List<String> docNeedToInsert = checkContains(existDocumentName,strDocumentName);
                    if(docNeedToInsert.size() > 0){
                        List<nm_WorkExperience__c> lstWK=[SELECT Id, Name, nm_CompanyName__c FROM nm_WorkExperience__c WHERE nm_Lead__c=:leadId];  
                        for(String strDocName : docNeedToInsert){  
                            if(strDocName.contains('Work') && !lstWK.IsEmpty()) {
                                for(nm_WorkExperience__c wk:lstWK ){
                                    nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
                                    objDocument.name  = strDocName + '/' + wk.Name + '/' + (String.isNotBlank(wk.nm_CompanyName__c) ? wk.nm_CompanyName__c.left(25) : '');
                                    objDocument.Work_Experience__c = wk.Id;
                                    objDocument.nm_DocumentName__c=strDocName + '/' + wk.Name + '/' + (String.isNotBlank(wk.nm_CompanyName__c) ? wk.nm_CompanyName__c.left(125) : '');
                                    objDocument.Lead__c = leadId;
                                    lstDocuments.add(objDocument);
                                   }
                               } else {
                                nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
                                objDocument.name = strDocName;
                                objDocument.nm_DocumentName__c = strDocName;
                                objDocument.Lead__c = leadId;
                                lstDocuments.add(objDocument);
                            } 
                          
                        }
                    }

                    // for deleting the old docs which is not required
                    List<nm_LinksForDocumentsLead__c> docNeedToDeleteCheck = checkDocToDelete(strDocumentName,existDocumentRecord);
                    if(docNeedToDeleteCheck.size() > 0) {
                        docNeedToDelete.addAll(docNeedToDeleteCheck);
                    }
                }
            }
        }
        mapofDocuments.put('INSERT',lstDocuments);
        mapofDocuments.put('DELETE',docNeedToDelete);
        
        return mapofDocuments;
    }

    /**
    * @description 
    * to check flag check for e.g. lateral , defence etc.. and respective documents insertion and deletion
    * @author shubhranshu | 1/7/2020 
    * @param lstLead 
    * @param lstOfLeadIds 
    * @return Map<String, List<nm_LinksForDocumentsLead__c>> 
    **/
    public Map<String,List<nm_LinksForDocumentsLead__c>> UpdateDocumentsOnLeadForFlagChanges(List<Lead> lstLead,Set<Id> lstOfLeadIds){

        // map of existing Documents
        Map<Id,Set<string>>  mapOfexistingDocs = new Map<Id,Set<String>>(); 
        // map of documents to insert and delete
        Map<String,List<nm_LinksForDocumentsLead__c>> mapofDocuments = new Map<String,List<nm_LinksForDocumentsLead__c>>();
        //Document list to insert  
        List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();
        //Document to delete
        List<nm_LinksForDocumentsLead__c> lstDocumentsToDelete = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocumentsLead__c> oldDocuments = new  List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocumentsLead__c> docNeedToDelete = new List<nm_LinksForDocumentsLead__c>();
        set<String> setOfLeadids = new Set<String>();
        Map<Id,string> documentsForNewCriteria = new Map<Id,string>();
        if(lstLead != null && lstLead.size() > 0)
        {   
            //fetch all document Already Inserted for current Lead 
            oldDocuments = [Select id, nm_DocumentName__c, Lead__c,nm_Account__c,  nm_DocumentLink__c, Documents_Submited_Date__c,  linkID__c, nm_ReasonforDisapprove__c, Registration_No__c,nm_Status__c, nm_URLforDocuments__c from nm_LinksForDocumentsLead__c where Lead__c =:lstOfLeadIds];
            if(oldDocuments.size() > 0){
                for(nm_LinksForDocumentsLead__c oldDoc : oldDocuments)
                {   
                    set<String> setOfDocs = mapOfexistingDocs.containsKey(oldDoc.Lead__c) ? mapOfexistingDocs.get(oldDoc.Lead__c) : new set<String>();
                    setOfDocs.add(oldDoc.nm_DocumentName__c);
                    mapOfexistingDocs.put(oldDoc.Lead__c,setOfDocs);
                }
            }
            
            // loop to create Additional Required Document
            for(Lead objLead :lstLead)
            {    
                Set<String> existingDocs = mapOfexistingDocs.containsKey(objLead.Id) ? mapOfexistingDocs.get(objLead.Id) : new set<String>();
                
                // defence check
                if(objLead.Are_you_from_Defence__c  =='Yes')
                {
                    documentsForNewCriteria.put(objLead.Id,'Defence Document');
                    if(!existingDocs.contains('Defence Document'))
                    {
                        nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                        objDoc.name ='Defence Document';
                        objDoc.nm_DocumentName__c='Defence Document';
                        objDoc.Lead__c = objLead.id;  
                        lstDocuments.add(objDoc);   
                    }       
                }
                if(objLead.Differently_abled__c  =='Yes')
                {
                    documentsForNewCriteria.put(objLead.Id,'Differently Abled Document');
                    if(!existingDocs.contains('Differently Abled Document'))
                    {
                        nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                        objDoc.name ='Differently Abled Document';
                        objDoc.nm_DocumentName__c='Differently Abled Document';
                        objDoc.Lead__c = objLead.id;  
                        lstDocuments.add(objDoc);   
                    }       
                }
                if(String.isNotBlank(objLead.nm_Category__c) && objLead.nm_Category__c != 'General' && PickListHelper.getPickListValuesForLeadCategory().contains(objLead.nm_Category__c))
                {
                    documentsForNewCriteria.put(objLead.Id,'Caste Certificate Document');
                    if(!existingDocs.contains('Caste Certificate Document'))
                    {
                        nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                        objDoc.name ='Caste Certificate Document';
                        objDoc.nm_DocumentName__c='Caste Certificate Document';
                        objDoc.Lead__c = objLead.id;  
                        lstDocuments.add(objDoc);   
                    }       
                }
                
                        
                if(objLead.Relationship__c !=null && objLead.Relationship__c !='Self' && objLead.Are_you_from_Defence__c =='Yes')
                {
                    documentsForNewCriteria.put(objLead.Id,'Relationship Document');
                    if(!existingDocs.contains('Relationship Document'))
                    {
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='Relationship Document';
                        objDoct.nm_DocumentName__c='Relationship Document';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }        
                }
                // lateral check 
                if(objLead.Is_Lateral__c){
                    documentsForNewCriteria.put(objLead.Id,'NMIMS Diploma Certificate');
                    if(!existingDocs.contains('NMIMS Diploma Certificate')){
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='NMIMS Diploma Certificate';
                        objDoct.nm_DocumentName__c='NMIMS Diploma Certificate';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }        
                    
                    documentsForNewCriteria.put(objLead.Id,'NMIMS Diploma Marksheet');
                    if(!existingDocs.contains('NMIMS Diploma Marksheet')){
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='NMIMS Diploma Marksheet';
                        objDoct.nm_DocumentName__c='NMIMS Diploma Marksheet';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }        
                }

                if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs' && (objLead.HSC_status__c == 'Appeared' || objLead.HSC_status__c == 'Pending')){
                    documentsForNewCriteria.put(objLead.Id,'11th Marksheet');
                    if(!existingDocs.contains('11th Marksheet')){
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='11th Marksheet';
                        objDoct.nm_DocumentName__c='11th Marksheet';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }        
                }
                
                if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs' && objLead.Diploma_status__c == 'Appeared'){
                    documentsForNewCriteria.put(objLead.Id,'Diploma 1st year Marksheet');
                    if(!existingDocs.contains('Diploma 1st year Marksheet')){
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='Diploma 1st year Marksheet';
                        objDoct.nm_DocumentName__c='Diploma 1st year Marksheet';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }
                    
                    documentsForNewCriteria.put(objLead.Id,'Diploma 2nd year Marksheet');
                    if(!existingDocs.contains('Diploma 2nd year Marksheet')){
                        nm_LinksForDocumentsLead__c objDoct = new nm_LinksForDocumentsLead__c();
                        objDoct.name ='Diploma 2nd year Marksheet';
                        objDoct.nm_DocumentName__c='Diploma 2nd year Marksheet';
                        objDoct.Lead__c = objLead.id;  
                        lstDocuments.add(objDoct);  
                    }
                }

                // not in used for as of now comment on 01/07/2020

                // if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c !=null && objLead.nm_ProgramName__c.StartsWith('A')){
                //     documentsForNewCriteria.put(objLead.Id,'NMIMS Certificate Program Completion Certificate');
                //     if(!existingDocs.contains('NMIMS Certificate Program Completion Certificate'))
                //     {
                //             nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //             objDoc.name = 'NMIMS Certificate Program Completion Certificate';
                //             objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Completion Certificate';
                //             objDoc.Lead__c = objLead.id;  
                //             lstDocuments.add(objDoc);
                //     } 
                // }
                
                // if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c !=null && objLead.nm_ProgramName__c.StartsWith('A')){
                //     documentsForNewCriteria.put(objLead.Id,'NMIMS Certificate Program Marksheet');
                //     if(!existingDocs.contains('NMIMS Certificate Program Marksheet'))
                //     {
                //             nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                //             objDoc.name = 'NMIMS Certificate Program Marksheet';
                //             objDoc.nm_DocumentName__c = 'NMIMS Certificate Program Marksheet';
                //             objDoc.Lead__c = objLead.id;  
                //             lstDocuments.add(objDoc);
                //     } 
                // }
            }
        }
            // loop to delete non - required document from Lead
            //Fetch old criteria documents and delete those which are not to be there as per New Criteria
            if(oldDocuments.size() > 0 )
            {   
                Boolean DefenseNotOpted = false;
                Boolean lateralNotOpted = false;
                Boolean hscAppearedNotOpted = false;
                Boolean differentlyAbled = false;
                Boolean castCertificate = false;
                
                string strDocumentName = '';
                for(Lead objLead :lstLead){
                    if(objLead.Are_you_from_Defence__c  =='No'){
                        DefenseNotOpted = true;
                    }
                    if(objLead.Differently_abled__c  =='No'){
                        differentlyAbled = true;
                    }
                    if(objLead.nm_Category__c  =='General'){
                        castCertificate = true;
                    }
                    
                    if(!objLead.Is_Lateral__c){
                        lateralNotOpted = true;
                    }

                    if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs' && objLead.HSC_status__c == 'Passed'){
                        hscAppearedNotOpted = true;
                    }
                }
                for(nm_LinksForDocumentsLead__c oldDoc : oldDocuments){
                    string DocumentName = oldDoc.nm_DocumentName__c;
                    List<String> documentsWithNewCriteria = new List<String>();
                    documentsWithNewCriteria = documentsForNewCriteria.values();
                    if(!documentsWithNewCriteria.contains(DocumentName))
                    {   
                        if(String.isNotBlank(DocumentName) && (DocumentName =='Defence Document' || DocumentName =='Relationship Document') && DefenseNotOpted){
                            lstDocumentsToDelete.add(oldDoc);
                        }
                        if(String.isNotBlank(DocumentName) && DocumentName == 'Caste Certificate Document' && castCertificate && oldDoc.nm_URLforDocuments__c == null){
                            lstDocumentsToDelete.add(oldDoc);
                        }
                        if(String.isNotBlank(DocumentName) && (DocumentName =='NMIMS Diploma Marksheet' || DocumentName =='NMIMS Diploma Certificate' || DocumentName =='NMIMS Certificate Program Completion Certificate' || DocumentName =='NMIMS Certificate Program Marksheet') && lateralNotOpted){                           
                            lstDocumentsToDelete.add(oldDoc);
                        }
                        if(String.isNotBlank(DocumentName) && DocumentName =='11th Marksheet' && hscAppearedNotOpted){                           
                            lstDocumentsToDelete.add(oldDoc);
                        }
                        
                    }
                }
            }
            //Delete old document list which dont requried as per new criteria   
            if(lstDocumentsToDelete.size() > 0)
            {
               docNeedToDelete.addAll(lstDocumentsToDelete);
               System.debug('docNeedToDelete '+docNeedToDelete);
            } 
        mapofDocuments.put('INSERT',lstDocuments);
        mapofDocuments.put('DELETE',docNeedToDelete);
        
        return mapofDocuments;
    }

    /**
    * @description 
    * documents insertion method after update
    * @author shubhranshu | 1/7/2020 
    * @param lstDocuments 
    * @return void 
    **/
    public void insertDocumentsAfterUpdate(List<nm_LinksForDocumentsLead__c> lstDocuments){
        
        //Inserting document list
        if(lstDocuments.size() > 0)
        {   
            try{
                insert lstDocuments;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }  
    }

    /**
    * @description 
    * documents deletion method after update
    * @author shubhranshu | 1/7/2020 
    * @param docNeedToDelete 
    * @return void 
    **/
    public void documentNeedToDelete(List<nm_LinksForDocumentsLead__c> docNeedToDelete){
        if(docNeedToDelete.size() > 0){
            try{
                Set<String> checkForDuplicate = new Set<String>();
                List<nm_LinksForDocumentsLead__c> lstDocNeedToDelete = new List<nm_LinksForDocumentsLead__c>();
                for(nm_LinksForDocumentsLead__c  objDoc : docNeedToDelete) {
                    if(!checkForDuplicate.contains(objDoc.Id)) {
                        checkForDuplicate.add(objDoc.Id);
                        lstDocNeedToDelete.add(objDoc);
                    } 
                }
                delete lstDocNeedToDelete;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }

    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }
    
    // public void UpdateDocumentSubmittedStatusOnAccount(List<Account> lstAccount)
    // {
    //     // create set Of Mandatory Document for new Eligiblity Criteria
    //     Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>{'Photo ID proof','Student Photograph'};
    //     set<String> setOfAllDocumentSubmitted = new set<String>(); // set for checking any document disapproved then update student status to Disapproved even if Mandatory document submitted to Approved
    //     set<String> setOfAccountId = new set<String>();
    //     // Document Name vs Document Link Map
    //     Map<String,String> documentLink = new Map<String,String>();
    //     // Document Name vs Document Status Map
    //     Map<String,String> documentStatus = new Map<String,String>();
    //     List<Account> lstAccountToUpdate = new List<Account>();
    //     List<Account> listUpdateDcoumentSubmittedDate = new List<Account>();
    //     String criteriaId ;
    //     Integer TotalManadatoryDoc;
    //     Integer TotalApprovedDoc;
    //     Boolean ValidApproved;
    //     //To itearte Provisional Reason on Account Provisional Reason 
    //     String ProvisionalReason = '';

    //     for(Account objAccount : lstAccount)
    //     {
    //         setOfAccountId.add(objAccount.id);
    //         criteriaId = objAccount.nm_EligiblityCriteria__c;
    //         // put mandatory Document According to Criteria 
    //         if(lstAccount.size()>0 && criteriaId != null)
    //         {          
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('Bachelor')  || objAccount.Eligibility_Criteria_Ref__c.contains('Graduation'))
    //         {
    //            mandatoryDocumentForCurrentCriteria.add('Degree Mark Sheet');
    //         }
             
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('HSC'))
    //         {
    //            mandatoryDocumentForCurrentCriteria.add('12th Mark Sheet');
    //         }
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('SSC'))
    //         {
    //            mandatoryDocumentForCurrentCriteria.add('10th Mark Sheet');
    //         }
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('Diploma'))
    //         {
    //            mandatoryDocumentForCurrentCriteria.add('Diploma Mark Sheet');
    //         }
    //         if(objAccount.Eligibility_Criteria_Ref__c.contains('Work') && !objAccount.Eligibility_Criteria_Ref__c.contains('preferably') )
    //         {                            
    //                 /*if( objAccount.Eligibility_Criteria_Ref__c.contains('preferably') && objAccount.Work_exp_Score__c>0 && objAccount.Work_exp_Score__c!=null)
    //                 {*/
    //                   if(objAccount.Eligibility_Criteria_Ref__c.contains('1') )
    //                   {
    //                       mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
    //                   }
                      
    //                   else if(objAccount.Eligibility_Criteria_Ref__c.contains('2'))
    //                   {
    //                      mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
    //                   }
    //                   else if(objAccount.Eligibility_Criteria_Ref__c.contains('3'))
    //                   {
    //                      mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
    //                   }
                         
    //                 /*}   
    //             else if(!objAccount.Eligibility_Criteria_Ref__c.contains('preferably')){
                
    //                    mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate - 2 years');
    //                }*/
              
    //         }   
    //        if(objAccount.Eligibility_Criteria_Ref__c.contains('Professional'))
    //         {
    //            mandatoryDocumentForCurrentCriteria.add('Additional Qualification Certificates');
    //         }           
    //         if(objAccount.nm_DefencePersonnel__c =='Yes')
    //         {
    //             mandatoryDocumentForCurrentCriteria.add('Defence Document');
    //         }
    //         if(objAccount.Is_Lateral__c && !objAccount.nmStudent_Program__c.startswith('Advance'))
    //         {
    //             mandatoryDocumentForCurrentCriteria.add('NMIMS Diploma Marksheet');
    //         }
    //          if(objAccount.Is_Lateral__c && objAccount.nmStudent_Program__c.startswith('Advance'))
    //         {
    //             mandatoryDocumentForCurrentCriteria.add('NMIMS Certificate Program Marksheet');
    //         }
            
    //         if(objAccount.nm_Relationship__c !='Self' && objAccount.nm_DefencePersonnel__c =='Yes')
    //         {
    //             mandatoryDocumentForCurrentCriteria.add('Relationship Document');
    //         }
    //       }
    //     }
    //     TotalManadatoryDoc = mandatoryDocumentForCurrentCriteria.size();
    //     System.debug('set Of Mandatory Document ---->'+mandatoryDocumentForCurrentCriteria);
    //     System.debug('Size Of Mandatory Document ---->'+mandatoryDocumentForCurrentCriteria.size());
    //     //fetch all document Already Inserted for current Account 
    //     List<nm_LinksForDocuments__c> lstDocuments = [Select id, nm_DocumentName__c, nm_Account__c, nm_AccountEmail__c,
    //     nm_DocumentLink__c, Documents_Submited_Date__c, nm_Lead__c, linkID__c, Links_For_Documents_Lead__c,
    //     nm_ReasonforDisapprove__c, Registration_No__c, Sample__c, nm_Status__c, nm_URLforDocuments__c from nm_LinksForDocuments__c where nm_Account__c In : setOfAccountId];
    //     Set<String> setOfDisapprovedDocuments = new Set<String>();
    //     Set<String> setOfProvisionalDocuments = new Set<String>();
    //     Set<String> setOfApprovedDocuments = new Set<String>();
    //     Set<String> setOfIncorrectDocuments = new Set<String>();
    //     Set<String> setOfReSubmittedDocuments = new Set<String>();
    //     Set<String> setofInvalidDocument = new Set<String>();
    //     Set<String> setofProvinalforNonMandatory =new Set<String>();
       
    //     if(lstDocuments != null && lstDocuments.size() > 0)
    //     {
      
    //     system.debug('lstDocuments--->'+lstDocuments);
    //         for(nm_LinksForDocuments__c objDoc : lstDocuments)
    //         {   
    //               documentLink.put(criteriaId+'-'+objDoc.nm_DocumentName__c,objDoc.nm_URLforDocuments__c);
    //             documentStatus.put(criteriaId+'-'+objDoc.nm_DocumentName__c,objDoc.nm_Status__c);
                
    //              System.debug('objDoc.nm_DocumentName__c ---->'+objDoc.nm_DocumentName__c);
    //             System.debug('objDoc.nm_URLforDocuments__c ---->'+objDoc.nm_URLforDocuments__c);
    //             System.debug('objDoc.nm_Status__c ---->'+objDoc.nm_Status__c);
                
    //             if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c) )
    //             {
    //                 setofProvinalforNonMandatory.add(objDoc.nm_DocumentName__c);                    
    //             }
    //             if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c) && objDoc.nm_ReasonforDisapprove__c != null){
    //                     ProvisionalReason += objDoc.nm_ReasonforDisapprove__c + '\n';
    //                 }
    //             if('Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c) && String.IsBlank(objDoc.nm_URLforDocuments__c) )
    //             {
    //                 setOfIncorrectDocuments.add(objDoc.nm_DocumentName__c);                    
    //             }
    //             if('Disapproved'.equalsIgnoreCase(objDoc.nm_Status__c) || 'Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c))
    //             {
    //                 setofInvalidDocument.add(objDoc.nm_DocumentName__c);
    //             }
    //             if('Disapproved'.equalsIgnoreCase(objDoc.nm_Status__c)){
    //                     setOfDisapprovedDocuments.add(objDoc.nm_DocumentName__c);
    //             }  
    //            if('Re-Submited'.equalsIgnoreCase(objDoc.nm_Status__c)  && !String.IsBlank(objDoc.nm_URLforDocuments__c)){
    //                     setOfReSubmittedDocuments.add(objDoc.nm_DocumentName__c);
    //             }
    //             if(mandatoryDocumentForCurrentCriteria.contains(objDoc.nm_DocumentName__c) && objDoc.nm_Status__c !=null && objDoc.nm_Status__c !='--None--'){
    //                 if('Admission Form & Documents Provisional'.equalsIgnoreCase(objDoc.nm_Status__c.trim()) ){
    //                     setOfProvisionalDocuments.add(objDoc.nm_DocumentName__c);
    //                 }else if('Approved'.equalsIgnoreCase(objDoc.nm_Status__c.trim())){
    //                     setOfApprovedDocuments.add(objDoc.nm_DocumentName__c);
    //                 }else if('Re-Submited'.equalsIgnoreCase(objDoc.nm_Status__c.trim())){
    //                     setOfReSubmittedDocuments.add(objDoc.nm_DocumentName__c);
    //                 }else if('Documents incorrect'.equalsIgnoreCase(objDoc.nm_Status__c.trim()) && !String.IsBlank(objDoc.nm_URLforDocuments__c)){
    //                     setOfReSubmittedDocuments.add(objDoc.nm_DocumentName__c);
                        
    //                 }
    //             }
    //             if(!IsNullOrEmpty(objDoc.nm_URLforDocuments__c))
    //             {
    //                 setOfAllDocumentSubmitted.add(objDoc.nm_DocumentName__c);         
    //             }
    //         }
    //     }
        
    //     boolean IsvalidDocuments = ValidateDocumentsEligibilityCriteriaWise(criteriaId ,documentLink,documentStatus,mandatoryDocumentForCurrentCriteria,setOfAllDocumentSubmitted);
        
    //     // put all non confirmed Account into Map and According to Document update Account Status 
    //     map<id,Account> objAccountChk = new map<id,Account> ([Select id,nm_StudentNo__c,nm_StudentStatus__c from Account where id in: setOfAccountId and (nm_StudentNo__c = null or nm_StudentNo__c = '') 
    //                                                          and nm_StudentStatus__c != 'Confirmed' and (Not nm_StudentStatus__c Like '%Cancel%')
    //                                                          and (Not nm_StudentStatus__c Like '%Closed%')]);
        
    //        // system.debug('nm_StudentStatus__c-->'+objAccountChk.nm_StudentStatus__c);   
    //     for(Account objAccount : lstAccount)
    //     {   

    //         if(objAccountChk.get(objAccount.id) !=null)
    //         {  System.debug('nm_StudentStatus__c '+objAccountChk.get(objAccount.id).nm_StudentStatus__c);
    //            Account objAccountToUpdate = new Account(id=objAccount.id);
    //            System.debug('IsvalidDocuments---->'+IsvalidDocuments);
    //            System.debug('objAccountToUpdate.nm_StudentStatus__c-->'+objAccount.nm_StudentStatus__c);
    //            System.debug('setOfDisapprovedDocuments--'+setOfDisapprovedDocuments.size());
    //            System.debug('setOfIncorrectDocuments--'+setOfIncorrectDocuments.size());
    //            System.debug('setOfReSubmittedDocuments--'+setOfReSubmittedDocuments.size());
    //            System.debug('setOfProvisionalDocuments--'+setOfProvisionalDocuments.size());
    //            System.debug('setOfApprovedDocuments--'+setOfApprovedDocuments.size());
    //            System.debug('setofProvinalforNonMandatory--'+setofProvinalforNonMandatory.size());
               
    //            Boolean chckFlagfForStudStatus = false;
    //            String StudStatus = objAccountChk.get(objAccount.id).nm_StudentStatus__c;
    //            if('Admission Form & Documents Provisional'.equalsIgnoreCase(StudStatus) || 'Admission form & documents Approved'.equalsIgnoreCase(StudStatus) ) {
    //                chckFlagfForStudStatus = true;
    //            }
    //            TotalApprovedDoc = setOfProvisionalDocuments.size()+ setOfApprovedDocuments.size();
    //            System.debug('TotalApprovedDoc---->'+TotalApprovedDoc);
    //            System.debug('TotalManadatoryDoc---->'+TotalManadatoryDoc);
               
    //            if(TotalApprovedDoc == TotalManadatoryDoc)
    //            {
    //               ValidApproved =true;
    //            }
    //            else
    //            {
    //               ValidApproved=false;
    //            }
    //            system.debug('ValidApproved-->'+ValidApproved);
    //            //Single Document dissapproved the status
    //            if(setOfDisapprovedDocuments.size() > 0){
    //                objAccountToUpdate.nm_StudentStatus__c = 'Documents Disapproved';                  
    //            }else if(setOfIncorrectDocuments.size() > 0 && chckFlagfForStudStatus == false){
    //                objAccountToUpdate.nm_StudentStatus__c = 'Registered';                 
    //            }else if((setOfProvisionalDocuments.size() > 0 || setofProvinalforNonMandatory.size()>0)  && setOfReSubmittedDocuments.size() == 0 && ValidApproved && setOfIncorrectDocuments.size()==0 && setofInvalidDocument.size()==0){
    //                objAccountToUpdate.nm_StudentStatus__c = 'Admission Form & Documents Provisional';  
    //                 if(!IsNullOrEmpty(ProvisionalReason))
    //                    {
    //                        objAccountToUpdate.nm_ReasonforProvisionalNoAdmission__c = ProvisionalReason;
    //                    }                   
    //                objAccountToUpdate.nm_IsProvisonal__c=true;                 
    //            }else if(setOfApprovedDocuments.size()>0 && ValidApproved && setOfDisapprovedDocuments.size()==0 && setofProvinalforNonMandatory.size()==0 && setOfIncorrectDocuments.size()==0 && setOfReSubmittedDocuments.size()== 0 && setofInvalidDocument.size()==0 ){
    //                objAccountToUpdate.nm_StudentStatus__c = 'Admission form & documents Approved';               
    //            }else if((IsvalidDocuments && setOfReSubmittedDocuments.size() >0) || IsvalidDocuments){
    //                objAccountToUpdate.nm_StudentStatus__c = 'Admission form & documents submitted';                   
    //            }else if(objAccount.nm_StudentStatus__c !='Documents Disapproved' && chckFlagfForStudStatus == false){ // added condition in order to allowed to update Account Status to Disapproved
    //                objAccountToUpdate.nm_StudentStatus__c = 'Registered';               
    //             }
    //             lstAccountToUpdate.add(objAccountToUpdate);
            
    //             System.debug('Student Status to Update---->'+objAccountToUpdate.nm_StudentStatus__c);  
    //         }
    //     }               
        
    //     //update Document Status on Account
    //     if(lstAccountToUpdate.size()>0)
    //     {
    //         update lstAccountToUpdate;
    //     }
    // }
   /* public boolean WorkexDetailcheck(Account objAccount)
    {
        if(!IsNullOrEmpty(objAccount.Industry) && !IsNullOrEmpty(objAccount.nm_WorkExperience__c) &&  !IsNullOrEmpty(objAccount.nm_Company_Name__c))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
   
    public boolean GraduationCheck(Account objAccount)

{
    if(!IsNullOrEmpty(objAccount.Name_of_Program1__c) && !IsNullOrEmpty(objAccount.Name_of_University1__c) &&  !IsNullOrEmpty(objAccount.Percentage1__c))
    {
        return true;
    }
    else
    {
        return false;
    }
}*/
    /*public boolean ValidateDocumentsEligibilityCriteriaWise(String criteriaId,Map<String,String> documentLink,Map<String,String> documentStatus ,set<String> mandatoryDocumentForCurrentCriteria, Set<String> setOfAllDocumentSubmitted)
    {
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
    } */
    /*
     public void UpdateDocumentSubmittedStatusOnLead(set<string> SetLeadId)
    {
      string ElegibilityCriteriaId;
      list<nm_LinksForDocumentsLead__c>  LstDocumentLead =new list<nm_LinksForDocumentsLead__c>();
      set<id> SetOfLeadId =new set<id>();
      map<string,string> DocumentStatus =new map<string,string>();
      map<string,string> DocumentLink = new map<string,string>();
      set<string> SubmittedDocument = new set<string> ();
      list<Lead> lstLeadUpdate =new list<Lead>();
      list<Lead> lstLead = new list<Lead>();
      set<string> SetofMandataryDocumentforEligibilityCriteria =new set<string>{'Photo ID proof','Student Photograph','Aadhaar Card'};
      lstLead =[select id,nm_ProgramName__c,nm_StudentStatus__c,nm_EligiblityCriteria__c,nm_Eligibility_Criteria_Ref__c,Are_you_from_Defence__c,Is_Lateral__c,Relationship__c from Lead where id in :SetLeadId];
      for(Lead objLead :lstLead)
            {
               ElegibilityCriteriaId = objLead.nm_EligiblityCriteria__c;
           SetOfLeadId.add(objLead.id);
           if(lstLead.size()>0 && ElegibilityCriteriaId!=null )
           {
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('Bachelor'))
              {
                  SetofMandataryDocumentforEligibilityCriteria.add('Degree Mark Sheet');
              }
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('Certificate'))
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('Certificate Mark Sheet');
              }
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('HSC'))
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('12th Mark Sheet'); 
              }
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('SSC'))
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('10th Mark Sheet');
              }
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('Diploma'))
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('Diploma Mark Sheet');
              }
              if(objLead.nm_Eligibility_Criteria_Ref__c.Contains('Work'))
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('Work Experience Certificate – 2 years');
              }
              if(objLead.Are_you_from_Defence__c=='Yes')
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('Defence Document');
              }
              if(objLead.Is_Lateral__c && !objLead.nm_ProgramName__c .startswith('Advance') )
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('NMIMS Diploma Marksheet'); 
              }
              if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c .startswith('Advance'))
              {
                    SetofMandataryDocumentforEligibilityCriteria.add('NMIMS Certificate Program Marksheet');
              }
              if(objLead.Relationship__c!='self' && objLead.Are_you_from_Defence__c=='Yes')
              {
                 SetofMandataryDocumentforEligibilityCriteria.add('Relationship Document');
              }
           }
        }
        
         LstDocumentLead=[select id,nm_ReasonforDisapprove__c,nm_URLforDocuments__c,nm_Status__c,Lead__c,nm_DocumentName__c from nm_LinksForDocumentsLead__c where Lead__c in:SetOfLeadId];
         
         if(LstDocumentLead.size()>0)
         {
             for(nm_LinksForDocumentsLead__c objDocLead : LstDocumentLead)
             {
                DocumentStatus.put(ElegibilityCriteriaId+'-'+objDocLead.nm_DocumentName__c,objDocLead.nm_Status__c);  
                DocumentLink.put(ElegibilityCriteriaId+'-'+objDocLead.nm_DocumentName__c,objDocLead.nm_URLforDocuments__c);
                
                if(objDocLead.nm_URLforDocuments__c!=null || objDocLead.nm_URLforDocuments__c!='' )
                {
                   SubmittedDocument.add(objDocLead.nm_DocumentName__c);   
                }
             }
          }
          
          Boolean CheckSubittedDocs = ValidateDocumentsEligibilityCriteriaWiseonLead(ElegibilityCriteriaId,DocumentStatus,DocumentLink,SubmittedDocument,SetofMandataryDocumentforEligibilityCriteria);
          system.debug('CheckSubittedDocs'+CheckSubittedDocs );
          map<id,Lead> MapOfbjLead = new map<id,Lead>([select id,nm_StudentStatus__c from Lead where id in :SetOfLeadId and (nm_StudentStatus__c!='Admission Form & Documents Provisional' and nm_StudentStatus__c != 'Admission form & documents Approved') ]);
          system.debug('MapOfbjLead'+MapOfbjLead );
          for(Lead objLead :lstLead)
          {
             
             if(MapOfbjLead.get(objLead.id)!=null)
             {
                Lead UpdateobjLead = new Lead(id=objLead.id);
                if(CheckSubittedDocs)
              {
                  UpdateobjLead.nm_StudentStatus__c='Admission form & documents submitted';
                  UpdateobjLead.nm_DocumentSubmittedDate__c=system.now();
                  lstLeadUpdate.add(UpdateobjLead);
              }
             
             }
          }
          if(lstLeadUpdate.size()>0)
          { 
             update lstLeadUpdate;
          }
          
    }*/
    
    public boolean ValidateDocumentsEligibilityCriteriaWiseonLead(string CriteriaId,map<string,string> DocumentStatus, map<string,string> DocumentLink, set<string> SubmittedDocument, set<string> SetofMandataryDocumentforEligibilityCriteria)
    {
       system.debug('enter ValidateDocumentsEligibilityCriteriaWiseonLead ');
       for(string DocName : SetofMandataryDocumentforEligibilityCriteria)
       {
           if(DocumentStatus.get(CriteriaId+'-'+DocName.trim()) == 'Disapproved')
           {
              system.debug('enter in Disapproved false');
                return false;
           }
           if(DocumentLink.get(CriteriaId+'-'+DocName.trim()) == null)
           {
              system.debug('enter in null loop');
                return false;
           }
       
       }
       
       for(string SumittedDoc :SetofMandataryDocumentforEligibilityCriteria)
       {
            if(DocumentStatus.get(CriteriaId+'-'+SumittedDoc)== 'Disapproved')
        { 
           system.debug('enter in DocumentStatus ');
           return false;
        }
       }
        
       return true;
    }
    
   //Class not in use logic transfer  
   /* public void UpdateDocumentStatusCountOnAccount(list<Account>lstAccount,Map<id,Account> oldMap)
    {
        for(Account objAccount :lstAccount)
        {  
            System.debug('Disapproved counter ---->'+objAccount.Number_Of_Times_Disapproved__c +'---'+' Current Account Status------->'+objAccount.nm_StudentStatus__c +'---'+'old Account Status------>'+oldMap.get(objAccount.id).nm_StudentStatus__c);
            if(objAccount.nm_StudentStatus__c =='Registered' && oldMap.get(objAccount.id).nm_StudentStatus__c !=objAccount.nm_StudentStatus__c)
            {
                if(objAccount.Number_Of_Times_Disapproved__c ==null)
                {
                    objAccount.Number_Of_Times_Disapproved__c = 0;
                }
                objAccount.Number_Of_Times_Disapproved__c +=1;
            }
            
            if(objAccount.nm_StudentStatus__c =='Admission form & documents Approved' && oldMap.get(objAccount.id).nm_StudentStatus__c !=objAccount.nm_StudentStatus__c && objAccount.Number_Of_Times_Disapproved__c ==1)
            {
                if(String.valueOf(objAccount.nm_DocumentSubmittedDate__c) !=null && String.valueOf(objAccount.nm_DocumentSubmittedDate__c) !='')
                {
                    // calculate Number of Days between Document Submission and Approved.
                    objAccount.Days_Between_Doc_Submission_Approved__c =String.valueOf(objAccount.nm_DocumentSubmittedDate__c.Date().daysBetween(System.now().Date()));
                }      
            }
            else if(objAccount.nm_StudentStatus__c =='Admission form & documents Approved' && objAccount.Number_Of_Times_Disapproved__c >1 && String.valueOf(objAccount.Re_DocumentSubmittedDate__c) !=null)
            {
                // calculate Number of Days between Document Submission and Approved.
                objAccount.Days_Between_Doc_Submission_Approved__c +=','+String.valueOf(Date.valueOf(objAccount.Re_DocumentSubmittedDate__c).daysBetween(System.now().Date()));  
            }
        }    
    }*/
}