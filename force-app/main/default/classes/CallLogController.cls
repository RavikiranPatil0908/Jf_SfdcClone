public without sharing class CallLogController {
    
    @AuraEnabled
    public static List<String>  getPickListValuesForDisposition(String callCategory){
        System.debug('callCategory : '+callCategory);
        // Map<String,List<String>> dList = new Map<String,List<String>>{
        //     'Admissions' => new List<String>{'Acknowledgement','Admission/Re- Registration- dates','Admission- Cancellation process','Admission - Payment issue','Admission queries - MBA WX','Admission queries - Msc Fin','Admission queries - PG/Dip','Admission queries - Prof/Cert','Admission queries - SAS','AEP Change request','Bonafide Certificate','De-registration','Documented related','Email/Mobile Verification','Email ID change','Exit Policy/procedure','Lateral entry','Lead - Not interested','Migration Certificate','Others','Payment related','PHD enquires','Program change','Program Withdrawal','Referral Bonus','Refund - Status','Re- Registration- payment issue','Re- Registration- procedure/link','Re- Registration- Policy clarification','University Approvals','Update Profile','Validity extension','Welcome email not received'},
        //     'Academics' => new List<String>{'Academic Calender not updated','Acknowledgement','Capstone round progression','Capstone schedule details','Change in session schedule','Course content feedback','Credential related','Credential related - email ID change','Credential related - not received by student > 48 hours','Digital Library- unable to access','E Book - not available','E Book - different from books','Email Notification not received','Faculty Feedback','Online session - Unable to attend','Online session - Unable to chat','Online session -Unable to hear the faculty','Others','Post a query','Post a Query - Not answered','PPT missing','PPT not complete/bad quality','PPT not uploaded > 72 hours','Recordings/PPT not uploaded > 72 hours','Session alert not received','Term 7 and 8 queries','Too many sessions on one day'},
        //     'Examination - Internal Assignment' => new List<String>{'IA - Copy case','IA - Missed','IA Issue - Unable to submit','IA marks clarification','IA QP incorrect','Internal Assignment Feedback'},
        //     'Examination - TEE' => new List<String>{'Bio Break','Camera/Microphone permission issue','Compatibility test issue','Demo exams not working','Disconnected from examination','Gradesheet/Final Certificate Status','Project Copy case','Re- Exam dates','Re- Exam pattern','Re- Exam payment issue','Re- Exam Policy clarification','Reissue of Mark sheet/Final Certificate','Scribe Request','TEE -Marks clarification','TEE - Missed both slots','TEE - Policy clarification','TEE - Results not declared','TEE - Unfair means','Unable to click on Exam Link','Unable to type descriptive answers'},
        //     'Logistics' => new List<String>{'Acknowledgement','Damaged Marksheet/Final certificate','Duplicate ID card - not received','Fee Recipt','ID card - lost','ID card - not received','	Marksheet/Final certificate returned back.','Others','Study Kit - Delivery Status','Study Kit - Printing Issue','Study Materials - Delivery exception','Study Materials - not received','Study Materials - On hold','Welcome kit - not received'},
        //     'Student Support' => new List<String>{'Acknowledgement','AEP Complaints','AEP Enquiry/Franchise','Career Services Enquiry','Do not want Promotional emails','LC Complaints','Mobile App - Cannot register for Exams','Mobile App - Cannot upload Assignments','Mobile App - Raise SR','	Mobile App - Unable to attend session','Mobile App - Unable to download PPT','Mobile App - Unable to download recordings','Mobile App - Unable to login','NMentor Enquiry','Others','Other University query','Payment related','Placements/Alma Connect','Service request- Status enquiry','	Service request - Technical issue','Toll free number issues','Webinar Certificates','Webinar Enquiry'},
        //     'Others' => new List<String>{'Acknowledgement','Others','Payment related','Service Request'},
        //     'Portal Support' => new List<String>{'Assignment incorrectly displayed -2 cycles live','Badges','Career Services - Unable to access','Change Password','ID card - Incorrect Details','Incorrect Gradesheet displayed','Incorrect Marksheet displayed','	Mobile App -Unable to Login','My Communication - email not received','My profile incorrect','Ranks','Session alerts not received','Student Portal Issues','Unable to Login -Mobile App','Unable to Login - Portal','Unable to raise Service Request - Technical issue','Unable to share FC on LinkedIn','Unable to update profile','Validity not extended - Payment done'}            
        // };

        Map<String,List<String>> dList = getFieldDependencies('Task','Call_Category__c','Disposition__c');
        List<String> lst = new List<String>();
        if(callCategory != NULL){
            lst =  dList.get(callCategory);   
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }

    public class MyPickListInfo
    {
         public String validFor;
    }
 
 public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
 {
     Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
 
     Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
 
     Schema.DescribeSObjectResult describeResult = objType.getDescribe();
     Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
     Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
 
     List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
     List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
 
     for(Schema.PicklistEntry currControllingValue : controllingValues)
     {
         System.debug('ControllingField: Label:' + currControllingValue.getLabel());
         controllingInfo.put(currControllingValue.getLabel(), new List<String>());
     }
 
     for(Schema.PicklistEntry currDependentValue : dependentValues)
     {
         String jsonString = JSON.serialize(currDependentValue);
 
         MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
 
         String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
 
         System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
 
         Integer baseCount = 0;
 
         for(Integer curr : hexString.getChars())
         {
             Integer val = 0;
 
             if(curr >= 65)
             {
                 val = curr - 65 + 10;
             }
             else
             {
                 val = curr - 48;
             }
 
             if((val & 8) == 8)
             {
                 System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                 controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
             }
             if((val & 4) == 4)
             {
                 System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                 controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
             }
             if((val & 2) == 2)
             {
                 System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                 controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
             }
             if((val & 1) == 1)
             {
                 System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                 controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
             }
 
             baseCount += 4;
         }            
     } 
 
     System.debug('ControllingInfo: ' + controllingInfo);
 
     return controllingInfo;
 }

    @AuraEnabled(cacheable=true)
    public static List<String>  getPickListValuesForCallCategory(){

        Schema.DescribeFieldResult fieldResult = Task.Call_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> lst = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            System.debug(f.getValue());
            lst.add(f.getValue());
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String>  getPickListValuesForCallType(){

        Schema.DescribeFieldResult fieldResult = Task.Call_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> lst = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            System.debug(f.getValue());
            lst.add(f.getValue());
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String>  getPickListValuesForSubject(){

        Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> lst = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            System.debug(f.getValue());
            lst.add(f.getValue());
        }
        System.debug('lst : '+lst.toString());
        return lst;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean checkAccount(String recordIdValue){
        if(recordIdValue != Null){
            List<Case> lstCase = [SELECT Id, Account.Id FROM Case where Id =:recordIdValue limit 1];
            if(lstCase[0].Account != Null)
            {
                return true;
            }
            return false;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean createCallLog(String recordId, Task objTask){
       // System.debug('recordId : '+recordId+'objTask : '+objTask.toString());
        if(recordId != Null){
            List<Case> lstCase = [SELECT Id, Account.Id FROM Case where Id =:recordId limit 1];

            if(lstCase.size() > 0){
                objTask.WhatId = lstCase[0].Account.Id;
                objTask.Status = 'Completed';
                Database.SaveResult slist= Database.insert(objTask);
                if(slist.success){
                    return true;
                }
                else{
                        for(Database.Error err : slist.getErrors()) {                  
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Partner Lead fields that affected this error: ' + err.getFields());
                        }
                        return false;
                }
            }
            return false;
        }
        return false;
    }
}