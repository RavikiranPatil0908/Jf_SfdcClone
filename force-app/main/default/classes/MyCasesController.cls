/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 27--03--2025
 * @last modified by  : @Ravi
**/
public without sharing class MyCasesController {
    //Note: studentNo may have something appended in front of it  
    public static String msg = '';
    public static String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
    public static String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    public static String web = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Web Case').getRecordTypeId();

    @AuraEnabled
    public static String decryptToken(String token){
        if(token !='' && token !=null)
        {
            System.debug('token1--'+token);
            //token = EncodingUtil.urlEncode(token, 'UTF-8');
            token = token.replace(' ','+');
            System.debug('token2--'+token);
            Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
            Blob encryptedData  = EncodingUtil.base64Decode(token);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128',key, encryptedData);
            String b64Decrypted = decryptedData.toString();
            long currentTimeInMiliseconds = DateTime.now().getTime();
            String sapId = b64Decrypted.split('~')[0];
            system.debug('Sap Id '+sapId);
            long timeUrlHit = Long.valueOf(b64Decrypted.split('~')[1]);
            
            Account acc = new Account();
            try{
                acc = [SELECT Id, nm_StudentNo__c FROM Account WHERE nm_StudentNo__c like :'%'+sapId LIMIT 1];            
            }catch(Exception e){
                system.debug(e);
                return 'No record found with this sapId';
            }            
            if(acc.nm_StudentNo__c != null){
                system.debug('sapid '+acc.nm_StudentNo__c);
                system.debug('time '+timeUrlHit);
                return acc.nm_StudentNo__c+' '+timeUrlHit; 
            }
        }           
        return '';
    }
    
    @AuraEnabled
    public static String createCase(Map<String,String> caseMap){
        system.debug('caseMap '+caseMap);
        DateTime dT = system.today();
        Date d = date.newinstance(dT.year(), dT.month(), dT.day());
        
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        Case c = new Case();
        Account acc = new Account();
        Lead lead = new Lead();
        c.CaseMap__c = String.valueOf(caseMap);
        List<String> CareerSubCategories=new List<String>();
        String studentNo=caseMap.get('studentNo');
        if(caseMap.get('category') == 'Career Services'){
            List<Case> listServiceCases= [SELECT Id,Student_Sub_Categories__c,Student_Category__c,Status,CaseNumber FROM Case WHERE Student_Category__c = 'Career Services' AND  Student_No__c=:studentNo AND Status !='Closed'];
            system.debug('listServiceCases==> '+listServiceCases);
            if(!listServiceCases.Isempty()){
            for(Case subCat: listServiceCases) {
                CareerSubCategories.add(subCat.Student_Sub_Categories__c);
            }
            if(CareerSubCategories.contains(caseMap.get('subcat'))){
                return 'You can only have one active callback request for Career Services at a time, Please wait until your existing request is closed. However, you may request callbacks for other services if needed';
             }
         }
        }
       
        if(caseMap.containsKey('accId')){
            acc = [SELECT Id, Name, PersonEmail, PersonContactId, nm_StudentNo__c, nm_Centers__c, LC_Name__c FROM Account WHERE IsPersonAccount = true AND Id = :caseMap.get('accId')];
            c.Student_No__c = acc.nm_StudentNo__c;
        }else if(caseMap.containsKey('converted') && caseMap.get('converted') != ''){
            if(caseMap.get('converted') == 'true'){
                if(String.isNotBlank(caseMap.get('regNo'))) {
                    acc = [SELECT Id, Name, PersonEmail, PersonContactId, nm_Centers__c, LC_Name__c FROM Account WHERE IsPersonAccount = true AND ((nm_RegistrationNumber__c != null AND nm_RegistrationNumber__c like :'%'+caseMap.get('regNo'))) LIMIT 1];
                } else if(String.isNotBlank(caseMap.get('email')) && String.isNotBlank(caseMap.get('mobile'))) {
                    acc = [SELECT Id, Name, PersonEmail, PersonContactId, nm_Centers__c, LC_Name__c FROM Account WHERE IsPersonAccount = true AND ((PersonEmail!=null AND PersonMobilePhone!=null AND PersonEmail=:caseMap.get('email') AND PersonMobilePhone=:caseMap.get('mobile'))) LIMIT 1];
                }
                c.Registration_No__c = caseMap.get('regNo');

            }else if(caseMap.get('converted') == 'false'){
                if(String.isNotBlank(caseMap.get('regNo'))) {
                    lead = lead = [SELECT Id, Name, MobilePhone, Email FROM Lead WHERE ((nm_RegistrationNo__c != null AND nm_RegistrationNo__c like :'%'+caseMap.get('regNo'))) limit 1];
                    c.Lead__c = lead.Id;
                    c.Registration_No__c = caseMap.get('regNo');
                    c.SuppliedEmail = lead.Email;
                    c.SuppliedName = lead.Name;
                } else if(String.isNotBlank(caseMap.get('email')) && String.isNotBlank(caseMap.get('mobile'))) {
                    lead = lead = [SELECT Id, Name, MobilePhone, Email FROM Lead WHERE ((Email!=null AND MobilePhone!=null AND Email=:caseMap.get('email') AND MobilePhone=:caseMap.get('mobile'))) limit 1];
                    c.Lead__c = lead.Id;
                    c.Registration_No__c = caseMap.get('regNo');
                    c.SuppliedEmail = lead.Email;
                    c.SuppliedName = lead.Name;
                }
            }
            c.RecordTypeId = web;
            c.Status = 'New';
            Case__c mcs = Case__c.getValues(caseMap.get('category'));
                Integer tat = Integer.valueOF(mcs.TAT__c);
                Integer diff = getNumberOfDays(System.today(), d.addDays(tat));
                if(diff < tat){
                    Integer actualTat = tat + (tat-diff);
                    c.Expected_Close_Date__c = d.addDays(actualTat);
                }else{
                    c.Expected_Close_Date__c = d.addDays(tat);
                }

        }else if(caseMap.containsKey('studentNo') && caseMap.get('studentNo') != ''){
            system.debug('studentNo '+caseMap.get('studentNo'));
            acc = [SELECT Id, Name, PersonEmail, PersonContactId, nm_Centers__c, LC_Name__c FROM Account WHERE IsPersonAccount = true AND nm_StudentNo__c like :'%'+caseMap.get('studentNo') LIMIT 1];
            c.Student_No__c = caseMap.get('studentNo');
           
        } else{
            CalloutException e = new CalloutException();
            e.setMessage('Case cannot be created.');
            throw e;
        }
        if(caseMap.containsKey('studentNo')) { 
            System.debug('Inside if');
            if(caseMap.get('purpose') == 'Feedback'){
                c.Status = 'Closed';
                c.Student_Status__c = 'Closed';
                c.Tech_Issue__c = 'No';
                c.RecordTypeId = feedback;               
            }else{
                c.Status = 'New';
                c.RecordTypeId = ticket;
                Case__c mcs = Case__c.getValues(caseMap.get('category'));
                Integer tat = Integer.valueOF(mcs.TAT__c);
                Integer diff = getNumberOfDays(System.today(), d.addDays(tat));
                if(diff < tat){
                    Integer actualTat = tat + (tat-diff);
                    c.Expected_Close_Date__c = d.addDays(actualTat);
                }else{
                    c.Expected_Close_Date__c = d.addDays(tat);
                }
            }    
        }

        c.Student_Purpose__c = caseMap.get('purpose');
        c.Student_Category__c = caseMap.get('category');
        c.Student_Sub_Categories__c = caseMap.get('subcat');
        c.Proposed_Research_Topic__c = caseMap.get('topic');
        c.Problem_Statament__c = caseMap.get('probStatement');
        c.Business_Issues__c = caseMap.get('businessIssu');
        c.Relevance_of_Research__c = caseMap.get('relevance');
        c.Research_Objective__c = caseMap.get('researchObj');
        c.Research_Hypothis__c = caseMap.get('researchHypo');
        c.Proposed_Research__c= caseMap.get('researchMetho');
        c.Expected_Outcomes_and_Implications__c = caseMap.get('expectedOutcome');

        // if (caseMap.get('category') == 'Learner Support Center') {
        //     c.Student_Sub_Categories__c = null; // Hide Sub category
        // } else {
        //     c.Student_Sub_Categories__c = caseMap.get('subcat');
        // }

        c.Subject = caseMap.get('sub');
        c.Description = caseMap.get('description');
        c.nm_Category__c = null;
        c.Escalation_Level__c = 0;
        c.Case_created__c = true;


    // Assign case owner based on category
        if (caseMap.containsKey('category') && (caseMap.get('category') == 'Learner Support Center' || (caseMap.get('category') == 'Admissions' && caseMap.get('subcat') == 'Admission Cancellation')) && acc.nm_Centers__c != null) {
        // Fetch the Account's LC and set as the case owner
            String learningCenterId = [SELECT OwnerId FROM nm_Centers__c WHERE Id = :acc.nm_Centers__c LIMIT 1].OwnerId;
            if (String.isNotBlank(learningCenterId)) {
              c.OwnerId = learningCenterId;
              //c.Is_Call_Schedule__c = true;
            }
            if(caseMap.get('category') == 'Admissions' && caseMap.get('subcat') == 'Admission Cancellation'){
                // set no modification flag
                c.nomodificationflag__c = true;
            }
        } else if(caseMap.containsKey('category') && (caseMap.get('category') == 'Career Services')){
            User lstUser = [SELECT Id, Name, IsActive, Profile.Name FROM User WHERE Name ='Vrushali Mahida'];
             c.OwnerId =lstUser.Id ;
        }
        else {
            c.setOptions(dmlOpts);
        }

        //set isSchedule flag
        if(caseMap.containsKey('isSchedule') && caseMap.get('isSchedule') == 'yes' && isSlotsAvialable(caseMap.get('category'),acc.LC_Name__c)) {
            c.Is_Call_Schedule__c = true;
        }
            
      if(acc.Id != null){
            c.AccountId = acc.Id;
            c.ContactId = acc.PersonContactId;
            c.SuppliedEmail = acc.PersonEmail;
            c.SuppliedName = acc.Name;
        }
        if(caseMap.containsKey('source')){
            c.Origin = caseMap.get('source');
        }else{
            c.Origin = 'Website';
        }
        insert c;
        
        String cno = [SELECT CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
        return c.Id+' '+cno;            
    }

    /**
    * @description : To find the Slots Avialablity
    * @author @BK | 07-10-2023 
    * @return Boolean 
    **/
    public static Boolean isSlotsAvialable(String category, String lcType) {
        try {
            String recordTypeName = category == 'Learner Support Center' ? 'Voice Call - LC Support' : 'Voice Call - Support';
            String type = category == 'Learner Support Center' ? lcType : '';
            List<Schedule_Time_Slot__c> lstScheduling = [SELECT Id,Start_time__c,End_time__c,Skill_Name__c,Total_Counselors__c,Type_of_Call__c,Per_Call_Schedule_Minutes__c,Start_date__c,End_date__c,Recurrence__c,Custom_Schedule_Days__c FROM Schedule_Time_Slot__c WHERE IsActive__c=true AND End_date__c>TODAY AND Type_of_Call__c='Regular' AND RecordType.Name =:recordTypeName AND LC_Type__c=:type];
            return lstScheduling.size() > 0 ? true : false;
        } catch (Exception e) {
            System.debug(e);
        }
        return false;
    }
    
    @AuraEnabled
    public static void addComment(String comment, String caseId, Boolean isReopen){
        
        CaseComment comm = new CaseComment();
        comm.CommentBody = comment;
        comm.ParentId = caseId; 
        comm.IsPublished = true;
        insert comm;
        
        Case c = [SELECT Status,OwnerId FROM Case WHERE Id = :caseId];
        List<Group> lstQueues = [SELECT Id,Name,DeveloperName,Email,Type FROM Group WHERE Type='Queue' AND Name='Omni Queue Backup Case' LIMIT 1];
        if(c.Status != 'Closed' && !isReopen && (c.OwnerId.getSobjectType()!=Group.SobjectType || (lstQueues.size() > 0 && lstQueues[0].Id != c.OwnerId))){
            c.Status = 'Response Received';
            update c;
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getStudentDetails(String sno, String rno, String email, String mobile){
        Map<String,String> studentMap = new Map<String,String>();
        List<Account> acc = new List<Account>();
        List<Lead> lead = new List<Lead>();
        try{                        
            if(rno != ''){
                //acc = [SELECT Id, nm_StudentImageUrl__c, FirstName, LastName, PersonMobilePhone, PersonEmail, nm_Program__r.Name, ValidUptoR__c, nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c like :'%'+rno limit 1];
                lead = [SELECT Id, MobilePhone, Email, FirstName, LastName, nm_Program__r.Name, IsConverted FROM Lead WHERE nm_RegistrationNo__c like :'%'+rno limit 1]; 
                if(lead.isEmpty()){
                    acc = [SELECT Id, nm_StudentImageUrl__c, FirstName, LastName, PersonMobilePhone, PersonEmail, nm_Program__r.Name, ValidUptoR__c, nm_StudentNo__c FROM Account WHERE IsPersonAccount = true AND nm_RegistrationNumber__c like :'%'+rno limit 1];
                }
            }
            if(email != '' && mobile != ''){
                //acc = [SELECT Id, nm_StudentImageUrl__c, FirstName, LastName, PersonMobilePhone, PersonEmail, nm_Program__r.Name, ValidUptoR__c, nm_StudentNo__c FROM Account WHERE (PersonEmail = :email AND PersonMobilePhone = :mobile) limit 1];
                lead = [SELECT Id, MobilePhone, Email, FirstName, LastName, nm_Program__r.Name, IsConverted FROM Lead WHERE (Email like :'%'+email AND MobilePhone like :'%'+mobile) limit 1];
                if(lead.isEmpty()){
                    acc = [SELECT Id, nm_StudentImageUrl__c, FirstName, LastName, PersonMobilePhone, PersonEmail, nm_Program__r.Name, ValidUptoR__c, nm_StudentNo__c FROM Account WHERE IsPersonAccount = true AND (PersonEmail like :'%'+email AND PersonMobilePhone like :'%'+mobile) limit 1];
                }
            }
            if(sno != ''){               
                acc = [SELECT Id, nm_StudentImageUrl__c, FirstName, LastName, PersonMobilePhone, PersonEmail, nm_Program__r.Name, ValidUptoR__c, nm_StudentNo__c FROM Account WHERE IsPersonAccount = true AND nm_StudentNo__c like :'%'+sno limit 1];
            }
            if(!acc.isEmpty()){
                if(acc[0].nm_Program__r.Name != ''){
                    studentMap.put('url', acc[0].nm_StudentImageUrl__c);
                    studentMap.put('fname', acc[0].FirstName);
                    studentMap.put('lname', acc[0].LastName);
                    studentMap.put('validity', acc[0].ValidUptoR__c);
                    studentMap.put('mobile', acc[0].PersonMobilePhone);
                    studentMap.put('email', acc[0].PersonEmail);
                    studentMap.put('program', acc[0].nm_Program__r.Name);
                    studentMap.put('sno', acc[0].nm_StudentNo__c);
                    studentMap.put('accountId', acc[0].Id);
                }
            }
            if(!lead.isEmpty()){
                if(lead[0].nm_Program__r.Name != ''){
                    studentMap.put('fname', lead[0].FirstName);
                    studentMap.put('lname', lead[0].LastName);
                    studentMap.put('mobile', lead[0].MobilePhone);
                    studentMap.put('email', lead[0].Email);
                    studentMap.put('program', lead[0].nm_Program__r.Name);
                    studentMap.put('converted', String.valueOf(lead[0].IsConverted));
                }
            }
        }catch(Exception e){
            system.debug(e);
        } 
        return studentMap;
    }
   
    @AuraEnabled
    public static List<CaseWrapper> getMyCaseList(String sno){
        
        List < CaseWrapper > listCaseWrapper = new List < CaseWrapper >();
        Map<ID,Case> mapOfCases = new Map<ID, Case>([SELECT Id, CaseNumber, Subject, Description, CreatedDate, Escalated_Date__c, Student_Category__c, Student_Status__c, Student_In_Progress_Date__c, Expected_Close_Date__c, Escalation_Level__c,Lead_Registrants_Student__c, AccountId, Lead__c FROM Case WHERE Status != 'Closed' AND RecordTypeId=:ticket AND Student_No__c like :'%'+sno ORDER BY CreatedDate DESC LIMIT 20]);
        List<Task> lstTask = [SELECT Id,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Case__c,Status From Task WHERE Case__c IN :mapOfCases.keySet() AND Subject='Call Scheduling' AND Schedule_Time_Slot__c!=null AND (Status IN ('Not Started','In Progress') OR (Status='Not Connected' AND Is_Call_Already_Connected__c=false)) AND Call_date__c>=YESTERDAY];
        Map<String, Task> mapOfCaseVsTask = new Map<String, Task>();
        for (Task objTask : lstTask) {
            mapOfCaseVsTask.put(objTask.Case__c, objTask);
        }
        for(Case c: mapOfCases.values()){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.label1 = 'Expected Close Date';
            caseWrap.caseId = c.Id;
            caseWrap.caseNumber = c.CaseNumber;
            caseWrap.caseSubject = c.Subject;          
            caseWrap.caseStatus = c.Student_Status__c!=null ? c.Student_Status__c : '';
            caseWrap.caseCreatedDate = Date.valueOf(c.CreatedDate);
            caseWrap.caseInProgressDate = c.Student_In_Progress_Date__c;
            caseWrap.caseCloseDate = c.Expected_Close_Date__c;     
            caseWrap.escalationNumber = String.valueOf(c.Escalation_Level__c) ;
            caseWrap.typeOfObject = c.Lead_Registrants_Student__c == 'Lead' ? 'Lead' : 'Account';
            caseWrap.recordId = caseWrap.typeOfObject == 'Lead' ? c.Lead__c : c.AccountId;
           
            if(c.Escalation_Level__c == 0 || c.Escalation_Level__c == null){
                caseWrap.isActive = c.Expected_Close_Date__c < system.today() ? false : true;
                caseWrap.showButton = 'Yes';
                caseWrap.escalationNumber = '';
                caseWrap.variant = 'destructive';                
            }else if(c.Escalation_Level__c == 1 || c.Escalation_Level__c == 2 || c.Escalation_Level__c == 3){
                caseWrap.isActive = c.Expected_Close_Date__c < system.today() ? false : true;
                caseWrap.showButton = caseWrap.isActive == true ? 'Escalated - Level '+c.Escalation_Level__c : 'Yes' ;
                caseWrap.variant = caseWrap.isActive == true ? 'base' : 'destructive' ;           
            } else if(c.Escalation_Level__c == 4) {
                caseWrap.isActive = true;
                caseWrap.showButton = 'Escalated - Level '+c.Escalation_Level__c;
                caseWrap.variant = 'base'; 
            }
            
            if(mapOfCaseVsTask.containsKey(caseWrap.caseId)) {
                Task objTask = mapOfCaseVsTask.get(caseWrap.caseId);
                caseWrap.callBtnLabel = (objTask.Status == 'In Progress' && objTask.Schedule_Call_Time__c!=null ? objTask.Schedule_Call_Time__c.format('dd-MM-yyyy hh:mm a') : DateTime.newInstance(
                    objTask.Call_date__c.year(), objTask.Call_date__c.month(), objTask.Call_date__c.day()).format('dd-MM-yyyy') +' '+ objTask.Time_Range__c);
                caseWrap.callBtnVariant = 'base';
                caseWrap.callBtnDisabled = true;
            } else {
                caseWrap.callBtnLabel = 'Yes';
                caseWrap.callBtnVariant = 'destructive';
                caseWrap.callBtnDisabled = false;
            }


            
            System.debug('caseWrap ==>'+caseWrap.isActive);
             if(c.Student_Category__c=='Career services') {
                caseWrap.isActive=true;
                caseWrap.callBtnDisabled=true;
             }
            listCaseWrapper.add(caseWrap);            
        }
        return listCaseWrapper;
    }
    
    @AuraEnabled
    public static List<CaseWrapper> getMyClosedCaseList(String sno){
        
        List < CaseWrapper > listCaseWrapper = new List < CaseWrapper >();        
        Map<ID,Case> mapOfCases = new Map<ID, Case>([SELECT Id, CaseNumber, Subject,Escalation_Level__c,Expected_Close_Date__c, Description, CreatedDate, Student_Status__c, Student_In_Progress_Date__c, ClosedDate FROM Case WHERE Status = 'Closed' AND RecordTypeId=:ticket AND Student_No__c like :'%'+sno ORDER BY CreatedDate DESC LIMIT 20]);
        List<Task> lstTask = [SELECT Id,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Case__c,Status From Task WHERE Case__c IN :mapOfCases.keySet() AND Subject='Call Scheduling' AND Schedule_Time_Slot__c!=null AND (Status IN ('Not Started','In Progress') OR (Status='Not Connected' AND Is_Call_Already_Connected__c=false)) AND Call_date__c>=YESTERDAY];
        Map<String, Task> mapOfCaseVsTask = new Map<String, Task>();
        for (Task objTask : lstTask) {
            mapOfCaseVsTask.put(objTask.Case__c, objTask);
        }
        for(Case c: mapOfCases.values()){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.label1 = 'Close Date';
            caseWrap.caseId = c.Id;
            caseWrap.caseNumber = c.CaseNumber;
            caseWrap.caseSubject = c.Subject;
            caseWrap.caseStatus = c.Student_Status__c;
            caseWrap.caseCreatedDate = Date.valueOf(c.CreatedDate);
            caseWrap.caseInProgressDate = c.Student_In_Progress_Date__c;
            caseWrap.caseCloseDate = Date.valueOf(c.ClosedDate);
            caseWrap.escalationNumber = String.valueOf(c.Escalation_Level__c);  
            if(c.Escalation_Level__c == 0 || c.Escalation_Level__c == null){
                // caseWrap.isActive = (c.Student_Status__c == 'Closed' && c.Expected_Close_Date__c < system.today() && c.ClosedDate.addDays(3) >= System.today()) ? false : true;
                caseWrap.isActive = (c.Student_Status__c == 'Closed' && c.ClosedDate.addDays(3) >= System.today()) ? false : true;
                caseWrap.showButton = 'Yes';
                caseWrap.escalationNumber = '';
                caseWrap.variant = 'destructive';                
            }else if(c.Escalation_Level__c == 1 || c.Escalation_Level__c == 2 || c.Escalation_Level__c == 3){
                caseWrap.isActive = (c.Student_Status__c == 'Closed' && c.ClosedDate.addDays(3) >= System.today()) ? false : true;
                caseWrap.showButton = caseWrap.isActive == true ? 'Escalated - Level '+c.Escalation_Level__c : 'Yes' ;
                caseWrap.variant = caseWrap.isActive == true ? 'base' : 'destructive' ;          
            } else if(c.Escalation_Level__c == 4) {
                caseWrap.isActive = true;
                caseWrap.showButton = 'Escalated - Level '+c.Escalation_Level__c;
                caseWrap.variant = 'base'; 
            }
            caseWrap.callBtnLabel = 'NA';
            if(mapOfCaseVsTask.containsKey(caseWrap.caseId)) {
                Task objTask = mapOfCaseVsTask.get(caseWrap.caseId);
                caseWrap.callBtnLabel = (objTask.Status == 'In Progress' && objTask.Schedule_Call_Time__c!=null ? objTask.Schedule_Call_Time__c.format('dd-MM-yyyy hh:mm a') : DateTime.newInstance(
                    objTask.Call_date__c.year(), objTask.Call_date__c.month(), objTask.Call_date__c.day()).format('dd-MM-yyyy') +' '+ objTask.Time_Range__c);
            }
            
            listCaseWrapper.add(caseWrap);            
        }
        return listCaseWrapper;
    }
    
    @AuraEnabled
    public static List<CaseWrapper> getFeedbacks(String sno){
       List < CaseWrapper > listCaseWrapper = new List < CaseWrapper >();        
        for(Case c: [SELECT Id, CaseNumber, Subject, CreatedDate, Student_Status__c FROM Case WHERE RecordTypeId=:feedback AND Student_No__c like :'%'+sno ORDER BY CreatedDate DESC LIMIT 20]){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.caseId = c.Id;
            caseWrap.caseNumber = c.CaseNumber;
            caseWrap.caseSubject = c.Subject;
            caseWrap.caseStatus = c.Student_Status__c;
            caseWrap.caseCreatedDate = Date.valueOf(c.CreatedDate);
            
            listCaseWrapper.add(caseWrap);            
        }
        return listCaseWrapper;
    }
    
    @AuraEnabled
    public static List<CaseWrapper> findCases(String searchKey, String sno) {
        
        String key = '%' + searchKey + '%';      
        Map<ID,Case> mapOfCases = new Map<ID, Case>([SELECT Id, CaseNumber, Subject, Description, CreatedDate, Student_Status__c, Student_In_Progress_Date__c, Expected_Close_Date__c, Escalation_Level__c, ClosedDate, Lead_Registrants_Student__c, AccountId, Lead__c FROM Case WHERE Subject LIKE :key AND Student_No__c like :'%'+sno LIMIT 20]);
        List < CaseWrapper > listCaseWrapper = new List < CaseWrapper >();  
        List<Task> lstTask = [SELECT Id,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Case__c,Status From Task WHERE Case__c IN :mapOfCases.keySet() AND Subject='Call Scheduling' AND Schedule_Time_Slot__c!=null AND (Status IN ('Not Started','In Progress') OR (Status='Not Connected' AND Is_Call_Already_Connected__c=false)) AND Call_date__c>=YESTERDAY];
        Map<String, Task> mapOfCaseVsTask = new Map<String, Task>();
        for (Task objTask : lstTask) {
            mapOfCaseVsTask.put(objTask.Case__c, objTask);
        }      
        for(Case c: mapOfCases.values()){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.label1 = 'Expected Close Date';
            caseWrap.caseId = c.Id;
            caseWrap.caseNumber = c.CaseNumber;
            caseWrap.caseSubject = c.Subject;
            caseWrap.caseStatus = c.Student_Status__c;
            caseWrap.caseCreatedDate = Date.valueOf(c.CreatedDate);
            caseWrap.caseInProgressDate = c.Student_In_Progress_Date__c;
            caseWrap.caseCloseDate = c.Student_Status__c != 'Closed' ? c.Expected_Close_Date__c : Date.valueOf(c.ClosedDate);
            caseWrap.isActive = (c.Student_Status__c != 'Closed' && c.Expected_Close_Date__c <= system.today()) ? false : true;
            
            // caseWrap.isActive = c.Expected_Close_Date__c <= system.today()? false : true;
            caseWrap.caseInProgressDate = c.Student_In_Progress_Date__c;
            caseWrap.escalationNumber = String.valueOf(c.Escalation_Level__c) ;
            caseWrap.typeOfObject = c.Lead_Registrants_Student__c == 'Lead' ? 'Lead' : 'Account';
            caseWrap.recordId = caseWrap.typeOfObject == 'Lead' ? c.Lead__c : c.AccountId;
            if(c.Escalation_Level__c == 0){
                caseWrap.isActive = c.Expected_Close_Date__c <= system.today() ? false : true;
                caseWrap.showButton = 'Yes';
                caseWrap.variant = 'destructive';
                caseWrap.escalationNumber = '';                
            }else if(c.Escalation_Level__c == 1 || c.Escalation_Level__c == 2 || c.Escalation_Level__c == 3){
                caseWrap.isActive = c.Expected_Close_Date__c > system.today() ? true : false;
                caseWrap.showButton = caseWrap.isActive == true ? 'Escalated - Level '+c.Escalation_Level__c : 'Yes' ;
                caseWrap.variant = caseWrap.isActive == true ? 'base' : 'destructive' ;           
            } else if(c.Escalation_Level__c == 4) {
                caseWrap.isActive = true;
                caseWrap.showButton = 'Escalated - Level '+c.Escalation_Level__c;
                caseWrap.variant = 'base'; 
            }
            
            if(mapOfCaseVsTask.containsKey(caseWrap.caseId)) {
                Task objTask = mapOfCaseVsTask.get(caseWrap.caseId);
                caseWrap.callBtnLabel = (objTask.Status == 'In Progress' && objTask.Schedule_Call_Time__c!=null ? objTask.Schedule_Call_Time__c.format('dd-MM-yyyy hh:mm a') : DateTime.newInstance(
                    objTask.Call_date__c.year(), objTask.Call_date__c.month(), objTask.Call_date__c.day()).format('dd-MM-yyyy') +' '+ objTask.Time_Range__c);
                caseWrap.callBtnVariant = 'base';
                caseWrap.callBtnDisabled = true;
            } else {
                caseWrap.callBtnLabel = 'Yes';
                caseWrap.callBtnVariant = 'destructive';
                caseWrap.callBtnDisabled = false;
            }
            
            listCaseWrapper.add(caseWrap);            
        }
        return listCaseWrapper;
    }
    
    @AuraEnabled
    public static List<CaseComment> getEmailsForCase(String caseId){ 
        return [select Id, CreatedDate, CreatedBy.Name, CommentBody FROM CaseComment WHERE ParentId = :caseId ORDER BY CreatedDate DESC];
    }
    
    @AuraEnabled
    public static Case getCaseDetails(String caseId){        
        return [SELECT Id, CaseNumber, Subject, Student_Status__c, Expected_Close_Date__c, Student_Purpose__c, CreatedDate, ClosedDate, Description, Student_Category__c, Student_Sub_Categories__c, Expected_Outcomes_and_Implications__c,Proposed_Research__c,Research_Hypothis__c,Research_Objective__c,Relevance_of_Research__c,Business_Issues__c,Problem_Statament__c,Proposed_Research_Topic__c,Account.FirstName ,Account.LastName, ReOpenable_period__c, Escalation_Level__c, Lead__c, AccountId, Account.nm_Program__r.Name FROM Case WHERE Id = :caseId];
    }
    
    @AuraEnabled
    public static void updateCaseStatus(String caseId, Boolean disclaimerflag){  
        try {
        system.debug(caseId);
        Case c = [SELECT  nomodificationflag__c,AdmissionCancellationDisclaimerflag__c,Admission_Cancellation_ClosedDatetime__c,Status FROM Case WHERE Id = :caseId];
        c.Status = 'Closed';
        if(disclaimerflag){
            c.AdmissionCancellationDisclaimerflag__c = disclaimerflag;
            c.Admission_Cancellation_ClosedDatetime__c = system.now();
        }
        update c;
        System.debug('c123 ==>' + c);
    } catch (Exception e) {
        System.debug('Error ==>' + e.getMessage());
        System.debug('Error line number ==>'+e.getLineNumber());
    }  
    }
    
    // @AuraEnabled
    // public static void updateCaseDisclamerflag(String caseId, Boolean disclaimerflag){  
    //     system.debug(caseId);
    //     Case c = [SELECT nomodificationflag__c,AdmissionCancellationDisclaimerflag__c,Admission_Cancellation_ClosedDatetime__c,Status FROM Case WHERE Id = :caseId];
    //     c.Status = 'Closed';
    //   // c.nomodificationflag__c = true;
    //    c.AdmissionCancellationDisclaimerflag__c = disclaimerflag;
    //    c.Admission_Cancellation_ClosedDatetime__c = system.now();
    //     update c;
    // }
    @AuraEnabled
    public static Boolean reopenCase(String caseId, String reason){   
        try {
            DateTime dT = system.today();
            Date d = date.newinstance(dT.year(), dT.month(), dT.day());
            System.debug('reason ==>'+reason);
            Case c = [SELECT Status, Expected_Close_Date__c, Escalation_Level__c, Student_Category__c ,Reason_for_Re_Opening_Case__c FROM Case WHERE Id = :caseId];
            c.Status = 'Re-Open';
            c.Reason_for_Re_Opening_Case__c = reason;
            
            Case__c mcs = Case__c.getValues(c.Student_Category__c);
            Integer tat = Integer.valueOF(mcs.TAT__c);
            Integer diff = getNumberOfDays(System.today(), d.addDays(tat));
            if(diff < tat){
                Integer actualTat = tat + (tat-diff);
                c.Expected_Close_Date__c = d.addDays(actualTat);
            }else{
                c.Expected_Close_Date__c = d.addDays(tat);
            }
            // c.Expected_Close_Date__c = c.Escalation_Level__c == 0 ? System.today().addDays(2) : c.Escalation_Level__c == 1 ? System.today().addDays(2) : c.Escalation_Level__c == 2 ? System.today().addDays(30) : c.Escalation_Level__c == 3 ? System.today().addDays(90) : c.Escalation_Level__c == 4 ? System.today().addDays(60) : c.Expected_Close_Date__c;
            update c;
            return true;
        } catch (Exception e) {
            System.debug('Error ==>' + e.getMessage());
            System.debug('Error line number ==>'+e.getLineNumber());
            return false;
        }  
        
    }

    @AuraEnabled
    public static void escalateCase(String caseId, String callValue){ 
        system.debug('caseId '+caseId);
        Case c = [SELECT Status, Count_of_ECD_changed_By_System__c, Escalated_Date__c, Escalation_Level__c, Escalation_Email__c, Expected_Close_Date__c, isCallback__c, Grievance_Escalation_Days__c, Head_Escalation_Days__c, Manager_Escalation_Days__c FROM Case WHERE Id = :caseId];        
        Integer level = Integer.valueOf(c.Escalation_Level__c);
        //To stop Level 4 escalation and send email
        if (level == 3) {
            System.debug('level--->' + level);
            Map<String, Object> params = new Map<String, Object>();
            params.put('caseId', c.Id);
            Flow.Interview.Case_Send_Email_to_Student_for_L4_Escalation objFlow = new Flow.Interview.Case_Send_Email_to_Student_for_L4_Escalation(params);
            objFlow.start();
            return;
        }
        System.debug('Escalated level'+level);
        if(callValue == 'No'){
            if(c.Status=='Closed' ){
               c.Status='Re-Open';
               update c;
            }
            
                // c.status= c.Status=='Closed' ?'Re-Open':c.Status;
            // Integer diff = getNumberOfDays(System.today(), System.today().addDays(2)) ;     
            // if(diff < 2){                
            //     Integer actualTat = 2 + (2-diff);
            //     system.debug(actualTat);
            //     c.Expected_Close_Date__c = System.today().addDays(actualTat);
            // }else{
            //     c.Expected_Close_Date__c = System.today().addDays(2);
            // }
            c.Expected_Close_Date__c = level == 0 || level == null ? System.today().addDays(2) : level == 1 ? System.today().addDays(7) : level == 2 ? System.today().addDays(30) : level == 3 ? System.today().addDays(60) : c.Expected_Close_Date__c;
        } else {   
            if(c.Status=='Closed'){
                c.Status='Re-Open';
                update c;
             }
        }

        // Case c1 = [SELECT Status, Count_of_ECD_changed_By_System__c, Escalated_Date__c, Escalation_Level__c, Escalation_Email__c, Expected_Close_Date__c, isCallback__c, Grievance_Escalation_Days__c, Head_Escalation_Days__c, Manager_Escalation_Days__c FROM Case WHERE Id = :caseId];        
        System.debug('level-->' + level);
        if(level == 0){  
           c.Escalation_Email__c = 'sangeeta.shetty@nmims.edu';
           c.Escalation_Level__c = 1;           
        }else if(level == 1){
           c.Escalation_Email__c = 'arif.sayed@nmims.edu';
           c.Escalation_Level__c = 2;
        }else if(level == 2){
           c.Escalation_Level__c = 3;     
        }
        else{
           c.Escalation_Level__c = 4; 
        }
        c.Count_of_ECD_changed_By_System__c = c.Count_of_ECD_changed_By_System__c!=null ? c.Count_of_ECD_changed_By_System__c + 1 : 1;
        c.Escalated_Date__c = System.today();        
        c.isCallback__c = false;
                       
        update c;
    }
    
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }

    @AuraEnabled
    public static boolean uploadFiles(List<Map<String, Object>> files, Id caseId){
        system.debug('Case Id '+files);
        Boolean isSuccess = false;
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            contentVersionFile.FirstPublishLocationId = caseId;
            relatedDocuments.add(contentVersionFile);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
        }
        CreateContentDistribution(relatedDocuments);
        return isSuccess;
    }

    public static void CreateContentDistribution(List<ContentVersion> lstDocs) {
        List<ContentDistribution> lstOfDistributionToInsert = new List<ContentDistribution>();
        for (ContentVersion files : lstDocs) {
            ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = files.id;
            newDist.Name = files.Title;
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload=true;
            system.debug('createContentDistribution creted');
            lstOfDistributionToInsert.add(newDist);
        }
        insert lstOfDistributionToInsert;
        System.debug(lstOfDistributionToInsert);
    }
  
    //Generate OTP for Student No
    @AuraEnabled
    public static String getMobileAndEmailForOTP(String studentNo, String registrationNo, String email, String mobile, String converted) {
        //String sno = studentNo;
        List<Account> acc = new List<Account>();
        List<Lead> lead = new List<Lead>();
        try{
            if(studentNo != ''){
                acc = [SELECT Id, PersonMobilePhone, PersonEmail, Email_Verification_Token__c, PersonContactId FROM Account WHERE nm_StudentNo__c like :'%'+studentNo limit 1];
            }else if(converted == 'true'){
                if(registrationNo != ''){
                    acc = [SELECT Id, PersonMobilePhone, PersonEmail, Email_Verification_Token__c, PersonContactId FROM Account WHERE nm_RegistrationNumber__c like :'%'+registrationNo limit 1];
                }else{
                    acc = [SELECT Id, PersonMobilePhone, PersonEmail, Email_Verification_Token__c, PersonContactId FROM Account WHERE PersonEmail like :'%'+email AND PersonMobilePhone like :'%'+mobile limit 1];
                }
            }else if(converted == 'false'){
                if(registrationNo != ''){
                    lead = [SELECT Id, MobilePhone, Email, Email_Verification_Token__c FROM Lead WHERE nm_RegistrationNo__c like :'%'+registrationNo limit 1];
                }else{
                    lead = [SELECT Id, MobilePhone, Email, Email_Verification_Token__c FROM Lead WHERE Email like :'%'+email AND MobilePhone like :'%'+mobile limit 1];
                }
            }                            
        }catch(Exception e){
            msg = 'No match found for entered Sap Id';
        }
        
        system.debug('acc '+acc);
        system.debug('lead '+lead);
        String mobileNo;
        String emailId;
        if(acc.size() != 0){ 
            if(acc[0].PersonMobilePhone.contains('_')){
                mobileNo = acc[0].PersonMobilePhone.substringAfter('_');
                emailId = acc[0].PersonEmail.substringAfter('_');
            }else{
                mobileNo = acc[0].PersonMobilePhone;
                emailId = acc[0].PersonEmail;
            }           
        }else{
            if(lead[0].MobilePhone.contains('_')){
                mobileNo = lead[0].MobilePhone.substringAfter('_');
                emailId = lead[0].Email.substringAfter('_');
            }else{
                mobileNo = lead[0].MobilePhone;
                emailId = lead[0].Email;
            }            
        }
        
       if(!String.isBlank(mobileNo) || String.isBlank(emailId)) {            
            String otpCode = sendOTP(mobileNo);
            if(acc.size() != 0){        
                acc[0].Email_Verification_Token__c = otpCode;
                update acc;
                sendEmailOTP(acc[0].PersonContactId);
                msg = mobileNo + ' ' + emailId + ' ' + acc[0].PersonContactId + ' ' + otpCode;
            }else{
                lead[0].Email_Verification_Token__c = otpCode;
                update lead;
                sendEmailOTP(lead[0].Id);
                msg = mobileNo + ' ' + emailId + ' ' + lead[0].Id + ' ' + otpCode;
            }                        
        }
        return msg;
    }
    
    @AuraEnabled
    public static String sendOTP(String mobileNo) {
        String OtpCode = generateOTPMSG();
        String smsMessage = OtpCode + ' is your verification code for NMIMS CDOE.';            
        String result = SMSSenderWebService.sendmGageSMS(mobileNo.left(10),smsMessage);
        System.debug('result ==>'+result);
   
        return OtpCode;
    }

    @AuraEnabled
     public static void sendEmailOTP(String personContactId) {
        try {
            // To Query Organisation Details.
            OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owe.id);
            
            // To Query the Email Template.
            EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Case' LIMIT 1];

            mail.setTargetObjectId(personContactId);
            mail.setTemplateId(emailTemplate.Id);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            
        } catch (Exception ex) {
            System.debug('Error Msg =>'+ex.getMessage());
            System.debug('Error No =>'+ex.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static String VerifyOTP(String OtpCode, String Otp, Long otpSentTime) {        
        system.debug('OtpCode '+OtpCode);
        system.debug('OtpSentTime '+otpSentTime);
        if(String.isNotBlank(Otp)) {
            Long otpEnteredTime = DateTime.now().getTime();
            Long milliseconds = otpEnteredTime - otpSentTime;
            Long seconds = milliseconds / 1000;
            if(OtpCode == Otp && seconds <= 180){                
                msg = 'OTP Verified';
            }else if(OtpCode != Otp) {               
                msg = 'Incorrect OTP Entered, kindly try again.';
            }else if(seconds > 180){             
                msg = 'OTP has been expired, kindly try again.';
            }else{              
                msg = 'OTP Verification has been failed, kindly try again';
            }          
        }
        return msg;
    }

    public static String generateOTPMSG() {
        Integer STRING_LENGTH = 5;
        Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
        String OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        System.debug('OtpCode-->'+OtpCode);
      
        return OtpCode;
    }
    
    
    
    //Acads level Cases
    @AuraEnabled
    public static Account verifyStudent(String sno){
        Account acc = new Account();
        try{
            acc = [SELECT Id, Name, nm_Program__r.Name, Batch__c FROM Account WHERE nm_StudentNo__c like :'%'+sno];            
        }catch(Exception e){
            system.debug('No match found for given student number');
        } 
        return acc;  
    }
    
    @AuraEnabled
    public static List<String> getDependentPicklistValues(String categoryValue, String program){
        system.debug('program '+program);
        system.debug('value '+categoryValue);
        Map<String,List<String>> wxMap = new Map<String,List<String>>{
                'Admissions' => new List<String>{},
                'Academics' => new List<String>{'Batch Planner clarification','Harvard module not available','E resources/Digital  books not available','PPT not updated','Recording not updated','Repeat subject policy clarification','Term III Electives selection','Term IV Electives selection','Term V Electives selection','Webinar/Ascend enquiries','Session schedule change'},
                'Assignment/Internal Assessment' => new List<String>{'IA - Copy case','IA - Missed','IA Issue - Unable to submit','IA marks clarification','IA QP incorrect','IA results not declared'},
                'Term End Examination' => new List<String>{'Capstone clarification','Compatibility test issue','Demo exams not working','Grade clarification','Re-Exam dates','Re-Exam pattern','Re-Exam payment issue','Re-Exam Policy clarification','TEE - results clarification','TEE - unable to join','TEE - Link not visible','TEE - Missed both slots','TEE - results not declared','TEE - schedule request','TEE - Unfair means'},          
                'Logistics' => new List<String>{},
                'Others' => new List<String>{'Course coordinator complaint'},
                'Service Request' => new List<String>{'Marksheet/Certificate - SR Procedure','Marksheet/Certificate - SR Status','Service Request - Status Enquiry'},
                'Learner Support Center' => new List<String>{}
        };
        Map<String,List<String>> retailMap = new Map<String,List<String>>{
            'Admissions' => new List<String>{'Exit Process','Fee receipt needed','Lateral admissions','Live Lectures - Payment Status/Issue','Re-registration - Payment Status/Issue','Program Change'},
            'Academics' => new List<String>{'Unable to access the Digital Library','E-Books different from books received','E-Books not available on portal','','Post a query - Not answered','PPT missing','PPT not complete/Bad quality','PPT not uploaded >48 hours','Program Credit details','Recordings Missing','Recordings not complete/Bad quality','Recordings not uploaded >48 hours','Session alert not received','Tracks clarification','Unable to download PPT/Session recordings'},
            'Assignment/Internal Assessment' => new List<String>{'Assignment Guidelines Clarification','Incorrect assignment submited','Assignment Question paper clarification','Missed Assignment Submission','Unable to pay for assignments','Unable to submit assignment due to tech issue','Re-evaluation Process','Assignment marked as Copy Case','Project Payment Issue'},
            'Term End Examination' => new List<String>{'Exam link not received','Cannot join back the test','Exam Pattern/Demo Exams/Questions bank','Exam Cancellation','Exam Conduct Dates','Exam Schedule change','Missed examination','Exam Slots not available','Exam Registration payment issue','Exam results dates','Result clarification','Re-evaluation Process','Unable to clear a subject','Project marked as Copy Case','UFM process','Hall ticket','Unable to download hall ticket','Proctor Feedback','Project Guidelines Clarification','Project Feedback needed','Ranking query','TEE policy clarifications','TEE Question paper feedback'},
            'Logistics' => new List<String>{'Book missing from the study kit','Damaged books received','Incorrect books received','Others','Study Materials - not received'},
            'Others' => new List<String>{'Coordinator Complaint','Career Services Enquiry','Webinar Enquiry'},
            'Service Request' => new List<String>{'Gradesheet/Certificate - SR Procedure','Gradesheet/Certificate - SR Status','De-registeration request'},
            'Learner Support Center' => new List<String>{},
            'Career Services' => new List<String>{}
        };
        Map<String,List<String>> aRetailMap = new Map<String,List<String>>{
            'Admissions' => new List<String>{'Admission Cancellation','Validity extension details','De-registration request'},
            'Academics' => new List<String>{'Academic calendar not updated','Batch Planner clarification','Harvard module not available','E resources/Digital  books not available','PPT not updated','Recording not updated','Repeat subject policy clarification','Term III Electives selection','Term IV Electives selection','Term V Electives selection','Webinar enquiries','Change in session schedule','Capstone round progression','Harvard module not available'},
            'Examination - Internal Assessment' => new List<String>{'IA - Copy case','IA - Missed','IA Issue - Unable to submit','IA marks clarification','IA QP incorrect','IA results not declared','IA- Technical issue','IA-QP to session incorrect mapping','IA Policy Clarification','IA Schedule change','IA Issue - Unable to Join'},
            'Examination - TEE' => new List<String>{'Unable to click on Exam Link','Disconnected from examination','Camera/Microphone permission issue','Unable to type descriptive answers','Proctor feedback','Missed examination','Mettl number not reachable','Compatibility test issue','Re- Exam dates','Re- Exam pattern','Re- Exam payment issue','Re- Exam Policy clarification','TEE -Marks clarification','TEE - Missed both slots','TEE - Results not declared','TEE - Unfair means','TEE - Policy Clarification','Gradesheet/Final Certifcate Status'},
            'Logistics' => new List<String>{},
            'Student Support' => new List<String>{'Ascend Certificates','Nmentor Enquiry','Student portal issues'},
            'Portal Support' => new List<String>{},
            'Learner Support Center' => new List<String>{},
            'Career Services' => new List<String>{}
        }; 
        Map<String,List<String>> aWxMap = new Map<String,List<String>>{
            'Admissions' => new List<String>{'Admission - Cancellation Process','Admission - Payment issue','Program Change','Re-Registration - Payment Issue','Re-Registration - Procedure/Link','Re-Registration - Policy Clarification','Registration cancellation','Re-registration dates','Live lectures - Payment status','Live Lectures - Issue','Lateral admissions - Process','Validity extension Policy'},
            'Academics' => new List<String>{'Acknowledgment','Credential related','Credential related- Email ID change','Digital Library unable to access','PPT missing','PPT not complete/Bad quality','Recordings Missing','Recordings not complete/Bad quality','E-Books different from books received','E-Books not available on portal','PPT not uploaded >48 hours','Program Credit details','Recordings not uploaded >48 hours','Tracks clarification','Project Topic confirmation'},
            'Examination - Internal Assessment' => new List<String>{'Acknowledgment','Assignment Related - Guidelines Clarification','Assignment Related - Incorrect submission','Assignment Related - Policy clarification','Assignment Related - QP clarification','Assignment Related - Submission post last date','Assignment Related - Unable to pay','Assignment Related - Unable to submit tech issues','Exam Pattern/Demo Exams/Questions bank','Exam Registration - Exam Cancellation','Exam Registration - Exam dates','Exam Registration - Exam Schedule change - Exception','Exam Registration payment issue','Exam Registration - Exam Schedule change','Exam Registration - Slots not available','Exam results - Reevaluation clarifications','Exam results - Reevaluation Process','Hall ticket','Hall ticket - Unable to download','Marksheet/Certificate - SR Procedure','Others','Project - Guidelines Clarification','Project Submission payment issue','Project Submission post last date','Refund- status','Assignment related -Missed Assignment Submission','Assignment related -Assignment marked as Copy Case','Exam Registration - Missed registering ','Exam Registration - after deadline','Marksheet - SR Status','Unable to click on Exam Link','Disconnected from examination','Camera/Microphone permission issue','Unable to type descriptive answers'},
            'Examination - TEE' => new List<String>{'Examination Centre feedback','Exam Pattern','TEE- UFM','Project Feedback','TEE Question paper feedback','Exam results - Dates','Exam results - Pass/Fail Status','Exam results - Unable to clear a subject','Late for examination','Absent/Missed examination','Project Feedback','Question paper feedback','Transcripts - Process','Final Certificate - SR Status','Transcripts - Status','Acknowledgment','WES - Process'},
            'Logistics' => new List<String>{'Acknowledgment','Others','Study Materials - not received','Study Materials - on hold','Damaged books received','Books missing from Study kit','Incorrect books received','Fee  receipt - Physical copy','Study materials - Returned back','Study Kit - OTP not received'},
            'Student Support' => new List<String>{'Student portal issues','Mettl number not reachable/not answering','Support counsellor complaint','Career Services - Call Back not recieved'},
            'Portal Support' => new List<String>{'Incorrect  Marksheet displayed','Invalid Credentials','Mobile App - Unable to Login','Mobile App- Issues','Lateral Subjects not updated','ID Card - incorrect data','Assignment incorrectly displayed -2 cycles live'},
            'Learner Support Center' => new List<String>{},
            'Career Services' => new List<String>{}
        }; 
        Boolean isTermProgram = [SELECT id,nm_ProgramName__c, Name, IsTerm__c FROM nm_Program__c WHERE Name =:program LIMIT 1].IsTerm__c;
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = Case.Student_Sub_Categories__c.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            system.debug(entry);
            if (entry.isActive()) {
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                system.debug('controllerValues '+controllerValues);
                system.debug('controllerValues size '+controllerValues.size());
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    if (bitIndex > base64chars.size() - 1) { 
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(i,6);
                    system.debug('bitIndex '+bitIndex);
                    system.debug('bitShift '+bitShift);
              
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    system.debug('controllerValue '+controllerValue);
                    system.debug('check '+dependentPicklistValues.get(controllerValue));
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        system.debug('dependentPicklistValues '+dependentPicklistValues);
        List<String> subcatLst = new List<String>();
        if(dependentPicklistValues.get(categoryValue) != null ){
            List<String> categoryLst = new List<String>();        
            Set<String> picklist = new Set<String>(dependentPicklistValues.get(categoryValue));
            system.debug(picklist);
            if(isTermProgram == true){
                //flag true WX Programs
                categoryLst = retailMap.get(categoryValue);                        
            }else{
                //Flag false retail programs
                categoryLst = wxMap.get(categoryValue);
            }
            system.debug('categoryLst==>'+categoryLst);
           
            if(categoryLst != null) {
                for(String sc : categoryLst){           
                    picklist.remove(sc);                   
                }
            }
            subcatLst = new List<String>(picklist);
        } else {
            return subcatLst;
        }
        system.debug('subcatLst '+subcatLst);
        return subcatLst;
    }
    
    //Account level cases
    @AuraEnabled
    public static Account getStudentNo(String accId){
        Account acc = [SELECT nm_StudentNo__c, nm_Program__r.Name FROM Account WHERE Id = :accId];            
        return acc;  
    }
    
    public static Integer getNumberOfDays(Datetime DateTimeOfStartDate, Datetime DateTimeOfEndDate) {
        if(String.isNotBlank(String.valueOf(DateTimeOfStartDate)) && String.isNotBlank(String.valueOf(DateTimeOfEndDate))) {
            Set<Date> uniqueDate = new Set<Date>();
            Date StartDate = date.newinstance(DateTimeOfStartDate.year(), DateTimeOfStartDate.month(), DateTimeOfStartDate.day());
            Date EndDate = date.newinstance(DateTimeOfEndDate.year(), DateTimeOfEndDate.month(), DateTimeOfEndDate.day());
    
            DateHelper DateHelper = new DateHelper();
            List<Date> lstDates =DateHelper.getAllDatesBetweenTwoDates(StartDate, EndDate);
            List<Date> ActualDate = lstDates.size()>0?DateHelper.getDateIgnoringSunday(lstDates) : new List<Date>();
            List<Date> ActualDateAfterHoliday = ActualDate.size()>0?DateHelper.getDateIgnoringHolidayList(ActualDate) : new List<Date>();
            system.debug('ActualDateAfterHoliday '+ActualDateAfterHoliday);
            uniqueDate.addAll(ActualDateAfterHoliday);
            system.debug('uniqueDate.size() '+uniqueDate.size());
            return uniqueDate.size() > 0 ? uniqueDate.size() : 0;
        } else {
            return 0;
        }
    }

    public Static String timeRangeFormat(Datetime startDateTime, DateTime endDateTime) {
        Integer getStartHour = startDateTime.hour();
        Integer getEndHour = endDateTime.hour();
        String startHour = getStartHour > 12 ? getStartHour - 12 + ' pm' :
            getStartHour == 12 ? '12 pm' :
            getStartHour == 0 ? '12 am' :
            getStartHour + ' am';
        String endHour = getEndHour> 12 ? getEndHour - 12 + ' pm' : 
        getEndHour == 12 ? '12 pm' :
        getEndHour == 0 ? '12 am' :
        getEndHour + ' am';
        return startHour + ' - ' + endHour;
    }

    @AuraEnabled
    public static String scheduleCall(ScheduleCallWrapper objWrapper){
        try {
            List<Case> lstCase = new List<Case>();
            //if (objWrapper.callType == 'Regular') {
                lstCase = [SELECT Id,Escalation_Level__c,Student_Category__c,Account.nm_Centers__r.OwnerId FROM Case WHERE Id=:objWrapper.caseId];
            //}
            // List<Case> lstCase = [SELECT Id,Escalation_Level__c FROM Case WHERE Id=:objWrapper.caseId];
            // objWrapper.scheduleEscalationLevel = String.isBlank(objWrapper.scheduleEscalationLevel) || objWrapper.scheduleEscalationLevel=='0' ? '1' : String.valueOf(lstCase[0].Escalation_Level__c);
            objWrapper.scheduleEscalationLevel = String.isBlank(objWrapper.scheduleEscalationLevel) || objWrapper.scheduleEscalationLevel=='0' ? '1' : objWrapper.callType == 'Regular' ? objWrapper.scheduleEscalationLevel : String.valueOf(lstCase[0].Escalation_Level__c);
            List<String> lstD = objWrapper.scheduleDate.split('-');
            Date mydate = Date.newInstance(Integer.valueOf (lstD[0]), Integer.valueOf(lstD[1]), Integer.valueOf(lstD[2]));
            Task objTask = new Task(Id= objWrapper.taskId ,Subject='Call Scheduling', is_Call_Cancel__c = false, Status='Not Started', Priority='Normal', Schedule_Time_Slot__c=objWrapper.scheduleId, Time_Range__c=objWrapper.scheduleTimeRange, Escalation_Level__c=objWrapper.scheduleEscalationLevel, WhatId=objWrapper.recordId, Call_date__c=mydate, Customer_number__c=objWrapper.mobileNumber, Student_Name__c=objWrapper.studentName, Case__c=objWrapper.caseId, Student_Email__c=objWrapper.email, Type_of_Call__c=objWrapper.CallType, Is_Call_Already_Connected__c = false);
            if (lstCase.size() > 0 && lstCase[0].Student_Category__c == 'Learner Support Center' && objWrapper.CallType == 'Regular') {
                objTask.OwnerId = lstCase[0].Account.nm_Centers__r.OwnerId;
            }
            upsert objTask;
            if(objWrapper.callType == 'Escalation' && objWrapper.isEscalate) {                
                Boolean status = updateEscalationDate(objWrapper.caseId, true);
            }
            System.debug('objTask --> ' + objTask);
            return 'Created' + objTask;
        } catch (Exception e) {
            System.debug('Error Msg: '+e.getMessage());
            System.debug('Error Line No: '+e.getLineNumber());
            return 'failed';
        } 
    }

    /**
    * @description 
    * @author @BK | 07-18-2023 
    * @param studentno 
    * @return String 
    **/
    @AuraEnabled
    public static String getAccountId(String studentno) {
        if(String.isBlank(studentno)) {
            return '';
        }
        List<Account> lstAccount = [SELECT Id, Name, PersonEmail, PersonContactId FROM Account WHERE IsPersonAccount=true AND nm_StudentNo__c like :'%'+studentno LIMIT 1];
        return lstAccount.size() > 0 ? lstAccount[0].Id : '';
    }

    /**
    * @description 
    * @author @BK | 07-10-2023 
    * @param escalationLevel 
    * @param caseId 
    * @param recordId 
    * @param callType 
    * @return DateTimeRangeAndSchedulingList 
    **/
    @AuraEnabled
    public static DateTimeRangeAndSchedulingList getSchedulingTask(String escalationLevel, String caseId, String recordId, String callType, String programName, String calledFor){ 
        System.debug('call date time');
        String msg = '';
        //String learningCenterId = '';
        DateTimeRangeAndSchedulingList scheduleList = new DateTimeRangeAndSchedulingList();
        Map<String, Integer> mapOfTimeRangeVsAssignedStudent = new Map<String, Integer>();
        Map<String, List<Map<String,String>>> mapOfDateVsTimeRange = new Map<String, List<Map<String,String>>>();
        List<Case> lstCaseRecord = [SELECT Id,Student_Category__c,Account.LC_Name__c FROM Case WHERE Id=:caseId];
        String lcType = lstCaseRecord.size() > 0 && lstCaseRecord[0].Student_Category__c == 'Learner Support Center' && callType == 'Regular' ? lstCaseRecord[0].Account.LC_Name__c : '';
        // List<Account> lstAccount = [SELECT Id,nm_Centers__c FROM Account WHERE Id=:recordId LIMIT 1];
        callType = String.isBlank(callType) ? 'Regular' : callType;
        // if (lstAccount.size() > 0 && category == 'Learner Support Center') {
        //     learningCenterId = [SELECT OwnerId FROM nm_Centers__c WHERE Id = :lstAccount[0].nm_Centers__c].OwnerId;
        // }
        try {
            System.debug('task inside');
            List<Task> lstTask = [Select Id,Schedule_Call_Time__c,Case__r.CaseNumber,Schedule_Time_Slot__c,Call_date__c,Time_Range__c,Case__c,Escalation_Level__c,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Type_of_Call__c,WhatId,Status, Call_Scheduled_Key__c FROM Task WHERE Subject='Call Scheduling' AND Schedule_Time_Slot__c!=null AND (Status IN ('Not Started','In Progress') OR (Status='Not Connected' AND Is_Call_Already_Connected__c=false)) AND Call_date__c>=YESTERDAY];
            for(Task objTask : lstTask) {
                Set<String> status = new Set<String>{'Not Started', 'In Progress'};
               if (((objTask.Case__c == caseId && status.contains(objTask.Status)) || recordId == objTask.WhatId) && calledFor != 'Reschedule') {
                    System.debug('inside --> ');
                    String callDT = (objTask.Schedule_Call_Time__c!=null ? objTask.Schedule_Call_Time__c.format('dd-MM-yyyy hh:mm a') : DateTime.newInstance(
                        objTask.Call_date__c.year(), objTask.Call_date__c.month(), objTask.Call_date__c.day()).format('dd-MM-yyyy'));
                    // msg = 'Call already Scheduled on ' + callDT + ' against the case no: '+ objTask.Case__r.CaseNumber;
                    msg = 'A callback is already scheduled on ' + callDT + ' for Ticket No. - '+objTask.Case__r.CaseNumber+'. Please wait to complete this callback to schedule a new one.';
                    throw new AuraHandledException(msg);
                }

                // String mapKey = objTask.Call_date__c + '_' + objTask.Time_Range__c + '_' + objTask.Schedule_Time_Slot__r.Type_of_Call__c + '_' + objTask.Schedule_Time_Slot__c;
                Integer assignedStudents = mapOfTimeRangeVsAssignedStudent.containsKey(objTask.Call_Scheduled_Key__c) ? mapOfTimeRangeVsAssignedStudent.get(objTask.Call_Scheduled_Key__c) : 0;
                assignedStudents++;
                mapOfTimeRangeVsAssignedStudent.put(objTask.Call_Scheduled_Key__c,assignedStudents);
            }
            // To get map of Date Vs TimeRange
            mapOfDateVsTimeRange = getSchedulingList(escalationLevel,mapOfTimeRangeVsAssignedStudent,callType, programName,lcType);

            // Update slots aviablity on case.
            if(mapOfDateVsTimeRange.size() == 0 && String.isNotBlank(caseId)) {
                List<Case> lstCase = [SELECT id,Is_Slot_Available__c,Type_of_Call__c FROM Case WHERE Id=:caseId AND (Is_Slot_Available__c=false OR Type_of_Call__c=null)];
                if(lstCase.size() > 0) {
                    lstCase[0].Is_Slot_Available__c = true;
                    lstCase[0].Type_of_Call__c = callType;
                    update lstCase;
                }
            }
        } catch (Exception err) {
            System.debug('Error Message ==>'+err.getMessage());
            System.debug('Error Line No.==>'+err.getLineNumber());
        }
        System.debug('msg test--->' + msg);
        scheduleList.mapOfDateVsTimeRange = mapOfDateVsTimeRange;
        scheduleList.status = mapOfDateVsTimeRange.isEmpty() ? 'error' : 'success';
        scheduleList.message = String.isNotBlank(msg) ? msg : 'Something Went Wrong';
        return scheduleList;
    }

    /**
    * @description 
    * @author @BK | 07-10-2023 
    * @param escalationLevel 
    * @param mapOfRangeVsStudents 
    * @param callType 
    * @return Map<String, List<Map<String, String>>> 
    **/
    public static Map<String,List<Map<String,String>>> getSchedulingList(String escalationLevel, Map<String,Integer> mapOfRangeVsStudents, String callType, String programName, String lcType) {
        escalationLevel = String.isBlank(escalationLevel) || escalationLevel=='0' ? '1' : escalationLevel;
        Map<String,List<Map<String,String>>> mapOfDateVsTimeRange = new Map<String, List<Map<String,String>>>();
        String programType = getProgramType(programName);
        //System.debug('category--->' + category);
        String recordTypeName = String.isBlank(lcType) ? 'Voice Call - Support' : 'Voice Call - LC Support';
        // if (category == 'Learner Support Center') {
        //     recordTypeName = 'Voice Call - LC Support';
        // }
        try {
            List<Schedule_Time_Slot__c> lstScheduling = [SELECT Id,Start_time__c,End_time__c,Skill_Name__c,Total_Counselors__c,Type_of_Call__c,Per_Call_Schedule_Minutes__c,Start_date__c,End_date__c,Recurrence__c,Custom_Schedule_Days__c, Program_Type__c FROM Schedule_Time_Slot__c WHERE Type_of_Call__c=:callType  AND RecordType.Name=:recordTypeName AND LC_Type__c=:lcType AND ((Type_of_Call__c='Escalation' AND Escalation_Level__c includes (:escalationLevel)) OR (Type_of_Call__c='Regular' AND Escalation_Level__c=null)) AND (Program_Type__c=:programType OR Program_Type__c='All') AND IsActive__c=true AND End_date__c>=TODAY ORDER BY Program_Type__c DESC];
            for (Schedule_Time_Slot__c objSlot : lstScheduling) {
                Date startDate = objSlot.Start_date__c > System.today() ? objSlot.Start_date__c : System.today();
                Date endDate = objSlot.End_date__c;
                Integer maxAllowedPerTimeRange = Integer.valueOf(objSlot.Total_Counselors__c * (60 / objSlot.Per_Call_Schedule_Minutes__c));
                List<String> workingDays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
                List<String> customDays = objSlot.Custom_Schedule_Days__c!=null && objSlot.Custom_Schedule_Days__c!='' ? objSlot.Custom_Schedule_Days__c.split(';') : workingDays;
                if(startDate < endDate) {
                    while (startDate <= endDate) {
                        DateTime dt = startDate;
                        String weekOfDay = dt.format('EEEE');
                        if(objSlot.Recurrence__c == 'Daily' || (objSlot.Recurrence__c == 'Monday to Saturday' && workingDays.contains(weekOfDay)) || (objSlot.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                            mapOfDateVsTimeRange = getDateWithTimeRange(startDate,objSlot,mapOfDateVsTimeRange,mapOfRangeVsStudents,maxAllowedPerTimeRange);
                        }
                        startDate = startDate.addDays(1);
                    }
                } else {
                    DateTime dt = startDate;
                    String weekOfDay = dt.format('EEEE');
                    if(objSlot.Recurrence__c == 'Daily' || (objSlot.Recurrence__c == 'Monday to Saturday' && workingDays.contains(weekOfDay)) || (objSlot.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                        mapOfDateVsTimeRange = getDateWithTimeRange(startDate,objSlot,mapOfDateVsTimeRange,mapOfRangeVsStudents,maxAllowedPerTimeRange);
                    }
                }
            }
        } catch (Exception err) {
            System.debug('Error Message ==>'+err.getMessage());
            System.debug('Error Line No: ==>'+err.getLineNumber());
        }
        return mapOfDateVsTimeRange;
    }

    /**
    * @description 
    * @author @BK | 07-10-2023 
    * @param startDate 
    * @param objSlot 
    * @param mapOfDateVsTimeRange 
    * @param mapOfTimeRangeVsStudent 
    * @param maxAllowedPerTimeRange 
    * @return Map<String, List<Map<String, String>>> 
    **/
    public static Map<String,List<Map<String,String>>> getDateWithTimeRange(Date startDate,Schedule_Time_Slot__c objSlot, Map<String,List<Map<String,String>>> mapOfDateVsTimeRange, Map<String,Integer> mapOfTimeRangeVsStudent, Integer maxAllowedPerTimeRange) {
        try {
            Datetime startDateTime =  Datetime.newInstance(startDate, objSlot.Start_time__c);
            System.debug('startDateTime---> ' + startDateTime);
            // startDateTime = startDateTime.date() == System.today() ? System.now().addHours(2) : startDateTime;
            if(startDateTime.date() == System.today()) {
                Datetime currentDateTime = System.now().addHours(3) >= startDateTime ? System.now().addHours(3) : startDateTime;
                currentDateTime = currentDateTime.minute() >= 30 ? currentDateTime.addHours(1) : currentDateTime;
                startDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), currentDateTime.hour(), 0, 0);
            }
            System.debug('startDateTime---> ' + startDateTime);
            Datetime endDateTime = Datetime.newInstance(startDate, objSlot.End_time__c);
            List<Map<String,String>> lstTimeRange = mapOfDateVsTimeRange.containsKey(String.valueOf(startDate)) ? mapOfDateVsTimeRange.get(String.valueOf(startDate)) : new List<Map<String,String>>();
            while (startDateTime < endDateTime) {
                String timeRange = timeRangeFormat(startDateTime, startDateTime.addHours(+1));
                // String mapKey = startDate + '_' + timeRange + '_' + objSlot.Type_of_Call__c + '_' + objSlot.id + '_' + objSlot.Program_Type__c;
                String mapKey = startDate.year() + '-' + String.valueOf(startDate.month()).leftPad(2, '0') + '-' + String.valueOf(startDate.day()).leftPad(2, '0') + '_' + timeRange + '_' + objSlot.Type_of_Call__c + '_' + String.valueOf(objSlot.id).left(15) + '_' + objSlot.Program_Type__c;
                Boolean isTimeRangeExists = true;
                for (Object mapOfTimeRangeAndIdObject : lstTimeRange) {
                    Map<String,String> mapOfTimeRangeAndIdAlready = (Map<String,String>) mapOfTimeRangeAndIdObject;
                    for(String keyValue : mapOfTimeRangeAndIdAlready.keySet()) {
                        if (keyValue == 'timeRange' && timeRange == mapOfTimeRangeAndIdAlready.get(keyValue)) {
                            isTimeRangeExists = false;
                        }
                    }
                }

                if (isTimeRangeExists && 
                    (!mapOfTimeRangeVsStudent.containsKey(mapKey) || (mapOfTimeRangeVsStudent.containsKey(mapKey) && maxAllowedPerTimeRange > mapOfTimeRangeVsStudent.get(mapKey)))) {
                    Map<String,String> mapOfTimeRangeAndId = new Map<String,String>();
                    mapOfTimeRangeAndId.put('timeRange', timeRange);
                    mapOfTimeRangeAndId.put('schedulingId', objSlot.Id);
                    lstTimeRange.add(mapOfTimeRangeAndId);
                    System.debug('lstTimeRange ==================>');
                    System.debug(lstTimeRange);
                }
                startDateTime = startDateTime.addHours(1);
            }
            if(lstTimeRange.size() > 0) {
                mapOfDateVsTimeRange.put(String.valueOf(startDate), lstTimeRange);
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage());
            System.debug('Error Line No: ==>'+e.getLineNumber());
        }
        return mapOfDateVsTimeRange;
    }

    public static String getProgramType(String programName) {
        Map<String, Set<String>> mapOfTypeVsLstProgram = new Map<String, Set<String>> {
            'Retail' => new Set<String>{'MBA (ITSM)', 'MBA (RM)', 'MBA (SCM)', 'MBA (MM)', 'MBA (ITM)', 'MBA (BFM)', 'MBA (FM)', 'MBA (HRM)', 'MBA (OM)', 'MBA (BM)', 'M.Sc. (Applied Finance)', 'DITM', 'DRM', 'DOM', 'DBM', 'DHRM', 'DMM', 'DFM', 'DBFM', 'DSCM'},
            'Professional and Certificate' => new Set<String>{'PDDM', 'PD-DS', 'PC-DS', 'PD - WM', 'PC-DM', 'CITM - ET', 'CITM - ES', 'CITM - DB', 'C-SMM & DMA', 'C-SEM & SMM', 'C-SEM & DMA', 'C-SMM', 'C-SEM', 'C-DMA', 'COM', 'CPM', 'CCC', 'CBM'},
            'Executive' => new Set<String>{'MBA(WX) - AF', 'MBA(WX) - DM', 'MBA(WX) - LS', 'MBA(WX) - M', 'MBA(WX) - OSC', 'MBAX - BA', 'M.Sc. (AI) - DL', 'M.Sc. (AI) - DO', 'M.Sc. (AI & ML Ops)', 'PD-DS', 'PC-DS' },
            'UG' => new Set<String>{'B.Com', 'BBA', 'BBA-BA'}
        };
        for(String programType : mapOfTypeVsLstProgram.keySet()) {
            if (mapOfTypeVsLstProgram.get(programType).contains(programName)) {
                return programType;
            }
        }
        return 'Not Found';
    }

    /**
    * @description 
    * @author @BK | 06-12-2023 
    * @param caseId 
    * @param callBack 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean updateEscalationDate(String caseId, Boolean callBack) {
        try {
            Case c = [SELECT OwnerId,ContactId,Expected_Close_Date__c,isCallback__c,Escalation_Level__c,Grievance_Escalation_Days__c,Head_Escalation_Days__c,Manager_Escalation_Days__c FROM Case WHERE Id=:caseId];
            // Integer diff = getNumberOfDays(System.today(), System.today().addDays(2));
            // if(diff < 2){
            //     Integer actualTat = 2 + (2-diff);
            //     system.debug(actualTat);
            //     c.Expected_Close_Date__c = System.today().addDays(actualTat);
            // }else{
            //     c.Expected_Close_Date__c = System.today().addDays(2);
            // }
            Integer level = Integer.valueOf(c.Escalation_Level__c);
            c.Expected_Close_Date__c = level == 1 ? System.today().addDays(2) : level == 2 ? System.today().addDays(7) : level == 3 ? System.today().addDays(30) : level == 4 ? System.today().addDays(60) : c.Expected_Close_Date__c;
            c.isCallback__c = callBack;
            update c;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Task checkCallAlreadyScheduled(String recordId){
        try {
            List<Task> lstTask = [Select Id,Schedule_Call_Time__c,Case__r.CaseNumber, Call_date__c FROM Task WHERE Subject='Call Scheduling' AND Schedule_Time_Slot__c != null AND WhatId=:recordId AND Call_date__c>=YESTERDAY AND (Status IN ('Not Started','In Progress') OR (Status='Not Connected' AND Is_Call_Already_Connected__c=false))];
            if(lstTask.size() > 0) {
                return lstTask[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 27-09-2023 
    * @param caseId 
    * @return list<Attachment> 
    **/
    // public static list<AttachmentData> getCaseAttachmentsV2(String caseId) {
    //     List<AttachmentData> lstData = new List<AttachmentData>();
    //     try {
    //         Map<String, String> dataUriMap = new Map<String, String>();
    //         // Add data URIs with file extensions as keys
    //         dataUriMap.put('txt', 'data:text/plain');
    //         dataUriMap.put('html', 'data:text/html');
    //         dataUriMap.put('png', 'data:image/png');
    //         dataUriMap.put('jpeg', 'data:image/jpeg');
    //         dataUriMap.put('gif', 'data:image/gif');
    //         dataUriMap.put('mp3', 'data:audio/mpeg');
    //         dataUriMap.put('mp4', 'data:video/mp4');
    //         dataUriMap.put('pdf', 'data:application/pdf');
    //         dataUriMap.put('json', 'data:application/json');
    //         dataUriMap.put('xml', 'data:application/xml');
    //         dataUriMap.put('js', 'data:application/javascript');
    //         dataUriMap.put('bin', 'data:application/octet-stream');
    //         // Now you have a map with file extensions as keys and data URI as the value

    //         List<Attachment> lstAttachments = [SELECT Id,Name,Body,CreatedDate,ContentType FROM Attachment WHERE ParentId=:caseId];
    //         for (Attachment obj : lstAttachments) {
    //             String fileName = obj.Name;
    //             String fileFormat = fileName.substringAfterLast('.');
    //             String dataMIMEType = String.isNotBlank(fileFormat) && dataUriMap.containsKey(fileFormat) ? dataUriMap.get(fileFormat) : 'data:application/octet-stream';
    //             AttachmentData objData = new AttachmentData();
    //             objData.name = fileName;
    //             objData.fileURL = EncodingUtil.base64Encode(obj.Body);
    //             objData.fileURL = dataMIMEType + ';base64,' + objData.fileURL;
    //             objData.recordId = obj.Id;
    //             objData.createdDate = obj.CreatedDate;
    //             lstData.add(objData);
    //         }
    //     } catch (Exception e) {
    //         System.debug(e.getMessage());
    //     }
    //     return lstData;
    // }

    /**
    * @description 
    * @author @BK | 10-10-2023 
    * @param caseId 
    * @return list<ContentDistribution> 
    **/
    @AuraEnabled
    public static list<AttachmentData> getCaseAttachments(String caseId) {
        try {
            if(String.isNotBlank(caseId)) {
                // List<AttachmentData> lstData = getCaseAttachmentsV2(caseId);
                List<AttachmentData> lstData = new List<AttachmentData>();
                Set<Id> docIdSet = new Set<Id>();
                Map<Id,ContentDocumentLink> mapOfIdVsfile = new Map<Id,ContentDocumentLink>();
                for(ContentDocumentLink doc : [Select ContentDocumentId,ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                                from ContentDocumentLink where LinkedEntityId =:caseId]){
                    docIdSet.add(doc.ContentDocumentId);
                    mapOfIdVsfile.put(doc.ContentDocumentId,doc);
                }

                if(docIdSet.size() > 0) {
                    List<ContentDistribution> lstpublicUrl = [SELECT Id,DistributionPublicUrl,ContentDocumentId,Name,ContentVersionId,CreatedDate FROM ContentDistribution WHERE ContentDocumentId IN : docIdSet];
                    if(lstpublicUrl.size() > 0) {
                        for (ContentDistribution objCD : lstpublicUrl) {
                            AttachmentData objData = new AttachmentData();
                            objData.name = objCD.Name;
                            objData.fileURL = objCD.DistributionPublicUrl;
                            objData.recordId = objCD.Id;
                            objData.createdDate = objCD.CreatedDate;
                            lstData.add(objData);
                        }
                    }
                }
                return lstData;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Boolean getCancelScheduleAPI(String callId, String taskId, String callStatus, String actionType) {
        try{
            boolean response = true;
            if(callStatus == 'In Progress') {
                response = getAPIResponse(callId);
            }
            if (response) {
                update new Task(Id = taskId, is_Call_Cancel__c = true, Status = 'Not Connected', Call_cancel_or_reschedule__c = actionType, Cancel_or_reschedule_time__c = System.now(), Is_Call_Already_Connected__c = true);
            }
            return response;
        
        } catch (Exception e) {
            System.debug(e.getLineNumber() + ' --- '+e.getMessage());
            return false;
        }
    }

    /**
    * @description 
    * @author @vickysahu | 27-12-2023 
    * @param String callId 
    * @return Boolean 
    **/
    public static Boolean getAPIResponse(String callId){
        try {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint('https://in1-ccaas-api.ozonetel.com/CAServices/scheduleCampaignData/deleteScheduleData.php?api_key=' + System.Label.OzontelAPIKey +'&row_id=' + callId);
            req.setMethod('GET');
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            String resBody = resp.getBody();
            System.debug('statusCode = '+statusCode);
            if(statusCode == 200) { 
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                if(responseBody.containsKey('status') && (String)responseBody.get('status')=='success') {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            System.debug(e.getLineNumber() + ' --- '+e.getMessage());
            return false;
        }
    }

    /**
    * @description 
    * @author @vickysahu | 27-12-2023 
    * @param String caseId 
    * @return List<ScheduleCallDataWrapper> 
    **/
    @AuraEnabled(cacheable=false)
    public static List<ScheduleCallDataWrapper> getScheduleTableData(String caseId) {
        List<ScheduleCallDataWrapper> lstCallSchedulingTable = new List<ScheduleCallDataWrapper>();
        for(Task objTask: [SELECT Id,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Status,Call_uuid__c,Case__c,Type_of_Call__c FROM Task WHERE Subject='Call Scheduling' AND Case__c=:caseId AND (Status='Not Started' OR Status='In Progress') Order by CreatedDate DESC]) {
            ScheduleCallDataWrapper ScheduleCallDataWrapper = new ScheduleCallDataWrapper();
            Boolean isButtonActive = objTask.Status == 'Not Started' || (objTask.Status == 'In Progress' && String.isNotBlank(objTask.Call_uuid__c) && objTask.Schedule_Call_Time__c != null && objTask.Schedule_Call_Time__c.addHours(-2) >= DateTime.now()) ? true : false;
            ScheduleCallDataWrapper.scheduleDateRange = (objTask.Status == 'In Progress' && objTask.Schedule_Call_Time__c!=null ? 
                objTask.Schedule_Call_Time__c.format('dd-MM-yyyy hh:mm a') : 
                DateTime.newInstance( objTask.Call_date__c.year(), objTask.Call_date__c.month(), objTask.Call_date__c.day()).format('dd-MM-yyyy') +' '+ objTask.Time_Range__c);
            ScheduleCallDataWrapper.scheduleStatus = objTask.Status;
            ScheduleCallDataWrapper.scheduleCancelBtnActive = isButtonActive ? false  : true;
            ScheduleCallDataWrapper.scheduleCancelBtnVariant = isButtonActive ? 'destructive' : 'base' ;
            ScheduleCallDataWrapper.scheduleCancelBtnText = isButtonActive ? 'Cancel' : 'NA';
            ScheduleCallDataWrapper.scheduleRescheduleBtnActive = isButtonActive ? false  : true;
            ScheduleCallDataWrapper.scheduleRescheduleBtnVariant = isButtonActive ? 'destructive' : 'base';
            ScheduleCallDataWrapper.scheduleRescheduleBtnText = isButtonActive ? 'Re-Schedule' : 'NA';
            ScheduleCallDataWrapper.scheduleCaseId = objTask.Case__c;
            ScheduleCallDataWrapper.scheduleTaskId = objTask.Id;
            ScheduleCallDataWrapper.scheduleCallUuid = objTask.Call_uuid__c;
            ScheduleCallDataWrapper.scheduleCallType = objTask.Type_of_Call__c;
            lstCallSchedulingTable.add(ScheduleCallDataWrapper);
        }
        System.debug('lstCallSchedulingTable --> ' + lstCallSchedulingTable);
        return lstCallSchedulingTable;
    }

    public class AttachmentData {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String fileURL;
        @AuraEnabled
        public string recordId;
        @AuraEnabled
        public DateTime createdDate;
    }

    public class DateTimeRangeAndSchedulingList {
        @auraEnabled public Map<String, List<Map<String,String>>> mapOfDateVsTimeRange {get;set;}
        @auraEnabled public String status {get; set;}
        @auraEnabled public String message {get; set;}
    }

    public class CaseWrapper {
        @AuraEnabled
        public String label1;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public Boolean isActive;
        @AuraEnabled
        public String caseSubject;
        @AuraEnabled
        public String caseStatus;
        @AuraEnabled
        public Date caseCreatedDate; 
        @AuraEnabled
        public Date caseCloseDate;    
        @AuraEnabled
        public String caseId; 
        @AuraEnabled 
        public String showButton;
        @AuraEnabled 
        public String variant;
        @AuraEnabled
        public Date caseInProgressDate; 
        @AuraEnabled 
        public String recordId;
        @AuraEnabled 
        public String escalationNumber;
        @AuraEnabled 
        public String typeOfObject;
        // Call button
        @AuraEnabled
        public String callBtnLabel;
        @AuraEnabled
        public String callBtnVariant;
        @AuraEnabled
        public Boolean callBtnDisabled;
    }

    public class ScheduleCallWrapper {
        @AuraEnabled
        public String scheduleId {get;set;} 
        @AuraEnabled
        public String scheduleDate {get;set;}
        @AuraEnabled
        public String scheduleTimeRange {get;set;} 
        @AuraEnabled
        public String scheduleEscalationLevel {get;set;}
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String typeOfObject {get;set;}
        @AuraEnabled
        public String mobileNumber {get;set;}
        @AuraEnabled
        public String studentName {get;set;}
        @AuraEnabled
        public String caseId {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String callType {get;set;}
        @AuraEnabled
        public String taskId {get;set;}
        @AuraEnabled
        public Boolean isEscalate {get;set;}

        public ScheduleCallWrapper() {
            this.scheduleId = scheduleId;
            this.scheduleDate = scheduleDate;
            this.scheduleTimeRange = scheduleTimeRange;
            this.scheduleEscalationLevel = scheduleEscalationLevel;
            this.recordId = recordId;
            this.typeOfObject = typeOfObject;
            this.mobileNumber = mobileNumber;
            this.studentName = studentName;
            this.caseId = caseId;
            this.email = email;
            this.callType = callType;
            this.taskId = taskId;
            this.isEscalate = true;
        }
    }

    public class ScheduleCallDataWrapper {
        @AuraEnabled public String scheduleDateRange {get; set;}
        @AuraEnabled public String scheduleStatus {get; set;}
        @AuraEnabled public Boolean scheduleCancelBtnActive {get; set;}
        @AuraEnabled public String scheduleCancelBtnVariant {get; set;}
        @AuraEnabled public String scheduleCancelBtnText {get; set;}
        @AuraEnabled public Boolean scheduleRescheduleBtnActive {get; set;}
        @AuraEnabled public String scheduleRescheduleBtnVariant {get; set;}
        @AuraEnabled public String scheduleRescheduleBtnText {get; set;}
        @AuraEnabled public String scheduleCaseId {get; set;}
        @AuraEnabled public String scheduleTaskId {get; set;}
        @AuraEnabled public String scheduleCallUuid {get; set;}
        @AuraEnabled public String scheduleCallType {get; set;}
    }
    
}