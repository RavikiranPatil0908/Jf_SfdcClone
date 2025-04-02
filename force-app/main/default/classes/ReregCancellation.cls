public class ReregCancellation {

    public static boolean IsAfterUpdateRunOnce = false;

    public static void doReregistrationCancellation(List<Opportunity> triggerNew,map<id,Opportunity> oldMap){
        if(IsAfterUpdateRunOnce){
            return;
        }        
        IsAfterUpdateRunOnce = true;
        
        Set<Id> opportunityIds = oldMap.keySet();
        List<Id> accountIds = new List<Id>();
        System.debug('triggerNew :  '+triggerNew.size());
        for(Opportunity oppCurr : triggerNew)
        {
            accountIds.add(oppCurr.AccountId);
        }
        opportunityIds = new Set<Id>();

        Decimal defenceDiscount = 0.2; // defence discount 20%
        Set<String> Pricebook2IdLst = new Set<String>();
        Set<String> ProgramLst = new Set<String>();
        List<Opportunity> lstOpportunity = [SELECT Id ,AccountId,nm_Semester__c,CareerServiceProgram__c, nm_Program__r.nm_Type__c, nm_Program__r.Specialisation__c,pricebook2Id ,nm_Program__c, Account.nm_DefencePersonnel__c,(Select Id, name,ListPrice,UnitPrice,ActualSalePrice__c,Product_Name_text__c,ProgramName2__c From OpportunityLineItems) FROM Opportunity WHERE AccountId IN : accountIds];
        Map<Id,List<Opportunity>> mapOfAccIdVsOpps = new Map<Id,List<Opportunity>>();
        for(Opportunity accObj : lstOpportunity) {

            if(mapOfAccIdVsOpps.containsKey(accObj.AccountId))
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

        nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
        List<PricebookEntry> priceBookLst = [SELECT Id, Product2Id, Product2.Name, UnitPrice , Pricebook2Id, Product2.nm_Program__c FROM PricebookEntry WHERE (Pricebook2Id IN : Pricebook2IdLst OR Product2.nm_Program__c IN : ProgramLst) AND Product2.IsActive = true AND Product2.IsActive = true];
        Map<String,List<PricebookEntry>> mapOfIdVsPricebookEntry = new Map<String,List<PricebookEntry>>();
        for(PricebookEntry priceBookEntryObj : priceBookLst) {

            if(mapOfIdVsPricebookEntry.containsKey(priceBookEntryObj.Pricebook2Id+'-'+priceBookEntryObj.Product2.nm_Program__c))
            {
                mapOfIdVsPricebookEntry.get(priceBookEntryObj.Pricebook2Id+'-'+priceBookEntryObj.Product2.nm_Program__c).add(priceBookEntryObj);
            }
            else
            {
                List<PricebookEntry> oppList = new List<PricebookEntry>();
                oppList.add(priceBookEntryObj);
                mapOfIdVsPricebookEntry.put(priceBookEntryObj.Pricebook2Id+'-'+priceBookEntryObj.Product2.nm_Program__c,oppList);
            }
        }

        List<nmRefund_Payment__c> refundPaymentlst = [SELECT Id,Opportunity__c,Account__c, Type_of_Refund__c FROM nmRefund_Payment__c WHERE Opportunity__c IN : opportunityIds ];
        Map<Id,List<nmRefund_Payment__c>> mapOfOppIdVsRefundPayment = new Map<Id,List<nmRefund_Payment__c>>();
        for(nmRefund_Payment__c accObj : refundPaymentlst) {

            if(mapOfOppIdVsRefundPayment.containsKey(accObj.Opportunity__c))
            {
                mapOfOppIdVsRefundPayment.get(accObj.Opportunity__c).add(accObj);
            }
            else
            {
                List<nmRefund_Payment__c> oppList = new List<nmRefund_Payment__c>();
                oppList.add(accObj);
                mapOfOppIdVsRefundPayment.put(accObj.Opportunity__c,oppList);
            }
        }
        List<Dispatch_Order__c> dispatchOrderlst  = [SELECT Id , Status_Of_Dispatch__c ,Opportunity__c FROM Dispatch_Order__c WHERE Dispatch_Order__c.Opportunity__c IN : opportunityIds ];
        List<NM_Payment_Form_Configuration__c> paymentConfiglst = [SELECT Id,Program_Category__c,Payment_Type__c,Session__c,Current_Admission_Year__c,Program_Type__c, LiveLecture_Startdate__c,Price_Book__c FROM NM_Payment_Form_Configuration__c WHERE Payment_Type__c = 'Re-Registration'];
        nmRefund_Payment__c refundPaymentObj = new nmRefund_Payment__c();

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


        List<nm_Payment__c> paymentlst = [SELECT Id , nm_ModeOfPayment__c,nm_OpportunityNew__c, nm_PaymentStatus__c,nm_PaymentType__c, nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c in : opportunityIds AND (nm_PaymentStatus__c = 'Payment Made' OR nm_PaymentStatus__c = 'Payment Approved')];

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
        
        List<Career_Service_Program__c> careerServicelst = [SELECT Id , Stage__c, Opportunity__c,Account__c, CareerServiceProgram__c,Current_semester__c FROM Career_Service_Program__c WHERE Opportunity__c in : opportunityIds AND Stage__c = 'Payment Done'];
        
        Map<Id,Career_Service_Program__c> mapOFCareerseriIdVsCareerService= new Map<Id,Career_Service_Program__c>();
        for(Career_Service_Program__c csObj : careerServicelst)
        {
                mapOFCareerseriIdVsCareerService.put(csObj.Id,csObj);
        }
        
        List<nm_Payment__c> paymentCareerServicelst = [SELECT Id , nm_ModeOfPayment__c,nm_OpportunityNew__c, nm_PaymentStatus__c,nm_PaymentType__c, nm_Amount__c,CareerServiceProgram__c FROM nm_Payment__c WHERE CareerServiceProgram__c in : mapOFCareerseriIdVsCareerService.keySet() AND (nm_PaymentStatus__c = 'Payment Made' OR nm_PaymentStatus__c = 'Payment Approved') AND (nm_PaymentType__c = 'Career Service')];
        Map<Id,List<nm_Payment__c>> mapOFopportunityIdVsCareerServicePayment= new Map<Id,List<nm_Payment__c>>();
        for(nm_Payment__c paymtObj : paymentCareerServicelst)
        {

            if(mapOFopportunityIdVsCareerServicePayment.containsKey(mapOFCareerseriIdVsCareerService.get(paymtObj.CareerServiceProgram__c).Opportunity__c))
            {
                mapOFopportunityIdVsCareerServicePayment.get(mapOFCareerseriIdVsCareerService.get(paymtObj.CareerServiceProgram__c).Opportunity__c).add(paymtObj);
            }
            else
            {
                List<nm_Payment__c> csList = new List<nm_Payment__c>();
                csList.add(paymtObj);
                mapOFopportunityIdVsCareerServicePayment.put(mapOFCareerseriIdVsCareerService.get(paymtObj.CareerServiceProgram__c).Opportunity__c,csList);
            }
        }
        List<Cancelation_Date__c> cancellationdatesLst =[SELECT Id, Amount__c, From_Date__c, To_Date__c, Percentage__c,NM_Payment_Form_Configuration__c FROM Cancelation_Date__c WHERE From_Date__c <= TODAY AND To_Date__c >= TODAY]; 
        List<nmRefund_Payment__c> paymentRefundInsertBucket = new List<nmRefund_Payment__c>();
        List<Opportunity> OpportunityInsertBucket = new List<Opportunity>();
        List<Opportunity> OpportunityUpdateBucket = new List<Opportunity>();
        List<Career_Service_Program__c> CareerServiceUpdateBucket = new List<Career_Service_Program__c>();
        for(Opportunity oppCurr : triggerNew)
        {   
            System.debug('oppCurr.PreviousStageName__c :: '+oppCurr.PreviousStageName__c);
           System.debug('mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id) :: '+mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id));
           System.debug('oppCurr.nm_Semester__c :: '+oppCurr.nm_Semester__c);
           System.debug('condition check :: '+ oppCurr.PreviousStageName__c == 'Closed Won');
            //Payment Type = 'Admission'  ,  'Registration', 'Live Lectures',  'Late Fees', 'Career Service'
            //annualfee,annualfeeloan, multiplesemfee,fullfee
            Decimal tutionFee = 0.0;
            Decimal registrationFee = 0.0;
            Decimal liveLecturesFee = 0.0;
            Decimal lateFee = 0.0;
            Decimal careerServiceFee = 0.0;
            Opportunity oppOld = oldMap.get(oppCurr.Id);
            Boolean isDispatched = false;
            //String modeofpayment = '';
            Decimal TotalAmtRefund = 0.0;
            Date liveLectureStartDate ;
            String nmPaymentConfigId ;
            Decimal cancelDateAmt = 0.0;
            if(oppCurr.StageName == 'Re-registration Cancelled' && oppOld.StageName != oppCurr.StageName && oppCurr.Is_Re_Registration_Payment__c == true)
            {
                String specData = '';
                String typeData = '';
                Decimal yearData = oppCurr.nm_Year__c;
                
                
                Map<String,Map<String,Decimal>> mapOFoppSemVsPrice = new Map<String,Map<String,Decimal>>();

                for(Opportunity oppnow : mapOfAccIdVsOpps.get(oppCurr.AccountId))
                {
                    Map<String,Decimal> mapOFoppProductNameVsPrice = new Map<String,Decimal>();
                    mapOFoppProductNameVsPrice.put('Tuition Fees',0.0);
                    mapOFoppProductNameVsPrice.put('Live Lectures',0.0);
                    mapOFoppProductNameVsPrice.put('Annual',0.0);
                    List<OpportunityLineItem> oppLineItemList = oppnow.OpportunityLineItems;
                    for(OpportunityLineItem oppLineItem : oppLineItemList)
                    {
                        if( oppnow.Account.nm_DefencePersonnel__c == 'Yes')
                        {
                            if(oppLineItem.ProgramName2__c == 'Tuition Fees'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.UnitPrice); // salesprice(UnitPrice)
                            }
                            if(oppLineItem.ProgramName2__c == 'Live Lectures'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.ActualSalePrice__c);
                            }
                            if(oppLineItem.ProgramName2__c == 'Annual'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.ActualSalePrice__c);
                            }

                        } else if(oppnow.Account.nm_DefencePersonnel__c == 'No'){

                            if(oppLineItem.ProgramName2__c == 'Tuition Fees'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.ListPrice);
                            }
                            if(oppLineItem.ProgramName2__c == 'Live Lectures'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.ActualSalePrice__c);
                            }
                            if(oppLineItem.ProgramName2__c == 'Annual'){
                                mapOFoppProductNameVsPrice.put(oppLineItem.ProgramName2__c,oppLineItem.ActualSalePrice__c);
                            }

                        }
                        
                        
    
                    }
                    mapOFoppSemVsPrice.put(oppnow.nm_Semester__c, mapOFoppProductNameVsPrice);
                    typeData = oppnow.nm_Program__r.nm_Type__c;
                    specData = oppnow.nm_Program__r.Specialisation__c;
                }
                System.debug(mapOFoppSemVsPrice);
                
                for(NM_Payment_Form_Configuration__c paymentConfig : paymentConfiglst)
                {  
                    if(paymentConfig.Program_Category__c == typeData && paymentConfig.Program_Type__c == specData && paymentConfig.Session__c == oppCurr.nm_Session__c && paymentConfig.Current_Admission_Year__c == yearData+''){
                        liveLectureStartDate = paymentConfig.LiveLecture_Startdate__c;
                        nmPaymentConfigId = paymentConfig.Id;                        
                    }

                }

                Map<String,Decimal> mapOffeetypevsAmtMain = getamtOpp(mapOfAccIdVsOpps,mapOFoppIdVsPayment, oppCurr, mapOFopportunityIdVsCareerServicePayment);
                tutionFee = mapOffeetypevsAmtMain.get('tutionFee');
                liveLecturesFee = mapOffeetypevsAmtMain.get('liveLecturesFee');
                lateFee = mapOffeetypevsAmtMain.get('lateFee');
                careerServiceFee = mapOffeetypevsAmtMain.get('careerServiceFee');


                // if((mapOfOppIdVsRefundPayment != null && (mapOfOppIdVsRefundPayment.get(oppCurr.Id) == null || mapOfOppIdVsRefundPayment.get(oppCurr.Id).Size() == 0))|| mapOfOppIdVsRefundPayment == null)
                // {
                // livelectureopted : Current Semester LIVE lecture fee;  ---livelectdate in nm payment form config    ::::::::::   LiveLecture_Startdate
                // study material not issued : 1000,study material issued : 5000    --- 
                    // career service full deduction 
                //   oppCurr.nm_Semester__c; //semester
                //  oppCurr.Sem_Fee__c; // amt
                    if((oppCurr.nm_Fee_Type__c).contains('Considered'))
                    {

                        System.debug('oppCurr.Account.nm_DefencePersonnel__c :: '+mapOfAccIdVsOpps.get(oppCurr.AccountId)[0].Account.nm_DefencePersonnel__c);

                            if(oppCurr.nm_Fee_Type__c == 'AnnualFee-Considered' || oppCurr.nm_Fee_Type__c == 'AnnualFeeLoan'){
                                if(oppCurr.nm_Semester__c == '2'){

                                    Decimal sem1amt = mapOFoppSemVsPrice.get('1').get('Tuition Fees');
                                    tutionFee -= sem1amt;
                                    System.debug('oppOld.StageName  :: '+oppOld.StageName +'oppCurr.StageName ::'+oppCurr.StageName+' oppCurr.Id ::'+oppCurr.Id);
                                    if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){

                                        Decimal dispatchAmt = 0.0;
                                        dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                        tutionFee -= dispatchAmt;
                                        if(dispatchAmt >= 5000)
                                        {
                                            isDispatched = true;
                                        }

                                        if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                        {
                                            System.debug('liveLectureStartDate :: '+liveLectureStartDate+' liveLecturesFee :: '+liveLecturesFee);
                                            System.debug('li :: '+mapOFoppSemVsPrice.get('2').get('Live Lectures'));
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                        }  
                                    }
                                        if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('1').get('Live Lectures');
                                        }

                                }

                                if(oppCurr.nm_Semester__c == '3'){

                                        Decimal sem2amt = mapOFoppSemVsPrice.get('2').get('Tuition Fees');

                                        tutionFee -= sem2amt;
                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){

                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }  
           
                                        if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                        {
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                        }  
                                        }
                                        if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                        }
                                       

                                }
                                else if(oppCurr.nm_Semester__c == '4'){
                                    System.debug('oppCurr.nm_Semester__c : '+oppCurr.nm_Semester__c);
                                    System.debug('oppCurr.nm_Semester__c == 4: '+oppCurr.nm_Semester__c == '4');
                                    Decimal sem3amt = mapOFoppSemVsPrice.get('3').get('Tuition Fees');
                                    tutionFee -= sem3amt;
                                    if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){
                                    
                                        Decimal dispatchAmt = 0.0;
                                        dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                        tutionFee -= dispatchAmt;
                                        if(dispatchAmt >= 5000)
                                        {
                                            isDispatched = true;
                                        }
                 
                                    if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                    {
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('4').get('Live Lectures');
                                    }
                                    }
                                    if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                    }
                                    

                                }

                            }
                            else if(oppCurr.nm_Fee_Type__c == 'MultipleSemFee-Considered')
                            {
                                if(oppCurr.nm_Semester__c == '3'){

                                        Decimal sem2amt = mapOFoppSemVsPrice.get('2').get('Tuition Fees');
                                        tutionFee -= sem2amt;

                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){

                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }
               
                                            if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                            {
                                                liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                            }
                                        }
                                        if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                        }
                                }
                                else if(oppCurr.nm_Semester__c == '4'){

                                    Decimal sem2amt = mapOFoppSemVsPrice.get('2').get('Tuition Fees');
                                        tutionFee -= sem2amt;
                                        Decimal sem3amt = mapOFoppSemVsPrice.get('3').get('Tuition Fees');
                                        tutionFee -= sem3amt;

                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){

                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }
                              
                                            if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                            {
                                                liveLecturesFee -= mapOFoppSemVsPrice.get('4').get('Live Lectures');
                                            }
                                        }
                                        if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                        }
                                }
                            }
                            else if(oppCurr.nm_Fee_Type__c == 'FullFee-Considered')
                            {
                                if(oppCurr.nm_Semester__c == '2'){

                                    Decimal sem1amt = mapOFoppSemVsPrice.get('1').get('Tuition Fees');
                                        tutionFee -= sem1amt;
                                    
                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){
                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }
                         

                                            if(liveLectureStartDate <= System.Today()  && liveLecturesFee > 0.0)
                                            {
                                                liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                            }
                                        }
                                        if(liveLecturesFee > 0.0){
                                        liveLecturesFee -= mapOFoppSemVsPrice.get('1').get('Live Lectures');
                                        }
                                }
                                if(oppCurr.nm_Semester__c == '3'){
                                        // Decimal sem1amt = mapOFoppSemVsPrice.get('1').get('Tuition Fees');
                                        // tutionFee -= sem1amt;
                                        // Decimal sem2amt = mapOFoppSemVsPrice.get('2').get('Tuition Fees');
                                        // tutionFee -= sem2amt;
                                        Decimal Annual = 0.00;
                                        List<PricebookEntry> priceBookEntrylst = new List<PricebookEntry>();
                                        priceBookEntrylst = mapOfIdVsPricebookEntry.get(oppCurr.Pricebook2Id+'-'+oppCurr.nm_Program__c);
                                        if(priceBookEntrylst != null){
                                            for(PricebookEntry priceBookEntryObj: priceBookEntrylst){
                                                if(priceBookEntryObj.Product2.Name == 'Annual'){
                                                    if( mapOfAccIdVsOpps.get(oppCurr.AccountId)[0].Account.nm_DefencePersonnel__c == 'Yes')
                                                    {
                                                        Annual = priceBookEntryObj.UnitPrice * (1-defenceDiscount);
                                                    }
                                                    else if(mapOfAccIdVsOpps.get(oppCurr.AccountId)[0].Account.nm_DefencePersonnel__c == 'No')
                                                    {
                                                        Annual = priceBookEntryObj.UnitPrice;
                                                    }
                                                }
                                            }
                                        }
 
                                        tutionFee -= Annual;

                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){
                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }
                           
                                            if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                            {
                                                liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                            }
                                        }
                                        if(liveLecturesFee > 0.0){
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('1').get('Live Lectures');
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                        }
                                        

                                }
                                else if(oppCurr.nm_Semester__c == '4'){
                                        Decimal sem1amt = mapOFoppSemVsPrice.get('1').get('Tuition Fees');
                                        tutionFee -= sem1amt;
                                        Decimal sem2amt = mapOFoppSemVsPrice.get('2').get('Tuition Fees');
                                        tutionFee -= sem2amt;
                                        Decimal sem3amt = mapOFoppSemVsPrice.get('3').get('Tuition Fees');
                                        tutionFee -= sem3amt;
                                    
                                        if(oppOld.StageName == 'Closed Won' && oppOld.StageName != oppCurr.StageName ){
                                            Decimal dispatchAmt = 0.0;
                                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                                            tutionFee -= dispatchAmt;
                                            if(dispatchAmt >= 5000)
                                            {
                                                isDispatched = true;
                                            }
                                      
                                            if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                                            {
                                                liveLecturesFee -= mapOFoppSemVsPrice.get('4').get('Live Lectures');
                                            }
                                        }
                                        if(liveLecturesFee > 0.0){
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('1').get('Live Lectures');
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('2').get('Live Lectures');
                                            liveLecturesFee -= mapOFoppSemVsPrice.get('3').get('Live Lectures');
                                        }

                                }

                            }

                    }
                    else if( oppCurr.nm_Fee_Type__c != '' && !(oppCurr.nm_Fee_Type__c).contains('Considered'))
                    {

                        if( oppOld.StageName == 'Closed Won'){

                            Decimal dispatchAmt = 0.0;
                            dispatchAmt = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);
                            tutionFee -= dispatchAmt;
                            if(dispatchAmt >= 5000)
                            {
                                isDispatched = true;
                            }
                            
                         
                            
                            if(liveLectureStartDate <= System.Today() && liveLecturesFee > 0.0)
                            {
                                liveLecturesFee -= mapOFoppSemVsPrice.get(oppCurr.nm_Semester__c).get('Live Lectures');
                            }

                       

                        }if(oppOld.StageName != 'Closed Won'){

                        }
                    }

                    if(careerServiceFee != null && careerServiceFee > 0){

                        if(oppCurr.Closed_Won_Date__c.addDays(10) <= System.Today() && careerServiceFee > 0.0)
                        {
                         careerServiceFee -= careerServiceFee;
                        }else if( careerServiceFee > 0.0) {
                            careerServiceFee -= 1500;
                        }
                    }
                  //  cancelDateAmt = getCancellationDateAmt(nmPaymentConfigId,tutionFee,cancellationdatesLst);

                    Decimal amt = 0.0;
                    Cancelation_Date__c canObjApplicable = new Cancelation_Date__c();
                    if(cancellationdatesLst != null && cancellationdatesLst.size() > 0){
                        for(Cancelation_Date__c canObj : cancellationdatesLst)
                        {
                            if(canObj.NM_Payment_Form_Configuration__c == nmPaymentConfigId){
                                if(canObj.Amount__c != null && canObj.Amount__c > 0.0){

                                    amt = canObj.Amount__c; 
                                } 
                                // else if( canObj.Percentage__c != null && canObj.Percentage__c > 0.0){
                                //     amt = tutionFee * (canObj.Percentage__c)/100;
                                // }
                                canObjApplicable = canObj;
                            }
                            
                        }
                    }
                   // return amt;
                    cancelDateAmt = amt;
                    

                    //TotalAmtRefund = tutionFee+liveLecturesFee+lateFee - cancelDateAmt ; // +careerServiceFee; // Amt to be returned after deduction
                    TotalAmtRefund = mapOffeetypevsAmtMain.get('liveLecturesFee')+mapOffeetypevsAmtMain.get('tutionFee') +mapOffeetypevsAmtMain.get('lateFee') +mapOffeetypevsAmtMain.get('careerServiceFee'); 
                    if(mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id) == null){
                        TotalAmtRefund += careerServiceFee;
                    }
                    refundPaymentObj.islivelectRefunded__c = liveLecturesFee >0.0 ? true : false;
                    refundPaymentObj.isCareerServiceRefunded__c = careerServiceFee > 0.0 ? true : false;
                    refundPaymentObj.Account__c = oppCurr.AccountId;
                    refundPaymentObj.Mode_Of_Payment__c = getPaymentMode(mapOfAccIdVsOpps, mapOFoppIdVsPayment, oppCurr);//modeofpayment
                    refundPaymentObj.Opportunity__c = oppCurr.Id;
                    refundPaymentObj.Status__c = 'Refund Request Created';
                    refundPaymentObj.Study_Kit__c = isDispatched;
                    refundPaymentObj.Total_Refund_Amount__c = TotalAmtRefund;
                    refundPaymentObj.Type_of_Refund__c = 'Re-registration Cancelled';
                    refundPaymentObj.nm_Information_Center__c = oppCurr.Account.nm_Centers__r.Id;
                    refundPaymentObj.nm_Payment_Status__c = 'Refund Initiated';
                    refundPaymentObj.nm_Student_E_mail__c = oppCurr.nm_StudentEmail__c;


                    refundPaymentObj.Additional_Deduction__c = (mapOffeetypevsAmtMain.get('liveLecturesFee')-liveLecturesFee)+(mapOffeetypevsAmtMain.get('tutionFee') - (tutionFee + getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO)))+(mapOffeetypevsAmtMain.get('careerServiceFee') - careerServiceFee);
                    String DescriptionforadditionDeduction = '';
                    if((mapOffeetypevsAmtMain.get('liveLecturesFee')-liveLecturesFee) > 0)
                    {
                        DescriptionforadditionDeduction += 'liveLecturesFee,';
                    }
                    if( (mapOffeetypevsAmtMain.get('tutionFee') - (tutionFee + getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO))) > 0)
                    {
                        DescriptionforadditionDeduction += 'tutionFee,';
                    }
                    if((mapOffeetypevsAmtMain.get('careerServiceFee') - careerServiceFee)  >0 ){

                        DescriptionforadditionDeduction += 'careerServiceFee,';
                    }

                    refundPaymentObj.Description_for_addition_Deduction__c = DescriptionforadditionDeduction;

                    refundPaymentObj.Addmission_Deduction__c = cancelDateAmt;


                    refundPaymentObj.CancelationDate_Deduction__c = cancelDateAmt;
                    refundPaymentObj.CareerService_Fee_Deduction__c = mapOffeetypevsAmtMain.get('careerServiceFee') - careerServiceFee;
                    refundPaymentObj.Late_Fee_Deduction__c = mapOffeetypevsAmtMain.get('lateFee')-lateFee;
                    refundPaymentObj.LiveLecture_Fee_Deduction__c = mapOffeetypevsAmtMain.get('liveLecturesFee')-liveLecturesFee;
                    refundPaymentObj.Tution_Fee_Deduction__c = mapOffeetypevsAmtMain.get('tutionFee') - (tutionFee + getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO));
                    refundPaymentObj.Cancellation_Date__c = canObjApplicable != null ? canObjApplicable.Id : null;
                    refundPaymentObj.StudyKit_Deduction__c = getDispatchAmt(oppCurr.Id, mapOfOppIdVsDO);  /// study kit deduction

                    if((oppCurr.nm_Fee_Type__c == 'FullFee-Considered' || oppCurr.nm_Fee_Type__c == 'AnnualFee-Considered') && oppCurr.nm_Semester__c == '4'){
                        Opportunity futureOpp = getNextSemOpportunity(oppCurr);
                        OpportunityInsertBucket.add(futureOpp);
                    }
                    else
                    {
                        //insert refundPaymentObj;
                        paymentRefundInsertBucket.add(refundPaymentObj);
                    }
                    

                    if(mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id) != null && mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id).size() > 0){

                        nmRefund_Payment__c refundPaymentCareerServiceObj = getRefundPaymentRecord(oppCurr,careerServiceFee, mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id)[0].CareerServiceProgram__c,mapOffeetypevsAmtMain.get('careerServiceFee'));
                        paymentRefundInsertBucket.add(refundPaymentCareerServiceObj);
                    }


                
                List<Opportunity> opportunityList = mapOfAccIdVsOpps.get(oppCurr.AccountId);
                for(Opportunity oppObj : opportunityList)
                {
                    if(oppObj.nm_Semester__c > oppCurr.nm_Semester__c )
                    {
                        oppObj.StageName = 'Re-registration Cancelled';
                        OpportunityUpdateBucket.add(oppObj);
                    }
                }
                

                
                if(mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id) != null && mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id).size() > 0)
                {
                    List<nm_Payment__c> lst = mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id);
                    if(lst != null && lst.size() > 0)
                    {
                        for(nm_Payment__c oppObj : lst)
                        {
                            Career_Service_Program__c csobj = mapOFCareerseriIdVsCareerService.get(oppObj.CareerServiceProgram__c);
                            csobj.Stage__c = 'Cancelled';
                            CareerServiceUpdateBucket.add(csobj);
                        }
                    }
                    
                }

                //-------------------------------------------------------------------------------------------------------------------------------------



                        if(TotalAmtRefund != null && TotalAmtRefund > 0) {
                            
                            handler.createICShareDebitEntries(oppCurr,Integer.valueOf(Math.round((TotalAmtRefund *  Decimal.valueOf(System.Label.ICSharePercentage_PGD_D)))));

                        } 

                  //-------------------------------------------------------------------------------------------------------------------------------------------------      

            } 
            
        }

        if(paymentRefundInsertBucket != null && paymentRefundInsertBucket.size() > 0)
        {
            insert paymentRefundInsertBucket;
        }
        if(OpportunityInsertBucket != null && OpportunityInsertBucket.size() > 0)
        {
            insert OpportunityInsertBucket;
        }
        
        if(OpportunityUpdateBucket != null && OpportunityUpdateBucket.size() > 0)
        {
            update OpportunityUpdateBucket;
        }

        if(CareerServiceUpdateBucket != null && CareerServiceUpdateBucket.size() > 0)
        {
            update CareerServiceUpdateBucket;
        }
    }

    public static Map<String,Decimal> getamtOpp(Map<Id,List<Opportunity>> mapOfAccIdVsOpps,Map<Id,List<nm_Payment__c>> mapOFoppIdVsPayment,Opportunity oppCurr, Map<Id,List<nm_Payment__c>> mapOFopportunityIdVsCareerServicePayment){

        Decimal tutionFee = 0.0;
        Decimal registrationFee = 0.0;
        Decimal liveLecturesFee = 0.0;
        Decimal lateFee = 0.0;
        Decimal careerServiceFee = 0.0;

        Map<String,Decimal> mapOffeetypevsAmtMain = new Map<String,Decimal>();
        mapOffeetypevsAmtMain.put('tutionFee', tutionFee);
        mapOffeetypevsAmtMain.put('liveLecturesFee', liveLecturesFee);
        mapOffeetypevsAmtMain.put('lateFee', lateFee);
        mapOffeetypevsAmtMain.put('careerServiceFee', careerServiceFee);

        List<Opportunity> oppList = mapOfAccIdVsOpps.get(oppCurr.AccountId);

        
        for(Opportunity oppC : oppList)
        {
            Map<String,Decimal> mapOffeetypevsAmtTemp = new Map<String,Decimal>();
            mapOffeetypevsAmtTemp.put('tutionFee', tutionFee);
            mapOffeetypevsAmtTemp.put('liveLecturesFee', liveLecturesFee);
            mapOffeetypevsAmtTemp.put('lateFee', lateFee);
            mapOffeetypevsAmtTemp.put('careerServiceFee', careerServiceFee);
            

            if((oppCurr.nm_Semester__c == oppC.nm_Semester__c  && oppCurr.nm_Fee_Type__c != '' && !(oppCurr.nm_Fee_Type__c).contains('Considered')) || (oppCurr.nm_Semester__c == '2' && (oppC.nm_Semester__c == '1' || oppC.nm_Semester__c == '2') && (oppCurr.nm_Fee_Type__c == 'AnnualFee-Considered' || oppCurr.nm_Fee_Type__c == 'AnnualFeeLoan'))
            || (oppCurr.nm_Semester__c == '3' && (oppC.nm_Semester__c == '2' || oppC.nm_Semester__c == '3') && (oppCurr.nm_Fee_Type__c == 'AnnualFee-Considered' || oppCurr.nm_Fee_Type__c == 'AnnualFeeLoan')) || (oppCurr.nm_Semester__c == '4' && (oppC.nm_Semester__c == '3' || oppC.nm_Semester__c == '4')&& (oppCurr.nm_Fee_Type__c == 'AnnualFee-Considered' || oppCurr.nm_Fee_Type__c == 'AnnualFeeLoan'))
            || (oppCurr.nm_Semester__c == '3' && (oppC.nm_Semester__c == '2' || oppC.nm_Semester__c == '3')&&(oppCurr.nm_Fee_Type__c == 'MultipleSemFee-Considered')) || (oppCurr.nm_Semester__c == '4' && (oppC.nm_Semester__c == '2' || oppC.nm_Semester__c == '3' || oppC.nm_Semester__c == '4')&&(oppCurr.nm_Fee_Type__c == 'MultipleSemFee-Considered')) 
            || ((oppC.nm_Semester__c == '1')&&(oppCurr.nm_Fee_Type__c == 'FullFee-Considered')))
            {

                mapOffeetypevsAmtTemp = getpaymentamtOpp(mapOFoppIdVsPayment,oppC, oppCurr,mapOFopportunityIdVsCareerServicePayment);

            }
            
            if(mapOffeetypevsAmtTemp != null){
                System.debug(mapOffeetypevsAmtMain);
                System.debug(mapOffeetypevsAmtTemp);
                mapOffeetypevsAmtMain.put('tutionFee',mapOffeetypevsAmtMain.get('tutionFee')+mapOffeetypevsAmtTemp.get('tutionFee'));
                mapOffeetypevsAmtMain.put('liveLecturesFee',mapOffeetypevsAmtMain.get('liveLecturesFee')+mapOffeetypevsAmtTemp.get('liveLecturesFee'));
                mapOffeetypevsAmtMain.put('lateFee',mapOffeetypevsAmtMain.get('lateFee')+mapOffeetypevsAmtTemp.get('lateFee'));
                mapOffeetypevsAmtMain.put('careerServiceFee',mapOffeetypevsAmtMain.get('careerServiceFee')+mapOffeetypevsAmtTemp.get('careerServiceFee'));
            }
        
        }
        
        return mapOffeetypevsAmtMain;
    
    }

    public static Map<String,Decimal> getpaymentamtOpp(Map<Id,List<nm_Payment__c>> mapOFoppIdVsPayment,Opportunity oppC, Opportunity oppCurr, Map<Id,List<nm_Payment__c>> mapOFopportunityIdVsCareerServicePayment){

        Set<String> validPaymentTypes = new Set<String>{
            'Admission',
            'Additional Charge',
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

        Decimal tutionFee = 0.0;
        Decimal registrationFee = 0.0;
        Decimal liveLecturesFee = 0.0;
        Decimal lateFee = 0.0;
        Decimal careerServiceFee = 0.0;

        Map<String,Decimal> mapOffeetypevsAmt = new Map<String,Decimal>();
        List<nm_Payment__c> paymentList = new List<nm_Payment__c>();
        paymentList = mapOFoppIdVsPayment.get(oppC.Id);
        if(paymentList != null){
            for(nm_Payment__c paymObj : paymentList)
            {
                System.debug('in cspaymentList 111 :: '+oppCurr.PreviousStageName__c);
                System.debug('in oppCurr.nm_Semester__c :: '+oppCurr.nm_Semester__c);
                System.debug('in oppC.nm_Semester__c  '+oppC.nm_Semester__c );
                System.debug('in cspaymentList 111 :: '+(oppCurr.nm_Semester__c == oppC.nm_Semester__c ));
                if(validPaymentTypes.contains(paymObj.nm_PaymentType__c) || paymObj.nm_PaymentType__c.contains('-DownPayment')){
                tutionFee += paymObj.nm_Amount__c;  // tution fees
                }

                if(paymObj.nm_PaymentType__c == 'Live Lectures'){
                liveLecturesFee += paymObj.nm_Amount__c;
                }
                if(paymObj.nm_PaymentType__c == 'Late Fees' && oppCurr.nm_Semester__c == oppC.nm_Semester__c){
                lateFee += paymObj.nm_Amount__c;
                }
                if(paymObj.nm_PaymentType__c == 'Career Service' && oppCurr.nm_Semester__c == oppC.nm_Semester__c && oppCurr.PreviousStageName__c != 'Closed Won'){
                careerServiceFee += paymObj.nm_Amount__c;
                } 
            }

        }

        if( oppCurr.nm_Semester__c == oppC.nm_Semester__c && oppCurr.PreviousStageName__c != null && oppCurr.PreviousStageName__c == 'Closed Won' && mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id) != null && mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id).size() > 0){
            System.debug('in cspaymentList 123 :: ');
            List<nm_Payment__c> cspaymentList = mapOFopportunityIdVsCareerServicePayment.get(oppCurr.Id);
            System.debug('cspaymentList :: '+cspaymentList);
            if(cspaymentList != null && cspaymentList.size() > 0)
            {
                for(nm_Payment__c cspaymObj : cspaymentList){
                    careerServiceFee += cspaymObj.nm_Amount__c;
                }
            }
            
        }
        
        mapOffeetypevsAmt.put('tutionFee', tutionFee);
        mapOffeetypevsAmt.put('liveLecturesFee', liveLecturesFee);
        mapOffeetypevsAmt.put('lateFee', lateFee);
        mapOffeetypevsAmt.put('careerServiceFee', careerServiceFee);

        return mapOffeetypevsAmt;

    }


    
    public static String getPaymentMode (Map<Id,List<Opportunity>> mapOfAccIdVsOpps,Map<Id,List<nm_Payment__c>> mapOFoppIdVsPayment,Opportunity oppCurr){

        String modeofpayment = '';
        List<nm_Payment__c> paymentList = new List<nm_Payment__c>();
        List<Opportunity> oppList = mapOfAccIdVsOpps.get(oppCurr.AccountId);

        
        for(Opportunity oppC : oppList)
        {
        paymentList = mapOFoppIdVsPayment.get(oppC.Id);
        if(paymentList != null){

      
            for(nm_Payment__c paymObj : paymentList)
            {          
                if(paymObj.nm_OpportunityNew__c == oppC.Id) 
                {
                    modeofpayment = paymObj.nm_ModeOfPayment__c;
                }  
            }
            break;
        }
        break;
        }
        return modeofpayment;
    }


    
    // public static Decimal getCancellationDateAmt(String nmPaymentConfigId,Decimal tutionFee,List<Cancelation_Date__c> cancellationdatesLst){
    //     System.debug('nmPaymentConfigId ::: '+nmPaymentConfigId);
    //     //List<Cancelation_Date__c> cancellationdatesLst =[SELECT Id, Amount__c, From_Date__c, To_Date__c, Percentage__c,NM_Payment_Form_Configuration__c FROM Cancelation_Date__c WHERE  NM_Payment_Form_Configuration__c = :nmPaymentConfigId AND From_Date__c <= TODAY AND To_Date__c >= TODAY]; 
    //     Decimal amt = 0.0;
        
    //     if(cancellationdatesLst != null && cancellationdatesLst.size() > 0){
    //         for(Cancelation_Date__c canObj : cancellationdatesLst)
    //         {
    //             if(canObj.NM_Payment_Form_Configuration__c == nmPaymentConfigId){
    //                 if(canObj.Amount__c != null && canObj.Amount__c > 0.0){

    //                     amt = canObj.Amount__c; 
    //                 } else if( canObj.Percentage__c != null && canObj.Percentage__c > 0.0){
    //                     amt = tutionFee * (canObj.Percentage__c)/100;
    //                 }
    //             }
                
    //         }
    //     }
    //     return amt;
    // }
    public static Decimal getDispatchAmt(String OpportunityId, Map<Id,List<Dispatch_Order__c>> mapOfOppIdVsDO){
        Decimal tutionFee = 0.0;
        List<Dispatch_Order__c> doLst = mapOfOppIdVsDO.get(OpportunityId);
        if(doLst != null){
        for(Dispatch_Order__c doObj : doLst)
        {
            if(doObj.Status_Of_Dispatch__c == 'Transit' || doObj.Status_Of_Dispatch__c == 'Delivered'){
            
                //isDispatched = true;
                tutionFee = 5000.0;
            }
            else {
                tutionFee = 1000.0;
            }
        }}
        return tutionFee;
    }

    public static nmRefund_Payment__c getRefundPaymentRecord(Opportunity oppCurr,Decimal careerServiceFee, Id cserviceprogramId, Decimal oldcareerServiceFee){
        System.debug('getRefundPaymentRecord123 ::: '+oppCurr.Account.nm_Centers__c);
        System.debug('getRefundPaymentRecord123 ::: '+oppCurr.Account.nm_Centers__r.Id);
        nmRefund_Payment__c refundPaymentCareerServiceObj = new nmRefund_Payment__c();
        refundPaymentCareerServiceObj.Total_Refund_Amount__c = careerServiceFee;
        refundPaymentCareerServiceObj.Type_of_Refund__c = 'Career Service Cancellation';
        refundPaymentCareerServiceObj.nm_Information_Center__c = oppCurr.Account.nm_Centers__r.Id;
        refundPaymentCareerServiceObj.nm_Payment_Status__c = 'Refund Initiated';
        refundPaymentCareerServiceObj.nm_Student_E_mail__c = oppCurr.nm_StudentEmail__c;
        refundPaymentCareerServiceObj.Account__c = oppCurr.AccountId;
        refundPaymentCareerServiceObj.isCareerServiceRefunded__c = careerServiceFee > 0.0 ? true : false;
        refundPaymentCareerServiceObj.CareerServiceProgram__c = cserviceprogramId;
        refundPaymentCareerServiceObj.CareerService_Fee_Deduction__c = oldcareerServiceFee - careerServiceFee;
        return refundPaymentCareerServiceObj;
    }
    
    public static Opportunity getNextSemOpportunity(Opportunity currentSemOpportunity){
        // Opportunity nextSemOpportunity = currentSemOpportunity.clone();
               Opportunity nextSemOpportunity = new Opportunity();
               if(currentSemOpportunity.nm_Session__c == 'January'){
                   nextSemOpportunity.nm_Session__c = 'July';
                   nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
               }else if(currentSemOpportunity.nm_Session__c == 'July'){
                   nextSemOpportunity.nm_Session__c = 'January';
                   nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c + 1;
               }
               
               Integer nextSem = Integer.valueOf(currentSemOpportunity.nm_Semester__c ) + 1;
               nextSemOpportunity.Name = currentSemOpportunity.AccountId;
               nextSemOpportunity.StageName = 'Closed Won - Re-registration Pending';
               nextSemOpportunity.CloseDate =System.today();
               nextSemOpportunity.nm_Fee_Type__c = currentSemOpportunity.nm_Fee_Type__c ;//'AnnualFee-Considered';//Changing so that trigger does not fire again and future Opportunities are not further created
               nextSemOpportunity.nm_Semester__c = currentSemOpportunity.nm_Semester__c;
               nextSemOpportunity.AccountId=currentSemOpportunity.AccountId;
               nextSemOpportunity.nm_StudentProgram__c=currentSemOpportunity.nm_StudentProgram__c;
               nextSemOpportunity.nm_Program__c=currentSemOpportunity.nm_Program__c;       
               nextSemOpportunity.Is_Re_Registration_Payment__c = true;
               nextSemOpportunity.nm_Future_Sems_Created__c = true;
               nextSemOpportunity.nm_Payment_Approved__c= true;
               nextSemOpportunity.OwnerId= System.label.DefaultOwner;
               /*   nextSemOpportunity.Fee_Receipt_Dispatched_Date__c =null;
               nextSemOpportunity.Processed__c =false;
               nextSemOpportunity.AdmissionPaymentID__c=null;
               nextSemOpportunity.Dispatch_Order_Number_For_Student__c=null;
               nextSemOpportunity.Synced_With_StudentZone__c =false;*/
               return nextSemOpportunity;
           }

}