/**
 * @File Name          : nmValidateLeadWebService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 06-11-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    21/9/2019   @BK     Initial Version
**/
global class nmValidateLeadWebService 
{  
   @AuraEnabled
   webService static String ValidateLead(String strLeadId) 
   {
      string x = ValidateLeadField(strLeadId);
      System.debug('x+++'+x);
      if(x == 'true') {
         return null;
      } else {
         return x;
      }
   }

   private static Map<String,String> mapOfFieldVsMsg = new Map<String,String>{
      'Salutation'  => 'Please select an Salutation.',
      'FirstName' => 'Please provide FirstName.',
      'LastName' => 'Please provide LastName.',
      'nm_DateOfBirth__c' => 'Date of Birth cannot be less than 17 years',
      'nm_Gender__c' => 'Please provide Gender.',
      'nm_MaritalStatus__c' => 'Please provide Marital Status.',
      'nm_BloodGroup__c' => 'Please provide Blood Group.',
      'nm_Category__c' => 'Please provide Category.',
      'nm_Nationality__c' => 'Please provide Nationality.',
      'nm_Domicile__c' => 'Please provide Domicile.',
      'nm_HouseNumber__c' => 'Please provide House Number.',
      'City' => 'Please provide City Name.',
      'State' => 'Please provide State Name.',
      'PostalCode' => 'Please provide PostalCode.',
      'Country' => 'Please provide Country Name.',
     // 'nm_Class12OrDiploma__c' => 'Please select class 12 or Diploma.',
      'nm_10thPercentage__c' => 'Please provide 10th Percentage.',
      'nm_NameofSchool__c' => 'Please provide name of school.',
      'nm_NameofBoard__c' => 'Please provide Name of Board.',
      'nm_YearofCompletion__c' => 'Please provide year of completion of 10th class.',
      'nm_HouseNumber_P__c' => 'Please provide House Number.',
      'nm_City_P__c' => 'Please provide City Name.',
      'nm_StateProvince_P__c' => 'Please provide State Name.',
      'nm_PostalCode_P__c' => 'Please provide Postal Code.',
      'nm_Country_P__c' => 'Please provide Country Name.',
      'House_No_Name_Shipping__c' => 'Please provide Shipping House Number.',
      'Shipping_City__c' => 'Please provide Shipping City Name.',
      'State_Province_Shipping__c' => 'Please provide correct Shipping State Name.',
      'Zip_Postal_Code_Shipping__c' => 'Please provide Shipping Postal Code.',
      'Country_Shipping__c' => 'Please provide correct Shipping Country Name.',
      'Father_First_Name__c' => 'Please provide Father First Name.',
      'Father_Last_Name__c' => 'Please provide Father Last Name.',
      'Father_Salutation__c' => 'Please provide Father Salutation.',
      'Mother_First_Name__c' => 'Please provide Mother First Name.',
      'Mother_Last_Name__c' => 'Please provide Mother Last Name.',
      'Mother_Salutation__c' => 'Please provide Mother Salutation.',
      'MobilePhone' => 'Kindly provide 10 digit mobile number',
      'nm_EligiblityCriteria__c' => 'Please select an Eligibility.'
   };

   private static Map<String,String> mapOfHSCFieldVsMsg = new Map<String,String>{
      'nm_Stream__c' => 'Please provide Stream',
      'nm_NameofSchool12__c' => 'Please provide name of school.',
      'nm_NameofBoard12__c' => 'Please provide Name of 12 th Board.',
      'nm_12thPercentage__c' => 'Please provide 12th Percentage.',
      'nm_YearofCompletion12__c' => 'Please provide year of completion of 12th.',
      'nm_12thClassStateBoardName__c' => 'Please provide name of 12th class state board.'
   };

   private static Map<String,String> mapOfDefenceFieldVsMsg = new Map<String,String>{
      'nm_ServiceNumber__c' => 'Please provide Service Number.',
      'Relationship__c' => 'Please provide Relationship.',
      'nm_DateofCommission__c' => 'Please provide Date of Commission.',
      'Armed_Service__c' => 'Please provide Armed Service.',
      'Rank__c' => 'Please provide Rank.'
   };

   private static Map<String,String> mapOfDiplomaFieldVsMsg = new Map<String,String>{
      'nm_DiplomaName__c' => 'Please provide Diploma Name.',
      'nm_StreamDiploma__c' => 'Please provide stream of diploma',
      'nm_DiplomaSchoolCollegeUniversityname__c' => 'Please provide diploma school college university name',
      'Result_Diploma__c' => 'Please result of diploma.',
      'nm_DurationOfDiploma__c' => 'Please provide Diploma Duration.',
      'nm_DiplomaYearOfCompletion__c' => 'Please provide year of completion of diploma'
   };

   private static Map<String,String> mapOfEligibilityFieldVsMsg = new Map<String,String>{ 
      'nm_BachelorsDegreePercentage__c' => 'Please provide Bachelors Degree Percentage.',
      'nm_BachelorsDegreeName__c' => 'Please provide Bachelors Degree Name.',
      'nm_NameOfCollege__c' => 'Please provide name of college.',
      'nm_NameofUniversity__c' => 'Please provide name university.',
      'nm_Specialization__c' => 'Please provide name Specialization.',
      'nm_YearofCollegeCompletion__c' => 'Please provide diploma year of college',
      'nm_GraduationDegreeMode__c' => 'Please provide Graduation Degree Mode.'
   };

   private static Set<String> setOfNoneValCheck = new Set<String>{'State','Country','nm_StateProvince_P__c','nm_Country_P__c','State_Province_Shipping__c','Country_Shipping__c'};

   static String ValidateLeadField(String leadId) {
      String strmsg = 'true';        
      String strQuery = 'SELECT nm_Program__r.Name';
         
      Map<String, Schema.SObjectField> mapOfLeadObjFields = Schema.SObjectType.Lead.fields.getMap();
      for(String fName : mapOfLeadObjFields.keyset()) {
         if(fName != 'address'){
            strQuery = strQuery + ',' + fName; 
         } 
      }

      strQuery = strQuery + ' FROM Lead WHERE id=:leadId';
      List<Lead> lstLead = Database.query(strQuery); 

      if(lstLead.size() > 0) {
         System.debug('lstLead.size() ===>'+lstLead.size());
         Lead objLead = lstLead[0];

         // All Fields Validation
         for(String fieldKey : mapOfFieldVsMsg.keySet()) {
            if(objLead.get(fieldKey) == null || (setOfNoneValCheck.contains(fieldKey) && objLead.get(fieldKey) == 'None')) {
               System.debug('fieldKey Error ===>'+fieldKey);
               return mapOfFieldVsMsg.get(fieldKey);
            }
            
            // To check for date for birth
            if(fieldKey.equalsIgnoreCase('nm_DateOfBirth__c')) {
               Integer days = lstLead[0].nm_DateOfBirth__c.daysBetween(Date.Today());
               Integer age = Integer.valueOf(days/365);
               if(age < 17) {
                  return 'Date of Birth cannot be less than 17 years';               
               }
            }

            // To check if Mobile Phone validate
            if(fieldKey.equalsIgnoreCase('MobilePhone')) {
               String mobile = objLead.MobilePhone;
               if(mobile.length() < 10 || mobile.length() > 10) {
                   return 'Kindly provide 10 digit mobile number';
               }
            }

         }

         // Additional fields Vaalidations
         
         // #1 Lateral Field Validations
         if(objLead.Is_Lateral__c) {
            if(objLead.Student_Number_Lateral__c == null) {
               return 'Please Enter lateral student Number';
            }    
         } 

         // #2 10th Fields Validation
         if(objLead.nm_10thClassStateBoardName__c == null && objLead.nm_NameofBoard__c.equalsIgnoreCase('State Boards/Others')) {
            return 'Please provide name of 10th class state board.';
         }

         // #3 Permanent Address Validations
         if(objLead.State_Province_Shipping__c.equalsIgnoreCase('Other')) {               
            return 'Please provide correct Shipping State Name.';               
         }
         
         // #4 Permanent Address Validations
         if(objLead.Country_Shipping__c.endsWithIgnoreCase('Other')) {               
            return 'Please provide correct Shipping Country Name.';               
         }

         //12th Fields Validation

         // if(lstLead[0].nm_Class12OrDiploma__c == 'XII/HSC' && (String.isBlank(lstLead[0].HSC_status__c) || lstLead[0].HSC_status__c == 'Passed')) {
         //    for(String fieldKey : mapOfHSCFieldVsMsg.keySet()) {
         //       if( objLead.get(fieldKey) == null && ( !fieldKey.equalsIgnoreCase('nm_12thClassStateBoardName__c') 
         //          || (fieldKey.equalsIgnoreCase('nm_12thClassStateBoardName__c') && objLead.nm_NameofBoard12__c == 'State Boards/Others')) ) {
         //          return mapOfHSCFieldVsMsg.get(fieldKey);
         //       }
         //    }
         // }

         //Defence Fields Validation
         if(objLead.Are_you_from_Defence__c == 'Yes') {
            for(String fieldKey : mapOfDefenceFieldVsMsg.keySet()) {
               if(objLead.get(fieldKey) == null) {
                  return mapOfDefenceFieldVsMsg.get(fieldKey);
               }
            }
         }


         // Diploma Fields Validation
         // if(objLead.nm_Class12OrDiploma__c=='Diploma') {
         //    for(String fieldKey : mapOfDiplomaFieldVsMsg.keySet()) {
         //       if(objLead.get(fieldKey) == null) {
         //          return mapOfDiplomaFieldVsMsg.get(fieldKey);
         //       }
         //    }
         // }

         // For Graduation Fields Validation
         if(objLead.nm_EligiblityCriteria__c != null) {
            nm_EligiblityCriteria__c objElig = [SELECT id,Graduation_Required__c,HSC_Re__c,Diploma_Required__c FROM nm_EligiblityCriteria__c WHERE id=:objLead.nm_EligiblityCriteria__c];
           
            if(objElig.Graduation_Required__c) {
               for(String fieldKey : mapOfEligibilityFieldVsMsg.keySet()) {
                  if(objLead.get(fieldKey) == null) {
                     return mapOfEligibilityFieldVsMsg.get(fieldKey);
                  }
               }
            }
          if(objElig.HSC_Re__c){
               for(String fieldKey : mapOfHSCFieldVsMsg.keySet()) {
                  if(objLead.get(fieldKey) == null) {
                     return mapOfHSCFieldVsMsg.get(fieldKey);
                  }
               }
            }
            if(objElig.Diploma_Required__c){
               for(String fieldKey : mapOfDiplomaFieldVsMsg.keySet()) {
                  if(objLead.get(fieldKey) == null) {
                     return mapOfDiplomaFieldVsMsg.get(fieldKey);
                  }
               }

            }
         }
         
      }
      System.debug('strmsg ==>'+strmsg);
      return strmsg;
   }
}