/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : @vickysahu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   10-07-2020   shubhranshu   Initial Version
**/
public class PostPaymentController
{
     //---- Stores error messages ---
    public string errMessages { get; set; }
    public string paymentTrackId{get;set;}  
    public string LeadId{get;set;}
    public String AccountId {get;set;}
    public String opportunityId {get;set;}
    public String validityExtensionId {get;set;}
    public String webinarRegid {get;set;}
    public boolean IsReRegistration {get;set;}
    public string paymentId{get;set;}
    public string paymentstatus {get;set;}
    public String semester {get;set;}
    public String recordId {get;set;}
    public Lead objLead {get;set;}
    public Career_Service_Program__c objcareer {get;set;}
    public String paymentType {get;set;}
    public boolean IsRegistrationPayment {get;set;}
    public boolean documentAvailable {get;set;}
    public String trackingLeadId {get;set;}

    public Opportunity objOpportunity {get;set;}
    public String studentNo {get;set;}
    public String careerservice {get;set;}
    public String cspackageid {get;set;}
    public String paymentmessage {get;set;}
    public Decimal totalsem {get;set;}

    public String programStructure {get;set;}
    public String courseList{get;set;}
    public String backlogList{get;set;}
    public String consumerType {get;set;}
    public String liveLecType {get;set;}
   
