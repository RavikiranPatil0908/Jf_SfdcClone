/**
 * @File Name          : nmICChangeRequestTriggerHandler.cls
 * @Description        : 
 * @Author             : phalguni
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 17/4/2020, 1:15:38 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    29/2/2020   phalguni     Initial Version
**/
public class nmICChangeRequestTriggerHandler {

    public void AfterUpdate(list < IC_Change_Request__c > triggerNew, map < id, IC_Change_Request__c > triggerOldMap) {
        // UpdateAccountInformationCenterAndDebitCreationOnApproval(triggerNew, triggerOldMap);
        DisapprovedServiceRequest(triggerNew, triggerOldMap);
        // method to update Sync with StudentZone check box on Opportunity to false as IC Change 
        SyncedWithStudentZone(triggerNew, triggerOldMap);
        //method to do activity once status is approved
    }
    
    public void AfterInsert(list < IC_Change_Request__c > triggerNew) {
        CreateServiceChangeRequestLineItemonInsertServiceChange(triggerNew);
        changeIcChangeRequestOnApproved(triggerNew);
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
    
    public void changeIcChangeRequestOnApproved(list <IC_Change_Request__c> lstIcChange) {
        List<Account> lstAccountToUpdateForRegister = new LisT<Account>();
        if(lstIcChange.size() > 0) {
            for(IC_Change_Request__c objICchange:lstIcChange ) {
                if( objICchange.Eligibility_Criteria__c!=null && objICchange.Student__c != null && objICchange.Eligibility_Criteria__c != objICchange.Old_Eligibility_Criteria__c) {
                    Account objAccount = new Account(id=objICchange.Student__c);
                    objAccount.nm_StudentStatus__c = 'Registered';
                    lstAccountToUpdateForRegister.add(objAccount);
                }
            }
        }
        if(lstAccountToUpdateForRegister.size() > 0) {
            update lstAccountToUpdateForRegister;
        }
    }
    
    /**
    * @description 
    * @author @BK | 16/3/2020 
    * @param lstIcChange 
    * @param triggerOldMap 
    * @return void 
    **/
    public void DisapprovedServiceRequest(list <IC_Change_Request__c> lstIcChange,map<id, IC_Change_Request__c> triggerOldMap) {
        Set<id> oppid = new Set<id> ();
        List<nm_StudentProgram__c> lstOfStudentProgramToUpdate = new List<nm_StudentProgram__c>();
        List<Account> lstOfAccountToUpdate = new List<Account>();
        Map<Id,OpportunityLineItem> mapOfOpportunityLineItemId = new  Map<Id,OpportunityLineItem>();
        Map<Id,IC_Change_Request__c> mapOfDissaprovedRequest = new Map<Id,IC_Change_Request__c>();
        ProductHelper productHelper = new ProductHelper();
        if(triggerOldMap!=null && lstIcChange.size() > 0) {
            for(IC_Change_Request__c objICchange:lstIcChange ) {
                if(objICchange.Status__c != triggerOldMap.get(objICchange.id).Status__c 
                    && objICchange.Status__c=='Disapproved' && objICchange.nm_TypeofRequest__c=='Program Change') {
    
                        if(objICchange.Opportunity__c!=null) {
                            oppid.add(objICchange.Opportunity__c);
                        } 
                        if(objICchange.Eligibility_Criteria__c!=null) {
                            mapOfDissaprovedRequest.put(objICchange.Student__c, objICchange);
                        }
                }
            }
    
            if(!mapOfDissaprovedRequest.isEmpty()) {
                List<nm_StudentProgram__c> lstStudentProgram = [SELECT Id,nm_Student__c,nm_EligiblityCriteria__c,nm_Student__r.nm_StudentStatus__c,nm_FeesPaidofSemester__c FROM nm_StudentProgram__c WHERE nm_Student__c IN : mapOfDissaprovedRequest.keySet()];
                if(lstStudentProgram.size() > 0) {
                    for(nm_StudentProgram__c objSP : lstStudentProgram) {
                        IC_Change_Request__c objIC = mapOfDissaprovedRequest.containsKey(objSP.nm_Student__c) ? mapOfDissaprovedRequest.get(objSP.nm_Student__c) : null;
                        if(objIC!=null && objSP.nm_EligiblityCriteria__c==objIC.Eligibility_Criteria__c) {
                            // to update student eligiblity back to old value if IC change request is Disapproved.
                            nm_StudentProgram__c newObjSP = new nm_StudentProgram__c(Id=objSP.Id);
                            newObjSP.nm_EligiblityCriteria__c = objIC.Old_Eligibility_Criteria__c;
                            lstOfStudentProgramToUpdate.add(newObjSP);
    
                            // to update account status back to confirmed if IC change request is Disapproved
                            if(objSP.nm_Student__r.nm_StudentStatus__c!='Confirmed' && objSP.nm_FeesPaidofSemester__c > 0) {
                                Account objAccount = new Account(id=objSP.nm_Student__c);
                                objAccount.nm_StudentStatus__c = 'Confirmed';
                                lstOfAccountToUpdate.add(objAccount);
                            }
                        }
                    }
    
                    if(lstOfStudentProgramToUpdate.size() > 0) {
                        update lstOfStudentProgramToUpdate;
                    }
    
                    if(lstOfAccountToUpdate.size() > 0) {
                        update lstOfAccountToUpdate;
                    }
                }
            }   
        }
    
        if(oppid.size() > 0) {
            String LineitemQuery = getQueryAllFieldSql('OpportunityLineItem','opportunityId=:oppid and ProgramName2__c = \'Program Change Fee\'',null);
            mapOfOpportunityLineItemId = new Map<id,OpportunityLineItem>((List<OpportunityLineItem>)DataBase.query(LineitemQuery));
            if(!mapOfOpportunityLineItemId.isEmpty()) {
                List<Id> toDeleteIds = new List<Id>(mapOfOpportunityLineItemId.keySet());
                Database.DeleteResult[] deleteResults = Database.delete(toDeleteIds, true);               
            }
    
            system.debug('oppid ===>'+ oppid);
            undoDisapprovedOppLineItem(oppid);
    
            for(Id OppsId : oppid) {
                Opportunity objOpp = new Opportunity();                       
                objOpp = productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId,'Payment Approved', null, null);
            }
        }
    }
    
