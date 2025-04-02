public class WorkExperienceTriggerHandler {
    public void AfterInsert(list<nm_WorkExperience__c> triggerNew, map<id, nm_WorkExperience__c> triggerOldMap)
    {
        system.debug('After Insert ===> '); 
        // This method will Caluclate Total Months of Experience and update on Lead and Student
        CaluclateWorkExeperience(triggerNew, triggerOldMap);
        CreateDocument(triggerNew, triggerOldMap);
    }
    
    
    public void AfterUpdate(list<nm_WorkExperience__c> triggerNew,map<id, nm_WorkExperience__c> triggerOldMap)
    { 
        // This method will Caluclate Total Months of Experience and update on Lead and Student
       
            CaluclateWorkExeperience(triggerNew, triggerOldMap);
            updateCompanyName(triggerNew, triggerOldMap);
       
        }
        
    public void AfterDelete(list<nm_WorkExperience__c> triggerOld)
    { 
        system.debug('After Delete ===> '); 
        DeleteDocument(triggerOld);
    }
   public void CaluclateWorkExeperience(list<nm_WorkExperience__c> triggerNew,map<id, nm_WorkExperience__c> triggerOldMap)
  {
       set<id> stIds=new set<id>();
       set<id> setLeadIds=new set<id>();
       
        for(nm_WorkExperience__c obWorkExperience:triggerNew)
        {
          if(obWorkExperience.nm_Student__c !=null){
             stIds.add(obWorkExperience.nm_Student__c);
             
          }
          if(obWorkExperience.nm_Lead__c !=null){
             setLeadIds.add(obWorkExperience.nm_Lead__c);
          }
        }
        
        if(stIds.size()>0)
        {
              list<Account> lstAccount=new list<Account>();
            lstAccount=[select id,nm_No_of_Months__c,(select id,nm_TotalMonths__c from Work_Experience__r) from Account where id=:stIds];
              list<nm_WorkExperience__c> lstWorkExp=new list<nm_WorkExperience__c>();
              //lstWorkExp=[select id,nm_TotalMonths__c from nm_WorkExperience__c where nm_Student__c IN:stIds];
              if(lstAccount.size()>0)
              {                 
                for(Account objAccount:lstAccount)
                {
                  Decimal TotalMonths=0;
                   for(nm_WorkExperience__c objWE: objAccount.Work_Experience__r)
                  {
                    if(objWE.nm_TotalMonths__c !=null)
                    {
                      TotalMonths+=objWE.nm_TotalMonths__c;
                    }
                  }
                  
                  objAccount.nm_No_of_Months__c=TotalMonths;
                }
                update lstAccount;
              }
         }
         if(setLeadIds.size()>0)
         {
             list<Lead> lstLead=new list<Lead>();
             Decimal TotalExperience=0;
            lstLead=[select id,nm_Total_Months_of_WorkExperience__c,(select id,nm_TotalMonths__c from Work_Experience__r) from Lead where id=:setLeadIds];
              list<nm_WorkExperience__c> lstWorkExponLead=new list<nm_WorkExperience__c>();
              //lstWorkExponLead=[select id,nm_TotalMonths__c from nm_WorkExperience__c where nm_Lead__c IN:setLeadIds];
              system.debug('lstWorkExponLead'+lstWorkExponLead);
              if(lstLead.size()>0)
              { 
                for(Lead objLead:lstLead)
                {
                  for(nm_WorkExperience__c objWEp:objLead.Work_Experience__r)
                  {
                    system.debug('lstWorkExponLead f'+objWEp.nm_TotalMonths__c);
                    if(objWEp.nm_TotalMonths__c !=null){
                      TotalExperience+=objWEp.nm_TotalMonths__c;
                    }
                  }
                  objLead.nm_Total_Months_of_WorkExperience__c=TotalExperience;
                }
                update lstLead;
              }
              
                
            }
        }

       public void CreateDocument(list<nm_WorkExperience__c> lstWorkEx,map<id, nm_WorkExperience__c> triggerOldMap) {
           system.debug('CreateDocument Started ----> ');
           Set<String>  setOFLeads = new set<String>();
           Set<String>  setOFAccounts = new Set<String>();
           List<nm_LinksForDocumentsLead__c> lstDocumentsForLead = new List<nm_LinksForDocumentsLead__c>();
           List<nm_LinksForDocuments__c> lstDocumentsForAccount = new List<nm_LinksForDocuments__c>();
           List<nm_WorkExperience__c>  lstWorkExperience = new List<nm_WorkExperience__c>();
           Set<String> setOfDocIDAlreadyUsed = new Set<String>();
           set<String> programType = new Set<String>(new List<String>(System.Label.WorkExpMandatory.split(',')));
           if(lstWorkEx.size() > 0) {
               for (nm_WorkExperience__c objWork : lstWorkEx) {
                   if(programType.contains(objWork.Program_Type__c) && String.isNotBlank(objWork.Eligibility_Criteria__c) && objWork.Eligibility_Criteria__c.containsIgnoreCase('Work')) {
                        String wkName = '';
                        if(objWork.Eligibility_Criteria__c.contains('1') )
                        {
                            wkName = 'Work Experience Certificate – 1 years';
                            // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
                        }
                        else if(objWork.Eligibility_Criteria__c.contains('2'))
                        {
                            wkName = 'Work Experience Certificate – 2 years';
                            // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
                        }
                        else if(objWork.Eligibility_Criteria__c.contains('3'))
                        {
                            wkName = 'Work Experience Certificate – 3 years';
                            // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
                        }
                       if(objWork.nm_Student__c != null) {
                           List<nm_LinksForDocuments__c> lstDocForAccount = [SELECT Id, Name FROM nm_LinksForDocuments__c WHERE  nm_Account__c = :objWork.nm_Student__c  AND (NOT Name LIKE '%WE-%' ) AND  Name LIKE 'Work Experience Certificate%' AND Work_Experience__c = null LIMIT 1 ];
                           if(lstDocForAccount.size() > 0) {
                               for (nm_LinksForDocuments__c objAccDoc : lstDocForAccount) {
                                //    if(!setOfDocIDAlreadyUsed.contains(objAccDoc.Id)) {
                                //        setOfDocIDAlreadyUsed.add(objAccDoc.Id);
                                       nm_LinksForDocuments__c objDoc1 = new nm_LinksForDocuments__c();
                                    //    objDoc1.Id = objAccDoc.Id;
                                    //    objDoc1.Name = objAccDoc.Name + ' (' + objWork.Name + ')';
                                    //    objDoc1.Work_Experience__c = objWork.Id;
                                    //    objDoc1.nm_DocumentName__c=objDoc1.Name;
                                    objAccDoc.Name  = wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(25) : '');
                                    objAccDoc.Work_Experience__c = objWork.Id;
                                       objAccDoc.nm_DocumentName__c=wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(125) : '');
                                       system.debug('update objAccDoc----> ' + objAccDoc);
                                       update objAccDoc;
                                    //    lstDocumentsForAccount.add(objAccDoc);
                                //    }
                                }
                            } else {
                                nm_LinksForDocuments__c objDoc = new  nm_LinksForDocuments__c();
                                objDoc.Name = wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(25) : '');
                                objDoc.Work_Experience__c = objWork.Id;
                                objDoc.nm_DocumentName__c=wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(125) : '');
                                objDoc.nm_Account__c=objWork.nm_Student__c;
                                system.debug('insert objDoc----> ' + objDoc);
                                lstDocumentsForAccount.add(objDoc);
                            }
                        } 
                        if(objWork.nm_Lead__c != null) {
                            List<nm_LinksForDocumentsLead__c> lstDocForLead = [SELECT Id, Name FROM nm_LinksForDocumentsLead__c WHERE  Lead__c = :objWork.nm_Lead__c AND Name LIKE 'Work Experience Certificate%' AND (NOT Name LIKE '%WE-%' ) AND Work_Experience__c = null LIMIT 1 ];
                            if(lstDocForLead.size() > 0) {
                                for (nm_LinksForDocumentsLead__c objLdDoc : lstDocForLead) {
                                    // nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                                    // objDoc.Id = objLdDoc.Id;
                                    // objDoc.Name = objLdDoc.Name + ' (' + objWork.Name + ')';
                                    // objDoc.Work_Experience__c = objWork.Id;
                                    // objDoc.nm_DocumentName__c=objDoc.Name;
                                    objLdDoc.Name  = wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(25) : '');
                                    objLdDoc.Work_Experience__c = objWork.Id;
                                    objLdDoc.nm_DocumentName__c= wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(125) : '');
                                    system.debug('update objLdDoc----> ' + objLdDoc);
                                    // lstDocumentsForLead.add(objLdDoc);
                                    update objLdDoc;
                                }
                            } else {
                                nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
                                objDoc.Name = wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(25) : '');
                                objDoc.Work_Experience__c = objWork.Id;
                                objDoc.nm_DocumentName__c=wkName + '/' + objWork.Name + '/' + (String.isNotBlank(objWork.nm_CompanyName__c) ? objWork.nm_CompanyName__c.left(125) : '');
                                objDoc.Lead__c=objWork.nm_Lead__c;
                                system.debug('insert objDoc----> ' + objDoc);
                                lstDocumentsForLead.add(objDoc);
                            }
                       }
                   }
               }
           }
           if (lstDocumentsForLead.size() > 0) {
               insert lstDocumentsForLead;
           }
           if (lstDocumentsForAccount.size() > 0) {
               insert lstDocumentsForAccount;
           }
       }

       public void DeleteDocument(List<nm_WorkExperience__c> lstWork) {
           Set<String>  setOFLeads = new set<String>();
           Set<String>  setOFAccounts = new Set<String>();
           Set<String>  setOFWK = new Set<String>();
           Set<String>  setOFEligibility = new Set<String>();
           List<nm_LinksForDocumentsLead__c> lstDocumentsForLead = new List<nm_LinksForDocumentsLead__c>();
            List<nm_LinksForDocuments__c> lstDocumentsForAccount = new List<nm_LinksForDocuments__c>();
            Map<String, List<nm_LinksForDocumentsLead__c>> mapOfLeadVsListOfDoc = new Map<String, List<nm_LinksForDocumentsLead__c>>();
            Map<String, List<nm_LinksForDocuments__c>> mapOfAccountVsListOfDoc = new Map<String, List<nm_LinksForDocuments__c>>();
           List<nm_LinksForDocumentsLead__c> lstDocumentsForLeadToDeleteActual = new List<nm_LinksForDocumentsLead__c>();
            List<nm_LinksForDocuments__c> lstDocumentsForAccountToDeleteActual = new List<nm_LinksForDocuments__c>();
           List<nm_LinksForDocumentsLead__c> lstDocumentsForLeadToUpdate = new List<nm_LinksForDocumentsLead__c>();
            List<nm_LinksForDocuments__c> lstDocumentsForAccountToUpdate = new List<nm_LinksForDocuments__c>();
            List<nm_WorkExperience__c>  lstWorkExperience = new List<nm_WorkExperience__c>();
            set<String> programType = new Set<String>(new List<String>( System.Label.WorkExpMandatory.split(',')));
            Map<String, String> mapOfIntVsWkName = new Map<String,String>{'1'=> 'Work Experience Certificate – 1 years', '2' => 'Work Experience Certificate – 2 years' , '3' => 'Work Experience Certificate – 3 years' };
                if(lstWork.size() > 0) {
                    for (nm_WorkExperience__c objWork : lstWork) {
                        if(programType.contains(objWork.Program_Type__c)) {
                            if(String.isNotBlank(objWork.nm_Lead__c)) {
                                setOFLeads.add(objWork.nm_Lead__c);
                                setOFWK.add(objWork.Name);
                                }
                            if(String.isNotBlank(objWork.nm_Student__c)) {
                                setOFAccounts.add(objWork.nm_Student__c);
                                setOFWK.add(objWork.Name);
                                
                            }
                        }
               }
           }
        if(setOFLeads.size() > 0) {
            lstDocumentsForLead = [SELECT Id, Name,Lead__c,nm_URLforDocuments__c,nm_DocumentName__c,Work_Experience__c,Lead__r.nm_EligiblityCriteria__c   FROM nm_LinksForDocumentsLead__c WHERE  Name LIKE 'Work Experience Certificate%' AND Lead__c = : setOFLeads ];            
        }
        if(setOFAccounts.size() > 0) {
            lstDocumentsForAccount = [SELECT Id, Name, nm_Account__c,nm_URLforDocuments__c,nm_DocumentName__c,Work_Experience__c, nm_Account__r.nm_EligiblityCriteria__c FROM nm_LinksForDocuments__c WHERE Name LIKE 'Work Experience Certificate%' AND nm_Account__c = :setOFAccounts  ];
        }
           if(lstDocumentsForLead.size() > 0) {
                for (nm_LinksForDocumentsLead__c objDoc : lstDocumentsForLead) {
                    System.debug('Lead objDoc --> '+ objDoc.Name);
                    if(!mapOfLeadVsListOfDoc.containsKey(objDoc.Lead__c)) {
                        mapOfLeadVsListOfDoc.put(objDoc.Lead__c, new List<nm_LinksForDocumentsLead__c>());
                    }
                    List<nm_LinksForDocumentsLead__c> lstDocumentsForLeadWK = mapOfLeadVsListOfDoc.get(objDoc.Lead__c);
                    lstDocumentsForLeadWK.add(objDoc);
                    mapOfLeadVsListOfDoc.put(objDoc.Lead__c, lstDocumentsForLeadWK);
                }
           }
           if(lstDocumentsForAccount.size() > 0) {
               for (nm_LinksForDocuments__c objDoc : lstDocumentsForAccount) {
                    System.debug('Account objDoc --> '+ objDoc.Name);
                    if(!mapOfAccountVsListOfDoc.containsKey(objDoc.nm_Account__c)) {
                        mapOfAccountVsListOfDoc.put(objDoc.nm_Account__c, new List<nm_LinksForDocuments__c>());
                    }
                    List<nm_LinksForDocuments__c> lstDocumentsForAccountWK = mapOfAccountVsListOfDoc.get(objDoc.nm_Account__c);
                    lstDocumentsForAccountWK.add(objDoc);
                    mapOfAccountVsListOfDoc.put(objDoc.nm_Account__c, lstDocumentsForAccountWK);
                }
           }
           if(!mapOfLeadVsListOfDoc.isEmpty()) {

                for (String leadId : mapOfLeadVsListOfDoc.keySet()) {
                    List<nm_LinksForDocumentsLead__c> lstDocumentsForLeadWK = mapOfLeadVsListOfDoc.get(leadId);
                    List<nm_LinksForDocumentsLead__c> lstDocumentsForLeadToDelete = new List<nm_LinksForDocumentsLead__c>();
                    Integer totalLstDocLd = lstDocumentsForLeadWK.size();
                    system.debug('Lead totalLstDocLd --> ' + totalLstDocLd);
                    if(lstDocumentsForLeadWK.size() > 0) {
                        for (nm_LinksForDocumentsLead__c objDoc : lstDocumentsForLeadWK) {
                            if(objDoc.Name.contains('/') && objDoc.nm_URLforDocuments__c == null) {
                                String wkName = objDoc.Name.split('/')[1].trim();
                                System.debug('Lead wkName --> '+ wkName);
                                if(setOFWK.contains(wkName)  ) {
                                    lstDocumentsForLeadToDelete.add(objDoc);
                                }
                            }
                        }
                    }
                    if(lstDocumentsForLeadToDelete.size() > 0) {
                        for (Integer i = 0; i < lstDocumentsForLeadToDelete.size(); i++) {
                            if( i == 0 && totalLstDocLd == lstDocumentsForLeadToDelete.size()  ) {
                                nm_LinksForDocumentsLead__c objDo = lstDocumentsForLeadToDelete[i];
                                String numberOnly= lstDocumentsForLeadToDelete[i].nm_DocumentName__c.replaceAll('[^0-9]', '').left(1);
                                System.debug('numberOnly ---> ' + numberOnly);
                                if(mapOfIntVsWkName.containsKey(numberOnly)) {
                                    objDo.Name = mapOfIntVsWkName.get(numberOnly);
                                    objDo.nm_DocumentName__c=objDo.Name;
                                }
                                system.debug('lstDocumentsForLeadToUpdate objDo---> ' + objDo);
                                lstDocumentsForLeadToUpdate.add(objDo);
                            } else {
                                system.debug('lstDocumentsForLeadToDeleteActual lstDocumentsForLeadToDelete[i]---> ' + lstDocumentsForLeadToDelete[i]);
                                lstDocumentsForLeadToDeleteActual.add(lstDocumentsForLeadToDelete[i]);
                            }
                        }
                    }
                }
           }
           if(!mapOfAccountVsListOfDoc.isEmpty()) {

                for (String accountId : mapOfAccountVsListOfDoc.keySet()) {
                    List<nm_LinksForDocuments__c> lstDocumentsForAccountWK = mapOfAccountVsListOfDoc.get(accountId);
                    List<nm_LinksForDocuments__c> lstDocumentsForAccountToDelete = new List<nm_LinksForDocuments__c>();
                    Integer totalLstDocAc = lstDocumentsForAccountWK.size();
                    System.debug('Account totalLstDocAc --> ' + totalLstDocAc);
                    
                    if(lstDocumentsForAccountWK.size() > 0) {
                        for (nm_LinksForDocuments__c objDoc : lstDocumentsForAccountWK) {
                            if(objDoc.Name.contains('/') && objDoc.nm_URLforDocuments__c == null) {
                                String wkName = objDoc.Name.split('/')[1].trim();
                                System.debug('Account wkName --> ' + wkName);
                                System.debug('lstDocumentsForAccountToDelete objDoc --> ' + objDoc.Name);
                                if(setOFWK.contains(wkName)  ) {
                                    lstDocumentsForAccountToDelete.add(objDoc);
                                }
                            }
                        }
                    }
                    if(lstDocumentsForAccountToDelete.size() > 0) {
                        for (Integer i = 0; i < lstDocumentsForAccountToDelete.size(); i++) {
                            if( i == 0 && totalLstDocAc == lstDocumentsForAccountToDelete.size()  ) {
                                nm_LinksForDocuments__c objDo = lstDocumentsForAccountToDelete[i];
                                // objDo.Id = lstDocumentsForAccountToDelete[i].Id;
                                String numberOnly= lstDocumentsForAccountToDelete[i].nm_DocumentName__c.replaceAll('[^0-9]', '').left(1);
                                System.debug('Account numberOnly --> ' + numberOnly);
                                if(mapOfIntVsWkName.containsKey(numberOnly)) {
                                    objDo.Name = mapOfIntVsWkName.get(numberOnly);
                                    objDo.nm_DocumentName__c=objDo.Name;
                                }
                                System.debug('Account lstDocumentsForAccountToUpdate --> ' + objDo);
                                lstDocumentsForAccountToUpdate.add(objDo);
                            } else {
                                System.debug('Account lstDocumentsForAccountToDelete[i] --> ' + lstDocumentsForAccountToDelete[i]);
                                lstDocumentsForAccountToDeleteActual.add(lstDocumentsForAccountToDelete[i]);
                            }
                        }
                    }
                }
           }

           if(lstDocumentsForLeadToDeleteActual.size() > 0) {
               DELETE lstDocumentsForLeadToDeleteActual;
           }
           if(lstDocumentsForLeadToUpdate.size() > 0) {
               UPDATE lstDocumentsForLeadToUpdate;
           }
           if(lstDocumentsForAccountToDeleteActual.size() > 0) {
               DELETE lstDocumentsForAccountToDeleteActual;
           }
           if(lstDocumentsForAccountToUpdate.size() > 0) {
               UPDATE lstDocumentsForAccountToUpdate;
           }

       }


    public void updateCompanyName(list<nm_WorkExperience__c> lstWorkEx,map<id, nm_WorkExperience__c> triggerOldMap) {
        Map<String, String> mapOfIdVsCompany = new Map<String, String>();
        List<nm_LinksForDocumentsLead__c> updateLstDocLead = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocuments__c> updateLstDocAcc = new List<nm_LinksForDocuments__c>();
        Map<String, String> mapOfIntVsWkName = new Map<String,String>{'1'=> 'Work Experience Certificate – 1 years', '2' => 'Work Experience Certificate – 2 years' , '3' => 'Work Experience Certificate – 3 years' };
        set<String> programType = new Set<String>(new List<String>(System.Label.WorkExpMandatory.split(',')));
        if(lstWorkEx.size() > 0) {
            for(nm_WorkExperience__c objWk : lstWorkEx) {
                if(programType.contains(objWk.Program_Type__c) && String.isNotBlank(objWk.Eligibility_Criteria__c) && objWk.Eligibility_Criteria__c.containsIgnoreCase('Work') && String.isNotBlank(objWk.nm_CompanyName__c)  && objWk.nm_CompanyName__c != triggerOldMap.get(objWk.Id).nm_CompanyName__c ) {
                    mapOfIdVsCompany.put(objWk.Id, objWk.nm_CompanyName__c);
                }
            }
        }
        if(!mapOfIdVsCompany.isEmpty()) {
            List<nm_LinksForDocumentsLead__c> lstDocLead = [SELECT Id, Name,nm_DocumentName__c,Eligibility_Criteria__c, Work_Experience__c, Work_Experience__r.Name FROM nm_LinksForDocumentsLead__c WHERE Work_Experience__c IN :mapOfIdVsCompany.keySet() AND Eligibility_Criteria__c != null];
            List<nm_LinksForDocuments__c> lstDocAcc = [SELECT Id, Name,nm_DocumentName__c, Eligibility_Criteria__c, Work_Experience__c, Work_Experience__r.Name FROM nm_LinksForDocuments__c WHERE Work_Experience__c IN :mapOfIdVsCompany.keySet() AND Eligibility_Criteria__c != null];

            if(lstDocLead.size() > 0) {
                for( nm_LinksForDocumentsLead__c objDocLead : lstDocLead) {
                    String wkName = '';
                    if(objDocLead.Eligibility_Criteria__c.contains('1') )
                    {
                        wkName = 'Work Experience Certificate – 1 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
                    }
                    else if(objDocLead.Eligibility_Criteria__c.contains('2'))
                    {
                        wkName = 'Work Experience Certificate – 2 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
                    }
                    else if(objDocLead.Eligibility_Criteria__c.contains('3'))
                    {
                        wkName = 'Work Experience Certificate – 3 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
                    }
                    if(String.isNotBlank(wkName)) {
                        objDocLead.Name = wkName + '/' + objDocLead.Work_Experience__r.Name + '/' + (String.isNotBlank(mapOfIdVsCompany.get(objDocLead.Work_Experience__c)) ? mapOfIdVsCompany.get(objDocLead.Work_Experience__c).left(25) : '');
                        objDocLead.nm_DocumentName__c = wkName + '/' + objDocLead.Work_Experience__r.Name + '/' + (String.isNotBlank(mapOfIdVsCompany.get(objDocLead.Work_Experience__c)) ? mapOfIdVsCompany.get(objDocLead.Work_Experience__c).left(125) : '');
                        updateLstDocLead.add(objDocLead);
                    }
                }
            }
            if(lstDocAcc.size() > 0) {
                for( nm_LinksForDocuments__c objDocAcc : lstDocAcc) {
                    String wkName = '';
                    if(objDocAcc.Eligibility_Criteria__c.contains('1') )
                    {
                        wkName = 'Work Experience Certificate – 1 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
                    }
                    else if(objDocAcc.Eligibility_Criteria__c.contains('2'))
                    {
                        wkName = 'Work Experience Certificate – 2 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
                    }
                    else if(objDocAcc.Eligibility_Criteria__c.contains('3'))
                    {
                        wkName = 'Work Experience Certificate – 3 years';
                        // mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
                    }
                    if(String.isNotBlank(wkName)) {
                        objDocAcc.Name = wkName + '/' + objDocAcc.Work_Experience__r.Name + '/' + (String.isNotBlank(mapOfIdVsCompany.get(objDocAcc.Work_Experience__c)) ? mapOfIdVsCompany.get(objDocAcc.Work_Experience__c).left(25) : '');
                        objDocAcc.nm_DocumentName__c = wkName + '/' + objDocAcc.Work_Experience__r.Name + '/' + (String.isNotBlank(mapOfIdVsCompany.get(objDocAcc.Work_Experience__c)) ? mapOfIdVsCompany.get(objDocAcc.Work_Experience__c).left(125) : '');
                        updateLstDocAcc.add(objDocAcc);
                    }
                }
            }
        }

        if(updateLstDocLead.size() > 0) {
            update updateLstDocLead;
        }
        if(updateLstDocAcc.size() > 0) {
            update updateLstDocAcc;
        }
    }
    
}