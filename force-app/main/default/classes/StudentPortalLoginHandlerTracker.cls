@istest (SeeAllData=false)
public with sharing class StudentPortalLoginHandlerTracker {
    public StudentPortalLoginHandlerTracker() {

    }
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"success":"true","message":"SuccessFully Added!"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    public static void setUpData(){
      //Test.setMock(HttpCalloutMock.class, new RestMock());
        Account acc1 = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('No',false,'Confirmed');
        // acc1.Synced_With_LDAP__c = true;
        // update acc1;
        Opportunity opp1 = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Bachelor Programs',acc1,'AnnualFee');
        nm_Payment__c pay1 = CreatePaymentRecords(opp1.Id,'Admission','Opportunity','installmentRef123','Payment Approved');

        // Account acc2 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('No',false,'Confirmed');
        // acc2.Synced_With_LDAP__c = true;
        // update acc2;
        // Opportunity opp2 = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Bachelor Programs',acc2,'AnnualFee');
        // nm_Payment__c pay2 = CreatePaymentRecords(opp2.Id,'Admission','Opportunity','installmentRef123','Payment Disapproved');
        
    }

    @isTest
    public static void test1()
    {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    nm_Payment__c paymentobj = [Select Id,nm_PaymentStatus__c,nm_PaymentDissapproved__c,Student_Status__c,nm_OpportunityNew__c from nm_Payment__c where nm_PaymentStatus__c ='Payment Approved' limit 1 ];
    map<id,nm_Payment__c> oldMap = new map<id,nm_Payment__c>();
    oldMap.put(paymentobj.Id,paymentobj);

    List<nm_Payment__c> paymentlst = new List<nm_Payment__c>();
    paymentobj.nm_PaymentStatus__c ='Payment Disapproved';
    paymentobj.nm_PaymentDissapproved__c = 'test';
    update paymentobj;
    paymentlst.add(paymentobj);

      
      StudentPortalLoginHandler.StudentStatusChangeFromPayment(paymentlst,oldMap);
      Test.stopTest();
    }
    // @isTest
    // public static  void test2()
    // {
    // Test.setMock(HttpCalloutMock.class, new RestMock());
    // Test.startTest();
    // nm_Payment__c paymentobj = [Select Id,nm_PaymentStatus__c,nm_PaymentDissapproved__c,Student_Status__c,nm_OpportunityNew__c from nm_Payment__c where nm_PaymentStatus__c ='Payment Disapproved' limit 1 ];
    // map<id,nm_Payment__c> oldMap = new map<id,nm_Payment__c>();
    // oldMap.put(paymentobj.Id,paymentobj);

    // List<nm_Payment__c> paymentlst = new List<nm_Payment__c>();
    // paymentobj.nm_PaymentStatus__c ='Payment Approved';
    // paymentobj.nm_PaymentDissapproved__c = 'test';
    // update paymentobj;
    // paymentlst.add(paymentobj);

    
    //   StudentPortalLoginHandler.StudentStatusChangeFromPayment(paymentlst,oldMap);
    //   Test.stopTest();
    // }

    public static nm_Payment__c CreatePaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef, String paymentstatus){
        nm_Payment__c objPayment = new nm_Payment__c ();
        if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }
        if('CareerServiceProgram__c'.equalsIgnoreCase(SObjectAPIName)){
          objPayment.CareerServiceProgram__c = recordId;
        }
      // }else {
      //       objPayment.nm_Lead__c  = recordId;
      //   }
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c =paymentstatus;
        objPayment.nm_PaymentDissapproved__c = 'test';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        objPayment.nm_Installment_Payment_Ref__c = installmentRef;
        insert objPayment;
        return objPayment;
    }

    public static  nm_EligiblityCriteria__c CreateElegibilityCriteria()
    {
        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor degree';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c= null ;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c ='Post Graduate Diploma Programs';
        objEc.Graduation_Required__c =false;
        objEc.Mandatory_Document_list__c = '10th Marksheet';
        insert objEc;
        return objEc;
    }

    public static nm_Centers__c CreateCenter(String centerName)
    {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        nm_Centers__c objLcCen = CreateLearningCenter('Mumbai - Mira Road East');

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name='Mumbai';
        
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
       // nm_UserMapping__c objuser = new nm_UserMapping__c (); 
     //  CreateICAndUser2(objCen);
        return objCen;
    }

    public Static PriceBook2 CreatePriceBook()
    {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
    }
    public static nm_Program__c CreatePGDiplomaProgram()
    {
        return CreateProgram('Post Graduate Diploma Programs','Post Graduate Diploma in Business Management',4,'');
    }
    public static Account CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2(String IsDefence,boolean IsLateral,String studentStatus)
    {
        nm_EligiblityCriteria__c objEc = CreateElegibilityCriteria();
        nm_Centers__c objCen = CreateCenter('Mumbai');
        PriceBook2 priceBook = CreatePriceBook();
       nm_Program__c  program = CreatePGDiplomaProgram();
        String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        Account  objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentNo__c= '77216433684';
        objAccount.nm_DateOfBirth__c= date.newInstance(1990, 12, 9);
        objAccount.nm_RegistrationNumber__c ='011564865';
        objAccount.nm_StudentStatus__c=studentStatus;       
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonLeadSource = 'Web';
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.ValidUptoR__c='June 2020';
         objAccount.nm_LeadId__c='00QO0000003JgdZ';
         objAccount.nm_Program__c = program.id;
        objAccount.Is_Lateral__c= IsLateral;       
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c = IsDefence;
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra'+randomNumber+'@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721'+Integer.valueOf(randomNumber);
        objAccount.PersonEmail='chandra'+randomNumber+'@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.Zip_Postal_Code_Shipping__c ='400043';
        //objAccount.Owner=objUser;
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Tagged_Pricebook__c = priceBook.id;
        objAccount.Sms_Status__c='Success';
        objAccount.smsSendTime__c = system.now();
        objAccount.EmailSendTime__c = system.now();
        objAccount.nmStudent_Program__c ='Post Graduate Diploma in Business Management';
        objAccount.nm_Centers__c=objCen.id;
        objAccount.Synced_With_LDAP__c = true;
        insert objAccount;
        return objAccount;
    }

    public static nm_Program__c CreateProgram(String typeOfProgram,String ProgramName,decimal totalSem,String sepcialization)
    {
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
       return program;
    }
    public static String generateRandomString(Integer length) {
      String charString = '9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAabcdefghijklmnopqrstuvwxyz!@#$&_';
      String randomNew = '';
      while (randomNew.length() < length) {
          Integer changeInt5 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
          randomNew += charString.substring(changeInt5 , changeInt5 +1);
      }
      randomNew = randomNew.left(4);
      return randomNew;
  }

  public static nm_Centers__c CreateLearningCenter(String centerName)
    {
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
        return objCen;
    }
}