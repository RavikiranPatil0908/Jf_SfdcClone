public class nmAdmissionForm
{
    //Public properties 
    public Account objAccount {get;set;}
    //to maintain the custom login session
    public id AccountId {get;set;}
    //used in case of sengle semester mayment.
    public Opportunity objOpportunity1 {get;set;}
    //used only for two semester payment
    public Opportunity objOpportunity2 {get;set;}
    //the program selected by the student
    public nm_StudentProgram__c objStudentProgram {get;set;}   
    //15 may        
    public string strOperationSelected{get;set;}
    //To show the section upload documents, payment or declaration
    public string strSectionToShow{get;set;}
    //Just to show the program name and eligibility criteria selected by the student
    public string strProgramName{get;set;}
    
    //17 may   
    //to maintain that student is paying for a single semester or for an year
    public string strSelectedSem{get;set;}
    //amount just for a single semester
    public decimal semFeeAmount{get;set;}    
    //amount for two semester
    public decimal yearFeeAmount{get;set;}
    //property to maintain payment mode
    public string strPaymentMethod{get;set;}
    
    //18 May
    //variable to store payment details
    public nm_Payment__c objPayment{get;set;}  
    public boolean isValidForYearlyPayment{get;set;} 
    
    //variable to store information to show on page
    public string strInformation{get;set;}
    //variable to store pdf url
    public string strurl{get;set;}
    
    public decimal TotalPaidAmmount{get;set;}
    
    //payment id to pass payment gateway
    public string strPaymentIdToPassResponsePage{get;set;} 
    
    public boolean showpage{get;set;}
    
     public boolean AdmissionFormForStudent{get;set;} 
    // by this variable we can show hide whole page bt uncheck admission form checkbox on nm_Configure_the_Pages__c object
    
    public string PDFDate{get;set;}
    public string PDFPlace{get;set;}
    
    ////////////////////////////////
    public boolean showemi{get;set;}
    public boolean showPayment{get;set;}
    public string selectedduration{get;set;}
    public Decimal Amount;
    public List<Installments__c> lstInstallments{get;set;}
    public boolean showpanel1{get;set;}
    public boolean showpanel2{get;set;}
    public boolean show1{get;set;}
    public boolean show2{get;set;}
    public boolean show3{get;set;}
    public string error ;
    public string udf4response ;  
    public String BatchName{get;set;}  
    ///////////////////////////////////
    
    //11-july-2014 Sumit Kumar Banarji
    public boolean isValidForFullPayment{get;set;}
    list<Opportunity> lstAllOpportunity {get;set;}
    public decimal fullFeeAmount{get;set;}
    public decimal latefeesamount{get;set;}
    public string pricebookid;
    public string oppid;
    ///////////////////////////////////////////////
    
    //Constructor
    public nmAdmissionForm()
    {
        AdmissionFormForStudent = false;
        nm_Configure_the_Pages__c objconfigforstudent = [select id,nm_Admission_Page__c from nm_Configure_the_Pages__c where Recordtype.Name='Student' limit 1];
        if(objconfigforstudent.nm_Admission_Page__c == true)
        {
            AdmissionFormForStudent = false;
        }
        else
        {
            AdmissionFormForStudent  = true;
        }
        showpage = false ;
        showemi = false;
        showPayment = true;
        showpanel1 = false;
        showpanel2 = true;
        show1=false;
        show2=false;
        show3 = false;
        objAccount = new Account();        
        objOpportunity1 = new Opportunity();
        objOpportunity2 = new Opportunity();
        objStudentProgram = new nm_StudentProgram__c();
        objPayment = new nm_Payment__c();
        lstInstallments = new List<Installments__c> ();
        strOperationSelected = '';        
        strSelectedSem = 'singlesem'; 
        strSectionToShow = '';   
        strPaymentMethod = 'demanddraft';
        isValidForYearlyPayment = false; 
        isValidForFullPayment = false; 
        BatchName='';
               
        //Checking if student come this page from login page then auto populate Account  details
        Cookie cookie = ApexPages.currentPage().getCookies().get('studentsessionid');
        if(cookie != null && cookie.getValue() != null && cookie.getValue() != '')
        {
            AccountId = cookie.getValue(); 
            if(AccountId != null)
            {           
                List<Account> lstAcc = [select nm_StudentStatus__c,nm_Batch_Name2__c from Account where id=:AccountId ];
                 
                if(lstAcc[0].nm_Batch_Name2__c !=null)
                {
                  BatchName=lstAcc[0].nm_Batch_Name2__c ;
                }
               
                if(lstAcc[0].nm_StudentStatus__c  =='Confirmed')
                {
                    showPayment = false ;
                }
                else
                {
                    List<Opportunity> lst_Acc_Opp = [select id from Opportunity where Account.id =:lstAcc[0].id 
                                                            and nm_Semester__c = '1' 
                                                            and StageName ='Payment Made'];
                    if(lst_Acc_Opp.size()>0)
                    {
                        showPayment = false;
                    }
                    else
                    {
                        showPayment = true;
                    }       
                    
                }
            }
        }          
    } 
    
    public void LoadData()
    {
        if(AccountId != null)
        {       
            
            //Creating query for account            
            string strQuery = 'select nm_Centers__r.name, nm_EligiblityCriteria__r.name';
            Map<String, Schema.SObjectField> M = Schema.SObjectType.Account.fields.getMap();
            for(string fName : m.keyset())
            {
                strQuery = strQuery + ',' + fName;  
            }                               
            strQuery = strQuery + ' from Account where id =: AccountId';
            //Fetch account details
            List<Account> lstAccount = Database.query(strQuery);
            
            if(lstAccount!= null && lstAccount.size()>0)
            {                  
                objAccount = lstAccount[0];                 
                system.debug('NRACAccount::'+objAccount.id);                
                
                list<nm_StudentProgram__c> lstStudentProgram = new  list<nm_StudentProgram__c>();
                //List of student program with unclosed opportunity
                lstStudentProgram =([select id,name, nm_CurrentSession__c, nm_Student__r.name, nm_program__r.name, nm_program__r.nm_ProgramName__c,
                                     nm_Student__r.firstname, nm_Student__r.lastname, nm_EligiblityCriteria__r.nm_EligiblityCriteria__c,
                                     (Select id,nm_StudentProgram__c, nm_EligiblityCriteriaid__c,
                                     name,StageName, nm_Semester__c,nm_PendingAmount__c, PendingAmmount__c,
                                     nm_Session__c, nm_Category__c,nm_Year__c, nm_ModeOfPayment__c, nm_PaymentDone__c,Pricebook2Id
                                     from Opportunities__r 
                                     where StageName = 'Registration Done' or StageName = 'Pending Payment'
                                     order by nm_Semester__c limit 1)
                                     from nm_StudentProgram__c where 
                                     nm_Student__c =:  AccountId]);    
                System.debug(lstStudentProgram.size());
                
                
                
                if(lstStudentProgram != null && lstStudentProgram.size() > 0)
                {
                    //system.debug('NRACAccountlstStudentProgram::'+lstStudentProgram[0].Opportunities__r[0].stageName);
                    
                    objStudentProgram = lstStudentProgram[0];
                    
                    strProgramName = objStudentProgram.nm_program__r.nm_ProgramName__c + ' - ' + objStudentProgram.nm_EligiblityCriteria__r.nm_EligiblityCriteria__c;
                    System.debug(objStudentProgram.Opportunities__r.size());
                    if(objStudentProgram.Opportunities__r != null && objStudentProgram.Opportunities__r.size() > 0)
                    {                       
                        objOpportunity1 = objStudentProgram.Opportunities__r[0];   
                        oppid = objOpportunity1.id;
                        //List<Opportunities> lstOpp 
                        if(objOpportunity1 !=null)
                        {
                            pricebookid = objOpportunity1.Pricebook2Id;
                            if(pricebookid !=null || pricebookid!='')
                            {
                                //getting pricebook netry of late fees to insert in opp line item
                                List<PriceBookEntry> lstPBE = [select id ,  
                                                              UnitPrice,  
                                                              product2.Name , 
                                                              pricebook2.id 
                                                              from PriceBookEntry  
                                                              where pricebook2.id = :pricebookid and product2.Name = 'Late Fees' limit 1];
                                                              
                                System.debug('lstPBE+++'+lstPBE.size());
                                
                                //Checking , if there is existing late fee product on opportunity
                                List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
                                lstOppLineItem= [select id  
                                                        from OpportunityLineItem  
                                                        where Opportunityid = : oppid
                                                        and Product2.Name = 'Late Fees' 
                                                        and Is_Waver_Off__c !=true limit 1];
                                                        
                                System.debug('lstOppLineItem+++'+lstOppLineItem.size());
                                
                                List<Late_Fee__c> lstLateFees = new List<Late_Fee__c> ();
                                lstLateFees = [select id , 
                                                      Late_Fees__c 
                                                      from Late_Fee__c 
                                                      where Start_Date__c <=Today
                                                      and End_Date__c >=Today
                                                      limit 1];
                                
                                
                                
                                
                                if(lstLateFees.size()>0)
                                {
                                    if(lstOppLineItem.size()>0)
                                    {
                                        lstOppLineItem[0].TotalPrice = lstLateFees[0].Late_Fees__c ;
                                        update lstOppLineItem;
                                    }
                                    else
                                    {                                      
                                        System.debug('lstLateFees+++'+lstLateFees.size());                                        
                                        if(lstPBE.size()>0 && lstLateFees.size()>0)
                                        {                                   
                                            OpportunityLineItem objLineItem = new OpportunityLineItem();
                                            objLineItem .OpportunityId = objOpportunity1.id;
                                            objLineItem .quantity = 1;
                                            objLineItem .TotalPrice = lstLateFees[0].Late_Fees__c ;
                                            objLineItem .pricebookentryid= lstPBE[0].id;
                                            insert objLineItem ;
                                        }                                   
                                    }
                                }
                            }                       
                        }
                        
                        
                        objOpportunity1 = new Opportunity();
                        
                        objOpportunity1 =  [Select id,nm_StudentProgram__c, nm_EligiblityCriteriaid__c,
                                             name,StageName, nm_Semester__c,nm_PendingAmount__c, PendingAmmount__c,
                                             nm_Session__c, nm_Category__c,nm_Year__c, nm_ModeOfPayment__c, nm_PaymentDone__c,Pricebook2Id
                                             from Opportunity where id=:oppid limit 1];
                        
                        
                        objOpportunity1.PendingAmmount__c = objOpportunity1.nm_PendingAmount__c;
                        semFeeAmount = objOpportunity1.PendingAmmount__c;  
                        List<OpportunityLineItem> lstOppLateFees = [select id  , UnitPrice
                                                                            from OpportunityLineItem  
                                                                            where Opportunityid = : oppid
                                                                            and Product2.Name = 'Late Fees' 
                                                                            limit 1];
                                                        
                        System.debug('semFeeAmount+++'+semFeeAmount );
                        system.debug('NRAC:::OPP1:::'+objOpportunity1);                                              
                        system.debug('isValidForYearlyPayment::'+isValidForYearlyPayment); 
                        system.debug('objStudentProgram'+objStudentProgram);
                        integer intTotalSem = 0;      
                        
                        if(lstOppLateFees.size()>0)
                        {
                            latefeesamount = lstOppLateFees[0].UnitPrice;
                        }
                        if(objStudentProgram != null)
                        {
                            if(objStudentProgram.nm_Program__c != null)
                            {
                                nm_Program__c objProgram = [Select nm_ProgramDuration__c,nm_ProgramValidity__c,nm_TotalSemesters__c
                                                            from nm_Program__c where id =: objStudentProgram.nm_Program__c];
                               
                                intTotalSem = integer.valueof(objProgram.nm_TotalSemesters__c);
                                system.debug('objProgram.nm_TotalSemesters__c'+objProgram.nm_TotalSemesters__c);  
                                system.debug('objOpportunity1.nm_Category__c++'+objOpportunity1.nm_Category__c);
                                if(objOpportunity1.nm_Category__c != 'Lateral Admission')
                                {
                                    if(objProgram.nm_TotalSemesters__c > 1)    
                                    {
                                        isValidForYearlyPayment = true;
                                    }
                                    if(objProgram.nm_TotalSemesters__c > 2)
                                    {
                                        isValidForFullPayment = true;
                                    }
                                }
                                else if(objOpportunity1.nm_Category__c == 'Lateral Admission' && objOpportunity1.nm_Semester__c == '2')
                                {
                                    isValidForYearlyPayment = false;
                                    isValidForFullPayment = false;
                                }
                                else if(objOpportunity1.nm_Category__c == 'Lateral Admission' && objOpportunity1.nm_Semester__c=='3')
                                {
                                    isValidForYearlyPayment = true;
                                    isValidForFullPayment = true;
                                }
                            }
                        }
                        system.debug('isValidForYearlyPayment'+isValidForYearlyPayment);    
                        if(isValidForYearlyPayment)
                        {
                            //Calling method to create temp opportunity for second semester
                            createOpportunityForNextSem();
                            system.debug('objOpportunity2.PendingAmmount__c'+objOpportunity2.PendingAmmount__c+'semFeeAmount'+semFeeAmount);  
                            system.debug('isValidForYearlyPayment'+isValidForYearlyPayment);
                            if(semFeeAmount !=null &&  objOpportunity2.PendingAmmount__c!=null)
                            {
                                yearFeeAmount = semFeeAmount + objOpportunity2.PendingAmmount__c; 
                            }
                        }
                        if(isValidForFullPayment)
                        {
                            fullFeeAmount = 0;
                            
                            /*fullpayment(intTotalSem);
                            for(Opportunity objOpp : lstAllOpportunity)
                                fullFeeAmount +=  objOpp.PendingAmmount__c;
                            System.debug('fullFeeAmount++'+fullFeeAmount);*/
                        }
                    }
                }
            }
        }
    }
    
    public void createOpportunityForNextSem()
    {
        if(objStudentProgram != null)
        if(objStudentProgram.nm_Program__c != null)
        {
            nm_Program__c objProgram = [Select nm_ProgramDuration__c,nm_ProgramValidity__c,nm_TotalSemesters__c
                                        from nm_Program__c where id =: objStudentProgram.nm_Program__c];
            
            if(objProgram.nm_TotalSemesters__c > 1)    
            {
                isValidForYearlyPayment = true;
                           
                map<string, PriceBookEntry> mapPricebook = new map<string, PriceBookEntry>();
                System.debug('********'+pricebookid);
                //Getting price book entry 
                List<PriceBookEntry> lstPriceBookEntry = [select id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
                                                                 from PriceBookEntry 
                                                                 where product2.isActive =: true
                                                                 and product2.nm_Program__c =: objStudentProgram.nm_Program__c
                                                                 and Pricebook2.id =: pricebookid 
                                                                 and Pricebook2.IsActive=true ];
                                                                
                System.debug('lstPriceBookEntry+++'+lstPriceBookEntry);                                              
                if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0)
                {
                    for(PriceBookEntry objPBE : lstPriceBookEntry)
                    {
                        if(objPBE.product2.nm_Program__c != null)
                        {
                            string strKey = objPBE.product2.nm_Program__c + '-' + objPBE.product2.nm_Semester__c;
                            mapPricebook.put(strKey, objPBE);
                        }
                    } 
                }
                System.debug('********');
                //Creating a temp. opportunity for next semester
                if(objProgram!= null)
                {
                    System.debug('********');
                    if(integer.valueof(objOpportunity1.nm_Semester__c) < objProgram.nm_TotalSemesters__c &&
                        objStudentProgram.nm_CurrentSession__c < objProgram.nm_ProgramValidity__c *2 )
                    {                           
                        System.debug('********');
                        date dtClosedate;
                        string strSession;
                        decimal intYear;
                        if(objOpportunity1.nm_Session__c == 'July')
                        {
                            strSession = 'January';
                            intYear = objOpportunity1.nm_Year__c + 1;
                            dtClosedate = date.newInstance((integer)intYear, 6, 30);
                            objOpportunity2.closedate = dtClosedate;
                        }
                        else if (objOpportunity1.nm_Session__c == 'January')
                        {
                            strSession = 'July';
                            intYear = objOpportunity1.nm_Year__c;
                            dtClosedate = date.newInstance((integer)intYear, 12, 31);
                            objOpportunity2.closedate = dtClosedate;
                        }
                        
                        objOpportunity2.nm_Program__c = objStudentProgram.nm_Program__c;
                        objOpportunity2.nm_Semester__c = string.valueof(integer.valueof(objOpportunity1.nm_Semester__c) + 1);
                        
                        if(mapPricebook != null)
                        if(mapPricebook.get(objOpportunity2.nm_Program__c + '-' + objOpportunity2.nm_Semester__c) != null)
                        {   
                            System.debug('********');
                            objOpportunity2.Name = 'a';
                            objOpportunity2.StageName = 'Pending Payment';
                            objOpportunity2.Accountid = objStudentProgram.nm_Student__c;
                            objOpportunity2.nm_StudentProgram__c = objStudentProgram.Id;
                            objOpportunity2.nm_Session__c = strSession;
                            objOpportunity2.nm_Year__c = intYear;
                            objOpportunity2.Amount = mapPricebook.get(objStudentProgram.nm_Program__c + '-' + objOpportunity2.nm_Semester__c).UnitPrice;
                            objOpportunity2.PendingAmmount__c = objOpportunity2.Amount;
                        }
                    }
                }
            }
        }
        
        system.debug('NRAC::objopportunity2::'+objopportunity2);
    }
    
    public pageReference MakePayment()
    {
        system.debug('objPayment.nm_ModeOfPayment__c'+objPayment.nm_ModeOfPayment__c);
        system.debug('strSelectedSem '+strSelectedSem );
        
        //12-July-2014 Code edited by Sumit Banarji
        if(strSelectedSem == 'full')
        {
            TotalPaidAmmount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            TotalPaidAmmount = yearFeeAmount;
        }
        else if(strSelectedSem != 'yearly') 
        {
            TotalPaidAmmount = semFeeAmount;
        }
        /////////////////////////////////////////////
        
        
        system.debug('objPayment.nm_ModeOfPayment__c ::::' + objPayment.nm_ModeOfPayment__c);
        
        objPayment.nm_ModeOfPayment__c = paymentMode();
        
        system.debug('objPayment.nm_ModeOfPayment__c ::::' + objPayment.nm_ModeOfPayment__c);
        
        if(objPayment.nm_ModeOfPayment__c == 'Demand Draft' || objPayment.nm_ModeOfPayment__c == 'challan')
        {   
            //11-june-2014 Coded by Sumit Kumar Banarji//////////////////
            if(strSelectedSem == 'full')
            {
                upsert lstAllOpportunity;
                return CreatePaymentRecordsForChaalan_DemandDraft(lstAllOpportunity);
            }
            ////////////////////////////////////////////////////////////
            else return CreateRecordsForChaalan_DemandDraft();

        }
        
        else if(objPayment.nm_ModeOfPayment__c == 'Online')
        {
              
            if(TotalPaidAmmount > 0)
            {         
                system.debug('NRAC:::::11::'+TotalPaidAmmount ); 
                
                objPayment.nm_Amount__c = TotalPaidAmmount ;
                objPayment.nm_TransactionDate__c = Date.today();
                
                //Creating payment tracking Id. 
                string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
                       
                nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
                
                objOnlinePayment.TranAmount = string.valueOf(TotalPaidAmmount );
                objOnlinePayment.TranTrackid = strTranTrackid;
                objOnlinePayment.strPaymentType = 'Admission';
                objOnlinePayment.strEmailId = objAccount.PersonEmail;
                objOnlinePayment.strMobileNumber = objAccount.PersonMobilePhone;
                objOnlinePayment.strAddress = AccountId+'_'+strSelectedSem;
                
                
                string strPaymentResponse = objOnlinePayment.MakePayment();
                system.debug('NRAC:::::2222::::'+objOnlinePayment);
                
                system.debug('NRAC:::::1::::2'+strPaymentResponse);
                if(strPaymentResponse != null && strPaymentResponse != '')            
                {    
                    system.debug('NRAC:::::2');
                    
                    objPayment.nm_TransactionID__c = strTranTrackid;
                    system.debug('objPayment.nm_TransactionID__c'+objPayment.nm_TransactionID__c);
                    if(strPaymentResponse != null && strPaymentResponse.split(':').size() > 1)
                    {
                        system.debug('NRAC:::::3');
                        
                        String strPaymentId = strPaymentResponse.split(':https:')[0];
                        String strPaymentUrl = 'https:'+strPaymentResponse.split(':https:')[1];
                        
                        //Commented by Neeraj 11 June
                        //CreateRecords();
                        
                        system.debug(strPaymentUrl+'?PaymentID='+strPaymentId);
                        return new PageReference(strPaymentUrl+'?PaymentID='+strPaymentId);
                    }
                    else
                        return null;
                }
                else
                {
                    return null;
                }              
            }
              
            return null;            
        }
        else
        {
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Payment method not selected!'));
            return null;    
        }   
    }
    
    public string MakePaymentAfterResponse(string strResTranId, string strPaymentTrackId,String strPaymentId, String strResResult, String strErrorText,String strErrorNo)
    {
                
        //11-july-2014 Coded by Sumit Kumar Banarji//////////////////
        if(strSelectedSem == 'full')
        {
            TotalPaidAmmount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            TotalPaidAmmount = yearFeeAmount;
        }
        else 
        {
            TotalPaidAmmount = semFeeAmount;
        }
        ////////////////////////////////////////////////////////////
        
        objPayment.nm_ModeOfPayment__c = 'Online';
        
        system.debug('objPayment.nm_ModeOfPayment__c ::::' + objPayment.nm_ModeOfPayment__c);
        system.debug('NRAC:::::10::'+TotalPaidAmmount ); 
        
        if(TotalPaidAmmount > 0)
        {         
            system.debug('NRAC:::::11::'+TotalPaidAmmount ); 
            
            objPayment.nm_Amount__c = TotalPaidAmmount ;
            objPayment.nm_TransactionDate__c = Date.today();
            objPayment.nm_TransactionID__c = strResTranId;
            objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
            objPayment.Online_Payment_Id__c = strPaymentId;
            objPayment.nm_PaymentGatewayResponse__c = strResResult;
            objPayment.Online_Response_Error__c = strErrorText;
            objPayment.nm_Error_Code__c=strErrorNo;
            
            error = strResResult;
            System.debug('error++++'+error);
            //12-july-2014  Sumit Banarji //////////////////
            if(strSelectedSem == 'full')
            {
                upsert lstAllOpportunity;
                CreatePaymentRecordsForOnlinePayment(lstAllOpportunity);
            }
            else
            {
                CreateRecordsForOnlinePayment();
            } 
            ////////////////////////////////////////////
            return strPaymentIdToPassResponsePage; 
                    
        }
              
        return null;  
    }
    
    public pageReference CreateRecordsForChaalan_DemandDraft()
    {   
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();       
        
        string strIncludedOpp = '';
        
        strIncludedOpp = strIncludedOpp + objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                         objStudentProgram.nm_program__r.name + '_Sem' + objOpportunity1.nm_Semester__c + '_' + objOpportunity1.nm_Session__c + '_' 
                          + string.valueof(objOpportunity1.nm_Year__c) ;
                          
        if(strSelectedSem == 'yearly')
        {
           strIncludedOpp = strIncludedOpp + '\n  '+ objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                             objStudentProgram.nm_program__r.name + '_Sem' + objOpportunity1.nm_Semester__c + '_' + objOpportunity2.nm_Session__c + '_' 
                             + string.valueof(objOpportunity2.nm_Year__c);
        }
        
        system.debug('testtt'+objOpportunity1);
        if(strSelectedSem != 'yearly') 
        {
            nm_Payment__c objPaymentToInsert1 = new nm_Payment__c(); 
                
            objPaymentToInsert1 = objPayment.clone();
            objPaymentToInsert1.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert1.nm_PaymentType__c = 'Admission';
            objPaymentToInsert1.nm_OpportunityNew__c = objOpportunity1.id;
            objPaymentToInsert1.nm_PaymentStatus__c = 'Payment Made';        
            objPaymentToInsert1.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert1.nm_ActualPaymentAmmount__c = semFeeAmount;
            objPaymentToInsert1.nm_Amount__c = objOpportunity1.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert1);
        }   
        system.debug('strSelectedSem'+strSelectedSem);
        if(strSelectedSem == 'yearly')
        {
            insert objOpportunity2;
            
            nm_Payment__c objPaymentToInsert1 = new nm_Payment__c(); 
                
            objPaymentToInsert1 = objPayment.clone();
            objPaymentToInsert1.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert1.nm_PaymentType__c = 'Admission';
            objPaymentToInsert1.nm_OpportunityNew__c = objOpportunity1.id;
            objPaymentToInsert1.nm_PaymentStatus__c = 'Payment Made';        
            objPaymentToInsert1.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert1.nm_ActualPaymentAmmount__c = yearFeeAmount;
            objPaymentToInsert1.nm_Amount__c = objOpportunity1.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert1);
            
            nm_Payment__c objPaymentToInsert2 = new nm_Payment__c(); 
            objPaymentToInsert2 = objPayment.clone();
            objPaymentToInsert2.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert2.nm_PaymentType__c = 'Admission';
            objPaymentToInsert2.nm_OpportunityNew__c = objOpportunity2.id;           
            objPaymentToInsert2.nm_PaymentStatus__c = 'Payment Made';                   
            objPaymentToInsert2.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert2.nm_ActualPaymentAmmount__c = yearFeeAmount;
            objPaymentToInsert2.nm_Amount__c = objOpportunity2.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert2);
        }
        
        if(lstPaymentToInsert.size() > 0)
        {
            insert lstPaymentToInsert;
            
            string strPaymentID = '';
            for(nm_Payment__c objPayment : lstPaymentToInsert)
            {
                strPaymentID += objPayment.id + ';';
            }
            
            list<nm_Payment__c> lstPaymentwithID = new  list<nm_Payment__c>();
            for(nm_Payment__c objPayment : lstPaymentToInsert)
            {
                objPayment.nm_IncludedPaymentID__c = strPaymentID;
                lstPaymentwithID.add(objPayment);
            }
            if(lstPaymentwithID.size()>0)
             update lstPaymentwithID;
        }
        
        strPaymentIdToPassResponsePage = lstPaymentToInsert[0].id;
        
        return new pageReference('/nmThankYou?PaymentId='+lstPaymentToInsert[0].id);
    }     
    
    public pageReference CreateRecordsForOnlinePayment()
    {    
       
        System.debug('error++++'+error);
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
       
        
        string strIncludedOpp = '';
        
        strIncludedOpp = strIncludedOpp + objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                         objStudentProgram.nm_program__r.name + '_Sem' + objOpportunity1.nm_Semester__c + '_' + objOpportunity1.nm_Session__c + '_' 
                          + string.valueof(objOpportunity1.nm_Year__c) ;
        System.debug('strIncludedOpp++++'+strIncludedOpp);                  
        if(strSelectedSem == 'yearly')
        {
           strIncludedOpp = strIncludedOpp + '\n  '+ objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                             objStudentProgram.nm_program__r.name + '_Sem' + objOpportunity1.nm_Semester__c + '_' + objOpportunity2.nm_Session__c + '_' 
                             + string.valueof(objOpportunity2.nm_Year__c);
        }
        
        
        if(strSelectedSem != 'yearly') 
        {
            nm_Payment__c objPaymentToInsert1 = new nm_Payment__c(); 
                
            objPaymentToInsert1 = objPayment.clone();
            objPaymentToInsert1.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert1.nm_PaymentType__c = 'Admission';
            objPaymentToInsert1.nm_OpportunityNew__c = objOpportunity1.id;
            objPaymentToInsert1.udf4response__c = udf4response;
            
            if(error == 'CAPTURED')
            {
                objPaymentToInsert1.nm_PaymentStatus__c = 'Payment Made';                
            }
            else if(error =='NOT CAPTURED')
            {
                objPaymentToInsert1.nm_PaymentStatus__c = 'Transaction Failed';
            }
            objPaymentToInsert1.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert1.nm_ActualPaymentAmmount__c = semFeeAmount;
            objPaymentToInsert1.nm_Amount__c = objOpportunity1.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert1);
        }   
        system.debug('strSelectedSem'+strSelectedSem);
        if(strSelectedSem == 'yearly')
        {
            insert objOpportunity2;
            
            nm_Payment__c objPaymentToInsert1 = new nm_Payment__c(); 
                
            objPaymentToInsert1 = objPayment.clone();
            objPaymentToInsert1.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert1.nm_PaymentType__c = 'Admission';
            objPaymentToInsert1.nm_OpportunityNew__c = objOpportunity1.id;
            objPaymentToInsert1.udf4response__c = udf4response;
            if(error == 'CAPTURED')
            {
                objPaymentToInsert1.nm_PaymentStatus__c = 'Payment Made';                
            }
            else if(error =='NOT CAPTURED')
            {
                objPaymentToInsert1.nm_PaymentStatus__c = 'Transaction Failed';
            }
            objPaymentToInsert1.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert1.nm_ActualPaymentAmmount__c = yearFeeAmount;
            objPaymentToInsert1.nm_Amount__c = objOpportunity1.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert1);
            
            nm_Payment__c objPaymentToInsert2 = new nm_Payment__c(); 
            objPaymentToInsert2 = objPayment.clone();
            objPaymentToInsert2.nm_ModeOfPayment__c = paymentMode();
            objPaymentToInsert2.nm_PaymentType__c = 'Admission';
            objPaymentToInsert2.nm_OpportunityNew__c = objOpportunity2.id;
            objPaymentToInsert2.udf4response__c = udf4response;
            if(error == 'CAPTURED')
            {
                objPaymentToInsert2.nm_PaymentStatus__c = 'Payment Made';                
            }
            else if(error =='NOT CAPTURED')
            {
                objPaymentToInsert2.nm_PaymentStatus__c = 'Transaction Failed';
            }
            objPaymentToInsert2.nm_IncludedOpportunities__c = strIncludedOpp;
            objPaymentToInsert2.nm_ActualPaymentAmmount__c = yearFeeAmount;
            objPaymentToInsert2.nm_Amount__c = objOpportunity2.PendingAmmount__c;
            
            lstPaymentToInsert.add(objPaymentToInsert2);
        }
        
        if(lstPaymentToInsert.size() > 0)
        {
            insert lstPaymentToInsert;
            
            string strPaymentID = '';
            for(nm_Payment__c objPayment : lstPaymentToInsert)
            {
                strPaymentID += objPayment.id + ';';
            }
            
            list<nm_Payment__c> lstPaymentwithID = new  list<nm_Payment__c>();
            for(nm_Payment__c objPayment : lstPaymentToInsert)
            {
                objPayment.nm_IncludedPaymentID__c = strPaymentID;
                lstPaymentwithID.add(objPayment);
            }
            if(lstPaymentwithID.size()>0)
             update lstPaymentwithID;
        }
        
        strPaymentIdToPassResponsePage = lstPaymentToInsert[0].id;
        
        return new pageReference('/nmThankYou?PaymentId='+lstPaymentToInsert[0].id);
    }
    
    public string paymentMode()
    {
        system.debug('strPaymentMethod :::::'+ strPaymentMethod );
        
        if(strPaymentMethod == 'challan')
            return 'challan';
        if(strPaymentMethod == 'demanddraft')
            return 'Demand Draft';
        else if(strPaymentMethod == 'online')
            return 'Online';
        else return null;
    }
    
    public void showHideOperations()
    {
        System.debug(strOperationSelected );
        if(strOperationSelected != null && strOperationSelected !='')
        {
            
            if(strOperationSelected == 'UPLOAD_DOCUMENTS') 
            {
                if(AccountID != null)
                    strSectionToShow = 'pnlDocument';
                else
                {
                    strInformation = 'Please login to upload documents.';
                    strSectionToShow = 'information';
                }
            }
            else if(strOperationSelected == 'MAKE_PAYMENT')
            {
                System.debug(AccountID);
                list<Account> lstAccountToCheck = [Select id, nmTotalDocuments__c, nmTotalApprovedDocuments__c, Total_Is_Provisional_Documents__c, nm_StudentStatus__c,
                                                          Total_Non_Applicable_Documents__c from Account where id =: AccountID];
                System.debug(lstAccountToCheck );
                if(lstAccountToCheck.size() > 0)
                { 
                    System.debug(lstAccountToCheck[0].nm_StudentStatus__c);
                    if(lstAccountToCheck[0].nm_StudentStatus__c == 'Admission Form & Documents Provisional' || (lstAccountToCheck[0].nmTotalDocuments__c == (lstAccountToCheck[0].nmTotalApprovedDocuments__c + lstAccountToCheck[0].Total_Is_Provisional_Documents__c + lstAccountToCheck[0].Total_Non_Applicable_Documents__c)))  
                    {              
                        try
                        {
                            LoadData();
                        }
                        catch(Exception ex)
                        {
                            system.debug('Exception::::'+ex.getmessage());
                        }
                        strSectionToShow = 'pnlPayment';
                    }
                    else
                    {
                        strInformation = 'You cannot make payment if documents are pending for approval.';
                        strSectionToShow = 'information';
                    }
                }
                else
                {
                    strInformation = 'Please login to make payment.';
                    strSectionToShow = 'information';
                }
            }
            else if(strOperationSelected == 'PRINT_FORM')
            {
                if(AccountID != null)
                    strSectionToShow = 'pnlPrintform';
                else
                {
                    strInformation = 'Please login to print.';
                    strSectionToShow = 'information';
                }
            }
        } 
    }
    
    public void GenChallan()
    {
         if(strSelectedSem == 'full')
        {
            nmCommon objCommon = new nmCommon();
            string strChlnNo = string.valueof(objCommon.generateChallan());
                
            for(integer i = strChlnNo.length(); i<6; i++)
                strChlnNo = '0'+strChlnNo;
            strurl = 'apex/nmBankChalan?Amount=' + fullFeeAmount + '&id=' + AccountId + '&type=Account&challan=' + strChlnNo +'&FeeType=Program Fee (Full fee):' ;
        }
        else if(strSelectedSem == 'yearly')
        {
            nmCommon objCommon = new nmCommon();
            string strChlnNo = string.valueof(objCommon.generateChallan());
                
            for(integer i = strChlnNo.length(); i<6; i++)
                strChlnNo = '0'+strChlnNo;
            strurl = 'apex/nmBankChalan?Amount=' + yearFeeAmount + '&id=' + AccountId + '&type=Account&challan=' + strChlnNo +'&FeeType=Program Fee (Full fee):' ;
        }
        else 
        {
            nmCommon objCommon = new nmCommon();
            string strChlnNo = string.valueof(objCommon.generateChallan());
                
            for(integer i = strChlnNo.length(); i<6; i++)
                strChlnNo = '0'+strChlnNo;
            strurl = 'apex/nmBankChalan?Amount=' + semFeeAmount + '&id=' + AccountId + '&type=Account&challan=' + strChlnNo +'&FeeType=Program Fee (Semester wise):' ;
        }
        
    }
    
    public void PrintForm()
    {
        showpage = true ;
    }
    
    public void ShowEMI()
    {
        System.debug('strSelectedSem '+strSelectedSem );
        System.debug('strPaymentMethod'+strPaymentMethod);
        strSectionToShow ='emi';    
    }
    
    //Method to create payment record of all opportunity
    public pageReference CreatePaymentRecordsForOnlinePayment(list<Opportunity> lstOppForPayment)
    {
        System.debug('error+++'+error);
        //list of payment records to insert
        list<nm_Payment__c> lstPayment = new list<nm_Payment__c>();
        //String of Included Opportunities in one payment
        string strIncOpp = '';
        for(Opportunity objOpp: lstOppForPayment)
        {
            strIncOpp = strIncOpp + objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                        objStudentProgram.nm_program__r.name + '_Sem_' + objOpp.nm_Semester__c + '_' + objOpp.nm_Session__c + '_' 
                        + string.valueof(objOpp.nm_Year__c) +'\n  ';           
        }
        
        for(Opportunity objOpp: lstOppForPayment)
        {
            if(objOpp.id != null)
            {
                //New object of payment to insert in list of records
                nm_Payment__c objPaymentToInsert = objPayment.clone();
                
                objPaymentToInsert.nm_PaymentType__c = 'Admission';
                objPaymentToInsert.nm_OpportunityNew__c = objOpp.id;
                if(error !='')
                {
                    objPaymentToInsert.nm_PaymentStatus__c = 'Payment Made';
                }
                else
                {
                    objPaymentToInsert.nm_PaymentStatus__c = 'Transaction Failed';
                }
                objPaymentToInsert.udf4response__c = udf4response;
                //objPaymentToInsert.nm_PaymentStatus__c = 'Payment Made';
                objPaymentToInsert.nm_IncludedOpportunities__c = strIncOpp;
                objPaymentToInsert.nm_ActualPaymentAmmount__c = TotalPaidAmmount;
                objPaymentToInsert.nm_Amount__c = objOpp.PendingAmmount__c;
                
                //Adding in list of Payment records
                lstPayment.add(objPaymentToInsert);
            }
            
        }
        //inserting payment records
        if(lstPayment != null && lstPayment.size()>0)
        insert lstPayment;
        
        string strIncludedID;
        for(nm_Payment__c objPayment : lstPayment)
        {
            if(strIncludedID == null)
                strIncludedID = objPayment.id;
            else
                strIncludedID += ';' + objPayment.id;
        }
        
        list<nm_Payment__c> lstPaymentToUpdate = new list<nm_Payment__c>();
        for(nm_Payment__c objPayment : lstPayment)
        {
            nm_Payment__c objPaymentToUpdate = new nm_Payment__c(id = objPayment.id);
            objPaymentToUpdate.nm_IncludedPaymentID__c = strIncludedID;
            lstPaymentToUpdate.add(objPaymentToUpdate);
        }
        
        if(lstPaymentToUpdate != null && lstPaymentToUpdate.size() > 0)
            update lstPaymentToUpdate;
            
        
        strPaymentIdToPassResponsePage = lstPaymentToUpdate[0].id;
        
        return new pageReference('/nmThankYou?PaymentId='+lstPaymentToUpdate[0].id);
    }
    
    //Method to create payment record of all opportunity
    public pageReference CreatePaymentRecordsForChaalan_DemandDraft(list<Opportunity> lstOppForPayment)
    {
        System.debug('error+++'+error);
        //list of payment records to insert
        list<nm_Payment__c> lstPayment = new list<nm_Payment__c>();
        //String of Included Opportunities in one payment
        string strIncOpp = '';
        for(Opportunity objOpp: lstOppForPayment)
        {
            strIncOpp = strIncOpp + objStudentProgram.nm_Student__r.firstName + '_' + objStudentProgram.nm_Student__r.lastname + '_' + 
                        objStudentProgram.nm_program__r.name + '_Sem_' + objOpp.nm_Semester__c + '_' + objOpp.nm_Session__c + '_' 
                        + string.valueof(objOpp.nm_Year__c) +'\n  ';           
        }
        
        for(Opportunity objOpp: lstOppForPayment)
        {
            if(objOpp.id != null)
            {
                //New object of payment to insert in list of records
                nm_Payment__c objPaymentToInsert = objPayment.clone();
                
                objPaymentToInsert.nm_PaymentType__c = 'Admission';
                objPaymentToInsert.nm_OpportunityNew__c = objOpp.id;               
                objPaymentToInsert.nm_PaymentStatus__c = 'Payment Made';
                objPaymentToInsert.nm_IncludedOpportunities__c = strIncOpp;
                objPaymentToInsert.nm_ActualPaymentAmmount__c = TotalPaidAmmount;
                objPaymentToInsert.nm_Amount__c = objOpp.PendingAmmount__c;
                
                //Adding in list of Payment records
                lstPayment.add(objPaymentToInsert);
            }
            
        }
        //inserting payment records
        if(lstPayment != null && lstPayment.size()>0)
        insert lstPayment;
        
        string strIncludedID;
        for(nm_Payment__c objPayment : lstPayment)
        {
            if(strIncludedID == null)
                strIncludedID = objPayment.id;
            else
                strIncludedID += ';' + objPayment.id;
        }
        
        list<nm_Payment__c> lstPaymentToUpdate = new list<nm_Payment__c>();
        for(nm_Payment__c objPayment : lstPayment)
        {
            nm_Payment__c objPaymentToUpdate = new nm_Payment__c(id = objPayment.id);
            objPaymentToUpdate.nm_IncludedPaymentID__c = strIncludedID;
            lstPaymentToUpdate.add(objPaymentToUpdate);
        }
        
        if(lstPaymentToUpdate != null && lstPaymentToUpdate.size() > 0)
            update lstPaymentToUpdate;
            
        
        strPaymentIdToPassResponsePage = lstPaymentToUpdate[0].id;
        
        return new pageReference('/nmThankYou?PaymentId='+lstPaymentToUpdate[0].id);
    }    
    //////////////////////////////////////////////////////////
    
    public void GetEmi()
    {        
        System.debug('strSelectedSem'+strSelectedSem );
        showpanel1 = true;
        showpanel2 = false ;
        show1=false;
        show2=false;       
    }
    
    public void GetEmi1()
    {       
        
        show2=false;
        show3 = true;
        System.debug('show1+++'+show1); 
        System.debug('show2+++'+show2);
        System.debug('strSelectedSem'+strSelectedSem );
        if(strSelectedSem == 'full')
        {
            Amount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            Amount= yearFeeAmount;
        }
        else if(strSelectedSem != 'yearly') 
        {
            Amount= semFeeAmount;
        }
        System.debug('Amount'+Amount);
        
        lstInstallments = [select id ,
                                  Duration__c,
                                  Loan_Amount__c,
                                  Interest_Annual__c,
                                  EMI__c,
                                  Interest_paid_to_Bank__c,
                                  Total_Cost__c 
                                  from Installments__c
                                  where Loan_Amount__c =: String.valueof(Amount)
                                  order by Duration__c ];
        System.debug('lstInstallments+'+lstInstallments);
        if(lstInstallments.size()>0)
        {
            show1=true;
        }
        
       
        
        
       
    }
    
    public void GetEmi2()
    {
        
        show1=false;
        show2=true; 
        show3 = true;     
        System.debug('show1+++'+show1); 
        System.debug('show2+++'+show2);
        System.debug('show1+++'+show1); 
        System.debug('show2+++'+show2);
        System.debug('strSelectedSem'+strSelectedSem );
        if(strSelectedSem == 'full')
        {
            Amount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            Amount= yearFeeAmount;
        }
        else if(strSelectedSem != 'yearly') 
        {
            Amount= semFeeAmount;
        }
        System.debug('Amount'+Amount);
        
        lstInstallments = [select id ,
                                  Duration__c,
                                  Loan_Amount__c,
                                  Interest_Annual__c,
                                  EMI__c,
                                  Interest_paid_to_Bank__c,
                                  Total_Cost__c 
                                  from Installments__c
                                  where Loan_Amount__c =: String.valueof(Amount)
                                  order by Duration__c ];
        System.debug('lstInstallments+'+lstInstallments);
        
        
        
    }
    
    public pagereference MakeEmiPayment()
    {
        System.debug(selectedduration);
        System.debug('strSelectedSem'+strSelectedSem );
        if(strSelectedSem == 'full')
        {
            Amount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            Amount= yearFeeAmount;
        }
        else if(strSelectedSem != 'yearly') 
        {
            Amount= semFeeAmount;
        }
        System.debug('Amount+++'+Amount);
        
        if(Amount !=null && (selectedduration !=null && selectedduration!=''))
        {
            TotalPaidAmmount = Amount ;
            system.debug('NRAC:::::11::'+TotalPaidAmmount );             
            objPayment.nm_Amount__c = TotalPaidAmmount ;
            objPayment.nm_TransactionDate__c = Date.today();
            //Creating payment tracking Id. 
            string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
                   
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            if(selectedduration !=null && selectedduration !='')
            {
                objOnlinePayment.duration = selectedduration ;
            }           
            if(objOnlinePayment.strPortalId != ''  &&  objOnlinePayment.strPassword != '')
            {       
                objOnlinePayment.TranAmount = string.valueOf(TotalPaidAmmount );
                objOnlinePayment.TranTrackid = strTranTrackid;
                objOnlinePayment.strPaymentType = 'Admission';
                objOnlinePayment.strEmailId = objAccount.PersonEmail;
                objOnlinePayment.strMobileNumber = objAccount.PersonMobilePhone;
                objOnlinePayment.strAddress = AccountId+'_'+strSelectedSem+'_'+selectedduration;
                
                
                string strPaymentResponse = objOnlinePayment.MakePayment();
                system.debug('NRAC:::::2222::::'+objOnlinePayment);
                system.debug('NRAC:::::1::::2'+strPaymentResponse);
                if(strPaymentResponse != null && strPaymentResponse != '')            
                {    
                    system.debug('NRAC:::::2');
                    
                    objPayment.nm_TransactionID__c = strTranTrackid;
                    system.debug('objPayment.nm_TransactionID__c'+objPayment.nm_TransactionID__c);
                    if(strPaymentResponse != null && strPaymentResponse.split(':').size() > 1)
                    {
                        system.debug('NRAC:::::3');
                        
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
            }
        }    
        
        return null;
    }       
       
    public pagereference MakeFullPayment()
    {       
        System.debug('strSelectedSem'+strSelectedSem );
        selectedduration = 'Full' ;
        if(strSelectedSem == 'full')
        {
            Amount = fullFeeAmount;
        }
        else if(strSelectedSem == 'yearly')
        {
            Amount= yearFeeAmount;
        }
        else if(strSelectedSem != 'yearly') 
        {
            Amount= semFeeAmount;
        }
        System.debug('Amount+++'+Amount);
        System.debug('selectedduration++++'+selectedduration);
        if(Amount !=null )
        {
            System.debug(selectedduration);
            TotalPaidAmmount = Amount ;
            system.debug('NRAC:::::11::'+TotalPaidAmmount );             
            objPayment.nm_Amount__c = TotalPaidAmmount ;
            objPayment.nm_TransactionDate__c = Date.today();
            //Creating payment tracking Id. 
            string strTranTrackid = datetime.now().year()+''+datetime.now().month()+''+datetime.now().day()+''+datetime.now().hour()+''+datetime.now().minute()+''+datetime.now().second();//'2014530163144';//
                   
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();          
            objOnlinePayment.duration = selectedduration ;      
            objOnlinePayment.TranAmount = string.valueOf(TotalPaidAmmount );
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.strPaymentType = 'Admission';
            objOnlinePayment.strEmailId = objAccount.PersonEmail;
            objOnlinePayment.strMobileNumber = objAccount.PersonMobilePhone;
            //objOnlinePayment.strAddress = AccountId+'_'+strSelectedSem+'_'+selectedduration;
            objOnlinePayment.strAddress = AccountId+'_'+strSelectedSem+'_'+selectedduration ;
            
            
            string strPaymentResponse = objOnlinePayment.MakePayment();
            system.debug('NRAC:::::2222::::'+objOnlinePayment);
            system.debug('NRAC:::::1::::2'+strPaymentResponse);
            if(strPaymentResponse != null && strPaymentResponse != '')            
            {    
                system.debug('NRAC:::::2');
                
                objPayment.nm_TransactionID__c = strTranTrackid;
                system.debug('objPayment.nm_TransactionID__c'+objPayment.nm_TransactionID__c);
                if(strPaymentResponse != null && strPaymentResponse.split(':').size() > 1)
                {
                    system.debug('NRAC:::::3');
                    
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
        }    
        
        return null;
    }
    
    public void Back()
    {
        showpanel1 = false;
        showpanel2 = true;
        show1=false;
        show2=false;
    }
}