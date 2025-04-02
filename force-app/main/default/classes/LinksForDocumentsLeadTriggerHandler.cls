/**
 * @File Name          : LinksForDocumentsLeadTriggerHandler.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-18-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/9/2019   @BK     Initial Version
**/
public without sharing class LinksForDocumentsLeadTriggerHandler {
    
    public static boolean IsAfterUpdateRunOnce = false;
    
    public LinksForDocumentsLeadTriggerHandler(){
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queriedxc  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' +  Limits.getLimitFutureCalls());
    }

    /**
    * @description 
    * @author @BK | 17/1/2020 
    * @param triggerNew 
    * @param triggerOldMap 
    * @return void 
    **/
    public void AfterUpdate(list<nm_LinksForDocumentsLead__c> triggerNew, Map<id, nm_LinksForDocumentsLead__c> triggerOldMap){ 
        if(IsAfterUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        
        IsAfterUpdateRunOnce = true;

        // to update the document submitted date if all the mandatory documents submitted
        updateDocumentSubmittedDate(triggerNew,triggerOldMap);
    }

    /**
    * @description : to update the document submitted date if all the mandatory documents submitted
    * @author @BK | 17/1/2020 
    * @param listOfLinksForDocumentsLead 
    * @param oldMapOfLinksForDocumentsLead 
    * @return void 
    **/
    public void updateDocumentSubmittedDate(List<nm_LinksForDocumentsLead__c> listOfLinksForDocumentsLead , Map<id,nm_LinksForDocumentsLead__c> oldMapOfLinksForDocumentsLead){  

        Map<String,Set<String>> mapOfIdVsMandatoryDocuments = new Map<String,Set<String>>();
        Map<String,Set<String>> mapOfIdVsSubmittedDocuments = new Map<String,Set<String>>();
        
        Set<String> setOfLeadId = new Set<String>();
        List<Lead> lstOfLeadToUpdate = new List<Lead>();

        for (nm_LinksForDocumentsLead__c objLinksForDocumentsLead : listOfLinksForDocumentsLead) {
            if(objLinksForDocumentsLead.nm_URLforDocuments__c!=oldMapOfLinksForDocumentsLead.get(objLinksForDocumentsLead.Id).nm_URLforDocuments__c 
              && objLinksForDocumentsLead.Eligibility_Criteria__c != null) {
                setOfLeadId.add(objLinksForDocumentsLead.Lead__c);
            }
        }

        if(setOfLeadId.size() > 0) {
            Map<String, Lead> mapOfIdVsLead = new Map<String, Lead>([SELECT Id,nm_Eligibility_Criteria_Ref__c,Relationship__c,Are_you_from_Defence__c,Is_Lateral__c,nm_ProgramName__c,nm_ChooseaProgram__c,HSC_status__c,Diploma_status__c,nm_Nationality__c FROM Lead WHERE Id IN :setOfLeadId]);
            Set<String> setOfCriteria = new Set<String>();
            Map<String, Set<String>> mapOfCriteraiIdVsManDocuments = new Map<String, Set<String>>();
            Map<String,List<nm_WorkExperience__c>> getMapLeadIdVsWk = getMapLeadIdVsWk(setOfLeadId);
            for (Lead objLead: mapOfIdVsLead.values()) {
                mapOfIdVsMandatoryDocuments.put(objLead.Id,getMandatoryDocumentList(objLead, getMapLeadIdVsWk.containsKey(objLead.Id) ? getMapLeadIdVsWk.get(objLead.Id) : new List<nm_WorkExperience__c>()));
            }
            
            List<nm_LinksForDocumentsLead__c> lstDocuments = [SELECT id,Eligibility_Criteria__c,nm_DocumentLink__c,nm_DocumentName__c,nm_URLforDocuments__c,Lead__c FROM nm_LinksForDocumentsLead__c WHERE Lead__c IN :mapOfIdVsLead.keySet() AND nm_URLforDocuments__c!=null];

            for (nm_LinksForDocumentsLead__c objDoc: lstDocuments) {

                if(mapOfIdVsSubmittedDocuments.get(objDoc.Lead__c) == null) {
                    mapOfIdVsSubmittedDocuments.put(objDoc.Lead__c,new set<string>());
                }
                mapOfIdVsSubmittedDocuments.get(objDoc.Lead__c).add(objDoc.nm_DocumentName__c);
            }

            lstOfLeadToUpdate = validateForAllDocumentsSubmitted(mapOfIdVsMandatoryDocuments,mapOfIdVsSubmittedDocuments);
            if(lstOfLeadToUpdate.size() > 0) {
                try {
                    update lstOfLeadToUpdate;
                } catch(DmlException e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 09-08-2024 
    * @param Set<String> setOfLeadId 
    * @return Map<String,List<nm_WorkExperience__c>>
    **/
    public Map<String,List<nm_WorkExperience__c>> getMapLeadIdVsWk(Set<String> setOfLeadId) {
        Map<String,List<nm_WorkExperience__c>> mapLeadIdVsWk = new Map<String,List<nm_WorkExperience__c>>();
        if(setOfLeadId.size() > 0) {
            List<nm_WorkExperience__c> lstWk = [SELECT Id, Name,nm_Lead__r.Id, nm_CompanyName__c From nm_WorkExperience__c WHERE nm_Lead__c IN :setOfLeadId];
            system.debug('lstWk --> ' + lstWk);
            if (lstWk.size() > 0) {
                for (nm_WorkExperience__c WK : lstWk) {
                    List<nm_WorkExperience__c> lstW = mapLeadIdVsWk.containsKey(WK.nm_Lead__r.Id)
                                                    ? mapLeadIdVsWk.get(WK.nm_Lead__r.Id)
                                                    : new List<nm_WorkExperience__c>();
                    lstW.add(WK);
                    mapLeadIdVsWk.put(WK.nm_Lead__r.Id, lstW);
                }
            }
        }
        return mapLeadIdVsWk;
    }

    /**
    * @description 
    * @author @BK | 09-08-2024 
    * @param Lead objLead 
    * @param List<nm_WorkExperience__c> lstWk
    * @return Set<String> 
    **/
    public Set<String> getMandatoryDocumentList(Lead objLead, List<nm_WorkExperience__c> lstWk) {
        GetMandatoryDocuments documentHanlder = new GetMandatoryDocuments();
        GetMandatoryDocuments.StudentStatus objStatus = new GetMandatoryDocuments.StudentStatus();
        objStatus.chooseProgram = objLead.nm_ChooseaProgram__c;
        objStatus.eligibilityCriteria = objLead.nm_Eligibility_Criteria_Ref__c;
        objStatus.isDefencePersonnel = objLead.Are_you_from_Defence__c;
        objStatus.relationship = objLead.Relationship__c;
        objStatus.studentProgram = objLead.nm_ProgramName__c;
        objStatus.hscStatus = objLead.HSC_status__c;
        objStatus.diplomaStatus = objLead.Diploma_status__c;
        objStatus.isLateral = objLead.Is_Lateral__c;
        objStatus.isIndian = objLead.nm_Nationality__c == 'Indian' ? true : false;
        objStatus.lstWk = lstWk;
        objStatus.objectType = 'Lead';
        return documentHanlder.getMandatoryDocumentsName(objStatus);
    }

    /**
    * @description 
    * @author @BK | 18/1/2020 
    * @param objLead 
    * @return Set<String> 
    **/
    // public Set<String> getMandatoryDocumentList(Lead objLead) {
    //     Set<String> mandatoryDocumentForCurrentCriteria = new Set<String>{'Photo ID proof','Student Photograph'};
    //     String eligiblityRef = objLead.nm_Eligibility_Criteria_Ref__c;

    //     if(eligiblityRef.contains('Bachelor') || eligiblityRef.contains('Graduation')) {
    //         mandatoryDocumentForCurrentCriteria.add('Degree Mark Sheet');
    //     }
        
    //     if(eligiblityRef.contains('HSC')) {
    //         mandatoryDocumentForCurrentCriteria.add('12th Mark Sheet');
    //     }

    //     if(eligiblityRef.contains('SSC')) {
    //         mandatoryDocumentForCurrentCriteria.add('10th Mark Sheet');
    //     }

    //     if(eligiblityRef.contains('Diploma')) {
    //         mandatoryDocumentForCurrentCriteria.add('Diploma Mark Sheet');
    //     }

    //     if(eligiblityRef.containsIgnoreCase('Work') && !eligiblityRef.contains('preferably')) {                            
    //         if(eligiblityRef.contains('1') ) {
    //             mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 1 years');
    //         }
    //         else if(eligiblityRef.contains('2')) {
    //             mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 2 years'); 
    //         }
    //         else if(eligiblityRef.contains('3')) {
    //             mandatoryDocumentForCurrentCriteria.add('Work Experience Certificate – 3 years'); 
    //         }
    //     }  

    //     if(eligiblityRef.contains('Professional')) {
    //         mandatoryDocumentForCurrentCriteria.add('Additional Qualification Certificates');
    //     }  

    //     if(objLead.Are_you_from_Defence__c == 'Yes') {
    //         mandatoryDocumentForCurrentCriteria.add('Defence Document');
    //         if(objLead.Relationship__c !='Self') {
    //             mandatoryDocumentForCurrentCriteria.add('Relationship Document');
    //         }
    //     }

    //     if(objLead.Is_Lateral__c && !objLead.nm_ProgramName__c.startswith('Advance')) {
    //         mandatoryDocumentForCurrentCriteria.add('NMIMS Diploma Marksheet');
    //     }

    //     if(objLead.Is_Lateral__c && objLead.nm_ProgramName__c.startswith('Advance')) {
    //         mandatoryDocumentForCurrentCriteria.add('NMIMS Certificate Program Marksheet');
    //     }

    //     return mandatoryDocumentForCurrentCriteria;
    // }

    /**
    * @description 
    * @author @BK | 17/1/2020 
    * @param mapOfIdVsMandatoryDocuments 
    * @param mapOfIdVsSubmittedDocuments 
    * @return List<Lead> 
    **/
    public List<Lead> validateForAllDocumentsSubmitted(Map<String,Set<String>> mapOfIdVsMandatoryDocuments,Map<String,Set<String>> mapOfIdVsSubmittedDocuments) {
        List<Lead> lstLead = new List<Lead>();
        for (String recordId: mapOfIdVsMandatoryDocuments.keySet()) {

            Set<String> mandatoryDocumentForCurrentCriteria = mapOfIdVsMandatoryDocuments.get(recordId);
            
            if(mapOfIdVsSubmittedDocuments.containsKey(recordId)) {
                Set<String> submittedDocumentsForCurrentCriteria = mapOfIdVsSubmittedDocuments.get(recordId);
                Boolean allDocumentsSubmitted = submittedDocumentsForCurrentCriteria.containsAll(mandatoryDocumentForCurrentCriteria);

                if(allDocumentsSubmitted) {
                    Lead objLead = new Lead(Id=recordId);
                    objLead.nm_DocumentSubmittedDate__c = System.now();
                    objLead.Documnet_submitted_date_on_Lead__c = System.now();
                    lstLead.add(objLead);
                }
            }
        }

        return lstLead;
    }
}