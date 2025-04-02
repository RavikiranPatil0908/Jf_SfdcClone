public without sharing class nmLateFees {
    public static String strPaymnetid;
    public nm_Payment__c objPayment { get; set; }
    public Decimal LateFees{get;set;}
    public String strPhone;
    public String AccountidOppid;
    public String strEnail;
    public String strModeOfPaymnet{get;set;}
    public string errMessages { get; set; }
    public string strSecToShow { get; set; }
    public String strInformationAddress{get;set;}
    public String strPaymnetid2{get;set;}
    public String StudentProgramId;
    public string icValue{ get; set; }
    public nmLateFees(){
    LateFees=0.0;
    
    strPaymnetid = ApexPages.currentPage().getParameters().get('id');
    icValue = ApexPages.currentPage().getParameters().get('IC');
    system.debug('strPaymnetid'+strPaymnetid);
    if(strPaymnetid !=null && strPaymnetid !=''){
        list<nm_Payment__c> lstPaymnet=[select nm_Amount__c,nm_OpportunityNew__r.nm_StudentProgram__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Account.PersonMobilePhone,nm_OpportunityNew__r.Account.PersonEmail from nm_Payment__c where nm_PaymentStatus__c='pending late fees' and nm_OpportunityNew__r.Accountid=:strPaymnetid];
        if(lstPaymnet.size()>0)
        {
            for(nm_Payment__c objPaymnet:lstPaymnet)
            {
                LateFees+=objPaymnet.nm_Amount__c;
            }
            if(lstPaymnet[0].nm_OpportunityNew__c !=null)
            {
                AccountidOppid=lstPaymnet[0].nm_OpportunityNew__c;
               
                if(lstPaymnet[0].nm_OpportunityNew__r.Account.PersonMobilePhone!=null)
                {
                    strPhone=lstPaymnet[0].nm_OpportunityNew__r.Account.PersonMobilePhone;
                }
                if(lstPaymnet[0].nm_OpportunityNew__r.Account.PersonEmail !=null)
                {
                    strEnail=lstPaymnet[0].nm_OpportunityNew__r.Account.PersonEmail;
                }
                if(lstPaymnet[0].nm_OpportunityNew__r.nm_StudentProgram__c !=null )
                {
                    StudentProgramId=lstPaymnet[0].nm_OpportunityNew__r.nm_StudentProgram__c;
                }
                strInformationAddress=lstPaymnet[0].nm_OpportunityNew__r.Account.nm_Centers__r.Name+'-'+lstPaymnet[0].nm_OpportunityNew__r.Account.nm_Centers__r.Address__c;
            }
        }
    }
    
  }
  public pageReference MakeOnlinePayment()
    {
        if( LateFees != null && LateFees > 0.0 && strEnail != null && strPhone != '')
        {      
            //Creating payment tracking Id. 
            //string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
            
            string strTranTrackid = datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
                 +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.random() * 1000 );       
                        
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.TranAmount = string.valueOf(LateFees);
            objOnlinePayment.strPaymentType ='Latefees';
            objOnlinePayment.strEmailId =strEnail;
            objOnlinePayment.strMobileNumber =strPhone ;
            objOnlinePayment.strAddress =AccountidOppid;//This line should be commented
            objOnlinePayment.recordId = AccountidOppid;
            
            //Commented by Sanket Start
            //string strPaymentResponse = objOnlinePayment.MakePayment();
            //Commented by Sanket End 
            
             //Sanket 27-Jun Start
            String msg = objOnlinePayment.createtBillDeskRequest();
            
                        
            //mayur 8-Oct2015 start
            //String payId = SaveLateFessPaymentBeforeResponse(AccountidOppid , strTranTrackid , msg);
            //System.debug('-----------payId----------'+payId);
            SaveLateFessPaymentBeforeResponse(AccountidOppid , strTranTrackid , msg);
            //mayur 8-Oct2015 end
            
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('msg', msg);
            return pgURL;
            //Sanket 27-Jun End
            
            //Commented by Sanket Start
            /*
            system.debug('Sumit strPaymentResponse:::: '+strPaymentResponse);
            if(strPaymentResponse != null && strPaymentResponse != '' && strPaymentResponse.split(':').size() > 1)            
            {   
                String strPaymentId = strPaymentResponse.split(':https:')[0];
                String strPaymentUrl = 'https:'+strPaymentResponse.split(':https:')[1];
                
                system.debug(strPaymentUrl+'?PaymentID='+strPaymentId);
                //UpdatePaymnet(strTranTrackid,strModeOfPaymnet,LateFees);
                PageReference pgURL = new PageReference(strPaymentUrl+'?PaymentID='+strPaymentId);
                pgURL.setRedirect(true);
                return pgURL;
            }
            else
            {
                return null;
            }   
            */
            //Commented by Sanket End                         
        }
        else
        {
            errMessages = 'Unable to get payment details.';
            strSecToShow = 'error';
            return null;
        }
    }
   
     public Void SaveLateFessPaymentBeforeResponse(String AccountidOppid , String strTranTrackid , String msg)
    {
            //------- Initializing payment object with common values ---------//
            /*
            Opportunity objOpportunity=[select id,(select id from Opportunities__r where nm_Amount__c=:strPayAmount and nm_PaymentStatus__c='pending late fees')from Opportunity where Accountid=:LatefeePaymentid];
            if(objOpportunity !=null && objOpportunity !='')
            {
                for()
            }*/
            //if(LatefeePaymentid !=null){
                list<nm_Payment_Initiated__c> lstPaymnetToUpdate=new List<nm_Payment_Initiated__c>();
                set<id> strPaymnetids=new set<id>();
                //String strid=LatefeePaymentid;
                
                nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
                objPayment.nm_PaymentStatus__c = 'Payment Initiated';
                objPayment.nm_ModeOfPayment__c = 'Online';
                objPayment.nm_TransactionDate__c = Date.today();
                objPayment.nm_Merchant_Track_Id__c = strTranTrackid;
                objPayment.nm_PaymentType__c = 'Late fees';
                objPayment.nm_OpportunityNew__c=AccountidOppid;
                objPayment.Gateway_Detailed_Request__c = msg;//Added by Sanket 13-OCt-2015
                insert  objPayment;
                
                //Added by Sanket to ensure Opportunity stage is updated to Payment made, when Late Fees is received.
                //Opportunity obbjUpdate=new Opportunity(id=objPayment.nm_OpportunityNew__c);
                //obbjUpdate.StageName='Payment Made';
                //update obbjUpdate;
                        
                //list<nm_Payment_Initiated__c> lstPaymnet=[select nm_Amount__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Account.Phone,nm_OpportunityNew__r.Account.PersonEmail from nm_Payment_Initiated__c where nm_OpportunityNew__c=:strid and nm_PaymentStatus__c='pending late fees'];
                  //delete lstPaymnet;
                
              //  }
           
            //return strTranTrackid;
    }
   

  
     public String MakeLateFessPaymentAfterResponse
    (
        string strResTranId, 
        string strPaymentTrackId,
        String strPaymentId, 
        String strResResult, 
        String strErrorText,
        String strErrorCode,
        String strPaymentType,
        String strPayAmount,
        String LatefeePaymentid,
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
    if( lstPaymentToUpdate.size() > 0 )
    {
        return lstPaymentToUpdate[0].id;
    } 
    else
    {
        return null;         
    }
    */
    //mayur 8-Oct-2015 end
        
            //------- Initializing payment object with common values ---------//
            /*
            Opportunity objOpportunity=[select id,(select id from Opportunities__r where nm_Amount__c=:strPayAmount and nm_PaymentStatus__c='pending late fees')from Opportunity where Accountid=:LatefeePaymentid];
            if(objOpportunity !=null && objOpportunity !='')
            {
                for()
            }*/
            if(LatefeePaymentid !=null){
                list<nm_Payment__c> lstPaymnetToUpdate=new List<nm_Payment__c>();
                set<id> strPaymnetids=new set<id>();
                String strid=LatefeePaymentid;
                
                nm_Payment__c objPayment = new nm_Payment__c();
                objPayment.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
                objPayment.nm_ModeOfPayment__c = 'Online';
                objPayment.nm_TransactionDate__c = Date.today();
                objPayment.nm_TransactionID__c = strResTranId;
                objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
                objPayment.Online_Payment_Id__c = strPaymentId;
                objPayment.nm_PaymentGatewayResponse__c = strResResult;
                objPayment.Online_Response_Error__c = strErrorText;
                objPayment.nm_Error_Code__c=strErrorCode;
                objPayment.nm_ActualPaymentAmmount__c = decimal.valueof( strPayAmount );
                objPayment.nm_Amount__c=decimal.valueof( strPayAmount );
                objPayment.nm_PaymentType__c = 'Late fees';
                objPayment.nm_OpportunityNew__c=strid;
                insert  objPayment;
              /*  
                if(objPayment.nm_PaymentType__c =='Late fees' && objPayment.nm_PaymentStatus__c =='Transaction Failed')
                {
                  objPayment.nm_ModeOfPayment__c = 'Online';
                  objPayment.nm_Amount__c=decimal.valueof( strPayAmount );
                  objPayment.nm_PaymentStatus__c ='Pending Late Fees';
                  objPayment.nm_OpportunityNew__c=strid;
                  insert  objPayment;
                  
                                    
                }
                */
                //Added by Sanket to ensure Opportunity stage is updated to Payment made, when Late Fees is received.
                Opportunity obbjUpdate=new Opportunity(id=objPayment.nm_OpportunityNew__c);
                 
              if(objPayment.nm_PaymentStatus__c =='Payment Made')
             {
                obbjUpdate.StageName='Payment Made';
                                      
            }
             else
           {
              obbjUpdate.StageName='Pending Payment';

           }

            update obbjUpdate;
            if(objPayment.nm_PaymentType__c =='Late fees' && objPayment.nm_PaymentStatus__c =='Payment Made')
                {

               list<nm_Payment__c> lstPaymnet=[select nm_Amount__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.Account.nm_Centers__r.Address__c,nm_OpportunityNew__c,nm_OpportunityNew__r.Account.PersonMobilePhone,nm_OpportunityNew__r.Account.PersonEmail from nm_Payment__c where nm_OpportunityNew__c=:strid and nm_PaymentStatus__c='pending late fees'];
                  delete lstPaymnet;
                  
                }
           }
            return null;
    }
   
}