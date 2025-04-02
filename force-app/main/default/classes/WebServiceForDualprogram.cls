/**
 * @File Name          : WebServiceForDualprogram.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 30/3/2020, 6:10:51 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/3/2020   shubhranshu     Initial Version
**/
global class WebServiceForDualprogram
{   
    @AuraEnabled
    webservice static String StudentInfo(id accountId,string Mobilephone,String email,string chooseprogram,id eligibility ,id program)
    {
        String LeadId;
        Account accountToBeMadeClosedLost = [select id,nm_LeadId__c,nm_RegistrationNumber__c ,nm_StudentStatus__c,PersonEmail ,PersonMobilePhone  from Account where id=:accountId];
        List<Lead> lstLead = new List<Lead>();
       /* if(chooseprogram =='Certificate Programs')      
        {
              lstLead =[select id, Name from Lead where IsConverted = true and (MobilePhone =:Mobilephone or Email =:email)and Status!='Registration Fee Paid' and Status!='Admission Fee Paid' and nm_ChooseaProgram__c ='Certificate Programs'];
              system.debug('lstLead--->'+lstLead );
        }*/
       
              lstLead =[select id, Name from Lead where IsConverted = false and (MobilePhone =:Mobilephone or Email =:email)and Status!='Registration Fee Paid' and Status!='Admission Fee Paid'];
         system.debug('lstLead--->'+lstLead );
       
             
        if(lstLead.size()>0)
        {
           System.debug('enter in loop of delete');
            delete lstLead;
        }
        
       string result = InsertLeadOnClosedLost(accountId,chooseprogram,eligibility,program);
        
       
       
        return result;  
    }
  
      public static String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
    public static string InsertLeadOnClosedLost(id accountId,string chooseprogram,id eligibility ,id program)
    {
        Lead led = new Lead();
        List<Lead>  reverselead = new list<Lead>();
        
           String accQueryString = getQueryAllFieldSql('Account',' id=:accountId',null);
        List<Account> lstAccount = DataBase.query(accQueryString);
        for(Account acct:lstAccount)
       
            {
             
             led.Old_Registration_Number__c= acct.nm_RegistrationNumber__c;
            // led.Status ='Closed Lost';
             led.nm_InformationCenter__c = acct.nm_Centers__c;
            // led.nm_DateOfBirth__c = '';
             led.Email= acct.PersonEmail;
             led.MobilePhone= acct.PersonMobilePhone;
                    led.FirstName = acct.FirstName;
            led.LastName = acct.LastName;
            led.Salutation = acct.Salutation;
            led.Email = acct.PersonEmail;
            led.MobilePhone = acct.PersonMobilePhone;
            //  led.nm_SelectedIC__c = acct.IC_Name_1__c;
            led.nm_Gender__c = acct.nm_Gender__c;
            led.LeadSource = acct.PersonLeadSource;
            led.Father_Salutation__c = acct.Father_Salutation__c;
            led.Father_First_Name__c = acct.Father_First_Name__c;
            led.Father_Last_Name__c = acct.Father_Last_Name__c;
            led.Mother_Salutation__c = acct.Mother_Salutation__c;
            led.Mother_First_Name__c = acct.Mother_First_Name__c;
            led.Mother_Last_Name__c = acct.Mother_Last_Name__c;
            led.nm_MaritalStatus__c = acct.nm_MaritialStatus__c;
            led.nm_SpouseName__c = acct.nm_SpouseName__c;
            led.Adhar_Card_Number__c = acct.Adhar_Card_Number__c;
            led.nm_BloodGroup__c = acct.nm_BloodGroup__c;
            led.nm_Category__c = acct.nm_Category__c;
            led.nm_Nationality__c = acct.nm_Nationality__c;
            led.nm_Domicile__c = acct.nm_Domicile__c;
            led.Zip_Postal_Code_Shipping__c = acct.Zip_Postal_Code_Shipping__c;
            led.Shipping_City__c = acct.City_Shipping_Account__c;
            led.State_Province_Shipping__c = acct.State_Province_Shipping__c;
            led.House_No_Name_Shipping__c = acct.House_No_Name_Shipping_Account__c;
            led.Shipping_Street__c = acct.Shipping_Street__c;
            led.Locality_Name_Shipping__c = acct.Locality_Name_Shipping__c;
            led.Country_Shipping__c = acct.Country_Shipping__c;
            led.Nearest_LandMark_Shipping__c = acct.Nearest_LandMark_Shipping__c;
            led.nm_SecondryEmail__c = acct.nm_SecondryEmail__c;
            led.PostalCode = acct.BillingPostalCode ;
            led.nm_HouseNumber__c = acct.nm_HouseNumber__c ;
            led.nm_LocalityName__c = acct.nm_LocalityName__c ;
            led.Street = acct.BillingStreet ;
            led.nm_NearestLandmark__c = acct.nm_NearestLandmark__c ;
            led.nm_PostalCode_P__c = acct.nm_PostalCode__c ;
            led.nm_HouseNumber_P__c = acct.nm_HouseNumber_P__c ;
            led.nm_Street_P__c = acct.nm_Street__c ;
            led.nm_LocalityName_P__c = acct.nm_LocalityName_P__c ;
            led.nm_NearestLandmark_P__c = acct.nm_NearestLandmark_P__c ;
            led.nm_SelfLearningMaterial__c = 'Send to my shipping address';
            led.Are_you_from_Defence__c = acct.nm_DefencePersonnel__c ;
            led.nm_ServiceNumber__c = acct.nm_ServiceNumber__c ;
            led.Relationship__c = acct.nm_Relationship__c ; 
            led.Armed_Service__c = acct.nm_ArmedService__c ;
            led.Rank__c = acct.Rank__c ;
            led.Student_Number_Lateral__c = acct.nm_StudentNo__c ;
            led.nm_10thPercentage__c = acct.nm_10thPercentage__c;
            led.nm_YearofCompletion__c = acct.nm_YearofCompletion__c;
            led.nm_NameofSchool__c = acct.nm_NameofSchool__c;
            led.nm_Class12OrDiploma__c = acct.nm_Class12OrDiploma__c;
            led.nm_NameofBoard__c = acct.nm_NameofBoard__c;
            led.nm_12thPercentage__c = acct.nm_12thPercentage__c;
            led.nm_NameofBoard12__c = acct.nm_NameofBoard12__c;
            led.nm_YearofCompletion12__c = acct.nm_YearofCompletion12__c;
            led.nm_NameofSchool12__c = acct.nm_NameofSchool12__c;
            led.nm_Stream__c = acct.nm_Stream__c;
            led.Result_Diploma__c = acct.nm_ResultDiploma__c;
            led.nm_DiplomaSchoolCollegeUniversityname__c = acct.nm_DiplomaSchoolCollegeUniversityname__c;
            led.nm_DiplomaYearOfCompletion__c = acct.nm_DiplomaYearOfCompletion__c;
            led.nm_DiplomaName__c = acct.nm_DiplomaName__c;
            led.nm_StreamDiploma__c = acct.nm_StreamDiploma__c;
            led.nm_DurationOfDiploma__c = acct.nm_DurationOfDiploma__c;
            led.nm_StudentImageUrl__c =acct.nm_StudentImageUrl__c;
            led.Agency__c= acct.Agency__c!=null?acct.Agency__c:'Direct';
            led.nm_NameofUniversity__c = acct.nm_NameofUniversity__c; 
            led.nm_BachelorsDegreeName__c = acct.nm_BachelorsDegreeName__c; 
            led.nm_Specialization__c = acct.nm_Specialization__c; 
            led.nm_NameOfCollege__c = acct.nm_NameOfCollege__c; 
            led.nm_BachelorsDegreePercentage__c = acct.Percentage_Bachlor__c; 
            led.nm_GraduationDegreeMode__c = acct.nm_GraduationDegreeMode__c; 
            led.nm_YearofCollegeCompletion__c = acct.nm_YearofCollegeCompletion__c; 
   
   

   
   

                /* led.FirstName= acct.FirstName;
                 led.LastName= acct.LastName;
                 led.nm_10thPercentage__c= acct.nm_10thPercentage__c;
                 led.nm_12thPercentage__c= acct.nm_12thPercentage__c;
                 led.nm_BachelorsDegreePercentage__c= acct.Percentage_Bachlor__c;
                 led.nm_BachelorsDegreeName__c= acct.nm_BachelorsDegreeName__c;
                 led.nm_BloodGroup__c= acct.nm_BloodGroup__c;
                 led.nm_City_P__c= acct.nm_City__c;
                 led.nm_Class12OrDiploma__c= acct.nm_Class12OrDiploma__c;
                 led.nm_DiplomaName__c= acct.nm_DiplomaName__c;
                 led.nm_FathersName__c= acct.nm_FathersName__c;
                 led.nm_HouseNumber__c= acct.nm_HouseNumber__c;
                 led.nm_MiddleName__c= acct.nm_MiddleName__c;
                 led.nm_MothersName__c= acct.nm_MothersName__c; 
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
                 led.nm_StateProvince_P__c= acct.nm_StateProvince__c;
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
                 led.nm_PostalCode_P__c= acct.IC_Zip_Postal_Code__c;
                 led.nm_Nationality__c = acct.nm_Nationality__c;
                 led.nm_CopyAddress__c= acct.nm_CopyAddress__c;
                 led.Is_Lateral__c= acct.Is_Lateral_c__c;
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
                 led.LeadSource = acct.PersonLeadSource;
                 led.nm_OtherLeadSources__c =acct.Other_Lead_Source__c;*/
                 led.nm_ChooseaProgram__c=chooseprogram;
                 led.DualProgram__c = true;
                 led.nm_Program__c = program;
                 led.nm_EligiblityCriteria__c = eligibility;
                 reverselead.add(led);
            }
           
                  // insert reverselead ;
                   if (reverselead.size() > 0){
                        System.debug('Create Lead '+reverselead);
                        Database.saveResult[] rslt=Database.Insert(reverselead, false);
                        for(Database.saveResult r: rslt){
                            if(r.isSuccess()){
                                id resultvalue = r.getId();
                                System.debug(r.getId());
                                return String.valueof(resultvalue);
                            }
                            else{
                                  for(Database.Error err : r.getErrors()){
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('lead fields that affected this error: ' + err.getFields());
                                    return String.valueof(err.getMessage());
                                }
                            }
                        }
               }
               return null;
                
    }
}