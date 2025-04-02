/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : @BK
**/
public class MassUpdateCases {
    @AuraEnabled
    public static void UpdateCases(Map<String,String> fieldMap){
        String casenos = fieldMap.get('nos');
        Set<String> numbersSet = new Set<String>();

        if (casenos != null && casenos != '') {
            String[] numbersArray = casenos.split(',');
            
            for (String num : numbersArray) {
                try {                    
                    numbersSet.add(num);
                } catch (Exception e) {
                    return;
                }
            }
        }
        
        List<Case> caseList = new List<Case>();
        List<CaseComment> commList = new List<CaseComment>();
        for(Case c: [SELECT Id, CaseNumber, Status, Expected_Close_Date__c, OwnerId FROM Case WHERE CaseNumber IN :numbersSet]){
            if(fieldMap.containsKey('status')){
                c.Status = fieldMap.get('status');
            }
            if(fieldMap.containsKey('ecd')){
                c.Expected_Close_Date__c = Date.valueOf(fieldMap.get('ecd'));
            }
            if(fieldMap.containsKey('owner')){
                c.OwnerId = fieldMap.get('owner');
            }
            if(fieldMap.containsKey('cat')){
                c.nm_Category__c = fieldMap.get('cat');
            }
            if(fieldMap.containsKey('subcat')){
                c.sub_categories__c = fieldMap.get('subcat');
            }
            if(fieldMap.containsKey('issue')){
                c.Tech_Issue__c = fieldMap.get('issue');
            }
            if(fieldMap.containsKey('comment')){
                CaseComment comm = new CaseComment();
                comm.CommentBody = fieldMap.get('comment');
                comm.ParentId = c.Id; 
                comm.IsPublished = true;
                commList.add(comm);
            }
            caseList.add(c);
        }
        try{
            Database.DMLOptions dlo = new Database.DMLOptions();
            Database.SaveResult[] sr = database.update(caseList, dlo);
            database.insert(commList);
        }catch(Exception e){
            system.debug(e);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getProgram(String caseId){
       String program;
       Case c = [SELECT AccountId, Account.nm_Program__r.Name, Lead__r.nm_Program__r.Name FROM Case WHERE Id = :caseId]; 
        if(c.AccountId != null){
           program = c.Account.nm_Program__r.Name;
        }else if(c.Lead__c != null){
           program = c.Lead__r.nm_Program__r.Name; 
        }else{
           program = 'No student or lead attached to the case.';
        }
        
        return program;
    }
    
    @AuraEnabled
    public static String addComment(Map<String,String> fieldMap, String caseId){
        system.debug(fieldMap);
		Case c = [SELECT Id, CaseNumber, Add_Comment__c, isOnlyStatus__c, Status, Expected_Close_Date__c, OwnerId, Count_of_ECD_changed_By_User__c, Count_of_ECD_changed_By_System__c FROM Case WHERE Id = :caseId];
        
        CaseComment comm = new CaseComment();
        
            if(fieldMap.containsKey('status')){
                c.Status = fieldMap.get('status'); 
                c.Add_Comment__c = true;
                c.isOnlyStatus__c = false;
                if(fieldMap.get('status') == 'In-Progress'){
                    Integer daysLeft = Integer.valueOf(c.Expected_Close_Date__c.daysBetween(System.today()));
                    Date addDaysToEcd = daysLeft == 2 ? c.Expected_Close_Date__c + 1 : ( daysLeft == 1 ? c.Expected_Close_Date__c + 2 : (daysLeft == 0 ? c.Expected_Close_Date__c + 3 : ( daysLeft < 0 ? System.today() + 3 : c.Expected_Close_Date__c )));                    
                    if(c.Expected_Close_Date__c != addDaysToEcd){
                        c.Count_of_ECD_changed_By_System__c = c.Count_of_ECD_changed_By_System__c!=null ? c.Count_of_ECD_changed_By_System__c + 1 : 1;
                        c.Expected_Close_Date__c = addDaysToEcd;
                    }                    
                }
            }
        
            if(fieldMap.containsKey('ecd')){
                c.Expected_Close_Date__c = Date.valueOf(fieldMap.get('ecd'));
                c.Count_of_ECD_changed_By_User__c = c.Count_of_ECD_changed_By_User__c!=null ? c.Count_of_ECD_changed_By_User__c + 1 : 1;
            }
            if(fieldMap.containsKey('owner')){
                system.debug(fieldMap.containsKey('owner'));
                c.OwnerId = fieldMap.get('owner');
            }
            if(fieldMap.containsKey('cat')){
                c.nm_Category__c = fieldMap.get('cat');
            }
            if(fieldMap.containsKey('subcat')){
                c.sub_categories__c = fieldMap.get('subcat');
            }
            if(fieldMap.containsKey('issue')){
                c.Tech_Issue__c = fieldMap.get('issue');
            }
        	system.debug(fieldMap.containsKey('comment'));
            if(fieldMap.containsKey('comment')){
				system.debug(fieldMap.get('comment'));               
                comm.CommentBody = fieldMap.get('comment');
                comm.ParentId = c.Id; 
                comm.IsPublished = true;               
            }
        
        update c;
        if(fieldMap.containsKey('comment')){
        	insert comm;  
            return comm.Id;
        }else{
            return '';
        }
              
    }
    
    @AuraEnabled
    public static List<String> getDependentPicklistValues(String categoryValue, String program){
        system.debug('program '+program);
        system.debug('value '+categoryValue);
        Map<String,List<String>> aWxMap = new Map<String,List<String>>{
        	'Admissions' => new List<String>{'Admission Cancellation','Validity extension details','De-registration request'},
            'Academics' => new List<String>{'Academic calendar not updated','Batch Planner clarification','Harvard module not available','E resources/Digital  books not available','PPT not updated','Recording not updated','Repeat subject policy clarification','Term III Electives selection','Term IV Electives selection','Term V Electives selection','Webinar enquiries','Change in session schedule','Capstone round progression','Harvard module not available'},
            'Examination - Internal Assessment' => new List<String>{'IA - Copy case','IA - Missed','IA Issue - Unable to submit','IA marks clarification','IA QP incorrect','IA results not declared','IA- Technical issue','IA-QP to session incorrect mapping','IA Policy Clarification','IA Schedule change','IA Issue - Unable to Join'},
            'Examination - TEE' => new List<String>{'Unable to click on Exam Link','Disconnected from examination','Camera/Microphone permission issue','Unable to type descriptive answers','Proctor feedback','Missed examination','Mettl number not reachable','Compatibility test issue','Re- Exam dates','Re- Exam pattern','Re- Exam payment issue','Re- Exam Policy clarification','TEE -Marks clarification','TEE - Missed both slots','TEE - Results not declared','TEE - Unfair means','TEE - Policy Clarification','Gradesheet/Final Certifcate Status'},
            'Logistics' => new List<String>{},
            'Student Support' => new List<String>{'Ascend Certificates','Nmentor Enquiry','Student portal issues'},
            'Portal Support' => new List<String>{}
        }; 
        Map<String,List<String>> aRetailMap = new Map<String,List<String>>{
        	'Admissions' => new List<String>{'Admission - Cancellation Process','Admission - Payment issue','Program Change','Re-Registration - Payment Issue','Re-Registration - Procedure/Link','Re-Registration - Policy Clarification','Registration cancellation','Re-registration dates','Live lectures - Payment status','Live Lectures - Issue','Lateral admissions - Process','Validity extension Policy'},
            'Academics' => new List<String>{'Acknowledgment','Credential related','Credential related- Email ID change','Digital Library unable to access','PPT missing','PPT not complete/Bad quality','Recordings Missing','Recordings not complete/Bad quality','E-Books different from books received','E-Books not available on portal','PPT not uploaded >48 hours','Program Credit details','Recordings not uploaded >48 hours','Tracks clarification','Project Topic confirmation'},
            'Examination - Internal Assessment' => new List<String>{'Acknowledgment','Assignment Related - Guidelines Clarification','Assignment Related - Incorrect submission','Assignment Related - Policy clarification','Assignment Related - QP clarification','Assignment Related - Submission post last date','Assignment Related - Unable to pay','Assignment Related - Unable to submit tech issues','Exam Pattern/Demo Exams/Questions bank','Exam Registration - Exam Cancellation','Exam Registration - Exam dates','Exam Registration - Exam Schedule change - Exception','Exam Registration payment issue','Exam Registration - Exam Schedule change','Exam Registration - Slots not available','Exam results - Reevaluation clarifications','Exam results - Reevaluation Process','Hall ticket','Hall ticket - Unable to download','Marksheet/Certificate - SR Procedure','Others','Project - Guidelines Clarification','Project Submission payment issue','Project Submission post last date','Refund- status','Assignment related -Missed Assignment Submission','Assignment related -Assignment marked as Copy Case','Exam Registration - Missed registering ','Exam Registration - after deadline','Marksheet - SR Status','Unable to click on Exam Link','Disconnected from examination','Camera/Microphone permission issue','Unable to type descriptive answers'},
            'Examination - TEE' => new List<String>{'Examination Centre feedback','Exam Pattern','TEE- UFM','Project Feedback','TEE Question paper feedback','Exam results - Dates','Exam results - Pass/Fail Status','Exam results - Unable to clear a subject','Late for examination','Absent/Missed examination','Project Feedback','Question paper feedback','Transcripts - Process','Final Certificate - SR Status','Transcripts - Status','Acknowledgment','WES - Process'},
            'Logistics' => new List<String>{'Acknowledgment','Others','Study Materials - not received','Study Materials - on hold','Damaged books received','Books missing from Study kit','Incorrect books received','Fee  receipt - Physical copy','Study materials - Returned back','Study Kit - OTP not received'},
            'Student Support' => new List<String>{'Student portal issues','Mettl number not reachable/not answering','Support counsellor complaint','Career Services - Call Back not recieved'},
            'Portal Support' => new List<String>{'Incorrect  Marksheet displayed','Invalid Credentials','Mobile App - Unable to Login','Mobile App- Issues','Lateral Subjects not updated','ID Card - incorrect data','Assignment incorrectly displayed -2 cycles live'}
        }; 
        Boolean isTermProgram = [SELECT nm_ProgramName__c, Name, IsTerm__c FROM nm_Program__c WHERE Name =:program LIMIT 1].IsTerm__c;
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = Case.Sub_Categories__c.getDescribe();
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
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                system.debug('controllerValues '+controllerValues);
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
        if(dependentPicklistValues.get(categoryValue) != null){
            List<String> categoryLst = new List<String>();        
            Set<String> picklist = new Set<String>(dependentPicklistValues.get(categoryValue));
            system.debug(picklist);
            if(isTermProgram == true){
                //flag true WX Programs
                categoryLst = aretailMap.get(categoryValue);                        
            }else{
                //Flag false retail programs
                categoryLst = awxMap.get(categoryValue);
            }
            system.debug('categoryLst '+categoryLst);
            for(String sc : categoryLst){           
                picklist.remove(sc);                   
            }
            subcatLst = new List<String>(picklist);
        }else{
            return subcatLst;
        }
        system.debug('subcatLst '+subcatLst);
        return subcatLst;
    }
    
}