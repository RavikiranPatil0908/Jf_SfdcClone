public class AvanseResponseWrapper{
    public boolean status;
	public cls_information information;
	public cls_data data;
	public class cls_information {
		public String code;	//201
		public String message;	//Created successfully
	}
	public class cls_data {
		public String application_no;	//AVUPSKLNG388141
		public String application_status;	//In-Progress
		public String link;	//https://avansedev.kelltontech.net/create-user?ct=rKpFoHRrahTNPkX9ul10lnWcyqdZCLNcRP/N2/+cMaLQKjv3D/JZDzQt CHeylgzr1rzipLpz26RKUImYtvD4rNT0cMioTgSN+NvArJpDOPEvuAdEDHj9Y7X+ AICHC+rK79daltR5hP1tOiQ8L8p0fYNTB+Pa2qQTQqbw7r8t0s0=&iv=604f3e5a 83e31e01f7a86b333179e6f5&s=b43ec8869bc350ca
		public cls_applicant_data applicant_data;
	}
	public class cls_applicant_data {
		public Integer loan_amount;	//20000
		public String discount;	//9000
		public Integer down_payment_value;	//10000
	}
	public static AvanseResponseWrapper parse(String json){
		return (AvanseResponseWrapper) System.JSON.deserialize(json, AvanseResponseWrapper.class);
	}

}