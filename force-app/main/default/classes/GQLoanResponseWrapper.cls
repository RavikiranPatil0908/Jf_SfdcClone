/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
public class GQLoanResponseWrapper{
	public boolean success;
	public Integer status_code;	//201
	public String message;	//Application Created successfully
	public cls_data data;
	public class cls_data {
		public String redirection_url;	//https://rapid.graydev.tech/anand-ay?sbdc=e756c865-51ca-40f4-a9a0-cf5efcc951ef&uid=6e898686-59c0-434e-875f-558c82e869e8
	}
	public static GQLoanResponseWrapper parse(String json){
		return (GQLoanResponseWrapper) System.JSON.deserialize(json, GQLoanResponseWrapper.class);
	}

	
}