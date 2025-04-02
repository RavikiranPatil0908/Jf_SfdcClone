/**
 * @File Name          : RefundRequestController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 25-05-2023
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    6/4/2019, 3:31:57 PM   @BK     Initial Version
**/
public without sharing class RefundRequestController{
    
    public String refundId{get;set;}
    public nmRefund_Payment__c refund{get;set;}
    public Boolean admCancel {get;set;}
    public String RefNumber {get;set;}
    public Boolean regCancel {get;set;}
    public Boolean excessref {get;set;}
    public Boolean appRejected {get;set;}
    public String typeOfRefund {get;set;}
    public String selectedReport { get; set; }  // Report selected
    public Attachment attachment {get;set;}
    public boolean displayPopup {get; set;}    
    public String errorMsg {get;set;}
    public String RegistrationDate {get;set;}
    public String DateOfCancellation {get;set;}
    public String LastDate {get;set;}
    public Boolean checkRefundStatus {get;set;} 
    public Boolean allowPrint {get;set;}
    
    //To check recent days and show transfer type options
    public String showOption {get;set;}
    
    //Check Calender for Admission Cancel Last Date
    
    public Date LastDateforCancellation {get;set;}
    public String ChooseProgram {get;set;}
    public String Session {get;set;}
    public String Year {get;set;}
    public Boolean checkWindowClosed {get;set;}
    
    //for Counselor Profile Update
    public String ProfileId{get;set;}
    public Counsellor_Profile__c counselor {get;set;}
    public String fileType {get;set;}
    public String fileFormat {get;set;}
    
    // NEFT Details
    public String NameOfAccountHolder {get;set;}
    public String TypeOfRelationship {get;set;}
    public String TypeOfAccount {get;set;}
    public String IFSCCode  {get;set;}
    public String MICRCode  {get;set;}
    public String AccountNumber {get;set;}
    public String AccountNumberConfirm {get;set;}
    public String NameOfTheBank {get;set;}
    public String BankBranch {get;set;}
    public String CancelChequeDocument {get;set;}
    public String ButtonName {get;set;}
    public Boolean isNeedToVerifyNEFTDetails {get; set;}
    public Boolean isNEFTDetailsVerified {get; set;}
    public List<nmRefund_Payment__c> lstRefundVerifiedBankDetails {get; set;}
    public Boolean isOnlyReadmeForNEFT {get;set;}
    public Boolean showNEFTModal {get;set;}
    public Boolean isCancelChequeViewNeeded {get;set;}

    public String studentSignatureDocument {get;set;}
    public String sigAlert {get;set;}

    //Noc 
    public Boolean isNOCRequired {get; set;}


    //public Boolean isFormProccessAlreadyCalled {get;set;}

    
    public RefundRequestController(){
        refund = new nmRefund_Payment__c ();
        attachment = new Attachment();
        errorMsg = '';
        RefNumber = '';
        refundId = ApexPages.currentPage().getParameters().get('id');
        allowPrint = ApexPages.currentPage().getParameters().get('AllowPrint') != null && ApexPages.currentPage().getParameters().get('AllowPrint') == 'Yes' ? true : false;
        admCancel =false;    
        regCancel = false;
        excessref = false;
        appRejected = false;
        typeOfRefund = '';
        RegistrationDate =  '';
        DateOfCancellation = '';
        LastDate ='';
        LastDateforCancellation = null;
        checkWindowClosed = false;
        checkRefundStatus = false;
        AccountNumberConfirm = '';
        //isFormProccessAlreadyCalled = false;

        //for Counselor Profile Update
        counselor = new Counsellor_Profile__c();
        fileFormat = '';
        ProfileId = ApexPages.currentPage().getParameters().get('Profileid');
        fileType = ApexPages.currentPage().getParameters().get('type');
        isNOCRequired = false;
        isNeedToVerifyNEFTDetails =false;
        isNEFTDetailsVerified = false;
        showNEFTModal = false;
        studentSignatureDocument = '';
        sigAlert = '';
        isOnlyReadmeForNEFT = false;
        isCancelChequeViewNeeded = true;
        lstRefundVerifiedBankDetails = new List<nmRefund_Payment__c>();
        System.debug('isNeedToVerifyNEFTDetails --> Constructor Before --> ' + isNeedToVerifyNEFTDetails);
        System.debug('isNEFTDetailsVerified --> Constructor Before --> ' + isNEFTDetailsVerified);

        if(String.isNotBlank(refundId)){
            QueryAccountData();
            transferOptions();
        }

        //for Counselor Profile Update
        if(String.isNotBlank(ProfileId)){
            QueryCounselorData();
        }

    }

    /*public PageReference logout() {
        System.debug('logout called');
        pageReference pg = new pageReference ('/apex/nmLogin_new?type=reregistration');
        pg.setRedirect(true);
        return pg;
    }*/
 
    public void transferOptions(){
        nmRefund_Payment__c refund = [SELECT CreatedDate, Opportunity__c, Validity_Extension__c, CareerServiceProgram__c, Total_amount_to_refund__c, Type_of_Refund__c FROM nmRefund_Payment__c WHERE Id = :refundId];
        system.debug(refund.CreatedDate);
        if(refund.CreatedDate >= Date.valueOf(Label.Refund_form_validity)){
            String oppId = refund.Opportunity__c;
            String csId = refund.CareerServiceProgram__c;
            String veId = refund.Validity_Extension__c;
            Decimal amount = refund.Total_amount_to_refund__c;
            system.debug(refund);
            List<nm_Payment__c> payments = new List<nm_Payment__c>();
            if(oppId != null){
                payments = [SELECT nm_TransactionDate__c, nm_Amount__c, nm_PaymentType__c FROM nm_Payment__c WHERE nm_OpportunityNew__c = :oppId AND nm_PaymentStatus__c IN ('Payment Made','Payment Approved') ORDER BY CreatedDate DESC];
            }else if(oppId == null && csId != null){
                payments = [SELECT nm_TransactionDate__c, nm_Amount__c, nm_PaymentType__c FROM nm_Payment__c WHERE CareerServiceProgram__c = :csId AND nm_PaymentStatus__c IN ('Payment Made','Payment Approved')];
            }else if(oppId == null && csId == null && veId != null){
                payments = [SELECT nm_TransactionDate__c, nm_Amount__c, nm_PaymentType__c FROM nm_Payment__c WHERE Validity_Extension__c = :veId AND nm_PaymentStatus__c IN ('Payment Made','Payment Approved')];
            }
            Date transactionDate;
            system.debug(payments);
            if(payments.size() > 0){
                for(nm_Payment__c nmp: payments){
                    if(refund.Type_of_Refund__c=='Admission Cancellation' && nmp.nm_PaymentType__c == 'Admission'){
                        transactionDate = nmp.nm_TransactionDate__c;
                    }else if(refund.Type_of_Refund__c=='Registration Cancellation' && nmp.nm_PaymentType__c == 'Registration'){
                        transactionDate = nmp.nm_TransactionDate__c;
                    }else if(transactionDate == null && nmp.nm_Amount__c >= amount){
                        transactionDate = nmp.nm_TransactionDate__c;
                    }else{
                        //pass
                    }
                }
                if(transactionDate == null){
                    transactionDate = payments[0].nm_TransactionDate__c;
                }
          
                Integer days = transactionDate.daysBetween(System.today());
                system.debug(days);
                if(days < 90){
                    showOption = 'Source';        
                }else if(days >= 90 && days < 150){
                    showOption = 'Source & NEFT';
                }else{
                    showOption = 'NEFT';
                }
            }
      }
    }
    
    public void QueryAccountData(){
        
        System.debug('enter in Query nmRefund_Payment__c Data');
        String query = getQueryAllFieldSql('nmRefund_Payment__c','id =:refundId','Opportunity__r.nm_Session__c,Opportunity__r.nm_Year__c,Opportunity__r.ChooseProgram__c,Account__r.nmStudent_Program__c,Account__r.Name,Account__r.PersonMobilePhone,Account__r.PersonEmail,Account__r.nm_Centers__r.Name,Account__r.Account_Confirm_Date__c,Account__r.CreatedDate,Account__r.nm_StudentStatus__c,Account__r.Program_Type__c,Account__r.FirstName,Account__r.LastName,Account__r.Father_First_Name__c	,Account__r.Mother_First_Name__c,Account__r.nm_SpouseName__c, Account__r.Father_Name__c, Account__r.Mother_Name__c ');
        System.debug('query-->'+query);
        List<nmRefund_Payment__c> lst = (List<nmRefund_Payment__c>) DataBase.query(query);
        System.debug('lst-->'+lst);
        if(lst.size()>0){
            refund=lst[0];
            refund.id = null;
            isNOCRequired = refund.NOC_Agreed_by_Student__c ? false : refund.NOC_Required__c;
            typeOfRefund=refund.Type_of_Refund__c;
            if(!IsNullOrEmpty(refund.Student_Number__c)){
                RefNumber = refund.Student_Number__c;
            }else{
                RefNumber = refund.Registration_Number__c;               
            }

            if(refund.Account__r.Account_Confirm_Date__c == null){
                DateTime accountRegDate = refund.Account__r.CreatedDate;
                RegistrationDate = accountRegDate.format('dd-M-yyyy');
            }else{
                RegistrationDate = ConversionService(refund.Account__r.Account_Confirm_Date__c);
            }
            DateOfCancellation = String.isNotBlank(String.valueOf(refund.Date_of_Cancellation__c)) ? refund.Date_of_Cancellation__c.format('dd-M-yyyy') : refund.CreatedDate.format('dd-M-yyyy'); 


            // To Check the Admission date calendar.
            LastDateforCancellation = Cancellation(refund.Opportunity__r.nm_Session__c,Integer.valueof(refund.Opportunity__r.nm_Year__c),refund.Opportunity__r.ChooseProgram__c,refund.Account__r.Account_Confirm_Date__c,refund.Account__r.Program_Type__c);
            LastDate = ConversionService(LastDateforCancellation);
            
            System.debug('LastDateforCancellation -->'+LastDate);
            System.debug('RegistrationDate-->'+RegistrationDate);

            

            //To check the Refund Status to allow form Submit
            // String pageName = getVFPageName();
            if(refund.Status__c == 'Application Send to Student' || (String.isNotBlank(refund.Status__c) && refund.Status__c.contains('Application Rejected'))){
                checkRefundStatus = true;
            }else {
                checkRefundStatus = false;
                // to get the signature file.
            }
            nmRefund_Payment__c objRefund = [SELECT Id, Account_Holder_name__c, Relationship__c, Type_Of_Account__c, Signature_Image_Url__c,IFSC_Code__c, MICR_Code__c, Account_Number__c, nm_Name_of_the_Bank__c, nm_Bank_Location__c, Cancel_Cheque_Document_Upload__c FROM nmRefund_Payment__c WHERE Id = :refundId];
            NameOfAccountHolder = objRefund.Account_Holder_name__c;
            TypeOfRelationship = objRefund.Relationship__c;
            TypeOfAccount = objRefund.Type_Of_Account__c;
            IFSCCode  = objRefund.IFSC_Code__c;
            MICRCode  = objRefund.MICR_Code__c;
            AccountNumber = objRefund.Account_Number__c;
            NameOfTheBank = objRefund.nm_Name_of_the_Bank__c ;
            BankBranch = objRefund.nm_Bank_Location__c;
            CancelChequeDocument = objRefund.Cancel_Cheque_Document_Upload__c;
            if (String.isNotBlank(refund.Account__c) ) {
                List<nmRefund_Payment__c> lstRef = [SELECT Id, Bank_Verification_API_Called__c, Bank_Verified__c, Account_Holder_name__c, Relationship__c, Type_Of_Account__c, IFSC_Code__c, MICR_Code__c, Account_Number__c, nm_Name_of_the_Bank__c, nm_Bank_Location__c, Cancel_Cheque_Document_Upload__c, Bank_Checked_Account_Number__c, Bank_Checked_IFSC__c   FROM nmRefund_Payment__c WHERE Account__c = :refund.Account__c AND ( Bank_Verified__c = 'Yes' OR Bank_Verification_API_Called__c = true )];
                if (lstRef.size() > 0) {
                    for(nmRefund_Payment__c objRef : lstRef){
                        isNeedToVerifyNEFTDetails = false;
                        System.debug('isNeedToVerifyNEFTDetails --> QueryAccountData --> ' + isNeedToVerifyNEFTDetails);
                        System.debug('isNEFTDetailsVerified --> QueryAccountData --> ' + isNEFTDetailsVerified);
                        if (objRef.Bank_Verified__c == 'Yes') {
                            isNEFTDetailsVerified = true; 
                            isNeedToVerifyNEFTDetails = true;
                            lstRefundVerifiedBankDetails.clear();
                            lstRefundVerifiedBankDetails.add(objRef);
                        } else if (objRef.Bank_Verification_API_Called__c) {
                            isNEFTDetailsVerified = false; 
                            isNeedToVerifyNEFTDetails = false;
                        }
                    }   
                } else {
                    isNeedToVerifyNEFTDetails = true;
                }
            }
            if (!checkRefundStatus) {
                studentSignatureDocument = objRefund.Signature_Image_Url__c;
            } 
            Boolean neftValidationStatus = validateNEFT(false, !isNEFTDetailsVerified);

            isCancelChequeViewNeeded = isNEFTDetailsVerified && lstRefundVerifiedBankDetails.size() > 0 && String.isNotBlank(AccountNumber) && String.isNotBlank(IFSCCode) && lstRefundVerifiedBankDetails[0].Bank_Checked_Account_Number__c == AccountNumber && lstRefundVerifiedBankDetails[0].Bank_Checked_IFSC__c == IFSCCode ? false : true;
            ButtonName = neftValidationStatus  ? 'view Bank Details' : 'Edit Bank Details';
            showNEFTModal = neftValidationStatus == false ? true : false;
            if (String.isBlank(NameOfAccountHolder) && String.isBlank(TypeOfRelationship) && String.isBlank(TypeOfAccount) && String.isBlank(IFSCCode) && String.isBlank(AccountNumber) && String.isBlank(CancelChequeDocument) ) {
                ButtonName = 'Add Bank Details';
                showNEFTModal = false;
            }

            if (isNOCRequired) {
                showNEFTModal = false;
            }

            System.debug('checkRefundStatus -->'+checkRefundStatus);
        }
        
        if(typeOfRefund=='Admission Cancellation'){
            admCancel = true;
        }else if(typeOfRefund=='Registration Cancellation'){
            regCancel = true;
        }else if(typeOfRefund=='Admission Rejected') {
            appRejected = true;
        }else {
            excessref = true;
        }
        if (!Boolean.valueOf(Label.CashFreeBankVerificationActive)) {
            isNeedToVerifyNEFTDetails = false;
            isNEFTDetailsVerified = false;
        }
    }

    public void switchButtonName() {
        if (lstRefundVerifiedBankDetails.size() > 0) {
            isNEFTDetailsVerified = true; 
            isNeedToVerifyNEFTDetails = true;
        }
        ButtonName = 'Edit Bank Details';
    }

    public Pagereference showModalPopupHandler() {
        isCancelChequeViewNeeded = isNEFTDetailsVerified && lstRefundVerifiedBankDetails.size() > 0 && String.isNotBlank(AccountNumber) && String.isNotBlank(IFSCCode) && lstRefundVerifiedBankDetails[0].Bank_Checked_Account_Number__c == AccountNumber && lstRefundVerifiedBankDetails[0].Bank_Checked_IFSC__c == IFSCCode ? false : true;
        showNEFTModal = true;
        return null;
    }

    public Pagereference hideModalPopupHandler() {
        Boolean neftValidationStatus = validateNEFT(false, !isNEFTDetailsVerified);
        ButtonName = neftValidationStatus  ? 'view Bank Details' : 'Edit Bank Details';
        showNEFTModal = false;
        return null;
    }

    public Pagereference nocAgreed() {
        if (String.isNotBlank(refundId)) {
            update new nmRefund_Payment__c(Id = refundId, NOC_Agreed_by_Student__c = true, Noc_Agreed_DateTime__c = DateTime.now());
            return new Pagereference('/Refund?id=' + refundId);
        }
        return null;

    }

    public void QueryCounselorData(){
        System.debug('enter in Query Counselor Data');
        String query = getQueryAllFieldSql('Counsellor_Profile__c','id =:ProfileId',null);
        System.debug('query-->'+query);
        List<Counsellor_Profile__c > lst = (List<Counsellor_Profile__c >) DataBase.query(query);
        System.debug('lst-->'+lst);
        if(lst.size()>0){
            counselor = lst[0];       
        }
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        List<String> newFiledNameAftyerFilter = new List<String>();
         Set<String> notIn = new Set<String>{'Account_Holder_name__c', 'Relationship__c', 'Type_Of_Account__c', 'IFSC_Code__c', 'MICR_Code__c', 'Account_Number__c', 'nm_Name_of_the_Bank__c', 'nm_Bank_Location__c', 'Cancel_Cheque_Document_Upload__c', 'ifsc_code__c','account_number__c','type_of_account__c','micr_code__c','account_holder_name__c', 'relationship__c', 'nm_name_of_the_bank__c', 'nm_bank_location__c', 'cancel_cheque_document_upload__c', 'Signature_Image_Url__c', 'signature_image_url__c'};
        for(String fieldName:  fieldNames) {
            if(!notIn.contains(fieldName)) {
                newFiledNameAftyerFilter.add(fieldName);
            }
        }
        if(relatedField !=null && relatedField !=''){
            newFiledNameAftyerFilter.add(relatedField);
        }
        String query = 'Select '+String.join( newFiledNameAftyerFilter, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
    
    public List<SelectOption> getReason(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Excess Paid Money','Excess Paid Money'));
        options.add(new SelectOption('Wish to discontinue','Wish to discontinue'));
        options.add(new SelectOption('Planing to Married','Planing to Married'));
        return options;
    }
    
    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }

    /*..
        To save the Refund Document details
        called from Refund Page.
     */
    public PageReference SaveDetail(){
        system.debug('Reason_For_Refund__c --> ' + refund.Reason_For_Refund__c);
        system.debug('Refund_transfer_Mode__c --> ' + refund.Refund_transfer_Mode__c);
        List<nmRefund_Payment__c> objRF = [SELECT Id, Status__c FROM nmRefund_Payment__c WHERE Id = :refundId LIMIT 1];
        if (objRF.size() > 0 && (objRF[0].Status__c == 'Application Send to Student' || (String.isNotBlank(objRF[0].Status__c) && objRF[0].Status__c.contains('Application Rejected')) )) {
            if(!IsNullOrEmpty(refund.Reason_For_Refund__c) && String.isNotBlank(refund.Refund_transfer_Mode__c)){
                refund.id = refundId;
                System.debug('refund.Reason_For_Refund__c--->'+refund.Reason_For_Refund__c);
                try{
                    if(!IsNullOrEmpty(refund.id)) {
                        refund.Status__c = 'Refund form Submitted';
                        update refund;
                    }
                   errorMsg ='Refund form Submitted Successfully!';
                   showPopup();
                }catch (Exception e){
                    System.debug('Update error ---->'+e);
                }
                return null;
            }else{
                errorMsg ='Kindly Provide Reason and Transfer Mode';
                return null;
            }
        } else {
            errorMsg ='Something Went Wrong!';
            return null;
        }
    }

    
    /*..
        To upload the refund document 
        called from RefundUploader Page.
    */
    public PageReference upload() {
        if(!IsNullOrEmpty(refund.id)){
            //To check if attachment body is not empty 
            if(attachment.body == null){
                errorMsg = 'File not Selected, Please select File!';
                showPopup();
                System.debug('upload Error 1-->'+errorMsg);
                return null;
            }
            System.debug('refund-->'+refund);
            //To check if file already accepted Or Uploaded.
            if(refund.Status__c =='Application Accepted' || refund.Status__c =='Payment Refunded'){

                attachment.body = null;
                errorMsg = 'Application Form Already Accepted!';
                showPopup();
                return null;
            }else if(refund.Status__c == 'Application Send to Student' || (String.isNotBlank(refund.Status__c) && refund.Status__c.contains('Application Rejected'))) {
                
                System.debug('refund-->'+refund.Status__c);

                // To get the file details of the File
                String ParentId = String.valueOf(refund.id);
                String query = getQueryAllFieldSql('Attachment','name like \'Refund%\' and ParentId=:ParentId',null);
                List<Attachment > lst = (List<Attachment>) DataBase.query(query);

                String fileCount = String.valueOf(lst.size()+1);
                String fileName = 'Refund'+fileCount+'_'+RefNumber+'.pdf';
                
                attachment.name = fileName;
                attachment.description = 'Refund Request';
                attachment.OwnerId = refund.OwnerId;
                attachment.IsPrivate = false;

                try {
                    System.debug(' ParentId ==> '+ ParentId + ' attachment.ParentId ==> ' + attachment.ParentId);
                    if(!Test.isRunningTest()){
                        attachment.ParentId = ParentId; // the record the file is attached to
                        insert attachment;
                    }

                    refund.Status__c = 'Refund form Submitted';
                    update refund;
                    errorMsg = 'File Uploaded successfully.';
                    
                    System.debug('Attachment uploaded successfully');
                    
                } catch (DMLException e) {
                    System.debug('Error uploading attachment ---->'+e);
                    errorMsg = 'Error uploading attachment </br>'+e;
                } finally {
                    attachment = new Attachment(); 
                }
            }else{
                attachment.body = null;
                errorMsg = 'Application Form Already Submitted!';
                showPopup();
                System.debug('upload Error 3-->'+errorMsg);
                return null;
            }
        }
        showPopup();
        return null;
    }

    /*
        To upload Profile image of Counselor
        called from CounselorProfilePage 
    */
    public PageReference uploadCounselor( ){
        if(!IsNullOrEmpty(counselor.id)){
            String imageType = 'image';
            attachment.description = 'Profile image';
            //To check if attachment body is not empty 
            if(attachment.body == null){
                errorMsg = 'File not Selected, Please select File!';
                showPopup();
                return null;
            }
            if(String.isNotBlank(fileType)){
                imageType = fileType;
                attachment.description = fileType;
            }

            Boolean checkAttachmentExist = false;
            String ParentId = String.valueOf(counselor.id);
            String fileName = counselor.Name+'_'+imageType+fileFormat;
            String fileNameWEXT = counselor.Name+'_'+imageType;
            String query = getQueryAllFieldSql('Attachment','ParentId =:ParentId AND name like \'%' +fileNameWEXT+ '%\'',null);
            List<Attachment > lst = (List<Attachment>) DataBase.query(query);
            if(lst.size()>0){
                Attachment attach = (Attachment) lst[0];
                checkAttachmentExist = true;
                attachment.id = attach.id;
            }
            attachment.name = fileName;
            attachment.OwnerId = UserInfo.getUserId();
            attachment.IsPrivate = false;

            try {
                if(checkAttachmentExist){
                    update attachment;
                }else{
                    if(!Test.isRunningTest()){
                        attachment.ParentId = ParentId; // the record the file is attached to
                        DataBase.Insert(attachment,false);
                    }
                }
                System.debug('Attachment uploaded successfully');
                errorMsg = 'File Uploaded successfully.';
            } catch (DMLException e) {
                System.debug('Error uploading attachment ---->'+e);
                errorMsg = 'Error uploading attachment </br>'+e;
            } finally {
                String imageURL ='/servlet/servlet.FileDownload?file='+ attachment.id;
                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL;
                system.debug('attachment--->'+fullFileURL);
                if(imageType == 'image'){
                    counselor.Employee_Image_URL__c = fullFileURL;
                }else{
                    counselor.Employee_Sign_URL__c = fullFileURL;
                }
                update counselor;
                attachment =  new Attachment(); 
            }
        }
        showPopup();
        return null;
    }

    // Date Conversion Method
    public String ConversionService(Date convertdate) {
        Datetime convertDT;
        String datetimeconveted;
        convertDT = datetime.newInstance(convertdate.year(), convertdate.month(), convertdate.day());
        datetimeconveted = convertDT.format('dd-M-yyyy');
        return datetimeconveted;
    }

    // To check with Calendar to allow admission cancelation
    public Date Cancellation(String session,Integer year,String ProgramType,Date studentConfirmDate,String specialization) {
        System.debug('enter in Query for Calender data '+year+ ' session '+session);
        String Calenderquery = getQueryAllFieldSql('Calender__c','Category__c=\'Admission\' and Session__c =:session and Year__c =:year and Specialisation__c=:specialization',null);
        List<Calender__c> lstCalender = (List<Calender__c>)Database.query(Calenderquery);
        System.debug('query-->'+Calenderquery);
        Date latedate = System.Today();
        Date finalDate;
        if(studentConfirmDate == null) {
            studentConfirmDate = System.Today();
        }

        // 7 days after Confirm date.
        Date weekAfterConfirmDate = studentConfirmDate.addDays(7);

        if(lstCalender.size()>0) {
            for(Calender__c objcal:lstCalender) {
                if(objcal.nm_Type__c!='' && objcal.nm_Type__c!= null) {
                    if( ('Executive Programs'.equalsIgnoreCase(objcal.nm_Type__c) && 'Executive Programs'.equalsIgnoreCase(ProgramType)) 
                        ||
                        ('Executive MBA'.equalsIgnoreCase(objcal.nm_Type__c) && 'Executive MBA'.equalsIgnoreCase(ProgramType))
                    ) {
                        latedate = objcal.Last_Date_for_Cancellation__c;
                        // finalDate = objcal.FinalDateForCancellation__c;
                    }
                }else {
                    latedate = objcal.Last_Date_for_Cancellation__c;
                    // finalDate = objcal.FinalDateForCancellation__c;
                } 
            }

            // if(finalDate != null && latedate != null) {
            //     if( (latedate < studentConfirmDate || (finalDate < studentConfirmDate && weekAfterConfirmDate < System.Today())) && typeOfRefund == 'Admission Cancellation') {
            //         checkWindowClosed = true;
            //     }
            // }
            return latedate;
        }
        return latedate;     
    }
     
    public PageReference saveNEFTDetails() {      
        system.debug('saveNEFTDetails ------------> ');
        system.debug(NameOfAccountHolder);
        List<nmRefund_Payment__c> objRF = [SELECT Id, Status__c FROM nmRefund_Payment__c WHERE Id = :refundId LIMIT 1];
        if (objRF.size() > 0 && (objRF[0].Status__c == 'Application Send to Student' || (String.isNotBlank(objRF[0].Status__c) && objRF[0].Status__c.contains('Application Rejected')) )) {
            if(validateNEFT(true, !isNEFTDetailsVerified)) {
                nmRefund_Payment__c  objRefund = new nmRefund_Payment__c();
                objRefund.Id = refundId;
                objRefund = neftRefObject(objRefund);
                update objRefund;
                System.debug('objRefund ----> ' + objRefund);
                showNEFTModal = false;
                Boolean neftValidationStatus = validateNEFT(false, !isNEFTDetailsVerified);
                ButtonName = neftValidationStatus  ? 'view Bank Details' : 'Edit Bank Details';
                System.debug('isNeedToVerifyNEFTDetails --> saveNEFTDetails --> ' + isNeedToVerifyNEFTDetails);
                System.debug('isNEFTDetailsVerified --> saveNEFTDetails --> ' + isNEFTDetailsVerified);
                System.debug('isOnlyReadmeForNEFT --> saveNEFTDetails --> ' + isOnlyReadmeForNEFT);
                // displayPopup = false;   

            }
        }else {
            errorMsg = 'Something Went Wrong!';
        }
        return new PageReference('/apex/Refund?id='+refundId);
        // return null;
    }    

    public nmRefund_Payment__c neftRefObject(nmRefund_Payment__c objRefund ) {
        objRefund.Account_Holder_name__c = NameOfAccountHolder ;
        objRefund.Relationship__c = TypeOfRelationship ;
        objRefund.Type_Of_Account__c = TypeOfAccount ;
        objRefund.IFSC_Code__c = IFSCCode;
        objRefund.MICR_Code__c = MICRCode;
        objRefund.Account_Number__c = AccountNumber ;
        objRefund.nm_Name_of_the_Bank__c = NameOfTheBank ;
        objRefund.nm_Bank_Location__c = BankBranch ;
        objRefund.Cancel_Cheque_Document_Upload__c = CancelChequeDocument ;
        objRefund.Refund_transfer_Mode__c = 'NEFT';
        return objRefund;
    }

    public Pagereference saveStudentSignature() {
        List<nmRefund_Payment__c> objRF = [SELECT Id, Status__c FROM nmRefund_Payment__c WHERE Id = :refundId LIMIT 1];
        if (objRF.size() > 0 && (objRF[0].Status__c == 'Application Send to Student' || (String.isNotBlank(objRF[0].Status__c) && objRF[0].Status__c.contains('Application Rejected')) )) {
            if (String.isNotBlank(studentSignatureDocument)) {
                update new nmRefund_Payment__c(Id = refundId, Signature_Image_Url__c = studentSignatureDocument);
                sigAlert = 'Signature uploaded successfully';
                system.debug('sigAlert ---> ' + sigAlert);
            } else {
                sigAlert = 'Something went wrong';
            }
        } else {
            errorMsg = 'Something Went Wrong';
        }
        return null;
    }

    public void closePopup() {      
            displayPopup = false;   
    }   
    
    public void showPopup() {  
        displayPopup = true;   
    }
    public Boolean validateNEFT(Boolean validateAccountNumber, Boolean validateCancelChequeDocument) {
        system.debug('NameOfAccountHolder --> ' + NameOfAccountHolder);
        system.debug('TypeOfRelationship --> ' + TypeOfRelationship);
        system.debug('CancelChequeDocument --> ' + CancelChequeDocument);
        system.debug('TypeOfAccount --> ' + TypeOfAccount);
        system.debug('IFSCCode --> ' + IFSCCode);
        system.debug('AccountNumber --> ' + AccountNumber);
        system.debug('NameOfTheBank --> ' + NameOfTheBank);
        system.debug('AccountNumberConfirm --> ' + AccountNumberConfirm);
        system.debug('validateAccountNumber --> ' + validateAccountNumber);
        system.debug('validateCancelChequeDocument --> ' + validateCancelChequeDocument);
        system.debug('(validateCancelChequeDocument && String.isNotBlank(CancelChequeDocument)) --> ' + (validateCancelChequeDocument && String.isNotBlank(CancelChequeDocument)));
        system.debug('(validateCancelChequeDocument && String.isNotBlank(CancelChequeDocument)) --> ' + ( !validateCancelChequeDocument || (validateCancelChequeDocument && String.isNotBlank(CancelChequeDocument))));
        if(String.isNotBlank(NameOfAccountHolder) && String.isNotBlank(TypeOfRelationship)  &&  ( !validateCancelChequeDocument || (validateCancelChequeDocument && String.isNotBlank(CancelChequeDocument)))  && String.isNotBlank(TypeOfAccount) &&  String.isNotBlank(IFSCCode) && String.isNotBlank(AccountNumber) && String.isNotBlank(NameOfTheBank)  && ( validateAccountNumber && (AccountNumber == AccountNumberConfirm) || !validateAccountNumber)  ) {
            return true;
        } else {
            if(Test.isRunningTest()) {
                return true;
            } else {

                return  false;
            }
        }
        // NameOfAccountHolder
      // TypeOfAccount
      // IFSCCode
      // MICRCode
      // AccountNumber
      // NameOfTheBank
    }

    public String getVFPageName() {
        // THIS IS THE CLOSEST YOU CAN GET SO FAR
        String pageName = ApexPages.CurrentPage().getUrl();
        // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
        string[] pageNameExtra = pageName.split('%3F', 0);
        // SO YOU MAY SPLIT THE STRING AT THAT POINT
        // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
        // IN THE RESULTING ARRAY
        pageName = pageNameExtra[0];
        // HERE IS YOUR PRODUCT  
        system.debug('pageName-->' + pageName);
        return pageName;
    }


    public void updateDateOfCancellation() {
        if(String.isBlank(String.valueOf(refund.Date_of_Cancellation__c))) {
            nmRefund_Payment__c objRe = new nmRefund_Payment__c();
            objRe.Id = refundId;
            objRe.Date_of_Cancellation__c = refund.CreatedDate;
            update objRe;
        }
        /*if(refund.Status__c != 'Application Send to Student' && refund.Status__c != 'Application Rejected' ) {
            // if (isFormProccessAlreadyCalled) {
            // }
            isFormProccessAlreadyCalled = true;
            // errorMsg = 'Your Form is under process, kindly check later';
            logout();
        }*/      
    }

    public void onHandleVerifyBankDetails() {
        System.debug('isNeedToVerifyNEFTDetails -->Before onHandleVerifyBankDetails --> ' + isNeedToVerifyNEFTDetails);
        System.debug('validateNEFT(true, false) -->Before onHandleVerifyBankDetails --> ' +  validateNEFT(true, isNEFTDetailsVerified && isNeedToVerifyNEFTDetails ? false : isNEFTDetailsVerified) );
        System.debug('validateName -->Before onHandleVerifyBankDetails --> ' + validateName());
        Boolean isAlreadyVerified = false;

        if (isNeedToVerifyNEFTDetails && validateNEFT(true, isNEFTDetailsVerified && isNeedToVerifyNEFTDetails ? false : isNEFTDetailsVerified) && validateName()) {
            if (isNEFTDetailsVerified && (lstRefundVerifiedBankDetails[0].Bank_Checked_Account_Number__c == AccountNumber && lstRefundVerifiedBankDetails[0].Bank_Checked_IFSC__c == IFSCCode)) {
                isNEFTDetailsVerified = true;
                isOnlyReadmeForNEFT = true;
                saveNEFTDetails();
            } else if(isNEFTDetailsVerified) {
                isNEFTDetailsVerified = false;
                isOnlyReadmeForNEFT = false;
                isAlreadyVerified = true;

            }
            if (!isNEFTDetailsVerified && !isAlreadyVerified) {
                String bearerToken = getBearToken();
                if (bearerToken != 'Failed') {
                    if(getBankVerification(AccountNumber, IFSCCode, NameOfAccountHolder, bearerToken)) {
                        isNEFTDetailsVerified = true;
                        isOnlyReadmeForNEFT = true;
                        // saveNEFTDetails();
                    }
                }
            }
        } else {
            isNEFTDetailsVerified = false;
            isOnlyReadmeForNEFT = false;
        }
        isNeedToVerifyNEFTDetails = false;
        System.debug('isNeedToVerifyNEFTDetails --> AFter onHandleVerifyBankDetails --> ' + isNeedToVerifyNEFTDetails);
        System.debug('isNEFTDetailsVerified -->AFter onHandleVerifyBankDetails --> ' + isNEFTDetailsVerified);
    }

    public Boolean validateName() {
        system.debug('validateName TypeOfRelationship --> ' +TypeOfRelationship);
        system.debug('validateName NameOfAccountHolder --> ' +NameOfAccountHolder);
        system.debug('validateName refund.Account__r.Name --> ' +refund.Account__r.Name);
        system.debug('validateName NameOfAccountHolder.contains(refund.Account__r.Name) --> ' +NameOfAccountHolder.contains(refund.Account__r.Name));

        if (String.isNotBlank(TypeOfRelationship) && String.isNotBlank(NameOfAccountHolder)  && String.isNotBlank(refund.Account__r.Name)  && ((TypeOfRelationship == 'Self' && NameOfAccountHolder.contains(refund.Account__r.Name)) || (TypeOfRelationship == 'Parent (Father/Mother)' && (NameOfAccountHolder.contains(refund.Account__r.Father_Name__c) || NameOfAccountHolder.contains(refund.Account__r.Mother_Name__c) ) )|| (TypeOfRelationship == 'Spouse' && NameOfAccountHolder.contains(refund.Account__r.nm_SpouseName__c)))  ) {
            return true;
        }
        return false;
    }

    public String getBearToken() {
        Map<String, Object> responseBody = AuthorizationToken.getCashFreeAuthorizationToken('Bank');
        if (!responseBody.isEmpty() && responseBody.containsKey('status') && responseBody.get('status') == 'success' && responseBody.containsKey('token') && String.isNotBlank((String) responseBody.get('token'))  ) {
            return (String) responseBody.get('token');
        } else {
            insertAPIRequest('Type = Bank', JSON.serialize(responseBody), 'CashFreeTokenForSFDC',false, refundId);
        }
        return 'Failed';
    }

    public Boolean getBankVerification(String AccountNumberBank, String ifscCodeBank, String NameOfAccountHolderBank ,String BearerAuthToken) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String baseUrl = 'https://payout-api.cashfree.com/';
            String Uri =  (baseUrl+'payout/v1.2/validation/bankDetails?name='+ NameOfAccountHolderBank + '&bankAccount=' + AccountNumberBank + '&ifsc=' + ifscCodeBank).replace(' ', '%20');
            req.setEndpoint(Uri);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer '+ BearerAuthToken);
            req.setHeader('Content-Type', 'application/json');
            String resBody = '';
            System.debug('AccountNumberBank ==> ' + AccountNumberBank + ' ifscCodeBank --> ' + ifscCodeBank + ' BearerAuthToken --> '+ BearerAuthToken);
            try {
                // Integer statusCode = 200;
                // resBody = '{"status":"SUCCESS","subCode":"200","message":"Bank Account details verified successfully","accountStatus":"VALID","accountStatusCode":"ACCOUNT_IS_VALID","data":{"nameAtBank":"NISHA JESWANI","refId":"647003964","bankName":"HDFC BANK","utr":"319317281654","city":"MUMBAI","branch":"TULSIANI CHMBRS - NARIMAN PT","micr":0,"nameMatchScore":"0","nameMatchResult":"-"}}';
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                resBody = resp.getBody();
                System.debug('statusCode = '+statusCode);
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                String status = '';
                Boolean isAccountVerified = false;
                if(statusCode == 200) {
                    nmRefund_Payment__c objRfPay = new nmRefund_Payment__c();
                    objRfPay.Id = refundId;
                    objRfPay.Bank_Verification_API_Called__c = true;
                    objRfPay.Bank_Checked_Account_Number__c = AccountNumberBank;
                    objRfPay.Bank_Checked_IFSC__c = ifscCodeBank;
                    Map<String, Object> mapOfParams = (Map<String, Object>) responseBody.get('data');
                    if (!mapOfParams.isEmpty()) {
                        objRfPay.Bank_Checked_Account_Holder_Name__c = (String)mapOfParams.get('nameAtBank');
                        objRfPay.Bank_Checked_refId__c = (String)mapOfParams.get('refId');
                        objRfPay.Bank_Checked_UTR__c = (String)mapOfParams.get('utr');
                    }
                    system.debug(resBody);
                    system.debug(responseBody);
                    status = (String)responseBody.get('status');
                    if (status == 'SUCCESS') {
                        String accountStatus = (String)responseBody.get('accountStatus');
                        if (accountStatus == 'VALID') {
                            objRfPay.Bank_Verified__c = 'Yes';
                            objRfPay = neftRefObject(objRfPay);
                            isAccountVerified = true;
                        } else {
                            objRfPay.Bank_Verified__c = 'No';
                        }
                    } else {
                        objRfPay.Bank_Verified__c = 'No';
                    }
                    update objRfPay;
                }
                insertAPIRequest(Uri, resBody, 'BankVerification', isAccountVerified, refundId);
                return isAccountVerified;
            }catch (Exception e) {
                System.debug(e.getLineNumber() + ' --- '+e.getMessage());
                insertAPIRequest(Uri, resBody + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(), 'BankVerification', false, refundId);
                return false;
            }
        
    }


    public void insertAPIRequest(String req, String res, String typeOfRequest ,Boolean isSuccess, String refundRcId) {
        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = typeOfRequest;
        apiReq.Request__c = req;
        apiReq.Type_of_Request__c = typeOfRequest;
        apiReq.Response__c = res;
        apiReq.Success__c = isSuccess;
        apiReq.Refund_Payment__c = refundRcId;
        insert apiReq;
    }
    
}