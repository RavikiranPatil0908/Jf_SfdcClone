/**
 * @File Name          : PropelledResponseWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-08-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/2/2020   @BK     Initial Version
**/
public class PropelledResponseWrapper {

	public class Errors {
		public String Location;
		public String Param;
		public String Msg;
		public Integer Code;
		public String Message;
	}

	public class Loan {
		public Integer LoanAmount;
		public Integer TotalTenor;
		public Integer MoratoriumPeriod;
		public Integer DiscountedCourseFee;
		public Integer AppliedLoanAmount;
	}

	public class Borrowers {
		public Applicant Applicant;
		public List<Applicant> CoApplicants;
	}

	public class Payload {
		public Application Application;
		public Loan Loan;
		public Borrowers Borrowers;
		public List<Disbursement> Disbursement;
		public String QuoteId;
		public String RedirectionUrl;
		public Integer PropelldInstituteId;
		public Integer PropelldCourseId;
		public Boolean StatusUpdated;
	}

	public Integer Code;
	public String Message;
	public List<Errors> Errors;
	public String Event;
	public List<String> Entities;
	public Payload Payload;
	public String CreatedOn;

	public class Disbursement {
		public Integer TranchNumber;
		public Decimal DisbursementAmount;
		public String DisbursementDate;
		public String DisbursementReference;
	}

	public class Application {
		public Decimal ApplicationId;
		public String QuoteId;
		public String Status;
		public Integer CourseId;
		public String CourseName;
		public Object Notes;
		public String ReferenceNumber;
	}

	public class Applicant {
		public String Name;
		public String Mobile;
		public String Email;
	}

	
	public static PropelledResponseWrapper parse(String json) {
		return (PropelledResponseWrapper) System.JSON.deserialize(json, PropelledResponseWrapper.class);
	}
}