    public void SyncedWithStudentZone(list < IC_Change_Request__c > triggerNew, map < id, IC_Change_Request__c > Oldmap) {
        List < Opportunity > lstOppsToUpdate = new List < Opportunity > ();
        if (triggerNew.size() > 0) {
            for (IC_Change_Request__c objIC: triggerNew) {
                IC_Change_Request__c oldIC = oldmap.get(objIC.id);
                if (oldIC.Status__c != objIC.Status__c && objIC.Status__c == 'Approved') {
                    // if ('IC Change'.equalsIgnoreCase(objIC.nm_TypeofRequest__c) || 'Program Change'.equalsIgnoreCase(objIC.nm_TypeofRequest__c)) {
                    if ('Program Change'.equalsIgnoreCase(objIC.nm_TypeofRequest__c)) {
                        Opportunity objOpps = new Opportunity(id = objIC.Opportunity__c);
                        objOpps.Synced_With_StudentZone__c = false;
                        lstOppsToUpdate.add(objOpps);
                    }
                }
            }
    
            if (lstOppsToUpdate.size() > 0) {
                update lstOppsToUpdate;
            }
        }
    }
    //<--------------------------------------------------------------------------------------------------------->//  
    // public void UpdateAccountInformationCenterAndDebitCreationOnApproval(list < IC_Change_Request__c > triggerNew, map < id, IC_Change_Request__c > triggerOldMap) {
    
    //     set < id > oppId = new set < id > ();
    //     String feeType = '', newInformationCenter = '', opportunityId = '';
    //     IC_Change_Request__c oldStage = new IC_Change_Request__c();
    //     list < Account > lstAccount = new list < Account > ();
    //     List < Opportunity > lstOpportunity = new List < Opportunity > ();
    
    
    //     for (IC_Change_Request__c icIterator: triggerNew) {
    //         newInformationCenter = icIterator.New_IC__c;
    //         Account objAccount = [select id, nm_Centers__c from Account where id =: icIterator.Student__c];
    
    //         oppId.add(icIterator.Opportunity__c);
    
    
    //         oldStage = triggerOldMap.get(icIterator.id);
    //         // if (oldStage.Status__c == 'New' && icIterator.Status__c == 'Approved' && icIterator.nm_TypeofRequest__c == 'IC Change') {
    //         //     objAccount.nm_Centers__c = icIterator.New_Information_Center__c;
    //         //     lstAccount.add(objAccount);
    //         // }
    //     }
    //     feeType = GetFeeTypeOfOpportunity(oppId);
    //     System.debug('ListAccount---->' + lstAccount.size());
        
    //     if (lstAccount.size() > 0 && lstAccount != null) {
    //         update lstAccount;
    //         System.debug('Fee Type--->' + feeType);
    //         if (feeType == 'PGAllSemFee-Considered' || feeType == 'AnnualFee-Considered' || feeType == 'MultipleSemFee-Considered') {
    //             GenerateFixedDebitandCreditToInfoCenterOnApproval(oppId, oldStage.Existing_Information_Center__c, newInformationCenter);
    //         }
    //         /*   else
    //         {
    //           //  UpdateSharesToNewInformationCenter(newInformationCenter,oppId); 
    //         }*/
    //     }
    // }
    
        // commented by suyog
    // public String GetFeeTypeOfOpportunity(set < id > setOpps) {
    //     list < Opportunity > oppList = [select id, nm_Fee_Type__c, StageName from Opportunity where id in: setOpps];
    //     System.debug(oppList[0].nm_Fee_Type__c);
    //     return oppList[0].nm_Fee_Type__c;
    
    // }
    
    /*   public void UpdateSharesToNewInformationCenter(String informationCenter,set<id> opportunityId)
       {
           System.debug('UpdateSharesToNewInformationCenter called');
           set<id> icpaymentIdToUpdate = new set<id>();
           list<IC_Payment__c> emptyListOfIcPayments = new list<IC_Payment__c>();
           list<IC_Payment_Transaction__c> paymentTransactionsRelatedToAccount = [select id,Amount__c,IC_Payment__c from IC_Payment_Transaction__c where Amount__c!=55.00 and Opportunity__c in:opportunityId];
           for(IC_Payment_Transaction__c icTransaction : paymentTransactionsRelatedToAccount)
           {
               icpaymentIdToUpdate.add(icTransaction.IC_Payment__c);
               System.debug('icpaymentIdToUpdate'+icpaymentIdToUpdate);
           }
           System.debug('icpaymentIdToUpdate---->'+icpaymentIdToUpdate);
           list<IC_Payment__c> listOfIcPayments = [select id,Centers__c from IC_Payment__c where id in :icpaymentIdToUpdate];
           if(listOfIcPayments!=null && listOfIcPayments.size()>0)
           {
               for(IC_Payment__c icPayment : listOfIcPayments)
               {
                   icPayment.Centers__c = informationCenter;
                   emptyListOfIcPayments.add(icPayment);
                   System.debug('informationCenter'+informationCenter);
                   
               }
           }
           if(emptyListOfIcPayments!=null && emptyListOfIcPayments.size()>0)
           {
               update emptyListOfIcPayments;
           }
       }*/
    
    
       // commented by suyog
    // public void GenerateFixedDebitandCreditToInfoCenterOnApproval(set < id > setOfOpps, String oldInformationCenter, string newInformationCenter) {
    //     System.debug('After Update Called');
    //     Set < id > setpricebook = new Set < id > ();
    //     List < PriceBookEntry > lstPriceBookEntry = new List < PriceBookEntry > ();
    //     Map < String, PriceBookEntry > mapOfFeeTypeVesPriceBook = new map < String, PriceBookEntry > ();
    //     list < IC_Payment_Transaction__c > listIcTransaction = new list < IC_Payment_Transaction__c > ();
    //     double Amount, sharePerSem, fixedDebit;
    //     integer shareMonth, shareYear, shareMonth_1, shareYear_1, shareMonth_2, shareYear_2;
    //     list < Opportunity > opps = [select id, nm_Fee_Type__c, nm_Semester__c, Account.nm_Tagged_Pricebook__c, nm_Year__c, IC__c, AccountID, Account.nm_Centers__c, Program_Name__c, Account.name, CloseDate, nm_Session__c, nm_Drive_Name__c, (select id, nm_Amount__c, nm_OpportunityNew__c, nm_TransactionID__c, nm_DemandDraftNumber__c from Opportunities__r where nm_PaymentType__c != 'Change of IC') from Opportunity where id in: setOfOpps];
    //     System.debug('<-------opps------>' + opps);
    //     System.debug('<------opps.AccountID------>' + opps[0].AccountID);
    
