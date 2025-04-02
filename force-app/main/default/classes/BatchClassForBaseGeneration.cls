/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-05-2024
 * @last modified by  : @BK
**/
public class BatchClassForBaseGeneration implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    private String recordId;
    private String currentBatch;
    private Decimal currentBatchYear;
    private nm_AdmissionDriveDate__c objBatch;
    private static final Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
    private static final Map<String,Integer> monthNumberMap = new Map<String,Integer>{'January'=>1,'February'=>2,'March'=>3,'April'=>4,'May'=>5, 'June'=>6,'July'=>7,'August'=>8,'September'=>9,'October'=>10, 'November'=>11,'December'=>12};
    public Map<Id, nm_Program__c> mapOfIdVsProgram = new Map<Id, nm_Program__c>();


    public BatchClassForBaseGeneration(String recordVal) {
        if(String.isBlank(recordId) && String.isNotBlank(recordVal)) {
            recordId = recordVal;
            objBatch = getBatch(recordId);
            if(objBatch != null) {
                currentBatchYear = objBatch.Drive_Year__c;
                currentBatch = objBatch.Drive_Month__c;
            }
        }
    }

    public void execute(SchedulableContext sc) {
        BatchClassForBaseGeneration b = new BatchClassForBaseGeneration(recordId);
        Database.executebatch(b, 200);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        // to return null records to stop batc class if Sessiona nd year is missing.
        if(String.isBlank(currentBatch) || currentBatchYear==null) {
            return Database.getQueryLocator('SELECT Id FROM nm_StudentProgram__c WHERE id=null');
        }

        System.debug('currentBatch==>'+currentBatch+'currentBatchYear==>'+currentBatchYear);
        // Map<String,Date> mapOfDriveVsDate = getDriveVsDate();
        // Date futureDateSem = null;
        // Date futureDateTerm = null;
        // String subQuery = '';
        // List<String> lstOfSemDrive = new List<String>{'January','July'};
        // List<String> lstOfTermDrive = new List<String>{'October','July','April','January'};
        // if(objBatch.Program_Type__c == 'Semester' && lstOfSemDrive.contains(currentBatch)) {
        //     futureDateSem = mapOfDriveVsDate.get(currentBatch + '-Sem');
        //     subQuery = 'AND nm_Student__r.Validity_End_Date__c>=:futureDateSem AND nm_Program__r.IsTerm__c=false';
        // } else if(objBatch.Program_Type__c == 'Term' && lstOfTermDrive.contains(currentBatch)) {
        //     futureDateTerm = mapOfDriveVsDate.get(currentBatch + '-Term');
        //     subQuery = 'AND nm_Student__r.Validity_End_Date__c>=:futureDateTerm AND nm_Program__r.IsTerm__c=true AND nm_Program__r.Name=\'PDDM\'';
        // } else if(objBatch.Program_Type__c == 'All' && lstOfTermDrive.contains(currentBatch) && lstOfSemDrive.contains(currentBatch)) {
        //     futureDateTerm = mapOfDriveVsDate.get(currentBatch + '-Term');
        //     futureDateSem = mapOfDriveVsDate.get(currentBatch + '-Sem');
        //     subQuery = 'AND ((nm_Program__r.IsTerm__c=true AND nm_Program__r.Name=\'PDDM\' AND nm_Student__r.Validity_End_Date__c>=:futureDateTerm) OR (m_Program__r.IsTerm__c=false AND nm_Student__r.Validity_End_Date__c>=:futureDateSem))';
        // }
        

        ValidityDateWrapper obj = getSubqueryDetails(objBatch.Program_Type__c);
        Date futureDateSem = obj.futureDateSem;
        Date futureDateTerm = obj.futureDateTerm;
        String subQuery = '';
        List<String> lstTermProgramAllowed = new List<String>{'Certificate Term 1', 'Certificate Term 2', 'Certificate Term 3', 'Professional Diploma Term 4'};
        if(objBatch.Program_Type__c == 'Semester'){
            subQuery = 'AND nm_Student__r.Validity_End_Date__c>=:futureDateSem AND nm_Program__r.IsTerm__c=false';
        } else if(objBatch.Program_Type__c == 'Term') {
            subQuery = 'AND nm_Student__r.Validity_End_Date__c>=:futureDateTerm AND nm_Program__r.IsTerm__c=true ';//' AND nm_Program__r.Specialisation__c IN :lstTermProgramAllowed';
        } else if(objBatch.Program_Type__c == 'All') {
            subQuery = 'AND ((nm_Program__r.IsTerm__c=true  AND nm_Student__r.Validity_End_Date__c>=:futureDateTerm) OR (nm_Program__r.IsTerm__c=false AND nm_Student__r.Validity_End_Date__c>=:futureDateSem))'; //AND nm_Program__r.Specialisation__c IN :lstTermProgramAllowed
        }
        System.debug('futureDateSem ==>'+futureDateSem);
        System.debug('futureDateTerm ==>'+futureDateTerm);
        System.debug('subQuery ==>'+subQuery);
        if(String.isBlank(subQuery)) {
            return Database.getQueryLocator('SELECT Id FROM nm_StudentProgram__c WHERE id=null');
        }

        String subQueryProgramCategory = '';
        if(objBatch.Program_Category__c != null){
        if(objBatch.Program_Category__c != 'All'){
            String progCategory = objBatch.Program_Category__c;
            subQueryProgramCategory = 'AND nm_Program__r.nm_Type__c =: progCategory ';
        }
        }
        System.debug('objBatch.Program_Category__c ==>'+objBatch.Program_Category__c);
        System.debug('subQuery ==>'+subQueryProgramCategory);

        // if(String.isBlank(subQueryProgramCategory)) {
        //     return Database.getQueryLocator('SELECT Id FROM nm_StudentProgram__c WHERE id=null');
        // }
        System.debug('objBatch.Program__c  ==>'+objBatch.Program__c );
        String subQueryProgram = '';
        if(objBatch.Program__c != null){
  
                Id selectedprogram = objBatch.Program__c;
                subQueryProgram = 'AND nm_Program__c =: selectedprogram ';
        
        }
        System.debug('subQuery ==>'+subQueryProgram);

        // if(String.isBlank(subQueryProgram)) {
        //     return Database.getQueryLocator('SELECT Id FROM nm_StudentProgram__c WHERE id=null');
        // }
        

        List<String> lstOfDrives = new List<String>{'Jan 2024','Jan 2023'};
        String query = Test.isRunningTest() ? 
            'SELECT Id,nm_Student__c,nm_Program__c,nextsem__c,nm_Student__r.nm_DefencePersonnel__c, Total_sem__c, nm_Program__r.Gap_Month__c, nm_Program__r.nm_Type__c FROM nm_StudentProgram__c' : 
            'SELECT Id,nm_Student__c,nm_Program__c,nextsem__c,nm_Student__r.nm_DefencePersonnel__c, Total_sem__c, nm_Program__r.Gap_Month__c, nm_Program__r.nm_Type__c FROM nm_StudentProgram__c WHERE nm_Student__r.nm_StudentStatus__c=\'Confirmed\' AND Total_sem__c>1 AND nm_IsClosed__c=FALSE AND nm_Student__r.Active_account__c=TRUE '+subQuery+' '+subQueryProgramCategory+' '+subQueryProgram+' AND nm_Student__r.Batch__c NOT IN :lstOfDrives';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<nm_StudentProgram__c> lstStPrg) { 
        System.debug('currentBatch ==>'+currentBatch);
        System.debug('currentBatchYear ==>'+currentBatchYear);
        List<Opportunity> lstOppstoUpsert = new List<Opportunity>();
        List<OpportunityLineItem> lstOppLineItemToDelete = new List<OpportunityLineItem>();
        List<nm_Payment__c> lstLateFeePayToUpdate = new List<nm_Payment__c>();
        Map<Id,nm_StudentProgram__c> mapOfAccIdVsStPrg = new Map<Id,nm_StudentProgram__c>();
        Map<Id,List<Opportunity>> mapOfAccountIdVslstOpps = new Map<Id,List<Opportunity>>();
        for (nm_StudentProgram__c obj : lstStPrg) {
            // accountIds.add(obj.nm_Student__c);
            mapOfAccIdVsStPrg.put(obj.nm_Student__c,obj);
        }
        List<String> lstOfStages = new List<String>{'Closed Won','Closed lost'};
        List<String> paymentMade = new List<String>{'Transaction Failed'};
        List<Opportunity> lstOpps = [SELECT id,AccountId,nm_Session__c,nm_Year__c,Sem__c,
            (SELECT Id, nm_PaymentType__c FROM Opportunities__r WHERE nm_PaymentStatus__c Not IN :paymentMade ),
            (SELECT Id,Product_Name__c FROM OpportunityLineItems WHERE Product_Name__c = 'Late Fee') FROM Opportunity 
            WHERE AccountId IN :mapOfAccIdVsStPrg.keySet() AND StageName NOT IN :lstOfStages ORDER BY nm_Semester__c ASC];
            
        for (Opportunity obj : lstOpps) {
            List<Opportunity> lst = mapOfAccountIdVslstOpps.containsKey(obj.AccountId) ? mapOfAccountIdVslstOpps.get(obj.AccountId) : new List<Opportunity>();
            lst.add(obj);
            mapOfAccountIdVslstOpps.put(obj.AccountId, lst);
        } 

        for (Id accountId : mapOfAccIdVsStPrg.keySet()) {
            List<Opportunity> lst = mapOfAccountIdVslstOpps.containsKey(accountId) ? mapOfAccountIdVslstOpps.get(accountId) :new  List<Opportunity>();
            nm_StudentProgram__c objStPrg = mapOfAccIdVsStPrg.get(accountId);
            Boolean isExists = false;
            Opportunity objOpp = null;
            if (objStPrg.Total_sem__c >= objStPrg.nextsem__c) {
                Map<Decimal, List<Opportunity>> mapSemVslstOpp = getmapSemVslstOpp(lst);
                if (mapSemVslstOpp.containsKey(objStPrg.nextsem__c)) {
                    // isExists = true;
                    OpportunityRecords OpportunityRecords = getLstOppToUpdate(objStPrg.nextsem__c, mapSemVslstOpp, objStPrg);
                    isExists = OpportunityRecords.isExist || OpportunityRecords.lstOpp.size() > 0 ? true : false;
                    if (isExists && OpportunityRecords.lstOpp.size() > 0) {
                        lstOppstoUpsert.addAll(OpportunityRecords.lstOpp);
                    }
                    if (OpportunityRecords.lstOppLineItems.size() > 0) {
                        lstOppLineItemToDelete.addAll(OpportunityRecords.lstOppLineItems);
                    }
                    if (OpportunityRecords.lstPayToUpdate.size() > 0) {
                        lstLateFeePayToUpdate.addAll(OpportunityRecords.lstPayToUpdate);
                    }
                }
    
                if(!isExists) {
                    Opportunity nextSemOpportunity = getNewOpportunity(String.valueOf(objStPrg.nextsem__c), currentBatch, currentBatchYear, String.valueOf(accountId), objStPrg);
                    lstOppstoUpsert.add(nextSemOpportunity);
                }
                
            }
        }

        if(lstOppstoUpsert.size() > 0) {
            System.debug('lstOppstoUpsert.size --> '+ lstOppstoUpsert.size());
            System.debug('lstOppstoUpsert --> '+ JSON.serialize(lstOppstoUpsert));
            // upsert lstOppstoUpsert;

            Database.UpsertResult[] results = Database.upsert(lstOppstoUpsert, false);
            for (Database.UpsertResult sr : results) {
                if(!sr.isSuccess()) {
                    System.debug('Record Upsert Failed');
                }
            }
        }
        if (lstOppLineItemToDelete.size() > 0) {
            System.debug('lstOppLineItemToDelete.size --> '+ lstOppLineItemToDelete.size());
            System.debug('lstOppLineItemToDelete --> '+ JSON.serialize(lstOppLineItemToDelete));
            Database.DeleteResult[] results = Database.delete(lstOppLineItemToDelete, false);
            for (Database.DeleteResult sr : results) {
                if(!sr.isSuccess()) {
                    System.debug('Record delete Failed -- ' +sr.getId() );
                }
            }
        }
        if (lstLateFeePayToUpdate.size() > 0) {
            System.debug('lstLateFeePayToUpdate.size --> '+ lstLateFeePayToUpdate.size());
            System.debug('lstLateFeePayToUpdate --> '+ JSON.serialize(lstLateFeePayToUpdate));
            Database.SaveResult[] results = Database.update(lstLateFeePayToUpdate, false);
            for (Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    System.debug('Record update Failed -- ' +sr.getId() );
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(objBatch != null) {
            objBatch.Status__c = 'Completed';
            update objBatch;
        }
        System.debug('Finished');
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String semester 
    * @param String session 
    * @param Decimal year 
    * @param String accountId 
    * @param nm_StudentProgram__c objStPrg 
    * @return Opportunity 
    **/
    public Opportunity getNewOpportunity(String semester, String session, Decimal year, String accountId, nm_StudentProgram__c objStPrg) {
        Opportunity nextSemOpportunity = new Opportunity();
        nextSemOpportunity.nm_Session__c = session;
        nextSemOpportunity.nm_Year__c = year;
        nextSemOpportunity.Name = 'test';
        nextSemOpportunity.StageName = 'Re-Registration Pending';
        nextSemOpportunity.CloseDate = System.today();
        nextSemOpportunity.nm_Fee_Type__c = 'ReRegistrationPayment'; //Changing so that trigger does not fire again and future Opportunities are not further created
        nextSemOpportunity.nm_Semester__c = semester;
        nextSemOpportunity.AccountId = accountId;
        nextSemOpportunity.nm_StudentProgram__c = objStPrg.Id;
        nextSemOpportunity.nm_Program__c = objStPrg.nm_Program__c;       
        nextSemOpportunity.Is_Re_Registration_Payment__c = true;
        nextSemOpportunity.Opportunity_Base_Status__c = nextSemOpportunity.nm_Session__c + nextSemOpportunity.nm_Year__c + '_Insert';
        return nextSemOpportunity;
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String oppId 
    * @param Date sessionDate 
    * @param Boolean isOppClosedLost 
    * @return Opportunity 
    **/
    public Opportunity getOppNewSession(String oppId, Date sessionDate, Boolean isOppClosedLost) {
        Integer month = sessionDate.month();
        Decimal year = sessionDate.year();
        Opportunity oppNewSession = new Opportunity();
        oppNewSession.Id = oppId;
        if (isOppClosedLost) {
            oppNewSession.StageName = 'Closed lost';
        } else {
            oppNewSession.nm_Session__c = monthNameMap.get(month);
            oppNewSession.nm_Year__c = year;
        }
        oppNewSession.Opportunity_Base_Status__c = oppNewSession.nm_Session__c + oppNewSession.nm_Year__c + '_Update';
        return oppNewSession;
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param Decimal currentSemester 
    * @param Map<Decimal List<Opportunity>> mapSemVslstOpp 
    * @param nm_StudentProgram__c objStPrg 
    * @return OpportunityRecords 
    **/
    public OpportunityRecords getLstOppToUpdate(Decimal currentSemester, Map<Decimal, List<Opportunity>> mapSemVslstOpp, nm_StudentProgram__c objStPrg) {
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> lstOppLineItemToDelete = new List<OpportunityLineItem>();
        List<nm_Payment__c> lstLateFeePayToUpdate = new List<nm_Payment__c>();
        OpportunityRecords OpportunityRecords = new OpportunityRecords();
        Boolean isExist = false;
        List<Decimal> semInOrder = new List<Decimal>(mapSemVslstOpp.keySet());
        semInOrder.sort();
        for (Decimal sem : semInOrder){
            if (!isExist) {
                if (sem >= currentSemester) {
                    List<Opportunity> lstOppWithPayment = new List<Opportunity>();
                    List<Opportunity> lstOppWithoutPayment = new List<Opportunity>();
                    for (Opportunity objOpp : mapSemVslstOpp.get(sem)) {
                        List<OpportunityLineItem> lstOppLineItem = objOpp.OpportunityLineItems;
                        if (lstOppLineItem.size() > 0) {
                            lstOppLineItemToDelete.addAll(lstOppLineItem);
                        }
                        if (isSessionYearSame(currentBatch, currentBatchYear, objOpp.nm_Session__c, objOpp.nm_Year__c) && objStPrg.nextsem__c == objOpp.Sem__c) {
                            isExist = true;
                            break;
                        } else {
                            if (objOpp.Opportunities__r.size() > 0) {
                                lstOppWithPayment.add(objOpp);
                                for (nm_Payment__c objPay : objOpp.Opportunities__r) {
                                    if (objPay.nm_PaymentType__c == 'Late Fees') {
                                        lstLateFeePayToUpdate.add(new nm_Payment__c(Id = objPay.Id, nm_PaymentType__c = 'Installment', nm_Installment_Payment_Ref__c = 'Installment-ReRegistrationPayment'));
                                    }
                                }
                            } else {
                                lstOppWithoutPayment.add(objOpp);
                            }
                        }
                    }
                    // system.debug('lstOppWithPayment --> ' + JSON.serialize(lstOppWithPayment));
                    // system.debug('lstOppWithoutPayment --> ' + JSON.serialize(lstOppWithoutPayment));
                    Date futureSessionDate = getFutureSessionDate(currentBatch, currentBatchYear, getSemGap(objStPrg.nm_Program__r.Gap_Month__c, sem, objStPrg.nextsem__c));
                    if (lstOppWithPayment.size() > 0) {
                        lstOppToUpdate.add(getOppNewSession(lstOppWithPayment[0].Id, futureSessionDate, false));
                        for (Opportunity obj : lstOppWithoutPayment) {
                            lstOppToUpdate.add(getOppNewSession(obj.Id, futureSessionDate, true));
                        }
                    } else if (lstOppWithoutPayment.size() > 0) {
                        for (Integer i = 0; i < lstOppWithoutPayment.size(); i++) {
                            lstOppToUpdate.add(getOppNewSession(lstOppWithoutPayment[i].Id, futureSessionDate, i == 0 ? false : true));
                        }
                    }
                }
            }
        }
        system.debug('isExist --> ' + isExist);
        system.debug('lstOppToUpdate --> ' + lstOppToUpdate);
        OpportunityRecords.isExist = isExist;
        OpportunityRecords.lstOpp = isExist ? new List<Opportunity>() : lstOppToUpdate;
        OpportunityRecords.lstOppLineItems = lstOppLineItemToDelete;
        OpportunityRecords.lstPayToUpdate = lstLateFeePayToUpdate;
        return OpportunityRecords;
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param List<Opportunity> lstOpp 
    * @return Map<Decimal, List<Opportunity>> 
    **/
    public Map<Decimal, List<Opportunity>> getmapSemVslstOpp(List<Opportunity> lstOpp) {
        Map<Decimal, List<Opportunity>> mapSemVslstOpp = new Map<Decimal, List<Opportunity>>();
        for (Opportunity objOpp : lstOpp) {
            List<Opportunity> lst = mapSemVslstOpp.containsKey(objOpp.Sem__c) ? mapSemVslstOpp.get(objOpp.Sem__c) : new List<Opportunity>();
            lst.add(objOpp);
            mapSemVslstOpp.put(objOpp.Sem__c, lst);
        }
        return mapSemVslstOpp;
    }

    // public Boolean isSessionYearFuture(String currentSession, Decimal currentYear, String Session, Decimal Year) {
    //     Date currentDate = Date.newInstance(Integer.valueOf(currentYear), monthNumberMap.get(currentSession), 1);
    //     Date futureDate = Date.newInstance(Integer.valueOf(Year), monthNumberMap.get(Session), 1);
    //     return futureDate >= currentDate ? true : false;
    // }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String currentSession 
    * @param Decimal currentYear 
    * @param String Session 
    * @param Decimal Year 
    * @return Boolean 
    **/
    public Boolean isSessionYearSame(String currentSession, Decimal currentYear, String Session, Decimal Year) {
        Date currentDate = Date.newInstance(Integer.valueOf(currentYear), monthNumberMap.get(currentSession), 1);
        Date futureDate = Date.newInstance(Integer.valueOf(Year), monthNumberMap.get(Session), 1);
        return futureDate == currentDate ? true : false;
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String Session 
    * @param Decimal Year 
    * @param String semGap 
    * @return Date 
    **/
    public Date getFutureSessionDate(String Session, Decimal Year, String semGap) {
        Date futureDate = Date.newInstance(Integer.valueOf(Year), monthNumberMap.get(Session), 1);
        return futureDate.addMonths(Integer.valueOf(semGap));
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param Decimal gapMonth 
    * @param Decimal oppSem 
    * @param Decimal currentSem 
    * @return string 
    **/
    public string getSemGap(Decimal gapMonth, Decimal oppSem, Decimal currentSem) {
        Decimal semGap = oppSem >= currentSem ? (oppSem - currentSem) * gapMonth : 0;
        return String.valueOf(semGap);
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String recordId 
    * @return nm_AdmissionDriveDate__c 
    **/
    public nm_AdmissionDriveDate__c getBatch(String recordId) {
        if(objBatch != null) { 
            return objBatch;
        }

        if(String.isBlank(recordId)) {
            return null;
        }

        List<nm_AdmissionDriveDate__c> lst = [SELECT id,Program_Type__c,Status__c,Drive_Month__c,Drive_Year__c, Program_Category__c, Program__c FROM nm_AdmissionDriveDate__c WHERE id = :recordId LIMIT 1];
        if(lst.size() == 0) {
            return null;
        }
        return lst[0];
    }

    /**
    * @description 
    * @author @BK | 02-05-2024 
    * @param Integer year 
    * @return Map<String, Date> 
    **/
    public Map<String,Date> getMapOfMonthVsEndaDate() {
        Integer year = Integer.valueOf(currentBatchYear);
        Map<String,Date> mapOfEndDate = new Map<String,Date>();
        for (Integer i = 1; i < 13; i++) {
            Date endDate = System.Date.newInstance(year, i, 1).addMonths(1).toStartofMonth().addDays(-1);
            DateTime newDate = endDate;
            mapOfEndDate.put(newDate.format('MMMM'),endDate);
        }
        return mapOfEndDate;
    }

    /**
    * @description 
    * @author @BK | 02-05-2024 
    * @return Map<String, Date> 
    **/
    public Map<String,Date> getDriveVsDate() {
        Map<String,Date> mapOfEndDate = getMapOfMonthVsEndaDate();
        Map<String,Date> mapOfDriveVsDate = new Map<String,Date>{
            'January-Sem' => mapOfEndDate.get('June'),
            'July-Sem' => mapOfEndDate.get('December'),
            'October-Term' => mapOfEndDate.get('December'),
            'July-Term' => mapOfEndDate.get('September'),
            'April-Term' => mapOfEndDate.get('June'),
            'January-Term' => mapOfEndDate.get('March')
        };
        return mapOfDriveVsDate;
    }

    /**
    * @description 
    * @author @BK | 02-05-2024 
    * @param String programType 
    * @return ValidityDateWrapper 
    **/
    public ValidityDateWrapper getSubqueryDetails(String programType) {
        Map<String,Date> mapOfDriveVsDate = getDriveVsDate();
        ValidityDateWrapper obj = new ValidityDateWrapper();
        obj.futureDateSem = null;
        obj.futureDateTerm = null;
        List<String> lstOfSemDrive = new List<String>{'January','July'};
        List<String> lstOfTermDrive = new List<String>{'October','July','April','January'};
        if(programType == 'Semester' && lstOfSemDrive.contains(currentBatch)) {
            obj.futureDateSem = mapOfDriveVsDate.get(currentBatch + '-Sem');
        } else if(programType == 'Term' && lstOfTermDrive.contains(currentBatch)) {
            obj.futureDateTerm = mapOfDriveVsDate.get(currentBatch + '-Term');
        } else if(programType == 'All' && lstOfTermDrive.contains(currentBatch) && lstOfSemDrive.contains(currentBatch)) {
            obj.futureDateTerm = mapOfDriveVsDate.get(currentBatch + '-Term');
            obj.futureDateSem = mapOfDriveVsDate.get(currentBatch + '-Sem');
        }
        System.debug('futureDateSem ==>'+obj.futureDateTerm);
        System.debug('futureDateTerm ==>'+obj.futureDateTerm);
        return obj;
    }

    public class OpportunityRecords {
        public Boolean isExist {get;set;}
        public List<Opportunity> lstOpp {get;set;}
        public List<OpportunityLineItem> lstOppLineItems {get;set;}
        public List<nm_Payment__c> lstPayToUpdate {get;set;}

        public OpportunityRecords() {
            isExist = false;
            lstOpp = new List<Opportunity>();
        }
    }

    public class ValidityDateWrapper {
        public Date futureDateSem {get;set;}
        public Date futureDateTerm {get;set;}
    }

}