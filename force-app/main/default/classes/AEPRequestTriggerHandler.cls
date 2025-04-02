public class AEPRequestTriggerHandler {
    public void AfterInsert(List<AEP_Request__c> triggerNew, map<id, AEP_Request__c> mapAEPRequestOldMap) {
        // AttachLCUser(triggerNew, mapAEPRequestOldMap);
        AutoAssignAEPRequestOnStatusChanged(triggerNew, mapAEPRequestOldMap, 'INSERT');
    }
    public void BeforeUpdate(List<AEP_Request__c> triggerNew, map<id, AEP_Request__c> mapAEPRequestOldMap) {
        // AttachLCUser(triggerNew, mapAEPRequestOldMap);
        //validationForStatus(triggerNew, mapAEPRequestOldMap);
    }
    public void AfterUpdate(List<AEP_Request__c> triggerNew, map<id, AEP_Request__c> mapAEPRequestOldMap) {
        // AttachLCUser(triggerNew, mapAEPRequestOldMap);
        AutoAssignAEPRequestOnStatusChanged(triggerNew, mapAEPRequestOldMap, 'UPDATE');
    }

    // public void AttachLCUser(List<AEP_Request__c> lstAEPRequest, map<id, AEP_Request__c> mapAEPRequestOldMap) {
    //     Map<Id, nm_Centers__c> mapOfIdVsCenter = new Map<Id, nm_Centers__c>();
    //     List<AEP_Request__c> lstAEPRequestToUpdate =new List<AEP_Request__c> ();
    //     Map<String, String> mapOfAEPRequestIdVsAEPId = new Map<String, String>();
    //     Set<String> setOfAEPIdToChangeToAssign = new Set<String>();
    //     Map<String, String> mapOfIdVsLead = new Map<String, String>();nm
    //     Map<String, String> mapOfIdVsAccount = new Map<String, String>();
    //     for (AEP_Request__c objAEPRequest : lstAEPRequest) {
    //         if(String.isBlank(objAEPRequest.User__c)  && String.isNotBlank(objAEPRequest.AEP__c) ) {
    //             mapOfAEPRequestIdVsAEPId.put(objAEPRequest.id, objAEPRequest.AEP__c);
    //         } else if((objAEPRequest.Status__c == 'Escalated to IC' || objAEPRequest.Status__c == 'New')&&( objAEPRequest.Status__c!= mapAEPRequestOldMap.get(objAEPRequest.Id).Status__c)) {
    //             if(String.isNotBlank(arg0))
    //             mapOfIdVsLead.put(objAEPRequest.id, objAEPRequest.AEP__c);
    //             setOfAEPIdToChangeToAssign.add(objAEPRequest.id);
    //         }
    //     }
    //     if(mapOfAEPRequestIdVsAEPId.size() > 0 ) {
    //         mapOfIdVsCenter = new Map<Id, nm_Centers__c>([SELECT Id, OwnerId FROM nm_Centers__c WHERE Id IN :mapOfAEPRequestIdVsAEPId.values()]);
    //     }
    //     if(mapOfIdVsCenter.size() > 0 &&   mapOfAEPRequestIdVsAEPId.size() > 0  ) {
    //         for(String key : mapOfIdVsCenter.keySet()) {
    //             AEP_Request__c objAEp = new AEP_Request__c(id = key);
    //             if(mapOfIdVsCenter.containsKey(mapOfAEPRequestIdVsAEPId.get(key))) {
    //                 objAEp.User__c = mapOfIdVsCenter.get(mapOfAEPRequestIdVsAEPId.get(key)).OwnerId;
    //                 lstAEPRequestToUpdate.add(objAEp);
    //             }
    //         }
    //     }
    //     if(setOfAEPIdToChangeToAssign.size() > 0  ) {
    //         for(String key : setOfAEPIdToChangeToAssign) {
    //             AEP_Request__c objAEp = new AEP_Request__c(id = key);
    //             if(mapOfIdVsCenter.containsKey(mapOfAEPRequestIdVsAEPId.get(key))) {
    //                 objAEp.User__c = mapOfIdVsCenter.get(mapOfAEPRequestIdVsAEPId.get(key)).OwnerId;
    //                 lstAEPRequestToUpdate.add(objAEp);
    //             }
    //         }
    //     }
    //     if(lstAEPRequestToUpdate.size() > 0) {
    //         update lstAEPRequestToUpdate;
    //     }


    // }

    public void validationForStatus(List<AEP_Request__c> lstAEPRequest, map<id, AEP_Request__c> mapAEPRequestOldMap) {
        system.debug('inside validationForStatus');
        List<AEP_Request__c> lstBAep = new List<AEP_Request__c>();
        Set<Id> setOfIds = new Set<Id>();
        Set<Id> setOfAttachmentId = new Set<Id>();

        for (AEP_Request__c objAep : lstAEPRequest) {
            if (objAep.Subject__c == 'Eligibility Exemption' && objAEP.Status__c != mapAEPRequestOldMap.get(objAEP.Id).Status__c 
                && objAEP.Escalate_to_LC__c ==  mapAEPRequestOldMap.get(objAEP.Id).Escalate_to_LC__c 
                ) {
                lstBAep.add(objAep);
                setOfIds.add(objAEP.Id);
            }
        }
        if (lstBAep.size() > 0) {
            for (Attachment attach : [SELECT Id,ParentId  FROM Attachment WHERE ParentId IN :setOfIds]) {
                setOfAttachmentId.add(attach.ParentId);
            }
            for (ContentDocumentLink attach : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setOfIds]) {
                setOfAttachmentId.add(attach.LinkedEntityId);
            }
            for (AEP_Request__c objAEP : lstBAep) {
                if (objAEP.Document_Link__c == null && !setOfAttachmentId.contains(objAEP.Id)) {
                    objAEP.addError('Kindly upload document');
                }
            }
            

        }
    }

    public void AutoAssignAEPRequestOnStatusChanged(List<AEP_Request__c> lstAEPRequest, map<id, AEP_Request__c> mapAEPRequestOldMap, String activity) {
        List<AEP_Request__c> lstAEPRequestToAdd = new List<AEP_Request__c>();
        List<AEP_Request__c> lstAEPRequestToReattachedOwner = new List<AEP_Request__c>();
        Set<String> setOfAepRequestWithCounsellor = new Set<String>();
        List<AEP_Request__c> lstOfAepRequestToUpdate = new List<AEP_Request__c>();
        List<AEP_Request__c> lstOfAepRequestToUpdateHODate = new List<AEP_Request__c>();
        for (AEP_Request__c objAEPRequest : lstAEPRequest) {
            if(objAEPRequest.Status__c == 'Escalated to HO' && ( (activity == 'UPDATE' && objAEPRequest.Status__c!= mapAEPRequestOldMap.get(objAEPRequest.Id).Status__c) || activity == 'INSERT')) {
                if(String.isBlank(String.valueOf(objAEPRequest.Escalated_to_HO_Date__c))) {
                    AEP_Request__c objAEP = new AEP_Request__c(Id =objAEPRequest.Id, Escalated_to_HO_Date__c = Date.Today() );
                    lstOfAepRequestToUpdateHODate.add(objAEP);
                }
                if(objAEPRequest.Admission_Co_ordinator__c == null) {
                    lstAEPRequestToAdd.add(objAEPRequest);
                } else {
                    setOfAepRequestWithCounsellor.add(objAEPRequest.Admission_Co_ordinator__c);
                    lstOfAepRequestToUpdate.add(objAEPRequest);
                }
            }
        }

        Map<Id, Counsellor_Profile__c> mapOfIdVsCounselorProfile = new Map<Id,Counsellor_Profile__c>([SELECT id,AEP_Request_Subject__c,AEP_Request_End_Time__c,AEP_Request_Start_Time__c, OwnerId FROM Counsellor_Profile__c WHERE Id IN :setOfAepRequestWithCounsellor]);

        if(lstOfAepRequestToUpdate.size() > 0) {
            for (AEP_Request__c objAEPRequest: lstOfAepRequestToUpdate) {
                if(mapOfIdVsCounselorProfile.containsKey(objAEPRequest.Admission_Co_ordinator__c)) {
                    AEP_Request__c newObjAepRequest = new AEP_Request__c(Id =objAepRequest.Id );
                    newObjAepRequest.Assign_To__c = mapOfIdVsCounselorProfile.get(objAEPRequest.Admission_Co_ordinator__c).OwnerId;
                    lstAEPRequestToReattachedOwner.add(newObjAepRequest);
                }
            }
        }
        if(lstOfAepRequestToUpdateHODate.size() > 0) {
            update lstOfAepRequestToUpdateHODate;
        }
        
        if(lstAEPRequestToReattachedOwner.size() > 0) {
            update lstAEPRequestToReattachedOwner;
        }
        if(lstAEPRequestToAdd.size() > 0) {
            addAdmissionCoordinate(lstAEPRequestToAdd);
        }
    }

    public void addAdmissionCoordinate(List<AEP_Request__c> lstAEPRequest) {
        List<AEP_Request__c> lstAEPRequestToUpdate = new List<AEP_Request__c>();
        Map<String, List<String>> mapOfSubjectVsLstOfCounsellor = new Map<String, List<String>>();
        Map<String, Integer> mapOfProfileVsCount = new Map<String, Integer>();
        List<AEP_Request__c> lstAssignedAEPRequest = [SELECT id,Admission_Co_ordinator__c,Subject__c,OwnerId FROM AEP_Request__c WHERE Admission_Co_ordinator__r.AEP_Request_Subject__c != null AND  Admission_Co_ordinator__c!=null ANd Escalated_to_HO_Date__c= TODAY];
        List<Counsellor_Profile__c> lstCounselorProfileWithStartAndEndTime = new  List<Counsellor_Profile__c> ();
        Map<Id, Counsellor_Profile__c> lstProfile = new Map<Id,Counsellor_Profile__c>([SELECT id,AEP_Request_Subject__c,OwnerId,AEP_Request_End_Time__c,AEP_Request_Start_Time__c FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office']);
        if(!lstProfile.isEmpty()) {
            for (Counsellor_Profile__c objProfile : lstProfile.values()) {
                if(objProfile.AEP_Request_End_Time__c != null && objProfile.AEP_Request_Start_Time__c != null) {
                    lstCounselorProfileWithStartAndEndTime.add(objProfile);
                }
                String programOffered = objProfile.AEP_Request_Subject__c;
                List<String> lstProgramOffered = String.isNotBlank(programOffered) ? programOffered.split(';') : new List<String>();
                if(lstProgramOffered.size() > 0) {
                    for(String program : lstProgramOffered) {
                        system.debug('program =====> ' + program);
                        List<String> lstProfileId = mapOfSubjectVsLstOfCounsellor.containsKey(program) ? mapOfSubjectVsLstOfCounsellor.get(program) : new List<String>();
                        lstProfileId.add(objProfile.id);
                        mapOfSubjectVsLstOfCounsellor.put(program,lstProfileId);
                    }
                }
            }
            System.debug('mapOfSubjectVsLstOfCounsellor.size() ==>'+mapOfSubjectVsLstOfCounsellor.size());
        }
        
        for (AEP_Request__c objAEep : lstAssignedAEPRequest) {
            mapOfProfileVsCount = updateProfileWithCount(mapOfProfileVsCount, objAEep.Admission_Co_ordinator__c);
        }
        system.debug('mapOfProfileVsCount.toString() =====> ' + mapOfProfileVsCount.toString() );
        String counsellorOwnerIdForStartAndEnd =  AssignCounselorByStartAndEndTime(lstCounselorProfileWithStartAndEndTime);

        system.debug('counsellorOwnerIdForStartAndEnd ====> '+ counsellorOwnerIdForStartAndEnd);

        for (AEP_Request__c objAepRequest : lstAEPRequest) {
            system.debug('objAepRequest ===>' + objAepRequest);
            AEP_Request__c newObjAepRequest = new AEP_Request__c(Id =objAepRequest.Id );
            String subject = objAepRequest.Subject__c;
            List<String> lstProfileWithSubject = mapOfSubjectVsLstOfCounsellor.containsKey(subject) ? mapOfSubjectVsLstOfCounsellor.get(subject) : new List<String>();
            if(lstProfileWithSubject.size() > 0) {
                Map<String, Integer> mapOfMatchSubject = new Map<String, Integer>();
                for (String pro : lstProfileWithSubject) {
                    mapOfMatchSubject.put(pro, mapOfProfileVsCount.containsKey(pro) ?mapOfProfileVsCount.get(pro) : 0);
                }
                system.debug('mapOfMatchSubject --> ' + mapOfMatchSubject);
                String lowestCountTOProfile =new List<String>(mapOfMatchSubject.keySet())[0];
                String setDefaultProfileForNull = null;
                for (String profile : lstProfileWithSubject) {
                    if(mapOfMatchSubject.containsKey(profile)) {
                        lowestCountTOProfile = mapOfMatchSubject.get(profile) < mapOfMatchSubject.get(lowestCountTOProfile) ? profile : lowestCountTOProfile;
                    } else {
                        setDefaultProfileForNull = profile;
                        break;
                    }
                }
                String profileToAttached = String.isNotBlank(setDefaultProfileForNull) ? setDefaultProfileForNull : lowestCountTOProfile;
                if(lstProfile.containsKey(profileToAttached)) {
                    newObjAepRequest.Admission_Co_ordinator__c = profileToAttached;
                    newObjAepRequest.Assign_To__c = lstProfile.get(profileToAttached).OwnerId;
                    lstAEPRequestToUpdate.add(newObjAepRequest);
                    mapOfProfileVsCount = updateProfileWithCount(mapOfProfileVsCount, profileToAttached);
                }
            } else {
                if(String.isNotBlank(counsellorOwnerIdForStartAndEnd)) {
                    newObjAepRequest.Admission_Co_ordinator__c = counsellorOwnerIdForStartAndEnd;
                    newObjAepRequest.Assign_To__c = lstProfile.get(counsellorOwnerIdForStartAndEnd).OwnerId;
                    lstAEPRequestToUpdate.add(newObjAepRequest);

                }
            }
        }

        if(lstAEPRequestToUpdate.size() > 0) {
            update lstAEPRequestToUpdate;
        }

    }

    public Map<String, Integer> updateProfileWithCount(Map<String, Integer> mapOfProfileVsCount, String recordId) {
        Integer Count = mapOfProfileVsCount.containsKey(recordId) ? mapOfProfileVsCount.get(recordId) : 0;
        Count++;
        mapOfProfileVsCount.put(recordId, Count);
        return mapOfProfileVsCount;
    }

    public String AssignCounselorByStartAndEndTime(List<Counsellor_Profile__c> lstCounselor) {
        if(lstCounselor.size() > 0 ) {
            for (Counsellor_Profile__c objCounselor : lstCounselor) {
                DateTime myDateTime = DateTime.now();
                Datetime startDateTime = Datetime.newInstance(Date.today(), objCounselor.AEP_Request_Start_Time__c);
                Datetime endDateTime = Datetime.newInstance(Date.today(), objCounselor.AEP_Request_End_Time__c);
                if(startDateTime >= endDateTime) {
                    system.debug('inside if');
                    endDateTime = endDateTime.addDays(1);
                    if(startDateTime >= myDateTime) {  
                        myDateTime = myDateTime.addDays(1);
                    }
                }
                if(startDateTime <= myDateTime &&  myDateTime<= endDateTime) {
                    return objCounselor.Id;
                }
            }
        }
        return null;
    }
}