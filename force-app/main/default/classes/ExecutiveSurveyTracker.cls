@isTest(SeeAllData=true)
public class ExecutiveSurveyTracker
{
    public static Lead objLead;
    public static Account objAccount;
    public static Survey_Question__c surveQ;
    public static Survey__c objsurve;
    public static String surveyId;
    public static String contactId;    
    public static String contactId2; 
    public static nm_EligiblityCriteria__c objEc;

    static Testmethod void testUpdateSurveyName() {
     
        LoadData(); 
        
        List<String> lstQuestion = new List<String>();

        for(Integer i=0;i<3;i++)
        {
        
        if(i==1) {
            surveQ = new Survey_Question__c();
            surveQ.Required__c =true;
            surveQ.Name='test';
            surveQ.OrderNumber__c=i;
            surveQ.Question__c='hgft';
            surveQ.Required__c =true;
            surveQ.Survey__c=objsurve.id;
            surveQ.Choices__c = 'Test';
            surveQ.Type__c='Multi-Select--Vertical';
            insert surveQ;
            System.debug('surveQ-->'+surveQ);
        }else{
            surveQ = new Survey_Question__c();
            surveQ.Required__c =true;
            surveQ.Name='test';
            surveQ.OrderNumber__c=i;
            surveQ.Question__c='hgft';
            surveQ.Required__c =true;
            surveQ.Survey__c=objsurve.id;
            surveQ.Choices__c = 'Test';
            surveQ.Type__c='Single Select--Vertical';
            insert surveQ;
            System.debug('surveQ-->'+surveQ);
        }

            lstQuestion.add(surveQ.id);

        }
        
        
        system.Test.startTest();
        Apexpages.currentPage().getParameters().put('id',objsurve.id);  
        Apexpages.currentPage().getParameters().put('stnu',objAccount.nm_StudentNo__c);
        

        Apexpages.Standardcontroller stc; 
        ExecutiveSurvey vsc = new ExecutiveSurvey(stc);

        vsc.questionId = lstQuestion.get(lstQuestion.size() - 1);

        vsc.saveAndNext();
        vsc.init();

        vsc.questionId = lstQuestion.get(1);
        vsc.saveAndNext();

        system.Test.stopTest();
         
    }

    static Testmethod void testUpdateSurveyName2() {
     
        LoadData(); 
        
        List<String> lstQuestion = new List<String>();

        for(Integer i=0;i<3;i++)
        {
        
        if(i==1) {
            surveQ = new Survey_Question__c();
            surveQ.Required__c =true;
            surveQ.Name='test';
            surveQ.OrderNumber__c=i;
            surveQ.Question__c='hgft';
            surveQ.Required__c =true;
            surveQ.Survey__c=objsurve.id;
            surveQ.Choices__c = 'Test';
            surveQ.Type__c='Multi-Select--Vertical';
            insert surveQ;
            System.debug('surveQ-->'+surveQ);
        }else{
            surveQ = new Survey_Question__c();
            surveQ.Required__c =true;
            surveQ.Name='test';
            surveQ.OrderNumber__c=i;
            surveQ.Question__c='hgft';
            surveQ.Required__c =true;
            surveQ.Survey__c=objsurve.id;
            surveQ.Choices__c = 'Test';
            surveQ.Type__c='Single Select--Vertical';
            insert surveQ;
            System.debug('surveQ-->'+surveQ);
        }

            lstQuestion.add(surveQ.id);

        }
        
        
        system.Test.startTest();
        Apexpages.currentPage().getParameters().put('id',objsurve.id);  
        Apexpages.currentPage().getParameters().put('lid',objLead.id);
        

        Apexpages.Standardcontroller stc; 
        ExecutiveSurvey vsc = new ExecutiveSurvey(stc);

        vsc.questionId = lstQuestion.get(lstQuestion.size() - 1);

        vsc.saveAndNext();
        vsc.init();

        vsc.questionId = lstQuestion.get(1);
        vsc.saveAndNext();

        system.Test.stopTest();
         
    }

    public static void LoadData() {
        objsurve =new Survey__c();
        objsurve.Name='test';
        objsurve.Hide_Survey_Name__c=true;
        objsurve.Submit_Response__c='hvgcdrt';
        objsurve.Survey_Container_CSS__c='hgfytfrtdrt';
        objsurve.Survey_Header__c='gfrtfty';
        objsurve.thankYouLink__c='hgf';
        objsurve.ShowResponseAfterSubmit__c=true;
        objsurve.Show_Result__c=true;
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

        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        
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
    }
}