    //     nm_StudentProgram__c studentProg = [select id, nm_FeesPaidofSemester__c from nm_StudentProgram__c where nm_Student__c =: opps[0].AccountID Limit 1];
    //     System.debug('studentProg---->' + studentProg);
    
    //     //Date today = Date.Today();
    
    //     Integer CloseDateYear = opps[0].CloseDate.Year();
    //     Integer CloseDateMonth = opps[0].CloseDate.Month();
    //     Integer CloseDateDay = opps[0].CloseDate.Day();
    
    //     for (Opportunity oppty: opps) {
    //         setpricebook.add(oppty.Account.nm_Tagged_Pricebook__c);
    //         lstPriceBookEntry = [select id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
    //             from PriceBookEntry
    //             where product2.isActive =: true
    //             and pricebook2.isStandard = false
    //             and Pricebook2.id in: setpricebook
    //             and Pricebook2.IsActive = true
    //         ];
    //         if (lstPriceBookEntry != null && lstPriceBookEntry.size() > 0) {
    //             for (PriceBookEntry objPBE: lstPriceBookEntry) {
    //                 mapOfFeeTypeVesPriceBook.put(objPBE.product2.Name, objPBE);
    //             }
    //         }
    
    //         if (oppty.nm_Fee_Type__c == 'PGAllSemFee-Considered') {
    //             Amount = mapOfFeeTypeVesPriceBook.get('PG_All_Sem').UnitPrice * Decimal.valueOf(Label.ICSharePercentage_PGD_D);
    //             sharePerSem = Amount / 4;
    //             fixedDebit = Amount - ((integer.valueOf(opps[0].nm_Semester__c) - 1) * sharePerSem);
    //         } else if (oppty.nm_Fee_Type__c == 'AnnualFee-Considered') {
    //             if (oppty.Program_Name__c.startswith('AC')) {
    //                 Amount = mapOfFeeTypeVesPriceBook.get('Certificate_Annual').UnitPrice * Decimal.valueOf(Label.ICSharePercentage_PGD_D);
    //                 sharePerSem = Amount / 2;
    //                 fixedDebit = sharePerSem;
    //             } else {
    //                 Amount = mapOfFeeTypeVesPriceBook.get('Annual').UnitPrice * Decimal.valueOf(Label.ICSharePercentage_PGD_D);
    //                 sharePerSem = Amount / 2;
    //                 fixedDebit = sharePerSem;
    //             }
    
    //         } else if (oppty.nm_Fee_Type__c == 'MultipleSemFee-Considered') {
    //             Amount = mapOfFeeTypeVesPriceBook.get('Multiple Semester').UnitPrice * Decimal.valueOf(Label.ICSharePercentage_PGD_D);
    //             sharePerSem = Amount / 3;
    //             fixedDebit = Amount - ((integer.valueOf(opps[0].nm_Semester__c) - 2) * sharePerSem);
    //         }
    //         System.debug('<---SharePerSem--->' + sharePerSem);
    //         system.debug('Amount' + Amount);
    //         system.debug('fixedDebit' + fixedDebit);
    //         System.debug('<------fixedDebit---->' + fixedDebit);
    //         if (opps[0].nm_Fee_Type__c == 'PGAllSemFee-Considered' || opps[0].nm_Fee_Type__c == 'AnnualFee-Considered' || opps[0].nm_Fee_Type__c == 'MultipleSemFee-Considered') {
    //             nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
    
    //             System.debug('Entered loop for IC Transaction');
    
    //             String RequiredMonthYear = MonthYearValue(CloseDateMonth, CloseDateYear, CloseDateDay);
    //             String RequiredMonthYear_1 = MonthYearValue(CloseDateMonth + 1, CloseDateYear, CloseDateDay);
    //             String RequiredMonthYear_2 = MonthYearValue(CloseDateMonth + 2, CloseDateYear, CloseDateDay);
    
    //             shareMonth = Integer.valueOf(RequiredMonthYear.substring(0, RequiredMonthYear.indexOf('_')));
    //             shareYear = Integer.valueOf(RequiredMonthYear.right(4));
    
    //             shareMonth_1 = Integer.valueOf(RequiredMonthYear_1.substring(0, RequiredMonthYear_1.indexOf('_')));
    //             shareYear_1 = Integer.valueOf(RequiredMonthYear_1.right(4));
    
    //             shareMonth_2 = Integer.valueOf(RequiredMonthYear_2.substring(0, RequiredMonthYear_2.indexOf('_')));
    //             shareYear_2 = Integer.valueOf(RequiredMonthYear_2.right(4));
    
