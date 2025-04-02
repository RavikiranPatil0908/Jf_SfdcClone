/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-20-2021   @BK   Initial Version
**/
public without sharing class AdditionalLiveLectures {
    
    public String recordId {get;set;}
    public String studentNo {get;set;}
    public Date dateOfBirth {get;set;}
    public Account objAccount {get;set;}
    public Opportunity objCurrentOpportunity {get;set;}
    public OpportunityLineItem objLiveLectureLineItem {get;set;}
    public OpportunityLineItem objBacklogLineItem {get;set;}
    public String message {get;set;}
    public String strSecToShow {get;set;}
    public String returnUrl {get;set;}
    public String liveLecType {get;set;}
    public String courseList {get;set;}
    public String backlogList {get;set;}
    public String OldCourseList {get;set;}
    public String OldBacklogList {get;set;}
    public Boolean lectureCantBeSwitch {get;set;}
    public String courseListWithBacklogList {get;set;}
    public String paymentGateWayName {get;set;}
    public String opportunityId {get;set;}
    public String feeType {get;set;}
    public Decimal feePaidAmount {get;set;}
    public Decimal feePaidBacklogAmount {get;set;}
    public String paymentFor {get;set;}
    public String sessionMonth {get;set;}
    public String sessionYear {get;set;}
    public Calender__c objCalendar {get;set;}
    public String currentSemester {get;set;} 
    public String currentSemesterWithPlural {get;set;} 
    public Boolean isStudentApplicableForLiveLectureThroughRegistrationNo {get;set;}

    public ProductHelper productHelper;
    public Set<String> setOfApplicablePaymentOptionForStudent {get;set;}// Map for Showing Payment Option
    public Map<String,PriceBookEntry> mapOfPricebook {get;set;}
    public Map<String,Decimal> mapOfProductAndAmount {get;set;}
    public Map<String,Map<Id,nm_Courses__c>> mapOfCourseKeyVsCourseObj {get;set;}
    public Map<Id,nm_Courses__c> mapOfCourseKeyVsCurrentCourseObj {get;set;}
    public Map<String , Object> mapOfBacklogCourseIdVsBacklogObject {get; set;}
    public integer sizeOfMapOfBacklogCourseIdVsBacklogObject {get; set;}
    public String jsonMapOfProductAndAmount {get;set;}
    public String jsonMapOfLectureTypeAndSubjects {get;set;}
    public String jsonMapOfsetOfApplicablePaymentOptionForStudent {get;set;}
    public String PostPaymentVFPage {get;set;}
    public Decimal applicableLiveLectureFee {get;set;}
    public Decimal applicableForLiveLectureFee {get;set;}
    public Decimal applicableForOnlyBacklog {get;set;}
    public Decimal applicableForBacklog {get;set;}
    public NM_Payment_Form_Configuration__c objPaymentFormConfiguration {get;set;}
    
    public AdditionalLiveLectures() {
        dateOfBirth = null;
        if(ApexPages.currentPage() != null) {
            studentNo = ApexPages.currentPage().getParameters().get('id');
            dateOfBirth = ApexPages.currentPage().getParameters().get('dob')!=null ? Date.parse(ApexPages.currentPage().getParameters().get('dob')) : null;
        }
        objAccount = new Account();
        objCurrentOpportunity = new Opportunity();
        objLiveLectureLineItem = null;
        objBacklogLineItem = null;
        message = '';
        strSecToShow = '';
        returnUrl = '';
        liveLecType='';
        courseList='';
        backlogList='';
        OldCourseList = '';
        OldBacklogList = '';
        lectureCantBeSwitch = false;
        courseListWithBacklogList= '';
        paymentGateWayName = '';
        opportunityId = '';
        recordId = '';
        feeType = '';
        paymentFor='';
        feePaidAmount = 0;
        feePaidBacklogAmount = 0;
        sessionMonth = '';
        sessionYear = '';
        objCalendar = new Calender__c();
        currentSemester = '1';
        currentSemesterWithPlural ='1st';
        isStudentApplicableForLiveLectureThroughRegistrationNo = false;

        productHelper = new ProductHelper();
        mapOfCourseKeyVsCourseObj = new Map<String,Map<Id,nm_Courses__c>> ();
        mapOfBacklogCourseIdVsBacklogObject = new Map<String, Object>();
        mapOfCourseKeyVsCurrentCourseObj = new Map<Id,nm_Courses__c> ();
        setOfApplicablePaymentOptionForStudent = new Set<String>();
        mapOfProductAndAmount = new Map<String,Decimal>();
        sizeOfMapOfBacklogCourseIdVsBacklogObject = 0;
        jsonMapOfProductAndAmount = '';
        jsonMapOfLectureTypeAndSubjects = '';
        jsonMapOfsetOfApplicablePaymentOptionForStudent = '';
        applicableLiveLectureFee = 0;
        applicableForLiveLectureFee = 0;
        applicableForOnlyBacklog = 0;
        applicableForBacklog = 0;
        objPaymentFormConfiguration = new NM_Payment_Form_Configuration__c();

        if(String.isNotBlank(studentNo) && dateOfBirth!=null) {
            QueryAccountOpportunityAndPaymentRelatedDetails();
        }else {
            ErrorMessage('Student Details Not Found!','PopUpError','nmLogin_New');
        }
    }

    public void QueryAccountOpportunityAndPaymentRelatedDetails() {
      //  nm_StudentProgram__c objStudentProgram = null;
        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity objOpportunity = null;
        Boolean isOpportunity = false;

        // For Payment Creation Query Purpose.
        if(String.isNotBlank(recordId)) {
            List<Account> lstAcc = [SELECT id,nm_StudentNo__c,nm_DateOfBirth__c FROM Account WHERE id=:recordId LIMIT 1];
            if(lstAcc.size() > 0) {
                studentNo = lstAcc[0].nm_StudentNo__c;
                dateOfBirth = lstAcc[0].nm_DateOfBirth__c;
            } else {
                List<Opportunity> lstOpps = [SELECT id,Account.nm_StudentNo__c,Account.nm_DateOfBirth__c FROM Opportunity WHERE id=:recordId LIMIT 1];
                studentNo = lstOpps[0].Account.nm_StudentNo__c;
                dateOfBirth = lstOpps[0].Account.nm_DateOfBirth__c;
                isOpportunity = true;
            }
        }

        List<Account> lstAccounts = [SELECT id,Current_semester__c,nm_RegistrationNumber__c,Name,nm_Centers__r.Contact_No_1__c,IC_Name_1__c,nm_ProgramType__c,Program_Type__c,nm_Tagged_Pricebook__c,nm_HouseNumber__c,BillingStreet,
        BillingCity,BillingState,BillingPostalCode,BillingCountry,FirstName,LastName,PersonEmail,PersonMobilePhone,nm_DateOfBirth__c,nm_StudentNo__c,Is_Lateral__c,Sem__c,
        (
            SELECT id,Name,nm_Semester__c,Sem__c,Total_Sem__c,LiveLecturesType__c,nm_Fee_Type__c,CourseList__c, BacklogList__c,nm_Session__c,nm_Year__c,Program_Structure__c,nm_Program__c,ConsumerType__c,Student_Number__c FROM Opportunities
        ) FROM Account WHERE nm_StudentNo__c=:studentNo AND nm_DateOfBirth__c=:dateOfBirth LIMIT 1];
        if(lstAccounts.size() > 0) {
            objAccount =  lstAccounts[0];
            String ICName = objAccount.IC_Name_1__c;
            String ICContact = objAccount.nm_Centers__r.Contact_No_1__c;
            lstOpp = objAccount.Opportunities;
            System.debug(lstOpp.size());

            if(lstOpp.size()>0) {
                for(Opportunity objOpp : lstOpp) {
                    if(isOpportunity) {
                        if(recordId.equals(objOpp.id)) {
                            objOpportunity = objOpp;
                        }
                    } else if(objOpp.Sem__c == objAccount.Current_semester__c) {
                        objOpportunity = objOpp;
                    }
                }
            }

            if(objOpportunity != null) {
                currentSemester = String.valueOf(objOpportunity.Sem__c);
                currentSemesterWithPlural = ordinal_suffix_of(Integer.valueOf(currentSemester));
                objCurrentOpportunity = objOpportunity;
                String year = String.valueOf(objOpportunity.nm_Year__c); 
                String programCategory = objAccount.nm_ProgramType__c;
                String programType = 'Re-Registration';
                if(objOpportunity.Sem__c == 1 || (objAccount.Is_Lateral__c && objOpportunity.Sem__c == Integer.valueOf(objAccount.Sem__c)) ) {
                    programType = 'Admission';
                }
                String programSpecialization = objAccount.Program_Type__c;
                liveLecType = objOpportunity.LiveLecturesType__c;
                courseList = objOpportunity.CourseList__c;
                backlogList = objOpportunity.BacklogList__c;
                OldCourseList = objOpportunity.CourseList__c;
                OldBacklogList = objOpportunity.BacklogList__c;
                Decimal totalsem = objOpportunity.Total_Sem__c;
                Integer Semester = Integer.valueOf(objOpportunity.Sem__c);
                String session = objOpportunity.nm_Session__c;
                sessionMonth = objOpportunity.nm_Session__c;
                sessionMonth = sessionMonth.substring(0, 3);
                // sessionMonth = 'Jul';
                sessionYear = year;
                opportunityId = objOpportunity.id;
                feeType = objOpportunity.nm_Fee_Type__c;
                set<String> specialRegistration = new Set<String>(new List<String>(System.Label.RegNoAllowedAfterEndDate_live_lec.split(',')));
                isStudentApplicableForLiveLectureThroughRegistrationNo = specialRegistration.contains(objAccount.nm_RegistrationNumber__c) ? true : false;
                Calender__c calender = retrieveCalenderFromSessionYearType(session,objOpportunity.nm_Year__c,programCategory);

                objCalendar = calender;
                // No Calender record found then the date has been expired.
                if(!isStudentApplicableForLiveLectureThroughRegistrationNo) {
                    if(calender==null) {
                        ErrorMessage('Hello student the window has been closed for the LiveLecture Purchase.','PopUpError','nmLogin_New');
                        return;
                    }
                }
                String fieldToRefer = objOpportunity.Sem__c > 1 ? 'Live_Lecture_Switch_Date_'+objOpportunity.Sem__c+'__c' : 'Live_Lecture_Switch_Date__c';
                lectureCantBeSwitch =  calender!= null&& String.isNotBlank(String.valueOf(objCalendar.get(fieldToRefer)))  ? (Date)objCalendar.get(fieldToRefer) >= System.today() : true;
                
                System.debug('Session__c =>'+session+' Current_Admission_Year__c=>'+year+' Program_Category__c=>'+programCategory+' Payment_Type__c=>'+programType+' Program_Type__c=>'+programSpecialization);
                //get Payment Form Configuration and calendar
                String queryNMPaymentFormConfigurationString = getQueryAllFieldSql('NM_Payment_Form_Configuration__c' ,'Session__c=:session AND Current_Admission_Year__c=:year AND Program_Category__c=:programCategory AND Payment_Type__c=:programType AND Program_Type__c=:programSpecialization',null);
                List<NM_Payment_Form_Configuration__c> lstFormConfiguration = DataBase.query(queryNMPaymentFormConfigurationString);
                
                if(lstFormConfiguration.size() == 0 || !lstFormConfiguration[0].ShowLiveLectures__c) {
                    ErrorMessage('Hello student kindly cordinate with AEP at ' +ICName+ ' Contact Number: '+ICContact,'PopUpError','nmLogin_New');
                    return;
                }
                objPaymentFormConfiguration = lstFormConfiguration[0];
                PostPaymentVFPage = objPaymentFormConfiguration.Post_Payment_VF_Page__c;
                setOfApplicablePaymentOptionForStudent.add('Custom');
                System.debug('liveLecType -->'+liveLecType);
                System.debug('courseList -->'+courseList);
                
    
                // if(Semester==1 || (objAccount.Is_Lateral__c && objOpportunity.Sem__c == Integer.valueOf(objAccount.Sem__c)) ) {
                    setOfApplicablePaymentOptionForStudent.add('1SemLecturesFee');
                // }


                if(feeType=='AnnualFee' || feeType=='MultipleSemFee' || feeType=='3SemFee' || feeType=='FullFee' ||((feeType=='MultipleSemFee-Considered' || feeType=='3SemFee-Considered' ) && Semester == 3) || (feeType=='FullFee-Considered' &&( Semester == 2 || Semester == 3))) {
                        setOfApplicablePaymentOptionForStudent.add('2SemLecturesFee');
                }

                if(feeType=='MultipleSemFee' || feeType=='3SemFee' || feeType=='FullFee' || (feeType=='FullFee-Considered' && Semester == 2)) {
                        setOfApplicablePaymentOptionForStudent.add('3SemLecturesFee');
                }
                if( feeType=='FullFee') {
                        setOfApplicablePaymentOptionForStudent.add('4SemLecturesFee');
                }



                // if((totalsem - Semester)>=1 && (Semester==2 || feeType=='AnnualFee' || feeType=='FullFee') && !feeType.contains('Considered')) {
                //     setOfApplicablePaymentOptionForStudent.add('2SemLecturesFee');
                // }
                // if((totalsem - Semester)>=2 && Semester!=1 && (Semester==3 || feeType=='MultipleSemFee' || feeType=='3SemFee' || feeType=='FullFee') && !feeType.contains('Considered')) {
                //     setOfApplicablePaymentOptionForStudent.add('3SemLecturesFee');
                // }
                // if((totalsem - Semester)>=3 && (Semester==4 || feeType=='MultipleSemFee' || feeType=='3SemFee' || feeType=='FullFee') && !feeType.contains('Considered'))
                // {
                //     setOfApplicablePaymentOptionForStudent.add('4SemLecturesFee');
                // }
                System.debug('setOfApplicablePaymentOptionForStudent ==>');
                System.debug(setOfApplicablePaymentOptionForStudent);
                jsonMapOfsetOfApplicablePaymentOptionForStudent = String.isBlank(jsonMapOfsetOfApplicablePaymentOptionForStudent) ? JSON.serialize(setOfApplicablePaymentOptionForStudent) : jsonMapOfsetOfApplicablePaymentOptionForStudent;
                configurePaymentOption(objOpportunity);
            }

        } else {
            ErrorMessage('Student Details Not Found!','PopUpError','nmLogin_New');
        }
    }
    

    public void configurePaymentOption(Opportunity objOpportunity){
        mapOfPricebook = productHelper.getMapOfProductVsPriceBookEntry(objAccount.nm_Tagged_Pricebook__c);
        Integer semester = Integer.valueOf(objOpportunity.Sem__c);
        String programStructure = objOpportunity.Program_Structure__c;
        String programId = objOpportunity.nm_Program__c;
        String consumerType = objOpportunity.ConsumerType__c;
        String programCategory = objAccount.nm_ProgramType__c;
        configurePaymentAmount(semester,programStructure,programId,consumerType,programCategory);
        jsonMapOfProductAndAmount = JSON.serialize(mapOfProductAndAmount);
    }

    public void configurePaymentAmount(Integer semester,String programStructure,String programId,String consumerType,String programCategory){ 
        if(mapOfPricebook != null && !mapOfPricebook.isEmpty()){
            // put Product Name and Amount Configuration
            Map<String,Decimal> mapOfliveLecTypeAndSubjects = new Map<String,Decimal>();
            Decimal liveLecturePrice =  mapOfPricebook.containskey('Live Lectures')? mapOfPricebook.get('Live Lectures').UnitPrice:0;
            Decimal backlogPrice =  mapOfPricebook.containskey('Backlog')? mapOfPricebook.get('Backlog').UnitPrice:0;
            // to add gst tax.
            if('Certificate Programs'.equalsIgnoreCase(programCategory) && liveLecturePrice > 0) {
                liveLecturePrice = (liveLecturePrice + (liveLecturePrice * Decimal.valueOf(Label.Service_Tax))).setScale(2);
            }
            List<OpportunityLineItem> lstLineItem = [SELECT id,ActualSalePrice__c,ProductCode FROM OpportunityLineItem WHERE OpportunityId=:opportunityId AND (ProductCode='Live Lectures' OR ProductCode='Backlog' ) LIMIT 2];


            // Opportunity beforeOpportunity = new Opportunity();
            // if(feeType.contains('Considered')) {
            //     if(feeType == 'AnnualFee-Considered') {
            //         beforeOpportunitySem = semester -1;
            //     } else if(feeType == 'MultipleSemFee-Considered') {
            //         beforeOpportunitySem = semester -2;
            //     } else if(feeType == 'FullFee-Considered') {
            //         beforeOpportunitySem = semester -3;
            //     }
            //     String oldSemester = beforeOpportunitySem >0 ? String.valueOf(beforeOpportunitySem) : '0';
            //     beforeOpportunity =[Select Id FROM Opportunity WHERE AccountId=:objAccount.Id AND nm_Semester__c=:oldSemester LIMIT 1];

            //     if(beforeOpportunity != null) {
            //         lstOldLineItem = [SELECT id,ActualSalePrice__c,ProductCode FROM OpportunityLineItem WHERE OpportunityId=:beforeOpportunity.Id AND (ProductCode='Live Lectures' OR ProductCode='Backlog' ) LIMIT 2];
            //     }
                
            // }
            


            // code added by suyog
            if(lstLineItem.size() > 0) {

                for(OpportunityLineItem objLineItem1 : lstLineItem) {
                    if(objLineItem1.ProductCode == 'Live Lectures') {
                        objLiveLectureLineItem = objLineItem1;
                    } else if (objLineItem1.ProductCode == 'Backlog') {
                        objBacklogLineItem = objLineItem1;
                    }
                }
            }

            // if(lstOldLineItem.size() > 0) {
            //      for(OpportunityLineItem objLineItem1 : lstOldLineItem) {
            //         if(objLineItem1.ProductCode == 'Live Lectures') {
            //             beforeOpportunityLiveLecturePrice = objLineItem1.ActualSalePrice__c;
            //         } else if (objLineItem1.ProductCode == 'Backlog') {
            //             beforeOpportunityBackLogPrice = objLineItem1.ActualSalePrice__c;
            //         }
            //     }
            // }
            // objLineItem = lstLineItem.size() > 0 ? lstLineItem[0] : null;
            feePaidAmount = objLiveLectureLineItem != null ? objLiveLectureLineItem.ActualSalePrice__c  : 0 ;
            feePaidBacklogAmount = objBacklogLineItem != null ? objBacklogLineItem.ActualSalePrice__c  : 0 ;
            // feePaidBacklogAmount = String.isNotBlank(OldBacklogList) && mapOfPricebook.containskey('Live Lectures') ? OldBacklogList.split(',').size() * mapOfPricebook.get('Live Lectures').UnitPrice  : 0;


            System.debug('liveLecturePrice ==>'+liveLecturePrice);
            System.debug('product Helper ==>'+productHelper.TotalNumberOfSubject(semester,programStructure,programId,'1SemLecturesFee','',consumerType));
            if(!mapOfProductAndAmount.containsKey('1SemLecturesFee'))
            {
                Decimal totalSubjects = productHelper.TotalNumberOfSubject(semester,programStructure,programId,'1SemLecturesFee','',consumerType);
                mapOfliveLecTypeAndSubjects.put('1SemLecturesFee', totalSubjects + 1);
                Decimal amount = liveLecturePrice*totalSubjects - feePaidAmount;
                mapOfProductAndAmount.put('1SemLecturesFee',amount);
                
                System.debug('1SemLecturesFee---->'+mapOfProductAndAmount.get('1SemLecturesFee'));
            }
            if(!mapOfProductAndAmount.containsKey('2SemLecturesFee'))
            {
                Decimal totalSubjects = productHelper.TotalNumberOfSubject(semester,programStructure,programId,'2SemLecturesFee','',consumerType);
                mapOfliveLecTypeAndSubjects.put('2SemLecturesFee', totalSubjects + 2);
                Decimal amount = liveLecturePrice*totalSubjects - feePaidAmount;
                mapOfProductAndAmount.put('2SemLecturesFee',amount);
                System.debug('2SemLecturesFee---->'+mapOfProductAndAmount.get('2SemLecturesFee'));
            }
            if(!mapOfProductAndAmount.containsKey('3SemLecturesFee'))
            {
                Decimal totalSubjects = productHelper.TotalNumberOfSubject(semester,programStructure,programId,'3SemLecturesFee','',consumerType);
                mapOfliveLecTypeAndSubjects.put('3SemLecturesFee', totalSubjects + 3);
                Decimal amount = liveLecturePrice*totalSubjects - feePaidAmount;
                mapOfProductAndAmount.put('3SemLecturesFee',amount);
                System.debug('3SemLecturesFee---->'+mapOfProductAndAmount.get('3SemLecturesFee'));
            }
            if(!mapOfProductAndAmount.containsKey('4SemLecturesFee'))
            {
                Decimal totalSubjects = productHelper.TotalNumberOfSubject(semester,programStructure,programId,'4SemLecturesFee','',consumerType);
                mapOfliveLecTypeAndSubjects.put('4SemLecturesFee', totalSubjects + 4);
                Decimal amount = liveLecturePrice*totalSubjects - feePaidAmount;
                mapOfProductAndAmount.put('4SemLecturesFee',amount);
                System.debug('4SemLecturesFee---->'+mapOfProductAndAmount.get('4SemLecturesFee'));
            }
        
            mapOfProductAndAmount.put('Live Lectures',liveLecturePrice);    
            mapOfProductAndAmount.put('Backlog',backlogPrice);    
            
            if(courseList!=null && courseList!='')
            {
                mapOfProductAndAmount.put('CustomLive',liveLecturePrice* productHelper.TotalNumberOfSubject(semester,programStructure,programId,'Custom',courseList,consumerType));
            }
            System.debug('liveLecturePrice--->'+liveLecturePrice);
            mapOfCourseKeyVsCourseObj = productHelper.getMapOfProgramNamekeyVsCourses();
            system.debug('mapOfCourseKeyVsCourseOb ----->' + mapOfCourseKeyVsCourseObj);
            mapOfCourseKeyVsCurrentCourseObj = mapOfCourseKeyVsCourseObj.get(programId+'-'+programStructure+'-'+semester+'-'+consumerType);
            jsonMapOfLectureTypeAndSubjects = String.isBlank(jsonMapOfLectureTypeAndSubjects) ? JSON.serialize(mapOfliveLecTypeAndSubjects) : jsonMapOfLectureTypeAndSubjects;
            System.debug('mapOfCourseKeyVsCurrentCourseObj--->'+mapOfCourseKeyVsCurrentCourseObj);
            if(String.isNotBlank(studentNo)) {
                getBacklogDataFromStudentZone(studentNo);
                sizeOfMapOfBacklogCourseIdVsBacklogObject = mapOfBacklogCourseIdVsBacklogObject.size();
            }

            System.debug('mapOfProductAndAmount --> ' + mapOfProductAndAmount);

        }
    }

    public void ErrorMessage(String msg,String secToShow, String uri){
        message = msg;
        strSecToShow = secToShow;
        returnUrl = uri;
    }

    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'SELECT '+String.join( fieldNames, ',') +' FROM '+ SObjectAPIName +' WHERE '+conditionString;
        return query;
    }

    public Calender__c retrieveCalenderFromSessionYearType(String session, Decimal year, String type) {
        System.debug('session ==>'+session+' year =>'+year+' type=>'+type);
        List<Calender__c> lstCalender = [SELECT id,Live_Lecture_Switch_Date__c,Live_Lecture_Switch_Date_2__c,Live_Lecture_Switch_Date_3__c,Live_Lecture_Switch_Date_4__c FROM Calender__c WHERE Session__c = :session AND Year__c = :year AND nm_Type__c=:type AND Session_End_Date__c >= Today LIMIT 1];
        return lstCalender.size() > 0 ? lstCalender[0] : null;
    }

    
    /**
    * @description Online Payment
    * @author @BK | 04-26-2021 
    * @return pageReference 
    **/
    public PageReference MakeOnlinePayment(){
        System.debug(validateOfPaymentButton());
        System.debug(validate());
        System.debug(opportunityId);
        if(String.isNotBlank(opportunityId) && validate() && validateOfPaymentButton()){
            System.debug('liveLecType '+liveLecType +' courseList '+courseList + ' BacklogList ' + backlogList);
            System.debug('Live Lectures Fees==>' +mapOfProductAndAmount.get('Live Lectures'));


            Decimal totalSubjects = liveLecType=='Custom' && String.isNotBlank(courseList) ? courseList.split(',').size() : 0; 
            Decimal totalBacklogSubject = String.isNotBlank(backlogList) ? backlogList.split(',').size() : 0;
            applicableForOnlyBacklog = totalBacklogSubject > 0 ? totalBacklogSubject * mapOfProductAndAmount.get('Backlog') - feePaidBacklogAmount : 0;
            System.debug('totalSubjects '+totalSubjects +'mapOfProductAndAmount.containsKey(liveLecType) '+mapOfProductAndAmount.containsKey(liveLecType)+'mapOfProductAndAmount.get(liveLecType) '+mapOfProductAndAmount.get(liveLecType));
            applicableForLiveLectureFee = mapOfProductAndAmount.containsKey(liveLecType) ? mapOfProductAndAmount.get(liveLecType)  : 
            (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures')  : 0);
            applicableForLiveLectureFee = liveLecType=='Custom' && String.isNotBlank(courseList) ? applicableForLiveLectureFee - feePaidAmount : applicableForLiveLectureFee;
            System.debug('applicableForLiveLectureFee-->'+applicableForLiveLectureFee);
            System.debug(courseList);
            System.debug(backlogList);
            courseListWithBacklogList = String.isNotBlank(backlogList) ? courseList + '-' + backlogList : courseList ;
            System.debug('courseListWithBacklogList ----> ' +courseListWithBacklogList);
            
            // // code added by suyog
            // applicableForBacklog = totalBacklogSubject > 0 ? totalBacklogSubject * mapOfProductAndAmount.get('Live Lectures') : 0;
            // applicableForBacklog = String.isNotBlank(backlogList) ? applicableForBacklog - feePaidBacklogAmount : applicableForBacklog;
            // System.debug('applicableForBacklog ---> '+ applicableForBacklog);
            applicableLiveLectureFee = applicableForLiveLectureFee + applicableForOnlyBacklog;

            System.debug('applicableLiveLectureFee' + applicableLiveLectureFee);
            
            if(applicableLiveLectureFee > 0) {
                //Creating payment tracking Id. 
                String strTranTrackid = studentNo+''+DateTime.now().year()+''+DateTime.now().month() +''+DateTime.now().day()+''+DateTime.now().hour() 
                +''+DateTime.now().minute()+''+DateTime.now().millisecond() + '' + Integer.valueof(Math.floor(1000 + Math.random()*9000));
                String studentAddress = objAccount.nm_HouseNumber__c + ',' +objAccount.BillingStreet +','+objAccount.BillingCity+','+objAccount.BillingState+','+objAccount.BillingPostalCode+','+objAccount.BillingCountry;
                nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
                objOnlinePayment.TranTrackid = strTranTrackid;
                objOnlinePayment.strAddress = studentAddress;
                objOnlinePayment.strCity = objAccount.BillingCity;
                objOnlinePayment.strPincode = objAccount.BillingPostalCode;
                objOnlinePayment.strName = objAccount.FirstName +' '+objAccount.LastName;
                objOnlinePayment.strEmailId = objAccount.PersonEmail;
                objOnlinePayment.strMobileNumber = objAccount.PersonMobilePhone;
                objOnlinePayment.recordId = objAccount.id;
                objOnlinePayment.opportunityId = opportunityId;
                objOnlinePayment.strPaymentType = 'Live Lectures';
                objOnlinePayment.InstallmentPayOpt = 'Live Lectures';
                objOnlinePayment.IsOptedForCareerService = false;
                objOnlinePayment.IsupGrad = false;
                objOnlinePayment.studentNo = studentNo;
                // for record + live
                objOnlinePayment.liveLecType = String.isBlank(liveLecType) ? 'No' : liveLecType;
                // objOnlinePayment.courseList = String.isNotBlank(courseList) ? courseList : null;
                objOnlinePayment.courseList = String.isNotBlank(courseListWithBacklogList) ? courseListWithBacklogList : null;
                objOnlinePayment.TranAmount = String.valueOf(applicableLiveLectureFee);
                System.debug('TranAmount--->'+objOnlinePayment.TranAmount);
                objOnlinePayment.postPaymentPage = PostPaymentVFPage;
                objOnlinePayment.IsReregistartion = false;
                objOnlinePayment.depositAmount = applicableLiveLectureFee;
                // Call Payment GateWay Option Based Upon Selected Option
                return PaymentRequestCreator(objOnlinePayment,strTranTrackid); 
            } else if(objCalendar!= null && objCalendar.Live_Lecture_Switch_Date__c >= System.today()) {
                System.debug('Entered if condition');
                if(createStudentSessionCourses(objCurrentOpportunity)) {
                    updateOpportunity(opportunityId);
                    PageReference loginPage = new PageReference('nmLogin_New');
                    loginPage.setRedirect(true);
                    return loginPage;
                } else {
                    ErrorMessage('Hello student kindly cordinate with Learning center at'+' '+objAccount.IC_Name_1__c+ ' Contact Number: '+objAccount.nm_Centers__r.Contact_No_1__c,'PopUpError','nmLogin_New');
                    return null;
                }
            } else {
                System.debug('Error Calendar date expired');
                ErrorMessage('Please note you can subscribe to add on subjects for live delivery. However, the window to change subject selection has been closed.','PopUpError','nmLogin_New');
                return null;
            }
        }else{
            ErrorMessage('Hello student kindly cordinate with Learning center at'+' '+objAccount.IC_Name_1__c+ ' Contact Number: '+objAccount.nm_Centers__r.Contact_No_1__c,'PopUpError','nmLogin_New');
            return null;
        }
    }

    /**
    * @description 
    * @author @BK | 04-28-2021 
    * @return Boolean 
    **/
    public Boolean validate() {
        Decimal feePaid = objLiveLectureLineItem != null ? objLiveLectureLineItem.ActualSalePrice__c : 0;
        if( feePaidAmount == feePaid && ((liveLecType=='Custom' && String.isNotBlank(courseList)) || liveLecType!='Custom')) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean validateOfPaymentButton() {
        system.debug('inside validateOfPaymentButton ---> ');
        List<String> oldCourseLst = String.isNotBlank(OldCourseList)  ? OldCourseList.split(',') : new List<String>();
        List<String> CourseLst = String.isNotBlank(courseList) ? courseList.split(',') : new List<String>();
        List<String> oldBacklogLst = String.isNotBlank(OldBacklogList) ? OldBacklogList.split(',') : new List<String>();
        List<String> BacklogLst =  String.isNotBlank(backlogList) ? backlogList.split(',') : new List<String>();
        String selectedLectureType = liveLecType;
        system.debug('validation selectedLectureType ---> ' + selectedLectureType);
        Boolean subjectCanBeSwitch = true;
        if (String.valueOf(lectureCantBeSwitch) == 'false') {
            if (selectedLectureType == 'Custom') {
                subjectCanBeSwitch = checkOldCourseContains(BacklogLst, oldBacklogLst) && checkOldCourseContains(CourseLst, oldCourseLst) ? true : false;
            } else {
                subjectCanBeSwitch = checkOldCourseContains(BacklogLst, oldBacklogLst);
                
            }
        }
        system.debug('validation lectureCantBeSwitch ---> ' + lectureCantBeSwitch);
        system.debug('validation checkOldCourseContains(BacklogList, oldBacklogList) ---> ' + checkOldCourseContains(BacklogLst, oldBacklogLst));
        system.debug('validation subjectCanBeSwitch ---> ' + subjectCanBeSwitch);
        if((String.isNotBlank(selectedLectureType)  && selectedLectureType != 'Custom' && selectedLectureType != 'No' || CourseLst.size() >= oldCourseLst.size()) && BacklogLst.size() >= oldBacklogLst.size()  && subjectCanBeSwitch) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean checkOldCourseContains(List<String> newList, List<String> oldList) {
        Boolean val = false;
        if (oldList.size() > 0) {
            for(String st : oldList) {
                if(newList.contains(st)) {
                    val = true;
                } else {
                    val = false;
                    break;
                }
            }
        } else {
            val = true;
        }
        return val;
    }

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param nmOnlinePayment objOnlinePayment 
    * @param String strTranTrackid 
    * @return PageReference 
    **/
    public PageReference PaymentRequestCreator(nmOnlinePayment objOnlinePayment ,String strTranTrackid){
        PaymentRequestParams objParams = new PaymentRequestParams();
        objParams.strTranTrackid = strTranTrackid;
        objParams.strPaymentType = objOnlinePayment.strPaymentType;
        objParams.paymentGatewayVersion = null;
        if(paymentGateWayName =='HDFC GateWay') {
            Map<String,String> mapOfParameters = objOnlinePayment.createHDFCDeskRequest();
            objParams.msg = mapOfParameters.get('msg');
            SavePaymentBeforeResponse(objParams);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.get('msg'), null);
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
        } else if(paymentGateWayName =='BillDesk GateWay') {
            if (Label.BillDesk_GatewayVersion == 'v1') {
                String msg = objOnlinePayment.createtBillDeskRequest();            
                objParams.msg = msg;
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
                   ErrorMessage('Unable to get payment details.','PopUpError',null);
                   return null;
                }
               //  String jsonResponse = JSON.serialize(mapOfParameters);
               //  SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('bdorderid'));
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
               pgURL.getParameters().put('bdOrderId', (String)mapOfParameters.get('bdorderid'));
               pgURL.getParameters().put('ru', (String)mapOfParameters.get('ru'));
               pgURL.getParameters().put('authToken', (String)mapOfAuth.get('authorization'));
               pgURL.getParameters().put('baseUrl', BilldeskV2.Base_Url__c);
                return pgURL;
            } else {
                ErrorMessage('Unable to get payment details.','PopUpError',null);
                return null;
            }

        } else if(paymentGateWayName == 'Razorpay GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createRazorPayOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                ErrorMessage('Unable to get payment details.','PopUpError',null);
                return null;
            }
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, null, (String)mapOfParameters.get('id'));
            objParams.orderId = (String)mapOfParameters.get('id');
            objParams.paymentCurrency = (String)mapOfParameters.get('currency');
            objParams.udf1 = (String)mapOfParameters.get('udf1');
            objParams.udf2 = (String)mapOfParameters.get('udf2');
            objParams.udf3 = (String)mapOfParameters.get('udf3');
            SavePaymentBeforeResponse(objParams);
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
            pgURL.getParameters().put('Name', objOnlinePayment.strName);
            pgURL.getParameters().put('email', objOnlinePayment.strEmailId);
            pgURL.getParameters().put('contact', objOnlinePayment.strMobileNumber);
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        } else if(paymentGateWayName == 'ICICI GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createICICIOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('type')) {
                ErrorMessage('Unable to get payment details.','PopUpError',null);
                return null;
            }
            // String jsonResponse = JSON.serialize(mapOfParameters);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('order_token'));
            objParams.msg = JSON.serialize(mapOfParameters);
            objParams.orderId = (String)mapOfParameters.get('order_token');
            objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            SavePaymentBeforeResponse(objParams);
            String paymentUrl = (String)mapOfParameters.get('payment_link');
            PageReference pgURL = new PageReference(paymentUrl);
            return pgURL;
        } else {
            Map<String,String> mapOfParameters = objOnlinePayment.createPayTMRequest();
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.remove('msg'), null);
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

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param String strPaymentType 
    * @param String strTranTrackid 
    * @param String msg 
    **/
    // public void SavePaymentBeforeResponse(String strPaymentType ,String strTranTrackid ,String msg, String orderId){
    public void SavePaymentBeforeResponse(PaymentRequestParams objParams){
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';
        objPayment.nm_OpportunityNew__c = opportunityId;
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
        lstPaymentToInsert.add(CreatePaymentInitiatedRecord( objPayment, 'Live Lectures', applicableLiveLectureFee,applicableLiveLectureFee, 'Live Lectures') );
        
        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                insert lstPaymentToInsert;
            }
        }catch(Exception e){
            System.debug('------String.valueof(e)--------'+String.valueof(e));
        }
    }

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param nm_Payment_Initiated__c objPayment 
    * @param String PaymentType 
    * @param decimal Amount 
    * @param decimal paymentForAmount 
    * @param String feesType 
    * @return nm_Payment_Initiated__c 
    **/
    public nm_Payment_Initiated__c CreatePaymentInitiatedRecord(nm_Payment_Initiated__c objPayment, String PaymentType, Decimal Amount , Decimal paymentForAmount, String feesType){
        nm_Payment_Initiated__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount;
        objPay.nm_Amount__c = Amount;
        objPay.nm_Fee_Type__c = feesType;
        objPay.nm_Lead__c = null;
        objPay.nm_OpportunityNew__c = opportunityId;
        return objPay;
    }

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param String strResTranId 
    * @param String paymentTransactionMode 
    * @param string strPaymentTrackId 
    * @param String strPaymentId 
    * @param String strResResult 
    * @param String strErrorText 
    * @param String strErrorCode 
    * @param String strPaymentType 
    * @param String detailedGatewayResponse 
    * @return String 
    **/
    // public String MakePaymentAfterResponse (
    //     String strResTranId, 
    //     String paymentTransactionMode,
    //     string strPaymentTrackId,
    //     String strPaymentId, 
    //     String strResResult, 
    //     String strErrorText,
    //     String strErrorCode,
    //     String strPaymentType,
    //     String detailedGatewayResponse,
    //     String additionalResult, // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
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
        String strPaymentType = objResponse.udf1; 
        String detailedGatewayResponse = objResponse.status; 
        String additionalResult = objResponse.udf2;  // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
        Decimal feeCharges = objResponse.feeChrages; 
        Decimal tax = objResponse.tax; 

        system.debug('strResTranId-->'+strResTranId);
        system.debug('paymentTransactionMode-->'+paymentTransactionMode);
        system.debug('strPaymentId-->'+strPaymentId);
        system.debug('strResResult-->'+strResResult);
        system.debug('strErrorText-->'+strErrorText);
        system.debug('strErrorCode-->'+strErrorCode);
        system.debug('strPaymentType-->'+strPaymentType);
        system.debug('detailedGatewayResponse-->'+detailedGatewayResponse);
        System.debug('additionalResult '+additionalResult);
        String LiveLecturesType = additionalResult.split('_')[1];
        String courseListWithBacklogList = additionalResult.split('_')[2];
        // String CourseListpt = strPaymentType.split('_')[8];

        String CourseListpt = '';
        String BacklogListpt = '';
        List<String> lstCourseAndBacklog = new List<String>();
        if(String.isNotBlank(courseListWithBacklogList) && courseListWithBacklogList.contains('-')) {
            system.debug(courseListWithBacklogList);
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


        Decimal totalSubjects = LiveLecturesType=='Custom' && String.isNotBlank(CourseListpt) ? CourseListpt.split(',').size() : 0; 

        Decimal totalBacklogSubject = String.isNotBlank(BacklogListpt) ? BacklogListpt.split(',').size() : 0;

        applicableForOnlyBacklog = totalBacklogSubject > 0 ? totalBacklogSubject * mapOfProductAndAmount.get('Live Lectures') - feePaidBacklogAmount : 0;

        System.debug('totalSubjects '+totalSubjects +'mapOfProductAndAmount.containsKey(liveLecType) '+mapOfProductAndAmount.containsKey(LiveLecturesType)+'mapOfProductAndAmount.get(liveLecType) '+mapOfProductAndAmount.get(LiveLecturesType));
            
        applicableForLiveLectureFee = mapOfProductAndAmount.containsKey(LiveLecturesType) ? mapOfProductAndAmount.get(LiveLecturesType)  : 
        (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures')  : 0);
         applicableForLiveLectureFee = LiveLecturesType=='Custom' && String.isNotBlank(CourseListpt) ? applicableForLiveLectureFee - feePaidAmount : applicableForLiveLectureFee;
        System.debug('applicableForLiveLectureFee-->'+applicableForLiveLectureFee);

        applicableLiveLectureFee = applicableForLiveLectureFee + applicableForOnlyBacklog;

        if(String.isNotBlank(LiveLecturesType) && LiveLecturesType != 'No') {
            liveLecType = LiveLecturesType; 
            courseList = String.isNotBlank(CourseListpt) ? CourseListpt: '';
        }

        backlogList = String.isNotBlank(BacklogListpt) ? BacklogListpt : '';
        
        
        // if(String.isNotBlank(LiveLecturesType) && LiveLecturesType != 'No') {
        //     Decimal totalSubjects = LiveLecturesType=='Custom' && String.isNotBlank(CourseListpt) ? CourseListpt.split(',').size() : 0; 
        //     applicableLiveLectureFee = mapOfProductAndAmount.containsKey(LiveLecturesType) ? mapOfProductAndAmount.get(LiveLecturesType) : 
        //     (totalSubjects > 0 ? totalSubjects * mapOfProductAndAmount.get('Live Lectures') : 0);
        //     applicableLiveLectureFee = feePaidAmount > 0 && LiveLecturesType=='Custom' ? applicableLiveLectureFee - feePaidAmount : applicableLiveLectureFee;
        //     liveLecType = LiveLecturesType;
        //     courseList = CourseListpt;
        // }

        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
        Date admissionTranscationDate = null;
        System.debug('-----------strPaymentTrackId------------'+strPaymentTrackId);
        
        lstPaymentToUpdate = [SELECT Id,nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c,nm_Amount__c,nm_ActualPaymentAmmount__c,nm_Lead__c,nm_PaymentGatewayName__c,nm_ModeOfPayment__c,nm_TransactionDate__c,nm_TransactionID__c,nm_Merchant_Track_Id__c,Online_Payment_Id__c,nm_PaymentGatewayResponse__c,Online_Response_Error__c,nm_Error_Code__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c=:strPaymentTrackId];
        list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
        System.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
        for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate) {
            objpay.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
            objpay.nm_TransactionID__c = strResTranId;
            objpay.payment_Transaction_Mode__c = paymentTransactionMode;
            objpay.Online_Payment_Id__c = strPaymentId;
            objpay.nm_PaymentGatewayResponse__c = strResResult;
            objpay.Online_Response_Error__c = strErrorText;
            objpay.nm_Error_Code__c=strErrorCode;
            objpay.Gateway_Detailed_Response__c = detailedGatewayResponse;
            // lstPaymentToInsert.add(CreatePaymentRecordv2(objpay,paymentFor,opportunityId,feeCharges,tax));
            lstPaymentToInsert.add(CreatePaymentRecordv2(objpay,objResponse));
        }
        
        if(lstPaymentToUpdate.size() > 0 ) {
            update lstPaymentToUpdate;
        }
        String firstPaymentRecordId = '';
        try{
            //----Inserting Payment records------//
            if(lstPaymentToInsert.size() > 0){
                //avoid multiple payment records being created for same merchant ID, for Browser back button press 
                firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
            }
            return firstPaymentRecordId;
        }catch(Exception e){
            return 'Failed to insert data in system :: Sumit ::' + string.valueof(e); 
        }
    }

    /**
    * @description 
    * @author @BK | 23-01-2023 
    * @param objpay 
    * @param paymentFor 
    * @param opportunityId 
    * @param feeCharges 
    * @param tax 
    * @return nm_Payment__c 
    **/
    // public nm_Payment__c CreatePaymentRecordv2(nm_Payment_Initiated__c objpay, String paymentFor, String opportunityId, Decimal feeCharges, Decimal tax){
    public nm_Payment__c CreatePaymentRecordv2(nm_Payment_Initiated__c objpay, PaymentHandler.PaymentResponseWrapper objResponse){
        nm_Payment__c objPayment =  new nm_Payment__c();
        if(String.isNotBlank(opportunityId) && opportunityId !='NA'){
            objPayment.nm_OpportunityNew__c = ID.valueOf(opportunityId);
        }
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
        objPayment.Fee_Charges__c =  objResponse.feeChrages;
        objPayment.Tax__c = objResponse.tax;
        objPayment.nm_PaymentType__c = objpay.nm_PaymentType__c;
        objPayment.nm_ActualPaymentAmmount__c = objpay.nm_ActualPaymentAmmount__c;
        objPayment.nm_Amount__c = objpay.nm_Amount__c;
        objPayment.nm_Installment_Payment_Ref__c = paymentFor;
        objPayment.Payment_Gateway_Version__c = objResponse.gatewayVersion;
        objPayment.Transaction_DateTime__c = objResponse.transactionDateTime;
        objPayment.nm_Fee_Type__c = paymentFor;
        if(objPayment.nm_PaymentStatus__c == 'Payment Made' && objPayment.nm_PaymentType__c=='Live Lectures'){
            updateOpportunity(opportunityId);
        }
        return objPayment;
    }

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param String OpportunityrecordId 
    **/
    public void updateOpportunity(String OpportunityrecordId){
        Opportunity objOpportunity = new Opportunity();
        if(String.isNotBlank(liveLecType)){
            System.debug('liveLecType  '+liveLecType +' courseList  '+courseList );
            objOpportunity.LiveLecturesType__c = liveLecType;
            objOpportunity.CourseList__c = courseList  != 'null' ? courseList  : '';
            if(String.isNotBlank(liveLecType) && liveLecType.contains('SemLecturesFee')) {
                Integer firstNo = Integer.valueOf(liveLecType.left(1));
                if(firstNo > 1) {
                    updateFutureOpportunity(liveLecType);
                }
            }
        }
        objOpportunity.BacklogList__c = backlogList  != 'null' ? backlogList  : '';
        objOpportunity.id = OpportunityrecordId;
        update objOpportunity;
        System.debug('objOpportunity----'+objOpportunity);
    }

    public void updateFutureOpportunity(String LiveLecturesType) {
        String accountId = objAccount.Id;
        Integer semester = Integer.valueOf(currentSemester) ;
        Integer LiveLectureSemester = Integer.valueOf(LiveLecturesType.left(1)) ;
        List<opportunity> lstFutureOpportunity = [Select Id,nm_Semester__c FROM Opportunity WHERE AccountId=:accountId Order by nm_Semester__c ASC ];
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        for (Opportunity opp : lstFutureOpportunity) {
            if(Integer.valueOf(opp.nm_Semester__c) > semester && Integer.valueOf(opp.nm_Semester__c) < LiveLectureSemester ) {
                Opportunity objOpp = new Opportunity();
                objOpp.Id = opp.Id;
                objOpp.LiveLecturesType__c = LiveLecturesType + '-Considered';
                lstOppToUpdate.add(opp);
            }
        }
        if(lstOppToUpdate.size() > 0) {
            update lstOppToUpdate;
        }
    }

    /**
    * @description 
    * @author @BK | 04-26-2021 
    * @param list<nm_Payment__c> lstPaymentToInsert 
    * @return String 
    **/
    public String upsertPaymentRecordsBasedOnMerchantNumber(list<nm_Payment__c> lstPaymentToInsert){
        System.debug('Method Of upsertPaymentRecordsBasedOnMerchantNumber called --->'+lstPaymentToInsert);
        list<nm_Payment__c> insertList = new List<nm_Payment__c>();
        list<nm_Payment__c> updateList = new List<nm_Payment__c>();
        String firstPaymentRecordId = '';
        
        Set<String> merchantRefNumberIds = new Set<String>();
        for(nm_Payment__c payment : lstPaymentToInsert){
            merchantRefNumberIds.add(payment.nm_Merchant_Track_Id__c);
        }
        
        Map<String, Id> merchantIdRecordIdMap = new Map<String, Id>();
        list<nm_Payment__c> existingPayments = [SELECT id,nm_Merchant_Track_Id__c,nm_TransactionID__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c IN :merchantRefNumberIds];
        if(existingPayments.size() > 0){
            for(nm_Payment__c payment : existingPayments){
                merchantIdRecordIdMap.put(payment.nm_Merchant_Track_Id__c,payment.Id);
            }
        }
        
        for(nm_Payment__c payment : lstPaymentToInsert){
            String key = payment.nm_Merchant_Track_Id__c;
            if(merchantIdRecordIdMap.containsKey(key)){
                //Payment Record already exists with given Merchant Track Id 
                Id id = merchantIdRecordIdMap.get(key);
                payment.Id = id;
                updateList.add(payment);
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

    public String ordinal_suffix_of(Integer i) {
        Integer j = Math.Mod(i, 10);
        Integer  k = Math.Mod(i, 100);
        if (j == 1 && k != 11) {
            return i + 'st';
        }
        if (j == 2 && k != 12) {
            return i +'nd';
        }
        if (j == 3 && k != 13) {
            return i + 'rd';
        }
        return i + 'th';
    }

    public Boolean createStudentSessionCourses(Opportunity opp) {
        Boolean msg = false;
        try {
            map<String, Object> result = new Map<String, Object>();
            String year = String.valueOf(Integer.valueOf(opp.nm_Year__c));
            result.put('sapId', opp.Student_Number__c);
            result.put('acadYear', year);
            result.put('acadMonth', opp.nm_Session__c);
            List<Integer> lstCourse = new List<Integer>();
            List<String> newLis = new List<String>();
            if(liveLecType == 'Custom' && String.isNotBlank(courseList)) {
                newLis = courseList.split(',');
            } else if(String.isNotBlank(liveLecType) && liveLecType.contains('SemLecturesFee')) {
                for (nm_Courses__c objCourse : mapOfCourseKeyVsCurrentCourseObj.values()) {
                    newLis.add(String.valueOf(objCourse.Student_Zone_Course_Id__c));
                } 
            }
            if(newLis.size() == 0) {
                return false;
            }
            for(String s: newLis) {
                lstCourse.add(Integer.valueOf(s));
            }
            result.put('courseIds', lstCourse);
            String jsonstring = System.JSON.serialize(result);
            
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String Uri = '';
            if(System.Label.Environment == 'Sandbox') {
                Uri = 'https://uat-studentzone-ngasce.nmims.edu/salesforce/createStudentSessionCourses';
            } else if (System.Label.Environment == 'Production') {

                Uri = System.Label.DOCUMENT_SERVER.trim() + 'm/createStudentSessionCourses';
            }
            req.setEndpoint(Uri);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('content-type', 'application/json');
            System.debug('jsonstring ==>');
            System.debug(jsonstring);
            req.setBody(jsonstring);

            resp = http.send(req);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            String message = (String)responseBody.get('message');
            if (responseBody.get('status') == 'success' || message.contains('Duplicate entry')) {
                msg = true;
            } else {
                msg = false;
            }
            return msg;

            // return true;
        }catch (Exception e) {
            System.debug(e);
            return msg;
        }
    }

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
        String Uri = System.Label.Student_Zone_Base_Url + 'exam/m/getPendingSubjectsForStudent';
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
                        mapOfBacklogCourseIdVsBacklogObject.put((String)backlogObject.get('subjectId'), instance);
                    }
                } 
            }
        }catch (Exception e) {
            System.debug(e);
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
            this.udf2 = null;
            this.udf3 = null;
            this.paymentGatewayVersion = null;
        }
    }
}