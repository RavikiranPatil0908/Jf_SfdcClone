/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class HomePageControllerTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        insertEscalationMatrix();
        insertSystemConfig();
        nmGenericTracker.InsertSerialNo();
        createCalender('Certificate Programs',null);
        nm_Program__c objProgram = createProgram('Certificate Programs','Certificate program in Project Management',1,'');
        nm_Centers__c objCenter = createCenter('Mumbai - Mira Road East'); 
        List<Lead> lstLeadToInsert = new List<Lead>();
        Lead objLead = insertLead(objProgram.id, objCenter.id, null,null,'09',null);
        objLead.LeadSource = 'Partner';
        objLead.Status = 'Hot';
        lstLeadToInsert.add(objLead);

        insert lstLeadToInsert;

        createCalender('Master Programs','MBA');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =system.today();
        objAccount.nm_ProgramType__c = 'Master Programs';
        objAccount.Program_Type__c = 'MBA';
        update objAccount;
    }

    @isTest 
    static void unitTest1(){ 
        Test.startTest();
            PageReference pageRef = Page.EnrollmentForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('nav','form');
            HomePageController objHome = new HomePageController();
            if(generateSession('Lead')) {
                objHome.validateSession();
                Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
                String sessionToken = sessionId != null ? sessionId.getValue() : null;
                System.assertNotEquals(null, sessionToken, 'Invalid Session');
            }
            objHome.queryData();
            System.assertEquals(true, objHome.isValid, 'Invalid Record');

            objHome.logout();
            Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
            String sessionToken = sessionId != null ? sessionId.getValue() : null;
            System.assertEquals(null, sessionToken, 'Session could not be cleared');
        Test.stopTest();
    }

    @isTest 
    static void unitTest2(){ 
        Test.startTest();
            HomePageController objHome = new HomePageController();
            generateSession('Account');
            objHome.validateSession();
            objHome.queryData();
        Test.stopTest();
    }

    public static Boolean generateSession(String type) {
        SessionManager objManager = new SessionManager();
        if(type == 'Lead') {
            List<Lead> lstLead = [SELECT id FROM Lead LIMIT 1];
            return objManager.loginSuccessFull(lstLead[0].Id,'Lead', null);
        } else {
            List<Account> lstAccount = [SELECT id FROM Account LIMIT 1];
            return objManager.loginSuccessFull(lstAccount[0].Id,'Account', null);
        }
        
    }

    public static Lead insertLead(String programId, String centerId, String selectedIC, String studentName, String count, String programType) {
        Lead objLead = new Lead();
        objLead.Email = 'test'+count+'@gmail.com';
        objLead.MobilePhone = '78451236'+count;
        objLead.nm_ChooseaProgram__c = String.isBlank(programType) ? 'Bachelor Programs' : programType;

        if(String.isBlank(programType)) {
            objLead.Program_Type__c = 'BBA';
        }
        if(String.isBlank(studentName)) {
            objLead.LastName ='Test';
            objLead.FirstName='User';
        } else {
            objLead.LastName = studentName;
        }
        objLead.nm_Program__c=programId;
        if(String.isNotBlank(selectedIC)) {
            objLead.nm_SelectedIC__c= selectedIC; // 'Mumbai';
        }
        if(String.isNotBlank(centerId)) {
            objLead.nm_InformationCenter__c = centerId;
        }
        objLead.nm_PlantoStart__c ='2-4 Months';
        objLead.LeadSource ='Web';
        objLead.nm_SelectedProgram__c = 'Bachelor of Business Administration';
        return objLead;
    }

    public static nm_Program__c createProgram(String typeOfProgram,String ProgramName,decimal totalSem,String sepcialization) {
        nm_Program__c program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.nm_ProgramCode__c = 'test';
        program.BookCChargeapplicable__c = true ;
        program.nm_ProgramDuration__c= 2.0;
        program.nm_ProgramName__c = ProgramName;
        program.nm_ProgramValidity__c = totalSem;
        program.nm_TotalSemesters__c = totalSem;
        program.nm_Type__c = typeOfProgram;
        program.prgst__c ='Jul2019';
        program.PVM__c = 48;
        program.Specialisation__c = sepcialization;          
        insert program; 
        createElegibilityCriteria(typeOfProgram);
        return program;
    }

    public static nm_Centers__c createCenter(String centerName) {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        nm_Centers__c objLcCen = nmGenericTracker.CreateLearningCenter('Mumbai - Mira Road East');

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name=centerName;
        
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.ShareApplicable__c =true;
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.OwnerId= UserInfo.getUserId();
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';

        insert objCen;

        createICAndUser2(objCen, generateRandomString(7));
        return objCen;
    }

    public static String generateRandomString(Integer length) {
        String charString = '9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAabcdefghijklmnopqrstuvwxyz';
        String randomNew = '';
        while (randomNew.length() < length) {
            Integer changeInt5 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt5 , changeInt5 +1);
        }
        randomNew = randomNew.left(4);
        return randomNew;
    }

    public static void createICAndUser2( nm_Centers__c objCen, String centerName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = centerName+'nbsp', Email= centerName+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='abpsg', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName= centerName+'@testorg.com');
        insert objUser;
        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCen.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
    }

    public static nm_EligiblityCriteria__c createElegibilityCriteria(String programName) {
        System.debug('programName ==>'+programName);
        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor degree';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c= null ;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c = programName;
        objEc.Graduation_Required__c =false;
        objEc.Mandatory_Document_list__c = '10th Marksheet';
        insert objEc;
        System.debug('objEc ==>'+objEc);
        return objEc;
    }

    public static void insertEscalationMatrix(){
        List<nm_EscalationMatrix__c> lstToInsert = new List<nm_EscalationMatrix__c>();
        List<String> lst = new List<String>{'0-1 Week','2-3 Week','2-4 Months','3-6 Week','5+ Months'};
        
        for(String settingKey : lst) {
            nm_EscalationMatrix__c setting = new nm_EscalationMatrix__c();
            setting.Name = settingKey;
            setting.nm_HOEscalationTime__c = '2:00';
            setting.nm_LCEscalationTime__c = '1:00';
            setting.nm_RemidertoHO__c = '2:00';
            setting.nm_RemidertoIC__c = '0:30';
            setting.nm_RemidertoLC__c = '1:00';
            setting.nm_SMLCEscalationTime__c = '4:00';
            lstToInsert.add(setting);
        }
        insert lstToInsert;
    }

    public static void insertSystemConfig() {
        SystemConfiguration__c objconfig = new SystemConfiguration__c();
        objconfig.Name = 'System Data';
        objConfig.nm_BusinessHoursEndTime__c = '18:00';
        objconfig.nm_BusinessHoursStartTime__c = '10:00';
        insert objconfig;
    } 

    public static void createCalender(String program, String specialisation) {
        List<Calender__c> lstCal = new List<Calender__c>();

        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = System.now().year();
        objCal.Session_End_Date__c = system.today()+1;
        objCal.Category__c= 'Admission';
        objCal.nm_Type__c = program;
        objCal.Specialisation__c = specialisation;
        lstCal.add(objCal);

        Calender__c objCal1 = new Calender__c();
        objCal1.Session_Start_Date__c = system.today();
        objCal1.Session__c = 'January';
        objCal1.Year__c = System.now().year();
        objCal1.Session_End_Date__c = system.today()+1;
        objCal1.Category__c= 'Re-Registration';
        objCal.nm_Type__c = program;
        objCal.Specialisation__c = specialisation;
        lstCal.add(objCal1);
        
        insert lstCal;
    }

}