    //             handler.createICTransactionDebitEntry(oppty, shareYear, shareMonth, fixedDebit, oldInformationCenter,'IC change');
    //             handler.createICTransactionCreditEntry(oppty, shareYear, shareMonth, fixedDebit * 0.6, newInformationCenter,'IC change');
    //             handler.createICTransactionCreditEntry(oppty, shareYear_1, shareMonth_1, fixedDebit * 0.2, newInformationCenter,'IC change');
    //             handler.createICTransactionCreditEntry(oppty, shareYear_2, shareMonth_2, fixedDebit * 0.2, newInformationCenter,'IC change');
    
    //         }
    //     }
    
    
    // }
    //<--------------------------------------------------------------------------------------------------------->//  
    
    
    //<--------------------------------------------------------------------------------------------------------->//  
    
    // commented by suyog
    // public String MonthYearValue(Decimal CloseDateMonth, Decimal CloseDateYear, Decimal CloseDateDay) {
    //     Date today = Date.Today();
    
    //     // Integer CloseDateYear = today.Year();    
    //     if (CloseDateDay <= 10) {
    //         CloseDateMonth = CloseDateMonth;
    //         System.debug('CloseDateMonth-->' + CloseDateMonth);
    //     } else {
    //         CloseDateMonth = CloseDateMonth + 1;
    //         System.debug('CloseDateMonth-->' + CloseDateMonth);
    //     }
    //     if (CloseDateMonth > = 13) {
    //         CloseDateMonth = CloseDateMonth - 12;
    //         CloseDateYear = CloseDateYear + 1;
    //         System.debug('CloseDateMonth-->' + CloseDateMonth);
    //         return String.valueOf(CloseDateMonth) + '_' + String.valueOf(CloseDateYear);
    //     } else {
    //         System.debug('CloseDateMonth-->' + CloseDateMonth);
    //         return String.valueOf(CloseDateMonth) + '_' + String.valueOf(CloseDateYear);
    //     }
    
    // }
    //<--------------------------------------------------------------------------------------------------------->//
    
