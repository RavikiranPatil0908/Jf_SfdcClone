/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 07-23-2021
 * @last modified by  : shubhranshu
**/
@isTest(SeeAllData=false)
public class ProductHelperTracker{
    
    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
         nmGenericTracker.CreateProduct('Live Lectures',1200);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',true);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Certificate Programs',objAccount,'admission');
    system.debug('objopp.nm_StudentProgram__c--->'+objopp.nm_StudentProgram__c);
    system.debug('objopp.id--->'+objopp.id);

     //  IC_Change_Request__c objICR = nmGenericTracker.CreateICChangeRequest(objopp);
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        
        // IC_Change_Request__c objIC = nmGenericTracker.CreateprogramChangeRequest(objopp);
        // objIC.Student__c = objAccount.Id;
        // objIC.Status__c = 'New';
        // update objIC;
        // system.debug(objIC);

        nmGenericTracker.CreateOpportunityLineItem(objopp);
        nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Admission');
        nmGenericTracker.CreateLateFeePaymentRecordForOppty(objopp);
        nmGenericTracker.createLateFeeRecord('Admission','Certificate Programs');
        nmGenericTracker.createLateFeeRecord('ReRegistration','Certificate Programs');
        Product2 registrationproduct = nmGenericTracker.CreateRegistrationProduct(objopp);
        Product2 lateFeeproduct = nmGenericTracker.CreatelateProduct(objopp);
        Product2 Careerproduct = nmGenericTracker.CreateCareerProduct(objopp);
        nmGenericTracker.CreatePriceBookEntry(lateFeeproduct,1000);
        nmGenericTracker.CreatePriceBookEntry(registrationproduct,1200);
        nmGenericTracker.CreatePriceBookEntry(Careerproduct ,1200);
       
      //  nmGenericTracker.createProductAndPricebookEntry('Career Development',null,null,priceBooke2Id);
        nmGenericTracker.createLateFeeRecord('Admission','Certificate Programs');
         system.debug('objopp.nm_StudentProgram__c2--->'+objopp.nm_StudentProgram__c);
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testmethod void opportunityPaymentMadeUnitTest(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Date batchstart = System.Today();
            Opportunity objOpps = [select id,IC__c,nm_Future_Sems_Created__c,late_fee__c,CareerServiceFee__c,nm_Session__c,nm_Year__c,RegistrationFee__c,ActualAmountReceived__c,ConsumerType__c,Sem__c,Program_Structure__c,LiveLecturesType__c,CourseList__c,WaivedOffAmount__c,E_S_charge__c,Account.nm_Centers__c,ShareApplicable__c ,AdditionalAmountRecieved__c,Total_Amount_Received__c,Account.nm_Tagged_Pricebook__c,Career_Service__c,Account.Name,Choose_a_Program__c,ChooseProgram__c,ActualPendingAmount__c,Pending_For__c,Actual_Amount__c,
            Account.nm_ChooseaProgram__c,CloseDate,Processed__c,Accountid,nm_StudentProgram__c,nm_Payment_Approved__c,nm_Category__c,Account.nm_IsEmailVerified__c,Specialisation__c,
                                 nm_StudentProgram__r.nm_Program__c,nm_Semester__c,nm_Program__c,nm_Fee_Type__c ,Account.Is_Mobile_Verified__c,Account.Program_Type__c,Account.Interview_Status__c,
                                 Is_Re_Registration_Payment__c,StageName,
                                 Account.nm_StudentStatus__c,Pricebook2Id,BacklogList__c from Opportunity where StageName = 'Payment Made' limit 1];
            Account objAccount = [select id,nm_Tagged_Pricebook__c,nm_Centers__c   from Account where id=: objOpps.AccountId];
            objAccount.nm_Tagged_Pricebook__c  = String.valueOf(objOpps.Pricebook2Id).substring(0, 15);
            update objAccount;
            
          //   IC_Change_Request__c objICR =[select id from IC_Change_Request__c ];
             nm_Centers__c objCenter = nmGenericTracker.CreateCenter('Mumbai');
             nmGenericTracker.CreateICAndUser(objCenter);
          /*  objOpps.Career_Service__c ='Career Development';
           update objOpps ;*/
            
            list<OpportunityLineItem > lstoppo = [select id,Name from OpportunityLineItem  where OpportunityId =:objOpps.id];
            
            Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objOpps);
            nm_Program__c objProgram = nmGenericTracker.CreateDegreeProgram();
            CreatePriceBookEntry(semesterproduct ,76000,objOpps.Pricebook2Id,objOpps.id);

            Map<String, List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = new Map<String, List<OpportunityLineItem>>();
            mapOfOppsIdVsOpportunityLineItem.put(objOpps.Id, lstoppo);

            Map<Id, Account>mapOfOppsVsAccount = new Map<Id, Account>();
            mapOfOppsVsAccount.put(objOpps.Id,objAccount);
           
            ProductHelper productHelper = new ProductHelper();
            Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            system.debug('mapPricebookIdVsPriceBook --> ' + mapPricebookIdVsPriceBook);
            Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
            PriceBookEntry entryP = mapPricebook.get('Late Fee');
            mapPricebook.put('PG_All_Sem',entryP);
            mapPricebook.put('MSAllSemFee',entryP );
            mapPricebook.put('Registration Fee',entryP );
            mapPricebook.put('Live Lectures',entryP );
            mapPricebook.put('3SemFee',entryP );
            mapPricebook.put('4SemFee',entryP );
            mapPricebook.put('5SemFee',entryP );
            mapPricebook.put('3SemFee'+'-'+objProgram.Id,entryP );
            mapPricebook.put('2SemFee',entryP );
            mapPricebook.put('Multiple Semester',entryP );
            mapPricebook.put('FullFee',entryP );
            mapPricebook.put('MSAllSemFee',entryP );
            mapPricebook.put('MBAallTermfee',entryP );
            mapPricebook.put('Annual',entryP );
            mapPricebook.put(objOpps.nm_Program__c + '-' + objOpps.nm_Semester__c,entryP );
            productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpps.id,'Payment Approved', null, null);
            productHelper.getPendingAmount(objOpps.id);
            productHelper.getProductPrice('Yes',1000);
            productHelper.Unitprice(objOpps,'PGAllSemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'PGAllSemFee','No',null,objProgram,mapPricebook,false);
             productHelper.Unitprice(objOpps,'3SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'3SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.Unitprice(objOpps,'2SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'2SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.Unitprice(objOpps,'4SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'4SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.Unitprice(objOpps,'5SemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'5SemFee','No',null,objProgram,mapPricebook,false);
             productHelper.Unitprice(objOpps,'MultipleSemFee','No',null,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'MultipleSemFee','No',null,objProgram,mapPricebook,false);
             productHelper.Unitprice(objOpps,'3SemFee','No',objOpps.nm_Program__c + '-' + objOpps.nm_Semester__c,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'3SemFee','No',objOpps.nm_Program__c + '-' + objOpps.nm_Semester__c,objProgram,mapPricebook,false);
             productHelper.Unitprice(objOpps,'','No',objOpps.nm_Program__c + '-' + objOpps.nm_Semester__c,objProgram,mapPricebook,false);
            productHelper.ActualUnitprice(objOpps,'','No',objOpps.nm_Program__c + '-' + objOpps.nm_Semester__c,objProgram,mapPricebook,false);
            productHelper.ValidateFeeType(2,'AnnualFee','Custom', false);
            productHelper.ValidateFeeType(4,'PGAllSemFee', 'Custom', false);
            productHelper.ValidateFeeType(3,'MultipleSemFee','Custom', false);
            productHelper.ValidateFeeType(3,'ReRegistrationPayment','Custom', false);
            productHelper.ValidateFeeType(4,'PGAllSemFee');
            productHelper.ValidateFeeType(2,'AnnualFee');
            productHelper.ValidateFeeType(3,'MultipleSemFee');
            productHelper.ValidateFeeType(3,'ReRegistrationPayment');
            productHelper.ValidateFeeType(4,'FullFee');
            productHelper.ValidateFeeType(5,'MBAallTermfee');
            productHelper.ValidateFeeType(5,'jfhdfbcb');
           // productHelper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpps);
           //  productHelper.UpdateICChangeStatusForPaymentApproved(objOpps,objICR);
         //   productHelper.getPendingPaymentFor(objOpps);
            productHelper.CheckforDebitCreditEntry(objOpps,new Set<String>{objOpps.id});
            productHelper.CheckForAdjustmentDebit(new Set<String>{objOpps.id},objOpps);
            productHelper.CheckForAdmissionComission(new Set<String>{objOpps.id},objOpps);
            productHelper.lateFee('Admission');
            productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps,objProgram, null, null );
            productHelper.getCenterUser(objCenter.id);
           // productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps,'PGDM');
            productHelper.DeleteOpportunityLineItemAfterProgramChange(objOpps);
            productHelper.getLateBasedUponTransDateAndCategory(System.today(),'Admission','Certificate Programs','July','2022');
            productHelper.getLateBasedUponTransDateAndCategory(System.today(),'Admission','Master Programs','MBA(WX)','July','2022');
            productHelper.getLateBasedUponTransDateAndCategory(System.today(),'ReRegistration',null,'July','2022');
            productHelper.getLateBasedUponTransDateAndCategory(null,'ReRegistration',null,'July','2022');
            productHelper.getLateFeeRecord('Admission',null,'July','2022' );
            productHelper.getLateFeeRecord('Admission',null,null,'July','2022' );
            productHelper.CreateLineIteam('Late Fee',mapPricebook,objOpps.id);
            productHelper.CreateLateFeeLineItem(100.0,mapPricebook,objOpps);
            productHelper.CreateLineIteamObject('Registration Fee',mapPricebook,objOpps.id);
           // Set<String> setacc = new Set<String>();
            //.add(objAccount.id);
           // productHelper.getOpportunity(String.valueof(objAccount.id));
            productHelper.Validity(batchstart, objProgram, 1) ;
          // productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps, objOpps.Program_Name__c);
            productHelper.Feetypeprice(objOpps,'3SemFee',mapPricebook,objProgram);
            productHelper.CareerServiceProduct(lstoppo ,objOpps );
            productHelper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpps );
            // productHelper.CreateSemesterLineIteam(objOpps,mapPricebookIdVsPriceBook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem);
        Test.StopTest();
    }
 /*   public static testmethod void opportunityPaymentMadeUnitTest2(){

        Account objAccount = [select id,nm_Tagged_Pricebook__c,nm_Centers__c  from Account limit 1];
        Opportunity objOpps = [select id,stageName,nm_Program__c ,LiveLecturesType__c,Specialisation__c,Career_Service__c,ChooseProgram__c,nm_Fee_Type__c,nm_Semester__c,Choose_a_Program__c,Program_Name__c,IC__c,nm_StudentProgram__c ,pricebook2Id,AccountId,Account.Name,nm_Category__c  from Opportunity where AccountId =: objAccount.Id limit 1];
        
            objAccount.nm_Tagged_Pricebook__c  = String.valueOf(objOpps.Pricebook2Id).substring(0, 15);
            update objAccount;
            system.debug('objOpps.nm_StudentProgram__c--->'+objOpps.nm_StudentProgram__c);
            system.debug('objOpps.id--->'+objOpps.id);
            system.debug('objAccount.id--->'+objAccount.id);
              ProductHelper productHelper = new ProductHelper();
             Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
            PriceBookEntry entryP = mapPricebook.get('Late Fee');
            mapPricebook.put('PG_All_Sem',entryP);
            mapPricebook.put('MSAllSemFee',entryP );
             mapPricebook.put('Registration Fee',entryP );
             mapPricebook.put('Live Lectures',entryP );
          //   IC_Change_Request__c objICR =[select id from IC_Change_Request__c ];
          system.debug('objOpps.LiveLecturesType__c--'+objOpps.LiveLecturesType__c);
            IC_Change_Request__c objICR = nmGenericTracker.CreateprogramChangeRequest(objOpps );
          //  list<OpportunityLineItem > lstoppo = [select id,Name from OpportunityLineItem  where OpportunityId =:objOpps.id];
            
            Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objOpps);
            nm_Program__c objProgram = nmGenericTracker.CreateDegreeProgram();
             Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
               // ProductHelper productHelper = new ProductHelper();
             productHelper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpps);
             productHelper.UpdateICChangeStatusForPaymentApproved(objOpps,objICR);
            Test.StopTest();
     }
    */
    public static testmethod void CourselistUnitTest1(){
          
            
            Opportunity objopp = [select id,stageName,CourseList__c,nm_Program__c ,LiveLecturesType__c,ConsumerType__c,Sem__c,Program_Structure__c,Specialisation__c,Career_Service__c,ChooseProgram__c,nm_Fee_Type__c,nm_Semester__c,Choose_a_Program__c,Program_Name__c,IC__c,nm_StudentProgram__c ,pricebook2Id,AccountId,Account.Name,nm_Category__c  from Opportunity where StageName = 'Payment Made' limit 1];
            Account objAccount = [select id,nm_Tagged_Pricebook__c,nm_Centers__c   from Account where id=: objopp.AccountId];
            objAccount.nm_Tagged_Pricebook__c  = String.valueOf(objopp.Pricebook2Id).substring(0, 15);
            update objAccount;
            
            objopp.LiveLecturesType__c='1SemLecturesFee';
            //update objopp;
            
            Product2 productvs1 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,1);
            nmGenericTracker.CreateCourseList(objOpp,1,'Business Economics',productvs1.id,23);
            nmGenericTracker.CreateCourseList(objOpp,1,'Economics',productvs1.id,45);
            nmGenericTracker.CreateCourseList(objOpp,1,'Business science',productvs1.id,67);
             Product2 productvs2 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,2);
            nmGenericTracker.CreateCourseList(objOpp,2,'Economics value',productvs2.id,673);
            nmGenericTracker.CreateCourseList(objOpp,2,'Economics to resolved',productvs2.id,43);
            nmGenericTracker.CreateCourseList(objOpp,2,'Business to overcome',productvs2.id,232);
            Product2 productvs3 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,3);
            nmGenericTracker.CreateCourseList(objOpp,3,'Supply chain',productvs3.id,672);
            nmGenericTracker.CreateCourseList(objOpp,3,'Disbursed chain',productvs3.id,345);
            Product2 productvs4 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,4);
            nmGenericTracker.CreateCourseList(objOpp,4,'Trade head',productvs4.id,897);
            nmGenericTracker.CreateCourseList(objOpp,4,'Stock market',productvs4.id,5667);
          
         //   list<OpportunityLineItem > lstoppo = [select id,Name from OpportunityLineItem  where OpportunityId =:objOpps.id];
            
            //Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objOpps);
           // nm_Program__c objProgram = nmGenericTracker.CreateDegreeProgram();
             Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
                ProductHelper productHelper = new ProductHelper();
            // productHelper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpps);
             //productHelper.UpdateICChangeStatusForPaymentApproved(objOpps,objICR);
             
            
          Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
            PriceBookEntry entryP = mapPricebook.get('Late Fee');
            mapPricebook.put('PG_All_Sem',entryP);
            mapPricebook.put('MSAllSemFee',entryP );
             mapPricebook.put('Registration Fee',entryP );
             mapPricebook.put('Live Lectures',entryP );
            
            productHelper.TotalNumberOfSubject(1,'Jul2019', objopp.nm_Program__c,'1SemLecturesFee','','Retail');
            productHelper.TotalNumberOfSubject(1,'Jul2019', objopp.nm_Program__c,'2SemLecturesFee','','Retail');
            productHelper.TotalNumberOfSubject(1,'Jul2019', objopp.nm_Program__c,'3SemLecturesFee','','Retail');
            productHelper.TotalNumberOfSubject(1,'Jul2019', objopp.nm_Program__c,'4SemLecturesFee','','Retail');
            productHelper.TotalNumberOfSubject(1,'Jul2019', objopp.nm_Program__c,'Custom','1,2,3,4,45,67','Retail');
            productHelper.getMapOfProgramNamekeyVsCourses();
            productHelper.SetLiveLecturesValue(objopp);
            productHelper.ActualUnitpriceLiveLecture(objopp,mapPricebook);
            productHelper.UnitpriceLiveLecture(objopp,'1SemLecturesFee',mapPricebook);
            productHelper.UnitpriceLiveLecture(objopp,'2SemLecturesFee',mapPricebook);
            productHelper.UnitpriceLiveLecture(objopp,'3SemLecturesFee',mapPricebook);
            productHelper.UnitpriceLiveLecture(objopp,'4SemLecturesFee',mapPricebook);
            Test.StopTest();
     }


    //  @IsTest
    //  public static void methodName3(){
       
    //    Test.startTest();
    //     Opportunity objOpp = [select id,IC__c,nm_Future_Sems_Created__c,late_fee__c,CareerServiceFee__c,RegistrationFee__c,ActualAmountReceived__c,ConsumerType__c,Sem__c,Program_Structure__c,LiveLecturesType__c,CourseList__c,WaivedOffAmount__c,E_S_charge__c,Account.nm_Centers__c,ShareApplicable__c ,AdditionalAmountRecieved__c,Total_Amount_Received__c,Account.nm_Tagged_Pricebook__c,Career_Service__c,Account.Name,Choose_a_Program__c,ChooseProgram__c,ActualPendingAmount__c,Pending_For__c,Actual_Amount__c,
    //         Account.nm_ChooseaProgram__c,CloseDate,Processed__c,Accountid,nm_StudentProgram__c,nm_Payment_Approved__c,nm_Category__c,Account.nm_IsEmailVerified__c,Specialisation__c,
    //                              nm_StudentProgram__r.nm_Program__c,nm_Semester__c,nm_Program__c,nm_Fee_Type__c ,Account.Is_Mobile_Verified__c,Account.Program_Type__c,Account.Interview_Status__c,
    //                              Is_Re_Registration_Payment__c,StageName,
    //                              Account.nm_StudentStatus__c,Pricebook2Id,BacklogList__c from Opportunity  limit 1];
    //     system.debug('objOpp -----> ' + objOpp);

    //     // objOpp.StageName = 'Closed';
    //     // update objOpp;
    //     nm_Program__c objProgram = [Select Id From nm_Program__c Limit 1 ];
    //     IC_Change_Request__c objCR = new IC_Change_Request__c ();
    //     // objCR.Status__c='New';
    //     // objCR.Student__c= objOpp.AccountID;
    //     // objCR.Opportunity__c=objOpp.id;
    //     // objCR.nm_TypeofRequest__c='Program Change';
    //     // objCR.nm_Reson__c='test test';
    //     // objCR.New_Program__c = objProgram.id;
        
    //     objCR.nm_Reason_for_Change_of_Program__c ='better oppos';
    //     insert objCR;
        
    //     // list<IC_Change_Request__c> lstICR=[select id, Status__c from IC_Change_Request__c ];
    //     // // IC_Change_Request__c objIC = new IC_Change_Request__c(Id = lstICR[0].Id);
    //     // // objIC.Status__c = 'New';
    //     // // update objIC;
    //     // system.debug('lstICR -----> ' + lstICR);
    //     // system.debug('objIC -----> ' + objIC);



    //   ProductHelper productHelper = new ProductHelper();
    //     productHelper.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpp );
    //    Test.stopTest();
       
    //  }


   public static OpportunityLineItem CreatePriceBookEntry(Product2 product ,decimal productPrice, Id priceBook2Id, Id OppsId)
    {
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert standardPriceBookEntry;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = priceBook2Id, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert objPriceBookEntry;
        
        OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice = productPrice;
        objLineItem.Quantity = 1;
        objLineItem.OpportunityId = OppsId;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c = productPrice;
        insert objLineItem ;
        return objLineItem;
    }


    // @IsTest
    // static void CreateSemesterLineIteam1(){
      
    //   Test.startTest();
    //   List<OpportunityLineItem> lstOppLine = new List<OpportunityLineItem>();
    //   Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = new Map<String,Map<String,PriceBookEntry>>();
    //   Map<String,PriceBookEntry> mapPricebookIdVsPrice  = new Map<String,PriceBookEntry>();
    //   Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = new Map<String,List<OpportunityLineItem>>();
    //   Map<Id,Account> mapOfOppsVsAccount = new Map<Id,Account>();

    //   Opportunity objOpp = [SELECT Id,AccountId, Pricebook2Id FROM Opportunity  LIMIT 1];
    //   Account objAccount = [SELECT Id, nm_Tagged_Pricebook__c FROM Account WHERE Id = :objOpp.AccountId];
      
    //   Product2 registrationFee = nmGenericTracker.CreateProduct('Registration Fee', 95000 );

    //   OpportunityLineItem oppLine = CreatePriceBookEntry(registrationFee, 95000, objOpp.Pricebook2Id, objOpp.Id);

    //   lstOppLine.add(oppLine);

    //   PriceBookEntry priceBook = [SELECT id FROM PriceBookEntry WHERE ID = : oppLine.PriceBookEntryId];

    //   mapPricebookIdVsPrice.put(oppLine.PriceBookEntryId,priceBook );

    //   mapOfOppsVsAccount.put(objOpp.Id, objAccount);
    //   mapOfOppsIdVsOpportunityLineItem.put(objOpp.Id, lstOppLine);
    //   mapPricebookIdVsPriceBook.put(objAccount.nm_Tagged_Pricebook__c,mapPricebookIdVsPrice );
       


      

    //   ProductHelper pHelper = new ProductHelper();
    //   pHelper.CreateSemesterLineIteam(objOpp,mapPricebookIdVsPriceBook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem);
    //   Test.stopTest();
      
    // }
}