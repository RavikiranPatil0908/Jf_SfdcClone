/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2024
 * @last modified by  : @BK
**/
public class nmPrintAdmissionForm 
{
    public Account objAccount {get;set;}
    
    public Boolean showpage { get; set; }
    public Boolean showEmailContent { get; set; }
    public String PDFPlace { get; set; }
    public String PDFDate { get; set; }
    public Id AccountId { get; set; }
    public String BatchName { get; set; }
    public list<Opportunity> objOpp{get;set;}
    public List<String> lstCities {get;set;}
    
    //For OTP Verification Login
    public String gupshupStatus { get;set; }
    public String optStatus {get;set;}
    public String Otp {get;set;}
    public String OtpValue {get;set;}
    public String resendOtp {get;set;}
    public String OtpCode {get;set;}
    public Long otpSentTime {get;set;}

    public String emailText {get; set;}
    public String mobileText {get; set;}

   

    public Boolean IsStudentNumber { get; set; }
    public Boolean showWelcomeMailer { get; set; }

    // For Payment after ClosedWon
    public String paymentUrl {get;set;}
    list<Calender__c> lstCalReReg { get; set; }
    list<Calender__c> lstCalAdd { get; set; }

    public nmPrintAdmissionForm()
    {
        objAccount = new Account();
        lstCities = new List<String>();
        objOpp = new list<Opportunity>(); 
        showpage = false;
        showEmailContent = false;
        PDFPlace = '';
        PDFDate = '';
        AccountId = Null;
        BatchName = '';


        gupshupStatus = '';
        optStatus = '';
        Otp = '';
        OtpValue = '';
        resendOtp = 'false';
        OtpCode = '';
        otpSentTime = 0;
        IsStudentNumber = false;
        paymentUrl = null;
        lstCalReReg = new List<Calender__c>();
        lstCalAdd = new List<Calender__c>();
        
        
        if(ApexPages.currentPage().getParameters().get('id') != Null && ApexPages.currentPage().getParameters().get('id') != '')
        {
            AccountId = ApexPages.currentPage().getParameters().get('id');
            
            List<Account> lstAcc = [SELECT Id,nm_StudentStatus__c,nm_ProgramType__c,nm_StudentNo__c,nm_NewPassword__c,Valid_Upto__c, nm_Batch_Name2__c,Synced_With_LDAP__c,nm_LeadId__c,
                                    PersonMobilePhone,Name,nmStudent_Program__c,Provisional_With_Hold__c,Eligibility_Criteria_Ref__c,PersonEmail,Program_Name__c,nm_ChooseaProgram__c,Program_Type__c,
                                    (
                                        SELECT id, nm_FeesPaidofSemester__c,nm_Program__r.nm_TotalSemesters__c,nm_Program__r.nm_Type__c,nm_Program__r.Specialisation__c
                                        FROM Student_Program__r LIMIT 1
                                    ) FROM Account WHERE id =: AccountId];
            objOpp=[SELECT Id,nm_Session__c,nm_Year__c,nm_Semester__c,StageName,Is_Re_Registration_Payment__c,nm_Fee_Type__c,Sem__c FROM Opportunity WHERE AccountId=:lstAcc[0].id AND (nm_Semester__c='1' OR nm_Semester__c='2' OR nm_Semester__c='3') ORDER BY nm_Semester__c ASC];
            objAccount =lstAcc[0];
            showWelcomeMailer = true;
            IsStudentNumber = String.isNotBlank(lstAcc[0].nm_StudentNo__c) && lstAcc[0].Synced_With_LDAP__c && lstAcc[0].Program_Name__c != 'MBA (Executive) with specialisation in Business Analytics' ? true : false;

            string currentSem = string.valueOf(Integer.valueOf(objOpp[0].nm_Semester__c) + 1);
            String programType = objAccount.nm_ChooseaProgram__c;
            String programSpecialization = objAccount.Program_Type__c;
            Integer yr = Integer.valueOf(objOpp[0].nm_Year__c);
          
            
            if(programSpecialization !=null && programSpecialization !='')
            {
                lstCalReReg = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                        where Category__c='Re-Registration' and nm_Type__c=:programType 
                                        and Specialisation__c=:programSpecialization 
                                                    and nm_Semester__c =: currentSem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
                lstCalAdd = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                        where Category__c='Admission' and nm_Type__c=:programType 
                                        and Specialisation__c=:programSpecialization 
                                                 and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() AND Session__c = :objOpp[0].nm_Session__c AND  Year__c = :yr ];
                    
            }else{
                lstCalReReg = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                                    where Category__c='Re-Registration' and nm_Type__c=:programType and nm_Semester__c =: currentSem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
                lstCalAdd = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
                                                    where Category__c='Admission' and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() AND Session__c = :objOpp[0].nm_Session__c AND  Year__c = :yr];
                    
   
            }
            System.debug('lstCalReReg --> ' + lstCalReReg);
            System.debug('lstCalAdd --> ' + lstCalAdd);
            