    // create service change request on manually Inserted service Change request record
    /*  public void CreateServiceChangeRequestLineItemonInsertServiceChange(list<IC_Change_Request__c> lstIcChange)
    {
          ProductHelper productHelper = new ProductHelper();
          list<OpportunityLineItem> lstOppLineItems = new list<OpportunityLineItem>();
          list<Opportunity> lstOpportunityUpdate = new list<Opportunity>();
          list<nm_Centers__c> lstOfCenter =new list<nm_Centers__c>();
          set<String> setOfOppsId = new Set<String>();
          set<String> setOfIcChangeId = new set<String>();
          set<String> setOfAccountId =new set<String>();
          decimal pendingAmount = 0.0;
          boolean isCenterActive =true;
          boolean ProgramChangeApplicable;
          for(IC_Change_Request__c objIc:lstIcChange)
            {
            //get Tag pricebook Id from Account and check student status 
               List<Account> lstAccount = [select id,nm_Tagged_Pricebook__c,nm_Centers__c,nm_StudentStatus__c from Account where id =:objIc.Student__c];
            
               setOfIcChangeId.add(objIc.id);
               setOfOppsId.add(objIc.Opportunity__c);
               setOfAccountId.add(objIc.Student__c);
               
               Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
               Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(lstAccount[0].nm_Tagged_Pricebook__c );            
               Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = productHelper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
               System.debug('Price Book--->'+lstAccount[0].nm_Tagged_Pricebook__c);
                list<Opportunity> lstOpps = [select id,nm_Program__c,Is_Re_Registration_Payment__c from Opportunity where id =:objIc.Opportunity__c];
                
                //If study kit apply manadatory create LineItem
               if(objIc.Student_Kits__c && mapPricebook!=null)
                {
                   lstOppLineItems.add(productHelper.CreateLineIteam('Student Kits',mapPricebook,objIc.Opportunity__c));
                }
                
               // check type of request for allowing to insert student kit without program change & use when rere-register from site
               if(objIc.nm_TypeofRequest__c !=null && objIc.nm_TypeofRequest__c !='' && mapPricebook!=null && objIc.ChangeAmount__c == null)
                {
                  
                    list<nm_Program__c> Lstofprogram = [select id, nm_Type__c, nmIsActive__c from nm_Program__c where id=:lstOpps[0].nm_Program__c ];
                    
                    //List check whether Current center is active or inactive
                    if(objIc.Current_Information_Center__c!=null)
                    {
                        lstOfCenter = [select id,Name,Nm_Active__c from nm_Centers__c where id=:objIc.Current_Information_Center__c];
                        isCenterActive = lstOfCenter[0].Nm_Active__c;
                    }
                    
                    if(Lstofprogram.size()>0 )
                    {
                        //If Program is inactive or Center is Inactive Lineitem inserted value will be zero
                        if(!Lstofprogram[0].nmIsActive__c || !isCenterActive)
                        {
                            OpportunityLineItem objLineItem = new OpportunityLineItem();
                            objLineItem.OpportunityId = objIc.Opportunity__c;
                            objLineItem.PriceBookEntryId = mapPricebook.get(objIc.nm_TypeofRequest__c+' Fee').id;
                            objLineItem.Quantity = 1.00;
                            objLineItem.TotalPrice = 0.0;
                            objLineItem.ActualSalePrice__c = 0.0;
                            lstOppLineItems.add(objLineItem);
                        }
                        //LineItem will be inserted only for Confirm student
                        else if(lstAccount[0].nm_StudentStatus__c=='Confirmed' )
                        {
                           lstOppLineItems.add(productHelper.CreateLineIteam(objIc.nm_TypeofRequest__c+' Fee',mapPricebook,objIc.Opportunity__c));
                        }
                    }
                    
                }
              //Custom Request create by Head office with applicable amount.
               else if(objIc.nm_TypeofRequest__c !=null && objIc.nm_TypeofRequest__c !='' && mapPricebook!=null && objIc.ChangeAmount__c != null)
                {
                   system.debug('Change Amount---->'+objIc.ChangeAmount__c);
                 
                   if(lstOpps.size()>0)
                    {
                        OpportunityLineItem objLineItem = new OpportunityLineItem();
                        objLineItem.OpportunityId = objIc.Opportunity__c;
                        objLineItem.PriceBookEntryId = mapPricebook.get(objIc.nm_TypeofRequest__c+' Fee').id;
                        objLineItem.Quantity = 1.00;
                        objLineItem.TotalPrice = objIc.ChangeAmount__c;
                        objLineItem.ActualSalePrice__c = objIc.ChangeAmount__c;
                        insert objLineItem;
                    }
                }
               //Program Change request prior confirmation 
               if(objIc.nm_TypeofRequest__c !=null && objIc.nm_TypeofRequest__c =='Program Change' && mapPricebook!=null && objIc.New_Program__c!=null  && lstAccount[0].nm_StudentStatus__c!='Confirmed' )
                {
                       system.debug('enter in Loop');
                       nm_StudentProgram__c objStudentProg =[select id,nm_Student__c from nm_StudentProgram__c where  nm_Student__c In :setOfAccountId ];
                       Opportunity objOpp = lstOpps[0];
                      
                      if(objIc.Fee_Type__c!=null)
                       {                          
                           objOpp.nm_Fee_Type__c= objIc.Fee_Type__c;
                           update objOpp;
                       }
                       if(objIc.Eligibility_Criteria__c!=null)
                       {
                            objStudentProg.nm_EligiblityCriteria__c = objIc.Eligibility_Criteria__c;
                       }
                       objStudentProg.nm_Program__c=objIc.New_Program__c;                   
                                             
                       update objStudentProg;                      
                }
                 //IC Change request prior confirmation 
               if(objIc.nm_TypeofRequest__c !=null && objIc.nm_TypeofRequest__c =='IC Change' && mapPricebook!=null && objIc.New_Information_Center__c!=null  && lstAccount[0].nm_StudentStatus__c!='Confirmed' )
                {
                       system.debug('enter in Loop');
                       nm_StudentProgram__c objStudentProg =[select id,nm_Student__c from nm_StudentProgram__c where  nm_Student__c In :setOfAccountId ];
                       Account objAccount = lstAccount[0];
                       Opportunity objOpp = lstOpps[0];
                        
                       objAccount.nm_Centers__c = objIc.New_Information_Center__c;                                        
                           update objAccount;
                       
                       if(objIc.Fee_Type__c!=null)
                       {                          
                           objOpp.nm_Fee_Type__c= objIc.Fee_Type__c;
                           update objOpp;
                       }
                       if(objIc.Eligibility_Criteria__c!=null)
                       {
                            objStudentProg.nm_EligiblityCriteria__c = objIc.Eligibility_Criteria__c;
                       }
                                     
                                             
                       update objStudentProg;                   
                }
                
            }
            
            if(lstOppLineItems.size()>0)
            {
                insert lstOppLineItems;
            }
            
            // update Opportunity Stage to Pending Payment or Payment Made after Service Request Insert
            if(setOfIcChangeId.size()>0)
            {
                List<IC_Change_Request__c> lstIcChangeReq = [select id, Opportunity__c from IC_Change_Request__c where id In :setOfIcChangeId];
               
                if(lstIcChangeReq.size()>0)
                {
                    for(IC_Change_Request__c objIc : lstIcChangeReq)
                    {
                        setOfOppsId.add(objIc.Opportunity__c);
                    }
                }
            }
            
            if(setOfOppsId.size()>0)
            {
                for(String OppsId : setOfOppsId)
                {
                   // calculate Pending and depending upon Pending Amount Update Opportunity Stage 
                    productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId,'service Change');
                }
            }  
            
    }*/
    public void CreateServiceChangeRequestLineItemonInsertServiceChange(list < IC_Change_Request__c > lstIcChange) {
        ProductHelper productHelper = new ProductHelper();
        list < OpportunityLineItem > lstOppLineItems = new list < OpportunityLineItem > ();
        list < Opportunity > lstOpportunityUpdate = new list < Opportunity > ();
        list < nm_Centers__c > lstOfCenter = new list < nm_Centers__c > ();
        set < String > setOfOppsId = new Set < String > ();
        set < String > setOfAccountId = new set < String > ();
        decimal pendingAmount = 0.0;
        boolean isCenterActive = true;
        boolean isProgramActive;
        boolean ProgramChangeApplicable;
        String Stage;
        
    
        for (IC_Change_Request__c objIc: lstIcChange) {
            //get Tag pricebook Id from Account and check student status 
    
            setOfOppsId.add(objIc.Opportunity__c);
            setOfAccountId.add(objIc.Student__c);
    
            list < Account > lstAccount = [select id,Program_Change_Waive_Off__c,OldStudentForExecutive__c, nm_Tagged_Pricebook__c, nm_Centers__c, nm_StudentStatus__c, nm_StudentNo__c,nm_DefencePersonnel__c from Account where id =: objIc.Student__c];
            Account objAccount = lstAccount[0];
    
            list < Opportunity > lstOpps = [select id,AccountId, StageName,nm_Semester__c, nm_Program__c, nm_Fee_Type__c, Is_Re_Registration_Payment__c,CourseList__c, nm_Program__r.Name,nm_Program__r.IsTerm__c, nm_Program__r.ReRegonly__c,nm_Program__r.nmIsActive__c,nm_Program__r.nm_ProgramName__c, nm_Program__r.nm_TotalSemesters__c,nm_Program__r.Specialisation__c, nm_Program__r.nm_Type__c,(SELECT Id,UnitPrice,ActualSalePrice__c,Product_Name__c FROM OpportunityLineItems) from Opportunity where id =: objIc.Opportunity__c];
            
            list <IC_Change_Request__c> lstIcChangeRequest = [SELECT Id FROM IC_Change_Request__c  WHERE   Student__c = :objAccount.Id];
            Boolean isIcChangeRequestAlreadyRaised = false;
            if(lstIcChangeRequest.size() > 0) {
                for (IC_Change_Request__c icChange : lstIcChangeRequest) {
                    system.debug('objIc ==> ' + objIc.Id);
                    system.debug('icChange ==> '+ icChange.id);
                    if(icChange.Id != objIc.Id) {
                        isIcChangeRequestAlreadyRaised = true;
                        break;
                    }
                }
            }
            system.debug('lstIcChangeRequest ==> ' + lstIcChangeRequest);
            system.debug('isIcChangeRequestAlreadyRaised' + isIcChangeRequestAlreadyRaised);
            nm_Program__c newProgram = new nm_Program__c();
            if(String.isNotBlank(objIc.New_Program__c)) {
    
              newProgram=  [select id,IsTerm__c,nm_TotalSemesters__c,name,nm_Type__c,Specialisation__c,nm_ProgramName__c from nm_Program__c WHERE Id = : objIc.New_Program__c LIMIT 1] ;
            }
            Opportunity objOpp = lstOpps[0];
            Stage = objOpp.StageName;
    
            list<nm_Program__c> Lstofprogram = [select id,IsTerm__c,nm_TotalSemesters__c,name,nm_Type__c,Specialisation__c,nm_ProgramName__c from nm_Program__c where id = :objOpp.nm_Program__c limit 1];
            nm_Program__c objprg = Lstofprogram[0];
    
            nm_StudentProgram__c objStudentProg = [select id, nm_Student__c, nm_EligiblityCriteria__c from nm_StudentProgram__c where nm_Student__c In: setOfAccountId limit 1];
    
            isProgramActive = lstOpps[0].nm_Program__r.nmIsActive__c || lstOpps[0].nm_Program__r.ReRegonly__c?true:false;
    
            System.debug('isProgramActive' + isProgramActive);
    
            Map < String, Map < String, PriceBookEntry >> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            Map < String, PriceBookEntry > mapPricebook = mapPricebookIdVsPriceBook.get(lstAccount[0].nm_Tagged_Pricebook__c);
    
            System.debug('mapPricebookIdVsPriceBook ---> ' + mapPricebookIdVsPriceBook.size());
            System.debug('mapPricebookIdVsPriceBook ---> ' + mapPricebookIdVsPriceBook.keySet());
            System.debug('lstAccount[0].nm_Tagged_Pricebook__c ----> ' + lstAccount[0].nm_Tagged_Pricebook__c);
            System.debug('mapPricebook ----> ' + mapPricebook);
            System.debug('mapPricebook.lstAccount[0].nm_Tagged_Pricebook__c ----> ' + mapPricebookIdVsPriceBook.containsKey(lstAccount[0].nm_Tagged_Pricebook__c));
    
    
            //If study kit apply manadatory create LineItem
            if (objIc.Student_Kits__c && mapPricebook != null) {
                lstOppLineItems.add(productHelper.CreateLineIteam('Student Kits', mapPricebook, objIc.Opportunity__c));
            }
            if(String.isNotBlank(objOpp.CourseList__c) ) {
                objIc.addError('Program can only be change if course list is empty');
            }
    
            if (objIc.Eligibility_Criteria__c != null && String.isBlank(objOpp.CourseList__c)) {
                objStudentProg.nm_EligiblityCriteria__c = objIc.Eligibility_Criteria__c;
                update objStudentProg;
            }
    
           
    
            // check type of request for allowing to insert student kit without program change & use when rere-register from site
            if (objIc.nm_TypeofRequest__c != null && objIc.nm_TypeofRequest__c != '' && mapPricebook != null) {
    
                if (objIc.ChangeAmount__c == null && (objAccount.nm_StudentStatus__c == 'Confirmed' || (objAccount.nm_StudentNo__c!=null && objAccount.nm_StudentNo__c!=''))) {
                    //List check whether Current center is active or inactive
                    if (objIc.Current_Information_Center__c != null) {
                        lstOfCenter = [select id, Name, Nm_Active__c from nm_Centers__c where id =: objIc.Current_Information_Center__c];
                        isCenterActive = lstOfCenter[0].Nm_Active__c;
                    }
    
    
                    //If Program is inactive or Center is Inactive Lineitem inserted value will be zero
                    if (!isProgramActive || !isCenterActive) {
    
                        lstOppLineItems.add(CreateLineIteam(objIc.nm_TypeofRequest__c + ' Fee', mapPricebook, objIc.Opportunity__c, 0));
                    }
    
                    //LineItem will be inserted only for Confirm student
                    else {
                        if(( objAccount.Program_Change_Waive_Off__c && !isIcChangeRequestAlreadyRaised && objOpp.nm_Semester__c == '2') && 
                            (newProgram != null && newProgram.nm_Type__c == 'MBA (Distance) Programs' && objOpp.nm_Program__r.nm_Type__c == 'Diploma Programs') && objOpp != null) {
                        lstOppLineItems.add(CreateLineIteam(objIc.nm_TypeofRequest__c + ' Fee', mapPricebook, objIc.Opportunity__c, 0));
                        }  
                        else {
                            if(newProgram != null && 
                            ((objOpp.nm_Program__r.Name == 'BBA'&& newProgram.Name == 'BBA-BA') || (objOpp.nm_Program__r.Name == 'BBA-BA'&& newProgram.Name == 'BBA')) ) {
                                System.debug('objOpp.nm_Program__r.Name ==> '+ objOpp.nm_Program__r.Name);
                                System.debug('newProgram.Name ==> '+ newProgram.Name);
                                programChangeForBBA(objOpp, newProgram, mapPricebook,objAccount.nm_DefencePersonnel__c,objprg,objAccount.OldStudentForExecutive__c);
                        } 
                            lstOppLineItems.add(productHelper.CreateLineIteam(objIc.nm_TypeofRequest__c + ' Fee', mapPricebook, objIc.Opportunity__c));
                        
                        }
                        
                    }
                }
                //Custom Request create by Head office with applicable amount.
                else if (objIc.ChangeAmount__c != null && lstOpps.size() > 0) {
                    system.debug('Change Amount---->' + objIc.ChangeAmount__c);
                    if(( objAccount.Program_Change_Waive_Off__c && !isIcChangeRequestAlreadyRaised && objOpp.nm_Semester__c == '2') && 
                        (newProgram != null && newProgram.nm_Type__c == 'MBA (Distance) Programs' && objOpp.nm_Program__r.nm_Type__c == 'Diploma Programs')) {
                        lstOppLineItems.add(CreateLineIteam(objIc.nm_TypeofRequest__c + ' Fee', mapPricebook, objIc.Opportunity__c, 0));
                    } else {
                        lstOppLineItems.add(CreateLineIteam(objIc.nm_TypeofRequest__c + ' Fee', mapPricebook, objIc.Opportunity__c, objIc.ChangeAmount__c));
                    
                    }
                }
                //Program Change request prior confirmation 
                if (objIc.nm_TypeofRequest__c == 'Program Change' && mapPricebook != null && objIc.New_Program__c != null 
                    && objAccount.nm_StudentStatus__c != 'Confirmed' && (objAccount.nm_StudentNo__c==null || objAccount.nm_StudentNo__c=='') ) {
                    System.debug('enter in Loop');
    
    
                    if (objIc.Fee_Type__c != null) {
                        objOpp.nm_Fee_Type__c = objIc.Fee_Type__c;
                        update objOpp;
                    }
    
                    //    objIc.Status__c='Approved';
                    objStudentProg.nm_Program__c = objIc.New_Program__c;
                    update objStudentProg;
    
                }
                //IC Change request prior confirmation 
                // if (objIc.nm_TypeofRequest__c == 'IC Change' && mapPricebook != null && objIc.New_Information_Center__c != null && objAccount.nm_StudentStatus__c != 'Confirmed') {
                //     system.debug('enter in Loop');
    
    
                //     objAccount.nm_Centers__c = objIc.New_Information_Center__c;
                //     update objAccount;
    
                //     if (objIc.Fee_Type__c != null) {
                //         objOpp.nm_Fee_Type__c = objIc.Fee_Type__c;
                //         update objOpp;
                //     }
    
                // }
    
            }
    
        }
    
        if (lstOppLineItems.size() > 0) {
            insert lstOppLineItems;
        }
    
    
        if (setOfOppsId.size() > 0) {
            for (String OppsId: setOfOppsId) {
                // calculate Pending and depending upon Pending Amount Update Opportunity Stage 
                if(!'Closed Won - Re-registration Pending'.equalsIgnoreCase(Stage))
                {
                     productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(OppsId, 'service Change', null, null);
                }
               
            }
        }
    
    }
    //Creating opportunity line item records
    public OpportunityLineItem CreateLineIteam(String TypeOfProduct, Map < String, PriceBookEntry > mapPricebook, String OppsId, Decimal amount) {
        OpportunityLineItem objLineItem = new OpportunityLineItem();
        objLineItem.OpportunityId = OppsId;
        objLineItem.PriceBookEntryId = mapPricebook.get(TypeOfProduct).id;
        objLineItem.Quantity = 1.00;
        objLineItem.UnitPrice = amount;
        objLineItem.ActualSalePrice__c = amount;
        return objLineItem;
    }
    
