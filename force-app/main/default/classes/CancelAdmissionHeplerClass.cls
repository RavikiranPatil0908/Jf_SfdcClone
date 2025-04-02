global class CancelAdmissionHeplerClass {


    webService static String calculateAdmissionCancelRefundRecord(String accId){
        try{

        List<Account> lstAccount = new List<Account>();
        //Map<Id,Account> accountOldMap = new Map<Id,Account>();
        lstAccount = [SELECT Id ,nm_Drive_Name__c, nm_Tagged_Pricebook__c, nm_Program__c, nm_DefencePersonnel__c, nm_StudentStatus__c, nm_ProgramType__c,Program_Type__c, Is_Lateral__c, Current_semester__c, Interview_Slot__c FROM Account WHERE Id =: accId];
        
        Map<Id,Account> accountIdVsMap = new Map<Id,Account>();
        for(Account accObj : lstAccount) {
            accountIdVsMap.put(accObj.Id,accObj);  
        }


        list<nmRefund_Payment__c> lstRefundpayment=new list<nmRefund_Payment__c>();

        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> lstOpportunity = [SELECT Id ,nm_Fee_Type__c,nm_Category__c,AccountId,Account.nm_ProgramType__c,nm_InformationCenters__c,Dispatch_Order_For_Student__c,StageName, nm_Semester__c,Is_Re_Registration_Payment__c,CareerServiceProgram__c, nm_Program__r.nm_Type__c, nm_Program__r.Specialisation__c,pricebook2Id ,nm_Program__c,nm_Year__c,nm_Session__c,Account.PersonEmail,Account.nm_StudentStatus__c,(Select Id, name,ListPrice,UnitPrice,ActualSalePrice__c,Product_Name_text__c,ProgramName2__c From OpportunityLineItems) FROM Opportunity WHERE AccountId IN : accountIdVsMap.keySet()];
        Map<Id,List<Opportunity>> mapOfAccIdVsOpps = new Map<Id,List<Opportunity>>();
        Set<String> Pricebook2IdLst = new Set<String>();
        Set<String> ProgramLst = new Set<String>();
        for(Opportunity accObj : lstOpportunity) {

            if(mapOfAccIdVsOpps != null && mapOfAccIdVsOpps.containsKey(accObj.AccountId))
            {
                mapOfAccIdVsOpps.get(accObj.AccountId).add(accObj);
            }
            else
            {
                List<Opportunity> oppList = new List<Opportunity>();
                oppList.add(accObj);
                mapOfAccIdVsOpps.put(accObj.AccountId,oppList);
            }  
            opportunityIds.add(accObj.Id);
            Pricebook2IdLst.add(accObj.pricebook2Id);
            ProgramLst.add(accObj.nm_Program__c);
        }

        System.debug('accountOldMap.keySet()123 :: '+accountIdVsMap.keySet());

        System.debug('opportunityIds123 :: '+opportunityIds);

        List<Calender__c> calenderLst = new List<Calender__c>();
        calenderLst = [Select Id, Session__c,Year__c, nm_Semester__c, Session_End_Date__c, Session_Start_Date__c, Specialisation__c, nm_Type__c, Category__c from Calender__c where Session_Start_Date__c <= TODAY  and Session_End_Date__c >=  TODAY];


        List<Cancelation_Date__c> cancellationdatesLst = new List<Cancelation_Date__c>();
        cancellationdatesLst =[SELECT Id, Amount__c, From_Date__c, To_Date__c, Percentage__c, Admission_Fee__c, NM_Payment_Form_Configuration__c FROM Cancelation_Date__c  Where From_Date__c <= TODAY AND To_Date__c >= TODAY]; //WHERE  NM_Payment_Form_Configuration__c = :nmPaymentConfigId


        List<PricebookEntry> priceBookLst = [SELECT Id, Product2Id, Product2.Name, UnitPrice , Pricebook2Id, Product2.nm_Program__c FROM PricebookEntry WHERE (Pricebook2Id IN : Pricebook2IdLst OR Product2.nm_Program__c IN : ProgramLst) AND Product2.IsActive = true AND Product2.IsActive = true];
        Map<String,List<PricebookEntry>> mapOfIdVsPricebookEntry = new Map<String,List<PricebookEntry>>();
        for(PricebookEntry priceBookEntryObj : priceBookLst) {

            if(mapOfIdVsPricebookEntry.containsKey(String.valueOf(priceBookEntryObj.Pricebook2Id).substring(0, 15)+'-'+priceBookEntryObj.Product2.nm_Program__c))
            {
                mapOfIdVsPricebookEntry.get(String.valueOf(priceBookEntryObj.Pricebook2Id).substring(0, 15)+'-'+priceBookEntryObj.Product2.nm_Program__c).add(priceBookEntryObj);
            }
            else
            {
                List<PricebookEntry> oppList = new List<PricebookEntry>();
                oppList.add(priceBookEntryObj);
                mapOfIdVsPricebookEntry.put(String.valueOf(priceBookEntryObj.Pricebook2Id).substring(0, 15)+'-'+priceBookEntryObj.Product2.nm_Program__c,oppList);
            }
        }

        List<nm_Payment__c> paymentlst = [SELECT Id , nm_ModeOfPayment__c,nm_OpportunityNew__c, nm_PaymentStatus__c,nm_PaymentType__c, nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c in : opportunityIds AND (nm_PaymentStatus__c = 'Payment Made' OR nm_PaymentStatus__c = 'Payment Approved') AND nm_PaymentType__c!='Registration'];

        Map<Id,List<nm_Payment__c>> mapOFoppIdVsPayment = new Map<Id,List<nm_Payment__c>>();
        for(nm_Payment__c paymentObj : paymentlst)
        {

            if(mapOFoppIdVsPayment.containsKey(paymentObj.nm_OpportunityNew__c))
            {
                mapOFoppIdVsPayment.get(paymentObj.nm_OpportunityNew__c).add(paymentObj);
            }
            else
            {
                List<nm_Payment__c> paymentList = new List<nm_Payment__c>();
                paymentList.add(paymentObj);
                mapOFoppIdVsPayment.put(paymentObj.nm_OpportunityNew__c,paymentList);
            }
        }

        System.debug('paymentlst123 :: '+paymentlst);
        System.debug('mapOFoppIdVsPayment123 :: '+mapOFoppIdVsPayment);

        List<Dispatch_Order__c> dispatchOrderlst  = [SELECT Id , Status_Of_Dispatch__c ,Opportunity__c FROM Dispatch_Order__c WHERE Dispatch_Order__c.Opportunity__c IN : opportunityIds ];
        Map<Id,List<Dispatch_Order__c>> mapOfOppIdVsDO = new Map<Id,List<Dispatch_Order__c>>();
        for(Dispatch_Order__c accObj : dispatchOrderlst) {

            if(mapOfOppIdVsDO.containsKey(accObj.Opportunity__c))
            {
                mapOfOppIdVsDO.get(accObj.Opportunity__c).add(accObj);
            }
            else
            {
                List<Dispatch_Order__c> oppList = new List<Dispatch_Order__c>();
                oppList.add(accObj);
                mapOfOppIdVsDO.put(accObj.Opportunity__c,oppList);
            }
        }

        //nm_payment_config
        List<NM_Payment_Form_Configuration__c> paymentConfiglst = [SELECT Id,Program_Category__c,Payment_Type__c,Session__c,Current_Admission_Year__c,Program_Type__c, LiveLecture_Startdate__c,Price_Book__c, Payment_Window_EndDate__c FROM NM_Payment_Form_Configuration__c]; // WHERE Payment_Type__c = 'Re-Registration'
        //payment
        //refundpayment
        //careerservice
        //opportunityproduct

        //defence discount
        


        ///program
        Set<String> progarmTypes = new Set<String>{
            'Diploma Programs',
            'Executive Programs',
            'Post Graduate Diploma Programs',
            'Professional Programs',
            'Bachelor Programs',
            'MBA (Distance) Programs',
            'MBA (Online) Programs'
        };

        Set<String> studentStatusForRegistrationCancel = new Set<String>{
            'Confirmed',
            'Registration Cancelled',
            'Not Eligible',
            'De-Registered',
            'Admission Cancelled',
            'Closed Lost',
            'Rejected',
            'Aluminus',
            'Rusticated',
            'Alumni'
        };

        Set<String> validPaymentTypes = new Set<String>{
            'Admission',
            'Additional Charge',
            'Admission',
            'Avanse-DownPayment',
            'Capital Float-DownPayment',
            'EduVanz-DownPayment',
            'GrayQuest-DownPayment',
            'Initial Payment',
            'Installment',
            'LiquiLoans-DownPayment',
            'Propelld-DownPayment',
            'Zest-DownPayment',
            '-DownPayment'
        };

        Decimal gstPercetage = 0.18;
        Decimal defenceDiscount = 0.2;

        for(Account currAcc :lstAccount)
        {
            System.debug('currAcc.Id ::'+currAcc.Id+ 'currAcc'+currAcc);

            if(accountIdVsMap.get(currAcc.Id).nm_StudentStatus__c == 'Confirmed'){ // for admission cancellation

                // If Cancellation requested after 12 months (for eg. For Jan 2024 after Dec 2024, For Jul 2024 after Jun 2025) – No refund applicable.
                System.debug('ac.nm_Drive_Name__c.contains(jan)123 '+currAcc.nm_Drive_Name__c.contains('January'));
                System.debug('ac.nm_Drive_Name__c123 '+currAcc.nm_Drive_Name__c);
                Date currDate = System.Today();
                System.debug('currDate.year()123 '+currDate.year()+'');
                if(currAcc.nm_Drive_Name__c.contains('January')){
                    
                    if(!currAcc.nm_Drive_Name__c.contains(String.valueOf(currDate.year()))){
                        //break;
                        throw new IllegalArgumentException('Cancellation requested after 12 months, No refund applicable');
                    }
                    System.debug('jan'+currAcc.nm_Drive_Name__c.contains('January'));
                    System.debug('janyear'+!currAcc.nm_Drive_Name__c.contains(String.valueOf(currDate.year())));
                }else if(currAcc.nm_Drive_Name__c.contains('July')){
                    
                    if((currAcc.nm_Drive_Name__c.contains(String.valueOf(currDate.year())) && currDate.month() > 6) || (currAcc.nm_Drive_Name__c.contains(String.valueOf((currDate.year()-1))) && currDate.month() <= 6 )){
                        
                    }else{
                        //break;
                        throw new IllegalArgumentException('Cancellation requested after 12 months, No refund applicable');
                    } 
                    System.debug('jan'+currAcc.nm_Drive_Name__c.contains('January'));
                    System.debug('janyear'+!currAcc.nm_Drive_Name__c.contains(String.valueOf(currDate.year())));
                }

                Map<String,Decimal> productPriceBook = new Map<String,Decimal>();
                List<PricebookEntry> priceBookEntrylst = new List<PricebookEntry>();
                priceBookEntrylst = mapOfIdVsPricebookEntry.get(currAcc.nm_Tagged_Pricebook__c+'-'+currAcc.nm_Program__c);
                System.debug('currAcc.nm_Tagged_Pricebook__c123 :: '+currAcc.nm_Tagged_Pricebook__c);
                System.debug('currAcc.nm_Program__c123 :: '+currAcc.nm_Program__c);
                System.debug('mapOfIdVsPricebookEntry123 :: '+mapOfIdVsPricebookEntry);
                if(priceBookEntrylst != null){
                    for(PricebookEntry priceBookEntryObj: priceBookEntrylst){

                        if(currAcc.nm_DefencePersonnel__c == 'Yes'){
                            productPriceBook.put(priceBookEntryObj.Product2.Name , priceBookEntryObj.UnitPrice * (1-defenceDiscount));
                        }
                        else if(currAcc.nm_DefencePersonnel__c == 'No'){

                            productPriceBook.put(priceBookEntryObj.Product2.Name , priceBookEntryObj.UnitPrice);
                            System.debug('priceBookEntryObj.Product2.Name123 :: '+priceBookEntryObj.Product2.Name);
                            System.debug('priceBookEntryObj.UnitPrice123 :: '+priceBookEntryObj.UnitPrice);
                        }
                    }
                }

                Boolean documentsApproved = false;
                Boolean InstallmentdoneFlag = false;
                Boolean initalPaymentDone = false;
                String accountOldStatus = accountIdVsMap.containsKey(currAcc.Id) ? accountIdVsMap.get(currAcc.Id).nm_StudentStatus__c : null;
                if(String.isNotBlank(accountOldStatus) && (accountOldStatus.endsWithIgnoreCase('Admission form & documents Approved') || accountOldStatus.endsWithIgnoreCase('Admission Form & Documents Provisional'))) {
                    documentsApproved = true;
                }
                String AccountStage = currAcc.nm_StudentStatus__c;

           
                //'MBA(WX) Program'
                if(currAcc.nm_ProgramType__c == 'Master Programs' && currAcc.Program_Type__c == 'MBA (WX)'){ //'MBA(WX) Program'

                    Decimal SemI = 0.00;

                    if(productPriceBook != null){
                        SemI = productPriceBook.get('Semester I');
                    }
                    Map<String,NM_Payment_Form_Configuration__c> nmPaymentConfigMap = new Map<String,NM_Payment_Form_Configuration__c>();
                    String ModeofPaymentSem1 = '';
                    List<Opportunity> opplst = mapOfAccIdVsOpps.get(currAcc.Id);
                    Decimal tutionFee = 0.00;
                    Decimal lateFee = 0.00;
                    Date lastDateofProgramFeePayment ;
                    Opportunity oppLocal = new Opportunity();
                    for(Opportunity oppObj:opplst){

                        if(oppObj.StageName == 'Closed Won')
                        {
                            if(oppObj.nm_Semester__c == '1' ){
                                oppLocal = oppObj;  
                            }
                            
                            Date liveLectureStartDate ;
                            String nmPaymentConfigId ;
                            String specData = '';
                            String typeData = '';
                            Decimal yearData = oppObj.nm_Year__c;
                            typeData = oppObj.nm_Program__r.nm_Type__c;
                            specData = oppObj.nm_Program__r.Specialisation__c; 

                            for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                            {  
                                if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppObj.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                                    liveLectureStartDate = paymentConfig.LiveLecture_Startdate__c;
                                    nmPaymentConfigId = paymentConfig.Id;
                                    lastDateofProgramFeePayment = paymentConfig.Payment_Window_EndDate__c.Date();
                                    if(oppObj.Is_Re_Registration_Payment__c == false && paymentConfig.Payment_Type__c == 'Admission'){
                                        nmPaymentConfigMap.put('Admission',paymentConfig); 
                                    }
                                    else if(oppObj.Is_Re_Registration_Payment__c == true && paymentConfig.Payment_Type__c == 'Re-Registration')
                                    {
                                        nmPaymentConfigMap.put('Re-Registration',paymentConfig); 
                                    }
                                                             
                                }
                            }

                            List<nm_Payment__c> paymentList = mapOFoppIdVsPayment.get(oppObj.Id);
                            if(paymentList != null){
                            for(nm_Payment__c payObj:paymentList){

                                if(validPaymentTypes.contains(payObj.nm_PaymentType__c) || payObj.nm_PaymentType__c.contains('-DownPayment')){
                                    tutionFee += payObj.nm_Amount__c; 
                                }
                                else if(payObj.nm_PaymentType__c == 'Late Fees'){

                                    lateFee = payObj.nm_Amount__c;
                                }
                                ModeofPaymentSem1 = payObj.nm_ModeOfPayment__c;
                                if (payObj.nm_PaymentType__c == 'Installment' )
                                {    
                                    InstallmentdoneFlag = true;
                                }
                                if (payObj.nm_PaymentType__c == 'Initial Payment' )
                                {    
                                    initalPaymentDone = true;
                                }

                            }
                        }
                        }
                    }
                    System.debug('tutionFee MBA (WX) ::'+tutionFee);
                    lstRefundpayment.add(InsertRefundRecord(oppLocal,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,0.0,0.0,lateFee, InstallmentdoneFlag, initalPaymentDone));

                }
                 // 'Certificate Program with GST'
                else if(currAcc.nm_ProgramType__c == 'Certificate Programs'){ // 'Certificate Program with GST'

                    Decimal SemI = 0.00;

                    if(productPriceBook != null){
                        SemI = productPriceBook.get('Semester I');
                    }

                    Map<String,NM_Payment_Form_Configuration__c> nmPaymentConfigMap = new Map<String,NM_Payment_Form_Configuration__c>();
                    String ModeofPaymentSem1 = '';
                    List<Opportunity> opplst = mapOfAccIdVsOpps.get(currAcc.Id);
                    Decimal tutionFee = 0.00;
                    Decimal lateFee = 0.00;
                    Date lastDateofProgramFeePayment ;
                    Opportunity oppLocal = new Opportunity();
                    for(Opportunity oppObj:opplst){

                        if(oppObj.StageName == 'Closed Won')
                        {
                            if(oppObj.nm_Semester__c == '1' ){
                                oppLocal = oppObj;
                                
                            }
                            
                            Date liveLectureStartDate ;
                            String nmPaymentConfigId ;
                            String specData = '';
                            String typeData = '';
                            Decimal yearData = oppObj.nm_Year__c;
                            typeData = oppObj.nm_Program__r.nm_Type__c;
                            specData = oppObj.nm_Program__r.Specialisation__c; 

                            for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                            {  
                                if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppObj.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                                    liveLectureStartDate = paymentConfig.LiveLecture_Startdate__c;
                                    nmPaymentConfigId = paymentConfig.Id;
                                    lastDateofProgramFeePayment = paymentConfig.Payment_Window_EndDate__c.Date();
                                    if(oppObj.Is_Re_Registration_Payment__c == false && paymentConfig.Payment_Type__c == 'Admission'){
                                        nmPaymentConfigMap.put('Admission',paymentConfig); 
                                    }
                                    else if(oppObj.Is_Re_Registration_Payment__c == true && paymentConfig.Payment_Type__c == 'Re-Registration')
                                    {
                                        nmPaymentConfigMap.put('Re-Registration',paymentConfig); 
                                    }                          
                                }
                            }

                            List<nm_Payment__c> paymentList = mapOFoppIdVsPayment.get(oppObj.Id);
                            if(paymentList != null){
                            for(nm_Payment__c payObj:paymentList){

                                if(validPaymentTypes.contains(payObj.nm_PaymentType__c) || payObj.nm_PaymentType__c.contains('-DownPayment')){
                                    tutionFee += payObj.nm_Amount__c; 
                                }
                                else if(payObj.nm_PaymentType__c == 'Late Fees'){

                                    lateFee = payObj.nm_Amount__c;
                                } 
                                ModeofPaymentSem1 = payObj.nm_ModeOfPayment__c;
                                if (payObj.nm_PaymentType__c == 'Installment' )
                                {    
                                    InstallmentdoneFlag = true;
                                }
                                if (payObj.nm_PaymentType__c == 'Initial Payment' )
                                {    
                                    initalPaymentDone = true;
                                }   
                            }
                        }
                        }
                    }
                    System.debug('tutionFee Certificate Programs ::'+tutionFee);
                    lstRefundpayment.add(InsertRefundRecord(oppLocal,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,0.0,0.0,lateFee, InstallmentdoneFlag, initalPaymentDone));
                }
            else if(progarmTypes.contains(currAcc.nm_ProgramType__c)){ // == 'Diploma, MBA, Professional & Certificate Program without GST'

            System.debug('Diploma, MBA, Professional & Certificate Program without GST');
                if(currAcc.Is_Lateral__c != true) { // for non-lateral
                    System.debug('currAcc.Is_Lateral__c != true 123 ::');
                List<Opportunity> opplst = mapOfAccIdVsOpps.get(currAcc.Id);
                Map<String,Map<String,Decimal>> feeAmtReceived = new Map<String,Map<String,Decimal>>(); // sem --->tutionFee,amt
                Map<String,NM_Payment_Form_Configuration__c> nmPaymentConfigMap = new Map<String,NM_Payment_Form_Configuration__c>();
                String ModeofPaymentSem1 = '';

                Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
                for(Opportunity oppObj:opplst){

                    if(oppObj.StageName == 'Closed Won')
                    { 
                        Decimal tutionFee = 0.00;
                        Decimal liveLectures = 0.00;
                        Decimal lateFee = 0.00;
                        String nmPaymentConfigId ;
                        String specData = '';
                        String typeData = '';
                        Decimal yearData = oppObj.nm_Year__c;
                        typeData = oppObj.nm_Program__r.nm_Type__c;
                        specData = oppObj.nm_Program__r.Specialisation__c; 

                        for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                        {  
                            if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppObj.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                                nmPaymentConfigId = paymentConfig.Id;
                            if(oppObj.Is_Re_Registration_Payment__c == false && paymentConfig.Payment_Type__c == 'Admission'){
                                nmPaymentConfigMap.put('Admission',paymentConfig); 
                            }
                            else if(oppObj.Is_Re_Registration_Payment__c == true && paymentConfig.Payment_Type__c == 'Re-Registration')
                            {
                                nmPaymentConfigMap.put('Re-Registration',paymentConfig); 
                            } 
                                System.debug('lastDateofProgramFeePayment1 123 :: ');                       
                            }
                        }
                        
                        List<nm_Payment__c> paymentList = mapOFoppIdVsPayment.get(oppObj.Id);
                        if(paymentList != null){

                            for(nm_Payment__c payObj:paymentList){

                                if(validPaymentTypes.contains(payObj.nm_PaymentType__c) || payObj.nm_PaymentType__c.contains('-DownPayment')){
                                    tutionFee += payObj.nm_Amount__c;
                                }
                                else if(payObj.nm_PaymentType__c == 'Live Lectures'){
    
                                    liveLectures += payObj.nm_Amount__c;
                                }
                                else if(payObj.nm_PaymentType__c == 'Late Fees'){
    
                                    lateFee = payObj.nm_Amount__c;
                                }
                                ModeofPaymentSem1 = payObj.nm_ModeOfPayment__c;
                                if (payObj.nm_PaymentType__c == 'Installment' )
                                {    
                                    InstallmentdoneFlag = true;
                                }
                                if (payObj.nm_PaymentType__c == 'Initial Payment' )
                                {    
                                    initalPaymentDone = true;
                                }  
                            }

                        }
                        
                        Map<String,Decimal> feeMap = new Map<String,Decimal>();
                        feeMap.put('tutionFee', tutionFee);
                        feeMap.put('Live Lectures', liveLectures);
                        feeMap.put('Late Fees', lateFee);
                        feeAmtReceived.put(oppObj.nm_Semester__c, feeMap) ; 
                        oppMap.put(oppObj.nm_Semester__c, oppObj);
                    }    
                }

                
                Decimal latefeefinal = 0.0; 
                Decimal dispatchAmtfinal = 0.0;
                Decimal liveLectureAmtfinal = 0.0;
                Opportunity curreopp = oppMap.get(String.valueOf(currAcc.Current_semester__c));
                System.debug('oppMap 123 :: '+oppMap);  
                System.debug('currAcc.Current_semester__c 123 :: '+currAcc.Current_semester__c);
                System.debug('oppMap.get(String.valueOf(currAcc.Current_semester__c)) 123 :: '+oppMap.get(String.valueOf(currAcc.Current_semester__c)));  
                if(curreopp != null){

                    System.debug('dispatchAmtfinal 123 :: ');  
                    if(calenderLst != null){
                        for(Calender__c  calenobj:calenderLst){
                            if(curreopp.nm_Category__c == 'Admission' && calenobj.Category__c == 'Admission' && 
                            calenobj.Session__c == curreopp.nm_Session__c && calenobj.Year__c == curreopp.nm_Year__c &&
                            curreopp.nm_Program__r.nm_Type__c == calenobj.nm_Type__c && curreopp.nm_Program__r.Specialisation__c == calenobj.Specialisation__c)
                            {
                                System.debug('dispatchAmtfinal 123 Admission :: ');
                                latefeefinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Late Fees');
                                if(curreopp.nm_Semester__c != '1'){
                                    dispatchAmtfinal = getDispatchAmt(oppMap.get(String.valueOf(currAcc.Current_semester__c)).Id, mapOfOppIdVsDO);
                                }
                                
                                if(oppMap.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures') != null)
                                {
                                    if(curreopp.StageName == 'Closed Won' &&  nmPaymentConfigMap.get('Admission').LiveLecture_Startdate__c <= System.today()){
                                        liveLectureAmtfinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures');
                                    }
                                }
                            }
                            else if(curreopp.nm_Category__c != 'Admission' && String.isBlank(curreopp.nm_Category__c) && curreopp.Is_Re_Registration_Payment__c == true &&
                            calenobj.Session__c == curreopp.nm_Session__c && calenobj.Year__c == curreopp.nm_Year__c 
                            && curreopp.nm_Program__r.nm_Type__c == calenobj.nm_Type__c && curreopp.nm_Program__r.Specialisation__c == calenobj.Specialisation__c)
                            {
                                System.debug('dispatchAmtfinal 123 Re-registration :: ');
                                latefeefinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Late Fees');
                                if(curreopp.nm_Semester__c != '1'){
                                dispatchAmtfinal = getDispatchAmt(oppMap.get(String.valueOf(currAcc.Current_semester__c)).Id, mapOfOppIdVsDO);
                                }

                                if(oppMap.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures') != null)
                                {
                                    System.debug('dispatchAmtfinal 123 Re-registration liveLectureAmtfinal1:: '+liveLectureAmtfinal);
                                    if(curreopp.StageName == 'Closed Won' && nmPaymentConfigMap.get('Re-Registration').LiveLecture_Startdate__c <= System.today() && curreopp.Is_Re_Registration_Payment__c == true){
                                        System.debug('productPriceBook.get(Live Lectures) != null :: '+productPriceBook.get('Live Lectures'));
                                        System.debug('dispatchAmtfinal 123 Re-registrationdate :: '+nmPaymentConfigMap.get('Re-Registration').LiveLecture_Startdate__c );
                                        System.debug('dispatchAmtfinal 123 Re-registration System.today() :: '+System.today());
                                        System.debug('dispatchAmtfinal 123 Re-registration liveLectureAmtfinal2:: '+liveLectureAmtfinal);
                                        if(  nmPaymentConfigMap.get('Re-Registration').LiveLecture_Startdate__c < System.today()){ 
                                            liveLectureAmtfinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures');
                                     
                                            System.debug('dispatchAmtfinal 123 Re-registration liveLectureAmtfinal2inner:: '+liveLectureAmtfinal);
                                        }
                                    }
                                }

                            }

                        }
                    }
                    
                }
                System.debug('cancellationdatesLst 123 :: '+cancellationdatesLst);  
                System.debug('nmPaymentConfigMap.get(Admission) 123 :: '+nmPaymentConfigMap.get('Admission'));
                if(cancellationdatesLst == null){
                    throw new IllegalArgumentException('Cancellation requested not within the date range');
                }
                Cancelation_Date__c  canObj = getCancellationDateDetails(nmPaymentConfigMap.get('Admission'), cancellationdatesLst);
                if(canObj != null ){
            
                        if(canObj.From_Date__c <= System.today() && canObj.To_Date__c >= System.today()){
                            
                        } else{
                            throw new IllegalArgumentException('Cancellation requested not within the date range');
                        }
                }
                else{
                    throw new IllegalArgumentException('Cancellation requested not within the date range');
                }


                if(nmPaymentConfigMap.get('Admission').Payment_Window_EndDate__c.Date() != null){
                    Decimal tutionFee = 0.0;
                    Decimal liveLectures = 0.0;
                    Opportunity opp1 = oppMap.get('1');
                    tutionFee = feeAmtReceived.get('1').get('tutionFee');
                    
                    System.debug('oppMap.get(1)123 :: '+oppMap.get('1'));
                    System.debug('lastDateofProgramFeePayment1.addDays(30)123 :: '+nmPaymentConfigMap.get('Admission').Payment_Window_EndDate__c.Date().addDays(30));
                    System.debug('System.Today()123 :: '+System.Today());
                    
                    if(System.Today() > nmPaymentConfigMap.get('Admission').Payment_Window_EndDate__c.Date().addDays(30)){

                        System.debug('oppMap.get(1)123 :: '+oppMap.get('1'));
                        if(oppMap.get('1') != null) 
                            {
                                
                                if(opp1.StageName == 'Closed Won' && (opp1.nm_Fee_Type__c  == 'AnnualFee' || opp1.nm_Fee_Type__c  == 'AnnualFeeLoan')){

                                    if(oppMap.get('2') != null){
                                        Opportunity opp2 = oppMap.get('2');
                                        
                                        if(opp2.StageName != 'Closed Won' && opp2.nm_Fee_Type__c  == 'AnnualFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

                                       
                                        }
                                        else if(opp2.StageName == 'Closed Won' && opp2.nm_Fee_Type__c  == 'AnnualFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                           
                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(opp2.Id, mapOfOppIdVsDO);
                                            System.debug('dispatchAmt123 :: '+dispatchAmt);
                                       
                                        }

                                    }
                                    Decimal SemI = 0.00;
                                    SemI = productPriceBook.get('Semester I');
                                lstRefundpayment.add(InsertRefundRecord(opp1,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));
                                        
                                }
                                else if(opp1.StageName == 'Closed Won' && (opp1.nm_Fee_Type__c  == 'FullFee' || opp1.nm_Fee_Type__c  == 'FullFeeLoan')){

                                 
                                    Boolean annualfeeflag = false;
                                    Decimal annualfeevalue = 0.0;
                                    if(oppMap.get('2') != null){
                                        Opportunity opp2 = oppMap.get('2');
                                        
                                        if(opp2.StageName != 'Closed Won' && opp2.nm_Fee_Type__c  == 'FullFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

             
                                        }
                                        else if(opp2.StageName == 'Closed Won' && opp2.nm_Fee_Type__c  == 'FullFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                        
                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(opp2.Id, mapOfOppIdVsDO);
                                         

                                        }
                                        else if(oppMap.get('3') != null){
                                            Opportunity opp3 = oppMap.get('3');
                                            

                                            if(opp3.StageName != 'Closed Won' && opp3.nm_Fee_Type__c  == 'FullFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                                annualfeeflag = true;
                                                annualfeevalue =  (productPriceBook.get('Annual'));
                                            }
                                            else if(opp3.StageName == 'Closed Won' && opp3.nm_Fee_Type__c  == 'FullFee-Considered' ){ //&& nmPaymentConfigMap.get(oppMap.get('3').id).Payment_Window_EndDate__c.Date() > System.Today()
                                                annualfeeflag = true;
                                                annualfeevalue =  (productPriceBook.get('Annual'));
                                                Decimal dispatchAmt = 0.0;
                                                dispatchAmt = getDispatchAmt(opp3.Id, mapOfOppIdVsDO);
                                      
                                            }
                                        }
                                    }
                                    Decimal SemI = 0.00;
                                    SemI = productPriceBook.get('Semester I');
                                    if(annualfeeflag){
                                        SemI = annualfeevalue;
                                    }
                                    lstRefundpayment.add(InsertRefundRecord(opp1,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));
                                }
                                else if(opp1.StageName == 'Closed Won' && opp1.nm_Fee_Type__c  == 'admission'){
                                    Decimal SemI = 0.00;
                                    Opportunity opp2 = oppMap.get('2');
                                    System.debug('productPriceBook123 :: '+productPriceBook);
                                    if(productPriceBook != null){
                                        SemI = productPriceBook.get('Semester I');
                                    }
                                    if(oppMap.get('2') != null && opp2.nm_Fee_Type__c  == 'AnnualFee'){
                                    if(opp2.StageName != 'Closed Won' && opp2.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                     }
                                     if(opp2.StageName == 'Closed Won' && opp2.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                     }
                                     Opportunity opp3 = oppMap.get('3');
                                     if(opp3 != null)
                                     {
                                         if(opp3.StageName != 'Closed Won' && opp3.nm_Fee_Type__c  == 'AnnualFee-Considered' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                            SemI += productPriceBook.get('Semester II'); 
                                         }
                                         if(opp3.StageName == 'Closed Won' && opp3.nm_Fee_Type__c  == 'AnnualFee-Considered' ){
                                            SemI += productPriceBook.get('Semester II'); 
                                         }
                                     }
                                    }
                                    else if(oppMap.get('2') != null && opp2.nm_Fee_Type__c  == 'admission'){
                                        Opportunity opp3 = oppMap.get('3');
                                        if(opp3 != null)
                                        {
                                            if(opp3.StageName != 'Closed Won' && opp3.nm_Fee_Type__c  == 'admission' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                                                SemI += productPriceBook.get('Semester II'); 
                                            }
                                            if(opp3.StageName == 'Closed Won' && opp3.nm_Fee_Type__c  == 'admission' ){ 
                                                SemI += productPriceBook.get('Semester II'); 
                                            }
                                        }
                                    }
                                    System.debug('InsertRefundRecord123 ::');
                                    lstRefundpayment.add(InsertRefundRecord(opp1,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));
                                }                       
                            }
                        }
                        else if(System.Today() <= nmPaymentConfigMap.get('Admission').Payment_Window_EndDate__c.Date().addDays(30)){
                            Decimal SemI = 0.00;
                            SemI = productPriceBook.get('Semester I');
                            System.debug('InsertRefundRecord123 ::');
                            lstRefundpayment.add(InsertRefundRecord(opp1,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemI,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));                   
                        }
                        
                    }
                }
                else if(currAcc.Is_Lateral__c == true){

                List<Opportunity> opplst = mapOfAccIdVsOpps.get(currAcc.Id);
                Map<String,Map<String,Decimal>> feeAmtReceived = new Map<String,Map<String,Decimal>>(); // sem --->tutionFee,amt
                Map<String,NM_Payment_Form_Configuration__c> nmPaymentConfigMap = new Map<String,NM_Payment_Form_Configuration__c>();
                String ModeofPaymentSem1 = '';

                Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
                for(Opportunity oppObj:opplst) {

                    if(oppObj.StageName == 'Closed Won')
                    {
                        Decimal tutionFee = 0.00;
                        Decimal liveLectures = 0.00;
                        Decimal lateFee = 0.00;
                        String nmPaymentConfigId ;
                        String specData = '';
                        String typeData = '';
                        Decimal yearData = oppObj.nm_Year__c;
                        typeData = oppObj.nm_Program__r.nm_Type__c;
                        specData = oppObj.nm_Program__r.Specialisation__c; 

                        for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                        {  
                            if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppObj.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                                nmPaymentConfigId = paymentConfig.Id;
                            if(oppObj.Is_Re_Registration_Payment__c == false){
                                nmPaymentConfigMap.put('Admission',paymentConfig); 
                            }
                            else if(oppObj.Is_Re_Registration_Payment__c == true)
                            {
                                nmPaymentConfigMap.put('Re-Registration',paymentConfig); 
                            } 
                                System.debug('lastDateofProgramFeePayment1 123 :: ');                       
                            }
                        }
                        List<nm_Payment__c> paymentList = mapOFoppIdVsPayment.get(oppObj.Id);
                        if(paymentList != null){
                            for(nm_Payment__c payObj:paymentList){

                                if(validPaymentTypes.contains(payObj.nm_PaymentType__c) || payObj.nm_PaymentType__c.contains('-DownPayment')){
                                    tutionFee += payObj.nm_Amount__c;
                                }
                                else if(payObj.nm_PaymentType__c == 'Live Lectures'){

                                    liveLectures += payObj.nm_Amount__c;
                                }
                                else if(payObj.nm_PaymentType__c == 'Late Fees'){

                                    lateFee = payObj.nm_Amount__c;
                                }
                                ModeofPaymentSem1 = payObj.nm_ModeOfPayment__c;
                                if (payObj.nm_PaymentType__c == 'Installment' )
                                {    
                                    InstallmentdoneFlag = true;
                                }
                                if (payObj.nm_PaymentType__c == 'Initial Payment' )
                                {    
                                    initalPaymentDone = true;
                                }  
                            }
                        }
                        Map<String,Decimal> feeMap = new Map<String,Decimal>();
                        
                            feeMap.put('tutionFee', tutionFee);
                        
                            feeMap.put('Live Lectures', liveLectures);
                       
                            feeMap.put('Late Fees', lateFee);
                    
                        feeAmtReceived.put(oppObj.nm_Semester__c, feeMap); 
                        oppMap.put(oppObj.nm_Semester__c, oppObj);
                        System.debug('feeMap123 ::'+feeMap);
                        System.debug('feeAmtReceived123 ::'+feeAmtReceived);
                    }

                }  
                Decimal latefeefinal = 0.0; 
                Decimal dispatchAmtfinal = 0.0;
                Decimal liveLectureAmtfinal = 0.0;
                Opportunity curreopp = oppMap.get(String.valueOf(currAcc.Current_semester__c));
                if(curreopp != null){

                    if(calenderLst != null){
                        for(Calender__c  calenobj:calenderLst){
                            if(curreopp.nm_Category__c == 'Lateral Admission' && calenobj.Category__c == 'Re-Registration' && 
                            calenobj.Session__c == curreopp.nm_Session__c && calenobj.Year__c == curreopp.nm_Year__c &&
                            curreopp.nm_Program__r.nm_Type__c == calenobj.nm_Type__c && curreopp.nm_Program__r.Specialisation__c == calenobj.Specialisation__c)
                            {
                                latefeefinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Late Fees');
                                if(curreopp.nm_Semester__c != '1'){
                                dispatchAmtfinal = getDispatchAmt(oppMap.get(String.valueOf(currAcc.Current_semester__c)).Id, mapOfOppIdVsDO);
                                }
                                if(oppMap.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures') != null)
                                {
                                    if(curreopp.StageName == 'Closed Won' &&  nmPaymentConfigMap.get('Admission').LiveLecture_Startdate__c <= System.today()){ 
                                        liveLectureAmtfinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures');
                                      
                                    }
                                }
                            }
                            else if(curreopp.nm_Category__c != 'Admission' && String.isBlank(curreopp.nm_Category__c) && curreopp.Is_Re_Registration_Payment__c == true &&
                            calenobj.Session__c == curreopp.nm_Session__c && calenobj.Year__c == curreopp.nm_Year__c 
                            && curreopp.nm_Program__r.nm_Type__c == calenobj.nm_Type__c && curreopp.nm_Program__r.Specialisation__c == calenobj.Specialisation__c)
                            {
                                latefeefinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Late Fees');
                                if(curreopp.nm_Semester__c != '1'){
                                dispatchAmtfinal = getDispatchAmt(oppMap.get(String.valueOf(currAcc.Current_semester__c)).Id, mapOfOppIdVsDO);
                                }
                                if(oppMap.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)) != null && feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures') != null)
                                {
                                   
                                    if(curreopp.StageName == 'Closed Won' && nmPaymentConfigMap.get('Re-Registration').LiveLecture_Startdate__c <= System.today() && curreopp.Is_Re_Registration_Payment__c == true){
                                        if( nmPaymentConfigMap.get('Re-Registration').LiveLecture_Startdate__c < System.today()){ 
                                            liveLectureAmtfinal = feeAmtReceived.get(String.valueOf(currAcc.Current_semester__c)).get('Live Lectures');
                                            
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
                if(cancellationdatesLst == null){
                    throw new IllegalArgumentException('Cancellation requested not within the date range');
                }
                Cancelation_Date__c  canObj = getCancellationDateDetails(nmPaymentConfigMap.get('Re-Registration'), cancellationdatesLst);
                if(canObj != null ){
                    if(canObj.From_Date__c <= System.today() && canObj.To_Date__c >= System.today()){  
                    } else{
                        throw new IllegalArgumentException('Cancellation requested not within the date range');
                    }
                }else{
                    throw new IllegalArgumentException('Cancellation requested not within the date range');
                }
             

                Decimal tutionFee = 0.0;
                if(oppMap.get('2') != null){
                    Decimal SemII = 0.0;
                    Opportunity opp2 = oppMap.get('2');
                    Opportunity opp3 = oppMap.get('3');
                    tutionFee = feeAmtReceived.get('2').get('tutionFee');
                    if(opp3.StageName != 'Closed Won' && opp3.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

                    }
                    else if(opp3.StageName == 'Closed Won' && opp3.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

                    }
                    else if(opp3.StageName != 'Closed Won' && opp3.nm_Fee_Type__c  == '3SemFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

                    }
                    else if(opp3.StageName == 'Closed Won' && opp3.nm_Fee_Type__c  == '3SemFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){

                    }
                    SemII = productPriceBook.get('Semester II'); 
                    System.debug('InsertRefundRecord123 lateral::');
                    lstRefundpayment.add(InsertRefundRecord(opp2,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemII,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));
                                

                }
                    else if(oppMap.get('3') != null){
                        Decimal SemIII = 0.0;
                        tutionFee = feeAmtReceived.get('3').get('tutionFee');
                        Opportunity opp3 = oppMap.get('3');
                        Opportunity opp4 = oppMap.get('4');
                        if(opp4.StageName != 'Closed Won' && opp4.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                        }
                        else if(opp4.StageName == 'Closed Won' && opp4.nm_Fee_Type__c  == 'AnnualFee' && nmPaymentConfigMap.get('Re-Registration').Payment_Window_EndDate__c.Date() > System.Today()){
                        }
                        SemIII = productPriceBook.get('Semester III'); 
                        System.debug('InsertRefundRecord123 lateral ::');
                        lstRefundpayment.add(InsertRefundRecord(opp3,ModeofPaymentSem1,tutionFee,AccountStage,documentsApproved,cancellationdatesLst,nmPaymentConfigMap.get('Admission'),SemIII,dispatchAmtfinal,liveLectureAmtfinal,latefeefinal,InstallmentdoneFlag,initalPaymentDone));          
                    }
                }
                }
            }
            else if(!studentStatusForRegistrationCancel.contains(accountIdVsMap.get(currAcc.Id).nm_StudentStatus__c)){ //for registration cancellation

                Map<String,Decimal> productPriceBook = new Map<String,Decimal>();
                List<PricebookEntry> priceBookEntrylst = new List<PricebookEntry>();
                priceBookEntrylst = mapOfIdVsPricebookEntry.get(currAcc.nm_Tagged_Pricebook__c+'-'+currAcc.nm_Program__c);
                if(priceBookEntrylst != null){
                    for(PricebookEntry priceBookEntryObj: priceBookEntrylst){
                        //if(priceBookEntryObj.Product2.Name == 'Semester I'){
                            //productPriceBook.put(priceBookEntryObj.Product2.Name , priceBookEntryObj.UnitPrice);
                            //SemI = priceBookEntryObj.UnitPrice;
                        //}

                        if(currAcc.nm_DefencePersonnel__c == 'Yes'){
                            productPriceBook.put(priceBookEntryObj.Product2.Name , priceBookEntryObj.UnitPrice * (1-defenceDiscount));
                        }
                        else if(currAcc.nm_DefencePersonnel__c == 'No'){

                            productPriceBook.put(priceBookEntryObj.Product2.Name , priceBookEntryObj.UnitPrice);
                        }
                    }
                }

                Map<String,NM_Payment_Form_Configuration__c> nmPaymentConfigMap = new Map<String,NM_Payment_Form_Configuration__c>();
                Boolean documentsApproved = false;
                Boolean InstallmentdoneFlag = false;
                Boolean initalPaymentDone = false;
                String accountOldStatus = accountIdVsMap.containsKey(currAcc.Id) ? accountIdVsMap.get(currAcc.Id).nm_StudentStatus__c : null;
                if(String.isNotBlank(accountOldStatus) && (accountOldStatus.endsWithIgnoreCase('Admission form & documents Approved') 
                || accountOldStatus.endsWithIgnoreCase('Admission Form & Documents Provisional'))) {
                    documentsApproved = true;
                }
                String AccountStage = currAcc.nm_StudentStatus__c;

                List<Opportunity> opplst = mapOfAccIdVsOpps.get(currAcc.Id);
                Decimal downPaymentLoan = 0.00;
                Decimal installmentFee = 0.00;
                Decimal initialPayment = 0.00;
                Decimal registrationFee = 0.00;
                Decimal tutionFee = 0.00;
                Decimal tutionFeeTotal = 0.00;
                Decimal liveLectures = 0.00;
                Decimal lateFee = 0.00;
                Date lastDateofProgramFeePayment ;
                String ModeofPaymentSem1 = '';
                Opportunity opp1 = new Opportunity();

                for(Opportunity oppObj:opplst){

                    if(oppObj.nm_Semester__c == '1')// && oppObj.StageName == 'Registration Done'
                    {
                        opp1 = oppObj;
                        Date liveLectureStartDate ;
                        String nmPaymentConfigId ;
                        String specData = '';
                        String typeData = '';
                        Decimal yearData = oppObj.nm_Year__c;
                        typeData = oppObj.nm_Program__r.nm_Type__c;
                        specData = oppObj.nm_Program__r.Specialisation__c; 

                        for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                        {  
                            if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppObj.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                                liveLectureStartDate = paymentConfig.LiveLecture_Startdate__c;
                                nmPaymentConfigId = paymentConfig.Id;
                                lastDateofProgramFeePayment = paymentConfig.Payment_Window_EndDate__c.Date();
                                if(oppObj.Is_Re_Registration_Payment__c == false){
                                    nmPaymentConfigMap.put('Admission',paymentConfig); 
                                }
                                                        
                            }
                        }

                        List<nm_Payment__c> paymentList = mapOFoppIdVsPayment.get(oppObj.Id);
                        if(paymentList != null){
                        for(nm_Payment__c payObj:paymentList){

                            if(validPaymentTypes.contains(payObj.nm_PaymentType__c) || payObj.nm_PaymentType__c.contains('-DownPayment')){
                                tutionFee += payObj.nm_Amount__c;
                                tutionFeeTotal += payObj.nm_Amount__c;
                            }
                            if(payObj.nm_PaymentType__c == 'Live Lectures'){

                                liveLectures += payObj.nm_Amount__c;
                            }
                            if(payObj.nm_PaymentType__c == 'Registration'){

                                registrationFee = payObj.nm_Amount__c;
                            }
                            if(payObj.nm_PaymentType__c == 'Initial Payment'){

                                initialPayment = payObj.nm_Amount__c;
                                initalPaymentDone = true;
                            }
                            if(payObj.nm_PaymentType__c == 'Installment'){

                                installmentFee = payObj.nm_Amount__c;
                                InstallmentdoneFlag = true;
                            }
                            if(payObj.nm_PaymentType__c == 'Late Fees'){

                                lateFee = payObj.nm_Amount__c;
                            }
                            if(payObj.nm_PaymentType__c.contains('-DownPayment')){

                                downPaymentLoan = payObj.nm_Amount__c;
                            }
                            ModeofPaymentSem1 = payObj.nm_ModeOfPayment__c;  
                        }
                        }
                    }
                }

                Boolean isInterviewSlotDeduction = false;
                Boolean isAdmissionformdocumentsApproved = false;
                Boolean tutionFeeGreaterThaninitialLessFullfee = false;
                Boolean tutionFeeGreaterThanFullfee = false;
                Boolean isInstallmentFee = false;
                Boolean isDownPaymentLoan = false;


                if(currAcc.nm_ProgramType__c == 'Master Programs' && currAcc.Program_Type__c == 'MBA (WX)'){ //'MBA(WX) Program'
                        if(currAcc.nm_StudentStatus__c == 'Document/s marked incorrect' || (currAcc.Interview_Slot__c != null && currAcc.Interview_Status__c == 'Rejected')){
                            //a.	No Deduction if candidate gets Rejected either due to documentation or due to Interview.

                        }
                        else if(currAcc.Interview_Slot__c == null){

                            //b.	Deduction of 1000/- if Interview slot is not selected.
                            tutionFee -= 1000;
                        }
                        else if(currAcc.Interview_Slot__c != null){
                            //c.	Deduction of 5000/- if Interview slot is selected. 
                            tutionFee -= 5000;
                            isInterviewSlotDeduction = true;
                        }
                    
                }
                else if(currAcc.nm_ProgramType__c  == 'Certificate Programs'){ // 'Certificate Program with GST'
                //'Admission form & documents Approved'

                if(tutionFee == initialPayment){

                    if(currAcc.nm_StudentStatus__c == 'Document/s marked incorrect' || currAcc.nm_StudentStatus__c == 'Documents Re-submitted' 
                || currAcc.nm_StudentStatus__c == 'Admission form & documents Approved' || currAcc.nm_StudentStatus__c == 'Admission Form & Documents Provisional' 
                || currAcc.nm_StudentStatus__c == 'Documents Disapproved'){
                    
                    tutionFee -= (800+(800*gstPercetage));
                    isAdmissionformdocumentsApproved =  true;
                }
                }
                else if(tutionFee > initialPayment && tutionFee < productPriceBook.get('FullFee')){

                    if(installmentFee > 0){

                        tutionFee -= (2500+(2500*gstPercetage));   
                        isInstallmentFee = true; 

                    }else if(downPaymentLoan > 0){

                        tutionFee -= (1000+(1000*gstPercetage));   
                        isDownPaymentLoan = true; 
                    }
                    tutionFeeGreaterThaninitialLessFullfee = true;
                }
                else if(tutionFee >= productPriceBook.get('FullFee') || tutionFee >= productPriceBook.get('FullFeeLoan')){

                    tutionFee -= (1000+(1000*gstPercetage));
                    tutionFeeGreaterThanFullfee = true;
                }

                }
                else if(progarmTypes.contains(currAcc.nm_ProgramType__c)){ 


                    if(tutionFee == initialPayment){

                        if(currAcc.nm_StudentStatus__c == 'Document/s marked incorrect' || currAcc.nm_StudentStatus__c == 'Documents Re-submitted' 
                        || currAcc.nm_StudentStatus__c == 'Admission form & documents Approved' || currAcc.nm_StudentStatus__c == 'Admission Form & Documents Provisional' 
                        || currAcc.nm_StudentStatus__c == 'Documents Disapproved'){
                            
                            tutionFee -= (800);
                            isAdmissionformdocumentsApproved = true;
                        }
                    }
                    else if(tutionFee > initialPayment && tutionFee < productPriceBook.get('FullFee')){
    
                        if(installmentFee > 0){
    
                            tutionFee -= (2500); 
                            isInstallmentFee = true;    
    
                        }else if(downPaymentLoan > 0){

                            tutionFee -= (1000);
                            isDownPaymentLoan = true;     
                        }

                        tutionFeeGreaterThaninitialLessFullfee = true;
                        
                    }
                    else if(tutionFee >= productPriceBook.get('FullFee') || tutionFee >= productPriceBook.get('FullFeeLoan')){
    
                        tutionFee -= (1000);
                        tutionFeeGreaterThanFullfee = true;
                    }

                }
                Map<String,Boolean> statusMap = new Map<String,Boolean>();
                statusMap.put('isInterviewSlotDeduction', isInterviewSlotDeduction);
                statusMap.put('isAdmissionformdocumentsApproved', isAdmissionformdocumentsApproved);
                statusMap.put('tutionFeeGreaterThaninitialLessFullfee', tutionFeeGreaterThaninitialLessFullfee);
                statusMap.put('tutionFeeGreaterThanFullfee', tutionFeeGreaterThanFullfee);
                statusMap.put('isInstallmentFee', isInstallmentFee);
                statusMap.put('isDownPaymentLoan', isDownPaymentLoan);

                lstRefundpayment.add(InsertRefundRecordForRegistration(opp1,ModeofPaymentSem1,tutionFeeTotal,AccountStage,documentsApproved,null,null,tutionFee,0.00,liveLectures,lateFee,InstallmentdoneFlag,initalPaymentDone,statusMap));
            }
        }

        if(lstRefundpayment != null && lstRefundpayment.size() > 0)
        {
            insert lstRefundpayment;
        }
    }
    catch(Exception e)
    {
        system.debug(e.getMessage());
        return e.getMessage();
    }
    return 'success';    
    }

    public static Decimal getDispatchAmt(String OpportunityId, Map<Id,List<Dispatch_Order__c>> mapOfOppIdVsDO){
        Decimal tutionFee = 0.0;
        List<Dispatch_Order__c> doLst = mapOfOppIdVsDO.get(OpportunityId);
        if(doLst != null){
        for(Dispatch_Order__c doObj : doLst)
        {
            if(doObj.Status_Of_Dispatch__c == 'Transit' || doObj.Status_Of_Dispatch__c == 'Delivered'){
                
                tutionFee = 5000.0;
            }
            else {
                tutionFee = 1000.0;
            }
        }}
        return tutionFee;
    }

    public static nmRefund_Payment__c InsertRefundRecord(Opportunity objOpps,String ModeofPaymentSem1,Decimal totalAmountTorefund,String AccountStage,Boolean documentsApproved, 
    List<Cancelation_Date__c> cancellationdatesLst, NM_Payment_Form_Configuration__c paymentConfig,Decimal SemI,Decimal dispatchAmt,Decimal liveLectures,Decimal lateFee,
    Boolean InstallmentdoneFlag, Boolean initalPaymentDone){
        

        System.debug('objOpps.Id ::'+objOpps.Id+ 'objOpps'+objOpps);
        System.debug('paymentConfig'+paymentConfig);
        System.debug('totalAmountTorefund ::'+totalAmountTorefund+' ModeofPaymentSem1 ::'+ModeofPaymentSem1+' AccountStage:: '+AccountStage);
        System.debug(' SemI:: '+SemI+ ' dispatchAmt :: '+dispatchAmt+' liveLectures:: '+liveLectures+' lateFee:: '+lateFee);
        System.debug('cancellationdatesLst ::'+cancellationdatesLst);

        Set<String> studentStatusForRegistrationCancel = new Set<String>{
            'Confirmed',
            'Registration Cancelled',
            'Not Eligible',
            'De-Registered',
            'Admission Cancelled',
            'Closed Lost',
            'Rejected',
            'Aluminus',
            'Rusticated',
            'Alumni'
        };
        Decimal gstPercetage = 0.18;
        nmRefund_Payment__c objRefundPayment=new nmRefund_Payment__c();

        objRefundPayment.Total_Refund_Amount__c=totalAmountTorefund+lateFee +liveLectures ;
        objRefundPayment.nm_Payment_Status__c='Refund Initiated';
        objRefundPayment.Account__c=objOpps.Accountid; 
        objRefundPayment.Study_Kit__c= dispatchAmt > 0.00 ? true : false;//objOpps.Dispatch_Order_For_Student__c;
        objRefundPayment.nm_Information_Center__c=objOpps.nm_InformationCenters__c;
        objRefundPayment.nm_Student_E_mail__c=objOpps.Account.PersonEmail;
        objRefundPayment.Documents_Approved__c=documentsApproved;
        objRefundPayment.Mode_Of_Payment__c=ModeofPaymentSem1;
        objRefundPayment.Instalment_done__c= InstallmentdoneFlag;
        objRefundPayment.Initial_Payment_done__c=initalPaymentDone;
        
        
        objRefundPayment.Type_of_Refund__c = 'Admission Cancellation';

        objRefundPayment.Opportunity__c = objOpps.id;

        if(paymentConfig != null ){

        Cancelation_Date__c  canObj = getCancellationDateDetails(paymentConfig, cancellationdatesLst);
        System.debug('canObj ::: '+canObj);
        Decimal amt = 0.0;
        Date  fromCanceDate ;
       // Cancelation_Date__c canDateObj ;
        if(canObj != null ){
            System.debug('canObj.From_Date__c  :: '+canObj.From_Date__c  +' canObj.Amount__c  :: '+canObj.Amount__c +' canObj.To_Date__c  :: '+canObj.To_Date__c);
                if(canObj.From_Date__c <= System.today() && canObj.To_Date__c >= System.today()){

                    if(canObj.Amount__c != null && canObj.Amount__c > 0.0){
                        System.debug('canObj.Percentage__c123 :: '+canObj.Amount__c +' SemI :: '+SemI);
                        amt = canObj.Amount__c; 
                        if(objOpps.Account.nm_ProgramType__c == 'Certificate Programs'){
                            amt += amt*gstPercetage;
                        }
                    } else if( canObj.Percentage__c != null && canObj.Percentage__c > 0.0){
                        System.debug('canObj.Percentage__c123 :: '+canObj.Percentage__c +' SemI :: '+SemI);
                        amt = SemI * (canObj.Percentage__c/100);
                        if(objOpps.Account.nm_ProgramType__c == 'Certificate Programs'){
                            amt += amt*gstPercetage;
                        }
                    }
                    if(canObj.From_Date__c != null){
                    
                        fromCanceDate  = canObj.From_Date__c;
                    }
                    if(canObj.Admission_Fee__c == true){
                        amt = SemI;
                        if(objOpps.Account.nm_ProgramType__c == 'Certificate Programs'){
                            amt += amt*gstPercetage;
                        }
                    }
                
                }
        }

        objRefundPayment.Additional_Deduction__c  = amt + liveLectures ;
        String additionDeduction = '';
        if(amt > 0.0 ){
            additionDeduction = 'TutionFee Deduction,';
        }
        if(liveLectures > 0.0){
            additionDeduction += 'LiveLectures Deduction,';
        }

        objRefundPayment.Description_for_addition_Deduction__c = additionDeduction; // after '+fromCanceDate 30.9.2024';  //From_Date__c
        objRefundPayment.Cancellation_Date__c = canObj != null ? canObj.Id : null;
        objRefundPayment.WaivedOff__c = true; //need to be checked


        objRefundPayment.CancelationDate_Deduction__c = amt;
        //refundPaymentObj.CareerService_Fee_Deduction__c = mapOffeetypevsAmtMain.get('careerServiceFee') - careerServiceFee;
        objRefundPayment.Late_Fee_Deduction__c = lateFee;
        objRefundPayment.LiveLecture_Fee_Deduction__c = liveLectures;
        objRefundPayment.Tution_Fee_Deduction__c = amt;
        objRefundPayment.StudyKit_Deduction__c = dispatchAmt;  /// study kit deduction
        }else{
            throw new IllegalArgumentException('Cancellation requested not within the date range');
        }
        return objRefundPayment;
    }


    public static nmRefund_Payment__c InsertRefundRecordForRegistration(Opportunity objOpps,String ModeofPaymentSem1,Decimal totalAmountTorefund,String AccountStage,Boolean documentsApproved, 
    List<Cancelation_Date__c> cancellationdatesLst, NM_Payment_Form_Configuration__c paymentConfig,Decimal SemI,Decimal dispatchAmt,Decimal liveLectures,Decimal lateFee,
    Boolean InstallmentdoneFlag, Boolean initalPaymentDone,Map<String,Boolean> statusMap){
        

        System.debug('objOpps.Id ::'+objOpps.Id+ 'objOpps'+objOpps);
        System.debug('paymentConfig'+paymentConfig);
        System.debug('totalAmountTorefund ::'+totalAmountTorefund+' ModeofPaymentSem1 ::'+ModeofPaymentSem1+' AccountStage:: '+AccountStage);
        System.debug(' SemI:: '+SemI+ ' dispatchAmt :: '+dispatchAmt+' liveLectures:: '+liveLectures+' lateFee:: '+lateFee);
        System.debug('cancellationdatesLst ::'+cancellationdatesLst);

        Set<String> studentStatusForRegistrationCancel = new Set<String>{
            'Confirmed',
            'Registration Cancelled',
            'Not Eligible',
            'De-Registered',
            'Admission Cancelled',
            'Closed Lost',
            'Rejected',
            'Aluminus',
            'Rusticated',
            'Alumni'
        };
        Decimal gstPercetage = 0.18;
        nmRefund_Payment__c objRefundPayment=new nmRefund_Payment__c();

        objRefundPayment.Total_Refund_Amount__c=totalAmountTorefund;
        objRefundPayment.nm_Payment_Status__c='Refund Initiated';
        objRefundPayment.Account__c=objOpps.Accountid; 
        objRefundPayment.Study_Kit__c= dispatchAmt > 0.00 ? true : false;//objOpps.Dispatch_Order_For_Student__c;
        objRefundPayment.nm_Information_Center__c=objOpps.nm_InformationCenters__c;
        objRefundPayment.nm_Student_E_mail__c=objOpps.Account.PersonEmail;
        objRefundPayment.Documents_Approved__c=documentsApproved;
        objRefundPayment.Mode_Of_Payment__c=ModeofPaymentSem1;
        objRefundPayment.Instalment_done__c= InstallmentdoneFlag;
        objRefundPayment.Initial_Payment_done__c=initalPaymentDone;
        objRefundPayment.Type_of_Refund__c = 'Registration Cancellation';

        objRefundPayment.Opportunity__c = objOpps.id;
        objRefundPayment.Additional_Deduction__c = SemI > 0 ? totalAmountTorefund-SemI : 0;
        String additionDeduction = '';
        if(statusMap.get('isInterviewSlotDeduction') == true){
            additionDeduction += 'InterviewSlotDeduction,';
        }
        if(statusMap.get('isAdmissionformdocumentsApproved') == true){
            additionDeduction += 'DocumentsApprovedDeduction,';
        }
        if(statusMap.get('tutionFeeGreaterThaninitialLessFullfee') == true){
            additionDeduction += 'TutionfeeDeduction,';
        }
        if(statusMap.get('tutionFeeGreaterThanFullfee') == true){
            additionDeduction += 'TutionfeeDeduction,';
        }
        if(statusMap.get('isInstallmentFee') == true){
            additionDeduction += 'InstallmentFeeDeduction,';
        }
        if(statusMap.get('isDownPaymentLoan') == true){
            additionDeduction += 'DownPaymentLoanDeduction,';
        }
        System.debug('additionDeduction'+additionDeduction);
        System.debug('statusMap'+statusMap);
        objRefundPayment.Description_for_addition_Deduction__c = additionDeduction;
        objRefundPayment.WaivedOff__c = true;

        return objRefundPayment;
    }

    public static  Cancelation_Date__c getCancellationDateDetails(NM_Payment_Form_Configuration__c paymentConfig, List<Cancelation_Date__c> cancellationdatesLst){

        Cancelation_Date__c cancelDtObj ;
        String nmPaymentConfigId  = paymentConfig.Id;
        System.debug('nmPaymentConfigId ::: '+nmPaymentConfigId);
        System.debug('cancellationdatesLst123 ::: '+cancellationdatesLst);
        
        for(Cancelation_Date__c cancelDateObj : cancellationdatesLst)
        {
            System.debug('cancelDateObj.NM_Payment_Form_Configuration__c  ::: '+cancelDateObj.NM_Payment_Form_Configuration__c );
            if(cancelDateObj.NM_Payment_Form_Configuration__c == nmPaymentConfigId){
                cancelDtObj = cancelDateObj;
            }
        }
        System.debug('cancelDtObj123 ::: '+cancelDtObj);
        return cancelDtObj;
    }
}