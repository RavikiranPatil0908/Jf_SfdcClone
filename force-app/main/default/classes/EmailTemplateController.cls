/**
 * @File Name          : EmailTemplateController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 24-08-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/3/2020   shubhranshu     Initial Version
**/
global with sharing class EmailTemplateController {
    
    public id AccountId;
    public id approvalId;
    public id OpportunityId;
    public List<nm_LinksForDocuments__c> lstlinkDocs;
    public Map<String,String> mapofCancellationDates = new Map<String,String>();
    public String session;
    public Integer year;
    public String chooseProgram;
    public String programType;
    public Date lastDateForCancelation {get;set;}
    public List<Cancelation_Date__c> lstDates {get;set;}

    public EmailTemplateController() {
        // dateEntries = new List<MapDateWrapper>();
        lastDateForCancelation = null;
        lstDates = new List<Cancelation_Date__c>();
    }

    public String getSession() {
        return this.session;
    }

    public void setSession(String session) {
        this.session = session;
    }

    public Integer getYear() {
        return this.year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public String getChooseProgram() {
        return this.chooseProgram;
    }

    public void setChooseProgram(String chooseProgram) {
        this.chooseProgram = chooseProgram;
    }

    public String getProgramType() {
        return this.programType;
    }

    public void setProgramType(String programType) {
        this.programType = programType;
    }
    
    public Map<String,String> getMapofCancellationDates() {
        return this.mapofCancellationDates;
    }

    public void setMapofCancellationDates(Map<String,String> mapofCancellationDates) {
        this.mapofCancellationDates = mapofCancellationDates;
    }

    public Id getOpportunityId() {
        return this.OpportunityId;
    }

    public void setOpportunityId(Id OpportunityId) {
        this.OpportunityId = OpportunityId;
        if(OpportunityId != null){
            getPaymentConfigCancellationDates();
        }
    }

    public id getApprovalId() {
        return this.approvalId;
    }

    public void setApprovalId(id approvalId) {
        this.approvalId = approvalId;
    }

    public List<nm_LinksForDocuments__c> getLstlinkDocs() {
        return this.lstlinkDocs;
    }
    public void setLstlinkDocs(List<nm_LinksForDocuments__c> lstlinkDocs) {
        this.lstlinkDocs = lstlinkDocs;
    }
    public Id getAccountId() {
        return this.AccountId;
    }
    public void setAccountId(Id AccountId) {
        this.AccountId = AccountId;
        if(AccountId != null){
            queryAllDocumnets();
        }
    }

    public void queryAllDocumnets(){
        if(this.AccountId != null){
            this.lstlinkDocs = [select id , Name , nm_DocumentName__c , nm_URLforDocuments__c , nm_Status__c,StudentStatus__c from nm_LinksForDocuments__c where nm_Account__c =: this.AccountId and SendforApproval__c = true]; 
            this.approvalId = getApprovalProcessRecord(this.AccountId);
        }
    }

    public void getPaymentConfigCancellationDates(){

        String stringYear = String.valueOf(this.year);
        String chooseProgramVal = this.chooseProgram;
        String progType = this.programType;
        String sessionValue = this.session;
        
       String query = 'select Id,Payment_Window_EndDate__c,Cancellation_from_date_1__c,Cancellation_from_date_2__c,Cancellation_from_date_3__c,Cancellation_to_date_1__c,Cancellation_to_date_2__c,Cancellation_to_date_3__c , Program_Category__c,'
                    +'Program_Type__c,Session__c,Current_Admission_Year__c from NM_Payment_Form_Configuration__c WHERE Payment_Type__c =\'Admission\' and Current_Admission_Year__c =:stringYear  and Session__c = :sessionValue and Program_Category__c =:chooseProgramVal';

                if(progType =='' || progType == null ){
                     query = 'select Id,Payment_Window_EndDate__c,Cancellation_from_date_1__c,Cancellation_from_date_2__c,Cancellation_from_date_3__c,Cancellation_to_date_1__c,Cancellation_to_date_2__c,Cancellation_to_date_3__c , Program_Category__c,'
                    +'Program_Type__c,Session__c,Current_Admission_Year__c from NM_Payment_Form_Configuration__c WHERE Payment_Type__c =\'Admission\' and Program_Type__c =\'\' and Current_Admission_Year__c =:stringYear  and Session__c = :sessionValue and Program_Category__c =:chooseProgramVal';
                } else if(String.isNotBlank(progType)) {
                    query = query +' and Program_Type__c =:progType';
                }
                 query = query + ' ORDER BY CreatedDate desc LIMIT 1';

        List<NM_Payment_Form_Configuration__c> lstpaymentConfig = Database.query(query);
        if(!lstpaymentConfig.isEmpty()){
            NM_Payment_Form_Configuration__c nmConfig = lstpaymentConfig[0];
            lstDates = [SELECT id,From_Date__c,To_Date__c,Percentage__c,Amount__c,Admission_Fee__c,Percentage_Note__c FROM Cancelation_Date__c WHERE NM_Payment_Form_Configuration__c=:nmConfig.Id ORDER BY From_Date__c ASC];
            
            if(!lstDates.isEmpty()) {
                System.debug('lstDates Size ==>'+lstDates.size());
                lastDateForCancelation = lstDates[lstDates.size() - 1].To_Date__c; // Last record
            }

            for(NM_Payment_Form_Configuration__c nmpayConfig : lstpaymentConfig){
                this.mapofCancellationDates.put('CancelFromDate1', nmpayConfig.Cancellation_from_date_1__c);
                this.mapofCancellationDates.put('CancelToDate1', nmpayConfig.Cancellation_to_date_1__c);
                this.mapofCancellationDates.put('CancelFromDate2', nmpayConfig.Cancellation_from_date_2__c);
                this.mapofCancellationDates.put('CancelToDate2', nmpayConfig.Cancellation_to_date_2__c);
                this.mapofCancellationDates.put('CancelFromDate3', nmpayConfig.Cancellation_from_date_3__c);
                this.mapofCancellationDates.put('CancelToDate3', nmpayConfig.Cancellation_to_date_3__c);
                this.mapofCancellationDates.put('PaymentWindowEndDate',String.valueOf(nmpayConfig.Payment_Window_EndDate__c.format())); //valueOfGmt
                Datetime cancelDate3 = Date.parse(nmpayConfig.Cancellation_to_date_3__c.replace('.', '/'));
                this.mapofCancellationDates.put('CancelToformatDate3',  cancelDate3.format('dd MMMM yyyy'));
            }            
        }
    }

    public Id getApprovalProcessRecord(Id accId){
        Id approvalprocessId = null;
        List<ProcessInstanceWorkitem> lstpwi = [SELECT CreatedById,ElapsedTimeInMinutes,Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:accId order by ProcessInstance.LastActorId desc LIMIT 1];
        if(lstpwi.size() > 0){
            System.debug('lstpwi[0] '+lstpwi[0]);
            approvalprocessId = lstpwi[0].Id;
        }
        this.approvalId = approvalprocessId;
        System.debug('approval Id '+ this.approvalId);
        return approvalId;
    }
}