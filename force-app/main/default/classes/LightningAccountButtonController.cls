/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 20--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   25--06--2025   @Ravi   Initial Version
**/
public without sharing class LightningAccountButtonController {

    /**
    * @description Retrieves payment-related data for a given Account during Admission Cancellation refund process.
    *                Specifically checks if the student has opted for Career Services by verifying related payments.
    * @author @Ravi | 26--06--2025 
    * @param String accountId 
    * @param String refundType- "Admission Cancellation"
    * @return AccountWrapper 
    **/
    @AuraEnabled
    public static AccountWrapper refundData(String accountId, String refundType){
        AccountWrapper wrap = new AccountWrapper();
        List<String> lstCsIds = new List<String>();
        List<nm_Payment__c> paymentList = new List<nm_Payment__c>();
        List<Career_Service_Program__c> cp = new List<Career_Service_Program__c>();
        wrap.paymentRecords = false;
        
        if(refundType == 'Admission Cancellation' && String.isNotBlank(accountId)) {
            cp = [SELECT Id FROM Career_Service_Program__c WHERE Account__c =:accountId];
            if (cp.size() > 0) {
                for (Career_Service_Program__c csRecord : cp) {
                    lstCsIds.add(csRecord.Id);
                }
                paymentList = [SELECT Id FROM nm_Payment__c WHERE CareerServiceProgram__c IN :lstCsIds];
                
                //This student has opt for career service if paymentList.size() > 0
                wrap.paymentRecords = paymentList.size() > 0 ? true : false;
                system.debug('work');
                system.debug(wrap.paymentRecords);
            }
        }
        return wrap;
    }

    /**
    * @description 
    * @author @Ravi | 04--07--2025 
    * @param String recordId 
    * @param String refundType 
    * @return AccountWrapper 
    **/
        @AuraEnabled(cacheable=true)
    public static AccountWrapper refundRequest(String recordId, String refundType){
        AccountWrapper wrap = new AccountWrapper();
        List<Opportunity> opp = new List<Opportunity>();
        try {
            if(String.isNotBlank(recordId)) {
                Account acc = [SELECT Id, nm_StudentStatus__c, PersonEmail, Interview_Slot__c FROM Account WHERE Id =:recordId LIMIT 1];
                opp = [SELECT Id, AccountId, Total_Amount_Received__c, Final_Status_Of_Dispatch__c, Specialisation__c, StageName, nm_TotalApprovedPayment__c, Dispatch_Order_For_Student__c, Actual_Amount__c, ID_opportunity__c, nm_Semester__c FROM Opportunity WHERE AccountId =:recordId order by nm_Semester__c asc LIMIT 1];
                wrap.account = acc;
                wrap.opportunity = opp; 
                return wrap;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    *  @description Retrieves refund eligibility and amount details for a given Opportunity in case of 'Registration Cancellation'.
    *            Also checks if any NEFT payments or installment payments were made.
    * @author @Ravi | 26--06--2025 
    * @param String oppId 
    * @return AccountWrapper 
    **/
    @AuraEnabled
    public static AccountWrapper refundAmountData(String oppId){
        AccountWrapper wrap = new AccountWrapper();
        Map<String,List<nm_Payment__c>> mapOfPayment = new Map<String,List<nm_Payment__c>>();
        List<nm_Payment__c> paymentType = new List<nm_Payment__c>();
        List<nm_Payment__c> paymentMode = new List<nm_Payment__c>();
        List<nmRefund_Payment__c> refundquery = new List<nmRefund_Payment__c>();
        List<OpportunityLineItem> lineitemquery = new List<OpportunityLineItem>() ;
        //boolean nmRefund = false;
        wrap.amount = 0;
        wrap.neft = 0;
        Decimal amount = 0;
        wrap.lineItem = 0;
            if(String.isNotBlank(oppId)) {
                refundquery = [SELECT Id, Type_of_Refund__c FROM nmRefund_Payment__c WHERE ( Type_of_Refund__c = 'Admission Cancellation' OR Type_of_Refund__c = 'Registration Cancellation' ) AND Opportunity__c =:oppId LIMIT 1];
                wrap.refund = refundquery.size() > 0 ? true : false;

                if(!wrap.refund) {
                    lineitemquery = [SELECT Id, OpportunityId , Product_Name__c, PriceBookEntryId, UnitPrice FROM OpportunityLineItem WHERE OpportunityId =:oppId AND Product_Name__c = 'Registration Fee' LIMIT 1];
                    if (lineitemquery.size() > 0) {
                        wrap.lineItem = lineitemquery[0].UnitPrice;
                    }
                    for(nm_Payment__c pay : [SELECT Id, nm_Amount__c, nm_PaymentType__c, nm_ModeOfPayment__c FROM nm_Payment__c WHERE nm_OpportunityNew__c =:oppId AND (nm_PaymentStatus__c = 'Payment Approved' OR nm_PaymentStatus__c	= 'Payment Made')]) {
                        System.debug('pay mode' + pay);
                        if(pay.nm_PaymentType__c.startsWithIgnoreCase('Installment')) {
                            paymentType.add(pay); 
                        }
                        if(pay.nm_ModeOfPayment__c.startsWithIgnoreCase('NEFT -')) {
                            paymentMode.add(pay);
                            amount = amount + pay.nm_Amount__c;
                        }
                    }
                    System.debug('install payment type' + JSON.serialize(paymentType));
                    System.debug('neft payment mode' + JSON.serialize(paymentMode));
                    wrap.neft = amount;
                    wrap.amount = amount + wrap.lineItem;
                    wrap.installment = paymentType.size() > 0 ? true : false;
                }
            }  
            return wrap;
        }

    /**
    * @description 
    * @author @Ravi | 26--06--2025 
    * @param nmRefund_Payment__c refundPayment 
    **/
    @AuraEnabled
    public static void insertRefundPayment(nmRefund_Payment__c refundPayment) {
        try{
            if(refundPayment != null) {
                insert refundPayment;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description  to get Account record details 
    * @author @Ravi | 23--07--2025 
    * @param String recordId 
    * @return AccountWrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static AccountWrapper getAccountById(String recordId){
        AccountWrapper wrapper = new AccountWrapper();   
        try {
            if(String.isNotBlank(recordId)) {
                Account acc = [SELECT Id, FirstName, Salutation, LastName, IC_Name_1__c, nm_Centers__c, nm_RegistrationNumber__c, nm_DateOfBirth__c, nm_StudentNo__c, nm_StudentStatus__c FROM Account WHERE Id =:recordId LIMIT 1];
                String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
                //nm_StudentProgram__c program = [SELECT Id, nm_FeesPaidofSemester__c, nm_Program__r.Name from nm_StudentProgram__c where nm_Student__c =:recordId limit 1];
                wrapper.account = acc;
                wrapper.profileName = profileName;
                //wrapper.studentProgram = program;
                return wrapper;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

//     @AuraEnabled(cacheable=true)
//     public static AccountWrapper studentProgramChange(String recordId){
//         Map<String,Opportunity> mapOfStage = new Map<String,Opportunity>();
//         AccountWrapper wrapper = new AccountWrapper();
//         try {
//             if(String.isNotBlank(recordId)) {
//                 String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
//                 for(Opportunity obj: [SELECT Id, Name, Account.FirstName, Account.LastName, Account.Salutation, AccountId, Account.nm_RegistrationNumber__c, StageName, Sem__c  FROM Opportunity WHERE AccountId = :recordId]) {
//                     if(obj.StageName == 'Re-Registration Pending') {
//                         Opportunity opp = mapOfStage.containsKey(obj.StageName) && mapOfStage.get(obj.StageName).Sem__c > obj.Sem__c ? mapOfStage.get(obj.StageName) : obj;
//                         mapOfStage.put(obj.StageName,opp);
//                     }
//                     else if(obj.StageName == 'Closed Won - Re-registration Pending') {
//                         Opportunity opp = mapOfStage.containsKey(obj.StageName) && mapOfStage.get(obj.StageName).Sem__c < obj.Sem__c ? mapOfStage.get(obj.StageName) : obj;
//                         mapOfStage.put(obj.StageName,opp);
//                     }
//                     else {
//                         Opportunity opp = mapOfStage.containsKey('other') && mapOfStage.get('other').Sem__c > obj.Sem__c ? mapOfStage.get('other') : obj;
//                         mapOfStage.put('other',opp);
//                     }
//                 }
//                 wrapper.checkOpp = mapOfStage;
//                 wrapper.profileName = profileName;
//                 return wrapper;
//             }
            
//         } catch (Exception e) {
//             throw new AuraHandledException(e.getMessage());
//         }
//         return null;
//     }
// //check
//     @AuraEnabled(cacheable=true)
//     public static AccountWrapper verifyEmailSms(String recordId){
//         AccountWrapper wrapper = new AccountWrapper();
//         List<nm_StudentProgram__c> programList = new List<nm_StudentProgram__c>();
//         Account acc = new Account();
//         try {
//             if(String.isNotBlank(recordId)) {
//                 acc = [SELECT Id, nm_RegistrationNumber__c, nm_IsEmailVerified__c, Is_Mobile_Verified__c, nm_AccountEmail__c, LC_Email__c, Name, PersonMobilePhone FROM Account WHERE Id =:recordId LIMIT 1];
//                 programList = [SELECT Id, nm_FeesPaidofSemester__c, nm_Program__r.Name from nm_StudentProgram__c where nm_Student__c =:recordId limit 1];
//                 wrapper.studentProgram = programList;
//                 wrapper.account = acc;
//                 return wrapper;
//             }
            
//         } catch (Exception e) {
//             throw new AuraHandledException(e.getMessage());
//         }
//         return null;
//     }

    
    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param String recordId 
    * @return AccountWrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static AccountWrapper getAccount(String recordId){
        AccountWrapper wrap = new AccountWrapper();
        List<nm_Program__c> programList = new List<nm_Program__c>();
        try {
            if(String.isNotBlank(recordId)) {
                Account acc = [SELECT Id, PersonLeadSource, LC_Name__c, IC_company__c,Lead_created_date__c,GroupName__c, Interview_Slot__c, Time_Range__c, Interview_Date__c, InterviewDateTime__c, Zoom_Url__c, HostZoomURL__c, Interview_Meeting_Id__c, Interview_Zoom_Meeting_Id__c, Interview_Score__c, nm_StudentStatus__c, nmCaptureOpportuntiyStage__c, Is_Late_fees_pending__c, Is_Late_fees_paid__c, PersonEmail, PersonMobilePhone, nm_RegistrationNumber__c, nm_StudentNo__c FROM Account WHERE Id =:recordId LIMIT 1];
                programList = [SELECT Id, nm_ProgramName__c from nm_Program__c where Name IN ('CBM','DBM' ,'DGM','C-SEM','C-SMM','C-DMA','C-SEM & SMM','C-SEM & DMA','C-SMM & DMA','PC-DM', 'PC-DS', 'PD-DS')];
                wrap.accountData = acc;
                wrap.listProgram = programList;
                return wrap;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }


    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param String email 
    * @return AccountWrapper 
    **/
    @AuraEnabled
    public static AccountWrapper getRecordForNewEmail(String email){
        AccountWrapper leadacc = new AccountWrapper();
        List<Account> accountList = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        try {
            if(String.isNotBlank(email)) {
                leadList = [SELECT id, Email, Lead_created_date__c, LeadSource, GroupName__c, LC_name__c, IC_company__c, nm_LeadId__c, MobilePhone, nm_RegistrationNo__c, IC_Name__c, Status FROM Lead WHERE IsConverted = false AND IsDeleted = false AND Email =:email LIMIT 1];
                accountList = [SELECT id, Lead_created_date__c, LC_Name__c, PersonEmail, GroupName__c, IC_company__c, PersonLeadSource, PersonMobilePhone, nm_StudentNo__c, Total_amount_received__c, nm_StudentStatus__c, IC_Name_1__c, nmCaptureOpportuntiyStage__c, nm_RegistrationNumber__c FROM Account WHERE PersonEmail =:email LIMIT 1];
                leadacc.accountRecordEmail = accountList;
                leadacc.leadRecordEmail = leadList;
                return leadacc;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param String mobile 
    * @return AccountWrapper 
    **/
    @AuraEnabled
    public static AccountWrapper getRecordForNewMobile(String mobile){
        AccountWrapper leadacc = new AccountWrapper();
        List<Account> accountList = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        try {
            if(String.isNotBlank(mobile)) {
                leadList = [SELECT id, Email, LC_name__c, Lead_created_date__c, IC_company__c, GroupName__c, nm_LeadId__c, LeadSource, MobilePhone, nm_RegistrationNo__c, IC_Name__c, Status FROM Lead WHERE IsConverted = false and IsDeleted = false AND MobilePhone =:mobile LIMIT 1];
                accountList = [SELECT id, Lead_created_date__c, LC_Name__c, PersonLeadSource, GroupName__c, IC_company__c, PersonEmail, PersonMobilePhone, nm_StudentNo__c, Total_amount_received__c, nm_StudentStatus__c, IC_Name_1__c, nmCaptureOpportuntiyStage__c, nm_RegistrationNumber__c FROM Account WHERE PersonMobilePhone =:mobile LIMIT 1];
                leadacc.accountRecordMobile = accountList;
                leadacc.leadRecordMobile = leadList;
                return leadacc;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param String mobile 
    **/
    @AuraEnabled
    public static void findDuplicateLead(String mobile){
        List<Lead> leadList = new List<Lead>();
        
        try {
            if(String.isNotBlank(mobile)) {
                leadList = [SELECT id, Email, LC_name__c, Lead_created_date__c, IC_company__c, GroupName__c, nm_LeadId__c, LeadSource, MobilePhone, nm_RegistrationNo__c, IC_Name__c, Status FROM Lead WHERE IsConverted = false AND IsDeleted = false AND (Not Status Like '%Fee Paid%') and MobilePhone =:mobile LIMIT 1];
                System.debug(leadList);
                if(leadList.size() > 0) {
                    Lead led=new Lead();
                    led= leadList[0];
                    delete led;
                } 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param Lead updateLead 
    **/
    @AuraEnabled
    public static void updateLeadRecord(Lead updateLead){
        try {
            if(updateLead != null) {
                update updateLead;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @Ravi | 11--07--2025 
    * @param Account acc 
    **/
    @AuraEnabled
    public static void updateAccountRecord(Account acc){
        try {
            if(acc != null) {
                System.debug('acc==>'+acc.PersonMobilePhone);
                System.debug('acc==>'+acc.PersonEmail);
                update acc;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string URLMatch(String AccountId ,String DocName){
        try {
            System.debug('trsdt' + AccountId + '=' + DocName);
            return FindabilityWebService.URLMatchvs2(AccountId, DocName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @Ravi | 18--08--2025 
    * @param Id accountId 
    * @param String docName 
    * @return String 
    **/
    @AuraEnabled
    public static String processDigiLockerDoc(Id accountId, String docName) {
        List<nm_LinksForDocuments__c> docList = [SELECT Id, Name, nm_URLforDocuments__c, Document_Upload_Mode__c, Updated_document_link__c FROM nm_LinksForDocuments__c WHERE nm_Account__c = :accountId AND Name = :docName LIMIT 1];
        
        if (!docList.isEmpty()) {
            nm_LinksForDocuments__c docRec = docList[0];
            if (docRec.Document_Upload_Mode__c == 'Upload via DigiLocker' && docRec.Updated_document_link__c == null) {
                // Call existing logic to fetch Aadhaar image
                String data = AadhaarXmlParser.fetchImageXml(docRec.nm_URLforDocuments__c);
                String imageUrl = UploadStudentProfileDocument.uploadFile(data, 'image.jpeg');
                
                docRec.Updated_document_link__c = imageUrl;
                update docRec;
                return imageUrl;
            }
        }
        return null;
    }

    // @AuraEnabled
    // public static void updateAccountInterviewSloat(Account acc, String slotId){
    //     List<Interview_Slot__c> listSloat = new List<Interview_Slot__c>();
    //     Interview_Slot__c clonedInterviewSloat = new Interview_Slot__c();
    //     try {
    //         if(acc != null) {
    //             update acc;
    //             if(String.isNotBlank(slotId)) {
    //                 listSloat = [SELECT Id, Account_Assigned__c FROM Interview_Slot__c WHERE Id =:slotId LIMIT 1];
    //                 if(listSloat.size() > 0) {
    //                     clonedInterviewSloat = listSloat[0].clone(true, true);
    //                     if(clonedInterviewSloat.Account_Assigned__c > 0) {
    //                         clonedInterviewSloat.Account_Assigned__c = clonedInterviewSloat.Account_Assigned__c -1;
    //                         system.debug(clonedInterviewSloat.Account_Assigned__c -1);
    //                         update clonedInterviewSloat;
    //                     }
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static AccountWrapper getAccountByRegno(String regno){
    //     AccountWrapper wrap = new AccountWrapper();
    //     List<Account> listAccount = new List<Account>();
    //     try {
    //         if(String.isNotBlank(regno)) {
    //             listAccount = [SELECT Id , Interview_Slot__c FROM Account WHERE nm_RegistrationNumber__c =:regno];
    //             wrap.listOfAccount = listAccount;
    //             return wrap;
    //         }
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return null;
    // }

    // // @AuraEnabled
    // // public static AccountWrapper getStudentRating(String Id){
    // //     AccountWrapper wrap = new AccountWrapper();
    // //     List<Student_Rating__c> listRating = new List<Student_Rating__c>();
    // //     if(String.isNotBlank(Id)) {
    // //         listRating = [SELECT Id, Student__c, Interview_Date__c, Q5_text__c, Question_1_Student_Rating__c, Question_2_Student_Rating__c, Question_3_Student_Rating__c, Question_4_Student_Rating__c, Question_5_Student_Rating__c FROM Student_Rating__c WHERE Student__c =:Id LIMIT 1];
    // //         wrap.listStudent = listRating;
    // //     }
    // //     return wrap;
    // // }

   

    // @AuraEnabled
    // public static Boolean createStudentRating(String oldId, String newId){
    //     List<Student_Rating__c> listRating = new List<Student_Rating__c>();
    //     Student_Rating__c clonedStudentRating = new Student_Rating__c();
    //     try {
    //         if(String.isNotBlank(oldId) && String.isNotBlank(newId)) {
    //             listRating = [SELECT Id, Student__c, Interview_Date__c, Q5_text__c, Question_1_Student_Rating__c, Question_2_Student_Rating__c, Question_3_Student_Rating__c, Question_4_Student_Rating__c, Question_5_Student_Rating__c FROM Student_Rating__c WHERE Student__c =:oldId LIMIT 1];
    //             if(listRating.size() > 0) {
    //                 clonedStudentRating = listRating[0].clone(false, true);
    //                 clonedStudentRating.Student__c = newId;
    //                 insert clonedStudentRating;
    //             }
    //         }
    //         return listRating.size() > 0 ? true : false;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     } 
    // }

    @AuraEnabled
    public static Accountwrapper deletePaymentUsingRegno(String accId, String regno){
        AccountWrapper wrap = new AccountWrapper();
        List<nmRefund_Payment__c> listPayment = new List<nmRefund_Payment__c>();
        wrap.paymentStatus = '';
        try {
            if(String.isNotBlank(accId) && String.isNotBlank(regno)) {
                listPayment = [SELECT Id, nm_Payment_Status__c, Type_of_Refund__c, Status__c FROM nmRefund_Payment__c WHERE Account__c =:accId AND Registration_Number__c =:regno LIMIT 1];
               if(listPayment.size() > 0 && listPayment[0].nm_Payment_Status__c != 'Payment Made' && listPayment[0].Status__c != 'Refund Submitted to Finance' && listPayment[0].Status__c != 'Payment Refunded' ) {
                delete listPayment[0];
                wrap.paymentStatus = 'success';
               }
               else {
                if(listPayment.size() == 0) {
                    System.debug('No Refund found to delete continuing the process.');
                    wrap.paymentStatus = 'success';
                }
                else {
                    wrap.paymentStatus = 'error';
                }
               }
            }
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Accountwrapper deleteLeadForUndo(String email, String mobile){
        AccountWrapper wrap = new AccountWrapper();
        List<Lead> listLead = new List<Lead>();
        wrap.leadStatus = '';
        try {
            if(String.isNotBlank(email) && String.isNotBlank(mobile)) {
                listLead = [SELECT Id, Status FROM Lead WHERE Email =:email AND MobilePhone =:mobile AND IsConverted=false LIMIT 1];
               if(listLead.size() > 0 && listLead[0].Status != 'Registration Fee Paid' && listLead[0].Status != 'Admission Fee Paid') {
                delete listLead[0];
                wrap.leadStatus = 'success';
               }
               else {
                if(listLead.size() == 0) {
                    wrap.leadStatus = 'success';
                    System.debug('No Lead record found to delete continuing the process.');
                }
                else {
                    wrap.leadStatus = 'error';
                }
               }
            }
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AccountWrapper getOpportunityClosed(String accId){
        AccountWrapper wrap = new AccountWrapper();
        List<Opportunity> oppList = new List<Opportunity>();
        Integer termOpp = 0;
        Integer nonTermOpp = 0;
        boolean noOpportunity = false;
        try {
            if(String.isNotBlank(accId)) {
                oppList = [SELECT Id, AccountId, StageName, Is_Re_Registration_Payment__c, nm_Program__r.IsTerm__c FROM Opportunity WHERE  AccountId =:accId AND StageName = 'Closed Won'];
                if(oppList.size() > 0) {
                    for(Opportunity opp : oppList) {
                        if(opp.nm_Program__r.IsTerm__c) {
                            termOpp++;
                        }
                        else {
                            nonTermOpp ++;
                        }
                    }
                }
                else {
                    noOpportunity = true;
                }
                wrap.termOpp = termOpp;
                wrap.nonTermOpp = nonTermOpp;
                wrap.noOpportunity = noOpportunity;
                return wrap;      
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static void updateDocumentForUndo(String accId){
        List<nm_LinksForDocuments__c> docList = new List<nm_LinksForDocuments__c>();
        nm_LinksForDocuments__c doc = new nm_LinksForDocuments__c();
        try {
            if(String.isNotBlank(accId)) {
                docList = [SELECT Id, nm_Status__c FROM nm_LinksForDocuments__c WHERE nm_Account__c =:accId AND nm_URLforDocuments__c != null LIMIT 1];
                if(docList.size() > 0) {
                    //doc.Id = docList[0].Id;
                    doc = docList[0].clone(true, true);
                    doc.nm_Status__c = docList[0].nm_Status__c;
                    update doc;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AccountWrapper updateOpportunityForUndo(String accId){
        List<Opportunity> oppList = new List<Opportunity>();
        AccountWrapper wrap = new AccountWrapper();
       // List<Account> accList = new List<Account>();
        String oppId = '';
        String stage = 'Pending Payment';
        try {
            if(String.isNotBlank(accId)) {
                oppList = [SELECT Id, StageName, Sem__c , nm_StudentProgram__r.nm_FeesPaidofSemester__c, ActualPendingAmount__c, nm_Fee_Type__c FROM Opportunity WHERE AccountId =:accId];
               //accList = [SELECT Id, nm_StudentStatus__c FROM Account WHERE Id =:accId LIMIT 1];
               // endsWithIgnoreCase
               System.debug(oppList);
                if(oppList.size() > 0 ) {
                    for(Opportunity opp : oppList) {
                        if (opp.Sem__c <= opp.nm_StudentProgram__r.nm_FeesPaidofSemester__c) {
                            if (opp.ActualPendingAmount__c == 0) {
                                if (opp.nm_Fee_Type__c.endsWithIgnoreCase('Considered')) {
                                    stage = 'Closed Won - Re-registration Pending';
                                }
                                else {
                                    stage = 'Closed Won';
                                }
                            }
                            else {
                                stage = 'Pending Payment';
                            }
                        }
                        else {
                            stage = 'Pending Payment';
                        }
                        // Opportunity objOpp = new Opportunity();
                        // objOpp.Id = opp.Id;
                        // objOpp.StageName = opp.StageName;
                        oppId = opp.Id;
                        opp.StageName = stage;
                    }
                    update oppList;
                }
                wrap.oppSize = oppList.size() > 0 ? true : false;
                wrap.opportunityId = oppId;
                return wrap;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null; 
    }

    @AuraEnabled
    public static void updatePaymentRecord(String opportunityId){
        List<nm_Payment__c> listPayment = new List<nm_Payment__c>();
        nm_Payment__c payment = new nm_Payment__c();
        try {
            if(String.isNotBlank(opportunityId)) {
                listPayment = [SELECT Id, nm_PaymentStatus__c FROM nm_Payment__c WHERE nm_OpportunityNew__c =:opportunityId AND nm_PaymentStatus__c = 'Payment Approved' AND nm_PaymentType__c != 'Registration' LIMIT 1];
                if(listPayment.size() > 0) {
                    payment = listPayment[0].clone(true, true);
                    payment.nm_PaymentStatus__c = listPayment[0].nm_PaymentStatus__c;
                    update payment;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateStudentProgram(String accId, String program){
        List<nm_StudentProgram__c> listStudentPrg = new List<nm_StudentProgram__c>();
        nm_StudentProgram__c studentProgram = new nm_StudentProgram__c();
        try {
            if(String.isNotBlank(accId) && String.isNotBlank(program)) {
                listStudentPrg = [SELECT Id, nm_Student__c, Certificate_Issue__c, StudentProgramId__c FROM nm_StudentProgram__c WHERE  nm_Student__c =:accId LIMIT 1];
                if(listStudentPrg.size() > 0) {
                    //studentProgram.Id = listStudentPrg[0].StudentProgramId__c;
                    studentProgram = listStudentPrg[0].clone(true, true);
                    studentProgram.Certificate_Issue__c = program;
                    update studentProgram;
                } 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<nm_Program__c> getProgramList(String program){
        List<nm_Program__c> listProgram = new List<nm_Program__c>();
            if(String.isNotBlank(program)) {
                listProgram = [SELECT Id, nm_ProgramName__c FROM nm_Program__c WHERE Id =:program LIMIT 1];
            }
        return listProgram;
    }

    @AuraEnabled
    public static void updateOpportunityList(String accId){
        List<Opportunity> listOpp = new List<Opportunity>();
        if(String.isNotBlank(accId)) {
            listOpp = [SELECT Id, AdditionalAmountRecieved__c, AccountId, Program_Structure__c, nm_StudentEmail__c, StageName, RefundInitiatedAmount__c FROM Opportunity WHERE  AccountId =:accId];
        }

        try {
            if(listOpp.size() > 0) {
                for (Opportunity opp : listOpp) {
                    opp.StageName = 'De-Registered';
                }
                update listOpp;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static AccountWrapper getAccountAndDoc(String recordId){
        AccountWrapper wrap = new AccountWrapper();
        Account acc = new Account();
        List<nm_LinksForDocuments__c> listDocument = new List<nm_LinksForDocuments__c>();
        try {
            if(String.isNotBlank(recordId)) {
                acc = [SELECT Id, Student_Image_Url2__c, nm_StudentImageUrl__c, Findability_Counter__c FROM Account WHERE Id =:recordId LIMIT 1];
                listDocument = [SELECT Id, Name, nm_Account__r.Student_Image_Url2__c, nm_URLforDocuments__c FROM nm_LinksForDocuments__c  WHERE(( Name = 'Photo ID proof' AND nm_URLforDocuments__c != null) OR (Name = 'Aadhaar Card' AND nm_URLforDocuments__c != null))  AND nm_Account__c =:recordId];
                wrap.docList = listDocument;
                wrap.account = acc;
                return wrap;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }


    public class AccountWrapper {
        @AuraEnabled
        public String paymentStatus { get; set; }

        @AuraEnabled
        public String leadStatus { get; set; }

        @AuraEnabled
        public Boolean oppSize { get; set; }

        @AuraEnabled
        public String opportunityId { get; set; }

        @AuraEnabled
        public Integer termOpp { get; set; }

        @AuraEnabled
        public Integer nonTermOpp { get; set; }

        @AuraEnabled
        public boolean noOpportunity { get; set; }

        @AuraEnabled
        public Account account { get; set; }

        @AuraEnabled
        public List<Opportunity> opportunity { get; set; }

        @AuraEnabled
        public boolean paymentRecords { get; set; }

        @AuraEnabled
        public String profileName { get; set; }
        
        @AuraEnabled
        public Map<String,Opportunity> checkOpp{ get; set; }

        @AuraEnabled
        public List<nm_StudentProgram__c> studentProgram { get; set; }

        @AuraEnabled
        public boolean refund { get; set; }

        @AuraEnabled
        public Decimal lineItem { get; set; }

        @AuraEnabled
        public List<Account> accountRecordEmail { get; set; }

        @AuraEnabled
        public List<Lead> leadRecordEmail { get; set; }

        @AuraEnabled
        public List<Account> accountRecordMobile { get; set; }

        @AuraEnabled
        public List<Lead> leadRecordMobile { get; set; }

        @AuraEnabled
        public Decimal amount { get; set; }

        @AuraEnabled
        public boolean installment { get; set; }

        @AuraEnabled
        public Decimal neft { get; set; }

        @AuraEnabled
        public Account accountData { get; set; }
   
        @AuraEnabled
        public List<Account> listOfAccount { get; set; }

        @AuraEnabled
        public List<nm_Program__c> listProgram { get; set; }

        @AuraEnabled
        public List<nm_LinksForDocuments__c> docList { get; set; }

    }
}