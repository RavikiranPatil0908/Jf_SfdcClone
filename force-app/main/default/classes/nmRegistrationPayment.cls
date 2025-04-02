// This Class is used as a Controller for VF Page nmRegistrationPayment
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        24-Nov-2014      Sumit Banarji          Initial Version
// ---------------------------------------------------------------------------------------------
public class nmRegistrationPayment 
{
    /*----------- Public Properties----------------*/
    //--- Lead Detailes--------- 
  /*
    public lead objLead { get; set; }
    
    public Account objAccount {get;set;}
    //---Payment Detailes-----
    public nm_Payment__c objPayment { get; set; }

    //---- Stores lead ID---
    public string strLeadId { get; set; }
    
    public string accountId{get;set;}
    
    //---- Hidden field to store selected amount option --  
    public string strSelectedPayFor { get; set; }

    //---- Payment option Shown on page --
    public paymentOptions payOptions { get; set; }
    
    //---- Stores messages ----
    public string Messages { get; set; }
    
    //---- Stores error messages ---
    public string errMessages { get; set; }
    
    //---- Stores name of section to show on page ---
    public string strSecToShow { get; set; }
    
    // --- ExtraFee Panel To Show On Page
    public string extraFeeApplicable{get;set;}
    
    //---- Late fee informations to show on page ---
    public Late_Fee__c objLateFee { get; set; }
    
    //--- No of payment options ----
    public integer noPayOptions { get; set; }
    
    //--- No of Semester ----
    public integer intTotalSem  { get; set; }
    
    //--- No of Semester ----
    public integer intNoOfSemToPay  { get; set; }
    public boolean isShow{get;set;}
    public boolean LateralStudent{get;set;}
    public String strShowPaymnetOptions{get;set;}

    public String selectedduration{get;set;}
    //mayur 17/7/2015
    public string icValue{ get; set; }
    public boolean allowPayment { get; set; }
    public string url {get;set;}
        
    public boolean isDefence{get;set;} // mayur 8/7/2015
    public boolean isLateral{get;set;}
    public String opportunityId{get;set;}
    
    //--- Lead Detailes--------- 
    public Opportunity objOpportunity { get; set; }
    
    //-- Stores today date ----
    public date Today
    {
        get
        {
                return date.Today();
        }
        set;
    }
    /*----------- Public Properties----------------*/
    
    
    /*------------------- Constructor ---------------------*/
    public nmRegistrationPayment()
    {
       
       
       } 
        
        /*
        //----- Initializing Default values --------//
        strSecToShow = 'main';          
        objLead = new Lead();
        objLateFee = new Late_Fee__c();
        objPayment = new nm_Payment__c();
        objOpportunity = new Opportunity();
        //mayur 17/7/2015
        icValue = ApexPages.currentPage().getParameters().get('IC');
        //allowPayment = ApexPages.currentPage().getParameters().get(true);
        objPayment.nm_ModeOfPayment__c = 'Online';
        
        strSelectedPayFor = 'registration';
        noPayOptions = 2;
        intTotalSem  = 1;

        strShowPaymnetOptions='';
        isShow=false;
       LateralStudent =false;
        //--- End Initializing Default values ------//
        
        strLeadId = ApexPages.currentPage().getParameters().get('id');
        accountId = ApexPages.currentPage().getParameters().get('accId');
        String strPaymnetFrom=ApexPages.currentPage().getParameters().get('PaymentFrom');
        opportunityId = ApexPages.currentPage().getParameters().get('oppId');
        //extraFeeApplicable =ApexPages.currentPage().getParameters().get('extraFees');
        System.debug('Extra Fee Applicable--->'+extraFeeApplicable);
        if(strPaymnetFrom !='' && strPaymnetFrom !=null)
        {
             strShowPaymnetOptions=strPaymnetFrom;
        }
        if( ApexPages.currentPage().getParameters().get('payOpt') != null && ApexPages.currentPage().getParameters().get('payOpt') !='')
                noPayOptions = integer.valueOf(ApexPages.currentPage().getParameters().get('payOpt'));
                
        if( strLeadId != null && strLeadId !='')
        {
            InitializeData();
        }
        
    }*/
    /*------------------ End Constructor --------------------*/
    
    
    /*-------- Initializing Lead Informations --------*/
 /*   public void InitializeData()
    {
        System.debug('<---Account ID-->'+accountId);
        System.debug('<----Lead ID--->'+strLeadId);
        findPaymentsMadeUsingLead();
        ConfigurePayOpt( objLead );
        
        System.debug('opportunityId = '+opportunityId);
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA')
        {
            findPaymentsMadeUsingOpportunity();
            ConfigurePayOpt(objOpportunity);
        }
        
       
        String TotalPay='';
        system.debug('intTotalSem'+intTotalSem+'payOptions.Option2.Amount'+payOptions.Option2.Amount);
        if(payOptions.Option2.Amount  !=null &&payOptions.Option2.Amount>0 && intTotalSem==1 && payOptions.Option3.PaymentType=='LeadRegistrationAdmission')
        {
            TotalPay=String.ValueOf(payOptions.Option2.Amount);
             system.debug('TotalPayASAS'+TotalPay);
        }
        else if(payOptions.Option3.Amount !=null && payOptions.Option3.Amount>0 && payOptions.Option3.PaymentType == 'LeadRegistrationFullFee')
        {
            TotalPay=String.ValueOf(payOptions.Option3.Amount);
            system.debug('TotalPaySSS'+TotalPay);
        }
        //mayur s 22/6/2015
        
        else if(payOptions.Option4.Amount !=null && payOptions.Option4.Amount>0 && payOptions.Option4.PaymentType == 'PGAllSemFee')
        {
            TotalPay=String.ValueOf(payOptions.Option4.Amount);
            system.debug('TotalPaySSS'+TotalPay);
        }
        
        //mayur e 22/6/2015
        
        //For AnnualFee 
        //Mayur s 3-Oct-2015
        
        else if(payOptions.Option5.Amount !=null && payOptions.Option5.Amount>0 && payOptions.Option5.PaymentType == 'AnnualFee')
        {
            TotalPay=String.ValueOf(payOptions.Option5.Amount);
            system.debug('TotalPaySSS'+TotalPay);
        }
        
        //Mayur e 3-Oct-2015
        
       /* decimal declateffeesTo=0.0;
        declateffeesTo+=lateFee ('Admission');
        system.debug('TotalPay'+TotalPay);
        if(declateffeesTo>0.0){
            if(TotalPay !='' && TotalPay !=null){
           
             TotalPay=String.valueof(decimal.valueof(TotalPay)+declateffeesTo);
             }
        }
        system.debug('TotalPay'+TotalPay);*/
  
     
    
