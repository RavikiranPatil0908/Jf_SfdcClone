public without sharing class nmRegistrationPaymentByIc
{ 
    public nm_Payment__c objPayment {get;set;}
    
    public Id leadId {get;set;}
    public String strLeadEmail {get;set;}
    public String strLeadPhone {get;set;}
    public decimal RegAmmount {get;set;}
    public decimal AdmAmmount {get;set;}
    public string strInforamtion {get;set;}
    public string strSectionToShow {get;set;}
    public boolean IsShowPaymnetMode{get;set;}

    //variable to get name 
    public string strName {get;set;}
    public string BankName {get;set;}
    
    //variable to get Registration No
    public string strRegNo {get;set;}  
    public string url {get;set;}
    public string returnurl {get;set;}
    
    //variable to get payment type
    public String PaymentTypeSelected {get;set;}
    public String strProgramId {get;set;}
    public Boolean RegDone {get;set;}
    public Boolean AdmDone {get;set;}
    public decimal decLatefees{get;set;}
    public boolean isPaywithLatefees{get;set;}
    
    public nmRegistrationPaymentByIc()
    {
        objPayment = new nm_Payment__c();
        strLeadEmail = '';
        strLeadPhone = '';
        strInforamtion = '';
        strSectionToShow = 'Payment';
        strName = '';
        strRegNo = '';
        url = '';
        returnurl = '';
        BankName ='HDFC Bank';
        PaymentTypeSelected = '--None--';
        strProgramId = '';
        RegAmmount = 0;
        AdmAmmount = 0;
        RegDone = false;
        AdmDone = false;
        decLatefees=0.0;
        IsShowPaymnetMode=false;
        isPaywithLatefees=false;
        if(ApexPages.currentPage().getParameters().get('id') != Null && ApexPages.currentPage().getParameters().get('id') != '')
        {
            leadId = ApexPages.currentPage().getParameters().get('id');
        }
        
        List<Lead> listLead = [select Id, Name, Email, MobilePhone, firstname,lastName, status, nm_RegistrationNo__c, nm_Program__c from lead where id =: leadID];
        
        if(listLead != null && listLead.size() > 0)
        {
            if(listLead[0].firstName != null)
                strName += listLead[0].firstName + ' ';
            
            // if(listLead[0].nm_MiddleName__c != null)
            //     strName += listLead[0].nm_MiddleName__c  + ' ';
            
            if(listLead[0].lastName != null)
                strName += listLead[0].lastName;
            
            if(listLead[0].nm_RegistrationNo__c != Null)
                strRegNo = listLead[0].nm_RegistrationNo__c ;
            
            if(listLead[0].nm_Program__c != Null)
                strProgramId = listLead[0].nm_Program__c; 
                
            if(listLead[0].Email != Null)
                strLeadEmail = listLead[0].Email; 
                
            if(listLead[0].MobilePhone != Null)
                strLeadPhone = listLead[0].MobilePhone;
        }
                        
        List<PriceBookEntry> lstPriceBookEntry = [select Id, UnitPrice, product2.Name from PriceBookEntry where Pricebook2.IsStandard = false and product2.isActive = true and Pricebook2.nmSession_Start_Date__c != null and Pricebook2.nmSession_End_Date__c != null and Pricebook2.nmSession_Start_Date__c <=: System.today() and Pricebook2.nmSession_End_Date__c >=: System.today() and product2.Name = 'Registration Fee'];
        List<PriceBookEntry> lstPriceBookEntryForAdmission = [select Id, UnitPrice, product2.Name from PriceBookEntry where Pricebook2.IsStandard = false and product2.isActive = true and Pricebook2.nmSession_Start_Date__c != null and Pricebook2.nmSession_End_Date__c != null and Pricebook2.nmSession_Start_Date__c <=: System.today() and Pricebook2.nmSession_End_Date__c >=: System.today() and product2.Name = 'Semester I' and product2.nm_Program__c =: strProgramId];
        
        if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0)
        {
            RegAmmount = lstPriceBookEntry[0].UnitPrice;
        }
        
        if(lstPriceBookEntryForAdmission != Null && lstPriceBookEntryForAdmission.size() > 0)
        {
             system.debug('fecth pricebook'+lstPriceBookEntryForAdmission+''+lstPriceBookEntryForAdmission[0]);
            AdmAmmount = lstPriceBookEntryForAdmission[0].UnitPrice;     
        }
        
        if(leadId != null) 
        {    
            list< Late_Fee__c > lstlateFee=new  list< Late_Fee__c >();
            objPayment.nm_Lead__c = leadId; 
            
            List<nm_Payment__c> listPayment = [select Id, nm_PaymentStatus__c, nm_Type__c  from nm_Payment__c where nm_PaymentStatus__c = 'Payment Made' and nm_Lead__c =: leadId]; 
            
            if(listPayment != null && listPayment.size() > 0)
            {
                for(nm_Payment__c obj : listPayment)
                {
                    if(obj.nm_Type__c == 'Registration')
                    {
                        RegDone = true;    
                    }
                    
                    if(obj.nm_Type__c == 'Admission')
                    {
                        AdmDone = true;
                    }
                }
                
                 lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                        from Late_Fee__c 
                                                        where Category__c =: 'Admission'
                                                        and Start_Date__c <= : date.Today() 
                                                        and End_Date__c >= : date.Today() ];
                 if(lstlateFee !=null && lstlateFee.size()>0)
                 {
                    //AdmAmmount+=lstlateFee[0].Late_Fees__c;
                    decLatefees+=lstlateFee[0].Late_Fees__c;
                 }                                       
                if(RegDone && AdmDone)
                {
                    strInforamtion = 'Previous payments are already in approval process. Plese don\'t make changes in contact details when any payment is in approval process.'; 
                    strSectionToShow = 'Information';               
                }
            } 
        }
    } 
    
    public String getPaymentTypeSelected() 
    {
        return PaymentTypeSelected;
    }
            
    public void setPaymentTypeSelected(String PaymentTypeSelected) 
    {
        this.PaymentTypeSelected = PaymentTypeSelected;
    }
    
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('--None--','--None--'));
        
        if(!RegDone)
        {
            options.add(new SelectOption('Registration','Registration'));
            objPayment.nm_Amount__c = RegAmmount;
            objPayment.nm_ActualPaymentAmmount__c = RegAmmount;
            objPayment.nm_PaymentType__c = 'Registration'; 
        }
        
        if(RegDone && !AdmDone)
        {
    
            options.add(new SelectOption('Admission','Admission'));
            objPayment.nm_Amount__c = AdmAmmount;
            objPayment.nm_ActualPaymentAmmount__c = AdmAmmount;
            objPayment.nm_PaymentType__c = 'Admission'; 
        }
        
        return options;
    }

    public boolean boolShow
    {
        get
        {
            if(objPayment.nm_ModeOfPayment__c == 'Demand Draft')
                return true;
            else
                return false;
        }
        set;
    }    
    
    public pageReference MakePayment()
    {
        list<nm_Payment__c> lstPayment=new list<nm_Payment__c>();
        if(leadId != Null)
        {        
           if(PaymentTypeSelected == '--None--'){
                     Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select type of payment '));
                     return null;
             }
            if(objPayment.nm_ModeOfPayment__c == 'Online')
            {         
                if(PaymentTypeSelected != '--None--')      
                {
                    PageReference pr = new PageReference('/apex/nmRegistrationPayment?&id='+ leadId+'&PaymentFrom=ICLogin');
                   // PageReference pr=MakeOnlinePayment();
                    pr.setRedirect(true);
                    return pr;
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select payment type to proceed...'));
                    return null;
                }
            }
            else
            {
                //Payment validations
                if(PaymentTypeSelected == '--None--' || objPayment.nm_DemandDraftNumber__c == null || objPayment.nm_DemandDraftDate__c ==null || objPayment.nm_NameoftheBank__c==null || objPayment.nm_BankLocation__c==null || objPayment.nm_DispatchDate__c==null)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill all the payment details '));
                    return null;
                }
                if(objPayment.nm_DispatchDate__c < objPayment.nm_DemandDraftDate__c )
                {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Dispatch Date should be not be less than Demand Draft Date'));
                     return null;
                }
                if( objPayment.nm_DemandDraftDate__c > system.today() )
                {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Demand Draft Date should not be grater than current date'));
                     return null;
                }
                 if( objPayment.nm_DispatchDate__c < system.today() )
                {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Dispatch Date Date should not be less than current date'));
                     return null;
                }
                
                if(PaymentTypeSelected != '--None--' && objPayment.nm_DemandDraftNumber__c != null && objPayment.nm_DemandDraftDate__c != null && objPayment.nm_NameoftheBank__c != null && objPayment.nm_BankLocation__c != null && objPayment.nm_DispatchDate__c != null)
                {
                    if(PaymentTypeSelected == 'Registration')
                    {
                        lstPayment.add(objPayment);
                        Lead objNewLeadtoUpdate = new Lead(id=leadId);
                        objNewLeadtoUpdate.Status = 'Registration Fee Paid';
                        objNewLeadtoUpdate.nm_PaymentStatus__c='Payment made';
                        
                        try 
                        {
                            update objNewLeadtoUpdate;
                        }
                        catch(exception e)
                        {
                           system.debug('error message' + e);
                        }
                        
                    }
                                        
                    try
                    {
                        
                        //pay with late fees
                        if(PaymentTypeSelected=='Admission' && decLatefees>0.0 && isPaywithLatefees)
                        {
                            nm_Payment__c objLateFees=new nm_Payment__c ();
                            objLateFees.nm_PaymentType__c='Late Fees';
                            objLateFees.nm_PaymentStatus__c='Payment Made';
                            objLateFees.nm_ModeOfPayment__c=objPayment.nm_ModeOfPayment__c;
                            objLateFees.nm_Lead__c=leadId ;
                            objLateFees.nm_DemandDraftNumber__c=objPayment.nm_DemandDraftNumber__c;
                            objLateFees.nm_NameoftheBank__c=objPayment.nm_NameoftheBank__c;
                            objLateFees.nm_DemandDraftDate__c=objPayment.nm_DemandDraftDate__c;
                            objLateFees.nm_BankLocation__c=objPayment.nm_BankLocation__c;
                            objLateFees.nm_DispatchDate__c=objPayment.nm_DispatchDate__c;
                            objLateFees.nm_Amount__c=decLatefees;
                            
                           
                            objPayment.nm_ActualPaymentAmmount__c=objPayment.nm_Amount__c+decLatefees;
                            objPayment.nm_Amount__c=AdmAmmount;
                            lstPayment.add(objPayment);
                            lstPayment.add(objLateFees);
                           
                        }
                        //pay without late fees
                         else if(PaymentTypeSelected=='Admission' && decLatefees>0.0 && isPaywithLatefees==false)
                        {
                            nm_Payment__c objpaymentwithoutLateFees=new nm_Payment__c ();
                            objpaymentwithoutLateFees.nm_PaymentType__c='Late Fees';
                            objpaymentwithoutLateFees.nm_PaymentStatus__c='Pending Payment';
                            objpaymentwithoutLateFees.nm_Lead__c=leadId ;
                            objpaymentwithoutLateFees.nm_Amount__c=decLatefees;
                            objPayment.nm_Amount__c=AdmAmmount;
                            lstPayment.add(objPayment);
                            lstPayment.add(objpaymentwithoutLateFees);
                           system.debug('lstPaymentwithlatefees'+lstPayment);
                        }
                        
                        
                       else if(PaymentTypeSelected=='Admission' && decLatefees==0.0 && isPaywithLatefees==false)
                        {
                          objPayment.nm_ActualPaymentAmmount__c=objPayment.nm_Amount__c;
                          lstPayment.add(objPayment);
                        }
                        if(lstPayment.size()>0)
                        {
                            insert lstPayment;
                        }
                        String paymentid;
                        if(lstPayment.size()>0 && lstPayment[0].nm_PaymentType__c=='Registration')
                        {
                          paymentid=lstPayment[0].id;
                        }
                        if(lstPayment.size()>0)
                        {
                            for(nm_Payment__c objpayment:lstPayment)
                            {
                                if(objpayment.nm_PaymentType__c=='Admission')
                                    paymentid=objpayment.id;
                            }
                                 
                        }
                        system.debug('paymentid'+paymentid);
                        url = 'apex/nmRegistrationReceipt?id='+paymentid;
                        returnurl = leadId;
                        strInforamtion = 'Payment Successful';
                        strSectionToShow = 'Information';
                        return null;
                    }
                    catch(exception e)
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,' ' + e));
                        return null;
                    }
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill all the payment details to proceed...'));
                    return null;
                }
            }
        }
        return Null;
    } 
   /* 
    public pageReference MakeOnlinePayment()
    {
        //Payment validations
        if(objPayment.nm_Amount__c > 0)
        {      
            //Creating payment tracking Id. 
            string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
                        
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.TranAmount = string.valueOf(objPayment.nm_Amount__c);
            objOnlinePayment.strPaymentType = PaymentTypeSelected;
            objOnlinePayment.strEmailId = strLeadEmail;
            objOnlinePayment.strMobileNumber = strLeadPhone;
            objOnlinePayment.strAddress = leadId;
            
            string strPaymentResponse = objOnlinePayment.MakePayment();
            
            if(strPaymentResponse != null && strPaymentResponse != '' && strPaymentResponse.split(':').size() > 1)            
            {   
                String strPaymentId = strPaymentResponse.split(':https:')[0];
                String strPaymentUrl = 'https:'+strPaymentResponse.split(':https:')[1];
                
                return new PageReference(strPaymentUrl + '?PaymentID=' + strPaymentId);
            }
            else
            {
                return null;
            }              
        }
        else
        {
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Please fill all the payment details'));
            return null;
        }
    }*/
    public void Checklatefees()
    {
        if(isPaywithLatefees==true){
             objPayment.nm_Amount__c = AdmAmmount+decLatefees;
          }
         if(isPaywithLatefees==false)
         {
           objPayment.nm_Amount__c = AdmAmmount;
           system.debug('objPayment.nm_Amount__c'+objPayment.nm_Amount__c); 
         }
    }  
    public void showPaymentMode()
    {
      IsShowPaymnetMode=true;
    }      
}