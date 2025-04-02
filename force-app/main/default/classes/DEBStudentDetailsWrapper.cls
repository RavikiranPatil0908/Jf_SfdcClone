/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
public class DEBStudentDetailsWrapper{
	public String Message;	//Data retrival successful.
	public String Status;	//Process Success
	public Resource[] Resource;
	public class Resource {
		public String StudentID;	//345345
		public String Program;	//
		public String email;	//test@gmail.com
		public String stdname;	//test test
		public String fathername;	//
		public String mobile;	//9000000001
		public String cdate;	//Sep  2 2024  6:34PM
		public String institutename;	//
		public String InstituteID;	//
		public String ipaddress;	//192.000.00.37
		public String programcode;	//000000027388
		public String mode;	//
		public String AdmissionDate;	//
		public String AdmissionDetails;	//
		public String UniversityName;	//
		public String CourseName;	//
		public String ABCID;	//600000000785
		public String DEBUniqueID;	//090000000088
		public String Gender;	//Male
		public String DOB;	//15/06/1991
	}
	
	public static DEBStudentDetailsWrapper parse(String json){
		return (DEBStudentDetailsWrapper) System.JSON.deserialize(json, DEBStudentDetailsWrapper.class);
	}
}