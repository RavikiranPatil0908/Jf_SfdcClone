public class nmMakeRegistrationPayment 
{ 
    //Property of payment to make payment
    public nm_Payment__c objPayment {get;set;}
    //Property for lead for making payment
    public Lead objLead {get;set;}
    //Variable to store lead id
    public id LeadId{get;set;}
    //Variable to Registration Ammount
    public decimal RegAmmount{get;set;}
    //Variable to store information
    public string  strInforamtion{get;set;}
    //Variable to Handle to show the section
    public string strSectionToShow{get;set;}
    //Variable to store url for pdf
    public string strurl{get;set;} 
    
    //variable to get studentprogram id
    public id strStudentProgramid {get;set;}
    
    //variable to get type
    public string strtype;   
    
    //variable to get name 
    public string strName{get;set;}
    public string strName1 ;
    public string strName2 ;
    public string strName3 ;
    public string BankName{get;set;}
    
    //variable to get Registration No
    public string strRegNo{get;set;}  
    public List<Opportunity> lstOpp ;
    public string url{get;set;}
    public string returnurl{get;set;}
    public nmMakeRegistrationPayment()
    {
        objPayment = new nm_Payment__c ();
        //objPayment.nm_NameoftheBank__c ='HDFC Bank';
        objLead = new Lead();
        lstOpp = new List<Opportunity>();
        RegAmmount = 0;
        strSectionToShow = 'Payment';
        BankName ='HDFC Bank';
        leadID = ApexPages.currentPage().getParameters().get('id');
        
        strStudentProgramid = ApexPages.currentPage().getParameters().get('spid');
        strtype = ApexPages.currentPage().getParameters().get('type');
        
        list<Lead> listLead = [select id, name,firstname,lastName, status, nm_RegistrationNo__c from lead where id =: leadID];
        list<nm_StudentProgram__c> lstSP = [select id , 
                                                   nm_Student__r.name , 
                                                   nm_Student__r.nm_RegistrationNumber__c 
                                                   from nm_StudentProgram__c where id =:strStudentProgramid limit 1];
        if(listLead != null && listLead.size() > 0)
        {
            if(listLead[0].firstName !=null)
            {
                strName1 =  listLead[0].firstName ;
            }
            else
            {
                strName1 = '';
            }            
            // // if(listLead[0].nm_MiddleName__c !=null)
            // // {
            // // strName2 =  listLead[0].nm_MiddleName__c ;
            // // }
            // else
            // {
            //     strName2='';
            // }
            if(listLead[0].lastName !=null)
            {
                strName3 = listLead[0].lastName;
            }
            else
            {
                strName3 = '';
            }
            strName3 =  listLead[0].lastName ;
            strName =   strName1 +' '+strName2+' '+strName3 ;
            
            strRegNo = listLead[0].nm_RegistrationNo__c ;
            objLead.firstname = strName1 ;
          //  objLead.nm_MiddleName__c = strName2;
            objLead.lastName = strName3; 
            
            objLead.nm_RegistrationNo__c = listLead[0].nm_RegistrationNo__c;
                
        }
        else if(lstSP.size()>0)
        {
            strName = lstSP[0].nm_Student__r.Name ;
            strRegNo = lstSP[0].nm_Student__r.nm_RegistrationNumber__c;
        
        }
        
        List<PriceBookEntry> lstPriceBookEntry = [select id, UnitPrice, product2.Name
                                                             from PriceBookEntry 
                                                             where Pricebook2.IsStandard = false and product2.isActive = true
                                                             and product2.Name = 'Registration Fee'];
        
        if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0)
        {
                RegAmmount =  lstPriceBookEntry[0].UnitPrice;
        }
        else
        {
                strInforamtion = 'Product for Registratrion Fee not available in system please contact admin to make make an product for ragistration.';
                strInforamtion = strInforamtion + ' Please give name' + '"' + 'Registration Fee' +'"' + 'to the product';
                strSectionToShow = 'Information';
        }
        
        objPayment.nm_Amount__c = RegAmmount;
        
        if(leadId != null) 
        {
                list<nm_Payment__c> listPayment = [select id, nm_PaymentStatus__c from nm_Payment__c
                                                                                         where nm_PaymentStatus__c = 'Payment Made'
                                                                                         and nm_Lead__c =: leadId]; 
                
                if(listPayment != null && listPayment.size() > 0)
                {
                        strInforamtion = 'Previous payment is already in approval process. Plese don\'t make changes in contact details when any payment is in approval process.'; 
                        strSectionToShow = 'Information';               
                } 
        }
        
    } 

    public boolean boolShow
    {
        get
        {
            if (objPayment.nm_ModeOfPayment__c == 'Demand Draft' || 
                objPayment.nm_ModeOfPayment__c == 'Challan')
                return true;
          
            else
                return false;
        }
        set;
    }    
   
    public pageReference MakePayment()
    {        
        System.debug(strStudentProgramid);
        System.debug(strtype);
        System.debug(objPayment.nm_ModeOfPayment__c);
        if(objPayment.nm_ModeOfPayment__c == 'Online')
        {               
                //System.debug(MakeOnlinePayment());
                //returnurl = String.valueof(MakeOnlinePayment());
                //return null;
                return MakeOnlinePayment();
        }
        else
        {
                //Payment validations
                if(objPayment.nm_DemandDraftNumber__c != null && objPayment.nm_DemandDraftDate__c != null && objPayment.nm_NameoftheBank__c != null && 
                        objPayment.nm_BankLocation__c != null)
                {
                        if(objPayment.nm_ModeOfPayment__c == 'Demand Draft' && objPayment.nm_DispatchDate__c == null)
                        {
                                apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please fill all the payment details'));
                                return null;
                        }
                                
                    objPayment.nm_Amount__c = RegAmmount;
                    objPayment.nm_PaymentType__c = 'Registration'; 
                    System.debug(leadId);
                    system.debug('objLead Status'+objLead.Status);
                    if(leadId !=null)
                    {
                        objPayment.nm_Lead__c = leadId;       
                                     
                        Lead objNewLeadtoUpdate = objLead.clone();
                        objNewLeadtoUpdate.Id = leadId;
                        objNewLeadtoUpdate.Status = 'Registration Fee Paid';
                        system.debug('%%%%EEEE'+objNewLeadtoUpdate);
                        try {
                            update objNewLeadtoUpdate;
                        }
                        catch(exception e)
                              {
                                 system.debug('the error message'+e);
                              }
                    }
                    else if(strStudentProgramid != null  && strtype !=null )
                    {
                        lstOpp = [select id from Opportunity where nm_StudentProgram__c=:strStudentProgramid limit 1];
                        if(lstOpp.size()>0)
                        {
                            objPayment.nm_OpportunityNew__c = lstOpp[0].id;
                            objPayment.nm_ActualPaymentAmmount__c = objPayment.nm_Amount__c;
                        }
                    } 
                        
                    try
                    {
                        insert objPayment;
                        if(leadId !=null)
                        {
                            url = 'apex/nmRegistrationReceipt?id='+objPayment.id;
                            returnurl= leadId;
                            strInforamtion = 'Payment Successful';
                            strSectionToShow = 'Information';
                            //return new pageReference('/'+leadId );
                            return null;
                        }
                        else if(strStudentProgramid != null)
                        {
                            url = 'apex/nmAdmissionReciept?PaymentId='+objPayment.id;
                            returnurl = strStudentProgramid;
                            strInforamtion = 'Payment Successful';
                            strSectionToShow = 'Information';
                            //return new pageReference('/'+strStudentProgramid);
                            return null;
                        }
                        else
                        {
                            return null;
                        }
                    }
                    catch(exception e)
                    {
                            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,' ' + e));
                            return null;
                    }
                        
                }
                else
                {
                    apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please fill all the payment details'));
                    return null;
                }
        }
    } 
    
    public pageReference MakeOnlinePayment()
    {
        system.debug('NRAC:::::1::'+RegAmmount);
        //Payment validations
        if(RegAmmount > 0)
        {      
            //Creating payment tracking Id. 
            string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
                        
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.TranAmount = string.valueOf(RegAmmount);
            objOnlinePayment.strPaymentType = 'Registration';
            objOnlinePayment.strEmailId = objLead.Email;
            objOnlinePayment.strMobileNumber = objLead.MobilePhone;
            objOnlinePayment.strAddress = leadId;
            
            string strPaymentResponse = objOnlinePayment.MakePayment();
            
            system.debug('NRAC:::::1::::2'+strPaymentResponse);
            if(strPaymentResponse != null && strPaymentResponse != '' && strPaymentResponse.split(':').size() > 1)            
            {   
                String strPaymentId = strPaymentResponse.split(':https:')[0];
                String strPaymentUrl = 'https:'+strPaymentResponse.split(':https:')[1];
                
                system.debug(strPaymentUrl+'?PaymentID='+strPaymentId);
                return new PageReference(strPaymentUrl+'?PaymentID='+strPaymentId);
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
    }       
    
    //Method to generate challan no 
    public void GenChallan()
    {
        nmCommon objCommon = new nmCommon();
        string strChlnNo = string.valueof(objCommon.generateChallan());
            
        for(integer i = strChlnNo.length(); i<6; i++)
            strChlnNo = '0'+strChlnNo;
        strurl = 'apex/nmBankChalan?Amount=' + RegAmmount + '&id=' + LeadId + '&type=Lead&challan=' + strChlnNo + '&FeeType=Admission Processing Fee:' ;
    } 
}