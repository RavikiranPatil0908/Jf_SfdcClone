/**
 * @File Name          : nmRegistrationReceipt.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    24/6/2019, 1:16:26 PM   @BK     Initial Version
**/
// This controller class made for pdf page nmRegistrationReceipt
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        05-May-2014     Sumit Banarji           Initial Version
// ---------------------------------------------------------------------------------------------
public class nmRegistrationReceipt 
{
    public string strPaymentId {get; set;}
    public Map<String,nm_Payment__c> mapOfPaymentRecord{get;set;}
    public List<nm_Payment__c> lstpayment{get;set;}
    public boolean IsRegistration{get;set;}
    public Set<String> setOfMerchantId {get;set;} // take merchant Id of Recently Payment Made Record and check Query related Payment 
    public Map<string,string> MapOfPriceBook{get;set;}
    public Map<string,string> MapFieldvsName {get;set;}
    public String MerchantId {get;set;}
    public Decimal UnitPriceofProduct {get;set;}
    public Decimal GSTAmount {get;set;}
    public Decimal DebitAmount {get;set;}
    public String PaymentType {get;set;}
    public String opportunityId {get;set;}
    public String InstallmentDisclaimer {get;set;}
    public Date paymenttransactionDate {get;set;}
    public Boolean isPaymentOfAEPMerchandise {get;set;}
    public Boolean IsActiveCoursera {get;set;}
    
