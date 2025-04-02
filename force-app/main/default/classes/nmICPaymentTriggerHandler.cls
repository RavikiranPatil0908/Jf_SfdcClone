/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-01-2024
 * @last modified by  : @BK
**/
public class nmICPaymentTriggerHandler {

    public final Integer fixedDeduct = Integer.ValueOf(Label.Courier_charge);
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Map<id Opportunity> newOptyMap 
    * @param Map<id Opportunity> oldOptyMap 
    **/
    public void AfterUpdate(Map<id, Opportunity> newOptyMap, Map<id, Opportunity> oldOptyMap) {
        adjustICShares(newOptyMap,oldOptyMap);
    }

    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Map<Id Opportunity> newOptyMap 
    * @param Map<Id Opportunity> oldOptyMap 
    **/
    public void adjustICShares(Map<Id, Opportunity> newOptyMap, Map<Id, Opportunity> oldOptyMap) {
        // Prepare the opportunity records to process
        List<Opportunity> oppsToProcess = getOpportunitiesToProcess(newOptyMap);
        if (oppsToProcess.isEmpty()) {
            return; // Exit if there are no opportunities to process
        }
        
        // Initialize variables for the current year and payment amounts
        Integer year = Date.today().year(); 
        
        // Create a set of years to check for existing IC payments
        Set<String> setofYear = new Set<String> { String.valueOf(year), String.valueOf(year + 1) };

        // store Payment share config
        List<PaymentShareConfig__c> configs = getPaymentShareConfig();

        if(configs.isEmpty()) {
            System.debug('Error: No record found for share Config');
            return;
        }
    
        // Map to store existing IC Payments
        Map<String, IC_Payment__c> existingICPaymentMap = getExistingICPayments(setofYear);
        List<IC_Payment_Transaction__c> ipTransactionList = new List<IC_Payment_Transaction__c>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
    
        try {
            System.debug('Oppty Size ' + oppsToProcess.size());
    
            // Process each opportunity
            for (Opportunity o : oppsToProcess) {
                processOpportunity(o, existingICPaymentMap, ipTransactionList, updateOpportunityList, year, configs);
            } 
    
            // Update opportunities and insert transactions in bulk
            if (!updateOpportunityList.isEmpty()) {
                Database.SaveResult[] srList = Database.update(updateOpportunityList, false);
                handleDatabaseResults(srList); // Handle results of the update
            }
    
            if (!ipTransactionList.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(ipTransactionList, false);
                handleDatabaseResults(srList); // Handle results of the insert
            }
        } catch (Exception ex) {
            // Log any exceptions that occur during processing
            System.debug('---ERRORS IN THE IC STUDENT PAYMENT TRIGGER ARE---' + ex.getMessage());
            System.debug('---ERRORS IN THE IC STUDENT PAYMENT TRIGGER Line Number---' + ex.getLineNumber());
        }
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Map<Id Opportunity> newOptyMap 
    * @return List<Opportunity> 
    **/
    private List<Opportunity> getOpportunitiesToProcess(Map<Id, Opportunity> newOptyMap) {
        // Query to retrieve opportunities that are not processed and are 'Closed Won'
        return [SELECT Id, StageName, CloseDate, Processed__c, nm_Fee_Type__c, Down_Payment_Made__c, 
                       WaivedOffAmount__c, E_S_charge__c, BookCChargeapplicable__c, Choose_a_Program__c, 
                       ChooseProgram__c, Specialisation__c, Account.nm_Tagged_Pricebook__c, IC__c, 
                       ActualAmountReceived__c, RegistrationFee__c, late_fee__c, nm_Semester__c, 
                       Account.Prior_information_center__c, AccountId, 
                       nm_DemandDraftNumber__c, nm_TransactionID__c, Account.Name, 
                       Account.Account_Confirm_Date__c, AEPSDebit__c, CareerServiceFee__c, 
                       Account.nm_StudentStatus__c, Account.nm_StudentNo__c, 
                       Account.nm_DefencePersonnel__c, Account.nm_Centers__c, nm_Drive_Name__c, 
                       nm_Session__c, nm_Year__c, Account.nm_Program__c, 
                       Account.Sem__c, Account.OldAccount__c, 
                       Account.nm_Program__r.Name, Account.OldAccount__r.nm_Program__r.Name, 
                       Account.Is_Lateral__c, Account.nm_Drive_Name__c,
                       (SELECT Id, ActualSalePrice__c, Quantity, Product_Name__c FROM OpportunityLineItems) 
                FROM Opportunity 
                WHERE Id IN :newOptyMap.keySet() 
                AND Processed__c = false 
                AND StageName = 'Closed Won' 
                AND ShareApplicable__c = true];
    }

    /**
    * @description 
    * @author @BK | 21-09-2024 
    * @return List<PaymentShareConfig__c> 
    **/
    private List<PaymentShareConfig__c> getPaymentShareConfig() {
        List<PaymentShareConfig__c> configs = [SELECT Percentage__c, Order__c 
                                                FROM PaymentShareConfig__c 
                                                WHERE Is_Active__c = TRUE 
                                                ORDER BY Order__c];
    
        Decimal totalPercentage = 0;
    
        // Validate total percentage
        for (PaymentShareConfig__c config : configs) {
            totalPercentage += config.Percentage__c;
        }
    
        if (totalPercentage != 100) {
            System.debug('Error: Total percentage is not 100%. Current total: ' + totalPercentage);
            // Handle the error appropriately
            return new List<PaymentShareConfig__c>(); // Return empty list to indicate error
        }
        
        return configs; // Return sorted and validated configurations
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Set<String> setofYear 
    * @return Map<String, IC_Payment__c> 
    **/
    private Map<String, IC_Payment__c> getExistingICPayments(Set<String> setofYear) {
        // Initialize a map to hold existing IC Payments
        Map<String, IC_Payment__c> existingICPaymentMap = new Map<String, IC_Payment__c>();
        
        // Query for existing IC Payments based on the specified years
        List<IC_Payment__c> existingICPayments = [
            SELECT Id, Payment_Month__c, Payment_Year__c, Amount__c, Centers__c 
            FROM IC_Payment__c 
            WHERE Payment_Year__c IN :setofYear
        ];
    
        // Populate the map with existing payments using a composite key
        for (IC_Payment__c payment : existingICPayments) {
            String primaryKey = String.valueOf(payment.Centers__c) + payment.Payment_Month__c + String.valueOf(payment.Payment_Year__c);
            existingICPaymentMap.put(primaryKey, payment);
        }
    
        return existingICPaymentMap; // Return the map of existing payments
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param List<Opportunity> updateOpportunityList 
    * @param Integer year 
    **/
    private void processOpportunity(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                    List<IC_Payment_Transaction__c> ipTransactionList, 
                                    List<Opportunity> updateOpportunityList, Integer year,
                                    List<PaymentShareConfig__c> configs) {
        // Extract relevant data from the opportunity
        Double actualAmountReceived = calculateActualAmountReceived(o);
        Double actualICShareAmount = calculateICShareAmount(o);
        
        if (o.StageName == 'Closed Won') {
            List<ConfigMonthYear> lstConfigMonthsYears = calculateConfirmMonthYear(o, configs); // Calculate confirmation month/year
            // for(ConfigMonthYear obj : lstConfigMonthsYears) {
            //     System.debug(obj);
            //     System.debug(obj.shareConfig);
            // }
            // Business logic for payment processing
            handlePayments(o, existingICPaymentMap, ipTransactionList, actualAmountReceived, actualICShareAmount, lstConfigMonthsYears);
            o.Processed__c = true; // Mark opportunity as processed
            updateOpportunityList.add(o); // Add to the list of opportunities to update
        }
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @return Double 
    **/
    private Double calculateActualAmountReceived(Opportunity o) {
        // Calculate the actual amount received based on various fees
        return o.ActualAmountReceived__c + o.E_S_charge__c - o.RegistrationFee__c - o.late_fee__c - o.CareerServiceFee__c;
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @return Double 
    **/
    private Double calculateICShareAmount(Opportunity o) {
        // Calculate the IC share amount from the opportunity line items
        List<OpportunityLineItem> lstLineItems = o.OpportunityLineItems;
        Decimal saleprice = 0;
        
        for (OpportunityLineItem obj : lstLineItems) {
            String s = obj.Product_Name__c;
    
            // Check for specific product names to include in the share amount calculation
            if(String.isNotBlank(s) && 
               (s.startsWithIgnoreCase('Semester') 
                || s.startsWithIgnoreCase('Certificate Service Tax') 
                || s.startsWithIgnoreCase('GST') 
                || s.startsWithIgnoreCase('Live'))) {
                saleprice += obj.ActualSalePrice__c; // Accumulate sale price
            }
        }
        return saleprice; // Return total sale price for IC share
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @return List<ConfigMonthYear> 
    **/
    private List<ConfigMonthYear> calculateConfirmMonthYear(Opportunity o, List<PaymentShareConfig__c> configs) {
        // Initialize response object to store confirmation month/year and details
        List<ConfigMonthYear> lstConfigMonthsYears = new List<ConfigMonthYear>();

        String feesType = String.isNotBlank(o.nm_Fee_Type__c) ? o.nm_Fee_Type__c : '';
    
        // Check if the opportunity is for a BBA program
        Boolean isBBAProgram = checkForBBAProgram(o, feesType);
        Integer paymentDate = isBBAProgram ? Date.today().day() : o.CloseDate.day();


        Integer count = 0;
        for (PaymentShareConfig__c shareConfig : configs) {
            ConfigMonthYear objConfig = new ConfigMonthYear();
            objConfig.incrementMonth = paymentDate > 10 ? (count + 1) : count;

            objConfig.confMonth = isBBAProgram ? Date.today().month() : o.CloseDate.month();
            objConfig.confYear = isBBAProgram ? Date.today().year() : o.CloseDate.year();

            PaymentDate objDate = calculateMonthYear(objConfig.confMonth, objConfig.confYear, objConfig.incrementMonth);
            objConfig.confMonth = objDate.confMonth;
            objConfig.confYear = objDate.confYear;
            objConfig.confirmationMonthYear = objDate.confirmationMonthYear;
            objConfig.shareConfig = shareConfig;

            lstConfigMonthsYears.add(objConfig);
            count++;
        }

        return lstConfigMonthsYears; // Return response object
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param String feesType 
    * @return Boolean 
    **/
    private Boolean checkForBBAProgram(Opportunity o, String feesType) {
        // Determine if the opportunity relates to a BBA program based on specific criteria
        Set<String> newPrograms = new Set<String>{'B.Com', 'BBA', 'BBA-BA'};
        Set<String> oldPrograms = new Set<String>{'CGM', 'CBA'};
        
        return o.Account.Is_Lateral__c && o.Account.Sem__c == '2' &&
               o.Account.nm_Drive_Name__c == 'January2023' &&
               String.isNotBlank(o.Account.nm_Program__c) &&
               String.isNotBlank(o.Account.OldAccount__c) &&
               newPrograms.contains(o.Account.nm_Program__r.Name) &&
               oldPrograms.contains(o.Account.OldAccount__r.nm_Program__r.Name) &&
               o.nm_Semester__c == '2' &&
               o.nm_Session__c == 'January' &&
               o.nm_Year__c == 2023 &&
               feesType.contains('Considered');
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Integer month 
    * @param Integer year 
    * @param Integer increment 
    * @return String 
    **/
    private PaymentDate calculateMonthYear(Integer month, Integer year, Integer increment) {
        // Calculate new month/year based on increment and handle year transitions
        PaymentDate objDate = new PaymentDate();
        Integer newMonth = month + increment;
        Integer newYear = year;
    
        if (newMonth > 12) {
            newMonth = Math.mod(newMonth, 12); // Wrap around month if greater than 12
            newYear++; // Increment year
        }
    
        objDate.confMonth = newMonth;
        objDate.confYear = newYear;
        objDate.confirmationMonthYear = String.valueOf(newMonth) + String.valueOf(newYear); // Return formatted month-year
        return objDate;
    }
    
    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param Double actualAmountReceived 
    * @param Double actualICShareAmount 
    * @param List<ConfigMonthYear> lstConfigMonthsYears 
    **/
    private void handlePayments(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                List<IC_Payment_Transaction__c> ipTransactionList, 
                                Double actualAmountReceived, Double actualICShareAmount, 
                                List<ConfigMonthYear> lstConfigMonthsYears) {

        Double actualPayment = calculatePayment(o, actualICShareAmount, actualAmountReceived);
        PaymentDate defaultConfig = new PaymentDate();
        defaultConfig.confirmationMonthYear = lstConfigMonthsYears[0].confirmationMonthYear;
        defaultConfig.confMonth = lstConfigMonthsYears[0].confMonth;
        defaultConfig.confYear = lstConfigMonthsYears[0].confYear;

        System.debug('---CONFIRM MONTH YEAR 1--- ' + defaultConfig.confMonth +' - '+ defaultConfig.confYear);

        if (o.nm_Fee_Type__c.contains('Considered')) {
            handleConsideredFeeType(o, existingICPaymentMap, ipTransactionList, defaultConfig);
            return;
        }
        
        // if (actualPayment_35 <= 0) return;
        Boolean firstTransaction = true;
        for (ConfigMonthYear obj : lstConfigMonthsYears) {
            System.debug('---CONFIRM MONTH YEAR '+ obj.incrementMonth +'---' + obj.confirmationMonthYear);
            processShares(o, existingICPaymentMap, actualPayment, ipTransactionList, obj, firstTransaction);
            firstTransaction = false;
        }
        
    }

    /**
    * @description 
    * @author @BK | 21-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param Double actualPayment 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param ConfigMonthYear objConfig 
    * @param Boolean firstTransaction 
    **/
    public void processShares(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap,
                            Double actualPayment,List<IC_Payment_Transaction__c> ipTransactionList,
                            ConfigMonthYear objConfig, Boolean firstTransaction) {

        if(firstTransaction) {
            handleExistingPayments(o, existingICPaymentMap, actualPayment, ipTransactionList, objConfig);
        } else {
            processPayment(o, existingICPaymentMap, actualPayment, ipTransactionList, objConfig);
        }

    }
    

    /**
    * @description 
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Double actualICShareAmount 
    * @param Double actualAmountReceived 
    * @return Double 
    **/
    private Double calculatePayment(Opportunity o, Double actualICShareAmount, Double actualAmountReceived) {
        // Extract relevant fields from the Opportunity object
        String feesType = o.nm_Fee_Type__c;
        String chooseProgram = o.ChooseProgram__c;
        String specialization = o.Specialisation__c;
    
        // Check if the actual IC share amount is greater than zero
        if (actualICShareAmount <= 0) {
            return 0.0; // No payment if actualICShareAmount is zero or negative
        }
    
        // Delegate payment calculation based on program type and specialization
        if (chooseProgram == 'Master Programs') {
            return calculateMasterProgramPayment(o, actualICShareAmount, actualAmountReceived, specialization, feesType);
        } else if (chooseProgram == 'Certificate Programs') {
            return calculateCertificateProgramPayment(o, actualICShareAmount, specialization, feesType);
        } else if (chooseProgram == 'Professional Programs') {
            return calculateProfessionalProgramPayment(o, actualICShareAmount, specialization, feesType);
        } else if (chooseProgram == 'MBA (Distance) Programs') {
            return calculateMBADistancePayment(o, actualICShareAmount, actualAmountReceived, feesType);
        } else {
            // Default payment calculation for all other cases
            return (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
        }
    }
    
    // Calculate payment for Master Programs
    private Double calculateMasterProgramPayment(Opportunity o, Double actualICShareAmount, Double actualAmountReceived, String specialization, String feesType) {
        if (specialization == 'M.Sc. (AI & ML Ops)' || specialization == 'M.Sc. (AI)') {
            return (o.Down_Payment_Made__c && feesType.equalsIgnoreCase('FullFee')) ?
                (actualAmountReceived > 0 ? (actualAmountReceived * Decimal.valueOf(Label.ICSharePercentage_DegreeProgram)) : 0) :
                (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_DegreeProgram));
        } else if (specialization != 'MBA (X)') {
            return (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_DegreeProgram));
        }
        return 0.0; // Fallback
    }
    
    // Calculate payment for Certificate Programs
    private Double calculateCertificateProgramPayment(Opportunity o, Double actualICShareAmount, String specialization, String feesType) {
        if (specialization == 'CPWL') {
            return (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_CPWL));
        } else if (specialization != null && specialization.contains('Certificate Term')) {
            Integer multipleFactor = getMultipleNumber(feesType);
            return ((actualICShareAmount - (Decimal.valueOf(Label.Stukent) * multipleFactor)) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
        } else if (specialization == 'PC Term 2') {
            return (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_DegreeProgram));
        }
        return 0.0; // Fallback
    }
    
    // Calculate payment for Professional Programs
    private Double calculateProfessionalProgramPayment(Opportunity o, Double actualICShareAmount, String specialization, String feesType) {
        if (specialization != null && specialization == 'PD Term 4') {
            return (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_DegreeProgram));
        } else if (specialization == 'Professional Diploma Term 4' && o.nm_Semester__c != '4') {
            Integer multipleFactor = getMultipleNumberPP(feesType, Integer.valueOf(o.nm_Semester__c));
            return ((actualICShareAmount - (Decimal.valueOf(Label.Stukent) * multipleFactor)) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
        } else if (specialization == 'Professional Diploma' && o.nm_Semester__c == '1') {
            return ((actualICShareAmount - 15000) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
        }
        return 0.0; // Fallback
    }

    /**
    * @description Calculate payment for MBA (Distance) Programs
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Double actualICShareAmount 
    * @param Double actualAmountReceived 
    * @param String feesType 
    * @return Double 
    **/
    private Double calculateMBADistancePayment(Opportunity o, Double actualICShareAmount, Double actualAmountReceived, String feesType) {
        return (o.Down_Payment_Made__c && feesType.equalsIgnoreCase('FullFeeLoan')) ?
            (actualAmountReceived > 0 ? (actualAmountReceived * Decimal.valueOf(Label.ICSharePercentage_PGD_D)) : 0) :
            (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
    }

    /**
    * @description Do not pay any IC share for Sem 2, 3, 4 if it is PGAllSemFee or Annual Fees, since share is paid in Sem 1
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param String accountConfirmMonthYear 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param Integer confMonth 
    * @param Integer confYear 
    **/
    private void handleConsideredFeeType(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                          List<IC_Payment_Transaction__c> ipTransactionList, PaymentDate objConfig) {
        // Log current confirmation month/year for debugging
        System.debug('confYear-->feetype' + objConfig.confYear);
        System.debug('confMonth-->feetype' + objConfig.confMonth);
        System.debug('accountConfirmMonthYear-->feetype' + objConfig.confirmationMonthYear);
        
        // Sets of new and old programs for validation
        Set<String> newProgram = new Set<String>{'B.Com', 'BBA', 'BBA-BA'};
        Set<String> oldProgram = new Set<String>{'CGM', 'CBA'};
        
        // Conditional check for specific program and semester details
        if (o.Account.Is_Lateral__c  && o.Account.Sem__c == '2' && o.Account.nm_Drive_Name__c == 'January2023' && 
            String.isNotBlank(o.Account.nm_Program__c) && String.isNotBlank(o.Account.OldAccount__c) && 
            newProgram.contains(o.Account.nm_Program__r.Name) && oldProgram.contains(o.Account.OldAccount__r.nm_Program__r.Name) &&
            o.nm_Semester__c == '2' && o.nm_Session__c == 'January' && o.nm_Year__c == 2023) {
            
            // Get adjustment amount for IC transaction
            Decimal amount = getIcTranAdjustmentDebitAmount(o.Account.OldAccount__c);
            if (amount > 1) {
                // Create credit record if amount is valid
                IC_Payment__c icp = getICPayment(String.valueOf(objConfig.confYear), String.valueOf(objConfig.confMonth), o.IC__c);
                Date dueDate = Date.newInstance(objConfig.confYear, objConfig.confMonth, 20);
                createAdhocCreditRecord(ipTransactionList, o, icp, Integer.valueOf(amount), false, '', dueDate, '');
            }
        }
        
        // Create courier debit entry for specific cases
        createCourierDebitEntryForFullFeeSEM2AndBeyond(existingICPaymentMap, o, ipTransactionList, objConfig);
        // o.Processed__c = TRUE; // Uncomment if needed for marking as processed
        // updateOpportunityList.add(o); // Uncomment if needed for updating the opportunity list
    }
    

    /**
    * @description Method to handle existing payments and process them accordingly
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param String accountConfirmMonthYear 
    * @param Double actualPayment 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param Integer confMonth 
    * @param Integer confYear 
    **/
    private void handleExistingPayments(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                        Double actualPayment, List<IC_Payment_Transaction__c> ipTransactionList,
                                        ConfigMonthYear objConfig) {
        // Initialize amount variables for Master and Professional courses
        String paymentKey = String.valueOf(o.Account.nm_Centers__c) + objConfig.confirmationMonthYear;
    
        // Check if there is an existing payment record
        IC_Payment__c iOne = existingICPaymentMap.get(paymentKey);
        Boolean isExistingPayment = (iOne != null);
    
        if (isExistingPayment) { 
            // Logic for handling existing payments
            System.debug('IF 1 ENTERED!');
            handlePaymentAdhocRecords(o, existingICPaymentMap, actualPayment, ipTransactionList, true, objConfig, iOne);
            
        } else {
            // Logic for handling new payments
            System.debug('ELSE 1 ENTERED!');       
            iOne = getICPayment(String.valueOf(objConfig.confYear), String.valueOf(objConfig.confMonth), o.IC__c);
            existingICPaymentMap.put(String.valueOf(iOne.Centers__c) + iOne.Payment_Month__c + String.valueOf(iOne.Payment_Year__c), iOne);
    
            handlePaymentAdhocRecords(o, existingICPaymentMap, actualPayment, ipTransactionList, false, objConfig, iOne);
        }
    }

    /**
    * @description Logic for handling payments
    * @author @BK | 20-09-2024 
    * @param Opportunity o 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param String accountConfirmMonthYear 
    * @param Double actualPayment 
    * @param List<IC_Payment_Transaction__c> ipTransactionList 
    * @param Integer confMonth 
    * @param Integer confYear 
    * @param IC_Payment__c iOne 
    **/
    private void handlePaymentAdhocRecords(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                            Double actualPayment , List<IC_Payment_Transaction__c> ipTransactionList, 
                                            Boolean isCredit, ConfigMonthYear cf, IC_Payment__c iOne) {
        Double amount = 0;
        // Extract relevant fields from the Opportunity object
        String feesType = o.nm_Fee_Type__c;
        String chooseProgram = o.ChooseProgram__c;
        String specialization = o.Specialisation__c;
        Double actualAmountReceived = calculateActualAmountReceived(o);
        Double actualICShareAmount = calculateICShareAmount(o);
        Integer percent = Integer.valueOf(cf.shareConfig.Percentage__c);
        Decimal icAmount = (actualPayment * percent) / 100;
        Date dueDate = Date.newInstance(cf.confYear, cf.confMonth, 20);
        PaymentDate objDate = new PaymentDate();
        objDate.confMonth = cf.confMonth;
        objDate.confYear = cf.confYear;
        objDate.confirmationMonthYear = cf.confirmationMonthYear;
        
        // Create transaction record for the new payment
        createICTransactionRecord(ipTransactionList, iOne.ID, icAmount, o, percent, dueDate);
            
        // Handle Book Courier Charges if applicable
        if (o.BookCChargeapplicable__c) {
            createAdhocDebitRecord(ipTransactionList, o, iOne, fixedDeduct, false, 'Book Courier Charges', dueDate, 'Postage Recovery (TBD)');
        }

        // Payment handling based on program and specialization
        if (chooseProgram == 'Master Programs' && (specialization == 'M.Sc. (AI & ML Ops)' || specialization == 'M.Sc. (AI)')) {
            amount = (o.Down_Payment_Made__c && feesType.equalsIgnoreCase('FullFee')) 
                        ? (actualAmountReceived > 0 ? (actualAmountReceived * Decimal.valueOf(Label.ICSharePercentage_MSC)) : 0 ) 
                        : (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_MSC));
            
            handleInsofeCredit(existingICPaymentMap, ipTransactionList, o, objDate, amount, isCredit);
        }

        if ((chooseProgram == 'Certificate Programs' && specialization == 'PC Term 2') || 
            (chooseProgram == 'Professional Programs' && specialization == 'PD Term 4')) {
            amount = (actualICShareAmount * Decimal.valueOf(Label.ICSharePercentage_MSC));
            handleInsofeCredit(existingICPaymentMap, ipTransactionList, o, objDate, amount, isCredit);
        }

        handleAEPSDebit(ipTransactionList, o, existingICPaymentMap, objDate, iOne, isCredit);
    }
    
    // Method to handle Insofe credits
    private void handleInsofeCredit(Map<String, IC_Payment__c> existingICPaymentMap, 
                                    List<IC_Payment_Transaction__c> ipTransactionList, 
                                    Opportunity o, PaymentDate cf, Double amount, 
                                    Boolean isCredit) {
        // Get Insofe payment record, creating a new one if it doesn't exist
        IC_Payment__c iOnems = getInsofePaymentRecord(existingICPaymentMap, cf);
        Date dueDate = date.newinstance(cf.confYear,cf.confMonth,20);
        if(isCredit) {
            // Create a credit record for Insofe
            createAdhocCreditRecord(ipTransactionList, o, iOnems, Integer.valueOf(amount), false, 'Insofe', dueDate, '');
        } else {
            // Create transaction record for the new payment
            createICTransactionRecord(ipTransactionList, iOnems.ID, amount, o, 100, dueDate);
        }
    }
    
    // Method to handle AEPS debits
    private void handleAEPSDebit(List<IC_Payment_Transaction__c> ipTransactionList, Opportunity o, 
                                  Map<String, IC_Payment__c> existingICPaymentMap, PaymentDate cf,
                                  IC_Payment__c iOne, Boolean isCredit) {
        // Check if AEPS debit is applicable
        if (o.AEPSDebit__c > 0) {                            
            // Extract relevant fields from the Opportunity object
            String chooseProgram = o.ChooseProgram__c;
            String specialization = o.Specialisation__c;
            Decimal icShareDegreeProgramPercentage = isCredit ? Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) : 0.25;
            Decimal icShareMSCProgramPercentage = isCredit ? Decimal.valueOf(Label.ICSharePercentage_MSC) : 0.32;
            Date dueDate = Date.newInstance(cf.confYear, cf.confMonth, 20);
            // Specific handling for Master Programs
            if (chooseProgram == 'Master Programs' && (specialization == 'M.Sc. (AI & ML Ops)' || specialization == 'M.Sc. (AI)')) {
                createAdhocDebitRecord(ipTransactionList, o, iOne, Integer.valueOf(o.E_S_charge__c * icShareDegreeProgramPercentage), true, 'Subvention charge', dueDate, 'Subventions Charges');
                // Get Insofe payment record, creating a new one if it doesn't exist
                IC_Payment__c iOnems = getInsofePaymentRecord(existingICPaymentMap,cf);
                createAdhocDebitRecord(ipTransactionList, o, iOnems, Integer.valueOf(o.E_S_charge__c * icShareMSCProgramPercentage), true, 'Subvention charge', dueDate, 'Subventions Charges');
            } else {
                // General handling for other programs
                createAdhocDebitRecord(ipTransactionList, o, iOne, Integer.valueOf(o.AEPSDebit__c), true, 'Subvention charge', dueDate, 'Subventions Charges');
            }
        }
    }

    /**
    * @description Get Insofe payment record, creating a new one if it doesn't exist
    * @author @BK | 20-09-2024 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param String accountConfirmMonthYear 
    * @param Integer confMonth 
    * @param Integer confYear 
    * @return IC_Payment__c 
    **/
    private IC_Payment__c getInsofePaymentRecord(Map<String, IC_Payment__c> existingICPaymentMap, PaymentDate cf) {
        return existingICPaymentMap.containsKey(String.valueOf(Label.Insofe) + cf.confirmationMonthYear) 
                ? existingICPaymentMap.get(String.valueOf(Label.Insofe) + cf.confirmationMonthYear) 
                : getICPayment(String.valueOf(cf.confYear), String.valueOf(cf.confMonth), 'Insofe');
    }
    
    // Method to process individual payments for an opportunity
    private void processPayment(Opportunity o, Map<String, IC_Payment__c> existingICPaymentMap, 
                                Double actualPayment, List<IC_Payment_Transaction__c> ipTransactionList, 
                                ConfigMonthYear cf) {
        // Generate a unique key to identify the payment record
        String paymentKey = String.valueOf(o.Account.nm_Centers__c) + cf.confirmationMonthYear;
        IC_Payment__c paymentRecord;
    
        // Check for existing payment records
        if (existingICPaymentMap.containsKey(paymentKey)) {
            System.debug('Payment record found for: ' + paymentKey);
            paymentRecord = existingICPaymentMap.get(paymentKey);
        } else {
            System.debug('No existing payment record found for: ' + paymentKey);
            // If not found, create a new payment record
            paymentRecord = getICPayment(String.valueOf(cf.confYear), String.valueOf(cf.confMonth), o.IC__c);
            existingICPaymentMap.put(String.valueOf(paymentRecord.Centers__c) + paymentRecord.Payment_Month__c + String.valueOf(paymentRecord.Payment_Year__c), paymentRecord);
        }
    
        // Create a transaction record for the payment
        Integer percent = Integer.valueOf(cf.shareConfig.Percentage__c);
        Decimal percentage = cf.shareConfig.Percentage__c / 100;
        createICTransactionRecord(ipTransactionList, paymentRecord.ID, actualPayment * percentage, o, percent, Date.newInstance(cf.confYear, cf.confMonth, 20));
    }
    
    // Method to handle database results after save operations
    private void handleDatabaseResults(Database.SaveResult[] srList) {
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Log successful save
                System.debug('--SUCCESS--' + sr.getId());
            } else {
                // Log errors if the save failed
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred: ' + err.getMessage());
                    System.debug('---ERROR IS ---- ' + err.getFields());
                }
            }
        }
    }

    public Decimal getIcTranAdjustmentDebitAmount(String accId) {
        Decimal totalAmount = 0.0;      
        totalAmount = (Decimal)[select sum(Amount__c)Amount from IC_Payment_Transaction__c WHERE Opportunity__r.AccountId = :accId AND Opportunity__r.nm_Semester__c = '1' AND Transaction_Type__c = 'Adjustment - Debit' AND ( NOT Narration__c LIKE '%Book Courier Charges')  ][0].get('Amount');
        
        return totalAmount;
    }
    
    public void createICTransactionRecord(List<IC_Payment_Transaction__c> ipTransectionList, ID icPaymentID, Decimal  amount, Opportunity o, Integer percent,Date Duedate){
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();

        ip.Amount__c = amount;
        ip.Narration__c = o.Account.Name;
        ip.IC_Payment__c = icPaymentID;
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = Duedate;
        ip.Date__c = o.CloseDate;
        ip.Opportunity__c = o.ID;
        ip.Commission_Percent__c = percent;
        ip.Account__c = o.AccountId;
        ipTransectionList.add(ip);

    }
    
    //Method used only when Admission Cancel from CancelAdmission trigger
    public void createICTransactionDebitRecord(Opportunity objOpp, IC_Payment__c icPayment,Date DueDate,Integer AdditionalDebitAmount){
            Date today = Date.Today(); 
            String opposid;
            double DebitSum;
            double CreditSum;
            //Link IC Payment with Student
            IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();     
            Opportunity objOpportunity =new Opportunity(id =objOpp.id);            
            opposid=objOpportunity.id;
              CreditSum = (Decimal) [Select Sum(Amount__c)aver  FROM  IC_Payment_Transaction__c where Transaction_Type__c='Admission Commision - Credit' and Opportunity__c =:opposid][0].get('aver');
                   DebitSum = (Decimal) [Select Sum(Amount__c)debitsum 
                            FROM  IC_Payment_Transaction__c 
                            where Transaction_Type__c='Adjustment - Debit' and Opportunity__c =:opposid 
                             and ( NOT Narration__c LIKE '%Book Courier Charges')][0].get('debitsum');    
        System.debug('CreditSum----->'+CreditSum);
        
        if (DebitSum <=0 || DebitSum ==null)
        {
            DebitSum =0;
        }
        if (CreditSum <=0 || CreditSum ==null)
        {
            CreditSum  =0;
        }
        
        ip.Amount__c = CreditSum - DebitSum;
        ip.Narration__c = objOpp.Account.Name +' - Admission Cancellation';
        ip.IC_Payment__c = icPayment.Id;
        ip.Transaction_Category__c = 'Admission Cancellation';
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = DueDate;
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;
    
        ip.Account__c = objOpp.AccountId;
        if (ip.Amount__c  > 1) {
            insert ip;
        }

    }
    //Create Fixed Debit entry for Books Deliverey charge
    public void createCourierDebitRecord(List<IC_Payment_Transaction__c> ipTransectionList, Opportunity objOpp,  Integer year, Integer month, IC_Payment__c icPayment){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();   
        ip.Amount__c = fixedDeduct;
        ip.Narration__c = objOpp.Account.Name + ' - Book Courier Charges';
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(year)+'-'+String.valueOf(month)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;
        ip.Transaction_Category__c = 'Postage Recovery (TBD)';
        ip.Account__c = objOpp.AccountId;
        ipTransectionList.add(ip);

    }

     //Method used only when Admission Cancel from CancelAdmission trigger
    public void createICShareDebitEntries(Opportunity objOpp,Integer AdditionalDebitAmount) {
        Set<String> setAEPName = new Set<String> ();
        Map<String,Integer> mapAEPNamevs = new Map<String,Integer>();
        Date today = Date.Today();
        Integer cancellationMonth = 0;
        Integer cancellationYear = today.Year();
        if (today.day() <= 10) {
            cancellationMonth = today.Month();
        } else {
            cancellationMonth = today.Month() + 1;
        }
        if(cancellationMonth >=13)
        {
            cancellationMonth = cancellationMonth - 12;
            cancellationYear = today.Year()+1;
        }

        List<IC_Payment_Transaction__c> listIcTransaction =  [Select id,Amount__c,AEP_share__c ,Transaction_Type__c FROM  IC_Payment_Transaction__c 
                                                            where (Transaction_Type__c='Admission Commision - Credit' 
                                                            or  Transaction_Type__c='Adjustment - Debit')
                                                            and ( NOT Narration__c LIKE '%Book Courier Charges') 
                                                            and Opportunity__c =:objOpp.id];

        if(listIcTransaction.size()>0) {
            for(IC_Payment_Transaction__c objICTransac : listIcTransaction) {
                string key = objOpp.IC__c+'_'+objICTransac.Transaction_Type__c;
                if(!mapAEPNamevs.containskey(key)) {
                    mapAEPNamevs.put(key,Integer.valueof(objICTransac.Amount__c));
                } else {
                    Integer existingvalue = mapAEPNamevs.get(key);
                    existingvalue = existingvalue+Integer.valueof(objICTransac.Amount__c);
                    mapAEPNamevs.put(key,existingvalue);
                }
            }
            setAEPName.add(objOpp.IC__c);
            createICTransactionDebitRecord(objOpp,date.newinstance(cancellationYear,cancellationMonth,20),mapAEPNamevs,setAEPName,AdditionalDebitAmount ); 
        }   
    }
  
    public void createICTransactionDebitRecord(Opportunity objOpp,Date DueDate,Map<String,Integer> mapAEPNamevs,Set<String>setAEPName,Integer AdditionalDebitAmount){
            Date today = Date.Today(); 
            String opposid;                 
            Integer cancellationMonth = 0;
              Integer AEPDebit = 0;
            Integer cancellationYear = today.Year();
            if (today.day() <= 10) {
                cancellationMonth = today.Month();
            } else {
                cancellationMonth = today.Month() + 1;
            }
            if(cancellationMonth >=13)
            {
                cancellationMonth = cancellationMonth - 12;
                cancellationYear = today.Year()+1;
            }
            
            //Link IC Payment with Student
            List<IC_Payment_Transaction__c> lstip = new List<IC_Payment_Transaction__c>();     
            Opportunity objOpportunity =new Opportunity(id =objOpp.id);            
            opposid=objOpportunity.id;
          
        if(setAEPName.size()>0)
        {
            for(String ICname:setAEPName)
            {
                double DebitSum = mapAEPNamevs.get(ICname+'_'+'Adjustment - Debit');
                double CreditSum = mapAEPNamevs.get(ICname+'_'+'Admission Commision - Credit');
                
                if (DebitSum <=0 || DebitSum ==null)
                {
                    DebitSum =0;
                }
                if (CreditSum <=0 || CreditSum ==null)
                {
                    CreditSum  =0;
                }
                if(AdditionalDebitAmount>0)
                {
                    AEPDebit  = Integer.valueof(AdditionalDebitAmount*getSharePercentage(objOpp.ChooseProgram__c,objOpp.Specialisation__c));
                }
                IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c (); 
                ip.Amount__c = CreditSum - DebitSum - AEPDebit;
                ip.Narration__c = objOpp.Account.Name +' - Admission Cancellation';
                IC_Payment__c iOne = getICPayment(String.valueof(cancellationYear), String.valueof(cancellationMonth), ICname);
                ip.IC_Payment__c = iOne.id;
                ip.Transaction_Category__c = 'Admission Cancellation';
                ip.Transaction_Type__c = 'Adjustment - Debit';
                ip.Due_Date__c = DueDate;
                ip.Date__c = today;
                ip.Opportunity__c = objOpp.ID;          
                ip.Account__c = objOpp.AccountId;
                if(ip.Amount__c > 1) {
                lstip.add(ip);
                }
            }
        }
        if(lstip.size()>0)
        {
            insert lstip;
        }  

    }
    

    /**
    * @description 
    * @author @BK | 21-09-2024 
    * @param Map<String IC_Payment__c> existingICPaymentMap 
    * @param Opportunity o 
    * @param List<IC_Payment_Transaction__c> ipTransectionList 
    * @param PaymentDate objConfig 
    **/
    public void createCourierDebitEntryForFullFeeSEM2AndBeyond(Map<String,IC_Payment__c> existingICPaymentMap, 
                                                                Opportunity o, List<IC_Payment_Transaction__c> ipTransectionList, 
                                                                PaymentDate objConfig) {

        Date dueDate = Date.newinstance(objConfig.confYear, objConfig.confMonth, 20);
        String paymentKey = String.valueOf(o.Account.nm_Centers__c) + objConfig.confirmationMonthYear;
        if(existingICPaymentMap.containsKey(paymentKey)) {
            System.debug('IF 1 ENTERED!');
            IC_Payment__c iOne = existingICPaymentMap.get(paymentKey);
            if(o.BookCChargeapplicable__c) {
                createAdhocDebitRecord(ipTransectionList, o, iOne,fixedDeduct ,false,'Book Courier Charges',dueDate,'Postage Recovery (TBD)');
            }
        }
        //If payment record for an IC for first Month+Year doesn't exists then create a record 
        else {
            system.debug('ELSE 1 ENTERED!');       
            IC_Payment__c iOne = getICPayment(String.valueof(objConfig.confYear),String.valueof(objConfig.confMonth),o.IC__c);
            if(o.BookCChargeapplicable__c) {                  
                createAdhocDebitRecord(ipTransectionList, o, iOne,fixedDeduct ,false,'Book Courier Charges',dueDate,'Postage Recovery (TBD)');
            }
        }
    }
    
    //phalguni 23-09-2017
    //Method call for Single Credit Entry from ProductHelper Class
      public void createICTransactionCreditEntry(Opportunity objOpp, Integer excessYear, Integer excessMonth,Decimal Amount,String InformationCenter,String Narration){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();  
        IC_Payment__c icPayment = getICPayment(String.valueOf(excessYear),String.valueOf(excessMonth),InformationCenter);        
        ip.Amount__c = Amount;
        ip.Narration__c = (Narration!='' && Narration!= null) ? objOpp.Account.Name +' - '+Narration : objOpp.Account.Name + ' - Pending Commission';
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(excessYear)+'-'+String.valueOf(excessMonth)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        insert ip;
    }
    //Method call for Single Debit Entry from ProductHelper Class
    public void createICTransactionDebitEntry(Opportunity objOpp, Integer excessYear, Integer excessMonth,Decimal Amount,String InformationCenter,String Narration){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();  
        IC_Payment__c icPayment = getICPayment(String.valueOf(excessYear),String.valueOf(excessMonth),InformationCenter);        
        ip.Amount__c = Amount;
        
        ip.Narration__c = (Narration!='' && Narration!= null) ?  objOpp.Account.Name +' - '+Narration : objOpp.Account.Name + ' - AdjustmentDebit'  ;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(excessYear)+'-'+String.valueOf(excessMonth)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        insert ip;
    }
   //Generic method to get IC payment
    public IC_Payment__c getICPayment(String paymentyear,String paymentmonth, String Center)
    {
        system.debug('paymentyear--->'+paymentyear);
        system.debug('paymentmonth--->'+paymentmonth);
        system.debug('Center--->'+Center);
         
         List<IC_Payment__c> lstofICPayment = [select id,Payment_Month__c,Payment_Year__c,Amount__c,
                                         Centers__c,nm_CenterName__c ,Payment_Due_Date__c
                                         from IC_Payment__c 
                                         where Payment_Year__c =:paymentyear 
                                         and Payment_Month__c =:paymentmonth
                                         and nm_CenterName__c =:Center];       
        if(lstofICPayment.size()>0 )
        {
        System.debug('lstofICPayment.size()--->'+lstofICPayment);
            return lstofICPayment[0];
        }
        else
        {
              IC_Payment__c icPayment = new IC_Payment__c();  
              list<nm_Centers__c>  lstcenterid = [select id, name from nm_Centers__c where name=:Center];          
                icPayment.Amount__c =  fixedDeduct;
                icPayment.Payment_Month__c = paymentmonth;
                icPayment.Payment_Year__c = paymentyear; 
                icPayment.Payment_Due_Date__c  = Date.ValueOf(String.valueOf(paymentyear)+'-'+String.valueOf(paymentmonth)+'-'+'20 1:00:00');
                icPayment.Centers__c = lstcenterid[0].id;
                insert icPayment;
                System.debug('icPayment--->'+icPayment);
                return icPayment;
        }
       
    }
     
     public void createAdhocDebitRecord(List<IC_Payment_Transaction__c> ipTransectionList, Opportunity objOpp, IC_Payment__c icPayment,Integer Amount,Boolean Sharetype,String Narration,Date DueDate,String Category){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();   
        ip.Amount__c = Amount;
        ip.Narration__c = objOpp.Account.Name +' - '+Narration;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = DueDate;
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        ip.NonAdmissionShare__c = Sharetype;
        ip.Transaction_Category__c = Category;
        ipTransectionList.add(ip);

    }  
    public void createAdhocDebitRecord(List<IC_Payment_Transaction__c> ipTransectionList, Opportunity objOpp, IC_Payment__c icPayment,Integer Amount,Boolean Sharetype,String Narration,Date DueDate){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();   
        ip.Amount__c = Amount;
        ip.Narration__c = objOpp.Account.Name +' - '+Narration;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = DueDate;
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        ip.NonAdmissionShare__c = Sharetype;
        ipTransectionList.add(ip);

    }  
     public void createAdhocCreditRecord(List<IC_Payment_Transaction__c> ipTransectionList, Opportunity objOpp, IC_Payment__c icPayment,Integer Amount,Boolean Sharetype,String Narration,Date DueDate,String Category){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();   
        ip.Amount__c = Amount;
        ip.Narration__c = objOpp.Account.Name +' - '+Narration;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = DueDate;
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        ip.NonAdmissionShare__c = Sharetype;
        ip.Transaction_Category__c = Category;
        ipTransectionList.add(ip);

    }  
    public void createAdhocCreditRecord(List<IC_Payment_Transaction__c> ipTransectionList, Opportunity objOpp, IC_Payment__c icPayment,Integer Amount,Boolean Sharetype,String Narration,Date DueDate){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();   
        ip.Amount__c = Amount;
        ip.Narration__c = objOpp.Account.Name +' - '+Narration;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = DueDate;
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        ip.NonAdmissionShare__c = Sharetype;
        ipTransectionList.add(ip);

    }  
    //Method call for Single Debit Entry Deregister
    public void createDebitEntry(Opportunity objOpp, Integer excessYear, Integer excessMonth,Decimal Amount,String InformationCenter,String Narration,Boolean Sharetype,String Category){
        Date today = Date.Today(); 
        //Link IC Payment with Student
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();  
        IC_Payment__c icPayment = getICPayment(String.valueOf(excessYear),String.valueOf(excessMonth),InformationCenter);        
        ip.Amount__c = Amount;
        
        ip.Narration__c = (Narration!='' && Narration!= null) ?  objOpp.Account.Name +' - '+Narration : objOpp.Account.Name + ' - AdjustmentDebit'  ;
        ip.IC_Payment__c = icPayment.Id;    
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(excessYear)+'-'+String.valueOf(excessMonth)+'-'+'20 1:00:00');
        ip.Date__c = today;
        ip.Opportunity__c = objOpp.ID;    
        ip.Account__c = objOpp.AccountId;
        ip.NonAdmissionShare__c = Sharetype;
        ip.Transaction_Category__c = Category;
        insert ip;
    }
    public Integer getMultipleNumber(String feesType)
    {
       Integer sem =1;
        if(feesType=='AnnualFee' || feesType == '2TermFee')
        {
            sem=2;
        }else if(feesType=='MultipleSemFee' || feesType=='3SemFee' || feesType=='3TermFee')
        {
            sem=3;
        }
        else if(feesType=='FullFee')
        {
            sem=2;
        } else 
        {
            sem =1;
        }
        return sem;
    }
    
    public Integer getMultipleNumberPP(String feesType,Integer currentsem) {
        Integer sem =1;
        if((feesType=='AnnualFee' || feesType == '2TermFee') && currentsem<3)
        {
            sem=2;
        }else if((feesType=='AnnualFee' ||  feesType == '2TermFee') && currentsem==3)
        {
            sem=1;
        }
        else if((feesType=='MultipleSemFee' || feesType=='3SemFee') || feesType=='3TermFee' && currentsem==2)
        {
            sem=2;
        }
        else if((feesType=='MultipleSemFee' || feesType=='3SemFee') || feesType=='3TermFee' && currentsem==1)
        {
            sem=3;
        }
        else if(feesType=='FullFee')
        {
            sem=3;
        } else 
        {
            sem =1;
        }
        return sem;
    }
    
    public Decimal getSharePercentage(String chooseProgram,String specialization) {
        if(chooseProgram =='Master Programs' && specialization != 'MBA (X)') {
            return Decimal.valueOf(Label.ICSharePercentage_DegreeProgram);
        } 
        
        if(chooseProgram =='Certificate Programs' && specialization == 'PC Term 2') {                         
            return Decimal.valueOf(Label.ICSharePercentage_DegreeProgram);                         
        }
        
        if(chooseProgram =='Professional Programs' && specialization == 'PD Term 4') {                         
            return Decimal.valueOf(Label.ICSharePercentage_DegreeProgram);                         
        }
        
        if(chooseProgram =='Certificate Programs' && specialization == 'CPWL') {
            return Decimal.valueOf(Label.ICSharePercentage_CPWL);
        }                        
                           
        return Decimal.valueOf(Label.ICSharePercentage_PGD_D);

    }
  
    public class ConfigMonthYear {
        public ConfigMonthYear() {
            this.confMonth = 0; // Initialize confirmation month
            this.confYear = 0; // Initialize confirmation year
            this.confirmationMonthYear = '';
            this.incrementMonth = 0;
            this.shareConfig = new PaymentShareConfig__c();
        }

        public Integer confMonth {get;set;} // Confirmation month property
        public Integer confYear {get;set;} // Confirmation year property
        public String confirmationMonthYear {get;set;} // confirmation month/year data
        public Integer incrementMonth {get;set;}
        public PaymentShareConfig__c shareConfig {get;set;}
    }

    public class PaymentDate {
        public PaymentDate() {
            this.confirmationMonthYear = '';
            this.confMonth = 0; // Initialize confirmation month
            this.confYear = 0; // Initialize confirmation year
        } 

        public String confirmationMonthYear {get;set;} // confirmation month/year data
        public Integer confMonth {get;set;} // Confirmation month property
        public Integer confYear {get;set;} // Confirmation year property
    }
        
}