    /*
    public void findPaymentsMadeUsingOpportunity(){
        
        list<Opportunity> lstOpportunity   = [ select id, Account.nm_DefencePersonnel__c,nm_Category__c,Account.nm_ChooseaProgram__c,nm_Program__r.nm_TotalSemesters__c, Account.nm_RegistrationNumber__c, nm_Program__c,
         nm_ModeOfPayment__c, Account.PersonEmail, Account.PersonMobilePhone, Account.nm_Centers__r.name,Account.nm_Centers__r.Contact_No_1__c,  
         Account.nm_Centers__r.nm_Street__c, Account.nm_Program__r.nm_TotalSemesters__c,IC__c,
        Account.nm_Centers__r.Address__c,Account.Is_Lateral__c,nm_Semester__c,
                ( Select nm_ActualPaymentAmmount__c, nm_Amount__c, nm_Pay_Mode__c, nm_PaymentType__c,
                 nm_PaymentStatus__c from Opportunities__r  where nm_PaymentStatus__c != 'Transaction Failed'
                  and nm_PaymentStatus__c != null    )   
                  
        from Opportunity   where id = : opportunityId
        and nm_Program__c != null
         and nm_Program__r.nm_TotalSemesters__c != null ];
         
         
        if( lstOpportunity != null && lstOpportunity.size() > 0 )
            objOpportunity =  lstOpportunity[0];    
                                      
        if( objOpportunity != null )
        {
            
            if(objOpportunity.Account.Is_Lateral__c && objOpportunity.nm_Semester__c =='2')
            {
               LateralStudent =true;
            }
            intTotalSem   = integer.valueof(objOpportunity.nm_Program__r.nm_TotalSemesters__c);
            intNoOfSemToPay = intTotalSem;
            for( nm_Payment__c objpay : objOpportunity.Opportunities__r )
            {
                if( objpay.nm_Amount__c != null && objpay.nm_PaymentStatus__c != null && objpay.nm_PaymentType__c != null )
                {
                    if( objpay.nm_PaymentStatus__c == 'Payment Made' || objpay.nm_PaymentStatus__c == 'Payment Approved' )
                    {
                        if(  objpay.nm_PaymentType__c == 'Registration' )
                        {
                            payOptions.Option1.AlreadyPaid = true;
                            strSelectedPayFor = 'admission';
                           
                        }
                        else if(  objpay.nm_PaymentType__c == 'Admission' )
                        {
                            payOptions.Option2.AlreadyPaid = true;
                        }
                    }
                }
            }
            
                
            if( payOptions.Option1.AlreadyPaid && payOptions.Option2.AlreadyPaid )
            {
                errMessages = 'Payment already done.';
                strSecToShow = 'error';
                isShow=true;
            }
        }
    }*/
    
   /* public void findPaymentsMadeUsingLead(){
        list<Lead> lstLead   = [ select id, Are_you_from_Defence__c,nm_Allowtomakepayment__c,Lead_Lateral_Catogery__c,IsConverted,nm_ChooseaProgram__c, nm_RegistrationNo__c, nm_Program__c,nm_Semester__c, nm_ModeOfPayment__c, Email, MobilePhone, nm_InformationCenter__r.name,LC_name__c,Is_Lateral__c, 
                                    nm_InformationCenter__r.nm_Street__c, nm_Program__r.nm_TotalSemesters__c, nm_InformationCenter__r.Address__c,nm_StudentImageUrl__c,nm_InformationCenter__r.Contact_No_1__c,IC_Name__c,
                                    ( 
                                        Select nm_ActualPaymentAmmount__c, nm_Amount__c, nm_Pay_Mode__c, nm_PaymentType__c, nm_PaymentStatus__c
                                        from Payment__r
                                        where nm_PaymentStatus__c != 'Transaction Failed'
                                        and nm_PaymentStatus__c != null
                                    )
                                    from Lead 
                                    where id = : strLeadId
                                    and nm_Program__c != null
                                    and nm_Program__r.nm_TotalSemesters__c != null ];
                                    
                                   
        if( lstLead != null && lstLead.size() > 0 )
        {
            objLead =  lstLead[0]; 
            isLateral = objLead.Is_Lateral__c;
            allowPayment = objLead.nm_Allowtomakepayment__c;
            if(isLateral && objLead.nm_Semester__c =='2')
            {
                LateralStudent=true;
                System.debug('Enter In Lateral Loop Ar Lead Level---->');
            }    
            system.debug('-----isLateral----'+isLateral);
         }
      
        
            list<Account> lstAccount =[select id,nm_StudentNo__c,nm_Allowtomakepayment__c,nm_LeadId__c, nm_ChooseaProgram__c,nm_RegistrationNumber__c,Is_Lateral__c from Account where nm_LeadId__c =:strLeadId];
            if(lstAccount !=null && lstAccount.size()>0)
            {
                objAccount =  lstAccount[0];
                isLateral =objaccount.Is_Lateral__c;
               allowPayment = objaccount.nm_Allowtomakepayment__c;
                System.debug('lstAccount------------>'+lstAccount);
            }
              
               
                                     
        if( objLead != null )
        {
            
            intTotalSem   = integer.valueof(objLead.nm_Program__r.nm_TotalSemesters__c);
            intNoOfSemToPay = intTotalSem;
            for( nm_Payment__c objpay : objLead.Payment__r )
            {
                if( objpay.nm_Amount__c != null && objpay.nm_PaymentStatus__c != null && objpay.nm_PaymentType__c != null )
                {
                    if( objpay.nm_PaymentStatus__c == 'Payment Made' || objpay.nm_PaymentStatus__c == 'Payment Approved' )
                    {
                        if(  objpay.nm_PaymentType__c == 'Registration' )
                        {
                            payOptions.Option1.AlreadyPaid = true;
                            strSelectedPayFor = 'admission';
                           
                        }
                        else if(  objpay.nm_PaymentType__c == 'Admission' )
                        {
                            payOptions.Option2.AlreadyPaid = true;
                        }
                    }
                }
            }
                        
            if( payOptions.Option1.AlreadyPaid && payOptions.Option2.AlreadyPaid )
            {
                errMessages = 'Payment already done.';
                strSecToShow = 'error';
                isShow=true;
            }
        }
    }*/
    
