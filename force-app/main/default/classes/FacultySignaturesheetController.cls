public with sharing class FacultySignaturesheetController {

    public String InterviewId{get;set;}
    // public Id FacultyId;
    public List<Interview_Slot__c> Interviewslot {get;set;}

    public FacultySignaturesheetController()
    {
        InterviewId=ApexPages.currentPage().getParameters().get('InterviewId');
        if(InterviewId != null){
            getInterviewDetail();
        }

    }
   
    public void  getInterviewDetail(){
        if(InterviewId!=null)
        {
            this.Interviewslot = [Select Id, Name, Faculty_name_1__c,Interview_Date__c,Start_time__c,End_time__c From Interview_Slot__c Where Id =: InterviewId ];

        }
    }
}