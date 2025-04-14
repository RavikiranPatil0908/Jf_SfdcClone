/**
 * @File Name          : CancelFutureHandler.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 10--04--2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/3/2019   shubhranshu     Initial Version
**/
public class CancelFutureHandler{

  /**
  * @description
  * @author shubhranshu | 9/17/2019
  * @param accountIds
  * @param RefundIds
  * @param lstOfExistingLead
  * @param appendedStudentStauts
  * @return void
  **/
 
  public static Map<String,String> mapOfAccountIdVsLeadId1 = new Map<String,String>();
  public static void CancelAdmission(Set<id> accountIds,Set<id> RefundIds , List<Lead> lstOfExistingLead,String appendedStudentStauts,String programType, String feeType)
  {    
    
          list<Lead> ledInsert = new list<Lead>();
          Set<String> setOfEmail = new Set<String>();
          Set<String> setOfMobile = new Set<String>();
          list<Account> lstAccount=new list<Account>();
          System.debug('accountIds '+accountIds+' RefundIds '+RefundIds+' lstOfExistingLead '+lstOfExistingLead+' appendedStudentStauts '+appendedStudentStauts);
          for(Account acct : [select Id,nm_StudentNo__c,Adhar_Card_Number__c,nm_YearofCollegeCompletion__c,nm_Gender__c,nm_Category__c,nm_Specialization__c,
           nm_YearofCompletion12__c,nm_DiplomaYearOfCompletion__c,nm_YearofCompletion__c,nm_No_of_Months__c,nm_Domicile__c,nm_IncomeInLacs__c,
           nm_WorkExperience__c,nm_Street__c,IC_Name_1__c,nm_NameofStateBoard10th__c,nm_StateProvince__c,nm_StreamDiploma__c,nm_LocalityName__c,
           nm_STDCode__c,nm_ResultDiploma__c,nm_NearestLandmark__c,nm_NameofUniversity__c,nm_StudentStatus__c,nm_NameofStateBoard12th__c,nm_Designation__c,
           nm_NameofBoard12__c,nm_NameofSchool__c,nm_NameofSchool12__c,nm_NameOfCollege__c,nm_NameofBoard__c,nm_Nationality__c,nm_StudentImageUrl__c,
           nm_DateOfBirth__c,nm_MaritialStatus__c,nm_CopyAddress__c,Percentage_Bachlor__c,nm_Country__c,
            nm_GraduationDegreeMode__c,Father_First_Name__c,Father_Last_Name__c,Father_Salutation__c,Mother_First_Name__c,Mother_Last_Name__c,Mother_Salutation__c,nm_HouseNumber__c,nm_Stream__c,nm_SpouseName__c,
           nm_City__c,nm_DiplomaName__c,nm_Class12OrDiploma__c,nm_BloodGroup__c,nm_Qualification__c,nm_BachelorsDegreeName__c,
           nm_Batch_Name2__c,nm_12thPercentage__c,nm_10thPercentage__c,PersonMobilePhone,nm_Centers__c,nm_Centers__r.nm_LearningCenter__c,IC_Zip_Postal_Code__c,Other_Lead_source__c,
           LastName,PersonEmail,nm_RegistrationNumber__c ,PersonLeadSource,nm_Program__c,FirstName,Interview_Status__c,Interview_Score__c,Grad_Score__c,
           SSC_Score__c,HSCOrDiploma_Score__c,Work_exp_Score__c,nm_ChooseaProgram__c,Reason__c,nm_Other_Reason__c, Zip_Postal_Code_Shipping__c, nm_DefencePersonnel__c,
           Shipping_Address_Choice__c, City_Shipping_Account__c, Shipping_Street__c, Locality_Name_Shipping__c, Nearest_LandMark_Shipping__c, House_No_Name_Shipping_Account__c,
           State_Province_Shipping__c, Country_Shipping__c,nm_EligiblityCriteria__c,nm_Centers__r.CenterName__c,nm_Centers__r.Name
               from Account where Id in: accountIds])
         {
            Lead led = new Lead();
             //strDuplicateEmail=acct.PersonEmail;
             System.debug('lstOfExistingLead '+lstOfExistingLead);
 
             // check for lstofexistinglead parameter is empty or not if yes then only create the lead else no lead creation !!!
             if(lstOfExistingLead.isEmpty()){
               led.Old_Registration_Number__c= acct.nm_RegistrationNumber__c;
               if(appendedStudentStauts == 'De-Registered'){
                 
               
                 if(feeType.containsIgnoreCase('MultipleSemFee') ||feeType.containsIgnoreCase('AnnualFee') ) {
                 
                   led.nm_Fee_Type__c = feeType;
                  
                   led.Status = 'Registration Fee Paid';
                   
                 } else {
                   led.nm_Fee_Type__c = null;
                   led.Status = appendedStudentStauts;
                   
                 }
                 // led.nm_StudentImageUrl__c = acct.nm_StudentImageUrl__c;
                 led.nm_Program__c = null;
                 led.Is_Lateral__c = true;
                 led.Student_Number_Lateral__c = acct.nm_StudentNo__c;
 
               } else {
                 led.Status = acct.nm_StudentStatus__c;
                 led.nm_Program__c = acct.nm_Program__c;
                 
               }
               led.nm_EligiblityCriteria__c = acct.nm_EligiblityCriteria__c;
               led.nm_InformationCenter__c = acct.PersonLeadSource !='Partner'?acct.nm_Centers__r.nm_LearningCenter__c:acct.nm_Centers__c;
               led.nm_DateOfBirth__c = acct.nm_DateOfBirth__c;
               led.Email= acct.PersonEmail.containsIgnoreCase('De-Registered_') ? acct.PersonEmail.split('egistered_')[1] :acct.PersonEmail;
               setOfEmail.add(led.Email);
               led.MobilePhone=acct.PersonMobilePhone.containsIgnoreCase('De-Registered_') ? acct.PersonMobilePhone.split('egistered_')[1] :acct.PersonMobilePhone;
               setOfMobile.add(led.MobilePhone);
               led.FirstName= acct.FirstName.deleteWhitespace();
               led.LastName= acct.LastName.deleteWhitespace();
               led.nm_10thPercentage__c= acct.nm_10thPercentage__c;
               led.nm_12thPercentage__c= acct.nm_12thPercentage__c;
               led.nm_BachelorsDegreePercentage__c= acct.Percentage_Bachlor__c;
               led.nm_BachelorsDegreeName__c= acct.nm_BachelorsDegreeName__c;
               led.nm_BloodGroup__c= acct.nm_BloodGroup__c;
               led.nm_City_P__c= acct.nm_City__c;
               led.nm_Class12OrDiploma__c= acct.nm_Class12OrDiploma__c;
               led.nm_DiplomaName__c= acct.nm_DiplomaName__c;
               led.Father_First_Name__c = acct.Father_First_Name__c;
               led.Father_Last_Name__c = acct.Father_Last_Name__c;
               led.Father_Salutation__c = acct.Father_Salutation__c;
               led.Mother_First_Name__c = acct.Mother_First_Name__c;
               led.Mother_Last_Name__c = acct.Mother_Last_Name__c;
               led.Mother_Salutation__c = acct.Mother_Salutation__c;
               led.nm_Gender__c= acct.nm_Gender__c;
               led.nm_GraduationDegreeMode__c= acct.nm_GraduationDegreeMode__c;
               led.nm_HouseNumber__c= acct.nm_HouseNumber__c;
              // led.nm_MiddleName__c= acct.nm_MiddleName__c !=null?acct.nm_MiddleName__c.deleteWhitespace():'';
               led.nm_NameofBoard__c= acct.nm_NameofBoard__c;
               led.nm_NameofBoard12__c= acct.nm_NameofBoard12__c;
               led.nm_NameOfCollege__c= acct.nm_NameOfCollege__c;
               led.nm_NameofSchool12__c= acct.nm_NameofSchool12__c;
               led.nm_NameofSchool__c= acct.nm_NameofSchool__c;
               led.nm_10thClassStateBoardName__c= acct.nm_NameofStateBoard10th__c;
               led.nm_12thClassStateBoardName__c= acct.nm_NameofStateBoard12th__c;
               led.nm_NameofUniversity__c= acct.nm_NameofUniversity__c;
               led.nm_NearestLandmark__c= acct.nm_NearestLandmark__c;
               led.Result_Diploma__c= acct.nm_ResultDiploma__c;
               led.State= acct.nm_StateProvince__c;
               led.nm_STDCode__c= acct.nm_STDCode__c;
               led.nm_Stream__c= acct.nm_Stream__c;
               led.nm_StreamDiploma__c= acct.nm_StreamDiploma__c;
               led.nm_Street_P__c= acct.nm_Street__c;
               led.nm_Total_Months_of_WorkExperience__c=acct.nm_No_of_Months__c;
               led.nm_WorkExperience__c= acct.nm_WorkExperience__c;
               led.nm_YearofCompletion__c= acct.nm_YearofCompletion__c;
               led.nm_YearofCompletion12__c= acct.nm_YearofCompletion12__c;
               led.nm_DiplomaYearOfCompletion__c= acct.nm_DiplomaYearOfCompletion__c;
               led.nm_YearofCollegeCompletion__c= acct.nm_YearofCollegeCompletion__c;
               led.Zip_Postal_Code_Shipping__c= acct.Zip_Postal_Code_Shipping__c;
               led.nm_PostalCode_P__c= acct.IC_Zip_Postal_Code__c;
               led.Are_you_from_Defence__c= acct.nm_DefencePersonnel__c  ;
                                             // led.Address = acct.BillingAddress;
               led.nm_Nationality__c = acct.nm_Nationality__c;
               led.nm_CopyAddress__c= acct.nm_CopyAddress__c;
             //  led.Is_Lateral__c= acct.Is_Lateral_c__c;
               led.nm_MaritalStatus__c= acct.nm_MaritialStatus__c;
               led.nm_SpouseName__c= acct.nm_SpouseName__c;
               led.nm_Category__c= acct.nm_Category__c;
               led.nm_Domicile__c= acct.nm_Domicile__c;
               led.nm_LocalityName__c= acct.nm_LocalityName__c;
               led.nm_Specialization__c= acct.nm_Specialization__c;
               led.nm_Street_P__c= acct.nm_Street__c;
               led.nm_City_P__c= acct.nm_City__c;
               led.nm_StateProvince_P__c= acct.nm_StateProvince__c;
               led.nm_Country_P__c= acct.nm_Country__c;
               led.nm_Qualification__c= acct.nm_Qualification__c;
               led.nm_Designation__c= acct.nm_Designation__c;
               led.nm_IncomeInLacs__c= acct.nm_IncomeInLacs__c;
               led.LeadSource= acct.PersonLeadSource;
               led.Adhar_Card_Number__c= acct.Adhar_Card_Number__c;
               led.nm_OtherLeadSources__c=acct.Other_Lead_source__c!=''?acct.Other_Lead_source__c:'';
               //led.nm_Publications__c=acct.nm_Publications__c !=''?acct.nm_Publications__c:'';
               //added for master's programs
               led.nm_ChooseaProgram__c = acct.nm_ChooseaProgram__c !='' ? acct.nm_ChooseaProgram__c : '';
               led.Is_Lead_Cancelled__c=true;
                                                                              
               //Score Details.
               led.Interview_Status__c=acct.Interview_Status__c;
               led.Interview_Score__c=acct.Interview_Score__c;
               led.Grad_Score__c = acct.Grad_Score__c;
               led.SSC_Score__c = acct.SSC_Score__c;
               led.HSCOrDiploma_Score__c = acct.HSCOrDiploma_Score__c;
               led.Work_exp_Score__c = acct.Work_exp_Score__c;
 
 
               // Address
               led.Shipping_Address_Choice__c = acct.Shipping_Address_Choice__c;
               led.Shipping_Street__c = acct.Shipping_Street__c;
               led.Locality_Name_Shipping__c = acct.Locality_Name_Shipping__c    ;
               led.Nearest_LandMark_Shipping__c  = acct.Nearest_LandMark_Shipping__c;
               led.House_No_Name_Shipping__c = String.isNotBlank(acct.House_No_Name_Shipping_Account__c) && acct.House_No_Name_Shipping_Account__c.length() <49 ? acct.House_No_Name_Shipping_Account__c : '';
               // led.Other_Country_Shipping__c  = acct.Other_Country_Shipping__c    ;
               led.State_Province_Shipping__c = acct.State_Province_Shipping__c  ;
               led.Country_Shipping__c = acct.Country_Shipping__c;
               led.Shipping_City__c = acct.City_Shipping_Account__c;
               led.nm_SelfLearningMaterial__c = 'Send to my shipping address';
 
 
 
               // if (programType != '') {
                 
                 
                 // }
                 if(appendedStudentStauts == 'De-Registered' && programType != null && programType != ''){
                   led.nm_ChooseaProgram__c = programType;
                   system.debug(led.nm_ChooseaProgram__c);
                   system.debug('#%#$#$#$#$');
                 } else {
                   
                   system.debug('#%#$#$#$#$ ' + acct.nm_ChooseaProgram__c );
                   led.nm_ChooseaProgram__c = acct.nm_ChooseaProgram__c;
             }
               led.Reason__c = acct.Reason__c;
               led.nm_Other_Reason__c = acct.nm_Other_Reason__c;
               led.OldAccount__c = acct.Id;
 
               // selected IC Value captured
               led.nm_SelectedIC__c= acct.IC_Name_1__c;
             }
             
             System.debug('led '+led);
             if(led != null){
               ledInsert.add(led);
             }
             if (String.isNotBlank(appendedStudentStauts)) {
                 List<String> lstStatus = new List<String>{'Rejected','De-Registered','Rusticated'};
                 acct.PersonMobilePhone = appendedStudentStauts+'_'+acct.PersonMobilePhone;
                 acct.nm_SecondryEmail__c = acct.PersonEmail;
                 acct.PersonEmail = appendedStudentStauts+'_'+acct.PersonEmail;
                 acct.nm_RegistrationNumber__c = appendedStudentStauts+'_'+acct.nm_RegistrationNumber__c;
                 if(lstStatus.contains(appendedStudentStauts)){
                     acct.nm_StudentStatus__c = appendedStudentStauts;
                 }
                 acct.Inactive_account__c = true;
                 acct.phone= appendedStudentStauts+'_'+acct.phone;
                 if(acct.nm_StudentNo__c!=null) {
                     acct.nm_StudentNo__c = appendedStudentStauts+'_'+acct.nm_StudentNo__c;
                 }
           }
 
             System.debug('acct to update'+acct);
             lstAccount.add(acct);
     }
     if(lstAccount.size()>0){
        try{
           update lstAccount;
           if (appendedStudentStauts == 'Cancel') {
             Set<Id> setOfAccAfterUpdate = new Set<Id>();
             for (Account acc : lstAccount) {
               setOfAccAfterUpdate.add(acc.Id);
             }
             for (Account objAcc : [SELECT Id, Name, PersonEmail, PersonMobilePhone, nm_RegistrationNumber__c, nm_Centers__c, nm_Centers__r.Name, nm_Centers__r.AEP_email_id__c, nm_Centers__r.LC_email__c FROM Account WHERE  Id IN :setOfAccAfterUpdate AND nm_StudentStatus__c LIKE '%Cancelled']) {
               if (String.isNotBlank(objAcc.nm_Centers__r.AEP_email_id__c) && String.isNotBlank(objAcc.nm_Centers__r.LC_email__c) ) {  
                // sendEmailToAepOnCancel(objAcc.Id, objAcc.Name,objAcc.PersonEmail, objAcc.PersonMobilePhone, objAcc.nm_RegistrationNumber__c, objAcc.nm_Centers__r.AEP_email_id__c, objAcc.nm_Centers__r.LC_email__c);
               } else {
                 system.debug('Aep Email Or Lc Email is null');
               }
             }
           }
         }catch(DmlException e){
           System.debug(e.getMessage());
         }
     }
 
     System.debug('ledInsert '+ledInsert);
     if(ledInsert.size()>0){
 
         try{
           insert ledInsert;
           System.debug('lead is inserted');
         }catch(DmlException e){
           System.debug(e.getMessage());
         }
      
         Set<String> setofAccountId = new Set<String>();
         Set<String> setOfLeadId = new Set<String>();
         Map<String,String> mapOfAccountIdVsLeadId = new Map<String,String>();
         for (Lead objLead : ledInsert) {
           if (String.isNotBlank(objLead.OldAccount__c)) {
               setOfLeadId.add(objLead.Id);
           }
         }
        List<Lead> leadInsert= [SELECT Id, Name, OldAccount__c FROM Lead WHERE Id IN :setOfLeadId];
     for (Lead objLead : leadInsert) {
           if (String.isNotBlank(objLead.OldAccount__c)) {
               setofAccountId.add(objLead.OldAccount__c);
               mapOfAccountIdVsLeadId.put(objLead.OldAccount__c,objLead.Id);
           }
         }

         mapOfAccountIdVsLeadId1.putAll(mapOfAccountIdVsLeadId);
         system.debug('setofAccountId --->'+setofAccountId +' mapOfAccountIdVsLeadId------->'+mapOfAccountIdVsLeadId);
         if(!setofAccountId.isEmpty() && !mapOfAccountIdVsLeadId.isEmpty()){
           insertLinkForDocument(setofAccountId,mapOfAccountIdVsLeadId);
           insertWorkExpereince(setofAccountId,mapOfAccountIdVsLeadId);
           insertStudentRating(setofAccountId,mapOfAccountIdVsLeadId);
         }
     }
     if(RefundIds !=null && RefundIds.size()>0 && ledInsert.size()>0)
     {
         list<nmRefund_Payment__c> lstRef=[select id,nm_Lead__c from nmRefund_Payment__c where Id in:RefundIds];
         for(nmRefund_Payment__c objRF:lstRef)
         {
             objRF.nm_Lead__c=ledInsert[0].id;
         }
         if(lstRef.size() >0){
           try{
             update lstRef;
           }catch(DmlException e){
             System.debug(e.getMessage());
           }
         }
     }
  
  }
 
    
     /**
     * @description insertLinkForDocument
     * @author shubhranshu | 11/5/2019 
     * @param setOfAccountId 
     * @param mapOfAccountIdVsLeadId 
     * @return void 
     **/
     public static void insertLinkForDocument(Set<String> setOfAccountId,Map<String,String> mapOfAccountIdVsLeadId) {
       List<nm_LinksForDocuments__c> lstlinkfordocument = [SELECT id,Name,nm_DocumentName__c,nm_Account__c,nm_URLforDocuments__c,nm_Status__c FROM nm_LinksForDocuments__c WHERE nm_Account__c IN :setOfAccountId AND (NOT Name LIKE '%WE-%' )];
       List<nm_LinksForDocumentsLead__c> lstDocumentLeadToInsert = new  List<nm_LinksForDocumentsLead__c>();
        
       if(lstlinkfordocument.size()>0 && mapOfAccountIdVsLeadId.size() > 0) {
         Boolean checkLinkExists = false;
         for (nm_LinksForDocuments__c objDoc : lstlinkfordocument)
         {
           nm_LinksForDocumentsLead__c objLeadDoc = new nm_LinksForDocumentsLead__c ();
           if(objDoc.nm_DocumentName__c == 'Photo ID proof' || objDoc.nm_DocumentName__c == 'Student Photograph') {
             objLeadDoc.nm_URLforDocuments__c = '';
             objLeadDoc.nm_Status__c = '';
           } else {
             objLeadDoc.nm_URLforDocuments__c = objDoc.nm_URLforDocuments__c;
             objLeadDoc.nm_Status__c = objDoc.nm_Status__c;
           }
           objLeadDoc.nm_DocumentName__c = objDoc.nm_DocumentName__c;
           objLeadDoc.Name = objDoc.Name;
           objLeadDoc.Lead__c = mapOfAccountIdVsLeadId.get(objDoc.nm_Account__c);
           lstDocumentLeadToInsert.add(objLeadDoc);
           checkLinkExists = objDoc.nm_URLforDocuments__c != null ? true : checkLinkExists;
         }
         if(checkLinkExists) {
           System.debug(lstDocumentLeadToInsert);
           if(lstDocumentLeadToInsert.size()>0) {
             try{
               insert lstDocumentLeadToInsert;
             }catch(DmlException e){
               System.debug(e.getMessage());
             }
           }
         } else {
           callInsertLinkFutureJob(setOfAccountId,mapOfAccountIdVsLeadId);
         }
         
       } else {
         callInsertLinkFutureJob(setOfAccountId,mapOfAccountIdVsLeadId);
       }
     }
 
