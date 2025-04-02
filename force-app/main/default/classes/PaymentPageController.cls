/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : @vickysahu
**/
public without sharing class PaymentPageController {
    public Id objectId;
    public String objectType;
    public ProductHelper productHelper;
    Boolean isCalled;

    public Lead objLead {get;set;}
    public Account objAccount {get;set;}
    public Opportunity objOpportunity {get;set;}
    public NM_Payment_Form_Configuration__c objPaymentFormConfiguration {get;set;}
    public nm_Payment__c objPayment {get;set;}
    public nm_Payment__c objDownPayment {get;set;}
    public String opportunityId {get;set;}
    public String feePaidSemester {get;set;}
    // public String studentProgramId {get;set;}
    public LoanRequestWrapper objLoanDetails {get;set;}
    public RequestWrapper objDetails {get;set;}
    public StudentDetails objStudentDetails {get;set;}
    public String errorMsg {get;set;}
    public Coursera objCoursera {get;set;}
    public AlreadyPaidFee objfee {get;set;}
    public LiveLecturePayment objLiveLecturePayment {get;set;}
    public AdmissionAmount objAdmissionAmount {get;set;}
    // public PaymentMade objPaymentMade {get;set;}

    // need fields to be global
    public String currentAdmissionSession {get;set;}
    public String currentAdmissionYear {get;set;}
    public String programCategory {get;set;}
    public String programSpecialization  {get;set;}
    public String InstallmentPayFor {get;set;}
    public String programType {get;set;}
    public String semester {get;set;}
    public String leadId {get;set;}
    public Set<String> setOfApplicablePaymentOptionForStudent {get;set;}// Map for Showing Payment Option
    public String jsonMapOfProductAndAmount {get;set;}
    public String jsonMapOfLectureTypeAndSubjects {get;set;}

    public Map<String,Map<Id,nm_Courses__c>> mapOfCourseKeyVsCourseObj {get;set;}
    public Map<Id,nm_Courses__c> mapOfCourseKeyVsCurrentCourseObj {get;set;}
    public Map<String , Object> mapOfBacklogCourseIdVsBacklogObject {get; set;}
    public integer sizeOfMapOfBacklogCourseIdVsBacklogObject {get; set;}

    public Map<String,PriceBookEntry> mapOfPricebook {get;set;}
    public Map<String,Decimal> mapOfProductAndAmount {get;set;}
    public Set<String> setOfPaymentOptionsAvailable {get;set;}
    public String paymentFor {get;set;}
    public Decimal depositAmount {get;set;}
    public String paymentGateWayName {get;set;}
    public boolean IsReregistartion {get;set;}
    public boolean IsICForMakingPayment {get;set;} // to distinguish between student and IC (for Showing DD Option for making Payment) 
    public boolean IsHOForMakingPayment {get;set;} // to distinguish between IC and HO (for Showing DD Option for making Payment) 

    public Boolean allowPayment {get;set;} // allowPayment - varaiable to be removed
    public Boolean isFormSubmitted {get;set;}

    //---- Stores error messages --- //
    public string errMessages { get; set; }
    public string strSecToShow { get; set; }
    public String returnUrl {get;set;}
    
    public PaymentPageController() {
        initalizeVariables();
    }

    /**
    * @description 
    * @author @BK | 08-26-2024 
    **/
    public void initalizeVariables() {
        objLead = new Lead();
        objAccount = new Account();
        objOpportunity = new Opportunity();
        objDownPayment = new nm_Payment__c();
        objPayment = new nm_Payment__c();
        objPaymentFormConfiguration = new NM_Payment_Form_Configuration__c();
        opportunityId = null;
        feePaidSemester = '1';
        leadId = null;
        productHelper = new ProductHelper();
        // studentProgramId = '';
        errorMsg = '';
        objLoanDetails = new LoanRequestWrapper();
        objDetails = new RequestWrapper();
        objStudentDetails = new StudentDetails();
        objCoursera = new Coursera();
        objfee = new AlreadyPaidFee();
        objLiveLecturePayment = new LiveLecturePayment();
        objAdmissionAmount = new AdmissionAmount();
        // objPaymentMade = new PaymentMade();
        isCalled=false;
        currentAdmissionSession = '';
        currentAdmissionYear = '';
        programCategory = '';
        programSpecialization = '';
        programType = '';
        semester = '';
        paymentFor = '';
        depositAmount = 0;
        paymentGateWayName = '';
        setOfApplicablePaymentOptionForStudent = new Set<String>();
        jsonMapOfProductAndAmount = '';
        jsonMapOfLectureTypeAndSubjects = '';
        mapOfProductAndAmount = new Map<String,Decimal>();
        mapOfPricebook = new Map<String,PriceBookEntry>();
        setOfPaymentOptionsAvailable = new Set<String>();
        mapOfCourseKeyVsCourseObj = new Map<String,Map<Id,nm_Courses__c>> ();
        mapOfBacklogCourseIdVsBacklogObject = new Map<String, Object>();
        sizeOfMapOfBacklogCourseIdVsBacklogObject =0;
        mapOfCourseKeyVsCurrentCourseObj = new Map<Id,nm_Courses__c> ();
        IsReregistartion = false;
        IsICForMakingPayment = false;
        IsHOForMakingPayment = false;
        allowPayment = false;
        isFormSubmitted = true;
        InstallmentPayFor = '';

        errMessages = '';
        strSecToShow = 'main';
        returnUrl = '';
    }

    public Id getObjectId() {
        return this.objectId;
    }

    public void setObjectId(Id objectId) {
        this.objectId = objectId;
       
        if(String.isNotBlank(this.objectId) && String.isBlank(leadId) && isCalled==false) {
            this.isCalled=true;
            // initalizeVariables();
            queryLeadAccountOpportunityAndPaymentRelatedDetails(this.objectId);
            findPaymentsMade();
            configurePaymentOption();
        }
    }

    public String getObjectType() {
        return this.objectType;
    }

    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    /**
    * @description 
    * @author @BK | 06-08-2024 
    * @param String status 
    * @param String icRecodType 
    **/
    public void isFormSubmittedCheck(String status, String icRecodType){
        List<String> lstStatus = new List<String>{'Registration Form Filled','Registration Fee Paid','Registration Fee Disapproved By Finance','Admission Fee Paid'};
        if(!lstStatus.contains(status) || icRecodType != 'Information Center'){
            isFormSubmitted=false;
        } 
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param Id recordId 
    **/
    public void queryLeadAccountOpportunityAndPaymentRelatedDetails(Id recordId){
        String leadQueryString = 'SELECT id,nm_Program__r.prgst__c,nm_Program__r.nm_TotalSemesters__c,nm_InformationCenter__r.ConsumerType__c,nm_InformationCenter__r.Nm_Active__c,nm_Program__r.IsTerm__c,'+
                                'nm_InformationCenter__r.Contact_No_1__c,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.recordtype__c,Coursera__c,IsConverted,ConvertedAccountId,'+
                                'Loan_Type__c,EMI_Amount__c,Capital_Float_Processing_Fee__c,nm_Fee_Type__c,EMI_Processing_Fee_Capital_Float__c,Down_Payment_Made__c,ConvertedOpportunityId,Loan_Approved__c,'+
                                'Are_you_from_Defence__c,Is_Lateral__c,nm_Year__c,nm_Session__c,nm_ChooseaProgram__c,Program_Type__c,No_Of_Installment_Allowed__c,Form_Id__c,nm_Program__r.Bachelor_Specialization__c,'+
                                'nm_Semester__c,Student_Number_Lateral__c,nm_RegistrationNo__c,nm_InformationCenter__c,Tenure__c,Interest_Rate__c,DP_EMI_Processing_Fee__c,Is_Already_Qualified__c,Loan_Amount__c,'+
                                'IC_Name__c,FirstName,LastName,Email,MobilePhone,Status,nm_EligiblityCriteria__c,nm_Eligibility_Criteria_Ref__c,nm_HouseNumber__c,Street,City,nm_Program__r.Form_Specialisation__c,'+
                                'State,PostalCode,Country,Locality_Name_Shipping__c,House_No_Name_Shipping__c,Shipping_Street__c,Shipping_City__c,LC_name__c,State_Province_Shipping__c,nm_Tagged_Pricebook__c,'+
                                'Zip_Postal_Code_Shipping__c,Country_Shipping__c,nm_Program__c,nm_ProgramName__c,Career_Service__c,LiveLecturesType__c,CourseList__c,nm_PaymentStatus__c,nm_Program__r.AvanseAPICode__c FROM Lead'+
                                ' WHERE id=:recordId and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null LIMIT 1';
        System.debug(''+leadQueryString);
        List<Lead> lstLead = DataBase.query(leadQueryString);
        if(lstLead.size() > 0 && lstLead[0].IsConverted) {
            if(String.isBlank(opportunityId)) {
                recordId = lstLead[0].ConvertedAccountId;
                leadId = recordId;
                opportunityId = lstLead[0].ConvertedOpportunityId;
            }
            System.debug('Lead is converted==>'+ lstLead[0].ConvertedAccountId +' '+ lstLead[0].ConvertedOpportunityId);
            lstLead = new List<Lead>();
        }
        String accountAdmissionQueryString = getQueryAllFieldSql('Account','Id=:recordId','nm_Centers__r.Contact_No_1__c,nm_Program__r.AvanseAPICode__c');
        System.debug('accountAdmissionQueryString ==>');
        System.debug(accountAdmissionQueryString);
        String centerAddressQueryString = getQueryAllFieldSql('nm_Centers__c',' Nm_Active__c = true ',null);
        Map<String,String> mapOfCenterNameAndCenterAddress = new Map<String,String>();
        // create Map Of Center Name and Center Address
        List<nm_Centers__c> lstCenters = DataBase.query(centerAddressQueryString);
        if(lstCenters.size() > 0) {
            for(nm_Centers__c objCenter : lstCenters){
                mapOfCenterNameAndCenterAddress.put(objCenter.id,objCenter.Name+'\n'+objCenter.Address__c);
            }
            lstCenters = null;
        }
        if(lstLead.size() > 0 ){
            System.debug('leadQueryString-->'+leadQueryString);
            objLead =  lstLead[0];
            leadId = objLead.Id;
            isFormSubmittedCheck(objLead.Status, objLead.nm_InformationCenter__r.recordtype__c);
            objLoanDetails.LoanType = objLead.Loan_Type__c;
            System.debug('EMI----0'+objLead.EMI_Amount__c);
            objLoanDetails.EMI = objLead.EMI_Amount__c;
            objLoanDetails.processingFee = objLead.Capital_Float_Processing_Fee__c;
            objLoanDetails.EMIFeeType = objLead.nm_Fee_Type__c;
            objLoanDetails.EMI_Processing_Fee = objLead.EMI_Processing_Fee_Capital_Float__c;
            if(objLead.Down_Payment_Made__c){// down Payment done then only show EMI Option for Capital float
                objLoanDetails.showEMIOption = true;
                objLoanDetails.isLoanOpted = true;
                objLoanDetails.loanApproved = objLead.Loan_Approved__c;
                objLoanDetails.loanAmount = String.isNotBlank(objLead.Loan_Amount__c) ? Decimal.valueOf(objLead.Loan_Amount__c) : 0;
            }
            objDetails.feeType = objLead.nm_Fee_Type__c;
            objDetails.liveLecType = objLead.LiveLecturesType__c;
            objDetails.courseList = objLead.CourseList__c;
            objDetails.consumerType = objLead.nm_InformationCenter__r.ConsumerType__c;
            objDetails.IsDefence = objLead.Are_you_from_Defence__c =='Yes'?true:false;
            objDetails.IsLateral = objLead.Is_Lateral__c;
            currentAdmissionYear = String.valueOf(objLead.nm_Year__c);
            currentAdmissionSession = objLead.nm_Session__c;
            programCategory = objLead.nm_ChooseaProgram__c;
            programSpecialization  = objLead.Program_Type__c;
            objDetails.subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
            objDetails.intTotalInstallmentOptionAvaliable = Integer.valueOf(objLead.No_Of_Installment_Allowed__c);
            programType = 'Admission';
            objDetails.totalsem = objLead.nm_Program__r.nm_TotalSemesters__c;
            semester = objLead.nm_Semester__c;
            objDetails.LateralStudentNo = objLead.Student_Number_Lateral__c;
            objDetails.centerAddressForDD = mapOfCenterNameAndCenterAddress.get(objLead.nm_InformationCenter__c);
            objDetails.ICName = objLead.IC_Name__c;
            objDetails.ICContact = objLead.nm_InformationCenter__r.Contact_No_1__c;

            //  Student Details
            objStudentDetails.studentNo = objLead.nm_RegistrationNo__c;
            objStudentDetails.studentName = objLead.FirstName +' '+objLead.LastName;
            objStudentDetails.firstName = objLead.FirstName;
            objStudentDetails.lastName = objLead.LastName;
            objStudentDetails.studentEmail = objLead.Email;
            objStudentDetails.studentMobileNo = objLead.MobilePhone;
            objStudentDetails.eligibility = objLead.nm_Eligibility_Criteria_Ref__c;
            objStudentDetails.studentAddress = objLead.nm_HouseNumber__c +','+ objLead.Street +','+objLead.City+','+objLead.State+','+objLead.PostalCode+','+objLead.Country;
            objStudentDetails.studentCity = objLead.City;
            objStudentDetails.studentCountry = objLead.Country;
            objStudentDetails.studentPincode = objLead.PostalCode;

            String locality = '';
            if(String.isNotBlank(objLead.Locality_Name_Shipping__c)) {
                locality = objLead.Locality_Name_Shipping__c+',';
            }
            objStudentDetails.studentShippingAddress = objLead.House_No_Name_Shipping__c+','+objLead.Shipping_Street__c+','+locality+objLead.Shipping_City__c +','+objLead.State_Province_Shipping__c+','+objLead.Zip_Postal_Code_Shipping__c+','+objLead.Country_Shipping__c;
            objDetails.programId = objLead.nm_Program__c;
            objDetails.programName = objLead.nm_ProgramName__c;
            objDetails.programSpecialisaton = objLead.nm_Program__r.Form_Specialisation__c;
            objDetails.program = objLead.nm_Program__r.Bachelor_Specialization__c;
            objDetails.programStructure = objLead.nm_Program__r.prgst__c;
            objDetails.isTerm = objLead.nm_Program__r.IsTerm__c;
            if(String.isNotBlank(objLead.Career_Service__c)){
                objDetails.CareerServicePackage = true; 
            }
            if (objLead.Is_Already_Qualified__c) {
                errorMsg ='Lead already qualified with another partner';
            }
            objCoursera.isCourseraAlreadyOpted = objLead.Coursera__c;
            objDetails.hasAvanseProgramCode = String.isNotBlank(objLead.nm_Program__r.AvanseAPICode__c) ? true : false;
        } else {
            System.debug('Account -->');
            List<Account> lstAccounts = DataBase.query(accountAdmissionQueryString);
            nm_StudentProgram__c objStudentProgram = new nm_StudentProgram__c();
            if(lstAccounts.size()>0){
                objAccount =  lstAccounts[0];
                leadId = objAccount.nm_LeadId__c;
                List<Lead> lstNLead = [SELECT id,ConvertedOpportunityId FROM Lead WHERE Id=:leadId LIMIT 1];
                if(lstNLead.size() > 0 && lstNLead[0].ConvertedOpportunityId != null) {
                    opportunityId = lstNLead[0].ConvertedOpportunityId;
                } else if(String.isBlank(opportunityId)) {
                    List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE AccountId=:objAccount.Id AND Is_Re_Registration_Payment__c=FALSE ORDER BY Sem__c ASC LIMIT 1];
                    opportunityId = lstOpp.size() > 0 ? lstOpp[0].Id : 'NA';
                }
                objDetails.IsDefence = objAccount.nm_DefencePersonnel__c =='Yes'?true:false;
                objDetails.IsLateral = objAccount.Is_Lateral__c;
                objDetails.TagPriceBookId = objAccount.nm_Tagged_Pricebook__c;
                objDetails.LateralStudentNo = String.valueOf(objAccount.Student_Number_Lateral__c);
                objDetails.centerAddressForDD = mapOfCenterNameAndCenterAddress.get(objAccount.nm_Centers__c);
                objDetails.ICName = objAccount.IC_Name_1__c;
                objDetails.ICContact = objAccount.nm_Centers__r.Contact_No_1__c;
                objDetails.hasAvanseProgramCode = String.isNotBlank(objAccount.nm_Program__r.AvanseAPICode__c) ? true : false;

                objDetails.stagename = objAccount.nmCaptureOpportuntiyStage__c;
                programSpecialization  = objAccount.Program_Type__c;
                objDetails.subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
                programCategory = objAccount.nm_ChooseaProgram__c;
                //  Student Details
                objStudentDetails.studentNo = objAccount.nm_RegistrationNumber__c;
                objStudentDetails.studentName = objAccount.FirstName +' '+objAccount.LastName;
                objStudentDetails.firstName = objAccount.FirstName;
                objStudentDetails.lastName =  objAccount.LastName;
                objStudentDetails.studentNumber = objAccount.nm_StudentNo__c;
                objStudentDetails.studentEmail = objAccount.PersonEmail;
                objStudentDetails.studentMobileNo = objAccount.PersonMobilePhone;
                objStudentDetails.eligibility = objAccount.Eligibility_Criteria_Ref__c;
                objStudentDetails.studentAddress = objAccount.nm_HouseNumber__c + ',' +objAccount.BillingStreet +','+objAccount.BillingCity+','+objAccount.BillingState+','+objAccount.BillingPostalCode+','+objAccount.BillingCountry;
                objStudentDetails.studentCity = objAccount.BillingCity;
                objStudentDetails.studentCountry = objAccount.BillingCountry;
                objStudentDetails.studentPincode = objAccount.BillingPostalCode;
                String locality = '';
                if(String.isNotBlank(objAccount.Locality_Name_Shipping__c)) {
                    locality = objAccount.Locality_Name_Shipping__c + ',';
                }
                objStudentDetails.studentShippingAddress = objAccount.House_No_Name_Shipping_Account__c+','+objAccount.Shipping_Street__c+','+locality+objAccount.City_Shipping_Account__c +','+objAccount.State_Province_Shipping__c+','+objAccount.Zip_Postal_Code_Shipping__c+','+objAccount.Country_Shipping__c;
                objDetails.DaysPendingforInitialPayment = objAccount.Interview_status_update_date__c!=null?objAccount.DaysSinceForInitialPayment__c:1;
                objDetails.DaysPendingforAdmissionPayment = objAccount.Days_Since_For_Admission_Payment__c;
                Id accId = objAccount.id;
                String studentProgramQueryString = getQueryAllFieldSql('nm_StudentProgram__c',' nm_Student__c=:accId  limit 1 ',null);
                List<nm_StudentProgram__c> lstStudentProgram = DataBase.query(studentProgramQueryString);
                System.debug('lstStudentProgram --->'+lstStudentProgram );
                if(lstStudentProgram.size() >0 ){
                    objStudentProgram = lstStudentProgram[0];
                    // studentProgramId = objStudentProgram.id;
                    // feePaidSemester = String.valueOf(objStudentProgram.nm_FeesPaidofSemester__c);
                }
            }

            System.debug('opportunityAdmissionQuerString -->'+opportunityId);
            if(String.isNotBlank(opportunityId) && opportunityId != 'NA'){
                String opportunityAdmissionQuerString = getQueryAllFieldSql('Opportunity','id=:opportunityId and nm_Program__c != null and nm_Program__r.nm_TotalSemesters__c != null','nm_Program__r.nm_TotalSemesters__c,nm_Program__r.IsTerm__c,nm_Program__r.Form_Specialisation__c,nm_Program__r.Bachelor_Specialization__c');
                List<Opportunity> lstOpportunity = DataBase.query(opportunityAdmissionQuerString);
                if(lstOpportunity != null && lstOpportunity.size() > 0 ){
                    objOpportunity =  lstOpportunity[0];
                    objDetails.oppExist = true;
                    System.debug('objOpportunity----'+objOpportunity);
                    opportunityId = objOpportunity.id;
                    objDetails.intTotalInstallmentOptionAvaliable = Integer.valueOf(objOpportunity.No_Of_Installment_Allowed__c);
                    currentAdmissionYear = String.valueOf(objOpportunity.nm_year__c);
                    currentAdmissionSession = objOpportunity.nm_Session__c;
                    programCategory = objAccount.nm_ChooseaProgram__c;
                    programType = 'Admission';
                    objDetails.feeType = objOpportunity.nm_Fee_Type__c;
                    objDetails.liveLecType = objOpportunity.LiveLecturesType__c;
                    objDetails.courseList = objOpportunity.CourseList__c;
                    objDetails.backlogList = objOpportunity.BacklogList__c;
                    objStudentDetails.studentNumber = objOpportunity.Student_Number__c;
                    objDetails.consumerType = objOpportunity.ConsumerType__c;
                    semester = objOpportunity.nm_Semester__c;
                    objDetails.programId = objOpportunity.nm_Program__c;
                    objDetails.stagename = objOpportunity.StageName;
                    objLoanDetails.LoanType = objOpportunity.Loan_Type__c;
                    objDetails.totalsem = objOpportunity.nm_Program__r.nm_TotalSemesters__c;
                    programSpecialization  = objOpportunity.Specialisation__c;
                    objDetails.isOpportunityProcessed = objOpportunity.Processed__c;
                    objDetails.subventionPrograms = checkSubventionSchemePrograms(programSpecialization);
                    if(String.isNotBlank(objOpportunity.Career_Service__c)) {
                        objDetails.CareerServicePackage = true;
                    }
                    objCoursera.isCourseraAlreadyOpted = objOpportunity.Coursera__c;
                    // totalamountreceived = objOpportunity.Total_Amount_Received__c  ;
                    objDetails.programName = objOpportunity.ProgramFullName__c;
                    objDetails.programSpecialisaton = objOpportunity.nm_Program__r.Form_Specialisation__c;
                    objDetails.program = objOpportunity.nm_Program__r.Bachelor_Specialization__c;
                    objDetails.programStructure =  objOpportunity.Program_Structure__c;
                    objDetails.actualPeningAmount = objOpportunity.ActualPendingAmount__c;

                    if(objOpportunity.Down_Payment_Made__c){ // down payment done then only show EMI Option for Loan Types
                        objLoanDetails.EMI = objOpportunity.EMI_Amount__c;
                        objLoanDetails.showEMIOption = true;
                        objLoanDetails.processingFee = objOpportunity.Capital_Float_Processing_Fee__c;
                        objLoanDetails.EMIFeeType = objOpportunity.nm_Fee_Type__c;
                        objLoanDetails.EMI_Processing_Fee = objOpportunity.EMI_Processing_Fee_Capital_Float__c;
                        objLoanDetails.isLoanOpted = true;
                        objLoanDetails.loanSanctioned = objOpportunity.Loan_Sanctioned__c;
                        //objLoanDetails.loanApproved = objOpportunity.Loan_Approved__c;
                        objLoanDetails.loanApproved = objOpportunity.Loan_Approved__c || objOpportunity.Loan_Order_Status__c == 'Ready To Disbursed' || objOpportunity.Loan_Order_Status__c == 'DISBURSAL_REQUESTED' || objOpportunity.Loan_Order_Status__c == 'emi.process.completed' ? true : false;                        
                        objLoanDetails.loanAmount = String.isNotBlank(objOpportunity.Loan_Amount__c) ? Decimal.valueOf(objOpportunity.Loan_Amount__c) : 0;                    
                    }
                }
            }
            System.debug('showEMIOption --'+objLoanDetails.showEMIOption );
        }

        //get Payment Form Configuration
        //String payConfigString = 'Session__c =:currentAdmissionSession AND Current_Admission_Year__c =:currentAdmissionYear AND Program_Category__c=:programCategory AND Payment_Type__c =:programType AND Program_Type__c=:programSpecialization';
        String payConfigString = 'Session__c =:currentAdmissionSession and Current_Admission_Year__c =:currentAdmissionYear  and Program_Category__c=:programCategory and Payment_Type__c =:programType and Program_Type__c=:programSpecialization and Payment_Window_EndDate__c>=TODAY';
        Set<String> setOfSemSpec = String.isNotBlank(System.Label.PayConfigSemSpecalisation) ? new Set<String>(System.Label.PayConfigSemSpecalisation.split(';')) : new set<String>();
        if (programType == 'Re-Registration' && String.isNotBlank(programSpecialization) && setOfSemSpec.contains(programSpecialization)) {
            payConfigString = payConfigString + ' AND Semester__c = :semester';
        }
        String queryNMPaymentFormConfigurationString = getQueryAllFieldSql('NM_Payment_Form_Configuration__c',payConfigString ,null);
        List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(queryNMPaymentFormConfigurationString);
        Set<String> setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>();
        Set<String> setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate = new Set<String>();
        System.debug('lstFormConfiguration --'+lstFormConfiguration.size()+'---currentAdmissionSession---'+currentAdmissionSession+'---CurrentAdmissionYear---'+currentAdmissionYear+'---programCategory--'+programCategory +'----programType---'+programType+'----programSpecialization---'+programSpecialization);
        if(lstFormConfiguration.size() >0){
            System.debug('lstFormConfiguration --'+lstFormConfiguration[0]);
            objPaymentFormConfiguration = lstFormConfiguration[0];
            
            objDetails.TagPriceBookId = String.isBlank(objDetails.TagPriceBookId) ? objPaymentFormConfiguration.Price_Book__c : objDetails.TagPriceBookId;
            // objDetails.processingFee = objPaymentFormConfiguration.Capital_Float_Processing_Fee__c ;// processing fee for Capital Float
            objDetails.RegistrationFee = objPaymentFormConfiguration.Registration_Fee__c;
            objDetails.maxInstalmentAmt = objPaymentFormConfiguration.MaxInstalment__c;
            objDetails.ShowCareerServiceOpt  = objPaymentFormConfiguration.ShowCareerManagement__c;
            objDetails.CareerServicePackageName  = String.isNotBlank(objDetails.CareerServicePackageName) ? objDetails.CareerServicePackageName : objPaymentFormConfiguration.Career_Service__c;
            objDetails.IsupGrad = objPaymentFormConfiguration.Use_different_payment_credentials__c;
            objCoursera.showCoursera = objPaymentFormConfiguration.Show_Coursera__c;
            if(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c !=null ){
                setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c.split(','));
            }

            if(objPaymentFormConfiguration.Reg_No_Allowed_For_Loan_After_End_Date__c !=null ){
                setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate = new Set<String>(objPaymentFormConfiguration.Reg_No_Allowed_For_Loan_After_End_Date__c.split(','));
            }
            
            if(objPaymentFormConfiguration.MergeAdmissionFeeWithRegistration__c) {
                objDetails.MergeAdmissionFeeWithRegistration = true;
                objDetails.PartAdmintoReg = objPaymentFormConfiguration.PercentageAtoR__c;
            }
            System.debug('DaysPendingforInitialPayment-->'+objDetails.DaysPendingforInitialPayment);
                if(objPaymentFormConfiguration.ShowInitialAdmissionPayment__c  && objDetails.DaysPendingforInitialPayment >= 0)
            {
                objDetails.ShowInitialAdmissionPayment =true;
                objDetails.InitialAdmissionPaymentAmount = objPaymentFormConfiguration.Initial_Admission_Payment__c;
                objDetails.actualInitialAdmissionPaymentAmount = objPaymentFormConfiguration.Initial_Admission_Payment__c;
            }
            System.debug('ShowInitialAdmissionPayment-->'+objPaymentFormConfiguration.ShowInitialAdmissionPayment__c);

            if(objDetails.RegistrationFee <= 0) {
                objfee.AlreadyPaidRegistrationFee = true;
            }
            objDetails.feeType = String.isBlank(objDetails.feeType) ? 'Admission': objDetails.feeType; 
            
            objDetails.intTotalInstallmentApplicable = Integer.valueOf(objPaymentFormConfiguration.No_Of_Applicable_Installment__c);
            if(objPaymentFormConfiguration.Show_Registration_Payment_Option__c){
                setOfApplicablePaymentOptionForStudent.add('Registration Fee');
            }
            if(objPaymentFormConfiguration.Show_Admission_Payment_Option__c){
                setOfApplicablePaymentOptionForStudent.add('Admission');
            }
            if(objPaymentFormConfiguration.ShowInitialAdmissionPayment__c ){
                setOfApplicablePaymentOptionForStudent.add('InitialAdmission');
            }

            if(objPaymentFormConfiguration.Show_AnnualSemFee_Payment_Option__c &&  (objDetails.totalsem - Integer.valueOf(semester))>=1  && !objDetails.feeType.contains('-Considered') && (objDetails.totalsem - Integer.valueOf(semester))>0){
                setOfApplicablePaymentOptionForStudent.add('AnnualFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            if(objPaymentFormConfiguration.Show_2TermFee_Payment_Option__c &&  (objDetails.totalsem - Integer.valueOf(semester))>=1  && !objDetails.feeType.contains('-Considered') && (objDetails.totalsem - Integer.valueOf(semester))>0){
                setOfApplicablePaymentOptionForStudent.add('2TermFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            if(objPaymentFormConfiguration.Show_MultipleSemFee_Payment_Option__c && Integer.valueOf(semester) == 2 && !objDetails.feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('MultipleSemFee');
            }
            if(objPaymentFormConfiguration.Show_3SemFee_Payment_Option__c &&  (objDetails.totalsem - Integer.valueOf(semester))==2 && !objDetails.feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('3SemFee');
            }
            if(objPaymentFormConfiguration.Show_3TermFee_Payment_Option__c   &&  (objDetails.totalsem - Integer.valueOf(semester))==2 && !objDetails.feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('3TermFee');
            }
            if(objPaymentFormConfiguration.Show_4SemFee_Payment_Option__c &&  (objDetails.totalsem - Integer.valueOf(semester))==3 &&  !objDetails.feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('4SemFee');
            }
            if(objPaymentFormConfiguration.Show_5SemFee_Payment_Option__c &&  (objDetails.totalsem - Integer.valueOf(semester))==4 &&  !objDetails.feeType.contains('-Considered')){
                setOfApplicablePaymentOptionForStudent.add('5SemFee');
            }
            if(objPaymentFormConfiguration.Show_FullFee_Payment_Option__c && !objDetails.IsLateral  &&  Integer.valueOf(semester) == 1  ){
                setOfApplicablePaymentOptionForStudent.add('FullFee');
            } 
            if(objPaymentFormConfiguration.Show_FullFeeLoan_Payment_Option__c  && !objDetails.IsLateral  &&  Integer.valueOf(semester) == 1 ){
                setOfApplicablePaymentOptionForStudent.add('FullFeeLoan');
            }
            if(objPaymentFormConfiguration.Show_AnnualFeeLoan_Payment_Option__c && !objDetails.IsLateral  &&  Integer.valueOf(semester) == 1) {
                setOfApplicablePaymentOptionForStudent.add('AnnualFeeLoan');
            }
            
            // for Advance Certificate Student Show Annual Option
            if(objDetails.programName.startsWith('Advance') && !objDetails.IsLateral && Integer.valueOf(semester) < 2 ){
                setOfApplicablePaymentOptionForStudent.add('AnnualFee');
                system.debug('setOfApplicablePaymentOptionForStudent--->'+setOfApplicablePaymentOptionForStudent);
            }
            
            // show Closure message to Student
            DateTime currentDateTime = DateTime.now();
            if(objPaymentFormConfiguration.Payment_Window_EndDate__c < currentDateTime){
                if(setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.size() > 0){
                    if(!setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.contains(objStudentDetails.studentNo)){
                        objDetails.paymentWindowClosed = true;
                        objDetails.paymentClouserMessage = objPaymentFormConfiguration.Payment_Window_Closure_Message__c;
                    }
                } else {
                    objDetails.paymentWindowClosed = true;
                    objDetails.paymentClouserMessage = objPaymentFormConfiguration.Payment_Window_Closure_Message__c;
                }
            }

            // show loan option
            if(objPaymentFormConfiguration.Loan_Window_EndDate__c < currentDateTime) {
                if(setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate.size() > 0) {
                    if(!setOfStudentAndRegistrationNoAllowedToOptLoanAfterEndDate.contains(objStudentDetails.studentNo)) {
                        objDetails.loanWindowClosed = true;
                    }
                } else {
                    objDetails.loanWindowClosed = true;
                }
            }
        }
        lstFormConfiguration = null;
    }

    /**
    * @description 
    * @author @BK | 04-12-2024 
    * @param String sObjectAPIName 
    * @param String conditionString 
    * @param String relatedField 
    * @return String 
    **/
    public String getQueryAllFieldSql(String sObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(sObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ sObjectAPIName +' where '+conditionString;
        return query;
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
    **/
    public void findPaymentsMade() { 
        List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
        String queryOpportunityPayment = '';
        if(String.isNotBlank(opportunityId)) {
            queryOpportunityPayment = getQueryAllFieldSql('nm_Payment__c' , ' nm_OpportunityNew__c =:opportunityId and nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null and nm_OpportunityNew__c !=null ORDER BY nm_TransactionDate__c ASC',null);
        } else {
            queryOpportunityPayment = getQueryAllFieldSql('nm_Payment__c' , ' nm_Lead__c =:leadId and nm_PaymentStatus__c != \'Transaction Failed\' and nm_PaymentStatus__c != null and nm_Lead__c !=null ORDER BY nm_TransactionDate__c ASC',null);
        }
        lstPayment = DataBase.query(queryOpportunityPayment);
        if(lstPayment.size() > 0){
            getAlreadyPaymentPaidOption(lstPayment);
        }
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param List<nm_Payment__c> lstPayment 
    **/
    public void getAlreadyPaymentPaidOption(List<nm_Payment__c> lstPayment){
        set<String> alreadyPaidOptions = new set<String>();
        alreadyPaidOptions.clear();
        System.debug('--lstPayment---'+lstPayment.size());
        objDetails.intTotalInstallmentApplicable = objDetails.intTotalInstallmentOptionAvaliable != null && objDetails.intTotalInstallmentOptionAvaliable !=0 ? objDetails.intTotalInstallmentOptionAvaliable : objDetails.intTotalInstallmentApplicable;
        for(nm_Payment__c objPay : lstPayment){
            if(objpay.nm_Amount__c != null && objpay.nm_PaymentStatus__c != null && objpay.nm_PaymentType__c != null){
                if(objpay.nm_PaymentStatus__c == 'Payment Made' || objpay.nm_PaymentStatus__c == 'Payment Approved' || objpay.nm_PaymentStatus__c == 'Waived Off' ) {
                    if(objpay.nm_PaymentStatus__c == 'Payment Made' || objpay.nm_PaymentStatus__c == 'Payment Approved') {
                        objDetails.isPaymentMade = true;
                        // objDetails.lstPayments.add(objpay);
                        if(!objDetails.mapOfPaymentsMade.containsKey(objpay.nm_Merchant_Track_Id__c)) {
                            objDetails.mapOfPaymentsMade.put(objpay.nm_Merchant_Track_Id__c,objpay);
                        }
                    }
                    /* To Avoid the payment of inital Amount on the Registration stage,
                    to check wheather the payment is already done. */
                    if(objpay.Consider_Initial_payment__c) {
                        objDetails.initalAmountRecieved = objDetails.initalAmountRecieved + objPay.nm_Amount__c;
                    }

                    objDetails.totalamountreceived += objPay.nm_Amount__c;
                    if( objpay.nm_PaymentType__c == 'Registration' ) {
                        objfee.AlreadyPaidRegistrationFee = true;
                    }else if('Admission'.equalsIgnoreCase(objpay.nm_PaymentType__c)){
                        objfee.AlreadyPaidAdmissionFee = true;
                    }else if('Installment'.equalsIgnoreCase(objPay.nm_PaymentType__c) ){
                        objfee.AlreadyPaidInstallmentAmount += objPay.nm_Amount__c;
                        objDetails.totalProductAmountPaid += objPay.nm_Amount__c;
                        objDetails.totalAmountPaid = objDetails.totalAmountPaid + objfee.AlreadyPaidInstallmentAmount;
                        objDetails.intTotalInstallmentPaid++;
                        //to update the previous payement record as down payemnt 
                        createDownPaymentRecord(objpay);
                        // to check if total Installments paid or not.
                        objfee.AlreadyMadeAllInstallment = objDetails.intTotalInstallmentApplicable == objDetails.intTotalInstallmentPaid;
                    }
                    else if( 'Initial Payment'.equalsIgnoreCase(objPay.nm_PaymentType__c)){
                        objfee.AlreadyPaidInitialAmount += objPay.nm_Amount__c;
                        objDetails.totalProductAmountPaid += objPay.nm_Amount__c;
                        objDetails.totalAmountPaid = objDetails.totalAmountPaid + objfee.AlreadyPaidInitialAmount;
                        //to update the previous payement record as down payemnt
                        createDownPaymentRecord(objpay);
                    }
                    else if('Late Fees'.equalsIgnoreCase(objpay.nm_PaymentType__c)){
                        objfee.AlreadyPaidLateFee = true;
                        objfee.AlreadyPaidLateFeeAmount += objPay.nm_Amount__c;
                    } 
                    else if('Live Lectures'.equalsIgnoreCase(objpay.nm_PaymentType__c)) {
                        objLiveLecturePayment.AlreadyPaidLiveLectureFee = true;
                        objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount = objPay.nm_Amount__c + (objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount > 0 ? objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount : 0);
                        objLiveLecturePayment.LiveLectureTypeOpted = objDetails.liveLecType;
                        objLiveLecturePayment.CourseList = objDetails.courseList;
                    } else if(objpay.nm_PaymentType__c.contains('DownPayment')) {
                        objDetails.totalProductAmountPaid += objPay.nm_Amount__c;
                        objLoanDetails.loanPaymentTrackId = objPay.nm_Merchant_Track_Id__c;
                        objLoanDetails.isDownPaymentMade = true;
                    }
                    if (objPay.nm_PaymentType__c.contains('Admission') || objPay.nm_PaymentType__c =='Installment' || objPay.nm_PaymentType__c.contains('DownPayment') || objPay.nm_PaymentType__c.contains('Subvention') || objPay.nm_PaymentType__c.contains('Initial Payment') || objPay.nm_PaymentType__c =='Additional Charge') {
                        objfee.AlreadyPaidAdmissionFee = true;
                        objAdmissionAmount.isAdmissionAmountPaid = objPay.nm_PaymentType__c.contains('Admission') ? true : objAdmissionAmount.isAdmissionAmountPaid;
                        objAdmissionAmount.admissionAmountPaid += objPay.nm_Amount__c;
                    }
                }

                if(objpay.nm_PaymentType__c == 'Additional Charge' && objpay.nm_PaymentStatus__c == 'Pending Extra Fees') {
                    objAdmissionAmount.isPendingPaymentRecordExists = true;
                    objAdmissionAmount.pendingPaymentRecordId = objpay.Id;
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param nm_Payment__c objPay 
    * @return nm_Payment__c 
    **/
    private nm_Payment__c createDownPaymentRecord(nm_Payment__c objPay){
        objDownPayment = new nm_Payment__c( id=objpay.id,
                                        nm_ActualPaymentAmmount__c=objpay.nm_ActualPaymentAmmount__c,
                                        nm_Installment_Payment_Ref__c=objpay.nm_Installment_Payment_Ref__c,
                                        nm_Merchant_Track_Id__c=objpay.nm_Merchant_Track_Id__c,
                                        nm_PaymentType__c=objPay.nm_PaymentType__c,
                                        nm_PaymentStatus__c=objpay.nm_PaymentStatus__c,
                                        nm_ModeOfPayment__c=objpay.nm_ModeOfPayment__c);
        return objDownPayment;
    }

    /**
    * @description 
    * @author @BK | 28-11-2024 
    **/
    public void configurePaymentOption(){
        // Check if the Price Book ID is missing
        if (String.isBlank(objDetails.TagPriceBookId)) {
            resetPaymentOptions();
            return;
        }
    
        // Fetch Price Book entries and configure payment amounts
        mapOfPricebook = productHelper.getMapOfProductVsPriceBookEntry(objDetails.TagPriceBookId);
        configurePaymentAmount();
    
        jsonMapOfProductAndAmount = JSON.serialize(mapOfProductAndAmount);
    
        if (objPaymentFormConfiguration.ShowLiveLectures__c) {
            objDetails.showliveLectureBasedOnSY = showlivelectureSY(programCategory, objAccount.BatchStartD__c);
            System.debug('showliveLectureBasedOnSY ' + objDetails.showliveLectureBasedOnSY);
            
            if (objDetails.showliveLectureBasedOnSY) {
                handleLiveLecturePayments();
            }
        }

        // handle Additional charge
        setUpAdditionalChargeRedirect();
    }
    
    /**
    * @description 
    * @author @BK | 28-11-2024 
    **/
    private void handleLiveLecturePayments() {
        Integer liveLectureSelected = 0;
    
        System.debug('liveLecType -->' + objDetails.liveLecType);
        System.debug('courseList -->' + objDetails.courseList);
        System.debug('objLiveLecturePayment ==>' + objLiveLecturePayment);
    
        Boolean isLiveLecturePaid = objLiveLecturePayment.AlreadyPaidLiveLectureFee == true ? objLiveLecturePayment.AlreadyPaidLiveLectureFee : false;
    
        if (shouldSelectLiveLecture(liveLectureSelected, isLiveLecturePaid)) {
            liveLectureSelected = Integer.valueOf(objDetails.liveLecType.substring(0, 1));
        }
    
        if (!allowPayment && !isLiveLecturePaid) {
            setOfApplicablePaymentOptionForStudent.add('Custom');
        }
    
        addLiveLecturePaymentOptions(liveLectureSelected);
    }
    
    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @param Integer liveLectureSelected 
    * @param Boolean isLiveLecturePaid 
    * @return Boolean 
    **/
    private Boolean shouldSelectLiveLecture(Integer liveLectureSelected, Boolean isLiveLecturePaid) {
        return ((!IsReregistartion && objAccount.nm_StudentStatus__c == 'Confirmed') || isLiveLecturePaid)
            && String.isNotBlank(objDetails.liveLecType)
            && objDetails.liveLecType != 'Custom'
            && objDetails.liveLecType != 'No';
    }
    
    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @param Integer liveLectureSelected 
    **/
    private void addLiveLecturePaymentOptions(Integer liveLectureSelected) {
        if (objDetails.totalsem >= 1 && shouldAddPaymentOption(1, liveLectureSelected)) {
            setOfApplicablePaymentOptionForStudent.add('1SemLecturesFee');
        }
    
        if ((objDetails.totalsem - Integer.valueOf(semester)) >= 1 && shouldAddPaymentOption(2, liveLectureSelected)) {
            setOfApplicablePaymentOptionForStudent.add('2SemLecturesFee');
        }
    
        if ((objDetails.totalsem - Integer.valueOf(semester)) >= 2 && shouldAddPaymentOption(3, liveLectureSelected)) {
            setOfApplicablePaymentOptionForStudent.add('3SemLecturesFee');
        }
    
        if ((objDetails.totalsem - Integer.valueOf(semester)) >= 3 && shouldAddPaymentOption(4, liveLectureSelected)) {
            setOfApplicablePaymentOptionForStudent.add('4SemLecturesFee');
        }
    }
    
    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @param Integer semesterCount 
    * @param Integer liveLectureSelected 
    * @return Boolean 
    **/
    private Boolean shouldAddPaymentOption(Integer semesterCount, Integer liveLectureSelected) {
        return (String.isNotBlank(objDetails.liveLecType) && !objDetails.liveLecType.contains('-Considered'))
            || String.isBlank(objDetails.liveLecType) && liveLectureSelected < semesterCount;
    }
    

    /**
    * @description 
    * @author @BK | 01-08-2024 
    **/
    private void resetPaymentOptions() {
        setOfApplicablePaymentOptionForStudent.clear();
        setOfPaymentOptionsAvailable.clear();
        errMessages = 'Kindly Fill the Application Form.';
        strSecToShow = 'error';
        returnUrl = '';
    }

    /**
    * @description 
    * @author @BK | 28-11-2024 
    **/
    private void configurePaymentAmount(){
        // Check if the pricebook is available, if not return with an error message
        if (mapOfPricebook == null || mapOfPricebook.isEmpty()) {
            errMessages = 'Product Price not found.';
            strSecToShow = 'error';
            returnUrl = '';
            return;
        }
    
        // Handle late fee logic
        handleLateFee();
    
        // Handle Career Service Fee logic
        handleCareerServiceFee();
    
        // Handle Coursera Fee logic
        handleCourseraFee();
    
        // Handle Admission Fee logic
        handleAdmissionFee();
    
        // Handle Registration Fee logic
        handleRegistrationFee();

        // Handle additional payment options logic
        handleAdditionalPaymentOptions();
    
        // Handle Live Lecture Fees logic
        handleLiveLectureFees();

        // Handle Remaining Loan Due
        handleRemainingLoanDue();
    }
    
    // Method to handle Late Fee logic
    private void handleLateFee() {
        // Apply late fee if applicable and the opportunity is not processed
        if (objPaymentFormConfiguration.Is_Late_Fee_Applicable__c && !objDetails.isOpportunityProcessed) {
            objDetails.applicableLateFee = getLateFeeAmount();
            objAdmissionAmount.isLateFeePending = objDetails.applicableLateFee > 0;
            System.debug('applicableLateFee --->' + objDetails.applicableLateFee);
        }
    }
    
    // Method to handle Career Service Fee logic
    private void handleCareerServiceFee() {
        // If Career Service is opted by the student, calculate the applicable fee
        if (objPaymentFormConfiguration.ShowCareerManagement__c && objDetails.CareerServiceOpted) {
            objDetails.applicableCareerServiceFee = getCareerServiceFee();
        } else {
            // Otherwise, assign a default value for the Career Service fee
            objDetails.applicableCareerServiceFee = getDefaultCareerServiceFee();
        }
        System.debug('applicableCareerServiceFee --->' + objDetails.applicableCareerServiceFee);
    }
    
    // Method to get the Career Service Fee based on the selected package
    private Decimal getCareerServiceFee() {
        // If a specific Career Service package is selected, return the price for that package
        if (String.isNotBlank(objDetails.CareerServicePackageName)) {
            return mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice;
        }
        // Default Career Service package price
        return mapOfPricebook.get('Career Development').UnitPrice;
    }
    
    // Method to get the default Career Service Fee
    private Decimal getDefaultCareerServiceFee() {
        // If the selected package has a valid price, return it; otherwise, return 0
        return (mapOfPricebook.containsKey(objDetails.CareerServicePackageName) 
                && mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice > 0) 
               ? mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice 
               : 0;
    }
    
    // Method to handle Coursera Fee logic
    private void handleCourseraFee() {
        // If Coursera is opted by the student, set the applicable fee
        if (objPaymentFormConfiguration.Show_Coursera__c && objCoursera.checkCourseraOpted) {
            objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
        } else {
            // Otherwise, set the Coursera fee to 0
            objCoursera.applicableCourseraFee = 0;
        }
        System.debug('applicableCourseraFee --->' + objCoursera.applicableCourseraFee);
    }
    
    // Method to handle Admission Fee logic
    private void handleAdmissionFee() {
        // If opportunity ID is blank or 'NA', check if admission fee should be merged with registration fee
        if (String.isBlank(opportunityId) || opportunityId == 'NA') {
            if (objDetails.MergeAdmissionFeeWithRegistration) {
                handleAdmissionFeeWithRegistration();
            }
        }
    }
    
    // Method to handle logic where Admission Fee is merged with Registration Fee
    private void handleAdmissionFeeWithRegistration() {
        objDetails.applicableAwithR = objDetails.PartAdmintoReg;
    
        // If the initial payment exceeds or equals the applicable amount, reset the flag and applicable fee
        if (objDetails.initalAmountRecieved >= objDetails.applicableAwithR) {
            objDetails.MergeAdmissionFeeWithRegistration = false;
            objDetails.applicableAwithR = 0;
        } else if (objDetails.initalAmountRecieved > 0) {
            // Otherwise, reduce the applicable fee by the amount already received
            objDetails.applicableAwithR -= objDetails.initalAmountRecieved;
        }
    
        System.debug('initalAmountRecieved ==> ' + objDetails.initalAmountRecieved);
        System.debug('applicableAwithR ==> ' + objDetails.applicableAwithR);
    }
    
    // Method to handle Registration Fee logic
    private void handleRegistrationFee() {
        // If admission fee is merged with registration, apply the combined amount
        if (objDetails.MergeAdmissionFeeWithRegistration && objDetails.applicableAwithR != null) {
            mapOfProductAndAmount.put('Registration Fee', objDetails.RegistrationFee.setScale(2));
            mapOfProductAndAmount.put('Initial Payment', objDetails.applicableAwithR.setScale(2));
        } else {
            // Otherwise, apply only the registration fee
            mapOfProductAndAmount.put('Registration Fee', objDetails.RegistrationFee.setScale(2));
        }
    
        // If the initial admission payment option is shown, calculate the remaining fee
        if (objDetails.ShowInitialAdmissionPayment) {
            if (objDetails.totalAmountPaid > 0) {
                objDetails.InitialAdmissionPaymentAmount -= objDetails.totalAmountPaid;
            }
            mapOfProductAndAmount.put('InitialAdmissionFee', objDetails.InitialAdmissionPaymentAmount.setScale(2));
        }
    }
    
    // Method to handle additional payment options logic
    private void handleAdditionalPaymentOptions() {
        // Define a set of payment options that shouldn't be added to the available options
        Set<String> setOfoptionsTONotChecked = new Set<String>{'Registration Fee', 'InitialAdmission'};
    
        // Loop through each applicable payment option and handle it
        for (String paymentOption : setOfApplicablePaymentOptionForStudent) {
            if (!setOfoptionsTONotChecked.contains(paymentOption)) {
                handlePaymentOption(paymentOption);
            }
        }
    }
    
    // Method to handle the logic for a specific payment option (e.g., Admission, Annual Fee, etc.)
    private void handlePaymentOption(String paymentOption) {
        // If it's an Admission fee, calculate it based on the opportunity or lead
        String key = paymentOption == 'Admission' ? getAdmissionKey() : getProductKey(paymentOption);
        Decimal productPrice = productPricing(paymentOption, getmultiplicationFactor(paymentOption), key);
        if (productPrice > objAdmissionAmount.admissionAmountPaid) {
            setOfPaymentOptionsAvailable.add(paymentOption);
            mapOfProductAndAmount.put(paymentOption, productPrice - objAdmissionAmount.admissionAmountPaid);
        }
    }
    
    // Method to get the admission key based on Opportunity or Lead
    private String getAdmissionKey() {
        return String.isNotBlank(opportunityId) && opportunityId != 'NA' 
            ? objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c 
            : objLead.nm_Program__c + '-' + objLead.nm_Semester__c;
    }
    
    // Method to get the product key for different options
    private String getProductKey(String paymentOption) {
        String productOption = paymentOption == 'AnnualFee' ? 'Annual' : paymentOption;
        return mapOfPricebook.containsKey(productOption + '-' + objDetails.programId) ? productOption + '-' + objDetails.programId : productOption;
    }

    // Method to handle Live Lecture Fees logic
    public void handleLiveLectureFees() {
        // Check if Live Lectures are configured to show
        if (objPaymentFormConfiguration.ShowLiveLectures__c) {
            objDetails.showliveLectureBasedOnSY = showlivelectureSY(programCategory, objAccount.BatchStartD__c);
            System.debug('objDetails.showliveLectureBasedOnSY ' + objDetails.showliveLectureBasedOnSY);

            if (objDetails.showliveLectureBasedOnSY) {
                handleLectureFeeCalculations();
            }
        }
    }

    // Method to handle the live lecture fee calculations
    private void handleLectureFeeCalculations() {
        
        Map<String, Decimal> mapOfliveLecTypeAndSubjects = new Map<String, Decimal>();

        // Get Live Lecture and Backlog Price from Pricebook
        Decimal liveLecturePrice = mapOfPricebook.containsKey('Live Lectures') ? mapOfPricebook.get('Live Lectures').UnitPrice : 0;
        Decimal backlogPrice = mapOfPricebook.containsKey('Backlog') ? mapOfPricebook.get('Backlog').UnitPrice : 0;

        // Apply service tax for Certificate Programs
        if ('Certificate Programs'.equalsIgnoreCase(programCategory) && liveLecturePrice > 0) {
            liveLecturePrice = liveLecturePrice + (liveLecturePrice * Decimal.valueOf(System.Label.Service_Tax).setScale(2));
        }
        System.debug('liveLecturePrice ==>' + liveLecturePrice);

        // Initialize Live Lecture Payment if it's null
        initializeLiveLecturePayment();

        // Handle each semester's live lecture fee calculation
        addLiveLectureFeeForSemester('1SemLecturesFee', mapOfliveLecTypeAndSubjects, liveLecturePrice, 1);
        addLiveLectureFeeForSemester('2SemLecturesFee', mapOfliveLecTypeAndSubjects, liveLecturePrice, 2);
        addLiveLectureFeeForSemester('3SemLecturesFee', mapOfliveLecTypeAndSubjects, liveLecturePrice, 3);
        addLiveLectureFeeForSemester('4SemLecturesFee', mapOfliveLecTypeAndSubjects, liveLecturePrice, 4);

        // Add additional fees for Live Lectures and Backlogs
        mapOfProductAndAmount.put('Live Lectures', liveLecturePrice);
        mapOfProductAndAmount.put('Backlog', backlogPrice);

        // Handle custom course fees if applicable
        handleCustomCourseFees(liveLecturePrice);

        // Serialize map of live lecture types and subjects for further processing
        seralizeLiveLecturesType(mapOfliveLecTypeAndSubjects);

        // Handle any backlog data if necessary
        handleBacklogDataIfNeeded();
    }

    // Helper method to initialize the Live Lecture Payment if it is not already initialized
    private void initializeLiveLecturePayment() {
        if (objLiveLecturePayment.AlreadyPaidLiveLectureFee == null) {
            objLiveLecturePayment.CourseList = '';
            objLiveLecturePayment.LiveLectureTypeOpted = '';
            objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount = 0.0;
            objLiveLecturePayment.AlreadyPaidLiveLectureFee = false;
        }
    }

    // Helper method to calculate and update semester-specific live lecture fees
    private void addLiveLectureFeeForSemester(String semesterKey, Map<String, Decimal> mapOfliveLecTypeAndSubjects, Decimal liveLecturePrice, Integer sem) {

        if (!mapOfProductAndAmount.containsKey(semesterKey)) {
            Decimal totalSubjects = productHelper.TotalNumberOfSubject(Integer.valueOf(semester), objDetails.programStructure, 
                                                                        objDetails.programId, semesterKey, '', objDetails.consumerType);
            mapOfliveLecTypeAndSubjects.put(semesterKey, totalSubjects + sem);

            Decimal price = (liveLecturePrice * totalSubjects) - objLiveLecturePayment.AlreadyPaidLiveLectureFeeAmount;
            mapOfProductAndAmount.put(semesterKey, price);
            System.debug(semesterKey + '---->' + mapOfProductAndAmount.get(semesterKey));
        }
    }

    // Helper method to handle custom course fees for live lectures
    private void handleCustomCourseFees(Decimal liveLecturePrice) {
        if (String.isNotBlank(objDetails.courseList)) {
            Decimal price = (liveLecturePrice * productHelper.TotalNumberOfSubject(Integer.valueOf(semester), objDetails.programStructure, 
                                                                                 objDetails.programId, 'Custom', objDetails.courseList, objDetails.consumerType));
            mapOfProductAndAmount.put('CustomLive', price);
        }
    }

    // Serialize map of live lecture types and subjects for further processing
    private void seralizeLiveLecturesType(Map<String, Decimal> mapOfliveLecTypeAndSubjects) {
        mapOfCourseKeyVsCourseObj = productHelper.getMapOfProgramNamekeyVsCourses();
        String mapKey = objDetails.programId+'-'+objDetails.programStructure+'-'+Integer.valueof(semester)+'-'+objDetails.consumerType;
        mapOfCourseKeyVsCurrentCourseObj = mapOfCourseKeyVsCourseObj.get(mapKey);
        jsonMapOfLectureTypeAndSubjects = String.isBlank(jsonMapOfLectureTypeAndSubjects) 
                                          ? JSON.serialize(mapOfliveLecTypeAndSubjects) 
                                          : jsonMapOfLectureTypeAndSubjects;
    }

    // Helper method to handle backlog data retrieval if necessary
    private void handleBacklogDataIfNeeded() {
        if (String.isNotBlank(objStudentDetails.studentNumber) && !allowPayment) {
            getBacklogDataFromStudentZone(objStudentDetails.studentNumber);
        }
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param String productName 
    * @param Integer multiplicationFactor 
    * @param String programKey 
    * @return Decimal 
    **/
    private Decimal productPricing(String productName,Integer multiplicationFactor,String programKey){
            
        Decimal amount = 0;
        Integer sem = String.isNotBlank(semester) ? Integer.valueof(semester) : 0;
        System.debug('--programKey---'+programKey+'-productName-'+productName+'programSpecialization--->'+programSpecialization);            
        if('BA'.equalsIgnoreCase(programSpecialization) && (productName =='AnnualFee' || productName =='3SemFee')) {
            for(Integer i = sem ;i<=(sem + multiplicationFactor - 1);i++) {
                System.debug('--multiplicationFactor---'+i+'-----'+objDetails.programId);  
                amount += mapOfPricebook.containsKey(objDetails.programId+'-'+i) ? mapOfPricebook.get(objDetails.programId+'-'+i).UnitPrice:0;
                System.debug('amount---->'+amount);        
            }
            if(productName =='AnnualFee') {
                amount = amount * 0.94;
                System.debug('amount---->'+amount);   
            } else if(productName =='3SemFee' ) {
                amount = amount * 0.92;
                System.debug('amount---->'+amount);   
            }
        }
        else if(mapOfPricebook.containsKey(programKey)) {
            System.debug('enter programName '+programKey);
            amount = mapOfPricebook.get(programKey).UnitPrice;   
        } 
        else {
            System.debug('not found '+programKey);
        }
        
        if(objDetails.IsDefence) {
            amount = amount * 0.8;
        }

        // service Tax for Certificate Program 
        if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
            amount += amount * Decimal.valueOf(System.Label.Service_Tax).setScale(2);
        }
        System.debug('CareerServiceOpted -->'+objDetails.CareerServiceOpted);
        if((objDetails.totalamountreceived >= (objDetails.RegistrationFee + objDetails.actualInitialAdmissionPaymentAmount)) 
            && objDetails.ShowInitialAdmissionPayment) {
            objfee.AlreadyPaidInitialAdmissionfee =true;
        }
        
        System.debug('AlreadyPaidInitialAmount--->'+objfee.AlreadyPaidInitialAmount );
        System.debug('amount--->'+amount+'---productName---'+productName);

        mapOfProductAndAmount.put(productName,amount.setScale(2));
        return amount.setScale(2);
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
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

    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @return Decimal 
    **/
    private Decimal getLateFeeAmount() {
        Decimal lateFeeAmount = 0;
        String lateFeeCategory = determineLateFeeCategory();
    
        // Check for admission late fee
        if (objDetails.DaysPendingforAdmissionPayment == -1) {
            lateFeeAmount += getDecimalValue(System.Label.AdmissionLatefeeMBAWX);
        }
    
        // Query late fees from database
        lateFeeAmount += fetchLateFeeFromDatabase(lateFeeCategory);
    
        // Adjust late fee amount based on already paid late fees
        lateFeeAmount = adjustLateFeeForAlreadyPaidAmount(lateFeeAmount);
    
        // Ensure late fee amount is non-negative
        return Math.max(lateFeeAmount, 0);
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @return String 
    **/
    private String determineLateFeeCategory() {
        return objDetails.IsLateral && programType == 'Admission' ? 'Is Lateral' : programType;
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param String label 
    * @return Decimal 
    **/
    private Decimal getDecimalValue(String label) {
        return Decimal.valueOf(label).setScale(2);
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param String lateFeeCategory 
    * @return Decimal 
    **/
    private Decimal fetchLateFeeFromDatabase(String lateFeeCategory) {
        List<Late_Fee__c> lateFeeRecords = [
            SELECT Late_Fees__c, Start_Date__c
            FROM Late_Fee__c
            WHERE Category__c = :lateFeeCategory
              AND nm_Type__c = :programCategory
              AND Program_Type__c = :programSpecialization
              AND Session__c = :currentAdmissionSession
              AND Year__c = :currentAdmissionYear
              AND Start_Date__c <= TODAY
              AND End_Date__c >= TODAY
        ];
    
        if (lateFeeRecords.isEmpty()) {
            return 0;
        }
    
        // Set start date for late fee
        objDetails.lateFeeStartDate = lateFeeRecords[0].Start_Date__c;
        return lateFeeRecords[0].Late_Fees__c;
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param Decimal lateFeeAmount 
    * @return Decimal 
    **/
    private Decimal adjustLateFeeForAlreadyPaidAmount(Decimal lateFeeAmount) {
        if (lateFeeAmount > 0 && objfee.AlreadyPaidLateFeeAmount > 0 && objfee.AlreadyPaidLateFee) {
            if (isCertificateOrExecutiveProgram()) {
                lateFeeAmount += lateFeeAmount * getDecimalValue(System.Label.Service_Tax);
            }
            lateFeeAmount -= objfee.AlreadyPaidLateFeeAmount;
        } else if (isCertificateOrExecutiveProgram()) {
            lateFeeAmount += lateFeeAmount * getDecimalValue(System.Label.Service_Tax);
        }
    
        return lateFeeAmount;
    }
    
    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @return Boolean 
    **/
    private Boolean isCertificateOrExecutiveProgram() {
        return 'Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory);
    }

    /**
    * @description 
    * @author @BK | 04-12-2024 
    * @param String programCategory 
    * @param Date batchStartDate 
    * @return Boolean 
    **/
    public Boolean showlivelectureSY(String programCategory, Date batchStartDate){
        Date checkDate = Date.parse(System.Label.LiveLectureAllowForReRegDate);
        System.debug('checkDate '+checkDate);
        if(programCategory == 'Diploma Programs' && ((batchStartDate >= checkDate && IsReregistartion) || !IsReregistartion)){
            return true;
        }else if(programCategory != 'Diploma Programs'){
            return true;
        }else{
            return false;
        }
    }

    /**
    * @description 
    * @author @BK | 04-12-2024 
    **/
    public void handleRemainingLoanDue() {
        Decimal pendingAmount = 0;
        if(objLoanDetails.loanAmount > 0 && objDetails.actualPeningAmount >= objLoanDetails.loanAmount && objLoanDetails.loanApproved) {
            pendingAmount = objDetails.actualPeningAmount - objLoanDetails.loanAmount;
        }
        if(objDetails.actualPeningAmount > 0 && (objAdmissionAmount.isAdmissionAmountPaid || pendingAmount > 0)) {
            objAdmissionAmount.hasUnpaidLoanBalance = true;
        }
    }


    /**
    * @description 
    * @author @BK | 04-12-2024 
    **/
    public void setUpAdditionalChargeRedirect() {
        objAdmissionAmount.returnURL = '';
        objAdmissionAmount.isRedirect = false;
        if(objAdmissionAmount.isPendingPaymentRecordExists) {
            objAdmissionAmount.returnURL = 'nmAdditonalCharge?id=' + objAdmissionAmount.pendingPaymentRecordId;
            objAdmissionAmount.isRedirect = true;
        } else if((objAdmissionAmount.isAdmissionAmountPaid || objLoanDetails.loanApproved) && (objAdmissionAmount.isLateFeePending || objAdmissionAmount.hasUnpaidLoanBalance)) {
            objAdmissionAmount.returnURL = 'nmAdditonalCharge?id=' + opportunityId;
            objAdmissionAmount.isRedirect = true;
        }
    }

    /**
    * @description 
    * @author @BK | 01-08-2024 
    * @param String programSpecialization 
    * @return Boolean 
    **/
    public Boolean checkSubventionSchemePrograms(String programSpecialization){
        String checkSubventionPrograms = System.Label.Subvention_Scheme_Programs;
        List<String> keys = checkSubventionPrograms.split(',');
        if(String.isNotBlank(programSpecialization) && JSON.serialize(keys).contains(programSpecialization)) {
            return true;
        }
        return false;
    }

    public PageReference makeOnlinePayment(){
        System.debug('paymentFor ---'+paymentFor);
        System.debug('recordId----'+leadId);
        List<Lead> ld = new List<Lead>();
        if(!IsReregistartion){
            ld = [SELECT Id,IsConverted from Lead Where Id=:leadId];
        }
        System.debug('ld convert check '+ld);
        if((ld.size() > 0 && ld[0].IsConverted) && String.isBlank(opportunityId) && !objDetails.oppExist && !IsReregistartion){
            strSecToShow ='PopUpError';
            errMessages ='Something went wrong please login again to continue..';
            returnUrl ='/Login';
            return null;
        } else {
            if((((objLead.LC_name__c != objLead.IC_Name__c || (objLead.nm_InformationCenter__r.nm_LearningCenter__c == null && objLead.nm_InformationCenter__r.recordtype__c == 'Information Center')) 
            && opportunityId ==null && ((objLead.nm_InformationCenter__r.ConsumerType__c == 'Retail' && objLead.nm_InformationCenter__r.Nm_Active__c) || objLead.nm_InformationCenter__r.ConsumerType__c == 'Corporate')) || IsReregistartion || (opportunityId !=null) || 'Verizon'.equalsIgnoreCase(objDetails.ICName)) && !'Counsellor'.equalsIgnoreCase(objDetails.ICName)){
                if(String.isNotBlank(paymentFor)){
                    //Creating payment tracking Id. 
                    string strTranTrackid = objStudentDetails.studentNo+''+datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
                    +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.floor(1000 + Math.random()*9000));
    
                    objDetails.courseListWithBacklogList = String.isNotBlank(objDetails.backlogList) ? objDetails.courseList + '-' + objDetails.backlogList : objDetails.courseList ;
                    strTranTrackid = strTranTrackid.right(30);
                    nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
                    objOnlinePayment.TranTrackid = strTranTrackid;
                    objOnlinePayment.strAddress = objStudentDetails.studentAddress;
                    objOnlinePayment.strCity = objStudentDetails.studentCity;
                    objOnlinePayment.strCountry = objStudentDetails.studentCountry;
                    objOnlinePayment.strPincode = objStudentDetails.studentPincode;
                    objOnlinePayment.strName = objStudentDetails.studentName;
                    objOnlinePayment.strEmailId = objStudentDetails.studentEmail;
                    objOnlinePayment.strMobileNumber = objStudentDetails.studentMobileNo;
                    objOnlinePayment.recordId = leadId;
                    objOnlinePayment.opportunityId = opportunityId;
                    objOnlinePayment.InstallmentAmount = String.valueOf(depositAmount);
                    objOnlinePayment.strPaymentType = paymentFor;
                    objOnlinePayment.InstallmentPayOpt = InstallmentPayFor;
                    objOnlinePayment.studentNo = objStudentDetails.studentNo;
                    System.debug('CareerServiceOpted check -->'+objDetails.CareerServiceOpted);
                    objOnlinePayment.IsOptedForCareerService = objDetails.CareerServiceOpted;
                    objOnlinePayment.isCourseraOpted = objCoursera.checkCourseraOpted;
                    objOnlinePayment.IsupGrad = objDetails.IsupGrad;
                    // for record + live
                    objOnlinePayment.liveLecType = String.isBlank(objDetails.liveLecType) || (objDetails.liveLecType=='Custom' && String.isBlank(objDetails.courseList)) ? 'No' : objDetails.liveLecType;
                    objOnlinePayment.courseList = String.isNotBlank(objDetails.courseListWithBacklogList) ? objDetails.courseListWithBacklogList : null;
                    
                    if(objDetails.IsupGrad) {
                        objOnlinePayment.Paytm_MerchantKey = objPaymentFormConfiguration.Paytm_Website_Key__c;
                        objOnlinePayment.Paytm_IndustryId = objPaymentFormConfiguration.Paytm_IndustryId__c;
                        objOnlinePayment.Paytm_MID = objPaymentFormConfiguration.Paytm_MID__c;
                        objOnlinePayment.Paytm_EncryptionKey = objPaymentFormConfiguration.Paytm_EncryptionKey__c;
                        objOnlinePayment.HDFC_SecretKey = objPaymentFormConfiguration.HDFC_SecretKey__c;
                        objOnlinePayment.HDFC_SALT = objPaymentFormConfiguration.HDFC_SALT__c;
                    }
                    
                    System.debug('CareerServiceOpted '+objDetails.CareerServiceOpted+' CareerServicePackageName -->'+objDetails.CareerServicePackageName+' applicableCareerServiceFee '+objDetails.applicableCareerServiceFee+' ShowCareerServiceOpt '+objDetails.ShowCareerServiceOpt);
                    if(objDetails.CareerServiceOpted && objDetails.applicableCareerServiceFee == 0 && objDetails.ShowCareerServiceOpt ) {
                        System.debug('Enter in carrer service '+objDetails.CareerServicePackageName);
                        if(String.isNotBlank(objDetails.CareerServicePackageName)) {
                            objDetails.applicableCareerServiceFee = mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice; 
                        } else {
                            objDetails.applicableCareerServiceFee = mapOfPricebook.get('Career Development').UnitPrice;
                            objDetails.CareerServicePackageName = 'Career Development';
                            System.debug('CareerServicePackageName after set-->'+objDetails.CareerServicePackageName);
                        }
                    }
                    if(objCoursera.showCoursera && objCoursera.applicableCourseraFee == 0 && objCoursera.checkCourseraOpted) {
                        objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
                    }
                    System.debug('applicableCourseraFee--->'+objCoursera.applicableCourseraFee);
                    System.debug('liveLecType '+objDetails.liveLecType +' courseList '+objDetails.courseList);
                    if(String.isNotBlank(objDetails.liveLecType) && objDetails.liveLecType != 'No') {
                        Decimal totalSubjects = objDetails.liveLecType=='Custom' && String.isNotBlank(objDetails.courseList) ? objDetails.courseList.split(',').size() : 0; 
                        System.debug('totalSubjects '+totalSubjects +'mapOfProductAndAmount.containsKey(liveLecType) '+mapOfProductAndAmount.containsKey(objDetails.liveLecType)+'mapOfProductAndAmount.get(liveLecType) '+mapOfProductAndAmount.get(objDetails.liveLecType));
                        objDetails.applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(objDetails.liveLecType) ? mapOfProductAndAmount.get(objDetails.liveLecType) : 
                        (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
                    }
                    objDetails.applicableBacklogFee = String.isNotBlank(objDetails.backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? objDetails.backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
                    objDetails.applicableLiveLectureFee = objDetails.applicableOnlyLiveLectureFee + objDetails.applicableBacklogFee;
                    system.debug('applicableLiveLectureFee-->'+objDetails.applicableLiveLectureFee);
                    // objOnlinePayment.TranAmount = String.valueOf(mapOfProductAndAmount.containsKey(paymentFor) ? mapOfProductAndAmount.get(paymentFor) + applicableLateFee + (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee')) : paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') : depositAmount );             
                    Decimal TransAmount = 0;
                    if(mapOfProductAndAmount.containsKey(paymentFor)) {
                        TransAmount = mapOfProductAndAmount.get(paymentFor) + objDetails.applicableLateFee + objDetails.applicableCareerServiceFee + objDetails.applicableLiveLectureFee + objCoursera.applicableCourseraFee + (objfee.AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
                    } else {
                        TransAmount = paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') + objDetails.applicableCareerServiceFee + objCoursera.applicableCourseraFee + (objDetails.MergeAdmissionFeeWithRegistration ? mapOfProductAndAmount.get('Initial Payment') : 0) : depositAmount;
                    }
                    // Decimal TransAmount = mapOfProductAndAmount.containsKey(paymentFor) ? mapOfProductAndAmount.get(paymentFor) + applicableLateFee +applicableCareerServiceFee+applicableLiveLectureFee+objCoursera.applicableCourseraFee+ (AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'))  : paymentFor =='Registration' ? mapOfProductAndAmount.get('Registration Fee') +applicableCareerServiceFee+objCoursera.applicableCourseraFee+ (MergeAdmissionFeeWithRegistration ? mapOfProductAndAmount.get('Initial Payment') : 0): depositAmount ;
                    objOnlinePayment.TranAmount = String.valueOf(TransAmount.setScale(2));
                    system.debug('TranAmount--->'+objOnlinePayment.TranAmount);
                    system.debug('applicableCareerServiceFee--->'+objDetails.applicableCareerServiceFee);
                    objOnlinePayment.postPaymentPage = objPaymentFormConfiguration.Post_Payment_VF_Page__c;
                    objOnlinePayment.IsReregistartion = IsReregistartion;
                    objOnlinePayment.depositAmount = depositAmount;
                    
                    objLoanDetails.DP_EMI_ProcessingFee = String.valueOf(depositAmount);
                    // Call Payment GateWay Option Based Upon Selected Option
                    return paymentRequestCreator(objOnlinePayment,strTranTrackid); 
                }else{
                    errMessages = 'Unable to get payment details.';
                    strSecToShow = 'error';
                    return null;
                }
            }else{
                strSecToShow ='PopUpError';
                errMessages ='Hello Student, Kindly coordinate with NMIMS CDOE on 18001025136';
                returnUrl ='/EnrollmentForm';
                return null;
            }
        }
    }
    
    /*-----------------------Payment Request Creator----------------------------------*/
    // Save Payment Reuest before Making Online Payment 
    // Based Upon selected Payment GateWay Option Create Secure Hash code for Online Payment
    public PageReference paymentRequestCreator(nmOnlinePayment objOnlinePayment ,String strTranTrackid){
        System.debug('CareerServiceOpted check2 -->'+objDetails.CareerServiceOpted);
        PaymentRequestParams objParams = new PaymentRequestParams();
        objParams.strTranTrackid = strTranTrackid;
        objParams.strPaymentType = objOnlinePayment.strPaymentType;
        objParams.paymentGatewayVersion = null;
        if(paymentGateWayName =='HDFC GateWay') {
            Map<String,String> mapOfParameters =objOnlinePayment.createHDFCDeskRequest();
            objParams.msg = mapOfParameters.get('msg');
            savePaymentBeforeResponse(objParams);
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
                savePaymentBeforeResponse(objParams);
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
                    return null;
                }
                objParams.msg = JSON.serialize(mapOfParameters);
                objParams.orderId = (String)mapOfParameters.get('bdorderid');
                Map<String,Object> mapOfAdditionalInfo = (Map<String,Object>)mapOfParameters.get('additional_info');
                objParams.udf1 = (String)mapOfAdditionalInfo.get('additional_info1');
                objParams.udf2 = (String)mapOfAdditionalInfo.get('additional_info2');
                objParams.udf3 = (String)mapOfAdditionalInfo.get('additional_info3');
                objParams.paymentGatewayVersion = 'v2';
                savePaymentBeforeResponse(objParams);
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
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
        }else if(paymentGateWayName =='Razorpay GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createRazorPayOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.orderId = (String)mapOfParameters.get('id');
            objParams.paymentCurrency = (String)mapOfParameters.get('currency');
            objParams.udf1 = (String)mapOfParameters.get('udf1');
            objParams.udf2 = (String)mapOfParameters.get('udf2');
            objParams.udf3 = (String)mapOfParameters.get('udf3');
            savePaymentBeforeResponse(objParams);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('orderId', (String)mapOfParameters.get('id'));
            pgURL.getParameters().put('amount', String.valueOf(mapOfParameters.get('amount')));
            pgURL.getParameters().put('Name', objStudentDetails.studentName);
            pgURL.getParameters().put('email', objStudentDetails.studentEmail);
            pgURL.getParameters().put('contact', objStudentDetails.studentMobileNo);
            pgURL.getParameters().put('type', paymentGateWayName);
            pgURL.getParameters().put('callback_url', (String)mapOfParameters.get('return_url'));
            pgUrl.getParameters().put('cancel_url',(String)mapOfParameters.get('return_url')+'?razorpay_order_id='+(String)mapOfParameters.get('id')+'&error[code]=PAYMENT_FAILED');
            pgURL.getParameters().put('currency', (String)mapOfParameters.get('currency'));

            return pgURL;
        }else if(paymentGateWayName == 'ICICI GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createICICIOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('type')) {
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.msg = JSON.serialize(mapOfParameters);
            objParams.orderId = (String)mapOfParameters.get('order_token');
            objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            savePaymentBeforeResponse(objParams);
            String paymentUrl = (String)mapOfParameters.get('payment_link');
            PageReference pgURL = new PageReference(paymentUrl);
            return pgURL;
        }else {
            Map<String,String> mapOfParameters = objOnlinePayment.createPayTMRequest();
            objParams.msg = mapOfParameters.remove('msg');
            savePaymentBeforeResponse(objParams);
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
    public void savePaymentBeforeResponse(PaymentRequestParams objParams){
        System.debug('objParams 2 ==>'+objParams);
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        Boolean checkForLiveLectures = false;
        System.debug('initaition strPaymentType -->'+objParams.strPaymentType);
        
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';
        objPayment.nm_Lead__c = IsReregistartion ? null : leadId;
        objPayment.nm_OpportunityNew__c = IsReregistartion ? opportunityId : null;
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
        System.debug('CareerServiceOpted check3 -->'+objDetails.CareerServiceOpted);
        if(objDetails.CareerServiceOpted) {
            objDetails.applicableCareerServiceFee = (mapOfPricebook.containsKey(objDetails.CareerServicePackageName) && mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice > 0) ? mapOfPricebook.get(objDetails.CareerServicePackageName).UnitPrice : mapOfPricebook.get('Career Development').UnitPrice;
            System.debug('applicableCareerServiceFee -->'+objDetails.applicableCareerServiceFee);
        }

        if(objCoursera.checkCourseraOpted) {
            objCoursera.applicableCourseraFee = mapOfPricebook.get('Coursera').UnitPrice;
            System.debug('applicableCourseraFee -->'+objCoursera.applicableCourseraFee);
        }

        if(String.isNotBlank(objDetails.liveLecType) && objDetails.liveLecType != 'No') {
            Decimal totalSubjects = objDetails.liveLecType=='Custom' && String.isNotBlank(objDetails.courseList) ? objDetails.courseList.split(',').size() : 0; 
            objDetails.applicableOnlyLiveLectureFee = mapOfProductAndAmount.containsKey(objDetails.liveLecType) ? mapOfProductAndAmount.get(objDetails.liveLecType) : 
            (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
            checkForLiveLectures = true;
        }
        objDetails.applicableBacklogFee = String.isNotBlank(objDetails.backlogList) && mapOfProductAndAmount.containsKey('Backlog') ? objDetails.backlogList.split(',').size() * mapOfProductAndAmount.get('Backlog') : 0;
        objDetails.applicableLiveLectureFee = objDetails.applicableBacklogFee + objDetails.applicableOnlyLiveLectureFee;
        System.debug('applicableLiveLectureFee-->'+objDetails.applicableLiveLectureFee);
       
        //Start test for intiation 
        if(paymentFor == 'Registration'){
            if(objDetails.MergeAdmissionFeeWithRegistration)
            {
                Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+mapOfProductAndAmount.get('Initial Payment') + objDetails.applicableCareerServiceFee + objCoursera.applicableCourseraFee;
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,0,0,0,0) );
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('Initial Payment'),actualPaymentAmount, paymentFor ,0,0,0,0));
                if(objDetails.CareerServiceOpted)
                {
                    lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
                if(objCoursera.checkCourseraOpted) {
                    lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
            } else {
                Decimal actualPaymentAmount = mapOfProductAndAmount.get('Registration Fee')+objDetails.applicableCareerServiceFee+objCoursera.applicableCourseraFee;
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),actualPaymentAmount, paymentFor ,0,0,0,0) );
                if(objDetails.CareerServiceOpted)
                {
                    lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
                if(objCoursera.checkCourseraOpted) {
                    lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount,paymentFor ,0,0,0,0) );
                }
            }
        }else if(paymentFor.startsWith('Installment')){
            String InstallmentOption = paymentFor.split('-')[1];
            Decimal installmentAmount = depositAmount - (objDetails.applicableLateFee + objDetails.applicableCareerServiceFee + objDetails.applicableLiveLectureFee + objCoursera.applicableCourseraFee);
            if(!objfee.AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, InstallmentOption,0,0,0,0) );
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Installment' , installmentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, InstallmentOption,0,0,0,0) );
            }else{
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Installment' , installmentAmount , depositAmount, InstallmentOption,0,0,0,0) );
            }

            if(objDetails.CareerServiceOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee,  installmentAmount, InstallmentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted) {
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, installmentAmount,InstallmentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLateFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Late Fees', objDetails.applicableLateFee, installmentAmount, InstallmentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Live Lectures', objDetails.applicableLiveLectureFee,  installmentAmount, InstallmentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }else if(paymentFor.contains('DownPayment')){
            String downPaymentOption = paymentFor.split('-')[1];
            Decimal downPaymentAmount = depositAmount - (objDetails.applicableLateFee + objDetails.applicableCareerServiceFee + objCoursera.applicableCourseraFee);
            if(!objfee.AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),depositAmount, downPaymentOption ,0,0,0,0) );
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, objLoanDetails.LoanType+'-DownPayment' , downPaymentAmount - mapOfProductAndAmount.get('Registration Fee'), depositAmount, downPaymentOption,0,0,0,0) );
            }else{
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, objLoanDetails.LoanType+'-DownPayment' , downPaymentAmount , depositAmount, downPaymentOption ,0,0,0,0) );
            }

            if(objDetails.CareerServiceOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee,  downPaymentAmount - objDetails.applicableLiveLectureFee, downPaymentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  downPaymentAmount - objDetails.applicableLiveLectureFee, downPaymentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLateFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Late Fees', objDetails.applicableLateFee, downPaymentAmount - objDetails.applicableLiveLectureFee, downPaymentOption  ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            /*if(objDetails.applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Live lecture', objDetails.applicableLiveLectureFee,  depositAmount -  objDetails.applicableLateFee - objDetails.applicableCareerServiceFee - objDetails.applicableLiveLectureFee, downPaymentOption ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee) );
            }*/
        }else if(paymentFor =='InitialAdmissionFee'){
            Decimal actualPaymentAmount = mapOfProductAndAmount.get('InitialAdmissionFee') + (objfee.AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
            if(!objfee.AlreadyPaidRegistrationFee){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', mapOfProductAndAmount.get('Registration Fee'),(mapOfProductAndAmount.get(paymentFor) + mapOfProductAndAmount.get('Registration Fee')) , paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Initial Payment', mapOfProductAndAmount.get('InitialAdmissionFee'), actualPaymentAmount + objDetails.applicableCareerServiceFee, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            
            if(objDetails.CareerServiceOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee,  actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee,  actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLateFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Late Fees', objDetails.applicableLateFee, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }else{
            if(!objfee.AlreadyPaidRegistrationFee){
                Decimal Amount = mapOfProductAndAmount.get('Registration Fee');
                Decimal paymentForAmount = mapOfProductAndAmount.get(paymentFor) + mapOfProductAndAmount.get('Registration Fee');
                if(Amount > 0) {
                    Amount = paymentForAmount < mapOfProductAndAmount.get('Registration Fee') ? paymentForAmount : Amount;
                    lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Registration', Amount, paymentForAmount, paymentFor, objDetails.applicableLateFee, objDetails.applicableCareerServiceFee, objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
                }
            }

            System.debug('paymentFor ==>'+paymentFor);
            System.debug('mapOfProductAndAmount.get(paymentFor) ==>'+mapOfProductAndAmount.get(paymentFor));
            System.debug('objfee.AlreadyPaidRegistrationFee ==>'+objfee.AlreadyPaidRegistrationFee);
            System.debug('mapOfProductAndAmount.get(\'Registration Fee\') ==>'+mapOfProductAndAmount.get('Registration Fee'));

            Decimal Amount2 = mapOfProductAndAmount.get(paymentFor);
            Decimal actualPaymentAmount = mapOfProductAndAmount.get(paymentFor) + (objfee.AlreadyPaidRegistrationFee ? 0 : mapOfProductAndAmount.get('Registration Fee'));
            if(Amount2 > 0) {
                lstPaymentToInsert.add(createPaymentInitiatedRecord( objPayment, 'Admission', Amount2, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee));
            }
            if(objDetails.CareerServiceOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Career Service', objDetails.applicableCareerServiceFee, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objCoursera.checkCourseraOpted){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Coursera', objCoursera.applicableCourseraFee, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLateFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Late Fees', objDetails.applicableLateFee, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
            if(objDetails.applicableLiveLectureFee > 0){
                lstPaymentToInsert.add( createPaymentInitiatedRecord( objPayment, 'Live Lectures', objDetails.applicableLiveLectureFee, actualPaymentAmount, paymentFor ,objDetails.applicableLateFee,objDetails.applicableCareerServiceFee,objDetails.applicableLiveLectureFee,objCoursera.applicableCourseraFee) );
            }
        }

        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                insert lstPaymentToInsert;
            }
        }catch(Exception e){
            System.debug('------string.valueof(e)--------'+String.valueof(e));
        }
    }
    
    /*----------------Create Payment Initiation Record ------------------------------------------------*/
    // Method to Create Payment Initiation Record
    public nm_Payment_Initiated__c createPaymentInitiatedRecord(nm_Payment_Initiated__c objPayment, 
                                                                String paymentType, Decimal amount, 
                                                                Decimal paymentForAmount, String feesType, 
                                                                Decimal lateFeeAmount, Decimal careerServicePrice, 
                                                                Decimal applicableLiveLectureFee, Decimal courseraFee){
        nm_Payment_Initiated__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = paymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount + lateFeeAmount + careerServicePrice + applicableLiveLectureFee + courseraFee;
        objPay.nm_Amount__c = amount;
        objPay.nm_Fee_Type__c = feesType;
        if(String.isNotBlank(opportunityId) && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = opportunityId;
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
            updateLoanDetails('Opportunity');
        }else{
            objPay.nm_Lead__c = leadId;
            updateLoanDetails('Lead');
        }
        return objPay;
    }

    public void updateLoanDetails(String typeOfObject){
        try {
            if('Opportunity'.equalsIgnoreCase(typeOfObject)){
                if(!objOpportunity.Down_Payment_Made__c){
                    objOpportunity.Loan_Type__c = objLoanDetails.LoanType;
                    System.debug('EMI----'+objLoanDetails.EMI);
                    objOpportunity.EMI_Amount__c = objLoanDetails.EMI;
                    objOpportunity.Tenure__c = objLoanDetails.Tenure;
                    objOpportunity.Interest_Rate__c = objLoanDetails.InterestRate;
                    objOpportunity.DP_EMI_Processing_Fee__c = objLoanDetails.DP_EMI_ProcessingFee;
                    objOpportunity.Zest_Loan_Application_Request__c = '';
                    if(objLoanDetails.LoanType =='Capital Float'){
                        objOpportunity.Capital_Float_Processing_Fee__c = objLoanDetails.processingFee;
                    }

                    update objOpportunity;
                }
            }else if('Lead'.equalsIgnoreCase(typeOfObject)){
                if(!objLead.Down_Payment_Made__c){
                    objLead.Loan_Type__c = objLoanDetails.LoanType;
                    System.debug('EMI----'+objLoanDetails.EMI);
                    objLead.EMI_Amount__c = objLoanDetails.EMI;
                    objLead.Tenure__c = objLoanDetails.Tenure;
                    objLead.Interest_Rate__c = objLoanDetails.InterestRate;
                    objLead.DP_EMI_Processing_Fee__c = objLoanDetails.DP_EMI_ProcessingFee;
                    objLead.Zest_Loan_Application_Request__c = '';
                    if(objLoanDetails.LoanType =='Capital Float'){
                        objLead.Capital_Float_Processing_Fee__c = objLoanDetails.processingFee;
                    }
                }
                if(String.isNotBlank(objDetails.TagPriceBookId)) {
                    ID priceBookId = objDetails.TagPriceBookId;
                    objLead.nm_Tagged_Pricebook__c = priceBookId.to15();
                }
                update objLead;
            }
        } catch (Exception error) {
            System.debug('error ==>'+error.getMessage());
            System.debug('error ==>'+error.getLineNumber());
        }
        
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
            objOpportunity.Loan_Type__c = objLoanDetails.LoanType;
            objOpportunity.EMI_Amount__c = objLoanDetails.EMI;
            objOpportunity.Tenure__c = objLoanDetails.Tenure;
            objOpportunity.Interest_Rate__c = objLoanDetails.InterestRate;
            objOpportunity.DP_EMI_Processing_Fee__c =  String.valueOf(totalAmtPaid);  
            objOpportunity.Loan_Cancellation_Reason__c = '';
            objOpportunity.Loan_Application_Cancelled__c = false;
            objOpportunity.Zest_Loan_Application_Request__c = '';
            System.debug('liveLecType  '+objDetails.liveLecType +' courseList  '+objDetails.courseList );
            if(String.isNotBlank(objDetails.liveLecType)){
                objOpportunity.LiveLecturesType__c = objDetails.liveLecType ;
                objOpportunity.CourseList__c = objDetails.courseList  != 'null' ? objDetails.courseList  : '';
            }
            objOpportunity.BacklogList__c = objDetails.backlogList != 'null' ? objDetails.backlogList : '';
            if(objOpportunity!=null){
                update objOpportunity;
            }
        }
        else if('Lead'.equalsIgnoreCase(typeOfObject)){
            objLead.Down_Payment_Made__c = true;
            objLead.Loan_Type__c = objLoanDetails.LoanType;
            objLead.EMI_Amount__c = objLoanDetails.EMI;
            objLead.Tenure__c = objLoanDetails.Tenure;
            objLead.Interest_Rate__c = objLoanDetails.InterestRate;
            objLead.DP_EMI_Processing_Fee__c = String.valueOf(totalAmtPaid);
            objLead.Zest_Loan_Application_Request__c = '';
            System.debug('liveLecType  '+objDetails.liveLecType +' courseList  '+objDetails.courseList );
            if(String.isNotBlank(objDetails.liveLecType)){
                objLead.LiveLecturesType__c = objDetails.liveLecType ;
                objLead.CourseList__c = objDetails.courseList  != 'null' ? objDetails.courseList  : '';
            }
            if(objLead!=null){
                update objLead;
            }
        }
    }

    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @return PageReference 
    **/
    public PageReference proceedToDirectLoan(){
        String merchantId='';
        Decimal totalAmountpaid =0.0;
        if(objDownPayment !=null){
            merchantId = objDownPayment.nm_Merchant_Track_Id__c;
            totalAmountPaid = objDownPayment.nm_ActualPaymentAmmount__c;
            objDownPayment.nm_PaymentType__c= objLoanDetails.LoanType+'-DownPayment';
            objDownPayment.nm_Installment_Payment_Ref__c=paymentFor;
            update objDownPayment;
        }

        if( String.isNotBlank(opportunityId) && opportunityId != 'NA'){
            updateLoanDetailsForSubvention('Opportunity',totalAmountPaid);
        }else{
             updateLoanDetailsForSubvention('Lead',totalAmountPaid);
        }

        if(String.isNotBlank(merchantId)){
            PageReference pg = new PageReference('/apex/PostPaymentPage?ResTrackId='+merchantId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @param String studentNo 
    **/
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

    /**
    * @description 
    * @author @BK | 28-11-2024 
    * @return Decimal 
    **/
    public Decimal getRegistrationFee() {
        return mapOfProductAndAmount.containsKey('Registration Fee') ? mapOfProductAndAmount.get('Registration Fee') : 0;
    }

    public class LoanRequestWrapper {
        public String LoanType {get;set;}
        public String EMI {get;set;}
        public String InterestRate {get;set;}
        public String Tenure {get;set;}
        public String processingFee {get;set;} // kept for Capital Float
        public boolean loanSanctioned {get;set;}
        public boolean loanApproved {get;set;}
        public boolean showEMIOption {get;set;}
        public String EMIFeeType {get;set;}
        public String EMI_Processing_Fee {get;set;}
        public String DP_EMI_ProcessingFee {get;set;}
        public Decimal loanAmount {get;set;}
        public Boolean isLoanOpted {get;set;}
        public String loanPaymentTrackId {get;set;}
        public Boolean isDownPaymentMade {get;set;}

        public LoanRequestWrapper() {
            this.isLoanOpted = false;
            this.loanAmount = 0;
            this.loanPaymentTrackId = '';
            this.isDownPaymentMade = false;
            this.loanSanctioned = false;
            this.loanApproved = false;
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

    public class RequestWrapper {
        public String feeType {get;set;}
        public String liveLecType {get;set;}
        public String courseList{get;set;}
        public String backlogList{get;set;}
        public String consumerType {get;set;}
        public boolean IsDefence {get;set;}
        public boolean IsLateral {get;set;}
        public Boolean subventionPrograms {get;set;}
        public Integer intTotalInstallmentOptionAvaliable {get;set;}
        public Decimal totalsem {get;set;}
        public String semester {get;set;}
        public String LateralStudentNo {get;set;}
        public String centerAddressForDD {get;set;}
        public String ICName {get;set;}
        public String ICContact {get;set;}
        public String programId {get;set;}
        public String programName {get;set;}
        public String program {get;set;}
        public String programSpecialisaton {get;set;}
        public String programStructure {get;set;}
        public Boolean isTerm {get;set;}
        public Boolean CareerServicePackage {get;set;}
        public String CareerServicePackageName {get;set;}
        public boolean CareerServiceOpted {get;set;}
        public String TagPriceBookId {get;set;}
        public String stagename {get;set;}
        public Decimal DaysPendingforInitialPayment {get;set;}
        public Decimal DaysPendingforAdmissionPayment {get;set;}
        public boolean oppExist {get;set;}
        public Boolean isOpportunityProcessed {get;set;}
        public Decimal RegistrationFee {get;set;}
        public Decimal maxInstalmentAmt {get;set;}
        public Boolean ShowCareerServiceOpt {get;set;}
        public Boolean IsupGrad {get;set;}
        public boolean MergeAdmissionFeeWithRegistration {get;set;}
        public boolean ShowInitialAdmissionPayment {get;set;}
        public Decimal InitialAdmissionPaymentAmount {get;set;}
        public Decimal actualInitialAdmissionPaymentAmount {get;set;}
        public Decimal PartAdmintoReg {get;set;}
        public Decimal intTotalInstallmentPaid  { get; set; } // to Keep Track of No of Installment Option available and Paid
        public Integer intTotalInstallmentApplicable {get;set;}
        public boolean paymentWindowClosed {get;set;}
        public boolean loanWindowClosed {get;set;}
        public String paymentClouserMessage {get;set;}
        public Decimal totalamountreceived {get;set;}
        public Decimal initalAmountRecieved {get;set;}
        public Decimal totalProductAmountPaid {get;set;}
        public Decimal totalAmountPaid {get;set;}
        public boolean showliveLectureBasedOnSY {get;set;}
        public Decimal applicableLateFee {get;set;}
        public Decimal applicableAwithR {get;set;}
        public date lateFeeStartDate {get;set;}
        public Decimal applicableCareerServiceFee {get;set;}
        public Decimal applicableBacklogFee {get;set;}
        public Decimal applicableOnlyLiveLectureFee {get;set;}
        public Decimal applicableLiveLectureFee {get;set;}
        public String courseListWithBacklogList {get;set;}
        // public List<nm_Payment__c> lstPayments {get;set;}
        public Map<String,nm_Payment__c> mapOfPaymentsMade {get;set;}
        public Boolean isPaymentMade {get;set;}
        public Decimal actualPeningAmount {get;set;}
        public Boolean hasAvanseProgramCode {get;set;}

        public RequestWrapper() {
            this.DaysPendingforInitialPayment = 1;
            this.DaysPendingforAdmissionPayment = 0;
            this.oppExist = false;
            this.isOpportunityProcessed = false;
            this.RegistrationFee = 0;
            this.maxInstalmentAmt = 0;
            this.ShowCareerServiceOpt = false;
            this.IsupGrad = false;
            this.MergeAdmissionFeeWithRegistration = false;
            this.ShowInitialAdmissionPayment = false;
            this.InitialAdmissionPaymentAmount = 0;
            this.actualInitialAdmissionPaymentAmount = 0;
            this.PartAdmintoReg = 0;
            this.intTotalInstallmentPaid = 0;
            this.intTotalInstallmentOptionAvaliable = 0;
            this.paymentWindowClosed = false;
            this.loanWindowClosed = false;
            this.paymentClouserMessage = '';
            this.totalamountreceived = 0;
            this.initalAmountRecieved = 0;
            this.totalProductAmountPaid = 0;
            this.totalAmountPaid = 0;
            this.showliveLectureBasedOnSY = false;
            this.CareerServiceOpted = false;
            this.applicableLateFee = 0;
            this.applicableAwithR = 0;
            this.applicableCareerServiceFee = 0;
            this.applicableBacklogFee = 0;
            this.applicableOnlyLiveLectureFee = 0;
            this.applicableLiveLectureFee = 0;
            // this.lstPayments = new List<nm_Payment__c>();
            this.mapOfPaymentsMade = new Map<String,nm_Payment__c>();
            this.isPaymentMade = false;
            this.lateFeeStartDate = null;
            this.CareerServicePackage = false;
            this.semester = null;
            this.actualPeningAmount = 0;
            this.hasAvanseProgramCode = false;
        }
    }

    public class AlreadyPaidFee {
        public boolean AlreadyPaidRegistrationFee {get;set;}
        public boolean AlreadyPaidInitialAdmissionfee {get;set;}
        public boolean AlreadyPaidAdmissionFee {get;set;}
        public boolean AlreadyPaidAnnualFee {get;set;}
        public boolean AlreadyPaidMultipleSemFee {get;set;}
        public boolean AlreadyPaidLateFee {get;set;}
        public boolean AlreadyPaid3SemFee {get;set;}
        public boolean AlreadyPaid3TermFee {get;set;}
        public boolean AlreadyPaidFullFee {get;set;}
        public boolean AlreadyPaid4SemFee {get;set;}
        public boolean AlreadyPaid5SemFee {get;set;}
        public Decimal AlreadyPaidInstallmentAmount {get;set;}
        public Decimal AlreadyPaidInitialAmount {get;set;}
        public Decimal AlreadyPaidLateFeeAmount {get;set;}
        public boolean AlreadyMadeAllInstallment {get;set;}

        public AlreadyPaidFee() { 
            this.AlreadyPaidRegistrationFee = false;
            this.AlreadyPaidInitialAdmissionfee = false;
            this.AlreadyPaidAdmissionFee = false;
            this.AlreadyPaidAnnualFee = false;
            this.AlreadyPaidMultipleSemFee = false;
            this.AlreadyPaidLateFee = false;
            this.AlreadyPaid3SemFee = false;
            this.AlreadyPaid3TermFee = false;
            this.AlreadyPaidFullFee = false;
            this.AlreadyPaid4SemFee = false;
            this.AlreadyPaid5SemFee = false;
            this.AlreadyPaidInstallmentAmount = 0;
            this.AlreadyPaidInitialAmount = 0;
            this.AlreadyPaidLateFeeAmount = 0;
            this.AlreadyMadeAllInstallment = false;
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

    public class AdmissionAmount {
        public Decimal admissionAmountPaid {get;set;}
        public Boolean isPendingPaymentRecordExists {get;set;}
        public Boolean isAdmissionAmountPaid {get;set;}
        public Boolean isLateFeePending {get;set;}
        public Boolean hasUnpaidLoanBalance {get;set;}
        public String pendingPaymentRecordId {get;set;}
        public String returnURL {get;set;}
        public Boolean isRedirect {get;set;}

        public AdmissionAmount() {
            this.admissionAmountPaid = 0;
            this.isAdmissionAmountPaid = false;
            this.isPendingPaymentRecordExists = false;
            this.isLateFeePending = false;
            this.hasUnpaidLoanBalance = false;
            this.pendingPaymentRecordId = '';
            this.returnURL = '';
            this.isRedirect = false;
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

    //  public class PaymentMade {
    //     public String paymentSuccessInstructions {get;set;}
    //     public String isSuccess {get;set;}
    //     public String errorMsg {get;set;}

    //     public PaymentMade() {
    //         this.paymentSuccessInstructions = '';
    //         this.isSuccess = false;
    //         this.errorMsg = '';
    //     }
    // }
}