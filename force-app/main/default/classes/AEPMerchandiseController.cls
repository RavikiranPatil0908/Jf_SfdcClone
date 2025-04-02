/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : @vickysahu
**/
public without sharing  class AEPMerchandiseController {
    public AEPMerchandiseController() {

    }

    @AuraEnabled(Cacheable = true)
    public static List<PriceBookAndProduct> getAllProducts(){
        List<PriceBookAndProduct> lstPriceBookAndProduct = new List<PriceBookAndProduct>(); 
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); 
        String PriceBookEntry = 'select id, UnitPrice,Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c,product2.Family, product2.Name, product2.nm_Program__c, product2.nm_Semester__c'+
                +' from PriceBookEntry where product2.isActive = true '+
                +'and pricebook2.isStandard = false and Pricebook2.nmSession_Start_Date__c !=null '+
                +'and Pricebook2.nmSession_End_Date__c !=null ' +
                +'and product2.Family = \'AEP Merchandise\' ' +
                +'and Pricebook2.IsActive=true ';
        System.debug('Query = '+PriceBookEntry);
        lstPriceBookEntry = DataBase.query(PriceBookEntry);

        Set<Id> setOfProductIds = new Set<Id>();

        for(PriceBookEntry objPriceBook : lstPriceBookEntry) {
                system.debug(objPriceBook);
                setOfProductIds.add(objPriceBook.Product2Id);
        }
        Map<Id,Product2>  mapOfProducts = new Map<id,Product2>([SELECT Id, Name,Product_Image__c, Product_Size__c, Size_Chart__c FROM Product2 WHERE Id IN :setOfProductIds ]);
        for(PriceBookEntry objPriceBook : lstPriceBookEntry) {
            if(mapOfProducts.containsKey(objPriceBook.Product2Id)) {
                PriceBookAndProduct PriceBookAndProduct = new PriceBookAndProduct();
                PriceBookAndProduct.Pricebook = objPriceBook;
                PriceBookAndProduct.Product = mapOfProducts.get(objPriceBook.Product2Id);
                lstPriceBookAndProduct.add(PriceBookAndProduct);
                system.debug(mapOfProducts.get(objPriceBook.Product2Id));
            }
        }
        return lstPriceBookAndProduct;

    }

    @AuraEnabled(Cacheable = true)  
    public static nm_UserMapping__c getCenterUserData(String userId) {
    
        nm_UserMapping__c centerUser = new nm_UserMapping__c();
        try{
            System.debug('userId -->'+userId);
            List<User> lstUser = [Select Id, UserRole.Name FROM User WHERE Id= :userId];
            system.debug('lstUser ---> ' + lstUser);
            List<nm_UserMapping__c> lstcenterDetails = [SELECT Id, nm_Centers__c, nm_Centers__r.Name,
            nm_Centers__r.Center_Name__c,nm_Head__c,UserId__c,nm_Centers__r.Password__c FROM nm_UserMapping__c WHERE 
            UserId__c =:userId AND (nm_User__r.UserRole.Name LIKE '%Executive' OR nm_User__r.Profile.Name = 'System Administrator') ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('lstcenterDetails-->'+lstcenterDetails);
            if(lstcenterDetails.size()>0){
                centerUser = lstcenterDetails[0];
                System.debug('lstcenterDetails-->'+lstcenterDetails);
            }
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }   
        return centerUser;
    }


    @AuraEnabled
    public static string placeOrder(String CenterId, String orderString){
        String response = '';
        try {
            nm_Centers__c center = [SELECT Id, AEP_Merchen__c FROM nm_Centers__c WHERE Id=:CenterId LIMIT 1];
            nm_Centers__c objCen = new nm_Centers__c();
            objCen.Id = CenterId;
            objCen.AEP_Merchen__c = String.isNotBlank(center.AEP_Merchen__c) ? center.AEP_Merchen__c + '\n ' + orderString : orderString;
            update objCen;
            response = 'order created';

        } catch (Exception e) {
            response = 'fail';
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    public static void SendMailForAEPMerchandise(String paymentId) {
        List<EmailTemplate> emailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE Name ='AEPMerchendise Email To Market' OR Name = 'AEPMerchendise Email To AEP' LIMIT 2];
        system.debug(emailTemplates);

        String EmailToMarket = '';
        String EmailToAEP = '';
        nm_Payment__c objPayment = [SELECT Id, AEP__r.AEP_email_id__c FROM nm_Payment__c WHERE Id = :paymentId LIMIT 1 ];
        system.debug('objPayment.AEP__r.AEP_email_id__c ==> ' + objPayment.AEP__r.AEP_email_id__c);


        List<Messaging.SingleEmailMessage > lstEmailMessage = new List<Messaging.SingleEmailMessage>();

        for(EmailTemplate objEmail: emailTemplates) {
            String[] sendingToAddresses;
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(objEmail.Id,null, paymentId);
            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            String[] sendingToBCCAddress = new List<String>{'suyog.deshmukh.ext@nmims.edu'};
            
            String emailSubject = email.getSubject();
            String emailTextBody = email.getHtmlBody();
            
            if(objEmail.Name == 'AEPMerchendise Email To Market' ) {
                if(System.Label.Environment == 'Sandbox') {
                    sendingToAddresses =  new List<String>{'suyog.deshmukh.ext@nmims.edu'};
                } else if(System.Label.Environment == 'Production') {
                     sendingToAddresses =  new List<String>{'Sumeet.Gimhavanekar@nmims.edu','Rajshree.Pawar@nmims.edu', 'marketing.ngasce@nmims.edu'};
                }
            } else if(objEmail.Name == 'AEPMerchendise Email To AEP') {
                if(System.Label.Environment == 'Sandbox') {
                    sendingToAddresses =  new List<String>{'suyog.deshmukh.ext@nmims.edu'};
                } else if(System.Label.Environment == 'Production') {
                    sendingToAddresses =  new List<String>{objPayment.AEP__r.AEP_email_id__c};
                }
            }
            email.setOrgWideEmailAddressId(owe.id); 
            email.setSubject(emailSubject);
            email.setHtmlBody(emailTextBody);
            email.setToAddresses(sendingToAddresses);
            email.setBccAddresses(sendingToBCCAddress);
            email.saveAsActivity = false;
            lstEmailMessage.add(email);
        }
        if(lstEmailMessage.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessage);
            if(results[0].success) {
                system.debug('Email Send Successfully');
            } else {
                system.debug('Failed to send mail ' + results[0].errors[0].message);
                 
            }

        }


    }

    @AuraEnabled(Cacheable = true)  
    public Static List<Case> searchCase(String searchQuery, String filterDetails) {
        try {
            String modifiedSearchQuery = '\'*'+ searchQuery +'*\'';
            String whereCon = '';
            if(String.isNotBlank(filterDetails)) {
    
                Map<String ,Object> mapOfFilterDetails = (Map<String ,Object>) System.JSON.deserializeUntyped(filterDetails);
                List<String> lstOfANDClause = new List<String>();
                for(String key: mapOfFilterDetails.keySet()) {
                    List<String> lstOfORClause = new List<String>();
                    System.debug(key);
                    Map<String, Object> mapOfKeyFilter = (Map<String, Object>) mapOfFilterDetails.get(key);
                    if ((String) mapOfKeyFilter.get('fieldType') == 'MultiplePickList') {
                        List<Object> lstFilter = (List<Object>) mapOfKeyFilter.get('value');
                        if (lstFilter.size() > 0) {
                            for(Object filter : lstFilter) {
                                String filterName = (String) filter == 'none' ? null : '\'' + (String) filter  +'\'';
                                lstOfORClause.add(mapOfKeyFilter.get('apiName') + ' = ' + filterName );
                            }
                            System.debug(lstFilter);
                            System.debug(String.join(lstOfORClause, ' OR ' ));
                            String joinOfORClause = '( ' + String.join(lstOfORClause, ' OR ' ) + ' )';
                            lstOfANDClause.add(joinOfORClause);       
                        }
                    }
                }
                System.debug(mapOfFilterDetails);
                if (lstOfANDClause.size() > 0) {
                    whereCon = 'WHERE ' + String.join(lstOfANDClause, ' AND ');
                }
                
                // whereCon = whereCon + String.join(lstOfANDClause, ' AND ');
            } 
            String query = '';
            if(String.isNotBlank(searchQuery)) {
                query = 'FIND ' + modifiedSearchQuery+' IN ALL FIELDS RETURNING Case (id, CaseNumber, Subject, Owner.Name, Description, Status ' + whereCon +' LIMIT 500 )';
                System.debug(query);
                List<List<SObject>> CaseSObject = Search.query(query);
                Case [] lstCase = ((List<Case>)CaseSObject[0]);
                return lstCase;

            } else {   
                query = 'SELECT CaseNumber, Id, Subject, Description, Status, Owner.Name FROM Case ' + whereCon + ' LIMIT 500';
                System.debug(query);
                return DataBase.query(query);
            }
        } catch (Exception e) {
            System.debug('Exception -- ' + e.getLineNumber() + ' --- '+e.getMessage());
            // return 'Something went Wrong, Failed to Update, Kindly try again';
            return new List<Case>();
        }

    }

    @AuraEnabled
    public Static String updateStatusAndSendMailForCase(String caseUpdateDetails) {
        List<Case> lstCaseToUpdate = new List<Case>();
        Boolean isNewSubjectNeeded = false;
        Boolean isEmailToSent = false;
        Messaging.SingleEmailMessage[] lstMails = new List<Messaging.SingleEmailMessage>();
        try {
            if(String.isNotBlank(caseUpdateDetails)) {
                Map<String, Object>  mapOfCaseUpdate = (Map<String ,Object>) JSON.deserializeUntyped(caseUpdateDetails);
                String caseNumber = (String) mapOfCaseUpdate.get('caseNumbers');
                String caseStatus = (String) mapOfCaseUpdate.get('caseStatus');
                String caseSubject = (String) mapOfCaseUpdate.get('caseSubject');
                String caseSubjectType = (String) mapOfCaseUpdate.get('caseSubjectType');
                String caseDescription = (String) mapOfCaseUpdate.get('caseDescription');
                isNewSubjectNeeded = (Boolean) mapOfCaseUpdate.get('isNewSubjectNeeded');
                isEmailToSent = (Boolean) mapOfCaseUpdate.get('isEmailToSent');
                Set<String> setOfCaseNumber = new Set<String>(new List<String>(caseNumber.split(',')));
                List<Case> lstCase = [SELECT id,CaseNumber,Case_Id__c,Owner_update__c,Tech_Issue__c,Mass_Email_Case_status__c,status,ContactEmail,SuppliedEmail,Description,Subject,Reference__c FROM Case WHERE  CaseNumber IN :setOfCaseNumber];
                if(lstCase.size() > 0) {
                    for(Case objCase : lstCase) {
                        objCase.Status = caseStatus;
                        if(String.isBlank(objCase.Tech_Issue__c)){
                            objCase.Tech_Issue__c = 'No';
                        }
                        if(isEmailToSent && String.isNotBlank(objCase.SuppliedEmail) && Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', objCase.SuppliedEmail)) {
                            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
                            String[] sendingToAddress = new List<String>();
                            sendingToAddress.add(objCase.SuppliedEmail);
                            if(System.Label.Environment == 'Sandbox') {
                                sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
                                sendingToAddress.add('dsuyog2013@gmail.com');
                            }
                            semail.setToAddresses(sendingToAddress); 
                            semail.setWhatId(objCase.Case_Id__c);
                            semail.setOrgWideEmailAddressId(owe.id); 
                            // semail.setReplyTo('ngasce@nmims.edu'); 
                            String emailSubject = caseSubjectType == 'Existing Subject' ? objCase.Subject : caseSubject;
                            semail.setSubject('Case # ' + objCase.CaseNumber + ': ' + emailSubject); 
                            String messageBody =    '<html><p>Dear Student,</p>'+
                                                    '<p>Greetings from NMIMS Center For Distance And Online Education! This is in reference to your query about</p>'+
                                                    '<p>' + caseDescription + '</p>' +
                                                    '<p>In case you have any queries, kindly call us on our Toll Free no.1800 1025 136 (Monday to Saturday between 9:00 AM to 7.00 PM)</p>' +
                                                    '<p>Have a Nice Day!!</p>' +
                                                    '<p>Thanks and Regards,</p>' +
                                                    '<p>NMIMS CDOE</p></html>';
                            semail.setHtmlBody(messageBody);
                            lstMails.add(semail);
                        }
                        lstCaseToUpdate.add(objCase);
                    }
                }
                if(lstMails.size() > 0 && isEmailToSent) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails);
                    if(results[0].success) {
                        system.debug('Email Send Successfully');
                        if(lstCaseToUpdate.size()>0)
                        {
                            system.debug('lstCaseToUpdate--->'+lstCaseToUpdate.size());
                            update lstCaseToUpdate;
                            return 'SuccessFully updated case and mailed';
                        }
                    } else {
                        system.debug('Failed to send mail ' + results[0].errors[0].message);
                        return 'Something went Wrong, Failed to send mail, Kindly try again ' +results[0].errors[0].message;
                        
                    }
                } else if(!isEmailToSent) {
                    if(lstCaseToUpdate.size()>0){
                        system.debug('lstCaseToUpdate--->'+lstCaseToUpdate.size());
                        update lstCaseToUpdate;
                        return 'SuccessFully updated case';
                    }
                }

            }
            return 'Something went wrong';
        } catch (Exception e) {
            System.debug('Exception -- ' + e.getLineNumber() + ' --- '+e.getMessage());
            return 'Something went Wrong, Failed to Update, Kindly try again' + e.getLineNumber() + ' --- '+e.getMessage();
        }

    }

    @AuraEnabled(cacheable=true)
    public static List<nm_Program__c> getProgramDetails(){
        try {
            return [SELECT Id, Name, nmIsActive__c, nm_ProgramName__c, nm_Type__c, prgst__c, Specialisation__c FROM nm_Program__c WHERE nmIsActive__c = TRUE];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Interview_Slot__c>> getMapOfInterviewSlot(){
        Set<String> setOfSpecialization = new Set<String>{'MBA (WX)', 'MBA (X)', 'M.Sc. (AI & ML Ops)', 'M.Sc. (AI)'};
        Map<String, Date> mapOfSpecVsDate = new Map<String, Date>();
        Map<String, List<Interview_Slot__c>> mapOfInterviewSlot = new Map<String, List<Interview_Slot__c>>();
        try {
            for (Calender__c objCal : [SELECT Id, Name, Session_Start_Date__c, Session_End_Date__c, Session__c, Year__c, Category__c, nm_Type__c, nm_Semester__c, Specialisation__c FROM Calender__c WHERE Session_End_Date__c >= TODAY AND Specialisation__c IN :setOfSpecialization AND Category__c = 'Admission']) {
                mapOfSpecVsDate.put(objCal.Specialisation__c, objCal.Session_Start_Date__c);
            }
            for (Interview_Slot__c objIntSlot : [SELECT Id, Interview_Date__c, Name, Start_time__c, End_time__c, Program_Type__c FROM Interview_Slot__c WHERE 
                (Interview_Date__c > :mapOfSpecVsDate.get('MBA (WX)') AND Program_Type__c = 'MBA (WX)' ) OR  (Interview_Date__c > :mapOfSpecVsDate.get('MBA (X)') AND Program_Type__c = 'MBA (X)' ) OR
                (Interview_Date__c > :mapOfSpecVsDate.get('M.Sc. (AI & ML Ops)') AND Program_Type__c = 'M.Sc. (AI & ML Ops)' ) OR  (Interview_Date__c > :mapOfSpecVsDate.get('M.Sc. (AI)') AND Program_Type__c = 'M.Sc. (AI)' )
                 ]) {
                List<Interview_Slot__c> lstInterview = mapOfInterviewSlot.containsKey(objIntSlot.Program_Type__c) ? mapOfInterviewSlot.get(objIntSlot.Program_Type__c) : new List<Interview_Slot__c>();
                lstInterview.add(objIntSlot);
                mapOfInterviewSlot.put(objIntSlot.Program_Type__c, lstInterview );
            }
            return mapOfInterviewSlot;
        } catch (Exception e) {
            throw new AuraHandledException( e.getLineNumber() + ' --- '+e.getMessage());
        }

    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, ProgramDates>> getProgramDates(){
        // List<String> lstCategory = new List<String>{'Admission', 'Re-Registration'};
        Set<String> setPayFormConf = new Set<String>();
        set<String> setSessionString = new Set<String>();
        set<String> setYearString = new Set<String>();
        set<String> setChooseProgramWithoutSpecialization = new Set<String>{'Certificate Programs', 'Diploma Programs', 'MBA (Distance) Programs'};
        Map<String, Map<String, ProgramDates>> mapOfTypeVsCategoryVsProgramDate = new Map<String, Map<String, ProgramDates>>();
        try {
            for (Calender__c objCal : [SELECT Id, Name, Session_Start_Date__c, Session_End_Date__c, Session__c, Year__c, Category__c, nm_Type__c, nm_Semester__c, Specialisation__c FROM Calender__c WHERE Session_End_Date__c >= TODAY ]) {
                
                if (objCal.Category__c == 'Admission' && objCal.Specialisation__c == null) {
                    for (String chooseProgram : setChooseProgramWithoutSpecialization) {
                        if (!mapOfTypeVsCategoryVsProgramDate.containsKey(chooseProgram)) {
                            mapOfTypeVsCategoryVsProgramDate.put(chooseProgram, new Map<String, ProgramDates>());
                        }
                        Map<String, ProgramDates> mapOfCategoryVsProgramDate = mapOfTypeVsCategoryVsProgramDate.get(chooseProgram);
                        String key = objCal.Category__c + '_null_1';
                        ProgramDates ProgramDates = mapOfCategoryVsProgramDate.containsKey(key) ? mapOfCategoryVsProgramDate.get(key) : new ProgramDates();
                        ProgramDates.ApplicationStartDate = objCal.Session_Start_Date__c;
                        ProgramDates.ApplicationEndDate = objCal.Session_End_Date__c;
                        ProgramDates.programType = chooseProgram ;
                        ProgramDates.admissionCategory = objCal.Category__c;
                        ProgramDates.semester = '1';
                        ProgramDates.session = objCal.Session__c;
                        ProgramDates.year = String.valueOf(objCal.Year__c);
                        ProgramDates.CalenderId = objCal.Id;
                        mapOfCategoryVsProgramDate.put(key, ProgramDates);
                        mapOfTypeVsCategoryVsProgramDate.put(chooseProgram, mapOfCategoryVsProgramDate);
                    }
                } else if(objCal.nm_Type__c != null){
                    if (!mapOfTypeVsCategoryVsProgramDate.containsKey(objCal.nm_Type__c)) {
                        mapOfTypeVsCategoryVsProgramDate.put(objCal.nm_Type__c, new Map<String, ProgramDates>());
                    }
                    Map<String, ProgramDates> mapOfCategoryVsProgramDate = mapOfTypeVsCategoryVsProgramDate.get(objCal.nm_Type__c);
                    String semester = objCal.nm_Semester__c == null ? '1' : objCal.nm_Semester__c;
                    String key = objCal.Category__c + '_' +objCal.Specialisation__c + '_' + semester;
                    ProgramDates ProgramDates = mapOfCategoryVsProgramDate.containsKey(key) ? mapOfCategoryVsProgramDate.get(key) : new ProgramDates();
                    ProgramDates.ApplicationStartDate = objCal.Session_Start_Date__c;
                    ProgramDates.ApplicationEndDate = objCal.Session_End_Date__c;
                    ProgramDates.programType = objCal.nm_Type__c; 
                    ProgramDates.admissionCategory = objCal.Category__c;
                    ProgramDates.semester = semester;
                    ProgramDates.session = objCal.Session__c;
                    ProgramDates.year = String.valueOf(objCal.Year__c);
                    ProgramDates.CalenderId = objCal.Id;
                    mapOfCategoryVsProgramDate.put(key, ProgramDates);
                    mapOfTypeVsCategoryVsProgramDate.put(objCal.nm_Type__c, mapOfCategoryVsProgramDate);
                }
            }
            for (NM_Payment_Form_Configuration__c objPayFormConf : [SELECT Id, Last_Date_For_Video_Verification__c, Program_Category__c, Payment_Type__c,Program_Type__c, Semester__c, Payment_Window_StartDate__c, Payment_Window_EndDate__c, Session__c, Current_Admission_Year__c,Loan_Window_EndDate__c FROM NM_Payment_Form_Configuration__c WHERE Payment_Window_EndDate__c >= TODAY ]) {
                    if (mapOfTypeVsCategoryVsProgramDate.containsKey(objPayFormConf.Program_Category__c)) {
                        Map<String, ProgramDates> mapOfCategoryVsProgramDate = mapOfTypeVsCategoryVsProgramDate.get(objPayFormConf.Program_Category__c);
                        String key = objPayFormConf.Payment_Type__c + '_' +  objPayFormConf.Program_Type__c + '_' + objPayFormConf.Semester__c;
                        ProgramDates ProgramDates = mapOfCategoryVsProgramDate.containsKey(key) ? mapOfCategoryVsProgramDate.get(key) : new ProgramDates();
                        ProgramDates.programType = objPayFormConf.Program_Category__c;
                        ProgramDates.admissionCategory = objPayFormConf.Payment_Type__c;
                        ProgramDates.semester = objPayFormConf.Semester__c;
                        ProgramDates.session = objPayFormConf.Session__c;
                        ProgramDates.year = objPayFormConf.Current_Admission_Year__c;
                        ProgramDates.specialization = String.isBlank(objPayFormConf.Program_Type__c) ? null : objPayFormConf.Program_Type__c;
                        ProgramDates.paymentStartDate = objPayFormConf.Payment_Window_StartDate__c;
                        ProgramDates.paymentEndDate = objPayFormConf.Payment_Window_EndDate__c;
                        ProgramDates.loanWindowEndDate = objPayFormConf.Loan_Window_EndDate__c;
                        ProgramDates.paymentConfigId = objPayFormConf.Id;
                        ProgramDates.videoVerificationLastDate = objPayFormConf.Last_Date_For_Video_Verification__c;
                        setPayFormConf.add(objPayFormConf.Id);
                        mapOfCategoryVsProgramDate.put(key, ProgramDates);
                        mapOfTypeVsCategoryVsProgramDate.put(objPayFormConf.Program_Category__c, mapOfCategoryVsProgramDate);
                    }
                }
            
        for (Late_Fee__c objLateFee : [SELECT Id, Name, Start_Date__c, Session__c, Year__c, End_Date__c, Late_Fees__c, nm_Type__c, Program_Type__c, Category__c FROM Late_Fee__c WHERE End_Date__c >= Today ]) {
                Integer lateFeeSlab = objLateFee.Late_Fees__c == 500 ? 1 : objLateFee.Late_Fees__c  == 1000 ? 2 : 0;
                if(mapOfTypeVsCategoryVsProgramDate.containsKey(objLateFee.nm_Type__c)) {
                    Map<String, ProgramDates> mapOfCategoryVsProgramDate = mapOfTypeVsCategoryVsProgramDate.get(objLateFee.nm_Type__c);
                    if (objLateFee.Category__c == 'Registration' || objLateFee.Category__c == 'Is Lateral') {
                        String category = objLateFee.Category__c == 'Is Lateral' ? 'Lateral'  : objLateFee.Category__c;
                        String key = category + '_' + objLateFee.Program_Type__c + '_' + '-';
                        ProgramDates ProgramDates = mapOfCategoryVsProgramDate.containsKey(key) ? mapOfCategoryVsProgramDate.get(key) : new ProgramDates();
                        ProgramDates.programType = objLateFee.nm_Type__c;
                        ProgramDates.admissionCategory = objLateFee.Category__c;
                        ProgramDates.semester = '-';
                        ProgramDates.session = objLateFee.Session__c;
                        ProgramDates.year = objLateFee.Year__c;
                        ProgramDates.specialization = String.isBlank(objLateFee.Program_Type__c) ? null : objLateFee.Program_Type__c;
                        if (lateFeeSlab == 1) {
                            ProgramDates.LateFeeStartDateSlab1 = objLateFee.Start_Date__c;
                            ProgramDates.LateFeeEndDateSlab1 = objLateFee.End_Date__c;
                            ProgramDates.LateFeeSlab1Id = objLateFee.Id;
                        } else if (lateFeeSlab == 2) {
                            ProgramDates.LateFeeStartDateSlab2 = objLateFee.Start_Date__c;
                            ProgramDates.LateFeeEndDateSlab2 = objLateFee.End_Date__c;
                            ProgramDates.LateFeeSlab2Id = objLateFee.Id;
                        } 
                        // else {
                        //     ProgramDates.LateFeeStartDateSlab3 = objLateFee.Start_Date__c;
                        //     ProgramDates.LateFeeEndDateSlab3 = objLateFee.End_Date__c;
                        //     ProgramDates.LateFeeSlab3Id = objLateFee.Id;
                        // }
                        mapOfCategoryVsProgramDate.put(key, ProgramDates);
                        mapOfTypeVsCategoryVsProgramDate.put(objLateFee.nm_Type__c, mapOfCategoryVsProgramDate);
                    } else {
                        for (String keySet : mapOfCategoryVsProgramDate.keySet()) {
                            List<String> catKey = keySet.split('_');
                            System.debug('catKey --> ' + catKey);
                            String category = catKey[0], specialization = catKey[1], semester = catKey[2];
                            String key = objLateFee.Category__c + '_' + objLateFee.Program_Type__c + '_' + semester;
                            if (mapOfCategoryVsProgramDate.containsKey(key)) {
                                ProgramDates ProgramDates = mapOfCategoryVsProgramDate.get(key);
                                if (lateFeeSlab == 1) {
                                    ProgramDates.LateFeeStartDateSlab1 = objLateFee.Start_Date__c;
                                    ProgramDates.LateFeeEndDateSlab1 = objLateFee.End_Date__c;
                                    ProgramDates.LateFeeSlab1Id = objLateFee.Id;
                                } else if (lateFeeSlab == 2) {
                                    ProgramDates.LateFeeStartDateSlab2 = objLateFee.Start_Date__c;
                                    ProgramDates.LateFeeEndDateSlab2 = objLateFee.End_Date__c;
                                    ProgramDates.LateFeeSlab2Id = objLateFee.Id;
                                } 
                                // else {
                                //     ProgramDates.LateFeeStartDateSlab3 = objLateFee.Start_Date__c;
                                //     ProgramDates.LateFeeEndDateSlab3 = objLateFee.End_Date__c;
                                //     ProgramDates.LateFeeSlab3Id = objLateFee.Id;
                                // }
                                mapOfCategoryVsProgramDate.put(key, ProgramDates);
                                mapOfTypeVsCategoryVsProgramDate.put(objLateFee.nm_Type__c, mapOfCategoryVsProgramDate);
                            }
                        }
                    }
                } 
            }
            System.debug('mapOfTypeVsCategoryVsProgramDate--->' + mapOfTypeVsCategoryVsProgramDate);
            return mapOfTypeVsCategoryVsProgramDate;
        } catch (Exception e) {
            // System.debug('Exception -- ' + e.getLineNumber() + ' --- '+e.getMessage());
            throw new AuraHandledException('error-->' +  e.getLineNumber() + ' --- '+e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Cancelation_Date__c> getCancelDates(String recordId, String dummy){
        List<Cancelation_Date__c> lstCancelationDates = new List<Cancelation_Date__c>();        
        try {
            if (String.isNotBlank(recordId)) {
                lstCancelationDates = [SELECT Id,Amount__c,Admission_Fee__c,NM_Payment_Form_Configuration__c,NM_Payment_Form_Configuration__r.Program_Category__c,NM_Payment_Form_Configuration__r.Program_Type__c,NM_Payment_Form_Configuration__r.Semester__c,NM_Payment_Form_Configuration__r.Payment_Type__c,Percentage__c,To_Date__c,From_Date__c FROM Cancelation_Date__c WHERE NM_Payment_Form_Configuration__c != null AND NM_Payment_Form_Configuration__c =:recordId  order by To_Date__c];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstCancelationDates;
    }

    @AuraEnabled(cacheable=false)
    public static String saveChangedDated(String jsonString){
        Map<String, Calender__c> mapOfKeyCalender = new Map<String, Calender__c>();
        Map<String, NM_Payment_Form_Configuration__c> mapOfKeyPayConfig= new Map<String, NM_Payment_Form_Configuration__c>();
        Map<String, Late_Fee__c> MapOfKeyVsLateFee= new Map<String, Late_Fee__c>();
        Map<String, Map<String, String>> mapOfObjectVsValue = new Map<String, Map<String, String>>();
        Map<String, List<String>> mapOfIdVsField = new Map<String, List<String>>{
            'CalenderId' => new List<String>{'ApplicationStartDate', 'ApplicationEndDate'},
            'paymentConfigId' => new List<String>{'paymentStartDate', 'paymentEndDate', 'loanWindowEndDate', 'videoVerificationLastDate'},
            'LateFeeSlab1Id' => new List<String>{'LateFeeStartDateSlab1', 'LateFeeEndDateSlab1'},
            'LateFeeSlab2Id' => new List<String>{'LateFeeStartDateSlab2', 'LateFeeEndDateSlab2'}
            //'LateFeeSlab3Id' => new List<String>{'LateFeeStartDateSlab3', 'LateFeeEndDateSlab3'}
        };
        Map<String, String> mapOfFieldVsObject = new Map<String, String>{
            'ApplicationStartDate' => 'Calender', 
            'ApplicationEndDate' => 'Calender', 
            'paymentStartDate' => 'payConfig', 
            'paymentEndDate' => 'payConfig', 
            'loanWindowEndDate' => 'payConfig', 
            'videoVerificationLastDate' => 'payConfig',
            'LateFeeStartDateSlab1' => 'lateFee', 
            'LateFeeEndDateSlab1' => 'lateFee',
            'LateFeeStartDateSlab2' => 'lateFee', 
            'LateFeeEndDateSlab2' => 'lateFee'
            // 'LateFeeStartDateSlab3' => 'lateFee', 
            // 'LateFeeEndDateSlab3' => 'lateFee'
        };
        Map<String, String> mapOfFieldVsAPIName = new Map<String, String>{
            'ApplicationStartDate' => 'Session_Start_Date__c', 
            'ApplicationEndDate' => 'Session_End_Date__c', 
            'paymentStartDate' => 'Payment_Window_StartDate__c', 
            'paymentEndDate' => 'Payment_Window_EndDate__c', 
            'loanWindowEndDate' => 'Loan_Window_EndDate__c', 
            'LateFeeStartDateSlab1' => 'Start_Date__c', 
            'LateFeeEndDateSlab1' => 'End_Date__c',
            'LateFeeStartDateSlab2' => 'Start_Date__c', 
            'LateFeeEndDateSlab2' => 'End_Date__c',
            'videoVerificationLastDate' => 'Last_Date_For_Video_Verification__c'
            // 'LateFeeStartDateSlab3' => 'Start_Date__c', 
            // 'LateFeeEndDateSlab3' => 'End_Date__c'
        };
        try {
            List<Object> ListOFJson = (List<Object>) JSON.deserializeUntyped(jsonString);
            for (Object obj : ListOFJson) {
                Map<String, Object> mapOfObject = (Map<String, Object>) obj;
                String fieldName = (String) mapOfObject.get('name');
                if (mapOfFieldVsObject.containsKey(fieldName) ) {
                    String objectName = mapOfFieldVsObject.get(fieldName);
                    if(objectName == 'Calender') {
                        Calender__c objCalender = mapOfKeyCalender.containsKey((String) mapOfObject.get('CalenderId')) ? mapOfKeyCalender.get((String) mapOfObject.get('CalenderId')) : new Calender__c();
                        objCalender.Id = (String) mapOfObject.get('CalenderId');
                        if(mapOfFieldVsAPIName.containsKey(fieldName)) {
                            List<String> lstSplit = ((String) mapOfObject.get('newValue')).split('/');
                            Date newDate = date.newInstance(Integer.valueOf(lstSplit[2].trim()) , Integer.valueOf(lstSplit[1].trim()), Integer.valueOf(lstSplit[0].trim()));
                            objCalender.put(mapOfFieldVsAPIName.get(fieldName), newDate);
                            mapOfKeyCalender.put((String) mapOfObject.get('CalenderId'), objCalender);
                        }
                    } else if (objectName == 'payConfig') {
                        NM_Payment_Form_Configuration__c objPayConf = mapOfKeyPayConfig.containsKey((String) mapOfObject.get('paymentConfigId')) ? mapOfKeyPayConfig.get((String) mapOfObject.get('paymentConfigId')) : new NM_Payment_Form_Configuration__c();
                        objPayConf.Id = (String) mapOfObject.get('paymentConfigId');
                        if (mapOfFieldVsAPIName.containsKey(fieldName) && fieldName == 'videoVerificationLastDate') {
                            List<String> lstSplit = ((String) mapOfObject.get('newValue')).split('/');
                            Date newDate = date.newInstance(Integer.valueOf(lstSplit[2].trim()) , Integer.valueOf(lstSplit[1].trim()), Integer.valueOf(lstSplit[0].trim()));
                            objPayConf.put(mapOfFieldVsAPIName.get(fieldName), newDate);
                            mapOfKeyPayConfig.put((String) mapOfObject.get('paymentConfigId'), objPayConf);
                        }
                        else if(mapOfFieldVsAPIName.containsKey(fieldName)) {
                            objPayConf.put(mapOfFieldVsAPIName.get(fieldName), getDateTimeOfString((String) mapOfObject.get('newValue')));
                            mapOfKeyPayConfig.put((String) mapOfObject.get('paymentConfigId'), objPayConf);
                        }
                    } else if(objectName == 'lateFee') {
                        String newValue = (String) mapOfObject.get('newValue');
                        String lastValue = fieldName.right(1);
                        Late_Fee__c objLateFee = MapOfKeyVsLateFee.containsKey(lastValue) ? MapOfKeyVsLateFee.get(lastValue) : new Late_Fee__c();
                        String lateFeeId = 'LateFeeSlab' + lastValue + 'Id';
                        if (mapOfObject.containsKey(lateFeeId)) {
                            objLateFee.Id = (String) mapOfObject.get(lateFeeId);
                        } else {
                            objLateFee.Name = 'Late Fees for '+ (String) mapOfObject.get('admissionCategory') +' ' + (String) mapOfObject.get('session') + ' ' + (String) mapOfObject.get('year') + ' slab ' + lastValue;
                            objLateFee.Late_Fees__c = lastValue == '1' ? 500 : lastValue == '2' ? 1000 : lastValue == '3' ? 1500 : 0;
                            objLateFee.Session__c = (String) mapOfObject.get('session');
                            objLateFee.Year__c = (String) mapOfObject.get('year');
                            objLateFee.nm_Type__c = (String) mapOfObject.get('programType');
                            objLateFee.Program_Type__c = (String) mapOfObject.get('specialization');
                            objLateFee.Category__c = (String) mapOfObject.get('admissionCategory');
                        }
                        if(mapOfFieldVsAPIName.containsKey(fieldName)) {
                            List<String> lstSplit = ((String) mapOfObject.get('newValue')).split('/');
                            Date newDate = date.newInstance(Integer.valueOf(lstSplit[2].trim()) , Integer.valueOf(lstSplit[1].trim()), Integer.valueOf(lstSplit[0].trim()));
                            objLateFee.put(mapOfFieldVsAPIName.get(fieldName),  newDate);
                        }
                        MapOfKeyVsLateFee.put(lastValue, objLateFee);
                    }
                }
            }

            System.debug('mapOfKeyCalender --> ' + JSON.serialize(mapOfKeyCalender));
            System.debug('mapOfKeyPayConfig --> ' + JSON.serialize(mapOfKeyPayConfig));
            System.debug('MapOfKeyVsLateFee --> ' + JSON.serialize(MapOfKeyVsLateFee));

            if (!mapOfKeyCalender.isEmpty()) {
                update mapOfKeyCalender.values();
            }
            if (!mapOfKeyPayConfig.isEmpty()) {
                update mapOfKeyPayConfig.values(); 
            }
            if (!MapOfKeyVsLateFee.isEmpty()) {
                List<Late_Fee__c>  lstLateFee = MapOfKeyVsLateFee.values();
                upsert lstLateFee;  
                system.debug(lstLateFee);
            }
            return 'success';

        } catch (Exception e) {
            system.debug(e.getLineNumber() + ' --- '+e.getMessage());
            throw new AuraHandledException( e.getLineNumber() + ' --- '+e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static ProgramDates saveCancelationDateRecord(List<Map<String,Object>> lstOfCancelationDates, String paymentConfigId) {
        ProgramDates objProgramDates = new ProgramDates();
        objProgramDates.isSuccess = false;
        try {
            List<Cancelation_Date__c> lstRecordsToInsert = new List<Cancelation_Date__c>();
            for (Map<String,Object> mapItem : lstOfCancelationDates) {
                Cancelation_Date__c objCancelDate = new Cancelation_Date__c();
                // Map fields from the incoming data
                if (mapItem.containsKey('From_Date__c') && String.isNotBlank((String) mapItem.get('From_Date__c'))) {
                    String fromDateStr = (String)mapItem.get('From_Date__c');
                    fromDateStr = fromDateStr.trim(); // Remove any leading/trailing whitespace
                    Date fromDate = Date.valueOf(fromDateStr);
                    objCancelDate.From_Date__c = fromDate;
                }
                if (mapItem.containsKey('To_Date__c') && String.isNotBlank((String) mapItem.get('To_Date__c'))) {
                    String toDateStr = (String)mapItem.get('To_Date__c');
                    toDateStr = toDateStr.trim(); // Remove any leading/trailing whitespace
                    Date toDate = Date.valueOf(toDateStr);
                    objCancelDate.To_Date__c = toDate;
                }
                if (mapItem.containsKey('Amount__c') && String.isNotBlank((String) mapItem.get('Amount__c'))) {
                    objCancelDate.Amount__c = Decimal.valueOf(mapItem.get('Amount__c').toString());
                }
                if (mapItem.containsKey('Percentage__c') && String.isNotBlank((String) mapItem.get('Percentage__c'))) {
                    objCancelDate.Percentage__c = Decimal.valueOf(mapItem.get('Percentage__c').toString());
                    objCancelDate.Percentage_Note__c = '%';
                }
                if (String.isNotBlank(paymentConfigId)) {
                    objCancelDate.NM_Payment_Form_Configuration__c = paymentConfigId;
                }
                else {
                    continue;
                }
                if (mapItem.containsKey('Admission_Fee__c')) {
                    objCancelDate.Admission_Fee__c = (Boolean)mapItem.get('Admission_Fee__c');
                }
                
                // Add to the list
                lstRecordsToInsert.add(objCancelDate);
            }
            System.debug('lstRecordsToInsert--->' + lstRecordsToInsert.size());
            if (lstRecordsToInsert.size() > 0) {
                insert lstRecordsToInsert;
                objProgramDates.lstInsertedCancelRecord = lstRecordsToInsert;
                objProgramDates.msg = 'Successfully inserted records';
                objProgramDates.isSuccess = true;
            }
        } catch (Exception e) {
            System.debug('error-->' + e.getMessage());
            objProgramDates.msg = 'Something went wrong, kindly try again later';
            objProgramDates.isSuccess = false;
        }
        return objProgramDates;
    }

    @AuraEnabled
    public static Boolean deleteCancelationDateByRecordId(String recordId){
        try {
            if (String.isNotBlank(recordId)) {
                Cancelation_Date__c obj = new Cancelation_Date__c();
                obj.Id = recordId;
                delete obj;
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateCancelationDateChanges(String recordId,Map<String,Object> mapOfInputAndValues){
        try {
            if (String.isNotBlank(recordId) && mapOfInputAndValues != null) {
                Cancelation_Date__c objCan = new Cancelation_Date__c();
                objCan.Id = recordId;

                for (String key : mapOfInputAndValues.keySet()) {
                    Object value = mapOfInputAndValues.get(key);

                    // Handle specific field logic
                    if (key == 'From_Date__c' || key == 'To_Date__c') {
                        objCan.put(key, Date.valueOf(((String)value).trim()));
                    } else if (key == 'Percentage__c') {
                        objCan.Percentage__c = String.isNotBlank((String)value) ? Decimal.valueOf((String)mapOfInputAndValues.get(key)) : null;
                        objCan.Percentage_Note__c = String.isNotBlank((String)value) ? '%' : null; // Additional logic for this field
                    } else if (key == 'Amount__c') {
                        objCan.Amount__c = String.isNotBlank((String)value) ? Decimal.valueOf((String)mapOfInputAndValues.get(key)) : null;
                    } 
                    else if (key == 'Admission_Fee__c') {
                        objCan.Admission_Fee__c = (Boolean) value;
                    }
                }
                update objCan;
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DateTime getDateTimeOfString(String strDateTime) {
        String[] dateTimeParts = strDateTime.split(', ');

        // Extract date parts
        Integer day = Integer.valueOf(dateTimeParts[0].split('/')[0]);
        Integer month = Integer.valueOf(dateTimeParts[0].split('/')[1]);
        Integer year = Integer.valueOf(dateTimeParts[0].split('/')[2]);

        // Extract time parts
        String[] timeParts = dateTimeParts[1].split(' ');
        Integer hours = Integer.valueOf(timeParts[0].split(':')[0]);
        Integer minutes = Integer.valueOf(timeParts[0].split(':')[1]);
        String amPm = timeParts[1];

        if (amPm == 'pm' && hours < 12) {
            hours += 12;
        } else if (amPm == 'am' && hours == 12) {
            hours = 0;
        }

        // Create DateTime instance
        DateTime dt = DateTime.newInstance(year, month, day, hours, minutes, 0);
        return dt;
    }



    public class ProgramDates {
        @auraEnabled public String programType {get;set;}
        @auraEnabled public String admissionCategory {get;set;}
        @auraEnabled public String semester {get;set;}
        @auraEnabled public String session {get;set;}
        @auraEnabled public String year {get;set;}
        @auraEnabled public String specialization {get;set;}
        @auraEnabled public Datetime paymentStartDate {get;set;}
        @auraEnabled public Datetime paymentEndDate {get;set;}
        @auraEnabled public Datetime loanWindowEndDate {get;set;}
        @auraEnabled public Date ApplicationStartDate {get;set;}
        @auraEnabled public Date ApplicationEndDate {get;set;}
        @auraEnabled public Date LateFeeStartDateSlab1 {get;set;}
        @auraEnabled public Date LateFeeStartDateSlab2 {get;set;}
        //@auraEnabled public Date LateFeeStartDateSlab3 {get;set;}
        @auraEnabled public Date LateFeeEndDateSlab1 {get;set;}
        @auraEnabled public Date LateFeeEndDateSlab2 {get;set;}
        //@auraEnabled public Date LateFeeEndDateSlab3 {get;set;}
        @auraEnabled public Date InterviewORTestStartDate {get;set;}
        @auraEnabled public Date InterviewORTestEndDate {get;set;}
        @auraEnabled public Date InterviewORTestResultStartDate {get;set;}
        @auraEnabled public Date InterviewORTestResultEndDate {get;set;}
        @auraEnabled public Date DocumentSubmissionStartDate {get;set;}
        @auraEnabled public Date DocumentSubmissionEndDate {get;set;}
        @auraEnabled public string paymentConfigId {get;set;}
        @auraEnabled public string CalenderId {get;set;}
        @auraEnabled public string LateFeeSlab1Id {get;set;}
        @auraEnabled public string LateFeeSlab2Id {get;set;}
        @auraEnabled public string LateFeeSlab3Id {get;set;}
        @auraEnabled public Date videoVerificationLastDate {get;set;}
        @auraEnabled public List<Cancelation_Date__c> lstInsertedCancelRecord {get;set;}
        @auraEnabled public String msg {get;set;}
        @auraEnabled public Boolean isSuccess {get;set;}
        // @auraEnabled public Date cancelToDate {get;set;}
        // @auraEnabled public Date cancelFromDate {get;set;}
        // @auraEnabled public Boolean admissionFee {get;set;}
        // @auraEnabled public Integer amount {get;set;}
        // @auraEnabled public Integer percentage {get;set;}
        // @auraEnabled public String cancelDateId {get;set;}
        //@auraEnabled public List<Cancelation_Date__c> lstCancelDate {get;set;}
    }


    public with sharing class PriceBookAndProduct {
        @auraEnabled public PriceBookEntry Pricebook {get;set;}
        @auraEnabled public Product2 Product {get;set;}
    }

}