    /*-------- Initializing Lead Informations --------*/   
    
    
    /*---------- Configring Payment Options --------------------*/
   /* public class paymentOptions
    {
        public Payment Option1 { get; set; }
        
        public Payment Option2 { get; set; }
        
        public Payment Option3 { get; set; }
        
        public Payment Option4 { get; set; } //for PGAllSemFee - mayur 22/6/2015
        
        public Payment Option5 { get; set; } //for AnnualFee - mayur 3-Oct-2015
        
        public Payment Option6 { get; set; } //for Multiple Sem Fee Lateral Student
        
        public paymentOptions()
        {
            Option1 = new Payment();
            Option2 = new Payment(); 
            Option3 = new Payment(); 
            Option4 = new Payment();  //for PGAllSemFee - mayur 22/6/2015
            Option5 = new Payment();  //for AnnualFee - mayur 3-Oct-2015
            Option6 = new Payment();
        }
    }
    */
/*
    public void ConfigurePayOpt( Lead regLead  )
    {
        payOptions.Option1.strPayFor = 'registration';
        payOptions.Option1.Amount = productPricing('Registration Fee','Name', regLead.Are_you_from_Defence__c, true);
        payOptions.Option1.PaymentType = 'LeadRegistration'; 
        
        payOptions.Option2.strPayFor = 'admission';
        payOptions.Option2.PaymentType = 'LeadRegistrationAdmission';
        payOptions.Option2.Amount = productPricing( regLead.nm_Program__c ,'ID', regLead.Are_you_from_Defence__c, false);
        if( payOptions.Option1.AlreadyPaid == false)
            payOptions.Option2.Amount += payOptions.Option1.Amount;
        payOptions.Option2.LateFeeAmount = CheckLateFeeCategory(objLead.Lead_Lateral_Catogery__c);
       
        payOptions.Option3.strPayFor = 'fullFee';
        payOptions.Option3.PaymentType = 'LeadRegistrationFullFee';
        payOptions.Option3.Amount = productPricing( regLead.nm_Program__c ,'ID', regLead.Are_you_from_Defence__c, false);
        if(!payOptions.Option1.AlreadyPaid)
            payOptions.Option3.Amount += payOptions.Option1.Amount;
        payOptions.Option3.LateFeeAmount = CheckLateFeeCategory(objLead.Lead_Lateral_Catogery__c);
        
        // mayur s 22/6/2015
        
        payOptions.Option4.strPayFor = 'PGAllSemFee';
        payOptions.Option4.PaymentType = 'PGAllSemFee';
        payOptions.Option4.Amount = productPricing( 'PG_All_Sem' ,'Name', regLead.Are_you_from_Defence__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option4.Amount += payOptions.Option1.Amount;
        payOptions.Option4.LateFeeAmount = CheckLateFeeCategory(objLead.Lead_Lateral_Catogery__c);
        
        // mayur e 22/6/0215
        
        //For Annual Fee
        //Mayur s 3-Oct-2015
        payOptions.Option5.strPayFor = 'AnnualFee';
        payOptions.Option5.PaymentType = 'AnnualFee';
        payOptions.Option5.Amount = productPricing( 'Annual' ,'Name', regLead.Are_you_from_Defence__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option5.Amount += payOptions.Option1.Amount;
        payOptions.Option5.LateFeeAmount = CheckLateFeeCategory(objLead.Lead_Lateral_Catogery__c);
        
        payOptions.Option6.strPayFor = 'MultipleSemFee';
        payOptions.Option6.PaymentType = 'MultipleSemFee';
        payOptions.Option6.Amount = productPricing( 'Multiple Semester' ,'Name', regLead.Are_you_from_Defence__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option6.Amount += payOptions.Option1.Amount;
        payOptions.Option6.LateFeeAmount = CheckLateFeeCategory(objLead.Lead_Lateral_Catogery__c);
        
        //Mayur e 3-Oct-2015
    }
    */
    /*
    //Added by Sanket 20-Jul-2015
    public void ConfigurePayOpt( Opportunity opportunity)
    {
        payOptions.Option1.strPayFor = 'registration';
        payOptions.Option1.Amount = productPricing('Registration Fee','Name', opportunity.Account.nm_DefencePersonnel__c, true);
        payOptions.Option1.PaymentType = 'LeadRegistration'; 
        
        payOptions.Option2.strPayFor = 'admission';
        payOptions.Option2.PaymentType = 'LeadRegistrationAdmission';
        payOptions.Option2.Amount = productPricing( opportunity.nm_Program__c ,'ID', opportunity.Account.nm_DefencePersonnel__c, false);
       
        if( payOptions.Option1.AlreadyPaid == false)
            payOptions.Option2.Amount += payOptions.Option1.Amount;
        payOptions.Option2.LateFeeAmount = CheckLateFeeCategory(opportunity.nm_Category__c);
       
        payOptions.Option3.strPayFor = 'fullFee';
        payOptions.Option3.PaymentType = 'LeadRegistrationFullFee';
        payOptions.Option3.Amount = productPricing( opportunity.nm_Program__c ,'ID', opportunity.Account.nm_DefencePersonnel__c, false);
        if(!payOptions.Option1.AlreadyPaid)
            payOptions.Option3.Amount += payOptions.Option1.Amount;
        payOptions.Option3.LateFeeAmount = CheckLateFeeCategory(opportunity.nm_Category__c);
        
        // mayur s 22/6/2015
        
        payOptions.Option4.strPayFor = 'PGAllSemFee';
        payOptions.Option4.PaymentType = 'PGAllSemFee';
        payOptions.Option4.Amount = productPricing( 'PG_All_Sem' ,'Name', opportunity.Account.nm_DefencePersonnel__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option4.Amount += payOptions.Option1.Amount;
        payOptions.Option4.LateFeeAmount = CheckLateFeeCategory(opportunity.nm_Category__c);
        
        // mayur e 22/6/0215
        
        //For Annual Fee 
        // mayur s 3-Oct-2015
        payOptions.Option5.strPayFor = 'AnnualFee';
        payOptions.Option5.PaymentType = 'AnnualFee';
        payOptions.Option5.Amount = productPricing( 'Annual' ,'Name', opportunity.Account.nm_DefencePersonnel__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option5.Amount += payOptions.Option1.Amount;
        payOptions.Option5.LateFeeAmount =CheckLateFeeCategory(opportunity.nm_Category__c);
        
        payOptions.Option6.strPayFor = 'MultipleSemFee';
        payOptions.Option6.PaymentType = 'MultipleSemFee';
        payOptions.Option6.Amount = productPricing( 'Multiple Semester' ,'Name', opportunity.Account.nm_DefencePersonnel__c, false);
        if(payOptions.Option1.AlreadyPaid == false)
            payOptions.Option6.Amount += payOptions.Option1.Amount;
        payOptions.Option6.LateFeeAmount = CheckLateFeeCategory(opportunity.nm_Category__c);
        
        // mayur e 3-Oct-2015
        
    }
    */
    /*-------- End Configring Payment Options -------------------*/
    
    
    /*---------------Make Payment------------------------*/
   /* public pageReference makePayment()
    {
         /*  date check=date.today();
     
      list<Calender__c> lstCal = new list<Calender__c>([select Session_End_Date__c, nm_Semester__c, Session_Start_Date__c,
                                                               Session__c, Year__c,nm_Type__c 
                                                                        from Calender__c 
                                                                            where Category__c='Admission'                                                                               
                                                                                and Session_Start_Date__c <=: check AND Session_End_Date__c >=:check ]); 
      */
                                                                       
