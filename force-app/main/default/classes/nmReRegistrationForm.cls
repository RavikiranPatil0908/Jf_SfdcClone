public class nmReRegistrationForm
{
    public Account objAccount{get;set;}
    public id AccountId{get;set;}
    public nm_Payment__c objPayment{get;set;}
    public list<Opportunity> lstOpportunity{get;set;}
    public nm_StudentProgram__c objStudentProgram{get;set;}
    public string strCenter {get;set;}
    
    public string strSelectResponse{get;set;}
    public boolean isShowChangeIC{get;set;}
    public boolean isShowChangeProgram{get;set;}
    
    public boolean isShowChangeICPanel{get;set;}
    public boolean isShowChangeProgramPanel{get;set;}
    
    public boolean isShowPaymentPanel{get;set;}
    
    public string strPaymentMethod{get;set;}
    public boolean blpnlDDPaymentDetails{get;set;}
    public boolean blpnlChalanPaymentDetails{get;set;}
    
    
    public nmReRegistrationForm()
    {
        objAccount = new Account();
        objPayment = new nm_Payment__c();
        lstOpportunity = new list<Opportunity>();
        objStudentProgram = new nm_StudentProgram__c();
        isShowChangeIC = true;
        isShowChangeProgram = false;
        isShowChangeICPanel = false;
        isShowChangeProgramPanel = false;
        isShowPaymentPanel = false;
        
        Cookie cookie = ApexPages.currentPage().getCookies().get('studentsessionid');
        if(cookie != null && cookie.getValue() != null && cookie.getValue() != '')
        {
            AccountId = cookie.getValue();
            list<Account> lstAccount = [select id, name, nm_Centers__c, nm_Centers__r.name, nm_Centers__r.nm_City__c, nm_Centers__r.nm_Country__c, 
                                        nm_Centers__r.nm_StateProvince__c, nm_Centers__r.nm_Street__c
                                        from Account where id =: AccountId];
        
            if(lstAccount!= null && lstAccount.size()>0)
            { 
                strCenter = lstAccount[0].nm_Centers__c;                
                objAccount = lstAccount[0]; 
                
                list<nm_StudentProgram__c> lstStudentProgram = new  list<nm_StudentProgram__c>();
                
                lstStudentProgram =([select id,name, nm_CurrentSession__c, nm_Student__r.name, nm_program__c, nm_program__r.name
                                     from nm_StudentProgram__c where 
                                     nm_IsClosed__c = false and
                                     nm_Student__c =:  AccountId limit 1]);
                if(lstStudentProgram !=null && lstStudentProgram.size()>0)
                {
                                     
                 objStudentProgram = lstStudentProgram[0];
                }
            }
        }
    }
    
    public void selectedOption()
    {
        if(strSelectResponse == 'YesChangeIC')
        {
            isShowChangeICPanel = true;
            isShowChangeIC = false;
        }
        
        if(strSelectResponse == 'NoChangeIC')
        {
            isShowChangeIC = false;
            isShowChangeProgram = true;
        }
        
        if(strSelectResponse == 'YesChangeProgram')
        {
            isShowChangeProgramPanel = true;
            isShowChangeProgram = false;
        }
        
        if(strSelectResponse == 'NoChangeProgram')
        {
            
        }
    }
    
    public List<SelectOption> getAllInformationCenters()
    {
        List<SelectOption> lstICOptions = new List<SelectOption>();
        lstICOptions.add(new SelectOption('','--None--'));
        
        //Fetching all Information centers
        List<nm_Centers__c> lstCenters = [select id, Name from nm_Centers__c where recordtype.Name =: 'Information Center'];
        
        //creating select option list from centers
        if(lstCenters != null && lstCenters.size() > 0)
        {
            for(nm_Centers__c objCenter : lstCenters)
            {
                lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
            }
        }
        
        //Finally returning list of ic options
        return lstICOptions;
    }
    public void ICchanged()
    {
        if(strCenter != objAccount.nm_Centers__c)
        {
            isShowPaymentPanel = true;
        }
        else
        {
            isShowPaymentPanel = false;
        }
    }
    
    
    public void selectedPaymentMethod()
    {
        if(strPaymentMethod == 'AxisBankChallan')
        {
            blpnlChalanPaymentDetails = true;
            blpnlDDPaymentDetails= false;
            objPayment.nm_ModeOfPayment__c = 'Cash by Chalan';
        }
        
        if(strPaymentMethod == 'DemandDraft')
        {
            blpnlDDPaymentDetails = true;
            blpnlChalanPaymentDetails = false;
            objPayment.nm_ModeOfPayment__c = 'Demand Draft';
        }
        if(strPaymentMethod == 'Online')
        {
            blpnlDDPaymentDetails = false;
            blpnlChalanPaymentDetails = false;
            objPayment.nm_ModeOfPayment__c = 'Online';
        }
    }
    
    public PageReference save()
    {
        if(objPayment.nm_Amount__c == null || objPayment.nm_Amount__c >= 0)
        {
            //Saves the record on if Payment mode is Demand draft or Cash by Chalan.
            if(objPayment.nm_ModeOfPayment__c == 'Demand Draft' || objPayment.nm_ModeOfPayment__c == 'Cash by Chalan')
            {
                if(objPayment.nm_DemandDraftNumber__c == null || objPayment.nm_NameoftheBank__c == null || objPayment.nm_DemandDraftDate__c == null ||
                    objPayment.nm_BankLocation__c == null || objPayment.nm_DispatchDate__c == null)
                {
                    apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please fill all the payment details'));
                    return null;
                }
                     
                if(lstOpportunity.size() > 1 && objPayment.nm_Amount__c > lstOpportunity[0].PendingAmmount__c)
                {
                    insert lstOpportunity[1];
                }
                objPayment.nm_OpportunityNew__c = lstOpportunity[0].id;
                objPayment.nm_PaymentStatus__c = 'Payment Made';
                
                //Insert payment
                insert objPayment;
                
                //Message on page
                //apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment Successful'));
                return new PageReference('/apex/nmThankYou');
            }
            
            //Handles Process if payment mode is online.
            if(objPayment.nm_ModeOfPayment__c == 'Online')
            {
                apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Online Payment not available now'));
            }
            
            return null;
        }
        return null;
    }
}