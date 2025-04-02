/**
 * @File Name          : CancelAdmissionTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 7/3/2020, 5:39:38 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/24/2019   shubhranshu     Initial Version
**/
@istest(SeeAllData=true)
public class CancelAdmissionTracker 

{

       Public static nm_Centers__c objCen;
       Public static User objUser;
       Public static nm_UserMapping__c objUserMap;
       Public static nm_Program__c objProgram;
       Public static nm_WorkExperience__c objWrkExp;
       public static nmRefund_Payment__c objRefundPayment; 
       public static Account objAccount;
       public static Opportunity opps;
       public static nm_Program__c program;
       public static nm_Payment__c payment;
       public static nm_Payment__c paymentLateFee;
       public static nm_StudentProgram__c objSP;
 
      private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
  static testMethod  void testmethod1() 
    {   
      
        loadData();
      //  checkRecursive.ischeckcanceltrigger = true;
        objAccount.nm_StudentStatus__c='Admission Cancelled';
        
       /*   IC_Payment__c iOne = new IC_Payment__c();
        iOne.Payment_Month__c='12';
        iOne.Payment_Year__c='2015';
        iOne.Centers__c= opps.Account.nm_Centers__c;
        iOne.Amount__c = 1000 * 0.60;
        iOne.Payment_Due_Date__c = System.Today();
                      
        insert iOne;
        */
        Test.StartTest();
        update objAccount;
        Test.StopTest();
        
    }
    
    static void loadData()
    {
      Test.setMock(HttpCalloutMock.class, new RestMock());
    // List<Opportunity> lstOpps= new List<Opportunity>();
      List<nm_EligiblityCriteria__c> lstElegCritria= new List<nm_EligiblityCriteria__c>();
      List<Account> lstAcc1= new List<Account>();
      List<Lead>  lstLead = new List<Lead>();
      nm_EligiblityCriteria__c  objEC = new nm_EligiblityCriteria__c();
      CommonTrackerClass.createEligibiltyCriteria(objEC);
      lstElegCritria.add(objEC);
      System.debug('**eligibility'+objEC);
      nm_EligiblityCriteria__c  objEC1 = new nm_EligiblityCriteria__c();
      CommonTrackerClass.createEligibiltyCriteria(objEC1);
      lstElegCritria.add(objEC1);
              
   
        
        
      
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser;    
        
        
      
         Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
         objCen= new nm_Centers__c();
         objCen.RecordTypeID = RT.id;         
         objCen.nm_CenterCode__c = '002';
         objCen.nm_CenterCity__c = 'Delhi';
         objCen.nm_City__c = 'Delhi';
         objCen.nm_StateProvince__c = 'Delhi';
         objCen.nm_Street__c = 'Krishna Nagar';
         objCen.nm_PostalCode__c = '110051';
         objCen.name='Delhi - Pitampura';
        // objCen.Owner=objUser;
         
         insert objCen;
         
         objUserMap= new nm_UserMapping__c();
         objUserMap.nm_Centers__c=objCen.id;
         objUserMap.nm_User__c=objUser.id;
         objUserMap.nm_Phone__c='326392156';
         objUserMap.nm_Head__c= true;
         insert objUserMap;
      
        objAccount= new Account();  
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Admission form & documents submitted';       
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Centers__c=objCen.id;        
        objAccount.lastname ='singh';
        objAccount.nm_Gender__c = 'male';
        objAccount.nm_RegistrationNumber__c='011534567809';
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEC1.Id;
        objAccount.nmCaptureOpportuntiyStage__c='Registration Done';
        objAccount.ownerid = objUser.id;
        objAccount.PersonLeadSource = 'Web';
        insert objAccount;
        
        program = new nm_Program__c();
        program = CommonTrackerClass.createProgram(program);
        
        objSP = new nm_StudentProgram__c ();
        objSP.nm_Student__c = objAccount.id;
        objSP.nm_EligiblityCriteria__c =objEc1.id;
        objSP.nm_FeesPaidofSemester__c = 0;
        objSP.nm_Program__c = program.id;
        objSP.nm_CurrentSession__c =2;
        insert objSP;
        
        opps = new Opportunity(); 
        opps.Name = 'Opps Student';
        opps.AccountID = objAccount.id;
        opps.nm_InformationCenters__c = objCen.id;
        opps.nm_StudentEmail__c = objAccount.PersonEmail;
        opps.nm_Program__c = program.id;
        opps.StageName ='Closed Won';
        opps.nm_Semester__c = '1';
        opps.nm_Session__c = 'January';
        opps.nm_Year__c  = 2018;
        opps.CloseDate = system.today();
        opps.nm_Category__c = 'Admission';
        opps.nm_StudentProgram__c=objSP.id;
        
        
        insert opps;
        
        objSP.nm_FeesPaidofSemester__c = 1;       
        update objSP;
        
        payment = new nm_Payment__c();
        payment.nm_ModeOfPayment__c = 'Demand Draft';
        payment.nm_Amount__c = 17000;
        payment.nm_PaymentType__c = 'Admission';
        payment.nm_PaymentStatus__c='Payment Approved';
        payment.nm_OpportunityNew__c = opps.id;
        
        insert payment;
        
         IC_Payment__c iOne = new IC_Payment__c();
        iOne.Payment_Month__c='12';
        iOne.Payment_Year__c='2015';
        iOne.Centers__c= objCen.id;
        iOne.Amount__c = 1000 * 0.60;
        iOne.Payment_Due_Date__c = System.Today();
                      
        insert iOne;
        
        IC_Payment_Transaction__c ip2 = new IC_Payment_Transaction__c ();
        ip2.Amount__c = 10000;
        ip2.Narration__c ='test';
        ip2.IC_Payment__c = iOne.Id;
 
        ip2.Transaction_Type__c = 'Admission Commision - Credit';
        ip2.Due_Date__c = System.Today();
        ip2.Date__c =System.Today();
        ip2.Opportunity__c = opps.ID;
   
        ip2.Account__c = opps.AccountId;
        insert ip2;
        
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();
        ip.Amount__c = 10000;
        ip.Narration__c =' - Admission Cancellation';
        ip.IC_Payment__c = iOne.Id;
    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = System.Today();
        ip.Date__c =System.Today();
        ip.Opportunity__c = opps.ID;
    
        ip.Account__c = opps.AccountId;
        insert ip;
        /*nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
        if(payment.nm_PaymentType__c=='Admission' && opps.StageName == 'Closed Won' && (payment.nm_PaymentStatus__c=='Payment Made' || payment.nm_PaymentStatus__c=='Payment Approved'))
                            {
                             handler.createICShareDebitEntries(opps);
                            } */
        
        
   
        
        
        
        

     }
}