    //Debit from Share
     public List<IC_Payment_Transaction__c> lstICPaymentTransaction{get;set;}
    
    
    //Dynamic receipt value
    public String DisplayName {get;set;}
    public string ReceiptNo {get;set;}
    public String RegistrationNo {get;set;}
    public String Name {get;set;}
    public String State {get;set;}
    public String programName {get;set;}
    public String programName2 {get;set;}
    public String Session {get;set;}
    public String Year {get;set;}
    public String StudentNumber {get;set;}
    public String Semester {get;set;}

    
    public nmRegistrationReceipt()
    {
        strPaymentId = ApexPages.currentPage().getParameters().get('id');
        UnitPriceofProduct =0;
        GSTAmount = 0;
        opportunityId = '';
        PaymentType  = '';
        DisplayName = '';
        Name ='';
        State = '';
        RegistrationNo ='';
        programName ='';
        programName2 ='';
        Session ='';
        Year ='';
        DebitAmount=0;
        StudentNumber='';
        Semester='';
        isPaymentOfAEPMerchandise = false;
        IsRegistration = false;
        IsActiveCoursera = false;
        
        paymenttransactionDate=null;
        setOfMerchantId  = new Set<String>();
        MapOfPriceBook = new Map<string,string>(); 
        mapOfPaymentRecord =new Map<String,nm_Payment__c>();
        lstpayment =new List<nm_Payment__c>();
        if(strPaymentId != null && strPaymentId != '')
        {
            // call a Method to get Student Related Data
            GetData();
            GetProductPriceofCertificateandAdvance();
            String myGeneratedFileName = '';
            if(String.isNotBlank(DisplayName)){
                myGeneratedFileName = 'Payment Receipt For '+DisplayName+'.pdf';
            }else{
                myGeneratedFileName = 'Payment Receipt.pdf';
            }
            
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename); 
        }
    }
    
    public void GetData()
    {
        string Query ='Select id,Student_number__c,nm_Type__c,Semester__c,Choose_program__c,nm_OpportunityNew__r.nm_Program2__r.name,nm_Lead__r.nm_Program2__r.name,Seminar__c,nm_OpportunityNew__r.Account.nm_StudentNo__c,nm_Merchant_Track_Id__c,'+
        +'nm_OpportunityNew__r.Account.nm_RegistrationNumber__c,nm_Lead__r.Coursera__c,nm_OpportunityNew__r.Coursera__c,nm_OpportunityNew__r.Account.name,CityWithState__c,AEP__c,'+
        +'nm_OpportunityNew__r.Account.State_Province_Shipping__c,nm_OpportunityNew__r.Account.nm_Centers__r.Name,AEP__r.nm_CenterCode__c,'+
        +'nm_OpportunityNew__r.nm_Program__r.name,nm_OpportunityNew__r.nm_Program__r.nm_Type__c,nm_OpportunityNew__r.nm_Program__r.Specialisation__c,AEP__r.Name,'+
        +'nm_OpportunityNew__r.nm_Session__c,nm_OpportunityNew__r.nm_Year__c,nm_OpportunityNew__r.Is_Re_Registration_Payment__c,'+
        +'nm_TransactionID__c,'+
        +'Receipt_Number__c, createdDate, nm_ModeOfPayment__c, nm_RefNo__c, nm_Amount__c, nm_PaymentType__c,nm_ActualPaymentAmmount__c,'+
        +'nm_DemandDraftNumber__c,nm_TransactionDate__c,Validity_Extension__r.Related_Account__r.nm_RegistrationNumber__c,'+
        +'Validity_Extension__r.Student_Number_Of_Account__c,Validity_Extension__r.Related_Account__r.State_Province_Shipping__c,'+
        +'Validity_Extension__c,Validity_Extension__r.Student_Program_Validity__c,Validity_Extension__r.Related_Account__r.Name,'+
        +'Validity_Extension__r.Related_Account__r.nm_Centers__r.Name,nm_Lead__r.State_Province_Shipping__c,nm_Lead__c,nm_Lead__r.nm_RegistrationNo__c,'+
        +'nm_Lead__r.Name,nm_Lead__r.nm_InformationCenter__r.name,nm_Lead__r.nm_Year__c,nm_Lead__r.nm_Session__c,nm_Lead__r.nm_Program__r.name,'+
        +'nm_Lead__r.nm_Program__r.nm_Type__c,nm_Lead__r.Program_Type__c,Seminar__r.Name__c ,CareerServiceProgram__r.nm_RegistrationNumber__c,'+
        +'CareerServiceProgram__r.Name__c,CareerServiceProgram__r.State__c,CareerServiceProgram__r.StudentProgram__c,CareerServiceProgram__c,Seminar__r.Webinar_Reg_no__c'+
        +' From nm_Payment__c ';
       
        String LeadId = '';
        IsRegistration = false;
        lstpayment = Database.query(Query+' where id=:strPaymentId'); 
        
        String Icsharequery = 'select id,Name,Amount__c,Narration__c,Transaction_Type__c,IC_Payment__r.Centers__r.nm_CenterCode__c,Due_Date__c,Date__c,IC_Payment__c,IC_Payment__r.nm_CenterName__c  ,IC_Payment__r.Centers__c'+
                                +' From IC_Payment_Transaction__c ';
        lstICPaymentTransaction = Database.query(Icsharequery+' where id=:strPaymentId'); 
        
        if(lstPayment.size()>0)
        {
            for(nm_Payment__c objPayment:lstPayment)
            {
                if(objPayment.nm_PaymentType__c == 'Coursera'){
                    IsActiveCoursera = true;
                }

                mapOfPaymentRecord.put(objPayment.id,objPayment);
                if(objPayment.nm_ModeOfPayment__c =='Online'){
                    setOfMerchantId.add(objPayment.nm_Merchant_Track_Id__c);
                }else{
                    setOfMerchantId.add(objPayment.nm_DemandDraftNumber__c);
                }
                if(objPayment.nm_PaymentType__c == 'Tshirt') {
                    isPaymentOfAEPMerchandise = true;
                }
                 if(objPayment.nm_TransactionDate__c!= null){
                    
                    paymenttransactionDate=objPayment.nm_TransactionDate__c;
                }         
                PaymentType  = objPayment.nm_PaymentType__c;

                if(objPayment.nm_Lead__c !=null)
                {   
                    LeadId = objPayment.nm_Lead__c;
                    mapOfPaymentRecord.put('LeadRecord',objPayment);
                    
                    DisplayName ='';
                    RegistrationNo = objPayment.nm_Lead__r.nm_RegistrationNo__c;
                    Name = objPayment.nm_Lead__r.Name;
                    State = objPayment.nm_Lead__r.State_Province_Shipping__c;
                    programName = objPayment.nm_Lead__r.nm_Program__r.name;
                    programName2 = objPayment.nm_Lead__r.nm_Program2__r.name;
                    Session = objPayment.nm_Lead__r.nm_Session__c;
                    Year = String.valueof(objPayment.nm_Lead__r.nm_Year__c);
                    Semester = objPayment.Semester__c!='none'?objPayment.Semester__c:'';

                    /*MapFieldvsName.put('DisplayName','');
                    MapFieldvsName.put('RegistrationNo',objPayment.nm_Lead__r.nm_RegistrationNo__c);
                    */
                    // query for InstallMent Payment 
                    List<nm_Payment__c> lstOfPaymentRecordRelatedToOpps = [select id,nm_PaymentType__c from nm_Payment__c where nm_Lead__c  =:objPayment.nm_Lead__c and (nm_PaymentStatus__c='Payment Made' or nm_PaymentStatus__c='Payment Approved') and nm_PaymentType__c  ='Installment'];
                    if(lstOfPaymentRecordRelatedToOpps.size()>0)
                    {
                        mapOfPaymentRecord.put('InstallmentPayment',objPayment);
                    }
                }
                else if(objPayment.Validity_Extension__c !=null)
                {
                    mapOfPaymentRecord.put('ValidityRecord',objPayment);
                    
                    DisplayName ='-VALIDITY EXTENSION';
                    StudentNumber = objPayment.Student_number__c!='none'?objPayment.Student_number__c:'';
                  //  RegistrationNo = objPayment.Validity_Extension__r.Related_Account__r.nm_RegistrationNumber__c;
                    Name = objPayment.Validity_Extension__r.Related_Account__r.Name;
                    State = objPayment.Validity_Extension__r.Related_Account__r.State_Province_Shipping__c;
                    programName = objPayment.Validity_Extension__r.Student_Program_Validity__c;
                    Session = '';
                    Year = '';

                    System.debug('Enter In Validity Loop--->'+mapOfPaymentRecord.get('ValidityRecord'));
                }
                else if(objPayment.CareerServiceProgram__c !=null)
                {
                    mapOfPaymentRecord.put('CareerService',objPayment);
                    
                    DisplayName ='- CAREER SERVICE';
                    StudentNumber = objPayment.Student_number__c!='none'?objPayment.Student_number__c:'';
                    RegistrationNo = objPayment.CareerServiceProgram__r.nm_RegistrationNumber__c;
                    Name = objPayment.CareerServiceProgram__r.Name__c;
                    State = objPayment.CareerServiceProgram__r.State__c;
                    programName = objPayment.CareerServiceProgram__r.StudentProgram__c;
                    Session = '';
                    Year = '';
                    
                    System.debug('Enter In Validity Loop--->'+mapOfPaymentRecord.get('CareerService'));
                }
                else if(objPayment.Seminar__c !=null)
                {
                    mapOfPaymentRecord.put('Seminar',objPayment);                    
                    DisplayName ='- SEMINAR REGISTRATION';                    
                    RegistrationNo = objPayment.Seminar__r.Webinar_Reg_no__c;
                    Name = objPayment.Seminar__r.Name__c;
                    State = '';
                    programName = '' ;
                    Session = '';
                    Year = '';
                    
                    System.debug('Enter In Seminar Loop--->'+mapOfPaymentRecord.get('Seminar'));
                }
                else if(objPayment.AEP__c !=null)
                {
                    mapOfPaymentRecord.put('Community',objPayment);                    
                    DisplayName = '- '+objPayment.nm_PaymentType__c.toUpperCase();                    
                    RegistrationNo = objPayment.AEP__r.nm_CenterCode__c;
                    Name = objPayment.AEP__r.Name;
                    State = '';
                    programName = '' ;
                    Session = '';
                    Year = '';
                    
                    System.debug('Enter In COMMUNITY Loop--->'+mapOfPaymentRecord.get('Community'));
                }
                else{
                    mapOfPaymentRecord.put('AccountRecord',objPayment);
                    
                    DisplayName ='';
                    StudentNumber = objPayment.Student_number__c!='none'?objPayment.Student_number__c:'';
                    RegistrationNo = objPayment.nm_OpportunityNew__r.Account.nm_RegistrationNumber__c;
                    Name = objPayment.nm_OpportunityNew__r.Account.name;
                    State = objPayment.nm_OpportunityNew__r.Account.State_Province_Shipping__c;
                    programName = objPayment.nm_OpportunityNew__r.nm_Program__r.name;
                    programName2 = objPayment.nm_OpportunityNew__r.nm_Program2__r.name;                    
                    Session = objPayment.nm_OpportunityNew__r.nm_Session__c;
                    Year = String.valueof(objPayment.nm_OpportunityNew__r.nm_Year__c);
                    Semester = objPayment.Semester__c!='none'?objPayment.Semester__c:'';

                    
                    // query for InstallMent Payment 
                    opportunityId = objPayment.nm_OpportunityNew__c ;
                    
                    List<nm_Payment__c> lstOfPaymentRecordRelatedToOpps = [select id,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c =:objPayment.nm_OpportunityNew__c and (nm_PaymentStatus__c='Payment Made' or nm_PaymentStatus__c='Payment Approved') and nm_PaymentType__c  ='Installment'];
                    if(lstOfPaymentRecordRelatedToOpps.size()>0)
                    {
                        mapOfPaymentRecord.put('InstallmentPayment',objPayment);
                    }
                }
            }
        }else if(lstICPaymentTransaction.size()>0)
        {
              // nm_Payment__c objPayment = new nm_Payment__c();
            
                    DisplayName ='- COMMUNITY LICENSES FEE REGISTRATION';                    
                    RegistrationNo = lstICPaymentTransaction[0].IC_Payment__r.Centers__r.nm_CenterCode__c;
                    Name = lstICPaymentTransaction[0].IC_Payment__r.nm_CenterName__c;
                    ReceiptNo = lstICPaymentTransaction[0].Name;
                    paymenttransactionDate = lstICPaymentTransaction[0].Date__c;
                    DebitAmount =  lstICPaymentTransaction[0].Amount__c;
                    State = '';
                    programName = '' ;
                    Session = '';
                    Year = '';
                    
            //mapOfPaymentRecord.put('Community',objPayment);     
        }

        if(setOfMerchantId.size() > 0 && LeadId !=null && LeadId !=''){
            List<nm_Payment__c> lstOfPaymentRecordRelatedToLead = Database.query(Query+' where nm_Lead__c  =:LeadId  and nm_PaymentStatus__c = \'Payment Made\' and (nm_Merchant_Track_Id__c in :setOfMerchantId or nm_DemandDraftNumber__c in : setOfMerchantId) and nm_PaymentType__c  !=:PaymentType '); 
            if(lstOfPaymentRecordRelatedToLead.size() > 0){
                lstpayment.addAll(lstOfPaymentRecordRelatedToLead);
                for(nm_Payment__c objPayment : lstOfPaymentRecordRelatedToLead) {
                    mapOfPaymentRecord.put(objPayment.id,objPayment);
                } 
            }    
        }else if(setOfMerchantId.size() > 0 && opportunityId  !=null && opportunityId  !=''){
            List<nm_Payment__c> lstOfPaymentRecordRelatedToOpportunity = Database.query(Query+' where nm_OpportunityNew__c   =:opportunityId  and nm_PaymentStatus__c = \'Payment Made\' and (nm_Merchant_Track_Id__c in :setOfMerchantId or nm_DemandDraftNumber__c in : setOfMerchantId) and nm_PaymentType__c  !=:PaymentType '); 
            if(lstOfPaymentRecordRelatedToOpportunity.size() > 0){
                lstpayment.addAll(lstOfPaymentRecordRelatedToOpportunity);
                for(nm_Payment__c objPayment : lstOfPaymentRecordRelatedToOpportunity) {
                    mapOfPaymentRecord.put(objPayment.id,objPayment);
                } 
            }
        }
        
        
        if(!mapOfPaymentRecord.containsKey('LeadRecord'))
        {
            mapOfPaymentRecord.put('LeadRecord',new nm_Payment__c());  
            
        }
        if(!mapOfPaymentRecord.containsKey('ValidityRecord'))
        {
            mapOfPaymentRecord.put('ValidityRecord',new nm_Payment__c());  
        }
        if(!mapOfPaymentRecord.containsKey('AccountRecord'))
        {
            mapOfPaymentRecord.put('AccountRecord',new nm_Payment__c());   
        }
        if(!mapOfPaymentRecord.containsKey('InstallmentPayment'))
        {
            mapOfPaymentRecord.put('InstallmentPayment',new nm_Payment__c());   
        }
        if(!mapOfPaymentRecord.containsKey('CareerService'))
        {
            mapOfPaymentRecord.put('CareerService',new nm_Payment__c());   
        }
        if(!mapOfPaymentRecord.containsKey('Seminar'))
        {
            mapOfPaymentRecord.put('Seminar',new nm_Payment__c());   
        } if(!mapOfPaymentRecord.containsKey('Community'))
        {
            mapOfPaymentRecord.put('Community',new nm_Payment__c());   
        }
          
    }
    
    Public void GetProductPriceofCertificateandAdvance()
    {
    
       if(lstPayment.size()>0)
       {
          nm_Payment__c  objPayment =lstPayment[0];
          
          if(objPayment.Validity_Extension__c!=null)
          {
              list<Validity_Extension__c> lstValidityExtension =[select id,Related_Account__r.nm_Tagged_Pricebook__c from Validity_Extension__c where id=:objPayment.Validity_Extension__c];
              
              id PriceBookid =lstValidityExtension[0].Related_Account__r.nm_Tagged_Pricebook__c;
              id Accountid = lstValidityExtension[0].Related_Account__c;
              list<Opportunity> lstOpportunity =[select id,nm_Program__c from Opportunity where Accountid=:Accountid limit 1];
              
              list<PriceBookEntry> lstPriceBookEntry =[select id,Program__c,UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
                                         from PriceBookEntry where Pricebook2.id=:PriceBookid 
                                          and product2.nm_Program__c=:lstOpportunity[0].nm_Program__c and product2.nm_Semester__c='1'];
                                         
              if(lstPriceBookEntry.size()>0)
              {
                 for(PriceBookEntry  objPriceBook :lstPriceBookEntry)
                {
                   if(objPriceBook.product2.Name.contains('Semester'))
                   {
                      UnitPriceofProduct = objPriceBook.UnitPrice/2;
                      system.debug('UnitPrice '+UnitPriceofProduct );
                      
                      GSTAmount = UnitPriceofProduct*0.09;
                   
                   }
                    //MapOfPriceBook.put(objPriceBook.product2.Name,string.valueOf(objPriceBook.UnitPrice));
                }
                
              }
            
          }


        //   For nm_Payment Configuration.

        if(mapOfPaymentRecord.containsKey('InstallmentPayment') && mapOfPaymentRecord.get('InstallmentPayment').id != null) {

            String currentAdmissionYear;
            String programCategory;
            String programType = 'Admission';
            String specialisation = '';

            if(objPayment.nm_Lead__c !=null) {
                currentAdmissionYear = String.valueOf(objPayment.nm_Lead__r.nm_Year__c);
                programCategory = objPayment.nm_Lead__r.nm_Program__r.nm_Type__c;
                specialisation = objPayment.nm_Lead__r.Program_Type__c;
            }else{
                currentAdmissionYear = String.valueOf(objPayment.nm_OpportunityNew__r.nm_Year__c);
                programCategory = objPayment.nm_OpportunityNew__r.nm_Program__r.nm_Type__c;
                specialisation = objPayment.nm_OpportunityNew__r.nm_Program__r.Specialisation__c;
                if(objPayment.nm_OpportunityNew__r.Is_Re_Registration_Payment__c){
                    programType = 'Re-Registration';
                }
            }

            System.debug('programType-->'+programType);
            list<NM_Payment_Form_Configuration__c> lstPaymentConfiguration = [select id,Installment_Disclaimer__c,Session__c,Program_Type__c from NM_Payment_Form_Configuration__c where Current_Admission_Year__c =:currentAdmissionYear and Program_Category__c =:programCategory  and Payment_Type__c =:programType and Session__c=:Session];

            if(lstPaymentConfiguration.size() > 0){
                System.debug('specialisation ==> '+specialisation);
                System.debug('Session ==> '+Session);
                for (NM_Payment_Form_Configuration__c objConfiguration: lstPaymentConfiguration) {
                    System.debug('objConfiguration.Program_Type__c ==> '+objConfiguration.Program_Type__c);
                    System.debug('objConfiguration.Session__c ==> '+objConfiguration.Session__c);
                    if(String.isNotBlank(specialisation) && specialisation!='M.Sc.' && objConfiguration.Program_Type__c==specialisation && objConfiguration.Session__c==Session) {
                        InstallmentDisclaimer = objConfiguration.Installment_Disclaimer__c;
                        System.debug('objConfiguration.id ==>'+objConfiguration.id);
                        break;
                    }
                    else if(String.isNotBlank(specialisation) && specialisation!='MBA (WX)' && specialisation!='MBA (X)' && objConfiguration.Program_Type__c==specialisation) {
                        InstallmentDisclaimer = objConfiguration.Installment_Disclaimer__c;
                        System.debug('objConfiguration.id ==>'+objConfiguration.id);
                        break;
                    }
                    else if(String.isBlank(specialisation)) {
                        InstallmentDisclaimer = objConfiguration.Installment_Disclaimer__c;
                        System.debug('objConfiguration.id ==>'+objConfiguration.id);
                        break;
                    }
                }
                // if(String.isBlank(InstallmentDisclaimer)) {
                //     InstallmentDisclaimer = lstPaymentConfiguration[0].Installment_Disclaimer__c;
                // }
                System.debug('InstallmentDisclaimer-->'+InstallmentDisclaimer);
            }
            System.debug('InstallmentDisclaimer-->'+InstallmentDisclaimer);
        }

       }
    
    }
}