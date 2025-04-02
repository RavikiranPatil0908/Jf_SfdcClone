/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2024
 * @last modified by  : @BK
**/
@isTest
public class AsyncShootTriggerHandlerTracker {
    
    @TestSetup
    static void makeData(){
       Async_Shoot_Post_Production__c ob=new Async_Shoot_Post_Production__c(); 
        ob.Subject__c='Business Communication';
        ob.Chapter_Name__c='Chap 1';
        ob.Shoot_Date__c=Date.Today();
        ob.Faculty_Name__c='Anurag Garg';
        ob.Faculty_Email__c='anuraggarg@gmail.com';
        ob.Editor_Name__c='Aman';
        ob.Editor_Email_Id__c='amanmishra2326@gmail.com';
        ob.Recording_Format__c='Zoom';
        ob.Recording_Platform__c='Zoom';
        ob.Post_Production_Minutes__c = 10;
        ob.Partner__c = 'Devendra Sharma';
        ob.Editor_Name__c = 'Devendra Sharma';
        ob.Editor_Email_Id__c = 'devendrasuthra750@gmail.com';
        ob.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        ob.Program__c = 'UG';
        insert ob;
        
    }
    
    static testmethod void testSuccessBatch1(){
        Async_Shoot_Post_Production__c alist=[select id from Async_Shoot_Post_Production__c limit 1];
       // Async_Shoot_Post_Production__c ob=new Async_Shoot_Post_Production__c();
        //ob.Id= alist.Id;
       alist.Post_Production_Status__c='Faculty Comments Shared with Production';
        
        update alist;
        
         Test.startTest();
        AsyncShootTriggerHandler batchClass = new AsyncShootTriggerHandler();
     
       Test.stopTest();
        
    }

}