        /* if((((objLead.LC_name__c != objLead.IC_Name__c) && opportunityId ==null) ||(opportunityId !=null)) )
           {
                if( strSelectedPayFor == payOptions.Option1.strPayFor )
                    return MakeOnlinePayment( payOptions.Option1 );
                else if ( strSelectedPayFor == payOptions.Option2.strPayFor )
                    return MakeOnlinePayment( payOptions.Option2 );
                else if ( strSelectedPayFor == payOptions.Option3.strPayFor )
                    return MakeOnlinePayment( payOptions.Option3 );
                  
                else if ( strSelectedPayFor == payOptions.Option4.strPayFor )  //mayur 22/6/2015
                    return MakeOnlinePayment( payOptions.Option4 ); 
                    
                else if ( strSelectedPayFor == payOptions.Option5.strPayFor )  //For Annual Fee - mayur 3-Oct-2015
                    return MakeOnlinePayment( payOptions.Option5 ); 
                    
                else if ( strSelectedPayFor == payOptions.Option6.strPayFor )  //For Annual Fee - mayur 3-Oct-2015
                    return MakeOnlinePayment( payOptions.Option6 );     
                  
                else return null;
           }
           else
           {
               strSecToShow ='PopUpError';
                 if(objLead.nm_InformationCenter__c!=null)
                 {
                   errMessages ='Hello student kindly cordinate with Learning center at'+' '+objLead.nm_InformationCenter__r.name+' '+objLead.nm_InformationCenter__r.Contact_No_1__c;
                   return null;
                 }
                 else
                 {
                      errMessages ='Hello student kindly cordinate with Learning center at'+' '+objOpportunity.IC__c+' '+objOpportunity.Account.nm_Centers__r.Contact_No_1__c;
                      return null;
                 }
                 return null; 
           }    
          
        
           
    }
    */
    /*--------------End Make Payment----------------------*/
    /*----------------Print form------------------------*/
   
    /* public pageReference Printform()
    {
        pageReference pg = new pageReference ('/apex/nmRegistartionform_New?&id='+strLeadId);
        
        pg.setRedirect(true);
        return pg;
     
    }*/
    
    
    /*--------------End Print form---------------------
    /*-----------------Online Payment---------------------*/
  /* public pageReference MakeOnlinePayment( Payment objPayOptions )
    {
        if( objPayOptions != null && objPayOptions.Amount != null && objPayOptions.Amount > 0 && objPayOptions.PaymentType != null && objPayOptions.PaymentType != '')
        {      
            //Creating payment tracking Id. 
            //string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
            string strTranTrackid = datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
                 +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.random() * 1000 );
            
                        
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
           
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.TranAmount = string.valueOf( objPayOptions.Amount +  objPayOptions.LateFeeAmount );
            objOnlinePayment.strPaymentType = objPayOptions.PaymentType;
            objOnlinePayment.strEmailId = objLead.Email;
            objOnlinePayment.strMobileNumber = objLead.MobilePhone;
            objOnlinePayment.strAddress = objLead.id;//This line should be deleted
            objOnlinePayment.recordId = objLead.id;
            objOnlinePayment.opportunityId = opportunityId;
            
            
            //string strPaymentResponse = objOnlinePayment.MakePayment();
            
            
            //Sanket 27-Jun Start
            String msg = objOnlinePayment.createtBillDeskRequest();
            String []splitMessage = msg.split('\\|');
            for(integer i =0;i<splitMessage.size();i++)
            {
                System.debug('Bill desk Response for Registration Payment->'+splitMessage[i]);
            
            } 
            // mayur start 29-Jul-2015
            //mayur 8-Oct2015 start
            //String payId = SavePaymentBeforeResponse(objPayOptions.PaymentType , strTranTrackid , msg);
            SavePaymentBeforeResponse(objPayOptions.PaymentType , strTranTrackid , msg);
            //System.debug('-----------payId----------'+payId);
            // mayur end 29-Jul-2015
            //mayur 8-Oct-2015 end
            
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('msg', msg);
            //pgURL.getParameters().put('type', 'BillDeskRequest');
            return pgURL;
            
            //Sanket 27-Jun End
           
            //Commented by Sanket Start
            /*system.debug('Sumit strPaymentResponse:::: '+strPaymentResponse);
            if(strPaymentResponse != null && strPaymentResponse != '' && strPaymentResponse.split(':').size() > 1)            
            {   
                String strPaymentId = strPaymentResponse.split(':https:')[0];
                String strPaymentUrl = 'https:'+strPaymentResponse.split(':https:')[1];
                
                system.debug(strPaymentUrl+'?PaymentID='+strPaymentId);
                PageReference pgURL = new PageReference(strPaymentUrl+'?PaymentID='+strPaymentId);
                pgURL.setRedirect(true);
                return pgURL;
            }
            else
            {
                return null;
            }  */
            
