/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-09-2024
 * @last modified by  : @BK
**/
public class nmCaseTriggerHandler {

    public static boolean IsAfterUpdateRunOnce = false;
    public static boolean IsBeforeUpdateRunOnce = false;

    public void AfterUpdate(List<Case> triggerNew , Map<id,Case> oldMap) {
        if(IsAfterUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        IsAfterUpdateRunOnce = true;
        RespondToPostMyQueryOnStudentZone(triggerNew,OldMap);
        // UpdateMostAssign(triggerNew,OldMap);
        loanObtainedByStudent(triggerNew, OldMap, 'UPDATE');
        // captureDateHO(triggerNew);
        manageCaseTeam(triggerNew, OldMap);//added by swati
    }
    
        
    public void Afterinsert(List<Case> triggerNew) {
        System.debug('Inside Afterinsert bulkified');

        // to map Account to Case.
        addAccountDetails(triggerNew);
        
        // Database.update(caseList, dmlOpts);
        loanObtainedByStudent(triggerNew, new map<id,Case>(), 'INSERT');
    }

    public void BeforeInsert(list<Case> triggerNew){ 
        // Block undefined cases
        String studentZoneCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Zone').getRecordTypeId();
        for(Case c: triggerNew){
            if (c.SuppliedEmail == 'undefined' && c.SuppliedPhone == 'undefined' && c.recordTypeId == studentZoneCases) {
                c.addError('Web email, web name, and web phone must be defined');
            }
        }

        // to set Program Type to Case.
        setProgramType(triggerNew);

        // Insert case with Expected Close Date for Ticketing tool type
        // commented on 21/12/23 due to duplicate case issue
        // insertCasesWithCloseDate(triggerNew); 

        // to Set Original Owner if case is assigned from Omnichannel
        // setOriginalOwner(triggerNew);
    }

    /**
    * @description 
    * @author @vickysahu | 25-12-2023 
    * @param triggerNew 
    **/
    // public void insertCasesWithCloseDate(list<Case> triggerNew) {
    //     String createdBy = System.UserInfo.getName();
    //     List<String> lstUsers = new List<String>{'NMIMS Site Guest User','Admin User'};
    //     String ticketing = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    //     for(Case c: triggerNew) {
    //         if(c.recordTypeId == ticketing && c.Expected_Close_Date__c == null && !lstUsers.contains(createdBy)) {
    //             Integer tat = 2;
    //             if(String.isNotBlank(c.Student_Category__c)) {
    //                 Case__c mcs = Case__c.getValues(c.Student_Category__c);
    //                 tat = Integer.valueOF(mcs.TAT__c);
    //             }
    //             Integer diff = MyCasesController.getNumberOfDays(System.today(), System.today().addDays(tat));
    //             if(diff < tat){
    //                 Integer actualTat = tat + (tat-diff);
    //                 c.Expected_Close_Date__c = System.today().addDays(actualTat);
    //             }else{
    //                 c.Expected_Close_Date__c = System.today().addDays(tat);
    //             }
    //         }
    //     }
    // }

    /**
    * @description 
    * @author @BK | 03-11-2023 
    * @param triggerNew 
    * @param oldMap 
    **/
    public void BeforeUpdate(List<Case> triggerNew , Map<id,Case> oldMap) {

        if(IsBeforeUpdateRunOnce){
            return;
        }

        IsBeforeUpdateRunOnce = true;

        if(System.Label.EnableCaseRouting == 'Yes') {
            // to update the case owner based on case routing.
            caseRouting(triggerNew, oldMap);
        }

        updateOriginalOwner(triggerNew, oldMap);
        
    }

    public void updateCasesWithLead(Map<String, List<Case>> emailToCasesMap) {
        if (emailToCasesMap == null || emailToCasesMap.isEmpty()) {
            return; // No need to proceed if the map is null or empty
        }

        // Create a set of unique email addresses
        Set<String> uniqueEmails = emailToCasesMap.keySet();

        // Query for Leads that match the email addresses in the map
        Map<String, Id> emailToLeadIdMap = new Map<String, Id>();
        for (Lead lead : [
            SELECT Id, Email
            FROM Lead
            WHERE Email IN :uniqueEmails
                AND IsConverted = false
                AND IsDeleted = false
        ]) {
            emailToLeadIdMap.put(lead.Email, lead.Id);
        }

        List<Case> casesToUpdate = new List<Case>();
        if(uniqueEmails.size()>0){
            for (String caseEmail : uniqueEmails) {
                if (emailToLeadIdMap.containsKey(caseEmail)) {
                    List<Case> relatedCases = emailToCasesMap.get(caseEmail);
                    Id leadId = emailToLeadIdMap.get(caseEmail);

                    for (Case relatedCase : relatedCases) {
                        Case caseOb = new Case();
                        caseOb.Id=relatedCase.Id;
                        caseOb.Lead__c = leadId;
                        casesToUpdate.add(caseOb);
                    }
                }
            }
        }

        if (casesToUpdate.size()>0) {
            update casesToUpdate;
        }
    }
    
    public void RespondToPostMyQueryOnStudentZone(List<Case> triggerNew , Map<id,Case> oldMap) {
        for(Case cases : triggerNew)
        {
            if('Academics'.equalsIgnoreCase(cases.nm_Category__c) && 'Post a Query'.equalsIgnoreCase(cases.sub_categories__c)
                && !''.equals(case.StudentZone_QueryId__c) && cases.StudentZone_QueryId__c !=null 
                && cases.Response_To_Post_My_Query__c != oldMap.get(cases.id).Response_To_Post_My_Query__c
                && !''.equals(cases.Response_To_Post_My_Query__c) && cases.Response_To_Post_My_Query__c !=null
            ){
                updatePostMyQueryAnsOnStuentZone(cases.id);
            } 
        }
    }

    /**
    * @description 
    * @author @BK | 12-06-2024 
    * @param List<Case> triggerNew 
    * @param Map<id Case> oldMap 
    **/
    public static void manageCaseTeam(List<Case> triggerNew , Map<id,Case> oldMap) {
        System.debug('manageCaseTeam called');
        CaseRoutingUtility utils = CaseRoutingUtility.getInstance();
        String ticketingCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();
        List<Id> lstOfCaseIds = new List<Id>();
        for (Case objCase : triggerNew) { 
            if(objCase.RecordTypeId==ticketingCases && objCase.OwnerId!=oldMap.get(objCase.Id).OwnerId) { 
                lstOfCaseIds.add(objCase.Id);
            }
        }

        if(lstOfCaseIds.size() > 0) {
            system.debug('lstOfCaseIds.size()==>'+lstOfCaseIds.size());
            List<CaseTeamRole> lstRoles = utils.objWrapper.lstRoles;
            Map<String,Id> mapOfCategoryVsUserId = utils.objWrapper.mapOfCategoryVsUserId;
            // Map<Id,String> mapQIdName = utils.objWrapper.mapOfAllQueueIdVsName;
            System.debug('mapOfCategoryVsUserId Size ==>'+mapOfCategoryVsUserId.size());
            Map<String,Id> mapOfRoleVsID = new Map<String,Id>();
            if(lstRoles.size() > 0) {
                for (CaseTeamRole objRole : lstRoles) {
                    mapOfRoleVsID.put(objRole.Name,objRole.Id);
                }
                List<CaseTeamMember> lstToUpsert = new List<CaseTeamMember>();
                List<CaseTeamMember> lstToDelete = new List<CaseTeamMember>();
                Map<Id,Map<Id,CaseTeamMember>> mapOfCaseIdVsListCTM = new Map<Id,Map<Id,CaseTeamMember>>();
                List<CaseTeamMember> lstOfCTM = [SELECT id,ParentId,MemberId,TeamRoleId,TeamRole.Name FROM CaseTeamMember WHERE ParentId IN :lstOfCaseIds];
                for (CaseTeamMember obj : lstOfCTM) {
                    Map<Id,CaseTeamMember> mapCTM = mapOfCaseIdVsListCTM.containsKey(obj.ParentId) ? mapOfCaseIdVsListCTM.get(obj.ParentId) : new Map<Id,CaseTeamMember>();
                    mapCTM.put(obj.MemberId,obj);
                    mapOfCaseIdVsListCTM.put(obj.ParentId,mapCTM);
                }

                for (Case objCase : triggerNew) { 
                    System.debug('objCase.InternalCategory__c ==>'+objCase.InternalCategory__c);
                    System.debug('objCase.InternalCategory__c ==>'+objCase.InternalCategory__c);
                    Map<Id,CaseTeamMember> mapCTM = mapOfCaseIdVsListCTM.containsKey(objCase.Id) ? mapOfCaseIdVsListCTM.get(objCase.Id) : new Map<Id,CaseTeamMember>();
                    if(oldMap.get(objCase.Id).OwnerId == objCase.CreatedById) {
                        // For Raiser
                        if(mapCTM.containsKey(objCase.CreatedById) && mapCTM.get(objCase.CreatedById).TeamRole.Name != 'Viewer') {
                            CaseTeamMember obj = mapCTM.get(objCase.CreatedById);
                            obj.TeamRoleId = mapOfRoleVsID.get('Viewer');
                            lstToUpsert.add(obj);
                        } else if(!mapCTM.containsKey(objCase.CreatedById)) {
                            CaseTeamMember obj = new CaseTeamMember(ParentId = objCase.Id, MemberId = oldMap.get(objCase.Id).OwnerId, TeamRoleId = mapOfRoleVsID.get('Viewer'));
                            lstToUpsert.add(obj);
                        } 
                    } 
                    else if(mapCTM.containsKey(oldMap.get(objCase.Id).OwnerId) && (mapOfCategoryVsUserId.containsKey(objCase.InternalCategory__c) 
                        && mapOfCategoryVsUserId.get(objCase.InternalCategory__c) != oldMap.get(objCase.Id).OwnerId)) { // For Not Raiser Person
                        lstToDelete.add(mapCTM.get(oldMap.get(objCase.Id).OwnerId));
                    }

                    // For Transfered Person
                    if(mapCTM.containsKey(objCase.OwnerId) && mapCTM.get(objCase.OwnerId).TeamRole.Name != 'Editor') {
                        CaseTeamMember obj = mapCTM.get(objCase.OwnerId);
                        obj.TeamRoleId = mapOfRoleVsID.get('Editor');
                        lstToUpsert.add(obj);
                    } else if(!mapCTM.containsKey(objCase.OwnerId) && objCase.OwnerId.getSobjectType()!=Group.SobjectType){
                        CaseTeamMember obj = new CaseTeamMember(ParentId = objCase.Id, MemberId = objCase.OwnerId, TeamRoleId = mapOfRoleVsID.get('Editor'));
                        lstToUpsert.add(obj);
                    } 
                    // for handling queue
                    // else if(objCase.OwnerId.getSobjectType() == Group.SobjectType && mapQIdName.containsKey(objCase.OwnerId)) {
                        
                    // }
                }

                if(lstToUpsert.size() > 0) {
                    upsert lstToUpsert;
                }

                if(lstToDelete.size() > 0) {
                    delete lstToDelete;
                }
            }
        }
    }

    public void loanObtainedByStudent(List<Case> triggerNew , Map<id,Case> oldMap, String activity) {
        Map<String, Set<String>> mapOfAccIdVsCase = new Map<String, Set<String>>();
        Set<String> setOfAccContainDownPayment = new Set<String>();
        List<Case> lstCaseToUpdate = new List<Case>();
        for (Case objCase : triggerNew) {
            // System.debug('objCase.AccountId --> ' + objCase.AccountId);
            // System.debug('activity --> ' + activity);
            // System.debug('oldMap.get(objCase.Id).AccountId --> ' + oldMap.get(objCase.Id).AccountId);
            // System.debug('objCase.AccountId --> ' + (activity == 'UPDATE' && objCase.AccountId != oldMap.get(objCase.Id).AccountId));
            if (objCase.AccountId != null && (activity == 'INSERT' || (activity == 'UPDATE' && objCase.AccountId != oldMap.get(objCase.Id).AccountId))) {
                Set<String> setOfCase = mapOfAccIdVsCase.containsKey(objCase.AccountId) ? mapOfAccIdVsCase.get(objCase.AccountId) : new Set<String>();
                setOfCase.add(objCase.Id);
                mapOfAccIdVsCase.put(objCase.AccountId, setOfCase);
            }
        }
        if (mapOfAccIdVsCase.size() > 0) {
            for (Opportunity objOpp : [SELECT Id, AccountId, Down_Payment_Made__c FROM Opportunity WHERE AccountId IN :mapOfAccIdVsCase.keySet() AND Down_Payment_Made__c = true AND Loan_Type__c != null ]) {
                setOfAccContainDownPayment.add(objOpp.AccountId);
            }

            for (String accId : setOfAccContainDownPayment) {
                Set<String> setOCaseId = mapOfAccIdVsCase.containsKey(accId) ? mapOfAccIdVsCase.get(accId) : new Set<String>();
                if (setOCaseId.size() > 0) {
                    for (String caseId : setOCaseId) {
                        if (setOfAccContainDownPayment.contains(accId)) {
                            lstCaseToUpdate.add(new Case(Id = caseId, Loan_obtained__c = true));
                        } 
                    }
                }
            }
        }
        if (lstCaseToUpdate.size() > 0) {
            update lstCaseToUpdate;
        }
    }

    /**
    * @description 
    * @author @BK | 24-01-2024 
    * @param List<Case> triggerNew 
    * @param Map<id Case> oldMap 
    **/
    public void updateOriginalOwner(List<Case> triggerNew , Map<id,Case> oldMap) {
        CaseRoutingUtility utils = CaseRoutingUtility.getInstance();
        Map<Id,String> mapQIdName = utils.objWrapper.mapOfAllQueueIdVsName;
        Map<Id,String> mapOfUserIdVsName = utils.objWrapper.mapOfUserIdCPVsName; // Map of Counselor UserId VS Name
        Map<String,Id> mapOfCPNameVsUserId = utils.objWrapper.mapOfCPNameVsUserId; // Map of Counselor 
        Id userId = UserInfo.getUserId();
        String ticketingCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        for (Case objCase : triggerNew) {
            if(objCase.RecordTypeId==ticketingCases && objCase.OwnerId!=oldMap.get(objCase.Id).OwnerId && utils.objWrapper.setOfSAUserIds.contains(userId)) {
                if(objCase.OwnerId.getSobjectType()!=Group.SobjectType && mapOfUserIdVsName.containsKey(objCase.OwnerId)) {
                    objCase.FirstCaseAssigned__c = mapOfUserIdVsName.get(objCase.OwnerId);
                } else if(objCase.OwnerId.getSobjectType()==Group.SobjectType && mapOfCPNameVsUserId.containsKey(mapQIdName.get(objCase.OwnerId))) {
                    objCase.FirstCaseAssigned__c = mapQIdName.get(objCase.OwnerId);
                }
            } 
            // else if(objCase.RecordTypeId==ticketingCases && String.isBlank(objCase.FirstCaseAssigned__c) ) {
            //     if(objCase.OwnerId!=oldMap.get(objCase.Id).OwnerId && mapOfUserIdVsName.containsKey(oldMap.get(objCase.Id).OwnerId)) {
            //         objCase.FirstCaseAssigned__c = mapOfUserIdVsName.get(oldMap.get(objCase.Id).OwnerId);
            //     } else if(mapOfUserIdVsName.containsKey(objCase.OwnerId)) {
            //         objCase.FirstCaseAssigned__c = mapOfUserIdVsName.get(objCase.OwnerId);
            //     }
            // } 
        }
    }

    /**
    * @description 
    * @author @BK | 19-04-2024 
    * @param List<Case> triggerNew 
    **/
    // public void setOriginalOwner(List<Case> triggerNew) {
    //     String ticketingCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    //     CaseRoutingUtility utils = CaseRoutingUtility.getInstance();
    //     Map<Id,String> mapOfUserIdVsName = utils.objWrapper.mapOfUserIdCPVsName; // Map of Counselor UserId VS Name
    //     for (Case objCase : triggerNew) {
    //         if (objCase.RecordTypeId == ticketingCases && STring.isBlank(objCase.FirstCaseAssigned__c) 
    //             && objCase.Status == 'New' && mapOfUserIdVsName.containsKey(objCase.OwnerId)) {
    //             objCase.FirstCaseAssigned__c = mapOfUserIdVsName.get(objCase.OwnerId);
    //         }
    //     }
    // }

    /**
    * @description To Map Account to Case.
    * @author @BK | 17-11-2023 
    * @param triggerNew 
    **/
    public void addAccountDetails(List<Case> triggerNew) {
        List<Case> lstUpdateCase = new List<Case>();
        Map<String,List<Case>> mapofEmailvsCase = new Map<String,List<Case>>();
        List<Id> lstRecordTypes = new List<Id> {
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId()
        };
        for(Case obj : triggerNew) {
            // if(!lstRecordTypes.contains(obj.RecordTypeId)) {
                if(!mapofEmailvsCase.containsKey(obj.SuppliedEmail)) {
                    mapofEmailvsCase.put(obj.SuppliedEmail,new List<Case>());
                }
                mapofEmailvsCase.get(obj.SuppliedEmail).add(obj);
            // }
        }
        System.debug('mapofEmailvsCase1==>'+mapofEmailvsCase);
        if(!mapofEmailvsCase.isEmpty()) {
            List<Contact> conlist=[SELECT id,AccountId,Email,Account.Program_Type__c FROM Contact WHERE Email IN:mapofEmailvsCase.keySet() ORDER BY CreatedDate ASC];
            Map<String,Contact> mapOfEmailVsContact = new Map<String,Contact>();
            for(Contact obj : conlist) {
                mapOfEmailVsContact.put(obj.Email,obj);      
                mapofEmailvsCase.remove(obj.Email);
            }
            System.debug('mapOfEmailVsContact==>'+mapOfEmailVsContact);
            System.debug('mapofEmailvsCase==>'+mapofEmailvsCase);
            for(Case obj : triggerNew) {
                System.debug('obj.AccountId==>'+obj.AccountId);
                if(obj.AccountId==null && (String.isBlank(obj.RecordTypeId) || !lstRecordTypes.contains(obj.RecordTypeId)) 
                    && mapOfEmailVsContact.containsKey(obj.SuppliedEmail))  {
                    System.debug('mapOfEmailVsContact.get(obj.SuppliedEmail)==>'+mapOfEmailVsContact.get(obj.SuppliedEmail));
                    Case caseOb = new Case();
                    caseOb.Id=obj.Id;
                    caseOb.AccountId=mapOfEmailVsContact.get(obj.SuppliedEmail).AccountId;
                    caseOb.ContactId=mapOfEmailVsContact.get(obj.SuppliedEmail).Id;
                    caseOb.Program_Type__c = String.isNotBlank(mapOfEmailVsContact.get(obj.SuppliedEmail).Account.Program_Type__c) 
                                                ? mapOfEmailVsContact.get(obj.SuppliedEmail).Account.Program_Type__c 
                                                : 'Retail';
                    lstUpdateCase.add(caseOb);
                }
            }
            if(lstUpdateCase.size()>0) {
                update lstUpdateCase;
            }
            if(mapofEmailvsCase!=null) {
                updateCasesWithLead(mapofEmailvsCase);
            }
        }
    }

    /**
     * @description
     * @author @BK | 04-04-2024
     * @param List<Case> triggerNew
     **/
    public void setProgramType(List<Case> triggerNew) {
        String ticketingCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        Set<Id> setOfAccountId = new Set<Id>();
        for (Case objCase : triggerNew) {
            if (objCase.RecordTypeId == ticketingCases && String.isNotBlank(objCase.AccountId)) {
                setOfAccountId.add(objCase.AccountId);
            }
        }

        if (setOfAccountId.size() > 0) {
            Map<Id, Account> mapOfIdVsAccount = new Map<Id, Account>(
                [SELECT Id, Program_Type__c FROM Account WHERE Id IN :setOfAccountId]
            );
            if (mapOfIdVsAccount.size() > 0) {
                for (Case objCase : triggerNew) {
                    if (mapOfIdVsAccount.containsKey(objCase.AccountId)) {
                        objCase.Program_Type__c = String.isNotBlank(mapOfIdVsAccount.get(objCase.AccountId).Program_Type__c)
                            ? mapOfIdVsAccount.get(objCase.AccountId).Program_Type__c : 'Retail';
                    }
                }
            }
        }
    }

    /**
    * @description Case Routing Function
    * @author @BK | 27-09-2024 
    * @param List<Case> triggerNew 
    * @param Map<Id Case> oldMap 
    **/
    public void caseRouting(List<Case> triggerNew, Map<Id, Case> oldMap) {
        try {
            // Get the utility instance for case routing operations
            CaseRoutingUtility utils = CaseRoutingUtility.getInstance();
            
            // Retrieve the record type ID for "Internal Ticket" cases
            String internalTicketCases = Schema.SObjectType.Case.getRecordTypeInfosByName()
                                        .get('Internal Ticket').getRecordTypeId();
            
            // Maps to hold cases that need routing and cases to avoid during processing
            Map<String, List<Case>> casesToRoute = new Map<String, List<Case>>();
            List<String> casesToAvoid = new List<String>();
    
            // Process each case to determine routing
            processCases(triggerNew, oldMap, utils, internalTicketCases, casesToRoute, casesToAvoid);
            
            // Assign cases to owners based on routing results
            assignCases(triggerNew, utils, casesToAvoid, casesToRoute, internalTicketCases);
            
        } catch (Exception e) {
            // Log the error for debugging purposes
            System.debug('Error: ' + e.getMessage());
            // Consider adding more robust error handling here
        }
    }
    
    /**
     * Processes each case to determine if it should be routed.
     */
    private void processCases(List<Case> triggerNew, Map<Id, Case> oldMap, 
                              CaseRoutingUtility utils, String internalTicketCases,
                              Map<String, List<Case>> casesToRoute, List<String> casesToAvoid) {
        
        for (Case objCase : triggerNew) {
            // Get the sub-category for the case
            String subCategory = getSubCategory(objCase, internalTicketCases);
            
            // Check if the sub-category has changed
            Boolean isSubCategoryChanged = isSubCategoryChanged(objCase, oldMap, internalTicketCases);
    
            // Determine if the case should be routed based on owner or sub-category changes
            Boolean shouldRouteCase = shouldRouteCase(objCase, oldMap, isSubCategoryChanged, utils, subCategory);
            if (shouldRouteCase) {
                if (String.isBlank(objCase.Previous_Owner__c)) {
                    // Route the case if it has no previous owner
                    routeCase(objCase, subCategory, utils, casesToRoute, casesToAvoid);
                } else {
                    // Revert to the previous owner if it exists
                    revertCaseOwnership(objCase);
                }
            }
        }
    }
    
    /**
     * Retrieves the sub-category for a given case based on its record type.
     */
    private String getSubCategory(Case objCase, String internalTicketCases) {
        return objCase.RecordTypeId == internalTicketCases ? 
               objCase.InternalSub_Category__c : objCase.sub_categories__c;
    }
    
    /**
     * Checks if the sub-category has changed for a given case.
     */
    private Boolean isSubCategoryChanged(Case objCase, Map<Id, Case> oldMap, String internalTicketCases) {
        return objCase.RecordTypeId == internalTicketCases ? 
               (objCase.InternalSub_Category__c != oldMap.get(objCase.Id).InternalSub_Category__c) : 
               (objCase.sub_categories__c != oldMap.get(objCase.Id).sub_categories__c);
    }
    
    /**
     * Determines if a case should be routed based on owner changes or sub-category changes.
     */
    private Boolean shouldRouteCase(Case objCase, Map<Id, Case> oldMap, Boolean isSubCategoryChanged,
                                    CaseRoutingUtility utils, String subCategory) {
        System.debug('is OwnerId Changed '+ String.valueOf(objCase.OwnerId != oldMap.get(objCase.Id).OwnerId));
        System.debug('is OwnerId Queue '+ String.valueOf(objCase.OwnerId.getSobjectType() == Group.SobjectType));
        System.debug('is Queue Contains Name '+String.valueOf(utils.objWrapper.mapOfQueueIdVsName.containsKey(objCase.OwnerId)));
        System.debug('is subCategory Blank '+ String.valueOf(String.isNotBlank(subCategory)));
        return (objCase.OwnerId != oldMap.get(objCase.Id).OwnerId || isSubCategoryChanged) &&
               objCase.OwnerId.getSobjectType() == Group.SobjectType &&
               utils.objWrapper.mapOfQueueIdVsName.containsKey(objCase.OwnerId) &&
               String.isNotBlank(subCategory);
    }
    
    /**
     * Routes a case by adding it to the appropriate list based on its owner and sub-category.
     */
    private void routeCase(Case objCase, String subCategory, CaseRoutingUtility utils,
                           Map<String, List<Case>> casesToRoute, List<String> casesToAvoid) {
        String mapKey = CaseRoutingHelper.getMapUniqueKey(objCase.OwnerId, subCategory, utils);
        if (String.isNotBlank(mapKey)) {
            // Add the case to the list for the mapped key
            List<Case> caseList = casesToRoute.containsKey(mapKey) ? casesToRoute.get(mapKey) : new List<Case>();
            caseList.add(objCase);
            casesToRoute.put(mapKey, caseList);
            casesToAvoid.add(objCase.Id); // Mark this case to avoid in future processing
        }
    }
    
    /**
     * Reverts the case ownership to the previous owner and marks it as reassigned.
     */
    private void revertCaseOwnership(Case objCase) {
        objCase.OwnerId = objCase.Previous_Owner__c;
        objCase.Is_Reassigned__c = true;
        objCase.Send_Notification__c = true;
    }
    
    /**
     * Assigns cases to owners based on routing results and updates their owners accordingly.
     */
    private void assignCases(List<Case> triggerNew, CaseRoutingUtility utils,
                             List<String> casesToAvoid, Map<String, List<Case>> casesToRoute,
                             String internalTicketCases) {
        if (!casesToRoute.isEmpty()) {
            // Get the map of user IDs
            Map<String, Id> userIdMap = utils.objWrapper.mapOfNameVsUserId;
            Map<String, Integer> userCaseCount = new Map<String, Integer>();
    
            // Query currently assigned cases that should not be avoided
            List<Case> assignedCases = [SELECT Id, OwnerId FROM Case 
                                        WHERE Id NOT IN :casesToAvoid 
                                        AND Is_Reassigned__c = false 
                                        AND Owner_Change_Date__c = TODAY 
                                        AND OwnerId = :userIdMap.values()];
    
            // Update user case counts based on assigned cases
            for (Case objCase : assignedCases) {
                userCaseCount = CaseRoutingHelper.updateMapUserVsCount(userCaseCount, objCase.OwnerId);
            }
    
            // Update the triggerNew cases with new owner assignments
            updateTriggerNewCases(triggerNew, casesToAvoid, utils, userCaseCount, internalTicketCases);
        }
    }
    
    /**
     * Updates the triggerNew cases with the newly assigned owners based on routing logic.
     */
    private void updateTriggerNewCases(List<Case> triggerNew, List<String> casesToAvoid,
                                        CaseRoutingUtility utils, Map<String, Integer> userCaseCount,
                                        String internalTicketCases) {
        for (Case objCase : triggerNew) {
            if (casesToAvoid.contains(objCase.Id)) {
                // Get the new owner based on routing logic
                objCase.OwnerId = CaseRoutingHelper.getCaseOwnerId(utils, objCase, userCaseCount, internalTicketCases);
                objCase.Previous_Owner__c = objCase.OwnerId; // Set previous owner
                userCaseCount = CaseRoutingHelper.updateMapUserVsCount(userCaseCount, objCase.OwnerId);
                objCase.Send_Notification__c = true; // Mark for notification
            }
        }
    }
    
    @future (callout=true)
    public static void updatePostMyQueryAnsOnStuentZone(String caseId) {
        Case cases = [select id,Response_To_Post_My_Query__c, StudentZone_QueryId__c from Case where id=:caseId];
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(System.Label.Student_Zone_Base_Url+'acads/api/updatePostMyQueryFromSalesforce');
        req.setBody('id='+cases.StudentZone_QueryId__c+'&answer='+cases.Response_To_Post_My_Query__c);
        req.setMethod('POST');
        
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }    
    }
}