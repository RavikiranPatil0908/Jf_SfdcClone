/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @vickysahu
**/
public class ZoomRecordingWrapper {

	public String uuid;
	public Long id;
	public String account_id;
	public String host_id;
	public String topic;
	public Integer type;
	public String start_time;
	public String timezone;
	public String host_email;
	public Integer duration;
	public Integer total_size;
	public Integer recording_count;
	public String share_url;
	public List<Recording_files> recording_files;
	public String password;
	public String recording_play_passcode;

	public class Recording_files {
		public String id;
		public String meeting_id;
		public String recording_start;
		public String recording_end;
		public String file_type;
		public String file_extension;
		public Integer file_size;
		public String play_url;
		public String download_url;
		public String status;
		public String recording_type;
	}

	
	public static ZoomRecordingWrapper parse(String json) {
		return (ZoomRecordingWrapper) System.JSON.deserialize(json, ZoomRecordingWrapper.class);
	}
}