             //Commented by Sanket End            
       /* }
        else
        {
            errMessages = 'Unable to get payment details.';
            strSecToShow = 'error';
            return null;
        }
    }
    */
    /*--------------- End Online Payment ---------------------*/
    
    
    /*------------ Get Product Price --------------------*/
   /* public decimal productPricing( string strParam, string strParamType, string defenceFlag,boolean isRegistration)
    {
       isDefence = defenceFlagCheck(defenceFlag);
       system.debug('!!!!isDefence!!!!!!!!'+isDefence);
       decimal intRegAmmount = 0;
      String priceBookName ='NMIMS Price Book New';
        if( strParam != null && strParamType != null )
        {
             string Query  = 'select id, UnitPrice, product2.Name';
                    Query += '  from PriceBookEntry ';
                    Query += '  where Pricebook2.IsStandard = false  ';
                    Query += '  and product2.isActive = true ';
                    Query += '  and UnitPrice != null ';
                    Query += '  and isActive = true';
                    Query += '  and PriceBookName__c=\''+priceBookName +'\'';
                   
                  /*  Query += '  and Pricebook2.nmSession_Start_Date__c <=: Today  ';  //newly added -By Vikas For New Price Book //
                    Query += '  and Pricebook2.nmSession_End_Date__c >=: Today  ';  */ //newly added-By Vikas For New Price Book // 
          /*   if( strParamType == 'ID' ){
                    Query += '  and product2.nm_Program__c =\''+ strParam + '\'';
             }
             else{
                    Query += '  and product2.Name =\''+ strParam + '\'  ';
             }      
                    //Query += '  and Pricebook2.nmSession_Start_Date__c !=null ';
                    //Query += '  and Pricebook2.nmSession_End_Date__c !=null ';
                    //Query += '  and Pricebook2.nmSession_Start_Date__c <=: Today  ';
                    //Query += '  and Pricebook2.nmSession_End_Date__c >=: Today  ';
                    //Query += '  and Pricebook2.IsActive=true limit 1 ';
                                     
            
            List<PriceBookEntry> lstPriceBookEntry = (list<PriceBookEntry>)Database.query(Query);
            
            system.debug('Sumit Query = '+ Query);
            system.debug('Sumit lstPriceBookEntry = '+ lstPriceBookEntry);
            
            
            if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0)                                                    
            {
                system.debug('!!!!defenceFlag!!!!'+defenceFlag);
                system.debug('!!!!isRegistration!!!!'+isRegistration);
                
                if(isRegistration == true) //mayur 8/7/2015
                {
                    intRegAmmount = lstPriceBookEntry[0].UnitPrice;
                }
                else if(isDefence == true)//Conditions rearranged by Sanket 18/07/2015
                {
                    //Commented and Changed by Sanket to give discount of flat 3400 instead of 20% for defense 23-Oct-2015
                    
                 intRegAmmount = (lstPriceBookEntry[0].UnitPrice)*0.8;
                    //intRegAmmount = (lstPriceBookEntry[0].UnitPrice) - 3400;
                    
                }   
                else
                {
                    intRegAmmount = lstPriceBookEntry[0].UnitPrice;
                }
            }
            else
            {
                errMessages = 'Product Price not found.';
                strSecToShow = 'error';
            }
        }
        return intRegAmmount.setScale(2);
    }*/
    /*----------End Get Product Price -------------------*/
   /* public boolean defenceFlagCheck(string defenceFlag)   //mayur 8/7/2015
    {  
        system.debug('!!!!defenceFlag insider method!!!!!!!!'+defenceFlag);
        if(defenceFlag == 'Yes')
        {
        return true;
        }
        else
        {
        return false;
        }
    }*/
    /*---------- Get late fee details -------------------*/
    /*public decimal lateFee ( string strCategory )
    {
        if( strCategory != null )
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and Start_Date__c <= : Today
                                                and End_Date__c >= : Today ];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                    return lstlateFee[0].Late_Fees__c; 
            }
        }    
        return 0;
    }
    */
    /*---------- End Get late fee details -------------------*/
    
    //mayur 8-Oct2015 start
    // mayur start 29-Jul-2015
    /*-------------- Creating Payment Records before Payment --------------*/
    /*public void SavePaymentBeforeResponse(String strPaymentType , String strTranTrackid , String msg)
    {
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        
        
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';
        objPayment.nm_Lead__c = objLead.id;
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c = Date.today();
        objPayment.nm_Merchant_Track_Id__c = strTranTrackid;
        objPayment.Gateway_Detailed_Request__c = msg;//Added by Sanket 13-OCt-2015
     
        //------- Initializing payment object with common values ---------//
        
        
        //------------- Checking Payment type and creting records -------------------//
      
            if( strPaymentType == payOptions.Option1.PaymentType )
            {
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option1, 'Registration', payOptions.Option1.Amount  ) );
            }
            else if( strPaymentType == payOptions.Option2.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option2, 'Registration', payOptions.Option1.Amount  ) );
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount - payOptions.Option1.Amount  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount));
                }
                
                if(payOptions.Option2.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option2, 'Late Fees', payOptions.Option2.LateFeeAmount ) );
            }
            else if(strPaymentType == payOptions.Option3.PaymentType)
            {
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option3, 'Registration', payOptions.Option1.Amount  ) );
                
                for( integer i = 0; i < intTotalSem; i++ )
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option3, 'Admission', payOptions.Option2.Amount - payOptions.Option1.Amount  ) );
                
                if( payOptions.Option2.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option3, 'Late Fees', payOptions.Option2.LateFeeAmount ) );
            }
            // mayur s 22/6/2015
            
            else if( strPaymentType == payOptions.Option4.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option4, 'Registration', payOptions.Option1.Amount  ) );
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount - payOptions.Option1.Amount  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount));
                }
                
                if(payOptions.Option4.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option4, 'Late Fees', payOptions.Option4.LateFeeAmount ) );
            }
            
            // mayur e 22/6/2015
            
            // For Annual Fee
            // Mayur s 3-Oct-2015            
            else if( strPaymentType == payOptions.Option5.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option5, 'Registration', payOptions.Option1.Amount  ) );
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount - payOptions.Option1.Amount  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount));
                }
                
                if(payOptions.Option5.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option5, 'Late Fees', payOptions.Option5.LateFeeAmount ) );
            }
            
            // For Multiple Sem Fee
                       
            else if( strPaymentType == payOptions.Option6.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option1, 'Registration', payOptions.Option1.Amount  ) );
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount - payOptions.Option1.Amount  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount));
                }
                
                if(payOptions.Option5.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, payOptions.Option6, 'Late Fees', payOptions.Option6.LateFeeAmount ) );
            }
            
            // Mayur e 3-Oct-2015
       
        //----------- End Checking Payment type and creating records -----------------//
        
        try
        {
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                insert lstPaymentToInsert;
            }
            //UpdateLeadBeforePayment(lstPaymentToInsert[0].nm_Lead__c);
            //return lstPaymentToInsert[0].id ;
        }
        catch(Exception e)
        {
            system.debug('------string.valueof(e)--------'+string.valueof(e));
            //return 'Failed to insert data in system :: Sumit ::' + string.valueof(e); 
        }
    }
    // mayur end 29-Jul-2015  
    //mayur 8-Oct-2015 end  

    /*-------------- Creating Payment Records after Payment --------------*/
  /*  public string MakePaymentAfterResponse
    (
        string strResTranId, 
        string strPaymentTrackId,
        String strPaymentId, 
        String strResResult, 
        String strErrorText,
        String strErrorCode,
        String strPaymentType,
        String detailedGatewayResponse//Added by Sanket 13-Oct-2015
    )
    {
        //mayur 8-Oct-2015 start
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
        
        system.debug('-----------strPaymentTrackId------------'+strPaymentTrackId);
        
        lstPaymentToUpdate = [Select Id, nm_PaymentStatus__c, nm_Lead__c, nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: strPaymentTrackId];
        
        system.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
        for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate)
        {
            objpay.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
            objpay.nm_TransactionID__c = strResTranId;
            objpay.Online_Payment_Id__c = strPaymentId;
            objpay.nm_PaymentGatewayResponse__c = strResResult;
            objpay.Online_Response_Error__c = strErrorText;
            objpay.nm_Error_Code__c=strErrorCode;
            objpay.Gateway_Detailed_Response__c = detailedGatewayResponse;//Added by Sanket 13-Oct-2015
        }
        
        if(lstPaymentToUpdate.size() > 0 )
        {
            update lstPaymentToUpdate;
        }
        /*
        if(strResResult.toUpperCase() == 'CAPTURED'){
            
            if(lstPaymentToUpdate.size() > 0 )
            {
                UpdateLead(lstPaymentToUpdate[0].nm_Lead__c);
            }
            
        }
        */
        
