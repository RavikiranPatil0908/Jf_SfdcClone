/**
 * @File Name          : PropelledResponseWrapperTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 29/2/2020, 12:50:03 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/2/2020   @BK     Initial Version
**/
@IsTest
public class PropelledResponseWrapperTracker {
	
	static testMethod void testParse() {
		String json = '{'+
		'	\"Code\": 0,'+
		'	\"Message\": \"SUCCESS\",'+
		'	\"Errors\": [{'+
		'		\"Location\": \"body\",'+
		'		\"Param\": \"FirstName\",'+
		'		\"Msg\": \"FirstName should be present\",'+
		'		\"Code\": 1,'+
		'		\"Message\": \"Failed Creation\"'+
		'	}],'+
		'	\"Event\": \"application.loan.disbursed\",'+
		'	\"Entities\": [\"Application\", \"Loan\", \"Borrowers\", \"Disbursement\"],'+
		'	\"Payload\": {'+
		'		\"Application\": {'+
		'			\"ApplicationId\": 666,'+
		'			\"QuoteId\": \"5362179f-d56f-40d3-949a-99cf6888cdee\",'+
		'			\"Status\": \"APPROVED\",'+
		'			\"CourseId\": 541,'+
		'			\"CourseName\": \"Artificial Intelligence\",'+
		'			\"Notes\": null,'+
		'			\"ReferenceNumber\": \"\"'+
		'		},'+
		'		\"Loan\": {'+
		'			\"LoanAmount\": 50000,'+
		'			\"TotalTenor\": 12,'+
		'			\"MoratoriumPeriod\": 6,'+
		'			\"DiscountedCourseFee\": 65000'+
		'		},'+
		'		\"Borrowers\": {'+
		'			\"Applicant\": {'+
		'				\"Name\": \"Jane Doe\",'+
		'				\"Mobile\": \"9999999999\",'+
		'				\"Email\": \"jane.doe@test.com\"'+
		'			},'+
		'			\"CoApplicants\": [{'+
		'				\"Name\": \"John Doe\",'+
		'				\"Mobile\": \"9999999999\",'+
		'				\"Email\": \"john.doe@test.com\"'+
		'			}]'+
		'		},'+
		'		\"Disbursement\": [{'+
		'			\"TranchNumber\": 1,'+
		'			\"DisbursementAmount\": 50000,'+
		'			\"DisbursementDate\": \"2019-08-20\",'+
		'			\"DisbursementReference\": \"AIASDO311144141\"'+
		'		}]'+
		'	},'+
		'	\"CreatedOn\": \"2019-08-06 18:00:00\"'+
		'}';
		PropelledResponseWrapper obj = PropelledResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}