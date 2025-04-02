/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-08-2024
 * @last modified by  : @BK
**/
@isTest
public class GetMandatoryDocumentsTracker {

    @isTest
    static void unitTest1() {

        Test.startTest();
            // Create test data
            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            nm_WorkExperience__c workExp2 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company B'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1, workExp2};

            // Test case 1: Basic eligibility
            GetMandatoryDocuments.StudentStatus status1 = new GetMandatoryDocuments.StudentStatus();
            status1.eligibilityCriteria = 'HSC';
            status1.chooseProgram = 'Other';
            status1.hscStatus = 'Passed';
            status1.diplomaStatus = 'Not Applicable';
            status1.isDefencePersonnel = 'No';
            status1.isDifferentlyAbled = 'No';
            status1.isLateral = false;
            status1.studentProgram = '';
            status1.lstWk = new List<nm_WorkExperience__c>{workExp1, workExp2};

        
            GetMandatoryDocuments docService = new GetMandatoryDocuments();
            Set<String> documents1 = docService.getMandatoryDocumentsName(status1);
        Test.stopTest();
        
        System.assertEquals(documents1.contains('Photo ID proof'),true, 'Photo ID proof Not Found');

    }

    @isTest
    static void unitTest2() {

        Test.startTest();
            // Create test data
            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            nm_WorkExperience__c workExp2 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company B'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1, workExp2};

            // Test case 2: Work Experience and Defence Personnel
            GetMandatoryDocuments.StudentStatus status2 = new GetMandatoryDocuments.StudentStatus();
            status2.eligibilityCriteria = '2';
            status2.chooseProgram = 'Other';
            status2.hscStatus = 'Passed';
            status2.diplomaStatus = 'Not Applicable';
            status2.isDefencePersonnel = 'Yes';
            status2.relationship = 'Spouse';
            status2.isDifferentlyAbled = 'No';
            status2.isLateral = false;
            status2.studentProgram = '';
            status2.lstWk = new List<nm_WorkExperience__c>{workExp1, workExp2};

            GetMandatoryDocuments docService2 = new GetMandatoryDocuments();
            Set<String> documents2 = docService2.getMandatoryDocumentsName(status2);
        Test.stopTest();
        
        System.assertEquals(documents2.contains('Photo ID proof'),true, 'Photo ID proof Not Found');

    }

    @isTest
    static void unitTest3() {

        Test.startTest();
            // Create test data
            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            nm_WorkExperience__c workExp2 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company B'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1, workExp2};

            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'Master';
            status3.chooseProgram = 'Advance Program';
            status3.hscStatus = 'Not Applicable';
            status3.diplomaStatus = 'Not Applicable';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'No';
            status3.isLateral = true;
            status3.recordId = workExp1.Id;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>();

            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents3 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents3.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest4() {

        Test.startTest();

            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1};

            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'Bachelor Professional';
            status3.chooseProgram = 'Bachelor Programs';
            status3.hscStatus = 'Passed';
            status3.diplomaStatus = 'Not Applicable';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'Yes';
            status3.isLateral = false;
            status3.objectType = 'Lead';
            status3.recordId = workExp1.Id;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>();
            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents4 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents4.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest5() {

        Test.startTest();
            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'Diploma';
            status3.chooseProgram = 'Bachelor Programs';
            status3.hscStatus = 'Passed';
            status3.diplomaStatus = 'Appeared';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'Yes';
            status3.isLateral = false;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>();
            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents4 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents4.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest6() {

        Test.startTest();
            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'Diploma HSC';
            status3.chooseProgram = 'Diploma Programs';
            status3.hscStatus = 'Passed';
            status3.diplomaStatus = 'Appeared';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'Yes';
            status3.isLateral = false;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>();
            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents4 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents4.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest7() {

        Test.startTest();
            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'Diploma HSC';
            status3.chooseProgram = 'Bachelor Programs';
            status3.hscStatus = 'Passed';
            status3.diplomaStatus = 'Passed';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'Yes';
            status3.isLateral = true;
            status3.studentProgram = 'Program';
            status3.lstWk = new List<nm_WorkExperience__c>();
            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents4 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents4.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest8() {

        Test.startTest();
            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'SSC HSC 1';
            status3.chooseProgram = 'Bachelor Programs';
            status3.hscStatus = 'Appeared';
            status3.diplomaStatus = 'Passed';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'Yes';
            status3.isLateral = true;
            status3.studentProgram = 'Program';
            status3.lstWk = new List<nm_WorkExperience__c>();
            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents4 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents4.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest9() {

        Test.startTest();
            // Create test data
            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            nm_WorkExperience__c workExp2 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company B'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1, workExp2};

            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'SSC+2yr Work exp.';
            status3.chooseProgram = 'Advance Program';
            status3.hscStatus = 'Not Applicable';
            status3.diplomaStatus = 'Not Applicable';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'No';
            status3.isLateral = true;
            status3.recordId = workExp1.Id;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>();

            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents3 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents3.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }

    @isTest
    static void unitTest10() {

        Test.startTest();
            // Create test data
            nm_WorkExperience__c workExp1 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company A'
            );
            
            nm_WorkExperience__c workExp2 = new nm_WorkExperience__c(
                nm_CompanyName__c = 'Company B'
            );
            
            insert new List<nm_WorkExperience__c>{workExp1, workExp2};

            // Test case 3: Lateral and Master Degree
            GetMandatoryDocuments.StudentStatus status3 = new GetMandatoryDocuments.StudentStatus();
            status3.eligibilityCriteria = 'SSC+2yr Work exp.';
            status3.chooseProgram = 'Advance Program';
            status3.hscStatus = 'Not Applicable';
            status3.diplomaStatus = 'Not Applicable';
            status3.isDefencePersonnel = 'No';
            status3.isDifferentlyAbled = 'No';
            status3.isLateral = true;
            status3.recordId = workExp1.Id;
            status3.studentProgram = 'Advance Program';
            status3.lstWk = new List<nm_WorkExperience__c>{workExp1, workExp2};

            
            GetMandatoryDocuments docService3 = new GetMandatoryDocuments();
            Set<String> documents3 = docService3.getMandatoryDocumentsName(status3);
        Test.stopTest();
        
        System.assertEquals(documents3.contains('Photo ID proof'),true, 'Photo ID proof Not Found');
    }
    
}