     public static void callInsertLinkFutureJob(Set<String> setOfAccountId,Map<String,String> mapOfAccountIdVsLeadId) {
         //Queue class to insert linkfor Documents on Lead.
         String jsonOfAccountId = JSON.serialize(setOfAccountId);
         String jsonOfAccountIdVsLeadId = JSON.serialize(mapOfAccountIdVsLeadId);
         InsertLinkForDocuments insertLinkForDocument = new InsertLinkForDocuments(jsonOfAccountId,jsonOfAccountIdVsLeadId);
         
         // enqueue the job for processing
         Id jobID = System.enqueueJob(insertLinkForDocument);
         System.debug('jobID -->'+jobID);
     }
 
     public static String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
       Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
       Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
       List <String> fieldNames = new List <String> (fieldMap.keySet());
       if(relatedField !=null && relatedField !=''){
           fieldNames.add(relatedField);
       }
       String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
       return query;
     }
 
     
     /**
     * @description insertWorkExpereince
     * @author shubhranshu | 11/5/2019 
     * @param setOfAccountId 
     * @param mapOfAccountIdVsLeadId 
     * @return void 
     **/
     public static void insertWorkExpereince(Set<String> setOfAccountId, Map<String,String> mapOfAccountIdVsLeadId) {
         List<nm_WorkExperience__c> lstWorkEx = [SELECT nm_Student__c,nm_TotalMonths__c,nm_Lead__c,
             Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,
             nm_Other_Company_Name__c,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c FROM nm_WorkExperience__c WHERE nm_Student__c IN :setOfAccountId];
          system.debug('lstWorkEx--->'+lstWorkEx );
         if(lstWorkEx.size() > 0 && mapOfAccountIdVsLeadId.size() > 0) {
             List<nm_WorkExperience__c> lstWorkExClone = lstWorkEx.DeepClone();
             for (nm_WorkExperience__c WorkEx: lstWorkExClone) {
               WorkEx.nm_Lead__c = mapOfAccountIdVsLeadId.get(WorkEx.nm_Student__c);
               WorkEx.nm_Student__c = null;
             }
 
             try{
               insert lstWorkExClone;
             }catch(DmlException e){
               System.debug(e.getMessage());
             }
         }
     }
 
    
    
     /**
     * @description  insertStudentRating
     * @author shubhranshu | 11/5/2019 
     * @param setOfAccountId 
     * @param mapOfAccountIdVsLeadId 
     * @return void 
     **/
     public static void insertStudentRating(Set<String> setOfAccountId, Map<String,String> mapOfAccountIdVsLeadId) {
         List<Student_Rating__c> lstStudentRating = [SELECT Question_2_Student_Rating__c,Student__c,Question_1_Student_Rating__c,Interview_Date__c,
         Interviewer_Name__c,Question_4_Student_Rating__c,Logical_Reasoning_Data_Interpretation__c,Number_of_retakes__c,Question_3_Student_Rating__c,
         Quantitative_Aptitude__c,Q5_text__c,Report_URL__c,Status__c,Question_5_Student_Rating__c,Submitted_At__c,Test_Score__c,Time_Taken__c,
         Verbal_Reasoning__c,nm_Lead__c FROM Student_Rating__c WHERE Student__c IN :setOfAccountId];
 
         if(lstStudentRating.size() > 0 && mapOfAccountIdVsLeadId.size() > 0) {
             List<Student_Rating__c> lstStudentRatingClone = lstStudentRating.deepClone();
             for (Student_Rating__c StudentRating: lstStudentRatingClone) {
               StudentRating.nm_Lead__c = mapOfAccountIdVsLeadId.get(StudentRating.Student__c);
               StudentRating.Student__c = null;
             }
             try{
               insert lstStudentRatingClone;
             }catch(DmlException e){
               System.debug(e.getMessage());
             }
            
         }
     }
 
     public static void sendEmailToAepOnCancel(String leadId,String name, String email, String mobile, String regNo, String AepEmail, String LcEmail) {
       Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
       OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
       String url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + leadId;
       system.debug('url -----> ' + url);
       String[] sendingToAddress = new List<String>();
       if(System.Label.Environment == 'Sandbox') {
         sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
         sendingToAddress.add('dsuyog2013@gmail.com');
       } else if(System.Label.Environment == 'Production') {
         sendingToAddress.add(AepEmail);
       }
       String[] sendingToCCAddress = new List<String>();
       if(System.Label.Environment == 'Sandbox') {
         sendingToCCAddress.add('suyog.deshmukh.ext@nmims.edu');
         sendingToCCAddress.add('dsuyog2013@gmail.com');
       } else if(System.Label.Environment == 'Production') {
         sendingToCCAddress.add(LcEmail);
         sendingToCCAddress.add('ngasce.admission@nmims.edu');
       }
       semail.setToAddresses(sendingToAddress); 
       semail.setCcAddresses(sendingToCCAddress); 
       semail.setOrgWideEmailAddressId(owe.id); 
       // semail.setReplyTo('ngasce@nmims.edu'); 
       semail.setSubject(regNo + ' Account Cancellation Notification'); 
       String messageBody = '<html><p>Dear Team,</p>'
                                 +'<p>This is to notify you that the account of the candidate with registration number '+ regNo  +' has been cancelled. A new lead has been created with the same details and assigned to you (AEP):</p>'
                                 +'<p>Name: <a href="'+url+'" >'+ name  +'</a></p>'
                                 +'<p>Email-id: '+email+'</p>'
                                 +'<p>Mobile: '+mobile+'</p>'
                                 +'<p>Note: If there is a web lead with the same details (mobile and email-id) already existing in the database, then the new lead will NOT get inserted by default.</p>'
                                 +'<p>Thanks and Regards,</p>'
                                 +'<p>NMIMS CDOE - Admissions Team</p></html>';
         semail.setHtmlBody(messageBody);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
     }
 
 }