        //commented by mayur 10-Oct-2015 - start
        /*
        if( lstPaymentToUpdate.size() > 0 )
        {
            return lstPaymentToUpdate[0].id;
            
        } else {
         
            return null;
         
        }
        */
        //commented by mayur 10-Oct-2015 - end
        //mayur 8-Oct-2015 end
        
       /* list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
        
        //------- Initializing payment object with common values ---------//
        nm_Payment__c objPayment = new nm_Payment__c();
        objPayment.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
        objPayment.nm_Lead__c = objLead.id;
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c = Date.today();
        objPayment.nm_TransactionID__c = strResTranId;
       // objPayment.nm_PaymentGatewayName__c =lstPaymentToUpdate[0].nm_PaymentGatewayName__c ;
        objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
        objPayment.Online_Payment_Id__c = strPaymentId;
        objPayment.nm_PaymentGatewayResponse__c = strResResult;
        objPayment.Online_Response_Error__c = strErrorText;
        objPayment.nm_Error_Code__c=strErrorCode;
        //------- Initializing payment object with common values ---------//
        
        
        //------------- Checking Payment type and creting records -------------------//
      
            if( strPaymentType == payOptions.Option1.PaymentType )
            {
                lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option1, 'Registration', payOptions.Option1.Amount, payOptions.Option1.strPayFor  ) );
            }
            else if( strPaymentType == payOptions.Option2.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option2, 'Registration', payOptions.Option1.Amount, payOptions.Option2.strPayFor  ) );
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount - payOptions.Option1.Amount, payOptions.Option2.strPayFor  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount, payOptions.Option2.strPayFor));
                }
                
                if(payOptions.Option2.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option2, 'Late Fees', payOptions.Option2.LateFeeAmount, payOptions.Option2.strPayFor ) );
            }
            else if(strPaymentType == payOptions.Option3.PaymentType)
            {
                lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option3, 'Registration', payOptions.Option1.Amount, payOptions.Option2.strPayFor  ) );
                
                for( integer i = 0; i < intTotalSem; i++ )
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option3, 'Admission', payOptions.Option2.Amount - payOptions.Option1.Amount, payOptions.Option2.strPayFor  ) );
                
                if( payOptions.Option2.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option3, 'Late Fees', payOptions.Option2.LateFeeAmount, payOptions.Option2.strPayFor ) );
            }
            // mayur s 22/6/2015
            
            else if( strPaymentType == payOptions.Option4.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option4, 'Registration', payOptions.Option1.Amount, payOptions.Option4.strPayFor  ) );
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount - payOptions.Option1.Amount, payOptions.Option4.strPayFor  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount, payOptions.Option4.strPayFor));
                }
                
                if(payOptions.Option4.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option4, 'Late Fees', payOptions.Option4.LateFeeAmount, payOptions.Option4.strPayFor ) );
            }
            
               // For Multiple Sem Fee
                       
             else if( strPaymentType == payOptions.Option6.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option6, 'Registration', payOptions.Option1.Amount, payOptions.Option6.strPayFor  ) );
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount - payOptions.Option1.Amount,  payOptions.Option6.strPayFor  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount,  payOptions.Option6.strPayFor));
                }
                
                if(payOptions.Option4.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option6, 'Late Fees', payOptions.Option6.LateFeeAmount,  payOptions.Option6.strPayFor ) );
            } 
            // mayur e 22/6/2015

            //For Annual Fee
            // Mayur s 3-Oct-2015
            else if( strPaymentType == payOptions.Option5.PaymentType )
            {
                if(!payOptions.Option1.AlreadyPaid) 
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option5, 'Registration', payOptions.Option1.Amount, payOptions.Option5.strPayFor  ) );
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount - payOptions.Option1.Amount,  payOptions.Option5.strPayFor  ) );
                }
                else
                {
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount,  payOptions.Option5.strPayFor));
                }
                
                if(payOptions.Option4.LateFeeAmount > 0)
                    lstPaymentToInsert.add( CreateRegRecord( objPayment, payOptions.Option5, 'Late Fees', payOptions.Option5.LateFeeAmount,  payOptions.Option5.strPayFor ) );
            } 
            
            // Mayur e 3-Oct-2015           
       
        //----------- End Checking Payment type and creting records -----------------//
        
        String firstPaymentRecordId = '';
        try
        {
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                //Added by Sanket to avoid multiple payment records being created for same merchant ID, for Browser back button press 
                firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
                //Commented by Sanket 25-Jul
                //insert lstPaymentToInsert;
            }
            //added bu chandu after paying Registration or Admission with Late fees updating Lead with status is Payment paid.
            if(strResResult.toUpperCase() == 'CAPTURED'){
                UpdateLead(lstPaymentToInsert[0].nm_Lead__c);
            }
            else
            {
                Lead lead = [Select Id, nm_Fee_Type__c from Lead where Id = : strLeadId];
                lead.nm_Fee_Type__c ='';
                update lead;
            }
            //Commented by Sanket 25-Jul-2015
            //return lstPaymentToInsert[0].id ;
            return firstPaymentRecordId;
        }
        catch(Exception e)
        {
            return 'Failed to insert data in system :: Sumit ::' + string.valueof(e); 
        }
     
    }
    
    public String upsertPaymentRecordsBasedOnMerchantNumber(list<nm_Payment__c> lstPaymentToInsert){
        
        list<nm_Payment__c> insertList = new List<nm_Payment__c>();
        list<nm_Payment__c> updateList = new List<nm_Payment__c>();
        String firstPaymentRecordId = '';
        
        Set<String> merchantRefNumberIds = new Set<String>();
        for(nm_Payment__c payment : lstPaymentToInsert){
            merchantRefNumberIds.add(payment.nm_Merchant_Track_Id__c);
        }
        
        Map<String, Id> merchantIdRecordIdMap = new Map<String, ID>();
        list<nm_Payment__c> existingPayments = [Select id, nm_Merchant_Track_Id__c, nm_TransactionID__c from nm_Payment__c where nm_Merchant_Track_Id__c in :merchantRefNumberIds];
        if(existingPayments != null ){
            for(nm_Payment__c payment : existingPayments){
                merchantIdRecordIdMap.put(payment.nm_Merchant_Track_Id__c + payment.nm_TransactionID__c, payment.ID);
            }
        }
        
        for(nm_Payment__c payment : lstPaymentToInsert){
            String key = payment.nm_Merchant_Track_Id__c + payment.nm_TransactionID__c;
            if(merchantIdRecordIdMap.containsKey(key)){
                //Payment Record already exists with given Merchant Track Id and Gateway Transaction ID 
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
            firstPaymentRecordId = insertList[0].Id;
        }
        
        if(updateList.size() > 0 ){
            System.debug('Updating existing Payment record');
            update updateList;
            firstPaymentRecordId = updateList[0].Id;
        }
        
        return firstPaymentRecordId;
    }
    
    public nm_Payment__c CreateRegRecord( nm_Payment__c objPayment, Payment Option, String PaymentType, decimal Amount, String feesType )
    {
        nm_Payment__c objPay =  new nm_Payment__c();
        objPay = objPayment.clone();
        if( objPay != null && Option != null && PaymentType != null && PaymentType != '' && Amount != null && Amount > 0 )
        {
            objPay.nm_PaymentType__c = PaymentType;
            objPay.nm_ActualPaymentAmmount__c = Option.Amount + Option.LateFeeAmount;
            objPay.nm_Amount__c = Amount;
        }
        if(PaymentType == 'Admission'){
            objPay.nm_Fee_Type__c = Option.PaymentType;
        }
        
        System.debug('!!! opportunityId = '+opportunityId);
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
            //Added by Sanket 10-Oct-2015
            setOpportunityFeesType(opportunityId, feesType);
        }
        else
        {
                objPay.nm_Lead__c = strLeadId;
                setLeadFeesType(strLeadId, feesType);
        } 
        return objPay;
    }
    
    /*------------ End Creating Payment Records after Payment ------------*/
    
