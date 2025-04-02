/**
 * @File Name          : WebServiceForClosedLost.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 7/3/2020, 5:46:45 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    2/8/2019, 4:38:21 PM   @BK     Initial Version
**/
global class WebServiceForClosedLost
{
    webservice static String MakeStudentClosedLost(id accountId,String FinalStatus,String AppendedStatus)
    {
        String LeadId;
        
        Set<String> setofEmail = new Set<String>();
        Set<String> setofMobile = new Set<String>();
        
        Account accountToBeMadeClosedLost = [select id,nm_LeadId__c,nm_RegistrationNumber__c ,nm_StudentStatus__c,PersonEmail ,PersonMobilePhone  from Account where id=:accountId];
       setofEmail.add(accountToBeMadeClosedLost.PersonEmail);
       setofEmail.add('reborn_'+accountToBeMadeClosedLost.PersonEmail);
      
       setofMobile.add(accountToBeMadeClosedLost.PersonMobilePhone);
       setofMobile.add(accountToBeMadeClosedLost.PersonMobilePhone+'0000');
       
       LeadId = accountToBeMadeClosedLost.nm_LeadId__c;
        //call method to insert Lead on Closed Lost
        List<Lead> lstLead =[select id from Lead Where (Not Status Like'%Fee paid%') and  (Id =:LeadId or Email =:setofEmail or MobilePhone =:setofMobile)   ];
        
        system.debug('lstLead-->'+lstLead);
        if(lstLead.size()>0)
        {
           System.debug('enter in loop of delete');
            delete lstLead;
        }
        InsertLeadOnClosedLost(accountId,FinalStatus);
        
        accountToBeMadeClosedLost.nm_RegistrationNumber__c = AppendedStatus+'_'+accountToBeMadeClosedLost.nm_RegistrationNumber__c;  
        accountToBeMadeClosedLost.nm_SecondryEmail__c = accountToBeMadeClosedLost.PersonEmail;
        accountToBeMadeClosedLost.PersonEmail =  AppendedStatus+'_'+ accountToBeMadeClosedLost.PersonEmail;
        accountToBeMadeClosedLost.PersonMobilePhone =  AppendedStatus+'_'+accountToBeMadeClosedLost.PersonMobilePhone;
        accountToBeMadeClosedLost.nm_StudentStatus__c=FinalStatus;
        accountToBeMadeClosedLost.Inactive_account__c = true;
        accountToBeMadeClosedLost.nm_LeadId__c='';
        update accountToBeMadeClosedLost;
      if(FinalStatus =='Rejected')
        {
              MakeStudentClosedLostForOtherSem(accountId,FinalStatus);
        }
      
        return 'success';  
    }
    webservice static String MakeStudentClosedLostForOtherSem(id accountId,String FinalStatus)
    {
      list<Opportunity> updateOpps = new List<Opportunity> ();
       list<Opportunity> lstoppo = [select id ,StageName,AccountID from Opportunity where accountid=:accountId];
       if(lstoppo.size()>0)
       {
           for (Opportunity objopps : lstoppo)
           {
               objopps.StageName = FinalStatus;
               updateOpps.add(objopps);
           }
       }
       if(updateOpps.size()>0)
       {
           update updateOpps;
           return 'success';
       }
       else{
           return 'error';
           }
    
     
        
    } 
    public static void InsertLeadOnClosedLost(id accountId,string FinalStatus)
    {
        Lead led = new Lead();
        List<Lead>  reverselead = new list<Lead>();
        for(Account acct : [select Id,nm_YearofCollegeCompletion__c,Other_Lead_Source__c,nm_Gender__c,nm_Category__c,nm_Specialization__c,Interview_Status__c,
        nm_YearofCompletion12__c,PersonLeadSource,nm_DiplomaYearOfCompletion__c,nm_YearofCompletion__c,nm_No_of_Months__c,nm_Domicile__c,nm_IncomeInLacs__c,Interview_Score__c,
        nm_WorkExperience__c,nm_Street__c,nm_NameofStateBoard10th__c,nm_StateProvince__c,nm_StreamDiploma__c,nm_LocalityName__c,Grad_Score__c,SSC_Score__c,
        nm_STDCode__c,nm_ResultDiploma__c,nm_NearestLandmark__c,nm_NameofUniversity__c,nm_NameofStateBoard12th__c,nm_Designation__c,
        nm_NameofBoard12__c,nm_NameofSchool__c,nm_NameofSchool12__c,nm_NameOfCollege__c,nm_NameofBoard__c,nm_Nationality__c,
        nm_DateOfBirth__c,nm_MaritialStatus__c,nm_CopyAddress__c,Percentage_Bachlor__c,nm_Country__c,
        Father_First_Name__c,Father_Last_Name__c,Mother_First_Name__c,Mother_Last_Name__c,nm_HouseNumber__c,nm_Stream__c,nm_SpouseName__c,nm_BachelorsDegreeName__c,nm_ChooseaProgram__c,
        nm_City__c,nm_DiplomaName__c,nm_Class12OrDiploma__c,nm_BloodGroup__c,nm_Qualification__c,HSCOrDiploma_Score__c,Work_exp_Score__c,
        nm_Batch_Name2__c,nm_12thPercentage__c,nm_10thPercentage__c,PersonMobilePhone,nm_Centers__c,IC_Zip_Postal_Code__c,
        LastName,PersonEmail,nm_RegistrationNumber__c ,nm_Program__c,FirstName from Account where Id =:accountId])
            {
             
                led.Old_Registration_Number__c= acct.nm_RegistrationNumber__c;
                led.Status = FinalStatus;
                led.nm_InformationCenter__c = acct.nm_Centers__c;
            // led.nm_DateOfBirth__c = '';
                led.Email= acct.PersonEmail;
                String mobileNo = acct.PersonMobilePhone;
                led.MobilePhone= mobileNo.right(10);
                led.FirstName= acct.FirstName;
                led.LastName= acct.LastName;
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
                led.nm_HouseNumber__c= acct.nm_HouseNumber__c;
              //  led.nm_MiddleName__c= acct.nm_MiddleName__c;
                led.Mother_First_Name__c = acct.Mother_First_Name__c;
                led.Mother_Last_Name__c = acct.Mother_Last_Name__c;
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
                led.nm_ChooseaProgram__c= acct.nm_ChooseaProgram__c;
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
                led.nm_PlantoStart__c ='2-3 Week';
                led.nm_OtherLeadSources__c =acct.Other_Lead_Source__c;
                reverselead.add(led);
            }
            if(reverselead.size()>0)
                {
                   insert reverselead ;
                }
    }
       
}