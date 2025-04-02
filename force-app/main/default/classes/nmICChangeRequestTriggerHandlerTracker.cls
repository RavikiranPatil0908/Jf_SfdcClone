@istest
public class nmICChangeRequestTriggerHandlerTracker 
{
    public static  Opportunity objopp;
    public static  nm_Payment__c objPayment;
    public static OpportunityLineItem objLineItem ;
    public static Account objAccount;
    public static  nmSerialNo__c objSerial;
    public static IC_Change_Request__c objICR;
     public static nm_Program__c program;

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

    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
         objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
         objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'Admission');
         program = nmGenericTracker.CreatePGDiplomaProgram();
         nmGenericTracker.CreateOpportunityLineItem(objopp);
         Id priceBooke2Id = [select id,nm_Tagged_Pricebook__c from Account limit 1].nm_Tagged_Pricebook__c;
         objAccount.nm_Tagged_Pricebook__c =String.valueOf(priceBooke2Id).substring(0, 15);
         update objAccount;
         system.debug('priceBooke2Id ==> '+ priceBooke2Id);
         Product2 lateFeeproduct = nmGenericTracker.CreatelateProduct(objopp);
            nmGenericTracker.createProductAndPricebookEntry('Annual',null,null,priceBooke2Id);
            nmGenericTracker.createProductAndPricebookEntry('Live Lectures',null,null,priceBooke2Id);
            nmGenericTracker.createProductAndPricebookEntry('Student Kits',null,null,priceBooke2Id);
            nmGenericTracker.createProductAndPricebookEntry('Program Change Fee',null,null,priceBooke2Id);
            nmGenericTracker.createProductAndPricebookEntry('IC Change Fee',null,null,priceBooke2Id);

         objICR = nmGenericTracker.CreateICChangeRequest(objopp);
    }
    // static testMethod void unitTest1()
    // {
    //     LoadData();  
    //     nmICChangeRequestTriggerHandler icchange = new nmICChangeRequestTriggerHandler ();
    //     pricebook2 pricenook2 = [SELECT Id,isStandard, IsActive FROM pricebook2 LIMIT 1 ];
    //     system.debug('pricenook2 ---> ' + pricenook2);
    //     PriceBookEntry pricebook = [select id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c,product2.isActive,pricebook2.isStandard,Pricebook2.id, Pricebook2.IsActive  from PriceBookEntry LIMIT 1];
    //    PriceBookEntry pricebook1 = pricebook.clone();
    //     pricebook1.Pricebook2Id = pricenook2.Id;
    //     insert pricebook1;
    //     system.debug('pricebook ---> ' + pricebook);
    //     objAccount.nm_Tagged_Pricebook__c = pricebook.Id;
    //     update objAccount;
    //     icchange.MonthYearValue(1,2018,5);
    //    Set<id> setOpp =new set<id>();
    //      setOpp.add(objopp.id);
    //     icchange.GenerateFixedDebitandCreditToInfoCenterOnApproval(setOpp,'Pune - Karve Road','Mumbai - Mira Road East');
    // }
    
    
    // static testMethod void unitTest2()
    // {
    //     LoadData(); 
    //     set<id> setOpp=new set<id>();
    //     setOpp.add(objopp.id); 
    //     nmICChangeRequestTriggerHandler icchange = new nmICChangeRequestTriggerHandler ();
    //     icchange.MonthYearValue(1,2018,14);
    //     icchange.GenerateFixedDebitandCreditToInfoCenterOnApproval(setOpp,'Pune - Karve Road','Mumbai');
    // }
    
    
    // static testMethod void unitTest3()
    // {
    //     LoadData(); 
    //     set<id> setOpp=new set<id>();
    //     setOpp.add(objopp.id); 
    //     nmICChangeRequestTriggerHandler icchange = new nmICChangeRequestTriggerHandler ();
    //    // icchange.setDataForPayment(objopp);
    // }
    // static testMethod void unitTest4()
    // {
    //     LoadData(); 
    //     List<nm_EligiblityCriteria__c> lstElig = [SELECT Id FROM nm_EligiblityCriteria__c LIMIT 1];
    //     Map<id, IC_Change_Request__c> oldMap = new Map<Id,IC_Change_Request__c >();
    //     oldMap.put(objICR.Id, objICR);
    //     objICR.Status__c = 'Disapproved';
    //     objICR.nm_TypeofRequest__c = 'Program Change';
    //     objICR.Eligibility_Criteria__c = lstElig[0].Id;

    //     update objICR;
    //     nmICChangeRequestTriggerHandler icchange = new nmICChangeRequestTriggerHandler ();
    //     icchange.DisapprovedServiceRequest(new List<IC_Change_Request__c>{objICR}, oldMap);
    //    // icchange.setDataForPayment(objopp);
    // }
    
    
    
     
    // static void LoadData()
    // {
    //      Test.setMock(HttpCalloutMock.class, new RestMock()); 
         
    //      objICR.Status__c = 'Approved';
    //      objICR.ChangeAmount__c= 10;
    //      objICR.Student_Kits__c= true;
    //      update objICR;
    // }

    @IsTest
    static void methodName1(){
        Account objAcc = [SELECT Id,nm_EligiblityCriteria__c,nm_Program__c, nm_Tagged_Pricebook__c  FROM Account LIMIT 1];
        System.debug('objAcc ==> ' + objAcc);
        nm_EligiblityCriteria__c objEl = new nm_EligiblityCriteria__c(Id = objAcc.nm_EligiblityCriteria__c);
        objEl.Name = 'Bachelor with 55% and 3 yr Work exp.';
        objEl.nm_Documnetslist__c = 'Photo ID proof; Student Photograph; Aadhaar Card; Work Experience Certificate – 2 years; 10th Mark Sheet OR Certificate; 12th Mark Sheet OR Certificate; Degree Mark Sheet; Degree Certificate; AIU Certificate (For Foreign University)';
        update objEl;
        System.debug('objEl ===> ' + objEl);
        IC_Change_Request__c  objIc = [SELECT Id FROM IC_Change_Request__c LIMIT 1];
        nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAcc.id;
         objSP.nm_EligiblityCriteria__c =objAcc.nm_EligiblityCriteria__c;
         objSP.nm_FeesPaidofSemester__c = 1;
         objSP.nm_Program__c = objAcc.nm_Program__c;
         insert objSP;
        IC_Change_Request__c icr = new IC_Change_Request__c(Id = objIc.Id);
        icr.Status__c = 'Disapproved'; 
        icr.nm_TypeofRequest__c = 'Program Change'; 
        icr.Eligibility_Criteria__c = objAcc.nm_EligiblityCriteria__c; 
        update icr;
        Test.startTest();

        Test.stopTest();
        
    }

    @IsTest
    static void methodName(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        objAccount.nm_StudentNo__c= '77200433684';
        update objAccount;
        nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test234';
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = 'Bachelor of Business Administration';
       program.nm_ProgramValidity__c = 4.0;
       program.nm_TotalSemesters__c = 4.0;
       program.nm_Type__c = 'Bachelor Programs';
       program.prgst__c ='Jul2019';
       program.Name ='BBA';
       program.Specialisation__c ='BBA';
       insert program;
        nm_Program__c program1 = new nm_Program__c();
       program1.nmIsActive__c = true;
       program1.nm_ProgramCode__c = 'test23456';
       program1.nm_ProgramDuration__c= 2.0;
       program1.nm_ProgramName__c = 'Bachelor of Business Administration - Business Analytics';
       program1.nm_ProgramValidity__c = 4.0;
       program1.nm_TotalSemesters__c = 4.0;
       program1.nm_Type__c = 'Bachelor Programs';
       program1.prgst__c ='Jul2019';
       program1.Name ='BBA-BA';
       program1.Specialisation__c ='BA';
       insert program1;
        nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAccount.id;
         objSP.nm_FeesPaidofSemester__c = 1;
         objSP.nm_Program__c = program.id;
         insert objSP;

       Opportunity objopp =new Opportunity();
        objopp.StageName = 'Pending Payment';
        objopp.nm_Fee_Type__c  = 'admission';
        objopp.nm_Payment_Approved__c =true;
        objopp.processed__c = false;
        objopp.nm_Session__c = 'January';
        objopp.nm_Year__c = 2019;
        objopp.CloseDate=System.today();
        objopp.nm_Semester__c= '2';
        objopp.Name='Chandra_gh_DSCM_Sem_1_Jan_2015';
        objopp.AccountId = objAccount.id; 
        objopp.nm_Program__c = program.id;
        objopp.nm_LateFee__c=1000;
        objopp.Amount=500.00; 
        objopp.TermRepeated__c= false;
        objopp.nm_Session__c='July';
        objopp.nm_Year__c=2020;
        objopp.nm_SelfLearningMaterial__c  ='Send to my Information Centre. I will pick up.';
        objOpp.nm_Category__c = 'Admission';
        insert objopp;



        nm_Centers__c objCenter = nmGenericTracker.CreateCenter('Mumbai-Mira');
        nm_Centers__c objCenter1 = nmGenericTracker.CreateCenter('Pune-Road');
        // nmGenericTracker.CreateICAndUser(objCenter);
        // nmGenericTracker.CreateICAndUser1(objCenter1);
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        objCR.Status__c='New';
        objCR.Student__c= objAccount.Id;
        objCR.Opportunity__c=objopp.id;
        objCR.nm_TypeofRequest__c='Program Change';
        objCR.nm_Reson__c='test test';
        objCR.New_Information_Center__c=objCenter1.id;
        objCR.Current_Information_Center__c=objCenter.id;
        objCR.New_Program__c=program1.id;
        objCR.Student_Kits__c=true;
        insert objCR;

        IC_Change_Request__c objCR1 = new IC_Change_Request__c ();
        objCR1.Status__c='New';
        objCR1.Student__c= objAccount.Id;
        objCR1.Opportunity__c=objopp.id;
        objCR1.nm_TypeofRequest__c='Program Change';
        objCR1.nm_Reson__c='test test';
        objCR1.New_Information_Center__c=objCenter1.id;
        objCR1.Current_Information_Center__c=objCenter.id;
        // objCR1.New_Program__c=program1.id;
        // objCR1.Student_Kits__c=true;
        objCR1.ChangeAmount__c= 200;
        insert objCR1;

        Test.startTest();

        Test.stopTest();
        
    }
}