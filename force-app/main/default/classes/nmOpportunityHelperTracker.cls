@istest (SeeAllData=false)
public without sharing class nmOpportunityHelperTracker {
    public nmOpportunityHelperTracker() {

    }
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson ='{"status":"success","message":[{"Response":"success"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    public static void setUpData(){
       // List<Opportunity> oppLst = new List<Opportunity>();

        List<OpportunityLineItem> OpportunityLineItemLst = new List<OpportunityLineItem>();
        List<nm_Payment__c> paymentLst = new List<nm_Payment__c>();

        Account acc1 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('No',false,'Confirmed');

        Opportunity opp1 = CreateOpportunityWithAccountAndProgram('Re-registration Cancelled','1','Bachelor Programs',acc1,'admission');
        insert opp1;
        nmGenericTracker.CreateOpportunityLineItem(opp1);
        nm_Payment__c pay1 = CreatePaymentRecords(opp1.Id,'Admission','Opportunity','installmentRef123');
        paymentLst.add(pay1);
        
        Career_Service_Package__c csp = new Career_Service_Package__c();
        csp.Package_Name__c = 'Career Development';
        csp.isActive__c = true;
        //csp.Package_Code__c = 'CSP-2104';
        insert csp;
        Career_Service_Program__c cs = new Career_Service_Program__c();
        cs.Account__c = acc1.Id;
        cs.Opportunity__c = opp1.Id;
        cs.Stage__c = 'Cancelled';
        cs.CareerServiceProgram__c = csp.id;
        insert cs;
        nm_Payment__c payc2 = CreatePaymentRecords( cs.Id,'Career Service','CareerServiceProgram__c','installmentRef123');
        paymentLst.add(payc2);




       // insert oppLst;
        // for(Opportunity oppObj : oppLst){
        //   OpportunityLineItemLst.add(CreateOpportunityLineItem(oppObj));

        // }
        
        // insert OpportunityLineItemLst;
        insert paymentLst;

       // oppLst[0].Id;

        List<nmRefund_Payment__c> refundPaymentlst = new List<nmRefund_Payment__c>();
        nmRefund_Payment__c refundPaymentObj = new nmRefund_Payment__c();
        refundPaymentObj.islivelectRefunded__c = 1000.00 >0.0 ? true : false;
        refundPaymentObj.isCareerServiceRefunded__c = 1500.00 > 0.0 ? true : false;
        refundPaymentObj.Account__c = opp1.AccountId;
        refundPaymentObj.Mode_Of_Payment__c = 'Online';//modeofpayment
        refundPaymentObj.Opportunity__c = opp1.Id;
        refundPaymentObj.Status__c = 'Refund Request Created';
        refundPaymentObj.Study_Kit__c = true;
        refundPaymentObj.Total_Refund_Amount__c = 8000;
        refundPaymentObj.Type_of_Refund__c = 'Re-registration Cancelled';
        refundPaymentObj.nm_Information_Center__c = opp1.Account.nm_Centers__r.Id;
        refundPaymentObj.nm_Payment_Status__c = 'Refund Initiated';
        refundPaymentObj.nm_Student_E_mail__c = opp1.nm_StudentEmail__c;
        refundPaymentlst.add(refundPaymentObj);

        nmRefund_Payment__c refundPaymentCareerServiceObj = new nmRefund_Payment__c();
        refundPaymentCareerServiceObj.Total_Refund_Amount__c = 1500.00;
        refundPaymentCareerServiceObj.Type_of_Refund__c = 'Career Service Cancellation';
        refundPaymentCareerServiceObj.nm_Information_Center__c = opp1.Account.nm_Centers__r.Id;
        refundPaymentCareerServiceObj.nm_Payment_Status__c = 'Refund Initiated';
        refundPaymentCareerServiceObj.nm_Student_E_mail__c = opp1.nm_StudentEmail__c;
        refundPaymentCareerServiceObj.Account__c = opp1.AccountId;
        refundPaymentCareerServiceObj.isCareerServiceRefunded__c = 1500.00 > 0.0 ? true : false;
        refundPaymentCareerServiceObj.CareerServiceProgram__c = cs.Id;
        refundPaymentlst.add(refundPaymentCareerServiceObj);


        insert refundPaymentlst;

        


    }

    @isTest
    public static void test1()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();   
        Opportunity objopp = [select id,nm_Session__c,nm_Year__c,PreviousStageName__c,StageName,nm_Semester__c,
        PVM__c,nm_Program__c,Program_Name__c,Specialisation__c,Total_Sem__c,
        ChooseProgram__c ,AccountID from Opportunity where nm_Semester__c = '1' AND nm_Fee_Type__c = 'admission' limit 1];
    //     Map<Id,Opportunity> oldmap= new Map<Id,Opportunity>();
    //     oldmap.put(objopp.id,objopp);
    //     List<Opportunity> lstOpp = new List<Opportunity>();
    //     //objopp.StageName = 'Closed Won';
    //     objopp.PreviousStageName__c = objopp.StageName;
    //     objopp.StageName = 'Re-registration Cancelled';
    //   //  objopp.Processed__c = true;
    //     update objopp;
    //     lstOpp.add(objopp);
       // ReregCancellation.doReregistrationCancellation(lstOpp, oldMap);
        nmOpportunityHelper.doUndoReregistrationCancellation(objopp.id,  objopp.AccountID);
        Test.stopTest();

    }

    public static Opportunity CreateOpportunityWithAccountAndProgram(String OpptyStage,String sem,String programType,Account objAccount,String Feetype)
    {
        Opportunity objopp =new Opportunity();
        list<Opportunity> lstopp=new list<Opportunity>();
        //Account objAccount = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        nm_Program__c program = new nm_Program__c();
        nm_StudentProgram__c objSP = new nm_StudentProgram__c();
        
        if(programType =='Bachelor Programs' )
        {
            program = CreateBachelorProgramsProgram();
          //  objSP = CreateBachelorProgram(objAccount);
        }
    //    objopp.nm_AdmissionDriveDate__c = createAdmissionDriveDate(program).id;
        objopp.StageName = OpptyStage;
        objopp.PreviousStageName__c = 'Closed Won';
        objopp.nm_Fee_Type__c  = Feetype;
        objopp.nm_Payment_Approved__c =true;
        objopp.processed__c = false;
        objopp.nm_Session__c = 'January';
        objopp.nm_Year__c = 2019;
        objopp.CloseDate=System.today();
        objopp.nm_Semester__c= sem;
        objopp.Name='Chandra_Singh_11DSCM_Sem_1_Jan_2015';
      //  objopp.nm_StudentProgram__c = objSP.id;
        system.debug('objopp.nm_StudentProgram__c--->'+objopp.nm_StudentProgram__c);
        objopp.AccountId = objAccount.id; 
        objopp.nm_Program__c = program.id;
        objopp.nm_LateFee__c=1000;
        objopp.Amount=500.00; 
        objopp.TermRepeated__c= false;
        objopp.nm_Session__c='July';
        objopp.nm_Year__c=2020;
        objopp.Is_Re_Registration_Payment__c = true;
        objopp.nm_SelfLearningMaterial__c  ='Send to my Information Centre. I will pick up.';
        if(objAccount.Is_Lateral__c){
            objOpp.nm_Category__c = 'Lateral Admission';
        }else{
            objOpp.nm_Category__c = 'Admission';
        }
      //  insert objopp;
        return objopp;
        
    }

    public static nm_Program__c CreateBachelorProgramsProgram()
    {
        return CreateProgram('Bachelor Programs','Bachelor of Business Administration',6,'MBA');
    }

    public static nm_Program__c CreateProgram(String typeOfProgram,String ProgramName,decimal totalSem,String sepcialization)
    {
      nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.BookCChargeapplicable__c = true ;
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = ProgramName;
       program.nm_ProgramValidity__c = totalSem;
       program.nm_TotalSemesters__c = totalSem;
       program.nm_Type__c = typeOfProgram;
       program.prgst__c ='Jul2019';
       program.PVM__c = 48;
       program.Specialisation__c = sepcialization;          
       insert program; 
       return program;
    }
   
    public static OpportunityLineItem CreateOpportunityLineItem(Opportunity objopp)
    {
        Product2 product = CreateSemesterProduct(objopp);
        product = CreateRegistrationProduct(objopp);
       product = CreatelateProduct(objopp);
        PriceBookEntry objPriceBookEntry = CreatePriceBookEntry(product,12000);
        
        OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c =1000;
        //insert objLineItem ;
        return objLineItem;
    }
    public Static Product2 CreateSemesterProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = objopp.nm_Program__c;
        product2.nm_Semester__c = objopp.nm_Semester__c;
        product2.isActive = true;
        insert product2;
        return product2;
    }

    public Static Product2 CreateRegistrationProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Registration Fee';
        product2.isActive = true;
        insert product2;
        return product2;
    }

    public Static Product2 CreatelateProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Late Fee';
        product2.isActive = true;
        insert product2;
        return product2;
    }
    public static PriceBookEntry CreatePriceBookEntry(Product2 product ,decimal productPrice)
    {
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert standardPriceBookEntry;
        
        Pricebook2 customPB = CreatePriceBook();
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert objPriceBookEntry;
        
        return objPriceBookEntry;
    }

    public Static PriceBook2 CreatePriceBook()
    {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
    }

    public static nm_Payment__c CreatePaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
      nm_Payment__c objPayment = new nm_Payment__c ();
      if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
          objPayment.nm_OpportunityNew__c = recordId;
      }
      if('CareerServiceProgram__c'.equalsIgnoreCase(SObjectAPIName)){
        objPayment.CareerServiceProgram__c = recordId;
      }
    // }else {
    //       objPayment.nm_Lead__c  = recordId;
    //   }
      objPayment.nm_Amount__c = 4272;
      objPayment.nm_ActualPaymentAmmount__c = 4272;
      objPayment.nm_PaymentStatus__c ='Payment Made';
      objPayment.nm_PaymentGatewayName__c ='Bill Desk';
      objPayment.nm_PaymentType__c = TypeOfPayment;
      objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
      objPayment.nm_Installment_Payment_Ref__c = installmentRef;
      //insert objPayment;
      return objPayment;
  }


}