    //---- Zest Loan Application ---------//
    public String productAmount {get;set;}
    public decimal downPaymentAmount {get;set;}
    public decimal initialPayment {get;set;} // consider initial payment as Down Payment for Eexecutive Program
    public String OrderId {get;set;}
    public String DeliveryPostCode {get;set;}
    public String EmailAddress {get;set;}
    public String FullName {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String fatherName {get;set;}
    public String City {get;set;}
    public String AddressLine1 {get;set;}
    public String AddressLine2 {get;set;}
    public String MobileNumber {get;set;}
    public String CallbackUrlBase {get;set;}
    public boolean CustomerHasPriorPurchase  {get;set;}
    public String  Description  {get;set;}
    public String Quantity {get;set;}
    public decimal TotalPrice {get;set;}
    public String Category {get;set;}
    public String LoanType {get;set;}
    public Map<String,PriceBookEntry> mapOfPricebook {get;set;}
    public String programId {get;set;}
    public String TagPriceBookId {get;set;}
    public ProductHelper productHelper;
    public boolean IsDefence {get;set;}
    public String ICName {get;set;}
    public decimal ICProgramChangeAmount {get;set;}
    public decimal StudyKitAmount {get;set;}
    public String LateralStudentNo {get;set;}
    public String productName {get;set;}
    public decimal LateFeeAmount {get;set;}
    public decimal LateFeeAppliedAmount {get;set;}
    public decimal balanceAmount {get;set;}
    public String  zestLaonApplicationRequest {get;set;}
    public boolean zestLoanApplicationRequestCancelled {get;set;}
    public boolean zestDownPaymentDone {get;set;}
    public decimal zestLaonApplicationCancellationsCount {get;set;}
   
    // For EduVanz Loan Application
    public boolean EduVanzLoanApplicationRequestCancelled {get;set;}
    public boolean EduVanzDownPaymentDone {get;set;}
    public decimal EduVanzLaonApplicationCancellationsCount {get;set;}

    // For LiquiLoans Loan Application
    public boolean liquiLoanApplicationRequestCancelled {get;set;}
    public boolean liquiLoansDownPaymentDone {get;set;}
    public decimal liquiLoansLaonApplicationCancellationsCount {get;set;}

    // For EzCred Loan Application
    public boolean ezcredApplicationRequestCancelled {get;set;}
    public boolean ezcredDownPaymentDone {get;set;}
    public decimal ezcredLaonApplicationCancellationsCount {get;set;}

  //  For GrayQuest Loan Application
    public boolean grayQuestApplicationRequestCancelled {get;set;}
    public boolean grayQuestDownPaymentDone {get;set;}
    public decimal grayQuestLoanApplicationCancellationsCount {get;set;}
    public DateTime grayQuestLoanRejectionDate {get;set;}

    
    public String tenure {get;set;}
    public String interestRate {get;set;}

    //Student Loan id issue need to remove after done
    public String registrationNumber {get;set;}

    // For Propelld Loan Application
    public Integer propelldApplicationCourseFee {get;set;}

    public Date StudDob {get;set;}
    public String StudGender {get;set;}
    public String StudMarital_status {get;set;}
    public String lc_Name {get;set;}
    public String ic_Name {get;set;}
    public String prog_name {get;set;}

    public decimal downPaymentAmountOptional {get;set;}

    // --- Payment form Configuration ----//
    public String currentAdmissionYear {get;set;}
    public String programCategory {get;set;}
    public String programSpecialization  {get;set;}
    public String programName {get;set;}
    public String programType {get;set;}
    public List<String> setOfEmailReceiver {get;set;}
    public String paymentSuccessInstructions {get;set;}
    public String paymentErrorInstructions {get;set;}
    public Boolean loanSanctioned {get;set;}
    public Boolean loanApproved {get;set;}
    public Boolean isApplicant {get;set;}
    // check Record Type (Lead / opportunity)
    public String recordType {get;set;}
    // Session management
    // public Map<String,String> mapOfURLParameters { get;set; }
    // public SessionManager objSessionManager {get;set;}
    // public SessionManager.SessionUser objSessionUser {get;set;}
   
    public PostPaymentController()
    {
        productAmount = '0';
        downPaymentAmount = 0;
        downPaymentAmountOptional = 0;
        initialPayment = 0;
        cspackageid='';
        paymentmessage='';
        productHelper = new ProductHelper();
        LateFeeAmount  = 0;
        LateFeeAppliedAmount=0;
        balanceAmount = 0;
        totalsem = 0;
        OrderId = '';
        paymentstatus='';
        careerservice='';
        webinarRegid='';
        zestLaonApplicationCancellationsCount = 0;
        zestLaonApplicationRequest = '';
        zestLoanApplicationRequestCancelled = false;
        zestDownPaymentDone = false;

        registrationNumber = '';

        // For Eduvanz Loan Application
        EduVanzLaonApplicationCancellationsCount = 0;
        EduVanzLoanApplicationRequestCancelled = false;
        EduVanzDownPaymentDone = false;
       
        // For Liquiloans Loan Application
        liquiLoansLaonApplicationCancellationsCount = 0;
        liquiLoanApplicationRequestCancelled = false;
        liquiLoansDownPaymentDone = false;

        // For EzCred Loan Application
        ezcredLaonApplicationCancellationsCount = 0;
        ezcredApplicationRequestCancelled = false;
        ezcredDownPaymentDone = false;

        // For GrayQuest Loan application 
        grayQuestApplicationRequestCancelled =false;
        grayQuestDownPaymentDone = false;
        grayQuestLoanApplicationCancellationsCount =0;
        grayQuestLoanRejectionDate = null;

        tenure ='';
        interestRate = '';

        // For Liquiloans Loan Application
        propelldApplicationCourseFee = 0;

        StudDob =  null;
        StudGender ='';
        StudMarital_status ='';
        ic_Name ='';
        lc_Name ='';
        prog_name ='';

        DeliveryPostCode = '';
        EmailAddress = '';
        FullName = '';
        firstName = '';
        lastName = '';
        fatherName='';
        validityExtensionId = '';
        City = '';
        TagPriceBookId = null;
        AddressLine1 = '';
        AddressLine2 = '';
        MobileNumber = '';
        CallbackUrlBase = System.Label.Site_Url+'ZestMoneyThankYou';
        CustomerHasPriorPurchase  = false;
        Description  = '';
        Quantity = '1';
        TotalPrice = 0;
        Category = '';
        errMessages ='';
        studentNo = '';
        IsRegistrationPayment = false;
        LeadId = '';
        setOfEmailReceiver = new List<String>();
        paymentType = '';
        semester = '';
        recordId = '';
        paymentId = '';
        LoanType = '';
        opportunityId = '';
        AccountId  = '';
        IsReRegistration = false;
        paymentSuccessInstructions = '';
        paymentErrorInstructions = '';
        objLead = new Lead();
        objOpportunity = new Opportunity();
        ICProgramChangeAmount = 0;
        StudyKitAmount =0;
        ICName = '';
        IsDefence = false;
        programId = '';
        productName = '';
        programSpecialization  = '';
        programName = '';
        programStructure ='';
        consumerType='';
        liveLecType='';
        mapOfPricebook = new Map<String,PriceBookEntry>();
        recordType = '';
        paymentTrackId = ApexPages.currentPage().getParameters().get('ResTrackId');
        loanSanctioned = false;
        loanApproved = false;
        documentAvailable = false;
        isApplicant = true;
        trackingLeadId = '';
        // validate sessions
        // objSessionManager = new SessionManager();
        // objSessionUser = new SessionManager.SessionUser();
        // mapOfURLParameters = new Map<String,String>();
        // objSessionUser = objSessionManager.validateSession();
        // System.debug('objSessionjUser2 ==>'+objSessionUser);
        // if(objSessionUser.sessionVerified) { 
        //     mapOfURLParameters = objSessionUser.mapOfURLParameters;
        //     paymentTrackId = mapOfURLParameters.containsKey('ResTrackId') ? mapOfURLParameters.get('ResTrackId') : null;
        //     System.debug('paymentTrackId ==>'+paymentTrackId);
        // } else {
        //     errMessages = 'Session Expired, please Sign-In again to continue..';
        //     // String type = IsRegistrationPayment ? 'reregistration' : 'registration';
        //     // returnUrl ='/nmLogin_new?type='+type;
        // }

        if(String.isNotBlank(paymentTrackId))
        {
            GetPaymentDetails();
        }else{
            errMessages = 'Transaction Failed:No Track ID found in Request';
        }
    }
   
    /**
    * @description 
    * @author @BK | 16-11-2024 
    **/
    public void GetPaymentDetails()
    {
        Boolean checkForDownPaymentMade = false;
        String productNameHelper = '';
        String paymentSql = getQueryAllFieldSql('nm_Payment__c' , ' nm_Merchant_Track_Id__c =:paymentTrackId ','nm_OpportunityNew__r.Account.nm_StudentStatus__c,nm_OpportunityNew__r.Account.nm_LeadId__c' );

        List<nm_Payment__c> lstPayment = DataBase.query(paymentSql);
 
        if(lstPayment.size()>0)
        {
            for(nm_Payment__c objPayment : lstPayment)
            { 
                if(objPayment.nm_OpportunityNew__r.Account.nm_StudentStatus__c != 'De-Registered') {
                // if(2==2) {

                    LeadId = objPayment.nm_Lead__c;
                    trackingLeadId = objPayment.nm_Lead__c != null ? objPayment.nm_Lead__c : objPayment.nm_OpportunityNew__r.Account.nm_LeadId__c;
                    opportunityId = objPayment.nm_OpportunityNew__c ;
                    validityExtensionId = objPayment.Validity_Extension__c;
                    careerservice = objPayment.CareerServiceProgram__c;
                    webinarRegid = objPayment.Seminar__c;
    
                    paymentId = objPayment.id;
                    paymentType = objPayment.nm_PaymentType__c;
                    paymentstatus = objPayment.nm_PaymentStatus__c;    
                    paymentmessage = objPayment.Online_Response_Error__c != null ? objPayment.Online_Response_Error__c : 'Txn Successful';
                   
                    if(objPayment.nm_PaymentType__c =='Registration'){
                        IsRegistrationPayment = true;
                    }
                   
                    if(LeadId !=null && LeadId !=''){
                        QueryLeadData();
                        getInitialPaymentAmount('Lead');
                        recordId = LeadId;
                    }else if(opportunityId !=null && opportunityId != ''){
                        QueryOpportunityData();
                        getInitialPaymentAmount('Opportunity');
                    }else if(validityExtensionId !=null && validityExtensionId !=''){
                        QueryValidityExtension();
                    }else if (String.isNotBlank(careerservice)) {
                        QueryCareerServiceData();
                    }
    
                    if(objPayment.nm_PaymentType__c.contains('DownPayment')){
                        downPaymentAmount += objPayment.nm_Amount__c;
                        productName = objPayment.nm_Installment_Payment_Ref__c.split('-')[1];
                        Category = productName;
                    }else if(objPayment.nm_PaymentType__c.contains('Late Fees')){
                        LateFeeAmount += objPayment.nm_Amount__c;
                    }
                   
                    if(objPayment.nm_Installment_Payment_Ref__c != null && objPayment.nm_Installment_Payment_Ref__c.contains('DownPayment')) {
                        checkForDownPaymentMade = true;
                        productNameHelper = objPayment.nm_Installment_Payment_Ref__c.split('-')[1];
                    }
                     
                    if(objPayment.nm_PaymentStatus__c != 'Transaction Failed')
                    {
                        errMessages = null;
                    }else{
                   
                        if(objPayment.nm_Error_Code__c != null){
                            // errMessages = lstPayment[0].Online_Response_Error__c;  
                            if (objPayment.Online_Response_Error__c != null) {
                                errMessages = objPayment.Online_Response_Error__c;
                            } else {
                                errMessages = 'Transaction Failed';
                            }
                        }else{
                            errMessages = 'Invalid Authentication at Bank:NA:Canceled By User';
                        }
                    }
                }
            }

            if(String.isBlank(errMessages) && checkForDownPaymentMade && String.isBlank(Category) && downPaymentAmount==0){
                downPaymentAmount = downPaymentAmountOptional;
                productName = productNameHelper;
                Category = productName;
            }

        }else{
            errMessages = 'Transaction Failed:No Payment record found with given Track ID:'+paymentTrackId;
        }
       
        // for Executive Program InitialPayment present
        if(initialPayment > 0){
            downPaymentAmount +=initialPayment ;
        }
    }
   
    public void QueryLeadData()
    {
        String query = getQueryAllFieldSql('Lead',' id =:LeadId','nm_InformationCenter__r.ConsumerType__c,nm_Program__r.prgst__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.Loan_API_Code__c,nm_InformationCenter__r.Loan_API_Code__c,nm_InformationCenter__r.nm_LearningCenter__r.Loan_API_Code__c,nm_Program__r.Propelld_API_Code__c,nm_InformationCenter__r.Propelld_API_Code__c,nm_InformationCenter__r.Avanse_API_Code__c,nm_Program__r.AvanseAPICode__c,nm_InformationCenter__r.Contact_No_1__c,nm_InformationCenter__r.AEP_email_id__c,nm_InformationCenter__r.Name');
       
        System.debug('query-->'+query);
        List<Lead> lstLead = (List<Lead>) DataBase.query(query);
        if(lstLead.size()>0)
        {
            recordType = 'Lead';
            objLead = lstLead[0];
            documentAvailable = true;
            Semester = objLead.nm_Semester__c;
            IsDefence = objLead.Are_you_from_Defence__c =='Yes'?true:false;
            currentAdmissionYear = String.valueOf(objLead.nm_Year__c);
            programCategory = objLead.nm_ChooseaProgram__c;
            programType = 'Admission';
            studentNo = objLead.nm_RegistrationNo__c;
            String formConfigurationQuery = getQueryAllFieldSql('NM_Payment_Form_Configuration__c' , ' Current_Admission_Year__c =:currentAdmissionYear and Program_Category__c =:programCategory and Payment_Type__c =:programType','' );
            programId = objLead.nm_Program__c;
            programStructure = objLead.nm_Program__r.prgst__c;
            liveLecType = objLead.LiveLecturesType__c;
            courseList = objLead.CourseList__c;
            consumerType = objLead.nm_InformationCenter__r.ConsumerType__c;
            programCategory = objLead.nm_ChooseaProgram__c;
            ICName = objLead.IC_Name__c;
            programSpecialization  = objLead.Program_Type__c;  
            programName = objLead.nm_ProgramName__c;    
            totalsem = objLead.nm_Program__r.nm_TotalSemesters__c;
            LateralStudentNo = objLead.Student_Number_Lateral__c;
            zestLaonApplicationRequest = objLead.Zest_Loan_Application_Request__c;
            zestDownPaymentDone = objLead.Down_Payment_Made__c;
            tenure = objLead.Tenure__c;
            interestRate = objLead.Interest_Rate__c;
            loanSanctioned = objLead.Loan_Sanctioned__c;
            loanApproved = objLead.Loan_Approved__c;
            TagPriceBookId = objLead.nm_Tagged_Pricebook__c;


            if(String.isNotBlank(objLead.Loan_Type__c) && objLead.Loan_Type__c.contains('EduVanz')){
                EduVanzDownPaymentDone = objLead.Down_Payment_Made__c;
            }
           
            if(String.isNotBlank(objLead.Loan_Type__c) && objLead.Loan_Type__c.contains('LiquiLoans')){
                liquiLoansDownPaymentDone = objLead.Down_Payment_Made__c;
            }

            if(String.isNotBlank(objLead.Loan_Type__c) && objLead.Loan_Type__c.contains('EzCred')){
                ezcredDownPaymentDone = objLead.Down_Payment_Made__c;
            }
           if(String.isNotBlank(objLead.Loan_Type__c) && objLead.Loan_Type__c.contains('GrayQuest')){
              grayQuestDownPaymentDone = objLead.Down_Payment_Made__c;
           }

            // create Zest Loan Application Request
            createZestLoanApplicationRequest('Lead',null,objLead.nm_RegistrationNo__c);
           
            List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(formConfigurationQuery);
            if(lstFormConfiguration.size()>0)
            {
                NM_Payment_Form_Configuration__c objFormConfiguration = lstFormConfiguration[0];
                paymentSuccessInstructions = objFormConfiguration.Payment_Success_Instructions__c;
                TagPriceBookId = String.isBlank(TagPriceBookId) ? objFormConfiguration.Price_Book__c : TagPriceBookId;
                LoanType = objLead.Loan_Type__c;
                System.debug('LoanType ==>'+LoanType);
                if(objLead.Loan_Type__c !=null){
                    if(objLead.Loan_Type__c.contains('Capital Float')){
                        paymentSuccessInstructions = objFormConfiguration.Capital_Float_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('Zest')){
                        paymentSuccessInstructions = objFormConfiguration.Zest_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('EduVanz')){
                        paymentSuccessInstructions = objFormConfiguration.EduVanz_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('LiquiLoans')){
                        paymentSuccessInstructions = objFormConfiguration.LiquiLoans_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('Propelld')){
                        paymentSuccessInstructions = objFormConfiguration.Propelld_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('EzCred')){
                        paymentSuccessInstructions = objFormConfiguration.Ezcred_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('Avanse')){
                        paymentSuccessInstructions = objFormConfiguration.Avanse_Loan_Payment_Disclaimer__c;
                    }else if(objLead.Loan_Type__c.contains('GrayQuest')){
                        paymentSuccessInstructions = objFormConfiguration.GrayQuest_Loan_Payment_Disclaimer__c;
                    }
                }
                paymentErrorInstructions = objFormConfiguration.Payment_Error_Instructions__c;
                if(objFormConfiguration.Capital_Float_Invoice_Receiver_EmailId_s__c !=null){
                    setOfEmailReceiver = new List<String>(objFormConfiguration.Capital_Float_Invoice_Receiver_EmailId_s__c.split(','));
                }
            }    
        }
    }
    public void QueryCareerServiceData()
    {   
        String serviceprogramid;
        String query = getQueryAllFieldSql('Career_Service_Program__c',' id =:careerservice','');
         System.debug('query-->'+query);
        List<Career_Service_Program__c> lstcareer = (List<Career_Service_Program__c>) DataBase.query(query);
        if(lstcareer.size()>0)
        {
            isApplicant = false;
            objcareer = lstcareer[0];
            studentNo = objcareer.Student_Number_Of_Account__c;
            cspackageid = objcareer.CareerServiceProgram__c;
           
            /*String packagequery = getQueryAllFieldSql('Career_Service_Package__c',' id =:serviceprogramid','');
            System.debug('packagequery-->'+packagequery);
            List<Career_Service_Package__c> lstcareer = (List<Career_Service_Package__c>) DataBase.query(packagequery);
            */
           
            /*if(paymentstatus!='' && paymentstatus!=null)
            {
                callStudentzoneurl(paymentstatus);
            }*/
             
           
             
        }
    }
     
     public void getInitialPaymentAmount(String typeOfObject){
        initialPayment = 0;
        List<nm_Payment__c> lstInitialPaymentMade = new List<nm_Payment__c>();
        if('Lead'.equalsIgnoreCase(typeOfObject)){
            lstInitialPaymentMade = [select id,nm_Amount__c,nm_PaymentType__c from nm_Payment__c where (nm_PaymentStatus__c ='Payment Made' or nm_PaymentStatus__c ='Payment Approved') and nm_Lead__c =:LeadId];
        }else if('Opportunity'.equalsIgnoreCase(typeOfObject)){
            lstInitialPaymentMade = [select id,nm_Amount__c,nm_PaymentType__c from nm_Payment__c where (nm_PaymentStatus__c ='Payment Made' or nm_PaymentStatus__c ='Payment Approved') and nm_OpportunityNew__c =:opportunityId];
        }

        if(lstInitialPaymentMade !=null && lstInitialPaymentMade.size() > 0){
            for(nm_Payment__c objPayment : lstInitialPaymentMade ){
               if('Initial Payment'.equalsIgnoreCase(objPayment.nm_PaymentType__c) || 'Installment'.equalsIgnoreCase(objPayment.nm_PaymentType__c) || 'Additional Charge'.equalsIgnoreCase(objPayment.nm_PaymentType__c) ){
                    initialPayment += objPayment.nm_Amount__c;
                }
                if(objPayment.nm_PaymentType__c.contains('DownPayment')) {
                    downPaymentAmountOptional = objPayment.nm_Amount__c;
                }
            }
        }
    }
     
    public void QueryOpportunityData()
    {
        String query = getQueryAllFieldSql('Opportunity',' id =:opportunityId','nm_Program__r.nm_TotalSemesters__c,Account.nm_DateOfBirth__c,Account.nm_Centers__r.Propelld_API_Code__c,nm_Program__r.Propelld_API_Code__c,Account.nm_Centers__r.Avanse_API_Code__c,nm_Program__r.AvanseAPICode__c,Account.nm_Centers__r.AEP_email_id__c,Account.nm_Centers__r.Contact_No_1__c,Account.nm_Centers__r.Name');
        String accountQueryString = getQueryAllFieldSql('Account',' id=:AccountId and nm_Centers__c != null','nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c,nm_Program__r.Propelld_API_Code__c,nm_Centers__r.Propelld_API_Code__c');
       
        System.debug('query-->'+query);
        List<Opportunity> lstOpps = (List<Opportunity>) DataBase.query(query);
        if(lstOpps.size()>0)
        {
            recordType = 'Opportunity';
            objOpportunity = lstOpps[0];
            Semester = objOpportunity.nm_Semester__c;
            AccountId = objOpportunity.AccountId;
            totalsem = objOpportunity.nm_Program__r.nm_TotalSemesters__c;      
            programSpecialization  = objOpportunity.Specialisation__c;
            programName = objOpportunity.Program_Name__c;
            programId = objOpportunity.nm_Program__c;
            programStructure =  objOpportunity.Program_Structure__c;
            liveLecType = objOpportunity.LiveLecturesType__c;
            courseList = objOpportunity.CourseList__c;
            backlogList = objOpportunity.BacklogList__c;
            consumerType = objOpportunity.ConsumerType__c;
            tenure = objOpportunity.Tenure__c;
            interestRate = objOpportunity.Interest_Rate__c;
            loanSanctioned = objOpportunity.Loan_Sanctioned__c;
            loanApproved = objOpportunity.Loan_Approved__c;
           
            Account objAccount = new Account();
            List<Account> lstAccount = (List<Account>) DataBase.query(accountQueryString);
            if(lstAccount.size() > 0){
                programCategory = lstAccount[0].nm_ChooseaProgram__c;
                recordId = lstAccount[0].id;
                TagPriceBookId = lstAccount[0].nm_Tagged_Pricebook__c;
                objAccount = lstAccount[0];
                documentAvailable = objAccount.nm_StudentStatus__c=='Registered'|| objAccount.nm_StudentStatus__c=='Documents  Incorrect' || objAccount.nm_StudentStatus__c=='Document/s marked incorrect'?true:false;
                IsDefence = objAccount.nm_DefencePersonnel__c =='Yes'?true:false;
                ICName = lstAccount[0].IC_Name_1__c;
                LateralStudentNo = String.valueOf(lstAccount[0].Student_Number_Lateral__c);
                studentNo = lstAccount[0].nm_RegistrationNumber__c;
                if(lstAccount[0].nm_StudentNo__c != null) {
                    studentNo = lstAccount[0].nm_StudentNo__c+Semester;
                    isApplicant = false;
                }
                registrationNumber = lstAccount[0].nm_RegistrationNumber__c;
                system.debug('studentNo--->'+studentNo);
            }
           
            currentAdmissionYear = String.valueOf(objOpportunity.nm_year__c);
            zestLaonApplicationRequest = objOpportunity.Zest_Loan_Application_Request__c;
            zestLoanApplicationRequestCancelled = objOpportunity.Loan_Application_Cancelled__c;
            zestDownPaymentDone = objOpportunity.Down_Payment_Made__c;
            zestLaonApplicationCancellationsCount = objOpportunity.Loan_Application_Cancellations_Count__c !=null ? objOpportunity.Loan_Application_Cancellations_Count__c : 0;
           
            if(String.isNotBlank(objOpportunity.Loan_Type__c) && objOpportunity.Loan_Type__c.contains('EduVanz')){
                EduVanzLoanApplicationRequestCancelled = objOpportunity.Loan_Application_Cancelled__c;
                EduVanzDownPaymentDone = objOpportunity.Down_Payment_Made__c;
                EduVanzLaonApplicationCancellationsCount = objOpportunity.Loan_Application_Cancellations_Count__c !=null ? objOpportunity.Loan_Application_Cancellations_Count__c : 0;
            }
           
            if(String.isNotBlank(objOpportunity.Loan_Type__c) && objOpportunity.Loan_Type__c.contains('LiquiLoans')){
                liquiLoanApplicationRequestCancelled = objOpportunity.Loan_Application_Cancelled__c;
                liquiLoansDownPaymentDone = objOpportunity.Down_Payment_Made__c;
                liquiLoansLaonApplicationCancellationsCount = objOpportunity.Loan_Application_Cancellations_Count__c !=null ? objOpportunity.Loan_Application_Cancellations_Count__c : 0;
            }
            
            if(String.isNotBlank(objOpportunity.Loan_Type__c) && objOpportunity.Loan_Type__c.contains('EzCred')){
                ezcredApplicationRequestCancelled = objOpportunity.Loan_Application_Cancelled__c;
                ezcredDownPaymentDone = objOpportunity.Down_Payment_Made__c;
                ezcredLaonApplicationCancellationsCount = objOpportunity.Loan_Application_Cancellations_Count__c !=null ? objOpportunity.Loan_Application_Cancellations_Count__c : 0;
            }

            if(String.isNotBlank(objOpportunity.Loan_Type__c) && objOpportunity.Loan_Type__c.contains('GrayQuest')){
                  grayQuestApplicationRequestCancelled = objOpportunity.Loan_Application_Cancelled__c;
                  grayQuestDownPaymentDone = objOpportunity.Down_Payment_Made__c;
                  grayQuestLoanApplicationCancellationsCount = objOpportunity.Loan_Application_Cancellations_Count__c !=null ? objOpportunity.Loan_Application_Cancellations_Count__c : 0;
                  grayQuestLoanRejectionDate = objOpportunity.Loan_Rejection_Date__c;
           }


            programType = 'Admission';
            IsReRegistration = objOpportunity.Is_Re_Registration_Payment__c;
           
            // create Zest Loan Application Request
            createZestLoanApplicationRequest('Account',objAccount,studentNo);
           
            if(IsReRegistration){
                programType = 'Re-Registration';
            }
            LateFeeAppliedAmount =0;
            List<OpportunityLineItem> lstOpportunityLineItem =  [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:opportunityId];
           if(lstOpportunityLineItem.size() > 0){
                for(OpportunityLineItem objLineItem : lstOpportunityLineItem){
                    if(objLineItem.Product_Name__c.equalsIgnoreCase('Program Change Fee')){
                        ICProgramChangeAmount = objLineItem.UnitPrice ;
                         System.debug('ICProgramChangeAmount--->'+ICProgramChangeAmount );
                    }
                    if(objLineItem.Product_Name__c.equalsIgnoreCase('Student Kits') ){
                        StudyKitAmount =  objLineItem.UnitPrice ;
                         System.debug('StudyKitAmount --->'+StudyKitAmount );
                    }
                    if(objLineItem.Product_Name__c.equalsIgnoreCase('Late Fee'))
                    {
                        LateFeeAppliedAmount = LateFeeAppliedAmount + objLineItem.UnitPrice;
                    }
                }
                System.debug('LateFeeAppliedAmount--->'+LateFeeAppliedAmount);
                System.debug('ICProgramChangeAmount--->'+ICProgramChangeAmount );
            }
           
            String formConfigurationQuery = getQueryAllFieldSql('NM_Payment_Form_Configuration__c' , ' Current_Admission_Year__c =:currentAdmissionYear and Program_Category__c =:programCategory  and Payment_Type__c =:programType' ,'');
           
            List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(formConfigurationQuery);
            if(lstFormConfiguration.size()>0)
            {
                NM_Payment_Form_Configuration__c objFormConfiguration = lstFormConfiguration[0];
                paymentSuccessInstructions = objFormConfiguration.Payment_Success_Instructions__c;
                LoanType = objOpportunity.Loan_Type__c;
                System.debug('LoanType ==>'+LoanType);
                if(objOpportunity.Loan_Type__c !=null){
                    if(objOpportunity.Loan_Type__c.contains('Capital Float')){
                        paymentSuccessInstructions = objFormConfiguration.Capital_Float_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('Zest')){
                        paymentSuccessInstructions = objFormConfiguration.Zest_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('EduVanz')){
                        paymentSuccessInstructions = objFormConfiguration.EduVanz_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('LiquiLoans')){
                        paymentSuccessInstructions = objFormConfiguration.LiquiLoans_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('Propelld')){
                        paymentSuccessInstructions = objFormConfiguration.Propelld_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('EzCred')){
                        paymentSuccessInstructions = objFormConfiguration.Ezcred_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('Avanse')){
                        paymentSuccessInstructions = objFormConfiguration.Avanse_Loan_Payment_Disclaimer__c;
                    }else if(objOpportunity.Loan_Type__c.contains('GrayQuest')){
                        paymentSuccessInstructions = objFormConfiguration.GrayQuest_Loan_Payment_Disclaimer__c;
                    }
                    
                }
                paymentErrorInstructions = objFormConfiguration.Payment_Error_Instructions__c;
                if(objFormConfiguration.Capital_Float_Invoice_Receiver_EmailId_s__c !=null){
                    setOfEmailReceiver = new List<String>(objFormConfiguration.Capital_Float_Invoice_Receiver_EmailId_s__c.split(','));
                }
            }    
        }
    }
   
    public void QueryValidityExtension(){
        IsRegistrationPayment  = false;
        opportunityId = validityExtensionId;
        String formConfigurationQuery = getQueryAllFieldSql('NM_Payment_Form_Configuration__c' , ' id != null limit 1','' );
           
        List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(formConfigurationQuery);
        if(lstFormConfiguration.size()>0)
        {
            NM_Payment_Form_Configuration__c objFormConfiguration = lstFormConfiguration[0];
            paymentSuccessInstructions = objFormConfiguration.Payment_Success_Instructions__c;
            paymentErrorInstructions = objFormConfiguration.Payment_Error_Instructions__c;
        }
    }
           
  /*  public String getQueryAllFieldSql(String SObjectAPIName,String conditionString)
    {
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
       
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
       
        return query;
    }*/
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
   
    public PageReference downloadPaymentReceipt()
    {
        String paymentAcknowledgementUrl = '/apex/nmRegistrationThankYou?id='+LeadId;
        if(IsRegistrationPayment ){
            paymentAcknowledgementUrl = '/apex/nmThankYou?PaymentId='+paymentId;
        }else if(opportunityId !=null && opportunityId !=''){
            paymentAcknowledgementUrl = '/apex/nmRegistrationThankYou?PaymentId='+paymentId;
        }else if(webinarRegid!=null && webinarRegid!=''){
            paymentAcknowledgementUrl = '/apex/nmRegistrationThankYou?PaymentId='+paymentId;
        }else if(String.isNotBlank(paymentId)){
            paymentAcknowledgementUrl = '/apex/nmRegistrationThankYou?PaymentId='+paymentId;
        }
       
        // paymentAcknowledgementUrl = objSessionManager.updateSessionParams(paymentAcknowledgementUrl,null);
        PageReference pg = new PageReference(paymentAcknowledgementUrl);
        pg.setRedirect(true);
        return pg;
    }

    // public PageReference PrintForm() {
    //     String printPageUrl = '';
    //     if (IsReRegistration) {
    //         printPageUrl = '/apex/PrintReRegistrationForm?sem=' + semester + '&id=' + recordId;
    //     } else if (String.isNotBlank(opportunityId)) {
    //         printPageUrl = '/apex/nmPrintAdmissionForm?id=' + AccountId;
    //     } else {
    //         printPageUrl = '/apex/nm_PrintRegistrationForm?id='+recordId;
    //     }

    //     printPageUrl = objSessionManager.updateSessionParams(printPageUrl,null);
    //     PageReference pg = new PageReference(printPageUrl);
    //     pg.setRedirect(true);
    //     return pg;
    // }
   
   
    public void createZestLoanApplicationRequest(String typeOfObject,Account objAccount,String studentNo){
        if('Lead'.equalsIgnoreCase(typeOfObject)){
            OrderId = studentNo;
            DeliveryPostCode = objLead.PostalCode;
            EmailAddress = objLead.Email;
            FullName = objLead.FirstName +' '+objLead.LastName;
            fatherName =objLead.Father_Name__c;
            firstName = objLead.FirstName;
            lastName = objLead.LastName;
            City = objLead.City;
            AddressLine1 = objLead.nm_HouseNumber__c+','+objLead.nm_LocalityName__c+','+objLead.Street;
            AddressLine2 = objLead.state+','+objLead.Country;
            MobileNumber = objLead.MobilePhone;
            CallbackUrlBase = System.Label.Site_Url+'ZestMoneyThankYou';
            CustomerHasPriorPurchase  = false;
            Description  = productName+'_'+OrderId;
            Quantity = '1';
            // added new field for Eduvanz
            StudDob = objLead.nm_DateOfBirth__c;
            StudGender = objLead.nm_Gender__c;
            StudMarital_status = objLead.nm_MaritalStatus__c;
            lc_Name = '1';  // lc_name api code set to 1 for eduvanz
            ic_Name = objLead.nm_InformationCenter__r.Loan_API_Code__c;
            prog_name = objLead.nm_Program__r.Loan_API_Code__c;

        }else if('Account'.equalsIgnoreCase(typeOfObject)){
            OrderId = studentNo;
            DeliveryPostCode = objAccount.BillingPostalCode;
            EmailAddress = objAccount.PersonEmail;
            FullName = objAccount.FirstName +' '+objAccount.LastName;
            fatherName = objAccount.Father_Name__c;
            firstName = objAccount.FirstName;
            lastName = objAccount.LastName;
            City = objLead.City;
            AddressLine1 = objAccount.nm_HouseNumber__c+','+objAccount.nm_LocalityName__c+','+objAccount.BillingStreet;
            AddressLine2 = objAccount.Billingstate+','+objAccount.BillingCountry;
            MobileNumber = objAccount.PersonMobilePhone;
            CallbackUrlBase = System.Label.Site_Url+'ZestMoneyThankYou';
            CustomerHasPriorPurchase  = false;
            Description  = productName+'_'+OrderId;
            Quantity = '1';
            // added new field for Eduvanz
            StudDob = objAccount.nm_DateOfBirth__c;
            StudGender = objAccount.nm_Gender__c;
            StudMarital_status = objAccount.nm_MaritialStatus__c;
            lc_name = '1'; // lc_name api code set to 1 for eduvanz
            ic_Name = objAccount.nm_Centers__r.Loan_API_Code__c;
            prog_name = objAccount.nm_Program__r.Loan_API_Code__c;
        }
    }

    public PageReference ZestLoanApplicationRequest(){
        String newOrderId = null;
        String LoanId = null;
        // redirect student to same Zest Laon Application request if Already Zest Request Created .
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        if(String.isNotBlank(zestLaonApplicationRequest) && !zestLoanApplicationRequestCancelled){
            System.debug('Entered inside the Loan redirection');
            PageReference pg = new PageReference(zestLaonApplicationRequest);
            pg.setRedirect(true);
            return pg;
        }
        
       
        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(zestLoanApplicationRequestCancelled && zestDownPaymentDone){
            //create New Loan Order Id
            if(zestLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(zestLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            zestLaonApplicationCancellationsCount = zestLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(zestLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
        Boolean isSubventionScheme = false;
        if(String.isNotBlank(programSpecialization) && (programSpecialization == 'MBA (WX)' || programSpecialization == 'MBA (X)' || programSpecialization == 'MBA - X') && programCategory == 'Master Programs') {
            isSubventionScheme = String.isNotBlank(interestRate) && (InterestRate == '0' || InterestRate == '0.0') ? true : false;
        }
        // create Fresh Zest Loan Application Request if not Creted previously
        getTotalProductAmount();
        ZestWebService objZestWebService = new ZestWebService();
        String jsonString = objZestWebService.createNewLoanApplication(String.valueOf(TotalPrice),OrderId,DeliveryPostCode,EmailAddress,FullName,City ,AddressLine1,AddressLine2,MobileNumber ,CallbackUrlBase ,CustomerHasPriorPurchase ,0 ,OrderId,Description,Quantity,TotalPrice ,Category,isSubventionScheme);
        String responseString = '';
        if(jsonString !=null && jsonString !=''){
            Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(jsonString);
            /*
                sample Out Put for Loan Application
                // sample output
                {"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200"}
            */
           if(!mapOfResponseParameters.isEmpty()){
                for(String key : mapOfResponseParameters.keySet()){
                    System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    responseString = String.valueOf(mapOfResponseParameters.get('LogonUrl'));
                    System.PageReference pageReference = new System.PageReference(responseString);
                    Map<String,String> MapOfUrlParams = pageReference.getParameters();
                    LoanId = MapOfUrlParams.containsKey('LoanApplicationId') ? MapOfUrlParams.get('LoanApplicationId') : LoanId;
                }
            }
           
            if(LeadId !=null && LeadId !=''){
                objLead.Zest_Loan_Application_Request__c = responseString;
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.EduVanz_lead_id__c = LoanId;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();

                update objLead;
            }else if(opportunityId !='' && opportunityId !=null){
                objOpportunity.Zest_Loan_Application_Request__c = responseString;
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                objOpportunity.EduVanz_lead_id__c = LoanId;
                if(!String.IsBlank(newOrderId) && zestLoanApplicationRequestCancelled && zestDownPaymentDone && zestLaonApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = zestLaonApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
                }
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                update objOpportunity;
            }
           
            PageReference pg = new PageReference(responseString);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public PageReference propelldApplicationReqest() {
        String newOrderId = null;
        String recordId = LeadId;
        String objType = '';
        Double subventionValue = 0.0;
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        if(String.isNotBlank(zestLaonApplicationRequest) && !zestLoanApplicationRequestCancelled){
            PageReference pg = new PageReference(zestLaonApplicationRequest);
            pg.setRedirect(true);
            return pg;
        }

        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(zestLoanApplicationRequestCancelled && zestDownPaymentDone){
            //create New Loan Order Id
            if(zestLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(zestLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            zestLaonApplicationCancellationsCount = zestLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(zestLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
        CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=registration';
        if(String.isNotBlank(opportunityId) && objOpportunity.nm_Semester__c != '1') {
            CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=reregistration';
        }

        if(String.isNotBlank(opportunityId)){
            recordId = opportunityId;
        }
        // to get the center code and program code
        if(LeadId !=null && LeadId !=''){
            ic_Name = objLead.nm_InformationCenter__r.Propelld_API_Code__c;
            prog_name = objLead.nm_Program__r.Propelld_API_Code__c;
            objType = 'Lead';
            subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c,objLead.Interest_Rate__c);
            
        } else if(opportunityId !='' && opportunityId !=null) {
            ic_Name = objOpportunity.Account.nm_Centers__r.Propelld_API_Code__c;
            prog_name = objOpportunity.nm_Program__r.Propelld_API_Code__c;
            objType = 'Opportunity';
            subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c,objOpportunity.Interest_Rate__c);
        }
        
        getTotalProductAmount();
        PropelldWebService objPropelldWebService = new PropelldWebService();
        String jsonString = objPropelldWebService.createNewLoanApplication(OrderId,EmailAddress,firstName,lastName,MobileNumber,CallbackUrlBase,TotalPrice ,tenure,recordId,objType,propelldApplicationCourseFee,ic_Name,prog_name );
        String responseString = '';
        String quoteId = '';
        if(jsonString !=null && jsonString !=''){
            Map<String,Object> mapOfResponseParameters = (Map<String,Object>)JSON.deserializeuntyped(jsonString);
            if(!mapOfResponseParameters.isEmpty()){
                for(String key : mapOfResponseParameters.keySet()){
                    System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    responseString = String.valueOf(mapOfResponseParameters.get('RedirectionUrl'));
                    quoteId = String.valueOf(mapOfResponseParameters.get('QuoteId'));
                }
            }
           
            if(LeadId !=null && LeadId !=''){
                objLead.Zest_Loan_Application_Request__c = responseString;
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.EduVanz_lead_id__c = quoteId;
                objLead.Subvention_Value__c = subventionValue;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();
                update objLead;
            }else if(opportunityId !='' && opportunityId !=null){
                objOpportunity.Zest_Loan_Application_Request__c = responseString;
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                objOpportunity.EduVanz_lead_id__c = quoteId;
                if(!String.IsBlank(newOrderId) && zestLoanApplicationRequestCancelled && zestDownPaymentDone && zestLaonApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = zestLaonApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
                    
                }
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                objOpportunity.Subvention_Value__c = subventionValue;
                update objOpportunity;
            }
           
            PageReference pg = new PageReference(responseString);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public PageReference avanseApplicationReqest() {
        System.debug('Avanse');
        String newOrderId = null;
        String recordId = LeadId;
        String objType = '';
        Double subventionValue = 0.0;
        String programName = '';
        String aepEmail = '';
        String aepMobile = '';
        String aepName = '';
        String centerId = '';
        List<AvanseTenureScheme__mdt> lstAvanseScheme = new list<AvanseTenureScheme__mdt>();
        nm_Centers__c objCenter = new nm_Centers__c();
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        if(String.isNotBlank(zestLaonApplicationRequest) && !zestLoanApplicationRequestCancelled){
            PageReference pg = new PageReference(zestLaonApplicationRequest);
            pg.setRedirect(true);
            return pg;
        }

        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(zestLoanApplicationRequestCancelled && zestDownPaymentDone){
            //create New Loan Order Id
            if(zestLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(zestLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            zestLaonApplicationCancellationsCount = zestLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(zestLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
        // CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=registration';
        // if(String.isNotBlank(opportunityId) && objOpportunity.nm_Semester__c != '1') {
        //     CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=reregistration';
        // }
        if (OrderId.startsWith('0')) {
            OrderId = OrderId.substring(1);
          }

        if(String.isNotBlank(opportunityId)){
            recordId = opportunityId;
        }
        // to get the center code and program code
        if(LeadId !=null && LeadId !=''){
            ic_Name = String.isNotBlank(objLead.nm_InformationCenter__r.Avanse_API_Code__c) ? objLead.nm_InformationCenter__r.Avanse_API_Code__c : '';
            prog_name = objLead.nm_Program__r.AvanseAPICode__c;
            aepEmail = String.valueOf(objLead.nm_InformationCenter__r.AEP_email_id__c);
            aepMobile = objLead.nm_InformationCenter__r.Contact_No_1__c;
            aepName = objLead.nm_InformationCenter__r.Name;
            centerId = objLead.nm_InformationCenter__c;
            // programName = objLead.nm_Program__r.nm_ProgramName__c;
            objType = 'Lead';
            subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c,objLead.Interest_Rate__c);
            
        } else if(opportunityId !='' && opportunityId !=null) {
            ic_Name = String.isNotBlank(objOpportunity.Account.nm_Centers__r.Avanse_API_Code__c) ? objOpportunity.Account.nm_Centers__r.Avanse_API_Code__c : '';
            prog_name = objOpportunity.nm_Program__r.AvanseAPICode__c;
            aepEmail = String.valueOf(objOpportunity.Account.nm_Centers__r.AEP_email_id__c);
            aepMobile = objOpportunity.Account.nm_Centers__r.Contact_No_1__c;
            aepName = objOpportunity.Account.nm_Centers__r.Name;
            centerId = objOpportunity.Account.nm_Centers__c;
            aepMobile = String.isNotBlank(aepMobile) && aepMobile.startsWith('+91')	? aepMobile.replaceFirst('\\+91\\s*', '') : aepMobile;
            
            System.debug('Formatted Mobile Number: ' + aepMobile);
            // programName = objOpportunity.nm_Program__r.nm_ProgramName__c;
            objType = 'Opportunity';
            subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c,objOpportunity.Interest_Rate__c);
        }
        // AvanseWebService objAvanseWebService2 = new AvanseWebService();
        // Map<String,Object> mapOfResponseParameters = objAvanseWebService2.getListOfProgramCode(ic_Name,objType,recordId);
        // prog_name = getProgramCode(mapOfResponseParameters,programName);
        //get Loan Plan code
        String loanPlanCode = '';
        lstAvanseScheme = [SELECT MasterLabel,Tenure__c,LoanPlanCode__c,InterestRate__c FROM AvanseTenureScheme__mdt WHERE InterestRate__c=:interestRate AND Tenure__c=:tenure LIMIT 1];
        if (lstAvanseScheme.size() > 0) {
            loanPlanCode = lstAvanseScheme[0].LoanPlanCode__c;
        }
        else {
            System.debug('Avanse Loan Plan code is empty');
            return null;
        }
        getTotalProductAmount();
        AvanseWebService objAvanseWebService = new AvanseWebService();
        //AEP Code will be created if already not created.
        if (String.isBlank(ic_Name)) {
            Map<String,Object> mapOfResponseParameters = objAvanseWebService.createAEPCode(aepEmail,aepMobile,aepName);
            Map<String,Object> mapData = mapOfResponseParameters != null && (Boolean)mapOfResponseParameters.get('status') == true ? (Map<String,Object>)mapOfResponseParameters.get('data') : null;
            ic_Name = mapData != null ? (String)mapData.get('dsa_code') : '';
            objCenter.Id = centerId;
            objCenter.Avanse_API_Code__c = ic_Name;
        }
        // Map<String,Object> mapOfResponseParameters = objAvanseWebService.getListOfProgramCode(ic_Name,objType,recordId);
        // prog_name = getProgramCode(mapOfResponseParameters,programName);
        if (String.isBlank(ic_Name)) {
            return null;
        }
        AvanseResponseWrapper wrapper = objAvanseWebService.createNewLead(OrderId,EmailAddress,firstName,MobileNumber,TotalPrice,tenure,recordId,objType,loanPlanCode,ic_Name,prog_name);
        if(wrapper != null && wrapper.status == true){
            if(LeadId !=null && LeadId !=''){
                objLead.Zest_Loan_Application_Request__c = wrapper.data.link;
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.EduVanz_lead_id__c = wrapper.data.application_no;
                objLead.Subvention_Value__c = subventionValue;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();
                update objLead;
            }else if(opportunityId !='' && opportunityId !=null){
                objOpportunity.Zest_Loan_Application_Request__c = wrapper.data.link;
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                objOpportunity.EduVanz_lead_id__c = wrapper.data.application_no;
                if(!String.IsBlank(newOrderId) && zestLoanApplicationRequestCancelled && zestDownPaymentDone && zestLaonApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = zestLaonApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
                }
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                objOpportunity.Subvention_Value__c = subventionValue;
                update objOpportunity;
            }
            if (String.isNotBlank(objCenter.Id)) {
                update objCenter;
            }
           
            PageReference pg = new PageReference(wrapper.data.link);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    /*public String getProgramCode(Map<String,Object> mapOfResponseParameters,String programName) {
        String programCode = '';
        if (mapOfResponseParameters != null) {
            // List<Map<String, Object>> dataList = (List<Map<String, Object>>) mapOfResponseParameters.get('data');
            // for (Map<String,Object> data : dataList) {
            //     if (data.get('course_name') == programName) {
            //         programCode = (String) data.get('course_code');
            //     }
            // }
            List<Object> rawDataList = (List<Object>) mapOfResponseParameters.get('data');
            List<Map<String, Object>> dataList = new List<Map<String, Object>>();
            for (Object obj : rawDataList) {
                dataList.add((Map<String, Object>) obj);
            }
            for (Map<String,Object> obj : dataList) {
                if ((String) obj.get('course_name') == programName) {
                    programCode = (String) obj.get('course_code');
                }
                System.debug((String) obj.get('course_name'));
            }
        }
        return programCode;
    }*/

    public PageReference ezcredApplicationReqest() {
        String newOrderId = null;
        String recordId = LeadId;
        String objType = '';
        String ICAPICode = ic_Name;
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        
        // to avoid fields creaion for same logic used zest field
        if(String.isNotBlank(zestLaonApplicationRequest) && !ezcredApplicationRequestCancelled){
            PageReference pg = new PageReference(zestLaonApplicationRequest);
            pg.setRedirect(true);
            return pg;
        }

        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(ezcredApplicationRequestCancelled && ezcredDownPaymentDone){
            //create New Loan Order Id
            if(ezcredLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(ezcredLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            ezcredLaonApplicationCancellationsCount = ezcredLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(ezcredLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
        CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=registration';
        if(String.isNotBlank(opportunityId) && objOpportunity.nm_Semester__c != '1') {
            CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=reregistration';
        }

        if(String.isNotBlank(opportunityId)){
            recordId = opportunityId;
        }
        
        getTotalProductAmount();
        EzCredRequestWrapper ezcredReq = new EzCredRequestWrapper();
        EzCredRequestWrapper.cls_customer_information ezcredReqCustInfo = new EzCredRequestWrapper.cls_customer_information();
        EzCredRequestWrapper.cls_personal_information ezcredReqPerInfo = new EzCredRequestWrapper.cls_personal_information();
        EzCredRequestWrapper.cls_personal_details ezcredReqPerDet = new EzCredRequestWrapper.cls_personal_details();
        EzCredRequestWrapper.cls_phones ezcredPhones = new EzCredRequestWrapper.cls_phones();
        List<EzCredRequestWrapper.cls_phones> ezcredPhoneslst = new List<EzCredRequestWrapper.cls_phones>();
        EzCredRequestWrapper.cls_emails ezcredEmails = new EzCredRequestWrapper.cls_emails();
        List<EzCredRequestWrapper.cls_emails> ezcredEmailslst = new List<EzCredRequestWrapper.cls_emails>();
        EzCredRequestWrapper.cls_product_details ezcredProdDet = new EzCredRequestWrapper.cls_product_details();

        ezcredReq.partner_id = System.Label.Ezcred_Partner_Id;
        ezcredReq.partner_reference_id = OrderId;
        ezcredReq.partner_merchant_id = ICAPICode;
        
        ezcredReqPerInfo.first_name = firstName;
        ezcredReqPerInfo.last_name = lastName;
        ezcredReqPerDet.email = EmailAddress;
        ezcredReqPerInfo.personal_details = ezcredReqPerDet;
        ezcredReqCustInfo.personal_information = ezcredReqPerInfo;
        
        ezcredPhones.type = 'MOBILE';
        ezcredPhones.country_calling_code = '91';
        ezcredPhones.mnumber = MobileNumber;
        ezcredPhoneslst.add(ezcredPhones);
        ezcredReqCustInfo.phones = ezcredPhoneslst;

        ezcredEmails.type = 'WORK';
        ezcredEmails.email = EmailAddress;
        ezcredEmailslst.add(ezcredEmails);
        ezcredReqCustInfo.emails = ezcredEmailslst;

        ezcredReq.redirect_url = CallbackUrlBase;
        
        ezcredProdDet.type = 'PRIMARY';
        ezcredProdDet.category = 'Category';
        ezcredProdDet.price = Integer.valueOf(TotalPrice);

        ezcredReq.customer_information = ezcredReqCustInfo;
        ezcredReq.product_details = ezcredProdDet;
        
        String JsonStringReq = SYSTEM.JSON.serialize(ezcredReq);
        JsonStringReq  = JsonStringReq.replace('mnumber','number');
        // EzcredWebService ezcredService = new EzcredWebService();
        System.debug('JsonStringReq '+JsonStringReq+' recordId '+recordId+' recordType '+recordType);
        String jsonString = EzcredWebService.createLead(JsonStringReq,recordId,recordType);
        String responseString = '';
        String lead_number = '';
        System.debug('jsonString '+jsonString);
        if(jsonString !=null && jsonString !=''){
            Map<String,Object> mapOfResponseParameters = (Map<String,Object>)JSON.deserializeuntyped(jsonString);
            if(!mapOfResponseParameters.isEmpty()){
                for(String key : mapOfResponseParameters.keySet()){
                    System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    responseString = String.valueOf(mapOfResponseParameters.get('loan_link'));
                    lead_number = String.valueOf(mapOfResponseParameters.get('lead_number'));
                }
            }
           
            if(LeadId !=null && LeadId !=''){
                objLead.Zest_Loan_Application_Request__c = responseString;
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.EduVanz_lead_id__c = lead_number;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();
                update objLead;
            }else if(opportunityId !='' && opportunityId !=null){
                objOpportunity.Zest_Loan_Application_Request__c = responseString;
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                objOpportunity.EduVanz_lead_id__c = lead_number;
                if(!String.IsBlank(newOrderId) && ezcredApplicationRequestCancelled && ezcredDownPaymentDone && ezcredLaonApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = ezcredLaonApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
                }
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                update objOpportunity;
            }
            System.debug('responseString '+responseString);
            PageReference pg = new PageReference(responseString);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public PageReference EduVanzLoanApplicationRequest(){

        // EduVanzAPI__c objEduvanz = EduVanzAPI__c.getValues('Loan Application Data');  // custom setting for EduVanz Loan Application

        //  String ProgramAPICode = '41';
        Double subventionValue = 0.0;
        String ProgramAPICode = prog_name;
        String LCAPICode = lc_Name;
        //  String ICAPICode = '60';
        String ICAPICode = ic_Name;
        String newOrderId = null;
        String source_id='8';
        String StudentFullName='';
        String StudFirstName='';
        String StudLastName='';
        Integer genderCode=0;
        Integer marital_statusCode=0;
        String redirect_url= System.Label.EduVanz_Redirect_URL;
        system.debug('dsfds-->'+objLead.MobilePhone+' objdobbbb-->'+objLead.nm_DateOfBirth__c+' StudDob-->'+StudDob);
        String dob = DateTime.newInstance(StudDob.year(),StudDob.month(),StudDob.day()).format('yyyy-MM-dd');
        String Scheme_id = '1';
        system.debug('dob-->'+dob);
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        if(StudGender == 'Male'){
            genderCode=1;
        }
        else if(StudGender == 'Female') {
            genderCode=2;
        }
        else{
            genderCode=3;
        }

        if(StudMarital_status == 'Married'){
            marital_statusCode=1;
        }
        else if(StudMarital_status == 'Unmarried') {
            marital_statusCode=2;
        }

        if(String.isNotBlank(LeadId) && (objLead.Interest_Rate__c == '0' || objLead.Interest_Rate__c == '0.0')){
            Scheme_id = '2';
        }else if(String.isNotBlank(opportunityId) && (objOpportunity.Interest_Rate__c == '0' || objOpportunity.Interest_Rate__c == '0.0')){
            Scheme_id = '2';
        }

        System.debug('Scheme_id '+Scheme_id);
        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(EduVanzLoanApplicationRequestCancelled && EduVanzDownPaymentDone){
            //create New Loan Order Id
            if(EduVanzLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(EduVanzLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            EduVanzLaonApplicationCancellationsCount = EduVanzLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(EduVanzLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
       
         // redirect student to same EduVanz Laon Application request if Already EduVanz Request Created .
       
        getTotalProductAmount();
        if(String.isNotBlank(LeadId)){
            subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c,objLead.Interest_Rate__c);
        }

        if(String.isNotBlank(opportunityId)){
            subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c,objOpportunity.Interest_Rate__c);
        }

        if(String.isNotBlank(FullName)){
            StudentFullName= FullName;
            String[] str = StudentFullName.split(' ');
            StudFirstName = str[0];
            StudLastName = str[1];
        }

        String formDataURL='/apex/NM_Eduvanz_FormData?metaData='+OrderId+'&roll_no='+studentNo+'&userName='+System.Label.EduVanz_UserName+'&password='+System.Label.EduVanz_Password+'&loan_amount='+String.valueOf(TotalPrice)+'&first_name='+StudFirstName+'&last_name='+StudLastName+'&email_id='+EmailAddress+'&source_id='+source_id;
               formDataURL= formDataURL +'&mobile_number='+MobileNumber+'&institutes_id='+LCAPICode+'&insitutes_location_id='+ICAPICode+'&course_id='+ProgramAPICode+'&redirect_url='+redirect_url+'&scheme_id='+Scheme_id;
               formDataURL= formDataURL +'&dob='+dob+'&gender_id='+genderCode+'&marital_status='+marital_statusCode;
   
        if(LeadId !=null && LeadId !=''){
            System.debug('OrderId-->'+OrderId);
            objLead.Loan_Order_Id__c = OrderId;
            objLead.Loan_Amount__c = String.valueOf(TotalPrice);
            objLead.Subvention_Value__c = subventionValue;
            objLead.Student_Consent_Loan__c = true;
            objLead.Student_Consent_Loan_Date__c = DateTime.now();
            update objLead;
            PageReference pg = new PageReference(formDataURL);          
            pg.setRedirect(true);
            return pg;
         
        }else if(opportunityId !='' && opportunityId !=null){
            objOpportunity.Loan_Order_Id__c = OrderId;
            objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
            if(!String.IsBlank(newOrderId) && EduVanzLoanApplicationRequestCancelled && EduVanzDownPaymentDone && EduVanzLaonApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = EduVanzLaonApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
            }
            objOpportunity.Student_Consent_Loan__c = true;
            objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
            objOpportunity.Subvention_Value__c = subventionValue;
            update objOpportunity;
            PageReference pg = new PageReference(formDataURL);
            pg.setRedirect(true);
            return pg;
           
        }
        return null;
    }
    
    /**
    * @description 
    * @author @BK | 06-11-2024 
    * @return PageReference 
    **/
    public PageReference GrayQuestRequest() {
        Double subventionValue = 0.0;
        String newOrderId = null;
        String recordId = LeadId;       
        String ICAPICode = ic_Name;
        String prgName = programName;
        String dob = DateTime.newInstance(StudDob.year(),StudDob.month(),StudDob.day()).format('yyyy-MM-dd');
        String responseString;
        // String application_id;
        Boolean loancancel = LeadId!=null ? objLead.Loan_Application_Cancelled__c : objOpportunity.Loan_Application_Cancelled__c;
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        // to avoid fields creaion for same logic used zest field
        if(String.isNotBlank(zestLaonApplicationRequest) && !grayQuestApplicationRequestCancelled){
            PageReference pg = new PageReference(zestLaonApplicationRequest);
            pg.setRedirect(true);
            return pg;
        }

        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(grayQuestLoanRejectionDate != null && grayQuestDownPaymentDone){
            //create New Loan Order Id
            if(grayQuestLoanApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(grayQuestLoanApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            grayQuestLoanApplicationCancellationsCount = grayQuestLoanApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(grayQuestLoanApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }
        CallbackUrlBase = System.Label.Site_Url+'ApplicationInquiry';
        if(String.isNotBlank(opportunityId) && objOpportunity.nm_Semester__c != '1') {
            CallbackUrlBase = System.Label.Site_Url+'nmlogin_new?type=reregistration';
        }
        
            getTotalProductAmount();

            if(String.isNotBlank(LeadId)){
            recordId = LeadId;
                subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c);            
            }
    
            if(String.isNotBlank(opportunityId)){
            recordId = opportunityId;
                subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c);             
            }

        List<GQ_Tenure_Scheme__mdt> lstGQScheme = [SELECT LoanPlanCode__c FROM GQ_Tenure_Scheme__mdt WHERE InterestRate__c=:interestRate AND Tenure__c=:tenure LIMIT 1];
        if (lstGQScheme.isEmpty()) {
            System.debug('GQ Loan Plan code is empty');
            return null;
        }
        String loanPlanCode = lstGQScheme[0].LoanPlanCode__c;
    
        GQLoanRequestWrapper graywrapper = new GQLoanRequestWrapper();
        GQLoanRequestWrapper.cls_student_details gqStudentDetails = new GQLoanRequestWrapper.cls_student_details();
        GQLoanRequestWrapper.cls_fee_headers gqFeeHeaders = new GQLoanRequestWrapper.cls_fee_headers();
        GQLoanRequestWrapper.cls_notes gqNotes = new GQLoanRequestWrapper.cls_notes();
        graywrapper.student_id = studentNo;
        graywrapper.reference_id = OrderId;
        graywrapper.customer_mobile = MobileNumber;
        graywrapper.emi_plan_id = Integer.valueOf(loanPlanCode);
        gqStudentDetails.student_first_name = FullName;
        graywrapper.student_details = gqStudentDetails;

        // Payment Section
        gqFeeHeaders.total_payable = Integer.valueof(TotalPrice);
        graywrapper.fee_headers = gqFeeHeaders;

        // Notes Section
        gqNotes.location = ICName ;
        gqNotes.program = prgName;
        gqNotes.programcode =  prog_name;
        gqNotes.aep =  ICAPICode;
        gqNotes.tenure  = tenure;
        gqNotes.interestRate  = interestRate;
        gqNotes.subventionvalue =  subventionValue;
        graywrapper.notes = gqNotes;

        String jsonStringReq = System.JSON.serialize(graywrapper);
        System.debug('JsonStringReq-->'+jsonStringReq);
        System.debug('zestLaonApplicationRequest-->'+zestLaonApplicationRequest);
        System.debug('loancancel-->'+loancancel);
        if(String.isBlank(zestLaonApplicationRequest) && !loancancel){
            String jsonString = GrayQuestWebService.createGQLoanRequest(jsonStringReq,recordId,recordType);
            System.debug('jsonString --->'+jsonString );
            if(String.isNotBlank(jsonString)) {      
                GQLoanResponseWrapper respWrapper = GQLoanResponseWrapper.parse(jsonString);
                if(respWrapper!=null && respWrapper.success && String.isNotBlank(respWrapper.data.redirection_url)) {            
                    responseString = respWrapper.data.redirection_url;
                }
            }
        }

        if(String.isNotBlank(responseString)){
            if(String.isNotBlank(LeadId)){
                objLead.Zest_Loan_Application_Request__c = responseString;
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.EduVanz_lead_id__c = String.valueof(OrderId);
                objLead.Subvention_Value__c = subventionValue;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();
                objLead.Loan_Student_Id__c = studentNo;
                update objLead;
          
            }else if(String.isNotBlank(opportunityId)){
                objOpportunity.Zest_Loan_Application_Request__c = responseString;
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                objOpportunity.EduVanz_lead_id__c = String.valueof(OrderId);
              
                if(!String.isBlank(newOrderId) && grayQuestLoanRejectionDate != null && grayQuestDownPaymentDone && grayQuestLoanApplicationCancellationsCount >0 ){
                    objOpportunity.Loan_Application_Cancelled__c = false;
                    objOpportunity.Loan_Application_Cancellations_Count__c = grayQuestLoanApplicationCancellationsCount;
                    objOpportunity.Loan_Order_Status__c = null;
                    objOpportunity.Loan_Cancellation_Reason__c = null;
                }
                objOpportunity.Subvention_Value__c = subventionValue;
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                objOpportunity.Loan_Student_Id__c = studentNo;
                update objOpportunity;
            } 
            System.debug('responseString '+responseString);
            PageReference pg = new PageReference(responseString);
            pg.setRedirect(true);
            return pg; 
        }
        return null; 
    } 

    /**
    * @description to redirect if student is opted for liquiloans
    * @author shubhranshu | 12/3/2019
    * @return Pagereference
    **/
    public Pagereference liquiLoansApplicationRequest(){
        Double subventionValue = 0.0;
        String feetypeforLiquiloan = '';
        // studentConsentLoan(String.isNotBlank(LeadId) ? LeadId : null, String.isNotBlank(opportunityId) ? opportunityId : null);
        getTotalProductAmount();
        if(String.isNotBlank(LeadId)){
            subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objLead.nm_ChooseaProgram__c,objLead.Program_Type__c,objLead.Loan_Type__c,objLead.Tenure__c,objLead.nm_Fee_Type__c,objLead.Interest_Rate__c);
            feetypeforLiquiloan = objLead.nm_Fee_Type__c;
        }

        if(String.isNotBlank(opportunityId)){
            subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c);
            // subventionValue = getSuvbentionValue(objOpportunity.ChooseProgram__c,objOpportunity.Specialisation__c,objOpportunity.Loan_Type__c,objOpportunity.Tenure__c,objOpportunity.nm_Fee_Type__c,objOpportunity.Interest_Rate__c);
            feetypeforLiquiloan = objOpportunity.nm_Fee_Type__c;
        }
        // to get all liquiloans scheme
        List<LiquiloansTenureSchemes__c> liquiloanTenureSchemelst = LiquiloansTenureSchemes__c.getall().values();
        Map<String,String> mapOfLiquiloansTenureScheme = new Map<String,String>();
        if(liquiloanTenureSchemelst.size()>0){
            for(LiquiloansTenureSchemes__c lqSch:liquiloanTenureSchemelst){
                mapOfLiquiloansTenureScheme.put(lqSch.Tenure__c+'-'+lqSch.Interest_rate__c,lqSch.schemeId__c);
            }
        }
        System.debug('mapOfLiquiloansTenureScheme '+mapOfLiquiloansTenureScheme +' tenure '+tenure+' interestRate '+interestRate);
        String schemeId ='';
        String chooseProgram = String.isNotBlank(LeadId) ? objLead.nm_ChooseaProgram__c : objOpportunity.ChooseProgram__c;
        if(mapOfLiquiloansTenureScheme.size() > 0 && String.isNotBlank(tenure) && String.isNotBlank(interestRate)){
            if(mapOfLiquiloansTenureScheme.containsKey(tenure+'-'+interestRate)){
                schemeId = mapOfLiquiloansTenureScheme.get(tenure+'-'+interestRate);
            }
            // if((programSpecialization == 'M.Sc. (AI & ML Ops)' || programSpecialization == 'M.Sc. (AI)') && String.isNotBlank(feetypeforLiquiloan) && feetypeforLiquiloan == 'FullFee'){
            //     if(tenure == '18'){
            //         schemeId = '3310';
            //     }else if(tenure == '24'){
            //         schemeId = '3311';
            //     }else if(tenure == '36'){
            //         schemeId = '3309';
            //     }
            // }
            // else if((programSpecialization == 'M.Sc. (AI & ML Ops)' || programSpecialization == 'M.Sc. (AI)') && String.isNotBlank(feetypeforLiquiloan) && feetypeforLiquiloan == 'AnnualFee'){
            //     if(tenure == '12'){
            //         schemeId = '2889';
            //     }
            // } 
            // else if(programSpecialization == 'MBA (WX)' && chooseProgram == 'Master Programs') {
            //     if(tenure == '18'){
            //         schemeId = '7527';
            //     }
            // } 
            else if(String.isBlank(schemeId)){
                schemeId = mapOfLiquiloansTenureScheme.get(tenure+'-'+interestRate);
            }
        }
        String sid = System.Label.LiquiLoans_SID;
        String newOrderId = '';
        String gender = '';
        String aep_id =  EncodingUtil.urlEncode('{"AEP_ID": \"'+ic_name+'\","schemeId": \"'+schemeId+'\","Tenure": \"'+tenure+'\","InterestRate": \"'+interestRate+'\"}','UTF-8');
        String loanAmount = String.valueOf(TotalPrice);
        System.debug('loanAmount '+loanAmount);
        System.debug('AEP_ID-->' + ic_name + ' ' + aep_id);
        if(StudGender =='Male'){ gender='m'; }
        else if(StudGender =='Female') { gender='f'; }
        String callback = System.Label.LiquiLoans_Redirect_URL;
        Datetime myDT = Datetime.now();
        String Timestamp = myDT.format('yyyy-MM-dd hh:mm:ss');
        System.debug('Timestamp ==>'+Timestamp);
        String Checksum = generateCheckSumForliquiLoans(sid,FullName,EmailAddress,MobileNumber,Timestamp,callback,loanAmount,gender);

        System.debug('checksum after convert '+Checksum);
        //if Loan Application request Cancelled then allowed him to Re-create New Fresh Request with New Order Id
        if(liquiLoanApplicationRequestCancelled && liquiLoansDownPaymentDone){
            //create New Loan Order Id
            if(liquiLoansLaonApplicationCancellationsCount > 0){
                newOrderId = OrderId.removeStart(String.valueOf(liquiLoansLaonApplicationCancellationsCount));
            }else{
                newOrderId = OrderId;
            }
            liquiLoansLaonApplicationCancellationsCount = liquiLoansLaonApplicationCancellationsCount + 1;
            newOrderId = String.valueOf(liquiLoansLaonApplicationCancellationsCount) + newOrderId;
            OrderId = newOrderId;
        }

        if (registrationNumber == '01252451465422' && semester == '1') {
            OrderId = '101252451465422';
        }
       
         // redirect student to same liqui Laon Application request if Already liquiloans Request Created .
        if(String.isNotBlank(schemeId)){
            
            String formDataURL='/apex/NM_LiquiLoans_FormData?sid='+sid+'&UDF='+aep_id+'&URN='+OrderId+'&name='+FullName+'&email='+EmailAddress+'&mobile='+MobileNumber+'&loanAmount='+loanAmount+'&callback='+callback+'&gender='+gender+'&CHECKSUM='+Checksum;
            formDataURL= formDataURL +'&Timestamp='+Timestamp+'&edit_email=N&edit_mobile=N&edit_name=N&schemeId='+schemeId;
            
            if(LeadId !=null && LeadId !=''){
                System.debug('OrderId-->'+OrderId);
                objLead.Loan_Order_Id__c = OrderId;
                objLead.Loan_Amount__c = String.valueOf(TotalPrice);
                objLead.Subvention_Value__c = subventionValue;
                objLead.Student_Consent_Loan__c = true;
                objLead.Student_Consent_Loan_Date__c = DateTime.now();
                update objLead;
                API_Request__c apiReq = new API_Request__c();
                apiReq.Request__c = formDataURL;
                apiReq.Lead__c = LeadId;
                //apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'LiquiLoans';
                apiReq.API_Name__c='liquiLoansCreationFormData';
                apiReq.Success__c = true;

                // common menthod to insert the apireq 
                EduvanzTrackLoanApplicationAPI.apiRequestsInsertion(apiReq);
                
                PageReference pg = new PageReference(formDataURL);          
                pg.setRedirect(true);
                return pg;
            
            }else if(opportunityId !='' && opportunityId !=null){
                objOpportunity.Loan_Order_Id__c = OrderId;
                objOpportunity.Loan_Amount__c = String.valueOf(TotalPrice);
                if(!String.IsBlank(newOrderId) && liquiLoanApplicationRequestCancelled && liquiLoansDownPaymentDone && liquiLoansLaonApplicationCancellationsCount >0 ){
                        objOpportunity.Loan_Application_Cancelled__c = false;
                        objOpportunity.Loan_Application_Cancellations_Count__c = liquiLoansLaonApplicationCancellationsCount;
                        objOpportunity.Loan_Order_Status__c = null;
                        objOpportunity.Loan_Cancellation_Reason__c = null;
                }
                objOpportunity.Student_Consent_Loan__c = true;
                objOpportunity.Student_Consent_Loan_Date__c = DateTime.now();
                objOpportunity.Subvention_Value__c = subventionValue;
                update objOpportunity;
                API_Request__c apiReq = new API_Request__c();
                apiReq.Request__c = formDataURL;
                apiReq.Opportunity__c = opportunityId;
                //apiReq.Response__c = messageWrapper.toString();
                apiReq.Type_of_Request__c= 'LiquiLoans';
                apiReq.API_Name__c='liquiLoansCreationFormData';
                apiReq.Success__c = true;

                // common menthod to insert the apireq 
                EduvanzTrackLoanApplicationAPI.apiRequestsInsertion(apiReq);
                
                PageReference pg = new PageReference(formDataURL);
                pg.setRedirect(true);
                return pg;
                
            }
        }
        return null;
    }

    public Double getSuvbentionValue(String chooseProgram,String ProgramType,String LoanType,String Tenure,String feeType){
        Double subventionValue = 0.0;
        List<String> programs = new List<String>{'Master Programs','MBA (Online) Programs'};
        ProgramType = String.isNotBlank(ProgramType) && programs.contains(chooseProgram) ? ProgramType : null;
        List<String> admissionFeeTypeLst = new List<String>{'MBAallTermfee','admission','registration','InitialAdmissionFee','ReRegistrationPayment'};
        if(admissionFeeTypeLst.contains(feeType)) {
            feeType = 'Admission';
        }
        String key = chooseProgram + '-' + ProgramType + '-' + LoanType + '-' + feeType;
        List<Tenure__c> lstTenures = [SELECT Id,Interest_Rate__c,Key__c,Subvention_Value__c,Tenure__c FROM Tenure__c WHERE Key__c=:key AND Tenure__c=:Tenure AND IsActive__c=true LIMIT 1];
        if(lstTenures.size() > 0) {
            subventionValue = lstTenures[0].Subvention_Value__c;
        }
        return subventionValue;
    }

    public void getTotalProductAmount(){
        // Map of Price Book
        if(String.isBlank(TagPriceBookId)) {
            Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            mapOfPricebook = getMapOfPriceBookIdProductVsPriceBookEntry.get(TagPriceBookId);
        } else {
            mapOfPricebook = productHelper.getMapOfProductVsPriceBookEntry(TagPriceBookId);
        }
        // Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        // mapOfPricebook = getMapOfPriceBookIdProductVsPriceBookEntry.get(TagPriceBookId);
        String programKey = programId+'-'+semester;
        System.debug('product Name--'+productName);
        if(mapOfPricebook != null && !mapOfPricebook.isEmpty()){
            Integer multiplicationFactor = 1;
            if('Admission'.equalsIgnoreCase(productName)){
                multiplicationFactor = 1;
                TotalPrice = ProductPricing(productName,multiplicationFactor,programKey);
            }else if('AnnualFee'.equalsIgnoreCase(productName)){
                multiplicationFactor = Integer.valueof(totalsem/2);
                if('Master Programs'.equalsIgnoreCase(programCategory) && ('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization)
                 || 'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization)) )
                {
                   TotalPrice =  ProductPricing('AnnualFee',5,'Annual'+'-'+programId);
                }
                else if(mapOfPricebook.containsKey('Annual'+'-'+programId) && !'M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) && !'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization))
                {
                    TotalPrice = ProductPricing('AnnualFee', 2,'Annual'+'-'+programId);
                }
                else {
                  TotalPrice =   ProductPricing('AnnualFee',2,'Annual');
                  system.debug('TotalPrice--->' +TotalPrice);
                }
                
            }else if('2TermFee'.equalsIgnoreCase(productName)) {
                multiplicationFactor = 2 ;
                if(mapOfPricebook.containsKey('2TermFee'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'2TermFee'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'2TermFee');
                }
               
            }else if('PGAllSemFee'.equalsIgnoreCase(productName)){
                if('Master Programs'.equalsIgnoreCase(programCategory) && 'M.Sc.'.equalsIgnoreCase(programSpecialization)) {
                    multiplicationFactor = 4;
                    TotalPrice = ProductPricing('PGAllSemFee',multiplicationFactor,'MSAllSemFee');
                } else if ('Bachelor Programs'.equalsIgnoreCase(programCategory) && 'BCom'.equalsIgnoreCase(programSpecialization)){
                    multiplicationFactor = 6;
                    TotalPrice = ProductPricing('PGAllSemFee',multiplicationFactor,'BComAllSemFee');
                } else if ('Bachelor Programs'.equalsIgnoreCase(programCategory) && 'BBA'.equalsIgnoreCase(programSpecialization)){
                    multiplicationFactor = 6;
                    TotalPrice = ProductPricing('PGAllSemFee',multiplicationFactor,'BBAAllSemFee');
                } else {
                    multiplicationFactor = 4;
                    TotalPrice = ProductPricing('PGAllSemFee',multiplicationFactor,'PG_All_Sem');
                }
            }else if('MultipleSemFee'.equalsIgnoreCase(productName)){
                multiplicationFactor = 3;
                TotalPrice = ProductPricing(productName,multiplicationFactor,'Multiple Semester');
            }else if('FullFee'.equalsIgnoreCase(productName)) {
                multiplicationFactor = Integer.valueof(totalsem );
                if(mapOfPricebook.containsKey('FullFee'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'FullFee'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'FullFee');
                }              
            }else if('FullFeeLoan'.equalsIgnoreCase(productName)) {
                multiplicationFactor = Integer.valueof(totalsem );
                if(mapOfPricebook.containsKey('FullFeeLoan'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'FullFeeLoan'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'FullFeeLoan');
                }              
            }else if('AnnualFeeLoan'.equalsIgnoreCase(productName)) {
                if(mapOfPricebook.containsKey('AnnualFeeLoan'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,2,'AnnualFeeLoan'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,2,'AnnualFeeLoan');
                }              
            }
            else if('3SemFee'.equalsIgnoreCase(productName)) {
                multiplicationFactor = 3 ;
                if(mapOfPricebook.containsKey('3SemFee'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'3SemFee'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'3SemFee');
                }
               
            }
            else if('3TermFee'.equalsIgnoreCase(productName)) {
                 multiplicationFactor = 3 ;
                 if(mapOfPricebook.containsKey('3TermFee'+'-'+programId))
                 {
                     TotalPrice = ProductPricing(productName,multiplicationFactor,'3TermFee'+'-'+programId);
                 }else
                 {
                     TotalPrice = ProductPricing(productName,multiplicationFactor,'3TermFee');
                 }
               
            }
            else if('4SemFee'.equalsIgnoreCase(productName)) {
                multiplicationFactor = 4 ;
                if(mapOfPricebook.containsKey('4SemFee'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'4SemFee'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'4SemFee');
                }
               
            }
            else if('5SemFee'.equalsIgnoreCase(productName)) {
                multiplicationFactor = 5 ;
                if(mapOfPricebook.containsKey('5SemFee'+'-'+programId))
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'5SemFee'+'-'+programId);
                }else
                {
                    TotalPrice = ProductPricing(productName,multiplicationFactor,'5SemFee');
                }
               
            }
            if(liveLecType!=null && liveLecType!='')
            {
               
                Decimal liveLecturePrice =  mapOfPricebook.containskey('Live Lectures')? mapOfPricebook.get('Live Lectures').UnitPrice:0;
                Decimal BacklogLecturePrice =  mapOfPricebook.containskey('Backlog')? mapOfPricebook.get('Backlog').UnitPrice:0;
                if('Certificate Programs'.equalsIgnoreCase(programCategory) && liveLecturePrice > 0) {
                    liveLecturePrice = liveLecturePrice + (liveLecturePrice * Decimal.valueOf(Label.Service_Tax).setScale(2));
                }
                System.debug('liveLecturePrice ==>'+liveLecturePrice);
                System.debug('product Helper ==>'+productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'1SemLecturesFee','',consumerType));
                if('1SemLecturesFee'.equalsIgnoreCase(liveLecType))
                {
                    Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'1SemLecturesFee','',consumerType);           
                    TotalPrice += liveLecturePrice*totalSubjects;
                    
                }
                if('2SemLecturesFee'.equalsIgnoreCase(liveLecType))
                {
                    Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'2SemLecturesFee','',consumerType);                   
                    TotalPrice += liveLecturePrice*totalSubjects;
                }
                if('3SemLecturesFee'.equalsIgnoreCase(liveLecType))
                {
                    Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'3SemLecturesFee','',consumerType);
                   
                     TotalPrice += liveLecturePrice*totalSubjects;
                }
                if('4SemLecturesFee'.equalsIgnoreCase(liveLecType))
                {
                    Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'4SemLecturesFee','',consumerType);
                    system.debug('TotalPrice --->'+TotalPrice );
                     TotalPrice += liveLecturePrice*totalSubjects;
                     system.debug('TotalPrice --->'+TotalPrice );
                }
               
                if(courseList!=null && courseList!='' && 'Custom'.equalsIgnoreCase(liveLecType))
                {
                    //mapOfProductAndAmount.put('CustomLive',liveLecturePrice* productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'Custom',courseList,consumerType));
                    TotalPrice += liveLecturePrice* productHelper.TotalNumberOfSubject(Integer.valueof(semester),programStructure,programId,'Custom',courseList,consumerType);
                }
                if(String.isNotBlank(backlogList) && BacklogLecturePrice > 0) {
                    TotalPrice += BacklogLecturePrice * backlogList.split(',').size();
                }
                System.debug('TotalPrice--->'+TotalPrice);
                
           
            }
        
    
        }
        propelldApplicationCourseFee = Integer.valueOf(TotalPrice);
        /*TotalPrice = TotalPrice + LateFeeAppliedAmount;
        TotalPrice = TotalPrice - (downPaymentAmount + LateFeeAmount);
        TotalPrice = TotalPrice.round(System.RoundingMode.CEILING);*/

        /*
        * Added by @BK (26-02-2020)
        * to Add late fee if late fee amount is already paid.
        */
        System.debug('LateFeeAmount before Query ==>'+LateFeeAmount);
        if(LateFeeAppliedAmount > 0 && LateFeeAmount!=LateFeeAppliedAmount) {
            List<String> lstOfStatus = new List<String>{'Payment Approved','Payment Made','Waived Off'};
            String paymentType = 'Late Fees';
            List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
            if(String.isNotBlank(opportunityId)) {
                String paymentSql = getQueryAllFieldSql('nm_Payment__c','nm_OpportunityNew__c=:opportunityId and nm_PaymentStatus__c IN :lstOfStatus and nm_PaymentType__c=:paymentType',null);
                lstPayment = DataBase.query(paymentSql);
            } else if(String.isNotBlank(LeadId)) {
                String paymentSql = getQueryAllFieldSql('nm_Payment__c','nm_Lead__c=:LeadId and nm_PaymentStatus__c IN :lstOfStatus and nm_PaymentType__c=:paymentType',null);
                lstPayment = DataBase.query(paymentSql);
            }
            if(lstPayment.size() > 0) {
                LateFeeAmount = 0;
                for (nm_Payment__c objPayment : lstPayment) {
                    LateFeeAmount += objPayment.nm_Amount__c;
                }
                System.debug('LateFeeAmount ==>'+LateFeeAmount);
            }
        }
        // we do not have the lineitem at lead level hence to avoid subtracting late fee on lead level
        else if(LateFeeAmount > 0 && LateFeeAppliedAmount == 0) {
            LateFeeAmount = 0;
        }

        system.debug('LateFeeAppliedAmount--->'+LateFeeAppliedAmount);
        system.debug('LateFeeAmount --->'+LateFeeAmount );
        system.debug('downPaymentAmount --->'+downPaymentAmount );
        system.debug('TotalPrice --->'+TotalPrice );
        TotalPrice = TotalPrice  + (LateFeeAppliedAmount - LateFeeAmount);
        TotalPrice = TotalPrice - (downPaymentAmount );
        TotalPrice = TotalPrice.round(System.RoundingMode.CEILING);
        system.debug('TotalPrice Final--->'+TotalPrice );
    }
   
    /*public decimal ProductPricing(String productName,Integer multiplicationFactor,String programKey){
        System.debug('---programKey---'+programKey);
        decimal amount = 0;
       
 
         if(IsDefence && productName != 'RepeatTermFee'){
     
           if(multiplicationFactor==2 && productName =='AnnualFee' && totalsem >=2 ){  
       
                for(Integer i=1;i<=multiplicationFactor;i++)
                {
                    System.debug('--multiplicationFactor---'+i+'-----'+programId);  
                    amount= amount + mapOfPricebook.get(programId+'-'+i).UnitPrice;
                    system.debug('amount---->'+amount);        
                }
            }else if('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) && productName =='AnnualFee' ||  productName =='FullFee' )
              {                      
                            amount =  mapOfPricebook.get(programKey).UnitPrice;
                            system.debug('amount---->'+amount);                              
              }
             
            else{
           
                amount = mapOfPricebook.get(programId+'-'+semester).UnitPrice;
                amount =  amount * multiplicationFactor;
            }
           
            amount = amount * 0.8;
           // amount = amount * multiplicationFactor;
        }
       
        else{
           // amount = mapOfPricebook.get(programKey).UnitPrice;
           if(mapOfPricebook.containsKey(programKey)) {
            System.debug('enter programName '+programKey);
            amount = mapOfPricebook.get(programKey).UnitPrice;
        }else{
            System.debug('not found '+programKey);
        }
            System.debug('amount ==>'+amount);
        }
       
        amount = amount + ICProgramChangeAmount;
       
        // taking Exam fees for Verizon Student
        if('Verizon'.equalsIgnoreCase(ICName)){
            amount += mapOfPricebook.get('Exam Fees').UnitPrice;
        }
       
        // service Tax for Certificate Program
        if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
            amount += amount * Decimal.valueOf(Label.Service_Tax).setScale(2);
        }
        // added discount for Already Confirmed Student and applied for Executive Program
        if(ValidateStudentNo()){
            amount = amount*0.8;
        }
       
        return (amount.setScale(2));
    }*/
    public decimal ProductPricing(String productName,Integer multiplicationFactor,String programKey){
        System.debug('---programKey---'+programKey);
        decimal amount = 0;
        
        Integer sem = semester!=null ?Integer.valueof(semester):0;
        
         if(IsDefence && productName != 'RepeatTermFee'){
             
                if(programSpecialization!=null && ('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) || 'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization)) && (productName =='AnnualFee' ||  productName =='FullFee') )
                {                      
                    amount =  mapOfPricebook.get(programKey).UnitPrice;
                    system.debug('amount---->'+amount);                              
                }
               else if(!'MBA (WX)'.equalsIgnoreCase(programSpecialization) && !'MBA (X)'.equalsIgnoreCase(programSpecialization) && !'MBA - X'.equalsIgnoreCase(programSpecialization) && !'M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programSpecialization) && !'M.Sc. (AI)'.equalsIgnoreCase(programSpecialization) ){   
                    for(Integer i = sem ;i<=(sem + multiplicationFactor - 1);i++)
                    {
                        System.debug('--multiplicationFactor---'+i+'-----'+programId);                
                        amount += mapOfPricebook.containsKey(programId+'-'+i) ? mapOfPricebook.get(programId+'-'+i).UnitPrice:0;
                        system.debug('amount---->'+amount);        
                    }                         
                } 
                else{

                    amount = mapOfPricebook.get(programId+'-'+semester).UnitPrice;
                    amount =  amount * multiplicationFactor;
                }

                amount = amount * 0.8;
            
        }
       
        else{
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
                System.debug('amount ==>'+amount);
        }
       system.debug('ICProgramChangeAmount--->'+ICProgramChangeAmount );
        amount = amount + ICProgramChangeAmount + StudyKitAmount ;
       
        // taking Exam fees for Verizon Student
        if('Verizon'.equalsIgnoreCase(ICName)){
            amount += mapOfPricebook.get('Exam Fees').UnitPrice;
        }
       
        // service Tax for Certificate Program
        if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
            amount += amount * Decimal.valueOf(Label.Service_Tax).setScale(2);
        }
        // added discount for Already Confirmed Student and applied for Executive Program
        if(ValidateStudentNo()){
            amount = amount*0.8;
        }
       
        return (amount.setScale(2));
    }
   
   
    public PageReference CareerServiceRedirect(){
        System.debug('careerservice-->'+careerservice);
        if(String.isNotBlank(careerservice)) {
            Map<String,String> mapOfParametersToPass = new Map<String,String>{
                'message'=>paymentmessage,
                'sapid'=>objcareer.Student_Number_Of_Account__c,
                'packageId'=>objcareer.CareerServiceProgram__c,
                'status'=>paymentstatus,
                'paymentTrackId'=>paymentTrackId,
                'paymentInitializationId'=>objcareer.CS_Program_Record_Id__c
            };
            //to generate checksum.
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Portal_Encryption_Key, mapOfParametersToPass);
            mapOfParametersToPass.put('CHECKSUMHASH',checkSum);
           
            //to convert map to url params.
            PageReference pageReference = new PageReference('');
            pageReference.getParameters().putAll(mapOfParametersToPass);
            String Param = pageReference.getUrl();
            String redirectURL='';
            System.debug('URL Param -->'+Param);

            System.debug('paymentstatus-->'+paymentstatus);
            if(paymentstatus == 'Payment Made' || paymentstatus == 'Payment Approved') {
                System.debug('success enter');
                paymentstatus = 'success';
                if(objcareer.Stage__c != 'Payment Done'){
                    objcareer.Stage__c='Payment Initiated';
                }
                redirectURL = objcareer.successURL__c+Param;
            }else{
                System.debug('error enter');
                paymentstatus = 'error';
                if(objcareer.Stage__c == 'Register'){
                    objcareer.Stage__c='Transaction Failed';
                }
                redirectURL = objcareer.failureURL__c+Param;
            }

            try{
                if(objcareer != null){
                    System.debug('objcareer '+objcareer);
                    update objcareer;
                }
            }catch(DMLException e){
                system.debug(e.getMessage());
            }

            if(String.isNotBlank(redirectURL)){
                PageReference pg = new PageReference(redirectURL);
                pg.setRedirect(true);
                return pg;
            }
        }
        return null;
    }

    public PageReference cancelLoanApplication(){

        Datetime dateofBirth = null;
        System.debug('paymentTrackId ==>'+paymentTrackId);
        if(String.isNotBlank(paymentTrackId)) {
            List<nm_Payment__c> downLoanPaymentLst = [SELECT id,nm_PaymentType__c,nm_Installment_Payment_Ref__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:paymentTrackId AND (nm_PaymentType__c LIKE '%DownPayment%') LIMIT 1];

            if(downLoanPaymentLst.size() > 0) {

                String installmentReference = 'Installment-admission';
                String loanType = '';
                String loanOrderId = '';
                String loanCancellationReason = '';
                String feeType = '';
                String quoteId = '';
                String recordId = '';

                if(recordType == 'Lead'){
                    System.debug('objLead 2-->'+objLead);
                    dateofBirth = objLead.nm_DateOfBirth__c;
                    objLead.Loan_Application_Cancelled__c = true;
                    objLead.Down_Payment_Made__c = false;
                    objLead.LiveLecturesType__c  = 'No';
                    objLead.Loan_Cancellation_Reason__c = 'do not want to opt for loan';
                    objLead.nm_Fee_Type__c = 'registration';
                    loanType = objLead.Loan_Type__c;
                    loanOrderId = objLead.Loan_Order_Id__c;
                    loanCancellationReason = objLead.Loan_Cancellation_Reason__c;
                    quoteId = objLead.EduVanz_lead_id__c;
                    recordId = objLead.Id;
                }
                else if(recordType == 'Opportunity'){
                    if(objOpportunity.Loan_Approved__c) {
                        errMessages = 'Loan has been already Approved, you can\'t cancel loan at this stage. Kindly contact your authorized AEP';
                        return null;
                    }
                    System.debug('objOpportunity 2-->'+objOpportunity);
                    dateofBirth = objOpportunity.Account.nm_DateOfBirth__c;
                    objOpportunity.Loan_Application_Cancelled__c = true;
                    objOpportunity.Down_Payment_Made__c = false;
                    objOpportunity.LiveLecturesType__c = 'No';
                    
                    objOpportunity.Loan_Cancellation_Reason__c = 'do not want to opt for loan';
                    feeType = 'registration';
                    if(objOpportunity.nm_Semester__c != '1') {
                        feeType = 'ReRegistrationPayment';
                    }
                    if(!objOpportunity.nm_Fee_Type__c.equalsIgnoreCase('MBAallTermfee-Considered') && !objOpportunity.nm_Fee_Type__c.equalsIgnoreCase('MBAallTermfee')) {
                        objOpportunity.nm_Fee_Type__c = feeType;
                    }
                    installmentReference = 'Installment-'+feeType;
                    loanType = objOpportunity.Loan_Type__c;
                    loanOrderId = objOpportunity.Loan_Order_Id__c;
                    loanCancellationReason = objOpportunity.Loan_Cancellation_Reason__c;
                    quoteId = objOpportunity.EduVanz_lead_id__c;
                    recordId = objOpportunity.Id;
                    if(loanType.equalsIgnoreCase('Propelld') || loanType.equalsIgnoreCase('EzCred') || loanType.equalsIgnoreCase('Avanse')) {
                        objOpportunity.Zest_Loan_Application_Request__c = '';
                    }
                }

                // To cancel zest loan request.
                boolean isFailed = false;
                if(String.isNotBlank(loanType) && (loanType.equalsIgnoreCase('Zest') || loanType.equalsIgnoreCase('Propelld')) && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c) {
                    String result = null;
                    if(loanType.equalsIgnoreCase('Zest')) {
                        Boolean isSubventionScheme = false;
                        if(String.isNotBlank(programSpecialization) && (programSpecialization == 'MBA (WX)' || programSpecialization == 'MBA (X)' || programSpecialization == 'MBA - X') && programCategory == 'Master Programs') {
                            isSubventionScheme = String.isNotBlank(interestRate) && (InterestRate == '0' || InterestRate == '0.0') ? true : false;
                        }
                        ZestWebService objZestWebService = new ZestWebService();
                        result = objZestWebService.CancelledLoanApplicationByOrderId(loanOrderId,loanCancellationReason,isSubventionScheme);
                    } 
                    // else if (loanType.equalsIgnoreCase('Avanse')) {
                    //     AvanseWebService objAvanseWebSerevice = new AvanseWebService();
                    //     result = objAvanseWebSerevice.cancelAvanseLoan(quoteId,recordType,recordId);
                    // } 
                    else {
                        PropelldWebService objPropelldWebService = new PropelldWebService();
                        result = objPropelldWebService.updateStatusByQuoteId(quoteId,false,recordId,recordType);
                    }
                   
                    if(String.isBlank(result)) {
                        System.debug('Loan Application Cancellation failed');
                        // errMessages = 'Loan Application Cancellation failed, kindly contact your authorized AEP';
                        isFailed = true;
                    }
                }else if(String.isNotBlank(loanType) && loanType.equalsIgnoreCase('LiquiLoans') && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c && String.isNotBlank(objOpportunity.EduVanz_lead_id__c)){
                    // String LoansStage = liquiLoansStatusUpdateAPI.CheckStatus(objOpportunity.EduVanz_lead_id__c,objOpportunity.Id,'Opportunity');  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                    // if(LoansStage.equalsIgnoreCase('Rejected')){
                    //     System.debug('Loan is already rejected...');
                    // }else{
                        String result = liquiLoansStatusUpdateAPI.statusUpdateForLoan(objOpportunity.EduVanz_lead_id__c,'N',objOpportunity.Id,'Opportunity');  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                        if(result != 'true') {
                            System.debug('Loan Application Cancellation failed');
                            // errMessages = 'Loan Application Cancellation failed, kindly contact your authorized AEP';
                            isFailed = true;
                        }
                    // }
                    
                }else if(String.isNotBlank(loanType) && loanType.equalsIgnoreCase('EzCred') && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c && String.isNotBlank(objOpportunity.EduVanz_lead_id__c) && String.isNotBlank(objOpportunity.Loan_Account_number__c)){
                    String result = EzcredWebService.cancelLoan(objOpportunity.Loan_Account_number__c,objOpportunity.Id,'Opportunity');  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                    if(result != 'success') {
                        System.debug('Loan Application Cancellation failed');
                        // errMessages = 'Loan Application Cancellation failed, kindly contact your authorized AEP';
                        isFailed = true;
                    }
                }else if(String.isNotBlank(loanType) && loanType.equalsIgnoreCase('EduVanz') && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c && String.isNotBlank(objOpportunity.EduVanz_lead_id__c) && String.isNotBlank(objOpportunity.Loan_Order_Id__c)){
                    String result = EduvanzTrackLoanApplicationAPI.EducancelLoan(objOpportunity.EduVanz_lead_id__c,objOpportunity.Loan_Order_Id__c,objOpportunity.Id,'Opportunity');  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                    if(result != 'success') {
                        System.debug('Loan Application Cancellation failed');
                        // errMessages = 'Loan Application Cancellation failed, kindly contact your authorized AEP';
                        isFailed = true;
                    }
                }else if(String.isNotBlank(loanType) && loanType.equalsIgnoreCase('GrayQuest') && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c && String.isNotBlank(objOpportunity.EduVanz_lead_id__c)){
                   system.debug('Loan cancel entry');
                    String result = GrayQuestWebService.cancelLoan(objOpportunity.Loan_Order_Id__c,objOpportunity.Loan_Student_Id__c,objOpportunity.Id,'Opportunity');
                    if(result != 'success') {
                        System.debug('Loan Application Cancellation failed');
                        // errMessages = 'Loan Application Cancellation failed, kindly contact your authorized AEP';
                        isFailed = true;
                    }
                }else if (String.isNotBlank(loanType) && loanType.equalsIgnoreCase('Avanse') && String.isNotBlank(loanOrderId) && objOpportunity.Loan_Application_Cancelled__c && String.isNotBlank(objOpportunity.EduVanz_lead_id__c)) {
                    AvanseWebService objAvanseWebSerevice = new AvanseWebService();
                    Boolean result = objAvanseWebSerevice.cancelAvanseLoan(quoteId,recordType,recordId);
                    if (!result) {
                        System.debug('Loan Application Cancellation failed');
                        isFailed = true;
                    }
                }
                if(isFailed) {
                    LoanCancellationRequestFailedController loanFailed = new LoanCancellationRequestFailedController();
                    loanFailed.loanCancellation(recordId,recordType, 'Loan Cancelation Failed', 'Loan Cancelation Failed');
                }

                nm_Payment__c downLoanPayment = downLoanPaymentLst[0];
                downLoanPayment.nm_PaymentType__c = 'Installment';
                downLoanPayment.nm_Installment_Payment_Ref__c = installmentReference;

                try {
                    if(String.isNotBlank(LeadId)) {
                        // To update Lead
                        update objLead;
                    } else if(String.isNotBlank(opportunityId)) {
                        // To update opportunity
                        update objOpportunity;
                    }

                    // To update payment record.
                    update downLoanPayment;

                } catch (Exception e) {
                    System.debug(e.getMessage());
                    return null;
                }
               
                String redirectURL = System.Label.Site_Url+'EnrollmentForm';
                if(feeType.endsWithIgnoreCase('ReRegistrationPayment')) {
                    redirectURL = System.Label.Site_Url+'nmlogin_new?dob='+dateofBirth.format('dd/MM/yyyy')+'&type=reregistration&studentNo='+studentNo;
                }
                // objSessionManager.destroySession();
                System.debug('redirectURL--'+redirectURL);
                PageReference pg = new PageReference(redirectURL);
                pg.setRedirect(true);
                return pg;
            } else {
                errMessages = 'No Record found against Loan request, Kindly raise a Ticket';
            }
        }
        return null;
    }

    /**
    * @description checksum logic for form-data API
      this method first create the string with pipe sepeated value then using HmacSHA256 and key it generate the cheksum value
      at last return the hex value of this checksum.
    * @author shubhranshu | 12/3/2019
    * @param sid
    * @param name
    * @param email
    * @param MobileNumber
    * @param TimeStamp
    * @param CallBackUrl
    * @param loanAmount
    * @param gender
    * @return String
    **/
    public String generateCheckSumForliquiLoans(String sid,String name,String email,String MobileNumber,String TimeStamp,String CallBackUrl,String loanAmount,String gender){
        String salt = sid+'|'+name+'|'+email+'|'+MobileNumber+'|'+TimeStamp+'|'+CallBackUrl+'|'+loanAmount+'|'+gender;
        System.debug('salt value '+salt);
        String key = System.Label.LiquiLoans_Api_Key;
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        System.debug('checksum ==>'+ EncodingUtil.convertToHex(data));

        return  EncodingUtil.convertToHex(data);
    }

     /*--------------------method to validate Student for Executive Program -----------------------------------------*/  
    public Boolean ValidateStudentNo(){
        if('Executive Programs'.equalsIgnoreCase(programCategory) && LateralStudentNo !='' && LateralStudentNo !=null){
            List<Account> lstAccount =[select id from Account where nm_StudentNo__c=:LateralStudentNo and nm_StudentStatus__c='Confirmed' ];
            if(lstAccount.size()>0){
                return true;
            }
        }
        return false;
    }

    // public void studentConsentLoan(String leadId, String oppId) {
    //     if (String.isNotBlank(oppId)) {
    //         Database.update(new Opportunity(Id = oppId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now()), true);
    //     } else if(String.isNotBlank(leadId)) {
    //         // Database.update(new Lead(Id = leadId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now()), true);
    //         // update new Lead(Id = leadId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now());
    //         List <Lead> lstLd = new List<Lead>();
    //         lstLd.add(new Lead(Id = leadId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now()));
    //         Database.SaveResult[] updateResults = Database.update(lstLd, true); // Check for errors 
    //         for (Database.SaveResult updateResult : updateResults) { 
    //             if (!updateResult.isSuccess()) { 
                
    //                 for (Database.Error error : updateResult.getErrors()) 
    //                 { System.debug('Error updating account: ' + error.getMessage()); 
    //                 } 
    //                 } 
    //                 else {
    //                     System.debug('Sucess -->');
    //                 }
    //                 }
    //     }
    // }
    // @future 
    // public static void studentConsentLoan(String leadId, String oppId) {
    //     if (String.isNotBlank(oppId)) {
    //         update new Opportunity(Id = oppId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now());
    //     } else if(String.isNotBlank(leadId)) {
    //         update new Lead(Id = leadId, Student_Consent_Loan__c = true, Student_Consent_Loan_Date__c = DateTime.now());
    //     }
    // }

    public pageReference logout() {
        String type = IsReRegistration ? 'reregistration' : 'registration';
        PageReference pg = new PageReference('/apex/nmLogin_new?type='+type);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference showDocuments() {
        String objectId = String.isNotBlank(LeadId) ? LeadId : (String.isNotBlank(AccountId) ? AccountId : null);
        String objType = String.isNotBlank(LeadId) ? 'Lead' : (String.isNotBlank(AccountId) ? 'Account' : null);
        if(String.isNotBlank(objectId)) {
            PageReference pg = new PageReference('/apex/NMIMS_MBA_UploadDocument?objType='+objType+'&id='+objectId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

}