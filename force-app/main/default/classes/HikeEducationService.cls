/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 26-09-2024
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/HikeEducationService/*')
global class HikeEducationService {
    
    public static String FName ='';
    public static String LName = '';
    global class WapperId
    {
        public String RegistrationNo {get;set;}
        public String result {get;set;}
        public String message {get;set;}
        public WapperId(String Id,String message,String result)
        {
            this.RegistrationNo=Id;
            this.message=message ;
            this.result =result;
        }
    }
     @HttpPost
    global static WapperId connectToEnquiry(String Name,String EmailID,String ContactNo,String Agency,String HighestQualification,decimal AdmissionYear,String CurrentLocation,String CourseIntrestedIn, String ProgramIntrestedIn,String Source,String mx_Lead_Status, String  mx_Lead_Description,String PartnerLeadSource)
    {   
        Set<String> setOfLeadStatus = new Set<String>();
        Set<String> setOfLeadDescription = new Set<String>();
        String requestString = '{"Name":\"'+Name+'\","EmailID":\"'+EmailID+'\","ContactNo":\"'+ContactNo+'\","Agency":\"'+Agency+'\","HighestQualification":\"'+HighestQualification+'\","AdmissionYear":\"'+AdmissionYear+'\","CurrentLocation":\"'+CurrentLocation+'\","CourseIntrestedIn":\"'+CourseIntrestedIn+'\","ProgramIntrestedIn":\"'+ProgramIntrestedIn+'\","Source":\"'+Source+'\","mx_Lead_Status":\"'+mx_Lead_Status+'\","mx_Lead_Description":\"'+mx_Lead_Description+'\","PartnerLeadSource":\"'+PartnerLeadSource+'\"}';
        for (Schema.PicklistEntry pe : Lead.Status.getDescribe().getPicklistValues()){
            setOfLeadStatus.add(pe.getValue());
        }
        for (Schema.PicklistEntry pe : Lead.Lead_Description__c.getDescribe().getPicklistValues()){
            setOfLeadDescription.add(pe.getValue());
        }
        String Category='Distance Learning / Correspondence';
        // string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
        String leadSource = Source != null && Source != '' && Source != 'null' ? Source : 'Web';
        String leadStatus = mx_Lead_Status != null && mx_Lead_Status != '' && mx_Lead_Status != 'null' ? mx_Lead_Status : '';
        String leadDescription = mx_Lead_Description != null && mx_Lead_Description != '' && mx_Lead_Description != 'null' ? mx_Lead_Description : '';
        API_Request__c apiReq = new API_Request__c();
        System.debug('CourseIntrested in--->'+CourseIntrestedIn);
        RestRequest req = RestContext.request;
        //HikeEducationServiceWrapper reqWrapper = HikeEducationServiceWrapper.parse(requestString);
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
        String CenterName = addInformationCenterBasedOnAEP(CurrentLocation, CourseIntrestedIn);
        
        
        // Insert Duplicate Lead with Reborn Status and throwing Error of Duplicate Lead for User 
        if(CenterName == 'Not Found') {
            WapperId obj =new WapperId('','Error','Lead Doesn\'t belong to HIKE Education');
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'HikeEducationService';
            apiReq.API_Name__c='HikeEducationService';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return obj;
        }

        if(String.isNotBlank(leadStatus)) {
            if (!setOfLeadStatus.contains(leadStatus)) {
                WapperId obj =new WapperId('','Error','Kindly Provide correct Lead Status');
                apiReq.Response__c = obj.toString();
                apiReq.Type_of_Request__c= 'HikeEducationService';
                apiReq.API_Name__c='HikeEducationService';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return obj;
            }
        }

        if(String.isNotBlank(leadDescription)) {
            if (!setOfLeadDescription.contains(leadDescription)) {
                WapperId obj =new WapperId('','Error','Kindly Provide correct Lead Description');
                apiReq.Response__c = obj.toString();
                apiReq.Type_of_Request__c= 'HikeEducationService';
                apiReq.API_Name__c='HikeEducationService';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);
                return obj;
            }
        }
        list<Lead> lstLead=[Select id,Email,MobilePhone,nm_RegistrationNo__c from Lead where (Email=:EmailID or MobilePhone=:ContactNo) AND nm_InformationCenter__r.Name =:CenterName and IsConverted=false LIMIT 1];
        if(lstLead.size()>0) {
            if (String.isNotBlank(leadStatus) && String.isNotBlank(leadDescription)) {
                Lead objLead = new Lead(Id = lstLead[0].Id, Status = leadStatus, Lead_Description__c = leadDescription, Next_Follow_up__c = system.now().addMinutes(30) );
                update objLead;
                WapperId obj;
                return obj = new WapperId(lstLead[0].nm_RegistrationNo__c,'Updated','Lead Status and Description Updated');
                
            }
            WapperId obj;
            obj = new WapperId(lstLead[0].nm_RegistrationNo__c,'Error','Kindly Provide Lead Status and Lead Description');
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'HikeEducationService';
            apiReq.API_Name__c='HikeEducationService';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            




            // apiReq.Response__c = obj.toString();
            // apiReq.Type_of_Request__c= 'HikeEducationService';
            // apiReq.Lead__c = lstLead[0].id;
            // apiReq.API_Name__c='HikeEducationService';
            // apiReq.Success__c = false;
            // apiRequestsInsertion(apiReq);

            // System.debug('ProgramIntrestedIn 1 -->'+ProgramIntrestedIn);
            // Map<String,String> mapOfErrorMessages = ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
            // System.debug('mapOfErrorMessages '+mapOfErrorMessages);
            // System.debug('ProgramIntrestedIn 2 -->'+ProgramIntrestedIn);
            // Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,Highest_Qualification__c=HighestQualification,Agency__c=Agency,
            // nm_StudentSelectedIC__c=CurrentLocation,
            // nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress,
            // nm_SelectedProgram__c=ProgramIntrestedIn);
            // if(!mapOfErrorMessages.isEmpty()) {
            //    obj =new WapperId(objLead.nm_RegistrationNo__c,'Error',mapOfErrorMessages.get('Error'));
            //    apiReq.Response__c = obj.toString();
            //    apiReq.Type_of_Request__c= 'HikeEducationService';
            //    apiReq.Lead__c = objLead.id;
            //    apiReq.API_Name__c='HikeEducationService';
            //    apiReq.Success__c = false;
            //    apiRequestsInsertion(apiReq);
            // } else {
            //     // insert objLead;
            //     obj =new WapperId(lstLead[0].nm_RegistrationNo__c,'Duplicate','Duplicate Lead Found');
            //     apiReq.Response__c = obj.toString();
            //     apiReq.Type_of_Request__c= 'HikeEducationService';
            //     apiReq.Lead__c = lstLead[0].id;
            //     apiReq.API_Name__c='HikeEducationService';
            //     apiReq.Success__c = false;
            //     apiRequestsInsertion(apiReq);       
            // }    
            return obj;
        } else {
                String leadStatusInElse = String.isNotBlank(leadStatus) ? leadStatus : 'Not Contacted';
                DateTime nextFollowUp = leadStatusInElse == 'Not Contacted' ? system.now() : system.now().addMinutes(30);
                Map<String,String> mapOfErrorMessages =ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
                Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=leadStatusInElse,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,Agency__c=Agency,
                nm_StudentSelectedIC__c=CurrentLocation,Lead_Description__c =leadDescription, Next_Follow_up__c= nextFollowUp,Partner_Lead_Source__c=PartnerLeadSource,
                Highest_Qualification__c=HighestQualification,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress,nm_SelectedProgram__c=ProgramIntrestedIn);
                try {
                    WapperId obj;
                    System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                    if(!mapOfErrorMessages.isEmpty()) {
                        System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                        obj =new WapperId('','Error',mapOfErrorMessages.get('Error'));
                        apiReq.Response__c = obj.toString();
                        apiReq.Type_of_Request__c= 'HikeEducationService';
                        apiReq.Lead__c = objLead.id;
                        apiReq.API_Name__c='HikeEducationService';
                        apiReq.Success__c = false;
                        apiRequestsInsertion(apiReq);         
                    } else {
                        insert objLead;
                        Lead ld = [select Id,FirstName,LastName,MobilePhone,Email,nm_RegistrationNo__c from Lead Where Id=:objLead.Id and IsConverted = false and IsDeleted = false LIMIT 1];
                        obj =new WapperId(ld.nm_RegistrationNo__c,'Success','Success');  
                        // apiReq.Response__c = obj.toString();
                        // apiReq.Type_of_Request__c= 'HikeEducationService';
                        // apiReq.Lead__c = objLead.id;
                        // apiReq.API_Name__c='HikeEducationService';
                        // apiReq.Success__c = true;
                        // apiRequestsInsertion(apiReq); 
                        
                    }    
                    return obj;
                }catch(Exception e) {  
                    System.debug('Exception '+e.getMessage());
                    WapperId obj =new WapperId('','Error','Internal Server Error');
                    apiReq.Response__c = obj.toString().replace('Internal Server Error', String.valueOf(e));
                    apiReq.Type_of_Request__c= 'HikeEducationService';
                    apiReq.Lead__c = objLead.id;
                    apiReq.API_Name__c='HikeEducationService';
                    apiReq.Success__c = false;
                    apiRequestsInsertion(apiReq);
                    return obj;
                }         
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

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
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
         List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
        String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null and RegistrationClosed__c =false AND GroupName__c= \'Group 1\'','RecordType.Name');            
        // lstActiveCenters = DataBase.query(queryActiveCenters);
        Map<id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<id,nm_Centers__c>((List<nm_Centers__c>)DataBase.query(queryActiveCenters));
        lstActiveCenters = mapOfCenterIdVsCenter.values() ;
        return lstActiveCenters;
    }

  

    public static  Map<String,nm_Centers__c> getMapOfCenterNameVsCenter(){
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();
        List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
         system.debug('lstActiveCenters2--->'+lstActiveCenters );
        if(lstActiveCenters.size() > 0){
            for(nm_Centers__c objCenter : lstActiveCenters){
                mapOfCenterNameVsCenter.put(objCenter.Name,objCenter);
            }
        }
        return mapOfCenterNameVsCenter;
    }

    public static string addInformationCenterBasedOnAEP(String currentLocation, String programName) {
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
        if(mapOfCenterNameVsCenter1.containsKey(currentLocation) && String.isNotBlank(programName)) {
            nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(currentLocation);
            if(String.isNotBlank(objCenter1.nm_ChooseaProgram__c) && objCenter1.nm_ChooseaProgram__c.contains(programName)){
                return String.valueof(objCenter1.Name);
            }
        } else if(currentLocation.equalsIgnoreCase('Hike Education')) {
            return 'Hike Education';
        }
        return 'Not Found' ;
    }
}