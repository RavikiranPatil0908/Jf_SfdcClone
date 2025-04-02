public without sharing class EmailToLCsController {
    
    public Id interviewSlotId;
    public List<Account> lstAccountDetail  {get;set;} 

    public Id getinterviewSlotId() {
        return this.interviewSlotId;
    }

    public void setinterviewSlotId(Id slotId) {
        this.interviewSlotId = slotId;
        if(interviewSlotId != null){
            getlstAccountDetail();
        }
    }
    
    public void  getlstAccountDetail(){
        if(interviewSlotId!=null)
        {
            this.lstAccountDetail = [select id,LC_email_id__c,LC_Name__c,nm_Centers__c,nm_ChooseaProgram__c,Rating_page_url__c,
                                               FirstName ,LastName , nm_RegistrationNumber__c , 
                                                PersonEmail,PersonMobilePhone  ,InterviewDateTime__c, Interview_Meeting_Id__c,Student_Info__c 
                                                from Account where Interview_Slot__c=:interviewSlotId ];

        }
        
    }
}