            if(objAccount.nm_Batch_Name2__c == 'Awaiting')
            {
                BatchName = objOpp[0].nm_Session__c + objOpp[0].nm_Year__c ;
            }
            else
            {
               BatchName =objAccount.nm_Batch_Name2__c;
            }
            
            List<nm_Centers__c> lstCenters = [select Id, nm_City__c from nm_Centers__c where Nm_Active__c = true];
            
            if(lstCenters != Null && lstCenters.size() > 0)
            {
                Set<String> setCities = new Set<String>();
                
                for(nm_Centers__c obj : lstCenters)
                {
                    setCities.add(obj.nm_City__c);    
                }
                
                if(setCities.size() > 0)
                {
                    for(String objstr : setCities)
                    {    
                        lstCities.add(objstr);
                    }
                    lstCities.sort();
                }
            }
            // to check if any pending amount and allow to pay even after closed won.
            getPendingAmount();
        }
    }

    public void PrintForm()
    {
        showpage = true ;
    }  
    public void  sendOTP() {
        optStatus = 'OTP Sent';
        system.debug('gupshupStatus-->'+ optStatus);
        String mobileNo = objAccount.PersonMobilePhone  ;   
        if (!Test.isRunningTest()) {
            String result = SMSSenderWebService.sendmGageSMS(mobileNo.left(10),generateOTPMSG());
    }
        optStatus = 'OTP Sent';
        mobileText = 'OTP has been send to XXXXXXX' + mobileNo.right(3);
        System.debug('gupshupStatus-->'+optStatus);
    }

    public void VerifyOTP() {
        String mobileNo = objAccount.PersonMobilePhone  ;

        OtpValue = Otp;
        system.debug('Otp ---> ' + Otp);
        system.debug('OtpValue ---> ' + OtpValue);
        if(String.isNotBlank(Otp)) {
            Long otpEnteredTime = DateTime.now().getTime();
            otpSentTime = DateTime.now().getTime();
            Long milliseconds = otpEnteredTime - otpSentTime;
            Long seconds = milliseconds / 1000;
            system.debug('seconds ---> ' + seconds);
            if(OtpCode == Otp && seconds <= 90){
            // if('1111' == String.valueOf(Otp)  && seconds <= 90){
                optStatus = 'OTP Verified';
                showWelcomeMailer = true;
                system.debug('showWelcomeMailer --> ' + showWelcomeMailer);
                system.debug('optStatus ---> ' + optStatus);
            }else if(OtpCode != Otp) {
                optStatus = '903';
            }else if(seconds > 90){
                optStatus = '907';
            }else{
                optStatus = '906';
            }
        }
    }

    public String generateOTPMSG() {
        Integer STRING_LENGTH = 5;
        Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
        OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        System.debug('OtpCode-->'+OtpCode);
        String smsMessage = OtpCode +' is your verification code for NMIMS CDOE.';
        // String smsMessage = OtpCode +' is your verification code for login to your NGASCE form.';
        otpSentTime = DateTime.now().getTime();
        return smsMessage;
    }

    public void sendEmail()
    {
        optStatus = 'Email Send';
        
        DateTime dt = Datetime.now();
        String datTime = dt.format('MMM dd, yyyy') + ' at ' + dt.format('hh:mm a');
        emailText = 'The Welcome Mailer has been sent to ' + objAccount.PersonEmail +' on ' + datTime +' , you can also view the Welcome Letter below,';
        showEmailContent = true;
        Account accountObj = new Account();
        accountObj.Id = AccountId;
        accountObj.Synced_With_LDAP__c = false;
        update accountObj;
        
        Account objAccount1 = new Account();
        objAccount1.Id = AccountId;
        objAccount1.Synced_With_LDAP__c = true; 
        update objAccount1;
    }

    public void showEmailContentToFalse() {
        showEmailContent = false;
        system.debug('showEmailContent ---> ' + showEmailContent);
    }

    /**
    * @description 
    * @author @BK | 10-17-2022 
    **/
    public void getPendingAmount() {
        List<String> lstPGProgram = new List<String>{'Certificate Programs','Diploma Programs','MBA (Distance) Programs','MBA (Online) Programs'};
        if((lstPGProgram.contains(objAccount.nm_ChooseaProgram__c) || (objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c == 'MBA')) 
        && String.isNotBlank(objAccount.nm_StudentNo__c) && lstCalAdd.size() > 0 && lstCalReReg.size() == 0) {
            Map<String,Decimal> feeTypeVsSem = new Map<String,Decimal>{'admission'=>1,'AnnualFee'=>2,'3SemFee'=>3,'MultipleSemFee'=>3};
            Decimal totalSem = objAccount.Student_Program__r[0].nm_Program__r.nm_TotalSemesters__c;
            Opportunity mostRecentClosedPaidOpportunity = new Opportunity();
            for (Opportunity opp : objOpp) {
                if(String.isNotBlank(opp.StageName) && (opp.StageName == 'Payment made' || opp.StageName == 'Closed Won')){ 
                    mostRecentClosedPaidOpportunity = opp;
                }
            }
            if(!mostRecentClosedPaidOpportunity.Is_Re_Registration_Payment__c && feeTypeVsSem.containsKey(mostRecentClosedPaidOpportunity.nm_Fee_Type__c)
            && feeTypeVsSem.get(mostRecentClosedPaidOpportunity.nm_Fee_Type__c) < totalSem) {
                paymentUrl = System.Label.GoToAdmissionPayment_Url.replace('/apex/','')+'id='+ objAccount.nm_LeadId__c + '&oppId=' + mostRecentClosedPaidOpportunity.id+'&sem='+mostRecentClosedPaidOpportunity.Sem__c+'&pp=true';
            }
            
        }
    }

    // public Boolean validateCalendar(Account objAccount,Opportunity mostRecentClosedPaidOpportunity) {
    //     if(objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0) {
    //         String Sem = String.valueOf(Integer.valueOf((Integer)(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c) +1));
    //         String feesPaidSem = String.valueOf(objAccount.Student_Program__r[0].nm_FeesPaidofSemester__c);
    //         String programType = objAccount.Student_Program__r[0].nm_Program__r.nm_Type__c;
    //         String programSpecialization = objAccount.Student_Program__r[0].nm_Program__r.Specialisation__c;
    //         list<Calender__c> lstCal = new list<Calender__c>();
            
    //         if(programSpecialization !=null && programSpecialization !='') {
    //             lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
    //                                 where Category__c='Re-Registration' and nm_Type__c=:programType 
    //                                 and Specialisation__c=:programSpecialization 
    //                                 and nm_Semester__c =: Sem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
        
    //         } else {
    //             lstCal = [select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c, nm_Type__c ,Session__c, Year__c from Calender__c
    //                                     where Category__c='Re-Registration' and nm_Type__c=:programType and nm_Semester__c =: Sem and Session_Start_Date__c <=:date.today() AND Session_End_Date__c >=:date.today() ];
    //         }
            
    //         Calender__c objCalender = new Calender__c();
    //         String calendarSession = null;
    //         Integer calendarSessionYear = 0;
        
    //         if(lstCal.size() > 0) {
    //             objCalender = lstCal[0];
    //             calendarSession = objCalender.Session__c;
    //             calendarSessionYear =Integer.valueOf(objCalender.Year__c);
    //             String closedWonSession = mostRecentClosedPaidOpportunity.nm_Session__c;
    //             String closedWonYear = Integer.valueOf(mostRecentClosedPaidOpportunity.nm_Year__c);
    //         }
    //     }
    //     return false;
    // }
     
}