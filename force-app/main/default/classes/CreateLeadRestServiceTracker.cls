@isTest(SeeAllData=false)
Public class CreateLeadRestServiceTracker
{
  public static lead objLead;
  private class RestMock implements HttpCalloutMock {
      RestMock() {
         
      }
      public HTTPResponse respond(HTTPRequest req) {
          // Can assert that the request is correct here
          // Generate a typical response
          String fullJson = '';
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
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Centers__c objCen = [SELECT Id FROM nm_Centers__c WHERE RecordType.Name = 'Learning Center' LIMIT 1];
        objCen.L1_Allotment__c = 80;
        update objCen;
        Agency_Access__c access =new Agency_Access__c();
        access.Name='DGM';
        access.password__c='DGM123';
        access.Is_Active__c=true;
        access.Email__c='sagar@gmail.com';
        insert access;
        Agency_Access__c access1 =new Agency_Access__c();
        access1.Name='StudentPortal';
        access1.password__c='portal@123';
        access1.Is_Active__c=true;
        access1.Email__c='portal@test.in';
        insert access1;
        nm_EscalationMatrix__c  escSetting = new nm_EscalationMatrix__c();
        escSetting.Name = '0-1 week';
        escSetting.nm_HOEscalationTime__c = '2:00';
        escSetting.nm_LCEscalationTime__c = '1:00';
        escSetting.nm_RemidertoHO__c = '2:00';
        escSetting.nm_RemidertoIC__c = '0:30';
        escSetting.nm_RemidertoLC__c = '1:00';
        escSetting.nm_SMLCEscalationTime__c = '4:00';        
        insert escSetting;

        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;

        Recordtype RTs=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCenCounsellor= new nm_Centers__c();

        objCenCounsellor.Nm_Active__c = true;
        objCenCounsellor.Name='Counsellor';
        objCenCounsellor.RecordTypeID = RTs.id;         
        objCenCounsellor.nm_CenterCode__c = '022';
        objCenCounsellor.ShareApplicable__c =true;
        objCenCounsellor.nm_CenterCity__c = 'Counsellor';
        objCenCounsellor.nm_City__c = 'Counsellor';
        objCenCounsellor.nm_StateProvince__c = 'Counsellor';
        objCenCounsellor.nm_Street__c = 'Krishna Nagar';
        objCenCounsellor.nm_PostalCode__c = '110051'; 
        objCenCounsellor.Sync_with_Portal__c =false;
        objCenCounsellor.OwnerId= UserInfo.getUserId();
        objCenCounsellor.Allow_PG__c= true;
        objCenCounsellor.Allow_Degree__c= true;
        objCenCounsellor.Allow_Bachelor__c= true;
        objCenCounsellor.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCenCounsellor.ConsumerType__c='Retail';
        insert objCenCounsellor;

        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        objUserMap.nm_Centers__c=objCenCounsellor.Id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;

        List < nm_Centers__c > lstCenter = [SELECT Id,L1_Allotment__c,L2_Allotment__c, L3_Allotment__c FROM nm_Centers__c WHERE  RecordType.Name = 'Learning Center' AND L1_Allotment__c != null ];
        String chooseProgram = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        String AgencyType = 'L1; L2; L3';
        RecordType RTSd = [SELECT Id, Name FROM RecordType WHERE Name = 'LC Assignment' LIMIT 1];
        List<Lead_Assignment__c> lstLeadAssigned = new List<Lead_Assignment__c>();
        for(nm_Centers__c objCenLc : lstCenter ) {
            lstLeadAssigned.add(new Lead_Assignment__c(Agency_Type__c = AgencyType, Choose_a_Program__c = chooseProgram, Assign_To__c = objCenLc.Id, Allotment_PG__c= objCenLc.L1_Allotment__c
            ,Allotment_MS__c= objCenLc.L2_Allotment__c, Allotment_UG__c= objCenLc.L3_Allotment__c, RecordTypeId = RTSd.Id, Active__c = TRUE  ));

        }
        system.debug('lstLeadAssigned ===> ' + lstLeadAssigned);
        insert lstLeadAssigned;
      
    }

    static TestMethod void unitTest1()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/createleadrestservice';
        RestContext.request.addHeader('httpMethod','POST');
        CreateLeadRestService.connectToEnquiry('First Name','dsgd1dgsg23hg@jgmail.com','9111334785','DGM','hsc',2017,'Mumbai','Diploma Programs','DGM123');
    }
    
  //  static testMethod void UnitTest()
  //   {
  //       System.RestContext.request = new RestRequest();
  //       RestResponse res = new RestResponse();
  //       RestRequest req = new RestRequest();
  //       RestContext.request.requestURI = 'https://services/apexrest/createleadrestservice';
  //       RestContext.request.addHeader('httpMethod','POST');
  //       CreateLeadRestService.connectToEnquiry('First Name','dsgd1dgsg23hg@jgmail.com','9111334785','google GSP','hsc',2017,'Mumbai','Diploma Programs','google.gsp@017');
        
        
  //       Agency = new Agency_Access__c();
  //       Agency.Name = 'google GSP';
  //       Agency.Email__c ='dgm@gmail.com';
  //       Agency.Is_Active__c=true;
  //       Agency.password__c='google.gsp@017';
  //       insert Agency;

  //       nm_EscalationMatrix__c  escSetting = new nm_EscalationMatrix__c();
  //       escSetting.Name = '0-1 week';
  //       escSetting.nm_HOEscalationTime__c = '2:00';
  //       escSetting.nm_LCEscalationTime__c = '1:00';
  //       escSetting.nm_RemidertoHO__c = '2:00';
  //       escSetting.nm_RemidertoIC__c = '0:30';
  //       escSetting.nm_RemidertoLC__c = '1:00';
  //       escSetting.nm_SMLCEscalationTime__c = '4:00';        
  //       insert escSetting;

  //       SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
  //       objSystemConfiguration.name='test';
  //       objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
  //       objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
  //       objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
  //       objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
  //       objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
  //       insert objSystemConfiguration;
        
  //       objLead = new Lead();
  //       objLead.FirstName = 'sandip';
  //       objLead.LastName = 'babar';
  //       objLead.Email = 'sac@gmail.com';
  //       objLead.Status = 'Not Contacted';
  //       objLead.MobilePhone = '8887373737';
  //       objLead.LeadSource = 'Web';
  //       objLead.nm_ChooseaProgram__c = 'DGM';
  //       objLead.nm_PlantoStart__c = '0-1 Week';
  //       objLead.nm_Year__c = 2017;
  //       objLead.nm_SelectedIC__c = 'Mumbai';
  //       objLead.Highest_Qualification__c = 'Degree';
  //       objLead.Agency__c = 'HT';
  //       objLead.nm_Lead_Category__c = 'Distance Learning / Correspondence';
  //       objLead.nm_IPForLead__c= '10.10.11';
  //       insert objLead;
  //   }
    
     static testMethod void DoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();



    req.requestURI = System.Label.Site_Url+'services/apexrest/createleadrestservice.json?Name=Test&Email=tesfryeyt@gmail.com&ContactNo=8852603567&CourseIntrestedIn=Diploma%20Programs&AdmissionYear=2017&CurrentLocation=Mumbai&HighestQualification=12&AgencyPassword=google.gsp@017&Agency=google%20GSP&AdmissionYear=2014';  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    
    CreateLeadRestService.doGet();
  
  }
    
}