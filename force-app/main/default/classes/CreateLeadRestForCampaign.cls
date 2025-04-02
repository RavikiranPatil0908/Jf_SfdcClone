/**
 * @File Name          : CreateLeadRestForCampaign.cls
 * @Description        :
 * @Author             : @BK
 * @Group              :
 * @Last Modified By   : @BK
 * @Last Modified On   : 16-08-2024
 * @Modification Log   :
 * Ver       Date            Author              Modification
 * 1.0    13/5/2020   @BK     Initial Version
 **/
@RestResource(urlMapping = '/CreateLeadRestForCampaign/*')
global without sharing class CreateLeadRestForCampaign {
    public static List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c> ();
    public static List<nm_Centers__c> lstLearningCenters = new List<nm_Centers__c> ();
    public static Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map <String,nm_Centers__c> ();
    public static Map<String,String> mapProgramNameVsActualName = new Map <String,String> ();
    public static Map<String,String> mapProgramVsType = new Map <String,String> ();
    public static String AgencyInternalCategory = '';

    global class WapperId {
        public String LeadId { get;set; }
        public String result { get;set; }
        public String message { get;set; }

        public WapperId(String Id, String message, String result) {
            this.LeadId = Id;
            this.message = message;
            this.result = result;
        }
    }

    @HttpPost
    global static WapperId connectToEnquiry() {
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        WapperId WapperId = null;
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            requestString = body.toString();
            CreateLeadRestForCampaignWrapper reqWrapper = CreateLeadRestForCampaignWrapper.parse(requestString);
            System.debug('reqWrapper'+ reqWrapper);
            apiReq.Request__c = requestString;
            String Keywords = reqWrapper.Keywords;
            String AdvertCampaign = reqWrapper.AdvertCampaign;
            String AdvertContent = reqWrapper.AdvertContent;
            string AdvertType = reqWrapper.AdvertType;
            String AdvertSize = reqWrapper.AdvertSize; 
            String ReferringURL = reqWrapper.ReferringURL; 
            string IPAddress = reqWrapper.IPAddress;
            string TimeStamp = reqWrapper.TimeStamp;
            string FullName = reqWrapper.FullName;
            string EmailAddress = reqWrapper.EmailAddress;
            string ContactNumber = reqWrapper.ContactNumber;
            string AgeGroup = reqWrapper.AgeGroup;
            string City = reqWrapper.City;
            string DateOfBirth = reqWrapper.DateOfBirth;
            string Center = reqWrapper.Center;
            string Program = reqWrapper.Program;
            String ProgramType = reqWrapper.ProgramType;
            String AdvertAgency = reqWrapper.AdvertAgency;
            String Industry = reqWrapper.Industry;
            String SelectProgram = reqWrapper.SelectProgram;
            String Title = reqWrapper.Title;
            String Company = reqWrapper.Company;
            String State = reqWrapper.State;
            String ZipCode = reqWrapper.ZipCode;
            String Google_Link = reqWrapper.Google_Link;
            String Source = reqWrapper.Source;
            String OtherLeadSource = reqWrapper.OtherLeadSource;
            String CountryCode = reqWrapper.CountryCode;
            String GACID = reqWrapper.GACID;
            String adgroup = reqWrapper.adgroup;
            String target = reqWrapper.target;
            String physicallocation = reqWrapper.physicallocation;
            String interestlocation = reqWrapper.interestlocation;
            String network = reqWrapper.network;
            String devicemodel = reqWrapper.devicemodel;
            String ad = reqWrapper.ad;
            String placement = reqWrapper.placement;
            String adposition = reqWrapper.adposition;
            String PartnerLeadSource=reqWrapper.PartnerLeadSource;
            String leadSource = Source != null && Source != '' && Source != 'null' ? Source : 'Web';
            Boolean leadThroughAgency = false;
            String FirstName = '';
            String LastName = '';
            String Country = '';
            String fromId = '';
            String adgroupId = reqWrapper.adgroupId;
            String campaignId = reqWrapper.campaignId;
            String experimentId = reqWrapper.experimentId;
            String FBCLID = reqWrapper.FBCLID;
            String keywordMatchType = reqWrapper.keywordMatchType;
            String siteLinks = reqWrapper.siteLinks;
            String leadFormID = reqWrapper.leadFormID;
            Lead objLead = new Lead();
            // API_Request__c apiReq = new API_Request__c();
            // apiReq.Request__c = requestString;
            String LeadId = '';
            if (String.isNotBlank(FullName)) {
                apiReq.Lead_Name__c = FullName;
            }
            // if(String.isNotBlank(Program)){
            //     apiReq.Choose_Program__c= Program;
            // }
            if (String.isNotBlank(EmailAddress)) {
                apiReq.Email_Id__c = EmailAddress;
            }
            if (String.isNotBlank(ContactNumber)) {
                apiReq.MobilePhone__c = ContactNumber;
                //  if(ContactNumber.length() > 10) {
                //   ContactNumber= ContactNumber.replaceAll( '\\s+', '');
                //   if (ContactNumber.contains('+')) {
                //    Country = getCountryNameFromPhoneNumber( (ContactNumber.split('\\+')[1]).substring(0,( ContactNumber.split('\\+')[1]).length() - 10));
                //   } else {          
                //     Country = getCountryNameFromPhoneNumber( (ContactNumber).substring(0,( ContactNumber).length() - 10));
                //   }
                //  } else {
                //    Country = 'India';
                //  }
            }
    
            AdvertAgency = AdvertAgency != null && AdvertAgency != '' && AdvertAgency != 'null' ? AdvertAgency : '';
            if (String.isNotBlank(AdvertAgency)) {
                apiReq.Agency__c = AdvertAgency;
            }
            if (String.isNotBlank(Center)) {
                apiReq.Selected_IC__c = Center.trim();
            }
            mapProgramNameVsActualName.put('Masters In Artificial Intelligence & Machine Learning', 'Master of Science in Artificial Intelligence and Machine Learning Ops');
            mapProgramNameVsActualName.put('MSc In Applied Finance', 'Master of Science in Applied Finance');
            mapProgramNameVsActualName.put('Professional Diploma In Wealth Management', 'Professional Diploma in Wealth Management');
    
            List <nm_Program__c> listProgram = [select id, nm_ProgramName__c, name, nm_Type__c from nm_Program__c where nmIsActive__c = true];
    
            if (listProgram.size() > 0) {
                for (nm_Program__c objprogram: listProgram) {
                    mapProgramVsType.put(objprogram.nm_ProgramName__c, objprogram.nm_Type__c);
                }
            }
    
            if (String.isNotBlank(FullName)) {
                if (FullName.length() > 39) {
                    List < String > lstFullNameString = FullName.split(' ');
                    if (lstFullNameString.size() > 1) {
                        List < String > lstFirstName = new List < String > ();
                        List < String > lstLastName = new List < String > ();
                        Integer half = lstFullNameString.size() / 2;
                        for (Integer i = 0; i < lstFullNameString.size(); i++) {
                            if (i < half) {
                                lstFirstName.add(lstFullNameString[i]);
                            } else {
                                lstLastName.add(lstFullNameString[i]);
                            }
                        }
                        FirstName = String.join(lstFirstName, ' ');
                        LastName = String.join(lstLastName, ' ');
                    } else {
                        FirstName = FullName;
                        LastName = '.';
                    }
                } else {
                    FirstName = FullName;
                    LastName = '.';
                }
            }
    
            if (String.isNotBlank(Program)) {
                // update choose program in proper format as in SFDC
                if (Program.startsWithIgnoreCase('Diploma')) {
                    Program = 'Diploma Programs';
                } else if (Program.startsWithIgnoreCase('Certificate')) {
                    Program = 'Certificate Programs';
                } else if (Program.startsWithIgnoreCase('Bachelor')) {
                    Program = 'Bachelor Programs';
                } else if (Program.startsWithIgnoreCase('Master') || Program.startsWithIgnoreCase('Executive') || Program.startsWithIgnoreCase('Data Science Programs') || Program.startsWithIgnoreCase('Applied Finance Programs')) {
                    Program = 'Master Programs';
                    SelectProgram = mapProgramNameVsActualName.containskey(SelectProgram) ? mapProgramNameVsActualName.get(SelectProgram) : SelectProgram;
                } else if (Program.startsWithIgnoreCase('Professional') || Program.startsWithIgnoreCase('Wealth Management Programs')) {
                    Program = 'Professional Programs';
                    SelectProgram = mapProgramNameVsActualName.containskey(SelectProgram) ? mapProgramNameVsActualName.get(SelectProgram) : SelectProgram;
                } else if (Program.startsWithIgnoreCase('MBA (Online)') || Program.startsWithIgnoreCase('MBA Online') || Program.startsWithIgnoreCase('Post')) {
                    Program = 'MBA (Online) Programs';
                } else if (Program.startsWithIgnoreCase('Digital Marketing Programs')) {
                    //Program = 'MBA (Distance) Programs';
                    Program = mapProgramVsType.containskey(SelectProgram) ? mapProgramVsType.get(SelectProgram) : 'Certificate Programs';
                }
    
                apiReq.Choose_Program__c = Program;
            }
            Center = Center != null && Center != '' && Center != 'null' ? Center : '';
            City = City != null && City != '' && City != 'null' ? City : '';
            CountryCode = CountryCode != null && CountryCode != '' && CountryCode != 'null' ? CountryCode : '';
    
    
            if (String.isNotBlank(CountryCode)) {
                CountryCode = CountryCode.trim();
                if(!CountryCode.equalsIgnoreCase('null')) {
                    if (CountryCode.contains('+')) {
                    //    Country = 'India';
                    Country = getCountryNameFromPhoneNumber( CountryCode.split('\\+')[1]);
                    } else {          
                        // Country = 'India';
                        Country = getCountryNameFromPhoneNumber(CountryCode);
                    }
                    if( Country == 'Invalid Calling Code') {
                    WapperId obj = new WapperId('', 'Error', Country);
                    apiReq.Type_of_Request__c = 'CreateLeadRestForCampaign';
                    apiReq.Lead__c = null;
                    apiReq.API_Name__c = 'CreateLeadRestForCampaign';
                    apiReq.Success__c = false;
                    apiReq.Response__c = obj.toString();
                    apiRequestsInsertion(apiReq);
                    return obj;
                    } else if(Country != 'India') {
                        fromId = 'INTERNATIONAL_FORM';
                    }
                    apiReq.Country_Code__c = CountryCode;
    
                }
            }
            CountryCode = CountryCode != null && CountryCode != '' && !CountryCode.equalsIgnoreCase('null') ? CountryCode: '';
    
            // Innformation Center
            String CenterName = '';
    
            // if (SelectProgram == 'MBA (X) - Business Analytics' || SelectProgram == 'MBA (Executive) with specialisation in Business Analytics') {
            //     // Center='upGrad';
            //     CenterName = 'upGrad';
            //     SelectProgram = 'MBA (Executive) with specialisation in Business Analytics';
            // }
            // else if(String.isNotBlank(ELR)){
            //   CenterName = checkELRWithExitingLeads(Center.trim(),ELR.trim());
            //   if(String.isBlank(CenterName)){
            //     CenterName = addInformationCenterBasedOnCurrentLocation(Center.trim(), Program, City.trim());  
            //   }
            // } 
            // else {
                CenterName = addInformationCenterBasedOnCurrentLocation(Center.trim(), Program, City.trim(), AdvertAgency, leadSource);
                system.debug('CenterName --> ' +CenterName);
            // }
    
        try {
    
          //to avoid null values
          
            ProgramType = ProgramType != null && ProgramType != '' && ProgramType != 'null' ? ProgramType : '';
            fromId = fromId != null && fromId != '' && fromId != 'null' ? fromId : '';
            //prettier-ignore
            if (DateOfBirth != null && DateOfBirth != '') {
                objLead = new Lead(nm_Keyword__c = Keywords, nm_AdvertisementCampaign__c = AdvertCampaign, Agency__c = AdvertAgency, utm_content__c = AdvertContent, nm_AdvertisementType__c = AdvertType, nm_AdvertisementSize__c = AdvertSize, nm_ReferringURL__c = ReferringURL, nm_IPForLead__c = IPAddress, nm_Timestamp_del__c = TimeStamp, LeadSource = leadSource, nm_OtherLeadSources__c = OtherLeadSource,
                FirstName = FirstName, LastName = LastName, Email = EmailAddress,
                MobilePhone = ContactNumber, Age_Group__c = AgeGroup, nm_City_P__c = City, nm_DateOfBirth__c = Date.parse(DateOfBirth), nm_SelectedIC__c = CenterName, nm_ChooseaProgram__c = Program,
                nm_StudentSelectedIC__c = Center,Partner_Lead_Source__c=PartnerLeadSource,Agency_Internal_Category__c =AgencyInternalCategory,LC_Wise_Marketing_Distribution_Date__c = Date.today(),
                nm_Country_P__c = Country, Form_Id__c = fromId, Lead_Form_ID__c = leadFormID,
                Program_Type__c = ProgramType, Industry = Industry, nm_SelectedProgram__c = SelectProgram, Title = Title, nm_Company_Name__c = Company, nm_StateProvince_P__c = State, nm_PostalCode_P__c = ZipCode, GCLID__c = Google_Link,  Country_Code__c = CountryCode, GACID__c = GACID,
                Ad_Group__c = adgroup, Average_Position__c = adposition, Targeting__c = target, User_Location_Physical__c = physicallocation, User_Location_Interest__c = interestlocation,  Networks__c = network, If_Mobile_and_If_Not_Mobile__c = devicemodel, Ads__c = ad, Placements__c = placement, Adgroup_ID__c = adgroupId, Campaign_ID__c = campaignId, Experiment_ID__c = experimentId, FBCLID__c = FBCLID, Keyword_Match_Type__c = keywordMatchType, Site_Links__c = siteLinks);
            } else {
                objLead = new Lead(nm_Keyword__c = Keywords, nm_AdvertisementCampaign__c = AdvertCampaign, Agency__c = AdvertAgency, utm_content__c = AdvertContent, nm_AdvertisementType__c = AdvertType, nm_AdvertisementSize__c = AdvertSize, nm_ReferringURL__c = ReferringURL, nm_IPForLead__c = IPAddress, nm_Timestamp_del__c = TimeStamp, LeadSource = leadSource, nm_OtherLeadSources__c = OtherLeadSource,
                FirstName = FirstName, LastName = LastName, Email = EmailAddress, MobilePhone = ContactNumber, Age_Group__c = AgeGroup, nm_City_P__c = City, nm_SelectedIC__c = CenterName,
                nm_StudentSelectedIC__c = Center,Partner_Lead_Source__c=PartnerLeadSource,Agency_Internal_Category__c =AgencyInternalCategory,LC_Wise_Marketing_Distribution_Date__c = Date.today(),
                nm_Country_P__c = Country,Form_Id__c = fromId, Lead_Form_ID__c = leadFormID,
                nm_ChooseaProgram__c = Program, Program_Type__c = ProgramType, Industry = Industry, nm_SelectedProgram__c = SelectProgram, Title = Title, nm_Company_Name__c = Company, nm_StateProvince_P__c = State, nm_PostalCode_P__c = ZipCode, GCLID__c = Google_Link, Country_Code__c = CountryCode, GACID__c = GACID,
                Ad_Group__c = adgroup, Average_Position__c = adposition, Targeting__c = target, User_Location_Physical__c = physicallocation, User_Location_Interest__c = interestlocation, Networks__c = network, If_Mobile_and_If_Not_Mobile__c = devicemodel, Ads__c = ad, Placements__c = placement, Adgroup_ID__c = adgroupId, Campaign_ID__c = campaignId, Experiment_ID__c = experimentId, FBCLID__c = FBCLID, Keyword_Match_Type__c = keywordMatchType, Site_Links__c = siteLinks);
            }
            list <Lead> lstExistingLead = [SELECT id, Email, MobilePhone, LeadSource FROM Lead WHERE (Email=:EmailAddress OR MobilePhone=:ContactNumber) AND IsConverted=FALSE];
            if (lstExistingLead.size() > 0) {
                LeadId = lstExistingLead[0].id;
                if (objLead.LeadSource.equalsIgnoreCase('partner') || objLead.LeadSource.equalsIgnoreCase('other')) {
                    leadThroughAgency = true;
                }
            }
            
                // if( Country == 'Invalid Calling Code') {
                //   String nullString;
                //   nullString = nullString.capitalize();
                // }
                System.debug(objLead + '@#@#@#@#@#@@');
                insert objLead;
                if (LeadId == null || LeadId == '') {
                    LeadId = objLead.id;
                }
    
    
                if (leadThroughAgency) {
                    WapperId obj = new WapperId(LeadId, 'Duplicate', 'Duplicate');
                    return obj;
                } else {
                    WapperId obj = new WapperId(LeadId, 'Success', 'Success');
                    return obj;
                }
                // apiReq.Response__c = obj.toString();
                // apiReq.Type_of_Request__c= 'CreateLeadRestForCampaign';
                // apiReq.Lead__c = objLead.id;
                // apiReq.API_Name__c='CreateLeadRestForCampaign';
                // apiReq.Success__c = true;
                // apiRequestsInsertion(apiReq);
                // return obj;
            } catch (Exception e) {
                apiReq.Type_of_Request__c = 'CreateLeadRestForCampaign';
                apiReq.Lead__c = null;
                apiReq.API_Name__c = 'CreateLeadRestForCampaign';
                apiReq.Success__c = false;
                String error = e.getMessage();
                WapperId obj = null;
                if(error.contains('DUPLICATE_VALUE') || error.contains('Duplicate Lead')) {
                    obj = new WapperId(LeadId, 'Duplicate', 'Duplicate');
                } else {
                    obj = new WapperId('','Error','Bad Request');
                }
                apiReq.Response__c = obj.toString() + ' \n ' + e.getMessage();
                API_Request__c api = apiRequestsInsertion(apiReq);
                // sendMailForFailed(requestString, obj.toString() + ' \n ' + e.getMessage(), api);
                return obj;
            }
        } catch (Exception e) {
            apiReq.Type_of_Request__c = 'CreateLeadRestForCampaign';
            apiReq.Lead__c = null;
            apiReq.API_Name__c = 'CreateLeadRestForCampaign';
            apiReq.Success__c = false;
            String error = e.getMessage();
            WapperId obj = null;
            obj = new WapperId('','Error','Bad Request');
            apiReq.Response__c = obj.toString() + ' \n ' + e.getMessage();
            system.debug('apiReq.Response__c --> ' + apiReq.Response__c + error);
            API_Request__c api = apiRequestsInsertion(apiReq);
            // sendMailForFailed(requestString, obj.toString() + ' \n ' + e.getMessage(), api);
            return obj;
        }

    }

    public static API_Request__c apiRequestsInsertion(API_Request__c apiRequest) {
        if (apiRequest != null) {
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
        return apiRequest;
    }

    public static String getQueryAllFieldSql(String SObjectAPIName, String conditionString, String relatedFields) {
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List < String > fieldNames = new List < String > (fieldMap.keySet());
        if (relatedFields != null && relatedFields != '') {
            fieldNames.add(relatedFields);
        }
        String query = 'Select ' + String.join(fieldNames, ',') + ' from ' + SObjectAPIName + ' where ' + conditionString;

        return query;
    }

    public static List < nm_Centers__c > getlstActiveCenters() {
        if (lstActiveCenters.isEmpty()) {
            String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c', ' id !=null', 'RecordType.Name');
            // lstActiveCenters = DataBase.query(queryActiveCenters);
            Map < id, nm_Centers__c > mapOfCenterIdVsCenter = new Map < id, nm_Centers__c > ((List < nm_Centers__c > ) DataBase.query(queryActiveCenters));
            lstActiveCenters = mapOfCenterIdVsCenter.values();
            system.debug('lstActiveCenters---query' + lstActiveCenters);
        }
        return lstActiveCenters;
    }

    public static Map < String, nm_Centers__c > getMapOfCenterNameVsCenter() {
        if (mapOfCenterNameVsCenter.isEmpty()) {
            //  String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' Name != null ',null);
            //   List<nm_Centers__c> lstActiveCenters = DataBase.query(queryActiveCenters);
            List < nm_Centers__c > lstActiveCenters = getlstActiveCenters();
            system.debug('lstActiveCenters2--->' + lstActiveCenters);
            if (lstActiveCenters.size() > 0) {
                for (nm_Centers__c objCenter: lstActiveCenters) {
                    if (objCenter.Assign_IC_To_LC__c != null && objCenter.Assign_IC_To_LC__c != '') {
                        system.debug('@@@@@@@@@$$@$');
                        system.debug(objCenter.Assign_IC_To_LC__c);
                        List < String > lstAssignityToLc = new List < String > ();
                        lstAssignityToLc = objCenter.Assign_IC_To_LC__c.split(';');
                        for (string assignIcTOLC: lstAssignityToLc) {
                            mapOfCenterNameVsCenter.put(assignIcTOLC.trim(), objCenter);
                        }
                    }
                    if(objCenter.RecordType.Name == 'Learning Center') {
                        system.debug('LC objCenter ====> ' + objCenter);
                       lstLearningCenters.add(objCenter);
                    }
                    mapOfCenterNameVsCenter.put(objCenter.Name, objCenter);
                }
            }
        }
        return mapOfCenterNameVsCenter;
    }

    public static string addInformationCenterBasedOnCurrentLocation(String currentLocation, String programName, String City, String AdvertAgency, String leadSource) {
        if (leadSource.equalsIgnoreCase('partner')) {
            return currentLocation;
        } else {
            Map < String, nm_Centers__c > mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
            AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
            // Map<String, String> mapOfProgramVsFamily = new Map<String, String>();
            // List < Lead > lstLeadOfForAllAgency = new List<Lead>();
            // Map<String, Map<String, Lead_Assignment__c>> getMapLeadAssignmentWithAgency = new Map<String, Map<String, Lead_Assignment__c>>();
            // Map<String, Lead_Assignment__c> mapOFLeadAssignment = new Map<String, Lead_Assignment__c>();
            // Map<String, Map<String,Integer>> mapOfAgencyVsMapOfLeadCount = new Map<String, Map<String, Integer>>();
    
            // Map<String, Map<String,Integer>> mapOfAgencyVsMapOfMaxCount = new Map<String, Map<String, Integer>>();
            if(currentLocation.contains(',')) {
                currentLocation = currentLocation.split(',')[0];
            }
            if(City.contains(',')) {
                City = City.split(',')[0];
            }
            system.debug('%^&%&^$%&^$%');
            if(Boolean.valueOf(System.Label.LC_Wise_Distribution_Active ) ) {
                AssignCounsellorHelper.LeadAssignmentMetadate LeadAssignmentMetadate = new AssignCounsellorHelper.LeadAssignmentMetadate();
                LeadAssignmentMetadate = AssignCounsellorHelper.getMapAgencyTypeFromMetadataVsLabel();
                Map<String, String> mapOfagencyVsType  = LeadAssignmentMetadate.mapOfagencyVsType;
                Map<String, set<String>> mapOfTypeVsSetAgency  = LeadAssignmentMetadate.mapOfTypeVsLstAgency;
                String agencyType = String.isNotBlank(AdvertAgency) &&  mapOfagencyVsType.containsKey(AdvertAgency.trim())  ?  mapOfagencyVsType.get(AdvertAgency.trim()) : 'Others';
                AgencyInternalCategory = agencyType;
                system.debug('agencyType --> ' + agencyType);
                if (String.isNotBlank(agencyType)) {
                    AssignCounsellorHelper.FamilyOfProgram FamilyOfProgram = new AssignCounsellorHelper.FamilyOfProgram();
                    Map<String, String> mapOfProgramVsFamily = FamilyOfProgram.mapOfProgramVsFamily;
                    Map<String, set<String>> mapOfFamilyVsSetOfProgram = FamilyOfProgram.mapOfFamilyVsSetOfProgram;
                    String family = mapOfProgramVsFamily.containsKey(programName) ? mapOfProgramVsFamily.get(programName) : null;
                    system.debug('family --> ' + family);
                    if (String.isNotBlank(family)) {
                        String selectedCenterName = null;
                        String selectedLearningCenterName = null;
                        if (mapOfCenterNameVsCenter1.containsKey(currentLocation) && programName != '') {
                            nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(currentLocation);
                            if (
                                objCenter1.nm_ChooseaProgram__c != null &&
                                objCenter1.nm_ChooseaProgram__c != '' &&
                                objCenter1.nm_ChooseaProgram__c.contains(programName) &&
                                objCenter1.RegistrationClosed__c == false
                            ) {
                                selectedCenterName = objCenter1.Name;
                                selectedLearningCenterName = objCenter1.CenterName__c;
                            } else if (
                                mapOfCenterNameVsCenter1.containsKey(objCenter1.CenterName__c) &&
                                mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c != null &&
                                mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c != '' &&
                                mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c.contains(programName) &&
                                mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).RegistrationClosed__c == false
                            ) {
                                nm_Centers__c objCenter2 = mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c);
                                selectedLearningCenterName = objCenter2.Name;
                            } 
                        }
                        Map<String, Map<String, Lead_Assignment__c>> getMapLeadAssignmentWithAgency = AssignCounsellorHelper.getMapLeadAssignmentWithAgency();
                        system.debug('getMapLeadAssignmentWithAgency --> ' + getMapLeadAssignmentWithAgency);
                        Set<String> setActiveAgency = new Set<String>(getMapLeadAssignmentWithAgency.keySet());
                        
                        AssignCounsellorHelper.LeadCount LeadCount = new AssignCounsellorHelper.LeadCount();
                        LeadCount = AssignCounsellorHelper.getMapAgencyTypeVsLstLead(family, agencyType, mapOfFamilyVsSetOfProgram, mapOfagencyVsType, mapOfTypeVsSetAgency, mapOfProgramVsFamily, setActiveAgency);
                        Map<String, Map<String, Integer>> mapOfAgencyTypeVsMapOfFamilyVsBaseCount = LeadCount.mapOfAgencyTypeVsMapOfFamilyVsBaseCount;
                        Map<String, Map<String, Map<String, Integer>>> mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount = LeadCount.mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount;
                        system.debug('mapOfAgencyTypeVsMapOfFamilyVsBaseCount --> ' + mapOfAgencyTypeVsMapOfFamilyVsBaseCount);
                        system.debug('mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount --> ' + mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount);
                        Map<String,Map<String,Map<String, Integer>>> MaxCountForAgencyVsFamilyVsCenterVsCount = AssignCounsellorHelper.getMaxCountForAgencyVsFamilyVsCenterVsCount(getMapLeadAssignmentWithAgency, mapOfAgencyTypeVsMapOfFamilyVsBaseCount);
                        Map<String, Map<String,Integer>> mapOfFamilyVsMapOfMaxCount = MaxCountForAgencyVsFamilyVsCenterVsCount.containsKey(agencyType) ? MaxCountForAgencyVsFamilyVsCenterVsCount.get(agencyType) : new Map<String, Map<String,Integer>>();
                        
                        Map<String, Map<String, Integer>> MapFamilyVsCenterVsLeadCount = mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.containsKey(agencyType) ? mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.get(agencyType) : new Map<String, Map<String, Integer>>();
                        Map<String, Integer> mapOfCenterVsLeadCount = MapFamilyVsCenterVsLeadCount.containsKey(family) ? MapFamilyVsCenterVsLeadCount.get(family) : new Map<String, Integer>();
                        Map<String, Integer>  mapOfMaxCount = mapOfFamilyVsMapOfMaxCount.containsKey(family) ? mapOfFamilyVsMapOfMaxCount.get(family) : new Map<String, Integer>();
                        Map<String, Integer>  mapOfLeadCount = MapFamilyVsCenterVsLeadCount.containsKey(family) ? MapFamilyVsCenterVsLeadCount.get(family) : new Map<String, Integer>();
                        system.debug('mapOfMaxCount --> ' + mapOfMaxCount);
                        system.debug('mapOfLeadCount --> ' + mapOfLeadCount);
    
    
                        String centerName = AssignCounsellorHelper.getCenterForLeadThroughAllotment(mapOfLeadCount,mapOfMaxCount, selectedLearningCenterName );
                        system.debug('centerName ==> ' + centerName);
                        system.debug('selectedLearningCenterName ==> ' + selectedLearningCenterName);
                        system.debug('selectedCenterName ==> ' + selectedCenterName);
                        return String.isNotBlank(selectedCenterName) && selectedLearningCenterName == centerName ? selectedCenterName: centerName;
                        }
                    }
            }
    
            if (mapOfCenterNameVsCenter1.containsKey(currentLocation) && programName != '') {
                nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(currentLocation);
                if (
                    objCenter1.nm_ChooseaProgram__c != null &&
                    objCenter1.nm_ChooseaProgram__c != '' &&
                    objCenter1.nm_ChooseaProgram__c.contains(programName) &&
                    objCenter1.RegistrationClosed__c == false
                ) {
                    return String.valueof(objCenter1.Name);
                } else if (
                    mapOfCenterNameVsCenter1.containsKey(objCenter1.CenterName__c) &&
                    mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c != null &&
                    mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c != '' &&
                    mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c.contains(programName) &&
                    mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).RegistrationClosed__c == false
                ) {
                    nm_Centers__c objCenter2 = mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c);
                    system.debug('objCenter1 --------------->>>' + objCenter2);
                    system.debug('objCenter1 --------------->>>' + objCenter2);
    
                    return objCenter2.Name;
                } 
                // else if(String.isNotBlank(centerAssignmentFromTime)) {
                //     return centerAssignmentFromTime;
                // }
                
                else if (
                    City != null &&
                    City != '' &&
                    mapOfCenterNameVsCenter1.containsKey(City) &&
                    mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != null &&
                    mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != '' &&
                    mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c.contains(programName) &&
                    mapOfCenterNameVsCenter1.get(City).RegistrationClosed__c == false
                ) {
                    system.debug('@#$@##@#@#');
                    nm_Centers__c objCenter3 = mapOfCenterNameVsCenter1.get(City);
                    system.debug('objCenter1 --------------->>>' + objCenter3);
    
                    return objCenter3.Name;
                } 
            } else if (
                City != null &&
                City != '' &&
                programName != '' &&
                mapOfCenterNameVsCenter1.containsKey(City) &&
                mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != null &&
                mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != '' &&
                mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c.contains(programName) &&
                mapOfCenterNameVsCenter1.get(City).RegistrationClosed__c == false
            ) {
                nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(City);
                return String.valueof(objCenter1.Name);
            }
            return mapOfCenterNameVsCenter1.get('Counsellor').name;

        }
    }
    //code by shubranshu
    // public Static String checkELRWithExitingLeads(String centerValue,String ELR){
    //   String centeranme = '';
    //   if(String.isNotBlank(ELR) && String.isNotBlank(centerValue)){
    //     List<Executive_Lead_Routing__c> lstexlr = [SELECT Id,Executive_Name__c,From_Center__c,From_Center__r.Name,Max_Lead_Count__c,To_center__c,To_center__r.Name from Executive_Lead_Routing__c WHERE Executive_Name__c=:ELR ORDER By CreatedDate asc];  
    //     Map<String,Executive_Lead_Routing__c> mapOfExecutiveLeadRouting = new Map<String,Executive_Lead_Routing__c>();
    //     Map<String,Integer> mapOfcenterVsCount = new Map<String,Integer>();
    //     List<String> nameOfcenters =new List<String>();
    //     if(lstexlr.size()>0){
    //       Integer totalLeadRoutingCount = lstexlr.size();
    //       for(Executive_Lead_Routing__c er:lstexlr){
    //           mapOfExecutiveLeadRouting.put(er.From_Center__r.Name,er);
    //           nameOfcenters.add(er.From_Center__r.Name);
    //       }
    //       AggregateResult[] ARs = [SELECT count(Id) myCount, nm_InformationCenter__r.Name center FROM Lead Where nm_InformationCenter__r.Name IN:nameOfcenters AND CreatedDate=TODAY AND ISConverted=false AND IsDeleted=false GROUP BY nm_InformationCenter__r.Name];
    //       System.debug(ARs);

    //       if(ARs.size()>0){
    //           for(AggregateResult ar:ARs){
    //               mapOfcenterVsCount.put(String.valueOf(ar.get('center')),Integer.valueOf(ar.get('myCount')));
    //           }
    //           System.debug('mapOfcenterVsCount '+mapOfcenterVsCount);
    //       }

    //       System.debug('totalLeadRoutingCount '+totalLeadRoutingCount+' nameOfcenters '+nameOfcenters);
    //       for(String str:nameOfcenters){
    //         System.debug('TodayLeadCount for '+str+' is '+mapOfcenterVsCount.get(str));     
    //         System.debug('TodayMaxCount for '+str+' is '+Integer.valueOf(mapOfExecutiveLeadRouting.get(str).Max_Lead_Count__c));
    //         if(mapOfcenterVsCount.get(str) >= Integer.valueOf(mapOfExecutiveLeadRouting.get(str).Max_Lead_Count__c)){
    //             centeranme = mapOfExecutiveLeadRouting.get(str).To_center__r.Name;
    //             System.debug('update center '+centeranme);
    //         }
    //       }
    //     }
    //     System.debug('centeranme '+centeranme);
    //   }
    //   return centeranme;
    // }

    // code by Suyog
    // public static String getCountryNameFromPhoneNumber(String CallingCode) {
    //   system.debug('CallingCode ------> ' + CallingCode);
    //   Http http = new Http();
    //   HttpRequest request = new HttpRequest();
    //   request.setEndpoint('https://restcountries.eu/rest/v2/callingcode/' + CallingCode);
    //   request.setMethod('GET');
    //   HttpResponse response = http.send(request);
    //   // If the request is successful, parse the JSON response.
    //   if(response.getStatusCode() == 200) {
    //       // Deserialize the JSON string into collections of primitive data types.
    //       // Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //       List<Object> result = (List<Object> ) JSON.deserializeUntyped(response.getBody());
    //       Map<String, Object> results =  (Map<String, Object>) result[0];
    //       if(results.containsKey('name')){

    //         system.debug('country name ------> ' + results.get('name'));
    //         return String.valueOf(results.get('name')) ;
    //       } else {
    //         return '';
    //       }
    //   } else {
    //     return 'Invalid Calling Code';
    //   }
    // }

    
    public static String getCountryNameFromPhoneNumber(String CallingCode) {
    String CountryJsonCh = '{"+263":"Zimbabwe","+260":"Zambia","+967":"Yemen","+681":"Wallis and Futuna","+84":"Vietnam","+58":"Venezuela","+678":"Vanuatu","+998":"Uzbekistan","+598":"Uruguay","+44":"United Kingdom","+971":"United Arab Emirates","+380":"Ukraine","+256":"Uganda","+1340":"U.S. Virgin Islands","+688":"Tuvalu","+1649":"Turks and Caicos Islands","+993":"Turkmenistan","+90":"Turkey","+216":"Tunisia","+1868":"Trinidad and Tobago","+676":"Tonga","+690":"Tokelau","+228":"Togo","+66":"Thailand","+255":"Zanzibar","+992":"Tajikistan","+886":"Taiwan","+963":"Syria","+41":"Switzerland","+46":"Sweden","+268":"Swaziland","+597":"Suriname","+249":"Sudan","+94":"Sri Lanka","+34":"Spain","+82":"South Korea","+27":"South Africa","+677":"Solomon Islands","+386":"Slovenia","+421":"Slovakia","+65":"Singapore","+232":"Sierra Leone","+248":"Seychelles","+381":"Serbia","+221":"Senegal","+966":"Saudi Arabia","+378":"San Marino","+685":"Samoa","+250":"Rwanda","+7":"Russia","+40":"Romania","+974":"Qatar","+1787":"Puerto Rico","+351":"Portugal","+48":"Poland","+63":"Philippines","+51":"Peru","+675":"Papua New Guinea","+507":"Panama","+970":"Palestinian Territory","+680":"Palau","+92":"Pakistan","+968":"Oman","+47":"Norway","+1670":"Northern Mariana Islands","+850":"North Korea","+683":"Niue","+234":"Nigeria","+227":"Niger","+505":"Nicaragua","+64":"New Zealand","+687":"New Caledonia","+1869":"Nevis","+31":"Netherlands","+977":"Nepal","+674":"Nauru","+264":"Namibia","+95":"Myanmar","+212":"Morocco","+1664":"Montserrat","+382":"Montenegro","+976":"Mongolia","+377":"Monaco","+373":"Moldova","+1808":"Wake Island","+691":"Micronesia","+52":"Mexico","+262":"Reunion","+230":"Mauritius","+222":"Mauritania","+692":"Marshall Islands","+356":"Malta","+223":"Mali","+960":"Maldives","+60":"Malaysia","+265":"Malawi","+261":"Madagascar","+389":"Macedonia","+853":"Macau SAR China","+352":"Luxembourg","+370":"Lithuania","+423":"Liechtenstein","+218":"Libya","+231":"Liberia","+266":"Lesotho","+961":"Lebanon","+371":"Latvia","+856":"Laos","+996":"Kyrgyzstan","+965":"Kuwait","+686":"Kiribati","+254":"Kenya","+77":"Kazakhstan","+962":"Jordan","+81":"Japan","+1876":"Jamaica","+225":"Ivory Coast","+39":"Italy","+972":"Israel","+353":"Ireland","+964":"Iraq","+98":"Iran","+62":"Indonesia","+91":"India","+354":"Iceland","+36":"Hungary","+852":"Hong Kong SAR China","+504":"Honduras","+509":"Haiti","+595":"Paraguay","+245":"Guinea-Bissau","+224":"Guinea","+502":"Guatemala","+1671":"Guam","+590":"Guadeloupe","+1473":"Grenada","+299":"Greenland","+30":"Greece","+350":"Gibraltar","+233":"Ghana","+49":"Germany","+995":"Georgia","+220":"Gambia","+241":"Gabon","+689":"French Polynesia","+594":"French Guiana","+596":"Martinique","+33":"France","+358":"Finland","+679":"Fiji","+298":"Faroe Islands","+500":"South Georgia and the South Sandwich Islands","+251":"Ethiopia","+372":"Estonia","+291":"Eritrea","+240":"Equatorial Guinea","+503":"El Salvador","+20":"Egypt","+593":"Ecuador","+670":"Timor Leste","+1809":"Dominican Republic","+1767":"Dominica","+253":"Djibouti","+45":"Denmark","+420":"Czech Republic","+537":"Cyprus","+599":"Netherlands Antilles","+53":"Cuba","+385":"Croatia","+506":"Costa Rica","+682":"Cook Islands","+243":"Congo, Dem. Rep. of (Zaire)","+242":"Congo","+269":"Comoros","+57":"Colombia","+86":"China","+56":"Easter Island","+235":"Chad","+236":"Central African Republic","+345":"Cayman Islands","+238":"Cape Verde","+1":"United States","+237":"Cameroon","+855":"Cambodia","+257":"Burundi","+226":"Burkina Faso","+359":"Bulgaria","+673":"Brunei","+1284":"British Virgin Islands","+246":"Diego Garcia","+55":"Brazil","+267":"Botswana","+387":"Bosnia and Herzegovina","+591":"Bolivia","+975":"Bhutan","+1441":"Bermuda","+229":"Benin","+501":"Belize","+32":"Belgium","+375":"Belarus","+1246":"Barbados","+880":"Bangladesh","+973":"Bahrain","+1242":"Bahamas","+994":"Azerbaijan","+43":"Austria","+672":"Norfolk Island","+61":"Cocos-Keeling Islands","+247":"Ascension","+297":"Aruba","+374":"Armenia","+54":"Argentina","+1268":"Barbuda","+1264":"Anguilla","+244":"Angola","+376":"Andorra","+1684":"American Samoa","+213":"Algeria","+355":"Albania","+93":"Afghanistan","+7840":"Abkhazia"}';
    Map<String,Object> mapOfCallingVsCountry= (Map<String,Object>) JSON.deserializeUntyped(CountryJsonCh);
    if(mapOfCallingVsCountry.containsKey('+' + CallingCode)){
        return String.valueOf(mapOfCallingVsCountry.get('+' + CallingCode)) ;
      } else {
        return 'Invalid Calling Code';
      }
    }

    public static void sendMailForFailed(String request, String response, API_Request__c apiReq) {
      Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
      String url =  URL.getOrgDomainUrl().toExternalForm()+ '/'+ apiReq.Id;
      OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
      String[] sendingToAddress = new List<String>();
      if(System.Label.Environment == 'Sandbox') {
        sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
      } else if(System.Label.Environment == 'Production') {
         sendingToAddress = System.Label.setBccAdderess.split(',');
      }
      semail.setToAddresses(sendingToAddress); 
      semail.setOrgWideEmailAddressId(owe.id); 
      semail.setReplyTo(owe.Address); 
      semail.setSubject('CreateLeadRestForCampaign Error'); 
      String messageBody = '<html><p>Dear Team,</p>'
                                +'<p>Request and Response for CreateLeadRestForCampaign for which Error was Found</p>'
                                +'<p>Please click <a href="'+url+'" >here</a> to navigate to API Request</p>'
                                +'<p>Request = ' + request +' </p>'
                                +'<p>Response = '+ response +' </p>'
                                +'<p>Thanks and Regards,</p>'
                                +'<p>NMIMS CDOE</p></html>';
        semail.setHtmlBody(messageBody);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
    }
}