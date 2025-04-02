/**
 * @File Name          : DeleteZoomMeetings.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 05-11-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    12/8/2019, 12:07:28 PM   @BK     Initial Version
**/
public class DeleteZoomMeetings implements Queueable, Database.AllowsCallouts {

    private List<String> zoomMeetingIds;
    private String token;

    public DeleteZoomMeetings(List<String> zoomMeetingIds,String token) {
        this.zoomMeetingIds = zoomMeetingIds;
        this.token = token;
    }

    public void execute(QueueableContext context) {
        ZoomWebService objZoomWebService = new ZoomWebService();
        for (String meetingId : zoomMeetingIds) {
            System.debug('meetingId -->'+meetingId);
            Boolean meetingDeleted = objZoomWebService.deleteMeeting(meetingId,token);
            System.debug('meetingDeleted -->'+meetingDeleted);
        }
    }

}