    public void programChangeForBBA(Opportunity opp, nm_Program__c newProgram, Map<String,PriceBookEntry> mapPricebook,String Isdefence,nm_Program__c objprg, Boolean IsexcutiveDiscount) {
        // OpportunityLineItem OpportunityLineItem = [SELECT Id,Product2.Name FROM Opportunity WHERE OpportunityId = :opp.Id AND Product2.nm_Program__c =:objOpp.nm_Program__r.Id LIMIT 1 ];
        List<Opportunity> lstOpportunity = [select id,StageName,nm_Semester__c, nm_Program__c, nm_Fee_Type__c, Is_Re_Registration_Payment__c,CourseList__c, nm_Program__r.Name,nm_Program__r.IsTerm__c, nm_Program__r.ReRegonly__c,nm_Program__r.nmIsActive__c,nm_Program__r.nm_ProgramName__c, nm_Program__r.nm_TotalSemesters__c,nm_Program__r.Specialisation__c, nm_Program__r.nm_Type__c FROM Opportunity WHERE AccountId = :opp.AccountId ORDER BY nm_Semester__c DESC];
    
        
        Boolean isPaymentMAdeBefore = opp.nm_Fee_Type__c.contains('Considered') ? true : false;
        String feeType = opp.nm_Fee_Type__c.contains('Considered') ?opp.nm_Fee_Type__c.split('-')[0] : opp.nm_Fee_Type__c;
        Integer paidLatestSemester = Integer.valueOf(opp.nm_Semester__c); 
        Opportunity oldOpp = new Opportunity();
        string strOldKey = objprg.Id + '-' + opp.nm_Semester__c;
        string strNewKey = newProgram.Id + '-' + opp.nm_Semester__c;
        system.debug('feeType ==> ' + feeType);
        system.debug('strOldKey ==> ' + strOldKey);
        system.debug('strNewKey ==> ' + strNewKey);
        // if(isPaymentMAdeBefore)
        for (Opportunity objOpp : lstOpportunity) {
            if(objOpp.nm_Fee_Type__c ==feeType ){
                oldOpp = objOpp;
                break;
            }
        }
        OpportunityLineItem objOppL =new OpportunityLineItem();
        List<OpportunityLineItem> lstOppLineItem = opp.OpportunityLineItems;
        for(OpportunityLineItem oppL : lstOppLineItem) {
            if(oppL.Product_Name__c.Contains('Semester')) {
                objOppL = oppL;
                break;
            }
        }
        system.debug('objOppL ===> ' + objOppL);
        system.debug('oldOpp ===> ' + oldOpp);
    
        ProductHelper productHelper = new ProductHelper();
        // productHelper.ActualUnitprice(objOpportunity, Feetype, Isdefence, Strkey, objprg, mapPricebook, IsexcutiveDiscount)
        Decimal oldActualOldPrice = productHelper.ActualUnitprice(oldOpp, feeType, Isdefence, strOldKey, objprg, mapPricebook, IsexcutiveDiscount);
        Decimal newActualOldPrice = productHelper.ActualUnitprice(oldOpp, feeType, Isdefence, strNewKey, newProgram, mapPricebook, IsexcutiveDiscount);
        Decimal newExtraPrice = 0;
        system.debug('oldActualOldPrice ===> ' + oldActualOldPrice);
        system.debug('newActualOldPrice ===> ' + newActualOldPrice);
        if(oldActualOldPrice < newActualOldPrice) {
            newExtraPrice = newActualOldPrice - oldActualOldPrice;
            objOppL.ActualSalePrice__c = objOppL.ActualSalePrice__c + newExtraPrice;
            system.debug('objOppL ==> ' + objOppL);
            update objOppL;
        }
    
        
        
    
        // if(OpportunityLineItem != null) {
        //     List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); 
        //     String PriceBookEntry = 'select id, UnitPrice,Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c,product2.Id,Product2Id, product2.Family, product2.Name, product2.nm_Program__c, product2.nm_Semester__c'+
        //         +' from PriceBookEntry where product2.isActive = true '+
        //         +'and pricebook2.isStandard = false and Pricebook2.nmSession_Start_Date__c !=null '+
        //         +'and Pricebook2.nmSession_End_Date__c !=null ' +
        //         +'and product2.Family = :newProgramId ' +
        //         +'and product2.Name = :OpportunityLineItem.Product2.Name ' +
        //         +'and Pricebook2.IsActive=true ';
        //     System.debug('Query = '+PriceBookEntry);
        //     lstPriceBookEntry = DataBase.query(PriceBookEntry);
        //     if(lstPriceBookEntry.size() > 0) {
        //         PriceBookEntry PriceBookEntry = lstPriceBookEntry[0];
        //     }
        // }
    }
    
