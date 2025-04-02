/* *
* @File Name          : nmPaymentNew.cls
* @Description        : 
 * @Author             : shubhranshu
* @Group              : 
 * @Last Modified By   : @Ravi
* @Last Modified On   : 14--11--2024
* @Modification Log   : 
 *==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    22/3/2019, 11:34:10 AM   shubhranshu      Initial Version
**/
public without sharing class nmPaymentNew{
    public Lead objLead {get;set;}
    public Account objAccount {get;set;}
    public nm_StudentProgram__c objStudentProgram {get;set;}
    public Opportunity objOpportunity {get;set;}
    public nm_Payment__c objPayment{get;set;}
    public nm_Payment__c objDownPayment {get;set;}
    public ProductHelper productHelper;
    public Set<String> setOfApplicablePaymentOptionForStudent {get;set;}// Map for Showing Payment Option
    public set<String> setOfCaptialFloatAEP {get;set;}
    public Map<String,String> mapOfActiveCalender {get;set;} // map Of Active Calendar not in use
    public Map<String,PriceBookEntry> mapOfPricebook {get;set;}
    public Map<String,Decimal> mapOfProductAndAmount {get;set;}
    public NM_Payment_Form_Configuration__c objPaymentFormConfiguration {get;set;}
    public String paymentGateWayName {get;set;}
    public String semester {get;set;}
    public String recordId {get;set;}
    public String opportunityId {get;set;}
    public String programId {get;set;}
    public String studentNumber {get;set;}
    public String accId {get;set;}
    public String programName {get;set;}
    public String programStructure {get;set;}
    public boolean CareerServicePackage {get;set;}
    public String CareerServicePackageName {get;set;}
    public boolean ShowCareerServiceOpt {get;set;}
    public boolean CareerServiceOpted {get;set;}
    public decimal applicableCareerServiceFee {get;set;}
    public decimal applicableOnlyLiveLectureFee {get;set;}
    public decimal applicableLiveLectureFee {get;set;}
    public decimal applicableBacklogFee {get;set;}
    public String returnUrl {get;set;}
    public String paymentFor {get;set;}
    public boolean IsReregistartion {get;set;}
    public boolean IsICForMakingPayment {get;set;} // to distinguish between student and IC (for Showing DD Option for making Payment) 
    public boolean IsHOForMakingPayment {get;set;} // to distinguish between IC and HO (for Showing DD Option for making Payment) 
    public String feePaidSemester {get;set;}
    public String studentProgramId {get;set;}
    public String studentNo {get;set;}
    public String centerAddressForDD {get;set;}
    public String ICName {get;set;}
    public String ICContact {get;set;}
    public String stagename {get;set;}
    public Boolean IsupGrad {get;set;}
    public Map<String,Map<Id,nm_Courses__c>> mapOfCourseKeyVsCourseObj {get;set;}
    public Map<Id,nm_Courses__c> mapOfCourseKeyVsCurrentCourseObj {get;set;}
    public Map<String , Object> mapOfBacklogCourseIdVsBacklogObject {get; set;}
    public integer sizeOfMapOfBacklogCourseIdVsBacklogObject {get; set;}
    public String jsonMapOfProductAndAmount {get;set;}
    public String jsonMapOfLectureTypeAndSubjects {get;set;}
    public String eligibility{get;set;}
    public String courseList{get;set;}
    public String backlogList{get;set;}
    public String courseListWithBacklogList{get;set;}
    public String consumerType {get;set;}
    public date Today {get;set;}
    public Boolean isTerm {get;set;}
    public Boolean isOpportunityProcessed {get;set;}
    //--------Select option----------//
  /*  public list<SelectOption> getChooseProgram {get;set;}
    public list<SelectOption> getProgramsList {get;set;}
    public list<SelectOption> getEligiblityCriteriaList {get;set;}*/
    //--------End of Select Option----------//
    
    //--- Installment -----//
    public decimal intTotalInstallmentPaid  { get; set; } // to Keep Track of No of Installment Option available and Paid
    public Integer intTotalInstallmentApplicable {get;set;} 
    public Decimal totalsem {get;set;}
   // public decimal InitialMBAWXFee {get;set;}
    public decimal maxInstalmentAmt {get;set;}
    public Integer intTotalInstallmentOptionAvaliable {get;set;} // kept for Special Cases
    public boolean AlreadyMadeAllInstallment {get;set;}
    public String InstallmentPayFor {get;set;}
    public decimal totalamountreceived {get;set;}
    public decimal depositAmount {get;set;}
    public date LateFeeStartDate {get;set;}
    public boolean paymentWindowClosed {get;set;}
    public boolean loanWindowClosed {get;set;}
    public STring paymentClouserMessage {get;set;}
    
    // --- Payment form Configuration ----//
    public String currentAdmissionYear {get;set;}
    public String currentAdmissionSession {get;set;}
    public String programCategory {get;set;}
    public String programSpecialization  {get;set;}
    public Boolean subventionPrograms {get;set;}
    // public Boolean subventionWith2PercentPrograms {get;set;}
    public String programType {get;set;}
    public String TagPriceBookId {get;set;}
    public boolean IsDefence {get;set;}
    public boolean IsLateral {get;set;}
    public String LateralStudentNo {get;set;}
    public String priceBookName {get;set;}
    public String productName {get;set;}
    public decimal applicableLateFee {get;set;}
    public decimal applicableAwithR {get;set;}
    public decimal DaysPendingforInitialPayment {get;set;}
    public decimal DaysPendingforAdmissionPayment {get;set;}
    public boolean MergeAdmissionFeeWithRegistration {get;set;}
    public boolean ShowInitialAdmissionPayment {get;set;}
    public decimal InitialAdmissionPaymentAmount {get;set;}
    public decimal PartAdmintoReg {get;set;}
    public decimal RegistrationFee{get;set;}
    public decimal AlreadyPaidInstallmentAmount {get;set;}
    public decimal AlreadyPaidInitialAmount {get;set;}
    public decimal AlreadyPaidLateFeeAmount {get;set;}
    // For Eduvanz Master's Programs
    public decimal totalAmountPaid {get;set;}
    // For Total Paid Amount 
    public decimal initalAmountRecieved {get;set;}
    public LiveLecturePayment objLiveLecturePayment {get;set;}
    public List<IC_Change_Request__c> lstProgchange {get;set;}

    public boolean AlreadyPaidRegistrationFee {get;set;}
    public boolean AlreadyPaidInitialAdmissionfee {get;set;}
    public boolean AlreadyPaidAdmissionFee {get;set;}
    public boolean AlreadyPaidAnnualFee {get;set;}
  //  public boolean AlreadyPaidPGAllSemFee {get;set;}
    public boolean AlreadyPaidMultipleSemFee {get;set;}
   // public boolean AlreadyPaidRepeatTermFee {get;set;}
    //public boolean AlreadyPaidMSAllSemFee {get;set;}
    public boolean AlreadyPaidLateFee {get;set;}
    public boolean AlreadyPaid3SemFee{get;set;}
    public boolean AlreadyPaid3TermFee{get;set;}
    public boolean AlreadyPaidFullFee{get;set;}
    public boolean AlreadyPaid4SemFee{get;set;}
    public boolean AlreadyPaid5SemFee{get;set;}
    public boolean showliveLectureBasedOnSY {get;set;}
    public String feeType {get;set;}
    public String liveLecType {get;set;}
    public Boolean hasAvanseProgramCode {get;set;}
    
    // --------------Student Details For Payment ----//
    public String studentName {get;set;}
    public String FirstName {get;set;}
    public String LastName {get;set;}
    public String studentEmail {get;set;}
    public String studentMobileNo {get;set;}
    public String studentAddress {get;set;}
    public String studentCity {get;set;}
    public String studentCountry {get;set;}
    public String studentPincode {get;set;}
    public String studentShippingAddress {get;set;}
    
    //-----------------------Loan Field --------------//
    public String LoanType {get;set;}
    public String EMI {get;set;}
    public String InterestRate {get;set;}
    public String Tenure {get;set;}
    public String processingFee {get;set;} // kept for Capital Float
    public boolean LoanSanctioned {get;set;}
    public boolean LoanApproved {get;set;}
    public boolean showEMIOption {get;set;}
    public String EMIFeeType {get;set;}
    public String EMI_Processing_Fee {get;set;}
    public String DP_EMI_ProcessingFee {get;set;}
    
    //---- Stores error messages --- //
    public string errMessages { get; set; }
    public boolean isShow {get;set;}
    public string strSecToShow { get; set; }
    public String SessionChecksum {get;set;}
    public boolean oppExist {get;set;}

    // ------ Coursera ------------------
    public Coursera objCoursera {get;set;}

    // To allow payment if student has not paid the full fee prior to drive closer
    public Set<String> setOfPaymentOptionsAvailable {get;set;}
    public Boolean allowPayment {get;set;} // allowPayment - varaiable to be removed
    public Boolean checkAdmissionPaid {get;set;} // checkAdmissionPaid - variable to be removed
    public Decimal totalProductAmountPaid {get;set;} // totalProductAmountPaid - varaiable to be removed

    // --------ReRegistration -------------------
    public ReRegistration objReReg {get;set;}

    // --------Admission Amount -------------------
    public AdmissionAmount objAdmissionAmount {get;set;}
   
    public nmPaymentNew(){
        Today = Date.today();
        studentName = '';
        EMIFeeType = '';
        processingFee = '';
        eligibility ='';
        accId ='';
        studentNumber = '';
        stagename ='';
        CareerServicePackage = false;
        ShowCareerServiceOpt =false;
        consumerType ='';
        CareerServiceOpted = false;
        CareerServicePackageName='';
        LoanSanctioned = false;
        LoanSanctioned = false;
        showEMIOption = false;
        AlreadyPaidInitialAdmissionfee =false;
        ShowInitialAdmissionPayment=false;
        MergeAdmissionFeeWithRegistration=false;
        showliveLectureBasedOnSY = false;
        programName = '';
        programStructure='';
        Tenure = '';
        DP_EMI_ProcessingFee = '';
        EMI = '';
        InterestRate = '';
        totalamountreceived =0;
        totalsem =0;
        maxInstalmentAmt =0;
        LoanType = '';
        studentAddress ='';
        studentShippingAddress ='';
        studentEmail = '';
        feeType = '';
        liveLecType='';
        courseList='';
        backlogList ='';
        courseListWithBacklogList='';
        studentMobileNo = '';
        programId = '';
        studentCity = '';
        studentPincode = '';
        EMI_Processing_Fee ='';
        programSpecialization  ='';
        objLead = new Lead();
        objAccount = new Account();
        setOfCaptialFloatAEP = new Set<String>();
        objStudentProgram = new nm_StudentProgram__c();
        objOpportunity = new Opportunity();
        AlreadyPaidLateFeeAmount = 0;
        AlreadyPaidInstallmentAmount = 0;
        AlreadyPaidInitialAmount =0;
        AlreadyPaidLateFeeAmount = 0;  
        objLiveLecturePayment = new LiveLecturePayment();
        objPayment = new nm_Payment__c();
        objDownPayment = null;
        productHelper = new ProductHelper();
        setOfApplicablePaymentOptionForStudent = new Set<String>();
        objPaymentFormConfiguration = new NM_Payment_Form_Configuration__c();
        mapOfProductAndAmount = new Map<String,Decimal>();
        mapOfCourseKeyVsCourseObj = new Map<String,Map<Id,nm_Courses__c>> ();
        mapOfBacklogCourseIdVsBacklogObject = new Map<String, Object>();
        sizeOfMapOfBacklogCourseIdVsBacklogObject =0;
        mapOfCourseKeyVsCurrentCourseObj = new Map<Id,nm_Courses__c> ();
        lstProgchange = new List<IC_Change_Request__c>();
        mapOfActiveCalender = new Map<String,String>();//Not in use
        intTotalInstallmentApplicable = 0;
        paymentWindowClosed = false;
        loanWindowClosed = false;
        intTotalInstallmentPaid = 0;
        intTotalInstallmentOptionAvaliable = 0;
        RegistrationFee=0;
        objReReg = new ReRegistration();
        objAdmissionAmount = new AdmissionAmount();
        centerAddressForDD = '';
        paymentClouserMessage = '';
        studentNo = '';
        //InitialMBAWXFee = 0;
        totalAmountPaid = 0;
        initalAmountRecieved = 0;
        InitialAdmissionPaymentAmount  =0;
        paymentGateWayName = '';
        ICName = '';
        ICContact = '';
        depositAmount = 0;
        DaysPendingforInitialPayment=1;
        DaysPendingforAdmissionPayment=0;
        semester = '';
        recordId = '';
        opportunityId = '';
        returnUrl = '';
        paymentFor = '';
        IsReregistartion = false;
        AlreadyPaidRegistrationFee = false;
        hasAvanseProgramCode = false;

        //AlreadyPaidMSAllSemFee=false;
        AlreadyPaidAdmissionFee = false;
        AlreadyPaidAnnualFee = false;
       // AlreadyPaidRepeatTermFee = false;
        //AlreadyPaidPGAllSemFee = false;
        AlreadyPaidMultipleSemFee = false;
        IsICForMakingPayment = false;
        IsHOForMakingPayment = false;
        AlreadyMadeAllInstallment = false;
        AlreadyPaidLateFee = true;
        AlreadyPaid3SemFee = false;
        AlreadyPaid3TermFee = false;
        AlreadyPaidFullFee =false;
        AlreadyPaid4SemFee = false;
        AlreadyPaid5SemFee= false;
        InstallmentPayFor = '';
        errMessages = '';
        LateralStudentNo = '';
        isShow = false;
        strSecToShow = 'main';
        currentAdmissionYear = '';
        currentAdmissionSession = '';
        programCategory = '';
        programType = '';
        feePaidSemester = '1';
        studentProgramId = '';
        TagPriceBookId = null;
        IsDefence = false;
        IsLateral = false;
        priceBookName = '';
        productName = '';
        applicableLateFee = 0;
        applicableAwithR = 0;
        applicableCareerServiceFee=0;
        applicableOnlyLiveLectureFee=0;
        applicableLiveLectureFee=0;
        applicableBacklogFee=0;
        InitialAdmissionPaymentAmount=0;
        IsupGrad = false;
        subventionPrograms = false;
        jsonMapOfProductAndAmount = '';
        jsonMapOfLectureTypeAndSubjects = '';
        isTerm = false;
        oppExist = false;
        isOpportunityProcessed = false;
        objCoursera = new Coursera();
        allowPayment = false;
        checkAdmissionPaid = false;
        totalProductAmountPaid = 0;
        // subventionWith2PercentPrograms = false;
        SessionChecksum = '';
        setOfPaymentOptionsAvailable = new Set<String>();
        if(ApexPages.currentPage() != null) {
            recordId = ApexPages.currentPage().getParameters().get('id');
            opportunityId = ApexPages.currentPage().getParameters().get('OppsId');
            system.debug('opportunityId --->'+opportunityId );
            semester = ApexPages.currentPage().getParameters().get('sem');
            
            if(ApexPages.currentPage().getParameters().get('IsReRestration') !=null && ApexPages.currentPage().getParameters().get('IsReRestration') !=''){
                IsReregistartion = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IsReRestration'));
            }
            
            if(ApexPages.currentPage().getParameters().get('IC') !=null && ApexPages.currentPage().getParameters().get('IC') !=''){
                IsICForMakingPayment = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IC'));
            }
            if(ApexPages.currentPage().getParameters().get('HO') !=null && ApexPages.currentPage().getParameters().get('HO') !=''){
                IsHOForMakingPayment = Boolean.valueOf(ApexPages.currentPage().getParameters().get('HO'));
            }
            
            if(ApexPages.currentPage().getParameters().get('oppId') !=null && ApexPages.currentPage().getParameters().get('oppId') !=''){
                opportunityId = ApexPages.currentPage().getParameters().get('oppId');
                system.debug('opportunityId --->'+opportunityId );
            }

            if(ApexPages.currentPage().getParameters().get('pp')!=null && ApexPages.currentPage().getParameters().get('pp')!='') {
                allowPayment = Boolean.valueOf(ApexPages.currentPage().getParameters().get('pp'));
            }
        }
        
        System.debug('IsReregistartion---'+IsReregistartion);
        System.debug('opportunityId --->'+opportunityId );
        if(String.isNotBlank(recordId)){
            QueryLeadAccountOpportunityAndPaymentRelatedDetails();
            findPaymentsMadeUsingOpportunity();
            findPaymentsMadeUsingLead();
            configurePaymentOption();
            generateSessionChecksum();
        }
        
    }
    
    /*--------------------Query All Record related to class --------------------------*/
    public void QueryLeadAccountOpportunityAndPaymentRelatedDetails(){
        
    //    String leadQueryString = [Select id, name,nm_Program__c from Lead where id='+recordId+' and IsConverted =false and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null];
        // String leadQueryString = getQueryAllFieldSql('Lead',' id=:recordId and IsConverted =false and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null ','nm_Program__r.prgst__c,nm_Program__r.nm_TotalSemesters__c,nm_InformationCenter__r.ConsumerType__c,nm_InformationCenter__r.Contact_No_1__c,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.recordtype__c');
        String leadQueryString = 'SELECT id,nm_Program__r.prgst__c,nm_Program__r.nm_TotalSemesters__c,nm_InformationCenter__r.ConsumerType__c,nm_InformationCenter__r.Nm_Active__c,nm_Program__r.IsTerm__c,'+
                                'nm_InformationCenter__r.Contact_No_1__c,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.recordtype__c,Coursera__c,IsConverted,ConvertedAccountId,'+
                                'Loan_Type__c,EMI_Amount__c,Capital_Float_Processing_Fee__c,nm_Fee_Type__c,EMI_Processing_Fee_Capital_Float__c,Down_Payment_Made__c,ConvertedOpportunityId,'+
                                'Are_you_from_Defence__c,Is_Lateral__c,nm_Year__c,nm_Session__c,nm_ChooseaProgram__c,Program_Type__c,No_Of_Installment_Allowed__c,Form_Id__c,'+
                                'nm_Semester__c,Student_Number_Lateral__c,nm_RegistrationNo__c,nm_InformationCenter__c,Tenure__c,Interest_Rate__c,DP_EMI_Processing_Fee__c,Is_Already_Qualified__c,'+
                                'IC_Name__c,FirstName,LastName,Email,MobilePhone,Status,nm_EligiblityCriteria__c,nm_Eligibility_Criteria_Ref__c,nm_HouseNumber__c,Street,City,'+
                                'State,PostalCode,Country,Locality_Name_Shipping__c,House_No_Name_Shipping__c,Shipping_Street__c,Shipping_City__c,LC_name__c,State_Province_Shipping__c,nm_Tagged_Pricebook__c,'+
                                'Zip_Postal_Code_Shipping__c,Country_Shipping__c,nm_Program__c,nm_ProgramName__c,Career_Service__c,LiveLecturesType__c,CourseList__c,nm_PaymentStatus__c,nm_Program__r.AvanseAPICode__c FROM Lead'+
                                ' WHERE id=:recordId and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null LIMIT 1';
        System.debug(''+leadQueryString);
        List<Lead> lstLead = DataBase.query(leadQueryString);
        if(lstLead.size() > 0 && lstLead[0].IsConverted) {
            if(String.isBlank(opportunityId)) {
                recordId = lstLead[0].ConvertedAccountId;
                opportunityId = lstLead[0].ConvertedOpportunityId;
            }
            System.debug('Lead is converted==>'+ lstLead[0].ConvertedAccountId +' '+ lstLead[0].ConvertedOpportunityId);
            lstLead = new List<Lead>();
        }
        // String leadPaymentQueryString = getQueryAllFieldSql('nm_Payment__c',' nm_Lead__c =:recordId nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null ');
        // String opportunityPaymentQueryString = getQueryAllFieldSql('nm_Payment__c',' nm_OpportunityNew__c  =:opportunityId nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null ');
        //String InitialPaymentQueryString = getQueryAllFieldSql('nm_Payment__c',' nm_OpportunityNew__c  =:opportunityId and nm_PaymentType__c= \'Initial Payment\' and ( nm_PaymentStatus__c =  \'Payment Made\' or nm_PaymentStatus__c =  \'Payment Approved\') ');
        String accountAdmissionQueryString = getQueryAllFieldSql('Account',' nm_LeadId__c=:recordId','nm_Centers__r.Contact_No_1__c,nm_Program__r.AvanseAPICode__c');
        String accountReRegQueryString = getQueryAllFieldSql('Account',' id=:recordId and nm_Centers__c != null','nm_Program__r.AvanseAPICode__c');
        String opportunityAdmissionQuerString = getQueryAllFieldSql('Opportunity','id=:opportunityId and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null','nm_Program__r.nm_TotalSemesters__c,nm_Program__r.IsTerm__c');
        String opportunityReRegQuerString = getQueryAllFieldSql('Opportunity',' nm_Semester__c =: feePaidSemester and ( StageName = \'Pending Payment - Instalment\' or StageName = \'Pending Payment\' or StageName = \'Pending Payment - Loan\' or StageName = \'Registration Done\' or StageName = \'Closed Won - Re-registration Pending\') and nm_StudentProgram__c =:studentProgramId','nm_Program__r.nm_TotalSemesters__c,nm_Program__r.IsTerm__c');
        //String studentProgramQueryString = getQueryAllFieldSql('nm_StudentProgram__c',' nm_Student__c=:recordId limit 1 ');
        String centerAddressQueryString = getQueryAllFieldSql('nm_Centers__c',' Nm_Active__c = true ',null);
        String opportunityProgramChangeReRegQuery= getQueryAllFieldSql('IC_Change_Request__c','Opportunity__c=:opportunityId  and Status__c = \'New\' and (New_Program__r.Name  =\'BBA-BA\' OR New_Program__r.Name  =\'BBA\') ','New_Program__r.Specialisation__c,New_Program__r.id,New_Program__r.Name,New_Program__r.nm_TotalSemesters__c');
        Map<String,String> mapOfCenterNameAndCenterAddress = new Map<String,String>();
        System.debug('opportunityAdmissionQuerString -->'+opportunityId);
        // create Map Of Center Name and Center Address
        List<nm_Centers__c> lstCenters = DataBase.query(centerAddressQueryString);
        if(lstCenters.size() > 0) {
            for(nm_Centers__c objCenter : lstCenters){
                mapOfCenterNameAndCenterAddress.put(objCenter.id,objCenter.Name+'\n'+objCenter.Address__c);
            }
            lstCenters = null;
        }
       //  List<nm_Payment__c> lstOfInitialPayment = DataBase.query(InitialPaymentQueryString);
        // List<Lead> lstLead = [Select id, name,nm_Program__c,Loan_Type__c from Lead where id=:recordId and IsConverted =false and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null];
        if(lstLead.size() > 0 ){
            System.debug('leadQueryString-->'+leadQueryString);
            objLead =  lstLead[0];
            LoanType = objLead.Loan_Type__c;
            System.debug('EMI----0'+objLead.EMI_Amount__c);
            EMI = objLead.EMI_Amount__c;
            processingFee = objLead.Capital_Float_Processing_Fee__c;
            EMIFeeType = objLead.nm_Fee_Type__c;
            EMI_Processing_Fee = objLead.EMI_Processing_Fee_Capital_Float__c;
            if(objLead.Down_Payment_Made__c){// down Payment done then only show EMI Option for Capital float
                showEMIOption = true;
            }
            feeType = objLead.nm_Fee_Type__c;
            liveLecType = objLead.LiveLecturesType__c;
            courseList = objLead.CourseList__c;
            consumerType = objLead.nm_InformationCenter__r.ConsumerType__c;
            IsDefence = objLead.Are_you_from_Defence__c =='Yes'?true:false;
            IsLateral = objLead.Is_Lateral__c;
            currentAdmissionYear = String.valueOf(objLead.nm_Year__c);
            currentAdmissionSession = objLead.nm_Session__c;
            programCategory = objLead.nm_ChooseaProgram__c;
            programSpecialization  = objLead.Program_Type__c;
            subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
            // subventionWith2PercentPrograms = checkSubventionWith2PerSchemePrograms(programSpecialization);
            intTotalInstallmentOptionAvaliable = Integer.valueOf(objLead.No_Of_Installment_Allowed__c);
            programType = 'Admission';
            totalsem = objLead.nm_Program__r.nm_TotalSemesters__c;
            Semester = objLead.nm_Semester__c;
            LateralStudentNo = objLead.Student_Number_Lateral__c;
            studentNo = objLead.nm_RegistrationNo__c;
            centerAddressForDD = mapOfCenterNameAndCenterAddress.get(objLead.nm_InformationCenter__c);
            ICName = objLead.IC_Name__c;
            ICContact = objLead.nm_InformationCenter__r.Contact_No_1__c;
            studentName = objLead.FirstName +' '+objLead.LastName;
            FirstName = objLead.FirstName;
            LastName = objLead.LastName;
            studentEmail = objLead.Email;
            studentMobileNo = objLead.MobilePhone;
            eligibility = objLead.nm_Eligibility_Criteria_Ref__c;
            studentAddress = objLead.nm_HouseNumber__c +','+ objLead.Street +','+objLead.City+','+objLead.State+','+objLead.PostalCode+','+objLead.Country;
            studentCity = objLead.City;
            studentCountry = objLead.Country;
            studentPincode = objLead.PostalCode;
            String locality = '';
            if(String.isNotBlank(objLead.Locality_Name_Shipping__c)) {
                locality = objLead.Locality_Name_Shipping__c+',';
            }
            studentShippingAddress = objLead.House_No_Name_Shipping__c+','+objLead.Shipping_Street__c+','+locality+objLead.Shipping_City__c +','+objLead.State_Province_Shipping__c+','+objLead.Zip_Postal_Code_Shipping__c+','+objLead.Country_Shipping__c;
            programId = objLead.nm_Program__c;
            programName = objLead.nm_ProgramName__c;
            programStructure = objLead.nm_Program__r.prgst__c;
            isTerm = objLead.nm_Program__r.IsTerm__c;
            if(String.isNotBlank(objLead.Career_Service__c)){
                CareerServicePackage = true; 
            }
            if (objLead.Is_Already_Qualified__c) {
                strSecToShow ='PopUpError';
                errMessages ='Lead already qualified with another partner';
                String type = 'registration';
                returnUrl ='/nmLogin_new?type='+type;
                // return null;
            }
            objCoursera.isCourseraAlreadyOpted = objLead.Coursera__c;
            hasAvanseProgramCode = String.isNotBlank(objLead.nm_Program__r.AvanseAPICode__c) ? true : false;
        }else if(!IsReregistartion){
            System.debug('IsReregistartion-->'+IsReregistartion);
            List<Account> lstAccounts = DataBase.query(accountAdmissionQueryString);
            if(lstAccounts.size()>0){
                objAccount =  lstAccounts[0];
                IsDefence = objAccount.nm_DefencePersonnel__c =='Yes'?true:false;
                IsLateral = objAccount.Is_Lateral__c;
                accId =objAccount.id;
                TagPriceBookId = objAccount.nm_Tagged_Pricebook__c;
                LateralStudentNo = String.valueOf(objAccount.Student_Number_Lateral__c);
                studentNo = objAccount.nm_RegistrationNumber__c;
                centerAddressForDD = mapOfCenterNameAndCenterAddress.get(objAccount.nm_Centers__c);
                ICName = objAccount.IC_Name_1__c;
                ICContact = objAccount.nm_Centers__r.Contact_No_1__c;
                studentName = objAccount.FirstName +' '+objAccount.LastName;
                FirstName = objAccount.FirstName;
                LastName =  objAccount.LastName;
                studentNumber = objAccount.nm_StudentNo__c;
                stagename = objAccount.nmCaptureOpportuntiyStage__c;
                programSpecialization  = objAccount.Program_Type__c;
                subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
                // subventionWith2PercentPrograms = checkSubventionWith2PerSchemePrograms(programSpecialization);
                programCategory = objAccount.nm_ChooseaProgram__c;
                studentEmail = objAccount.PersonEmail;
                studentMobileNo = objAccount.PersonMobilePhone;
               // InitialMBAWXFee = Decimal.valueOf(Label.InitialMBAWXFee).setScale(2);
                eligibility = objAccount.Eligibility_Criteria_Ref__c;
                studentAddress = objAccount.nm_HouseNumber__c + ',' +objAccount.BillingStreet +','+objAccount.BillingCity+','+objAccount.BillingState+','+objAccount.BillingPostalCode+','+objAccount.BillingCountry;
                studentCity = objAccount.BillingCity;
                studentCountry = objAccount.BillingCountry;
                studentPincode = objAccount.BillingPostalCode;
                String locality = '';
                if(String.isNotBlank(objAccount.Locality_Name_Shipping__c)) {
                    locality = objAccount.Locality_Name_Shipping__c + ',';
                }
                studentShippingAddress = objAccount.House_No_Name_Shipping_Account__c+','+objAccount.Shipping_Street__c+','+locality+objAccount.City_Shipping_Account__c +','+objAccount.State_Province_Shipping__c+','+objAccount.Zip_Postal_Code_Shipping__c+','+objAccount.Country_Shipping__c;
                DaysPendingforInitialPayment = objAccount.Interview_status_update_date__c!=null?objAccount.DaysSinceForInitialPayment__c:1;
                DaysPendingforAdmissionPayment = objAccount.Days_Since_For_Admission_Payment__c;
                String studentProgramQueryString = getQueryAllFieldSql('nm_StudentProgram__c',' nm_Student__c=:accId  limit 1 ',null);
                List<nm_StudentProgram__c> lstStudentProgram = DataBase.query(studentProgramQueryString);
                System.debug('lstStudentProgram --->'+lstStudentProgram );
                if(lstStudentProgram.size() >0 ){
                    objStudentProgram = lstStudentProgram[0];
                    studentProgramId = objStudentProgram.id;
                    feePaidSemester = String.valueOf(objStudentProgram.nm_FeesPaidofSemester__c);
                }
                hasAvanseProgramCode = String.isNotBlank(objAccount.nm_Program__r.AvanseAPICode__c);
            }
            
            if(opportunityId !=null && opportunityId != '' && opportunityId != 'NA'){
                list<Opportunity> lstOpportunity = DataBase.query(opportunityAdmissionQuerString);
                if( lstOpportunity != null && lstOpportunity.size() > 0 ){
                    objOpportunity =  lstOpportunity[0];
                    oppExist = true;
                    System.debug('objOpportunity----'+objOpportunity);
                    opportunityId = objOpportunity.id;
                    intTotalInstallmentOptionAvaliable = Integer.valueOf(objOpportunity.No_Of_Installment_Allowed__c);
                    currentAdmissionYear = String.valueOf(objOpportunity.nm_year__c);
                    currentAdmissionSession = objOpportunity.nm_Session__c;
                    programCategory = objAccount.nm_ChooseaProgram__c;
                    programType = 'Admission';
                    feeType = objOpportunity.nm_Fee_Type__c;
                    liveLecType = objOpportunity.LiveLecturesType__c;
                    courseList = objOpportunity.CourseList__c;
                    backlogList = objOpportunity.BacklogList__c;
                    studentNumber = objOpportunity.Student_Number__c;
                    consumerType = objOpportunity.ConsumerType__c;
                    Semester = objOpportunity.nm_Semester__c;
                    programId = objOpportunity.nm_Program__c;
                    stagename = objOpportunity.StageName;
                    LoanType = objOpportunity.Loan_Type__c;
                    totalsem = objOpportunity.nm_Program__r.nm_TotalSemesters__c;
                    programSpecialization  = objOpportunity.Specialisation__c;
                    isOpportunityProcessed = objOpportunity.Processed__c;
                    subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
                    // subventionWith2PercentPrograms = checkSubventionWith2PerSchemePrograms(programSpecialization);
                    if(String.isNotBlank(objOpportunity.Career_Service__c)) {
                        CareerServicePackage = true;
                    }
                    objCoursera.isCourseraAlreadyOpted = objOpportunity.Coursera__c;
                   // totalamountreceived = objOpportunity.Total_Amount_Received__c  ;
                    programName = objOpportunity.Program_Name__c;
                    programStructure =  objOpportunity.Program_Structure__c;
                    System.debug('EMI-----1'+objOpportunity.EMI_Amount__c);
                    EMI = objOpportunity.EMI_Amount__c;
                    if(objOpportunity.Down_Payment_Made__c){// down payment done then only show EMI Option for Capital float
                        showEMIOption = true;
                        processingFee = objOpportunity.Capital_Float_Processing_Fee__c;
                        EMIFeeType = objOpportunity.nm_Fee_Type__c;
                        EMI_Processing_Fee = objOpportunity.EMI_Processing_Fee_Capital_Float__c;
                    }
                }
            }
            System.debug('showEMIOption --'+showEMIOption );
        }else if(IsReregistartion){
            List<Account> lstAccounts = DataBase.query(accountReRegQueryString);
            if(lstAccounts.size()>0){
                objAccount =  lstAccounts[0];
                IsDefence = objAccount.nm_DefencePersonnel__c =='Yes'?true:false;
                IsLateral = objAccount.Is_Lateral__c;
                accId = objAccount.id;
                TagPriceBookId = objAccount.nm_Tagged_Pricebook__c;
                LateralStudentNo = String.valueOf(objAccount.Student_Number_Lateral__c);
                studentNo = objAccount.nm_StudentNo__c;
                studentNumber = objAccount.nm_StudentNo__c;
                centerAddressForDD = mapOfCenterNameAndCenterAddress.get(objAccount.nm_Centers__c);
                ICName = objAccount.IC_Name_1__c;
                studentName = objAccount.FirstName +' '+objAccount.LastName;
                studentEmail = objAccount.PersonEmail;
                programCategory = objAccount.nm_ChooseaProgram__c;
                studentMobileNo = objAccount.PersonMobilePhone;
                studentAddress = objAccount.nm_HouseNumber__c + ',' +objAccount.BillingStreet +','+objAccount.BillingCity+','+objAccount.BillingState+','+objAccount.BillingPostalCode+','+objAccount.BillingCountry;
                String locality = '';
                if(String.isNotBlank(objAccount.Locality_Name_Shipping__c)) {
                    locality = objAccount.Locality_Name_Shipping__c + ',';
                }
                studentShippingAddress = objAccount.House_No_Name_Shipping_Account__c+','+objAccount.Shipping_Street__c+','+locality+objAccount.City_Shipping_Account__c +','+objAccount.State_Province_Shipping__c+','+objAccount.Zip_Postal_Code_Shipping__c+','+objAccount.Country_Shipping__c;
                studentCity = objAccount.BillingCity;
                studentCountry = objAccount.BillingCountry;
                studentPincode = objAccount.BillingPostalCode;
                programSpecialization  = objAccount.Program_Type__c;
                subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
                // subventionWith2PercentPrograms = checkSubventionWith2PerSchemePrograms(programSpecialization);
                String studentProgramQueryString = getQueryAllFieldSql('nm_StudentProgram__c',' nm_Student__c=:accId  limit 1 ',null);
                List<nm_StudentProgram__c> lstStudentProgram = DataBase.query(studentProgramQueryString);
                if(lstStudentProgram.size() >0 ){
                    objStudentProgram = lstStudentProgram[0];
                    studentProgramId = objStudentProgram.id;
                    feePaidSemester = String.valueOf(objStudentProgram.nm_FeesPaidofSemester__c);
                }  
                hasAvanseProgramCode = String.isNotBlank(objAccount.nm_Program__r.AvanseAPICode__c) ? true : false;
            }
           
            Integer additionalSem = 1;
            if(objStudentProgram.ProgramType__c=='Master Programs' && (objAccount.Program_Type__c=='MBA (WX)' || objAccount.Program_Type__c=='MBA (X)' || objAccount.Program_Type__c=='MBA - X')) {
                additionalSem = 0;
            }
            feePaidSemester = String.valueOf(Integer.valueOf(feePaidSemester) + additionalSem);
            System.debug('---feePaidSemester--'+feePaidSemester+'---'+studentProgramId);
            list<Opportunity> lstOpportunity = DataBase.query(opportunityReRegQuerString);
            if( lstOpportunity != null && lstOpportunity.size() > 0 ){
                           
                objOpportunity =  lstOpportunity[0];
                opportunityId = objOpportunity.id;
               lstProgchange = DataBase.query(opportunityProgramChangeReRegQuery); 
               system.debug('lstProgchange--->'+lstProgchange.size()); 
                intTotalInstallmentOptionAvaliable = Integer.valueOf(objOpportunity.No_Of_Installment_Allowed__c);
                currentAdmissionYear = String.valueOf(objOpportunity.nm_year__c);
                currentAdmissionSession = objOpportunity.nm_Session__c;
                programCategory = objAccount.nm_ChooseaProgram__c;
               programId = lstProgchange.size()>0? lstProgchange[0].New_Program__r.id :objOpportunity.nm_Program__c;
                // programId = objOpportunity.nm_Program__c;
                programType = 'Re-Registration';
                CareerServicePackageName = objOpportunity.Career_Service__c;
                CareerServiceOpted = String.isNotBlank(CareerServicePackageName) ? true : false;
                objCoursera.isCourseraAlreadyOpted = objOpportunity.Coursera__c;
                feeType = objOpportunity.nm_Fee_Type__c;
                liveLecType = objOpportunity.LiveLecturesType__c;
                courseList = objOpportunity.CourseList__c;
                backlogList = objOpportunity.BacklogList__c;
                consumerType = objOpportunity.ConsumerType__c;
                Semester = objOpportunity.nm_Semester__c;
                LoanType = objOpportunity.Loan_Type__c;
                isOpportunityProcessed = objOpportunity.Processed__c;
               programName = lstProgchange.size()>0? lstProgchange[0].New_Program__r.Name : objOpportunity.Program_Name__c;
                // programName =  objOpportunity.Program_Name__c;
                programStructure =  objOpportunity.Program_Structure__c;
               totalsem = lstProgchange.size()>0? lstProgchange[0].New_Program__r.nm_TotalSemesters__c : objOpportunity.nm_Program__r.nm_TotalSemesters__c;
               programSpecialization = lstProgchange.size()>0? lstProgchange[0].New_Program__r.Specialisation__c : objOpportunity.Specialisation__c;
            //    totalsem =  objOpportunity.nm_Program__r.nm_TotalSemesters__c;
            //    programSpecialization = objOpportunity.Specialisation__c;
                stagename = objOpportunity.StageName;
                isTerm = objOpportunity.nm_Program__r.IsTerm__c;
                System.debug('EMI----2'+objOpportunity.EMI_Amount__c);
                EMI = objOpportunity.EMI_Amount__c;
                if(objOpportunity.Down_Payment_Made__c){// down payment done then only show EMI Option for Capital float
                    showEMIOption = true;
                    processingFee = objOpportunity.Capital_Float_Processing_Fee__c;
                    EMIFeeType = objOpportunity.nm_Fee_Type__c;
                    EMI_Processing_Fee = objOpportunity.EMI_Processing_Fee_Capital_Float__c;
                }
                
            }
        }

        //get Payment Form Configuration
        String payConfigString = 'Session__c =:currentAdmissionSession and Current_Admission_Year__c =:currentAdmissionYear  and Program_Category__c=:programCategory and Payment_Type__c =:programType and Program_Type__c=:programSpecialization';
        Set<String> setOfSemSpec = String.isNotBlank(Label.PayConfigSemSpecalisation) ? new Set<String>(Label.PayConfigSemSpecalisation.split(';')) : new set<String>();
        if (programType == 'Re-Registration' && String.isNotBlank(programSpecialization) && setOfSemSpec.contains(programSpecialization)) {
            payConfigString = payConfigString + ' AND Semester__c = :Semester';
        }
        String queryNMPaymentFormConfigurationString = getQueryAllFieldSql('NM_Payment_Form_Configuration__c',payConfigString ,null);
        List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(queryNMPaymentFormConfigurationString);
        Set<String> setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>();
        Set<String> setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate = new Set<String>();
        System.debug('lstFormConfiguration --'+lstFormConfiguration.size()+'---currentAdmissionSession---'+currentAdmissionSession+'---CurrentAdmissionYear---'+currentAdmissionYear+'---programCategory--'+programCategory +'----programType---'+programType+'----programSpecialization---'+programSpecialization);
       // System.debug('lstFormConfiguration --'+lstFormConfiguration[0]);
        if(lstFormConfiguration.size() >0){
            objPaymentFormConfiguration = lstFormConfiguration[0];
           
           /* for (NM_Payment_Form_Configuration__c objFormConfigure: lstFormConfiguration)
            {
                if(objFormConfigure.Session__c!=null && objFormConfigure.Session__c!='' && currentAdmissionSession.equalsIgnoreCase(objFormConfigure.Session__c))
                {
                    objPaymentFormConfiguration = objFormConfigure;
                    break;
                }
                else
                {
                     objPaymentFormConfiguration = objFormConfigure;
                }
            }*/
            TagPriceBookId = String.isBlank(TagPriceBookId) ? objPaymentFormConfiguration.Price_Book__c : TagPriceBookId;
            processingFee = objPaymentFormConfiguration.Capital_Float_Processing_Fee__c ;// processing fee for Capital Float
            RegistrationFee = objPaymentFormConfiguration.Registration_Fee__c;
            maxInstalmentAmt = objPaymentFormConfiguration.MaxInstalment__c;
            ShowCareerServiceOpt  = objPaymentFormConfiguration.ShowCareerManagement__c;
            CareerServicePackageName  = CareerServicePackageName!=null ? CareerServicePackageName : objPaymentFormConfiguration.Career_Service__c;
            IsupGrad = objPaymentFormConfiguration.Use_different_payment_credentials__c;
            objCoursera.showCoursera = objPaymentFormConfiguration.Show_Coursera__c;
            if(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c !=null ){
                setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c.split(','));
            }

            if(objPaymentFormConfiguration.Reg_No_Allowed_For_Loan_After_End_Date__c !=null ){
                setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate = new Set<String>(objPaymentFormConfiguration.Reg_No_Allowed_For_Loan_After_End_Date__c.split(','));
            }
            
            if(objPaymentFormConfiguration.Capital_Float_AEP_Available__c !=null){
                setOfCaptialFloatAEP = new Set<String>(objPaymentFormConfiguration.Capital_Float_AEP_Available__c.split(','));
            }
            
            // Captial Float Available for Selected AEP Only
            if(!setOfCaptialFloatAEP.contains(ICName)){
                objPaymentFormConfiguration.Show_Capital_Float_Option__c = false;
            }
           if(objPaymentFormConfiguration.MergeAdmissionFeeWithRegistration__c)
            {
                MergeAdmissionFeeWithRegistration =true;
                PartAdmintoReg = objPaymentFormConfiguration.PercentageAtoR__c;
            }
            System.debug('DaysPendingforInitialPayment-->'+DaysPendingforInitialPayment);
             if(objPaymentFormConfiguration.ShowInitialAdmissionPayment__c  && DaysPendingforInitialPayment >= 0)
            {
                ShowInitialAdmissionPayment =true;
                InitialAdmissionPaymentAmount = objPaymentFormConfiguration.Initial_Admission_Payment__c;
            }
            System.debug('ShowInitialAdmissionPayment-->'+objPaymentFormConfiguration.ShowInitialAdmissionPayment__c);
          /*  if(objPaymentFormConfiguration.ShowInitialAdmissionPayment__c  && DaysPendingforInitialPayment > 0)
            {
               ShowInitialAdmissionPayment = false;                  
            }*/
            if(RegistrationFee <= 0)
            {
                  AlreadyPaidRegistrationFee = true;
            }               
            // for verizon student Late Fee not Applicable 
            if('Verizon'.equalsIgnoreCase(ICName)){
                //objPaymentFormConfiguration.Is_Late_Fee_Applicable__c = false;
                objPaymentFormConfiguration.Show_Registration_Payment_Option__c = false;
                objPaymentFormConfiguration.Show_PGAllSem_Payment_Option__c = false;
                objPaymentFormConfiguration.Show_AnnualSemFee_Payment_Option__c = false;
                objPaymentFormConfiguration.Show_MultipleSemFee_Payment_Option__c = false;
            }
            // if('Emerson'.equalsIgnoreCase(ICName)){
            //     //objPaymentFormConfiguration.Is_Late_Fee_Applicable__c = false;
            //     objPaymentFormConfiguration.Show_Registration_Payment_Option__c = false;
            //     objPaymentFormConfiguration.Show_PGAllSem_Payment_Option__c = false;
            //     objPaymentFormConfiguration.Show_AnnualSemFee_Payment_Option__c = true;
            //     objPaymentFormConfiguration.Show_MultipleSemFee_Payment_Option__c = false;
            // }

            if(feeType ==null || feeType ==''){
                feeType = 'Admission';
            }
            
            intTotalInstallmentApplicable = Integer.valueOf(objPaymentFormConfiguration.No_Of_Applicable_Installment__c);
            if(objPaymentFormConfiguration.Show_Registration_Payment_Option__c){
                setOfApplicablePaymentOptionForStudent.add('Registration Fee');
            }
            if(objPaymentFormConfiguration.Show_Admission_Payment_Option__c){
                setOfApplicablePaymentOptionForStudent.add('Admission');
            }
            if(objPaymentFormConfiguration.ShowInitialAdmissionPayment__c ){
                setOfApplicablePaymentOptionForStudent.add('InitialAdmission');
            }
           /* if(objPaymentFormConfiguration.Show_PGAllSem_Payment_Option__c && !IsLateral && Integer.valueOf(Semester) == 1 ){
                setOfApplicablePaymentOptionForStudent.add('PGAllSemFee');
            }*/
            if(objPaymentFormConfiguration.Show_AnnualSemFee_Payment_Option__c &&  (totalsem - Integer.valueOf(Semester))>=1  && !feeType.contains('-Considered') && (totalsem - Integer.valueOf(Semester))>0){
                setOfApplicablePaymentOptionForStudent.add('AnnualFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            if(objPaymentFormConfiguration.Show_2TermFee_Payment_Option__c &&  (totalsem - Integer.valueOf(Semester))>=1  && !feeType.contains('-Considered') && (totalsem - Integer.valueOf(Semester))>0){
                setOfApplicablePaymentOptionForStudent.add('2TermFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            if(objPaymentFormConfiguration.Show_MultipleSemFee_Payment_Option__c && Integer.valueOf(Semester) == 2 && !feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('MultipleSemFee');
            }
            if(objPaymentFormConfiguration.Show_3SemFee_Payment_Option__c &&  (totalsem - Integer.valueOf(Semester))==2 && !feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('3SemFee');
            }
            if(objPaymentFormConfiguration.Show_3TermFee_Payment_Option__c   &&  (totalsem - Integer.valueOf(Semester))==2 && !feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('3TermFee');
            }
            if(objPaymentFormConfiguration.Show_4SemFee_Payment_Option__c &&  (totalsem - Integer.valueOf(Semester))==3 &&  !feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('4SemFee');
            }
            if(objPaymentFormConfiguration.Show_5SemFee_Payment_Option__c &&  (totalsem - Integer.valueOf(Semester))==4 &&  !feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('5SemFee');
            }
            if(objPaymentFormConfiguration.Show_FullFee_Payment_Option__c && !IsLateral  &&  Integer.valueOf(Semester) == 1  ){
                 setOfApplicablePaymentOptionForStudent.add('FullFee');
            } 
            if(objPaymentFormConfiguration.Show_FullFeeLoan_Payment_Option__c  && !IsLateral  &&  Integer.valueOf(Semester) == 1 ){
                setOfApplicablePaymentOptionForStudent.add('FullFeeLoan');
            }
            if(objPaymentFormConfiguration.Show_AnnualFeeLoan_Payment_Option__c && !IsLateral  &&  Integer.valueOf(Semester) == 1) {
                setOfApplicablePaymentOptionForStudent.add('AnnualFeeLoan');
            }

            /* if(objPaymentFormConfiguration.Show_MBA_Repeat_Term_Payment_Option__c) {
                subventionPrograms = false;
                setOfApplicablePaymentOptionForStudent.add('RepeatTermFee');
            }*/
            
            //--------//-----------//
            
            // for Advance Certificate Student Show Annual Option
            if(programName.startsWith('Advance') && !IsLateral && Integer.valueOf(Semester) < 2 ){
                setOfApplicablePaymentOptionForStudent.add('AnnualFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            
            // show Closure message to Student
            DateTime currentDateTime = DateTime.now();
            if(objPaymentFormConfiguration.Payment_Window_EndDate__c < currentDateTime){
                if(setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.size() > 0){
                    if(!setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.contains(studentNo)){
                         paymentWindowClosed = true;
                         paymentClouserMessage = objPaymentFormConfiguration.Payment_Window_Closure_Message__c;
                    }
                }else{
                     paymentWindowClosed = true;
                     paymentClouserMessage = objPaymentFormConfiguration.Payment_Window_Closure_Message__c;
                }
            }
              // show loan option
            if(objPaymentFormConfiguration.Loan_Window_EndDate__c < currentDateTime) {
                if(setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate.size() > 0) {
                    if(!setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate.contains(studentNo)) {
                        loanWindowClosed = true;
                    }
                } else {
                    loanWindowClosed = true;
                }
            }
        }
        lstFormConfiguration = null;
    }
    
    public Boolean showlivelectureSY(String programCategory,Date BatchStartDate){
        Date checkDate = Date.parse(System.Label.LiveLectureAllowForReRegDate);
        System.debug('checkDate '+checkDate);
        if(programCategory == 'Diploma Programs' && ((BatchStartDate >= checkDate && IsReregistartion) || !IsReregistartion)){
            return true;
        }else if(programCategory != 'Diploma Programs'){
            return true;
        }else{
            return false;
        }
    }
    
    public void configurePaymentOption(){
        // Map of Price Book
        if(String.isBlank(TagPriceBookId)) {
            Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            mapOfPricebook = getMapOfPriceBookIdProductVsPriceBookEntry.get(TagPriceBookId);
        } else {
            mapOfPricebook = productHelper.getMapOfProductVsPriceBookEntry(TagPriceBookId);
        }
        
        // for ReReg Cases 
        if(String.isNotBlank(opportunityId) && opportunityId != 'NA' && !objReReg.isReRegistrationAmountChecked){
            List<OpportunityLineItem> lstOpportunityLineItem =  [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:opportunityId];
            if(lstOpportunityLineItem.size() > 0){
                for(OpportunityLineItem objLineItem : lstOpportunityLineItem){
                    if(objLineItem.Product_Name__c.contains('Change Fee') || objLineItem.Product_Name__c.contains('Student Kits') ){
                        objReReg.ReRegistrationAmount = objReReg.ReRegistrationAmount + objLineItem.UnitPrice;
                    }
                    objReReg.isReRegistrationAmountChecked = true;
                }
            }
        }
       /* String icchangeQueryString = getQueryAllFieldSql('IC_Change_Request__c', ' Student__c  =:recordId and Opportunity__c =:opportunityId and Status__c = \'New\' and ChangeAmount__c = \'\' and ChangeAmount__c = null ');
        List<IC_Change_Request__c> lstICChangeRequest = DataBase.query(icchangeQueryString);
        if(lstICChangeRequest.size() > 0){
            for(IC_Change_Request__c objIC : lstICChangeRequest){
                ReRegistrationAmount = ReRegistrationAmount + mapOfPricebook.get(objIC.nm_TypeofRequest__c+' Fee').UnitPrice;
            }
        }*/
        System.debug('ReRegistrationAmount---'+objReReg.ReRegistrationAmount);
        // configure Payment Option AMount
        configurePaymentAmount();
        if(IsReregistartion){
            getReRegistrationAmountForAdmssion();// PGALlSemFee Consider Cases
        }
        jsonMapOfProductAndAmount = JSON.serialize(mapOfProductAndAmount);

        if(objPaymentFormConfiguration.ShowLiveLectures__c)
        {   
            
            showliveLectureBasedOnSY = showlivelectureSY(programCategory,objAccount.BatchStartD__c);
            System.debug('showliveLectureBasedOnSY '+showliveLectureBasedOnSY);
            if(showliveLectureBasedOnSY){
                
                Integer liveLectureSelected = 0;
                System.debug('liveLecType -->'+liveLecType );
                System.debug('courseList -->'+courseList );
                System.debug('objLiveLecturePayment ==>'+objLiveLecturePayment);
                Boolean isLiveLecturePaid = objLiveLecturePayment.AlreadyPaidLiveLectureFee == true ? objLiveLecturePayment.AlreadyPaidLiveLectureFee : false;
                if(((!IsReregistartion && objAccount.nm_StudentStatus__c=='Confirmed') || isLiveLecturePaid) && String.isNotBlank(liveLecType) && liveLecType!='Custom' && liveLecType != 'No' ) {
                    liveLectureSelected = Integer.valueOf(liveLecType.substring(0,1));
                }
                if(!allowPayment && !isLiveLecturePaid) {
                    setOfApplicablePaymentOptionForStudent.add('Custom');
                }
                System.debug('liveLectureSelected ==>'+liveLectureSelected);
                if(totalsem>=1 && ((String.isNotBlank(liveLecType) && !liveLecType.contains('-Considered')) || String.isBlank(liveLecType)) && liveLectureSelected<1)
                {
                    setOfApplicablePaymentOptionForStudent.add('1SemLecturesFee');
                }           
                if((totalsem - Integer.valueOf(Semester))>=1 && ((String.isNotBlank(liveLecType) && !liveLecType.contains('-Considered')) || String.isBlank(liveLecType)) && liveLectureSelected<2)
                {
                    setOfApplicablePaymentOptionForStudent.add('2SemLecturesFee');
                }
                if((totalsem - Integer.valueOf(Semester))>=2 && ((String.isNotBlank(liveLecType) && !liveLecType.contains('-Considered')) || String.isBlank(liveLecType)) && liveLectureSelected<3)
                {
                    setOfApplicablePaymentOptionForStudent.add('3SemLecturesFee');
                }
                if((totalsem - Integer.valueOf(Semester))>=3 && ((String.isNotBlank(liveLecType) && !liveLecType.contains('-Considered')) || String.isBlank(liveLecType)) && liveLectureSelected<4)
                {
                    setOfApplicablePaymentOptionForStudent.add('4SemLecturesFee');
                }
            }
        }
    }
    
    public void getReRegistrationAmountForAdmssion(){
        if(objOpportunity.nm_Fee_Type__c !=null && objOpportunity.nm_Fee_Type__c !=''){
            if(objOpportunity.nm_Fee_Type__c.contains('-Considered')){// for PGALLSEM,Annual,Multiple Fee Consider take Semester Amount zero as he has already paid
                mapOfProductAndAmount.put('Admission',objReReg.ReRegistrationAmount);
            }
        }
    }

    public void configurePaymentAmount(){
        //System.debug('mapOfPricebook--'+mapOfPricebook.containsKey('Registration Fee'));
        if(mapOfPricebook != null && !mapOfPricebook.isEmpty()){
            // put Product Name and Amount Configuration
            // Registration Amount

            if(objPaymentFormConfiguration.Is_Late_Fee_Applicable__c && !isOpportunityProcessed){ 
                // calculate Late Fee Amount Based upon category 
                applicableLateFee = getLateFeeAmount();
                system.debug('applicableLateFee --->'+applicableLateFee );
            }
            // -------------------------------- Career Service Fee Section --------------------------------
            System.debug('CareerServiceOpted-->'+CareerServiceOpted);
            System.debug('CareerServicePackageName--->'+CareerServicePackageName);
            if(objPaymentFormConfiguration.ShowCareerManagement__c && CareerServiceOpted){
                system.debug('CareerServicePackageName--->'+CareerServicePackageName);
                if(String.isNotBlank(CareerServicePackageName))
                {
                     applicableCareerServiceFee = mapOfPricebook.get(CareerServicePackageName).UnitPrice; 
                }else{
                   //  applicableCareerServiceFee =applicableCareerServiceFee !=null?applicableCareerServiceFee: mapOfPricebook.get('Career Development').UnitPrice; 
                   applicableCareerServiceFee = mapOfPricebook.get('Career Development').UnitPrice; 
                }
            }else {
                applicableCareerServiceFee = (mapOfPricebook.containsKey(CareerServicePackageName) && mapOfPricebook.get(CareerServicePackageName).UnitPrice>0) ? mapOfPricebook.get(CareerServicePackageName).UnitPrice : 0;
            }
            System.debug('applicableCareerServiceFee --->'+applicableCareerServiceFee );

            // ------------------------ Coursera Fee Section ---------------------------------------
            System.debug('checkCourseraOpted -->'+objCoursera.checkCourseraOpted);
            if(objPaymentFormConfiguration.Show_Coursera__c && objCoursera.checkCourseraOpted) {
                objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
            }else {
                objCoursera.applicableCourseraFee = 0;
            }
            System.debug('applicableCourseraFee --->'+objCoursera.applicableCourseraFee );
            
            // Admission Amount 
            if(!IsReregistartion ){
                if(opportunityId !=null && opportunityId != '' && opportunityId != 'NA'){
                }else{
                    Decimal downpaymentAmount = 10000;
                    if(MergeAdmissionFeeWithRegistration){
                        applicableAwithR = PartAdmintoReg;
                        applicableAwithR = (applicableAwithR > downpaymentAmount || applicableAwithR < downpaymentAmount) && (objLead.Program_Type__c!='MBA (WX)' && objLead.Program_Type__c!='MBA (X)' && objLead.Program_Type__c!='MBA - X' && objLead.Program_Type__c!='M.Sc. (AI & ML Ops)' && objLead.Program_Type__c!='M.Sc. (AI)') ? downpaymentAmount : applicableAwithR;
                        if(initalAmountRecieved >= applicableAwithR) {
                            MergeAdmissionFeeWithRegistration = false;
                            applicableAwithR = 0;
                        } else if(initalAmountRecieved > 0 && initalAmountRecieved < applicableAwithR)  {
                            applicableAwithR = applicableAwithR - initalAmountRecieved;
                        }
                        System.debug('initalAmountRecieved ==>'+initalAmountRecieved);
                        System.debug('applicableAwithR ==>'+applicableAwithR);   
                    }                  
                }
                if(ShowInitialAdmissionPayment) {
                    mapOfProductAndAmount.put('InitialAdmissionFee',InitialAdmissionPaymentAmount.setScale(2));              
                }
                
            }else if(IsReregistartion ){
                system.debug('AlreadyPaidRegistrationFee -->'+AlreadyPaidRegistrationFee );
                System.debug('objOpportunity ==>'+objOpportunity);
                AlreadyPaidRegistrationFee = true;
            }
          if(MergeAdmissionFeeWithRegistration && applicableAwithR!=null)
            {
                 System.debug('objPaymentFormConfiguration.Registration_Fee__c-->'+objPaymentFormConfiguration.Registration_Fee__c);
                 mapOfProductAndAmount.put('Registration Fee',RegistrationFee.setScale(2));     
                 mapOfProductAndAmount.put('Initial Payment',applicableAwithR.setScale(2));              
            }
            else
            {
                System.debug('objPaymentFormConfiguration.Registration_Fee__c-->'+objPaymentFormConfiguration.Registration_Fee__c);
                System.debug('RegistrationFee.setScale(2)-->'+RegistrationFee.setScale(2));
                mapOfProductAndAmount.put('Registration Fee',RegistrationFee.setScale(2) );                              
            }
            if(ShowInitialAdmissionPayment)
            {   
                if(totalAmountPaid > 0){
                    InitialAdmissionPaymentAmount = InitialAdmissionPaymentAmount - totalAmountPaid;
                }
                 mapOfProductAndAmount.put('InitialAdmissionFee',InitialAdmissionPaymentAmount.setScale(2));              
            }
            // mapOfProductAndAmount.put('2TermFee', 32445);
            System.debug('Registration Fee--'+mapOfProductAndAmount.get('Registration Fee'));

            Set<String> setOfoptionsTONotChecked = new Set<String>{'Registration Fee', 'InitialAdmission'};
            for (String paymentOption : setOfApplicablePaymentOptionForStudent) {
                if (!setOfoptionsTONotChecked.contains(paymentOption)) {
                    if (paymentOption == 'Admission') {
                        String key = '';
                        if(!IsReregistartion ){
                            key = opportunityId !=null && opportunityId != '' && opportunityId != 'NA' ? objOpportunity.nm_Program__c+'-'+objOpportunity.nm_Semester__c : objLead.nm_Program__c +'-'+objLead.nm_Semester__c;
                        }else if(IsReregistartion ){
                            key = objOpportunity.nm_Program__c+'-'+objOpportunity.nm_Semester__c;
                            if(lstProgchange.size() > 0 && (lstProgchange[0].New_Program__r.Specialisation__c == 'BA' || lstProgchange[0].New_Program__r.Specialisation__c == 'BBA')) {
                                key = lstProgchange[0].New_Program__c+'-'+objOpportunity.nm_Semester__c;
                            }
                        }
                        Decimal productPrice = ProductPricing(paymentOption,getmultiplicationFactor(paymentOption),key);
                        system.debug('paymentOption --> '+paymentOption + '--' + productPrice + ' -- ' + objAdmissionAmount.admissionAmountPaid + ' -- ' + (productPrice - objAdmissionAmount.admissionAmountPaid));
                        if (productPrice > objAdmissionAmount.admissionAmountPaid) {
                            setOfPaymentOptionsAvailable.add(paymentOption);
                            mapOfProductAndAmount.put(paymentOption, productPrice - objAdmissionAmount.admissionAmountPaid);
                        }
                    } else {
                        String productOption = paymentOption == 'AnnualFee' ? 'Annual' : paymentOption;
                        String key = mapOfPricebook.containsKey(productOption+'-'+programId) ? productOption+'-'+programId : productOption;
                        Decimal productPrice = ProductPricing(paymentOption,getmultiplicationFactor(paymentOption),key);
                        system.debug('paymentOption --> '+paymentOption + '--' + productPrice + ' -- ' + objAdmissionAmount.admissionAmountPaid + ' -- ' + (productPrice - objAdmissionAmount.admissionAmountPaid));
                        if (productPrice > objAdmissionAmount.admissionAmountPaid) {
                            setOfPaymentOptionsAvailable.add(paymentOption);
                            mapOfProductAndAmount.put(paymentOption, productPrice - objAdmissionAmount.admissionAmountPaid);
                        }
                    }
                }
            }
            
            // To add the RepeatTermFee in the MapOfProductAnd Amount
          // ProductPricing('RepeatTermFee',1,'Repeat Term');
            // Add Lectures cost
            if(objPaymentFormConfiguration.ShowLiveLectures__c)
            {   
                showliveLectureBasedOnSY = showlivelectureSY(programCategory,objAccount.BatchStartD__c);
                System.debug('showliveLectureBasedOnSY '+showliveLectureBasedOnSY);
                if(showliveLectureBasedOnSY == true){
                    Map<String,Decimal> mapOfliveLecTypeAndSubjects = new Map<String,Decimal>();
                    Decimal liveLecturePrice =  mapOfPricebook.containskey('Live Lectures')? mapOfPricebook.get('Live Lectures').UnitPrice:0;
                    Decimal BacklogPrice =  mapOfPricebook.containskey('Backlog')? mapOfPricebook.get('Backlog').UnitPrice:0;
                    if('Certificate Programs'.equalsIgnoreCase(programCategory) && liveLecturePrice > 0) {
                        liveLecturePrice = liveLecturePrice + (liveLecturePrice * Decimal.valueOf(Label.Service_Tax).setScale(2));
                    }
                    System.debug('liveLecturePrice ==>'+liveLecturePrice);
                    System.debug('product Helper ==>'+productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'1SemLecturesFee','',consumerType));
                    System.debug('objLiveLecturePayment ===> ' + objLiveLecturePayment);
                    if(objLiveLecturePayment.AlreadyPaidLiveLectureFee == null) {
                        objLiveLecturePayment.CourseList = '';
                        objLiveLecturePayment.LiveLectureTypeOpted = '';
                        objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount = 0.0;
                        objLiveLecturePayment.AlreadyPaidLiveLectureFee = false;
                    }
                    if(!mapOfProductAndAmount.containsKey('1SemLecturesFee'))
                    {
                        Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'1SemLecturesFee','',consumerType);
                        mapOfliveLecTypeAndSubjects.put('1SemLecturesFee', totalSubjects + 1);
                        Decimal price = (liveLecturePrice*totalSubjects) - objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount;
                        mapOfProductAndAmount.put('1SemLecturesFee',price);
                        System.debug('1SemLecturesFee---->'+mapOfProductAndAmount.get('1SemLecturesFee'));
                    }
                    if(!mapOfProductAndAmount.containsKey('2SemLecturesFee'))
                    {
                        Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'2SemLecturesFee','',consumerType);
                        mapOfliveLecTypeAndSubjects.put('2SemLecturesFee', totalSubjects + 2);
                        Decimal price = (liveLecturePrice*totalSubjects) - objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount;
                        mapOfProductAndAmount.put('2SemLecturesFee',price);
                        System.debug('2SemLecturesFee---->'+mapOfProductAndAmount.get('2SemLecturesFee'));
                    }
                    if(!mapOfProductAndAmount.containsKey('3SemLecturesFee'))
                    {
                        Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'3SemLecturesFee','',consumerType);
                        mapOfliveLecTypeAndSubjects.put('3SemLecturesFee', totalSubjects + 3);
                        Decimal price = (liveLecturePrice*totalSubjects) - objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount;
                        mapOfProductAndAmount.put('3SemLecturesFee',price);
                        System.debug('3SemLecturesFee---->'+mapOfProductAndAmount.get('3SemLecturesFee'));
                    }
                    if(!mapOfProductAndAmount.containsKey('4SemLecturesFee'))
                    {
                        Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'4SemLecturesFee','',consumerType);
                        mapOfliveLecTypeAndSubjects.put('4SemLecturesFee', totalSubjects + 4);
                        Decimal price = (liveLecturePrice*totalSubjects) - objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount;
                        mapOfProductAndAmount.put('4SemLecturesFee',price);
                        System.debug('4SemLecturesFee---->'+mapOfProductAndAmount.get('4SemLecturesFee'));
                    }
                
                    mapOfProductAndAmount.put('Live Lectures',liveLecturePrice);    
                    mapOfProductAndAmount.put('Backlog', BacklogPrice);  
                    if(courseList!=null && courseList!='') {
                        Decimal price = (liveLecturePrice * productHelper.TotalNumberOfSubject(Integer.valueOf(semester),programStructure,programId,'Custom',courseList,consumerType));
                        mapOfProductAndAmount.put('CustomLive',price);
                    }
                    System.debug('liveLecturePrice--->'+liveLecturePrice);
                    mapOfCourseKeyVsCourseObj = productHelper.getMapOfProgramNamekeyVsCourses();
                    mapOfCourseKeyVsCurrentCourseObj = mapOfCourseKeyVsCourseObj.get(programId+'-'+programStructure+'-'+Integer.valueof(semester)+'-'+consumerType);
                    jsonMapOfLectureTypeAndSubjects = String.isBlank(jsonMapOfLectureTypeAndSubjects) ? JSON.serialize(mapOfliveLecTypeAndSubjects) : jsonMapOfLectureTypeAndSubjects;
                    system.debug('mapOfCourseKeyVsCurrentCourseObj--->'+mapOfCourseKeyVsCurrentCourseObj);
                    if (String.isNotBlank(studentNumber) && !allowPayment) {
                        getBacklogDataFromStudentZone(studentNumber);
                        sizeOfMapOfBacklogCourseIdVsBacklogObject = mapOfBacklogCourseIdVsBacklogObject.size();
                    }
                }
                
            }
        }else{
            errMessages = 'Product Price not found.';
            strSecToShow = 'error';
            returnUrl ='';
        }
    }
    
    public decimal ProductPricing(String productName,Integer multiplicationFactor,String programKey){
            
        decimal amount = 0;
        Integer sem = String.isNotBlank(semester) ? Integer.valueof(semester) : 0;
        System.debug('--programKey---'+programKey+'-productName-'+productName+'programSpecialization--->'+programSpecialization);            
        // if(IsDefence ){
        //     // system.debug('multiplicationFactor-->'+multiplicationFactor);
        //     if(!'MBA (WX)'.equalsIgnoreCase(programSpecialization) && !'MBA (X)'.equalsIgnoreCase(programSpecialization) && !'MBA - X'.equalsIgnoreCase(programSpecialization) && !'M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization)  
        //     && !'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization)){   
            
        //         for(Integer i = sem ;i<=(sem + multiplicationFactor - 1);i++)
        //         {
        //             System.debug('--multiplicationFactor---'+i+'-----'+programId);                
        //             amount += mapOfPricebook.containsKey(programId+'-'+i) ? mapOfPricebook.get(programId+'-'+i).UnitPrice:0;
        //             system.debug('amount---->'+amount);        
        //         }
        //     }else if(('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) || 'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization)) && (productName =='AnnualFee' || productName =='FullFee'))
        //     {        
        //         system.debug('Msc Annual');         
        //             amount =  mapOfPricebook.get(programKey).UnitPrice;                
        //     }
        //     else {
        //         amount = mapOfPricebook.get(programId+'-'+semester).UnitPrice;
        //         amount =  amount * multiplicationFactor;      
        //     }
            
        //     amount = amount * 0.8;
        // // amount = amount * multiplicationFactor;
        // }else{
            if('BA'.equalsIgnoreCase(programSpecialization) && (productName =='AnnualFee' || productName =='3SemFee') )
            {
                for(Integer i = sem ;i<=(sem + multiplicationFactor - 1);i++)
                {
                    System.debug('--multiplicationFactor---'+i+'-----'+programId);  
                    amount += mapOfPricebook.containsKey(programId+'-'+i) ? mapOfPricebook.get(programId+'-'+i).UnitPrice:0;
                    system.debug('amount---->'+amount);        
                }
                if(productName =='AnnualFee')
                {
                    amount = amount * 0.94;
                    system.debug('amount---->'+amount);   
                }else if(productName =='3SemFee' )
                {
                    amount = amount * 0.92;
                    system.debug('amount---->'+amount);   
                }
            }
            else if(mapOfPricebook.containsKey(programKey)) {
                System.debug('enter programName '+programKey);
                amount = mapOfPricebook.get(programKey).UnitPrice;
            }else{
                System.debug('not found '+programKey);
            }
        // }
        if(IsDefence ) {
            amount = amount * 0.8; 
        }
        
        amount = amount+objReReg.ReRegistrationAmount;
        
        // taking Exam fees for Verizon Student
        if('Verizon'.equalsIgnoreCase(ICName)){
            amount += mapOfPricebook.get('Exam Fees').UnitPrice;
        }
        // if('Emerson'.equalsIgnoreCase(ICName) && 'AnnualFee'.equalsIgnoreCase(productName)){
        //     amount = mapOfPricebook.get('AnnualFeeEmerson').UnitPrice;
        // }
        
        // service Tax for Certificate Program 
        if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
            amount += amount * Decimal.valueOf(Label.Service_Tax).setScale(2);
        }
        System.debug('CareerServiceOpted -->'+CareerServiceOpted);
        /* if(CareerServiceOpted)
        {
            amount += mapOfPricebook.get('Career Development').UnitPrice;
        }*/
    
        // added discount for Already Confirmed Student and applied for Executive Program
        if(ValidateStudentNo()){
            amount = amount*0.8;
        }
        
        // debit Installment AMount from Product 
        // if(AlreadyPaidInstallmentAmount > 0){
        //     amount = amount - AlreadyPaidInstallmentAmount ;
        // }
        // if(AlreadyPaidInitialAmount >0)
        // {
        //     amount = amount - AlreadyPaidInitialAmount;
        // // AlreadyPaidInitialAdmissionfee =true;
        // }
        if( ( totalamountreceived  >= (RegistrationFee+InitialAdmissionPaymentAmount ) )&& ShowInitialAdmissionPayment )
        {
            AlreadyPaidInitialAdmissionfee =true;
        }

        
        System.debug('AlreadyPaidInitialAmount--->'+AlreadyPaidInitialAmount );
        System.debug('amount--->'+amount+'---productName---'+productName);

        mapOfProductAndAmount.put(productName,amount.setScale(2));
        return amount.setScale(2);
    }
    
        
    /* ------------------------------- Already Paid Option section to Allowed to student to Upgrade Payment --------------------------------------*/
    public decimal alreadyPaidOptionAmount(String paymentType)
    {
        decimal amountToBeReturn = 0;
        if(AlreadyPaidAnnualFee && paymentType =='FullFee'){// PG All Sem Paid
            amountToBeReturn +=mapOfProductAndAmount.get('AnnualFee');
        }
        if(AlreadyPaidAdmissionFee && (paymentType =='AnnualFee' || paymentType =='2TermFee')){// Annual Sem Paid
            amountToBeReturn +=mapOfProductAndAmount.get('Admission');
        }
        if(AlreadyPaidAnnualFee && paymentType =='MultipleSemFee'){// Multiple Sem Paid
            amountToBeReturn +=mapOfProductAndAmount.get('AnnualFee');
        }
        if(AlreadyPaidAdmissionFee && paymentType =='FullFee' && !AlreadyPaidAnnualFee){
            amountToBeReturn +=mapOfProductAndAmount.get('Admission');
        }
        if(!AlreadyPaidAnnualFee && paymentType =='MultipleSemFee' && AlreadyPaidAdmissionFee){// Multiple Sem Paid
            amountToBeReturn +=mapOfProductAndAmount.get('Admission');
        }
        if(amountToBeReturn < 0){
            amountToBeReturn = 0;
        }
        System.debug('Amount to be return :'+amountToBeReturn);
        return amountToBeReturn;
    }
    /*-----------------------------------------end ------------------------------------------------------------------------------------------------*/
    
    public void findPaymentsMadeUsingOpportunity()
    {                       
        if( objOpportunity != null )
        {
            String queryOpportunityPayment = getQueryAllFieldSql('nm_Payment__c' , ' nm_OpportunityNew__c =:opportunityId and nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null and nm_OpportunityNew__c !=null',null);
            List<nm_Payment__c> lstPayment = DataBase.query(queryOpportunityPayment);
            if(lstPayment.size() >0){
                getAlreadyPaymentPaidOption(lstPayment);
            }
        }
    }
    
    public void findPaymentsMadeUsingLead()
    {   
        if( objLead != null )
        {
            String queryOpportunityPayment = getQueryAllFieldSql('nm_Payment__c' , ' nm_Lead__c =:recordId and nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null and nm_Lead__c  !=null',null);
            List<nm_Payment__c> lstPayment = DataBase.query(queryOpportunityPayment);
            if(lstPayment.size() >0){
                getAlreadyPaymentPaidOption(lstPayment);
            }
        }
    }
    
    public void getAlreadyPaymentPaidOption(List<nm_Payment__c> lstPayment){
        set<String> alreadyPaidOptions = new set<String>();
        alreadyPaidOptions.clear();
        System.debug('--lstPayment---'+lstPayment.size());
        intTotalInstallmentApplicable = intTotalInstallmentOptionAvaliable != null && intTotalInstallmentOptionAvaliable !=0 ? intTotalInstallmentOptionAvaliable : intTotalInstallmentApplicable;
        for(nm_Payment__c objPay : lstPayment){
            if(objpay.nm_Amount__c != null && objpay.nm_PaymentStatus__c != null && objpay.nm_PaymentType__c != null){
                if(objpay.nm_PaymentStatus__c == 'Payment Made' || objpay.nm_PaymentStatus__c == 'Payment Approved' || objpay.nm_PaymentStatus__c == 'Waived Off' )
                {
                    /* To Avoid the payment of inital Amount on the Registration stage,
                    to check wheather the payment is already done. */
                    if(objpay.Consider_Initial_payment__c) {
                        initalAmountRecieved = initalAmountRecieved + objPay.nm_Amount__c;
                    }

                    totalamountreceived += objPay.nm_Amount__c;
                    if( objpay.nm_PaymentType__c == 'Registration' )
                    {
                        AlreadyPaidRegistrationFee = true;
                    }else if('Admission'.equalsIgnoreCase(objpay.nm_PaymentType__c)){
                        AlreadyPaidAdmissionFee = true;

                        // To be Removed
                        // checkAdmissionPaid = true;
                        // totalProductAmountPaid += objPay.nm_Amount__c;
                        // if(objpay.nm_Installment_Payment_Ref__c == 'AnnualFee' || objpay.nm_Installment_Payment_Ref__c == '2TermFee') {
                        //     AlreadyPaidAnnualFee = true;
                        // } else if(objpay.nm_Installment_Payment_Ref__c == 'MultipleSemFee') {
                        //     AlreadyPaid3SemFee = true;
                        // } else if(objpay.nm_Installment_Payment_Ref__c == '3TermFee') {
                        //     AlreadyPaid3TermFee = true;
                        // }
                    }else if('Installment'.equalsIgnoreCase(objPay.nm_PaymentType__c) ){
                        AlreadyPaidInstallmentAmount += objPay.nm_Amount__c;
                        totalProductAmountPaid += objPay.nm_Amount__c;
                        totalAmountPaid = totalAmountPaid + AlreadyPaidInstallmentAmount;
                        intTotalInstallmentPaid++;
                        //to update the previous payement record as down payemnt 
                        createDownPaymentRecord(objpay);
                        if(intTotalInstallmentApplicable == intTotalInstallmentPaid){
                            AlreadyMadeAllInstallment = true;
                        }
                    }
                    else if( 'Initial Payment'.equalsIgnoreCase(objPay.nm_PaymentType__c)){
                        AlreadyPaidInitialAmount += objPay.nm_Amount__c;
                        totalProductAmountPaid += objPay.nm_Amount__c;
                        totalAmountPaid = totalAmountPaid + AlreadyPaidInitialAmount;
                        //to update the previous payement record as down payemnt
                        createDownPaymentRecord(objpay);
                    }
                    else if('Late Fees'.equalsIgnoreCase(objpay.nm_PaymentType__c)){
                        AlreadyPaidLateFee = true;
                        AlreadyPaidLateFeeAmount += objPay.nm_Amount__c;
                    } 
                    else if('Live Lectures'.equalsIgnoreCase(objpay.nm_PaymentType__c)) {
                        objLiveLecturePayment.AlreadyPaidLiveLectureFee = true;
                        objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount = objPay.nm_Amount__c + (objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount > 0 ? objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount : 0);
                        objLiveLecturePayment.LiveLectureTypeOpted = liveLecType;
                        objLiveLecturePayment.CourseList = courseList;
                    } else if(objpay.nm_PaymentType__c.contains('DownPayment')) {
                        totalProductAmountPaid += objPay.nm_Amount__c;
                    }
                    if (objPay.nm_PaymentType__c.contains('Admission') || objPay.nm_PaymentType__c =='Installment' || objPay.nm_PaymentType__c.contains('DownPayment') || objPay.nm_PaymentType__c.contains('Subvention') || objPay.nm_PaymentType__c.contains('Initial Payment') || objPay.nm_PaymentType__c =='Additional Charge') {
                        AlreadyPaidAdmissionFee = true;
                        objAdmissionAmount.isAdmissionAmountPaid = true;
                        objAdmissionAmount.admissionAmountPaid += objPay.nm_Amount__c;
                    }
                }
            }
        }
        // To be removed
        // boolean allApplicablePaymentDone = true;
        // System.debug('alreadyPaidOptions :'+alreadyPaidOptions);
        // System.debug('totalProductAmountPaid :'+totalProductAmountPaid); 
        // System.debug('setOfApplicablePaymentOptionForStudent :'+setOfApplicablePaymentOptionForStudent);
        // for(String pendingOption : setOfApplicablePaymentOptionForStudent){
        //     if(!alreadyPaidOptions.contains(pendingOption)){
        //         allApplicablePaymentDone = false;
        //     }
        // }
        
        // if(allApplicablePaymentDone ){
        //     errMessages = 'Payment already done.';
        //     strSecToShow = 'error';
        //     isShow=true;
        // }
    }
        
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
   
    public decimal getLateFeeAmount(){
        String lateFeeCategory = '';
        decimal LateFeeAmount = 0;
        if(IsLateral && programType=='Admission'){
            lateFeeCategory = 'Is Lateral';
        }else{
            lateFeeCategory = programType;
        }
         
      /* No late fee for 7 days expire
       if(DaysPendingforInitialPayment ==-1 && totalamountreceived < InitialMBAWXFee )
        {
        system.debug('LateFeeAmount --->'+LateFeeAmount );
       // system.debug('totalamountreceived --->'+totalamountreceived );
            LateFeeAmount += Decimal.valueOf(Label.InitialLatefeeExecutiveMBA).setScale(2);
           
        }*/
      
        if(DaysPendingforAdmissionPayment ==-1)
        {
            LateFeeAmount += Decimal.valueOf(Label.AdmissionLatefeeMBAWX).setScale(2);
            system.debug('LateFeeAmount --->'+LateFeeAmount );
           
        }
        system.debug('LateFeeAmount --->'+LateFeeAmount );
        //String lateFeeQueryString = getQueryAllFieldSql('Late_Fee__c',' Category__c =: lateFeeCategory and nm_Type__c=:programCategory and Program_Type__c=:programSpecialization and Start_Date__c <= : Today and End_Date__c >= : Today ',null);
        String lateFeeQueryString = getQueryAllFieldSql('Late_Fee__c',' Category__c =: lateFeeCategory and nm_Type__c=:programCategory and Program_Type__c=:programSpecialization and Session__c=:currentAdmissionSession and Year__c=:currentAdmissionYear and Start_Date__c <= : Today and End_Date__c >= : Today ',null);
        List<Late_Fee__c> lstLateFee = DataBase.query(lateFeeQueryString);
        if(lstLateFee.size() > 0){
          system.debug('LateFeeAmount --->'+LateFeeAmount );
            LateFeeAmount += lstLateFee[0].Late_Fees__c;
            LateFeeStartDate = lstLateFee[0].Start_Date__c;
        }
           system.debug('AlreadyPaidLateFeeAmount --->'+AlreadyPaidLateFeeAmount );
            system.debug('AlreadyPaidLateFee--->'+AlreadyPaidLateFee);
            
        if(LateFeeAmount > 0 && AlreadyPaidLateFeeAmount > 0 && AlreadyPaidLateFee){
            // for Certificate Program Taking Late Fee with Service Tax
            if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
                LateFeeAmount += ( LateFeeAmount * Decimal.valueOf(Label.Service_Tax) );
            }
         
            LateFeeAmount = LateFeeAmount - AlreadyPaidLateFeeAmount;
        }// for Certificate Program Taking Late Fee with Service Tax
        else if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
            LateFeeAmount += ( LateFeeAmount * Decimal.valueOf(Label.Service_Tax) );
        }
        
        if(LateFeeAmount < 0){
            LateFeeAmount = 0;
        }
        
        return LateFeeAmount;
    }
    
    /*--------------------method to validate Student for Executive Program -----------------------------------------*/  
    public Boolean ValidateStudentNo(){
        if('Executive Programs'.equalsIgnoreCase(programCategory) && LateralStudentNo  !='' && LateralStudentNo  !=null){
            List<Account> lstAccount =[select id from Account where nm_StudentNo__c=:LateralStudentNo and nm_StudentStatus__c='Confirmed' ];
            if(lstAccount.size()>0){
                return true;
            }
        }
        return false;
    }
    
    /*---------------------------------------------Online Payment -----------------------------------------------------------------*/
    public pageReference MakeOnlinePayment(){
        System.debug('paymentFor ---'+paymentFor);
        system.debug('recordId----'+recordId);
        List<Lead> ld = new List<Lead>();
        if(!IsReregistartion){
            ld =[SELECT Id,IsConverted from Lead Where Id=:recordId];
        }
        System.debug('ld convert check '+ld);
        if((ld.size() > 0 && ld[0].IsConverted) && String.isBlank(opportunityId) && !oppExist && !IsReregistartion){
            strSecToShow ='PopUpError';
            errMessages ='Something went wrong please login again to continue..';
            String type = IsReregistartion ? 'reregistration' : 'registration';
            returnUrl ='/nmLogin_new?type='+type;
            return null;
        } else {
            if((((objLead.LC_name__c != objLead.IC_Name__c || (objLead.nm_InformationCenter__r.nm_LearningCenter__c == null && objLead.nm_InformationCenter__r.recordtype__c == 'Information Center')) 
            && opportunityId ==null && ((objLead.nm_InformationCenter__r.ConsumerType__c == 'Retail' && objLead.nm_InformationCenter__r.Nm_Active__c) || objLead.nm_InformationCenter__r.ConsumerType__c == 'Corporate')) || IsReregistartion || (opportunityId !=null) || 'Verizon'.equalsIgnoreCase(ICName)) && !'Counsellor'.equalsIgnoreCase(ICName)){
                if(paymentFor !=null && paymentFor !=''){
                    //Creating payment tracking Id. 
                    string strTranTrackid = studentNo+''+datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
                    +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.floor(1000 + Math.random()*9000));
    
                    courseListWithBacklogList = String.isNotBlank(backlogList) ? courseList + '-' + backlogList : courseList ;
                    strTranTrackid = strTranTrackid.right(30);
                    nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
                    objOnlinePayment.TranTrackid = strTranTrackid;
                    objOnlinePayment.strAddress = studentAddress;
                    objOnlinePayment.strCity = studentCity;
                    objOnlinePayment.strCountry = studentCountry;
                    objOnlinePayment.strPincode = studentPincode;
                    objOnlinePayment.strName = studentName;
                    objOnlinePayment.strEmailId = studentEmail;
                    objOnlinePayment.strMobileNumber = studentMobileNo;
                    objOnlinePayment.recordId = recordId;
                    objOnlinePayment.opportunityId = opportunityId;
                    objOnlinePayment.InstallmentAmount = String.valueOf(depositAmount);
                    objOnlinePayment.strPaymentType = paymentFor;
                    objOnlinePayment.InstallmentPayOpt = InstallmentPayFor;
                    objOnlinePayment.studentNo = studentNo;
                    System.debug('CareerServiceOpted check -->'+CareerServiceOpted);
                    objOnlinePayment.IsOptedForCareerService = CareerServiceOpted;
                    objOnlinePayment.isCourseraOpted = objCoursera.checkCourseraOpted;
                    objOnlinePayment.IsupGrad = IsupGrad;
                    // for record + live
                    objOnlinePayment.liveLecType = String.isBlank(liveLecType) || (liveLecType=='Custom' && String.isBlank(courseList)) ? 'No' : liveLecType;
                    objOnlinePayment.courseList = String.isNotBlank(courseListWithBacklogList) ? courseListWithBacklogList : null;
                    
                    if(IsupGrad) {
                        objOnlinePayment.Paytm_MerchantKey = objPaymentFormConfiguration.Paytm_Website_Key__c;
                        objOnlinePayment.Paytm_IndustryId = objPaymentFormConfiguration.Paytm_IndustryId__c;
                        objOnlinePayment.Paytm_MID = objPaymentFormConfiguration.Paytm_MID__c;
                        objOnlinePayment.Paytm_EncryptionKey = objPaymentFormConfiguration.Paytm_EncryptionKey__c;
                        objOnlinePayment.HDFC_SecretKey = objPaymentFormConfiguration.HDFC_SecretKey__c;
                        objOnlinePayment.HDFC_SALT = objPaymentFormConfiguration.HDFC_SALT__c;
                    }
                    
                    System.debug('CareerServiceOpted '+CareerServiceOpted+' CareerServicePackageName -->'+CareerServicePackageName+' applicableCareerServiceFee '+applicableCareerServiceFee+' ShowCareerServiceOpt '+ShowCareerServiceOpt);
                    if(CareerServiceOpted && applicableCareerServiceFee == 0 && ShowCareerServiceOpt ) {
                        System.debug('Enter in carrer service '+CareerServicePackageName);
                        if(String.isNotBlank(CareerServicePackageName)) {
                            applicableCareerServiceFee = mapOfPricebook.get(CareerServicePackageName).UnitPrice; 
                        } else {
                            applicableCareerServiceFee = mapOfPricebook.get('Career Development').UnitPrice;
                            CareerServicePackageName = 'Career Development';
                            System.debug('CareerServicePackageName after set-->'+CareerServicePackageName);
                        }
                    }
                    if(objCoursera.showCoursera && objCoursera.applicableCourseraFee == 0 && objCoursera.checkCourseraOpted) {
                        objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
                    }
                    System.debug('applicableCourseraFee--->'+objCoursera.applicableCourseraFee);
                    System.debug('liveLecType '+liveLecType +' courseList '+courseList);
                    if(String.isNotBlank(liveLecType) && liveLecType != 'No') {
                        Decimal totalSubjects = liveLecType=='Custom' && String.isNotBlank(courseList) ? courseList.split(',').size() : 0; 
                        System.debug('totalSubjects '+totalSubjects +'mapOfProductAndAmount.containsKey(liveLecType) '+mapOfProductAndAmount.containsKey(liveLecType)+'mapOfProductAndAmount.get(liveLecType) '+mapOfProductAndAmount.get(liveLecType));
                        applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(liveLecType) ? mapOfProductAndAmount.get(liveLecType) : 
                        (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
                    }
                    applicableBacklogFee = String.isNotBlank(backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
                    applicableLiveLectureFee = applicableOnlyLiveLectureFee + applicableBacklogFee;
                    system.debug('applicableLiveLectureFee-->'+applicableLiveLectureFee);
                    // objOnlinePayment.TranAmount = String.valueOf(mapOfProductAndAmount.containsKey(paymentFor) ? mapOfProductAndAmount.get(paymentFor) + applicableLateFee + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee')) : paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') : depositAmount );             
                    Decimal TransAmount = 0;
                    if(mapOfProductAndAmount.containsKey(paymentFor)) {
                        TransAmount = mapOfProductAndAmount.get(paymentFor) + applicableLateFee + applicableCareerServiceFee + applicableLiveLectureFee + objCoursera.applicableCourseraFee + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
                    } else {
                        TransAmount = paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') + applicableCareerServiceFee + objCoursera.applicableCourseraFee + (MergeAdmissionFeeWithRegistration ? mapOfProductAndAmount.get('Initial Payment') : 0) : depositAmount;
                    }
                    // Decimal TransAmount = mapOfProductAndAmount.containsKey(paymentFor) ? mapOfProductAndAmount.get(paymentFor) + applicableLateFee +applicableCareerServiceFee+applicableLiveLectureFee+objCoursera.applicableCourseraFee+ (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'))  : paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') +applicableCareerServiceFee+objCoursera.applicableCourseraFee+ (MergeAdmissionFeeWithRegistration ? mapOfProductAndAmount.get('Initial Payment') : 0): depositAmount ;
                    objOnlinePayment.TranAmount = String.valueOf(TransAmount.setScale(2));
                    system.debug('TranAmount--->'+objOnlinePayment.TranAmount);
                    system.debug('applicableCareerServiceFee--->'+applicableCareerServiceFee);
                    objOnlinePayment.postPaymentPage = objPaymentFormConfiguration.Post_Payment_VF_Page__c;
                    objOnlinePayment.IsReregistartion = IsReregistartion;
                    objOnlinePayment.depositAmount = depositAmount;
                    
                    DP_EMI_ProcessingFee = String.valueOf(depositAmount);
                    // Call Payment GateWay Option Based Upon Selected Option
                    return PaymentRequestCreator(objOnlinePayment,strTranTrackid); 
                }else{
                    errMessages = 'Unable to get payment details.';
                    strSecToShow = 'error';
                    return null;
                }
            }else{
                strSecToShow ='PopUpError';
                errMessages ='Hello Student, Kindly coordinate with NMIMS CDOE on 18001025136';
                String type = IsReregistartion ? 'reregistration' : 'registration';
                returnUrl ='/nmLogin_new?type='+type;
                return null;
            }
        }
    }
    
    /*-----------------------Payment Request Creator----------------------------------*/
    // Save Payment Reuest before Making Online Payment 
    // Based Upon selected Payment GateWay Option Create Secure Hash code for Online Payment
    public PageReference PaymentRequestCreator(nmOnlinePayment objOnlinePayment ,String strTranTrackid){
        System.debug('CareerServiceOpted check2 -->'+CareerServiceOpted);
        PaymentRequestParams objParams = new PaymentRequestParams();
        objParams.strTranTrackid = strTranTrackid;
        objParams.strPaymentType = objOnlinePayment.strPaymentType;
        objParams.paymentGatewayVersion = null;
        if(paymentGateWayName =='HDFC GateWay') {
            Map<String,String> mapOfParameters =objOnlinePayment.createHDFCDeskRequest();
            objParams.msg = mapOfParameters.get('msg');
            SavePaymentBeforeResponse(objParams);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            String md5HashData = Label.SECURE_SECRET;
            Blob hmacData = Crypto.generateDigest('MD5', Blob.valueOf(mapOfParameters.get('msg')));
            String checkSum = EncodingUtil.convertToHex(hmacData);
            pgURL.getParameters().put('test',mapOfParameters.get('msg'));
            mapOfParameters.remove('msg');
            mapOfParameters.remove('algo');
            mapOfParameters.remove('submit');
            for (String key : mapOfParameters.keySet()){
                pgURL.getParameters().put(key, mapOfParameters.get(key));
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            //pgURL.getParameters().put('secure_hash', checkSum.toUppercase());
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        }else if(paymentGateWayName =='BillDesk GateWay') {
            if (Label.BillDesk_GatewayVersion == 'v1') {
                String msg = objOnlinePayment.createtBillDeskRequest();            
                objParams.msg = msg;
                SavePaymentBeforeResponse(objParams);
                PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
                pgURL.getParameters().put('msg', msg);
                pgURL.getParameters().put('type', paymentGateWayName);
                return pgURL;
            } else if(Label.BillDesk_GatewayVersion == 'v2') {
                API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
                Map<String,Object> mapOfParameters = objOnlinePayment.createtBillDeskRequestV2();
                System.debug('mapOfParameters --> ' + mapOfParameters);
                if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                    strSecToShow = 'PopUpError';
                    errMessages = 'Unable to get payment details.';
                    strSecToShow = 'error';
                    return null;
                }
                objParams.msg = JSON.serialize(mapOfParameters);
                objParams.orderId = (String)mapOfParameters.get('bdorderid');
                Map<String,Object> mapOfAdditionalInfo = (Map<String,Object>)mapOfParameters.get('additional_info');
                objParams.udf1 = (String)mapOfAdditionalInfo.get('additional_info1');
                objParams.udf2 = (String)mapOfAdditionalInfo.get('additional_info2');
                objParams.udf3 = (String)mapOfAdditionalInfo.get('additional_info3');
                objParams.paymentGatewayVersion = 'v2';
                SavePaymentBeforeResponse(objParams);
                List<Object> listOfLinks = (List<Object>)mapOfParameters.get('links');
                Map<String, Object> mapOfHeaders = (Map<String, Object>) listOfLinks[1];
                Map<String, Object> mapOfAuth = (Map<String, Object>) mapOfHeaders.get('headers');
                PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
                pgURL.getParameters().put('type', 'BillDesk GateWay v2');
                pgURL.getParameters().put('merchantId', (String)mapOfParameters.get('mercid'));
                pgURL.getParameters().put('TranTrackid', (String)mapOfParameters.get('orderid'));
                pgURL.getParameters().put('bdOrderId', (String)mapOfParameters.get('bdorderid'));
                pgURL.getParameters().put('ru', (String)mapOfParameters.get('ru'));
                pgURL.getParameters().put('authToken', (String)mapOfAuth.get('authorization'));
                pgURL.getParameters().put('baseUrl', BilldeskV2.Base_Url__c);
                return pgURL;
            } else {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
        }else if(paymentGateWayName =='Razorpay GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createRazorPayOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.orderId = (String)mapOfParameters.get('id');
            objParams.paymentCurrency = (String)mapOfParameters.get('currency');
            objParams.udf1 = (String)mapOfParameters.get('udf1');
            objParams.udf2 = (String)mapOfParameters.get('udf2');
            objParams.udf3 = (String)mapOfParameters.get('udf3');
            SavePaymentBeforeResponse(objParams);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('orderId', (String)mapOfParameters.get('id'));
            pgURL.getParameters().put('amount', String.valueOf(mapOfParameters.get('amount')));
            pgURL.getParameters().put('Name', studentName);
            pgURL.getParameters().put('email', studentEmail);
            pgURL.getParameters().put('contact', studentMobileNo);
            pgURL.getParameters().put('type', paymentGateWayName);
            pgURL.getParameters().put('callback_url', (String)mapOfParameters.get('return_url'));
            pgUrl.getParameters().put('cancel_url',(String)mapOfParameters.get('return_url')+'?razorpay_order_id='+(String)mapOfParameters.get('id')+'&error[code]=PAYMENT_FAILED');
            pgURL.getParameters().put('currency', (String)mapOfParameters.get('currency'));

            return pgURL;
        }else if(paymentGateWayName == 'ICICI GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createICICIOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('type')) {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.msg = JSON.serialize(mapOfParameters);
            objParams.orderId = (String)mapOfParameters.get('order_token');
            objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            SavePaymentBeforeResponse(objParams);
            String paymentUrl = (String)mapOfParameters.get('payment_link');
            PageReference pgURL = new PageReference(paymentUrl);
            return pgURL;
        } 
        else {
            Map<String,String> mapOfParameters = objOnlinePayment.createPayTMRequest();
            objParams.msg = mapOfParameters.remove('msg');
            SavePaymentBeforeResponse(objParams);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            for (String key : mapOfParameters.keySet()){
                pgURL.getParameters().put(key, mapOfParameters.get(key));
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        }
    }
    
     /*-------------- Creating Payment Records before Payment --------------*/
    // Creating Payment Initiation Record Based Upon Selected Option (eg.Regisatrtion,Admission,PGAllSemFee,AnnualFee) for Future Reference
    public void SavePaymentBeforeResponse(PaymentRequestParams objParams){
        System.debug('objParams 2 ==>'+objParams);
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        Boolean checkForLiveLectures = false;
        System.debug('initaition strPaymentType -->'+objParams.strPaymentType);
        
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';
        objPayment.nm_Lead__c = IsReregistartion?null:recordId;
        objPayment.nm_OpportunityNew__c = IsReregistartion ? opportunityId:null;
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c = Date.today();
        objPayment.nm_PaymentGatewayName__c = paymentGateWayName;
        objPayment.nm_Merchant_Track_Id__c = objParams.strTranTrackid;
        objPayment.Additional_param1__c = objParams.udf1;
        objPayment.Additional_param2__c = objParams.udf2;
        objPayment.Additional_param3__c = objParams.udf3;
        objPayment.Payment_Gateway_Version__c = objParams.paymentGatewayVersion;
        if(String.isNotBlank(objParams.orderId)) {
            objPayment.OrderId__c = objParams.orderId;
        }
        objPayment.Gateway_Detailed_Request__c = objParams.msg;
        // objPayment.Opted_For_Career_Service__c = CareerServiceOpted;
        // String checkCareerserviceOpted = strPaymentType.substringAfterLast('_');
        System.debug('CareerServiceOpted check3 -->'+CareerServiceOpted);
        if(CareerServiceOpted)
        {
            applicableCareerServiceFee = mapOfPricebook.containsKey(CareerServicePackageName) && mapOfPricebook.get(CareerServicePackageName).UnitPrice>0?mapOfPricebook.get(CareerServicePackageName).UnitPrice:mapOfPricebook.get('Career Development').UnitPrice;
            System.debug('applicableCareerServiceFee -->'+applicableCareerServiceFee);
        }

        if(objCoursera.checkCourseraOpted) {
            objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
            System.debug('applicableCourseraFee -->'+objCoursera.applicableCourseraFee);
        }

        if(String.isNotBlank(liveLecType) && liveLecType != 'No') {
            Decimal totalSubjects = liveLecType=='Custom' && String.isNotBlank(courseList) ? courseList.split(',').size() : 0; 
            applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(liveLecType) ? mapOfProductAndAmount.get(liveLecType) : 
            (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
            checkForLiveLectures = true;
        }
        applicableBacklogFee = String.isNotBlank(backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
        applicableLiveLectureFee = applicableBacklogFee + applicableOnlyLiveLectureFee;
        System.debug('applicableLiveLectureFee-->'+applicableLiveLectureFee);
       
        //Start test for intiation 
        if(paymentFor == 'Registration'){
            if(MergeAdmissionFeeWithRegistration)
            {
                Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+mapOfProductAndAmount.get('Initial Payment') + applicableCareerServiceFee + objCoursera.applicableCourseraFee;
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,0,0,0,0) );
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('Initial Payment'),actualPaymentAmount, paymentFor ,0,0,0,0));
                if(CareerServiceOpted)
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
                if(objCoursera.checkCourseraOpted) {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
            } else {
                Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+applicableCareerServiceFee+objCoursera.applicableCourseraFee;
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,0,0,0,0) );
                if(CareerServiceOpted)
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
                if(objCoursera.checkCourseraOpted) {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
            }
        }else if(paymentFor.startsWith('Installment')){
            String InstallmentOption = paymentFor.split('-')[1];
            Decimal installmentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + applicableLiveLectureFee + objCoursera.applicableCourseraFee);
            if(!AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, InstallmentOption,0,0,0,0) );
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Installment' , installmentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, InstallmentOption,0,0,0,0) );
            }else{
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Installment' , installmentAmount , depositAmount, InstallmentOption,0,0,0,0) );
            }

            if(CareerServiceOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee,  installmentAmount, InstallmentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted) {
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, installmentAmount,InstallmentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Late Fees', applicableLateFee, installmentAmount, InstallmentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Live Lectures', applicableLiveLectureFee,  installmentAmount, InstallmentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }else if(paymentFor.contains('DownPayment')){
            String downPaymentOption = paymentFor.split('-')[1];
            Decimal downPaymentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + objCoursera.applicableCourseraFee);
            if(!AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, downPaymentOption ,0,0,0,0) );
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, LoanType+'-DownPayment' , downPaymentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, downPaymentOption,0,0,0,0) );
            }else{
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, LoanType+'-DownPayment' , downPaymentAmount , depositAmount, downPaymentOption ,0,0,0,0) );
            }

            if(CareerServiceOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee,  downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Late Fees', applicableLateFee, downPaymentAmount - applicableLiveLectureFee, downPaymentOption  ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            /*if(applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Live lecture', applicableLiveLectureFee,  depositAmount -  applicableLateFee - applicableCareerServiceFee - applicableLiveLectureFee, downPaymentOption ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee) );
            }*/
        }else if(paymentFor =='InitialAdmissionFee'){
            Decimal actualPaymentAmount = mapOfProductAndAmount.get('InitialAdmissionFee') + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
            if(!AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),(mapOfProductAndAmount.get(paymentFor) + mapOfProductAndAmount.get('Registration Fee')) , paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('InitialAdmissionFee'), actualPaymentAmount + applicableCareerServiceFee, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            
            if(CareerServiceOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee,  actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }else{
            if(!AlreadyPaidRegistrationFee){
                Decimal Amount = mapOfProductAndAmount.get('Registration Fee');
                Decimal paymentForAmount = mapOfProductAndAmount.get(paymentFor) + mapOfProductAndAmount.get('Registration Fee');
                if(Amount > 0) {
                    Amount = paymentForAmount < mapOfProductAndAmount.get('Registration Fee') ? paymentForAmount : Amount;
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Registration', Amount, paymentForAmount, paymentFor, applicableLateFee, applicableCareerServiceFee, applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                }
            }
            Decimal Amount2 = mapOfProductAndAmount.get(paymentFor);
            Decimal actualPaymentAmount = mapOfProductAndAmount.get(paymentFor) + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
            if(Amount2 > 0) {
                lstPaymentToInsert.add(CreatePaymentInitiatedRecord( objPayment, 'Admission', Amount2, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee));
            }
            if(CareerServiceOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Career Service', applicableCareerServiceFee, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Live Lectures', applicableLiveLectureFee, actualPaymentAmount, paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }

        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                insert lstPaymentToInsert;
            }
        }catch(Exception e){
            system.debug('------string.valueof(e)--------'+string.valueof(e));
        }
    }
    
    /*----------------Create Payment Initiation Record ------------------------------------------------*/
    // Method to Create Payment Initiation Record
    public nm_Payment_Initiated__c CreatePaymentInitiatedRecord(nm_Payment_Initiated__c objPayment, String PaymentType, Decimal Amount, Decimal paymentForAmount, String feesType, Decimal LateFeeAmount, Decimal CareerServicePrice, Decimal applicableLiveLectureFee, Decimal CourseraFee){
        nm_Payment_Initiated__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount + CareerServicePrice + applicableLiveLectureFee + CourseraFee;
        objPay.nm_Amount__c = Amount;
        objPay.nm_Fee_Type__c = feesType;
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = opportunityId;
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
            updateLoanDetails('Opportunity');
        }else{
            objPay.nm_Lead__c = recordId;
            updateLoanDetails('Lead');
        }
        return objPay;
    }
    
    public void updateLoanDetailsForSubvention(String typeOfObject,Decimal totalAmtPaid){
        if('Opportunity'.equalsIgnoreCase(typeOfObject)){
            if(objOpportunity.nm_Fee_Type__c!=null && objOpportunity.nm_Fee_Type__c!='' && objOpportunity.nm_Fee_Type__c != 'MBAallTermfee-Considered') {
                System.debug('paymentFor in updateLoanDetailsForSubvention '+paymentFor);
                if(String.isNotBlank(paymentFor) && paymentFor.contains('-')) {
                    String downPaymentPayFor = paymentFor.split('-')[1];
                    if(objOpportunity.nm_Fee_Type__c == 'MBAallTermfee' && downPaymentPayFor.equalsIgnoreCase('admission')){ // added due to fee type change from MBAallTermfee to admission
                        System.debug('can not update the fee type ');
                    }else{
                        objOpportunity.nm_Fee_Type__c = downPaymentPayFor;
                    }
                } else if(String.isNotBlank(paymentFor) && !paymentFor.contains('-')) {
                    objOpportunity.nm_Fee_Type__c = paymentFor;
                }
            }
            System.debug('objOpportunity.nm_Fee_Type__c ==>'+objOpportunity.nm_Fee_Type__c);
            objOpportunity.Down_Payment_Made__c = true;
            objOpportunity.Loan_Type__c = LoanType;
            objOpportunity.EMI_Amount__c = EMI;
            objOpportunity.Tenure__c = Tenure;
            objOpportunity.Interest_Rate__c = InterestRate;
            objOpportunity.DP_EMI_Processing_Fee__c =  String.valueOf(totalAmtPaid);  
            objOpportunity.Loan_Cancellation_Reason__c = '';
            objOpportunity.Loan_Application_Cancelled__c = false;
            System.debug('liveLecType  '+liveLecType +' courseList  '+courseList );
            if(String.isNotBlank(liveLecType)){
                objOpportunity.LiveLecturesType__c = liveLecType ;
                objOpportunity.CourseList__c = courseList  != 'null' ? courseList  : '';
            }
            objOpportunity.BacklogList__c = backlogList != 'null' ? backlogList : '';
            if(objOpportunity!=null){
                update objOpportunity;
            }
        }
        else if('Lead'.equalsIgnoreCase(typeOfObject)){
            objLead.Down_Payment_Made__c = true;
            objLead.Loan_Type__c = LoanType;
            objLead.EMI_Amount__c = EMI;
            objLead.Tenure__c = Tenure;
            objLead.Interest_Rate__c = InterestRate;
            objLead.DP_EMI_Processing_Fee__c = String.valueOf(totalAmtPaid);
            System.debug('liveLecType  '+liveLecType +' courseList  '+courseList );
            if(String.isNotBlank(liveLecType)){
                objLead.LiveLecturesType__c = liveLecType ;
                objLead.CourseList__c = courseList  != 'null' ? courseList  : '';
            }
            if(objLead!=null){
                update objLead;
            }
        }
    }


    public void updateLoanDetails(String typeOfObject){
       if('Opportunity'.equalsIgnoreCase(typeOfObject)){
            if(!objOpportunity.Down_Payment_Made__c){
                objOpportunity.Loan_Type__c = LoanType;
                System.debug('EMI----'+EMI);
                objOpportunity.EMI_Amount__c = EMI;
                objOpportunity.Tenure__c = Tenure;
                objOpportunity.Interest_Rate__c = InterestRate;
                objOpportunity.DP_EMI_Processing_Fee__c = DP_EMI_ProcessingFee;
                if(LoanType =='Capital Float'){
                    objOpportunity.Capital_Float_Processing_Fee__c = processingFee;
                }
                
                update objOpportunity;
            }
        }else if('Lead'.equalsIgnoreCase(typeOfObject)){
            if(!objLead.Down_Payment_Made__c){
                objLead.Loan_Type__c = LoanType;
                 System.debug('EMI----'+EMI);
                objLead.EMI_Amount__c = EMI;
                objLead.Tenure__c = Tenure;
                objLead.Interest_Rate__c = InterestRate;
                objLead.DP_EMI_Processing_Fee__c = DP_EMI_ProcessingFee;
                if(LoanType =='Capital Float'){
                    objLead.Capital_Float_Processing_Fee__c = processingFee;
                }
            }
            if(String.isNotBlank(TagPriceBookId)) {
                ID priceBookId = TagPriceBookId;
                objLead.nm_Tagged_Pricebook__c = priceBookId.to15();
            }
            update objLead;
        }
    }

    public String MakePaymentAfterResponse(PaymentHandler.PaymentResponseWrapper objResponse){
        System.debug('strResTranId ->'+objResponse.transactionId);
        System.debug('paymentTransactionMode ->'+objResponse.modeOfPayment);
        System.debug('strPaymentTrackId ->'+objResponse.merchantId);
        System.debug('strPaymentId ->'+objResponse.BankTXNId);
        System.debug('strResResult ->'+objResponse.status);
        System.debug('strErrorText ->'+objResponse.responseDescription);
        System.debug('strErrorCode ->'+objResponse.responseCode);
        System.debug('udf1 ->'+objResponse.udf1);
        System.debug('detailedGatewayResponse ->'+objResponse.detailedGatewayResponse);
        System.debug('udf2 ->'+objResponse.udf2);
        System.debug('currencyOfPayment ->'+objResponse.currencyCode);
        System.debug('feeCharges ->'+objResponse.feeChrages);
        System.debug('tax ->'+objResponse.tax);
    
        try{
    
            //--------- List of payments to insert in System -------------
            list<nm_Payment_Initiated__c> lstPaymentInitaitedToUpdate = new list<nm_Payment_Initiated__c>();
            list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
            lstPaymentInitaitedToUpdate = [SELECT Id,nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c,
                nm_Amount__c,nm_ActualPaymentAmmount__c,nm_Lead__c,nm_PaymentGatewayName__c,nm_ModeOfPayment__c,
                nm_TransactionDate__c,nm_TransactionID__c,nm_Merchant_Track_Id__c,Online_Payment_Id__c,
                nm_PaymentGatewayResponse__c,Online_Response_Error__c,nm_Error_Code__c FROM nm_Payment_Initiated__c 
                WHERE nm_Merchant_Track_Id__c=:objResponse.merchantId AND nm_Amount__c>0];
            System.debug(lstPaymentInitaitedToUpdate.size());
            if(lstPaymentInitaitedToUpdate.size()<=0) {
                System.debug('Payment Record not found against merchant track Id ==>'+objResponse.merchantId);
                return 'Payment Details not found.';
            }
    
            paymentFor = objResponse.udf1.split('_')[0];
            String checkCareerserviceOpted = objResponse.udf2.split('_')[0];
            objCoursera.checkCourseraOpted = String.isNotBlank(objResponse.udf2.split('_')[3]) ? Boolean.valueOf(objResponse.udf2.split('_')[3]) : false;
            String LiveLecturesType = objResponse.udf2.split('_')[1];
            String courseListWithBacklogList = objResponse.udf2.split('_')[2];
    
            // To check and set Live Lecture details from the payment record.
            String CourseListpt = '';
            String BacklogListpt = '';
            List<String> lstCourseAndBacklog = new List<String>();
            if(String.isNotBlank(courseListWithBacklogList) && courseListWithBacklogList.contains('-')) {
                System.debug(courseListWithBacklogList);
                lstCourseAndBacklog = courseListWithBacklogList.split('-');
                if (lstCourseAndBacklog.size() == 2) {
                    CourseListpt = lstCourseAndBacklog[0];
                    BacklogListpt = lstCourseAndBacklog[1]; 
                } else if(lstCourseAndBacklog.size() == 1) {
                    CourseListpt = lstCourseAndBacklog[0];
                }
            } else if(String.isNotBlank(courseListWithBacklogList))  {
                CourseListpt = courseListWithBacklogList;
            }
    
            if(String.isNotBlank(LiveLecturesType) && LiveLecturesType != 'No') {
                liveLecType = LiveLecturesType;
                courseList = CourseListpt;
            }
            backlogList = String.isNotBlank(BacklogListpt) ? BacklogListpt : '';
            
            // To check career service opted or not
            if(checkCareerserviceOpted=='true')
            {
                applicableCareerServiceFee = mapOfPricebook.containsKey(CareerServicePackageName) && mapOfPricebook.get(CareerServicePackageName).UnitPrice>0?mapOfPricebook.get(CareerServicePackageName).UnitPrice:mapOfPricebook.get('Career Development').UnitPrice;
            }
            // to check coursera opted or not
            if(objCoursera.checkCourseraOpted) {
                objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
            }
    
            for(nm_Payment_Initiated__c objpay : lstPaymentInitaitedToUpdate) {
                objpay.nm_PaymentStatus__c = objResponse.status.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
                objpay.nm_TransactionID__c = objResponse.transactionId;
                objpay.payment_Transaction_Mode__c = objResponse.modeOfPayment;
                objpay.Online_Payment_Id__c = objResponse.BankTXNId;
                objpay.nm_PaymentGatewayResponse__c = objResponse.status;
                objpay.Online_Response_Error__c = objResponse.responseDescription;
                objpay.nm_Error_Code__c = objResponse.responseCode;
                // admissionTranscationDate = objpay.nm_TransactionDate__c;
                objpay.Gateway_Detailed_Response__c = objResponse.detailedGatewayResponse;
                lstPaymentToInsert.add(CreatePaymentRecordV2(objpay,objResponse));
            }
    
            Decimal totalAmountToCreate = 0;
            if(lstPaymentToInsert.size() > 0) {
                Boolean paymentMade = false;
                for (nm_Payment__c objPayment : lstPaymentToInsert) {
                    System.debug('Amount==>'+objPayment.nm_Amount__c);
                    totalAmountToCreate += objPayment.nm_Amount__c;
                    paymentMade = objPayment.nm_PaymentStatus__c == 'Payment Made' ? true : false;
                }
    
                if(totalAmountToCreate!=objResponse.depositAmount) {
                    System.debug('Payment amount mismatch with the amount recieved merchant track Id ==>'+objResponse.merchantId);
                    System.debug('Total Amount to be created ==>'+totalAmountToCreate);
                    System.debug('Total Amount Recieved ==>'+objResponse.depositAmount);
                    String PaymentGatewayName = lstPaymentToInsert[0].nm_PaymentGatewayName__c;
                    Date transactionDate = lstPaymentToInsert[0].nm_TransactionDate__c;
                    lstPaymentToInsert = new list<nm_Payment__c>();
                    lstPaymentToInsert.add(CreatePaymentRecordV3(objResponse,transactionDate,PaymentGatewayName));
                    // return 'Payment Details not found.';
                }
    
                String feeType = String.isNotBlank(paymentFor) && paymentFor.contains('-') ? paymentFor.split('-')[1] : paymentFor;
                if(String.isNotBlank(opportunityId) && opportunityId != 'NA' && paymentMade){
                    System.debug('Opportunity update ==>'+opportunityId);
                    updateOpportunityFeesType(opportunityId,feeType,applicableCareerServiceFee);
                    /// add for account/opportunity
                    ChangeToDownPayment('Opportunity', opportunityId, feeType, paymentFor);
                    
                } else if(paymentMade){
                    System.debug('Lead update ==>'+recordId);
                    updateLeadFeeType(recordId,feeType);

                    /// add here for lead
                    ChangeToDownPayment('Lead', recordId, feeType, paymentFor);
                    
                }
            }
            
            if(lstPaymentInitaitedToUpdate.size() > 0){
                update lstPaymentInitaitedToUpdate;
            }
            
            String firstPaymentRecordId = '';
        
            //----upserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                //avoid multiple payment records being created for same merchant ID, for Browser back button press 
                firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
            }
            
            if(objResponse.status.toUpperCase() == 'CAPTURED'){
                if((String.isBlank(opportunityId) || opportunityId =='NA')){
                    UpdateLeadStatus(lstPaymentToInsert[0].nm_Lead__c,applicableCareerServiceFee,LiveLecturesType,CourseList);
                }
            } else {
                if((String.isBlank(opportunityId) || opportunityId =='NA')){
                    Lead lead = [SELECT Id,nm_Fee_Type__c,DP_EMI_Processing_Fee__c FROM Lead WHERE Id=:recordId];
                    lead.nm_Fee_Type__c ='';
                    if(!lead.Down_Payment_Made__c && !paymentFor.contains('DownPayment')){
                        lead.Loan_Type__c = null;
                        lead.EMI_Amount__c = '';
                        lead.Tenure__c = '';
                        lead.Interest_Rate__c = '';
                        lead.DP_EMI_Processing_Fee__c = '';
                    }
                    update lead;
                }else{
                    if(!objOpportunity.Down_Payment_Made__c && !paymentFor.contains('DownPayment')){
                        objOpportunity.Loan_Type__c = null;
                        objOpportunity.EMI_Amount__c = '';
                        objOpportunity.Tenure__c = '';
                        objOpportunity.Interest_Rate__c = '';
                        objOpportunity.DP_EMI_Processing_Fee__c = '';
                        update objOpportunity;
                    }
                }
            }
            return firstPaymentRecordId;
        }catch(Exception e){
            return 'Failed to insert data in system :: Sumit ::' + String.valueof(e); 
        }
    }


    public void ChangeToDownPayment(String objtype , String recordId, String feeType, String paymentFor){

        
        //'Pending Payment - Loan'
        if(paymentFor.contains('DownPayment')){
            List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
            List<nm_Payment__c> lstPaymentforupdate = new List<nm_Payment__c>();
            String paymenttypeLocal = '';
            String InstallmentPaymentRef = '';
        
            if(objtype == 'Lead'){
                paymenttypeLocal =  objLead.Loan_Type__c+'-DownPayment'; 
                InstallmentPaymentRef =	'DownPayment-'+feeType;
                lstPayment = [SELECT Id,nm_PaymentType__c, nm_Installment_Payment_Ref__c FROM nm_Payment__c where  nm_Lead__c =: recordId AND nm_PaymentType__c In ('Installment','Initial Payment') AND nm_PaymentStatus__c In ('Payment Approved', 'Payment Made')];
            }
            else if(objtype == 'Opportunity'){
                paymenttypeLocal = objOpportunity.Loan_Type__c+'-DownPayment'; 
                InstallmentPaymentRef =	'DownPayment-'+feeType;
                lstPayment = [SELECT Id,nm_PaymentType__c, nm_Installment_Payment_Ref__c FROM nm_Payment__c where  nm_OpportunityNew__c =: recordId AND nm_PaymentType__c In ('Installment','Initial Payment') AND nm_PaymentStatus__c In ('Payment Approved', 'Payment Made')];
            }

            if(lstPayment.size() > 0){
                for(nm_Payment__c payobj : lstPayment){
                    payobj.nm_PaymentType__c = paymenttypeLocal;
                    payobj.nm_Installment_Payment_Ref__c = InstallmentPaymentRef;
                    lstPaymentforupdate.add(payobj);
                }
            }

            if(lstPaymentforupdate.size() > 0){
                update(lstPaymentforupdate);
            }
            
        }


    }
    
    public nm_Payment__c CreatePaymentRecordV2(nm_Payment_Initiated__c objpay, PaymentHandler.PaymentResponseWrapper objResponse){
        nm_Payment__c objPayment = new nm_Payment__c();
        if(String.isNotBlank(opportunityId) && opportunityId !='NA'){
            objPayment.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            objPayment.nm_Lead__c = null;
        }else{
            objPayment.nm_Lead__c = ID.valueOf(recordId);
        }
        String paymentFor = objResponse.udf1.split('_')[0];
        objPayment.nm_PaymentStatus__c = objpay.nm_PaymentStatus__c;
        objPayment.nm_ModeOfPayment__c = objpay.nm_ModeOfPayment__c;
        objPayment.nm_TransactionDate__c = objpay.nm_TransactionDate__c; // making Payment Initation Created Date As Transction Date for Payment Record
        objPayment.nm_TransactionID__c = objpay.nm_TransactionID__c;
        objPayment.payment_Transaction_Mode__c = objpay.payment_Transaction_Mode__c;
        objPayment.nm_PaymentGatewayName__c = objpay.nm_PaymentGatewayName__c ;
        objPayment.nm_Merchant_Track_Id__c = objpay.nm_Merchant_Track_Id__c;
        objPayment.Online_Payment_Id__c = objpay.Online_Payment_Id__c;
        objPayment.nm_PaymentGatewayResponse__c = objpay.nm_PaymentGatewayResponse__c;
        objPayment.Online_Response_Error__c = objpay.Online_Response_Error__c;
        objPayment.nm_Error_Code__c = objpay.nm_Error_Code__c;
        objPayment.Fee_Charges__c = objResponse.feeChrages;
        objPayment.Tax__c = objResponse.tax;
        objPayment.nm_PaymentType__c = objpay.nm_PaymentType__c;
        objPayment.nm_ActualPaymentAmmount__c = objpay.nm_ActualPaymentAmmount__c;
        objPayment.nm_Amount__c = objpay.nm_Amount__c;
        objPayment.nm_Installment_Payment_Ref__c = paymentFor;
        objPayment.nm_Fee_Type__c = paymentFor;
        objPayment.Payment_Gateway_Version__c = objResponse.gatewayVersion;
        objPayment.Transaction_DateTime__c = objResponse.transactionDateTime;
        return objPayment;
    }

    public nm_Payment__c CreatePaymentRecordV3(PaymentHandler.PaymentResponseWrapper objResponse,Date transactionDate,String PaymentGatewayName){
        nm_Payment__c objPayment = new nm_Payment__c();
        if(String.isNotBlank(opportunityId) && opportunityId !='NA'){
            objPayment.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            objPayment.nm_Lead__c = null;
        }else{
            objPayment.nm_Lead__c = ID.valueOf(recordId);
        }
        String paymentFor = objResponse.udf1.split('_')[0];
        objPayment.nm_PaymentStatus__c = objResponse.status.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c = transactionDate; // making Payment Initation Created Date As Transction Date for Payment Record
        objPayment.nm_TransactionID__c = objResponse.transactionId;
        objPayment.payment_Transaction_Mode__c = objResponse.modeOfPayment;
        objPayment.nm_PaymentGatewayName__c = PaymentGatewayName;
        objPayment.nm_Merchant_Track_Id__c = objResponse.merchantId;
        objPayment.Online_Payment_Id__c = objResponse.BankTXNId;
        objPayment.nm_PaymentGatewayResponse__c = objResponse.status;
        objPayment.Online_Response_Error__c = objResponse.responseDescription;
        objPayment.nm_Error_Code__c = objResponse.responseCode;
        objPayment.Fee_Charges__c = objResponse.feeChrages;
        objPayment.Tax__c = objResponse.tax;
        objPayment.nm_PaymentType__c = 'Installment';
        objPayment.nm_ActualPaymentAmmount__c = objResponse.depositAmount;
        objPayment.nm_Amount__c = objResponse.depositAmount;
        objPayment.nm_Installment_Payment_Ref__c = 'Installment';
        objPayment.nm_Fee_Type__c = 'Installment';
        return objPayment;
    }

    /*-------------- Creating Payment Records after Payment --------------*/
    // This Method used to Handle Payment Response After Making Online Payment
    // Creating Payment Record with status of Payment made if transition is successfully 
    // Creating Payment Record with status of Transaction Failed if transition is failed
    // public String MakePaymentAfterResponse(
    //     String strResTranId,
    //     String paymentTransactionMode, 
    //     String strPaymentTrackId,
    //     String strPaymentId, 
    //     String strResResult, 
    //     String strErrorText,
    //     String strErrorCode,
    //     String strPaymentType,
    //     String detailedGatewayResponse,//Added by Sanket 13-Oct-2015
    //     //String PaymentSelectionOption // it can be Creadit card,Debit card ,Net Banking
    //     String additionalResult, // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
    //     String currencyOfPayment,
    //     Decimal feeCharges,
    //     Decimal tax
    // ){
    //     System.debug('strResTranId ->'+strResTranId);
    //     System.debug('paymentTransactionMode ->'+paymentTransactionMode);
    //     System.debug('strPaymentTrackId ->'+strPaymentTrackId);
    //     System.debug('strPaymentId ->'+strPaymentId);
    //     System.debug('strResResult ->'+strResResult);
    //     System.debug('strErrorText ->'+strErrorText);
    //     System.debug('strErrorCode ->'+strErrorCode);
    //     System.debug('strPaymentType ->'+strPaymentType);
    //     System.debug('detailedGatewayResponse ->'+detailedGatewayResponse);
    //     System.debug('additionalResult ->'+additionalResult);
    //     System.debug('currencyOfPayment ->'+currencyOfPayment);
    //     System.debug('feeCharges ->'+feeCharges);
    //     System.debug('tax ->'+tax);
    //     //--------- List of payments to insert in System -------------
    //     list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
    //     objCoursera.checkCourseraOpted = String.isNotBlank(additionalResult.split('_')[3]) ? Boolean.valueOf(additionalResult.split('_')[3]) : false;
    //     String checkCareerserviceOpted = additionalResult.split('_')[0];
    //     // String strRecordlive = strPaymentType.split('_')[1];
    //     String LiveLecturesType = additionalResult.split('_')[1];
    //     Boolean checkForLiveLectures = false;
    //     String courseListWithBacklogList = additionalResult.split('_')[2];
    //     // String CourseListpt = strPaymentType.split('_')[8];

    //     String CourseListpt = '';
    //     String BacklogListpt = '';
    //     List<String> lstCourseAndBacklog = new List<String>();
    //     if(String.isNotBlank(courseListWithBacklogList) && courseListWithBacklogList.contains('-')) {
    //         system.debug(courseListWithBacklogList);
    //         lstCourseAndBacklog = courseListWithBacklogList.split('-');
    //         if (lstCourseAndBacklog.size() == 2) {
    //             CourseListpt = lstCourseAndBacklog[0];
    //             BacklogListpt = lstCourseAndBacklog[1]; 
    //         } else if(lstCourseAndBacklog.size() == 1) {
    //             CourseListpt = lstCourseAndBacklog[0];
    //         }
    //     } else if(String.isNotBlank(courseListWithBacklogList))  {
    //         CourseListpt = courseListWithBacklogList;
    //     }
        
    //     Date admissionTranscationDate = null;
    //     System.debug('-----------strPaymentTrackId------------'+strPaymentTrackId);
        
    //     lstPaymentToUpdate = [Select Id, nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c,nm_Amount__c,nm_ActualPaymentAmmount__c, nm_Lead__c,nm_PaymentGatewayName__c , nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: strPaymentTrackId];
        
    //     System.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
    //     if(String.isNotBlank(LiveLecturesType) && LiveLecturesType != 'No') {
    //         Decimal totalSubjects = LiveLecturesType=='Custom' && String.isNotBlank(CourseListpt) ? CourseListpt.split(',').size() : 0; 
    //         applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(LiveLecturesType) ? mapOfProductAndAmount.get(LiveLecturesType) : 
    //         (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
    //         checkForLiveLectures = true;
    //         liveLecType = LiveLecturesType;
    //         courseList = CourseListpt;
    //     }
    //     backlogList = String.isNotBlank(BacklogListpt) ? BacklogListpt : '';

    //     applicableBacklogFee = String.isNotBlank(backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
    //     applicableLiveLectureFee = applicableBacklogFee + applicableOnlyLiveLectureFee;
    //     System.debug('applicableLiveLectureFee-->'+applicableLiveLectureFee);

    //     for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate) {
    //         objpay.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
    //         objpay.nm_TransactionID__c = strResTranId;
    //         objpay.payment_Transaction_Mode__c = paymentTransactionMode;
    //         objpay.Online_Payment_Id__c = strPaymentId;
    //         objpay.nm_PaymentGatewayResponse__c = strResResult;
    //         objpay.Online_Response_Error__c = strErrorText;
    //         objpay.nm_Error_Code__c=strErrorCode;
    //         admissionTranscationDate = objpay.nm_TransactionDate__c;
    //         objpay.Gateway_Detailed_Response__c = detailedGatewayResponse;//Added by Sanket 13-Oct-2015
    //        /* if('Admission'.equalsIgnoreCase(objpay.nm_PaymentType__c)) // checking Admission Trans Date for Inserting Late Fee Product
    //         {
    //             admissionTranscationDate = objpay.nm_TransactionDate__c;
    //         }*/
    //     }
        
    //     if(lstPaymentToUpdate.size() > 0 )
    //     {
    //         update lstPaymentToUpdate;
    //     }
        
    //     list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
    //     nm_Payment__c objPayment = new nm_Payment__c();
    //     objPayment.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
    //     if(String.isNotBlank(opportunityId) && opportunityId !='NA'){
    //         objPayment.nm_OpportunityNew__c = opportunityId;
    //     }else{
    //         objPayment.nm_Lead__c = recordId;
    //     }
        
    //     objPayment.nm_ModeOfPayment__c = 'Online';
    //     objPayment.nm_TransactionDate__c =lstPaymentToUpdate.size()>0 ? lstPaymentToUpdate[0].nm_TransactionDate__c : Date.today(); // making Payment Initation Created Date As Transction Date for Payment Record
    //     objPayment.nm_TransactionID__c = strResTranId;
    //     objPayment.payment_Transaction_Mode__c = paymentTransactionMode;
    //     objPayment.nm_PaymentGatewayName__c =lstPaymentToUpdate[0].nm_PaymentGatewayName__c ;
    //     objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
    //     objPayment.Online_Payment_Id__c = strPaymentId;
    //     objPayment.nm_PaymentGatewayResponse__c = strResResult;
    //     objPayment.Online_Response_Error__c = strErrorText;
    //     objPayment.nm_Error_Code__c=strErrorCode;
    //     objPayment.Fee_Charges__c = feeCharges;
    //     objPayment.Tax__c = tax;
        
    //     //*--------------------------Section to Avoid Cases where Payment Initation Record Created in 1st Late Fee Slab and Payment Record Created by Query API in 2nd Late Fee Slab with double amount then actual Payment Made by Student -----*//
    //     if(objPaymentFormConfiguration.Is_Late_Fee_Applicable__c && !isOpportunityProcessed){ 
    //         String lateFeeCategory = '';
    //         if(IsLateral && programType=='Admission'){
    //             lateFeeCategory = 'Is Lateral';
    //         }else{
    //             lateFeeCategory = programType;
    //         }
    //          Late_Fee__c objLateFees = new Late_Fee__c ();
    //         if(String.isNotBlank(programSpecialization)){
    //             objLateFees = productHelper.getLateBasedUponTransDateAndCategory(admissionTranscationDate,lateFeeCategory,programCategory,programSpecialization,currencyOfPayment ,currentAdmissionSession,currentAdmissionYear);
    //         }else{
    //             objLateFees = productHelper.getLateBasedUponTransDateAndCategory(admissionTranscationDate,lateFeeCategory,programCategory,currencyOfPayment ,currentAdmissionSession,currentAdmissionYear);
    //         }
    //     //    Late_Fee__c objLateFees = productHelper.getLateBasedUponTransDateAndCategory(admissionTranscationDate,lateFeeCategory,programCategory);
    //         decimal LateFeeAmt  = 0;
    //          System.debug('DaysPendingforInitialPayment-->'+DaysPendingforInitialPayment);
    //          //System.debug('InitialMBAWXFee--->'+InitialMBAWXFee);
    //         System.debug('totalamountreceived --->'+totalamountreceived );
    //         /* No Late feee for expire of initial payment
    //          if(DaysPendingforInitialPayment ==-1 && totalamountreceived < InitialMBAWXFee)
    //         {
    //             LateFeeAmt  += Decimal.valueOf(Label.InitialLatefeeExecutiveMBA).setScale(2);
               
    //         }*/
    //          if(DaysPendingforAdmissionPayment ==-1)
    //         {
    //             LateFeeAmt  += Decimal.valueOf(Label.AdmissionLatefeeMBAWX).setScale(2);
               
    //         }
    //         if(objLateFees !=null){
    //            LateFeeAmt  += objLateFees.Late_Fee_Amount__c;
    //         }
    //          System.debug('LateFeeAmt  -->'+LateFeeAmt );
    //         if( AlreadyPaidLateFeeAmount > 0){// checking if student already paid Late Fee Or Not
    //             // for Certificate Program Taking Late Fee with Service Tax
    //             if('Certificate Programs'.equalsIgnoreCase(programCategory)|| 'Executive Programs'.equalsIgnoreCase(programCategory)){
    //                 LateFeeAmt += (LateFeeAmt * Decimal.valueOf(Label.Service_Tax));
    //             }
    //             LateFeeAmt = LateFeeAmt - AlreadyPaidLateFeeAmount;
    //         }else if('Certificate Programs'.equalsIgnoreCase(programCategory)|| 'Executive Programs'.equalsIgnoreCase(programCategory)){
    //             LateFeeAmt += (LateFeeAmt * Decimal.valueOf(Label.Service_Tax));
    //         }
            
    //         if(LateFeeAmt < 0){// Late Fee Less than zero assign zero to Late Fee
    //             LateFeeAmt = 0;
    //         }
            
    //         applicableLateFee = LateFeeAmt;
    //     }
        
    //     paymentFor = strPaymentType.split('_')[0];
    //     DP_EMI_ProcessingFee = String.valueOf(depositAmount);
    //     System.debug('checkCareerserviceOpted '+checkCareerserviceOpted +' CareerServicePackageName '+CareerServicePackageName);
    //     if(checkCareerserviceOpted=='true')
    //     {
    //         applicableCareerServiceFee = mapOfPricebook.containsKey(CareerServicePackageName) && mapOfPricebook.get(CareerServicePackageName).UnitPrice>0?mapOfPricebook.get(CareerServicePackageName).UnitPrice:mapOfPricebook.get('Career Development').UnitPrice;
    //     }
    //     if(objCoursera.checkCourseraOpted) {
    //         objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
    //     }
    //     system.debug('applicableLiveLectureFee--->'+applicableLiveLectureFee+' applicableCareerServiceFee '+applicableCareerServiceFee);
    //     if(paymentFor == 'Registration'){
    //         if(MergeAdmissionFeeWithRegistration) {
    //             Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+mapOfProductAndAmount.get('Initial Payment') + applicableCareerServiceFee + objCoursera.applicableCourseraFee;
    //             lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             lstPaymentToInsert.add(CreatePaymentRecord(objPayment, 'Initial Payment', mapOfProductAndAmount.get('Initial Payment'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0));
    //             if(checkCareerserviceOpted=='true') {
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             }
    //             if(objCoursera.checkCourseraOpted) {
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             }
    //         } else {
    //             Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee') + applicableCareerServiceFee + objCoursera.applicableCourseraFee;
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             if(checkCareerserviceOpted=='true') {
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             }
    //             if(objCoursera.checkCourseraOpted) {
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
    //             }
    //         }
    //     } else if(paymentFor.startsWith('Installment')) {
    //         String InstallmentOption = paymentFor.split('-')[1];
    //         Decimal installmentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + applicableLiveLectureFee + objCoursera.applicableCourseraFee);
    //         if(!AlreadyPaidRegistrationFee){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, InstallmentOption ,paymentFor,0,0,0,0) );
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Installment' , installmentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, InstallmentOption ,paymentFor,0,0,0,0) );
    //         }else{
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Installment' , installmentAmount, depositAmount, InstallmentOption ,paymentFor,0,0,0,0) );
    //         }
            
    //         if(checkCareerserviceOpted == 'true'){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(objCoursera.checkCourseraOpted){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLateFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLiveLectureFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Live Lectures', applicableLiveLectureFee, installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //     } else if(paymentFor.contains('DownPayment')){
    //         String downPaymentOption = paymentFor.split('-')[1];
    //         Decimal downPaymentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + applicableLiveLectureFee + objCoursera.applicableCourseraFee);
    //         if(!AlreadyPaidRegistrationFee){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, downPaymentOption ,paymentFor ,0, 0,0,0) );
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, LoanType+'-DownPayment', downPaymentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, downPaymentOption ,paymentFor,0,0,0,0) );
    //         }else{
    //             Decimal paidAmount = depositAmount - applicableLateFee -applicableLiveLectureFee - applicableCareerServiceFee - objCoursera.applicableCourseraFee;
    //             if(paidAmount == 0) {
    //                 convertInstallmentToDownPayment(LoanType,paymentFor);
    //             }else {
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, LoanType+'-DownPayment' , downPaymentAmount, depositAmount, downPaymentOption ,paymentFor,0, 0,0,0) );
    //             }
    //         }
            
    //         if(checkCareerserviceOpted == 'true'){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(objCoursera.checkCourseraOpted){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLateFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //     } else if (paymentFor =='InitialAdmissionFee'){
    //         Decimal actualPaymentAmount = mapOfProductAndAmount.get('InitialAdmissionFee') + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
    //         if(!AlreadyPaidRegistrationFee){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),(mapOfProductAndAmount.get('Registration Fee') + mapOfProductAndAmount.get(paymentFor) ), paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('InitialAdmissionFee'), actualPaymentAmount, paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         if(checkCareerserviceOpted == 'true'){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount , paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(objCoursera.checkCourseraOpted){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , actualPaymentAmount , paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLateFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,paymentFor ,applicableLateFee,0,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //     }/*else if(paymentFor == 'RepeatTermFee') {
    //         lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Repeat Term Fee', mapOfProductAndAmount.get(paymentFor), mapOfProductAndAmount.get(paymentFor), paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee) );
    //     }*/else{
    //         if(!AlreadyPaidRegistrationFee){
    //             Decimal Amount = mapOfProductAndAmount.get('Registration Fee');
    //             Decimal paymentForAmount = mapOfProductAndAmount.get(paymentFor) + mapOfProductAndAmount.get('Registration Fee');
    //             if(Amount > 0) {
    //                 Amount = paymentForAmount < mapOfProductAndAmount.get('Registration Fee') ? paymentForAmount : Amount;
    //                 lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', Amount, paymentForAmount, paymentFor, paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //             }
    //         }
    //         Decimal Amount2 = mapOfProductAndAmount.get(paymentFor);
    //         Decimal actualPaymentAmount = mapOfProductAndAmount.get(paymentFor) + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
    //         if(Amount2 > 0) {
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Admission', Amount2, actualPaymentAmount, paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
            
    //         if(checkCareerserviceOpted == 'true'){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(objCoursera.checkCourseraOpted){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLateFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //         if(applicableLiveLectureFee > 0){
    //             lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Live Lectures', applicableLiveLectureFee, actualPaymentAmount, paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
    //         }
    //     }
    //     String firstPaymentRecordId = '';
    //     try{
    //         //----Inserting Payment records------//
    //         if( lstPaymentToInsert.size() > 0 ){
    //             //avoid multiple payment records being created for same merchant ID, for Browser back button press 
    //             firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
    //        }
            
    //         if(strResResult.toUpperCase() == 'CAPTURED'){
    //             if((opportunityId == null || opportunityId == '' || opportunityId =='NA')){
    //                 UpdateLeadStatus(lstPaymentToInsert[0].nm_Lead__c,applicableCareerServiceFee,LiveLecturesType,CourseList);
    //             }/*else{
    //                 if(String.isNotBlank(LiveLecturesType)){
    //                     System.debug('LiveLecturesType '+LiveLecturesType+' CourseList '+CourseList);
    //                     objOpportunity.LiveLecturesType__c = LiveLecturesType;
    //                     objOpportunity.CourseList__c = CourseList != 'null' ? CourseList : '';
    //                     //try {
    //                       //  update objOpportunity;
    //                   //  } catch (DMLException e) {
    //                        // System.debug('error '+e.getMessage());
    //                   //  }
    //                 }
                    
    //             }*/
    //         }
    //         else
    //         {
    //            if((opportunityId == null || opportunityId == '' || opportunityId =='NA')){
    //                 Lead lead = [Select Id, nm_Fee_Type__c,DP_EMI_Processing_Fee__c  from Lead where Id = : recordId ];
    //                 lead.nm_Fee_Type__c ='';
    //                 if(!lead.Down_Payment_Made__c && !paymentFor.contains('DownPayment')){// clear EMI selection 
    //                     lead.Loan_Type__c = null;
    //                     lead.EMI_Amount__c = '';
    //                     lead.Tenure__c = '';
    //                     lead.Interest_Rate__c = '';
    //                     lead.DP_EMI_Processing_Fee__c = '';
    //                 }
    //                 update lead;
    //             }else{
    //                 if(!objOpportunity.Down_Payment_Made__c && !paymentFor.contains('DownPayment')){
    //                     objOpportunity.Loan_Type__c = null;
    //                     objOpportunity.EMI_Amount__c = '';
    //                     objOpportunity.Tenure__c = '';
    //                     objOpportunity.Interest_Rate__c = '';
    //                     objOpportunity.DP_EMI_Processing_Fee__c = '';
    //                    update objOpportunity;
    //                 }
    //             }
    //         }
    //         return firstPaymentRecordId;
    //     }catch(Exception e){
    //         return 'Failed to insert data in system :: Sumit ::' + String.valueof(e); 
    //     }
    // }
    
    // Update Lead status based upon Fee Type
    public void UpdateLeadStatus(String Leadid,Decimal applicableCareerServiceFee,String LiveLecturesType,String CourseList)
    {
        Lead objLead=[select id,nm_PaymentStatus__c,Status,nm_Fee_Type__c,Career_Service__c,nm_Tagged_Pricebook__c  from Lead where id=:Leadid];
        if(applicableCareerServiceFee>0)
        {   if(String.isNotBlank(CareerServicePackageName)){
                objLead.Career_Service__c = CareerServicePackageName;   
            }else{
                objLead.Career_Service__c = 'Career Development';
            }
        }
        
       if(objLead!=null)
        {  
            if(String.isNotBlank(LiveLecturesType)){
                System.debug('LiveLecturesType '+LiveLecturesType+' CourseList '+CourseList);
                objLead.LiveLecturesType__c = LiveLecturesType;
                objLead.CourseList__c = CourseList != 'null' ? CourseList : '';
            }
          if(objLead.nm_Fee_Type__c =='Registration')
            {
            objLead.nm_PaymentStatus__c='Payment made';
            objLead.Status='Registration Fee Paid';
            /*if(checkCareerserviceOpted == 'true') {
                objLead.Career_Service__c = 'Career Development';
            }*/
            // update objLead;
            }
           else if('Admission'.equalsIgnoreCase(objLead.nm_Fee_Type__c) || 'FullFee'.equalsIgnoreCase(objLead.nm_Fee_Type__c) || 'AnnualFee'.equalsIgnoreCase(objLead.nm_Fee_Type__c)  || 'MultipleSemFee'.equalsIgnoreCase(objLead.nm_Fee_Type__c))
            {
                objLead.nm_PaymentStatus__c='Payment made';
                objLead.Status='Admission Fee Paid';
              /*  if(checkCareerserviceOpted == 'true') {
                    objLead.Career_Service__c = 'Career Development';
                }*/
                // update objLead;
             }
             
            if(String.isNotBlank(TagPriceBookId) && String.isBlank(objLead.nm_Tagged_Pricebook__c)) {
                ID priceBookId = TagPriceBookId;
                objLead.nm_Tagged_Pricebook__c = priceBookId.to15();
            }

            try {
                update objLead;
            } catch (DMLException e) {
                System.debug('Error '+e.getMessage());
            }
        }
    }
    
    public String upsertPaymentRecordsBasedOnMerchantNumber(list<nm_Payment__c> lstPaymentToInsert){
        System.debug('Method Of upsertPaymentRecordsBasedOnMerchantNumber called --->'+lstPaymentToInsert);
        list<nm_Payment__c> insertList = new List<nm_Payment__c>();
        list<nm_Payment__c> updateList = new List<nm_Payment__c>();
        String firstPaymentRecordId = '';
        
        Set<String> merchantRefNumberIds = new Set<String>();
        for(nm_Payment__c payment : lstPaymentToInsert){
            merchantRefNumberIds.add(payment.nm_Merchant_Track_Id__c);
        }
        
        Map<String, List<nm_Payment__c>> merchantIdVslstPayment = new Map<String, List<nm_Payment__c>>();
        list<nm_Payment__c> existingPayments = [SELECT id,nm_Merchant_Track_Id__c,nm_TransactionID__c,nm_PaymentType__c,nm_PaymentStatus__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c IN :merchantRefNumberIds];
        if(existingPayments.size() > 0){
            for(nm_Payment__c payment : existingPayments){
                List<nm_Payment__c> lstpay = merchantIdVslstPayment.containsKey(payment.nm_Merchant_Track_Id__c) ? merchantIdVslstPayment.get(payment.nm_Merchant_Track_Id__c) : new List<nm_Payment__c>();
                lstpay.add(payment);
                merchantIdVslstPayment.put(payment.nm_Merchant_Track_Id__c,lstpay);
            }
        }
        
        for(nm_Payment__c payment : lstPaymentToInsert){
            String key = payment.nm_Merchant_Track_Id__c;
            if(merchantIdVslstPayment.containsKey(key)){
                //Payment Record already exists with given Merchant Track Id 
                List<nm_Payment__c> lstpay = merchantIdVslstPayment.get(key);
                for(nm_Payment__c objPay : lstpay) {
                    if(objPay.nm_PaymentType__c == payment.nm_PaymentType__c && objPay.nm_PaymentStatus__c!='Payment Approved') {
                        payment.ID = objPay.ID;
                        updateList.add(payment);
                    }
                }
            }else{
                //New Record
                insertList.add(payment);
            }
        }
        
        if(insertList.size() > 0 ){
            System.debug('Adding new Payment record');
            insert insertList;
            firstPaymentRecordId = insertList[0].Id;
        }
        
        if(updateList.size() > 0 ){
            System.debug('Updating existing Payment record '+updateList);
            update updateList;
            firstPaymentRecordId = updateList[0].Id;
        }
        
        return firstPaymentRecordId;
    }
    
    // Create Online Pyament Record in system
    public nm_Payment__c CreatePaymentRecord( nm_Payment__c objPayment, String PaymentType, Decimal Amount, Decimal paymentForAmount,String feesType ,String InstallmentRef, Decimal LateFeeAmount, Decimal CareerServicePrice,Decimal applicableLiveLectureFee, Decimal CourseraFee){
        nm_Payment__c objPay =  new nm_Payment__c();
        objPay = objPayment.clone();
        
        objPay.nm_PaymentType__c = PaymentType;
        if(paymentForAmount !=null){
            objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount + CareerServicePrice + applicableLiveLectureFee + CourseraFee;
        }
        if(objPay.nm_ModeOfPayment__c != 'Online')
        {
            objPay.nm_PaymentStatus__c = 'Payment Made';
        }
        
        objPay.nm_Amount__c = Amount;
        objPay.nm_Installment_Payment_Ref__c = InstallmentRef;
        
        objPay.nm_Fee_Type__c = PaymentType;

        if(String.isNotBlank(opportunityId) && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            objPay.nm_Lead__c = null;
            if(objPay.nm_PaymentStatus__c == 'Payment Made'){
                updateOpportunityFeesType(opportunityId,feesType,CareerServicePrice);
            }
        }else{
           if(objPay.nm_PaymentStatus__c =='Payment Made'){
                System.debug('recordId '+recordId);
                objPay.nm_Lead__c = recordId ;
                updateLeadFeeType(recordId,feesType);
            }
        }
        
        if(objPay.nm_Amount__c>0) {
            return objPay;
        } else {
            return null;
        }
    }
    /*-----------------------------------------------------------------------DD Payment ------------------------------------------------*/
        public pageReference  SaveNEFT(){
            return null;
        }
   
    public pageReference  SaveDD(){
        System.debug('paymentFor---'+paymentFor);
        system.debug('CareerServiceOpted --->'+CareerServiceOpted );
        if(CareerServiceOpted) {
            applicableCareerServiceFee = mapOfPricebook.get('Career Development').UnitPrice;
        }
        if(objCoursera.checkCourseraOpted) {
            objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
        }
        if(String.isNotBlank(liveLecType) && liveLecType != 'No') {
            Decimal totalSubjects = liveLecType=='Custom' && String.isNotBlank(courseList) ? courseList.split(',').size() : 0; 
            applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(liveLecType) ? mapOfProductAndAmount.get(liveLecType) : 
            (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
           // checkForLiveLectures = true;
        }
        applicableBacklogFee = String.isNotBlank(backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
        applicableLiveLectureFee = applicableBacklogFee + applicableOnlyLiveLectureFee;
        System.debug('objPayment.nm_DemandDraftNumber__c---'+objPayment.nm_DemandDraftNumber__c);
        System.debug('objPayment.nm_DemandDraftDate__c---'+objPayment.nm_DemandDraftDate__c);
        System.debug('objPayment.nm_NameoftheBank__c---'+objPayment.nm_NameoftheBank__c);
        System.debug('objPayment.nm_DispatchDate__c---'+objPayment.nm_DispatchDate__c);

        DP_EMI_ProcessingFee = String.valueOf(depositAmount);
        list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();  
        if((((objLead.LC_name__c != objLead.IC_Name__c) && opportunityId ==null) || IsReregistartion || (opportunityId !=null) || 'Verizon'.equalsIgnoreCase(ICName)) && !'Counsellor'.equalsIgnoreCase(ICName)){
            if(objPayment.nm_DemandDraftNumber__c != null && objPayment.nm_DemandDraftDate__c != null && objPayment.nm_NameoftheBank__c != null && objPayment.nm_BankLocation__c != null && objPayment.nm_DispatchDate__c != null
            || objPayment.nm_TransactionID__c != null && objPayment.nm_TransactionDate__c != null){
                try{
                    system.debug('DD payment loop');
                    objPayment.nm_ModeOfPayment__c = objPayment.nm_DemandDraftNumber__c!=null && objPayment.nm_DemandDraftNumber__c!='' ?'Demand Draft':'NEFT';
                    if(paymentFor == 'Registration'){
                        if(MergeAdmissionFeeWithRegistration) {
                            Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+mapOfProductAndAmount.get('Initial Payment') + applicableCareerServiceFee + objCoursera.applicableCourseraFee;
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0 ) );
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('Initial Payment'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0 ) );
                            if(CareerServiceOpted) {
                                lstPaymentToInsert.add(CreatePaymentRecord ( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
                            }
                            if(objCoursera.checkCourseraOpted) {
                                lstPaymentToInsert.add(CreatePaymentRecord ( objPayment, 'Coursera', objCoursera.applicableCourseraFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
                            }
                        } else {
                            Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee') + applicableCareerServiceFee + objCoursera.applicableCourseraFee;
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
                            if(CareerServiceOpted) {
                                lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
                            }
                            if(objCoursera.checkCourseraOpted) {
                                lstPaymentToInsert.add(CreatePaymentRecord ( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount, paymentFor ,paymentFor,0,0,0,0) );
                            }
                        }
                    } else if(paymentFor.startsWith('Installment')) {
                        String InstallmentOption = paymentFor.split('-')[1];
                        Decimal installmentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + applicableLiveLectureFee + objCoursera.applicableCourseraFee);
                        if(!AlreadyPaidRegistrationFee){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, InstallmentOption ,paymentFor ,0,0,0,0) );
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Installment' , installmentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, InstallmentOption ,paymentFor,0,0,0,0) );
                        }else{
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Installment' , installmentAmount, depositAmount, InstallmentOption ,paymentFor,0,0,0,0) );
                        }
                        if(CareerServiceOpted){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(objCoursera.checkCourseraOpted){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(applicableLateFee > 0){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(applicableLiveLectureFee > 0){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Live Lectures', applicableLiveLectureFee, installmentAmount, InstallmentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }

                   }else if(paymentFor.contains('DownPayment')){
                        String downPaymentOption = paymentFor.split('-')[1];
                        Decimal downPaymentAmount = depositAmount - (applicableLateFee + applicableCareerServiceFee + objCoursera.applicableCourseraFee);
                        if(!AlreadyPaidRegistrationFee){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, downPaymentOption ,paymentFor ,0,0,0,0) );
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, LoanType+'-DownPayment' , downPaymentAmount - mapOfProductAndAmount.get('Registration Fee') , depositAmount, downPaymentOption ,paymentFor,0,0,0,0) );
                        }else{
                            Decimal paidAmount = depositAmount - applicableLateFee - applicableCareerServiceFee - objCoursera.applicableCourseraFee;
                            if(paidAmount == 0) {
                                convertInstallmentToDownPayment(LoanType,paymentFor);
                            }else {
                                lstPaymentToInsert.add(CreatePaymentRecord( objPayment, LoanType+'-DownPayment' , paidAmount, depositAmount, downPaymentOption ,paymentFor,0,0,0,0) );
                            }
                        }
                        if(CareerServiceOpted){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee , downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(objCoursera.checkCourseraOpted){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee , downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(applicableLateFee > 0){
                            lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, downPaymentAmount - applicableLiveLectureFee, downPaymentOption ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                    }else if(paymentFor =='InitialAdmissionFee'){
                        Decimal actualPaymentAmount = mapOfProductAndAmount.get('InitialAdmissionFee') + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
                        if(!AlreadyPaidRegistrationFee){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),(mapOfProductAndAmount.get('Registration Fee') + mapOfProductAndAmount.get(paymentFor)), paymentFor ,paymentFor,applicableLateFee,0,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('InitialAdmissionFee'), actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,0,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        if(applicableLateFee > 0){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,0,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(CareerServiceOpted){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee,  actualPaymentAmount, paymentFor ,paymentFor,0,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(objCoursera.checkCourseraOpted){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  actualPaymentAmount, paymentFor ,paymentFor,0,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                    }/*else if(paymentFor == 'RepeatTermFee') {
                        lstPaymentToInsert.add( CreateDDRecord( objPayment, 'Repeat Term Fee', mapOfProductAndAmount.get(paymentFor), mapOfProductAndAmount.get(paymentFor), paymentFor ,paymentFor ,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee ) );
                    }*/else{
                        system.debug('applicableLiveLectureFee--->' +applicableLiveLectureFee);
                        Decimal actualPaymentAmount = mapOfProductAndAmount.get(paymentFor) + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
                        if(!AlreadyPaidRegistrationFee){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),(mapOfProductAndAmount.get('Registration Fee') + mapOfProductAndAmount.get(paymentFor)), paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Admission', mapOfProductAndAmount.get(paymentFor), actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        if(applicableLateFee > 0){                 
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }

                        if(CareerServiceOpted){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Career Service', applicableCareerServiceFee,  actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee));
                        }
                        if(objCoursera.checkCourseraOpted){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  actualPaymentAmount, paymentFor ,paymentFor,0,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                        }
                        if(applicableLiveLectureFee>0){
                            lstPaymentToInsert.add(CreatePaymentRecord( objPayment, 'Live Lectures', applicableLiveLectureFee,  actualPaymentAmount, paymentFor ,paymentFor,applicableLateFee,applicableCareerServiceFee,applicableLiveLectureFee,objCoursera.applicableCourseraFee));
                        }
                    }
                    System.debug('lstPaymentToInsert--'+lstPaymentToInsert);
                    System.debug('opportunityId--'+opportunityId);
                    System.debug('applicableCareerServiceFee--'+applicableCareerServiceFee);
                    if(lstPaymentToInsert.size()>0 && !IsReregistartion){
                        insert lstPaymentToInsert;
                        if(opportunityId == null || opportunityId == '' ){
                            UpdateLeadStatus(lstPaymentToInsert[0].nm_Lead__c,applicableCareerServiceFee,liveLecType,courseList);
                        }
                        // String Uri = objSessionManager.updateSessionParams(Label.Site_Url+ 'nmRegistrationThankYou?id=' + lstPaymentToInsert[0].id,null);
                        String Uri = Label.Site_Url+ 'nmRegistrationThankYou?id=' + lstPaymentToInsert[0].id;
                        return new pageReference(Uri);
                    }else if(lstPaymentToInsert.size()>0){
                        insert lstPaymentToInsert;
                        // String Uri = objSessionManager.updateSessionParams(Label.Site_Url+ 'nmRegistrationReceipt?id=' + lstPaymentToInsert[0].id,null);
                        String Uri = Label.Site_Url+ 'nmRegistrationReceipt?id=' + lstPaymentToInsert[0].id;
                        return new pageReference(Uri);
                    }
                }catch(Exception e){
                    strSecToShow ='PopUpError';
                    errMessages = e.getMessage();
                    returnUrl ='';
                    return null;
                }
            }
        }else{
            strSecToShow ='PopUpError';
            errMessages ='Hello Student, Kindly coordinate with NMIMS CDOE on 18001025136';
            String type = IsReregistartion ? 'reregistration' : 'registration';
            returnUrl ='/nmLogin_new?type='+type;
            return null;
        }
        return null;
    }
    
    public nm_Payment__c createDownPaymentRecord(nm_Payment__c objPay){
        objDownPayment = new nm_Payment__c( id=objpay.id,
                                        nm_ActualPaymentAmmount__c=objpay.nm_ActualPaymentAmmount__c,
                                        nm_Installment_Payment_Ref__c=objpay.nm_Installment_Payment_Ref__c,
                                        nm_Merchant_Track_Id__c=objpay.nm_Merchant_Track_Id__c,
                                        nm_PaymentType__c=objPay.nm_PaymentType__c,
                                        nm_PaymentStatus__c=objpay.nm_PaymentStatus__c,
                                        nm_ModeOfPayment__c=objpay.nm_ModeOfPayment__c);
        return objDownPayment;
    }

    public pageReference proceedToDirectLoan(){

        String MerchantId='';
        Decimal totalAmountpaid =0.0;

        if(objDownPayment !=null){
            MerchantId = objDownPayment.nm_Merchant_Track_Id__c;
            totalAmountPaid = objDownPayment.nm_ActualPaymentAmmount__c;
            objDownPayment.nm_PaymentType__c= LoanType+'-DownPayment';
            objDownPayment.nm_Installment_Payment_Ref__c=paymentFor;
            update objDownPayment;
            
        }

        if( opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            updateLoanDetailsForSubvention('Opportunity',totalAmountPaid);
        }else{
             updateLoanDetailsForSubvention('Lead',totalAmountPaid);
        }
        

        if(String.isNotBlank(MerchantId)){
            PageReference pg = new PageReference('/apex/PostPaymentPage?ResTrackId='+MerchantId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public void convertInstallmentToDownPayment(String LoanType,string paymentFor){
        if(objDownPayment !=null){
            objDownPayment.nm_PaymentType__c= LoanType+'-DownPayment';
            objDownPayment.nm_Installment_Payment_Ref__c=paymentFor;
            update objDownPayment;
        }
    }

    public nm_Payment__c CreateDDRecord( nm_Payment__c objPayment , String PaymentType, decimal Amount , decimal paymentForAmount, String feesType,String InstallmentRef,decimal LateFeeAmount,decimal CareerServicePrice ,decimal applicableLiveLectureFee){
        nm_Payment__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount + CareerServicePrice + applicableLiveLectureFee;
        objPay.nm_Amount__c = Amount;
        objPay.nm_PaymentStatus__c = 'Payment Made';
        objPay.nm_Installment_Payment_Ref__c = InstallmentRef;
        
      /*  if(PaymentType == 'Registration' && objPay.nm_PaymentStatus__c =='Payment Made'){
            objPay.Receipt_Number__c  = generateRegistrationReceiptNo();
        }*/
        
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = opportunityId;
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
            updateOpportunityFeesType(opportunityId,feesType,CareerServicePrice);
        }else{
            objPay.nm_Lead__c = recordId;
            updateLeadFeeType(recordId,feesType);
        }
        
        return objPay;
    }
    
     public void updateOpportunityFeesType(String updateRecordId , String feesType,Decimal CareerServicePrice){
        // update Loan Information on Opportunity
        System.debug('objOpportunity.Down_Payment_Made__c--'+objOpportunity.Down_Payment_Made__c+'---LoanType--'+LoanType+' CareerServicePrice '+CareerServicePrice+ ' ' + paymentFor);
        if(paymentFor.contains('DownPayment')){
            objOpportunity.Down_Payment_Made__c = true;
        }
        // Career Service Section
        System.debug('CareerServicePrice ==>'+CareerServicePrice);
        if(CareerServicePrice > 0) {
            System.debug('CareerServicePackageName '+CareerServicePackageName);
            if(String.isNotBlank(CareerServicePackageName)){
                objOpportunity.Career_Service__c = CareerServicePackageName;   
            }else{
                objOpportunity.Career_Service__c = 'Career Development';
            }
        }
        if(objCoursera.checkCourseraOpted) {
            objOpportunity.Coursera__c = objCoursera.checkCourseraOpted;
        }
        // Live Lecture Section
        if(String.isNotBlank(liveLecType)){
            System.debug('liveLecType  '+liveLecType +' courseList  '+courseList );
            objOpportunity.LiveLecturesType__c = liveLecType ;
            objOpportunity.CourseList__c = courseList  != 'null' ? courseList  : '';
        }
        objOpportunity.BacklogList__c = backlogList != 'null' ? backlogList : '';
        system.debug('feesType-->'+feesType);
        System.debug('IsReregistartion--->'+IsReregistartion);
        System.debug('programCategory--->'+programCategory);
        system.debug('objOpportunity.Down_Payment_Made__c--'+objOpportunity.Down_Payment_Made__c);
        system.debug('objOpportunity.Career_Service__c--'+objOpportunity.Career_Service__c);
        String oppFeetype = '';
         if('Master Programs'.equalsIgnoreCase(programCategory) && !IsReregistartion
          && ('MBA (WX)'.equalsIgnoreCase(programSpecialization)
           ||  'MBA (X)'.equalsIgnoreCase(programSpecialization) 
           ||  'MBA - X'.equalsIgnoreCase(programSpecialization) 
           ||  ('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) && feesType !='AnnualFee' && feesType !='FullFee') ) ){
            // objOpportunity.nm_Fee_Type__c = 'MBAallTermfee';
            oppFeetype = 'MBAallTermfee';
            System.debug('objOpportunity.nm_Fee_Type__c---->'+objOpportunity.nm_Fee_Type__c);
        }
        if(objOpportunity.nm_Fee_Type__c !='' && objOpportunity.nm_Fee_Type__c !=null && objOpportunity.nm_Fee_Type__c.containsIgnoreCase('-Considered') && objOpportunity.nm_Fee_Type__c != 'MBAallTermfee'){
            // objOpportunity.nm_Fee_Type__c = feesType;
            oppFeetype = feesType;
        }else if(feesType =='AccountReRegistrationAdmission' || feesType =='ReRegistrationPayment'){
            // objOpportunity.nm_Fee_Type__c = 'Admission';
            oppFeetype = 'Admission';
        }else if(String.isBlank(oppFeetype)){
            oppFeetype = feesType; 
        }
        
        if(IsReregistartion && 'Admission'.equalsIgnoreCase(feesType)){
            // objOpportunity.nm_Fee_Type__c = 'ReRegistrationPayment'; 
            oppFeetype ='ReRegistrationPayment'; 
        }
        objOpportunity.nm_Fee_Type__c = oppFeetype; 
        System.debug('objOpportunity.nm_Fee_Type__c final '+objOpportunity.nm_Fee_Type__c);
        update objOpportunity;
        System.debug('objOpportunity----'+objOpportunity);
    }
    
    public void updateLeadFeeType(String leadId, String feesType){
        Lead lead = [Select Id, nm_Fee_Type__c,Loan_Type__c,DP_EMI_Processing_Fee__c ,Down_Payment_Made__c,EMI_Amount__c,Tenure__c,Interest_Rate__c,Capital_Float_Processing_Fee__c,Coursera__c from Lead where Id = : leadId];
        System.debug('feesType'+feesType);
        if(lead.nm_Fee_Type__c == 'AnnualFee' && feesType == 'registration'){
            System.debug('You can not update the fee type ');
        }else{
            lead.nm_Fee_Type__c = feesType;
        }
        if(objCoursera.checkCourseraOpted) {
            lead.Coursera__c = objCoursera.checkCourseraOpted;
        }
        if(!lead.Down_Payment_Made__c){
            if(paymentFor.contains('DownPayment')){
                lead.Down_Payment_Made__c = true;
            }
        }
        update lead;
    }
    //Method not in use
    public void getMapOfActiveCalender(){
        if(currentAdmissionSession !=null && currentAdmissionSession !='' && currentAdmissionYear !=null && currentAdmissionYear !=''){
            Decimal year = Decimal.valueOf(currentAdmissionYear);
            System.debug('CurrentAdmissionYear----'+year+'------currentAdmissionSession------'+currentAdmissionSession);
            String actvieCalenderQueryString = getQueryAllFieldSql('Calender__c',' Session_Start_Date__c <=:Today and Session__c =:currentAdmissionSession and Year__c =:year',null);
            list<Calender__c> lstActiveCalender = DataBase.query(actvieCalenderQueryString);
                                                    
            DateTime currentDateTime = DateTime.now();
            
            if(lstActiveCalender.size() > 0){
                for(Calender__c objCal : lstActiveCalender){
                    String key = objCal.Category__c+'-'+objCal.nm_Semester__c+'-'+objCal.nm_Type__c;
                    
                    if(objCal.Session_End_Date__c >= Date.today() && currentDateTime < objCal.Closed_Date__c){ // checking Current Date Time is greater then excepted Closed Date Time then show Closure Message 
                        mapOfActiveCalender.put(key,'Calender Live');
                    }else{
                        mapOfActiveCalender.put(key,objCal.Closure_Message__c);
                    }
                }
            }
        }
    }
    // written method to update Registration Receipt No after Payment Made:--Method transfer to Trigger
    public String generateRegistrationReceiptNo()
    {
         List<nm_Payment__c> lstMaxReceipt = new List<nm_Payment__c>();
         String year = string.valueof(System.now().year()).substring(2,4);
         String years = year+String.valueOf(integer.valueOf(year)+1);
         String maxNMATReceiptNo = 'SDLR-'+year+'000000000';
         
         lstMaxReceipt = [select id,Receipt_Number__c from nm_Payment__c where Receipt_Number__c!='' and nm_PaymentType__c = 'Registration' and Receipt_Number__c Like :('SDLR%') order by Receipt_Number__c desc limit 1];
         if(lstMaxReceipt.size()>0)
         {
            maxNMATReceiptNo = lstMaxReceipt[0].Receipt_Number__c;
         }
         Long uniqueNMATMaxNumber = Long.valueOf(maxNMATReceiptNo.split('-')[1]);
         uniqueNMATMaxNumber = uniqueNMATMaxNumber + 1; 
         return 'SDLR-'+uniqueNMATMaxNumber;
    }

    public Boolean checkSubventionSchemePrograms(String programSpecialization){

        String checkSubventionPrograms = System.Label.Subvention_Scheme_Programs;
        List<String> keys = checkSubventionPrograms.split(',');
        if(String.isNotBlank(programSpecialization) && JSON.serialize(keys).contains(programSpecialization))
        {
          return true;
        }
        return false;
    }

    /**
    * @description 
    * @author @BK | 14-08-2024 
    * @param string feetype 
    * @return Integer 
    **/
    public Integer getmultiplicationFactor(string feetype) {
        Integer multiFactor = 0;
        switch on feetype {
            when 'AnnualFee', '2SemFee', '2TermFee', 'AnnualFeeLoan' {
                multiFactor =2;
            }
            when '3SemFee', '3TermFee', 'MultiSemFee' {
                multiFactor =3;
            }
            when '4SemFee' {
                multiFactor =4;
            }
            when '5SemFee' {
                multiFactor =5;
            }
            when 'FullFee', 'FullFeeLoan' {
                multiFactor =4;
            }
            when else {
                multiFactor = 1;
            }
         }
        return multiFactor;
    }

    public pageReference logout() {
        String type = IsReregistartion ? 'reregistration' : 'registration';
        PageReference pg = new PageReference('/apex/nmLogin_new?type='+type);
        pg.setRedirect(true);
        return pg;
    }

    public void generateSessionChecksum(){
        if(String.isNotBlank(studentNo)){
            SessionChecksum = GetLoanDetailsService.generateChecksumForSession(studentNo);
        }else{
            System.debug('studentNo not found');
        }
    }
    //  public Boolean checkSubventionWith2PerSchemePrograms(String programSpecialization){

    //     String checkSubventionPrograms = System.Label.Subvention_With_18_by_2;
    //     List<String> keys = checkSubventionPrograms.split(',');
    //     if(String.isNotBlank(programSpecialization) && JSON.serialize(keys).contains(programSpecialization))
    //     {
    //       return true;
    //     }else{
    //         return false;
    //     }
    //     return false;
    // }

    /*  not is use to update record via page
    public List<SelectOption> getChooseProgram(){
   
       List<SelectOption> lstProgramOptions = new List<SelectOption>();
       Set<string> programtype = new Set<string>();
        List<nm_Program__c> lstPrograms = [select id,nmIsActive__c,nm_ProgramName__c,nm_Type__c from nm_Program__c where nmIsActive__c = true ];
        if(lstPrograms.size()>0)
        {
            for(nm_Program__c objprg:lstPrograms )
            {
                programtype.add(objprg.nm_Type__c);
            }
            for (String programtypelist:programtype )
            {
               lstProgramOptions.add(new SelectOption(programtypelist,programtypelist));
            }
        }
        return lstProgramOptions;
    }
     public List<SelectOption> getProgramsList(){
        List<SelectOption> lstProgramsOptions = new List<SelectOption>();      
        List<nm_Program__c> lstActiveProgram = [select id,nmIsActive__c,nm_ProgramName__c,nm_Type__c from nm_Program__c where nmIsActive__c = true and nm_Type__c=:programCategory];
        System.debug('lstActiveProgram--'+lstActiveProgram);
        if(lstActiveProgram.size() > 0){
            for(nm_Program__c objProgram : lstActiveProgram){
                lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
            }
        }
        return lstProgramsOptions;
    }
    public List<SelectOption> getEligiblityCriteriaList()
    {
        List<SelectOption> lstECOptions = new List<SelectOption>();
        List<nm_EligiblityCriteria__c> lstEC =[select id, Name, nm_EligiblityCriteria__c from nm_EligiblityCriteria__c where nm_Program__c=:programCategory]; 
            if(lstEC != null && lstEC.size() > 0)
            {
                for(nm_EligiblityCriteria__c objEC : lstEC)
                {
                        lstECOptions.add(new SelectOption(objEC.id, objEC.nm_EligiblityCriteria__c)); 
                }
            }
            return lstECOptions;
        }
      public PageReference UpdateDetail(){
        Double random = Math.random(); 
         if(opportunityId!=null && opportunityId!=''){               
                    objAccount.FirstName = FirstName;
                    objAccount.LastName = LastName;
                    objStudentProgram.nm_EligiblityCriteria__c = eligibility;
                    objStudentProgram.nm_Program__c = programName;
                    update objAccount;
                    update objStudentProgram;
                    
                    PageReference pgURL = new PageReference(System.Label.GoPayment_Url+'id='+recordId+'&OppsId='+opportunityId+'&random='+random);
                    pgURL.setRedirect(true);
                    return pgURL;
            }else{
                    objLead.nm_ChooseaProgram__c = programCategory;         
                    objLead.nm_Program__c = programName;
                    objLead.nm_EligiblityCriteria__c= eligibility ;
                    objLead.FirstName = FirstName;
                    objLead.LastName = LastName;            
                    update objLead;
                    
                    PageReference pgURL = new PageReference(System.Label.GoPayment_Url+'id='+recordId+'&random='+random);
                    pgURL.setRedirect(true);
                    return pgURL;
            }           
         }*/
    
    public void getBacklogDataFromStudentZone(String studentNo) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        map<String, Object> result = new Map<String, Object>();
        if(System.Label.Environment == 'Sandbox') {
            studentNo = '77121627861';
        }
        result.put('sapid', studentNo);
        String jsonString = System.JSON.serialize(result);
        Http http = new Http();
        String Uri = System.Label.Backlog_Api + 'exam/m/getPendingSubjectsForStudent';
        req.setEndpoint(Uri);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        System.debug('jsonString ==>' + jsonString);
        req.setBody(jsonString);
        try {
            resp = http.send(req);
            system.debug(resp);
            Integer statusCode = resp.getStatusCode();
            System.debug('statusCode = '+statusCode);
            if(statusCode == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                system.debug(responseBody.get('pendingSubjects'));
                List<Object> lstSubjectPending = (List<Object>)  responseBody.get('pendingSubjects');
                String message = (String)responseBody.get('message');
                if (responseBody.get('status') == 'Success') {
                    for (Object instance : lstSubjectPending){
                        Map<String , Object> backlogObject = (Map<String , Object> ) instance;
                        mapOfBacklogCourseIdVsBacklogObject.put((String)backlogObject.get('courseId'), instance);
                    }
                } 
            }
        }catch (Exception e) {
            System.debug(e);
        }

    }

    public class LiveLecturePayment {
        public Boolean AlreadyPaidLiveLectureFee {get;set;}
        public Decimal AlreadyPaidLiveLectureFeeAmount {get;set;}
        public String LiveLectureTypeOpted {get;set;}
        public String CourseList {get;set;}

        public LiveLecturePayment() {
            this.AlreadyPaidLiveLectureFee = false;
            this.AlreadyPaidLiveLectureFeeAmount = 0;
            this.LiveLectureTypeOpted = LiveLectureTypeOpted;
            this.CourseList = CourseList;
        }
    }
    
    public class Coursera {
        public Boolean isCourseraAlreadyOpted {get;set;} // is to check wheather the user already opted the Coursera
        public Boolean showCoursera {get;set;} // to check wheather the user is eligble for Coursera
        public Boolean checkCourseraOpted {get;set;} // to check if user selected coursera
        public Decimal applicableCourseraFee {get;set;}
        public Coursera() {
            this.isCourseraAlreadyOpted = false;
            this.showCoursera = false;
            this.checkCourseraOpted = false;
            this.applicableCourseraFee = 0;
        }
    }

    public class ReRegistration {
        public Decimal ReRegistrationAmount {get;set;}
        public Boolean isReRegistrationAmountChecked {get;set;}
        public ReRegistration() {
            this.ReRegistrationAmount = 0;
            this.isReRegistrationAmountChecked = false;
        }
    }

    public class AdmissionAmount {
        public Decimal admissionAmountPaid {get;set;}
        public Boolean isAdmissionAmountPaid {get;set;}
        public AdmissionAmount() {
            this.admissionAmountPaid = 0;
            this.isAdmissionAmountPaid = false;
        }
    }

    public class PaymentRequestParams {
        public String strPaymentType {get;set;}
        public String strTranTrackid {get;set;}
        public String msg {get;set;}
        public String orderId {get;set;}
        public String paymentCurrency {get;set;}
        public String udf1 {get;set;}
        public String udf2 {get;set;}
        public String udf3 {get;set;}
        public String paymentGatewayVersion {get;set;}
        public PaymentRequestParams() {
            this.strPaymentType = null;
            this.strTranTrackid = null;
            this.msg = null;
            this.orderId = null;
            this.paymentCurrency = 'INR';
            this.udf1 = null;
            this.udf3 = null;
            this.paymentGatewayVersion = null;
        }
    }
    
}