@istest
public class nmPrintPreviewController_Lead1Tracker
{    
    public static Lead objLead;
    public static nm_WorkExperience__c objWorkExp;
    public static nm_EligiblityCriteria__c eligibility;
    public static  RecordType AccountRecordType  = [select id,Name from RecordType where SobjectType='Account' and name='Person Account'];
    private static nm_Centers__c   objcenter;
    private static nm_UserMapping__c objMap;
    private static nm_UserMapping__c obuse;
   
    static  testmethod  void unitTest1()
    {     
         
       LoadData();
       PageReference pg = new PageReference('/apex/nm_PrintRegistrationForm');
       Test.setCurrentPage(pg);apexpages.currentpage().getparameters().put('id',objLead.id);
       apexpages.currentpage().getparameters().put('date',String.ValueOf(system.today()));
       apexpages.currentpage().getparameters().put('city','Delhi');
       nmPrintPreviewController_Lead objnmPrint=new nmPrintPreviewController_lead();
       
    }
    public static void LoadData()
    {
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead); 
    }   

           
}