    //mayur 8-Oct-2015 start
    
   /* public nm_Payment_Initiated__c CreatePaymentInitiatedRecord( nm_Payment_Initiated__c objPayment, Payment Option, String PaymentType, decimal Amount )
    {
        nm_Payment_Initiated__c objPay =  new nm_Payment_Initiated__c();
        objPay = objPayment.clone();
        if( objPay != null && Option != null && PaymentType != null && PaymentType != '' && Amount != null && Amount > 0 )
        {
            objPay.nm_PaymentType__c = PaymentType;
            objPay.nm_ActualPaymentAmmount__c = Option.Amount + Option.LateFeeAmount;
            objPay.nm_Amount__c = Amount;
        }
        if(PaymentType == 'Admission'){
            objPay.nm_Fee_Type__c = Option.PaymentType;
        }
        
        System.debug('!!! opportunityId = '+opportunityId);
        if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
            objPay.nm_OpportunityNew__c = ID.valueOf(opportunityId);
            //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
            objPay.nm_Lead__c = null;
        }
        
        return objPay;
    }
    
    //mayur 8-Oct-2015 end
    
    /*------------- Payment Option Wrapper ------------------*/
    /*
    public class Payment
    {
        public string strPayFor { get; set; }
        public decimal Amount { get; set; }
        public decimal LateFeeAmount  { get; set; }
        public string PaymentType { get; set; }
        public boolean AlreadyPaid { get; set; } 
        
        public Payment()
        {
            strPayFor = '';
            Amount = 0;
            LateFeeAmount = 0;
            PaymentType ='';
            AlreadyPaid = false;
        }
    }
    /*-----------End Payment Option Wrapper -----------------*/
   /*
    public void UpdateLead(String Leadid)
    {
        Lead objLead=[select id,nm_PaymentStatus__c,Status,nm_Fee_Type__c  from Lead where id=:Leadid];
       if(objLead!=null)
        {  
          if(objLead.nm_Fee_Type__c =='registration')
            {
            objLead.nm_PaymentStatus__c='Payment made';
            objLead.Status='Registration Fee Paid';
            update objLead;
            }
           else if(objLead.nm_Fee_Type__c =='admission' || objLead.nm_Fee_Type__c =='PGAllSemFee' || objLead.nm_Fee_Type__c =='AnnualFee')
            {
                objLead.nm_PaymentStatus__c='Payment made';
                objLead.Status='Admission Fee Paid';
                update objLead;
             }   
        }
    }
    
    // mayur start 29-Jul-2015
    public void UpdateLeadBeforePayment(String Leadid)
    {
        Lead objLead=[select id,nm_PaymentStatus__c,Status from Lead where id=:Leadid];
        if(objLead !=null)
        {
            objLead.nm_PaymentStatus__c='Payment Initiated';
            objLead.Status='Registration Form Filled';
            update objLead;
        }
    }
    // mayur end 29-Jul-2015
   
    //mayur s 18/7/2015
    public pageReference  SaveDD()
    {
       if((((objLead.LC_name__c != objLead.IC_Name__c) && opportunityId ==null) ||(opportunityId !=null)) )
       {
            list<nm_Payment__c> lstPaymentToInsert=new list<nm_Payment__c>();
            System.debug('!!Payment Mode = '+objPayment.nm_ModeOfPayment__c);
            if(strLeadId != Null)
            {        
               
                if(objPayment.nm_ModeOfPayment__c == 'Demand Draft')
                {         
                
                    if(objPayment.nm_DemandDraftNumber__c != null && objPayment.nm_DemandDraftDate__c != null && objPayment.nm_NameoftheBank__c != null && objPayment.nm_BankLocation__c != null && objPayment.nm_DispatchDate__c != null)
                    {
                        try
                        {
                            system.debug('!!!!!strSelectedPayFor!!!!!'+strSelectedPayFor);
                            system.debug('!!!!!lateFee Admission !!!!!'+ lateFee('Admission'));
                            System.debug('Enter in strSelectedPayFor  loop------>'+strSelectedPayFor);
                            if( strSelectedPayFor == 'Registration' )
                            {
                                lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option1, 'Registration', payOptions.Option1.Amount, strSelectedPayFor  ) );
                            }
                            else if( strSelectedPayFor == 'Admission' )
                            {
                                if(!payOptions.Option1.AlreadyPaid) 
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option2, 'Registration', payOptions.Option1.Amount, strSelectedPayFor  ) );
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount - payOptions.Option1.Amount, strSelectedPayFor  ) );
                                }
                                else
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option2, 'Admission', payOptions.Option2.Amount, strSelectedPayFor));
                                }
                                
                                if(payOptions.Option2.LateFeeAmount > 0)
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option2, 'Late Fees', payOptions.Option2.LateFeeAmount, strSelectedPayFor ) );
                            }
    
                            else if( strSelectedPayFor == 'PGAllSemFee' )
                            {
                                if(!payOptions.Option1.AlreadyPaid) 
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option4, 'Registration', payOptions.Option1.Amount, strSelectedPayFor  ) );
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount - payOptions.Option1.Amount, strSelectedPayFor  ) );
                                }
                                else
                                {
                                    System.debug('Entered else block for PGALLSEMFEE');
                                    System.debug('String Val Sent--->'+strSelectedPayFor);
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option4, 'Admission', payOptions.Option4.Amount, strSelectedPayFor));
                                }
                                
                                if(payOptions.Option4.LateFeeAmount > 0)
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option4, 'Late Fees', payOptions.Option4.LateFeeAmount, strSelectedPayFor ) );
                            }
                           
                            else if( strSelectedPayFor == 'MultipleSemFee' )
                            {
                                 
                                if(!payOptions.Option1.AlreadyPaid) 
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option6, 'Registration', payOptions.Option1.Amount, strSelectedPayFor  ) );
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount - payOptions.Option1.Amount, strSelectedPayFor  ) );
                                }
                                else
                                {
                                    System.debug('Entered else block for MultipleSemFee');
                                    System.debug('String Val Sent--->'+strSelectedPayFor);
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option6, 'Admission', payOptions.Option6.Amount, strSelectedPayFor));
                                }
                                
                                if(payOptions.Option4.LateFeeAmount > 0)
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option6, 'Late Fees', payOptions.Option6.LateFeeAmount, strSelectedPayFor ) );
                            }

                            
                            //For Annual Fee
                            // Mayur s 3-Oct-2015
                            
                            else if( strSelectedPayFor == 'AnnualFee' )
                            {
                                if(!payOptions.Option1.AlreadyPaid) 
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option5, 'Registration', payOptions.Option1.Amount, strSelectedPayFor  ) );
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount - payOptions.Option1.Amount, strSelectedPayFor  ) );
                                }
                                else
                                {
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option5, 'Admission', payOptions.Option5.Amount, strSelectedPayFor));
                                }
                                
                                if(payOptions.Option5.LateFeeAmount > 0)
                                    lstPaymentToInsert.add( CreateDDRecord( objPayment, payOptions.Option5, 'Late Fees', payOptions.Option5.LateFeeAmount, strSelectedPayFor ) );
                            }
                            
                            //Mayur e 3-Oct-2015
                            
                            system.debug('!!!!!lstPaymentToInsert.size()!!!!!'+lstPaymentToInsert.size());
                            if(lstPaymentToInsert.size()>0)
                            {
                                insert lstPaymentToInsert;
                                if(opportunityId == null || opportunityId == ''){
                                    UpdateLead(lstPaymentToInsert[0].nm_Lead__c);
                                }
                            }
                            
                            //Sanket: This needs to come from Custom Settings, and not hard coded
                           // url = Label.Site_Url+ '/nmRegistrationThankYou?id=' + lstPaymentToInsert[0].id;
                            //return url;
                            
                            return new pageReference(Label.Site_Url+ 'nmRegistrationThankYou?id=' + lstPaymentToInsert[0].id);
                            
                            
                        }
                        catch(exception e)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,' ' + e));
                            System.debug('Error registration Payment--->'+e);
                            return new pageReference(Label.Site_Url+ 'nmRegistrationPayment?id='+strLeadId +'&IC=true');
                        }
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill all the DD details to proceed'));
                        return null;
                    }
                }
            }
            return Null;
         }
         else
         {
             strSecToShow ='PopUpError';
             if(objLead.nm_InformationCenter__c!=null)
             {
               errMessages ='Hello student kindly cordinate with Learning center at'+' '+objLead.nm_InformationCenter__r.name+' '+objLead.nm_InformationCenter__r.Contact_No_1__c;
               return null;
             }
             else
             {
                  errMessages ='Hello student kindly cordinate with Learning center at'+' '+objOpportunity.IC__c+' '+objOpportunity.Account.nm_Centers__r.Contact_No_1__c;
                  return null;
             } 
             return null; 
         }   
    } 
    
    public nm_Payment__c CreateDDRecord( nm_Payment__c objPayment, Payment Option, String PaymentType, decimal Amount , String feesType)
    {
        nm_Payment__c objPay =  new nm_Payment__c();
        System.debug('strSecToShow---->'+strSecToShow);
        objPay = objPayment.clone();
        if( objPay != null && Option != null && PaymentType != null && PaymentType != '' && Amount != null && Amount > 0 )
        {
            objPay.nm_PaymentType__c = PaymentType;
            objPay.nm_ActualPaymentAmmount__c = Option.Amount + Option.LateFeeAmount;
            objPay.nm_Amount__c = Amount;
            objPay.nm_PaymentStatus__c ='Payment Made';
            if(opportunityId != null && opportunityId != '' && opportunityId != 'NA'){
                objPay.nm_OpportunityNew__c = ID.valueOf(opportunityId);
                //Do not set Lead if Opportunity exists. Link payment with Opportunity instead of Lead
                objPay.nm_Lead__c = null;
                //Added by Sanket 10-Oct-2015
                setOpportunityFeesType(opportunityId, feesType);
            }else{
                objPay.nm_Lead__c = strLeadId;
                setLeadFeesType(strLeadId, feesType);
            }
        }
        if(PaymentType == 'Admission'){
            objPay.nm_Fee_Type__c = Option.PaymentType;

        }
        
        return objPay;
    }
    //mayur e 18/7/2015//
    
    public void setOpportunityFeesType(String opportunityId, String feesType){
        Opportunity opportunity = [Select Id, nm_Fee_Type__c from Opportunity where Id = : opportunityId];
        opportunity.nm_Fee_Type__c = feesType;
        update opportunity;
    }
    
    public void setLeadFeesType(String leadId, String feesType){
        Lead lead = [Select Id, nm_Fee_Type__c from Lead where Id = : leadId];
        lead.nm_Fee_Type__c = feesType;
        update lead;
    }
    
    public decimal CheckLateFeeCategory(String Category)
    {
       decimal LateFeeAmt=0.0;
       if(Category =='Lateral Admission')
       {
          LateFeeAmt = lateFee('Is Lateral');
       }
       else
       {
           LateFeeAmt = lateFee('Admission');
       }
       return LateFeeAmt;
    }
}
*/
}