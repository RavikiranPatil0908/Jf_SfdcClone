/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 04-30-2024
 * @last modified by  : @vickysahu
**/
public class ScheduledMettingsWrapper {

	public class Meetings {
		public String agenda;
		public String created_at;
		public Integer duration;
		public String host_id;
		public Long id;
		public String join_url;
		public String pmi;
		public String start_time;
		public String timezone;
		public String topic;
		public Integer type;
		public String uuid;
	}

	public String next_page_token;
	public Integer page_count;
	public Integer page_number;
	public Integer page_size;
	public Integer total_records;
	public List<Meetings> meetings;

	
	public static ScheduledMettingsWrapper parse(String json) {
		return (ScheduledMettingsWrapper) System.JSON.deserialize(json, ScheduledMettingsWrapper.class);
	}
}