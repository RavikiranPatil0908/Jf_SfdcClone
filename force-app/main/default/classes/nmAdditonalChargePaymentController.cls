/**
 * @File Name          : nmAdditonalChargePaymentController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 28-06-2024
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    7/10/2019   @BK     Initial Version
**/
public without sharing class nmAdditonalChargePaymentController{
    
    public String recordId {get;set;}
    public boolean IsICForMakingPayment {get;set;} // to distinguish between student and IC (for Showing DD Option for making Payment) 
    public String paymentGatewayName {get;set;}
    public nm_Payment__c objPayment{get;set;}
    public Map<String,String> mapOfActiveCalender {get;set;} // map Of Active Calendar
    public String centerAddressForDD {get;set;}
    public boolean paymentWindowClosed {get;set;}
    public String paymentClouserMessage {get;set;}
    public date LateFeeStartDate {get;set;}
    public decimal AlreadyPaidLateFeeAmount {get;set;}
    public boolean AlreadyPaidLateFee {get;set;}
    public decimal applicableLateFee {get;set;}
    public Map<String,Decimal> mapOfProductAndAmount {get;set;}
    public boolean IsReregistartion {get;set;}
    public String opportunityId {get;set;}
    public set<String> setOfAEPLicense {get;set;}
    public String paymentFor {get;set;}
    public NM_Payment_Form_Configuration__c objPaymentFormConfiguration {get;set;}
    public nm_Centers__c objtCenter {get;set;}
    public AEP_site_inspection__c aepisp {get;set;}
    public date Today {get;set;}
    public String programType {get;set;}
    public String programCategory {get;set;}
    public String semester {get;set;}
    public String centerId {get;set;}
    public String webinarRegid {get;set;}
    public String programId {get;set;}
    public String AEPId {get;set;}
    public String AEPISPId {get;set;}
    public String currentAdmissionSession {get;set;}
    public decimal currentAdmissionYear {get;set;}
    public String TagPriceBookId {get;set;}
    public boolean IsLateral {get;set;}
    public String postPaymentPage {get;set;}
    public String validityExtensionId {get;set;}
    public String CareerServiceRecordId {get;set;}
    public Map<String,nm_Program__c> mapOfProgramNameVsProgram {get;set;}
    public Map<Integer,String> licenseapplicable {get;set;}
    public String programSpecialization  {get;set;}
    public String displayName {get;set;}// kept for Registration No or Student No to show on Page 
    public ProductHelper productHelper {get;set;}
    public string careerServicePackageName {get;set;} 
    public Integer licensesFee {get;set;}
    public String Cpjson  {get;set;}
    public String liveLecType {get;set;}
    public String courseList{get;set;}
    public Map<String,Decimal> mapOfAEPMerchandiseAndPrice {get;set;}
    public Boolean isCourseraOpted {get;set;}
    public Boolean IsDefence {get;set;}


    //-----------------Error Message Parameter ----//
    public string errMessages { get; set; }
    public string strSecToShow { get; set; }
    
    // --------------Student Details For Payment ----//
    public String studentNo {get;set;}
    public String studentName {get;set;}
    public String studentInfo{get;set;}
    public String studentEmail {get;set;}
    public String studentMobileNo {get;set;}
    public String studentAddress {get;set;}
    public String studentCity {get;set;}
    public String studentPincode {get;set;}
    public String aepCenId {get;set;}
    public Decimal TotalAEPMerchPrice {get;set;}
    public Boolean isOpportunityProcessed {get;set;}
    
    public nmAdditonalChargePaymentController(){
        recordId = '';
        Today = Date.today();
        programType = '';
        programCategory = '';
        semester = '';
        IsReregistartion = false;
        IsICForMakingPayment = false;
        paymentGatewayName = '';    
        productHelper = new ProductHelper();
        mapOfProgramNameVsProgram = new Map<String,nm_Program__c>();
        licenseapplicable = new Map<Integer,String>();
        paymentClouserMessage = '';
        programSpecialization  ='';
        paymentWindowClosed = false;
        LateFeeStartDate = null;
        AlreadyPaidLateFee = false;
        AlreadyPaidLateFeeAmount = 0;
        careerServicePackageName ='';
        studentInfo ='';
        liveLecType='';
        courseList='';
        objPayment = new nm_Payment__c();
        objtCenter = new nm_Centers__c ();
        aepisp = new AEP_site_inspection__c();
        mapOfProductAndAmount = new Map<String,Decimal>();
        // objPaymentFormConfiguration = new NM_Payment_Form_Configuration__c();
        errMessages = '';
        TagPriceBookId = null;
        currentAdmissionYear  = 0;
        currentAdmissionSession = '';
        strSecToShow = '';
        IsLateral = false;
        applicableLateFee = 0;
        licensesFee=0;
        studentName = '';
        studentEmail = '';
        studentMobileNo = '';
        CareerServiceRecordId='';
        studentAddress = '';
        validityExtensionId = '';
        studentCity = '';
        postPaymentPage = 'PostPaymentPage';
        studentPincode = '';
        centerId = '';
        displayName = '';     
        opportunityId = '';
        webinarRegid = '';
        AEPId='';
        AEPISPId = '';
        IsDefence = false;
        Cpjson ='';
        paymentFor = '';
        setOfAEPLicense = new Set<String>();
        mapOfActiveCalender = new Map<String,String>();
        mapOfAEPMerchandiseAndPrice = new Map<String, Decimal>();
        TotalAEPMerchPrice  = 0;
        isOpportunityProcessed = false;
        aepCenId='';
        isCourseraOpted = false;
        if(ApexPages.currentPage() != null) {
            recordId = ApexPages.currentPage().getParameters().get('id');
            if(ApexPages.currentPage().getParameters().get('IC') !=null){
                IsICForMakingPayment = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IC'));
            }
            if(ApexPages.currentPage().getParameters().get('pyt') !=null){
                paymentFor = ApexPages.currentPage().getParameters().get('pyt');
            }
                
            if(ApexPages.currentPage().getParameters().get('aepCenId') !=null && ApexPages.currentPage().getParameters().get('aepCenId') != '') {
                aepCenId = ApexPages.currentPage().getParameters().get('aepCenId');
            }
        }

        if(String.isNotBlank(recordId) && String.isBlank(aepCenId) && paymentFor!='coursera'){
            // query related to Validity Extension or Additional Charge Payment
            QueryPaymentOpportunityAndValidityExtensionDetails();
        }
        if(String.isNotBlank(aepCenId)) {
            QueryAEPMerchandise();
        }
        if(String.isNotBlank(recordId) && String.isBlank(aepCenId) && paymentFor=='coursera') {
            QueryCourseraProduct();
        }
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString , String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
    public void QueryAEPMerchandise() {
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); 
        String PriceBookEntry = 'select id, UnitPrice,Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c,product2.Id,Product2Id, product2.Family, product2.Name, product2.nm_Program__c, product2.nm_Semester__c'+
                +' from PriceBookEntry where product2.isActive = true '+
                +'and pricebook2.isStandard = false and Pricebook2.nmSession_Start_Date__c !=null '+
                +'and Pricebook2.nmSession_End_Date__c !=null ' +
                +'and product2.Family = \'AEP Merchandise\' ' +
                +'and Pricebook2.IsActive=true ';
        System.debug('Query = '+PriceBookEntry);
        lstPriceBookEntry = DataBase.query(PriceBookEntry);
        System.debug('lstPriceBookEntry ---> ' + lstPriceBookEntry);
        if(lstPriceBookEntry.size() > 0) {
            for(PriceBookEntry objPriceBook :lstPriceBookEntry) {
                system.debug('objPriceBook --> ' + objPriceBook);
                system.debug('objPriceBook.Product2Id --> ' + objPriceBook.Product2Id);
                system.debug('objPriceBook.UnitPrice --> ' + objPriceBook.UnitPrice);
                Decimal unitPriceWithGst5per = objPriceBook.UnitPrice + (objPriceBook.UnitPrice * 0.05);
                mapOfAEPMerchandiseAndPrice.put(objPriceBook.Product2Id, unitPriceWithGst5per );
            }
        }
        String centerquery = getQueryAllFieldSql('nm_Centers__c','id =:aepCenId',null);
        List<nm_Centers__c> lstCenter  = DataBase.query(centerquery);
        Decimal TotalPriceOfCart = 0;
        Map<String, Decimal> mapOfProductAndMoney = new Map<String, Decimal>();
        if(lstCenter.size() > 0) {
            nm_Centers__c objCenter = lstCenter[0];
            system.debug('objCenter --> ' + objCenter);
            studentNo = objcenter.nm_CenterCode__c.replaceAll('[^a-zA-Z0-9\\s+]', '').deleteWhitespace();
            recordId = objCenter.Id;
            AEPId = objCenter.Id;
            system.debug('AEPId -->' + AEPId);
            List<String> lstOrder = String.isNotBlank(objCenter.AEP_Merchen__c) ? objCenter.AEP_Merchen__c.split('\n') : new List<String>();            
            String orderString = lstOrder.size() > 0 ? lstOrder[lstOrder.size() -1] : '';
            if(String.isNotBlank(orderString)) {
                List<Object> lstJsonObject = (List<Object>) JSON.deserializeUntyped(orderString);
                for (Object obj : lstJsonObject) {
                    Map<String, Object> mapOfObject = (Map<String,Object>) obj;
                    if(mapOfObject.containsKey('ProductId')) {
                        system.debug((Decimal) Decimal.valueOf(String.valueOf(mapOfObject.get('NumberOfProduct')) ) );
                        system.debug( mapOfObject.get('ProductId') );
                        system.debug( mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId')) );
                        System.debug((Decimal) Decimal.valueOf((Integer) mapOfObject.get('NumberOfProduct')) * mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId')));
                        Decimal priceOfProduct = (Decimal) Decimal.valueOf((Integer) mapOfObject.get('NumberOfProduct')) * mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId'));
                        if(mapOfProductAndMoney.containsKey((String) mapOfObject.get('ProductId'))) {
                            Decimal amount = mapOfProductAndMoney.get((String) mapOfObject.get('ProductId')) + priceOfProduct;
                            mapOfProductAndMoney.remove((String) mapOfObject.get('ProductId'));
                            mapOfProductAndMoney.put((String) mapOfObject.get('ProductId'), amount);
                        } else {
                            mapOfProductAndMoney.put((String) mapOfObject.get('ProductId'), priceOfProduct);
                        }
                        TotalPriceOfCart = TotalPriceOfCart + (Decimal) Decimal.valueOf((Integer) mapOfObject.get('NumberOfProduct')) * mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId'));
                        
                    }
                }

            }
        }
        if(TotalPriceOfCart > 0 && mapOfProductAndMoney.size() > 0 ) {
            TotalAEPMerchPrice = TotalPriceOfCart.setScale(2);
            paymentFor = 'Tshirt';
            mapOfProductAndAmount.put('Tshirt', TotalPriceOfCart.setScale(2));
        }
    }

    public void QueryCourseraProduct() {
        String opportunityQuery = getQueryAllFieldSql('Opportunity',' id=:recordId Limit 1','Account.nm_DefencePersonnel__c ,Account.nm_Tagged_Pricebook__c,Account.nm_StudentNo__c,Account.nm_Centers__r.nm_City__c,Account.nm_RegistrationNumber__c,Account.nm_Allowtomakepayment__c,Account.nm_Centers__r.Name,Account.nm_Centers__r.Address__c,Account.PersonMobilePhone,Account.PersonEmail,Account.FirstName,nm_Program__r.nm_Type__c,Account.LastName,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.nm_ChooseaProgram__c,Account.nm_Centers__r.id,Account.Is_Lateral__c');
        List<Opportunity> lstOpportunity = DataBase.query(opportunityQuery);
        if(lstOpportunity.size() > 0){ 
            Opportunity objOpportunity = lstOpportunity[0];
            studentNo = objOpportunity.Account.nm_StudentNo__c;
            displayName = 'Student No';
            studentAddress = objOpportunity.Account.BillingStreet +','+objOpportunity.Account.BillingCity+','+objOpportunity.Account.BillingState+','+objOpportunity.Account.BillingPostalCode+','+objOpportunity.Account.BillingCountry;
            studentCity = objOpportunity.Account.BillingCity;
            studentPincode = objOpportunity.Account.BillingPostalCode;
            studentName = objOpportunity.Account.FirstName +' '+objOpportunity.Account.LastName;
            studentEmail = objOpportunity.Account.PersonEmail;
            studentMobileNo = objOpportunity.Account.PersonMobilePhone;
            opportunityId = recordId;
            IsDefence = objOpportunity.Account.nm_DefencePersonnel__c=='Yes'?true:false;
            TagPriceBookId = objOpportunity.Account.nm_Tagged_Pricebook__c;
            String priceBookEntryQuery1 = getQueryAllFieldSql('PriceBookEntry',' product2.Name=\'Coursera\' and product2.isActive=true and Pricebook2.id =:TagPriceBookId',' product2.Name,product2.nm_Program__c,product2.nm_Semester__c ');
            List<PriceBookEntry> lstPriceBookEntry = DataBase.query(priceBookEntryQuery1);
            system.debug('lstPriceBookEntry-->'+lstPriceBookEntry);
            
            if(lstPriceBookEntry.size() > 0){
                isCourseraOpted = true;
                paymentFor = 'Coursera';
                Decimal courseraFee = (lstPriceBookEntry[0].UnitPrice); // calculate extension fee amount 50% of Admission fee                           
                courseraFee = courseraFee.setScale(2);       
                mapOfProductAndAmount.put(paymentFor,courseraFee);
                System.debug('paymentFor-----'+paymentFor+'------'+courseraFee);
            }
        }
    }
    
    public void QueryPaymentOpportunityAndValidityExtensionDetails(){
        String manuallyCreatedAdditionalPaymentQuery  = getQueryAllFieldSql('nm_Payment__c', '(nm_PaymentType__c = \'Additional Charge\' or nm_PaymentType__c = \'Late Fees\') and (nm_PaymentStatus__c= \'Pending Late Fees\' or nm_PaymentStatus__c= \'Pending Extra Fees\') and  id=:recordId','nm_OpportunityNew__r.Account.nm_StudentNo__c,nm_OpportunityNew__r.Specialisation__c,nm_OpportunityNew__r.stageName,nm_OpportunityNew__r.Is_Re_Registration_Payment__c,nm_OpportunityNew__r.nm_Category__c,nm_OpportunityNew__r.Account.nm_RegistrationNumber__c,nm_OpportunityNew__r.Account.nm_Allowtomakepayment__c,nm_OpportunityNew__r.nm_StudentProgram__c,nm_OpportunityNew__r.Account.nm_Centers__r.id,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__r.Account.nm_Centers__r.nm_City__c,nm_OpportunityNew__r.Account.PersonMobilePhone,nm_OpportunityNew__r.Account.PersonEmail,nm_OpportunityNew__r.Account.FirstName,nm_OpportunityNew__r.Account.LastName,nm_OpportunityNew__r.nm_Semester__c,nm_OpportunityNew__r.nm_Program__r.nm_Type__c,nm_OpportunityNew__r.Account.BillingStreet,nm_OpportunityNew__r.Account.BillingCity,nm_OpportunityNew__r.Account.BillingState,nm_OpportunityNew__r.Account.BillingPostalCode,nm_OpportunityNew__r.Account.BillingCountry,nm_OpportunityNew__r.Account.nm_ChooseaProgram__c,nm_OpportunityNew__r.nm_year__c,nm_OpportunityNew__r.nm_Session__c,nm_OpportunityNew__r.Account.Is_Lateral__c' );
        String opportunityQuery = getQueryAllFieldSql('Opportunity',' id=:recordId ','Account.nm_StudentNo__c,Account.nm_Centers__r.nm_City__c,Account.nm_RegistrationNumber__c,Account.nm_Allowtomakepayment__c,Account.nm_Centers__r.Name,Account.nm_Centers__r.Address__c,Account.PersonMobilePhone,Account.PersonEmail,Account.FirstName,nm_Program__r.nm_Type__c,Account.LastName,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.nm_ChooseaProgram__c,Account.nm_Centers__r.id,Account.Is_Lateral__c,Account.nm_DefencePersonnel__c');
        String validityExtensionQuery = getQueryAllFieldSql('Validity_Extension__c','Related_Account__c =:recordId AND Payment_Approved__c = false','Related_Account__r.nm_Allowtomakepayment__c,Related_Account__r.nm_Centers__r.name,Related_Account__r.nm_Centers__r.nm_City__c,Related_Account__r.PersonEmail,Related_Account__r.PersonMobilePhone,Related_Account__r.FirstName,Related_Account__r.LastName, Related_Account__r.BillingStreet,Related_Account__r.BillingCity,Related_Account__r.BillingState,Related_Account__r.BillingPostalCode,Related_Account__r.BillingCountry,Related_Account__r.nm_Centers__r.id,Related_Account__r.nm_Tagged_Pricebook__c,Related_Account__r.nm_ChooseaProgram__c,Related_Account__r.nm_DefencePersonnel__c');
        String careerservicerecordquery = getQueryAllFieldSql('Career_Service_Program__c','id=:recordId','CareerServiceProgram__r.Package_Name__c,Account__r.nm_ChooseaProgram__c,Account__r.FirstName,Account__r.LastName,Account__r.PersonEmail,Account__r.PersonMobilePhone,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.nm_Tagged_Pricebook__c,Account__r.nm_Centers__r.id');
        String webinarquery = getQueryAllFieldSql('Referral__c','id =:recordId','Webinar__r.Id');
        String centerquery = getQueryAllFieldSql('nm_Centers__c','id =:recordId',null);
        String asiQuery = getQueryAllFieldSql('AEP_site_inspection__c','id =:recordId and Centers__c = null',null);
        
        List<nm_Payment__c> lstManuallyCreatedPendingPayment = DataBase.query(manuallyCreatedAdditionalPaymentQuery);
       System.debug('lstManuallyCreatedPendingPayment--->'+lstManuallyCreatedPendingPayment.size());
        if(lstManuallyCreatedPendingPayment.size() > 0){
            for(nm_Payment__c objPayment : lstManuallyCreatedPendingPayment){
                IsReregistartion = objPayment.nm_OpportunityNew__r.Is_Re_Registration_Payment__c;
                programCategory = objPayment.nm_OpportunityNew__r.Account.nm_ChooseaProgram__c;
                programType = 'Admission';
                recordId = objPayment.nm_OpportunityNew__c;
                opportunityId = objPayment.nm_OpportunityNew__c;
                Semester = objPayment.nm_OpportunityNew__r.nm_Semester__c;
                programSpecialization  = objPayment.nm_OpportunityNew__r.Specialisation__c;
                studentName = objPayment.nm_OpportunityNew__r.Account.FirstName +' '+objPayment.nm_OpportunityNew__r.Account.LastName;
                studentEmail = objPayment.nm_OpportunityNew__r.Account.PersonEmail;
                studentMobileNo = objPayment.nm_OpportunityNew__r.Account.PersonMobilePhone;
                studentAddress = objPayment.nm_OpportunityNew__r.Account.BillingStreet +','+objPayment.nm_OpportunityNew__r.Account.BillingCity+','+objPayment.nm_OpportunityNew__r.Account.BillingState+','+objPayment.nm_OpportunityNew__r.Account.BillingPostalCode+','+objPayment.nm_OpportunityNew__r.Account.BillingCountry;
                studentCity = objPayment.nm_OpportunityNew__r.Account.BillingCity;
                studentPincode = objPayment.nm_OpportunityNew__r.Account.BillingPostalCode;
                centerId = objPayment.nm_OpportunityNew__r.Account.nm_Centers__r.id;
                studentNo = objPayment.nm_OpportunityNew__r.Account.nm_RegistrationNumber__c;
                displayName = 'Registration No';
                currentAdmissionYear = objPayment.nm_OpportunityNew__r.nm_year__c;
                currentAdmissionSession = objPayment.nm_OpportunityNew__r.nm_Session__c;
                paymentFor = 'Additional Charge';
                mapOfProductAndAmount.put(paymentFor,objPayment.nm_Amount__c);
                IsLateral = objPayment.nm_OpportunityNew__r.Account.Is_Lateral__c;
                if(IsReregistartion){
                    studentNo = objPayment.nm_OpportunityNew__r.Account.nm_StudentNo__c;
                    displayName = 'Student No';
                }
            }
        }else{
            List<Opportunity> lstOpportunity = DataBase.query(opportunityQuery);
             System.debug('lstOpportunity--->'+lstOpportunity.size());
            if(lstOpportunity.size() > 0){
                for(Opportunity objOpportunity : lstOpportunity){
                    IsReregistartion = objOpportunity.Is_Re_Registration_Payment__c;
                    programCategory = objOpportunity.Account.nm_ChooseaProgram__c;
                    programType = 'Admission';
                    opportunityId = objOpportunity.id;
                    Semester = objOpportunity.nm_Semester__c;
                    studentName = objOpportunity.Account.FirstName +' '+objOpportunity.Account.LastName;
                    studentEmail = objOpportunity.Account.PersonEmail;
                    studentMobileNo = objOpportunity.Account.PersonMobilePhone;
                    studentAddress = objOpportunity.Account.BillingStreet +','+objOpportunity.Account.BillingCity+','+objOpportunity.Account.BillingState+','+objOpportunity.Account.BillingPostalCode+','+objOpportunity.Account.BillingCountry;
                    studentCity = objOpportunity.Account.BillingCity;
                    studentPincode = objOpportunity.Account.BillingPostalCode;
                    centerId = objOpportunity.Account.nm_Centers__r.id;
                    studentNo = objOpportunity.Account.nm_RegistrationNumber__c;
                    displayName = 'Registration No';
                    programSpecialization  = objOpportunity.Specialisation__c;
                    currentAdmissionYear = objOpportunity.nm_year__c;
                    currentAdmissionSession = objOpportunity.nm_Session__c;
                    liveLecType = objOpportunity.LiveLecturesType__c;
                    courseList = objOpportunity.CourseList__c;
                    isOpportunityProcessed = objOpportunity.Processed__c;
                    getPendingPaymentFor(objOpportunity);
                    IsLateral = objOpportunity.Account.Is_Lateral__c;
                    IsDefence = objOpportunity.Account.nm_DefencePersonnel__c=='Yes'?true:false;

                    if(IsReregistartion){
                        studentNo = objOpportunity.Account.nm_StudentNo__c;
                        displayName = 'Student No';
                    }
                }
            }else{
                List<Validity_Extension__c> lstValidityExtension = DataBase.query(validityExtensionQuery);
                 System.debug('lstValidityExtension --->'+lstValidityExtension.size());
                String priceBookEntryQuery = getQueryAllFieldSql('PriceBookEntry',' product2.nm_Program__c=:programId and product2.isActive=true and Pricebook2.id=:TagPriceBookId and product2.nm_Semester__c!=null',' product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
                String noOfValExt = '';
                if(lstValidityExtension.size() > 0){
                    getMapOfProgramNameVsProgram();
                    for(Validity_Extension__c objValidityExtension : lstValidityExtension){
                        studentName = objValidityExtension.Related_Account__r.FirstName +' '+objValidityExtension.Related_Account__r.LastName;
                        studentEmail = objValidityExtension.Related_Account__r.PersonEmail;
                        studentMobileNo = objValidityExtension.Related_Account__r.PersonMobilePhone;
                        studentAddress = objValidityExtension.Related_Account__r.BillingStreet +','+objValidityExtension.Related_Account__r.BillingCity+','+objValidityExtension.Related_Account__r.BillingState+','+objValidityExtension.Related_Account__r.BillingPostalCode+','+objValidityExtension.Related_Account__r.BillingCountry;
                        studentCity = objValidityExtension.Related_Account__r.BillingCity;
                        studentPincode = objValidityExtension.Related_Account__r.BillingPostalCode;
                        centerId = objValidityExtension.Related_Account__r.nm_Centers__r.id;
                        studentNo = objValidityExtension.Student_Number_Of_Account__c;
                        TagPriceBookId = objValidityExtension.Related_Account__r.nm_Tagged_Pricebook__c;
                        displayName = 'Student No';
                        IsDefence = objValidityExtension.Related_Account__r.nm_DefencePersonnel__c =='Yes'?true:false;

                        validityExtensionId = objValidityExtension.id;
                        programCategory = objValidityExtension.Related_Account__r.nm_ChooseaProgram__c;
                        noOfValExt = objValidityExtension.Number_of_validity_taken__c;
                        system.debug('objValidityExtension.Student_Program_Validity__c--->'+objValidityExtension.Student_Program_Validity__c);
                        if(mapOfProgramNameVsProgram.containsKey(objValidityExtension.Student_Program_Validity__c)){
                            programId = mapOfProgramNameVsProgram.get(objValidityExtension.Student_Program_Validity__c).id;
                            system.debug('programId --->'+programId);
                        }
                    }
                    
                    if(programId !=null && programId !=''){
                        decimal extensionFee = getValExtOf1Ext(TagPriceBookId, programId, programCategory, IsDefence, noOfValExt);
                        if (extensionFee > 1) {
                            paymentFor = 'Validity Extension Fee';
                            mapOfProductAndAmount.put(paymentFor,extensionFee);
                            System.debug('paymentFor-----'+paymentFor+'------'+extensionFee);
                        }
                    }else{
                        errMessages = 'Unable to get Program Details....';
                        strSecToShow = 'error';
                    }
                }
                
                else{
                    List<Referral__c> lstofwebinar = DataBase.query(webinarquery);
                    if(lstofwebinar.size()>0)
                    {
                        for(Referral__c objwebinar:lstofwebinar) {
                            studentName = objwebinar.Name__c;
                            studentEmail = objwebinar.Email__c;
                            studentMobileNo = objwebinar.Mobile_Number__c;
                            studentCity = objwebinar.City__c;
                            studentPincode = '400056';
                            studentNo = objwebinar.Webinar_Reg_no__c;
                            displayName = 'NMentor Conclave Registration Number';
                            webinarRegid = objwebinar.id;
                            paymentFor = 'Seminar Fee'; 
                            Integer seminarFee = Integer.valueOf(Label.Seminar_Fee);        
                            mapOfProductAndAmount.put(paymentFor,seminarFee+(seminarFee*Decimal.valueOf(Label.Service_Tax)));                                             
                        } 
                    }
                    else {
                        List<Career_Service_Program__c> lstCareerserviceProgram  = DataBase.query(careerservicerecordquery);
                        //  String priceBookEntryQuery = getQueryAllFieldSql('PriceBookEntry',' product2.nm_Program__c =:programId and product2.isActive = true and Pricebook2.id =: TagPriceBookId',' product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
                        system.debug('lstCareerserviceProgram--->'+lstCareerserviceProgram);
                        if(lstCareerserviceProgram.size()>0)
                        {
                            for(Career_Service_Program__c objCarrerServiceProgram : lstCareerserviceProgram){
                                studentName = objCarrerServiceProgram.Account__r.FirstName +' '+objCarrerServiceProgram.Account__r.LastName;
                                studentEmail = objCarrerServiceProgram.Account__r.PersonEmail;
                                studentMobileNo = objCarrerServiceProgram.Account__r.PersonMobilePhone;
                                studentAddress = objCarrerServiceProgram.Account__r.BillingStreet +','+objCarrerServiceProgram.Account__r.BillingCity+','+objCarrerServiceProgram.Account__r.BillingState+','+objCarrerServiceProgram.Account__r.BillingPostalCode+','+objCarrerServiceProgram.Account__r.BillingCountry;
                                studentCity = objCarrerServiceProgram.Account__r.BillingCity;
                                studentPincode = objCarrerServiceProgram.Account__r.BillingPostalCode;
                                centerId = objCarrerServiceProgram.Account__r.nm_Centers__r.id;
                                studentNo = objCarrerServiceProgram.Student_Number_Of_Account__c;
                                TagPriceBookId = objCarrerServiceProgram.Account__r.nm_Tagged_Pricebook__c;
                                displayName = 'Student No';
                                CareerServiceRecordId = objCarrerServiceProgram.id;
                                programCategory = objCarrerServiceProgram.Account__r.nm_ChooseaProgram__c; 
                                //paymentFor = objCarrerServiceProgram.CareerServiceProgram__r.Package_Name__c;
                                careerServicePackageName = objCarrerServiceProgram.CareerServiceProgram__r.Package_Name__c;                          
                                paymentFor = 'Career Service';
                            }
                            String priceBookEntryQuery1 = getQueryAllFieldSql('PriceBookEntry',' product2.Name=:careerServicePackageName and  product2.isActive = true and Pricebook2.id =: TagPriceBookId',' product2.Name, product2.nm_Program__c,product2.nm_Semester__c ');
                             List<PriceBookEntry> lstPriceBookEntry = DataBase.query(priceBookEntryQuery1);
                             system.debug('lstPriceBookEntry-->'+lstPriceBookEntry);
                             
                            if(lstPriceBookEntry.size() > 0){
                                decimal careerserviceFee = (lstPriceBookEntry[0].UnitPrice); // calculate extension fee amount 50% of Admission fee                           
                                careerserviceFee = careerserviceFee.setScale(2);                           
                                mapOfProductAndAmount.put(paymentFor,careerserviceFee);
                                System.debug('paymentFor-----'+programCategory+'------'+careerserviceFee);
                            }
                        }
                        else{
                            List<nm_Centers__c> lstCenter  = DataBase.query(centerquery);
                        //  String priceBookEntryQuery = getQueryAllFieldSql('PriceBookEntry',' product2.nm_Program__c =:programId and product2.isActive = true and Pricebook2.id =: TagPriceBookId',' product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
                            system.debug('lstCenter--->'+lstCenter);
                           
                            if(lstCenter.size()>0)
                            {
                                Date expiryDate ;
                                Decimal productprice;
                                Map<String,Integer> licenseapplicableName = new Map<String,Integer>();      
                                
                                String UserLicense  = getQueryAllFieldSql('PermissionSetLicense','Status = \'Active\' limit 1',null);
                                String priceBookEntryQuery4 = getQueryAllFieldSql('PriceBookEntry','product2.Family=\'AEP\' and product2.isActive = true AND Pricebook2.nmSession_Start_Date__c <= today AND Pricebook2.nmSession_End_Date__c >= today',' product2.Name,product2.GST__c, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');

                                List<PriceBookEntry> lstPriceBookEntry = DataBase.query(priceBookEntryQuery4);
                                if(lstPriceBookEntry.size() > 0 && paymentFor!=null){
                                
                                    for(PriceBookEntry objprice: lstPriceBookEntry)
                                    {
                                        // mapOfProductAndAmount.put(objprice.product2.Name,objprice.product2.GST__c? (objprice.UnitPrice+(objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax))).setScale(2): objprice.UnitPrice);
                                        if (lstCenter[0].Discount_applicable__c) {
                                            Decimal discountedAmount = Decimal.valueOf(Label.Discount_applicable_value) * objprice.UnitPrice;
                                            Decimal gstAmount = objprice.product2.GST__c?  discountedAmount*Decimal.valueOf(Label.Service_Tax) : 0;
                                            Decimal tdsAmount = lstCenter[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * discountedAmount : 0;
                                            mapOfProductAndAmount.put(objprice.product2.Name, (discountedAmount + gstAmount + tdsAmount).setScale(2));
                                        } else {
                                            Decimal gstAmount = objprice.product2.GST__c?  objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax) : 0;
                                            Decimal tdsAmount = lstCenter[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * objprice.UnitPrice : 0;
                                            mapOfProductAndAmount.put(objprice.product2.Name, (objprice.UnitPrice + gstAmount - tdsAmount).setScale(2));
                                        }
                                    }
                                    
                                }
                                List<PermissionSetLicense> lstUserLicense  = DataBase.query(UserLicense);
                                if(lstUserLicense.size()>0)
                                {
                                    expiryDate = lstUserLicense[0].ExpirationDate ;
                                }                                
                                for(nm_Centers__c objcenter:lstCenter)
                                {
                                    Integer countlicense = 0;
                                    
                                    objtCenter =  objcenter;
                                    studentName = objcenter.Name;
                                    studentEmail = objcenter.AEP_email_id__c;
                                    studentMobileNo = objcenter.Contact_No_1__c;
                                    studentCity = objcenter.nm_City__c;
                                    studentPincode = objcenter.nm_PostalCode__c;
                                    
                                   // studentNo = objcenter.nm_CenterCode__c;
                                   studentInfo = paymentFor;
                                   studentNo = '';
                                   paymentFor = paymentFor;
                                   AEPId = objcenter.id;
                                //    if( objcenter.Allow_Degree__c && paymentFor == 'MS License Fee')
                                //    {
                                //        countlicense = countlicense+1;
                                //        licenseapplicable.put(countlicense,'MS License Fee');
                                //        system.debug('countlicense-->'+countlicense);
                                //        system.debug('allowDegree-->'+objcenter.Allow_Degree__c);
                                //    }
                               //    if(objcenter.Allow_Bachelor__c)
                               //    {
                               //     countlicense =countlicense+1;
                               //     licenseapplicable.put(countlicense,'UG License Fee');
                               //     system.debug('countlicense-->'+countlicense);
                               //    }
                                //    if(objcenter.Allow_PG__c && paymentFor == 'UG And PG License Fee')
                                //    {
                                //        countlicense =countlicense+1;
                                //        licenseapplicable.put(countlicense,'UG And PG License Fee');
                                //        system.debug('countlicense-->'+countlicense);
                                //    }
                                
                                    Cpjson = objcenter.Partner_User_list__c ;
                                    displayName = paymentFor !=null ?paymentFor:'Partner Community Licenses Fee';
                                    Integer monthsBetween = expiryDate!=null? expiryDate.monthsBetween(Today):0;
                                    Integer TotalLicensesRequired = Integer.valueOf(objcenter.TotalLicensesRequired__c) !=null? Integer.valueOf(objcenter.TotalLicensesRequired__c) :0;
                                    paymentFor = paymentFor !=null && paymentFor!='' ?paymentFor:'Community Licenses Fee';
                                    licensesFee = objcenter.amount_For_new_License__c>0 && objcenter.amount_For_new_License__c!=null?Integer.valueof(objcenter.amount_For_new_License__c ):0;      
                                    system.debug('licensesFee--->'+licensesFee);  
                                    system.debug('monthsBetween--->'+monthsBetween);
                                    system.debug('TotalLicensesRequired--->'+TotalLicensesRequired);
                                    system.debug('mapOfProductAndAmount-->'+mapOfProductAndAmount);
                                    system.debug('paymentFor-->'+paymentFor);
                                    if(paymentFor=='Community Licenses Fee')
                                    {
                                        mapOfProductAndAmount.put(paymentFor,licensesFee); 
                                    }
                                    // if(licenseapplicable.size()>=1 )
                                    // {
                                    //     productprice = mapOfProductAndAmount.get(paymentFor);
                                    //     for (Integer license : licenseapplicable.keySet())
                                    //     {
                                    //         Map<String, Decimal> paymentTypevsamount = new Map<String, Decimal>();
                                    //         String paymentQueryForAEP = getQueryAllFieldSql('nm_Payment__c',' AEP__c =:recordId and ( nm_PaymentStatus__c = \'Payment Made\' or nm_PaymentStatus__c = \'Payment Approved\' or nm_PaymentStatus__c = \'Waived Off\' )',null);
                                    //         List<nm_Payment__c> lstPayment = DataBase.query(paymentQueryForAEP);
                                    //         for(nm_Payment__c objpymt :lstPayment)
                                    //         {
                                    //             if(!paymentTypevsamount.containsKey(objpymt.nm_PaymentType__c))
                                    //             {
                                    //                 paymentTypevsamount.put(objpymt.nm_PaymentType__c,objpymt.nm_Amount__c);
                                    //             }else{
                                    //                 paymentTypevsamount.put(objpymt.nm_PaymentType__c,paymentTypevsamount.get(objpymt.nm_PaymentType__c)+objpymt.nm_Amount__c);
                                    //             }
                                    //         }
    
                                    //         // if(license ==1){
                                    //         //     putLicenseFee(1,productprice,0,paymentTypevsamount);
                                    //         // }

                                    //         // if(license==2){
                                    //         //     putLicenseFee(2,productprice,0.8,paymentTypevsamount);
                                    //         // }
                                            
                                    //         // if(license==3){
                                    //         //     putLicenseFee(3,productprice,0.7,paymentTypevsamount);
                                    //         // }

                                    //         List<nm_Payment__c> lstPay = [SELECT Id,nm_Amount__c,nm_PaymentType__c,nm_PaymentStatus__c from nm_Payment__c Where AEP__c=:recordId and (nm_PaymentType__c = 'MS License Fee' or nm_PaymentType__c = 'UG And PG License Fee') and (nm_PaymentStatus__c = 'Payment Approved' or nm_PaymentStatus__c = 'Payment Made')];
                                    //         if(lstPay.size()>0){
                                    //             putLicenseFeeNew(1,productprice,0.2,paymentTypevsamount);
                                    //         }else{
                                    //             putLicenseFeeNew(1,productprice,0,paymentTypevsamount);
                                    //         }

                                    //     }
                                        
                                    // }
                                    
                                   /*  if(mapOfProductAndAmount.containsKey('New AEP License Fee'))
                                    {
                                        system.debug('countlicense-->'+countlicense);
                                        if(countlicense==2)
                                        {
                                            productprice = mapOfProductAndAmount.get('New AEP License Fee');
                                            productprice += productprice*0.8; 
                                            productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                            mapOfProductAndAmount.put('New AEP License Fee',productprice.setScale(2)); 

                                        }else if(countlicense==3)
                                        {
                                            productprice =  mapOfProductAndAmount.get('New AEP License Fee'); 
                                            productprice = productprice+productprice+(productprice*0.7); 
                                            productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                            mapOfProductAndAmount.put('New AEP License Fee',productprice.setScale(2)); 

                                        }

                                    } if(mapOfProductAndAmount.containsKey('Renewal License Fee'))
                                    {
                                        system.debug('countlicense-->'+countlicense);
                                        if(countlicense==2)
                                        {
                                            productprice = mapOfProductAndAmount.get('Renewal License Fee');
                                            productprice += productprice*0.8; 
                                            productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                            mapOfProductAndAmount.put('Renewal License Fee',productprice.setScale(2)); 

                                        }else if(countlicense==3)
                                        {
                                            productprice =  mapOfProductAndAmount.get('Renewal License Fee'); 
                                            productprice = productprice+productprice+(productprice*0.7); 
                                            productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                            mapOfProductAndAmount.put('Renewal License Fee',productprice.setScale(2)); 

                                        }

                                    }*/
                                }
                            } 
                            
                            else
                            {
                               
                                List<AEP_site_inspection__c> lstAEPSiteIns  = DataBase.query(asiQuery);
                                //  String priceBookEntryQuery = getQueryAllFieldSql('PriceBookEntry',' product2.nm_Program__c =:programId and product2.isActive = true and Pricebook2.id =: TagPriceBookId',' product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
                                    system.debug('lstAEPSiteIns--->'+lstAEPSiteIns);
                                   
                                    if(lstAEPSiteIns.size()>0)
                                    {
                                        Date expiryDate ;
                                        Decimal productprice;
                                        Map<String,Integer> licenseapplicableName = new Map<String,Integer>();      
                                        
                                        // String UserLicense  = getQueryAllFieldSql('PermissionSetLicense','Status = \'Active\' limit 1',null);
                                        String priceBookEntryQuery5 = getQueryAllFieldSql('PriceBookEntry','product2.Family=\'AEP\' and product2.isActive = true AND Pricebook2.nmSession_Start_Date__c <= today AND Pricebook2.nmSession_End_Date__c >= today',' product2.Name,product2.GST__c, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
        
                                        List<PriceBookEntry> lstPriceBookEntry1 = DataBase.query(priceBookEntryQuery5);
                                        if(lstPriceBookEntry1.size() > 0 && paymentFor!=null){
                                        
                                            for(PriceBookEntry objprice: lstPriceBookEntry1)
                                            {
                                                if (lstAEPSiteIns[0].Discount_applicable__c) {
                                                    Decimal discountedAmount = Decimal.valueOf(Label.Discount_applicable_value  ) * objprice.UnitPrice;
                                                    Decimal gstAmount = objprice.product2.GST__c?  discountedAmount*Decimal.valueOf(Label.Service_Tax) : 0;
                                                    Decimal tdsAmount = lstAEPSiteIns[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * discountedAmount : 0;
                                                    mapOfProductAndAmount.put(objprice.product2.Name, (discountedAmount + gstAmount + tdsAmount).setScale(2));
                                                } else {
                                                    Decimal gstAmount = objprice.product2.GST__c?  objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax) : 0;
                                                    Decimal tdsAmount = lstAEPSiteIns[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * objprice.UnitPrice : 0;
                                                    mapOfProductAndAmount.put(objprice.product2.Name, (objprice.UnitPrice + gstAmount - tdsAmount).setScale(2));
                                                }
                                            }
                                            
                                        }
                                        // List<PermissionSetLicense> lstUserLicense  = DataBase.query(UserLicense);
                                        // if(lstUserLicense.size()>0)
                                        // {
                                        //     expiryDate = lstUserLicense[0].ExpirationDate ;
                                        // }                                
                                        for(AEP_site_inspection__c aepisp:lstAEPSiteIns)
                                        {
                                            Integer countlicense = 0;
                                            
                                            aepisp =  aepisp;
                                            studentName = aepisp.Name_of_the_Centre__c;
                                            studentEmail = aepisp.User_Email__c;
                                            studentMobileNo = aepisp.Contact_No_1__c;
                                            studentCity = aepisp.Location_City__c;
                                            studentPincode = aepisp.nm_PostalCode__c;
                                            studentInfo = paymentFor;
                                            studentNo = aepisp.Name.Split('-')[1].trim();
                                            paymentFor = paymentFor;
                                            AEPISPId = aepisp.id;
                                        //    if( aepisp.Offer_Master__c && paymentFor == 'MS License Fee')
                                        //    {
                                        //     countlicense = countlicense+1;
                                        //     licenseapplicable.put(countlicense,'MS License Fee');
                                        //     system.debug('countlicense-->'+countlicense);
                                        //     system.debug('Offer_Master__c-->'+aepisp.Offer_Master__c);
        
                                        //    }
                                        //    if(aepisp.Offer_PG__c && paymentFor == 'UG And PG License Fee')
                                        //    {
                                        //     countlicense =countlicense+1;
                                        //     licenseapplicable.put(countlicense,'UG And PG License Fee');
                                        //     system.debug('countlicense-->'+countlicense);
                                        //    }
                                        //    if(objcenter.Allow_PG__c)
                                        //    {
                                        //     countlicense =countlicense+1;
                                        //     licenseapplicable.put(countlicense,'PG License Fee');
                                        //     system.debug('countlicense-->'+countlicense);
                                        //    }
                                        
                                            // Cpjson = objcenter.Partner_User_list__c ;
                                            // displayName = paymentFor !=null ?paymentFor:'Partner Community Licenses Fee';
                                            // Integer monthsBetween = expiryDate!=null? expiryDate.monthsBetween(Today):0;
                                            // Integer TotalLicensesRequired = Integer.valueOf(objcenter.TotalLicensesRequired__c) !=null? Integer.valueOf(objcenter.TotalLicensesRequired__c) :0;
                                            // paymentFor = paymentFor !=null && paymentFor!='' ?paymentFor:'Community Licenses Fee';
                                            // licensesFee = objcenter.amount_For_new_License__c>0 && objcenter.amount_For_new_License__c!=null?Integer.valueof(objcenter.amount_For_new_License__c ):0;      
                                            // system.debug('licensesFee--->'+licensesFee);  
                                            // system.debug('monthsBetween--->'+monthsBetween);
                                            // system.debug('TotalLicensesRequired--->'+TotalLicensesRequired);
                                            // system.debug('mapOfProductAndAmount-->'+mapOfProductAndAmount);
                                            // system.debug('paymentFor-->'+paymentFor);
                                            // if(paymentFor=='Community Licenses Fee')
                                            // {
                                            //     mapOfProductAndAmount.put(paymentFor,licensesFee); 
                                            // }

                                            displayName = String.isNotBlank(paymentFor) ? paymentFor : '';
                                            
                                            // if(licenseapplicable.size()>=1 )
                                            // {
                                            //     productprice = mapOfProductAndAmount.get(paymentFor);
                                            //     for (Integer license : licenseapplicable.keySet())
                                            //     {
                                            //         Map<String, Decimal> paymentTypevsamount = new Map<String, Decimal>();
                                            //         String paymentQueryForAEP = getQueryAllFieldSql('nm_Payment__c',' AEP_site_inspection__c =:recordId and ( nm_PaymentStatus__c = \'Payment Made\' or nm_PaymentStatus__c = \'Payment Approved\' or nm_PaymentStatus__c = \'Waived Off\' )',null);
                                            //         List<nm_Payment__c> lstPayment = DataBase.query(paymentQueryForAEP);
                                            //         for(nm_Payment__c objpymt :lstPayment)
                                            //         {
                                            //             if(!paymentTypevsamount.containsKey(objpymt.nm_PaymentType__c))
                                            //             {
                                            //                 paymentTypevsamount.put(objpymt.nm_PaymentType__c,objpymt.nm_Amount__c);
                                            //             }else{
                                            //                 paymentTypevsamount.put(objpymt.nm_PaymentType__c,paymentTypevsamount.get(objpymt.nm_PaymentType__c)+objpymt.nm_Amount__c);
                                            //             }
                                            //         }


                                            //         List<nm_Payment__c> lstPay = [SELECT Id,nm_Amount__c,nm_PaymentType__c,nm_PaymentStatus__c from nm_Payment__c Where AEP_site_inspection__c=:recordId and (nm_PaymentType__c = 'MS License Fee' or nm_PaymentType__c = 'UG And PG License Fee') and (nm_PaymentStatus__c = 'Payment Approved' or nm_PaymentStatus__c = 'Payment Made')];
                                            //         if(lstPay.size()>0){
                                            //             putLicenseFeeNew(1,productprice,0.2,paymentTypevsamount);
                                            //         }else{
                                            //             putLicenseFeeNew(1,productprice,0,paymentTypevsamount);
                                            //         }

                                            //         // if(license ==1){
                                            //         //     putLicenseFee(1,productprice,0,paymentTypevsamount);
                                            //         // }
        
                                            //         // if(license==2){
                                            //         //     putLicenseFee(2,productprice,0.8,paymentTypevsamount);
                                            //         // }
                                                    
                                            //         // if(license==3){
                                            //         //     putLicenseFee(3,productprice,0.7,paymentTypevsamount);
                                            //         // }
        
                                            //     }
                                                
                                            // }
                                            
                                           /*  if(mapOfProductAndAmount.containsKey('New AEP License Fee'))
                                            {
                                                system.debug('countlicense-->'+countlicense);
                                                if(countlicense==2)
                                                {
                                                    productprice = mapOfProductAndAmount.get('New AEP License Fee');
                                                    productprice += productprice*0.8; 
                                                    productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                                    mapOfProductAndAmount.put('New AEP License Fee',productprice.setScale(2)); 
        
                                                }else if(countlicense==3)
                                                {
                                                    productprice =  mapOfProductAndAmount.get('New AEP License Fee'); 
                                                    productprice = productprice+productprice+(productprice*0.7); 
                                                    productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                                    mapOfProductAndAmount.put('New AEP License Fee',productprice.setScale(2)); 
        
                                                }
        
                                            } if(mapOfProductAndAmount.containsKey('Renewal License Fee'))
                                            {
                                                system.debug('countlicense-->'+countlicense);
                                                if(countlicense==2)
                                                {
                                                    productprice = mapOfProductAndAmount.get('Renewal License Fee');
                                                    productprice += productprice*0.8; 
                                                    productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                                    mapOfProductAndAmount.put('Renewal License Fee',productprice.setScale(2)); 
        
                                                }else if(countlicense==3)
                                                {
                                                    productprice =  mapOfProductAndAmount.get('Renewal License Fee'); 
                                                    productprice = productprice+productprice+(productprice*0.7); 
                                                    productprice += productprice*Decimal.valueOf(Label.Service_Tax);
                                                    mapOfProductAndAmount.put('Renewal License Fee',productprice.setScale(2)); 
        
                                                }
        
                                            }*/
                                        }
                                    }
                                    else{
                                        errMessages = 'No matching record found for mention details';
                                        strSecToShow = 'error';
                                        System.debug('errMessages '+errMessages+' strSecToShow '+strSecToShow);
                                        return;
                                    }     
                            }
                        }
                    }
                }
            }
        }
        
        if(IsReregistartion){
            programType = 'Re-Registration';
        }
    }
    
    public void putLicenseFee(Integer license,Decimal productprice,Decimal precentageProdPrice,Map<String,Decimal> paymentTypevsamount){
        // Decimal productprice1 = 0.0;
        // if(precentageProdPrice > 0){
        //     productprice1 = productprice * precentageProdPrice; 
        //     productprice1 = productprice1 + productprice1 * Decimal.valueOf(Label.Service_Tax);
        // }else{
        //     productprice1 = productprice + productprice * Decimal.valueOf(Label.Service_Tax);
        // }
        
        // Decimal paidamount1 = paymentTypevsamount.containsKey(licenseapplicable.get(license)) ? paymentTypevsamount.get(licenseapplicable.get(license)): 0;
        // productprice1 = paidamount1 > 0 ? productprice1 - paidamount1 : productprice1 ;
        // system.debug('productprice1-->'+productprice1);
        // if(productprice1 > 0){
        //     mapOfProductAndAmount.put(licenseapplicable.get(license),productprice1.setScale(2)); 
        //     system.debug('licenseapplicable--->'+licenseapplicable.get(license));
        //     setOfAEPLicense.add(String.valueof(license));
        // }
    }

    public void putLicenseFeeNew(Integer license,Decimal productprice,Decimal precentageProdPrice,Map<String,Decimal> paymentTypevsamount){
        Decimal productprice1 = 0.0;
        if(precentageProdPrice > 0){
            // productprice1 = productprice * precentageProdPrice; 
            // productprice1 = productprice1 + productprice1 * Decimal.valueOf(Label.Service_Tax);
            productprice1 = productprice - (productprice * precentageProdPrice);
        }
        
        Decimal paidamount1 = paymentTypevsamount.containsKey(licenseapplicable.get(license)) ? paymentTypevsamount.get(licenseapplicable.get(license)): 0;
        productprice1 = paidamount1 > 0 ? productprice1 - paidamount1 : productprice1 ;
        system.debug('productprice1-->'+productprice1);
        if(productprice1 > 0){
            mapOfProductAndAmount.put(licenseapplicable.get(license),productprice1.setScale(2)); 
            system.debug('licenseapplicable--->'+licenseapplicable.get(license));
            setOfAEPLicense.add(String.valueof(license));
        }
    }


    
    // calculate Pending Amount for Admission ,Additional Charge,Late Fees,StudyKit,ICChange Fee ,Program Change Fee,Certificate Service Tax 
    public void getPendingPaymentFor(Opportunity objOpportunity){
        decimal admissionAmountReceived = 0;
        decimal LateFeeAmountReceived = 0;
        decimal ICChangeFeeReceived = 0;
        decimal ProgramChangeFeeReceived = 0;
        decimal StudyKitFeeReceived = 0;
       // decimal LiveLecturesReceived = 0;
        decimal programChangeWithStudyKitFeeReceived = 0;
        decimal programChangeAndICChangeWithStudyKitFeeReceived = 0;
        decimal programChangeAndICChangeWithoutStudyKitFeeReceived = 0;
        decimal ICChangeWithStudyKitFeeReceived = 0;
        decimal CertificateSerivceTaxFeeReceived = 0;
        decimal RepeatTermFeeReceived =0 ;
        decimal CarrerServiceFeeReceived = 0;
        
        decimal semesterProductPrice = 0;
        decimal RepeatTermProductPrice = 0;
        decimal ICChangeProductPrice = 0;
        decimal ProgramChangeProductPrice = 0;
        decimal StudyKitProductPrice = 0;
        decimal LiveLecturePrice = 0;
        decimal LiveLectureFeeReceived = 0;
        decimal CourseraFeeReceived = 0;
        decimal CertificateSerivceTaxProductPrice = 0;
        decimal LateFeeProductPrice = 0;
        decimal CarrerServiceFee = 0;
        decimal CourseraFee = 0;
        decimal loanOptedAmount = (objOpportunity.Loan_Amount__c!=null && objOpportunity.Loan_Amount__c!='') ? Decimal.valueOf(objOpportunity.Loan_Amount__c) : 0;
        
        String paymentQueryForOpportunity = getQueryAllFieldSql('nm_Payment__c',' nm_OpportunityNew__c =:opportunityId and nm_PaymentStatus__c != \'Transaction Failed\' ',' nm_OpportunityNew__r.ActualPendingAmount__c');
        List<nm_Payment__c> lstPayment = DataBase.query(paymentQueryForOpportunity);
        Boolean loanAmountDisbursed = false;
        if(lstPayment.size() > 0){
            for(nm_Payment__c objPayment : lstPayment){
                if(objPayment.nm_PaymentStatus__c == 'Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' || objPayment.nm_PaymentStatus__c == 'Payment Approved'){
                    if(objPayment.nm_PaymentType__c.contains('Admission') || objPayment.nm_PaymentType__c =='Installment' || objPayment.nm_PaymentType__c.contains('DownPayment') || objPayment.nm_PaymentType__c.contains('Subvention') || objPayment.nm_PaymentType__c.contains('Initial Payment') || objPayment.nm_PaymentType__c =='Additional Charge'){
                        admissionAmountReceived += objPayment.nm_Amount__c;
                        // to check if Loan Amount Disbursed by checking the payment type.
                        String modeOfPayment = objPayment.nm_ModeOfPayment__c;
                        if(String.isNotEmpty(modeOfPayment) && modeOfPayment.containsIgnoreCase('NEFT -')) {
                            loanAmountDisbursed = true;
                        }
                    }else if(objPayment.nm_PaymentType__c.contains('Late Fees')){
                        LateFeeAmountReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - ICChange - StudentKit')){
                        programChangeAndICChangeWithStudyKitFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - StudentKit')){
                        programChangeWithStudyKitFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ICChange - StudentKit')){
                        ICChangeWithStudyKitFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - ICChange')){
                        programChangeAndICChangeWithoutStudyKitFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ProgramChange')){
                        ProgramChangeFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('ICChange')){
                        ICChangeFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('StudentKit')){
                        StudyKitFeeReceived += objPayment.nm_Amount__c;
                    }else if(objPayment.nm_PaymentType__c.contains('Certificate') || objPayment.nm_PaymentType__c.contains('GST')){
                        CertificateSerivceTaxFeeReceived += objPayment.nm_Amount__c;
                    }else if (objPayment.nm_PaymentType__c.contains('Repeat Term Fee')){
                        RepeatTermFeeReceived += objPayment.nm_Amount__c;
                    }else if (objPayment.nm_PaymentType__c.contains('Career Service')){
                        CarrerServiceFeeReceived += objPayment.nm_Amount__c;
                    } else if(objPayment.nm_PaymentType__c.contains('Live Lectures')) {
                        LiveLectureFeeReceived += objPayment.nm_Amount__c;
                    } else if(objPayment.nm_PaymentType__c.contains('Coursera')) {
                        CourseraFeeReceived += objPayment.nm_Amount__c;
                    }
                }
            }
        }
        
        String opportunityLineItemsQuery = getQueryAllFieldSql('OpportunityLineItem',' OpportunityId =:opportunityId',null);
        List<OpportunityLineItem> lstOpportunityLineItem = DataBase.query(opportunityLineItemsQuery);
        if(lstOpportunityLineItem.size() > 0){
            for(OpportunityLineItem objLineItem : lstOpportunityLineItem){
                if(objLineItem.Product_Name__c.contains('Semester')){
                    semesterProductPrice += objLineItem.ActualSalePrice__c ;
                }else if(objLineItem.Product_Name__c.contains('Late Fee')){
                    LateFeeProductPrice += objLineItem.ActualSalePrice__c ;
                    system.debug('LateFeeProductPrice ------>'+LateFeeProductPrice );
                }else if(objLineItem.Product_Name__c.contains('IC Change')){
                    ICChangeProductPrice += objLineItem.ActualSalePrice__c;
                }else if(objLineItem.Product_Name__c.contains('Program Change')){
                    ProgramChangeProductPrice += objLineItem.ActualSalePrice__c;
                }else if(objLineItem.Product_Name__c.contains('Student Kits')){
                    StudyKitProductPrice += objLineItem.ActualSalePrice__c;
                }else if(objLineItem.Product_Name__c.contains('Certificate') || objLineItem.Product_Name__c.contains('GST')){
                    CertificateSerivceTaxProductPrice += objLineItem.ActualSalePrice__c;
                }else if (objLineItem.Product_Name__c.contains('Repeat Term')){
                    RepeatTermProductPrice += objLineItem.ActualSalePrice__c;
                }else if (objLineItem.Product_Name__c.contains('Career')){
                    CarrerServiceFee += objLineItem.ActualSalePrice__c;
                }else if(objLineItem.Product_Name__c.contains('Live Lectures')) {
                    LiveLecturePrice += objLineItem.ActualSalePrice__c;
                } else if(objLineItem.Product_Name__c.contains('Coursera')) {
                    CourseraFee += objLineItem.ActualSalePrice__c;
                }
            }

            ICChangeProductPrice -= ICChangeFeeReceived;
            ProgramChangeProductPrice -= ProgramChangeFeeReceived;
            StudyKitProductPrice -= StudyKitFeeReceived;
            CertificateSerivceTaxProductPrice -= CertificateSerivceTaxFeeReceived;
            RepeatTermProductPrice -= RepeatTermFeeReceived;
            CarrerServiceFee -= CarrerServiceFeeReceived;
            LiveLecturePrice -= LiveLectureFeeReceived;
            CourseraFee -= CourseraFeeReceived;

            System.debug('LiveLecturePrice ==>'+LiveLecturePrice);
            System.debug('LiveLectureFeeReceived ==>'+LiveLectureFeeReceived);
            LateFeeProductPrice = LateFeeProductPrice - LateFeeAmountReceived;
            System.debug('semesterProductPrice Before GST ==> ' + semesterProductPrice);
            // check if Only GST pending.
            if(CertificateSerivceTaxProductPrice > 0) {
                CertificateSerivceTaxProductPrice = checkGSTApplicable(CertificateSerivceTaxProductPrice, semesterProductPrice, admissionAmountReceived);
            }
            System.debug('semesterProductPrice After GST ==> ' + semesterProductPrice);
            semesterProductPrice  = semesterProductPrice  - admissionAmountReceived;
              system.debug('LateFeeProductPrice ------>'+LateFeeProductPrice);           
        }
        
        if(programChangeAndICChangeWithStudyKitFeeReceived > 0){
            programChangeAndICChangeWithStudyKitFeeReceived = programChangeAndICChangeWithStudyKitFeeReceived - (ProgramChangeProductPrice + ICChangeProductPrice + StudyKitProductPrice);
            ProgramChangeProductPrice = 0;
            ICChangeProductPrice = 0;
            StudyKitProductPrice = 0;
        }
        
        if(programChangeWithStudyKitFeeReceived > 0){
            programChangeWithStudyKitFeeReceived = programChangeWithStudyKitFeeReceived - (ProgramChangeProductPrice + StudyKitProductPrice);
            ProgramChangeProductPrice = 0;
            StudyKitProductPrice = 0;
        } else if (StudyKitProductPrice > 0 && ProgramChangeProductPrice > 0) {
            programChangeWithStudyKitFeeReceived = ProgramChangeProductPrice + StudyKitProductPrice;
            ProgramChangeProductPrice = 0;
            StudyKitProductPrice = 0;
        }


        
        if(ICChangeWithStudyKitFeeReceived > 0){
            ICChangeWithStudyKitFeeReceived = ICChangeWithStudyKitFeeReceived - (ICChangeProductPrice + StudyKitProductPrice);
            ICChangeProductPrice = 0;
            StudyKitProductPrice = 0;
        }
        
        if(programChangeAndICChangeWithoutStudyKitFeeReceived > 0){
            programChangeAndICChangeWithoutStudyKitFeeReceived = programChangeAndICChangeWithoutStudyKitFeeReceived - (ProgramChangeProductPrice + ICChangeProductPrice);
            ProgramChangeProductPrice = 0;
            ICChangeProductPrice = 0;
        }

        /**
        * To check if loan is in under approval stage,
        * then minus the product amount with loan Opted amount. 
        * Added by Bala 07-10-2019
        **/
        if(objOpportunity.Down_Payment_Made__c && loanOptedAmount > 0 && !objOpportunity.Loan_Application_Cancelled__c && 
            (!loanAmountDisbursed || (objOpportunity.Loan_Approved__c && objOpportunity.Loan_Type__c!='Zest')) ) {
            Decimal LiveLectureProductPrice = LiveLecturePrice;
            // to check if live lecture amount has been added to loan amount
            // * Added by Bala 03-19-2022
            if(loanOptedAmount > semesterProductPrice && LiveLecturePrice > 0) {
                LiveLecturePrice = (semesterProductPrice + LiveLecturePrice) - loanOptedAmount;
            }
            Decimal reminingPendingAmount = semesterProductPrice - loanOptedAmount;
            
            if(ProgramChangeProductPrice > 0 && LiveLectureProductPrice < 1) {
                if(loanOptedAmount == (semesterProductPrice+ProgramChangeProductPrice)) {
                    ProgramChangeProductPrice = 0;
                }
            }
            
            // to check if the reminingPendingAmount should be grater than zero or check if late fee pending then allow remainging amount zero.
            if(reminingPendingAmount > 0 || LateFeeProductPrice > 0) {
                semesterProductPrice = reminingPendingAmount;
            }
        }
        
        if(objOpportunity.ActualPendingAmount__c > 0){
            decimal balanceAmount = 0;
            if(semesterProductPrice > 0){
                balanceAmount = semesterProductPrice;
                if(balanceAmount > 0){
                    if(ProgramChangeProductPrice > 0) { 
                        balanceAmount = semesterProductPrice +ProgramChangeProductPrice;    
                    }
                    paymentFor = 'Additional Charge - Admission';
                    mapOfProductAndAmount.put(paymentFor,balanceAmount);
                }
            }
            System.debug('balance ---> ' + balanceAmount);
            if(balanceAmount <= 0){
                if(CertificateSerivceTaxProductPrice > 0){
                    balanceAmount = CertificateSerivceTaxProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - GST';
                        // paymentFor = 'Additional Charge - Certificate Service Tax';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(LateFeeProductPrice > 0){
                    balanceAmount = LateFeeProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Late Fees';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(programChangeAndICChangeWithStudyKitFeeReceived > 0){
                    balanceAmount = programChangeAndICChangeWithStudyKitFeeReceived ;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - ProgramChange - ICChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(programChangeAndICChangeWithoutStudyKitFeeReceived > 0){
                    balanceAmount = programChangeAndICChangeWithoutStudyKitFeeReceived ;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - ProgramChange - ICChange';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(programChangeWithStudyKitFeeReceived > 0){
                    balanceAmount = programChangeWithStudyKitFeeReceived;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - ProgramChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ICChangeWithStudyKitFeeReceived > 0){
                    balanceAmount = ICChangeWithStudyKitFeeReceived;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - ICChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ICChangeProductPrice > 0 && ProgramChangeProductPrice > 0 && StudyKitProductPrice > 0){
                    balanceAmount = ICChangeProductPrice+ProgramChangeProductPrice+StudyKitProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - ProgramChange - ICChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ICChangeProductPrice > 0 && ProgramChangeProductPrice > 0 ){
                    balanceAmount = ICChangeProductPrice+ProgramChangeProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - ProgramChange - ICChange';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ICChangeProductPrice > 0 && StudyKitProductPrice > 0){
                    balanceAmount = ICChangeProductPrice + StudyKitProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - ICChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ProgramChangeProductPrice > 0 && StudyKitProductPrice > 0){
                    balanceAmount = ProgramChangeProductPrice + StudyKitProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - ProgramChange - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ICChangeProductPrice >= 0){
                    balanceAmount = ICChangeProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Additional Charge - ICChange';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(ProgramChangeProductPrice > 0){
                    balanceAmount = ProgramChangeProductPrice;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - ProgramChange';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(StudyKitProductPrice > 0){
                    balanceAmount = StudyKitProductPrice;
                    if(balanceAmount >= 0){
                        paymentFor = 'Additional Charge - StudentKit';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(RepeatTermProductPrice > 0){
                    balanceAmount = RepeatTermProductPrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Repeat Term Fee';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(CarrerServiceFee > 0){
                    balanceAmount = CarrerServiceFee;
                    if(balanceAmount > 0){
                        paymentFor = 'Career Service';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(LiveLecturePrice > 0) {
                    balanceAmount = LiveLecturePrice;
                    if(balanceAmount > 0){
                        paymentFor = 'Live Lectures';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
                if(CourseraFee > 0) {
                    balanceAmount = CourseraFee;
                    if(balanceAmount > 0){
                        paymentFor = 'Coursera';
                        mapOfProductAndAmount.put(paymentFor,balanceAmount);
                    }
                }
            }

            System.debug('paymentFor--'+paymentFor+'----'+mapOfProductAndAmount.get(paymentFor));
        }
    }

    /**
    * @description To check if GST Applicable and added to Semester (Admission) Amount itself.
    * @author @BK | 08-20-2022 
    * @param gstAmount 
    * @param productPrice 
    * @return Decimal 
    **/
    public Decimal checkGSTApplicable(Decimal gstAmount, Decimal productPrice, Decimal amountReceived) {
        productPrice = (productPrice + gstAmount) - amountReceived;
        if(productPrice >= gstAmount) {
            return gstAmount;
        } 
        return 0;
    }
    
    public void showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae(){
        if(programCategory !=null && programCategory !='' && programType !=null && programType !=''){
            
            Opportunity objOpportunity = [select id,nm_Year__c,nm_Session__c,Is_Re_Registration_Payment__c,Processed__c,Account.nm_ChooseaProgram__c,nm_Category__c,AccountId,StageName,AdditionalAmountRecieved__c from Opportunity where id=:opportunityId];
            // allowed to Make Payment after Payment Window Closed for Some student and also show Payment Window Closure Message
            Set<String> setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>();
            String queryNMPaymentFormConfigurationString = '';
            if(objOpportunity != null) {
                String session = objOpportunity.nm_Session__c;
                String year = String.valueOf(objOpportunity.nm_Year__c);
                queryNMPaymentFormConfigurationString=getQueryAllFieldSql('NM_Payment_Form_Configuration__c' ,'Session__c=:session AND Current_Admission_Year__c=:year AND Program_Category__c =:programCategory  and Payment_Type__c =:programType and Program_Type__c=:programSpecialization',null);            
            } else {
                queryNMPaymentFormConfigurationString=getQueryAllFieldSql('NM_Payment_Form_Configuration__c' ,'Program_Category__c =:programCategory  and Payment_Type__c =:programType and Program_Type__c=:programSpecialization',null);
            }
            List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(queryNMPaymentFormConfigurationString);
            system.debug('lstFormConfiguration--->'+lstFormConfiguration );
            if(lstFormConfiguration.size() >0){
                NM_Payment_Form_Configuration__c objPaymentFormConfiguration = lstFormConfiguration[0];
                
               for (NM_Payment_Form_Configuration__c objFormConfigure: lstFormConfiguration)
                {
                    if(objFormConfigure.Session__c!=null && objFormConfigure.Session__c!='' && currentAdmissionSession.equalsIgnoreCase(objFormConfigure.Session__c)){

                        objPaymentFormConfiguration = objFormConfigure;
                        break;
                    }
                    else
                    {
                         objPaymentFormConfiguration = objFormConfigure;
                    }
                }
                
                if(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c !=null ){
                    setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate = new Set<String>(objPaymentFormConfiguration.Reg_No_Allowed_After_End_Date__c.split(','));
                }
                
                if(objPaymentFormConfiguration.Is_Late_Fee_Applicable__c && !objOpportunity.Processed__c){
                    // calculate Late Fee Amount Based upon category 
                    productHelper.addLateFeeCheck = true;
                    applicableLateFee = productHelper.CreateLateFeeProduct(objOpportunity,'Additional Charge').setScale(2);//create Late Fee Product and get Late Fee while making Additional Charge Payment in Late Fee Slab
                }
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
            
            }
            
            //show and hide Make payment button  on Page
            //getMapOfActiveCalender();
          /*  if(!mapOfActiveCalender.isEmpty()){
                String key = programType+'-'+semester+'-'+programCategory;
                if('Admission'.equalsIgnoreCase(programType) && !'Executive Programs'.equalsIgnoreCase(programCategory)){// for Admission payment do not check semester and Program Category
                    key = programType +'-null-null';
                }
                
                if(mapOfActiveCalender.containsKey(key)){
                    if(mapOfActiveCalender.get(key) != 'Calender Live' && setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.size() > 0){
                        if(!setOfStudentAndRegistrationNoAllowedToMakePaymentAfterEndDate.contains(studentNo)){
                            paymentWindowClosed = true;
                            paymentClouserMessage = mapOfActiveCalender.get(key);
                        }
                    }else if(mapOfActiveCalender.get(key) != 'Calender Live'){
                        paymentWindowClosed = true;
                        paymentClouserMessage = mapOfActiveCalender.get(key);
                    }
                }
            }*/
             
            
        }
        
        
        // show Center Address while Making DD payment by Student 
        String centerAddressQueryString = getQueryAllFieldSql('nm_Centers__c',' Nm_Active__c = true and id=:centerId',null);
        List<nm_Centers__c> lstOfActiveCenters = DataBase.query(centerAddressQueryString);
        if(lstOfActiveCenters.size() > 0){
            for(nm_Centers__c objCenter : lstOfActiveCenters){
               centerAddressForDD = objCenter.Name +' '+ objCenter.Address__c;
            }
        }
    }
    
    
    public void getMapOfActiveCalender(){
        if(currentAdmissionSession !=null && currentAdmissionSession !='' && currentAdmissionYear !=null && currentAdmissionYear > 0){
            String actvieCalenderQueryString = getQueryAllFieldSql('Calender__c',' Session_Start_Date__c <=:Today and Session__c =:currentAdmissionSession and Year__c =:currentAdmissionYear',null);
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
    
    public decimal getBalanceAmountToPay(decimal totalAmountPending,decimal amountReceived){
        return (totalAmountPending - amountReceived);
    }
    
    public void getMapOfProgramNameVsProgram(){
        String queryProgram = getQueryAllFieldSql('nm_Program__c',' nm_ProgramName__c !=null ',null);
        List<nm_Program__c> lstPrograms = DataBase.query(queryProgram);
        system.debug('lstPrograms -->'+lstPrograms);
        if(lstPrograms.size() > 0){
            for(nm_Program__c objProgram : lstPrograms){
                mapOfProgramNameVsProgram.put(objProgram.nm_ProgramName__c,objProgram);
            }
        }
    }

     /*---------------------------------------------Online Payment -----------------------------------------------------------------*/
    public pageReference MakeOnlinePayment(){
       System.debug('paymentFor ---'+paymentFor );
       if(paymentFor !=null && paymentFor !=''){
            //Creating payment tracking Id. 
            string strTranTrackid = studentNo+''+datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
            +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.floor(1000 + Math.random()*9000));
            System.debug('recordId--->'+recordId);
            strTranTrackid = strTranTrackid.right(30);
            System.debug('strTranTrackid--->'+strTranTrackid);
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.strAddress = studentAddress;
            objOnlinePayment.strCity = studentCity;
            objOnlinePayment.strPincode = studentPincode;
            objOnlinePayment.strName = studentName;
            objOnlinePayment.strEmailId = studentEmail;
            objOnlinePayment.strMobileNumber = studentMobileNo;
            objOnlinePayment.recordId = recordId;
            objOnlinePayment.opportunityId = opportunityId;
            objOnlinePayment.InstallmentAmount = 'NA';
            objOnlinePayment.strPaymentType = paymentFor;
            objOnlinePayment.InstallmentPayOpt = 'NA';
            objOnlinePayment.isCourseraOpted = isCourseraOpted;
            objOnlinePayment.studentNo = studentNo;
            system.debug('applicableLateFee-->'+applicableLateFee);
            if(paymentFor == 'Late Fees'){  
                objOnlinePayment.TranAmount = String.valueOf(applicableLateFee);
            }else{
                objOnlinePayment.TranAmount = String.valueOf(mapOfProductAndAmount.get(paymentFor) + applicableLateFee);
            }
            objOnlinePayment.postPaymentPage = postPaymentPage;
            objOnlinePayment.IsReregistartion = IsReregistartion;
            objOnlinePayment.depositAmount = 0;
            if(String.isNotBlank(courseList)){
                objOnlinePayment.courseList = courseList;
            }else{
                objOnlinePayment.courseList = null;
            }
            if(String.isNotBlank(liveLecType )){
                objOnlinePayment.liveLecType  = liveLecType ;
            }else{
                objOnlinePayment.liveLecType  = null;
            }
            System.debug('objPaymentFormConfiguration ==>'+objPaymentFormConfiguration);
            if(objPaymentFormConfiguration!=null) {
                objOnlinePayment.IsupGrad = objPaymentFormConfiguration.Use_different_payment_credentials__c;
                if(objOnlinePayment.IsupGrad) {
                    List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c,HDFC_SecretKey__c,HDFC_SALT__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];
                    PaymentConfigurationParameters__c objPCP = new PaymentConfigurationParameters__c();
                    if(lstPaymentConfigdetails.size() > 0) {
                        objPCP = lstPaymentConfigdetails[0];
                    }
                    objOnlinePayment.Paytm_MerchantKey = objPCP.Paytm_Website_Key__c;
                    objOnlinePayment.Paytm_IndustryId = objPCP.Paytm_IndustryId__c;
                    objOnlinePayment.Paytm_MID = objPCP.Paytm_MID__c;
                    objOnlinePayment.Paytm_EncryptionKey = objPCP.Paytm_EncryptionKey__c;
                    objOnlinePayment.HDFC_SecretKey = objPCP.HDFC_SecretKey__c;
                    objOnlinePayment.HDFC_SALT = objPCP.HDFC_SALT__c;
                }
            }
            
            // Call Payment GateWay Option Based Upon Selected Option
           return PaymentRequestCreator(objOnlinePayment,strTranTrackid); 
        }else{
            errMessages = 'Unable to get payment details.';
            strSecToShow = 'error';
            return null;
        }
    }
    
    /*-----------------------Payment Request Creator----------------------------------*/
    // Save Payment Reuest before Making Online Payment 
    // Based Upon selected Payment GateWay Option Create Secure Hash code for Online Payment
    public PageReference PaymentRequestCreator(nmOnlinePayment objOnlinePayment ,String strTranTrackid){
        System.debug('PaymentRequestCreator call ');
        PaymentRequestParams objParams = new PaymentRequestParams();
        objParams.strTranTrackid = strTranTrackid;
        objParams.strPaymentType = objOnlinePayment.strPaymentType;
        objParams.paymentGatewayVersion = null;
    
        if(paymentGateWayName =='HDFC GateWay'){
            Map<String,String> mapOfParameters =objOnlinePayment.createHDFCDeskRequest();
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.get('msg'), null);
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
        }else if(paymentGateWayName == 'BillDesk GateWay'){
            if (Label.BillDesk_GatewayVersion == 'v1') {
                String msg = objOnlinePayment.createtBillDeskRequest(); 
                objParams.msg = msg;
                // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, msg, null);
                SavePaymentBeforeResponse(objParams);
                
                PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
                pgURL.getParameters().put('msg', msg);
                pgURL.getParameters().put('type', paymentGateWayName);
                return pgURL;
            } else if(Label.BillDesk_GatewayVersion == 'v2') {

                // Bill Desk Gateway v2
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
                // String jsonResponse = JSON.serialize(mapOfParameters);
                // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('bdorderid'));
                List<Object> listOfLinks = (List<Object>)mapOfParameters.get('links');
                Map<String, Object> mapOfHeaders = (Map<String, Object>) listOfLinks[1];
                Map<String, Object> mapOfAuth = (Map<String, Object>) mapOfHeaders.get('headers');
                PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
                pgURL.getParameters().put('type', 'BillDesk GateWay v2');
                pgURL.getParameters().put('merchantId', (String)mapOfParameters.get('mercid'));
                pgURL.getParameters().put('bdOrderId', (String)mapOfParameters.get('bdorderid'));
                pgURL.getParameters().put('ru', (String)mapOfParameters.get('ru'));
                pgURL.getParameters().put('authToken', (String)mapOfAuth.get('authorization'));
                pgURL.getParameters().put('TranTrackid', (String)mapOfParameters.get('orderid'));
                pgURL.getParameters().put('baseUrl', BilldeskV2.Base_Url__c);
                return pgURL;
            } else {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            

        }
        else if(paymentGateWayName == 'Razorpay GateWay') {
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
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, null, (String)mapOfParameters.get('id'));
            PageReference pgURL = new PageReference('/apex/RazorPayGateway');
            List<String> lstKey = new List<String>{'amount','amount_paid','amount_due','attempts','created_at'};
            for (String key : mapOfParameters.keySet()){
                String mapValue = null;
                if(lstKey.contains(key)) {
                    mapValue = String.valueOf(mapOfParameters.get(key));
                } else if(key == 'notes') {
                    Map<String,Object> mapOfNotes = (Map<String,Object>)mapOfParameters.get(key);
                    for (String NoteKey : mapOfNotes.keySet()){ 
                        pgURL.getParameters().put(NoteKey, (String)mapOfNotes.get(NoteKey));
                    }
                    mapValue = JSON.serialize(mapOfNotes);
                } else {
                    mapValue = (String)mapOfParameters.get(key);
                }
                pgURL.getParameters().put(key, mapValue);
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            pgURL.getParameters().put('Name', studentName);
            pgURL.getParameters().put('email', studentEmail);
            pgURL.getParameters().put('contact', studentMobileNo);
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        } else if(paymentGateWayName == 'ICICI GateWay') {
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
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('order_token'));
            // objParams.msg = JSON.serialize(mapOfParameters);
            // objParams.orderId = (String)mapOfParameters.get('order_token');
            // objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            // SavePaymentBeforeResponse(objParams);

            String paymentUrl = (String)mapOfParameters.get('payment_link');
            PageReference pgURL = new PageReference(paymentUrl);
            return pgURL;
        }
        /*on hold
        else if(paymentGateWayName =='PayPal GateWay') {
            Map<String,String> mapOfParameters = objOnlinePayment.createPayPalRequest();
            SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.remove('JSONREQ'));
            PageReference pgURL = new PageReference(mapOfParameters.get('ReturnURL'));
            return pgURL;
        }*/
        // else if(paymentGateWayName == 'CCAvenue GateWay') {
        //     Map<String,String> mapOfParameters = objOnlinePayment.createCCAvenueOrderRequest();
        //     System.debug('mapOfParameters ==>'+mapOfParameters);
        //     objParams.msg = mapOfParameters.remove('msg');
        //     objParams.paymentCurrency = 'USD';
        //     objParams.udf1 = mapOfParameters.remove('udf1');
        //     objParams.udf2 = mapOfParameters.remove('udf2');
        //     // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, mapOfParameters.remove('msg'), null, 'USD', mapOfParameters.get('merchant_param1'), mapOfParameters.get('merchant_param2'));
        //     System.debug('objParams 1 ==>'+objParams);
        //     SavePaymentBeforeResponse(objParams);
        //     PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
        //     for (String key : mapOfParameters.keySet()){
        //         pgURL.getParameters().put(key, mapOfParameters.get(key));
        //         System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
        //     }
        //     pgURL.getParameters().put('type', paymentGateWayName);
        //     return pgURL;
        // } 
        else{
            // For Paytm Gateway
            Map<String,String> mapOfParameters = objOnlinePayment.createPayTMRequest();
            objParams.msg = mapOfParameters.remove('msg');
            SavePaymentBeforeResponse(objParams);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.remove('msg'), null);
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
    // public void SavePaymentBeforeResponse(String strPaymentType ,String strTranTrackid ,String msg, String orderId){
    public void SavePaymentBeforeResponse(PaymentRequestParams objParams){
        // System.debug('objParams 2 ==>'+objParams);
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        
        
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c(); 
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';   
        objPayment.nm_Lead__c = IsReregistartion?null:recordId; 
        objPayment.nm_OpportunityNew__c = IsReregistartion ? opportunityId:null;    
        objPayment.nm_ModeOfPayment__c = 'Online';  
        objPayment.nm_TransactionDate__c = Date.today();    
        objPayment.nm_PaymentGatewayName__c = paymentGateWayName;   
        objPayment.nm_Merchant_Track_Id__c = objParams.strTranTrackid;    
        objPayment.Gateway_Detailed_Request__c = objParams.msg;   
        objPayment.Additional_param1__c = objParams.udf1;
        objPayment.Additional_param2__c = objParams.udf2;
        objPayment.Additional_param3__c = objParams.udf3;
        objPayment.Payment_Gateway_Version__c = objParams.paymentGatewayVersion;
        if(String.isNotBlank(objParams.orderId)) {
            objPayment.OrderId__c = objParams.orderId;
        }
        if(String.isNotBlank(paymentFor)){

            if(paymentFor != 'Late Fees' && !paymentFor.contains('Application And')){  
              lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, paymentFor, mapOfProductAndAmount.get(paymentFor),mapOfProductAndAmount.get(paymentFor), paymentFor ,applicableLateFee) );
            } else if (paymentFor != 'Late Fees' && paymentFor.contains('Application And')) {
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Application Fee', mapOfProductAndAmount.get('Application Fee'),mapOfProductAndAmount.get(paymentFor), 'Application Fee' ,applicableLateFee) );
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, paymentFor.substringAfter('Application And '), mapOfProductAndAmount.get(paymentFor.substringAfter('Application And ')).setScale(2),mapOfProductAndAmount.get(paymentFor).setScale(2), paymentFor.substringAfter('Application And '),applicableLateFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Late Fees', applicableLateFee, mapOfProductAndAmount.get(paymentFor) , paymentFor ,applicableLateFee) );
            }
        }
        System.debug('lstPaymentToInsert --> ' + lstPaymentToInsert);
        System.debug('paymentFor--'+paymentFor+'------'+mapOfProductAndAmount.get(paymentFor)+'--validityExtensionId---'+validityExtensionId);
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
    public nm_Payment_Initiated__c CreatePaymentInitiatedRecord( nm_Payment_Initiated__c objPayment, String PaymentType, decimal Amount , decimal paymentForAmount, String feesType,decimal LateFeeAmount){
        nm_Payment_Initiated__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        if(PaymentType == 'Late Fees' && feesType!='Live Lectures'){
            objPay.nm_ActualPaymentAmmount__c = LateFeeAmount;
        }else{
            objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount;
        }
        objPay.nm_Amount__c = Amount;
        objPay.nm_Fee_Type__c = feesType;
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = opportunityId;
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
        }else if(validityExtensionId !='' && validityExtensionId !=null && validityExtensionId !='NA'){
            objPay.Validity_Extension__c = validityExtensionId;
            objPay.nm_Lead__c = null;
        }
        else if(CareerServiceRecordId !='' && CareerServiceRecordId !=null && CareerServiceRecordId !='NA'){
            objPay.CareerServiceProgram__c = CareerServiceRecordId;
            objPay.nm_Lead__c = null;
        }else if(webinarRegid !='' && webinarRegid !=null && webinarRegid !='NA'){
            objPay.Seminar__c = webinarRegid;
            objPay.nm_Lead__c = null;
        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            system.debug('AEPId -->' + AEPId);
            objPay.AEP__c = AEPId;
            objPay.nm_Lead__c = null;
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            System.debug('AEPISPId -->'+AEPISPId);
            objPay.AEP_site_inspection__c = AEPISPId;
            objPay.nm_Lead__c = null;
        
        
        }
        
        return objPay;
    }
    
    /*-------------- Creating Payment Records after Payment --------------*/
    // This Method used to Handle Payment Response After Making Online Payment
    // Creating Payment Record with status of Payment made if transition is successfully 
    // Creating Payment Record with status of Transaction Failed if transition is failed

    //
    // public String MakePaymentAfterResponse (
    //     String strResTranId, 
    //     String paymentTransactionMode,
    //     string strPaymentTrackId,
    //     String strPaymentId, 
    //     String strResResult, 
    //     String strErrorText,
    //     String strErrorCode,
    //     String strPaymentType,
    //     String detailedGatewayResponse,//Added by Sanket 13-Oct-2015
    //     //String PaymentSelectionOption // it can be Creadit card,Debit card ,Net Banking
    //     String additionalResult, // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
    //     // String currencyOfPayment,
    //     Decimal feeCharges,
    //     Decimal tax
    // ){
    
    public String MakePaymentAfterResponse (PaymentHandler.PaymentResponseWrapper objResponse){
        String strResTranId = objResponse.transactionId;
        String paymentTransactionMode = objResponse.modeOfPayment;
        string strPaymentTrackId = objResponse.merchantId;
        String strPaymentId = objResponse.BankTXNId;
        String strResResult = objResponse.status;
        String strErrorText = objResponse.responseDescription;
        String strErrorCode = objResponse.responseCode;
        String strPaymentType =objResponse.udf1;
        String detailedGatewayResponse = objResponse.status; //Added by Sanket 13-Oct-2015
        //String PaymentSelectionOption // it can be Creadit card,Debit card ,Net Banking
        String additionalResult = objResponse.udf2; // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
        // String currencyOfPayment,
        Decimal feeCharges = objResponse.feeChrages;
        Decimal tax = objResponse.tax;
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
        isCourseraOpted = String.isNotBlank(additionalResult.split('_')[3]) ? Boolean.valueOf(additionalResult.split('_')[3]) : false;
        Date admissionTranscationDate = null;
        system.debug('-----------strPaymentTrackId------------'+strPaymentTrackId);
        system.debug('AEPId -->' + AEPId);
        
        lstPaymentToUpdate = [Select Id, nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c,nm_Amount__c,nm_ActualPaymentAmmount__c, nm_Lead__c,nm_PaymentGatewayName__c , nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: strPaymentTrackId];
        
        system.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
        for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate)
        {
            objpay.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
            objpay.nm_TransactionID__c = strResTranId;
            objpay.payment_Transaction_Mode__c = paymentTransactionMode;
            objpay.Online_Payment_Id__c = strPaymentId;
            objpay.nm_PaymentGatewayResponse__c = strResResult;
            objpay.Online_Response_Error__c = strErrorText;
            objpay.nm_Error_Code__c=strErrorCode;
            objpay.Gateway_Detailed_Response__c = detailedGatewayResponse;//Added by Sanket 13-Oct-2015
            if('Admission'.equalsIgnoreCase(objpay.nm_PaymentType__c)) // checking Admission Trans Date for Inserting Late Fee Product
            {
                admissionTranscationDate = objpay.nm_TransactionDate__c;
            }
        }
        
        if(lstPaymentToUpdate.size() > 0 )
        {
            update lstPaymentToUpdate;
        }
        
        list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
        nm_Payment__c objPayment = new nm_Payment__c();
        objPayment.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
        if(opportunityId !='' && opportunityId !='NA' && opportunityId !=null){
            objPayment.nm_OpportunityNew__c = opportunityId;
        }else if(validityExtensionId !='' && validityExtensionId !=null && validityExtensionId !='NA'){
            objPayment.Validity_Extension__c = validityExtensionId;
        }
        else if(CareerServiceRecordId !='' && CareerServiceRecordId !=null && CareerServiceRecordId !='NA'){
            objPayment.CareerServiceProgram__c = CareerServiceRecordId;
        }else if(webinarRegid !='' && webinarRegid !=null && webinarRegid !='NA'){
            objPayment.Seminar__c = webinarRegid;
            //objPayment.nm_Lead__c = null;
        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPayment.AEP__c = AEPId;
            system.debug('AEPId -->' + AEPId);
            
            //objPayment.nm_Lead__c = null;
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            System.debug('AEPISPId -->'+AEPISPId);
            objPayment.AEP_site_inspection__c = AEPISPId;
        }
       
        
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c =lstPaymentToUpdate.size()>0 ? lstPaymentToUpdate[0].nm_TransactionDate__c : Date.today(); // making Payment Initation Created Date As Transction Date for Payment Record
        objPayment.nm_TransactionID__c = strResTranId;
        objPayment.payment_Transaction_Mode__c = paymentTransactionMode;
        objPayment.nm_PaymentGatewayName__c =lstPaymentToUpdate[0].nm_PaymentGatewayName__c ;
        objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
        objPayment.Online_Payment_Id__c = strPaymentId;
        objPayment.nm_PaymentGatewayResponse__c = strResResult;
        objPayment.Online_Response_Error__c = strErrorText;
        objPayment.nm_Error_Code__c=strErrorCode;
        objPayment.Fee_Charges__c = feeCharges;
        objPayment.Tax__c = tax;
        objPayment.Payment_Gateway_Version__c = objResponse.gatewayVersion;
        objPayment.Transaction_DateTime__c = objResponse.transactionDateTime;
        // if(currencyOfPayment == 'USD') {
        //     objPayment.CurrencyIsoCode = currencyOfPayment;
        // }
        paymentFor = strPaymentType.split('_')[0];
        System.debug('Product Keys -->'+mapOfProductAndAmount.keySet());
        system.debug('mapOfProductAndAmount.get(paymentFor)--->'+mapOfProductAndAmount.get(paymentFor));
        Decimal discountedPrice = 0.0;
        if(String.isNotBlank(paymentFor) && (paymentFor == 'UG And PG License Fee' || paymentFor == 'MS License Fee')){
            List<nm_Payment__c> lstPay = [SELECT Id,nm_Amount__c,nm_PaymentType__c,nm_PaymentStatus__c from nm_Payment__c Where AEP_site_inspection__c=:AEPISPId and (nm_PaymentType__c = 'MS License Fee' or nm_PaymentType__c = 'UG And PG License Fee') and (nm_PaymentStatus__c = 'Payment Approved' or nm_PaymentStatus__c = 'Payment Made')];
            if(lstPay.size()>0){
                discountedPrice = mapOfProductAndAmount.get(paymentFor) - (mapOfProductAndAmount.get(paymentFor) * 0.2);
            }
        } 

        if(String.isNotBlank(paymentFor)){
            System.debug('paymentFor '+paymentFor);
            if(paymentFor.contains('Application And')) {
                mapOfProductAndAmount.put(paymentFor, (mapOfProductAndAmount.get('Application Fee') + mapOfProductAndAmount.get(paymentFor.substringAfter('Application And '))).setScale(2));
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Application Fee', mapOfProductAndAmount.get('Application Fee'),mapOfProductAndAmount.get(paymentFor), 'Application Fee' ,paymentFor ,applicableLateFee) );
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, paymentFor.substringAfter('Application And '), mapOfProductAndAmount.get(paymentFor.substringAfter('Application And ')).setScale(2),mapOfProductAndAmount.get(paymentFor), paymentFor.substringAfter('Application And ') ,paymentFor ,applicableLateFee) );
            } else if(paymentFor != 'Late Fees'){
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, paymentFor, mapOfProductAndAmount.get(paymentFor),mapOfProductAndAmount.get(paymentFor), paymentFor ,paymentFor ,applicableLateFee) );
            }
            if(applicableLateFee > 0){
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Late Fees', applicableLateFee, mapOfProductAndAmount.get(paymentFor) ,paymentFor , paymentFor ,applicableLateFee) );
            }
        }
        
         String firstPaymentRecordId = '';
        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                //avoid multiple payment records being created for same merchant ID, for Browser back button press 
                firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
            }
            return firstPaymentRecordId;
        }catch(Exception e){
            return 'Failed to insert data in system :: Sumit ::' + string.valueof(e); 
        }
    }
    
    // update Payment records based upon Merchant Ref No
    public String upsertPaymentRecordsBasedOnMerchantNumber(list<nm_Payment__c> lstPaymentToInsert){
        System.debug('Method Of upsertPaymentRecordsBasedOnMerchantNumber called --->'+lstPaymentToInsert);
        list<nm_Payment__c> insertList = new List<nm_Payment__c>();
        list<nm_Payment__c> updateList = new List<nm_Payment__c>();
        boolean AEPlicensePayment = false ;
        String firstPaymentRecordId = '';
        Boolean AEPMerchendisePayment = false;
        
        Set<String> merchantRefNumberIds = new Set<String>();
        for(nm_Payment__c payment : lstPaymentToInsert){
            merchantRefNumberIds.add(payment.nm_Merchant_Track_Id__c);
            System.debug('Payment data '+payment.nm_PaymentType__c +' '+payment.nm_PaymentStatus__c +' '+ payment.AEP__c +' '+Cpjson);
            if(payment.nm_PaymentType__c =='Community Licenses Fee' && payment.nm_PaymentStatus__c =='Payment Made' && String.isNotBlank(payment.AEP__c) && String.isNotBlank(Cpjson))
            {   
                AEPlicensePayment =true;
                System.debug('AEPlicensePayment '+AEPlicensePayment);
                //insertContactsandSendMail(Cpjson);
            }   
            if(payment.nm_PaymentStatus__c == 'Payment Made' && String.isNotBlank(payment.AEP__c) && payment.nm_PaymentType__c =='Tshirt') {
                AEPMerchendisePayment = true;
            }
            
        }
        
        Map<String, Id> merchantIdRecordIdMap = new Map<String, ID>();
        list<nm_Payment__c> existingPayments = [Select id, nm_Merchant_Track_Id__c, nm_TransactionID__c from nm_Payment__c where nm_Merchant_Track_Id__c in :merchantRefNumberIds];
        if(existingPayments != null ){
            for(nm_Payment__c payment : existingPayments){
                merchantIdRecordIdMap.put(payment.nm_Merchant_Track_Id__c, payment.ID);
            }
        }
        
        for(nm_Payment__c payment : lstPaymentToInsert){
            String key = payment.nm_Merchant_Track_Id__c;
            if(merchantIdRecordIdMap.containsKey(key)){
                //Payment Record already exists with given Merchant Track Id  
                ID id = merchantIdRecordIdMap.get(key);
                payment.ID = id;
                updateList.add(payment);
            }else{
                //New Record
                insertList.add(payment);
            }
        }
        
        if(insertList.size() > 0 ){
            System.debug('Adding new Payment record');
            insert insertList;
            system.debug('insertList --> ' + insertList);
            firstPaymentRecordId = insertList[0].Id;
            if(AEPlicensePayment)
            {
                insertContactsandSendMail(Cpjson,firstPaymentRecordId);

            }
            if(AEPMerchendisePayment) {
                system.debug('firstPaymentRecordId ---> ' + firstPaymentRecordId);
                AEPMerchandiseController.SendMailForAEPMerchandise(firstPaymentRecordId);

            }
        }
        
        if(updateList.size() > 0 ){
            System.debug('Updating existing Payment record');
            update updateList;
            firstPaymentRecordId = updateList[0].Id;
        }
        
        return firstPaymentRecordId;
    }
    
     // Create Online Pyament Record in system
    public nm_Payment__c CreatePaymentRecord( nm_Payment__c objPayment, String PaymentType, decimal Amount, decimal paymentForAmount,String feesType ,String InstallmentRef, decimal LateFeeAmount){
        nm_Payment__c objPay =  new nm_Payment__c();
        System.debug('objPayment  ->'+objPayment);
        objPay = objPayment.clone();
        if(PaymentType == 'Tshirt') {
           objPay.Merchendise__c = clearOrderDetailsFromCenter(AEPId);
        }
        LateFeeAmount = LateFeeAmount!=null ? LateFeeAmount : 0;
        paymentForAmount = paymentForAmount!=null ? paymentForAmount : 0;
        objPay.nm_PaymentType__c = PaymentType;
        system.debug('paymentForAmount -->'+paymentForAmount +'LateFeeAmount--->'+LateFeeAmount);
        if(PaymentType == 'Late Fees'){
            objPay.nm_ActualPaymentAmmount__c = LateFeeAmount;
        }else{
            objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount;
        }
        //system.debug('paymentForAmount -->'+paymentForAmount +'LateFeeAmount--->'+LateFeeAmount);
        objPay.nm_Amount__c = Amount;
        objPay.nm_Installment_Payment_Ref__c = InstallmentRef;
        objPay.nm_Fee_Type__c = PaymentType;
   
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            objPay.nm_Lead__c = null;
            if(objPay.nm_PaymentStatus__c == 'Payment Made' && isCourseraOpted){
                updateOpportunityFeesType(opportunityId);
            }
        }else if(validityExtensionId !='' && validityExtensionId !=null && validityExtensionId !='NA'){
            objPay.Validity_Extension__c = validityExtensionId ;
        }
        else if(CareerServiceRecordId !='' && CareerServiceRecordId !=null && CareerServiceRecordId !='NA'){
            objPay.CareerServiceProgram__c = CareerServiceRecordId;
        }else if(webinarRegid !='' && webinarRegid !=null && webinarRegid !='NA'){
            objPay.Seminar__c = webinarRegid;      
        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPay.AEP__c = AEPId;

        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPay.AEP__c = AEPId;
           
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            objPay.AEP_site_inspection__c = AEPISPId;    
        }
        
        if((PaymentType =='Additional Charge' || PaymentType =='Late Fees') && objPay.nm_PaymentStatus__c =='Payment Made' && objPay.nm_OpportunityNew__c !=null)
        {
          list<nm_Payment__c> lstPaymnet = [select nm_Amount__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Account.Phone,nm_OpportunityNew__r.Account.PersonEmail from nm_Payment__c where ((nm_PaymentStatus__c='Pending Extra Fees' and nm_PaymentType__c = 'Additional Charge') or (nm_PaymentStatus__c='pending late fees' and nm_PaymentType__c ='Late Fees')) and nm_OpportunityNew__c=:objPay.nm_OpportunityNew__c];
          if(lstPaymnet.size()>0)
          {
            delete lstPaymnet;
          }
        }

        return objPay;
    }

    public void updateOpportunityFeesType(String updateRecordId){
        Opportunity objOpportunity = new Opportunity(id=updateRecordId);
        objOpportunity.Coursera__c = true;
        update objOpportunity;
        System.debug('objOpportunity----'+objOpportunity);
    }

    public void insertContactsandSendMail(String userListJson,String paymentId){

        List<Counsellor_Profile__c> lstOfCp = new List<Counsellor_Profile__c>();
        List<Contact> lstContact = new List<Contact>();
        
        Map<String,Object> mapOfCps = (Map<String,Object>)Json.deserializeuntyped(userListJson);
        System.debug('mapOfCps '+mapOfCps);
        Set <String> cpIdSet = new Set<String>();
        if(mapOfCps != null){
           cpIdSet = mapOfCps.keySet();
        }
        System.debug('cpIdSet '+cpIdSet);
        if(cpIdSet.size() > 0){
            lstOfCp = [Select Id,First_Name__c,Last_Name__c,Email__c,MobilePhone__c ,BusinessAccount__c from Counsellor_Profile__c where id in: cpIdSet];
        }
        System.debug('lstOfCp '+lstOfCp);
        if(lstOfCp.size() > 0){
            for(Counsellor_Profile__c cp : lstOfCp){
               
                Contact c = new Contact();
                c.FirstName = cp.First_Name__c;
                c.LastName = cp.Last_Name__c;
                c.AccountId = cp.BusinessAccount__c;
                c.Email = String.valueOf(cp.Email__c);
                c.Phone = String.valueOf(cp.MobilePhone__c);
                c.LeadSource = 'Web';
                c.Counselor_Profile__c = cp.Id;
                c.User_Role__c = String.valueOf(mapOfCps.get(cp.Id));

                lstContact.add(c);
            }
        }
        System.debug('lstContact '+lstContact);
        if(lstContact.size()>0)
        {   
            try{
                insert lstContact;
            }catch(DMLException e){
                System.debug('Error '+e.getMessage());
            }
            
            String paymentReceipt = System.Label.Site_Url +'nmRegistrationThankYou?PaymentId='+paymentId;
            Decimal timePeriod = purchaseLicenseForAEPController.getNoOfMonths();
           
            if(objtCenter != null){

                purchaseLicenseForAEPController.sendNotificationEmail(objtCenter.Center_Name__c,String.valueOf(objtCenter.TotalLicensesRequired__c),String.valueOf(objtCenter.amount_For_new_License__c),String.valueOf(timePeriod),lstContact,paymentReceipt,'online');
            }

        }
    }
    
     /*-----------------------------------------------------------------------DD Payment ------------------------------------------------*/
    public pageReference  SaveDD(){
        System.debug('paymentFor---'+paymentFor);
        list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();  
        if(objPayment.nm_DemandDraftNumber__c != null && objPayment.nm_DemandDraftDate__c != null && objPayment.nm_NameoftheBank__c != null && objPayment.nm_BankLocation__c != null && objPayment.nm_DispatchDate__c != null){
            try{
                lstPaymentToInsert.add( CreateDDRecord( objPayment, paymentFor, mapOfProductAndAmount.get(paymentFor),mapOfProductAndAmount.get(paymentFor), paymentFor ,applicableLateFee) );
            
                if(applicableLateFee > 0){
                    lstPaymentToInsert.add( CreateDDRecord ( objPayment, 'Late Fees', applicableLateFee, mapOfProductAndAmount.get(paymentFor) , paymentFor ,applicableLateFee) );
                }
                
                try{
                    if(lstPaymentToInsert.size()>0){
                        insert lstPaymentToInsert;
                    }
                }catch(Exception e){
                    System.debug('Error In Insert DD--->'+e.getMessage());
                }
                
                return new pageReference(Label.Site_Url+ 'nmRegistrationThankYou?id=' +lstPaymentToInsert[0].id); 
            }catch(Exception e){
                strSecToShow ='error';
                errMessages = e.getMessage();
                return null;
            }
        }else{
            strSecToShow ='error';
            errMessages = 'Please fill all the DD details to proceed';
            return null;
        }  
    }
    
    public nm_Payment__c CreateDDRecord( nm_Payment__c objPayment , String PaymentType, decimal Amount , decimal paymentForAmount, String feesType,decimal LateFeeAmount){
        nm_Payment__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount + LateFeeAmount;
        objPay.nm_Amount__c = Amount;
        objPay.nm_PaymentStatus__c = 'Payment Made';
        objPay.nm_Installment_Payment_Ref__c = PaymentType;
        
        
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = opportunityId;
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
        }else if(validityExtensionId !='' && validityExtensionId !=null && validityExtensionId !='NA'){
            objPay.Validity_Extension__c = validityExtensionId;
        }
        else if(CareerServiceRecordId !='' && CareerServiceRecordId !=null && CareerServiceRecordId !='NA'){
            objPay.CareerServiceProgram__c = CareerServiceRecordId;
        }else if(webinarRegid !='' && webinarRegid !=null && webinarRegid !='NA'){
            objPay.Seminar__c = webinarRegid;            
        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPay.AEP__c = AEPId;
            
        }
        
        if((PaymentType =='Additional Charge' || PaymentType =='Late Fees') && objPay.nm_PaymentStatus__c =='Payment Made' && objPay.nm_OpportunityNew__c !=null)
        {
          list<nm_Payment__c> lstPaymnet = [select nm_Amount__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Account.Phone,nm_OpportunityNew__r.Account.PersonEmail from nm_Payment__c where ((nm_PaymentStatus__c='Pending Extra Fees' and nm_PaymentType__c = 'Additional Charge') or (nm_PaymentStatus__c='pending late fees' and nm_PaymentType__c ='Late Fees')) and nm_OpportunityNew__c=:objPay.nm_OpportunityNew__c];
          if(lstPaymnet.size()>0)
          {
            delete lstPaymnet;
          }
        }
        
        return objPay;
    }

    public String clearOrderDetailsFromCenter(String centerId) {
        if(String.isNotBlank(centerId)) {
            nm_Centers__c objCenter = [SELECT Id, AEP_Merchen__c FROM nm_Centers__c WHERE Id=:centerId LIMIT 1 ];
            if(objCenter != null) {
                List<String> lstOrder = String.isNotBlank(objCenter.AEP_Merchen__c) ? objCenter.AEP_Merchen__c.split('\n') : new List<String>();            
                String orderString = lstOrder.size() > 0 ? lstOrder[lstOrder.size() -1] : '';
                nm_Centers__c udCenter = new nm_Centers__c();
                udCenter.Id = objCenter.Id;
                udCenter.AEP_Merchen__c = '';
                update udCenter;
                system.debug('orderString ---> ' + orderString);
                return orderString;
            }
        }
        return '';
        
    }

    public decimal getValExtOf1Ext(String TagPriceBookId, String programId,String programCategory, Boolean IsDefence, String noOfValExt) {
        decimal extensionFee = 0;
        String priceBookEntryQuery = getQueryAllFieldSql('PriceBookEntry',' product2.nm_Program__c=:programId and product2.isActive=true and Pricebook2.id=:TagPriceBookId and product2.nm_Semester__c!=null',' product2.Name, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');
        List<PriceBookEntry> lstPriceBookEntry = DataBase.query(priceBookEntryQuery);
        if(lstPriceBookEntry.size() > 0){
           extensionFee = 0.5*(lstPriceBookEntry[0].UnitPrice); // calculate extension fee amount 50% of Admission fee
            if('Certificate Programs'.equalsIgnoreCase(programCategory) || 'Executive Programs'.equalsIgnoreCase(programCategory)){
                extensionFee += extensionFee * Decimal.valueOf(Label.Service_Tax);
                extensionFee = extensionFee.setScale(2);
            }else{
                extensionFee = IsDefence ? (0.8*extensionFee).setScale(2) :extensionFee.setScale(2);
            }
        }
        return String.isNotBlank(noOfValExt) ? Integer.valueOf(noOfValExt) * extensionFee : extensionFee;
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
            this.udf2 = null;
            this.udf3 = null;
            this.paymentGatewayVersion = null;
        }
    }
    
    
    // method not in use
    public String MakeAdditionalChargePaymentAfterResponse(
        string strResTranId, 
        string strPaymentTrackId,
        String strPaymentId, 
        String strResResult, 
        String strErrorText,
        String strErrorCode,
        String strPaymentType,
        String detailedGatewayResponse,
        String detailedGatewayResponse1,
        String detailedGatewayResponse2
    ){
        return null;
    }
}