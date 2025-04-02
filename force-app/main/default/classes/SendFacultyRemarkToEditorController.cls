public class SendFacultyRemarkToEditorController {
    public String recordId {get; set;}
    public Async_Shoot_Post_Production__c asyncObject {get; set;}
    public SendFacultyRemarkToEditorController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(recordId)) {
            asyncObject = [SELECT Id, Subject__c, Name,Chapter_Name__c,Acads_Team_Remarks__c,Editor_Name__c,Recording_Platform__c,Topics_Covered__c,Faculty_Name__c,Shoot_Date__c,Final_Video_Link__c,Video_Link_Version_1__c,Video_Link_Version_2__c,Video_Link_Version_3__c,Faculty_Remarks_for_Edit_Version_1__c, Faculty_Remarks_for_Edit_Version_2__c FROM Async_Shoot_Post_Production__c where id =:recordId ];
        }
    }


}