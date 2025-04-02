public  class InterviewEmailController {
    
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
            this.lstAccountDetail = [select id, Rating_page_url__c,FirstName ,LastName ,nm_RegistrationNumber__c , 
                                                PersonEmail,PersonMobilePhone  ,InterviewDateTime__c, Interview_Meeting_Id__c,Student_Info__c 
                                                from Account where Interview_Slot__c=:interviewSlotId ];

        }
        
    }

    
}