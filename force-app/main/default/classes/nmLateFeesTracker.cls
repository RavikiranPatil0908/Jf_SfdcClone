@isTest(SeeAllData=true)
private class nmLateFeesTracker
{
     Private static Opportunity objopp;
     private static nm_Payment__c objpaymnt;
      private static nm_Program__c objprogram;
    
     private static testmethod void unitTest2()
     {
          
        Account Acc = new Account();
        acc = CommonTrackerClass.createAccount(acc);  
       acc.PersonEmail = 'Praveen.p@saasfocus.in';
        acc.PersonMobilePhone= '9632100000';
        update acc;
        
        objprogram = new nm_Program__c ();
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c ='Certificate Programs';        
        objProgram.nm_ProgramName__c='MCA';      
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;
           
        objopp = new opportunity();
        objopp.accountId =Acc.id;
        objOPP.nm_Semester__c = '1';
        objOpp.name ='test opp';
        objOPP.StageName ='Registration done';
        objopp.nm_Program__c =objprogram.id;
        objopp.nm_Session__c = 'July';
        objopp.nm_year__c=2014;
        objOpp.CloseDate =System.today();
        insert objopp;
        
        objPaymnt = new nm_Payment__c();
        objPaymnt.nm_OpportunityNew__c =objopp.id;
        objPaymnt.nm_PaymentType__c='Admission';
        objPaymnt.nm_Amount__c = 25;
        objPaymnt.nm_ModeOfPayment__c='Online';
        objPaymnt.nm_PaymentStatus__c='pending late fees' ;
        insert objPaymnt;  
        
          SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
          objSystemConfiguration.name='test';
          objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
          objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
          objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
          objSystemConfiguration.nm_PaymentgatewayID__c='PRAVEEN.P.COM';
          insert objSystemConfiguration; 
        
        ApexPages.currentPage().getParameters().put('id',acc.id);
      
       
        
        nmLateFees objnmLateFees = new nmLateFees();
        objnmLateFees.LateFees = 55;
        objnmLateFees.strModeOfPaymnet = 'Cash';
        
        nmOnlinePayment objnmOnline=new nmOnlinePayment();
        objnmOnline.strPortalId = objSystemConfiguration.nm_PaymentgatewayID__c;
        objnmOnline.TranTrackid = '0144258285';
        objnmOnline.TranAmount = '586';
        objnmOnline.MakePayment();
        objnmLateFees.MakeOnlinePayment();
        objnmLateFees.MakeLateFessPaymentAfterResponse('AAA','bbbb','cccc','dddd','eeee','ffff','gggg','25',objopp.id, 'response');
        
     }
}