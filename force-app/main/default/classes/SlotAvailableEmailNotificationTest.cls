/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-12-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class SlotAvailableEmailNotificationTest {

    @testSetup
    public static void setUpData(){ 
        
        List<Case__c> lstTat = new List<Case__c>();
        Case__c objTAT = new Case__c();
        objTAT.Name = 'Admissions';
        objTAT.TAT__c = 3;
        lstTat.add(objTAT);

        Case__c objTAT2 = new Case__c();
        objTAT2.Name = 'Academics';
        objTAT2.TAT__c = 2;
        lstTat.add(objTAT2);
        insert lstTat;

        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;
        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77119958556', nm_Program__c=prog.Id , PersonMobilePhone='8652532023',PersonEmail='priyankakorade22@gmail.com');
        insert acc;
        String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
    	String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket, Account=acc);
        c1.Is_Slot_Available__c = true;
        c1.Type_of_Call__c = 'Regular';
        c1.SuppliedEmail = 'test@gmail.com';
        insert c1;

        Case c2 = new Case(Subject='Test', Status='Closed', Student_Purpose__c='Feedback', Tech_Issue__c='No', nm_Category__c='Admissions', sub_categories__c='Admission - Payment issue', Student_Category__c='Admissions', Student_No__c='77119958556', RecordTypeId=feedback, Account=acc);
        insert c2;
        Case c3 = new Case(Subject='Test', Status='Closed', Student_Purpose__c='Complaint', Tech_Issue__c='No', nm_Category__c='Admissions', sub_categories__c='Admission - Payment issue', Student_Category__c='Admissions', Student_No__c='77119958556', RecordTypeId=ticket, Account=acc);
        insert c3;
        CaseComment cc = new CaseComment(CommentBody='Test', ParentId=c1.Id);
        insert cc;
                        
        Case__c cs = new Case__c( Name='Admissions', TAT__c=2.0);
		insert cs;
    
        ContentVersion cvf = new ContentVersion(Title='Doc1', FirstPublishLocationId=c1.Id, Comment_Id__c=cc.Id, PathOnClient='Doc1.pdf', VersionData=Blob.valueOf('Test Content Version Data'));
        insert cvf;

        List<Schedule_Time_Slot__c> lstST = new List<Schedule_Time_Slot__c>();
        Schedule_Time_Slot__c obj = new Schedule_Time_Slot__c(Start_date__c=System.today(),End_date__c=System.today().addDays(5),Recurrence__c='Daily',Start_time__c=Time.newInstance(22,00,00,00),End_time__c=Time.newInstance(23,00,00,00),IsActive__c=TRUE,Type_of_Call__c='Escalation',Total_Counselors__c=1,Skill_Name__c='TEST',Per_Call_Schedule_Minutes__c=15,Escalation_Level__c='1');
        lstST.add(obj);

        Schedule_Time_Slot__c obj2 = obj.clone();
        obj2.Start_date__c = System.today().addDays(3);
        obj2.End_date__c = System.today().addDays(9);
        lstST.add(obj2);

        Schedule_Time_Slot__c obj3 = obj.clone();
        obj3.Type_of_Call__c = 'Regular';
        obj3.Escalation_Level__c = null;
        lstST.add(obj3);

        insert lstST;
    }

    @isTest
    static void unitTest1() {
        Test.startTest();
            SlotAvailableEmailNotification batchClass = new SlotAvailableEmailNotification('Regular');
            SlotAvailableEmailNotification.FlowInputs objFI = new SlotAvailableEmailNotification.FlowInputs();
            List<SlotAvailableEmailNotification.FlowInputs> lstFI = new List<SlotAvailableEmailNotification.FlowInputs>();
            objFI.callType = 'Regular';
            lstFI.add(objFI);
            SlotAvailableEmailNotification.sendEmail(lstFI);
        Test.stopTest();
    }
}