@isTest
private class nm_AdmissionRecieptClassTracker
{

     private static opportunity objopp;
     private static nm_Payment__c objpaymnt;
     
     private static testmethod void unitTest1()
     {
       /* string strrecord = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1].id;        
        Account Acc = new Account(
        RecordTypeID=strrecord,
        FirstName='jane',
        LastName='doe',
        nm_PreStudentNo__c ='77213',
        nm_StudentStatus__c='Confirmed',
        nm_SerialNo__c=2) ; 
        insert Acc;
        System.assert(Acc.id!=null);        
        objopp = new opportunity();
        objopp.accountId =Acc.id;
        objOpp.name ='test opp';
        objOPP.StageName ='Registration done';
        objOpp.CloseDate =System.today();
        insert objopp;*/
        
          Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);

      
        nm_Payment__c objpaymnt = nmGenericTracker.CreateAdmissionPaymentRecordForLead(objLead);

        
        ApexPages.currentPage().getParameters().put('id',objpaymnt.id);
        nm_AdmissionRecieptClass obj = new nm_AdmissionRecieptClass();
        nm_Payment__c  lstpymnt =obj.objPayment;
        
    }
    
  }