/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-10-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-10-2020   shubhranshu   Initial Version
**/
public without sharing class nmPrintPreviewController 
{
    public string Accountid {get;set;}
    public string objdate{get;set;}
    public string city{get;set;}
    public Opportunity objOpp{get;set;}
    public Account objAccount{get;set;}
    public String BatchName{get;set;}
    public string Url { get;set; }
    public list<nm_StudentProgram__c> lststuprogram{get;set;}
    public list<nm_WorkExperience__c> lstworkexpr{get;set;}
    
    public nmPrintPreviewController() 
    {      
        BatchName='' ;  
        objOpp =new Opportunity();   
        Accountid = apexpages.currentpage().getparameters().get('id');
        objdate = apexpages.currentpage().getparameters().get('date');
        city = apexpages.currentpage().getparameters().get('city');
         lstworkexpr =new list<nm_WorkExperience__c>();
        try
        {
                LoadData();       
        }
        catch(Exception ex)
        {
                system.debug('NRAC::::'+ex.getMessage());
        }
    }
     public string getQueryAllFieldSql(string SObjectAPIName,string conditionString,string relatedFields){
        Map<string,schema.SObjectType> scemapMap=schema.getGlobalDescribe();
        Map<string,schema.SObjectField> fieldMap=scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<string> fieldNames=new  List<string>(fieldMap.keySet());
        if(relatedFields!=null&&relatedFields!='')fieldNames.add(relatedFields);
        string query='Select '+string.join(fieldNames,',')+' from '+SObjectAPIName+' where '+conditionString;
        return query;
    }
    public void LoadData()
    {
        System.debug('Accountid--->'+Accountid);
        if(Accountid != null)
        {
            string AccountQueryString=getQueryAllFieldSql('Account',' id=:Accountid','nm_Centers__r.Name,nm_EligiblityCriteria__r.Name,nm_Program2__r.Name');
            List<Account> lstAccount =DataBase.query(AccountQueryString);
            if(lstAccount.size()>0)
            {
                Account objAccountLocal = lstAccount[0];
                
                System.debug('lstAccount-->'+lstAccount.size());
            
         /*   Account objAccountLocal = [Select a.nm_YearofCompletion__c, a.nm_YearofCompletion12__c, a.nm_YearofCollegeCompletion__c, PersonMobilePhone,PersonEmail,
                            a.nm_WorkExperience__c,a.nm_StudentImage__c, a.nm_StudentImageUrl__c, a.nm_Street__c, a.nm_Stream__c, a.nm_StreamDiploma__c,
                             a.nm_StateProvince__c, a.nm_SpouseName__c, a.nm_Specialization__c, a.nm_SerialNo__c, a.nm_SecondryEmail__c, 
                             a.nm_STDCode__c, a.nm_ResultDiploma__c,a.nm_Qualification__c, a.nm_PreviousInformationCenter__c, a.nm_PreStudentNo__c, a.nm_PostalCode__c,
                            a.nm_PostGraduationPercentage__c, a.nm_PostGraduateDegreeName__c, a.nm_PermanentAddress__c, a.nm_PGSpecialization__c,
                             a.nm_OtherCategory__c, a.nm_OtherBloodGroup__c, a.nm_NewProgram__c, a.nm_NearestLandmark__c, a.nm_NearestLandmark_P__c, 
                             a.nm_Nationality__c, a.nm_NameoftheBank__c, a.nm_NameofUniversity__c, a.nm_NameofSchool__c, a.nm_NameofSchool12__c, 
                             a.nm_NameofBoard__c, a.nm_NameofBoard12__c, a.nm_NameOfCollege__c, a.Mother_Name__c, a.nm_ModeOfPayment__c,
                              a.nm_MiddleName__c, a.nm_MaritialStatus__c, a.nm_LocalityName__c, a.nm_LocalityName_P__c, a.nm_LeadId__c,
                               a.nm_IsProvisonal__c, a.nm_HouseNumber__c, a.nm_HouseNumber_P__c, a.nm_GraduationPercentage__c,
                                a.nm_GraduationDegreeMode__c, a.nm_Gender__c, a.Father_Name__c, nm_EligiblityCriteria__r.Name,
                                 a.nm_DurationOfDiploma__c, a.nm_Domicile__c,  a.nm_DiplomaYearOfCompletion__c,nm_Centers__r.Name ,
                                  a.nm_DiplomaSchoolCollegeUniversityname__c, a.nm_DiplomaName__c, a.nm_Designation__c,
                                    a.nm_DateOfBirth__c, a.nm_Country__c, a.nm_Class12OrDiploma__c, a.nm_City__c,nm_RegistrationNumber__c,
                                    a.nm_CheckDuplicate__c, a.nm_Centers__c, a.nm_Category__c, a.nm_BloodGroup__c, a.nm_BankLocation__c,
                                     a.nm_BachelorsDegreeName__c, a.nm_AccountEmail__c, a.nm_12thPercentage__c, a.nm_10thPercentage__c,
                                     a.Salutation, a.RecordTypeId, a.Phone, a.PersonTitle, a.PersonOtherStreet, a.PersonOtherState,
                                         a.PersonAssistantName, a.Percentage_Bachlor__c, a.ParentId, a.OwnerId, a.NumberOfEmployees, 
                                           a.LastName, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate,a.nm_StudentNo__c,
                                                a.FirstName,a.BillingStreet, a.BillingState, a.BillingPostalCode,a.nm_Batch_Name2__c,
                                                 a.BillingCountry, a.BillingCity From Account a where id=: Accountid];*/
                                                 
            lstworkexpr=[select id,nm_CompanyName__c,nm_TotalMonths__c,nm_OtherNatureExperience__c,nm_NatureofExperience__c,nm_Designation__c,nm_CompanyAddress__c,nm_TotalPay__c,Total_Work_Experience__c,nm_StartDate__c,nm_EndDate__c,Industry__c,Department__c from nm_WorkExperience__c where nm_Student__c = : Accountid];

           /* objOpp=[select nm_Session__c,nm_Year__c from Opportunity where AccountId=:Accountid and nm_Semester__c='1'];                 
            if(lstworkexpr.size() == 0)
            {
                nm_WorkExperience__c objworkexpr = new nm_WorkExperience__c();
                lstworkexpr.add(objworkexpr );
            }
            */
            
            lststuprogram = [select nm_EligiblityCriteria__r.Name, nm_EligiblityCriteria__r.nm_EligiblityCriteria__c, nm_Program__r.Name 
                            from nm_StudentProgram__c where nm_Student__c =: Accountid];
            if(lststuprogram.size() == 0)
            {
                nm_StudentProgram__c objstuprogram = new nm_StudentProgram__c ();
                lststuprogram.add(objstuprogram );
            }
               
            if(objAccountLocal.nm_Batch_Name2__c=='Awaiting')
            {
                BatchName =objOpp.nm_Session__c + objOpp.nm_Year__c ;
            }
            else
            {
                BatchName =objAccountLocal.nm_Batch_Name2__c;
                Url = objAccountLocal.nm_StudentImageUrl__c;
            }   
             objAccount = objAccountLocal.clone();
           }
        }
    }
}