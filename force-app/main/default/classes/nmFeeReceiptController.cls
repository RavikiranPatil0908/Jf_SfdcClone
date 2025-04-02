/**
 * @File Name          : nmFeeReceiptController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 8/31/2019, 11:17:53 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    8/31/2019   shubhranshu     Initial Version
**/
public without sharing class nmFeeReceiptController
{
    public string Paymentid {get;set;}
    public List<nm_Payment__c> listPayment {get;set;}
    public Decimal LateFees {get;set;}
    public String RegistrationNum{get;set;}
    public String Ref{get;set;}
    public String strName{get;set;}
    public String ICName{get;set;}
    public String Program{get;set;}
    public String Program2{get;set;}
    public String Salutation{get;set;}
    public String Session{get;set;}
    public String strYear{get;set;}
    public String strState{get;set;}
    public String currencyInWords {get;set;}
    public Decimal TuitionFees {get;set;}
    public Decimal LivelecFees {get;set;}
    public Decimal BacklogFee {get;set;}
    public Decimal ProgramChangeFees {get;set;}
    public Decimal ICChangeFees {get;set;}
    public Decimal TotalAmount {get;set;}
    public decimal StudentKitPrice{get;set;}
    public string ReceiptNumber{get;set;}
    public string TypeOfProgram{get;set;}
    public Decimal ServiceTax {get;set;}
    Public Date oppcCloseDate {get;set;}
    public Decimal WaviedOffAmount{get;set;}
    
    public String FeeType{get;set;}
    public Boolean IsTerm{get;set;}
    public String ProgramName{get;set;}
    
    public list<WrapperFeeReceipt> lstWrapperReceipt {get;set;}
    
    public Class WrapperFeeReceipt
    {
        public string DDNo{get;set;}
        public string DDDate{get;set;}
        public string bankname{get;set;}
        public string locationbank{get;set;}
        
   
        public WrapperFeeReceipt(string DDNo,string DDDate,string bankname,string locationbank)
        {
            this.DDNo=DDNo;
            this.DDDate=DDDate;
            this.bankname=bankname;
            this.locationbank=locationbank;
        }
    }
    
    public nmFeeReceiptController() 
    {
        listPayment = new List<nm_Payment__c>();
        LateFees =0;
        TuitionFees =0;
        LivelecFees=0;
        BacklogFee=0;
        StudentKitPrice =0;
        ReceiptNumber ='';
        ProgramChangeFees =0;
        ICChangeFees = 0;
        TotalAmount =0;
        WaviedOffAmount =0;
        ServiceTax=0;
        RegistrationNum ='';
        Ref='';
        strName='';
        ICName='';
        Program='';
        Program2='';
        strYear='';
        strState = '';
        Session='';                     
        currencyInWords = '';
        oppcCloseDate =null;

        FeeType='';
        IsTerm= false;
        ProgramName='';

        lstWrapperReceipt = new list<WrapperFeeReceipt>();
        Paymentid = apexpages.currentpage().getparameters().get('id');
        if(Paymentid !=null)
        {
            // call method to get Payment related data to show on Page
            GetData();
        }
    }
    
    public void GetData()
    {
        currencytowords ob = new currencytowords();
        List<nm_Payment__c> lstPayment =[select id,nm_Amount__c,nm_SAPDDDate__c,Semester_Line_Item__c,
                                        nm_Merchant_Track_Id__c,nm_ModeOfPayment__c,Receipt_Number__c,nm_SAPTransactionDate__c,nm_DemandDraftDate__c,
                                        nm_OpportunityNew__c,nm_BankLocation__c,nm_NameoftheBank__c,nm_ActualPaymentAmmount__c,nm_Lead__c,
                                        CityWithState__c,nm_DemandDraftNumber__c,nm_PaymentType__c,nm_PaymentStatus__c,nm_RefNo__c,nm_TransactionDate__c,nm_TransactionID__c,nm_OpportunityNew__r.nm_Program__r.nm_Type__c, nm_OpportunityNew__r.nm_Program__r.Name
                                           from nm_Payment__c
                                           where id=:Paymentid and nm_PaymentStatus__c ='Payment Approved'];
                                   
        if(lstPayment.size()>0)
        {
            listPayment.addAll(lstPayment);
           
            strState = listPayment[0].CityWithState__c;
           // TotalAmount =listPayment[0].Semester_Line_Item__c;
            ReceiptNumber =listPayment[0].Receipt_Number__c;
            nm_Payment__c objPayments =listPayment[0];
            if(objPayments.nm_ModeOfPayment__c=='Demand Draft')
            {
                    WrapperFeeReceipt objWrapper= new WrapperFeeReceipt(objPayments.nm_DemandDraftNumber__c,String.valueOf(objPayments.nm_SAPDDDate__c),objPayments.nm_NameoftheBank__c,objPayments.nm_BankLocation__c);
                    lstWrapperReceipt.add(objWrapper);
            }
           else if(objPayments.nm_Merchant_Track_Id__c!=null)
            {
                    WrapperFeeReceipt objWrapper= new WrapperFeeReceipt(objPayments.nm_Merchant_Track_Id__c,String.valueOf(objPayments.nm_SAPTransactionDate__c),objPayments.nm_NameoftheBank__c,objPayments.nm_BankLocation__c);
                    lstWrapperReceipt.add(objWrapper);
                    
            }else
            {
                   WrapperFeeReceipt objWrapper= new WrapperFeeReceipt(objPayments.nm_TransactionID__c,String.valueOf(objPayments.nm_SAPTransactionDate__c),objPayments.nm_NameoftheBank__c,objPayments.nm_BankLocation__c);
                    lstWrapperReceipt.add(objWrapper);
            } 
            Opportunity objopp=[select id, CloseDate,Specialisation__c, nm_Program2__c,Program2_Full_Name__c,nm_Semester__c,Academic_Year__c,Account.IC_Name__c,Account.LC_Name__c,WaivedOffAmount__c,Account.Ref__c,Account.Salutation, Account.nm_StudentNo__c,Sum__c,Amount,nm_LateFee__c,Account.Name, nm_ModeOfPayment__c,Account.nm_Centers__r.nm_LearningCenter__r.Name,nm_Year__c,nm_Session__c,nm_Program__r.Fee_Program__c,nm_Program__r.nm_Type__c, nm_Fee_Type__c, IsTerm__c, Program_Name__c
                               from Opportunity where id=:listPayment[0].nm_OpportunityNew__c];
           
            //section to Show String on Page
            if(objopp!=null)
            {
                if(objopp.Account.nm_StudentNo__c !=null)
                {
                    RegistrationNum=objopp.Account.nm_StudentNo__c;
                }
                if(objopp.Account.Ref__c !=null)
                {
                    Ref=objopp.Account.Ref__c;
                }
                
                if(objopp.Account.Name !=null)
                {
                    strName=objopp.Account.Name;
                }
                if(objopp.Account.LC_Name__c !=null || objopp.Account.LC_Name__c !='')
                {
                    ICName=objopp.Account.LC_Name__c;
                }
                if(objopp.Account.LC_Name__c ==null)
                {
                    ICName ='Mumbai';
                }
                if(objopp.Academic_Year__c!=null)
                {
                    strYear=String.ValueOf(objopp.Academic_Year__c);
                }
                if(objopp.nm_Semester__c !=null)
                {
                    Session='Semester'+objopp.nm_Semester__c;
                }
               /*if(objopp.Specialisation__c!=null && objopp.nm_Fee_Type__c !='AnnualFee' && (objopp.Specialisation__c.contains('MBA') || objopp.Specialisation__c.contains('M.Sc. (AI & ML Ops)')) )
                {
                    Session='All Semester';
                }*/
                if( ( objopp.Specialisation__c!=null && objopp.nm_Fee_Type__c =='FullFee'  && (objopp.Specialisation__c.contains('Professional Diploma Term 4')  || objopp.Specialisation__c.contains('PC Term 2')  || objopp.Specialisation__c.contains('PD Term 4') || objopp.Specialisation__c.contains('M.Sc. (AI)') || objopp.Specialisation__c.contains('M.Sc. (AI & ML Ops)')) && Integer.valueOf(objopp.nm_Semester__c) <5 ) )
                {
                    Session=' All Term';
                }
                if(objopp.nm_Fee_Type__c == 'MBAallTermfee' && objopp.Specialisation__c!=null) {
                    Session=' All Term';
                }
                 if(objopp.Specialisation__c!=null && objopp.nm_Fee_Type__c =='AnnualFee' && (objopp.Specialisation__c.contains('M.Sc. (AI)')  || objopp.Specialisation__c.contains('M.Sc. (AI & ML Ops)'))  && Integer.valueOf(objopp.nm_Semester__c) <5 )
                {
                    Session='First Year';
                }
                   if(objopp.Specialisation__c!=null && objopp.nm_Fee_Type__c =='AnnualFee' && ( objopp.Specialisation__c.contains('PD Term 4') )  )
                {
                    Session='2 Term';
                }  
                if(objopp.Specialisation__c!=null && objopp.nm_Fee_Type__c =='AnnualFee' && (objopp.Specialisation__c.contains('M.Sc. (AI)')  || objopp.Specialisation__c.contains('M.Sc. (AI & ML Ops)'))  && Integer.valueOf(objopp.nm_Semester__c) >2)
                {
                    Session='Second Year';
                }
                if(objopp.nm_Program__r.Fee_Program__c !=null)
                {
                    Program=objopp.nm_Program__r.Fee_Program__c;
                }
                if(objopp.Program2_Full_Name__c!=null)
                {
                    Program2 = ','+objopp.Program2_Full_Name__c;
                }
                if(objopp.Account.Salutation !=null)
                {
                    Salutation=objopp.Account.Salutation;
                }
                if(objopp.nm_Program__r.nm_Type__c != null)
                {
                    TypeOfProgram = objopp.nm_Program__r.nm_Type__c;
                }
                if(objopp.WaivedOffAmount__c != null)
                {
                  //  WaviedOffAmount = objopp.WaivedOffAmount__c;
                  WaviedOffAmount =(Decimal)[select sum(nm_Amount__c)waivedoff
                                                            from nm_Payment__c
                                                            where nm_OpportunityNew__c=:objopp.id 
                                                            and nm_PaymentStatus__c ='Waived Off' 
                                                            and nm_PaymentType__c like 'Late%' ][0].get('waivedoff'); 
                }
                if(objopp.CloseDate!= null){
                    
                     oppcCloseDate=objopp.CloseDate;
                }

                if(objopp.Program_Name__c!= null){
                    
                     ProgramName = objopp.Program_Name__c;
                }
                if(objopp.nm_Fee_Type__c!= null){
                    
                    FeeType = objopp.nm_Fee_Type__c;
                }
                if(objopp.IsTerm__c != null){
                    
                     IsTerm = objopp.IsTerm__c;
                }

            }
            
            // Section to Check Opportunity Line Item Related to Opportunity 
            list<OpportunityLineItem> lstOpportunityLineItem=[select product2.id,ProgramName2__c, PricebookEntry.Product2.Family,
                                                            Product_Name__c,UnitPrice,ActualSalePrice__c,
                                                            Quantity,OpportunityId
                                                            from OpportunityLineItem 
                                                            where OpportunityId=:objopp.id ];
            for(OpportunityLineItem objOppLine :lstOpportunityLineItem)
            {
                if(objOppLine.ProgramName2__c =='Miscellaneous Fee' )
                {
                    ICChangeFees = objOppLine.UnitPrice;
                    TotalAmount += ICChangeFees;
                }
                if(objOppLine.ProgramName2__c =='Program Change Fee')
                {
                    ProgramChangeFees =objOppLine.UnitPrice;
                    TotalAmount += ProgramChangeFees;
                }
                if(objOppLine.ProgramName2__c =='Tuition Fees')
                {
                system.debug('objOppLine.PricebookEntry.Product2.Family--->'+objOppLine.PricebookEntry.Product2.Family);
                if(objOppLine.PricebookEntry.Product2.Family=='MBA (WX)' ||  (Session==' All Term' || Session =='Second Year'))
                {
                    TuitionFees =objOppLine.ActualSalePrice__c;
                    TotalAmount += TuitionFees; 
                }
                else
                {
                    TuitionFees =objOppLine.UnitPrice;
                    TotalAmount += TuitionFees;
                    }
                   
                }
                if(objOppLine.ProgramName2__c =='Student Kits')
                {
                    StudentKitPrice =objOppLine.UnitPrice;
                    TotalAmount += StudentKitPrice;
                }
                if(objOppLine.ProgramName2__c =='Live Lectures')
                {
                    LivelecFees =objOppLine.UnitPrice;
                    TotalAmount += LivelecFees;
                }               
                if(objOppLine.ProgramName2__c =='Backlog')
                {
                    BacklogFee =objOppLine.UnitPrice;
                    TotalAmount += BacklogFee;
                }               
                if(objOppLine.ProgramName2__c =='Certificate Service Tax' || objOppLine.ProgramName2__c =='GST')
                {
                    ServiceTax =objOppLine.UnitPrice; 
                     TotalAmount += ServiceTax;
                }
                if(objOppLine.ProgramName2__c =='Late Fee')
                {                                   
                    if(WaviedOffAmount >0)
                    {
                        LateFees =( LateFees  + objOppLine.UnitPrice) - WaviedOffAmount;
                    }
                    else{
                         LateFees =( LateFees + objOppLine.UnitPrice);
                    }
                    TotalAmount += LateFees;
                }
                
                
                
                 currencyInWords = ('Rupees '+ob.convert((long)Math.floor(TotalAmount))+' only').toUpperCase(); 
                
            }
        }           
    }
}