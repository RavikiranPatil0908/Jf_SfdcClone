/**
 * @File Name          : UpGradUpdateScoreRequestWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20/7/2019, 11:01:28 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    29/5/2019, 1:49:24 PM   @BK     Initial Version
**/
public class UpGradUpdateScoreRequestWrapper {

	public class Request {
		public String email;
		public Double total_score;
        public String submitted_at;
        public String time_taken;
        public String status;
		public Integer number_of_retakes;
        public String report_url;
		public List<Sectional_score> sectional_score;
	}

	public String authToken;
	public String source;
	public Request request;

	public class Sectional_score {
		public String section_name;
		public Double section_score;
	}

	
	public static UpGradUpdateScoreRequestWrapper parse(String json) {
		return (UpGradUpdateScoreRequestWrapper) System.JSON.deserialize(json, UpGradUpdateScoreRequestWrapper.class);
	}
}