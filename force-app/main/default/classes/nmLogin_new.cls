/**
 * @File Name          : nmLogin_new.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 18-01-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/15/2019   shubhranshu     Initial Version
**/
// This Class is used as a Controller for login page
// ---------------------------------------------------------------------------------------------
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        5-Nov-2014      Sumit Banarji          Initial Version
// ---------------------------------------------------------------------------------------------
public class nmLogin_new
{
    public Lead objLead{get;set;}
    public Account objAccount{get;set;}
    public string message { get; set; }
    public list<string> lstMsg  { get; set; }
    public string strSecToShow { get; set; }
    public string HeaderMessage  { get; set; }
    public string strBtnURL  { get; set; }
    public String showerror{get;set;}
    public String strtype {get;set;}
    public String pdfBtnURL {get;set;}
    public String IC {get;set;}
    public String HO {get;set;}
    public String urlGenerate {get; set;}
    public nm_Payment__c objAdditionalChargerPayment ;
    public Map<String,String> mapOfActiveCalenderCategoryAndMessage {get;set;}
    public Opportunity objOpportunity ;
    public ProductHelper productHelper ;
    public String merchantTrackId {get;set;}
  //  public set<String> sasProgramAEP {get;set;}
  //  public set<String> sasPrograms {get;set;}
    public String token {get;set;}
    public String Src {get;set;}
    public Boolean Inactive {get;set;}
    public Boolean  downPaymentDone {get;set;}
    public Boolean allowPayment {get;set;}

    //Added By Bala 04-12-2018
    //For OTP Verification Login
    public OTPFields objOTP {get;set;}

    public Boolean alreadyDonePayment {get;set;}
    public Boolean allowValidityExtension {get;set;}
    public String corporateBatchName {get;set;}
    public Boolean checkExpireDateforBatch {get;set;}
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
    public String programChangeUrl {get;set;}

    // ------------ lateralPopup
    public Boolean showLateralPopup {get; set;}

