@isTest
public class ViewSurveyControllerTracker
{
public static Account objAccount;
 public static Survey_Question__c surveQ;
 public static Survey__c objsurve;
  public static String surveyId;
  public static String contactId;    
  public static String contactId2; 
  public static String caseId; 
  public static nm_EligiblityCriteria__c objEc;
 
 private static Testmethod void testUpdateSurveyName() {
     
      objsurve =new Survey__c();
      objsurve.Name='test';
      objsurve.Hide_Survey_Name__c=true;
      objsurve.Submit_Response__c='hvgcdrt';
      objsurve.Survey_Container_CSS__c='hgfytfrtdrt';
      objsurve.Survey_Header__c='gfrtfty';
      objsurve.thankYouLink__c='hgf';
      insert objsurve;
      
      surveyId = objsurve.id;
      
      
         objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='Bachelor degree';
         objEc.Is_Active__c = true;
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.Experience_Required_In_Year__c= null ;
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Post Graduate Diploma Programs';
         objEc.Graduation_Required__c =false;
         insert objEc;
     
      
        objAccount =new Account();
        objAccount.nm_StudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Admission form & documents Approved';    
        objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.Is_Lateral__c=true;       
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.Shipping_Address_Choice__c= 'Shipping Address as Billing Address';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_EligiblityCriteria__c =objEc.id;
        objAccount.nmStudent_Program__c ='Advance Certificate in Digital Marketing';

        
        insert objAccount;
      
     Contact c = new Contact();
    c.LastName = 'Doe';
    c.FirstName = 'John';
    c.Email = 'surveyAppUser@hotmail.com';
    c.account= objAccount;
    insert c;
    contactId = c.Id;   
    
    Contact c2 = new Contact();
    c2.LastName = 'Doe2';
    c2.FirstName = 'John2';
    c2.Email = 'surveyAppUser2@hotmail.com';
    insert c2;
    contactId2 = 'none';   
    
    Case c3 =new Case();
    c3.Status= 'New';
    c3.Contact = c2;   
    c3.Subject ='Book misplaced';
    c3.StudentZone_QueryId__c ='2261';
    c3.SuppliedEmail ='sachin920@gmail.com';
    c3.Description ='Fedex has lost my book';
    insert c3;
    
    caseId = c3.id;
    
    
     
      surveQ = new Survey_Question__c();
      surveQ.Required__c =true;
      surveQ.Name='test';
    //  surveQ.Choices__c='hgftyfty';
      surveQ.OrderNumber__c=254;
      surveQ.Question__c='hgft';
      surveQ.Required__c =true;
      surveQ.Survey__c=objsurve.id;
      surveQ.Type__c='Single Select--Horizontal';
      insert surveQ;
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.currentPage().getParameters().put('caid',caseId);
        Apexpages.currentPage().getParameters().put('stnu',c2.Account.nm_StudentNo__c);
      Apexpages.Standardcontroller stc; 
     ViewSurveyController vsc = new ViewSurveyController(stc);
     
      ViewSurveyController.checkRequired('test',surveQ);
      vsc.resultPage();
      vsc.submitResults();
      vsc.AddSurveyTaker();
      vsc.refreshQuestionList();
       vsc.init();
      vsc.surveyName = 'new name';
      system.assert(vsc.updateSurveyName() == null);
      
  }
   private static Testmethod void testupdateSurveyThankYouAndLink() {
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
    Apexpages.Standardcontroller stc; 
   ViewSurveyController vsc = new ViewSurveyController(stc);
    vsc.surveyThankYouText = 'new stuff';
    vsc.surveyThankYouURL = 'more new stff';
    vsc.refreshQuestionList();
    system.assert(vsc.updateSurveyThankYouAndLink()==null);
  }
  }