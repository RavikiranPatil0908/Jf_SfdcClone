/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 26-09-2024
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/CompanyLeadService/*')
global class CompanyLeadService {
    
    public static String FName ='';
    public static String LName = '';
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
    global static WapperId connectToEnquiry(String Name,String EmailID,String ContactNo,String Agency,String Company,String CourseIntrestedIn, String ProgramIntrestedIn,String Source)
    {   
        String requestString = '{"Name":\"'+Name+'\","EmailID":\"'+EmailID+'\","ContactNo":\"'+ContactNo+'\","Agency":\"'+Agency+'\","Company":\"'+Company+'\","CourseIntrestedIn":\"'+CourseIntrestedIn+'\","ProgramIntrestedIn":\"'+ProgramIntrestedIn+'\","Source":\"'+Source+'\"}';
        String Category='Distance Learning / Correspondence';
        string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
        Integer AdmissionYear;
        Agency = Agency != null && Agency != '' && Agency != 'null' ? Agency : '';
        API_Request__c apiReq = new API_Request__c();
        System.debug('CourseIntrested in--->'+CourseIntrestedIn);
        RestRequest req = RestContext.request;
        //CompanyLeadServiceWrapper reqWrapper = CompanyLeadServiceWrapper.parse(requestString);
        apiReq.Request__c = requestString;
        String ipAddress = req.remoteAddress;
        Company = Company != null && Company != '' && Company != 'null' ? Company.trim() : '';
        if (String.isBlank(Company)) {
            WapperId obj =new WapperId('','Error','Kindly Provide Company Name');
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'CompanyLeadService';
            apiReq.API_Name__c='CompanyLeadService';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return obj;
        }
        String leadSource = CompanyVsLeadSource(Company);
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

        AdmissionYear = System.Today().year();
        System.debug('AdmissionYear '+AdmissionYear);
        // Innformation Center
        String CenterName = addLCBasedOnCompany(Company);
        
        
        // Insert Duplicate Lead with Reborn Status and throwing Error of Duplicate Lead for User 
        if(CenterName == 'Not Found') {
            WapperId obj =new WapperId('','Error','No Company Found with ' + Company);
            apiReq.Response__c = obj.toString();
            apiReq.Type_of_Request__c= 'CompanyLeadService';
            apiReq.API_Name__c='CompanyLeadService';
            apiReq.Success__c = false;
            apiRequestsInsertion(apiReq);
            return obj;
        }
        list<Lead> lstLead=[Select id,Email,MobilePhone,nm_RegistrationNo__c from Lead where (Email=:EmailID or MobilePhone=:ContactNo) and IsConverted=false];
        if(lstLead.size()>0) {
            WapperId obj;
            Map<String,String> mapOfErrorMessages = ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
            System.debug('ProgramIntrestedIn 2 -->'+ProgramIntrestedIn);
            Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,Agency__c=Agency,
            nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress, nm_OtherLeadSources__c = Source,nm_Company_Name__c	= Company,
            nm_SelectedProgram__c=ProgramIntrestedIn);
            if(!mapOfErrorMessages.isEmpty()) {
               obj =new WapperId(objLead.Id,'Error',mapOfErrorMessages.get('Error'));
               apiReq.Response__c = obj.toString();
               apiReq.Type_of_Request__c= 'CompanyLeadService';
               apiReq.Lead__c = lstLead[0].id;
               apiReq.API_Name__c='CompanyLeadService';
               apiReq.Success__c = false;
               apiRequestsInsertion(apiReq);
            } else {
                // insert objLead;
                obj =new WapperId(lstLead[0].id,'Duplicate','Duplicate Lead Found');
                apiReq.Response__c = obj.toString();
                apiReq.Type_of_Request__c= 'CompanyLeadService';
                apiReq.Lead__c = lstLead[0].id;
                apiReq.API_Name__c='CompanyLeadService';
                apiReq.Success__c = false;
                apiRequestsInsertion(apiReq);       
            }    
            return obj;
        } else {
                Map<String,String> mapOfErrorMessages =ValidateNameandMaobile(Name,ContactNo,CourseIntrestedIn);
                Lead objLead = new Lead(FirstName=FName,LastName=LName,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CenterName,Agency__c=Agency,
                nm_OtherLeadSources__c = Source,nm_Company_Name__c	= Company,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress,nm_SelectedProgram__c=ProgramIntrestedIn);
                try {
                    WapperId obj;
                    System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                    if(!mapOfErrorMessages.isEmpty()) {
                        System.debug('mapOfErrorMessages '+mapOfErrorMessages);
                        obj =new WapperId('','Error',mapOfErrorMessages.get('Error'));
                        apiReq.Response__c = obj.toString();
                        apiReq.Type_of_Request__c= 'CompanyLeadService';
                        apiReq.Lead__c = objLead.id;
                        apiReq.API_Name__c='CompanyLeadService';
                        apiReq.Success__c = false;
                        apiRequestsInsertion(apiReq);         
                    } else {
                        insert objLead;
                        // Lead ld = [select Id,FirstName,LastName,MobilePhone,Email,nm_RegistrationNo__c from Lead Where Id=:objLead.Id and IsConverted = false and IsDeleted = false LIMIT 1];
                        obj =new WapperId(objLead.Id,'Success','Success');  
                        apiReq.Response__c = obj.toString();
                        apiReq.Type_of_Request__c= 'CompanyLeadService';
                        apiReq.Lead__c = objLead.id;
                        apiReq.API_Name__c='CompanyLeadService';
                        apiReq.Success__c = true;
                        apiRequestsInsertion(apiReq); 
                        
                    }    
                    return obj;
                }catch(Exception e) {  
                    System.debug('Exception '+e.getMessage());
                    WapperId obj =new WapperId('','Error','Internal Server Error');
                    apiReq.Response__c = obj.toString().replace('Internal Server Error', String.valueOf(e));
                    apiReq.Type_of_Request__c= 'CompanyLeadService';
                    apiReq.Lead__c = objLead.id;
                    apiReq.API_Name__c='CompanyLeadService';
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

    public static  String getlstActiveCenters(){
         List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
        return getQueryAllFieldSql('nm_Centers__c',' id !=null and RegistrationClosed__c =false',null);
    }

  

    public static  Map<String,nm_Centers__c> getMapOfCenterNameVsCenter(){
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();
        for(nm_Centers__c objCenter : DataBase.query(getlstActiveCenters())){
            // mapOfCenterNameVsCenter.put(objCenter.Name, objCenter);
            if (String.isNotBlank(objCenter.Assign_Company__c)) {
                    List < String > lstAssignityToLc = new List < String > ();
                    lstAssignityToLc = objCenter.Assign_Company__c.split(';');
                    for (string assignTOLC: lstAssignityToLc) {
                        mapOfCenterNameVsCenter.put(assignTOLC.trim().toLowerCase(), objCenter);
                    }
                }
        }
        return mapOfCenterNameVsCenter;
    }

    public static string addLCBasedOnCompany(String Company) {
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
        if(String.isNotBlank(Company) && mapOfCenterNameVsCenter1.containsKey(Company.toLowerCase())  ) {
            return  mapOfCenterNameVsCenter1.get(Company.toLowerCase()).CenterName__c;
        } 
        return 'Not Found' ;
    }

    public static String CompanyVsLeadSource(String company) {

        for (Company_Lead_Source__mdt cLead : [ SELECT id, Company_List__c	, Label FROM Company_Lead_Source__mdt]) {
            List<String> lstCompany = String.isNotBlank(cLead.Company_List__c) ? cLead.Company_List__c.split(';') : new List<String>();
            if(lstCompany.size() > 0) {
                for (String com : lstCompany) {
                    if(com.trim().equalsIgnoreCase(company)) {
                        return cLead.Label;
                    }
                }
            }
        }
        return '';


    // Set<String> setOfCCAEP = new Set<String>{'Accenture', 'Apollo Tyres', 'AON', 'OTIS', 'Verizon', 'Cushman Wakefield', 'Mettler Toledo', 'Diageo', 'Udaan', 'Live Pixel Technologies', 'Den', 'Mswipe Technologies', 'Medika Bazaar', 'BOS', 'Edward life science', 'Luke plascon', 'Mercer Mettl', 'Vendimann', 'Admiral Solutions', 'Dainik Bhaskar', 'Sandhar', 'Map my India', 'Rategain', 'Guardian', 'Q3 Technologies', 'AVIVA', 'AHFL', 'Sentiss Pharma', 'Ecole Intuit', 'PWC', 'HCL Technologies'};
    // Set<String> setOfAEPCC = new Set<String>{'Concentrix', 'Multiplier Brands', 'CBSL - Conneqt Business Solutions ltd', 'ADP', 'CtrlS', 'Infosys'};
    // if(setOfCCAEP.contains(company)) {
    //     return 'CC-AEP';
    // } else if(setOfAEPCC.contains(company)) {
    //     return 'AEP-CC';
    // } else {
    //     return '';
    // }

    }
}