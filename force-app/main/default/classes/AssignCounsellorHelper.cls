public class AssignCounsellorHelper {

    public String Group1 = 'Group 1';
    public List<nm_UserMapping__c> lstUserCenterMapping= new List<nm_UserMapping__c>();
    // public Map<Id,nm_UserMapping__c> mapOfCenterIdVsCenterUserMappinghead = new Map<Id,nm_UserMapping__c>();
    public Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = new Map<String,List<nm_UserMapping__c>>();
    // public   Map<String,String> mapOfUserIdVsCenterId = new Map<String,String>();
    // public   Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<Id,nm_Centers__c>();
    public   Map<id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = new Map<id,Counsellor_Profile__c>();
    public   Map<id,List<Counsellor_Profile__c>> mapOfCenterIdVsCounsellor = new Map<id,List<Counsellor_Profile__c>>();

    // public List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
    // public List<Lead> lstLeadWithCounsellor = new List<Lead>();
    // public Map<String, Integer> mapOfCounsellorVsCount = new Map<String, Integer>();
    public Map<String, Integer> mapOfCounsellorIdVsCountLimit = new Map<String, Integer>();


    Map<String, Map<String, List<String>>> mapOfCenterIdVsMapOfProgramVsCounsellorProfile = new Map<String, Map<String, List<String>>>();
    Map<String, Map<String, Integer>> mapOfCenterIdVsMapOfCounsellorProfileVsCount = new Map<String, Map<String, Integer>>();

        public void getLeadWithCounsellor() {
        // Map<id,Counsellor_Profile__c> MapAllCounsellor = getMapAllCounsellor();
        this.mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
        // mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
        // mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
        this.mapOfCounseloridVsCounselorProfile = getMapAllCounsellor();

         Map<Id, List<Counsellor_Profile__c>> mapOfCenterIdVsCounsellor = getMapOfCenterIdVsCounsellor();

         Map<String, Map<String, List<String>>> mapOfCenterIdVsMapOfProgramVsProfile = new Map<String, Map<String, List<String>>>();

         Map<String, Map<String, Integer>> mapOfCenterIdVsMapOfProfileVsCount = new Map<String, Map<String, Integer>>();

         if(!mapOfCenterIdVsCounsellor.isEmpty()) {
             for(Id centerId : mapOfCenterIdVsCounsellor.keySet()) {
                 List<Counsellor_Profile__c> lstOfCounsellor = mapOfCenterIdVsCounsellor.get(centerId);
                 Map<String,List<String>> mapOfProgramVsProfiles = new Map<String,List<String>>();
                 for (Counsellor_Profile__c objCounsellor : lstOfCounsellor) {
                    String programOffered = objCounsellor.nm_ChooseaProgram__c;
                    List<String> lstProgramOffered = String.isNotBlank(programOffered) ? programOffered.split(';') : new List<String>();
                    for(String program : lstProgramOffered) {
                        List<String> lstProfileId = mapOfProgramVsProfiles.containsKey(program) ? mapOfProgramVsProfiles.get(program) : new List<String>();
                        lstProfileId.add(objCounsellor.id);
                        mapOfProgramVsProfiles.put(program,lstProfileId);
                    }

                 }
                 mapOfCenterIdVsMapOfProgramVsProfile.put(centerId, mapOfProgramVsProfiles);
             }
         }
         this.mapOfCenterIdVsMapOfProgramVsCounsellorProfile = mapOfCenterIdVsMapOfProgramVsProfile;
         system.debug('this.mapOfCenterIdVsMapOfProgramVsCounsellorProfile ==> ' + this.mapOfCenterIdVsMapOfProgramVsCounsellorProfile);


        List<Lead> lstLeadAssigned =  [SELECT Id, Counselor_Profile__c, nm_InformationCenter__c	 FROM Lead WHERE Counselor_Profile__c!= null AND CreatedDate= Today AND IsConverted=false AND IsDeleted = false AND nm_InformationCenter__r.GroupName__c = :Group1 ];
        if(lstLeadAssigned.size() > 0) {
            for (Lead objLead : lstLeadAssigned) {
                if(!mapOfCenterIdVsMapOfProfileVsCount.containsKey(objLead.nm_InformationCenter__c)) {
                    mapOfCenterIdVsMapOfProfileVsCount.put(objLead.nm_InformationCenter__c, new Map<String, Integer>());
                }
                Map<String, Integer> mapOfProfileVsCount  = mapOfCenterIdVsMapOfProfileVsCount.get(objLead.nm_InformationCenter__c);
                mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount, objLead.Counselor_Profile__c);
                mapOfCenterIdVsMapOfProfileVsCount.put(objLead.nm_InformationCenter__c, mapOfProfileVsCount);
            }
        }
        System.debug('mapOfCenterIdVsMapOfProfileVsCount ==> ' + mapOfCenterIdVsMapOfProfileVsCount);
        this.mapOfCenterIdVsMapOfCounsellorProfileVsCount = mapOfCenterIdVsMapOfProfileVsCount;
        System.debug('this.mapOfCenterIdVsMapOfCounsellorProfileVsCount ==> ' + this.mapOfCenterIdVsMapOfCounsellorProfileVsCount);

    }

    public Map<String,Integer> updateMapProfileVsCount(Map<String,Integer> mapOfProfileVsCount, String recId) {
        Integer count = mapOfProfileVsCount!= null && mapOfProfileVsCount.containsKey(recId) ? mapOfProfileVsCount.get(recId) : 0;
        count++;
        mapOfProfileVsCount.put(recId,count);
        return mapOfProfileVsCount;
    }

    public String AssignCenterHead(List<nm_UserMapping__c> lstUserMapping, String ownerId) {
        String leadNewOwner = '';
        Boolean isOwnerAlreadyMatched = false;
        if(lstUserMapping.size() > 0) {
            for(nm_UserMapping__c objUserMapping : lstUserMapping) {
                if(objUserMapping.nm_Head__c && objUserMapping.User_Active__c) {
                    if(objUserMapping.nm_User__c == ownerId ) {
                        isOwnerAlreadyMatched = true;
                        break;
                    }
                    leadNewOwner = objUserMapping.nm_User__c;
                }
                
            }

        }
        if(isOwnerAlreadyMatched) {
            return '';
        } else {
            return leadNewOwner;
        }
    }

        public Map<String,List<nm_UserMapping__c>> getMapOfCenterIdVsCenterUserMapping(){
     if(this.mapOfCenterIdVsCenterUserMapping.isEmpty()){
      List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
      system.debug('lstUserCenterMapping --> ' + lstUserCenterMapping);
         if(this.lstUserCenterMapping.size() > 0){
             for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                 if(!this.mapOfCenterIdVsCenterUserMapping.containsKey(objCenteruserMapping.nm_Centers__c)){
                     this.mapOfCenterIdVsCenterUserMapping.put(objCenteruserMapping.nm_Centers__c,new List<nm_UserMapping__c>());
                 }
                //  if(objCenteruserMapping.nm_Head__c)
                //  {
                //    this.mapOfCenterIdVsCenterUserMappinghead.put(objCenteruserMapping.nm_Centers__c,objCenteruserMapping);
                //  }
                 this.mapOfCenterIdVsCenterUserMapping.get(objCenteruserMapping.nm_Centers__c).add(objCenteruserMapping);
             }
         }
     }
     return this.mapOfCenterIdVsCenterUserMapping;
    }

    // public List<nm_Centers__c> getlstActiveCenters(){
    //     if(this.lstActiveCenters.isEmpty()){
    //         String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null and RegistrationClosed__c =false AND GroupName__c = :Group1',null);       
    //          this.mapOfCenterIdVsCenter = new Map<id,nm_Centers__c>((List<nm_Centers__c>)DataBase.query(queryActiveCenters));
    //         this.lstActiveCenters = mapOfCenterIdVsCenter.values() ;
    //         system.debug('lstActiveCenters---query'+lstActiveCenters );
    //     }       
    //     return this.lstActiveCenters;
    // }

    public List<nm_UserMapping__c> getlstUserCenterMapping(){
        if(this.lstUserCenterMapping.isEmpty()){
           system.debug('UserMaping call out');
           String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false AND nm_Centers__r.GroupName__c = :Group1','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name');
            this.lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
        }       
        return this.lstUserCenterMapping;
    }

    public Map<id,Counsellor_Profile__c> getMapAllCounsellor (){
        if(this.mapOfCounseloridVsCounselorProfile.isEmpty()){
            String CounsellorProfile = getQueryAllFieldSql('Counsellor_Profile__c','Name!=null and AEP_Name__r.GroupName__c = :Group1 AND UserIsActive__c = true',null);
               this.mapOfCounseloridVsCounselorProfile = new Map<id,Counsellor_Profile__c>((List<Counsellor_Profile__c>)DataBase.query(CounsellorProfile));
               system.debug('mapOfCounseloridVsCounselorProfile -->'+mapOfCounseloridVsCounselorProfile );
        }       
        return this.mapOfCounseloridVsCounselorProfile;
    }

    // public Map<Id,nm_Centers__c> getMapOfCenterIdVsCenter(){
    //         system.debug('this.mapOfCenterIdVsCenter outside--->'+this.mapOfCenterIdVsCenter );
    //     if(this.mapOfCenterIdVsCenter.isEmpty()){
    //         List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
    //         system.debug('lstActiveCenters--->'+lstActiveCenters );
    //         system.debug('this.mapOfCenterIdVsCenter inside --->'+this.mapOfCenterIdVsCenter );
    //         if(lstActiveCenters.size() > 0 && this.mapOfCenterIdVsCenter.isEmpty()){
    //             for(nm_Centers__c objCenter : lstActiveCenters){
    //                 this.mapOfCenterIdVsCenter.put(objCenter.id,objCenter);
    //             }
    //         }
    //     }
    //     return this.mapOfCenterIdVsCenter;
    // }

    // public Map<String,String> getMapOfUserIdVsCenterId(){
    //     if(this.mapOfUserIdVsCenterId.isEmpty()){
    //       List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
    //         if(this.lstUserCenterMapping.size() > 0){
    //             for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
    //                 this.mapOfUserIdVsCenterId.put(objCenteruserMapping.nm_User__c,objCenteruserMapping.nm_Centers__c);
    //             }
    //         }
    //     }
    //     return this.mapOfUserIdVsCenterId;
    // }

    public Map<Id, List<Counsellor_Profile__c>> getMapOfCenterIdVsCounsellor () {
        if(this.mapOfCenterIdVsCounsellor.isEmpty()) {
            List<Counsellor_Profile__c> lstOfCounsellor = getMapAllCounsellor().values();
            Map<String,Integer> CounsellorIdVsCountLimit = new Map<String,Integer>();
            if(lstOfCounsellor.size() > 0) {
                for (Counsellor_Profile__c objCou : lstOfCounsellor) {
                    if(!this.mapOfCenterIdVsCounsellor.containsKey(objCou.AEP_Name__c)) {
                        this.mapOfCenterIdVsCounsellor.put(objCou.AEP_Name__c, new List<Counsellor_Profile__c>());
                    }
                    this.mapOfCenterIdVsCounsellor.get(objCou.AEP_Name__c).add(objCou);
                    if(String.isNotBlank(String.valueOf(objCou.Max_Lead_Count__c)) && objCou.Max_Lead_Count__c > 0) {
                        CounsellorIdVsCountLimit.put(objCou.Id, Integer.valueOf( objCou.Max_Lead_Count__c));
                    }
                }
            }
            this.mapOfCounsellorIdVsCountLimit = CounsellorIdVsCountLimit;
        }
        return this.mapOfCenterIdVsCounsellor;
    }

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


    public Lead getLeadToUpdate(Lead objLead) {
        if(this.mapOfCenterIdVsMapOfProgramVsCounsellorProfile.containsKey(objLead.nm_InformationCenter__c)) {
                        List<nm_UserMapping__c> lstALLUserMapping = new List<nm_UserMapping__c>();
                        lstALLUserMapping = this.mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                         Map<String, Map<String, Integer>> mapOfCenterIdVsMapOfProfileVsCount = this.mapOfCenterIdVsMapOfCounsellorProfileVsCount;
                        String programName = objLead.nm_ChooseaProgram__c;
                        Map<String, List<String>> mapOfProgramVsLstCounsellor = this.mapOfCenterIdVsMapOfProgramVsCounsellorProfile.get(objLead.nm_InformationCenter__c);
                        Map<String, Integer>  mapOfProfileVsCount = mapOfCenterIdVsMapOfProfileVsCount.get(objLead.nm_InformationCenter__c);
                        if(mapOfProfileVsCount == null) {
                            mapOfProfileVsCount = new Map<String, Integer> ();
                        }
                        system.debug('mapOfProfileVsCount ==> ' + mapOfProfileVsCount);
                        if(mapOfProgramVsLstCounsellor.containsKey(programName)) {
                             List<String> lstProfileId = mapOfProgramVsLstCounsellor.get(programName);
                             List<String> lstProfileAllowed = new List<String>();
                             if(lstProfileId.size() > 0 ) {
                                for (String profileId : lstProfileId) {
                                    if(this.mapOfCounsellorIdVsCountLimit.containsKey(profileId)) {
                                        Integer maxCountAllowed =this.mapOfCounsellorIdVsCountLimit.get(profileId);
                                        Integer NoOfCount = mapOfProfileVsCount != null && mapOfProfileVsCount.containsKey(profileId) ? mapOfProfileVsCount.get(profileId) : 0;
                                        if(NoOfCount < maxCountAllowed) {
                                            lstProfileAllowed.add(profileId);
                                        }
                                    }
                                }
                                system.debug('lstProfileAllowed ==> '+ lstProfileAllowed.toString());

                                if(lstProfileAllowed.size() > 0) {
                                    Lead upLead = new Lead();
                                    upLead.Id = objLead.Id;
                                    system.debug('mapOfProfileVsCount.isEmpty()  ==> '+ mapOfProfileVsCount != null);
                                    if( mapOfProfileVsCount != null && !mapOfProfileVsCount.isEmpty()  ) {
                                        String lowKey = mapOfProfileVsCount.isEmpty() ? null : new List<String>(mapOfProfileVsCount.keySet())[0];
                                        String noKey = null;
                                        for (String profileId : lstProfileAllowed) {
                                             if(mapOfProfileVsCount.containsKey(profileId)) {
                                                 lowKey = mapOfProfileVsCount.containsKey(profileId) && mapOfProfileVsCount.get(profileId) < mapOfProfileVsCount.get(lowKey) ? profileId : lowKey;
                                             }   else {
                                                noKey = profileId;
                                                break;
                                            }                                 
                                        }
                                        upLead.Counselor_Profile__c = String.isNotBlank(noKey) ? noKey : lowKey;

                                    } else {
                                        upLead.Counselor_Profile__c = lstProfileAllowed[0];
                                    }
                                    system.debug('upLead ==> ' + upLead);
                                    mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount, upLead.Counselor_Profile__c);
                                    mapOfCenterIdVsMapOfProfileVsCount.put(objLead.nm_InformationCenter__c, mapOfProfileVsCount);
                                    this.mapOfCenterIdVsMapOfCounsellorProfileVsCount = mapOfCenterIdVsMapOfProfileVsCount;
                                    // leadToUpdate.add(upLead);  
                                    return upLead;
                                } else {
                                    String userMap = AssignCenterHead(lstALLUserMapping, objLead.OwnerId);
                                    if(String.isNotBlank(userMap) ) {
                                        Lead upLead = new Lead(Id = objLead.Id, OwnerId = userMap);
                                        return upLead;
                                        // leadToUpdate.add(upLead);  
                                    }
                                }
                            } else {
                                String userMap = AssignCenterHead(lstALLUserMapping, objLead.OwnerId);
                                if(String.isNotBlank(userMap) ) {
                                    Lead upLead = new Lead(Id = objLead.Id, OwnerId = userMap);
                                    return upLead;
                                    // leadToUpdate.add(upLead);  
                                }
                            }
                            
                        } else {
                            String userMap = AssignCenterHead(lstALLUserMapping, objLead.OwnerId);
                            if(String.isNotBlank(userMap) ) {
                                Lead upLead = new Lead(Id = objLead.Id, OwnerId = userMap);
                                return upLead;
                                // leadToUpdate.add(upLead);  
                            }
                        }
        } else {
                        return null;
        }
        return null;
    }


    // public List<Lead_Assignment__c> getAllLeadAssigned(String AgencyType, String Program) {
    //     return [SELECT Id, Name,Agency_Type__c,Start_Time__c, End_Time__c,Assign_To__c,Assign_To__r.Name,Allotment__c FROM  Lead_Assignment__c WHERE RecordType.Name = 'LC Assignment' AND Choose_a_Program__c includes  (:Program )AND Agency_Type__c = :AgencyType];
    // }

    // public String AssignAgencyByStartAndEndTime(List<Lead_Assignment__c> lstLeadAssignment) {
    //     if(lstLeadAssignment.size() > 0 ) {
    //         for (Lead_Assignment__c objLeadAssign : lstLeadAssignment) {
    //             if(objLeadAssign.Start_Time__c != null && objLeadAssign.End_Time__c != null ) {
    //             DateTime myDateTime = DateTime.now();
    //             Datetime startDateTime = Datetime.newInstance(Date.today(), objLeadAssign.Start_Time__c);
    //             Datetime endDateTime = Datetime.newInstance(Date.today(), objLeadAssign.End_Time__c);
    //             if(startDateTime >= endDateTime) {
    //                 system.debug('inside if');
    //                 endDateTime = endDateTime.addDays(1);
    //                 if(startDateTime >= myDateTime) {  
    //                     myDateTime = myDateTime.addDays(1);
    //                 }
    //             }
    //             if(startDateTime <= myDateTime &&  myDateTime<= endDateTime) {
    //                 return objLeadAssign.Assign_To__r.Name;
    //             }

    //             }
    //         }
    //     }
    //     return null;
    // }

    // public Map<String, Integer> getMaxCountForLeadAssigned(List<Lead_Assignment__c> lstLeadAssignment) {
    //     Map<String,Integer> mapOfMaxCount = new Map<String,Integer>();
    //     Integer baseCount = Integer.valueOf(System.Label.Lead_Assignment_Base);
    //     for (Lead_Assignment__c objLeadAssign : lstLeadAssignment) {
    //         if(objLeadAssign.Start_Time__c == null && objLeadAssign.Allotment__c == null ) {
    //             mapOfMaxCount.put(objLeadAssign.Id,Integer.valueOf(objLeadAssign.Allotment__c /100 * baseCount));
    //         }
    //     }
    //     return mapOfMaxCount;
    // }

    // public void getLstLeadOfAgency(String agencyType, Map<String, Integer> mapOfMaxCount, List<Lead_Assignment__c> lstLeadAssignment) {
    //     Map<String, Integer> leadCountWithAssignment = new Map<String,Integer>();
    //     String agency = agencyType + '_%';
    //     List<Lead> lstLead = [SELECT Id FROM Lead WHERE Agency__c LIKE :agency];
    //     if(lstLead.size() > 0) {
    //       leadCountWithAssignment =  updateLeadAssignmentCount( lstLeadAssignment, mapOfMaxCount);
    //     }
    // }

    // public void updateLeadAssignmentCount(List<Lead_Assignment__c> lstLeadAssignment, Map<String, Integer> mapOfMaxCount, Map<String, Integer> leadCountWithAssignment) {
    //     for (Lead_Assignment__c objLeadAssign : lstLeadAssignment) {
    //         leadCountWithAssignment = getLeadAssignmentCantBeAdded(leadCountWithAssignment, mapOfMaxCount);
    //     }
    //     return leadCountWithAssignment;
    //     // if(!leadCountWithAssignment.isEmpty()) {
    //     //    Integer listSize = availableValues.size() - 1;
    //     //      List<String> availableValues = leadCountWithAssignment.keySet();
    //     //     Integer randomNumber = Integer.valueof((Math.random() * listSize));
    //     //     return availableValues[randomNumber];
    //     // } else {
    //     //     return 'Counsellor';
    //     // }


    // }

    // public Map<String, Integer> getLeadAssignmentCantBeAdded(Map<String, Integer> leadCountWithAssignment, Map<String, Integer> mapOfMaxCount ) {
    //     for (String mapOfMaxCountId : mapOfMaxCount.keySet()) {
    //         Integer count = leadCountWithAssignment.containsKey(mapOfMaxCountId) ? leadCountWithAssignment.get(mapOfMaxCountId) : 0;
    //         count ++;
    //         if(count< mapOfMaxCount.get(mapOfMaxCountId) ) {
    //             leadCountWithAssignment.put(mapOfMaxCountId, count);
    //         } else {
    //             if(leadCountWithAssignment.containsKey(mapOfMaxCountId)) {
    //                 leadCountWithAssignment.remove(mapOfMaxCountId);
    //             }
    //         }
    //     }
    //     return leadCountWithAssignment;

    // }


    
    // public Map<String,Map<String, Integer>> getMaxCountForLC(List<nm_Centers__c> lstLC) {
    //     Map<String, Map<String,Integer>> mapOfAgencyVsMapOfMaxCount = new Map<String, Map<String, Integer>>();
    //     Decimal baseCount = Decimal.valueOf(System.Label.Lead_Assignment_Base);
    //     system.debug('lstLC ===> ' + lstLC);
    //     for (nm_Centers__c objCenter : lstLC) {
    //         if(objCenter.L1_Allotment__c != null) {
    //             if(!mapOfAgencyVsMapOfMaxCount.containsKey('L1')) {
    //                 mapOfAgencyVsMapOfMaxCount.put('L1', new Map<String, Integer>());
    //             }
    //             Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get('L1');
    //             mapOfMaxCount.put(objCenter.Name,Integer.valueOf(Math.ceil(objCenter.L1_Allotment__c /100.0 * baseCount) ));
    //             mapOfAgencyVsMapOfMaxCount.put('L1', mapOfMaxCount);
    //         }
    //         if(objCenter.L2_Allotment__c != null) {
    //             if(!mapOfAgencyVsMapOfMaxCount.containsKey('L2')) {
    //                 mapOfAgencyVsMapOfMaxCount.put('L2', new Map<String, Integer>());
    //             }
    //             Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get('L2');
    //             mapOfMaxCount.put(objCenter.Name,Integer.valueOf(Math.ceil(objCenter.L2_Allotment__c /100.0 * baseCount) ));
    //             mapOfAgencyVsMapOfMaxCount.put('L2', mapOfMaxCount);
                
    //         }
    //         if(objCenter.L3_Allotment__c != null) {
    //             if(!mapOfAgencyVsMapOfMaxCount.containsKey('L3')) {
    //                 mapOfAgencyVsMapOfMaxCount.put('L3', new Map<String, Integer>());
    //             }
    //             Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get('L3');
    //             mapOfMaxCount.put(objCenter.Name,Integer.valueOf(Math.ceil(objCenter.L3_Allotment__c /100.0 * baseCount) ));
    //             mapOfAgencyVsMapOfMaxCount.put('L3', mapOfMaxCount);

    //         }
    //     }
    //     return mapOfAgencyVsMapOfMaxCount;
    // }

    public LeadAssignmentMetadate getMapAgencyTypeFromMetadataVsLabel() {
        Map<String, String> mapOfagencyVsType = new Map<String, String>();
        Map<String, Set<String>> mapOfTypeVsLstAgency = new Map<String, Set<String>>();
        for (Lead_Assignment__c agencyType : [ SELECT id, Agency_List__c, Agency_Internal_Category__c FROM Lead_Assignment__c WHERE Active__c = TRUE AND RecordType.Name = 'Agency Assignment' ]) {
            List<String> lstAgency = String.isNotBlank(agencyType.Agency_List__c) ? agencyType.Agency_List__c.split(';') : new List<String>();
            if(lstAgency.size() > 0) {
                for (String agency : lstAgency) {
                    mapOfagencyVsType.put(agency.trim(), agencyType.Agency_Internal_Category__c);
                    if(!mapOfTypeVsLstAgency.containsKey(agencyType.Agency_Internal_Category__c.trim())) {
                        mapOfTypeVsLstAgency.put(agencyType.Agency_Internal_Category__c.trim(), new Set<String>());
                    }
                    Set<String> setOfAgency = mapOfTypeVsLstAgency.get(agencyType.Agency_Internal_Category__c.trim());
                    setOfAgency.add(agency.trim());
                    mapOfTypeVsLstAgency.put(agencyType.Agency_Internal_Category__c.trim(), setOfAgency);
                }
            }
        }
        LeadAssignmentMetadate LeadAssignmentMetadate = new LeadAssignmentMetadate();
        LeadAssignmentMetadate.mapOfagencyVsType = mapOfagencyVsType;
        LeadAssignmentMetadate.mapOfTypeVsLstAgency = mapOfTypeVsLstAgency;
        return LeadAssignmentMetadate;
    }

    public Map<String, Map<String, Lead_Assignment__c>> getMapLeadAssignmentWithAgency() {
        Map<String, Map<String, Lead_Assignment__c>> mapOfAgencyVsmapOfNameVsAssignment = new Map<String, Map<String, Lead_Assignment__c>>();
        List<Lead_Assignment__c> lstLeadAssignment = [SELECT Id, Agency_Type__c,Choose_a_Program__c,RecordType.Name, Assign_To__c, Assign_To__r.Name, Allotment_PG__c, Allotment_MS__c, Allotment_UG__c, Center_Name__c FROM Lead_Assignment__c WHERE  Assign_To__c!= null AND  Active__c = true AND RecordType.Name = 'LC Assignment'];
        
        for (Lead_Assignment__c objAssignment : lstLeadAssignment) {
            if (!mapOfAgencyVsmapOfNameVsAssignment.containsKey(objAssignment.Agency_Type__c)) {
                mapOfAgencyVsmapOfNameVsAssignment.put(objAssignment.Agency_Type__c, new Map<String, Lead_Assignment__c>());
            }
            Map<String, Lead_Assignment__c> mapOfNameVsAssignment = mapOfAgencyVsmapOfNameVsAssignment.get(objAssignment.Agency_Type__c);
            mapOfNameVsAssignment.put(objAssignment.Assign_To__r.Name, objAssignment);
            mapOfAgencyVsmapOfNameVsAssignment.put(objAssignment.Agency_Type__c, mapOfNameVsAssignment);
        }
        return mapOfAgencyVsmapOfNameVsAssignment;
    }

    public Map<String,Map<String,Lead_Assignment__c>> getMapLeadAssignmentForAEP() {
        Map<String,Map<String,Lead_Assignment__c>> mapOfNameVsAssignment = new Map<String,Map<String,Lead_Assignment__c>>();
        for (Lead_Assignment__c objAssignment : [SELECT Id, From_Center__r.Name, Agency_Type__c,Choose_a_Program__c,RecordType.Name, Assign_To__c, Assign_To__r.Name, Allotment_PG__c, Allotment_MS__c, Allotment_UG__c, Center_Name__c FROM Lead_Assignment__c WHERE From_Center__c != null AND  Assign_To__c!= null AND  Active__c = true AND RecordType.Name = 'AEP Assignment']) {
            if(!mapOfNameVsAssignment.containsKey(objAssignment.From_Center__r.Name)) {
                mapOfNameVsAssignment.put(objAssignment.From_Center__r.Name, new Map<String , Lead_Assignment__c>());
            }
            Map<String, Lead_Assignment__c> mapOfAepVsLeadAllotment = mapOfNameVsAssignment.get(objAssignment.From_Center__r.Name);
            mapOfAepVsLeadAllotment.put(objAssignment.Assign_To__r.Name, objAssignment);
            mapOfNameVsAssignment.put(objAssignment.From_Center__r.Name, mapOfAepVsLeadAllotment);
            // mapOfAepVsLeadAllotment.clear();
        }
        return mapOfNameVsAssignment;
    }

    // public Map<String,Map<String, Integer>> getMaxCountForLC2(Map<String, Lead_Assignment__c> mapOFLeadAssignment,Map<String, Decimal> mapOfBaseCount) {
    //     Map<String, Map<String,Integer>> mapOfAgencyVsMapOfMaxCount = new Map<String, Map<String, Integer>>();
    //     for (Lead_Assignment__c objAssignment : mapOFLeadAssignment.values()) {
    //         for (String family : mapOfBaseCount.keySet()) {
    //             String fieldName = 'Allotment_' + family + '__c';
    //             if( objAssignment.get(fieldName) != null && objAssignment.get(fieldName) != 0) {
    //                 if(!mapOfAgencyVsMapOfMaxCount.containsKey(family)) {
    //                     mapOfAgencyVsMapOfMaxCount.put(family, new Map<String, Integer>());
    //                 }
    //                 Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get(family);
    //                 Decimal count = (decimal) objAssignment.get(fieldName);
    //                 mapOfMaxCount.put(objAssignment.Assign_To__r.Name,Integer.valueOf(Math.ceil(count  /100.0 * mapOfBaseCount.get(family)) ));
    //                 mapOfAgencyVsMapOfMaxCount.put(family, mapOfMaxCount);
    //             }
    //         }
    //     }
    //     return mapOfAgencyVsMapOfMaxCount;
    // }

    public Map<String,Map<String,Map<String, Integer>>> getMaxCountForAgencyVsFamilyVsCenterVsCount(Map<String, Map<String, Lead_Assignment__c>> mapLeadAssignmentWithAgency, Map<String, Map<String, Integer>> mapOfAgencyTypeVsMapOfFamilyVsBaseCount) {
        Map<String,Map<String,Map<String, Integer>>> maxCountForAgencyVsFamilyVsCenterVsCount = new Map<String,Map<String,Map<String, Integer>>>();
        for (String agency : mapLeadAssignmentWithAgency.keySet()) {
            Map<String, Map<String,Integer>> mapOfAgencyVsMapOfMaxCount = new Map<String, Map<String, Integer>>();
           Map<String, Lead_Assignment__c> mapOFLeadAssignment = mapLeadAssignmentWithAgency.get(agency);

            for (Lead_Assignment__c objAssignment : mapOFLeadAssignment.values()) {
                Map<String, Integer> mapOfBaseCount = mapOfAgencyTypeVsMapOfFamilyVsBaseCount.containsKey(agency) ?  mapOfAgencyTypeVsMapOfFamilyVsBaseCount.get(agency) : new Map<String, Integer>();
                for (String family : mapOfBaseCount.keySet()) {
                    String fieldName = 'Allotment_' + family + '__c';
                    if( objAssignment.get(fieldName) != null && objAssignment.get(fieldName) != 0) {
                        if(!mapOfAgencyVsMapOfMaxCount.containsKey(family)) {
                            mapOfAgencyVsMapOfMaxCount.put(family, new Map<String, Integer>());
                        }
                        Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get(family);
                        Decimal count = (decimal) objAssignment.get(fieldName);
                        mapOfMaxCount.put(objAssignment.Assign_To__r.Name,Integer.valueOf(Math.ceil(count  /100.0 * mapOfBaseCount.get(family)) ));
                        mapOfAgencyVsMapOfMaxCount.put(family, mapOfMaxCount);
                    }
                }
            }
            maxCountForAgencyVsFamilyVsCenterVsCount.put(agency, mapOfAgencyVsMapOfMaxCount);
        }
        return maxCountForAgencyVsFamilyVsCenterVsCount;
    }

    public Map<String, Map<String,  Map<String, Integer>>> getMapOfMaxCountForAEP(Map<String,Map<String,Lead_Assignment__c>> mapOfNameVsAssignment, Map<String, Map<String, Decimal>> mapOfBaseCountForAgencyVsAEP) {
        Map<String, Map<String,  Map<String, Integer>>> MapOfMaxCountForAEP = new Map<String, Map<String,  Map<String, Integer>>>();
        if(mapOfNameVsAssignment.keySet().size() > 0) {
            for (String LcName : mapOfNameVsAssignment.keySet()) {
                Map<String,Lead_Assignment__c> mapOFLeadAssignment = mapOfNameVsAssignment.get(LcName);
                Map<String, Map<String,Integer>> mapOfAgencyVsMapOfMaxCount = new Map<String, Map<String, Integer>>();
                for (Lead_Assignment__c objAssignment : mapOFLeadAssignment.values()) {
                    Map<String, Decimal> mapOfBaseCount = mapOfBaseCountForAgencyVsAEP.containsKey(LcName) ? mapOfBaseCountForAgencyVsAEP.get(LcName) : new Map<String, Decimal>();
                    if (mapOfBaseCount.keySet().size() > 0) {
                        for (String family : mapOfBaseCount.keySet()) {
                            String fieldName = 'Allotment_' + family + '__c';
                            if(objAssignment.get(fieldName) != null && objAssignment.get(fieldName) != 0) {
                                if(!mapOfAgencyVsMapOfMaxCount.containsKey(family)) {
                                    mapOfAgencyVsMapOfMaxCount.put(family, new Map<String, Integer>());
                                }
                                Map<String,Integer> mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.get(family);
                                Decimal count = (decimal) objAssignment.get(fieldName);
                                mapOfMaxCount.put(objAssignment.Assign_To__r.Name,Integer.valueOf(Math.ceil(count  /100.0 * mapOfBaseCount.get(family)) ));
                                mapOfAgencyVsMapOfMaxCount.put(family, mapOfMaxCount);
                                MapOfMaxCountForAEP.put(LcName, mapOfAgencyVsMapOfMaxCount);
                                // mapOfMaxCount.clear();
                            }
                        }
                        // mapOfBaseCount.clear();
                    }
                        
                    }
                // mapOfAgencyVsMapOfMaxCount.clear();
                // mapOFLeadAssignment.clear();
            }
        }
        // mapOfNameVsAssignment.clear();
        // mapOfBaseCountForAgencyVsAEP.clear();
        return MapOfMaxCountForAEP;
    }

    // public  set<String> getAllAgencyForType(String agencyType) {
    //     Set<String> setOfAgency = new Set<String>();
    //     if(String.isBlank(agencyType)) {
    //         for (Lead_Assignment_Agency_Type__mdt objLAssignmentType : [SELECT id, Agency_Name_List__c, Label FROM Lead_Assignment_Agency_Type__mdt]) {
    //             for (String  agency : objLAssignmentType.Agency_Name_List__c.split(';')) {
    //                 setOfAgency.add(agency.trim());
    //             }
    //         } 
    //     } else {
    //         for (String agency : [SELECT id, Agency_Name_List__c, Label FROM Lead_Assignment_Agency_Type__mdt WHERE Label = :agencyType LIMIT 1 ][0].Agency_Name_List__c.split(';')) {
    //             setOfAgency.add(agency.trim());
    //         }
    //     }
    //     return setOfAgency;
    // }

   public LeadCount getMapAgencyTypeVsLstLead(String familyType, String agencyType,Map<String, Set<String>> mapOfFamilyVsLstOfprogram ,Map<String, String> mapOfagencyVsType ,Map<String, set<String>> mapOfTypeVsSetAgency, Map<String, String> mapOfProgramVsFamily,Set<String> setActiveAgency) {
    Map<String, Map<String, Integer>> mapOfAgencyTypeVsMapOfFamilyVsBaseCount = new Map<String, Map<String, Integer>>();
    Map<String, Map<String, Map<String, Integer>>> mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount = new Map<String, Map<String, Map<String, Integer>>>();
    
    Map<String, List<Lead>> mapAgencyTypeVsLstLead = new Map<String, List<Lead>>();    
    String queryCon = 'nm_ChooseaProgram__c != null ';
        if(String.isNotBlank(familyType)) {
            Set<String> setOfFamilyProgram = mapOfFamilyVsLstOfprogram.get(familyType);
            queryCon = 'nm_ChooseaProgram__c IN : setOfFamilyProgram';
        }
        String agencyCon = '';
        Set<String> setOfAgency = new Set<String>();
        if (String.isNotBlank(agencyType)) {
            if (agencyType == 'Others') {
                for(String key : mapOfTypeVsSetAgency.keySet()){ {
                    for (String agency : mapOfTypeVsSetAgency.get(key)) {
                        setOfAgency.add(agency);
                        }
                    }
                }
                agencyCon = ' Agency__c NOT IN : setOfAgency AND ';
            } else {
                setOfAgency = mapOfTypeVsSetAgency.get(agencyType);
                agencyCon = ' Agency__c IN : setOfAgency AND ';
            }
        } 
        // else {
        //     for(String key : mapOfTypeVsSetAgency.keySet()){ {
        //         for (String agency : mapOfTypeVsSetAgency.get(key)) {
        //             setOfAgency.add(agency);
        //             }
        //         }
        //     }
        // }
        // agencyCon = 'Agency__c IN : setOfAgency';
        Map<String, Integer>  mapOfLeadCount = new Map<String, Integer>();
        String query = 'SELECT Id,Name,Agency__c,nm_ChooseaProgram__c,  LC_name__c FROM Lead WHERE ' + agencyCon + ' '+ queryCon +'  AND LeadSource!= \'Partner\'  AND (LC_Wise_Marketing_Distribution_Date__c = Today OR (CreatedDate = Today AND CreatedBy.Name = \'marketing ngasce\'))';
        system.debug('query ---> ' + query);
        // List<Lead> lstLead = Database.query(query);
        for (Lead objLead : Database.query(query)) {
            String agencyName = String.isNotBlank(objLead.Agency__c) ? objLead.Agency__c.trim() : null;
            String chooseProgram = objLead.nm_ChooseaProgram__c.trim();
            String agencyInternalCategory = String.isNotBlank(agencyName) && mapOfagencyVsType.containsKey(agencyName) ? mapOfagencyVsType.get(agencyName) : 'Others';
            if (mapOfProgramVsFamily.containsKey(chooseProgram)) {
                // Base Count
                if (!mapOfAgencyTypeVsMapOfFamilyVsBaseCount.containsKey(agencyInternalCategory)) {
                    mapOfAgencyTypeVsMapOfFamilyVsBaseCount.put(agencyInternalCategory, new Map<String, Integer>());
                }
                Map<String, Integer> MapOfFamilyVsBaseCount = mapOfAgencyTypeVsMapOfFamilyVsBaseCount.get(agencyInternalCategory);
                if (!MapOfFamilyVsBaseCount.containsKey(mapOfProgramVsFamily.get(chooseProgram))) {
                    MapOfFamilyVsBaseCount.put(mapOfProgramVsFamily.get(chooseProgram), 0);
                }
                Integer baseCount =  MapOfFamilyVsBaseCount.get(mapOfProgramVsFamily.get(chooseProgram));
                baseCount ++;
                MapOfFamilyVsBaseCount.put(mapOfProgramVsFamily.get(chooseProgram), baseCount);
                mapOfAgencyTypeVsMapOfFamilyVsBaseCount.put(agencyInternalCategory, MapOfFamilyVsBaseCount);

                // Lead Count
                if (!mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.containsKey(agencyInternalCategory)) {
                    mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.put(agencyInternalCategory, new Map<String, Map<String, Integer>>());
                }
                Map<String, Map<String, Integer>> MapFamilyVsCenterVsLeadCount = mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.get(agencyInternalCategory);
                if (!MapFamilyVsCenterVsLeadCount.containsKey(mapOfProgramVsFamily.get(chooseProgram))) {
                    MapFamilyVsCenterVsLeadCount.put(mapOfProgramVsFamily.get(chooseProgram), new Map<String, Integer>());
                }
                Map<String, Integer> mapOfCenterVsLeadCount = MapFamilyVsCenterVsLeadCount.get(mapOfProgramVsFamily.get(chooseProgram));
                if (objLead.LC_name__c != 'Counsellor' && String.isNotBlank(objLead.LC_name__c)) {
                    String family = mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c);
                    if(!MapFamilyVsCenterVsLeadCount.containsKey(family)) {
                        MapFamilyVsCenterVsLeadCount.put(family, new Map<String, Integer>());
                    }
                    mapOfCenterVsLeadCount = MapFamilyVsCenterVsLeadCount.get(family);
                    mapOfCenterVsLeadCount= updateLeadAllotmentCount( mapOfCenterVsLeadCount, objLead.LC_name__c);
                    MapFamilyVsCenterVsLeadCount.put(family, mapOfCenterVsLeadCount);
                }
                mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.put(agencyInternalCategory, MapFamilyVsCenterVsLeadCount);
            }
        }
        Map<String, Map<String, Integer>> TrueMapOfAgencyVsMapOfFamilyBaseCount = new Map<String, Map<String, Integer>>();

        for (String agencyNewType : setActiveAgency) {
            if (!TrueMapOfAgencyVsMapOfFamilyBaseCount.containsKey(agencyNewType)) {
                TrueMapOfAgencyVsMapOfFamilyBaseCount.put(agencyNewType, new Map<String, Integer>());
            }

            Map<String, Integer> TrueMapOfFamilyBaseCount =  TrueMapOfAgencyVsMapOfFamilyBaseCount.get(agencyNewType);
            Map<String, Integer> mapOfBaseCount = mapOfAgencyTypeVsMapOfFamilyVsBaseCount.containsKey(agencyNewType) ? mapOfAgencyTypeVsMapOfFamilyVsBaseCount.get(agencyNewType) : new Map<String, Integer>();
            for (String family : mapOfFamilyVsLstOfprogram.keySet()) {
                TrueMapOfFamilyBaseCount.put(family, mapOfBaseCount.containsKey(family) ? mapOfBaseCount.get(family) : 0);
            }
            TrueMapOfAgencyVsMapOfFamilyBaseCount.put(agencyNewType, TrueMapOfFamilyBaseCount);
        }
        LeadCount LeadCount = new LeadCount();
        LeadCount.mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount = mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount;
        LeadCount.mapOfAgencyTypeVsMapOfFamilyVsBaseCount = TrueMapOfAgencyVsMapOfFamilyBaseCount;
        return LeadCount;
    }


   public List<Lead> getLstLeadOfForAllAEP(String chooseProgram) {

        String agencyL1 =  'L1_%';
        String agencyL2 =  'L2_%';
        String agencyL3 =  'L3_%';
        String onlyCen = '';
        String aepAllotmentLc = System.Label.Lead_Assignment_For_AEP;
        if(String.isNotBlank(aepAllotmentLc)) {
            List<String> lstCe = aepAllotmentLc.split(';');
            onlyCen = ' AND LC_Name__c IN : lstCe ';
        }
        String queryCon = 'nm_ChooseaProgram__c != null ';
        if(String.isNotBlank(chooseProgram)) {
            queryCon = 'nm_ChooseaProgram__c = \'' + chooseProgram + '\'';
        }
        Map<String, Integer>  mapOfLeadCount = new Map<String, Integer>();
        String query = 'SELECT Id,Name,Agency__c,nm_ChooseaProgram__c,nm_InformationCenter__r.CenterName__c, nm_InformationCenter__c,nm_InformationCenter__r.Name, nm_InformationCenter__r.RecordType.Name,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.nm_LearningCenter__r.Name  FROM Lead WHERE (Agency__c LIKE :agencyL1 OR Agency__c LIKE :agencyL2 OR Agency__c LIKE :agencyL3) AND '+ queryCon +' AND nm_InformationCenter__r.Name != \'Counsellor\' AND nm_InformationCenter__c != null  AND CreatedDate = Today ' + onlyCen;
        return Database.query(query);
        // return [SELECT Id,Name,Agency__c,nm_ChooseaProgram__c, nm_InformationCenter__c,nm_InformationCenter__r.Name, nm_InformationCenter__r.RecordType.Name,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.nm_LearningCenter__r.Name  FROM Lead WHERE (Agency__c LIKE :agencyL1 OR Agency__c LIKE :agencyL2 OR Agency__c LIKE :agencyL3) AND nm_ChooseaProgram__c != null AND CreatedDate = Today ];
    }




    public Map<String, Integer>  updateLeadAllotmentCount(Map<String, Integer>  mapOfLeadCount,String recordId) {
        Integer Count = mapOfLeadCount.containsKey(recordId) ? mapOfLeadCount.get(recordId) : 0;
        Count++;
        mapOfLeadCount.put(recordId, Count);
        return mapOfLeadCount;
    }

    // public Map<String, Map<String, Map<String, Integer>>> getMapOfAgencyTypeMapAgencyVsMapOfLeadCount(Map<String, List<Lead>> mapAgencyTypeVsLstLead, Map<String, String> mapOfProgramVsFamily) {
    //     Map<String, Map<String, Map<String, Integer>>> mapOfAgencyTypeMapAgencyVsMapOfLeadCount = new Map<String, Map<String, Integer>>();
    //     if (!mapAgencyTypeVsLstLead.isEmpty()) {
    //         for (String agency : mapAgencyTypeVsLstLead) {
    //             List<Lead> lstLead = mapAgencyTypeVsLstLead.get(agency);
    //             Map<String, Map<String, Integer>> mapOfAgencyVsMapOfLeadCount = new Map<String, Map<String, Integer>>();
    //             if (lstLead != null && lstLead.size() > 0) {
    //                 for (Lead objLead : lstLead) {
    //                     if(objLead.nm_InformationCenter__r.Name != 'Counsellor' && String.isNotBlank(objLead.nm_InformationCenter__r.Name) ) {
    //                         Map<String, Integer>  mapOfLeadCount = new Map<String, Integer>();
    //                         String family = mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c);
    //                         if(!mapOfAgencyVsMapOfLeadCount.containsKey(family)) {
    //                             mapOfAgencyVsMapOfLeadCount.put(family, new Map<String, Integer>());
    //                         }
    //                         mapOfLeadCount = mapOfAgencyVsMapOfLeadCount.get(family);
    //                         if(objLead.nm_InformationCenter__r.nm_LearningCenter__c != null) {
    //                         mapOfLeadCount= updateLeadAllotmentCount( mapOfLeadCount,  objLead.nm_InformationCenter__r.nm_LearningCenter__r.Name);
    //                         } else {
    //                             mapOfLeadCount= updateLeadAllotmentCount( mapOfLeadCount, objLead.nm_InformationCenter__r.Name);
    //                         }
    //                         mapOfAgencyVsMapOfLeadCount.put(family, mapOfLeadCount);
    //                     }
    //                 }
    //             } else {

    //             }
    //             mapOfAgencyTypeMapAgencyVsMapOfLeadCount.put(arg0, arg1);
    //         }
    //     }


        // if(lstLead.size() > 0) {
        //      for (Lead objLead : lstLead) {
        //         if(objLead.nm_InformationCenter__r.Name != 'Counsellor') {
        //             Map<String, Integer>  mapOfLeadCount = new Map<String, Integer>();
        //             String agency2 = mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c);
        //             if(!mapOfAgencyVsMapOfLeadCount.containsKey(agency2)) {
        //                 mapOfAgencyVsMapOfLeadCount.put(agency2, new Map<String, Integer>());
        //             }
        //             mapOfLeadCount = mapOfAgencyVsMapOfLeadCount.get(agency2);
        //             if(objLead.nm_InformationCenter__r.nm_LearningCenter__c != null) {
        //                mapOfLeadCount= updateLeadAllotmentCount( mapOfLeadCount,  objLead.nm_InformationCenter__r.nm_LearningCenter__r.Name);
        //             } else {
        //                 mapOfLeadCount= updateLeadAllotmentCount( mapOfLeadCount, objLead.nm_InformationCenter__r.Name);
        //             }
        //             mapOfAgencyVsMapOfLeadCount.put(agency2, mapOfLeadCount);
        //         }
        //     }
        // }
        // return mapOfAgencyVsMapOfLeadCount;
    // }

    public Map<String, Map<String, Map<String , Integer>>> getMapOFAgencyVsAEPCount(List<Lead> lstLead,  Map<String, String> mapOfProgramVsFamily) {
         Map<String, Map<String, Map<String , Integer>>> MapOFAgencyVsAEPCount = new Map<String, Map<String, Map<String , Integer>>>();
         if(lstLead.size() > 0)  {
            for (Lead objLead : lstLead) {
                if(mapOfProgramVsFamily.containsKey(objLead.nm_ChooseaProgram__c) && objLead.nm_InformationCenter__r.RecordType.Name == 'Information Center') {
                    String lcName = objLead.nm_InformationCenter__r.CenterName__c;
                    String agency2 = mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c);
                    if (!MapOFAgencyVsAEPCount.containsKey(lcName)) {
                        MapOFAgencyVsAEPCount.put(lcName, new Map<String, Map<String , Integer>>());
                    }
                    Map<String, Map<String , Integer>> mapOfLcVsAepCount = MapOFAgencyVsAEPCount.get(lcName);
                    if (!mapOfLcVsAepCount.containsKey(agency2)) {
                        mapOfLcVsAepCount.put(agency2, new Map<String , Integer>());
                    }
                    Map<String, Integer>  mapOfLeadCount = mapOfLcVsAepCount.get(agency2);
                    mapOfLeadCount= updateLeadAllotmentCount( mapOfLeadCount, objLead.nm_InformationCenter__r.Name);
                    mapOfLcVsAepCount.put(agency2, mapOfLeadCount);
                    MapOFAgencyVsAEPCount.put(lcName, mapOfLcVsAepCount);
                    // mapOfLeadCount.clear();
                    // mapOfLcVsAepCount.clear();
                }
            }
         }
        //  lstLead.clear();
        //  mapOfProgramVsFamily.clear();
         return MapOFAgencyVsAEPCount;
    }


    // public  Map<String, Decimal> getBaseCountForAgency(List<Lead > lstLead, Map<String, String> mapOfProgramVsFamily) {
    //     Map<String, Decimal> mapOfBaseCount = new Map<String, Decimal>();
    //     Set<String> setOfFamily = new Set<String>(mapOfProgramVsFamily.values());
    //     if(lstLead.size() > 0) {
    //          for (Lead objLead : lstLead) {
    //                 String agency2 =  mapOfProgramVsFamily.containsKey(objLead.nm_ChooseaProgram__c)? mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c) : null ;
    //                 if(String.isNotBlank(agency2)) {
    //                     if(!mapOfBaseCount.containsKey(agency2)) {
    //                         mapOfBaseCount.put(agency2, 0);
    //                     }
    //                     Decimal count = mapOfBaseCount.get(agency2);
    //                     count++;
    //                     mapOfBaseCount.put(agency2, count);
    //                 }
    //             }
    //     }
    //     for (String family : setOfFamily) {
    //         mapOfBaseCount.put(family, mapOfBaseCount.containsKey(family) ? mapOfBaseCount.get(family) : 0);
    //     }
    //     return mapOfBaseCount;
    // }

    public Map<String, Map<String, Decimal>> getBaseCountForAgencyVsAEP(List<Lead > lstLead, Map<String, String> mapOfProgramVsFamily) {
        Map<String, Map<String, Decimal>> mapOfBaseCountForAgencyVsAEP = new Map<String, Map<String, Decimal>>();
        Set<String> setOfFamily = new Set<String>(mapOfProgramVsFamily.values());
        if(lstLead.size() > 0 ) {
            for (Lead objLead : lstLead) {
                String lcName = objLead.nm_InformationCenter__r.CenterName__c;
                if(!mapOfBaseCountForAgencyVsAEP.containsKey(lcName)) {
                    mapOfBaseCountForAgencyVsAEP.put(lcName, new Map<String, Decimal>());
                }
                Map<String, Decimal> mapOfBaseCount = mapOfBaseCountForAgencyVsAEP.get(lcName);
                String agency2 =  mapOfProgramVsFamily.containsKey(objLead.nm_ChooseaProgram__c)? mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c) : null ;
                    if(String.isNotBlank(agency2)) {
                        if(!mapOfBaseCount.containsKey(agency2)) {
                            mapOfBaseCount.put(agency2, 0);
                        }
                        Decimal count = mapOfBaseCount.get(agency2);
                        count++;
                        mapOfBaseCount.put(agency2, count);
                        mapOfBaseCountForAgencyVsAEP.put(lcName, mapOfBaseCount);
                        // mapOfBaseCount.clear();
                    }
            }
        }
        // lstLead.clear();
        for (String lcName : mapOfBaseCountForAgencyVsAEP.keySet()) {
             Map<String, Decimal> mapOfBaseCount = mapOfBaseCountForAgencyVsAEP.get(lcName);
             for (String family : setOfFamily) {
                mapOfBaseCount.put(family, mapOfBaseCount.containsKey(family) ? mapOfBaseCount.get(family) : 0);
                mapOfBaseCountForAgencyVsAEP.put(lcName, mapOfBaseCount);
            }
            // mapOfBaseCount.clear();
        }
        return mapOfBaseCountForAgencyVsAEP;
    }





    public String  getCenterForLeadThroughAllotment(Map<String, Integer> mapOfLeadCount, Map<String, Integer> mapOfMaxCount, String selectedLearningCenterName) {
        List<String> lstCenterCanBeAdded = new List<String>();
        String centerToAttached = null;
        if(!mapOfLeadCount.isEmpty()) {
            for (String centerId : mapOfMaxCount.keySet()) {
                if(mapOfLeadCount.containsKey(centerId)   ) {
                    if(mapOfMaxCount.get(centerId) >mapOfLeadCount.get(centerId)) {
                        lstCenterCanBeAdded.add(centerId);
                    }
                } else {
                    lstCenterCanBeAdded.add(centerId);

                }
            } 
        } else {
            // lstCenterCanBeAdded.add(String.isNotBlank(selectedLearningCenterName) ? selectedLearningCenterName : new List<String>(mapOfMaxCount.keySet())[0]);
            if (String.isNotBlank(selectedLearningCenterName) && mapOfMaxCount.containsKey(selectedLearningCenterName) ) {
                lstCenterCanBeAdded.add(selectedLearningCenterName);
            } else if(!mapOfMaxCount.isEmpty()) {
                lstCenterCanBeAdded.add(new List<String>(mapOfMaxCount.keySet())[0]);
            }
        }

        if(lstCenterCanBeAdded.size() > 1) {
            if(String.isNotBlank(selectedLearningCenterName) && lstCenterCanBeAdded.contains(selectedLearningCenterName)) {
                centerToAttached = selectedLearningCenterName;
            } else {
                String lowestCountTOAdd = lstCenterCanBeAdded.size() == 0 ? null : lstCenterCanBeAdded[0];
                   String setDefaultId = null;
                   for (String centerId : lstCenterCanBeAdded) {
                       if(mapOfLeadCount.containsKey(centerId)) {
                           lowestCountTOAdd = mapOfLeadCount.get(centerId) < mapOfLeadCount.get(lowestCountTOAdd) ? centerId : lowestCountTOAdd;
                       } else {
                           setDefaultId = centerId;
                           break;
                       }
                   }
                centerToAttached = String.isNotBlank(setDefaultId) ? setDefaultId : lowestCountTOAdd;
            }
        } else if(lstCenterCanBeAdded.size() == 1) {
            centerToAttached = lstCenterCanBeAdded[0];
        } else {
            centerToAttached = 'Counsellor';
        }
        // mapOfLeadCount.clear();
        return centerToAttached;
    }

    public class LeadAssignmentMetadate {
        public Map<String, String> mapOfagencyVsType {get; set;}
        public Map<String, set<String>> mapOfTypeVsLstAgency {get; set;}
        public LeadAssignmentMetadate() {
            mapOfagencyVsType = new Map<String, String>();
            mapOfTypeVsLstAgency = new Map<String, set<String>>();
        }
    }

    public Map<String, String> getMapOfProgramVsFamily() {
        Map<String, String> mapOfProgramVsFamily = new Map<String, String>();
        mapOfProgramVsFamily.put('Certificate Programs', 'PG');
        mapOfProgramVsFamily.put('Diploma Programs', 'PG');
        mapOfProgramVsFamily.put('Post Graduate Diploma Programs', 'PG');
        mapOfProgramVsFamily.put('MBA (Distance) Programs', 'PG');
        mapOfProgramVsFamily.put('Professional Programs', 'MS');
        mapOfProgramVsFamily.put('Master Programs', 'MS');
        mapOfProgramVsFamily.put('Bachelor Programs', 'UG');
        return mapOfProgramVsFamily;
    }

    public class FamilyOfProgram {
        public Map<String, String> mapOfProgramVsFamily {get; set;}
        public Map<String, set<String>> mapOfFamilyVsSetOfProgram {get; set;}
        public FamilyOfProgram() {
            mapOfProgramVsFamily =  getMapOfProgramVsFamily();
            mapOfFamilyVsSetOfProgram = getMapOfFamilyVsLstOfprogram();
        }
        public Map<String, String> getMapOfProgramVsFamily() {
            Map<String, String> mapOfProgramVsFamily = new Map<String, String>();
            mapOfProgramVsFamily.put('Certificate Programs', 'PG');
            mapOfProgramVsFamily.put('Diploma Programs', 'PG');
            mapOfProgramVsFamily.put('Post Graduate Diploma Programs', 'PG');
            mapOfProgramVsFamily.put('MBA (Distance) Programs', 'PG');
            mapOfProgramVsFamily.put('Professional Programs', 'MS');
            mapOfProgramVsFamily.put('Master Programs', 'MS');
            mapOfProgramVsFamily.put('Bachelor Programs', 'UG');
            return mapOfProgramVsFamily;
        }
    
        public Map<String, Set<String>> getMapOfFamilyVsLstOfprogram() {
            Map<String, Set<String>> MapOfFamilyVsLstOfprogram = new Map<String, Set<String>>();
             MapOfFamilyVsLstOfprogram.put('PG', new Set<String>{'Certificate Programs', 'Diploma Programs', 'Post Graduate Diploma Programs', 'MBA (Distance) Programs'});
             MapOfFamilyVsLstOfprogram.put('UG', new Set<String>{'Bachelor Programs'});
             MapOfFamilyVsLstOfprogram.put('MS', new Set<String>{'Master Programs'});
            return MapOfFamilyVsLstOfprogram;
    
        }
    }

    public class LeadCount {
        public Map<String, Map<String, Integer>> mapOfAgencyTypeVsMapOfFamilyVsBaseCount {get; set;}
        public Map<String, Map<String, Map<String, Integer>>> mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount {get; set;}
        public LeadCount() {
            mapOfAgencyTypeVsMapOfFamilyVsBaseCount = new Map<String, Map<String, Integer>>();
            mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount = new Map<String, Map<String, Map<String, Integer>>>();
        }
    }


    // public Map<String, Integer> getLeadAssignmentCantBeAdded(Map<String, Integer> leadCountWithAssignment, Map<String, Integer> mapOfMaxCount ) {
    //     for (String mapOfMaxCountId : mapOfMaxCount.keySet()) {
    //         Integer count = leadCountWithAssignment.containsKey(mapOfMaxCountId) ? leadCountWithAssignment.get(mapOfMaxCountId) : 0;
    //         count ++;
    //         if(count< mapOfMaxCount.get(mapOfMaxCountId) ) {
    //             leadCountWithAssignment.put(mapOfMaxCountId, count);
    //         } else {
    //             if(leadCountWithAssignment.containsKey(mapOfMaxCountId)) {
    //                 leadCountWithAssignment.remove(mapOfMaxCountId);
    //             }
    //         }
    //     }
    //     return leadCountWithAssignment;

    // }


}