/**
 * @File Name          : nmLeadTriggerHandlerTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 11-26-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2019   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class nmLeadTriggerHandlerTracker {

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

    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='[{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        insertEscalationMatrix();
        insertSystemConfig();
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCalender();

        CreateCalender('Bachelor Programs','BBA');
        createProgram('Bachelor Programs','Bachelor of Business Administration',6,'BBA');

        CreateCalender('Professional Programs','Professional Diploma');
        nm_Program__c objProgram = createProgram('Certificate Programs','Certificate program in Project Management',1,'');
        nm_Program__c objProgram2 = createProgram('MBA (Distance) Programs','MBA (Financial Management)',4,'');
        nm_Centers__c objCenter = CreateCenter('Mumbai - Mira Road East'); 
        nm_Centers__c objCenterMumbai = CreateCenter('Mumbai');
        nm_Centers__c objCenterCounsellor = CreateCenter('Counsellor');
        nm_Centers__c objLcCen = CreateCenter('Banglore');
        objLcCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs';
        update objLcCen;

        insertLeadRouting(objCenterMumbai.id,objCenter.id);

        // For reborn duplicate check
        Lead objLeadReborn = createLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false,'reborn_amit.kumar@saasfocus.com');

        Lead objLead = createLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false,'amit.kumar@saasfocus.com');

        // For dnd check and send sms
        Lead objLeadForDND = createLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false,'amit.kumar12@saasfocus.com');
        objLeadForDND.is_dnd_new__c = 'Yes';
        update objLeadForDND;

        // For lateral student
        Account objLateralAccount = nmGenericTracker.CreateAccountWithUpgradCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        Opportunity objOpp1 = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Post Graduate Diploma Programs',objLateralAccount,'admission');

        Lead objlateralLead = createLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',true,objLateralAccount.PersonEmail);
        objlateralLead.Student_Number_Lateral__c = objLateralAccount.nm_StudentNo__c;
        update objlateralLead;


        List<Lead> lstLeadToInsert = new List<Lead>();
        Lead objLead2 = insertLead(objProgram.id, objCenter.id, null,null,'09',null);
        objLead2.LeadSource = 'Partner';
        objLead2.Status = 'Hot';
        lstLeadToInsert.add(objLead2);

        Lead objLead3 = insertLead(objProgram.id, objCenter.id, null,null,'08',null);
        objLead3.LeadSource = 'Partner';
        objLead3.Status = 'Hot';
        lstLeadToInsert.add(objLead3);

        Lead objLead4 = insertLead(objProgram.id, objCenter.id, null,null,'07',null);
        objLead4.LeadSource = 'Web';
        objLead4.Status = 'Hot';
        lstLeadToInsert.add(objLead4);

        Lead objLead5 = insertLead(objProgram.id, objLcCen.id, null,null,'10',null);
        objLead5.LeadSource = 'Web';
        objLead5.Status = 'Warm';
        objLead5.Counter__c = null;
        lstLeadToInsert.add(objLead5);

        Lead objLead6 = insertLead(objProgram.id, objCenterMumbai.id, null,null,'11',null);
        objLead6.LeadSource = 'Partner';
        objLead6.Status = 'Hot';
        lstLeadToInsert.add(objLead6);

        Lead objLead7 = insertLead(objProgram.id, objLcCen.id, null,null,'12',null);
        objLead7.LeadSource = 'Web';
        objLead7.Status = 'Warm';
        lstLeadToInsert.add(objLead7);

        lstLeadToInsert.add(createDuplicateAccount(objProgram2.id, objLcCen.id));

        insert lstLeadToInsert;

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

    public static Lead createDuplicateAccount(String programId, String centerId) {
        List<nm_Program__c> lstProgram = [SELECT id,nm_Type__c FROM nm_Program__c WHERE id=:programId LIMIT 1];
        nm_EligiblityCriteria__c obj = createElegibilityCriteria(lstProgram[0].nm_Type__c);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
        objAccount.PersonMobilePhone = '8377985721';
        objAccount.nm_ProgramType__c = 'MBA (Distance) Programs';
        objAccount.nm_Program__c = lstProgram[0].id;
        objAccount.nm_EligiblityCriteria__c = obj.id;
        update objAccount;

        // Certificate Programs
        System.debug('==> Program Type '+lstProgram[0].nm_Type__c);

        Lead objLead = insertLead(lstProgram[0].id, centerId, null,null,'13','MBA (Distance) Programs');
        objLead.Email = objAccount.PersonEmail;
        objLead.MobilePhone = objAccount.PersonMobilePhone;
        objLead.nm_EligiblityCriteria__c = obj.id;
        return objLead;
    }

    public static Lead createLeadWithProgramAndCenterAndECForGivenDefenceAndLateral(String IsDefence,boolean IsLateral,String email) {
        nm_Program__c objProgram = nmGenericTracker.CreatePGDiplomaProgram();
        nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai');

        String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        String alias = 'newUser' + randomNumber.left(1);
        String emailAddress = 'newuser' + randomNumber.left(3) + '@testorg.com';
        String userName = String.valueOf(System.now().millisecond()) + 'newuseoijior' + String.valueOf(System.now().millisecond()) + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = alias, Email= emailAddress, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        insert objUser; 
        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCen.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;


        nm_EligiblityCriteria__c  objEc = nmGenericTracker.CreateElegibilityCriteria();
        Lead objLead = new  Lead();
        objLead.nm_SelectedIC__c ='Mumbai';
        objLead.nm_Program__c=objProgram.id;
        objLead.Salutation='Mr';
        objLead.nm_DateOfBirth__c = date.newInstance(1990, 12, 9);
        objLead.nm_Semester__c = '1';
        objLead.LastName ='kumar';
        objLead.FirstName='amit';
        //objLead.nm_MiddleName__c = 'test';
        objLead.Father_Salutation__c='Mr.';
        objLead.Mother_Salutation__c='Ms.';
        objLead.Mother_Last_Name__c='test';
        objLead.status='Reborn';
        objLead.nm_Class12OrDiploma__c ='XII/HSC';
        objLead.nm_Class12OrDiploma__c='Diploma';
        objLead.Email=email;
        objLead.MobilePhone ='83779'+randomNumber;
        objLead.City='noida';
        objLead.nm_Stream__c='hgfgc';
        objLead.nm_Gender__c = 'Male';
        objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
        objLead.nm_EligiblityCriteria__c = objEc.id;
        objLead.nm_PaymentCompleted__c = false;
        objLead.nm_NameofBoard12__c='hvh';
        objLead.nm_SelectedProgram__c ='ccc';
        objLead.nm_InformationCenter__c =objCen.id;
        objLead.nm_Year__c =2014;
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
        objLead.Is_Lateral__c = IsLateral;
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

    public static void insertLeadRouting(String fromId, String toId) {
        List<Lead_Routing__c> lst = new List<Lead_Routing__c>();
        Lead_Routing__c obj1 = new Lead_Routing__c();
        obj1.Active__c = true;
        obj1.From_Center__c = fromId; //objCenterMumbai.id;
        obj1.To_Center__c = toId; //objCenter.id;
        obj1.Agency__c = 'Test';
        obj1.Choose_a_Program__c = 'Diploma Programs;Master Programs';
        lst.add(obj1);

        Lead_Routing__c obj2 = new Lead_Routing__c();
        obj2.Active__c = true;
        obj2.From_Center__c = fromId; //objCenterMumbai.id;
        obj2.To_Center__c = toId; //objCenter.id;
        obj2.Choose_a_Program__c = 'Bachelor Programs;Master Programs;Diploma Programs';
        obj2.Program_Type__c = 'BBA';
        lst.add(obj2);

        Lead_Routing__c obj3 = new Lead_Routing__c();
        obj3.Active__c = true;
        obj3.From_Center__c = fromId; //objCenterMumbai.id;
        obj3.To_Center__c = toId; //objCenter.id;
        obj3.Program_Type__c = 'BA';
        lst.add(obj3);

        Lead_Routing__c obj4 = new Lead_Routing__c();
        obj4.Active__c = true;
        obj4.From_Center__c = fromId; //objCenterMumbai.id;
        obj4.To_Center__c = toId; //objCenter.id;
        obj4.Agency__c = 'test';
        lst.add(obj4);

        Lead_Routing__c obj5 = new Lead_Routing__c();
        obj5.Active__c = true;
        obj5.From_Center__c = fromId; //objCenterMumbai.id;
        obj5.To_Center__c = toId; //objCenter.id;
        obj5.Choose_a_Program__c = 'Master Programs';
        lst.add(obj5);

        Lead_Routing__c obj6 = new Lead_Routing__c();
        obj6.Active__c = true;
        obj6.From_Center__c = fromId; //objCenterMumbai.id;
        obj6.To_Center__c = toId; //objCenter.id;
        obj6.Program_Type__c = 'BCom';
        obj6.Agency__c = 'Test';
        lst.add(obj6);

        Lead_Routing__c obj7 = new Lead_Routing__c();
        obj7.Active__c = true;
        obj7.From_Center__c = fromId; //objCenterMumbai.id;
        obj7.To_Center__c = toId; //objCenter.id;
        lst.add(obj7);

        Lead_Routing__c obj8 = new Lead_Routing__c();
        obj8.Active__c = true;
        obj8.From_Center__c = fromId; //objCenterMumbai.id;
        obj8.To_Center__c = toId; //objCenter.id;
        obj8.Choose_a_Program__c = 'Bachelor Programs;Master Programs;Diploma Programs';
        obj8.Program_Type__c = 'BBA';
        obj8.Agency__c = 'test';
        lst.add(obj8);

        insert lst;
    }

    public static nm_Centers__c CreateCenter(String centerName) {
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

        CreateICAndUser2(objCen, generateRandomString(7));
        return objCen;
    }

    public static nm_Centers__c CreateLearningCenter(String centerName) {
         Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Lata Kunj';
        objCen.nm_PostalCode__c = '400051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';
        insert objCen;
        CreateICAndUser2(objCen,generateRandomString(7));
        return objCen;
    }

    public static void CreateICAndUser2( nm_Centers__c objCen, String centerName) {
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

    public static User createUser(String email, String mobile, String alias, String profileId) {
        User uu = new User(
            ProfileId = profileId, //profile1.Id,
            Username = System.now().millisecond() + email,
            Alias = alias, //'batman',
            Email=email, //'bruce22.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='marketing',
            Lastname='ngasce',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            MobilePhone=mobile //'9897654545'
        );
        return uu;
    }

    public static User setDataforCounsellor(Boolean setProgram, Boolean unsetCenterProgram) {
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        List<nm_Centers__c> lstCenter = [SELECT id,nm_ChooseaProgram__c FROM nm_Centers__c WHERE Name='Counsellor' LIMIT 1];
        if(unsetCenterProgram) {
            lstCenter[0].nm_ChooseaProgram__c = null;
            update lstCenter;
        }
        List<User> lstuu = new List<User>();
        List<nm_UserMapping__c> lstUM = new List<nm_UserMapping__c>();
        lstuu.add(createUser('test1@gmail.com','7410258963','bat',profile1.Id));
        lstuu.add(createUser('test2@gmail.com','7410008963','bat1',profile1.Id));
        insert lstuu;
        for(User obj : lstuu) {
            nm_UserMapping__c objUserMap= new nm_UserMapping__c();
            objUserMap.nm_Centers__c=lstCenter[0].id;
            objUserMap.nm_User__c=obj.id;
            objUserMap.nm_Phone__c='326392156';
            if(setProgram ) {
                objUserMap.nm_ChooseaProgram__c = 'Bachelor Programs; MBA (Distance) Programs; Diploma Programs';
            }
            lstUM.add(objUserMap);
        }
        insert lstUM;
        return lstuu[0];
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

    /* ----------------------------------------------- Insert -------------------------------------------------------------------    */ 
    @isTest
    static void unitTest1() {
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            List<Lead> lstLead = new List<Lead>();
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test User','00','MBA'));
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test User .','01','Bachelor'));
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test','02','Certificate'));
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test','03','Master'));
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test','04','Diploma'));
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai','Test','05','Professional'));
            insert lstLead;
        Test.stopTest();
    }

    /**
    * @description For Lead Routing
    * @author @BK | 07-02-2024 
    **/
    @isTest
    static void unitTest2() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            List<Lead> lstLead = new List<Lead>();
            lstLead.add(insertLead(lstProgram[0].id,lstCenter[0].id, 'Mumbai',null, '00',null));
            insert lstLead;
        Test.stopTest();
    }

    @isTest
    static void unitTest3() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        Test.startTest();
            Lead objLead = insertLead(lstProgram[0].id,null,'Mumbai',null,'00',null);
            insert objLead;
        Test.stopTest();
    }

    @isTest
    static void unitTest4() { 
        User uu = setDataforCounsellor(false,false);
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        Test.startTest();
            System.runAs(uu) {
                Lead objLead = insertLead(lstProgram[0].id, null, 'Mumbai',null,'00',null);
                objLead.Description = 'Test';
                insert objLead;
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest5() { 
        setDataforCounsellor(true,false);
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        Test.startTest();
            Lead objLead = insertLead(lstProgram[0].id, null, null,null,'00',null);
            objLead.Lead_Action__c = 'Email Sent';
            insert objLead;
        Test.stopTest();
    }

    @isTest
    static void unitTest6() { 
        setDataforCounsellor(false,false);
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        Test.startTest();
            Lead objLead = insertLead(lstProgram[0].id, null, null,null,'00',null);
            objLead.Description = 'Test';
            objLead.Lead_Action__c = 'Email Sent';
            insert objLead;
        Test.stopTest();
    }

    @isTest
    static void unitTest7() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE nm_City__c='Mumbai - Mira Road East' AND recordtype__c='Information Center' LIMIT 1];
        Test.startTest();
            try {
                Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'09',null);
                objLead.LeadSource = 'Partner';
                objLead.Agency__c = 'test';
                insert objLead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead, Record already exists with same Email or Mobile No') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest8() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'08',null);
            objLead.LeadSource = 'Web';
            insert objLead;
        Test.stopTest();
    }

    @isTest
    static void unitTest9() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            try {
                Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'07',null);
                objLead.LeadSource = 'Web';
                objLead.Agency__c = 'test';
                insert objLead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead, Record already exists with same Email or Mobile No') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest10() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            try {
                Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'07',null);
                objLead.LeadSource ='CC-AEP';
                insert objLead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead, Record already exists with same Email or Mobile No') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest11() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Test.startTest();
            try {
                Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'10',null);
                objLead.LeadSource ='Web';
                insert objLead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead, Record already exists with same Email or Mobile No') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest12() { 
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        Lead obLead = [SELECT id,nm_InformationCenter__c,nm_InformationCenter__r.Name FROM Lead WHERE Email='test11@gmail.com' LIMIT 1];
        System.debug('obLead ==>'+obLead.nm_InformationCenter__r.Name);
        System.debug('obLead ==>'+obLead.nm_InformationCenter__c);
        System.debug('lstCenter ==>'+lstCenter[0].id);
        Test.startTest();
            try {
                Lead objLead = insertLead(lstProgram[0].id, lstCenter[0].id, null,null,'11',null);
                objLead.LeadSource ='Web';
                objLead.Agency__c = 'test';
                insert objLead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead, Record already exists with same Email or Mobile No') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest13() { 
        setDataforCounsellor(false,true);
        List<nm_Program__c> lstProgram = [SELECT id FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        Test.startTest();
            Lead objLead = insertLead(lstProgram[0].id, null, null,null,'00','MBA');
            objLead.Lead_Action__c = 'Email Sent';
            insert objLead;
        Test.stopTest();
    }

    /* ----------------------------------------------- Insert Ends -------------------------------------------------------------------    */ 

    /* ----------------------------------------------- Update -------------------------------------------------------------------    */ 

    @isTest
    static void unitTest14() { 
        List<Lead> lstlead = [SELECT id,Email,mobilephone FROM Lead WHERE Email='test10@gmail.com' LIMIT 1];
        Test.startTest();
            try {
                lstlead[0].Email = 'test12@gmail.com';
                update lstlead;
            } catch (Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Lead Found') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest15() { 
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        List<Lead> lstlead = [SELECT id,Email,mobilephone,nm_CopyAddress__c,Shipping_Address_Choice__c,nm_PaymentCompleted__c,PostalCode,nm_PostalCode_P__c,Zip_Postal_Code_Shipping__c FROM Lead WHERE nm_CopyAddress__c=null LIMIT 3];
        Test.startTest();
            for (Integer i = 0; i < lstlead.size(); i++) {
                if(i<=0) {
                    lstlead[i].nm_CopyAddress__c = 'Yes';
                    lstlead[i].PostalCode = '400071';
                } else if( i == 1) {
                    lstlead[i].Shipping_Address_Choice__c = 'Shipping Address as Permanent Address';
                    lstlead[i].nm_PostalCode_P__c = '400071';
                } else if(i==2) {
                    lstlead[i].Shipping_Address_Choice__c = 'Shipping Address as Billing Address';
                    lstlead[i].Zip_Postal_Code_Shipping__c = '400071';
                }
            }
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest16() { 
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Mumbai' LIMIT 1];
        List<Lead> lstlead = [SELECT id,Email,mobilephone,nm_InformationCenter__c,is_dnd_new__c,Loan_Type__c,Loan_Approved__c,EduVanz_lead_id__c FROM Lead WHERE nm_InformationCenter__c!=:lstCenter[0].id LIMIT 1];
        Test.startTest();
            lstlead[0].nm_InformationCenter__c = lstCenter[0].id;
            lstlead[0].is_dnd_new__c = 'Yes';
            lstLead[0].Loan_Type__c = 'LiquiLoans';
            lstlead[0].Loan_Approved__c = true;
            lstlead[0].EduVanz_lead_id__c = '123456';
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest17() { 
        List<nm_Program__c> lstProgram = [SELECT id,nm_Type__c FROM nm_Program__c WHERE nm_Type__c='Bachelor Programs' LIMIT 1];
        List<nm_EligiblityCriteria__c> lstCritria = [SELECT id FROM nm_EligiblityCriteria__c WHERE nm_Program__c=:lstProgram[0].nm_Type__c LIMIT 1];
        List<Lead> lstlead = [SELECT id,Email,mobilephone,nm_Program__c,nm_EligiblityCriteria__c,Loan_Type__c,Loan_Application_Cancelled__c,EduVanz_lead_id__c FROM Lead WHERE nm_Program__c!=:lstProgram[0].id LIMIT 1];
        Test.startTest();
            lstlead[0].nm_Program__c = lstProgram[0].id;
            lstlead[0].nm_EligiblityCriteria__c = lstCritria[0].id;
            lstLead[0].Loan_Type__c = 'LiquiLoans';
            lstlead[0].Loan_Application_Cancelled__c = true;
            lstlead[0].EduVanz_lead_id__c = '123456';
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest18() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Account> lstAcc = [SELECT id,Pass_Out__c,nm_StudentStatus__c,nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c ='011564865' LIMIT 1];
        lstAcc[0].Pass_Out__c = true;
        lstAcc[0].nm_StudentStatus__c = 'De-Registered';
        update lstAcc;

        List<Lead> lstlead = [SELECT id,Email,mobilephone,Student_Number_Lateral__c,Is_Lateral__c,Loan_Type__c,Loan_Approved__c,EduVanz_lead_id__c FROM Lead LIMIT 1];
        Test.startTest();
            lstlead[0].Student_Number_Lateral__c = lstAcc[0].nm_StudentNo__c;
            lstlead[0].Is_Lateral__c = true;
            lstLead[0].Loan_Type__c = 'Propelld';
            lstlead[0].Loan_Approved__c = true;
            lstlead[0].EduVanz_lead_id__c = '123456';
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest19() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Account> lstAcc = [SELECT id,Pass_Out__c,nm_StudentStatus__c,nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c ='011564865' LIMIT 1];
        lstAcc[0].Pass_Out__c = true;
        lstAcc[0].nm_StudentStatus__c = 'De-Registered';
        lstAcc[0].Program_Type__c = 'Diploma Programs';
        update lstAcc;

        List<Lead> lstlead = [SELECT id,Email,mobilephone,Student_Number_Lateral__c,Is_Lateral__c,nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Test.startTest();
            lstlead[0].Student_Number_Lateral__c = lstAcc[0].nm_StudentNo__c;
            lstlead[0].Is_Lateral__c = true;
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest20() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Account> lstAcc = [SELECT id,Pass_Out__c,nm_StudentStatus__c,nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c ='011564865' LIMIT 1];
        lstAcc[0].Pass_Out__c = true;
        lstAcc[0].nm_StudentStatus__c = 'De-Registered';
        lstAcc[0].Program_Type__c = 'Diploma Programs';
        update lstAcc;
        List<nm_EligiblityCriteria__c> lstCritria = [SELECT id,nm_Program__c,Name FROM nm_EligiblityCriteria__c WHERE nm_Program__c='Master Programs' LIMIT 1];
        if(lstCritria.size() == 0) {
            lstCritria.add(createElegibilityCriteria('Master Programs'));
            System.debug('Program ==>'+lstCritria[0].nm_Program__c);
            System.debug('Program Id ==>'+lstCritria[0].id);
            System.debug('Program Name ==>'+lstCritria[0].Name);
        }
        List<Lead> lstlead = [SELECT id,Email,mobilephone,Student_Number_Lateral__c,Is_Lateral__c,nm_ChooseaProgram__c FROM Lead LIMIT 1];
        Test.startTest();
            lstlead[0].nm_ChooseaProgram__c = 'Master Programs';
            lstlead[0].nm_EligiblityCriteria__c = lstCritria[0].id;
            lstlead[0].Student_Number_Lateral__c = lstAcc[0].nm_StudentNo__c;
            lstlead[0].Is_Lateral__c = true;
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest21() { 
        List<Lead> lstlead = [SELECT id,Email,mobilephone,nm_PaymentCompleted__c,LeadSource FROM Lead LIMIT 1];
        Test.startTest();
            lstlead[0].LeadSource = 'Partner';
            lstlead[0].nm_PaymentCompleted__c = true;
            update lstlead;
        Test.stopTest();
    }

    // @isTest
    // static void unitTest22() { 
    //     List<Account> lstAcc = [SELECT id,Pass_Out__c,nm_StudentStatus__c,nm_StudentNo__c,nm_ChooseaProgram__c FROM Account WHERE PersonMobilePhone ='8377985721' LIMIT 1];
    //     List<Lead> lstlead = [SELECT id,Email,nm_PaymentCompleted__c,nm_ChooseaProgram__c,LeadSource,nm_EligiblityCriteria__c FROM Lead WHERE mobilephone='8377985721' LIMIT 1];

    //     List<nm_EligiblityCriteria__c> lstCritria = [SELECT id,nm_Program__c,Name FROM nm_EligiblityCriteria__c WHERE nm_Program__c ='Master Programs' LIMIT 1];
    //     if(lstCritria.size() == 0) {
    //         lstCritria.add(createElegibilityCriteria('Master Programs'));
    //         System.debug('Program ==>'+lstCritria[0].nm_Program__c);
    //         System.debug('Program Id ==>'+lstCritria[0].id);
    //         System.debug('Program Name ==>'+lstCritria[0].Name);
    //     }

    //     Test.startTest();
    //         lstlead[0].LeadSource = 'Partner';
    //         lstlead[0].nm_PaymentCompleted__c = true;
    //         lstlead[0].nm_EligiblityCriteria__c = lstCritria[0].id;
    //         lstlead[0].nm_ChooseaProgram__c = 'Master Programs';
    //         update lstlead;
    //     Test.stopTest();
    // }

    @isTest
    static void unitTest23() { 
        List<Lead> lstlead = [SELECT id,Email,mobilephone,Is_Mobile_Verified__c,Status,Next_Follow_up__c,NoResponse__c FROM Lead LIMIT 5];
        Test.startTest();
            for (Integer i = 0; i < lstlead.size(); i++) {
                if(i==0) {
                    lstlead[i].mobilephone = '1200000036';
                } else if(i==1) {
                    lstlead[i].Email = '1200000036@gmail.com';
                } else if(i==2) {
                    lstlead[i].mobilephone = '1200000037';
                    lstlead[i].Is_Mobile_Verified__c = true;
                } else if(i==3) {
                    lstlead[i].Email = '1200000037@gmail.com';
                    lstlead[i].nm_IsEmailVerified__c = true;
                } else if(i==4) {
                    lstlead[i].Status = 'Phone Switched Off/Ringing/No Response';
                    lstlead[i].Is_Mobile_Verified__c = true;
                    lstlead[i].Next_Follow_up__c = System.now().addDays(1);
                    lstlead[i].NoResponse__c = false;
                }
            }
            update lstlead;
        Test.stopTest();
    }

    @isTest
    static void unitTest24() { 
        List<Lead> lstlead = [SELECT id,nm_EscallationDone__c,nm_PlantoStart__c FROM Lead LIMIT 3];
        Test.startTest();
            for (Integer i = 0; i < lstlead.size(); i++) {
                if(i==0) {
                    lstlead[i].nm_EscallationDone__c = 0;
                    lstlead[i].nm_PlantoStart__c = '2-3 Week';
                } else if(i==1) {
                    lstlead[i].nm_EscallationDone__c = 1;
                    lstlead[i].nm_PlantoStart__c = '2-3 Week';
                } else if(i==2) {
                    lstlead[i].nm_EscallationDone__c = 2;
                    lstlead[i].nm_PlantoStart__c = '2-3 Week';
                } 
            }
            update lstlead;

            System.assertEquals(lstlead[0].nm_PlantoStart__c, '2-3 Week', 'Expected Value 2-3 Week');
        Test.stopTest();
    }

    @isTest
    static void unitTest25() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Account> lstAcc = [SELECT id,Pass_Out__c,nm_StudentStatus__c,nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c ='011564865' LIMIT 1];
        lstAcc[0].Pass_Out__c = true;
        lstAcc[0].nm_StudentStatus__c = 'De-Registered';
        update lstAcc;

        List<Lead> lstlead = [SELECT id,Email,mobilephone,Student_Number_Lateral__c,Is_Lateral__c,Loan_Type__c,Loan_Approved__c,EduVanz_lead_id__c FROM Lead LIMIT 1];
        Test.startTest();
            lstlead[0].Student_Number_Lateral__c = lstAcc[0].nm_StudentNo__c;
            lstlead[0].Is_Lateral__c = true;
            lstLead[0].Loan_Type__c = 'Avanse';
            lstlead[0].Loan_Approved__c = true;
            lstlead[0].EduVanz_lead_id__c = '123456';
            update lstlead;
        Test.stopTest();
    }
    
    @isTest
    static void unitTest26() { 
        nmLeadTriggerHandler handler =new nmLeadTriggerHandler();
    Test.startTest();
        handler.addInformationCenterBasedOnCurrentLocation('test','test','test');
        
    Test.stopTest();
        
    }
    
}