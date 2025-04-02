/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-09-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class ConnecToHelperClassTracker {


    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[{"Response":"success","ScheduleTime":"2023-05-13 12:45:00","campaign_name":"Test_Campaign","PhoneNumber":"8800000000","Name":"Bala","AgentID":null,"skill":"TEST","msg":"Data updated successfully","rowId":"2561154","index":0}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

	@testSetup
    public static void setUpData(){ 

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
		insert objUser;


		Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nm_Centers__c obj = nmGenericTracker.CreateCenter('Banglore');
		obj.RegistrationClosed__c = false;
		obj.Name = 'Banglore';
		update obj;
		nmGenericTracker.CreateICAndUser2(obj);
		Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

		// insert Connecto
		Connecto__c objConnecto=new Connecto__c();
		objConnecto.Email_ID__c = 'sagar.phadtare93@gmail.com';
		objConnecto.OwnerID = objUser.id;
		objConnecto.Mobile_Number__c = '9987226106';
		objConnecto.City__c = obj.Name;
		insert objConnecto;
	}

	@isTest
    static void testUnit1() { 
		Lead objLead = [SELECT id,MobilePhone,Email FROM Lead LIMIT 1];
		Connecto__c objConnecto = [SELECT id,Mobile_Number__c FROM Connecto__c LIMIT 1];
		Test.startTest();
			ConnecToHelperClass objConnecToHelper = new ConnecToHelperClass();
			objConnecToHelper.CheckExistingLeadBasedOnMobileNum(objLead.MobilePhone);
			objConnecToHelper.CheckExistingAccountBasedOnMobileNum(objLead.MobilePhone);
			objConnecToHelper.CheckExistingLeadEmail(objLead.Email);
			objConnecToHelper.CheckExistingAccountEmail(objLead.Email);

		Test.stopTest();
	}

	@isTest
	static void testUnit2() { 
		Lead objLead = [SELECT id,MobilePhone,Email,nm_InformationCenter__c FROM Lead LIMIT 1];
		Connecto__c objConnecto = [SELECT id,Mobile_Number__c FROM Connecto__c LIMIT 1];
		Test.startTest();
			ConnecToHelperClass objConnecToHelper = new ConnecToHelperClass();
			objConnecToHelper.CheckConnectToRecordForDuplicateMobile(objConnecto.Mobile_Number__c);
			objConnecToHelper.CheckIfCenterIsActive(objLead.nm_InformationCenter__c); 
			objConnecToHelper.updateExistingLeadTORebornFromMobileNo(objLead.MobilePhone);
			objConnecToHelper.updateExistingLeadTORebornFromEmail(objLead.Email);
		Test.stopTest();
	}

    // public static Lead objLead;
    // public static Account objAccount;
    // public static User objUser;
    // public static nm_UserMapping__c objUserMap;
    // public static nm_EligiblityCriteria__c objEc;
    // public static nm_Centers__c centerInformationCenter;
    // public static nm_Centers__c centerLearningCenter;
    // public static Connecto__c objConnecto;
    // public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    // public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    //     static testMethod void test1()
    //     {
    //         loadData();
    //           ConnecToHelperClass objConnecToHelper=new ConnecToHelperClass();

    //         objConnecToHelper.CheckExistingLeadBasedOnMobileNum(objLead.MobilePhone);
    //         objConnecToHelper.CheckExistingAccountBasedOnMobileNum(objAccount.PersonMobilePhone);
    //         objConnecToHelper.CheckExistingLeadEmail(objLead.Email);
    //         objConnecToHelper.CheckExistingAccountEmail(objAccount.PersonEmail);
    //         objConnecToHelper.CheckConnectToRecordForDuplicateMobile(objConnecto.Mobile_Number__c);  

    //     }
    //     static void loadData()
    //     {

    //       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    //       objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
    //       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    //       LocaleSidKey='en_US', ProfileId = p.Id,
    //       TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');

    //       insert objUser;

    //       nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
    //       objCustomSeetings3.name='0-1 week';
    //       objCustomSeetings3.nm_LCEscalationTime__c='22:45';
    //       objCustomSeetings3.nm_RemidertoIC__c='22:45';
    //       objCustomSeetings3.nm_HOEscalationTime__c='20:56';
    //       objCustomSeetings3.nm_RemidertoHO__c='22:45';
    //       insert objCustomSeetings3;

    //       nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
    //       objCustomSeetings.name='2-4 week';
    //       objCustomSeetings.nm_LCEscalationTime__c='20:45';
    //       objCustomSeetings.nm_RemidertoIC__c='21:45';
    //       objCustomSeetings.nm_HOEscalationTime__c='20:56';
    //       objCustomSeetings.nm_RemidertoHO__c='21:45';
    //       insert objCustomSeetings; 

    //       nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
    //       objCustomSeetings2.name='3-6 week';
    //       objCustomSeetings2.nm_LCEscalationTime__c='20:34';
    //       objCustomSeetings2.nm_RemidertoIC__c='21:45';
    //       objCustomSeetings2.nm_HOEscalationTime__c='20:56';
    //       objCustomSeetings2.nm_RemidertoHO__c='21:45';
    //       insert objCustomSeetings2; 

    //       nm_Holidays__c objHoliday=new nm_Holidays__c();
    //       objHoliday.Name='Holi';
    //       objHoliday.nm_Date__c=system.today();
    //       insert objHoliday;

    //       SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
    //       objSystemConfiguration.name='test';
    //       objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
    //       objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
    //       insert objSystemConfiguration;

    //       centerLearningCenter = new nm_Centers__c();
    //       centerLearningCenter.Nm_Active__c = true;
    //       centerLearningCenter.nm_CenterCode__c = 'abcd1';
    //       centerLearningCenter.nm_City__c = 'Mumbai';
    //       centerLearningCenter.Contact_No_1__c = '9867167685';
    //       centerLearningCenter.nm_Country__c = 'India';
    //       centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
    //       centerLearningCenter.nm_Street__c = 'Altmount Road';
    //       centerLearningCenter.nm_PostalCode__c = '400601';
    //       centerLearningCenter.RecordTypeID = learningCenter.id;

    //       insert centerLearningCenter;

    //       centerInformationCenter = new nm_Centers__c();
    //       centerInformationCenter.Nm_Active__c = true;
    //       centerInformationCenter.Name = 'Counsellor';
    //       centerInformationCenter.nm_CenterCode__c = 'abcd2';
    //       centerInformationCenter.nm_City__c = 'Mumbai Mira Road';
    //       centerInformationCenter.Contact_No_1__c = '9867167685';
    //       centerInformationCenter.nm_Country__c = 'India';
    //       centerInformationCenter.nm_StateProvince__c = 'Maharashtra';
    //       centerInformationCenter.nm_LearningCenter__c = centerLearningCenter.id;
    //       centerInformationCenter.nm_Street__c = 'Altmount Road';
    //       centerInformationCenter.nm_PostalCode__c = '400601';
    //       centerInformationCenter.RecordTypeID = informationCenter.id;

    //       insert centerInformationCenter;

    //       objEc = new nm_EligiblityCriteria__c ();
    //       objEc.Name='NameEligibility Criteria';
    //       objEc.nm_Documnetslist__c ='10th Marksheet';
    //       objEc.Experience_Required_In_Year__c=2;
    //       objEc.nm_EligiblityCriteria__c ='test';
    //       objEc.nm_Program__c ='Certificate Programs';
    //       insert objEc;  

    //       objUserMap= new nm_UserMapping__c();
    //       objUserMap.nm_Centers__c=centerInformationCenter.id;
    //       objUserMap.nm_User__c=objUser.id;
    //       objUserMap.nm_Phone__c='326392156';
    //       objUserMap.nm_Head__c= true; 

    //       insert objUserMap;

    //       objLead = new Lead();
    //       objLead.FirstName ='Mohite';
    //       objLead.LastName='test';
    //       objLead.Status ='Not Contacted';
    //       objLead.MobilePhone='6451322334459';
    //       objLead.Email='Sacawfeehi45rn@gmail.com';
    //       objLead.nm_ChooseaProgram__c='PGDM';
    //       objLead.nm_InformationCenter__c=centerInformationCenter.id;
    //       objLead.LeadSource='Web';
    //       objLead.nm_PlantoStart__c='0-1 week';
    //      // insert objLead;


    //       objAccount = new Account();
    //       objAccount.LastName = 'Menon';
    //       objAccount.PersonMobilePhone= '9930630174';
    //       objAccount.PersonEmail = 'vikasrmenon@gmail.com';
    //       objAccount.Agency__c = 'student';
    //       objAccount.nm_BloodGroup__c = 'B+';
    //       objAccount.nm_City__c = 'Mumbai';
    //       objAccount.nm_Gender__c = 'Male';
    //       objAccount.nm_Centers__c = centerInformationCenter.id;
    //       objAccount.Is_Lateral__c = false;
    //      // objAccount.Launch_Year__c = 'JUL2014';
    //       objAccount.nm_EligiblityCriteria__c = objEc.id;

    //       insert objAccount;


    //        objConnecto=new Connecto__c();
    //        objConnecto.Email_ID__c='sagar.phadtare93@gmail.com';
    //        objConnecto.OwnerID=objUser.id;
    //        objConnecto.Mobile_Number__c='9987226106';
    //        objConnecto.City__c = 'Mumbai Mira Road';

    //        insert objConnecto; 
    //     }
}