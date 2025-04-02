public without sharing class MassFeeReceiptController {
    public String startingNumber{get;set;}
    public String endingNumber{get;set;}
    public String ListReceiptNumber{get;set;}
    public List<string> lstInvalidFeeReceipt{get;set;}
    public List<nm_Payment__c> lstpayment{get;set;}
    public List<nm_Payment__c> lstPaymentToAdd{get;set;}
    public List<nm_Payment__c> lstPaymentToUpdate{get;set;}
    public boolean Fault;
    public nm_Payment__c objPayment{get;set;}
    public String Numbers;
    public List<String> individualReceiptNo;
    public Map<String,Decimal> mapOfStudnetKit {get;set;} 
    public Map<String,Decimal> mapOfServiceTax {get;set;} 
    public Map<String,Decimal> mapOfLateFees {get;set;}
    public Map<String,Decimal> mapOfTotalAmount {get;set;}
    public Map<String,Decimal> mapOfSemesterProduct {get;set;}
    public Map<String,Decimal> mapOfICAndProgramChangeProduct {get;set;}
    public Map<String,String> mapOfcurrencytowords {get;set;}
    public String strState{get;set;}
     
    public MassFeeReceiptController()
    {
        ListReceiptNumber ='';
        Numbers ='';
        lstPaymentToUpdate =new List<nm_Payment__c>();
        lstpayment =new List<nm_Payment__c>();
        objPayment =new nm_Payment__c();
        lstPaymentToAdd = new List<nm_Payment__c>();
        mapOfStudnetKit =new map<String,Decimal>();
        mapOfServiceTax =new map<String,Decimal>();
        mapOfICAndProgramChangeProduct  = new map<String,Decimal>();
        lstInvalidFeeReceipt=new list<string>();
        Fault=false;
        mapOfLateFees =new map<String,Decimal>();
        mapOfSemesterProduct  =new map<String,Decimal>();
        mapOfTotalAmount  =new map<String,Decimal>();
        mapOfcurrencytowords =new map<String,String>();
        strState = '';
    }

    public PageReference search()
    {
        String View='DownloadMethod';
        FindRecordsUsingReceiptNo(View);
        if(Fault)
        {
            System.debug('Enter in loop of Fault---->');
            return null;
        }
        return Page.nmFeeTest;
        return null;
    }
    
    public PageReference View()
    {
        String View='ViewMethod';
        FindRecordsUsingReceiptNo(View);
        return null;
    }

    public void FindRecordsUsingReceiptNo(String MethodName)
    {
       Fault=false;
       integer counter = 0;
       integer successCount = 0;
       integer BATCH_SIZE = 5;
       set<String> setOfOppsId =new set<String>();
       if(ListReceiptNumber =='')
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Receipt No should not be empty');
           ApexPages.addMessage(myMsg); 
           Fault=true;
        }
       else if(ListReceiptNumber !='')
        {
            
            Numbers = ListReceiptNumber;
           lstpayment.clear();
           lstPaymentToAdd.clear();
           lstPaymentToUpdate.clear();
           setOfOppsId.clear();
           lstInvalidFeeReceipt.clear();
           System.debug('<----------------------------------Numbers----------->'+Numbers);
           List<String> individualReceiptNo = Numbers.Split(',');
            for(String num :individualReceiptNo)
            {
                lstPaymentToAdd = [select id,Name, nm_OpportunityNew__c,nm_OpportunityNew__r.nm_Program__r.nm_Type__c,nm_OpportunityNew__r.nm_Category__c,nm_OpportunityNew__r.Is_Re_Registration_Payment__c,Program_Name__c,Semester_Line_Item__c,nm_TransactionID__c,nm_ModeOfPayment__c,IcChangeFee__c,ProgramChangeFee__c,
                nm_Merchant_Track_Id__c,nm_DemandDraftDate__c,nm_TransactionDate__c,CityWithState__c,Currency_To_Words__c,Tuition_Fees__c,nm_OpportunityNew__r.Account.IC_Name__c,
                nm_OpportunityNew__r.Sum__c,Registration_Fee__c,nm_OpportunityNew__r.nm_Semester__c,Receipt_Number__c,
                nm_OpportunityNew__r.Academic_Year__c,nm_OpportunityNew__r.Account.nm_StudentNo__c,nm_OpportunityNew__r.Account.Ref__c ,nm_PaymentStatus__c,nm_PaymentType__c,
                 nm_OpportunityNew__r.Account.Name,nm_OpportunityNew__r.Account.Salutation,nm_OpportunityNew__r.nm_Program__r.Fee_Program__c,nm_OpportunityNew__r.Account.LC_Name__c,nm_OpportunityNew__r.Account.nmStudent_Program__c,nm_SAPTransactionDate__c,
                 nm_OpportunityNew__r.nm_InformationCenters__r.nm_LearningCenter__r.nm_CenterCity__c,nm_BankLocation__c,ExportFeeReceipt__c,
                 nm_DemandDraftNumber__c,nm_SAPDDDate__c,nm_NameoftheBank__c,nm_OpportunityNew__r.nm_LateFee__c from nm_Payment__c
                where  Receipt_Number__c =:num and nm_PaymentStatus__c='Payment Approved' and nm_PaymentType__c='Admission'];
                if(lstPaymentToAdd.size()>0)
                {
                    
                    if(lstPaymentToAdd[0].ExportFeeReceipt__c)
                    {
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,' Fee Receipt For This Payment Record Already Generated'+' '+num);
                          ApexPages.addMessage(myMsg);
                          lstInvalidFeeReceipt.add(num);
                          Fault=true;
                    }
                    else
                    {      
                          lstpayment.addAll(lstPaymentToAdd);
                    }
                }
                else
                {    
                    lstInvalidFeeReceipt.add(num); 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,' No Such a Fee Receipt Number Found'+' '+num);
                    ApexPages.addMessage(myMsg);
                }
           } 
           System.debug('Method name----->'+MethodName);
            if(lstpayment.size()>0)
            {
               for(nm_Payment__c objPayment :lstpayment)
                {  
                     nm_Payment__c objPaymentUpdate =new nm_Payment__c(id=objPayment.id);
                     setOfOppsId.add(objPayment.nm_OpportunityNew__c);
                     List<String> lstOfIds =new List<String>(setOfOppsId);
                     currencytowords cwObj = new currencytowords();
                     objPaymentUpdate.ExportFeeReceipt__c =true;
                     objPaymentUpdate.Export_Date_Time__c= datetime.now();
                     objPaymentUpdate.Currency_To_Words__c = cwObj.convert(integer.valueOf(objPayment.Semester_Line_Item__c));
                            
                    if(MethodName=='DownloadMethod' && !Fault)
                    {
                       lstPaymentToUpdate.add(objPaymentUpdate);
                       counter++;
                       System.debug('Value of Counter---->'+counter);
                       if(counter == BATCH_SIZE)
                        {
                           System.debug('Value of Counter---->'+counter);
                            try
                            {
                              update lstPaymentToUpdate;
                              System.debug('Enter in Update Loop----->'+lstPaymentToUpdate);
                            }
                            catch(Exception e)
                            {
                                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+e);
                                 ApexPages.addMessage(myMsg);
                            } 
                            counter=0;
                        }
                    }  
                } 
                if(setOfOppsId.size()>0)
                {
                    // call a method to update map on page for student kit ,Late fee ,Total Amount and Currency to Word
                    UpdateMaponPage(setOfOppsId);
                }
                if(lstPaymentToUpdate.size()>0) //update remaining records
                {
                    System.debug('Enter In remaining Method');
                    update lstPaymentToUpdate;
                } 
            }
        }  
    }
    public Pagereference RemoveError()
    {
      ListReceiptNumber =ListReceiptNumber+',';
      for(string num:lstInvalidFeeReceipt)
      {
        ListReceiptNumber=ListReceiptNumber.remove(num+',');  
      }
      ListReceiptNumber=ListReceiptNumber.removeEnd(',');
      FindRecordsUsingReceiptNo('View');
      return null;
    
    }
    
    public void UpdateMaponPage(set<String> setOfOppsId)
    {
        decimal LateFees=0;
        decimal changeFee = 0;
        ProductHelper productHelper = new ProductHelper();
        Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = productHelper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
        
        currencytowords cwObj = new currencytowords();
        mapOfLateFees.clear();
        mapOfTotalAmount.clear();
        mapOfStudnetKit.clear();
        mapOfServiceTax.clear();
        mapOfSemesterProduct.clear();
        mapOfICAndProgramChangeProduct.clear();
        if(setOfOppsId.size()>0)
        {
            OpportunityLineItem objOpportunityLineItem =new OpportunityLineItem();
            List<String> lstOfIds =new List<String>(setOfOppsId);
            for(String OppsId : mapOfOppsIdVsOpportunityLineItem.keySet())
            {
                for(OpportunityLineItem lineItem : mapOfOppsIdVsOpportunityLineItem.get(OppsId))
                {
                    if(lineItem.Product_Name__c == 'Student Kits'){
                        mapOfStudnetKit.put(OppsId,lineItem.UnitPrice);
                    }else if(lineItem.Product_Name__c == 'Late Fee'){
                        if(!mapOfLateFees.containsKey(OppsId))
                        {
                            // Clear Late Fee Amount So that it will not added to next Record 
                            LateFees=0;
                        }
                        LateFees += lineItem.UnitPrice;
                        mapOfLateFees.put(OppsId,LateFees);
                    }else if(lineItem.Product_Name__c.contains('Semester')){
                        mapOfSemesterProduct.put(OppsId,lineItem.UnitPrice);
                    }else if(lineItem.Product_Name__c.contains('Certificate Service Tax')){
                        mapOfServiceTax.put(OppsId,lineItem.UnitPrice);
                    }else if(lineItem.Product_Name__c.contains('Change Fee')){
                        if(!mapOfICAndProgramChangeProduct.containsKey(OppsId))
                        {
                            // Clear IC/Program Change Amount So that it will not added to next Record 
                            changeFee =0;
                        }
                        changeFee += lineItem.UnitPrice;
                        mapOfICAndProgramChangeProduct.put(OppsId,changeFee );
                    }
                }
                
                mapOfTotalAmount.put(OppsId,mapOfSemesterProduct.get(OppsId));
                  
                if(mapOfStudnetKit.containsKey(OppsId)){
                    mapOfTotalAmount.put(OppsId,mapOfStudnetKit.get(OppsId) + mapOfTotalAmount.get(OppsId));
                }if(mapOfLateFees.containsKey(OppsId)){
                    mapOfTotalAmount.put(OppsId,mapOfLateFees.get(OppsId) + mapOfTotalAmount.get(OppsId));
                }if(mapOfServiceTax.containsKey(OppsId)){
                    mapOfTotalAmount.put(OppsId,mapOfServiceTax.get(OppsId) + mapOfTotalAmount.get(OppsId));
                }if(mapOfICAndProgramChangeProduct.containsKey(OppsId)){
                    mapOfTotalAmount.put(OppsId,mapOfICAndProgramChangeProduct.get(OppsId) + mapOfTotalAmount.get(OppsId));
                }
                mapOfcurrencytowords.put(OppsId,cwObj.convert(integer.valueOf(mapOfTotalAmount.get(OppsId))));
            }
            
            //loop  to Check if opportunity does not contains Student Kits Fees,Late Fees  Then insert zero Amount
            if(lstOfIds.size() >0)
            {
               System.debug('Enter in Loop Of else--->');
               for(String ids :lstOfIds)
               {
                    if(!mapOfStudnetKit.containsKey(ids))
                    {
                      mapOfStudnetKit.put(ids,0);
                    }
                    if(!mapOfLateFees.containsKey(ids))
                    {
                        mapOfLateFees.put(ids,0);
                    }
                    if(!mapOfTotalAmount.containsKey(ids))
                    {
                        mapOfTotalAmount.put(ids,0);
                    }
                    if(!mapOfcurrencytowords.containsKey(ids))
                    {
                        mapOfcurrencytowords.put(ids,'Zero');
                    }
               }     
            }
        }   
    }
}