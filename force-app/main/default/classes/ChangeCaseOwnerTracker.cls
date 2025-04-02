/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : @BK
**/
@isTest
public class ChangeCaseOwnerTracker 
{
    public static Case ObjCase;
    public static nm_Centers__c center;
    public static nm_Program__c objP;
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    // public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
   
    public static nm_UserMapping__c objMap;
    
    static testMethod void test1()
    {      
        Test.StartTest();
         user usr = [Select id from user limit 1];
         ObjCase=new Case();
         objcase.nm_Category__c = 'Admissions';
        objcase.sub_categories__c = 'Acknowledgement';
        objcase.StudentZone_QueryId__c ='2261';
        objcase.SuppliedEmail ='sachin920@gmail.com';
         insert objcase;
         
       
        Test.stopTest();

    }
    
    }