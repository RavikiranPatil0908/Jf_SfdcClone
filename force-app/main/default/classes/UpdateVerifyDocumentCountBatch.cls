/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public with sharing class UpdateVerifyDocumentCountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    // public UpdateVerifyDocumentCountBatch() {}
    public Set<String> lstFailedRecords;
    public Set<String> lstSuccessRecords;

    public void execute(SchedulableContext sc) {
        UpdateVerifyDocumentCountBatch b = new UpdateVerifyDocumentCountBatch();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('UpdateVerifyDocumentCountBatch started');

        String query = 'select ID,Admission_Co_ordinator__c,nm_DocumentSubmittedDate__c from Account where (nm_StudentStatus__c = \'Admission form & documents submitted\' OR nm_StudentStatus__c = \'Documents Re-submitted\') AND nm_DocumentSubmittedDate__c != null AND Admission_Co_ordinator__c != \'\' ';
        System.debug('query '+query); 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) { 

        if(scope.size() > 0) {
            Map<String,Verified_Document__c> mapofVDocs = new Map<String,Verified_Document__c>();
            
            Map<String,List<Account>> mapofAccountPending= new Map<String,List<Account>>();
            //Map<String,List<Account>> mapofAccountApprovd= new Map<String,List<Account>>();
            List<Account> lstPending = [select Admission_Co_ordinator__c,Id,nm_DocumentSubmittedDate__c from Account where (nm_StudentStatus__c =    'Admission form & documents submitted' OR nm_StudentStatus__c = 'Documents Re-submitted') AND Admission_Co_ordinator__c != '' ORDER BY Admission_Co_ordinator__c];
            
            system.debug('lstPending-->'+lstPending);
            
        /*  List<Account> lstApproved = [select Admission_Co_ordinator__c, Id,nm_DocumentSubmittedDate__c from Account where (nm_StudentStatus__c = 'Admission form & documents Approved' OR nm_StudentStatus__c='Confirmed' OR nm_StudentStatus__c ='Admission Form & Documents Provisional') AND Document_Approved_Date__c = TODAY AND Admission_Co_ordinator__c != ''  ORDER BY Admission_Co_ordinator__c];
            
            system.debug('lstApproved-->'+lstApproved);*/
           if(lstPending.size()>0)  
            {              
                    for (Account ar : lstPending)  {
                        
                        if(ar.nm_DocumentSubmittedDate__c!=null)
                        {
                            DateTime dT = ar.nm_DocumentSubmittedDate__c;
                            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                            //sdate = String.valueOfmyDate);
                            String key = ar.Admission_Co_ordinator__c +'-'+myDate;  
                            
                            if(!mapofAccountPending.containskey(key))
                            {
                                mapofAccountPending.put(key,new List<Account>());
                            }
                                mapofAccountPending.get(key).add(ar);                                            
                        }                         
                    }
                    if(!mapofAccountPending.isEmpty())
                        {
                            for (String cpkey : mapofAccountPending.keyset())
                            {
                                 string CPId = cpkey.SubStringBefore('-');
                                 Integer DocCount = mapofAccountPending.get(cpkey).size();
                                 Date submitted = Date.valueOf(cpkey.SubStringAfter('-')); 
                                   System.debug('Counselor ID' + CPId);
                                  System.debug('Doc count' + DocCount);
                                  
                                   Verified_Document__c vd1 = new Verified_Document__c();
                                     vd1.Counselor_Profile__c = CPId;
                                     vd1.Document_approval_pending_count__c = DocCount;
                                     vd1.nm_DocumentSubmittedDate__c =  submitted;
                                     vd1.Batch_Updated_Date__c = SYSTEM.today();
                                     vd1.VerifyDocUniqueCheck__c = cpkey+'-'+ SYSTEM.today();
                                     mapofVDocs.put(cpkey,vd1);
                            }
                        } 
                

                System.debug('mapofVDocs '+mapofVDocs);

                if(mapofVDocs.size()>0){
                    try {
                        // insert mapofVDocs.values();
                        insertVerifydocs(mapofVDocs.values());
                    } catch (DMLException e) {
                        System.debug('error '+e.getMessage());                    
                    }
                }
            }
       }
    }

    public void insertVerifydocs(List<Verified_Document__c> VerifiedDocsList) {
        try {
            lstFailedRecords = new Set<String>();
            lstSuccessRecords = new Set<String>();
            Database.SaveResult[] srList = Database.insert(VerifiedDocsList, false);
            for (Integer i = 0; i < VerifiedDocsList.size(); i++) {
                Database.SaveResult sr = srList[i];
                Verified_Document__c origRecord = VerifiedDocsList[i];
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    lstSuccessRecords.add(origRecord.Id);
                    System.debug('Successfully insert Verify docs. VD ID: ' + sr.getId());

                } else {
                    System.debug('sr.getId() -->'+origRecord.id);
                    lstFailedRecords.add(origRecord.id);
                    // Operation failed, so get all errors.                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Verify docs fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish Method Execute');
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,     JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:bc.getJobId()];
        
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('UpdateVerifyDocumentCountBatch ' + a.Status);
        mail.setOrgWideEmailAddressId(owe.id);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +
        'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}