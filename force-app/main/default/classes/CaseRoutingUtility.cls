/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 29-11-2024
 * @last modified by  : @BK
**/
public without sharing class CaseRoutingUtility {

    private static CaseRoutingUtility utils { get; private set; }
    public UtlityWrapper objWrapper {get; private set;}

    public CaseRoutingUtility() {
        this.objWrapper = new UtlityWrapper();
        this.objWrapper = getRoutingMap();
    }

    public static CaseRoutingUtility getInstance() {
        if(utils == null) {
            utils = new CaseRoutingUtility();
        }
        return utils;
    }

    /**
    * @description 
    * @author @BK | 25-10-2023 
    * @param m1 
    * @param m2 
    * @return String[] 
    **/
    public String[] combineStrings(String[] m1, String[] m2) {
        Set<String> unqiueUsers = new Set<String> ();
        unqiueUsers.addAll(m1);
        unqiueUsers.addAll(m2);
        return new List<String>(unqiueUsers);
    }

    /**
    * @description 
    * @author @BK | 26-10-2023 
    * @return Map<String, String[]> 
    **/
    public UtlityWrapper getRoutingMap() {
        UtlityWrapper objWrapperV2 = new UtlityWrapper();
        objWrapperV2.mapOfQueueIdVsName = new Map<Id,String>();
        objWrapperV2.mapOfAllQueueIdVsName = new Map<Id,String>();
        List<String> queueNames = new List<String>(); 
        Map<String,String[]> caseRotuingMap = new Map<String,String[]>();
        MapWrapper objMapWrapper = getUserNameVsId();
        objWrapperV2.mapOfNameVsUserId = objMapWrapper.mapOfNameVsUserId;
        objWrapperV2.mapOfUserIdCPVsName = objMapWrapper.mapOfUserIdCPVsName;
        objWrapperV2.setOfSAUserIds = objMapWrapper.setOfSAUserIds;
        objWrapperV2.mapOfCPNameVsUserId = objMapWrapper.mapOfCPNameVsUserId;
        objWrapperV2.lstRoles = objMapWrapper.lstRoles;
        objWrapperV2.mapOfCategoryVsUserId = objMapWrapper.mapOfCategoryVsUserId;
        for (Case_Routing__c objCR : [SELECT id,Admission_Sub_Category__c,User__c,Queue_Name__c FROM Case_Routing__c WHERE isActive__c=true AND User__c!=null]) {
            String[] categoryValues = objCR.Admission_Sub_Category__c!=null ? objCR.Admission_Sub_Category__c.split(';') : new List<String>();
            String[] userValues = getUserIds(objWrapperV2.mapOfNameVsUserId, objCR.User__c);
            queueNames.add(objCR.Queue_Name__c);
            if(categoryValues.size() > 0) {
                for (String mapKey : categoryValues) {
                    String uniqueKey = mapKey + '_' + objCR.Queue_Name__c;
                    caseRotuingMap.put(uniqueKey,getUserValues(userValues,uniqueKey,caseRotuingMap));
                }
            } else {
                String uniqueKey = 'All_' + objCR.Queue_Name__c;
                caseRotuingMap.put(uniqueKey,getUserValues(userValues,uniqueKey,caseRotuingMap));
            }
        }
        objWrapperV2.caseRotuingMap = caseRotuingMap;
        if(queueNames.size() > 0){
            MapQueueWrapper objQWrapper = getQueues(queueNames);
            objWrapperV2.mapOfQueueIdVsName = objQWrapper.mapOfQueueIdVsName;
            objWrapperV2.mapOfAllQueueIdVsName = objQWrapper.mapOfAllQueueIdVsName;
        }
        return objWrapperV2;
    }

    /**
    * @description 
    * @author @BK | 24-02-2024 
    * @return MapQueueWrapper 
    **/
    public MapQueueWrapper getQueues(List<String> queueNames) {
        MapQueueWrapper objQWrapper = new MapQueueWrapper();
        objQWrapper.mapOfQueueIdVsName = new Map<Id,String>();
        objQWrapper.mapOfAllQueueIdVsName = new Map<Id,String>();
        List<Group> lstQueues = [SELECT Id,Name,DeveloperName,Email,Type FROM Group WHERE Type='Queue'];
        for (Group objGQ : lstQueues) {
            if(queueNames.contains(objGQ.Name)) {
                objQWrapper.mapOfQueueIdVsName.put(objGQ.Id,objGQ.Name);
            }
            objQWrapper.mapOfAllQueueIdVsName.put(objGQ.Id,objGQ.Name);
        }
        return objQWrapper;
    }

    /**
    * @description 
    * @author @BK | 12-25-2023 
    * @param userValues 
    * @param uniqueKey 
    * @param caseRotuingMap 
    * @return String[] 
    **/
    public String[] getUserValues(String[] userValues, String uniqueKey, Map<String,String[]> caseRotuingMap) {
        String[] exisitngValues = !caseRotuingMap.containsKey(uniqueKey) ? new List<String>() : caseRotuingMap.get(uniqueKey);
        if(exisitngValues.size() > 0) {
            return combineStrings(userValues,exisitngValues);
        } else {
            return userValues;
        }
    }

    /**
    * @description 
    * @author @BK | 12-25-2023 
    * @return Map<String, Id> 
    **/
    public MapWrapper getUserNameVsId() {
        MapWrapper objMapWrapper = new MapWrapper();
        objMapWrapper.mapOfNameVsUserId = new Map<String,Id>();
        objMapWrapper.mapOfCPNameVsUserId = new Map<String,Id>();
        objMapWrapper.mapOfUserIdCPVsName = new Map<Id,String>();
        objMapWrapper.setOfSAUserIds = new Set<Id>();
        objMapWrapper.mapOfCategoryVsUserId = new Map<String,Id>();
        List<String> lstProfileNames = new List<String>{'Head Office Community','Head Office','Counsellor','Super Admin'};
        List<String> lstSuperAdmins = new List<String>{'Sangeeta Shetty','Farah Shaikh','Neeta Vichare','Hemal doshi','Khushboo Thakkar'};

        Map<String,String> mapUserNamesVsCategory = new Map<String,String>{
            'Finance Department' => 'Finance',
            'Mihhiir Lakhani' => 'Marketing' ,
            'Admission Dept.' => 'Admissions',
            'Ngasce Exams' => 'Internal Exam',
            'NCDOE Exams - University' => 'TEE',
            'Ngasce Academics' => 'Academics',
            'Varun Mathur' => 'Career Services',
            'Likesh Bhambhwani' => 'Product',
            'Logistics Department' => 'Logistics',
            'Sangeeta Shetty' => 'Student Support',
            'LC Mumbai' => 'LC Mumbai',
            'LC Lucknow' => 'LC Lucknow',
            'LC Chandigarh' => 'LC Chandigarh',
            'LC Ahmedabad' => 'LC Ahmedabad',
            'LC Hyderabad' => 'LC Hyderabad',
            'LC Indore' => 'LC Indore',
            'LC Bangalore' => 'LC Bangalore',
            'LC Pune' => 'LC Pune',
            'LC Kolkata' => 'LC Kolkata',
            'LC Delhi' => 'LC Delhi',
            'LC Chennai' => 'LC Chennai'
        };
        List<User> lstUsers = [SELECT Id,Name,IsActive,Profile.Name FROM User WHERE (Profile.Name IN :lstProfileNames OR Name IN : mapUserNamesVsCategory.keySet()) AND IsActive=true];
        objMapWrapper.lstRoles = [SELECT Id,Name FROM CaseTeamRole WHERE Name IN ('Viewer','Editor')];
        for (User objUser : lstUsers) {
            if(objUser.Profile.Name == 'Head Office Community' || objUser.Profile.Name == 'Head Office') {
                String userName = objUser.Name == 'Admission Dept.' ? 'Manasvi Malve' : objUser.Name;
                objMapWrapper.mapOfNameVsUserId.put(userName,objUser.Id);
            } else if(objUser.Profile.Name == 'Counsellor' || (objUser.Profile.Name == 'Super Admin' && lstSuperAdmins.contains(objUser.Name))) {
                objMapWrapper.mapOfUserIdCPVsName.put(objUser.Id,objUser.Name);
                objMapWrapper.mapOfCPNameVsUserId.put(objUser.Name,objUser.Id);
                if(objUser.Profile.Name == 'Super Admin') {
                    objMapWrapper.setOfSAUserIds.add(objUser.Id);
                }
            }

            if(mapUserNamesVsCategory.containsKey(objUser.Name)) {
                objMapWrapper.mapOfCategoryVsUserId.put(mapUserNamesVsCategory.get(objUser.Name), objUser.Id);
            }
        }
        return objMapWrapper;
    }

    /**
    * @description 
    * @author @BK | 12-25-2023 
    * @param mapOfNameVsUserId 
    * @param userList 
    * @return String[] 
    **/
    public String[] getUserIds(Map<String,Id> mapOfNameVsUserId, String userList) {
        String[] userNames = userList.split(';');
        String[] userIds = new List<String>();
        for (String userName : userNames) {
            if(mapOfNameVsUserId.containsKey(userName)) {
                userIds.add(mapOfNameVsUserId.get(userName));
            }
        }
        return userIds;
    }

    public class UtlityWrapper {
        public Map<String,String[]> caseRotuingMap { get; private set; }
        public Map<Id,String> mapOfQueueIdVsName {get; private set;}
        public Map<Id,String> mapOfAllQueueIdVsName {get; private set;}
        public Map<String,Id> mapOfNameVsUserId {get; private set;}
        public Map<String,Id> mapOfCPNameVsUserId {get; private set;}
        public Map<Id,String> mapOfUserIdCPVsName {get; private set;} // Map of Counselor UserId VS Name
        public Set<Id> setOfSAUserIds {get; private set;} // Set of Super Admin User Ids
        public List<CaseTeamRole> lstRoles {get; private set;}
        public Map<String,Id> mapOfCategoryVsUserId {get; private set;}
    }

    public class MapWrapper {
        public Map<String,Id> mapOfCPNameVsUserId {get; private set;}
        public Map<String,Id> mapOfNameVsUserId {get; private set;}
        public Map<Id,String> mapOfUserIdCPVsName {get; private set;} // Map of Counselor UserId VS Name
        public Set<Id> setOfSAUserIds {get; private set;} // Set of Super Admin User Ids
        public List<CaseTeamRole> lstRoles {get; private set;}
        public Map<String,Id> mapOfCategoryVsUserId {get; private set;}
    }

    public class MapQueueWrapper {
        public Map<Id,String> mapOfQueueIdVsName {get; private set;}
        public Map<Id,String> mapOfAllQueueIdVsName {get; private set;}
    }
}