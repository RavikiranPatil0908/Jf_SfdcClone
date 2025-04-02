/**
 * @File Name          : LeadService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 16-08-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    4/7/2019, 1:26:43 PM   @BK     Initial Version
**/
@RestResource(urlMapping='/leadservice/*')
global without sharing class LeadService
{    
   public static List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
    public static List<nm_Centers__c> lstLearningCenters = new List<nm_Centers__c> ();

   public static Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();
   public static String FName ='';
   public static String LName = '';
   public static String AgencyInternalCategory = '';

    global class WapperId
    {
        public String LeadId {get;set;}
        public String result {get;set;}
        public String message {get;set;}
        public WapperId(String Id,String message,String result)
        {
            this.LeadId=Id;
            this.message=message ;
            this.result =result;
        }
    }
      
    @HttpPost
    global static WapperId connectToEnquiry(String Name,String EmailID,String ContactNo,String Agency,String HighestQualification,decimal AdmissionYear,String CurrentLocation,String CourseIntrestedIn,String AgencyPassword,String ProgramIntrestedIn, String WorkExperience, String Designation)
    {   
        String requestString = '{"Name":\"'+Name+'\","EmailID":\"'+EmailID+'\","ContactNo":\"'+ContactNo+'\","Agency":\"'+Agency+'\","HighestQualification":\"'+HighestQualification+'\","AdmissionYear":\"'+AdmissionYear+'\","CurrentLocation":\"'+CurrentLocation+'\","CourseIntrestedIn":\"'+CourseIntrestedIn+'\","AgencyPassword":\"'+AgencyPassword+'\","ProgramIntrestedIn":\"'+ProgramIntrestedIn+'\","WorkExperience":\"'+WorkExperience+'\","Designation":\"'+Designation+'\"}';
        String leadSource='Web';
        String Category='Distance Learning / Correspondence';
        string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
     
        API_Request__c apiReq = new API_Request__c();
        System.debug('CourseIntrested in--->'+CourseIntrestedIn);
        RestRequest req = RestContext.request;
        //leadServiceWrapper reqWrapper = leadServiceWrapper.parse(requestString);
        apiReq.Request__c = requestString;
        String ipAddress = req.remoteAddress;
        if(String.isNotBlank(CourseIntrestedIn)){// update choose program in proper format as in SFDC
            if(CourseIntrestedIn.startsWithIgnoreCase('Diploma')){
                CourseIntrestedIn ='Diploma Programs';
            }else if(CourseIntrestedIn.startsWithIgnoreCase('Certificate')){
                CourseIntrestedIn ='Certificate Programs';
            }else if(CourseIntrestedIn.startsWithIgnoreCase('Bachelor')){
                CourseIntrestedIn ='Bachelor Programs';
            }else if(CourseIntrestedIn.startsWithIgnoreCase('Master')){                           
                CourseIntrestedIn ='Master Programs';        
            }else if(CourseIntrestedIn.startsWithIgnoreCase('Professional')){      
                CourseIntrestedIn ='Professional Programs';      
            }else if(CourseIntrestedIn.startsWithIgnoreCase('MBA (Online)') || CourseIntrestedIn.startsWithIgnoreCase('Post')) {
                CourseIntrestedIn ='MBA (Online) Programs';
            }
            apiReq.Choose_Program__c= CourseIntrestedIn;
        }                   
        if(String.isNotBlank(Name)){
            Name = Name.trim();
            Name = Name.replace('.', ' ');
            SplitLeadName(Name);
            apiReq.Lead_Name__c = Name;
        }
        if(String.isNotBlank(EmailID)){
            apiReq.Email_Id__c = EmailID;
        }
        if(String.isNotBlank(ContactNo)){
            apiReq.MobilePhone__c = ContactNo;
        }
        if(String.isNotBlank(Agency)){
            apiReq.Agency__c = Agency;
        }
        if(String.isNotBlank(CurrentLocation)){
            apiReq.Selected_IC__c = CurrentLocation;
        }
        if(AdmissionYear == null){
            AdmissionYear = System.Today().year();
        }
        System.debug('AdmissionYear '+AdmissionYear);
        // Innformation Center
        String CenterName = addInformationCenterBasedOnAEP(CurrentLocation, CourseIntrestedIn, Agency);
        
        
        // Insert Duplicate Lead with Reborn Status and throwing Error of Duplicate Lead for User 
        list<Lead> lstLead=[Select id,Email,MobilePhone,nm_RegistrationNo__c from Lead where (Email=:EmailID or MobilePhone=:ContactNo) and IsConverted=false];
        if(lstLead.size()>0) {
            WapperId obj;
            obj = new WapperId(lstLead[0].id,'Duplicate','Duplicate');
            System.debug('ProgramIntrestedIn 1 -->'+ProgramIntrestedIn);
            List<Agency_Access__c> lstAgency =[select id, Name,Email__c,Is_Active__c,password__c from Agency_Access__c where Name =:Agency and password__c =:AgencyPassword and Is_Active__c=true];
            if(lstAgency.size()>0) {
                Map<String,String> mapOfErrorMessages = ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
                System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                System.debug('ProgramIntrestedIn 2 -->'+ProgramIntrestedIn);
                Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,Highest_Qualification__c=HighestQualification,Agency__c=Agency,
                nm_StudentSelectedIC__c=CurrentLocation,Agency_Internal_Category__c =AgencyInternalCategory,LC_Wise_Marketing_Distribution_Date__c = Date.today(),
                nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress,Total_Work_Experience__c = WorkExperience,nm_Designation__c  = Designation,
                nm_SelectedProgram__c=ProgramIntrestedIn);
                try{
                        if(!mapOfErrorMessages.isEmpty()) {
                           obj =new WapperId(objLead.id,'Error',mapOfErrorMessages.get('Error'));
                           apiReq.Response__c = obj.toString();
                           apiReq.Type_of_Request__c= 'LeadService';
                           apiReq.Lead__c = objLead.id;
                           apiReq.API_Name__c='leadservice';
                           apiReq.Success__c = false;
                           apiRequestsInsertion(apiReq);
                        } else {
                            insert objLead;
                            // apiReq.Response__c = 'Success';
                            // apiReq.Type_of_Request__c= 'LeadService';
                            // apiReq.Lead__c = objLead.id;
                            // apiReq.API_Name__c='leadservice';
                            // apiReq.Success__c = true;
                            // apiRequestsInsertion(apiReq);
                            if(Agency == 'StudentPortal'){
                                // List<Duplicate_Lead__c> dupLead = [Select Id,nm_FirstName__c,nm_LastName__c,Agency__c,Original_Existing_Lead__r.nm_RegistrationNo__c,Mobile_No__c,Email__c 
                                //                                     From Duplicate_Lead__c Where Mobile_No__c=:ContactNo and Email__c =:EmailID and Original_Existing_Lead__c != null order by LastModifiedDate Desc];
                                
                                obj =new WapperId(lstLead[0].nm_RegistrationNo__c,'Duplicate','Duplicate');
                                apiReq.Response__c = obj.toString();
                                apiReq.Type_of_Request__c= 'LeadService';
                                apiReq.Lead__c = lstLead[0].id;
                                apiReq.API_Name__c='leadservice';
                                apiReq.Success__c = false;
                                apiRequestsInsertion(apiReq);                                 
                            }else{
                                obj =new WapperId(lstLead[0].id,'Duplicate','Duplicate');
                                apiReq.Response__c = obj.toString();
                                apiReq.Type_of_Request__c= 'LeadService';
                                apiReq.Lead__c = lstLead[0].id;
                                apiReq.API_Name__c='leadservice';
                                apiReq.Success__c = false;
                                apiRequestsInsertion(apiReq);         
                            }
                        }    
                        return obj;
                    } catch(Exception e) {
                        System.debug('Exception '+e.getMessage());
                            obj =new WapperId('','Error','Internal Server Error');
                            apiReq.Response__c = obj.toString().replace('Internal Server Error', String.valueOf(e));
                            apiReq.Type_of_Request__c= 'LeadService';
                            apiReq.Lead__c = objLead.id;
                            apiReq.API_Name__c='leadservice';
                            apiReq.Success__c = false;
                            API_Request__c api = apiRequestsInsertion(apiReq);
                            // sendMailForFailed(requestString, obj.toString() + ' \n ' + e.getMessage(), api);
                            return obj;
                    }
                    }
            return obj;
        } else {
            List<Agency_Access__c> lstAgency =[select id, Name,Email__c,Is_Active__c,password__c from Agency_Access__c where Name =:Agency and password__c =:AgencyPassword and Is_Active__c=true];
            if(lstAgency.size()>0) {
                Map<String,String> mapOfErrorMessages =ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
                Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,
                nm_StudentSelectedIC__c=CurrentLocation,Total_Work_Experience__c = WorkExperience,nm_Designation__c  = Designation,Agency_Internal_Category__c =AgencyInternalCategory,LC_Wise_Marketing_Distribution_Date__c = Date.today(),
                Highest_Qualification__c=HighestQualification,Agency__c=Agency,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress,nm_SelectedProgram__c=ProgramIntrestedIn);
                try {
                    WapperId obj;
                    System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                    if(!mapOfErrorMessages.isEmpty()) {
                        System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                        obj =new WapperId(objLead.id,'Error',mapOfErrorMessages.get('Error'));
                        apiReq.Response__c = obj.toString();
                        apiReq.Type_of_Request__c= 'LeadService';
                        apiReq.Lead__c = objLead.id;
                        apiReq.API_Name__c='leadservice';
                        apiReq.Success__c = false;
                        apiRequestsInsertion(apiReq);         
                    } else {
                        insert objLead;
                        Lead ld = [select Id,FirstName,LastName,MobilePhone,Email,nm_RegistrationNo__c from Lead Where Id=:objLead.Id and IsConverted = false and IsDeleted = false LIMIT 1];
                        if(Agency == 'StudentPortal' && ld != null){
                            obj =new WapperId(ld.nm_RegistrationNo__c,'Success','Success');  
                            // apiReq.Response__c = obj.toString();
                            // apiReq.Type_of_Request__c= 'LeadService';
                            // apiReq.Lead__c = objLead.id;
                            // apiReq.API_Name__c='leadservice';
                            // apiReq.Success__c = true;
                            // apiRequestsInsertion(apiReq); 
                        }else{
                            obj =new WapperId(objLead.id,'Success','Success');
                            // apiReq.Response__c = obj.toString();
                            // apiReq.Type_of_Request__c= 'LeadService';
                            // apiReq.Lead__c = objLead.id;
                            // apiReq.API_Name__c='leadservice';
                            // apiReq.Success__c = true;
                            // apiRequestsInsertion(apiReq);
                        }
                    }    
                    return obj;
                }catch(Exception e) {  
                    System.debug('Exception '+e.getMessage());
                    WapperId obj =new WapperId('','Error','Internal Server Error');
                    apiReq.Response__c = obj.toString().replace('Internal Server Error', String.valueOf(e));
                    apiReq.Type_of_Request__c= 'LeadService';
                    apiReq.Lead__c = objLead.id;
                    apiReq.API_Name__c='leadservice';
                    apiReq.Success__c = false;
                    API_Request__c api = apiRequestsInsertion(apiReq);
                    // sendMailForFailed(requestString, obj.toString() + ' \n ' + e.getMessage(), api);
                    return obj;
                }  
            } 
            WapperId obj =new WapperId(null,'Error','Your Credentials are incorrect.');
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'LeadService';
            apiReq.API_Name__c='leadservice';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return obj;        
        }
    }  

    public static void SplitLeadName(String NameValue){
        if(String.isNotBlank(NameValue)){
            if(NameValue.indexOf(' ') > 0){
                FName=NameValue.substring(0,NameValue.indexOf(' '));
            }else{
                FName=NameValue;
            }

            if(NameValue.indexOf(' ') > 0){
                LName=NameValue.substring(NameValue.indexOf(' ')+1);
            }else{
                LName = '.';
            }
        }
    }
    
    public static map<string,string> ValidateNameandMaobile(string Name,string ContactNo,string CourseIntrestedIn)
    {
        map<string,string> mapOfError = new map<string,string>();
        if(!ContactNo.StartsWith('9') && !ContactNo.StartsWith('7') && !ContactNo.StartsWith('8') && !ContactNo.StartsWith('6')) {
            mapOfError.put('Error','Please Make Sure number should be start with 9 or 8 or 7 or 6 digits.');
        } else if(ContactNo.length() != 10 && ContactNo.length() != 12 ) {
            mapOfError.put('Error','Mobile Number Should be 10 OR 12 digits.');
        } else {
            Pattern phonePattern = Pattern.compile('^[0-9]*$');  
            Matcher phoneMatcher = phonePattern.matcher(ContactNo);  
            if(!phoneMatcher.find()) {
                mapOfError.put('Error','Mobile Number Should Not Contains Special Character.');
            }
        }
       
        if(Name != '') {
            String SPECIAL_CHAR_PATTERN = '[/[^a-zA-Z ]/,]';
            Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
            Matcher pm = p.matcher(Name);
            while (pm.find())
            {
                mapOfError.put('Error','Please Enter Valid Name.Name should not be contain special character and Number');
            }
        }
        if(CourseIntrestedIn!='Certificate Programs' && CourseIntrestedIn!='MBA (Online) Programs' && CourseIntrestedIn!='Diploma Programs' && CourseIntrestedIn!='Professional Programs' && CourseIntrestedIn!='Master Programs' && CourseIntrestedIn!='Bachelor Programs') {
            mapOfError.put('Error','Please choose correct program name --> Certificate Programs or Diploma Programs or Professional Programs or Master Programs or MBA (Online) Programs');
        }
        return mapOfError;
    }

    public static API_Request__c apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
        return apiRequest;
    }

    public static  String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }

    public static   List<nm_Centers__c> getlstActiveCenters(){
        if(lstActiveCenters.isEmpty()){
            String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null and RegistrationClosed__c =false','RecordType.Name');            
            // lstActiveCenters = DataBase.query(queryActiveCenters);
            Map<id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<id,nm_Centers__c>((List<nm_Centers__c>)DataBase.query(queryActiveCenters));
            lstActiveCenters = mapOfCenterIdVsCenter.values() ;
            system.debug('lstActiveCenters---query'+lstActiveCenters );
        }       
        return lstActiveCenters;
    }

  

    public static  Map<String,nm_Centers__c> getMapOfCenterNameVsCenter(){
        if(mapOfCenterNameVsCenter.isEmpty()){
          //  String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' Name != null ',null);
         //   List<nm_Centers__c> lstActiveCenters = DataBase.query(queryActiveCenters);
            List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
             system.debug('lstActiveCenters2--->'+lstActiveCenters );
            if(lstActiveCenters.size() > 0){
                for(nm_Centers__c objCenter : lstActiveCenters){
                    if(objCenter.Assign_IC_To_LC__c != null && objCenter.Assign_IC_To_LC__c != '') {
                        system.debug('@@@@@@@@@$$@$');
                        system.debug(objCenter.Assign_IC_To_LC__c);
                        List<String> lstAssignityToLc= new List<String>();
                        lstAssignityToLc =  objCenter.Assign_IC_To_LC__c.split(';');
                        for(string assignIcTOLC: lstAssignityToLc ) {
                         mapOfCenterNameVsCenter.put(assignIcTOLC.trim(),objCenter );
                        }
                        if(objCenter.RecordType.Name == 'Learning Center') {
                            system.debug('LC objCenter ====> ' + objCenter);
                            lstLearningCenters.add(objCenter);
                        }
 
                    }
                    mapOfCenterNameVsCenter.put(objCenter.Name,objCenter);
                }
            }
        }
        return mapOfCenterNameVsCenter;
    }

    // public static string addInformationCenterBasedOnCurrentLocation(String currentLocation, String programName) {


    //     Map<String,nm_Centers__c> mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();

    //     if(mapOfCenterNameVsCenter1.containsKey(currentLocation)) {
    //         nm_Centers__c c1 = mapOfCenterNameVsCenter1.get(currentLocation);
    //         if (c1.nm_ChooseaProgram__c == null) {
    //             c1.nm_ChooseaProgram__c = '';
    //         }
    //             System.debug(c1.nm_ChooseaProgram__c  + '@#@#@#@#@#@#@#@#');
    //             List<String> lstCourse1 =c1.nm_ChooseaProgram__c.split(';');
    //         List<String> lstCourseTrim1 = new List<String>();
    //         for(String str : lstCourse1) {
    //             lstCourseTrim1.add(str.trim());
    //         }
    //         if (lstCourseTrim1.contains(programName)) {
    //             return c1.Name;
    //         } else {
    //             nm_Centers__c c2 = mapOfCenterNameVsCenter1.get(c1.CenterName__c);
    //             if(c2.nm_ChooseaProgram__c == null) {
    //                 c2.nm_ChooseaProgram__c = '';
    //             }
    //             List<String> lstCourse2 =c2.nm_ChooseaProgram__c.split(';');
    //             List<String> lstCourseTrim2 = new List<String>();
    //         for(String str1 : lstCourse2) {
    //             lstCourseTrim2.add(str1.trim());
    //         }
    //             if(lstCourseTrim2.contains(programName)) {
    //                 return c2.Name;
    //             } else {
    //                 return mapOfCenterNameVsCenter1.get('Counsellor').name;
    //             }

    //         }
            
            
    //     }
    //     return mapOfCenterNameVsCenter1.get('Counsellor').name;

        // IF(currentLocation.contains('-')) {
        //     List<String> LocationWithDash = currentLocation.split('-');
        //     String rightLoc = LocationWithDash[1].trim();
        //     // List<nm_Centers__c	> centerLst = [SELECT ID, Name,Allow_Bachelor__c, Allow_PG__c, RecordType.Id FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //     List <nm_Centers__c> lstCenter = new List<nm_Centers__c>();
        //     for(nm_Centers__c c : lstActiveCenters) {
        //         if(c.Name.contains(rightLoc)) {
        //             lstCenter.add(c);
        //         }
        //     }

        //     If(lstCenter.size() > 0 ) {
        //         if (lstCenter.size() = 1) {
        //             // Code to return center Id
        //             If(programName == 'Bachelor Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }

        //             } else if (programName == 'MBA (Distance) Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }
        //             }

        //         } else {
        //             String leftLoc = '%' + LocationWithDash[0].trim() + '%';
        //             // List<nm_Centers__c	> centerLst1 = [SELECT ID, Name, Allow_Bachelor__c, Allow_PG__c FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //             // if(centerLst1 > 0) {
        //             //     // code to return center Id
        //             // }
        //         }
                
        //     }
        // } else if (currentLocation.contains(' ')) {
        //     List<String> LocationWithDash = currentLocation.split(' ');
        //     String rightLoc = LocationWithDash[1].trim();
        //     // List<nm_Centers__c	> centerLst = [SELECT ID, Name,Allow_Bachelor__c, Allow_PG__c, RecordType.Id FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //     List <nm_Centers__c> lstCenter = new List<nm_Centers__c>();
        //     for(nm_Centers__c c : lstActiveCenters) {
        //         if(c.Name.contains(rightLoc)) {
        //             lstCenter.add(c);
        //         }
        //     }

        //     If(lstCenter.size() > 0 ) {
        //         if (lstCenter.size() = 1) {
        //             // Code to return center Id
        //             If(programName == 'Bachelor Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }

        //             } else if (programName == 'MBA (Distance) Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }
        //             }

        //         } else {
        //             String leftLoc = '%' + LocationWithDash[0].trim() + '%';
        //             // List<nm_Centers__c	> centerLst1 = [SELECT ID, Name, Allow_Bachelor__c, Allow_PG__c FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //             // if(centerLst1 > 0) {
        //             //     // code to return center Id
        //             // }
        //         }
                
        //     }
        // } else {
        //     // List<String> LocationWithDash = currentLocation.split(' ');
        //     String rightLoc = currentLocation.trim();
        //     // List<nm_Centers__c	> centerLst = [SELECT ID, Name,Allow_Bachelor__c, Allow_PG__c, RecordType.Id FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //     List <nm_Centers__c> lstCenter = new List<nm_Centers__c>();
        //     for(nm_Centers__c c : lstActiveCenters) {
        //         if(c.Name.contains(rightLoc)) {
        //             lstCenter.add(c);
        //         }
        //     }

        //     If(lstCenter.size() > 0 ) {
        //         if (lstCenter.size() = 1) {
        //             // Code to return center Id
        //             If(programName == 'Bachelor Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }

        //             } else if (programName == 'MBA (Distance) Programs') {
        //                 nm_Centers__c c1 = mapOfCenterIdVsCenter.get(lstCenter[0].Id);
        //                 if (c1.Allow_Bachelor__c == True) {
        //                     return c1.Id;
        //                 } else if (c1.Allow_Bachelor__c == False) {
        //                     if ( mapOfCenterIdVsCenter.containsKey(c1.nm_LearningCenter__c)) {
        //                         nm_Centers__c c2 = mapOfCenterIdVsCenter.get(c1.nm_LearningCenter__c);
        //                         if(c2.Allow_Bachelor__c == True)  {
        //                             return c2.Id;
        //                         }
        //                         return null;
        //                     }
        //                 } else {
        //                     return 'a02O000000E97Ho';
        //                 }
        //             }

        //         } else {
        //             String leftLoc = '%' + LocationWithDash[0].trim() + '%';
        //             // List<nm_Centers__c	> centerLst1 = [SELECT ID, Name, Allow_Bachelor__c, Allow_PG__c FROM nm_Centers__c WHERE Name Like :rightLoc ];
        //             // if(centerLst1 > 0) {
        //             //     // code to return center Id
        //             // }
        //         }
                
        //     }
        // }
    // }
    public static string addInformationCenterBasedOnAEP(String currentLocation, String programName,String  AdvertAgency) {
        Map < String, nm_Centers__c > mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
        AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
        if(currentLocation.contains(',')) {
            currentLocation = currentLocation.split(',')[0];
        }

        system.debug('%^&%&^$%&^$%');
        if( Boolean.valueOf(System.Label.LC_Wise_Distribution_Active	)) {
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
        if(mapOfCenterNameVsCenter1.containsKey(currentLocation) && programName!=''  ) {
            nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(currentLocation);
            if(objCenter1.nm_ChooseaProgram__c!=null && objCenter1.nm_ChooseaProgram__c!=''  && objCenter1.nm_ChooseaProgram__c.contains(programName)){
            
                return String.valueof(objCenter1.Name);
            
            } else {
                
                nm_Centers__c objCenter2 = mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c);
                
                if(objCenter2.nm_ChooseaProgram__c!=null && objCenter2.nm_ChooseaProgram__c!='' && objCenter2.nm_ChooseaProgram__c.contains(programName)){
    
                    return objCenter2.Name;
                }
            }
        } 
        return mapOfCenterNameVsCenter1.get('Counsellor').name;
    }

    // public static void sendMailForFailed(String request, String response, API_Request__c apiReq) {
    //   Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    //   String url =  URL.getOrgDomainUrl().toExternalForm()+ '/'+ apiReq.Id;
    //   OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS Global Access' LIMIT 1];
    //   String[] sendingToAddress = new List<String>();
    //   if(System.Label.Environment == 'Sandbox') {
    //     sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
    //   } else if(System.Label.Environment == 'Production') {
    //      sendingToAddress = System.Label.setBccAdderess.split(',');
    //   }
    //   semail.setToAddresses(sendingToAddress); 
    //   semail.setOrgWideEmailAddressId(owe.id); 
    //   semail.setReplyTo('ngasce@nmims.edu'); 
    //   semail.setSubject('LeadService Error'); 
    //   String messageBody = '<html><p>Dear Team,</p>'
    //                             +'<p>Request and Response for LeadService for which Error was Found</p>'
    //                             +'<p>Please click <a href="'+url+'" >here</a> to navigate to API Request</p>'
    //                             +'<p>Request = ' + request +' </p>'
    //                             +'<p>Response = '+ response +' </p>'
    //                             +'<p>Thanks and Regards,</p>'
    //                             +'<p>NMIMS Global Access</p></html>';
    //     semail.setHtmlBody(messageBody);
    //   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
    // }
    
}