    public void undoDisapprovedOppLineItem(Set<Id> oppId) {
        system.debug('undoDisapprovedOppLineItem ==> ' );
        system.debug('oppId ==> ' + oppId.toString());
        ProductHelper productHelper = new ProductHelper();
        Map < String, Map < String, PriceBookEntry >> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        // objAccount.nm_DefencePersonnel__c,objprg,objAccount.OldStudentForExecutive__c
        
        List<Opportunity> lstOpportunity = [select id,Account.nm_Tagged_Pricebook__c,AccountId,StageName,nm_Semester__c, nm_Program__c, nm_Fee_Type__c, Is_Re_Registration_Payment__c,CourseList__c, nm_Program__r.Name,
         Account.nm_DefencePersonnel__c,Account.OldStudentForExecutive__c,
        nm_Program__r.IsTerm__c, nm_Program__r.ReRegonly__c,nm_Program__r.nmIsActive__c,nm_Program__r.nm_ProgramName__c, nm_Program__r.nm_TotalSemesters__c,nm_Program__r.Specialisation__c, nm_Program__r.nm_Type__c ,(SELECT Id,UnitPrice,ActualSalePrice__c,Product_Name__c FROM OpportunityLineItems WHERE Product_Name__c LIKE 'Semester%' ) FROM Opportunity WHERE Id IN :oppId AND (nm_Program__r.Specialisation__c = 'BBA' OR nm_Program__r.Specialisation__c = 'BA')  ];
        
        if(lstOpportunity.size() > 0) {
            for (Opportunity opp : lstOpportunity) {
                system.debug('opp ===> ' + opp);
                list<nm_Program__c> Lstofprogram = [select id,IsTerm__c,nm_TotalSemesters__c,name,nm_Type__c,Specialisation__c,nm_ProgramName__c from nm_Program__c where id = :opp.nm_Program__c limit 1];
                nm_Program__c objprg = Lstofprogram[0];
                string strKey = objprg.Id + '-' + opp.nm_Semester__c;
                Map < String, PriceBookEntry > mapPricebook = mapPricebookIdVsPriceBook.get(opp.Account.nm_Tagged_Pricebook__c);
                Decimal ActualSalesPrice = productHelper.ActualUnitprice(opp, opp.nm_Fee_Type__c, opp.Account.nm_DefencePersonnel__c, strKey, objprg, mapPricebook, opp.Account.OldStudentForExecutive__c);
                system.debug('ActualSalesPrice ===> '+ ActualSalesPrice );
                if(opp.OpportunityLineItems.size() > 0) {
                    for (OpportunityLineItem oppLItem : opp.OpportunityLineItems) {
                        system.debug('oppLItem ===> ' + oppLItem);
                        oppLItem.ActualSalePrice__c = ActualSalesPrice;
                        lstOppLineItem.add(oppLItem);
                    }
                }
                
            }
        }
        if(lstOppLineItem.size() > 0) {
            update lstOppLineItem;
        }
    }
    
    }