    public nmLogin_new()
    {
        msgInitialize();
        objLead = new Lead();
        objAccount = new Account();
        mapOfActiveCalenderCategoryAndMessage = new Map<String,String>();
        strtype = '';
        pdfBtnURL ='';
        objAdditionalChargerPayment = new nm_Payment__c();
        objOpportunity = new Opportunity();
        // call Product Helper for Checking Pending' Amount
        producthelper = new ProductHelper();
        allowPayment = false;

        IC = '';
        HO = '';
        urlGenerate = '';
        merchantTrackId='';
        alreadyDonePayment=false;
        AdmissionPaymentPaid =false;
        LateFeePaid = false;
        Inactive = false;
        TotalAmountReceived = 0;
        downPaymentDone =false;
        allowValidityExtension = false;
        showCoursera = false;
        isCourseraAlreadyOpted = false;
        paymentUrl = '';
        programChangeUrl = '';
        // isUserFromIndia = true;
        objOTP = new OTPFields();
        objOTP.checkToAllowOTP = String.isNotBlank(System.label.AllowOTP) ? Boolean.valueOf(System.label.AllowOTP) : false ;
        showLateralPopup = false;

        if(ApexPages.currentPage().getParameters().get('type') != Null && ApexPages.currentPage().getParameters().get('type') != '')
        {
            strtype = ApexPages.currentPage().getParameters().get('type');
        }
       
        //Added by Sanket 21-Jul-2015
        if(ApexPages.currentPage().getParameters().get('studentNo') != Null && ApexPages.currentPage().getParameters().get('studentNo') != '')
        {   studentNo = ApexPages.currentPage().getParameters().get('studentNo');
            objAccount.nm_StudentNo__c = ApexPages.currentPage().getParameters().get('studentNo');
        }
        if(ApexPages.currentPage().getParameters().get('registrationNo') != Null && ApexPages.currentPage().getParameters().get('registrationNo') != '')
        {   registrationNo = ApexPages.currentPage().getParameters().get('registrationNo');
            objLead.nm_RegistrationNo__c  = ApexPages.currentPage().getParameters().get('registrationNo');
        }
       
        if(ApexPages.currentPage().getParameters().get('dob') != Null && ApexPages.currentPage().getParameters().get('dob') != '')
        {
            objAccount.nm_DateOfBirth__c = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
        }
       
        if(ApexPages.currentPage().getParameters().get('dob') != Null && ApexPages.currentPage().getParameters().get('dob') != '')
        {
            objLead.nm_DateOfBirth__c = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
        }

        if(ApexPages.currentPage().getParameters().get('request') != null && ApexPages.currentPage().getParameters().get('request') != '') {
            showCoursera = ApexPages.currentPage().getParameters().get('request') == 'coursera' ? true : false;
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('src'))) {
            Src = ApexPages.currentPage().getParameters().get('src');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('batch'))) {
            corporateBatchName = ApexPages.currentPage().getParameters().get('batch');
            checkExpireDateforBatch = calenderCheckForCorporate(corporateBatchName);
            System.debug('checkExpireDateforBatch '+checkExpireDateforBatch);
        }

        if (ApexPages.currentPage().getParameters().get('skipOTP') != null && ApexPages.currentPage().getParameters().get('skipOTP') != '') {
            objOTP.skipOTP = Boolean.valueOf(ApexPages.currentPage().getParameters().get('skipOTP'));
        }
        if(ApexPages.currentPage().getParameters().get('IC') !=null && ApexPages.currentPage().getParameters().get('IC') !=''){
            IC =ApexPages.currentPage().getParameters().get('IC');
        }
        if(ApexPages.currentPage().getParameters().get('HO') !=null && ApexPages.currentPage().getParameters().get('HO') !=''){
            HO = ApexPages.currentPage().getParameters().get('HO');
        }

        objOTP.checkToAllowOTP = objOTP.checkToAllowOTP && !objOTP.skipOTP  ? true : false;
        
        if(String.isNotBlank(HO)) {
            urlGenerate = '&HO=' + HO + '&IC=' + IC;
        } else if (String.isNotBlank(IC)) {
            urlGenerate = '&IC=' + IC;
        }
        // ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        // System.debug('ipAddress ==> ' + ipAddress);
        // if(String.isNotBlank(ipAddress)) {
        //     isUserFromIndia = IsCountryNotIndia(ipAddress);
        // }

        token = ApexPages.currentPage().getParameters().get('token');
       
        //sasProgramAEP = new Set<String>(System.Label.SAS_Program_AEP.split(','));
        //sasPrograms = new Set<String>();
       
        getMapOfActiveCalender();

        // if(String.isNotBlank(strtype) && strtype.equalsIgnoreCase('reregistration') && objAccount.nm_StudentNo__c!=null && objAccount.nm_DateOfBirth__c!=null) {
        //     allowValidityExtension = checkToAllowValidityExtension();
        // }
       
    }
   
    public void msgInitialize() {
        strSecToShow = '';
        message = '';
        HeaderMessage = '';
        strBtnURL='';
        lstMsg = new list<string>();        
    }

    public PageReference yesButton() {
        if (objOpportunity != null) {
            Opportunity opp = new Opportunity();
            opp.Id =objOpportunity.Id;
            opp.StageName = 'Closed Won';
            update opp;
        }
        pageReference pg = new pageReference ('/nmPrintAdmissionForm?id='+objOpportunity.AccountId);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference logout() {
        pageReference pg = new pageReference ('/apex/nmLogin_new?type=registration');
        pg.setRedirect(true);
        return pg;
    }

    public void getMobileAndEmailForOTP() {
        Date DOB = objLead.nm_DateOfBirth__c;
        registrationNo = objLead.nm_RegistrationNo__c;
        String leadQuery = 'select id,nm_InformationCenter__c,Adhar_Card_Number__c,InactiveLead__c,nm_Session__c,nm_Year__c,Capital_Float_Processing_Fee__c,EMI_Processing_Fee_Capital_Float__c,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c,IC_Name__c,nm_Program__c,nm_ChooseaProgram__c,nm_IsEmailVerified__c,Is_Mobile_Verified__c,'+
        'nm_ProgramName__c,Is_Lateral__c,nm_Semester__c, nm_RegistrationNo__c,nm_InformationCenter__r.name,nm_PaymentStatus__c, isconverted, Status , name,  nm_DateOfBirth__c,nm_Reason_for_Dead_Invalid_Leads__c,MobilePhone,nm_InformationCenter__r.Contact_No_1__c,Program_Type__c,StudentLogin__c,nm_EligiblityCriteria__c,Email, '+
        '( '+
        '    Select nm_ActualPaymentAmmount__c,nm_Merchant_Track_Id__c ,nm_Installment_Payment_Ref__c, nm_Amount__c, nm_Pay_Mode__c, nm_PaymentType__c,nm_Type__c, nm_PaymentStatus__c,nm_PaymentDissapproved__c '+
        '    from Payment__r '+
        '    where nm_PaymentStatus__c != \'Transaction Failed\' '+
        '    and nm_PaymentStatus__c != null order by createddate ASC '+
        ') '+
        'from Lead ';
        if(objOTP.checkToAllowOTP) {
            leadQuery += 'where nm_RegistrationNo__c =: registrationNo and isconverted = false limit 1';
        } else {
            leadQuery += 'where nm_RegistrationNo__c =: registrationNo and nm_DateOfBirth__c =:DOB and isconverted = false limit 1';
        }
        System.debug('leadQuery ==>'+leadQuery);
        List<Lead> lstLead = DataBase.query(leadQuery);
        system.debug('lstLead ----'+lstLead);
        if(lstLead != null && lstLead.size() > 0)
        {
            objOTP.recordObject = 'Lead';
            objOTP.mobileNo = lstLead[0].MobilePhone;
            objOTP.EmailId = lstLead[0].Email;
            objOTP.recordId = lstLead[0].id;
            objOTP.isEmailVerified = lstLead[0].nm_IsEmailVerified__c ;
            objOTP.isMobileVerified = lstLead[0].Is_Mobile_Verified__c;
            objOTP.lstMsg.clear();
        }else
        {
            String accountQuery = 'SELECT id,PersonContactId,nm_LeadId__c,Interview_Status__c,Extend_Validity_Upto_Year__c,Provisional_With_Hold__c,Extend_Validity_upto_Month__c,Validity_Month__c,nm_Program__c,IC_Name_1__c,nm_ChooseaProgram__c,nmStudent_Program__c, '+
            'Is_Lateral__c,Program_Name__c,nm_Centers__r.name, name, nm_StudentStatus__c ,nm_StudentNo__c, nm_RegistrationNumber__c, nm_DateOfBirth__c,Program_Type__c,PersonMobilePhone,PersonEmail,nm_IsEmailVerified__c,Is_Mobile_Verified__c, '+
            '( '+
            '    Select id, nm_PendingAmount__c,Capital_Float_Processing_Fee__c,EMI_Processing_Fee_Capital_Float__c, nm_Semester__c ,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c '+
            '    from Opportunities '+
            '    where StageName != \'Closed Won\' '+
            '    and nm_PendingAmount__c > 0 '+
            ') '+
            'FROM Account ';
            if(objOTP.checkToAllowOTP) {
                accountQuery += 'WHERE nm_RegistrationNumber__c =: registrationNo AND nm_StudentStatus__c!=\'Closed Lost\' LIMIT 1';
            } else {
                accountQuery += 'WHERE nm_RegistrationNumber__c =: registrationNo AND nm_DateOfBirth__c =: DOB AND nm_StudentStatus__c!=\'Closed Lost\' LIMIT 1';
            }
            List<Account> lstAccount = DataBase.query(accountQuery);
            system.debug('lstAccount --> ' + lstAccount);
            if(lstAccount != null && lstAccount.size() > 0)
            {
                objOTP.recordObject = 'Account';
                objOTP.mobileNo = lstAccount[0].PersonMobilePhone;
                objOTP.EmailId = lstAccount[0].PersonEmail;
                objOTP.recordId = lstAccount[0].id;
                objOTP.PersonContactId = lstAccount[0].PersonContactId;
                objOTP.isEmailVerified = lstAccount[0].nm_IsEmailVerified__c ;
                objOTP.isMobileVerified = lstAccount[0].Is_Mobile_Verified__c;
                objOTP.lstMsg.clear();
            }
        }
    }
   
    public void getQueryRelatedToLeadAndAccount(String typeOfLogin)
    {
        system.debug('typeOfLogin --->'+typeOfLogin );
        Date DOB = objLead.nm_DateOfBirth__c;
        registrationNo = objLead.nm_RegistrationNo__c;
        if(typeOfLogin =='LeadLogin')
        {
            String leadQuery = 'select id,nm_InformationCenter__c,Adhar_Card_Number__c,InactiveLead__c,nm_Session__c,nm_Year__c,Capital_Float_Processing_Fee__c,EMI_Processing_Fee_Capital_Float__c,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c,IC_Name__c,nm_Program__c,nm_ChooseaProgram__c,nm_ProgramName__c,Is_Lateral__c,nm_Semester__c, nm_RegistrationNo__c,nm_InformationCenter__r.name,nm_PaymentStatus__c, isconverted, Status , name,  nm_DateOfBirth__c,nm_Reason_for_Dead_Invalid_Leads__c,MobilePhone,nm_InformationCenter__r.Contact_No_1__c,Program_Type__c,StudentLogin__c,nm_EligiblityCriteria__c,Email,Form_Id__c, '+
            '( '+
            '    Select nm_ActualPaymentAmmount__c,nm_Merchant_Track_Id__c ,nm_Installment_Payment_Ref__c, nm_Amount__c, nm_Pay_Mode__c, nm_PaymentType__c,nm_Type__c, nm_PaymentStatus__c,nm_PaymentDissapproved__c '+
            '    from Payment__r '+
            '    where nm_PaymentStatus__c != \'Transaction Failed\' '+
            '    and nm_PaymentStatus__c != null order by createddate ASC '+
            ') '+
            'from Lead ';
            if(objOTP.checkToAllowOTP) {
                leadQuery += 'where nm_RegistrationNo__c =: registrationNo and isconverted = false limit 1';
            } else {
                leadQuery += 'where nm_RegistrationNo__c =: registrationNo and nm_DateOfBirth__c =:DOB and isconverted = false limit 1';
            }
            System.debug('leadQuery ==>'+leadQuery);
            List<Lead> lstLead = DataBase.query(leadQuery);
            system.debug('lstLead ----'+lstLead);
            if(lstLead != null && lstLead.size() > 0)
            {
                objLead = lstLead[0];
                objOTP.mobileNo = objLead.MobilePhone;
                objOTP.EmailId = objLead.Email;
                //getProgramsList('Executive Programs');
                objAccount = null;
            }else
            {
                String accountQuery = 'SELECT id,Sem__c,nm_Drive_Name__c,OldAccount__c,nm_Program__r.Name, OldAccount__r.nm_Program__r.Name,nm_LeadId__c,Interview_Status__c,Extend_Validity_Upto_Year__c,Provisional_With_Hold__c,Extend_Validity_upto_Month__c,Validity_Month__c,nm_Program__c,IC_Name_1__c,nm_ChooseaProgram__c,nmStudent_Program__c, '+
                'Is_Lateral__c,Program_Name__c,nm_Centers__r.name, name, nm_StudentStatus__c ,nm_StudentNo__c, nm_RegistrationNumber__c, nm_DateOfBirth__c,Program_Type__c,PersonMobilePhone,PersonEmail, '+
                '( '+
                '    Select id, nm_PendingAmount__c,Capital_Float_Processing_Fee__c,EMI_Processing_Fee_Capital_Float__c, nm_Semester__c ,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c '+
                '    from Opportunities '+
                '    where StageName != \'Closed Won\' '+
                '    and nm_PendingAmount__c > 0 '+
                ') '+
                'FROM Account ';
                if(objOTP.checkToAllowOTP) {
                    accountQuery += 'WHERE nm_RegistrationNumber__c =: registrationNo AND nm_StudentStatus__c!=\'Closed Lost\' LIMIT 1';
                } else {
                    accountQuery += 'WHERE nm_RegistrationNumber__c =: registrationNo AND nm_DateOfBirth__c =: DOB AND nm_StudentStatus__c!=\'Closed Lost\' LIMIT 1';
                }
                List<Account> lstAccount = DataBase.query(accountQuery);
                
                if(lstAccount != null && lstAccount.size() > 0)
                {
                    objAccount = lstAccount[0];
                    objOTP.mobileNo = objAccount.PersonMobilePhone;
                    objOTP.EmailId = objAccount.PersonEmail;
                   // getProgramsList('Executive Programs');
                    objLead = null;
                }else
                {
                    objLead = null;
                    objAccount = null;
                   
                }
           }
        }else if(typeOfLogin =='studentLogin')
        {
            Date SDOB = objAccount.nm_DateOfBirth__c;
            studentNo = objAccount.nm_StudentNo__c;
            System.debug('Enter In Student Login');
            String accountQuery = 'SELECT id,Adhar_Card_Number__c,Interview_Status__c,Is_Lateral__c,Provisional_With_Hold__c,Extend_Validity_Upto_Year__c,Extend_Validity_upto_Month__c,Validity_Month__c,nm_Centers__r.name,nm_ChooseaProgram__c,'+
            'Validity_Year__c,Sem__c,Batch__c,name, nm_StudentStatus__c ,nm_StudentNo__c,nmCaptureOpportuntiyStage__c,nm_RegistrationNumber__c,PersonMobilePhone,PersonEmail,PersonContactId,'+
            'nm_DateOfBirth__c,Program_Type__c,nm_LeadId__c,'+
            '('+
               ' SELECT id, nm_FeesPaidofSemester__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_Program__r.Specialisation__c '+
                'FROM Student_Program__r '+
                'WHERE nm_IsClosed__c = false LIMIT 1'+
            ')'+
            'FROM Account ';
            if(objOTP.checkToAllowOTP) {
                accountQuery += 'WHERE nm_StudentNo__c =: studentNo LIMIT 1';
            } else {
                accountQuery += 'WHERE nm_StudentNo__c =: studentNo AND nm_DateOfBirth__c =: SDOB LIMIT 1';
            }
            List<Account> lstAccount = DataBase.query(accountQuery);
            // list<Account> lstAccount = [SELECT id,Adhar_Card_Number__c,Interview_Status__c,Is_Lateral__c,Provisional_With_Hold__c,Extend_Validity_Upto_Year__c,Extend_Validity_upto_Month__c,Validity_Month__c,nm_Centers__r.name,nm_ChooseaProgram__c,
            //                             Validity_Year__c,Sem__c,Batch__c,name, nm_StudentStatus__c ,nm_StudentNo__c,nmCaptureOpportuntiyStage__c,nm_RegistrationNumber__c,
            //                             nm_DateOfBirth__c,Program_Type__c,nm_LeadId__c,
            //                             (
            //                                 SELECT id, nm_FeesPaidofSemester__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_Program__r.Specialisation__c
            //                                 FROM Student_Program__r
            //                                 WHERE nm_IsClosed__c = false LIMIT 1
            //                             )
            //                             FROM Account
            //                             WHERE nm_StudentNo__c =: objAccount.nm_StudentNo__c
            //                             AND nm_DateOfBirth__c =: objAccount.nm_DateOfBirth__c LIMIT 1];                        
            if( lstAccount != null && lstAccount.size() > 0 )
            {
                objAccount = lstAccount[0];
                objOTP.mobileNo = objAccount.PersonMobilePhone;
                objOTP.EmailId = objAccount.PersonEmail;
                objOTP.recordId = objAccount.id;
                objOTP.PersonContactId = objAccount.PersonContactId;
                objOTP.isEmailVerified = true;
                objOTP.isMobileVerified = true;
            }else
            {
                objAccount = null;
            }
        }
       
        if(objAccount !=null)
        {
            // get Pending Additional Payment In order to handle old cases
            list<nm_Payment__c> lstPendingAdditionalCharge=[select id,nm_Amount__c,nm_Merchant_Track_Id__c ,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__r.Accountid=:objAccount.id and nm_PaymentType__c ='Additional Charge' and nm_PaymentStatus__c ='Pending Extra Fees'];
            if(lstPendingAdditionalCharge.size()>0)
            {
                objAdditionalChargerPayment = lstPendingAdditionalCharge[0];
               
            }else
            {
                objAdditionalChargerPayment = null;
            }
           
            //get Account Related Opportunity
            List<Opportunity> lstOpportunity = [select id,Is_Re_Registration_Payment__c,Program_Name__c,AccountId,
                                                    EMI_Processing_Fee_Capital_Float__c,Capital_Float_Processing_Fee__c,
                                                    nm_Semester__c,Loan_Approved__c,Loan_Sanctioned__c,Loan_Type__c,
                                                    ActualPendingAmount__c, nm_Session__c, nm_Year__c,StageName,nm_Fee_Type__c,nm_Program__r.nmIsActive__c
                                                    ,Loan_Amount__c from Opportunity where AccountId =:objAccount.id  and Is_Re_Registration_Payment__c =false ];
            if(lstOpportunity.size()>0)
            {
                objOpportunity = lstOpportunity[0];
            }
        }
    }
   
    public PageReference LeadLogin()
    {
        objOTP.LoginType = 'Lead';
        objOTP.recordObject = 'Lead';
        // Inactive = objLead.InactiveLead__c;
        msgInitialize();      
        if( objLead.nm_RegistrationNo__c != null && objLead.nm_RegistrationNo__c != '')
        {
            // get Query Related to Lead and Account
            system.debug('LeadLogin-->');
            getMobileAndEmailForOTP();

            if(String.isBlank(objOTP.mobileNo) || String.isBlank(objOTP.EmailId)) {
                System.debug('Entered if condition 1');
                strSecToShow = 'msg';
                HeaderMessage = 'Invalid data';
                strBtnURL = '';
                lstMsg.add('No match found for entered Registration no');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No match found for entered Registration no.'));
                return null;
            } else if(objOTP.checkToAllowOTP && !objOTP.isEmailVerified) {
                System.debug('Entered if condition 2');
                // strSecToShow = 'otpVerify';
                sendOTP();
                // objOTP.lstMsg.add(objOTP.alertMsg);
            } else if(objOTP.checkToAllowOTP && !objOTP.isMobileVerified) {
                System.debug('Entered if condition 2');
                // strSecToShow = 'otpVerify';
                sendOTP();
                // objOTP.lstMsg.add(objOTP.alertMsg);
            }else if(objOTP.optStatus != 'OTP Verified' && objOTP.checkToAllowOTP) {
                System.debug('Entered if condition 2');
                // strSecToShow = 'otpVerify';
                sendOTP();
                // objOTP.lstMsg.add(objOTP.alertMsg);
            } else if(objOTP.optStatus == 'OTP Verified' || !objOTP.checkToAllowOTP) {
                verifyEmailAndMobile();
                getQueryRelatedToLeadAndAccount('LeadLogin');
                System.debug('Entered if condition 3');
                if(objLead !=null)
                {    
                    System.debug('objLead.nm_Session__c--'+objLead.nm_Session__c);
                    System.debug('objLead.nm_Year__c--'+objLead.nm_Year__c);              
               
                    if(objLead.Payment__r.size()>1)
                    {                
                        if( objLead.Payment__r != null && objLead.Payment__r.size() > 0 )
                        {
                            HeaderMessage = 'Payment Status';
                            strSecToShow = 'msg';
                            strBtnURL = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objLead.id+ urlGenerate + '&random=' + Math.random() ;
                            CheckalreadyDonePayment(objLead.Payment__r ,objLead.nm_ChooseaProgram__c,objLead.Is_Lateral__c);
                            lstMsg.add('Payment Amount 1200 of Registration is in waiting for Approval.');
                            System.debug('downPaymentDone-----'+downPaymentDone);
                            if(alreadyDonePayment)
                            {
                                strSecToShow = 'msg';
                                HeaderMessage = 'Important Message';
                                strBtnURL = 'nm_PrintRegistrationForm?id='+objLead.id;
                                lstMsg.clear();
                                lstMsg.add('Kindly Print Form.');
                                return null;
                            }else if(downPaymentDone){
                                DownPaymentcheck(objLead,null) ;
                                return null;
                                
                            }else{
                            strBtnURL = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objLead.id+ urlGenerate + '&random=' + Math.random() ;
                            lstMsg.clear();
                            lstMsg.add('Your All Payments Under Approval.');
                            return null;
                            }
                        }
                        return null;
                    }
                    else if(objLead.nm_InformationCenter__r.name =='EMERSON')
                    {
                        strSecToShow = 'msg';
                        HeaderMessage = 'Important Message';
                        strBtnURL = 'nm_PrintRegistrationForm?id='+objLead.id;
                        lstMsg.add('Kindly Print Form.');
                        return null;
                    }else if(objLead.InactiveLead__c)
                    {
                        strSecToShow = 'msg';
                        HeaderMessage = 'Important Message';               
                        lstMsg.add('Provided Registration Number had been expired.');
                        return null;
                    }
                    else
                    {
                        System.debug('Lead Related------>'+objLead.Payment__r.size());
                        if( objLead.Payment__r != null && objLead.Payment__r.size() > 0 && objLead.nm_EligiblityCriteria__c!=null )
                        {
                            HeaderMessage = 'Payment Status';
                            strSecToShow = 'msg';
                            strBtnURL = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objLead.id + urlGenerate + '&random=' + Math.random() ;                                                  
                            lstMsg.add('Payment Amount Rs.'+TotalAmountReceived+' has been received' );
                        }
                        else
                        {
                           
                            List<NM_Orgnisation_Based_FormConfiguration__c> lstConfig = [SELECT id FROM NM_Orgnisation_Based_FormConfiguration__c WHERE Configuration_Id__c =:objLead.Form_Id__c LIMIT 1];
                            Boolean formConfig = lstConfig.size() > 0 ? true : false;
                            String FormURL = '';
                            if(String.isNotBlank(corporateBatchName) && corporateBatchName.equalsIgnoreCase(System.Label.Conneqt_Batch)){
                                FormURL = '/nm/apex/corporatecompleteForm?batch='+System.Label.Conneqt_Batch+'&';
                                if(objLead.nm_ChooseaProgram__c == 'Master Programs') {
                                    FormURL = '/nm/apex/CorporateMBACompleteForm?batch='+System.Label.Conneqt_Batch+'&';
                                }
                            }
                            else if(formConfig) {
                                FormURL = '/apex/NM_CompleteOrginzationForm?FormId='+objLead.Form_Id__c+'&';
                            }
                            else{
                                FormURL = '/apex/nmcompleteFormRevised?';
                                if(objLead.nm_ChooseaProgram__c == 'Master Programs') {
                                    FormURL = '/apex/NMIMS_Executive_MBA?';
                                }
                                // else if(objLead.nm_ChooseaProgram__c == 'Master Programs' && objLead.Program_Type__c == 'MBA (X)') {
                                //     FormURL = '/apex/NMIMS_MBA_BusinessAnalytics?';
                                // }
                                else if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs') {
                                    FormURL = '/apex/NMIMS_BachelorForm?';
                                }else if(objLead.nm_InformationCenter__r.name == 'BAJAJ') {
                                    FormURL = '/apex/nmCompleteFormBajaj?';
                                }
                                if(objLead.Form_Id__c == 'INTERNATIONAL_FORM') {
                                    FormURL = '/apex/NM_InternationalForm?FormId=INTERNATIONAL_FORM&';
                                }
                                if (Boolean.valueOf(System.label.Only_Admission_Form_Allowed)) {
                                    FormURL = '/apex/AdmissionForm?';
                                }
                            }
                        
                                objLead.StudentLogin__c=true;
                                if(objLead != null){
                                    try{
                                        update objLead;
                                    }catch(DmlException e){
                                        System.debug(e.getMessage());
                                    }
                                }
                                nmRegistration_Controller objController = new nmRegistration_Controller();
                                objController.setCookie(objLead.id);
                                PageReference pgURL = new PageReference(FormURL+'id='+objLead.id+'&ReLogin=true');
                                pgURL.setRedirect(true);
                                return pgURL;
                            
                        
                        }  
                    }
                }
                // Lead after COnverted login for making remaining payment
                if(objAccount !=null)
                {
                    decimal peendingAmount = 0.0;
                
                    // do not allowed EMERSON student go for make payment Page Instead of it allowed to Print Form
                    if(objAccount.nm_Centers__r.name =='EMERSON')
                    {
                        strSecToShow = 'msg';
                        HeaderMessage = 'Important Message';
                        strBtnURL = 'nmPrintAdmissionForm?id='+objAccount.id;
                        lstMsg.add('Kindly Print Your Form');
                        return null;
                    }
                
                    if(objAdditionalChargerPayment !=null)
                    {
                        PageReference pgURL = new PageReference('/apex/nmAdditonalCharge?&id='+ objAdditionalChargerPayment.id);
                        pgURL.setRedirect(true);
                        return pgURL;
                    }
                
                    if(objAccount.Interview_Status__c == 'Rejected'){
                        System.debug('Interview Status--'+objAccount.Interview_Status__c);
                        String msg = 'Sorry , we regret to inform you that your Interview status is Rejected for '+objAccount.Program_Name__c+' program .';
                        strSecToShow = 'msg';
                        HeaderMessage = 'Interview Status';
                        lstMsg.clear();
                        lstMsg.add(msg);
                        return null;
                    }

                    Set<String> newProgram = new Set<String>{'B.Com', 'BBA', 'BBA-BA'};
                    Set<String> oldProgram = new Set<String>{'CGM', 'CBA'};

                    if (objAccount.Is_Lateral__c  && objAccount.Sem__c == '2' && objAccount.nm_Drive_Name__c == 'January2023' && (objAccount.nm_StudentStatus__c == 'Admission form & documents Approved' || objAccount.nm_StudentStatus__c == 'Admission Form & Documents Provisional') && String.isBlank(objAccount.nm_StudentNo__c) && String.isNotBlank(objAccount.nm_Program__c) 
                        && String.isNotBlank(objAccount.OldAccount__c) && newProgram.contains(objAccount.nm_Program__r.Name) && oldProgram.contains(objAccount.OldAccount__r.nm_Program__r.Name) &&
                        objOpportunity.nm_Semester__c == '2' && objOpportunity.nm_Session__c == 'January' && objOpportunity.nm_Year__c == 2023 && (objOpportunity.StageName == 'Closed Won - Re-registration Pending') ) {
                            showLateralPopup = true;
                    }

                    if (!showLateralPopup) {
                        System.debug('objOpportunity.StageName ==>'+objOpportunity.StageName);
                        // redirect Payment Made or Closed Opportunity to Print Form
                        if((objOpportunity.StageName.contains('Pending Payment') || objOpportunity.StageName =='Registration Done') && (objOpportunity.nm_Program__r.nmIsActive__c==true || objOpportunity.Program_Name__c=='MBA(X) - BA'))// redirect to Payment Page as Stage is Pending Payment
                        {
                            System.debug('objOpportunity.nm_Program__r.nmIsActive__c'+objOpportunity.nm_Program__r.nmIsActive__c);
                            // checking if Admission Payment is received or Not if Admission Payment not received then redirect to nmPaymentNew class
                            // decimal pendingAmount = producthelper.getPendingAmount(objOpportunity.id);
                            decimal pendingAmount = (decimal)objOpportunity.ActualPendingAmount__c;
                            set<String> setOfOppsId = new set<String>{objOpportunity.id};
                            List<nm_Payment__c> lstOppsRelatedPayment = [select nm_Installment_Payment_Ref__c,id,nm_Amount__c,nm_OpportunityNew__c,nm_OpportunityNew__r.IC__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_Merchant_Track_Id__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c In :setOfOppsId and nm_PaymentStatus__c !='Transaction Failed'];
                            // boolean AdmissionPaymentPaid = false;
                            if(lstOppsRelatedPayment.size()>0)
                            {
                                CheckalreadyDonePayment(lstOppsRelatedPayment,objAccount.nm_ChooseaProgram__c,objAccount.Is_Lateral__c);
                            }
                            
                            // if Admission Payment not paid then call nmPaymentnew
                            if(downPaymentDone){
                                DownPaymentcheck(null, objOpportunity);
                                return null;
                            }else if(!AdmissionPaymentPaid)
                            {
                                lstMsg.add('Pending Amount for semester ' + objOpportunity.nm_Semester__c + ' Rs. '+objOpportunity.ActualPendingAmount__c+'.');  
                                // String urlGenerate = '';
                                strBtnURL = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + urlGenerate +'&oppId=' + objOpportunity.Id+'&sem=1';
                            }else{ // if Admission Payment is Made then call Additional Charge for Taking remaning Late Fee
                                lstMsg.add('Pending Amount for semester ' + objOpportunity.nm_Semester__c + ' Rs. ' +pendingAmount+'.');
                                strBtnURL = 'nmAdditonalCharge?&id='+ objOpportunity.id +'&amount='+pendingAmount;
                            }
                        }else if(objOpportunity.StageName =='Payment made' || objOpportunity.StageName =='Closed')
                        {
                            List<nm_Payment__c> lstOppsRelatedPayment = [select nm_Installment_Payment_Ref__c,id,nm_Amount__c,nm_PaymentType__c,nm_PaymentStatus__c,nm_Merchant_Track_Id__c from nm_Payment__c where nm_OpportunityNew__c =:objOpportunity.id];
                            alreadyDonePayment = false;
                            if(lstOppsRelatedPayment.size()>0)
                            {                    
                                CheckalreadyDonePayment(lstOppsRelatedPayment ,objAccount.nm_ChooseaProgram__c,objAccount.Is_Lateral__c);                      
                            }
                            System.debug('alreadyDonePayment--> '+alreadyDonePayment);
                            if(alreadyDonePayment)
                            {
                                strSecToShow = 'msg';
                                HeaderMessage = 'Under Approval';
                                strBtnURL = 'nmPrintAdmissionForm?id='+objOpportunity.AccountId;
                                lstMsg.clear();
                                lstMsg.add('Your All Payments Under Approval.');
                                lstMsg.add('Please click OK to print form ');
                                return null;
                            }else{
                                HeaderMessage = 'Payment Status';
                                strSecToShow = 'msg';
                                strBtnURL = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c +'&oppId=' +  objOpportunity.Id + urlGenerate +'&sem=1';
                                System.debug('strBtnURL---->' + strBtnURL );
                                allowPayment = true;
                                lstMsg.clear();
                                lstMsg.add('Your All Payments Under Approval.');
                                return null;
                            }
                            return null;
                        }else if(objAccount.nm_StudentStatus__c=='Confirmed') // allowed to take remaning payment even student confirmed
                        {
                            strSecToShow = 'msg';
                            HeaderMessage = 'Admission Confirmed';
                            strBtnURL = 'nmPrintAdmissionForm?id='+objAccount.id;
                            lstMsg.add('Your Admission has been Confirmed. Student Number is '+objAccount.nm_StudentNo__c);
                            return null;
                        }
                        else if(objOpportunity.nm_Program__r.nmIsActive__c==false && objOpportunity.Program_Name__c!='MBA(X) - BA')
                        {
                            strSecToShow = 'msg';
                            HeaderMessage = 'Get in Touch';
                            strBtnURL = '';
                            lstMsg.add('Kindly get in touch with your Information center.');
                            System.debug('objOpportunity.nm_Program__r.nmIsActive__c'+objOpportunity.nm_Program__r.nmIsActive__c);
                            return null;
                        }
                        else
                        {
                            if(objAccount.nm_StudentStatus__c == 'Admission form & documents submitted')
                            {
                                lstMsg.add('Eligibility Documents uploaded, verification pending.' );
                            }
                            else if(objAccount.nm_StudentStatus__c == 'Documents Disapproved')
                            {                                      
                                list<nm_LinksForDocuments__c> lstDocuments = [select id ,
                                                                            nm_DocumentName__c ,
                                                                            nm_ReasonforDisapprove__c
                                                                            from nm_LinksForDocuments__c
                                                                            where nm_Account__c =:objAccount.id and nm_Status__c ='Disapproved'] ;  
                                if( lstDocuments != null && lstDocuments.size()>0)
                                {
                                    for(nm_LinksForDocuments__c objDoc: lstDocuments)
                                    {
                                        if( objDoc.nm_DocumentName__c != null )
                                        {
                                            string strDisDoc = 'Submitted Document '+ objDoc.nm_DocumentName__c+ ' has been disapproved ';
                                            if( objDoc.nm_ReasonforDisapprove__c != null )
                                                strDisDoc += 'reason "'+ objDoc.nm_ReasonforDisapprove__c + '"';
                                                strDisDoc += '.';
                                            lstMsg.add( strDisDoc ) ;
                                        }
                                    }
                                }          
                            }
                        }
                    
                        if( lstMsg != null && lstMsg.size() > 0 )
                        {
                            HeaderMessage = 'Student Status';
                            strSecToShow = 'msg';
                        }
                    }

                }
            
                if(objAccount ==null && objLead ==null)
                {
                    strSecToShow = 'msg';
                    HeaderMessage = 'Invalid data';
                    strBtnURL = '';
                    lstMsg.add('No match found for entered Registration no and Date of Birth.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No match found for entered Registration no and Date of Birth.'));
                    return null;
                }
            }
        } else {
            objLead = new Lead();
            strSecToShow = 'msg';
            message = '';
            HeaderMessage = 'Fields Required';
            strBtnURL = '';
            lstMsg.add('Please enter Registration no and Date of Birth.');
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 11-07-2022 
    **/
    public void validateOTPStatus() {
        system.debug('objOTP. --> ' + JSON.serialize(objOTP));
        objOTP.lstMsg.clear();
        if(String.isBlank(objOTP.optStatus)) {
            sendOTP();
        } else if(objOTP.optStatus == '903') {
            objOTP.lstMsg.add('Incorrect OTP Entered, kindly try again.');
            sendOTP();
        } else if(objOTP.optStatus == '907') {
            objOTP.lstMsg.add('OTP has been expired, kindly try again.');
            sendOTP();
        } else {
            objOTP.lstMsg.add('OTP Verification has been failed, kindly try again');
            sendOTP();
        }
        system.debug('optStatus --> '  + objOTP.optStatus);
    }

    // TO Check pending payment for Program change 
    public Boolean checkProgramChange(Opportunity opp, List<nm_Payment__c> lstOppsRelatedPayment) {
        if(opp.nm_Semester__c == '1' ) {
            Decimal programChangeWithStudyKitFeeReceived = 0;
            Decimal ProgramChangeFeeReceived = 0;
            Decimal StudyKitFeeReceived = 0;
            Decimal ProgramChangeProductPrice = 0;
            Decimal StudyKitProductPrice = 0;
            for (nm_Payment__c objPayment : lstOppsRelatedPayment) {
                if(objPayment.nm_PaymentType__c.contains('ProgramChange - StudentKit')){
                    programChangeWithStudyKitFeeReceived += objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ProgramChange')){
                    ProgramChangeFeeReceived += objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('StudentKit')){
                    StudyKitFeeReceived += objPayment.nm_Amount__c;
                }
            }
            List<OpportunityLineItem> lstOppLineItems = opp.OpportunityLineItems;
            for (OpportunityLineItem objLineItem : lstOppLineItems) {
                if(objLineItem.Product_Name__c.contains('Program Change')){
                    ProgramChangeProductPrice += objLineItem.ActualSalePrice__c;
                }else if(objLineItem.Product_Name__c.contains('Student Kits')){
                    StudyKitProductPrice += objLineItem.ActualSalePrice__c;
                }
            }
            if (programChangeWithStudyKitFeeReceived > 0 && ProgramChangeProductPrice > 0 && StudyKitProductPrice > 0 ) {
                programChangeWithStudyKitFeeReceived = programChangeWithStudyKitFeeReceived - (ProgramChangeProductPrice + StudyKitProductPrice);
                ProgramChangeProductPrice = 0;
                StudyKitProductPrice = 0;
            }
            if (ProgramChangeProductPrice > 0) {
                ProgramChangeProductPrice = ProgramChangeProductPrice - ProgramChangeFeeReceived;
                StudyKitProductPrice = 0;
                programChangeWithStudyKitFeeReceived = 0;
            }
            if (StudyKitProductPrice > 0) {
                StudyKitProductPrice = StudyKitProductPrice - StudyKitFeeReceived;
                ProgramChangeProductPrice = 0;
                programChangeWithStudyKitFeeReceived = 0;
            }
            if (programChangeWithStudyKitFeeReceived > 0 || StudyKitProductPrice > 0 || ProgramChangeProductPrice > 0) {
                return true;
            }
        }
        return false;
    }

    //To Check Program change is allowed
    public Boolean isProgramChangeAllowed(Opportunity objOpp, List<nm_Payment__c> lstOppsRelatedPayment ) {
        if (objOpp.nm_Semester__c == '1') {
            Date today = Date.today();
            List<Calender__c> lstCal = [SELECT Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c , Session__c, Year__c FROM Calender__c WHERE Category__c='Admission' 
            AND Session_Start_Date__c <=:today AND Session_End_Date__c >=:today AND Session__c = :objOpp.nm_Session__c AND Year__c = :objOpp.nm_Year__c LIMIT 1];
            if (lstCal.size() > 0) {
                for (nm_Payment__c objPay : lstOppsRelatedPayment) {
                    if (String.isNotBlank(objPay.nm_PaymentStatus__c) && objPay.nm_PaymentStatus__c == 'Payment Made' && String.isNotBlank(objPay.nm_PaymentType__c) && (objPay.nm_PaymentType__c.contains('ProgramChange') || (objPay.nm_PaymentType__c.contains('StudentKit') ) )) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
   
    // section for login after student confirmed and for Re-Registred
    public PageReference studentLogin()
    {
        objOTP.LoginType = 'Account';
        objOTP.recordObject = 'Account';
        msgInitialize();
        if( objAccount.nm_StudentNo__c != null && objAccount.nm_StudentNo__c != '' )
        {
            // get Query related to Account and Student Program
            getQueryRelatedToLeadAndAccount('studentLogin');
            String closedWonSession = null;
            integer closedWonYear = 0;
            string AccountBatchName = null;
            String ValidityMonth = null;
            integer ValidityYear = 0;
            string FeeType=null;
            Opportunity objOppRecord = new Opportunity();
            if(String.isBlank(objOTP.mobileNo) || String.isBlank(objOTP.EmailId)) {
                System.debug('Entered if condition 1');
                strSecToShow = 'msg';
                HeaderMessage = 'Invalid data';
                strBtnURL = '';
                lstMsg.add('No match found for entered Student no');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No match found for entered Student no.'));
                return null;
            } else if(objOTP.optStatus != 'OTP Verified' && objOTP.checkToAllowOTP) {
                System.debug('Entered if condition 2');
                // strSecToShow = 'otpVerify';
                sendOTP();
                // objOTP.lstMsg.add(objOTP.alertMsg);
            } else if(objOTP.optStatus == 'OTP Verified' || !objOTP.checkToAllowOTP) {
                if(objAccount !=null)
                {   
                    List<Opportunity> lstOpp = [select id,TermRepeated__c,ActualPendingAmount__c,EMI_Processing_Fee_Capital_Float__c,Capital_Float_Processing_Fee__c ,Loan_Approved__c,Loan_Sanctioned__c,
                                                Loan_Type__c,IcChangeFee__c,Is_Re_Registration_Payment__c, nm_Session__c, nm_Year__c ,nm_Category__c,ProgramChangeFee__c,Accountid,StageName,
                                                nm_Fee_Type__c, nm_PendingAmount__c,Loan_Amount__c,Sem__c,nm_Semester__c 
                                                from Opportunity where Accountid=:objAccount.id  order by nm_Semester__c desc];

                    list<Opportunity> lstOpportunityToCheckPendingPaymnet = new List<Opportunity>();
                    list<Opportunity> lstOpportunityToCheckPendingForLoanandInstallment = new List<Opportunity>();
                    list<Opportunity> lstOpportunityClosedorPaid = new List<Opportunity>();
                    list<Opportunity> lstOpportunityClosedWonReRegistrationPending = new List<Opportunity>(); //added new//
                    list<Opportunity> lstOpportunityToCheck = new List<Opportunity>();
                    list<Opportunity> lstOpportunityTermFeePending = new List<Opportunity>();
                    if(lstOpp.size() > 0){
                        for(Opportunity opp:lstOpp){
                            String stgaeName = opp.StageName;
                                if(String.isNotBlank(stgaeName) && (stgaeName == 'Pending Payment - Loan' || stgaeName == 'Pending Payment - Instalment')){                                                      
                                lstOpportunityToCheckPendingForLoanandInstallment.add(opp);
                            }else if(String.isNotBlank(stgaeName) && (stgaeName == 'Payment made' || stgaeName == 'Closed Won')){
                                lstOpportunityClosedorPaid.add(opp);
                            }else if(String.isNotBlank(stgaeName) && (stgaeName == 'Closed Won - Re-registration Pending' || stgaeName == 'Re-Registration Pending' || stgaeName=='Pending Payment')){                           
                                lstOpportunityClosedWonReRegistrationPending.add(opp);
                            }                       
                            if(opp.TermRepeated__c && stgaeName.contains('Pending Payment'))
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
                        strBtnURL = 'nmPrintAdmissionForm?id='+objAccount.id;
                        lstMsg.add('Kindly Print Your Form');
                    
                        return null;
                    }
                    System.debug('objAdditionalChargerPayment---->'+objAdditionalChargerPayment);
                    if(objAdditionalChargerPayment !=null)
                    {
                        PageReference pgURL = new PageReference('/apex/nmAdditonalCharge?&id='+ objAdditionalChargerPayment.id);
                        pgURL.setRedirect(true);
                        return pgURL;
                    }
                
                    if(objAccount.Interview_Status__c == 'Rejected'){
                        System.debug('Interview Status--'+objAccount.Interview_Status__c);
                        String msg = 'Sorry , we regret to inform you that your Interview status is Rejected for '+objAccount.Program_Name__c+' program .';
                        strSecToShow = 'msg';
                        HeaderMessage = 'Interview Status';
                        lstMsg.clear();
                        lstMsg.add(msg);
                        return null;
                    }
                
                    //get Most recent Closed won or Payment Made Opportunity Session and Year
                    Opportunity mostRecentClosedPaidOpportunity = null;
                    if(lstOpportunityClosedorPaid != null &&  lstOpportunityClosedorPaid.size() > 0)
                    {
                        mostRecentClosedPaidOpportunity = lstOpportunityClosedorPaid[0];
                        closedWonSession = mostRecentClosedPaidOpportunity.nm_Session__c;
                        closedWonYear = Integer.valueOf(mostRecentClosedPaidOpportunity.nm_Year__c);
                    }
                
                    if( objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0 )
                    {
                        string Sem = '';
                        string Sem1 = string.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
                        string Sem2 = string.valueOf(integer.valueOf((integer)(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) +1));
                        String feesPaidSem = String.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
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
                    
                        Calender__c objCalender = new Calender__c();
                        String calendarSession = null;
                        integer calendarSessionYear = 0;
                    
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
                        sem = String.isNotBlank(sem) ? sem : string.valueOf(integer.valueOf((integer)(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) +1));
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
                            Feetype = objOppRecord.nm_Fee_Type__c ;
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
                                    strBtnURL = 'nmPaymentNew?&IsReRestration=true&oppId='+objOppRecord.id+ urlGenerate +'&id='+objOppRecord.AccountId;
                                    return null;
                                }
                                //Opportunity objOppRecord = lstOpportunityToCheckPendingForLoanandInstallment[0];
                                // if Admission Payment not paid then call nmPaymentnew
                                system.debug('downPaymentDone--->'+downPaymentDone);
                                if(downPaymentDone){
                                    DownPaymentcheck(null, objOppRecord);
                                    return null;
                                }
                                else if(!AdmissionPaymentPaid || TermFeeProductInserted) {
                                    
                                    if(LateFeeProductInserted && !LateFeePaid)
                                    {
                                        pendingAmount = pendingAmount - LateFee ;
                                    }
                                    System.debug('enter in pending Admission fee');
                                    //Opportunity is already created for new Session, but not paid. Ask student to pay now
                    
                                PageReference pgURL = new PageReference(System.Label.GoPayment_Url+'id='+ objAccount.id+'&IsReRestration=true&sem='+Sem + urlGenerate +'&amount='+pendingAmount);
                                pgURL.setRedirect(true);
                                return pgURL;
                    
                                    
                                }else{ // if Admission Payment is Made then call Additional Charge for Taking remaning Late Fee
                                    //Opportunity is already created for new Session, but not paid. Ask student to pay now
                                    System.debug('Pending Late Fee Amount--->'+pendingAmount);
                                    PageReference pgURL = new PageReference('/apex/nmAdditonalCharge?&id='+objOppRecord.id+'&amount='+objOppRecord.ActualPendingAmount__c);
                                    pgURL.setRedirect(true);
                                    return pgURL;
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
                            lstMsg.add('Please click OK to print form for Sem '+mostRecentClosedPaidOpportunity.nm_Semester__c + 'registration.');
                            List<String> lstPGProgram = new List<String>{'Certificate Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
                            verifyProgramChangeShouldBeAllowed(String.valueOf(mostRecentClosedPaidOpportunity.Sem__c), mostRecentClosedPaidOpportunity.nm_Session__c, mostRecentClosedPaidOpportunity.nm_Year__c, objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c, objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c, mostRecentClosedPaidOpportunity.id);
                            if(lstPGProgram.contains(objAccount.nm_ChooseaProgram__c) || (objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c == 'MBA')) {
                                Map<String,Decimal> feeTypeVsSem = new Map<String,Decimal>{'admission'=>1,'AnnualFee'=>2,'3SemFee'=>3,'MultipleSemFee'=>3};
                                Decimal totalSem = objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c;
                                if(!mostRecentClosedPaidOpportunity.Is_Re_Registration_Payment__c && feeTypeVsSem.containsKey(mostRecentClosedPaidOpportunity.nm_Fee_Type__c)
                                && feeTypeVsSem.get(mostRecentClosedPaidOpportunity.nm_Fee_Type__c) < totalSem) {
                                    lstMsg.add('Click Proceed to Pay button to pay the balance amount');
                                    paymentUrl = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + urlGenerate +'&oppId=' + mostRecentClosedPaidOpportunity.id+'&sem='+mostRecentClosedPaidOpportunity.Sem__c+'&pp=true';
                                }
                            }
                            return null;
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
                                        return null;
                                    } else {
                                        System.debug('Entered PostGrad Validity If Block');
                                        pageReference pg = new pageReference ('/apex/'+Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id + urlGenerate +'&calendarSession='+calendarSession+ '&calendarSessionYear='+calendarSessionYear);
                                        pg.setRedirect(true);
                                        return pg;
                                    }
                                } else {
                                    system.debug('<--Error Block For Post Grad Validity->');
                                    strSecToShow = 'msg';
                                    HeaderMessage = 'Re-Registration Error';
                                    strBtnURL = '';
                                    lstMsg.add('Hello! Your re-registration has been put on hold. To reactivate the same, please complete your document submission process(as per eligibility criteria). You may submit all documents to your AEP.');
                                    return null;
                                }
                            }
                            else
                            {
                                    system.debug('<--Error Block For Post Grad Validity->');
                                    strSecToShow = 'msg';
                                    HeaderMessage = 'Re-Registration Error';
                                    strBtnURL = '';
                                    lstMsg.add('Can not Re-Register because your '+lstStudentProgram[0].nm_Program__r.nm_Type__c +' validity Expired');
                                    return null;
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
                                return null;
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
                                        return null;
                                    } else {
                                        PageReference pgURL = new PageReference('/apex/'+Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id +urlGenerate+'&calendarSession='+calendarSession+ '&calendarSessionYear='+calendarSessionYear);
                                        pgURL.setRedirect(true);
                                        return pgURL;
                                    }
                                } else {
                                    system.debug('<--Error Block For Post Grad Validity->');
                                    strSecToShow = 'msg';
                                    HeaderMessage = 'Re-Registration Error';
                                    strBtnURL = '';
                                    lstMsg.add('Hello! Your re-registration has been put on hold. To reactivate the same, please complete your document submission process(as per eligibility criteria). You may submit all documents to your AEP. ');
                                    return null;
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
                                List<String> lstPGProgram = new List<String>{'Certificate Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
                                if(lstPGProgram.contains(objAccount.nm_ChooseaProgram__c) || (objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c == 'MBA')) {
                                    Map<String,Decimal> feeTypeVsSem = new Map<String,Decimal>{'admission'=>1,'AnnualFee'=>2,'3SemFee'=>3,'MultipleSemFee'=>3};
                                    Decimal totalSem = objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c;
                                    if(!mostRecentClosedPaidOpportunity.Is_Re_Registration_Payment__c && feeTypeVsSem.containsKey(mostRecentClosedPaidOpportunity.nm_Fee_Type__c)
                                    && feeTypeVsSem.get(mostRecentClosedPaidOpportunity.nm_Fee_Type__c) < totalSem) {
                                        lstMsg.add('Click Proceed to Pay button to pay the balance amount');
                                        paymentUrl = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + urlGenerate +'&oppId=' + mostRecentClosedPaidOpportunity.id+'&sem='+mostRecentClosedPaidOpportunity.Sem__c+'&pp=true';
                                    }
                                }
                                return null;
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
                        return null;
                    }
                }
                else
                {
                    strSecToShow = 'msg';
                    HeaderMessage = 'Invalid data';
                    strBtnURL = '';
                
                    lstMsg.add('No match found for entered Student no and Date of Birth.');
                }
            }
        }
        else
        {
            //Invalid Credentials entered.
            objAccount = new Account();
            strSecToShow = 'msg';
            message = '';
            HeaderMessage = 'Fields Required';
            strBtnURL='';
            lstMsg.add('Please enter Student no and Date of Birth.');
        }
        return null;
    }

    public PageReference OptForCoursera() {
        objOTP.LoginType = 'Account';
        objOTP.recordObject = 'Account';
        msgInitialize();
        if(objAccount.nm_DateOfBirth__c != null && String.isNotBlank(objAccount.nm_StudentNo__c) && showCoursera)
        {
            // get Query related to Account and Student Program
            getQueryRelatedToLeadAndAccount('studentLogin');
            Integer semester = Integer.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
            List<Opportunity> lstOpp = [SELECT id,TermRepeated__c,ActualPendingAmount__c,EMI_Processing_Fee_Capital_Float__c,Capital_Float_Processing_Fee__c ,Loan_Approved__c,Loan_Sanctioned__c,
                                        Loan_Type__c,IcChangeFee__c,Is_Re_Registration_Payment__c, nm_Session__c, nm_Year__c ,nm_Category__c,ProgramChangeFee__c,Accountid,StageName,
                                        nm_Fee_Type__c, nm_PendingAmount__c,Loan_Amount__c,Sem__c,nm_Semester__c,Coursera__c,Account.nm_Tagged_Pricebook__c,
                                        (SELECT OpportunityId ,ActualSalePrice__c,Product_Name__c from OpportunityLineItems Where Product_Name__c='Coursera')
                                        FROM Opportunity WHERE Accountid=:objAccount.id AND Sem__c=:semester LIMIT 1];
            
            if(lstOpp.size() > 0) {
                if(!lstOpp[0].Coursera__c) {
                    String session = lstOpp[0].nm_Session__c;
                    String currentAdmissionYear = String.valueOf(lstOpp[0].nm_Year__c);
                    String programSpecialization = objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c;
                    List<NM_Payment_Form_Configuration__c> lstConfig = [SELECT id,Show_Coursera__c FROM NM_Payment_Form_Configuration__c WHERE Session__c=:session AND Current_Admission_Year__c=:currentAdmissionYear AND Program_Category__c=:objAccount.nm_ChooseaProgram__c AND Payment_Type__c = 'Re-Registration' AND Program_Type__c=:programSpecialization LIMIT 1];
                    if(lstConfig.size() > 0 && lstConfig[0].Show_Coursera__c) {
                        String oppId = lstOpp[0].id;
                        List<nm_Payment__c> lstOppsRelatedPayment = [select nm_Installment_Payment_Ref__c,id,nm_Amount__c,nm_OpportunityNew__c,nm_OpportunityNew__r.IC__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_Merchant_Track_Id__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c =:oppId and nm_PaymentStatus__c !='Transaction Failed'];
                        if(lstOppsRelatedPayment.size()>0) {
                            CheckalreadyDonePayment(lstOppsRelatedPayment,objAccount.nm_ChooseaProgram__c,objAccount.Is_Lateral__c);
                        }
                        if(isCourseraAlreadyOpted) {
                            strSecToShow = 'msg';
                            HeaderMessage = 'Important Message';
                            lstMsg.add('Coursera Payment already made');
                            return null;
                        } else {
                            strSecToShow = 'msg';
                            HeaderMessage = 'Important Message';
                            lstMsg.add('Click Here to proceed to pay for Coursera');
                            lstMsg.add('Note: You have selected to opt for the Annual Coursera subscription, Kindly note cancellation from Coursera can be opted within 7 days only.');
                            strBtnURL = 'nmAdditonalCharge?pyt=coursera&id='+lstOpp[0].id+ urlGenerate;
                            return null;
                        }
                    }
                } else {
                    strSecToShow = 'msg';
                    HeaderMessage = 'Important Message';
                    lstMsg.add('Already coursera Opted.');
                    return null;
                }
            }
        }
        strSecToShow = 'msg';
        HeaderMessage = 'Important Message';
        lstMsg.add('Kindly Check Later');
        return null;
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
   
   
    public PageReference studentZOneReRegistrationLogin()
    {
        // if token is not null means request from studentzone
        if(token !='' && token !=null)
        {
            System.debug('token1--'+token);
            //token = EncodingUtil.urlEncode(token, 'UTF-8');
            token = token.replace(' ','+');
            System.debug('token2--'+token);
            Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
            Blob encryptedData  = EncodingUtil.base64Decode(token);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128',key, encryptedData);
            String b64Decrypted = decryptedData.toString();
            // b64Decrypted contains studentNo~CurrentTime
            System.debug('decryptedData-->'+decryptedData.toString());
            long currentTimeInMiliseconds = DateTime.now().getTime();
            String sapId = b64Decrypted.split('~')[0];
            long timeUrlHit = Long.valueOf(b64Decrypted.split('~')[1]);
           
            System.debug('currentTimeInMiliseconds-->'+currentTimeInMiliseconds);
            long diff = currentTimeInMiliseconds - timeUrlHit;
            System.debug('diff-->'+diff);
           
            if((!sapId.equalsIgnoreCase(objAccount.nm_StudentNo__c))){
                strSecToShow = 'msg';
                HeaderMessage = 'Invalid data';
                strBtnURL = '';
                lstMsg.add('link has been expired.');
                return null;
            }else{
                List<Account> lstAccount = [select id,nm_DateOfBirth__c from Account where nm_StudentNo__c =:objAccount.nm_StudentNo__c ];
                if(lstAccount.size()>0)
                {
                    objAccount.nm_DateOfBirth__c = lstAccount[0].nm_DateOfBirth__c;
                }
                return studentLogin();
            }
        }    
        return null;
    }
   
    public void getMapOfActiveCalender()
    {
        List<Calender__c> lstActiveCalender = [Select id, Category__c ,Closure_Message__c ,Session__c ,Year__c ,Session_End_Date__c ,nm_Type__c,Session_Start_Date__c
                                              from Calender__c
                                              where Session_Start_Date__c <= :Date.Today() ];
        if(lstActiveCalender.size() > 0)
        {
            for(Calender__c objCal : lstActiveCalender)
            {
                if(objCal.Session_End_Date__c >= Date.today()) // if Calender is live then don't show error msg
                {
                    System.debug('calender Live--'+objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c);
                    mapOfActiveCalenderCategoryAndMessage.put(objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c,'Calender Live');
                }else{ // if Calender is live then show error msg
                     System.debug('Window Closed --'+objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c+'-'+objCal.nm_Type__c);
                    mapOfActiveCalenderCategoryAndMessage.put(objCal.Category__c+'-'+objCal.Session__c+'-'+objCal.Year__c +'-'+objCal.nm_Type__c ,objCal.Closure_Message__c );
               }  
            }
        }
    }
   
   /* public void getProgramsList(String programCategory)
    {
        if(programCategory != null)
        {
             List<nm_Program__c> lstPrograms = [select id, Name, nm_ProgramName__c from nm_Program__c where nm_Type__c =: programCategory and nmIsActive__c = true order by Name asc];
             if(lstPrograms.size()>0)
             {
                 for(nm_Program__c objProgram : lstPrograms)
                 {
                     sasPrograms.add(objProgram.id);
                 }
             }
        }
    }*/
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

    public void DownPaymentcheck(Lead objLead, Opportunity objOpportunity)
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
            } else{
                        lstMsg.clear();
                        lstMsg.add('Your Loan Application is  Approved.');
                        lstMsg.add('Kindly Print Form.');
                        strSecToShow = 'msg';
                        HeaderMessage = 'Important Message';
                        strBtnURL = 'PrintReRegistrationForm?target=pdf&id='+objOpportunity.AccountId+'&sem='+objOpportunity.nm_Semester__c;
                    }
                    
                    //return null;
                    
        }else if(objLead!=null)
        {
                if(!objLead.Loan_Sanctioned__c || !objLead.Loan_Approved__c){
                    lstMsg.clear();
                    lstMsg.add('Your Loan Application is Under Approval.');
                    if(objLead.Loan_Type__c.contains('Capital Float')){
                        lstMsg.add('You have opted for Capital Float Loan application , will confirm once done . Kindly Print Form.');
                    }else if(objLead.Loan_Type__c!=null){ // for other Loan Application Re-direct student to PostPaymentPage
                        lstMsg.add('Proceed to Loan Application .');
                        strSecToShow = 'msg';
                        HeaderMessage = 'Important Message';
                        strBtnURL = 'postPaymentPage?ResTrackId='+merchantTrackId;
                        //return null;
                    }
                }else{
                    lstMsg.clear();
                    lstMsg.add('Your Loan Application is  Approved.');
                    lstMsg.add('Kindly Print Form.');
                strSecToShow = 'msg';
                HeaderMessage = 'Important Message';
                strBtnURL = 'nm_PrintRegistrationForm?id='+objLead.id;
                //return null;

                }
                // strSecToShow = 'msg';
                // HeaderMessage = 'Important Message';
                //strBtnURL = 'nm_PrintRegistrationForm?id='+objLead.id;
                //return null;
        }
    }
    
    public void sendOTP() {
        objOTP.lstMsg.clear();
        if (!objOTP.isEmailVerified || objOTP.OtpMode == 'E') {
            strSecToShow = 'otpVerify';
            String smsMessage = generateOTPMSG();
            sendEmailOTP();
            objOTP.OtpMode = 'E';
            objOTP.optStatus = 'OTP Sent';
            objOTP.lstMsg.add(objOTP.alertMsg);
            String objOTPJSON = JSON.serialize(objOTP);
            System.debug('objOTPJSON-->'+objOTPJSON);
            // setCookieForObjOTP(objOTPJSON);
            
        } else if(!objOTP.isMobileVerified  || objOTP.OtpMode == 'M') {
            if(System.Label.Enable_SMS_Service=='Yes'){
                strSecToShow = 'otpVerify';
                String smsMessage = generateOTPMSG();
                sendmGageSMSFuture(objOTP.mobileNo.left(10),smsMessage);
                objOTP.OtpMode = 'M';
                objOTP.alertMsg = 'OTP has been sent to your mobile no ******'+objOTP.mobileNo.right(4);
                objOTP.optStatus = 'OTP Sent';
                objOTP.lstMsg.add(objOTP.alertMsg);
                String objOTPJSON = JSON.serialize(objOTP);
                // setCookieForObjOTP(objOTPJSON);
                System.debug('optStatus-->'+objOTP.optStatus);
            }
        } else if (objOTP.isEmailVerified && objOTP.isMobileVerified && objOTP.OtpMode == 'N') {
            objOTP.OtpMode = 'D';
            String objOTPJSON = JSON.serialize(objOTP);
            // setCookieForObjOTP(objOTPJSON);
            system.debug('objOTP.OtpMode --> ' + objOTP.OtpMode);
        }
        system.debug('serialize --> '+JSON.serialize(objOTP));
        
    } 

    @future(callout=true)
    public static void sendmGageSMSFuture(String mobileNumber, String msg){        
        SMSSenderWebService.sendmGageSMS(mobileNumber, msg) ;
    }

    public void VerifyOTP() {
        msgInitialize();
        objOTP.lstMsg.clear();
        objOTP.lstMsg.add(objOTP.alertMsg);
        strSecToShow = 'otpVerify';
        if(String.isNotBlank(objOTP.Otp)) {
            Long otpEnteredTime = DateTime.now().getTime();
            Long milliseconds = otpEnteredTime - objOTP.otpSentTime;
            Long seconds = milliseconds / 1000;
            if(objOTP.OtpCode == objOTP.Otp && seconds <= 180){
                objOTP.optStatus = 'OTP Verified';
                objOTP.lstMsg.clear();
                verifyEmailAndMobile();
            }else if(objOTP.OtpCode != objOTP.Otp) {
                objOTP.optStatus = '903';
                objOTP.lstMsg.add('Incorrect OTP Entered, kindly try again.');
            }else if(seconds > 180){
                objOTP.optStatus = '907';
                objOTP.lstMsg.add('OTP has been expired, kindly try again.');
            }else{
                objOTP.optStatus = '906';
                objOTP.lstMsg.add('OTP Verification has been failed, kindly try again');
            }
        }
    }

    public String generateOTPMSG() {
        Integer STRING_LENGTH = 5;
        Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
        objOTP.OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        // objOTP.OtpCode = '111111';
        System.debug('OtpCode-->'+objOTP.OtpCode);
        String smsMessage = objOTP.OtpCode +' is your verification code for NMIMS CDOE.';
        objOTP.otpSentTime = DateTime.now().getTime();
        return smsMessage;
    }

    public void sendEmailOTP() {
        try {
            String mailRecordId = '';
            String mailTemplateId = '';
            // To Query Organisation Details.
            // OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS Global' LIMIT 1];
            // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // mail.setOrgWideEmailAddressId(owe.id);
            // mail.setReplyTo(owe.Address);
            if(objOtp.recordObject == 'Lead') {
                // To Query the Email Template.
                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Lead' LIMIT 1];
                objLead.Email_Verification_Token__c = objOTP.OtpCode;
                objLead.id = objOTP.recordId;
                update objLead;

                // mail.setTargetObjectId(objLead.Id);
                // mail.setTemplateId(emailTemplate.Id);
                mailRecordId = objLead.Id;
                mailTemplateId = emailTemplate.Id;
            } else if(objOtp.recordObject == 'Account') {
                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Account' LIMIT 1];
                Account objAccountToUpdate = new Account();
                objAccountToUpdate.Email_Verification_Token__c = objOTP.OtpCode;
                objAccountToUpdate.id = objOTP.recordId;
                update objAccountToUpdate;

                // mail.setTargetObjectId(objOTP.PersonContactId);
                // mail.setTemplateId(emailTemplate.Id);
                mailRecordId = objOTP.PersonContactId;
                mailTemplateId = emailTemplate.Id;
            }
            // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            SendEmailForOTP.callEmailAlertFlow(mailRecordId, mailTemplateId);
            String s2 = objOTP.EmailId.substringBefore('@');
            String s1 = '';
            Integer count = s2.length() - 4;
            Integer loopCount = 0;
            while (loopCount < count) {
                s1 = s1 + '*';
                loopCount++;
            }
            s2 = s2.substring(0,2) + s1 + s2.right(2) +'@';
            objOTP.alertMsg = 'OTP has been sent to your Email Id '+ s2 + objOTP.EmailId.substringAfter('@');
        } catch (Exception ex) {
            System.debug('Error Msg =>'+ex.getMessage());
            System.debug('Error No =>'+ex.getLineNumber());
        }
    }

    public void verifyEmailAndMobile() {
        try {
            if((!objOTP.isEmailVerified || !objOTP.isMobileVerified) && objOTP.checkToAllowOTP) {
                if(String.isBlank(objOTP.PersonContactId)) {
                    Boolean updateRec = false;
                    Lead objLeadToUpdate = new Lead();
                    objLeadToUpdate.id = objOTP.recordId;
                    if(objOTP.OtpMode == 'E' && !objOTP.isEmailVerified) {
                        objLeadToUpdate.nm_IsEmailVerified__c = true;
                        objOTP.isEmailVerified = true;
                        updateRec = true;
                        objOTP.OtpMode = '';
                    } else if(objOTP.OtpMode == 'M' && !objOTP.isMobileVerified) {
                        objLeadToUpdate.Is_Mobile_Verified__c = true;
                        objOTP.isMobileVerified = true;
                        updateRec = true;
                        objOTP.OtpMode = '';
                    }
                    if(updateRec) {
                        update objLeadToUpdate;
                    }
                } else if(String.isNotBlank(objOTP.PersonContactId)) {
                    Boolean updateRec = false;
                    Account objAccountToUpdate = new Account();
                    objAccountToUpdate.Id = objOTP.recordId;
                    if(objOTP.OtpMode == 'E' && !objOTP.isEmailVerified) {
                        objAccountToUpdate.nm_IsEmailVerified__c = true;
                        objOTP.isEmailVerified = true;
                        objOTP.OtpMode = '';
                        updateRec = true;
                    } else if(objOTP.OtpMode == 'M' && !objOTP.isMobileVerified) {
                        objAccountToUpdate.Is_Mobile_Verified__c = true;
                        objOTP.isMobileVerified = true;
                        objOTP.OtpMode = '';
                        updateRec = true;
                    }
                    if(updateRec) {
                        update objAccountToUpdate;
                    }
                }
            }
        } catch (Exception er) {
            System.debug('Error ==>'+er.getMessage());
            System.debug('Error Line No.==>'+er.getLineNumber());
        }
    }

    public Boolean checkToAllowValidityExtension() {
        Map<String,Integer> mapOfMonthAndNumber = new Map<String,Integer>{'January'=>1,'February'=>2,'March'=>3,'April'=>4,'May'=>5,'June'=>6,'July'=>7,'August'=>8,'September'=>9,'October'=>10,'November'=>11,'December'=>12};
        HelperClassForValidityExtension objHelperclass = new HelperClassForValidityExtension();
        Map<String,String> mapOfValidRecord = objHelperclass.ValidateRecord(objAccount.nm_StudentNo__c,objAccount.nm_DateOfBirth__c,mapOfMonthAndNumber);
        if(mapOfValidRecord.get('Success')!=null) {
            return true;
        }
        return false;
    }

    public Boolean calenderCheckForCorporate( String BatchNamePara){
       
        Date ExpireDate = Date.valueOf(System.Label.Conneqt_Expired_date);
        String BatchName = System.Label.Conneqt_Batch;

        if(ExpireDate != null && BatchName != null){
            if(ExpireDate >= Date.today() && BatchNamePara.equalsIgnoreCase(BatchName)){
                return true;
            }
        }

        return false;
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
            programChangeUrl = Label.ReRegistrationForm+'?target=RegForm&id='+ objAccount.id +urlGenerate+'&calendarSession='+lstCal[0].Session__c+ '&calendarSessionYear='+lstCal[0].Year__c+'&oppSem='+Sem + '&oppPcId='+oppId;
        }
    }

    public class OTPFields {
        public String optStatus {get;set;}
        public String Otp {get;set;}
        public String resendOtp {get;set;}
        public String LoginType {get;set;}
        public String recordObject {get;set;}
        public String OtpCode {get;set;}
        public Long otpSentTime {get;set;}
        public String mobileNo {get;set;}
        public String EmailId {get;set;}
        public Boolean checkToAllowOTP {get;set;}
        public Boolean skipOTP {get;set;}
        public String OtpMode {get;set;}
        public String recordId {get;set;}
        public String PersonContactId {get;set;}
        public String alertMsg {get;set;}
        public Boolean isEmailVerified {get;set;}
        public Boolean isMobileVerified {get;set;}
        public List<String> lstMsg {get;set;}

        public OTPFields() {
            this.optStatus = '';
            this.Otp = '';
            this.resendOtp = 'false';
            this.LoginType = 'Lead';
            this.recordObject = 'Lead';
            this.OtpCode = '';
            this.otpSentTime = 0;
            this.mobileNo = null;
            this.EmailId = null;
            this.checkToAllowOTP = false;
            this.skipOTP = false;
            this.OtpMode = 'N';
            this.recordId = '';
            this.PersonContactId = '';
            this.alertMsg = '';
            this.isEmailVerified = false;
            this.isMobileVerified = false;
            this.lstMsg = new List<String>();
        }
    }

    // public Boolean IsCountryNotIndia(String ipAddress) {
    //     String jsonstring = '{"ip":"'+ipAddress +'"}';
    //     Boolean isCountrtIndia = true;
    //     HttpRequest req = new HttpRequest();
    //         HttpResponse resp = new HttpResponse();
    //         Http http = new Http();
    //         String Uri = 'https://studentzone-ngasce.nmims.edu:8090/salesforce/m/getIpDetails';
    //         // String Uri = System.Label.DOCUMENT_SERVER + 'm/getIpDetails';
    //         req.setEndpoint(Uri);
    //         req.setMethod('POST');
    //         req.setHeader('content-type', 'application/json');
    //         System.debug('jsonstring ==> ' + jsonstring);
    //         req.setBody(jsonstring);
    //         try {
    //             resp = http.send(req);
    //             Integer statusCode = resp.getStatusCode();
    //             System.debug('statusCode = '+statusCode);
    //             if(statusCode == 200) {
    //                 Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
    //                 if (responseBody.get('error') == 'false') {
    //                     String country = (String) responseBody.get('country');
    //                     if(!country.equalsIgnoreCase('India')) {
    //                         isCountrtIndia = false;
    //                     }  
    //                 } else {
    //                     API_Request__c apiReq = new API_Request__c();
    //                     apiReq.API_Name__c = 'MaxMind API';
    //                     apiReq.Request__c = jsonstring;
    //                     apiReq.Response__c = resp.getBody();
    //                     apiReq.Success__c = responseBody.get('error') == 'false' ? true : false;
    //                     lstAPIRequests.add(apiReq);
    //                 }
    //             } else {
    //                 API_Request__c apiReq = new API_Request__c();
    //                     apiReq.API_Name__c = 'MaxMind API';
    //                     apiReq.Request__c = jsonstring;
    //                     apiReq.Response__c = resp.getBody();
    //                     apiReq.Success__c = false;
    //                     lstAPIRequests.add(apiReq);
    //             }
    //         }catch (Exception e) {
    //             System.debug(e);
    //         }

    //         if(lstAPIRequests.size() > 0) {
    //             insert lstAPIRequests;
    //         }
    //         return isCountrtIndia;
    // }
}