/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-21-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class GenerateRegistrationNoBatchTracker {

    @testSetup
    public static void setUpData(){
        // nmGenericTracker.CreateCalender();
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Calender__c objCal = new Calender__c();
        objCal.Category__c = 'Admission';
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2021;
        objCal.Session_End_Date__c = system.today()+1;
        insert objCal;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_Year__c = 2021;
        objLead.nm_RegistrationNo__c = null;
        objLead.nm_RegistrationID__c = null;
        update objLead;
    }

    @isTest
    static void unitTest1() {
        Test.startTest();
            GenerateRegistrationNoBatch instance = new GenerateRegistrationNoBatch();
            Database.executeBatch(instance,50);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Test.startTest();
            GenerateRegistrationNoBatch instance = new GenerateRegistrationNoBatch();
            Database.executeBatch(instance,50);
            
            Lead objLead = [SELECT id,nm_RegistrationNo__c,nm_RegistrationID__c,Email,MobilePhone,nm_PlantoStart__c FROM Lead];
            Lead objLeadClone = createLead();
            objLeadClone.nm_RegistrationID__c = objLead.nm_RegistrationID__c;
            update objLeadClone;
            Database.executeBatch(instance,50);
        Test.stopTest();
    }

    public static Lead createLead() {
        nm_Program__c objProgram = nmGenericTracker.CreatePGDiplomaProgram();
        nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai - vashi');
        nm_EligiblityCriteria__c objEc = nmGenericTracker.CreateElegibilityCriteriaforMaster(objProgram.nm_Type__c);

        Lead objLead = new  Lead();
        objLead.nm_SelectedIC__c ='Mumbai';
         objLead.nm_Program__c=objProgram.id;
         objLead.Salutation='Mr';
         objLead.nm_DateOfBirth__c = date.newInstance(1990, 12, 9);
         objLead.nm_Semester__c = '1';
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
         objLead.Father_Salutation__c='Mr.';
         objLead.Mother_Salutation__c='Ms.';
         objLead.Mother_Last_Name__c='test';
         objLead.status='Reborn';
         objLead.nm_Class12OrDiploma__c ='XII/HSC';
         objLead.nm_Class12OrDiploma__c='Diploma';
         objLead.Email='amitq.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985711';
         objLead.City='noida';
         objLead.nm_Stream__c='hgfgc';
         objLead.nm_Gender__c = 'Male';
         objLead.nm_ChooseaProgram__c =objProgram.nm_Type__c;
         objLead.nm_EligiblityCriteria__c = objEc.id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_NameofBoard12__c='hvh';
         objLead.nm_SelectedProgram__c ='ccc';
         objLead.nm_InformationCenter__c =objCen.id;
         objLead.OwnerId= objCen.OwnerId;
         objLead.nm_Year__c =2017;
         objLead.LeadSource ='Web';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=3;
         objLead.nm_MaritalStatus__c ='Married';
         objLead.nm_Nationality__c='Indian';
       // objLead.nm_FathersName__c='test';
         objLead.Father_First_Name__c='hgvghv';
        objLead.Mother_First_Name__c ='cfgcfg';
       // objLead.nm_MothersName__c='test';
        objLead.nm_BloodGroup__c='test';
        objLead.nm_LocalityName__c='test';
        objLead.nm_Domicile__c='test';
        objLead.PostalCode='123456';
        objLead.nm_NearestLandmark__c='test';
        objLead.State='Goa';
        objLead.Country='India';
        objLead.Street='test';
        objLead.nm_Category__c='General';
        objLead.nm_12thClassStateBoardName__c='dsfd';
        objLead.nm_10thClassStateBoardName__c='ghftf';
        objLead.nm_10thPercentage__c=77.00;
        objLead.nm_12thPercentage__c =66.00;
        objLead.nm_NameofSchool__c='test';
        objLead.nm_NameofSchool12__c='test';
        objLead.nm_NameofBoard__c='CBSE';
        objLead.nm_YearofCompletion__c='2014';
        objLead.nm_DiplomaName__c='test';
        objLead.nm_StreamDiploma__c='test';
        objLead.nm_DiplomaSchoolCollegeUniversityname__c='test';
        objLead.Result_Diploma__c=6;
        objLead.nm_DurationOfDiploma__c=8;
        objLead.nm_DiplomaYearOfCompletion__c=2014;
        objLead.nm_HouseNumber_P__c='2';
        objLead.nm_YearofCompletion12__c='1';
        objLead.nm_Street_P__c='test';
        objLead.nm_City_P__c='test';
        objLead.nm_StateProvince_P__c='test';
        objLead.nm_PostalCode_P__c='400049';
        objLead.nm_Country_P__c='India';
        objLead.Father_Last_Name__c='fgcff';
        objLead.nm_LocalityName_P__c='test';
        objLead.nm_NearestLandmark_P__c='test';
        objLead.House_No_Name_Shipping__c='2';
        objLead.Shipping_Street__c='test';
        objLead.Shipping_City__c='test';
        objLead.State_Province_Shipping__c='test';
        objLead.Zip_Postal_Code_Shipping__c='400043';
        objLead.Country_Shipping__c='India';
        objLead.Locality_Name_Shipping__c='test';
        objLead.Nearest_LandMark_Shipping__c ='test';
        objLead.Are_you_from_Defence__c ='Yes';
        objLead.nm_ServiceNumber__c ='test';
        objLead.Relationship__c ='self';
        objLead.nm_DateofCommission__c =System.today();
        objLead.Armed_Service__c ='test';
        objLead.Rank__c ='test';
        objLead.nm_HouseNumber__c='2';
        objLead.Is_Lateral__c = true;
        objLead.nm_Street_P__c='test';
        objLead.nm_RegistrationID__c='a0BN0000001FUdB';
        objLead.Have_you_ever_registered_with_us_before__c = 'No';
        objLead.smsSendTime__c = system.now();
        objLead.Sms_Status__c = 'Success';
        objLead.Student_Plan_to_Start__c ='1 week';
        objLead.Reason_for_not_joining__c = 'Looking for full time course only';
        objLead.Other_Reason_for_not_joining__c = 'Test';
        objLead.Student_Define_Date_Time__c = null;      
        insert objLead;
        return objLead;
    }
}