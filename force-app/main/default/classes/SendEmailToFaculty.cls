/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : @vickysahu
**/
global class SendEmailToFaculty {
    
    WebService static void callEmailAlertFlow(String recordId, String recordName, String remark, String emailId, String Subject, String ShootDate, String TopicsCovered, String ChapterName, String FacultyName, String videoRemark) {
        Map<String,Object> params = new Map<String, Object>();
        params.put('recordId',recordId);
        params.put('recordName',recordName);
        params.put('toMailId', emailId);
        params.put('remark', remark);
        params.put('Subject', Subject);
        params.put('TopicsCovered', TopicsCovered);
        params.put('ShootDate', ShootDate);
        params.put('ChapterName', ChapterName);
        params.put('facultyName', FacultyName);
        params.put('videoRemark', videoRemark);
        
        Flow.Interview.Send_Video_Remark_Form_Link flow1 = new Flow.Interview.Send_Video_Remark_Form_Link(params);
        flow1.start();
    }
}