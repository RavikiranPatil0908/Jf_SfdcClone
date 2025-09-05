/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 07-31-2025
 * @last modified by  : @vickysahu
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   07--05--2025   @Ravi   Initial Version
**/
public without sharing class ReRegistrationFormController {
    public Id objectId;
    public String objectType;
    public Boolean isDataFetched;


    public Account objAccount{get;set;}
    //public List<Account> lstAccount {get;set;}
    public string message { get; set; }
    public list<string> lstMsg  { get; set; }
    public string strSecToShow { get; set; }
    public string HeaderMessage  { get; set; }
    public string strBtnURL  { get; set; }
    public String feesPaidSem {get;set;}
    public nm_StudentProgram__c objStudentProgram {get;set;}
    public String programStructure;
    // public String showerror{get;set;}
    // public String strtype {get;set;}
    // public String pdfBtnURL {get;set;}
    // public String IC {get;set;}
    // public String HO {get;set;}
    public String urlGenerate {get; set;}
    public nm_Payment__c objAdditionalChargerPayment ;
    // public Map<String,String> mapOfActiveCalenderCategoryAndMessage {get;set;}
    // public Opportunity objOpportunity ;
    public ProductHelper productHelper ;
    public String merchantTrackId {get;set;}
    //  public set<String> sasProgramAEP {get;set;}
    //  public set<String> sasPrograms {get;set;}
    // public String token {get;set;}
    // public String Src {get;set;}
    // public Boolean Inactive {get;set;}
    public Boolean  downPaymentDone {get;set;}
    public Boolean allowPayment {get;set;}

    //Added By Bala 04-12-2018
    //For OTP Verification Login
    public Boolean AdmissionPaymentPaid {get;set;}
    public Boolean LateFeePaid {get;set;}
    public Decimal TotalAmountReceived{get;set;}
    public String studentNo {get;set;}
    public String registrationNo {get;set;}
    // public String ipAddress {get;set;}
    // public Boolean isUserFromIndia {get;set;}
    // public List<API_Request__c> lstAPIRequests = new List<API_Request__c>();
    // ------ Coursera ------------------
    public Boolean showCoursera {get;set;}
    public Boolean isCourseraAlreadyOpted {get;set;}
    public String paymentUrl {get;set;}
    // public String programChangeUrl {get;set;}

    // ------------ lateralPopup
    // public Boolean showLateralPopup {get; set;}public OTPFields objOTP {get;set;}

    public Boolean alreadyDonePayment {get;set;}
    // public Boolean allowValidityExtension {get;set;}
    // public String corporateBatchName {get;set;}
    // public Boolean checkExpireDateforBatch {get;set;}
    public Boolean eligiableForRereg {get;set;}
    public Calender__c objCalender {get;set;}
    public String calendarSession {get;set;}
    public integer calendarSessionYear {get;set;}
    public String Sem {get;set;}
    public Opportunity objOppRecord {get;set;}
    public String strCurrentProgName {get;set;}
    public List<IC_Change_Request__c> lstICChange {get;set;}
    public Map<String, PriceBookEntry> mapPricebook;
    public List<PriceBookEntry> lstPriceBookEntry {get;set;}

    public List<Opportunity> lstOpportunity {get;set;}
    public List<SelectOption> lstPrograms  { get; set; }
    public List<SelectOption> getSelfLearningMaterial {get;set;}
    public List<SelectOption> getShippingOption {get;set;}
    public Map<String,String> mapOfInactiveProgramVsProgramName {get;set;}
    public List<String> errorMessage;
    public Set<String> invalidPrograms {get;set;}
    public String ipAddress {get;set;}
    public String strAccID {get; set;}
    public Boolean checkIfProgramIsEligible {get;set;}
    // public String message {get;set;}
    // public String strSecToShow {get;set;}
    public Integer strRegFor {get;set;}
    public Decimal progChangeFee {get;set;}
    public String changeProgram {get;set;}
    public Integer feePaidSem {get;set;}
    public Boolean programChangeRequested {get;set;}
    public String strSession {get;set;}
    public Integer intYear {get;set;}
    public Decimal totalPayFee {get;set;}
    public Boolean checkProgramSwitch {get;set;}
    public String chooseProgram {get;set;}
    public Boolean ICChangeRequested {get;set;}
    public String ChangeRequestedStatus {get;set;}
    public String strCitySelected {get;set;}
    public String strICSelected {get;set;}
    public String strChangeICReason {get;set;}
    public String strProgramSelected {get;set;}
    public String programSpecialization  {get;set;}
    // Program Fields
    public String strSelectedEligiblity {get;set;}
    public String strSelectedProg {get;set;}
    public String strProgChangeReason {get;set;}
    public String programChangeDiscalimer {get;set;}
    public String jsonMapOfEligibilityVsRequiredAcademicPercentage {get;set;}
    public Integer yearsEligibility {get;set;}
    public Boolean enableUpdateQualification {get;set;}
    public Boolean enableUpdateWRKEXP {get;set;}
    public Map<String,nm_EligiblityCriteria__c> mapOfIdVsEligiblity {get;set;}
    public List<nm_WorkExperience__c> lstWorkExperience {get;set;}
    public Set<Id> removedWorkExperience {get;set;}
    public Account objAccountClone {get;set;}
    public Boolean requireDocumentUpload {get;set;}
    public Boolean isNeedToAddStudentKit {get;set;}
    public Map<String,Id> mapOfNameVsId {get;set;}
    // Address Fields
    public AddressField address {get;set;}
    // Career Service Fields
    public CSPackage csProgram {get;set;}
    // Show Program to switch 
    public ShowAvailableProgram objAvialableProgram {get;set;}
    public String lcContactNumber {get;set;}
    public String centerLocationName {get;set;}
    // ------ Coursera ------------------
    public Coursera objCoursera {get;set;}

    public Campaign_Call__c objCampaignCall {get; set;}
    public String electiveSelected {get; set;}
    public Boolean isElectiveNeeded {get; set;}
    public String semFuture {get; set;}
    // public String oppPcId {get; set;}
    public List<String> lstConsideredFeeTypes = new List<String>{'FullFee-Considered','AnnualFeeLoan-Considered','FullFeeLoan-Considered','PGAllSemFee-Considered','AnnualFee-Considered','MultipleSemFee-Considered','MBAallTermfee-Considered','2SemFee-Considered','2TermFee-Considered','3SemFee-Considered','3TermFee-Considered','4SemFee-Considered','5SemFee-Considered'};
    public String IC;
    public Boolean showReregButton {get;set;}
    public String pgURL {get;set;}
    public String oppPcId {get;set;}



    public ReRegistrationFormController() {
        isDataFetched = false;
        msgInitialize();
        // objLead = new Lead();
        objAccount = new Account();
        objStudentProgram = new nm_StudentProgram__c(); 
        //lstAccount = new List<Account>();
        // mapOfActiveCalenderCategoryAndMessage = new Map<String,String>();
        // strtype = '';
        // pdfBtnURL ='';
        objAdditionalChargerPayment = new nm_Payment__c();
        // objOpportunity = new Opportunity();
        // call Product Helper for Checking Pending' Amount
        producthelper = new ProductHelper();
        allowPayment = false;
        feesPaidSem = '';

        // IC = '';
        // HO = '';
        urlGenerate = '';
        merchantTrackId='';
        alreadyDonePayment=false;
        AdmissionPaymentPaid =false;
        LateFeePaid = false;
        // Inactive = false;
        TotalAmountReceived = 0;
        downPaymentDone =false;
        // allowValidityExtension = false;
        showCoursera = false;
        isCourseraAlreadyOpted = false;
        paymentUrl = '';
        eligiableForRereg = false;
        objCalender = new Calender__c();
        calendarSession = '';
        calendarSessionYear = 0;
        //Sem = '2';
        objOppRecord = new Opportunity();
        strCurrentProgName = '';
        progChangeFee = 0.0;
        totalPayFee = 0;
        yearsEligibility = 0;
        mapPricebook = new map<string, PriceBookEntry>();
        mapOfInactiveProgramVsProgramName = new Map<String,String>();
        mapOfIdVsEligiblity = new Map<String,nm_EligiblityCriteria__c>();
        lstWorkExperience = new List<nm_WorkExperience__c>();
        mapOfNameVsId = new Map<String,Id>();
        removedWorkExperience = new Set<Id>();
        invalidPrograms = new Set<String>();
        errorMessage = new List<String>();
        changeProgram = 'No';
        checkIfProgramIsEligible = true; 
        programChangeDiscalimer = '';
        strSelectedProg = '';
        strProgChangeReason = '';
        feePaidSem = 0;
        programChangeRequested = false;

        ICChangeRequested = false;
        strCitySelected = '';
        strICSelected = '';
        strChangeICReason = '';
        ChangeRequestedStatus ='';
        strProgramSelected = '';
        programSpecialization  ='';
        strSession = '';
        intYear = 0;
        checkProgramSwitch = false;
        chooseProgram = '';
        enableUpdateQualification = false;
        enableUpdateWRKEXP = false;
        strSelectedEligiblity = '';
        requireDocumentUpload = false;
        jsonMapOfEligibilityVsRequiredAcademicPercentage = null;
        electiveSelected = '';
        semFuture = '';
        objAccountClone = new Account();
        isNeedToAddStudentKit = false;

        // address section
        address = new AddressField();
        //cs section
        csProgram = new CSPackage();
        // avialable Program Options 
        objAvialableProgram = new ShowAvailableProgram();
        lstPriceBookEntry = new List<PriceBookEntry>();
        lstOpportunity = new List<Opportunity>();
        lstPrograms = new List<SelectOption>();
        lstICChange = new List<IC_Change_Request__c>();
        getSelfLearningMaterial = new List<SelectOption>();
        getShippingOption =  new List<SelectOption>();
        objCoursera = new Coursera();
        objCampaignCall = new Campaign_Call__c();
        isElectiveNeeded = false;
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        strAccID = '';
        programStructure = '';
        showReregButton = true;
        pgURL = '';
        oppPcId = '';
    }

    public Id getObjectId() {
        System.debug('get Id');
        return this.objectId;
    }

    public void setObjectId(Id objectId) {
        system.debug('setObjectId --> ' );
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId) && !isDataFetched) {
            studentLogin();
            // queryRecordData(this.objectId); 
            // getSchedulingVVCCall(this.objectId);
            isDataFetched = true;
            if (eligiableForRereg && String.isEmpty(pgURL)) {
                queryBlock();
            }
            else if (!eligiableForRereg && lstMsg.isEmpty() && String.isEmpty(pgURL)){
                strSecToShow = 'msg';
                HeaderMessage = 'Re-Registration Error';
                strBtnURL = '';
                lstMsg.add('Hello! Re-Registration window is not yet opened.');
                return;
            }
        }
    }

    public String getObjectType() {
        System.debug('get type');
        return this.objectType;
    }
     
    public void setObjectType(String objectType) {
        System.debug('set type');
        this.objectType = objectType;
    }

     // section for login after student confirmed and for Re-Registred
    public void studentLogin()
    {
        msgInitialize();
        if( objectId != null && objectType == 'Account' ) {
            // get Query related to Account and Student Program
            getQueryRelatedToAccount();
            String closedWonSession = null;
            integer closedWonYear = 0;
            string AccountBatchName = null;
            String ValidityMonth = null;
            integer ValidityYear = 0;
            string FeeType=null;
            // Opportunity objOppRecord = new Opportunity();
            if(objAccount !=null)
            {   
                List<Opportunity> lstOpp = [select id,TermRepeated__c,ActualPendingAmount__c,EMI_Processing_Fee_Capital_Float__c,Capital_Float_Processing_Fee__c ,Loan_Approved__c,Loan_Sanctioned__c,
                                            Loan_Type__c,IcChangeFee__c,Is_Re_Registration_Payment__c, nm_Session__c, nm_Year__c ,nm_Category__c,ProgramChangeFee__c,Accountid,StageName,
                                            nm_Fee_Type__c, nm_PendingAmount__c,Loan_Amount__c,Sem__c,nm_Semester__c 
                                            from Opportunity where Accountid=:strAccID  order by nm_Semester__c desc];
                System.debug('lstOpp--->' + lstOpp.size() + ' '+ objAccount.id);
                // list<Opportunity> lstOpportunityToCheckPendingPaymnet = new List<Opportunity>();
                list<Opportunity> lstOpportunityToCheckPendingForLoanandInstallment = new List<Opportunity>();
                list<Opportunity> lstOpportunityClosedorPaid = new List<Opportunity>();
                list<Opportunity> lstOpportunityClosedWonReRegistrationPending = new List<Opportunity>(); //added new//
                list<Opportunity> lstOpportunityToCheck = new List<Opportunity>();
                list<Opportunity> lstOpportunityTermFeePending = new List<Opportunity>();
                if(lstOpp.size() > 0){
                    for(Opportunity opp:lstOpp){
                        String stageName = opp.StageName;
                        System.debug('stageName--->' + stageName);

                        if(String.isNotBlank(stageName) && (stageName == 'Pending Payment - Loan' || stageName == 'Pending Payment - Instalment')){  
                            System.debug('stageName--->' + 'Pending Payment - Loan');                                                    
                            lstOpportunityToCheckPendingForLoanandInstallment.add(opp);
                        }else if(String.isNotBlank(stageName) && (stageName == 'Payment made' || stageName == 'Closed Won')){
                            lstOpportunityClosedorPaid.add(opp);
                        }else if(String.isNotBlank(stageName) && (stageName == 'Closed Won - Re-registration Pending' || stageName == 'Re-Registration Pending' || stageName=='Pending Payment')){                           
                            lstOpportunityClosedWonReRegistrationPending.add(opp);
                        }                       
                        if(opp.TermRepeated__c && stageName.contains('Pending Payment'))
                        {
                            lstOpportunityTermFeePending.add(opp);     
                        }
                    }
                }

                // do not allowed EMERSON student go for make payment Page Instead of it allowed to Print Form
                if(objAccount.nm_Centers__r.name =='EMERSON')
                {
                    strSecToShow = 'msg';
                    HeaderMessage = 'Important Message';
                    // strBtnURL = 'nmPrintAdmissionForm?id='+objAccount.id;
                    strBtnURL = 'nmPrintAdmissionForm?id='+strAccID;
                    lstMsg.add('Kindly Print Your Form');
                    return;
                }
                System.debug('objAdditionalChargerPayment---->'+objAdditionalChargerPayment);

                if(objAdditionalChargerPayment !=null)
                {
                    // PageReference pgURL = new PageReference('/apex/nmAdditonalCharge?&id='+ objAdditionalChargerPayment.id);
                    // pgURL.setRedirect(true);
                    // return pgURL;
                    pgURL = '/nmAdditonalCharge?&id='+ objAdditionalChargerPayment.id;
                    return;
                }
            
                if(objAccount.Interview_Status__c == 'Rejected'){
                    System.debug('Interview Status--'+objAccount.Interview_Status__c);
                    String msg = 'Sorry , we regret to inform you that your Interview status is Rejected for '+objAccount.Program_Name__c+' program .';
                    strSecToShow = 'msg';
                    HeaderMessage = 'Interview Status';
                    lstMsg.clear();
                    lstMsg.add(msg);
                    return;
                }
            
                //get Most recent Closed won or Payment Made Opportunity Session and Year
                Opportunity mostRecentClosedPaidOpportunity = null;
                if(lstOpportunityClosedorPaid != null &&  lstOpportunityClosedorPaid.size() > 0)
                {
                    mostRecentClosedPaidOpportunity = lstOpportunityClosedorPaid[0];
                    closedWonSession = mostRecentClosedPaidOpportunity.nm_Session__c;
                    closedWonYear = Integer.valueOf(mostRecentClosedPaidOpportunity.nm_Year__c);
                }

                System.debug('size1---->'+ objAccount.Student_Program__r.size());
                if( objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0 )
                {
                    System.debug('size---->'+ objAccount.Student_Program__r.size());
                    list<Calender__c> lstCal = getActiveReregCalender();
                    
                    System.debug('lstOpportunityToCheckPendingForLoanandInstallment-->'+lstOpportunityToCheckPendingForLoanandInstallment.size());
                    //Term Repeated                     
                    if((lstOpportunityToCheckPendingForLoanandInstallment.size() > 0 && lstOpportunityToCheckPendingForLoanandInstallment !=null) 
                    || (lstOpportunityTermFeePending.size() > 0 && lstOpportunityTermFeePending !=null))
                
                    {  
                        System.debug('lstOpportunityToCheckPendingForLoanandInstallment-->'+lstOpportunityToCheckPendingForLoanandInstallment.size());
                        if(lstOpportunityTermFeePending.size()>0)
                        {
                            objOppRecord = lstOpportunityTermFeePending[0];
                        }else
                        {
                            objOppRecord = lstOpportunityToCheckPendingForLoanandInstallment[0];
                        }
                        //Payment is made, but not yet approved. Allow him to only download Form, and nothing else                       
                        decimal pendingAmount = (decimal)objOppRecord.ActualPendingAmount__c;                       
                        Feetype = objOppRecord.nm_Fee_Type__c;
                        system.debug('Feetype--->'+Feetype );
                        if(pendingAmount > 0 && pendingAmount !=null)
                        {
                            set<String> setOfOppsId = new set<String>{objOppRecord.id};
                            List<nm_Payment__c> lstOppsRelatedPayment = [select nm_Installment_Payment_Ref__c,id,nm_Amount__c,nm_Merchant_Track_Id__c ,nm_OpportunityNew__c,nm_OpportunityNew__r.IC__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c,nm_OpportunityNew__r.nm_Fee_Type__c from nm_Payment__c where nm_OpportunityNew__c In :setOfOppsId and nm_PaymentStatus__c !='Transaction Failed'];
                            // get all Opportunity Line Item related to Opportunity to update Semester Line Item after Fee Type Changes
                            Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = productHelper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
                            List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.get(objOppRecord.id) ;
        

                            boolean LateFeeProductInserted = false ;
                            boolean TermFeeProductInserted = false;
                            // boolean downPaymentDone = false;
                            String merchantTrackId = '';
                            decimal LateFee = 0.0;
                            decimal Termfee =0.0 ;
                        
                            if (Feetype=='MBAallTermfee-Considered')
                            {
                                AdmissionPaymentPaid  =true ;
                            }
                            if(lstOppsRelatedPayment.size()>0)
                            {
                            CheckalreadyDonePayment(lstOppsRelatedPayment,objAccount.nm_ChooseaProgram__c,objAccount.Is_Lateral__c);
                            system.debug('AdmissionPaymentPaid-->'+AdmissionPaymentPaid);
                            }
                            if(lstOpportunitylineItem.size() > 0)
                            {
                                for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
                                {
                                    if(objLineIteam.Product_Name__c.contains('Late Fee'))
                                    {
                                        LateFeeProductInserted = true;
                                        LateFee = objLineIteam.UnitPrice;
                                    }
                                    else if(objLineIteam.Product_Name__c.contains('Repeat Term'))
                                    {
                                        TermFeeProductInserted = true;
                                        Termfee = objLineIteam.UnitPrice;
                                        if(objOppRecord.Sem__c < Integer.valueOf(Sem)) {
                                            Sem = String.valueOf(objOppRecord.Sem__c);
                                        }
                                        System.debug('Repeat Term Product contains Pending Fee==>'+pendingAmount+' Termfee==>'+Termfee);
                                    }
                                }    
                            }
                        
                            if(TermFeeProductInserted && pendingAmount >= Termfee)      
                            {
                                System.debug('nmPaymentNew?&IsReRestration=true&oppId==>'+objOppRecord.id);                               
                                strSecToShow = 'msg';
                                HeaderMessage = 'Important Message';
                                lstMsg.add('Pending Amount for Repeat term Rs' +Termfee);                             
                                //strBtnURL = 'nmPaymentNew?&IsReRestration=true&oppId='+objOppRecord.id+ urlGenerate +'&id='+objOppRecord.AccountId;
                                strBtnURL = 'EnrollmentForm?nav=payment';
                                return;
                            }
                            //Opportunity objOppRecord = lstOpportunityToCheckPendingForLoanandInstallment[0];
                            // if Admission Payment not paid then call nmPaymentnew
                            system.debug('downPaymentDone--->'+downPaymentDone);
                            if(downPaymentDone){
                                DownPaymentcheck(objOppRecord);
                                return;
                            }
                            else if(!AdmissionPaymentPaid || TermFeeProductInserted) {
                                
                                if(LateFeeProductInserted && !LateFeePaid)
                                {
                                    pendingAmount = pendingAmount - LateFee ;
                                }
                                System.debug('enter in pending Admission fee');
                                //Opportunity is already created for new Session, but not paid. Ask student to pay now
                
                                // PageReference pgURL = new PageReference(System.Label.GoPayment_Url+'id='+ objAccount.id+'&IsReRestration=true&sem='+Sem + urlGenerate +'&amount='+pendingAmount);
                                //PageReference pgURL = new PageReference('/EnrollmentForm?nav=payment');
                                // PageReference pgURL = new PageReference('/apex/postPaymentPage?ResTrackId='+merchantTrackId);
                                // pgURL.setRedirect(true);
                                // return pgURL;
                                pgURL = '/EnrollmentForm?nav=payment';
                                return;
                            }else{ // if Admission Payment is Made then call Additional Charge for Taking remaning Late Fee
                                //Opportunity is already created for new Session, but not paid. Ask student to pay now
                                System.debug('Pending Late Fee Amount--->'+pendingAmount);
                                // PageReference pgURL = new PageReference('/apex/nmAdditonalCharge?&id='+objOppRecord.id+'&amount='+objOppRecord.ActualPendingAmount__c);
                                // pgURL.setRedirect(true);
                                pgURL = '/apex/nmAdditonalCharge?&id='+objOppRecord.id+'&amount='+objOppRecord.ActualPendingAmount__c;
                                return;
                            }
                        }
                    }

                    //Added by Sanket Start
                    if(calendarSession != null && calendarSessionYear != 0 && calendarSession == closedWonSession && calendarSessionYear == closedWonYear)
                    {
                        //Money is already paid for current session. Do not show option to register for future sem and allow to download receipt of paid semester
                        strSecToShow = 'msg';
                        System.debug('<----------Entered in Loop ------>');
                        feesPaidSem= String.valueOf(integer.valueOf(feesPaidSem));
                        HeaderMessage = 'Print Form.';
                        strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+lstOpportunityClosedorPaid[0].Accountid+'&sem='+mostRecentClosedPaidOpportunity.nm_Semester__c;
                        lstMsg.add('Please click OK to print form for Sem '+mostRecentClosedPaidOpportunity.nm_Semester__c + ' registration.');
                        List<String> lstPGProgram = new List<String>{'Certificate Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
                        verifyProgramChangeShouldBeAllowed(String.valueOf(mostRecentClosedPaidOpportunity.Sem__c), mostRecentClosedPaidOpportunity.nm_Session__c, mostRecentClosedPaidOpportunity.nm_Year__c, objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c, objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c, mostRecentClosedPaidOpportunity.id);
                        // if(lstPGProgram.contains(objAccount.nm_ChooseaProgram__c) || (objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c == 'MBA')) {
                        //     Map<String,Decimal> feeTypeVsSem = new Map<String,Decimal>{'admission'=>1,'AnnualFee'=>2,'3SemFee'=>3,'MultipleSemFee'=>3};
                        //     Decimal totalSem = objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c;
                        //     if(!mostRecentClosedPaidOpportunity.Is_Re_Registration_Payment__c && feeTypeVsSem.containsKey(mostRecentClosedPaidOpportunity.nm_Fee_Type__c)
                        //     && feeTypeVsSem.get(mostRecentClosedPaidOpportunity.nm_Fee_Type__c) < totalSem) {
                        //         lstMsg.add('Click Proceed to Pay button to pay the balance amount');
                        //         //paymentUrl = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + urlGenerate +'&oppId=' + mostRecentClosedPaidOpportunity.id+'&sem='+mostRecentClosedPaidOpportunity.Sem__c+'&pp=true';
                        //     }
                        // }
                        return;
                    }

                    AccountBatchName = string.valueOf(objAccount.Batch__c);
                    String validityStatus ='';
                    system.debug('<---AccountBatchName-->'+AccountBatchName);
                    String AccountBatchYear = AccountBatchName.right(4);
                    String AccountBatchMonth = AccountBatchName.left(3);
                    Boolean ReRegAllowed = false;
                    String validitymon = (objAccount.Extend_Validity_upto_Month__c!='' && objAccount.Extend_Validity_upto_Month__c!=null) ?objAccount.Extend_Validity_upto_Month__c.left(3):objAccount.Validity_Month__c.left(3);
                    Integer validyear = objAccount.Extend_Validity_Upto_Year__c!=null ? Integer.valueof(objAccount.Extend_Validity_Upto_Year__c) :  Integer.valueof(objAccount.Validity_Year__c);
                    system.debug('<---validyear -->'+validyear );
                    ValidityForStudentLogin checkStudent = new ValidityForStudentLogin();
                
                    // <-------------------------------------------------------------------------------------------------------->//            
                    List<nm_StudentProgram__c> lstStudentProgram = [select id,nm_Student__c,nm_Program__r.nm_Type__c from nm_StudentProgram__c where nm_Student__c=:objAccount.id];
                    List<nm_StudentProgram__c> lstProgramForPostGrad = new List<nm_StudentProgram__c>();
                    List<nm_StudentProgram__c> lstProgramForDiploma = new List<nm_StudentProgram__c>();
                    List<nm_StudentProgram__c> lstProgramForCertificate = new List<nm_StudentProgram__c>();

                    if(lstStudentProgram.size() > 0){
                        for(nm_StudentProgram__c studProg : lstStudentProgram){
                            if(studProg.nm_Program__r.nm_Type__c == 'Post Graduate Diploma Programs'){
                                ReRegAllowed=true;
                                lstProgramForPostGrad.add(studProg);
                            }else if(studProg.nm_Program__r.nm_Type__c == 'Diploma Programs'){
                                ReRegAllowed=true;
                                lstProgramForDiploma.add(studProg);
                            }else if(studProg.nm_Program__r.nm_Type__c == 'Certificate Programs'){
                                ReRegAllowed=true;
                                lstProgramForCertificate.add(studProg);
                            }
                        }
                    }

                    system.debug('<-- lstProgramForPostGrad-->'+ lstProgramForPostGrad.size()+'lstOpportunityValues------>'+'<-------------->');
                    Integer driveYear = getDriveYear(objAccount.Batch__c);
                    if(ReRegAllowed && (objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c < objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c) 
                        && (objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c==objCalender.nm_Type__c)
                        && (objCalender.Session_Start_Date__c<= date.today() && date.today() <= objCalender.Session_End_Date__c) 
                        )
                    {
                        System.debug('1'+objCalender.Session__c+'2'+calendarSessionYear+'3'+integer.valueOf(AccountBatchYear)+'4'+AccountBatchMonth+'5'+feesPaidSem);
                        validityStatus = checkStudent.checkValidityForPGforLogin(objCalender.Session__c,calendarSessionYear,validyear,validitymon,objAccount.Sem__c);
                        System.debug('<--------validityStatus--------->'+validityStatus);
                        // if(validityStatus == 'RedirectPG' && objAccount.Validity_Month__c !='September'){
                        if(validityStatus == 'RedirectPG'){
                            if(!objAccount.Provisional_With_Hold__c || driveYear > 2023) {
                                List<String> batchNotAllowed = Label.ReReg_Batch_Not_Allowed.split(';');
                                if (batchNotAllowed.contains(objAccount.Batch__c)) {
                                    system.debug('<--Error Block For ReReg Not allowed for -> ' + objAccount.Batch__c);
                                    strSecToShow = 'msg';
                                    HeaderMessage = 'Re-Registration Error';
                                    strBtnURL = '';
                                    lstMsg.add('Hello! Re-Registration window is not yet opened.');
                                    return;
                                } else {
                                    // System.debug('Entered PostGrad Validity If Block');
                                    // pageReference pg = new pageReference ('/apex/'+Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id + urlGenerate +'&calendarSession='+calendarSession+ '&calendarSessionYear='+calendarSessionYear);
                                    // pg.setRedirect(true);
                                    // return pg;
                                    eligiableForRereg = true;
                                }
                            } else {
                                system.debug('<--Error Block For Post Grad Validity->');
                                strSecToShow = 'msg';
                                HeaderMessage = 'Re-Registration Error';
                                strBtnURL = '';
                                lstMsg.add('Hello! Your re-registration has been put on hold. To reactivate the same, please complete your document submission process(as per eligibility criteria). You may submit all documents to your AEP.');
                                return;
                            }
                        }
                        else
                        {
                            system.debug('<--Error Block For Post Grad Validity->');
                            strSecToShow = 'msg';
                            HeaderMessage = 'Re-Registration Error';
                            strBtnURL = '';
                            lstMsg.add('Can not Re-Register because your '+lstStudentProgram[0].nm_Program__r.nm_Type__c +' validity Expired');
                            return;
                        }
                    }
                    else
                    {
                        /* @BK 26-10-2019
                        ** Conditions updated to stop re-registration Form for MBA-(WX) & MBA-(X).
                        */
                        if((objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c==objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c)
                        || (objAccount.nm_ChooseaProgram__c=='Master Programs' && (objAccount.Program_Type__c=='MBA (WX)' || objAccount.Program_Type__c=='MBA (X)')) )
                        {
                            //Fees paid for all semesters. Student can download Form/Receipt. No more Re-registration
                            strSecToShow = 'msg';
                            HeaderMessage = 'Re-registration - Not Applicable.';
                            // strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+lstOpportunityToCheckPendingPaymnet[0].Accountid+'&sem='+feesPaidSem;
                            strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+objAccount.id+'&sem='+feesPaidSem;
                            lstMsg.add('Re-Registration to next semester not possible for this Program');
                            lstMsg.add('Please click OK to print form');
                            return;
                        }
                        //mayur 27-Oct-2015 -- for ClosedWon For ReRegistration Payment directly Redirect to ReRegistration Page
                        else if(lstOpportunityClosedWonReRegistrationPending.size()>0 || lstCal.size()>0)
                        {
                            if(!objAccount.Provisional_With_Hold__c || driveYear > 2023) {
                                List<String> batchNotAllowed = Label.ReReg_Batch_Not_Allowed.split(';');
                                if (batchNotAllowed.contains(objAccount.Batch__c)) {
                                    system.debug('<--Error Block For ReReg Not allowed for -> ' + objAccount.Batch__c);
                                    strSecToShow = 'msg';
                                    HeaderMessage = 'Re-Registration Error';
                                    strBtnURL = '';
                                    lstMsg.add('Hello! Re-Registration window is not yet opened.');
                                    return;
                                } else {
                                    // PageReference pgURL = new PageReference('/apex/'+Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id +urlGenerate+'&calendarSession='+calendarSession+ '&calendarSessionYear='+calendarSessionYear);
                                    // pgURL.setRedirect(true);
                                    // return pgURL;
                                    eligiableForRereg = true;
                                }
                            } else {
                                system.debug('<--Error Block For Post Grad Validity->');
                                strSecToShow = 'msg';
                                HeaderMessage = 'Re-Registration Error';
                                strBtnURL = '';
                                lstMsg.add('Hello! Your re-registration has been put on hold. To reactivate the same, please complete your document submission process(as per eligibility criteria). You may submit all documents to your AEP. ');
                                return;
                            }
                            
                        }
                        else
                        {
                            //Re-registration - Not Yet Open
                            strSecToShow = 'msg';
                            HeaderMessage = 'Re-registration - Not Yet Open.';
                            strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+objAccount.id+'&sem='+feesPaidSem;
                            lstMsg.add('Re-Registration for Next semester not yet open');
                            lstMsg.add('Please click OK to print form of last semester');
                            verifyProgramChangeShouldBeAllowed(String.valueOf(mostRecentClosedPaidOpportunity.Sem__c), mostRecentClosedPaidOpportunity.nm_Session__c, mostRecentClosedPaidOpportunity.nm_Year__c, objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c, objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c, mostRecentClosedPaidOpportunity.id);
                            // List<String> lstPGProgram = new List<String>{'Certificate Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
                            // if(lstPGProgram.contains(objAccount.nm_ChooseaProgram__c) || (objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c == 'MBA')) {
                            //     Map<String,Decimal> feeTypeVsSem = new Map<String,Decimal>{'admission'=>1,'AnnualFee'=>2,'3SemFee'=>3,'MultipleSemFee'=>3};
                            //     Decimal totalSem = objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c;
                            //     if(!mostRecentClosedPaidOpportunity.Is_Re_Registration_Payment__c && feeTypeVsSem.containsKey(mostRecentClosedPaidOpportunity.nm_Fee_Type__c)
                            //     && feeTypeVsSem.get(mostRecentClosedPaidOpportunity.nm_Fee_Type__c) < totalSem) {
                            //         lstMsg.add('Click Proceed to Pay button to pay the balance amount');
                            //         paymentUrl = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + urlGenerate +'&oppId=' + mostRecentClosedPaidOpportunity.id+'&sem='+mostRecentClosedPaidOpportunity.Sem__c+'&pp=true';
                            //     }
                            // }
                            return;
                        }
                    }
                }else // else if Student Program Is Closed Then allowed to Print form
                {  
                    list<Account> lststudent = [select id, name, nm_StudentStatus__c ,nm_StudentNo__c,nmCaptureOpportuntiyStage__c,nm_RegistrationNumber__c, nm_DateOfBirth__c,
                                                (
                                                    select id, nm_FeesPaidofSemester__c,  nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c
                                                    from Student_Program__r
                                                    where nm_IsClosed__c = true
                                                )
                                                from Account
                                                where nm_StudentNo__c =: objAccount.nm_StudentNo__c
                                                and nm_DateOfBirth__c =: objAccount.nm_DateOfBirth__c limit 1];
                    strSecToShow = 'msg';
                    String finalFees = string.valueOf(lststudent[0].Student_Program__r[0].nm_FeesPaidofSemester__c);
                    System.debug('<----------finalFees---------->'+finalFees);
                    HeaderMessage = 'Invalid Student';
                    strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+lststudent[0].id+'&sem='+finalFees;      
                    lstMsg.add('Re-registration - Not Applicable');
                    lstMsg.add('Please click OK to print form');
                    return;
                }
            }
        }
    }

    public list<Calender__c> getActiveReregCalender() {
        // string Sem = '';
        System.debug('program check--->' +  JSON.serialize(objAccount.Student_Program__r[0]));
        string Sem1 = string.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
        string Sem2 = string.valueOf(integer.valueOf((integer)(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) +1));
        feesPaidSem = String.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
        String programType = objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c;
        String programSpecialization = objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c;
        list<Calender__c> lstCal = new  list<Calender__c>();
        
        if(String.isNotBlank(programSpecialization)) {
            lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                    where Category__c='Re-Registration' and nm_Type__c=:programType 
                                    and Specialisation__c=:programSpecialization 
                                    and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() Order By nm_Semester__c ASC ];
        } else {
            lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                        where Category__c='Re-Registration' and nm_Type__c=:programType and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() Order By nm_Semester__c ASC];
        }
    
        // Calender__c objCalender = new Calender__c();
        // String calendarSession = null;
        // integer calendarSessionYear = 0;
    
        if(!lstCal.isEmpty()) {
            for (Calender__c objCal : lstCal) {
                if ((objCal.nm_Semester__c == Sem1) || (objCal.nm_Semester__c == Sem2) ) {
                    objCalender = objCal;
                    calendarSession = objCalender.Session__c;
                    calendarSessionYear =Integer.valueOf(objCalender.Year__c);
                    Sem = objCalender.nm_Semester__c;
                    break;
                }
            }
        }
        System.debug('calendarSession ==>'+calendarSession);
        System.debug('calendarSessionYear ==>'+calendarSessionYear);
        Sem = String.isNotBlank(Sem) ? Sem : string.valueOf(integer.valueOf((integer)(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) +1));
        return lstCal;
    }


    private Integer getDriveYear(String batch) {
        Integer driveYear = 0;
        try {
            if(String.isNotBlank(batch)) {
                driveYear = Integer.valueOf(batch.split(' ')[1]);
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            driveYear = 0;
        }
        return driveYear;
    }

    public void verifyProgramChangeShouldBeAllowed(String Sem, String currentSession, Decimal currentYear, String programType, String programSpecialization, String oppId) {
        list<Calender__c> lstCal = new  list<Calender__c>();
        if(programSpecialization !=null && programSpecialization !=''){
            lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                    where Category__c='Re-Registration' and nm_Type__c=:programType 
                                    and Specialisation__c=:programSpecialization 
                                    and nm_Semester__c =: Sem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
        } else{
            lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                    where Category__c='Re-Registration' and nm_Type__c=:programType and nm_Semester__c =: Sem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
        }
        system.debug('currentSession --> '+ currentSession +  ' currentYear ---> ' + currentYear + ' Sem ---> ' + Sem  );
        if(lstCal!= null && lstCal.size() > 0 && currentSession == lstCal[0].Session__c && currentYear == lstCal[0].Year__c){
            system.debug('lstCal[0] --> '+ JSON.serialize(lstCal) );
            // programChangeUrl = Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id +urlGenerate+'&calendarSession='+lstCal[0].Session__c+ '&calendarSessionYear='+lstCal[0].Year__c+'&oppSem='+Sem + '&oppPcId='+oppId;
            eligiableForRereg = true;
            this.Sem = Sem;
            this.calendarSession = currentSession;
            this.calendarSessionYear = Integer.valueOf(currentYear);
            oppPcId = oppId;
        }
    }


    public void DownPaymentcheck(Opportunity objOpportunity)
    {
        if(objOpportunity!=null)
        {
            decimal pendingAmount = objOpportunity.ActualPendingAmount__c;   
            Decimal loanAmount = (objOpportunity.Loan_Amount__c!=null && objOpportunity.Loan_Amount__c!='') ? Decimal.valueOf(objOpportunity.Loan_Amount__c) : 0;
            Decimal remainingPendingAmount = pendingAmount;
            
            if(pendingAmount >= loanAmount && !objOpportunity.Loan_Approved__c) {
                remainingPendingAmount = (Decimal)pendingAmount - loanAmount;
            }
            system.debug('remainingPendingAmount-->'+remainingPendingAmount);
            system.debug('loanAmount-->'+loanAmount);
            if(loanAmount >= pendingAmount && objOpportunity.Loan_Approved__c){
                lstMsg.clear();
                lstMsg.add('Your Loan Application is Approved, Loan is under process for disbursal...');
                lstMsg.add('Proceed to Loan Application ...');
                strSecToShow = 'msg';
                HeaderMessage = 'Important Message';
                strBtnURL = 'postPaymentPage?ResTrackId='+merchantTrackId; 
                //strBtnURL = 'EnrollmentForm?nav=payment';
            }else if((!objOpportunity.Loan_Approved__c) && (remainingPendingAmount <= 0 || loanAmount == 0)){
                system.debug('Enter section1');
                lstMsg.clear();
                lstMsg.add('Your Loan Application is Under Approval.');
            
                if(objOpportunity.Loan_Type__c.contains('Capital Float')){
                lstMsg.add('You have opted for Capital Float Loan application , will confirm once done . Kindly Print Form.');
                }else if(objOpportunity.Loan_Type__c!=null){
                    System.debug('proceed to loan');
                    lstMsg.add('Proceed to Loan Application ...');
                    strSecToShow = 'msg';
                    HeaderMessage = 'Important Message';
                    strBtnURL = 'postPaymentPage?ResTrackId='+merchantTrackId;
                    //strBtnURL = 'EnrollmentForm?nav=payment';
                    // return null;
                }
            }                   
            else if(objOpportunity.ActualPendingAmount__c > 0 && (AdmissionPaymentPaid || remainingPendingAmount > 0) )
            {
                remainingPendingAmount = AdmissionPaymentPaid ? pendingAmount : remainingPendingAmount;
                System.debug('objOpportunity.ActualPendingAmount__c--->'+objOpportunity.ActualPendingAmount__c);
                strSecToShow = 'msg';
                HeaderMessage = 'Important Message';
                lstMsg.add('Pending Amount for semester ' + objOpportunity.nm_Semester__c + ' Rs. ' +remainingPendingAmount+'.');
                strBtnURL = 'nmAdditonalCharge?&id='+ objOpportunity.id +'&amount='+remainingPendingAmount;
                system.debug('Enter section2');
            }
            else if(!objOpportunity.Is_Re_Registration_Payment__c){
                lstMsg.clear();
                lstMsg.add('Your Loan Application is  Approved.');
                lstMsg.add('Kindly Print Form.');
                strSecToShow = 'msg';
                HeaderMessage = 'Important Message';
                strBtnURL = 'nmPrintAdmissionForm?id='+objOpportunity.AccountId;
                system.debug('Enter section3');
            } 
            else {
                lstMsg.clear();
                lstMsg.add('Your Loan Application is  Approved.');
                lstMsg.add('Kindly Print Form.');
                strSecToShow = 'msg';
                HeaderMessage = 'Important Message';
                strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+objOpportunity.AccountId+'&sem='+objOpportunity.nm_Semester__c;
            }
        }
    }

    // public void getMapOfActiveCalender()
    // {
    //     List<Calender__c> lstActiveCalender = [Select id, Category__c ,Closure_Message__c ,Session__c ,Year__c ,Session_End_Date__c ,nm_Type__c,Session_Start_Date__c
    //                                           from Calender__c
    //                                           where Session_Start_Date__c <= :Date.Today() ];
    //     if(lstActiveCalender.size() > 0)
    //     {
    //         for(Calender__c objCal : lstActiveCalender)
    //         {
    //             if(objCal.Session_End_Date__c >= Date.today()) // if Calender is live then don't show error msg
    //             {
    //                 System.debug('calender Live--'+objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c);
    //                 mapOfActiveCalenderCategoryAndMessage.put(objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c,'Calender Live');
    //             }else{ // if Calender is live then show error msg
    //                  System.debug('Window Closed --'+objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c);
    //                 mapOfActiveCalenderCategoryAndMessage.put(objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c +'-'+objCal.nm_Type__c ,objCal.Closure_Message__c );
    //            }  
    //         }
    //     }
    // }


     public void CheckalreadyDonePayment (list<nm_Payment__c> lstPayment,String chooseProgram, Boolean Lateral)  
    {     

        for( nm_Payment__c objpay : lstPayment)
        {
            if( objpay.nm_Amount__c != null && objpay.nm_PaymentStatus__c != null && objpay.nm_PaymentType__c != null && (objPay.nm_PaymentStatus__c =='Payment Made' || objPay.nm_PaymentStatus__c =='Payment Approved'))
            {
                TotalAmountReceived = +objpay.nm_Amount__c;
                if(objpay.nm_PaymentType__c =='Admission')
                {
                    AdmissionPaymentPaid =true;
                    if(objpay.nm_Installment_Payment_Ref__c !=null && !objpay.nm_Installment_Payment_Ref__c.contains('-'))
                    {
                        if(chooseProgram =='Post Graduate Diploma Programs')
                        {
                            if((objpay.nm_Installment_Payment_Ref__c =='PGAllSemFee') && !Lateral)
                            {
                                    alreadyDonePayment = true;
                            }else if((objpay.nm_Installment_Payment_Ref__c =='MultipleSemFee') && Lateral){
                                    alreadyDonePayment = true;
                            }
                        }else if(chooseProgram =='Diploma Programs')
                        {
                            if((objpay.nm_Installment_Payment_Ref__c =='AnnualFee' ) && !Lateral)
                            {
                                    alreadyDonePayment = true;
                            }
                        }else if(chooseProgram =='Professional Programs')
                        {
                            if(objpay.nm_Installment_Payment_Ref__c =='AnnualFee'  || objpay.nm_Installment_Payment_Ref__c =='2TermFee' )
                            {
                                    alreadyDonePayment = true;
                            }
                        }
                    }
                }else if(objpay.nm_PaymentType__c =='Late Fees')
                {
                    LateFeePaid = true;
                }else if(objPay.nm_PaymentType__c.contains('DownPayment') ){
                    downPaymentDone = true;
                    merchantTrackId = objPay.nm_Merchant_Track_Id__c;
                }else if(objpay.nm_PaymentType__c.contains('Coursera')) {
                    isCourseraAlreadyOpted = true;
                }
            }
        }       
        
    }

    public void msgInitialize() {
        strSecToShow = '';
        message = '';
        HeaderMessage = '';
        strBtnURL='';
        lstMsg = new list<string>();        
    }


    public void getQueryRelatedToAccount()
    {
            // String accountQuery = 'SELECT id,Adhar_Card_Number__c,Interview_Status__c,Is_Lateral__c,Provisional_With_Hold__c,Extend_Validity_Upto_Year__c,Extend_Validity_upto_Month__c,Validity_Month__c,nm_Centers__r.name,nm_ChooseaProgram__c,'+
            // 'Validity_Year__c,Sem__c,Batch__c,name, nm_StudentStatus__c ,nm_StudentNo__c,nmCaptureOpportuntiyStage__c,nm_RegistrationNumber__c,PersonMobilePhone,PersonEmail,PersonContactId,'+
            // 'nm_DateOfBirth__c,Program_Type__c,nm_LeadId__c,'+
            // '('+
            //    ' SELECT id, nm_FeesPaidofSemester__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_Program__r.Specialisation__c '+
            //     'FROM Student_Program__r '+
            //     'WHERE nm_IsClosed__c = false LIMIT 1'+
            // ')'+
            // 'FROM Account WHERE Id =:objectId LIMIT 1 ';

            // List<Account> lstAccount = DataBase.query(accountQuery);
            List<Account> lstAccount = [SELECT id, Name,Batch__c,nm_Tagged_Pricebook__c,nm_DefencePersonnel__c,nm_StudentImageUrl__c, FirstName, lastname, nm_StudentNo__c, nm_DateOfBirth__c, nm_Centers__c, nm_Gender__c, Phone,nm_Centers__r.Name,nm_Centers__r.nm_CenterGroup__c,
                                    PersonMobilePhone, PersonEmail,nm_PostalCode__c,nm_StudentImage__c,Shipping_Street__c ,SLF__c,IsPersonAccount,nm_Centers__r.nm_LearningCenter__r.Contact_No_1__c,nm_Centers__r.Contact_No_1__c,nm_Drive_Name__c,
                                    House_No_Name_Shipping_Account__c, Locality_Name_Shipping__c,Street_Shipping_Account__c,City_Shipping_Account__c,State_Province_Shipping__c,Country_Shipping__c,Zip_Postal_Code_Shipping__c,Program_Type__c,BatchStartD__c,
                                    nm_Centers__r.Owner.Email,nm_Centers__r.nm_CenterCode__c,nm_Centers__r.nm_LearningCenter__r.Name,nm_Centers__r.Nm_Active__c,Shipping_Address_Choice__c,nm_ChooseaProgram__c,Percentage_Bachlor__c,nm_BachelorsDegreeName__c,nm_Specialization__c,
                                    nm_NameOfCollege__c,nm_NameofUniversity__c,Other_University_Name__c,University_Type__c,nm_GraduationDegreeMode__c,nm_YearofCollegeCompletion__c,nm_WorkExperience__c,nm_IPForLead__c,nm_EligiblityCriteria__c,nm_StudentStatus__c,
                                    Extend_Validity_Upto_Year__c,Validity_Year__c,Extend_Validity_upto_Month__c,Validity_Month__c,Interview_Status__c,Is_Lateral__c,Provisional_With_Hold__c,Sem__c,nm_LeadId__c,Program_Name__c,
                                    (
                                        SELECT id, nm_CurrentSession__c,nm_Program__r.nmIsActive__c, nm_FeesPaidofSemester__c, nm_IsClosed__c, nm_Program__c, nm_Program__r.nm_TotalSemesters__c,nm_Student__c,
                                        nm_program__r.name, nm_program__r.nm_Type__c, nm_PreviousProgram__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.id , nm_Program__r.ReRegonly__c, nm_Program__r.prgst__c,
                                        nm_program__r.Specialisation__c
                                        FROM Student_Program__r WHERE nm_IsClosed__c = false LIMIT 1
                                    ),(SELECT Id,nm_StartDate__c,nm_EndDate__c,Currently_Working_Here__c,nm_CompanyName__c,nm_Designation__c,Industry__c,nm_Department__c,Department__c,Experience_Level__c,Annual_Income__c,nm_Student__c,RecordId__c,Name FROM Work_Experience__r)
                                    FROM Account WHERE id=:objectId AND nm_Centers__c != null];
            
            // List<Account> lstAccount = [SELECT id, Name,Batch__c,nm_Tagged_Pricebook__c,nm_DefencePersonnel__c,nm_StudentImageUrl__c, FirstName, lastname, nm_StudentNo__c, nm_DateOfBirth__c, nm_Centers__c, nm_Gender__c, Phone,nm_Centers__r.Name,nm_Centers__r.nm_CenterGroup__c,
            //                         PersonMobilePhone, PersonEmail,nm_PostalCode__c,nm_StudentImage__c,Shipping_Street__c ,SLF__c,IsPersonAccount,nm_Centers__r.nm_LearningCenter__r.Contact_No_1__c,nm_Centers__r.Contact_No_1__c,nm_Drive_Name__c,
            //                         House_No_Name_Shipping_Account__c, Locality_Name_Shipping__c,Street_Shipping_Account__c,City_Shipping_Account__c,State_Province_Shipping__c,Country_Shipping__c,Zip_Postal_Code_Shipping__c,Program_Type__c,BatchStartD__c,
            //                         nm_Centers__r.Owner.Email,nm_Centers__r.nm_CenterCode__c,nm_Centers__r.nm_LearningCenter__r.Name,nm_Centers__r.Nm_Active__c,Shipping_Address_Choice__c,nm_ChooseaProgram__c,Percentage_Bachlor__c,nm_BachelorsDegreeName__c,nm_Specialization__c,
            //                         nm_NameOfCollege__c,nm_NameofUniversity__c,Other_University_Name__c,University_Type__c,nm_GraduationDegreeMode__c,nm_YearofCollegeCompletion__c,nm_WorkExperience__c,nm_IPForLead__c,nm_EligiblityCriteria__c,nm_StudentStatus__c,
            //                         Extend_Validity_Upto_Year__c,Validity_Year__c,Extend_Validity_upto_Month__c,Validity_Month__c,
            //                         (
            //                             SELECT id, nm_CurrentSession__c,nm_Program__r.nmIsActive__c, nm_FeesPaidofSemester__c, nm_IsClosed__c, nm_Program__c, nm_Program__r.nm_TotalSemesters__c,nm_Student__c,
            //                             nm_program__r.name, nm_program__r.nm_Type__c, nm_PreviousProgram__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.id , nm_Program__r.ReRegonly__c, nm_Program__r.prgst__c,
            //                             nm_program__r.Specialisation__c
            //                             FROM Student_Program__r LIMIT 1
            //                         ),(SELECT Id,nm_StartDate__c,nm_EndDate__c,Currently_Working_Here__c,nm_CompanyName__c,nm_Designation__c,Industry__c,nm_Department__c,Department__c,Experience_Level__c,Annual_Income__c,nm_Student__c,RecordId__c,Name FROM Work_Experience__r)
            //                         FROM Account WHERE id='001Ik000005k8d9' AND nm_Centers__c != null];

        if(lstAccount != null && lstAccount.size() > 0) {
            objAccount = lstAccount[0].clone();
            //objAccountClone = objAccount.clone();
            System.debug('objStudentProgram--->' + JSON.serialize(objAccount.Student_Program__r[0].clone(true)));
            System.debug('objAccount--->' + objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c +' '+ objAccount.Id);
            strAccID = lstAccount[0].Id;
            // get Pending Additional Payment In order to handle old cases
            list<nm_Payment__c> lstPendingAdditionalCharge=[select id,nm_Amount__c,nm_Merchant_Track_Id__c ,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__r.Accountid=:strAccID and nm_PaymentType__c ='Additional Charge' and nm_PaymentStatus__c ='Pending Extra Fees'];
            if(lstPendingAdditionalCharge.size()>0)
            {
                objAdditionalChargerPayment = lstPendingAdditionalCharge[0];
            }else
            {
                objAdditionalChargerPayment = null;
            }
           
            //get Account Related Opportunity
            // List<Opportunity> lstOpportunity = [select id,Is_Re_Registration_Payment__c,Program_Name__c,AccountId,
            //                                         EMI_Processing_Fee_Capital_Float__c,Capital_Float_Processing_Fee__c,
            //                                         nm_Semester__c,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c,
            //                                         ActualPendingAmount__c, nm_Session__c, nm_Year__c,StageName,nm_Fee_Type__c,nm_Program__r.nmIsActive__c
            //                                         ,Loan_Amount__c from Opportunity where AccountId =:objAccount.id  and Is_Re_Registration_Payment__c =false ];
            // if(lstOpportunity.size()>0)
            // {
            //     objOpportunity = lstOpportunity[0];
            // }
        }
    }

    public void queryBlock() {
        if(objAccount != null) {
            //objAccount = lstAccount[0].clone();
            objAccountClone = objAccount.clone();
            lcContactNumber = objAccount.nm_Centers__r.nm_LearningCenter__r.Contact_No_1__c;
            centerLocationName = objAccount.nm_Centers__r.nm_LearningCenter__r.Name;
            programSpecialization  = objAccount.Program_Type__c;
            if(objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0) {
                objStudentProgram = objAccount.Student_Program__r[0].clone(true); 
            }
            System.debug('objStudentProgram--->' + JSON.serialize(objStudentProgram));
            System.debug('objAccount--->' + objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c);

            if(objAccount.Work_Experience__r!=null && objAccount.Work_Experience__r.size() > 0) {
                List<nm_WorkExperience__c> lstWorkExperienceRecord = objAccount.Work_Experience__r;
                for (nm_WorkExperience__c objWp : lstWorkExperienceRecord) {
                    nm_WorkExperience__c objWpClone = objWp;
                    objWpClone.id = null;
                    lstWorkExperience.add(objWpClone);
                    mapOfNameVsId.put(objWp.Name,objWp.RecordId__c);
                    System.debug('mapOfNameVsId==>');
                    System.debug(mapOfNameVsId);
                }
            }
            lstICChange = queryProgramChangeRequest();
            String programChangeOppId = '';
            if(lstICChange.size() > 0) {
                programChangeOppId = lstICChange[0].Opportunity__c;
            }

            // query to get PriceBookEntry        
            lstPriceBookEntry = [SELECT id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c
                                FROM PriceBookEntry WHERE Pricebook2.IsStandard = false AND ((product2.isActive = true
                                AND product2.nm_Program__c =:objStudentProgram.nm_Program__c) OR product2.Name = 'IC Change Fee'
                                OR product2.Name = 'Program Change Fee') AND Pricebook2.id =: objAccount.nm_Tagged_Pricebook__c];   

                                // query to get PriceBookEntry        
            lstPriceBookEntry = [SELECT id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c
                                FROM PriceBookEntry WHERE Pricebook2.IsStandard = false AND ((product2.isActive = true
                                AND product2.nm_Program__c =:objStudentProgram.nm_Program__c) OR product2.Name = 'IC Change Fee'
                                OR product2.Name = 'Program Change Fee') AND Pricebook2.id =: objAccount.nm_Tagged_Pricebook__c];                                         
                
            // query to Check Existing Pending Opportunity or If he had paid all four sem Fee     
            String futureSem = getFutureSem(calendarSession, Integer.valueOf(calendarSessionYear) , objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c, objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c, objStudentProgram.nm_FeesPaidofSemester__c);
            semFuture = futureSem;
            strRegFor = String.isNotBlank(futureSem) ? Integer.valueOf(futureSem) : null;
            lstOpportunity = [SELECT id,Elective_Subject_Name__c,ActualPendingAmount__c, Program_Name__c,nm_Program__r.nm_ProgramName__c,nm_Program__r.Specialisation__c,Term_Cleared__c,Amount, Tuition_Fees__c,Dispatch_Order_For_Student__c,Account.nm_DefencePersonnel__c,nm_StudentProgram__c, nm_PendingAmount__c, PendingAmmount__c, nm_PaymentDone__c, nm_Semester__c,ConsumerType__c,ReRegCompleted__c,
                                Accountid,nm_StudentProgram__r.nm_Program__c,nm_Session__c,nm_year__c,nm_SelfLearningMaterial__c,nm_program__r.name, nm_Fee_Type__c,StageName ,Program_Structure__c,Career_Service__c,CareerServiceProgram__c,Name,Form_Submission_History__c,LiveLecturesType__c,Sem__c,Account.nm_Tagged_Pricebook__c, Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c, Dispatch_Order_Number_For_Student__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c
                                FROM Opportunity
                                WHERE nm_Semester__c =:futureSem
                                AND nm_Session__c =:calendarSession 
                                AND nm_year__c=:calendarSessionYear
                                AND AccountId=:strAccID
                                AND ( ((StageName = 'Pending Payment' OR StageName ='Re-Registration Pending') AND nm_Fee_Type__c NOT IN :lstConsideredFeeTypes) 
                                OR ( StageName = 'Closed Won - Re-registration Pending' AND nm_Fee_Type__c IN :lstConsideredFeeTypes) 
                                OR ((StageName='Pending Payment' OR StageName='Closed') AND nm_Fee_Type__c IN :lstConsideredFeeTypes AND (ActualPendingAmount__c>0 OR id=:programChangeOppId))
                                OR (StageName='Closed' AND nm_Fee_Type__c NOT IN :lstConsideredFeeTypes AND (ActualPendingAmount__c>0 OR id=:programChangeOppId)))
                                AND nm_StudentProgram__c=:objStudentProgram.id];

            if (lstOpportunity.size() == 0 && oppPcId != null) {
                lstOpportunity = [SELECT id,Elective_Subject_Name__c,ActualPendingAmount__c, Program_Name__c,nm_Program__r.nm_ProgramName__c,nm_Program__r.Specialisation__c,Term_Cleared__c,Amount, Tuition_Fees__c,Dispatch_Order_For_Student__c,Account.nm_DefencePersonnel__c,nm_StudentProgram__c, nm_PendingAmount__c, PendingAmmount__c, nm_PaymentDone__c, nm_Semester__c,ConsumerType__c,ReRegCompleted__c,
                                Accountid,nm_StudentProgram__r.nm_Program__c,nm_Session__c,nm_year__c,nm_SelfLearningMaterial__c,nm_program__r.name, nm_Fee_Type__c,StageName ,Program_Structure__c,Career_Service__c,CareerServiceProgram__c,Name,Form_Submission_History__c,LiveLecturesType__c,Sem__c,Account.nm_Tagged_Pricebook__c, Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c, Dispatch_Order_Number_For_Student__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c
                                FROM Opportunity
                                WHERE nm_Semester__c =:futureSem
                                AND nm_Session__c =:calendarSession 
                                AND nm_year__c=:calendarSessionYear
                                AND AccountId=:strAccID
                                AND Id = :oppPcId
                                AND nm_StudentProgram__c=:objStudentProgram.id];
            }

             //Get Closed Won Opportunity if calender is active for program change and Payment
            if (lstOpportunity.size() == 0) {
                String studentProgramId = objStudentProgram.Id;
                Decimal currentSem = objStudentProgram.nm_FeesPaidofSemester__c > 0 ? objStudentProgram.nm_FeesPaidofSemester__c - 1 : objStudentProgram.nm_FeesPaidofSemester__c;
                String sem = getFutureSem(calendarSession, Integer.valueOf(calendarSessionYear) , objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c, objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c, currentSem);
                
                // lstOpportunity = [SELECT id,Elective_Subject_Name__c,ActualPendingAmount__c, Program_Name__c,nm_Program__r.nm_ProgramName__c,nm_Program__r.Specialisation__c,Term_Cleared__c,Amount, Tuition_Fees__c,Dispatch_Order_For_Student__c,Account.nm_DefencePersonnel__c,nm_StudentProgram__c, nm_PendingAmount__c, PendingAmmount__c, nm_PaymentDone__c, nm_Semester__c,ConsumerType__c,ClosedWonDateTime__c,
                //                 Accountid,nm_StudentProgram__r.nm_Program__c,nm_Session__c,nm_year__c,nm_SelfLearningMaterial__c,nm_program__r.name, nm_Fee_Type__c,StageName ,Program_Structure__c,Career_Service__c,CareerServiceProgram__c,Name,Form_Submission_History__c,LiveLecturesType__c,Sem__c,Account.nm_Tagged_Pricebook__c, Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c, Dispatch_Order_Number_For_Student__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c
                //                 FROM Opportunity
                //                 WHERE nm_Semester__c =:sem
                //                 AND nm_Session__c =:calendarSession 
                //                 AND nm_year__c=:calendarSessionYear
                //                 AND AccountId=:strAccID
                //                 AND Id = :oppPcId
                //                 AND nm_StudentProgram__c=:objStudentProgram.id];
                String query = 'SELECT id, Elective_Subject_Name__c, ActualPendingAmount__c, Program_Name__c, ' +
                'nm_Program__r.nm_ProgramName__c, nm_Program__r.Specialisation__c, Term_Cleared__c, Amount, ' +
                'Tuition_Fees__c, Dispatch_Order_For_Student__c, Account.nm_DefencePersonnel__c, ' +
                'nm_StudentProgram__c, nm_PendingAmount__c, PendingAmmount__c, nm_PaymentDone__c, ' +
                'nm_Semester__c, ConsumerType__c, ClosedWonDateTime__c, Accountid, ' +
                'nm_StudentProgram__r.nm_Program__c, nm_Session__c, nm_year__c, nm_SelfLearningMaterial__c, ' +
                'nm_program__r.name, nm_Fee_Type__c, StageName, Program_Structure__c, Career_Service__c, ' +
                'CareerServiceProgram__c, Name, Form_Submission_History__c, LiveLecturesType__c, Sem__c, ' +
                'Account.nm_Tagged_Pricebook__c, Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c, ' +
                'Dispatch_Order_Number_For_Student__c, Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c, ' +
                'Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c,ReRegCompleted__c ' +
                'FROM Opportunity WHERE nm_Semester__c = :sem ' +
                'AND nm_Session__c = :calendarSession ' +
                'AND nm_year__c = :calendarSessionYear ' +
                'AND AccountId = :strAccID ' +
                'AND nm_StudentProgram__c = :studentProgramId';


                if (oppPcId != null && !String.isBlank(oppPcId)) {
                    query += ' AND Id = :oppPcId';
                }

                lstOpportunity = Database.query(query);

                if (lstOpportunity.size() > 0 && lstOpportunity[0].ClosedWonDateTime__c != null) {
                    semFuture = sem;
                    strRegFor = String.isNotBlank(sem) ? Integer.valueOf(sem) : null;
                }
                else {
                    lstOpportunity = new List<Opportunity>();
                }
            }
  
            if(lstOpportunity.size() > 0) {
                programStructure = lstOpportunity[0].Program_Structure__c;
                if(lstOpportunity[0].Career_Service__c!=null && lstOpportunity[0].Career_Service__c!='') {
                    csProgram.id = lstOpportunity[0].CareerServiceProgram__c;
                    csProgram.name = lstOpportunity[0].Career_Service__c;
                }
            }
            System.debug('sem value---->' + strRegFor +' ' + semFuture);

            // to check if the Center is active
            checkIfStudentBelongsToInactiveCenter();

            invalidPrograms = checkReregEligibility(objStudentProgram);

            // to get the List of Program options.
            if(getProgramDetailsAndProductPricing(programStructure, objStudentProgram, invalidPrograms, null)){
                productPricing(objStudentProgram);
            }

            // to get the previously opted Program change Request.
            setParameterForSecToShow();

            // to check if student is eligible for choose program change.
            checkProgramEligible();

            // to check if student is eligble for Coursera.
            checkCourseraEligible();

            checkForElectiveProgram();

            // to check for validity of the student.
            Boolean isValidityExprired = checkForValdiity();

            List<String> batchNotAllowed = Label.ReReg_Batch_Not_Allowed.split(';');
            if (batchNotAllowed.contains(objAccount.Batch__c)) {
                system.debug('<--Error Block For ReReg Not allowed for -> ' + objAccount.Batch__c);
                ErrorMessage('Hello! Re-Registration window is not yet opened.','PopUpErrorForTerm');
                showReregButton = false;
            }

            // if (objAccount.Provisional_With_Hold__c) {
            //     system.debug('<--Error Block For ReReg Not allowed for provisional -> ' + objAccount.Provisional_With_Hold__c);
            //     ErrorMessage('Hello! Your re-registration has been put on hold. To reactivate the same, please complete your document submission process(as per eligibility criteria). You may submit all documents to your AEP. ','PopUpErrorForTerm');
            //     showReregButton = false;
            // }
             
            if(isValidityExprired) {
                System.debug('<--Validity Expired -> ' + isValidityExprired);
                ErrorMessage('Can not Re-Register because your '+ objStudentProgram.nm_Program__r.nm_Type__c +' Validity Expired.','PopUpErrorForTerm');
                showReregButton = false;
            }

            if(strRegFor == null || strRegFor == 0 || String.isBlank(calendarSession) || calendarSessionYear == 0 || calendarSessionYear == null) {
                System.debug('<--Window not open yet -> ');
                ErrorMessage('Re-Registration window is not opened yet.','PopUpErrorForTerm');
                showReregButton = false;
            }

            if(errorMessage.size() > 0){
                ErrorMessage(String.join(errorMessage,'<br/>'),'PopUpError');
                showReregButton = false;
            }
        }
    }

    public void ErrorMessage(String msg,String msgType) {
        message = msg;
        strSecToShow = msgType;
        errorMessage = new List<String>();
    }

    public List<IC_Change_Request__c> queryProgramChangeRequest() {
        List<IC_Change_Request__c> lstProgramChange = new List<IC_Change_Request__c>();
        lstProgramChange = [SELECT Id, New_Information_Center__c, New_Program__c, nm_Reson__c, nm_Reason_for_Change_of_Program__c, nm_TypeofRequest__c,Old_Eligibility_Criteria__c,
        New_Information_Center__r.nm_City__c, New_Information_Center__r.Name, New_Program__r.Name,Status__c,Eligibility_Criteria__c,New_Program__r.nm_Type__c,Opportunity__c,
        Opportunity__r.nm_Semester__c,Email__c,Student__r.PersonEmail FROM IC_Change_Request__c WHERE Student__c =: strAccID AND Status__c='New'];
        return lstProgramChange;
    }

    public String getFutureSem(String calenderSession, integer calenderYear, String programType, String programSpecialization, decimal futureSem) {
        String sem = '';
        String Sem1 = string.valueOf(futureSem);
        String Sem2 = string.valueOf(futureSem +1);
        List<Calender__c> lstCal = new List<Calender__c>();
        if(programSpecialization !=null && programSpecialization !='') {
            lstCal = [SELECT Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c FROM Calender__c
                                    WHERE Category__c='Re-Registration' AND nm_Type__c=:programType 
                                    AND Specialisation__c=:programSpecialization 
                                    AND Session__c = :calenderSession AND Year__c = :calenderYear
                                    AND Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ORDER BY nm_Semester__c ASC ];
    
        }else{
            lstCal = [SELECT Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c FROM Calender__c
                                    WHERE Category__c='Re-Registration' AND Session__c = :calenderSession AND Year__c = :calenderYear AND nm_Type__c=:programType AND Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ORDER BY nm_Semester__c ASC];
    
        }
        //(objCal.nm_Semester__c == Sem1) || 
        for (Calender__c objCal : lstCal) {
            if (objCal.nm_Semester__c == Sem2) {
                return objCal.nm_Semester__c;
            }
        }

        return sem;
    }

    public Boolean checkIfStudentBelongsToInactiveCenter() {
        String centerCode = objAccount.nm_Centers__r.nm_CenterCode__c;
        if(String.isNotBlank(centerCode) && centerCode!='KOL104' && !objAccount.nm_Centers__r.Nm_Active__c) {
            if(centerLocationName != '' && lcContactNumber != ''){
                errorMessage.add('Your AEP is not active, kindly get in touch with your Learning Centre – '+ centerLocationName +', Contact No.'+lcContactNumber);
            }else{
                errorMessage.add(objAccount.nm_Centers__r.Name+' '+'center is now not avaiable for Re-Registration.Kindly change your AEP');
            }
            return true;
        }
        return false;
    }

    public Set<String> checkReregEligibility(nm_StudentProgram__c objStudentProgram) {
        List<nm_InvalidProgram__c> lstofInvalidProgram = new list<nm_InvalidProgram__c>();
        Set<String> invalidProgram = new Set<String>();

        lstofInvalidProgram = [SELECT id,Disable_Is_re_reg__c,DisableLateralAdmission__c,ProgramName__c,Semester__c FROM nm_InvalidProgram__c];
        System.debug('lstofInvalidProgram.size() ==>'+lstofInvalidProgram.size());
        if(lstofInvalidProgram.size() > 0 && objStudentProgram!=null) {
            // String futureSem = String.valueOf((Integer)objStudentProgram.nm_FeesPaidofSemester__c + 1);
            Set<String> setString = new Set<String>();
            list<nm_Program__c> lstProgram = [SELECT Name,nm_ProgramName__c FROM nm_Program__c
                                                WHERE nm_Type__c =: objStudentProgram.nm_program__r.nm_Type__c
                                                AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                                AND (nmIsActive__c=true OR ReRegonly__c=true)];
            System.debug('lstProgram--->'+lstProgram.size());
            for (nm_Program__c objprogram :lstProgram ) {
                setString.add(objprogram.Name); 
                System.debug('setString--->'+setString);
            }
            
            for (nm_InvalidProgram__c objInvalidPrg :lstofInvalidProgram) { 
                String key = objInvalidPrg.ProgramName__c+'_'+objInvalidPrg.Semester__c+'_'+objInvalidPrg.Disable_Is_re_reg__c;
                mapOfInactiveProgramVsProgramName.put(key,objInvalidPrg.ProgramName__c);
                        
                if(objInvalidPrg.Disable_Is_re_reg__c && objInvalidPrg.Semester__c.equalsIgnorecase(semFuture) && setString.contains(objInvalidPrg.ProgramName__c)) {
                    System.debug('objInvalidPrg.ProgramName__c-->'+objInvalidPrg.ProgramName__c);
                    invalidProgram.add(objInvalidPrg.ProgramName__c);
                }                 
            }

            // to check if the student program is eligible for Re-Reg
            checkIfStudentEligibleForReReg(objStudentProgram);

        }
        return invalidProgram;
    }

    public void checkIfStudentEligibleForReReg(nm_StudentProgram__c objStudentProgram) {
        if(!mapOfInactiveProgramVsProgramName.isEmpty()){
            String key = objStudentProgram.nm_program__r.name+'_'+String.valueof(semFuture)+'_true';
            if(mapOfInactiveProgramVsProgramName.containsKey(key)){
                checkIfProgramIsEligible = false;
                System.debug('checkIfProgramIsEligible---> '+checkIfProgramIsEligible);
                Set<String> AllowedToReRegForInActiveProgram = new Set<String>(Label.AllowedToReRegForInActiveProgram.split('\\|'));

                if(!AllowedToReRegForInActiveProgram.contains(objAccount.nm_StudentNo__c)){
                    errorMessage.add(mapOfInactiveProgramVsProgramName.get(key)+' '+'Program are not available for Re-Registration.Kindly change the program');
                }
            }
        }
    }

    public Boolean getProgramDetailsAndProductPricing(String programStructure, nm_StudentProgram__c objStudentProgram, Set<String> invalidProgram, String programType) {
        List<nm_Program__c> lstOfPrograms = new List<nm_Program__c>();
        Boolean ReRegOnlyPrg = false;
        Boolean PrgActive = false;
        if(objStudentProgram!=null) {
            // to get the Program eligiblity.
            ReRegOnlyPrg = objStudentProgram.nm_Program__r.ReRegonly__c;
            PrgActive = objStudentProgram.nm_Program__r.nmIsActive__c;
            if(String.isBlank(programType)) {
                programType = objStudentProgram.nm_program__r.nm_Type__c;
            }
            
            if(String.isBlank(programStructure)) {
                programStructure = objStudentProgram.nm_program__r.prgst__c;
            }

            System.debug('<------objStudentProgram.nm_FeesPaidofSemester__c--------->'+objStudentProgram.nm_FeesPaidofSemester__c+'<-------objStudentProgram.nm_Program__r.nm_TotalSemesters__c---->'+objStudentProgram.nm_Program__r.nm_TotalSemesters__c);
            if(objStudentProgram.nm_Program__r.nm_ProgramName__c != null) {
                strCurrentProgName = objStudentProgram.nm_Program__r.nm_ProgramName__c;
            }   
            
            //Added by Sachin so that Alumin student can take last sem form
            feePaidSem = (Integer)objStudentProgram.nm_FeesPaidofSemester__c;
            Integer lastSem = (Integer)objStudentProgram.nm_Program__r.nm_TotalSemesters__c;
            Integer nextSem = feePaidSem + 1;
            if(feePaidSem == lastSem || nextSem <= lastSem) {
                //setParameterForUrl();
            }
            else {
                errorMessage.add('You are not eligible to Re-Register for programs.');
                return false;
            }
            System.debug('programType--->'+programType);
            System.debug('invalidProgram--->'+invalidProgram);
            lstPrograms = new List<SelectOption>();
            lstPrograms.add(new SelectOption('','Choose a Program'));
            if(PrgActive && !ReRegOnlyPrg) {
                System.debug('Set 1');
                if(programType=='Post Graduate Diploma Programs' ) {
                    System.debug('Set 1--condition 1');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND (NOT Name IN :invalidProgram) 
                                    AND ((prgst__c=:programStructure AND ReRegonly__c = true AND nmIsActive__c = false)
                                    OR nm_ProgramName__c='Post Graduate Diploma in Business Management')];
                                    system.debug('lstOfPrograms--->'+lstOfPrograms);
                } else if(objStudentProgram.nm_program__r.Specialisation__c == 'BBA' || objStudentProgram.nm_program__r.Specialisation__c == 'BA') {
                    System.debug('Set 1--condition 3');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND nm_ProgramName__c != 'Bachelor of Commerce'
                                    AND (NOT Name IN :invalidProgram)                                    
                                    AND nmIsActive__c = true];
                                    system.debug('lstOfPrograms--->'+lstOfPrograms);
                } else if(programType == 'MBA (Online) Programs') {
                    System.debug('Set 1--condition 3');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType AND Specialisation__c = 'MBA'
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND (NOT Name IN :invalidProgram)                                    
                                    AND nmIsActive__c = true];
                                    system.debug('lstOfPrograms--->'+lstOfPrograms);
                }
                else {
                    System.debug('Set 1--condition 3');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c
                                    AND prgst__c=:programStructure
                                    AND (NOT Name IN :invalidProgram)                                    
                                    AND nmIsActive__c = true];
                                    system.debug('lstOfPrograms--->'+lstOfPrograms);
                }
            }
            else if (ReRegOnlyPrg && !PrgActive)  {    
                if(programType == 'MBA (Online) Programs') {
                    System.debug('Set 2--condition 1');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType AND Specialisation__c = 'MBA'
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND (NOT Name IN :invalidProgram)  
                                    AND ((ReRegonly__c = true AND prgst__c=:programStructure))                                  
                                    AND nmIsActive__c = true];
                                    system.debug('lstOfPrograms--->'+lstOfPrograms);
                } else {
                    System.debug('Set 2--condition 2');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c, nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType
                                    AND nm_ProgramName__c != :objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND (NOT Name IN :invalidProgram)
                                    AND ((ReRegonly__c = true AND prgst__c=:programStructure) OR (nm_ProgramName__c='Post Graduate Diploma in Business Management'))];
                }
            }
            else if(PrgActive && ReRegOnlyPrg) {     
                if(programType == 'MBA (Online) Programs') {
                    System.debug('Set 2--condition 1');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                        WHERE nm_Type__c = :programType AND Specialisation__c = 'MBA'
                        AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                        AND (NOT Name IN :invalidProgram)  
                        AND prgst__c=:programStructure AND (nmIsActive__c =:PrgActive OR ReRegonly__c =:ReRegOnlyPrg)];
                        system.debug('lstOfPrograms--->'+lstOfPrograms);
                } else {
                    System.debug('Set 3');
                    lstOfPrograms = [SELECT id,nm_ProgramName__c,nm_Type__c,Name,prgst__c FROM nm_Program__c
                                    WHERE nm_Type__c = :programType
                                    AND nm_ProgramName__c !=: objStudentProgram.nm_program__r.nm_ProgramName__c 
                                    AND (NOT Name IN :invalidProgram) 
                                    AND prgst__c=:programStructure
                                    AND (nmIsActive__c =:PrgActive OR ReRegonly__c =:ReRegOnlyPrg)];

                } 
            }
                                                
            if(lstOfPrograms.size() > 0) {
                lstPrograms = new List<SelectOption>();
                lstPrograms.add(new SelectOption('','Choose a Program'));
                for(nm_Program__c objProgram : lstOfPrograms ) {
                    lstPrograms.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
                }
            }
            return true;   
        }
        return false;
    }

    // public void setParameterForUrl() {
    //     String sem = ApexPages.currentPage().getParameters().get('sem');
    //     if(String.isNotBlank(sem)) {
    //         strRegFor = Integer.valueOf(ApexPages.currentPage().getParameters().get('sem'));
    //         System.debug('Value of strRegFor---->'+strRegFor);
    //     }
    // }

    public void productPricing(nm_StudentProgram__c objStudentProgram) {
        String futureSem = String.valueOf((Integer)objStudentProgram.nm_FeesPaidofSemester__c + 1);
        if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0) {
            for(PriceBookEntry objPBE : lstPriceBookEntry) {

                System.debug('Sumit objPBE.product2.nm_Program__c : '+objPBE.product2.nm_Program__c);
                System.debug('Sumit objStudentProgram.nm_Program__c : '+objStudentProgram.nm_Program__c);
                System.debug('Check Product'+ objPBE.product2.nm_Semester__c == futureSem);

                if(objPBE.product2.nm_Program__c != null && objStudentProgram.nm_Program__c == objPBE.product2.nm_Program__c && objPBE.product2.nm_Semester__c == futureSem) {
                    mapPricebook.put(objStudentProgram.nm_Program__c, objPBE);
                }
                
                if(objPBE.product2.Name == 'Program Change Fee') {
                    mapPricebook.put('Program Change Fee', objPBE);
                    System.debug('checkIfProgramIsEligible value--->'+checkIfProgramIsEligible);
                    if(checkIfProgramIsEligible) {
                        progChangeFee = mapPricebook.get('Program Change Fee').UnitPrice;
                    }
                    programChangeDiscalimer = 'Program Change Fee ' + progChangeFee + ' is applicable to change the Program';
                }      
            } 
        }
    }

    public void setParameterForSecToShow() {
        // call method to get Session and Year for PrintReRegistrationForm as well as for Opportunity  
        getYearAndSession();
        
        if(lstICChange.size() > 0) {
            for(IC_Change_Request__c obj : lstICChange) {
                if(obj.Opportunity__c!=null && obj.nm_TypeofRequest__c == 'IC Change' && strRegFor == Integer.valueof(obj.Opportunity__r.nm_Semester__c))
                {
                    ICChangeRequested = true;
                    strCitySelected = obj.New_Information_Center__r.nm_City__c;
                    strICSelected = obj.New_Information_Center__r.Name;
                    strChangeICReason = obj.nm_Reson__c;
                    ChangeRequestedStatus = obj.Status__c;
                }
                if(obj.Opportunity__c!=null && obj.nm_TypeofRequest__c=='Program Change' && strRegFor == Integer.valueOf(obj.Opportunity__r.nm_Semester__c)){
                    programChangeRequested=true;
                    strProgramSelected = obj.New_Program__r.Name;
                    changeProgram = 'Yes';
                    strSelectedProg = obj.New_Program__c;
                    strProgChangeReason = obj.nm_Reason_for_Change_of_Program__c;
                    strSelectedEligiblity = obj.Eligibility_Criteria__c;
                    chooseProgram = obj.New_Program__r.nm_Type__c;
                    ChangeRequestedStatus = obj.Status__c;
                    getProgramDetails();
                }
            }
        } 
        
        if(objAccount.SLF__c == 'Send to my shipping address') {
            System.debug('addressChoice ==>'+address.addressChoice);
        }
    }

    public void getYearAndSession() {    
        String nextSem = String.valueOf(strRegFor) ;
        Calender__c objCalenders;
        list<Calender__c> lstCal = new List<Calender__c>();
        system.debug('programSpecialization  --->'+programSpecialization  );
        //Fetch Student Program details from Account
        if(objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0) {
            Date today = Date.today();
            String programType = objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c; 
            //Find session and year from Calendar based on today's date for Student's program and sem and use it for Opportunity
            if(programSpecialization !='')
            {
            lstCal = [SELECT Session_End_Date__c, nm_Semester__c, Session_Start_Date__c,Specialisation__c, nm_Type__c ,
                                        Session__c, Year__c FROM Calender__c WHERE Category__c='Re-Registration' 
                                        AND nm_Type__c=: programType AND nm_Semester__c =: nextSem and Specialisation__c=:programSpecialization 
                                        AND Session_Start_Date__c <=:today AND Session_End_Date__c >=:today];
                
            }else{
            lstCal = [SELECT Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,
                                        Session__c, Year__c FROM Calender__c WHERE Category__c='Re-Registration' 
                                        AND nm_Type__c=: programType AND nm_Semester__c =: nextSem 
                                        AND Session_Start_Date__c <=:today AND Session_End_Date__c >=:today];
        
            }
            if(lstCal!= null && lstCal.size() > 0) {
                objCalenders = lstCal[0];
                strSession = objCalenders.Session__c;
                intYear = Integer.valueOf(objCalenders.Year__c);
                if(String.isBlank(calendarSession) || calendarSessionYear == 0) {
                    calendarSession = objCalenders.Session__c;
                    calendarSessionYear = Integer.valueOf(objCalenders.Year__c);
                }
            }
        }
    }

    public void getProgramDetails() {
        // System.assert(false);
        System.debug('method called');
        nm_StudentProgram__c objStudentProgram = objAccount.Student_Program__r[0].clone(true);
        String programStructure = '';
        if(lstOpportunity.size() > 0) {
            programStructure = lstOpportunity[0].Program_Structure__c;
        }
        Boolean checkProgram = getProgramDetailsAndProductPricing(programStructure, objStudentProgram, invalidPrograms, chooseProgram);
        callValidate();
        if(!checkProgram) {
            ErrorMessage('Error Occured','PopUpError');
        }
    }

    public void callValidate() {
        System.debug('Eligibility check');
        enableUpdateQualification = false;
        enableUpdateWRKEXP = false;
        if(mapOfIdVsEligiblity.isEmpty() && String.isNotBlank(strSelectedEligiblity)) {
            getElegibilityCriteriaList();
        }
        //if(String.isNotBlank(strSelectedEligiblity) && mapOfIdVsEligiblity.containsKey(strSelectedEligiblity) && (objAccount.nm_ChooseaProgram__c=='Diploma Programs' || chooseProgram =='Diploma Programs')) {
        if(String.isNotBlank(strSelectedEligiblity) && mapOfIdVsEligiblity.containsKey(strSelectedEligiblity) && objAccount.nm_ChooseaProgram__c=='Diploma Programs') {

            nm_EligiblityCriteria__c objEligibility = mapOfIdVsEligiblity.get(strSelectedEligiblity);
            yearsEligibility = Integer.valueOf(objEligibility.Experience_Required_In_Year__c);

            // to enable the garduation and work expereince section.
            Integer year = 0;
            List<nm_WorkExperience__c> lstWEXP = objAccount.Work_Experience__r;
            if(lstWEXP.size() > 0) {
                Integer monthDiff = 0;
                for(nm_WorkExperience__c objWE : lstWEXP) {
                    if((objWE.nm_StartDate__c != null && objWE.nm_EndDate__c != null) || objWE.Currently_Working_Here__c){

                        Date a = objWE.nm_StartDate__c;
                        Date b = Date.today();
                        if(!objWE.Currently_Working_Here__c) {
                            b = objWE.nm_EndDate__c;
                        }
                        monthDiff += a.monthsBetween(b);
                        if (b.day() > a.day()){
                            monthDiff++;
                        }
                    }
                }

                if(monthDiff > 0) {
                    Integer months = math.MOD(monthDiff, 12);
                    year = monthDiff/12;
                }
            }

            System.debug('objEligibility.Graduation_Required__c ==>'+objEligibility.Graduation_Required__c);
            System.debug('objEligibility.Graduation_Percentage__c ==>'+objEligibility.Graduation_Percentage__c);
            System.debug('objAccount.Percentage_Bachlor__c ==>'+objAccount.Percentage_Bachlor__c);
            // if(objEligibility.Graduation_Required__c && objEligibility.Graduation_Percentage__c > 0 && (objAccount.Percentage_Bachlor__c < objEligibility.Graduation_Percentage__c || objAccount.Percentage_Bachlor__c==null) ) {
            if(objEligibility.Graduation_Required__c && objEligibility.Graduation_Percentage__c > 0) {
                enableUpdateQualification = true;
            } 
            else if(objEligibility.Graduation_Required__c && yearsEligibility > 0) {
                enableUpdateQualification = true;
                enableUpdateWRKEXP = true;
            }
        }else{
            yearsEligibility = 0;
        }

        if(yearsEligibility > 0) {
            ErrorMessage('For this eligibility criteria its mandatory to submit Work experience proof of '+ yearsEligibility + ' years.','PopUpError');
        }else {
            ErrorMessage('','');
        }
    }

    public List<SelectOption> getElegibilityCriteriaList(){
        List<SelectOption> lstECOptions = new List<SelectOption>();
        Map<String,Decimal> mapOfEligibilityVsRequiredAcademicPercentage = new Map<String,Decimal>();
        System.debug('chooseProgram--->'+ chooseProgram);
        lstECOptions.add(new SelectOption('', 'Choose Eligiblity Criteria'));
        String prQuery = ' nm_Program__c=:chooseProgram ';
        // if (chooseProgram == 'MBA (Online) Programs') {
        //     prQuery =  ' nm_Program__c=:chooseProgram AND Program_Type__c = \'MBA\'' ;
        // }
        String queryEligibilityCriteria = getQueryAllFieldSql('nm_EligiblityCriteria__c',prQuery,null);
        List<nm_EligiblityCriteria__c> lstElegibility = DataBase.query(queryEligibilityCriteria);
        if(lstElegibility.size() > 0 ){
            for(nm_EligiblityCriteria__c objEligibility : lstElegibility){
                if( chooseProgram!='Diploma Programs' || (chooseProgram=='Diploma Programs' && objEligibility.Graduation_Required__c)) {
                    lstECOptions.add(new SelectOption(objEligibility.id, objEligibility.nm_EligiblityCriteria__c)); 
                    mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id+'-Graduation',objEligibility.Graduation_Percentage__c);
                    mapOfIdVsEligiblity.put(objEligibility.id, objEligibility);
                }
                
            }
            
            if(!mapOfEligibilityVsRequiredAcademicPercentage.isEmpty()) {
                jsonMapOfEligibilityVsRequiredAcademicPercentage = JSON.serialize(mapOfEligibilityVsRequiredAcademicPercentage);
            }
        }
        return lstECOptions;
    }

    public String getQueryAllFieldSql(String ObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ ObjectAPIName +' where '+conditionString;
        return query;
    }

    public void checkProgramEligible() {
        System.debug('feePaidSem ==>'+feePaidSem);
        List<String> lstProgramType = new List<String>{'Post Graduate Diploma Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
        if(lstProgramType.contains(objAccount.nm_ChooseaProgram__c) && strRegFor <=2) {
            checkProgramSwitch = true;
            showAvailableProgramToSwitch(objAccount.nm_ChooseaProgram__c,objAccount.BatchStartD__c, objAccount.Program_Type__c);
        }
    }

    public void showAvailableProgramToSwitch(String programCategory,Date batchStartDate, String programSpecalisation){
        Date checkDate = Date.parse(System.Label.LiveLectureAllowForReRegDate);
        if(programCategory == 'Diploma Programs' && batchStartDate >= checkDate){
            //Date july2024 = Date.parse('2024-7-1');
            Date july2024 = Date.newInstance(2024, 7, 1);
            objAvialableProgram.diploma = true;
            objAvialableProgram.postGraduate = false;
            objAvialableProgram.mbaOnline = false;
            objAvialableProgram.mbaDistance = false;
            if(batchStartDate >= july2024) {
                objAvialableProgram.mbaOnline = true;
            } else {
                objAvialableProgram.mbaDistance = true;
            }
        } else if(programCategory == 'Diploma Programs' && batchStartDate < checkDate){
            objAvialableProgram.diploma = true;
            objAvialableProgram.mbaDistance = false;
            objAvialableProgram.postGraduate = true;
            objAvialableProgram.mbaOnline = false;
        } else if(programCategory == 'Post Graduate Diploma Programs'){
            objAvialableProgram.diploma = true;
            objAvialableProgram.mbaDistance = false;
            objAvialableProgram.postGraduate = true;
            objAvialableProgram.mbaOnline = false;
        } else if(programCategory == 'MBA (Distance) Programs'){
            objAvialableProgram.diploma = true;
            objAvialableProgram.mbaDistance = true;
            objAvialableProgram.postGraduate = false;
            objAvialableProgram.mbaOnline = false;
        } else if(programCategory == 'MBA (Online) Programs' && programSpecalisation == 'MBA'){
            objAvialableProgram.diploma = true;
            objAvialableProgram.mbaDistance = false;
            objAvialableProgram.postGraduate = false;
            objAvialableProgram.mbaOnline = true;
        } else {
            objAvialableProgram.diploma = false;
            objAvialableProgram.mbaDistance = false;
            objAvialableProgram.postGraduate = false;
            objAvialableProgram.mbaOnline = false;
        }
    }

    public void checkCourseraEligible() {
        System.debug('Entered for Coursera ==>');
        String admissionYear = calendarSessionYear > 0 ? String.valueOf(calendarSessionYear) : '0';
        List<NM_Payment_Form_Configuration__c> lstOfConfig = [SELECT id,Show_Coursera__c FROM NM_Payment_Form_Configuration__c WHERE Session__c=:calendarSession AND Current_Admission_Year__c=:admissionYear AND Program_Category__c=:objAccount.nm_ChooseaProgram__c AND Payment_Type__c='Re-Registration' AND Program_Type__c=:programSpecialization LIMIT 1];
        if(lstOfConfig.size() > 0 && lstOfConfig[0].Show_Coursera__c) {
            objCoursera.showCoursera = true;
            System.debug('strAccID ==>'+strAccID);
            List<Opportunity> lstOpps = [SELECT id,Coursera__c,Account.nm_Tagged_Pricebook__c FROM Opportunity WHERE AccountId=:strAccID];
            for (Opportunity objOpps: lstOpps) {
                if(objOpps.Coursera__c) {
                    objCoursera.isCourseraAlreadyOpted = true;
                }
            }
            if(!objCoursera.isCourseraAlreadyOpted) {
                ProductHelper helper = new ProductHelper();
                objCoursera.applicableCourseraFee = helper.CourseraProduct(null, lstOpps[0], true);
                objCoursera.disclaimer = 'Coursera Fee Rs.' + objCoursera.applicableCourseraFee + '/- is applicable.<br/><br/>Note: You have opted for the Annual Coursera subscription. Kindly note, cancellation from Coursera can be opted within 7 days only.';
            }
        }
    }

    public void checkForElectiveProgram() {
        System.debug('checkForElectiveProgram---->' + lstOpportunity.size());
        if(!lstOpportunity.isEmpty()) {
            // isElectiveNeeded = true;
            Opportunity objOpp = lstOpportunity[0];
            // objCampaignCall = [SELECT Id,Marketing_Disclaimer__c,Finance_Disclaimer__c FROM Campaign_Call__c WHERE Type_Of_Object__c = 'Elective' LIMIT 1];
            if((objOpp.nm_Semester__c == '5') && objOpp.nm_Program__r.Specialisation__c == 'BBA' ) {
                isElectiveNeeded = true;
                if(String.isNotBlank(objOpp.Elective_Subject_Name__c)) {
                    String ElectiveSubject =  objOpp.Elective_Subject_Name__c.split(';')[0];
                    nm_Courses__c objCourse = [SELECT Id, Elective__c, Name FROM nm_Courses__c WHERE Program__r.Specialisation__c = :objOpp.nm_Program__r.Specialisation__c AND Name = :ElectiveSubject AND Sem__c = :objOpp.nm_Semester__c ];
                    electiveSelected = objCourse.Elective__c;
                }
                objCampaignCall = [SELECT Id,Marketing_Disclaimer__c,Finance_Disclaimer__c FROM Campaign_Call__c WHERE Type_Of_Object__c = 'Elective' LIMIT 1];
                // objCampaignCall = [SELECT Id, Disclaimer__c FROM Campaign_Call__c WHERE Type_Of_Object__c = 'Elective' LIMIT 1];
                system.debug('objCampaignCall ==> ' + objCampaignCall);
            }
        }
    }

    public Boolean checkForValdiity() {
        String validitymon = (objAccount.Extend_Validity_upto_Month__c!='' && objAccount.Extend_Validity_upto_Month__c!=null) ? objAccount.Extend_Validity_upto_Month__c.left(3) : objAccount.Validity_Month__c.left(3);
        Integer validyear = objAccount.Extend_Validity_Upto_Year__c!=null ? Integer.valueof(objAccount.Extend_Validity_Upto_Year__c) : Integer.valueof(objAccount.Validity_Year__c);
        ValidityForStudentLogin checkStudent = new ValidityForStudentLogin();
        String validityStatus = checkStudent.checkValidityForPGforLogin(calendarSession,calendarSessionYear,validyear,validitymon,String.valueOf(strRegFor));
        if(validityStatus == 'RedirectPG') {
            return false;
        }
        return true;
    }

    public List<SelectOption> getSelfLearningMaterial() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Self Learning Material'));
        options.add(new SelectOption('Send to my shipping address','Send to my shipping address'));
        options.add(new SelectOption('Send to my Information Centre. I will pick up.','Send to my Information Centre. I will pick up.'));
        return options;
    }

    public List<SelectOption> getShippingOption() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Choose here'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    **/
    public void updateAddressDetails() {
        System.debug('updateAddressDetails--->');
        if(String.isNotBlank(address.postalcode)) {
            // Create an instance of GeocodeController
            GeocodeController geocodeController = new GeocodeController();
                    
            // Call the processGeocode method
            GeocodeResult result = geocodeController.processGeocode(address.postalcode, System.Label.GeoCodeServiceType);

            // Handle the result
            handleGeocodeResult(result);
        }
    }

    // Method to process the result
    private void handleGeocodeResult(GeocodeResult result) {
        // Example of processing the result
        System.debug('City: ' + result.city);
        System.debug('State: ' + result.state);
        System.debug('Country: ' + result.country);
        System.debug('Message: ' + result.postalCodeMessage);

        address.country = result.country;
        address.state = result.state;
        address.city = result.city;
        address.postalCodeMessage = result.postalCodeMessage;
    }

    public list<SelectOption> getGraduationDegreeMode(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('','Graduation Degree Mode'));
        options.add(new SelectOption('Full Time','Full Time'));
        options.add(new SelectOption('Part Time','Part Time'));
        options.add(new SelectOption('Distance Learning','Distance Learning'));
        options.add(new SelectOption('Correspondence','Correspondence'));
        return options;
    }

    public List<SelectOption> getBachelorsDegreeName(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Lead.nm_BachelorsDegreeName__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','Bachelor Degree Name'));
        for(Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return options;
    }

    public void AddExperience() {
        nm_WorkExperience__c objWE = new nm_WorkExperience__c();
        objWE.id = null;
        lstWorkExperience.add(objWE);
    }

    public void RemoveExperience() {
        Integer strRowNo = lstWorkExperience.size();
        if(strRowNo != null && strRowNo > 1){
            Integer IndexVal = integer.valueOf(strRowNo) - 1;
            String WEXPName = lstWorkExperience[IndexVal].Name;
            System.debug('WEXPName ==>'+WEXPName);
            String RemoveExperienceId = String.isNotBlank(WEXPName) && mapOfNameVsId.containsKey(WEXPName) ? mapOfNameVsId.get(WEXPName) : null;
            if(RemoveExperienceId != '' && RemoveExperienceId != null){
                RemovedWorkExperience.add(RemoveExperienceId);
            }
            lstWorkExperience.remove(IndexVal);
        }
    }

    public List<SelectOption> getWorkExpTimeList() {
        List<SelectOption> options = new List<SelectOption>();
        if(yearsEligibility == null || yearsEligibility == 0) {
            options.add(new SelectOption('','Total Work Experience'));
            options.add(new SelectOption('0-1 Years','0-1 Years'));
            options.add(new SelectOption('1-3 Years','1-3 Years'));
            options.add(new SelectOption('3-5 Years','3-5 Years'));
            options.add(new SelectOption('5-10 Years','5-10 Years'));
            options.add(new SelectOption('10+ Years','10+ Years'));
        }else if(yearsEligibility > 0) {
            options.add(new SelectOption('','Total Work Experience'));
            options.add(new SelectOption('1-3 Years','1-3 Years'));
            options.add(new SelectOption('3-5 Years','3-5 Years'));
            options.add(new SelectOption('5-10 Years','5-10 Years'));
            options.add(new SelectOption('10+ Years','10+ Years'));
        }
        return options;
    }

    public PageReference save() {
        // System.assert(false);
        Savepoint spRB = Database.setSavepoint();
        try {
            System.debug('Called save method');
            if(validateRequest()) {
                System.debug('request validated');
                if(lstOpportunity.isEmpty()) {
                    if(createNewOpportunity()) {  
                        System.debug('Create new opportunity loop');
                        insert lstOpportunity;
                        // call method to calculateTotalPay
                        totalPayFee = calculateTotalPay();
                    } 
                    else {
                        if(errorMessage.size() > 0){
                            ErrorMessage(String.join(errorMessage,'<br/>'),'PopUpError');
                        }
                        return null;
                    }
                }

                if(!lstOpportunity.isEmpty()) {
                    System.debug('Opportunity exists');
                    // call method to calculateTotalPay
                    totalPayFee = calculateTotalPay();
                    if(lstOpportunity[0].Amount == null) {
                        lstOpportunity[0].Amount = 0;
                    }       
                    String electiveCourse = getValueForElectiveSubject(electiveSelected, semFuture);
                    if(String.isNotBlank(electiveCourse)) {
                        lstOpportunity[0].Elective_Subject_Name__c = electiveCourse;
                    } 
                    
                    // call method to update account for selflearning material
                    updateAccountForSelfLearningMaterial();
                    
                    //call method to Insert Product 
                    insertProduct();

                    // call method to calculateTotalPay
                    totalPayFee = calculateTotalPay();

                    System.debug('lstOpportunity[0].ActualPendingAmount__c ==>'+lstOpportunity[0].ActualPendingAmount__c);
                    if(errorMessage.size() <= 0) {
                        if((lstOpportunity[0].StageName != 'Pending Payment' && changeProgram=='Yes') || lstOpportunity[0].StageName =='Re-Registration Pending' || lstOpportunity[0].ActualPendingAmount__c > 0) {
                            lstOpportunity[0].StageName = 'Pending Payment';
                            lstOpportunity[0].nm_SelfLearningMaterial__c = objaccount.SLF__c;
                            System.debug('Pending Payment stage update loop');
                        }

                        // to check if Career Service Package is opted.
                        System.debug('csName ===>'+csProgram.name+' csId===>'+csProgram.id);
                        if(String.isNotBlank(csProgram.name)) {
                            lstOpportunity[0].Career_Service__c = csProgram.name;
                            lstOpportunity[0].CareerServiceProgram__c = csProgram.id;
                        } else {
                            lstOpportunity[0].Career_Service__c = '';
                            lstOpportunity[0].CareerServiceProgram__c = null;
                        }

                        if (!lstOpportunity[0].ReRegCompleted__c) {
                            lstOpportunity[0].ReRegCompleted__c = true;
                        }

                        // Track Form Submission History
                        Boolean isICActive = String.isBlank(IC) ? false : true;
                        String history = 'IP Address : ' + ipAddress +'\n';
                        history += 'IsAdmin : ' + isICActive +'\n';
                        lstOpportunity[0].Form_Submission_History__c = lstOpportunity[0].Form_Submission_History__c + history;

                        update lstOpportunity;

                        String recordId = lstOpportunity[0].id;
                        System.debug('recordId ==>'+recordId);
                        if((lstOpportunity[0].StageName == 'Pending Payment' && totalPayFee == 0) || String.isNotBlank(csProgram.isEligible)) {
                            lstOpportunity = [SELECT id,ActualPendingAmount__c, Program_Name__c,nm_Program__r.nm_ProgramName__c,Amount, Tuition_Fees__c,Dispatch_Order_For_Student__c,Account.nm_DefencePersonnel__c,nm_StudentProgram__c,nm_PendingAmount__c,PendingAmmount__c,nm_PaymentDone__c,nm_Semester__c,ConsumerType__c,ReRegCompleted__c,
                                Accountid,nm_StudentProgram__r.nm_Program__c,nm_Session__c,nm_year__c,nm_SelfLearningMaterial__c,nm_program__r.name,nm_Fee_Type__c,StageName,Program_Structure__c,Career_Service__c,CareerServiceProgram__c,Name,Form_Submission_History__c,LiveLecturesType__c,Sem__c
                                FROM Opportunity WHERE id=:recordId];
                                System.debug('lstOpportunity[0].ActualPendingAmount__c 2 ==>'+lstOpportunity[0].ActualPendingAmount__c);
                        }

                        // call method to calculateTotalPay
                        totalPayFee = calculateTotalPay();

                        if(!requireDocumentUpload) {
                            // strSecToShow = 'Popuppayment';
                            if(objAccount.SLF__c == 'Send to my shipping address') {
                                // errorMessage.add('Your Study Material will be delivered to your shipping address, Are you sure you want to Submit your Detail and proceed futher for payment?');
                                errorMessage.add('Your Study Material will be delivered to your shipping address');
                            } else {
                                errorMessage.add('Your Study Material will be delivered to your information center');
                                // errorMessage.add('Your Study Material will be delivered to your information center,Are you sure you want to Submit your Detail and proceed futher for payment?');
                            }
                        }
                        if(objCoursera.checkCourseraOpted) {
                            totalPayFee += objCoursera.applicableCourseraFee;
                        }

                        if(totalPayFee > 0 && !requireDocumentUpload) {
                            errorMessage.add('Your total amount for payment is : '+ totalPayFee +'. Are you sure you want to Proceed to Payment?');
                        } else if(!requireDocumentUpload &&  objAccount.nm_StudentStatus__c == 'Confirmed') {
                            errorMessage.add('There is no fees Pending. Are you sure you want to confirm your re-registration for next Semester? Please note you will not be able to undo this step.');
                        } else {
                            errorMessage.add('Kindly submit Eligibility documents to AEP to further process your program change request.');
                        }

                        // to validate on Closed Won - Re-registration Pending to check if any pending amount on Admission Record
                        if(partPaymentValidation(lstOpportunity[0])) {
                            errorMessage = new List<String>();
                            errorMessage.add('Your Part Payment is pending to reregister');
                        }

                        if(errorMessage.size() > 0){
                            ErrorMessage(String.join(errorMessage,'<br/><br/>'),'PopUpPayment');
                        }

                        return null;
                    }
                }
            }

            System.debug('request invalidate 1');

            if(errorMessage.size() > 0){
                System.debug('request invalidate 2');
                ErrorMessage(String.join(errorMessage,'<br/><br/>'),'PopUpError');
                Database.rollback(spRB);
            }
            return null;
        } catch (Exception e) {
            System.debug('check error line');
            Database.rollback(spRB);
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            ErrorMessage('Internal error occured. Please try again later','PopUpError');
            return null;
        }
    }

    public PageReference goPayment() {
        String url = '';
        if(totalPayFee > 0) {
            // String IC = ApexPages.currentPage().getParameters().get('IC');
            // String HO = ApexPages.currentPage().getParameters().get('HO');
            // String urlGenerate = '';
            // if(String.isNotBlank(HO)) {
            //     urlGenerate = '&HO=' + HO + '&IC=' + IC;
            // } else if (String.isNotBlank(IC)) {
            //     urlGenerate = '&IC=' + IC;
            // }
            url = '/EnrollmentForm?nav=payment';
            if(isAdmissionFeePaid() && totalPayFee != objCoursera.applicableCourseraFee){
                url = '/apex/nmAdditonalCharge?id='+lstOpportunity[0].id+'&amount='+totalPayFee;
            } else if(objCoursera.checkCourseraOpted && totalPayFee == objCoursera.applicableCourseraFee) {
                url = '/apex/nmAdditonalCharge?id='+lstOpportunity[0].id+'&amount='+totalPayFee+'&pyt=coursera';
            }
        } else if(lstConsideredFeeTypes.contains(lstOpportunity[0].nm_Fee_Type__c)) {
            if (!requireDocumentUpload) {
                markCloseWon();
            }
            url ='/apex/PrintReRegistrationForm?target=pdf&id='+strAccID+'&sem='+strRegFor;
        }
        if (String.isBlank(url)) {
            if (checkisOppClosedWon()) {
                url ='/apex/PrintReRegistrationForm?target=pdf&id='+strAccID+'&sem='+strRegFor;
            }
        }
        pageReference pg = new pageReference(url);
        pg.setRedirect(true);
        return pg;
    }

    public boolean isAdmissionFeePaid(){
        List<nm_Payment__c> lstPayment= [SELECT id FROM nm_Payment__c WHERE nm_PaymentType__c ='Admission' AND (nm_PaymentStatus__c ='Payment Made' OR nm_PaymentStatus__c = 'Payment Approved') AND nm_OpportunityNew__c=:lstOpportunity[0].id];
        if(lstPayment.size() > 0){
            return true;
        }
        return false;
    }

    public Boolean checkisOppClosedWon() {
        if (lstOpportunity.size() > 0) {
            List<Opportunity> lstOpp = [SELECT Id, StageName FROM Opportunity WHERE Id =:lstOpportunity[0].Id LIMIT 1];
            if (lstOpp.size() > 0) {
                return lstOpp[0].StageName == 'Closed Won' ? true : false;
            }
        }
        return false;
    }

    public void markCloseWon() {
        System.debug('Marking Opportunity Closed Won');
        ProductHelper helper = new ProductHelper();
        // String oppId = lstOpportunity[0].id;
        if(lstOpportunity.size()>0 && lstOpportunity[0].id!=null) {
            lstOpportunity[0].StageName = 'Closed Won';
            lstOpportunity[0].CloseDate = System.Today();
            lstOpportunity[0].nm_Session__c = calendarSession;
            lstOpportunity[0].nm_Year__c = calendarSessionYear;
            lstOpportunity[0].nm_SelfLearningMaterial__c = objaccount.SLF__c;
            lstOpportunity[0].ReRegCompleted__c = true;

            if(lstOpportunity[0].LiveLecturesType__c!='' && lstOpportunity[0].LiveLecturesType__c!=null  && lstOpportunity[0].LiveLecturesType__c!='Custom') {
                lstOpportunity[0] = helper.SetLiveLecturesValue(lstOpportunity[0]);
            }
            update lstOpportunity;
        }
        Boolean studentrequest = helper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(lstOpportunity[0]);
    }

    public Boolean validateRequest() { 
        System.debug('validate Method called');
        errorMessage = new List<String>();
        Account objAcc = new Account(id=strAccID); 
        Set<String> AllowedToReRegForInActiveProgram = new Set<String>(Label.AllowedToReRegForInActiveProgram.split('\\|'));
        System.debug('Selected program--->'+strSelectedProg);
        if(String.isNotBlank(address.postalCode) && address.postalCode.length() != 6) { 
            errorMessage.add('Please enter valid India Pin Code');
            return false;
        }
        else if(checkIfStudentBelongsToInactiveCenter()) {
            return false;
        }
        else if(!checkIfProgramIsEligible && !AllowedToReRegForInActiveProgram.contains(objAccount.nm_StudentNo__c) && String.isBlank(strSelectedProg)) {
            errorMessage.add('Please Change Program before proceeding for Re-Registration');
            return false;
        } else if(String.isNotBlank(strSelectedProg) && lstOpportunity.size() > 0 && chooseProgram == 'Diploma Programs' && 
            (lstOpportunity[0].nm_Fee_Type__c == 'FullFee-Considered' || lstOpportunity[0].nm_Fee_Type__c == 'FullFeeLoan-Considered'  || lstOpportunity[0].nm_Fee_Type__c == 'PGAllSemFee-Considered')) {
            errorMessage.add('You cannot select this Program Category, Kindly contact your Learning Centre – '+ centerLocationName +', Contact No.'+lcContactNumber);
            return false;
        }
        return true;
    }

    public Boolean createNewOpportunity() { 
        nm_StudentProgram__c objStudentProgram;
        Integer lastSem = 0;
        Integer nextSem = 0;
        if(objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0) {
            objStudentProgram = objAccount.Student_Program__r[0].clone(true); 
            lastSem = (Integer)objStudentProgram.nm_Program__r.nm_TotalSemesters__c;
            nextSem = feePaidSem + 1;
            system.debug('objStudentProgram--->'+objStudentProgram);
            system.debug('objStudentProgram.nm_Program__c--->'+objStudentProgram.nm_Program__c);
        }
        if(objStudentProgram!=null && nextSem <= lastSem) {
            System.debug('MapPriceBook Value--->'+mapPricebook+'Value Of MapPriceBook--->'+mapPricebook.get((String)objStudentProgram.nm_Program__c)+'program type-->'+objAccount.nm_ChooseaProgram__c);
            if(!mapPricebook.isEmpty() && mapPricebook.get((String)objStudentProgram.nm_Program__c) != null) {
                System.debug('strSession'+strSession+'intYear'+intYear);
                lstOpportunity = new list<Opportunity>();
                // call method to Insert Opportunity
                insertNewOpportunity(objStudentProgram);
            }
            else {
                errorMessage.add('Unable to precessed for Re-Registration for next semester for this program please contact your current Information Center.');
                return false;
            }
        }
        else {
            errorMessage.add('Fee for total semesters already paid cannot preocess to payment.');
            return false;
        }
        return true;
    }

    public void insertNewOpportunity(nm_StudentProgram__c objStudentProgram) {
        String electiveCourse = getValueForElectiveSubject(electiveSelected, semFuture);
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.nm_SelfLearningMaterial__c =  objAccount.SLF__c;
        objOpportunity.Name = 'a';
        objOpportunity.StageName = 'Pending Payment';
        objOpportunity.Accountid = objStudentProgram.nm_Student__c;
        objOpportunity.nm_StudentProgram__c = objStudentProgram.Id;
        objOpportunity.nm_Semester__c = String.valueOf(feePaidSem + 1);
        objOpportunity.CloseDate = date.today();
        objOpportunity.nm_Program__c = objStudentProgram.nm_Program__c;
        objOpportunity.nm_Session__c = strSession;
        objOpportunity.nm_Year__c = intYear;
        objOpportunity.Is_Re_Registration_Payment__c = true;
        objOpportunity.nm_Fee_Type__c='ReRegistrationPayment';
        if(String.isNotBlank(electiveCourse)) {
            objOpportunity.Elective_Subject_Name__c = electiveCourse;
        }
        System.debug('Pending Payment stage update while insert opportunity');
        if(objAccount.nm_DefencePersonnel__c =='Yes') {
            objOpportunity.Amount = (mapPricebook.get((String)objStudentProgram.nm_Program__c).UnitPrice)*0.8;
        }
        else {
            objOpportunity.Amount = mapPricebook.get((String)objStudentProgram.nm_Program__c).UnitPrice;
        }
        lstOpportunity.add(objOpportunity);
    } 

    public Decimal calculateTotalPay() {
        Decimal totalPayAmount = 0;
        totalPayAmount = lstOpportunity[0].ActualPendingAmount__c != null ? lstOpportunity[0].ActualPendingAmount__c : totalPayAmount;
        System.debug('lstOpportunity[0].ActualPendingAmount__c inside ==>'+lstOpportunity[0].ActualPendingAmount__c);
        System.debug('totalPayAmount ==> '+ totalPayAmount);
        return totalPayAmount;
    }

    public String getValueForElectiveSubject(String electiveSelected, String semester) {
        Set<String> cousreId = new Set<String>();
        if(String.isNotBlank(electiveSelected) &&  String.isNotBlank(semester)) {
            List<nm_Courses__c> lstCourses = [SELECT Id, Student_Zone_Course_Id__c, Name FROM nm_Courses__c WHERE Elective__c = :electiveSelected AND Sem__c=:semester];
            system.debug('lstCourses ===> ' + lstCourses);
            if(lstCourses.size() > 0 ) {
                for(nm_Courses__c objCourse : lstCourses) {
                    cousreId.add(objCourse.Name);
                }
            }
            if(cousreId.size() > 0 ) {
                String electiveList = String.join(new List<String>(cousreId) , ';');
                system.debug('electiveList ==> ' + electiveList);
            return electiveList ;
            }
        }
        return null;
    }

    public void updateAccountForSelfLearningMaterial() {
        Account objAcc = new Account(id=strAccID);
        if(enableUpdateQualification || enableUpdateWRKEXP) {
            objAcc = objAccountClone.clone();
            objAcc.id = strAccID;
        }
        System.debug('lstAccount------>'+objAccountClone +'  strAccID'+strAccID);       
        objAcc.PersonMobilePhone = objAccount.PersonMobilePhone;
        objAcc.PersonEmail = objAccount.PersonEmail;
        objAcc.SLF__c = objAccount.SLF__c;
        objAcc.nm_IPForLead__c = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        objAcc.Shipping_Address_Choice__c='';
        System.debug('strSelectedEligiblity ==>'+strSelectedEligiblity);
        System.debug('objAccount.nm_EligiblityCriteria__c ==>'+objAccount.nm_EligiblityCriteria__c);
        // to update the selected elgiblity and update the Account status to selected elibility inorder to upload the documents and block payment
        if(String.isNotBlank(strSelectedEligiblity) && objAccount.nm_EligiblityCriteria__c!=strSelectedEligiblity 
            && (chooseProgram=='Post Graduate Diploma Programs' || chooseProgram=='MBA (Distance) Programs' || chooseProgram=='MBA (Online) Programs') && chooseProgram!=objAccount.nm_ChooseaProgram__c) {
                objAcc.nm_EligiblityCriteria__c = strSelectedEligiblity;
                objAcc.nm_StudentStatus__c = 'Registered';
                requireDocumentUpload = true;
        } 
        else if(String.isNotBlank(strSelectedEligiblity) && objAccount.nm_EligiblityCriteria__c==strSelectedEligiblity 
            && objAccount.nm_StudentStatus__c!='Confirmed'&& (chooseProgram=='Post Graduate Diploma Programs' || chooseProgram=='MBA (Distance) Programs' || chooseProgram=='MBA (Online) Programs')
            && chooseProgram!=objAccount.nm_ChooseaProgram__c) {
                requireDocumentUpload = true;
        }
        System.debug('selfLearning Marterial----->'+objAccount.SLF__c);
        System.debug('shipping choice--->'+address.addressChoice);
        System.debug('Shipping city ---->'+objAccount.City_Shipping_Account__c);
        if(objAccount.SLF__c == 'Send to my shipping address' && address.addressChoice =='Yes' && (String.isNotBlank(address.city) && String.isNotBlank(address.state))) {
            System.debug('addressChoice '+address.addressChoice);
            // address to shipping 
            objAcc.Shipping_Address_Choice__c='';
            objAcc.House_No_Name_Shipping_Account__c = address.addressLine1;
            objAcc.Shipping_Street__c = address.addressLine2;
            objAcc.Locality_Name_Shipping__c = address.addressLine3;
            objAcc.State_Province_Shipping__c = address.state;
            objAcc.Zip_Postal_Code_Shipping__c = address.postalCode;
            objAcc.City_Shipping_Account__c = address.city;
            objAcc.Country_Shipping__c = address.country;

        }   
        update objAcc; 

        if(String.isNotBlank(strSelectedEligiblity)) {
            nm_EligiblityCriteria__c objEligibility = mapOfIdVsEligiblity.get(strSelectedEligiblity);
            List<nm_WorkExperience__c> lstWEToUpsert = new List<nm_WorkExperience__c>();
            if(lstWorkExperience != null && lstWorkExperience.size() > 0) {
                for(nm_WorkExperience__c objWE : lstWorkExperience) {
                    objWE.nm_Student__c = strAccID;
                    System.debug('objWE.Name==>'+objWE.Name);
                    objWE.Id = objWE.Name!=null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
                    if((objWE.nm_StartDate__c != null && objWE.nm_EndDate__c != null) || (objWE.nm_StartDate__c != null && objWE.Currently_Working_Here__c)) {
                        System.debug('objWE.Industry__c ==>'+objWE.Industry__c);
                        System.debug('objWE.Id ==>'+objWE.Id);
                        lstWEToUpsert.add(objWE);
                    }
                }

                if( lstWEToUpsert.size() > 0 ){
                    //to delete removed workexpereince.
                    if(removedWorkExperience.size() > 0){
                        delete [SELECT Id FROM nm_WorkExperience__c WHERE Id in :removedWorkExperience];
                    }
                    upsert lstWEToUpsert;
                }

                for(nm_WorkExperience__c objWE :lstWorkExperience) {
                    objWE.Id = null;
                }
            }
        }
    }

    public void insertProduct() { 
        nm_StudentProgram__c objStudentProgram;
        Boolean checkDisapproved = false;
        String pgName = '';
        if(objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0) {
            objStudentProgram = objAccount.Student_Program__r[0].clone(true); 
        }
        if (String.isNotBlank(strSelectedProg) ) {
            List<nm_Program__c> lstPg = [SELECT Id, Name FROM nm_Program__c WHERE Id = :strSelectedProg LIMIT 1];
            if (lstPg.size() > 0) {
                pgName = lstPg[0].Name;
            }
        }
        System.debug('-------------ProgChangeFee---------------'+progChangeFee);
        lstICChange = queryProgramChangeRequest();
        if( changeProgram=='Yes' && mapPricebook.containsKey('Program Change Fee') && mapPricebook.get('Program Change Fee')!= null && lstICChange.size()<1) {
            insertOpportunityLineItem(progChangeFee);
            if( strSelectedProg != null && objStudentProgram!=null && (String)objStudentProgram.nm_Program__c != strSelectedProg) {
                if(strProgChangeReason != null) {
                    insertServiceChangeRequest(strProgChangeReason,'Program Change',strSelectedProg, strSelectedEligiblity, pgName);
                }
            }
            else {
                errorMessage.add('Unable to process the Program change request. Please contact your current Information Center.');
            }
        }
        System.debug('changeProgram ==>'+changeProgram);
        if(lstICChange.size() > 0) {
            List<IC_Change_Request__c> lstICChangetoUpdate = new List<IC_Change_Request__c>();
            for(IC_Change_Request__c obj : lstICChange) {
                if(obj.Opportunity__c!=null && obj.nm_TypeofRequest__c == 'Program Change' && strRegFor == Integer.valueOf(obj.Opportunity__r.nm_Semester__c) && changeProgram=='Yes') {
                    obj.nm_Reason_for_Change_of_Program__c = strProgChangeReason;
                    obj.New_Program__c = strSelectedProg;
                    if(obj.Eligibility_Criteria__c == null && String.isNotBlank(strSelectedEligiblity)) {
                        obj.Old_Eligibility_Criteria__c = objAccount.nm_EligiblityCriteria__c; 
                    }
                    obj.Eligibility_Criteria__c = strSelectedEligiblity;
                    programChangeRequested = true;
                    // to check is need to add student kits=
                    Boolean isNeedToAddStudentKit1 = checkForStudentKit(lstOpportunity, pgName);
                    system.debug('isNeedToAddStudentKit --> ' + isNeedToAddStudentKit1);
                    if (isNeedToAddStudentKit1) {
                        obj.Student_Kits__c=true;
                    }
                    lstICChangetoUpdate.add(obj);
                } 
                else if(obj.Opportunity__c!=null && obj.nm_TypeofRequest__c == 'Program Change' && strRegFor == Integer.valueOf(obj.Opportunity__r.nm_Semester__c) && changeProgram=='No') {
                    checkDisapproved = true;
                    programChangeRequested = false;
                    obj.Status__c = 'Disapproved';
                    lstICChangetoUpdate.add(obj);
                }
            }
            System.debug('checkDisapproved ==>'+checkDisapproved);
            System.debug('programChangeRequested ==>'+programChangeRequested);
            if(lstICChangetoUpdate.size() > 0) {
                update lstICChangetoUpdate;
            }

            // To referesh the opporutnity records if lineItem is deleted.
            if(checkDisapproved) {
                String recordId = lstOpportunity[0].id;
                lstOpportunity = [SELECT id,ActualPendingAmount__c, Program_Name__c,nm_Program__r.nm_ProgramName__c,Amount, Tuition_Fees__c,Dispatch_Order_For_Student__c,Account.nm_DefencePersonnel__c,nm_StudentProgram__c, nm_PendingAmount__c, PendingAmmount__c, nm_PaymentDone__c, nm_Semester__c,ConsumerType__c,ReRegCompleted__c,
                                Accountid,nm_StudentProgram__r.nm_Program__c,nm_Session__c,nm_year__c,nm_SelfLearningMaterial__c,nm_program__r.name,nm_Fee_Type__c,StageName,Program_Structure__c,Career_Service__c,CareerServiceProgram__c,Name,Form_Submission_History__c,LiveLecturesType__c,Sem__c
                                FROM Opportunity WHERE id=:recordId];
            }
        }

    }

    public Boolean checkForStudentKit(List<Opportunity> lstOpp, String pgName) {
        if (lstOpp.size() > 0  ) {
            Opportunity objOpp = lstOpp[0];
            if (objOpp.Dispatch_Order_Number_For_Student__c != null && String.isNotBlank(pgName)) {
                List<String> lstProgram = objOpp.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c != null ? objOpp.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__r.Program__c.split(';') : new List<String>();
                System.debug('objOpp.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c --> ' + objOpp.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c);
                System.debug('lstProgram.contains(objOpp.Program_Name__c) -->'  + lstProgram.contains(pgName));
                System.debug('pgName'  + pgName);
                if (objOpp.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c != null && lstProgram.size() > 0 &&  !lstProgram.contains(pgName) ) {
                    return true;
                }
            }
        }
        return false;
    }


    public void insertOpportunityLineItem(decimal serviceChangeFee) {
        lstOpportunity[0].Amount += serviceChangeFee;
        lstOpportunity[0].nm_SelfLearningMaterial__c = objAccount.SLF__c;
        totalPayFee += serviceChangeFee;
        if(lstOpportunity.size()>0) {
            System.debug('----------------Inside Loop------------------');
            update lstOpportunity;
        }
    }

    public void insertServiceChangeRequest(String reasonForChange, String typeOfRequest, String selectedServiceName, String selectedEligiblity, String pgName) {
        lstICChange = queryProgramChangeRequest();
        if(lstICChange.size()<1) {
            IC_Change_Request__c objICRProgran = new IC_Change_Request__c();
            if(typeOfRequest == 'Program Change') {
                objICRProgran.nm_Reason_for_Change_of_Program__c = reasonForChange;
                objICRProgran.New_Program__c = SelectedServiceName;
                if(String.isNotBlank(selectedEligiblity)) {
                    objICRProgran.Eligibility_Criteria__c = selectedEligiblity;
                    objICRProgran.Old_Eligibility_Criteria__c = objAccount.nm_EligiblityCriteria__c;
                }
                programChangeRequested = true;
            }
            String StrEmail = objAccount.nm_Centers__r.Owner.Email;
            if(String.isNotBlank(StrEmail)) {
                StrEmail = StrEmail.replace('lcdelhi',' AC_NewDelhi');
                StrEmail = StrEmail.replace('lc','ac_');
            }
            objICRProgran.LC_Email__c = StrEmail ;
            System.debug('lsti[0].Owner.Email-->'+StrEmail);
            objICRProgran.Student__c=lstOpportunity[0].Accountid;
            objICRProgran.Opportunity__c=lstOpportunity[0].id;
            objICRProgran.nm_TypeofRequest__c=typeOfRequest;
            if (semFuture == String.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) && lstOpportunity[0].StageName == 'Closed Won') {
                objICRProgran.ignore_closed_won_check__c=true;
            }
            Boolean isNeedToAddStudentKit1 = checkForStudentKit(lstOpportunity, pgName);
            system.debug('isNeedToAddStudentKit --> ' + isNeedToAddStudentKit1);
            if (isNeedToAddStudentKit1) {
                objICRProgran.Student_Kits__c=true;
            }
            insert objICRProgran;
        }
        
    }

    public Boolean partPaymentValidation(Opportunity objOpp) {
        try {
            nm_StudentProgram__c objStudentProgram = objAccount.Student_Program__r[0];
            Integer lastSem = (Integer)objStudentProgram.nm_Program__r.nm_TotalSemesters__c;
            Integer currentSem = Integer.valueOf(objOpp.nm_Semester__c);
            Integer midSem = (lastSem/2) + 1;
            if(midSem == currentSem && objOpp.nm_Fee_Type__c.contains('Considered')) {
                List<Opportunity> lstOpp = [SELECT id,nm_Semester__c FROM Opportunity WHERE AccountId=:objAccount.id AND nm_Semester__c='1' LIMIT 1];
                if (lstOpp.size() > 0) {
                    List<nm_Payment__c> lstPayment = [SELECT id,nm_PaymentStatus__c FROM nm_Payment__c WHERE nm_OpportunityNew__c =:lstOpp[0].id AND nm_PaymentStatus__c='Waived Off' AND nm_PaymentType__c='Additional Charge'];
                    if(lstPayment.size() > 0) {
                        return true;
                    }
                } else {
                    return false;
                }
            } 
            return false;
        } catch (Exception error) {
            System.debug(error.getMessage());
            return true;
        }
    }

    // For Career Service API  objAccount.nm_StudentNo__c objStudentProgram
    // @RemoteAction
    public static String getCSAvailability() {
        String sapid = '';
        String sem = '';
        String jsonBody = '{"sapid":"'+sapid+'","sem":"'+sem+'"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.SetEndPoint('https://studentzone-ngasce.nmims.edu/careerservices/m/getStudentPacakgeForSemester');
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setBody(jsonBody);
        //response = http.send(request);
        System.debug(response.getBody());
        String result = response.getBody();
        return result;
    }

    public class ShowAvailableProgram {
        public Boolean diploma {get;set;}
        public Boolean postGraduate {get;set;} 
        public Boolean mbaDistance {get;set;}
        public Boolean mbaOnline {get;set;}

        public ShowAvailableProgram() {
            this.diploma = diploma;
            this.postGraduate = postGraduate;
            this.mbaDistance = mbaDistance;
            this.mbaOnline = mbaOnline;
        }
    }

    public class AddressField {
        public String addressChoice {get;set;}
        public String postalCode {get;set;}
        public String postalCodeMessage {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String addressLine1 {get;set;}
        public String addressLine2 {get;set;}
        public String addressLine3 {get;set;}
        public String country {get;set;}

        public AddressField() {
            this.addressChoice = addressChoice;
            this.postalCode = postalCode;
            this.city = city;
            this.state = state;
            this.addressLine1 = addressLine1;
            this.addressLine2 = addressLine2;
            this.addressLine3 = addressLine3;
            this.country = country;
            this.postalCodeMessage = postalCodeMessage;
        }
    }

    public class CSPackage {
        public Id id {get;set;}
        public String name {get;set;}
        public String isEligible {get;set;}

        public CSPackage() {
            this.id = id;
            this.name = name;
            this.isEligible = isEligible;
        }
    }

    public class Coursera {
        public Boolean isCourseraAlreadyOpted {get;set;} // is to check wheather the user already opted the Coursera
        public Boolean showCoursera {get;set;} // to check wheather the user is eligble for Coursera
        public Boolean checkCourseraOpted {get;set;} // to check if user selected coursera
        public Decimal applicableCourseraFee {get;set;}
        public String disclaimer {get;set;}
        public Coursera() {
            this.isCourseraAlreadyOpted = false;
            this.showCoursera = false;
            this.checkCourseraOpted = false;
            this.applicableCourseraFee = 0;
            this.disclaimer = null;
        }
    }

}