public with sharing class InterviewSlotApprovalController {
    public String InterviewSlotID;
    public List<Account> lstAccount {get; set;}
    public InterviewSlotApprovalController() {
        System.debug('InterviewSlotApprovalController --> ');
        lstAccount = new List<Account>();
    }
    public String getInterviewSlotID() {
        return this.InterviewSlotID;
    }
    public void setInterviewSlotID(String InterviewSlotID) {
        system.debug('InterviewSlotID --> ' + InterviewSlotID);
        this.InterviewSlotID = InterviewSlotID;
        if(String.isNotBlank(InterviewSlotID) ){
             getListOfAccount();
          
        }
	}

    public void getListOfAccount() {
        if(String.isNotBlank(InterviewSlotID)) {
            List<String> lstOFApproval = new List<String>{'Approval Pending'};
             lstAccount = [SELECT Id, Name From Account WHERE Interview_Slot__c = :InterviewSlotID AND Interview_Status__c IN:lstOFApproval ];

        }
    }
}