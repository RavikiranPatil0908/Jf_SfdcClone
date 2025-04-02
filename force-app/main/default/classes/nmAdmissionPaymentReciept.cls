/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
**/
public class nmAdmissionPaymentReciept
{
    public String PaymentId{get;set;}
    public Map<String,nm_Payment__c> mapOfPaymentRecord {get;set;}
    public String InstallmentDisclaimer {get;set;}
     public String programName2 {get;set;}

    public nmAdmissionPaymentReciept()
    {
        PaymentId=ApexPages.currentPage().getParameters().get('PaymentId');
         programName2 ='';
        mapOfPaymentRecord =new Map<String,nm_Payment__c>();
        if(PaymentId != null)
        {
            // call method to get all Details related to Student from SFDC
            GETData();
        }
    }
    
    public void GETData()
    {
        List<nm_Payment__c> lstPayment  = [Select id,nm_OpportunityNew__r.nm_Program2__r.name,Choose_program__c,nm_Lead__r.nm_Program2__r.name,nm_OpportunityNew__r.Account.nm_StudentNo__c,nm_OpportunityNew__r.Account.nm_RegistrationNumber__c,nm_OpportunityNew__r.Account.name,
                                           nm_OpportunityNew__r.Account.nm_Centers__r.Name,nm_OpportunityNew__r.nm_Program__r.name,nm_OpportunityNew__r.nm_Program__r.nm_Type__c,nm_OpportunityNew__r.nm_Session__c,nm_OpportunityNew__r.nm_Year__c,
                                           nm_OpportunityNew__r.Is_Re_Registration_Payment__c,
                                           nm_TransactionID__c, createdDate, nm_ModeOfPayment__c, nm_RefNo__c, nm_Amount__c, nm_PaymentType__c,nm_ActualPaymentAmmount__c,nm_DemandDraftNumber__c,nm_TransactionDate__c,
                                           Validity_Extension__r.Related_Account__r.nm_RegistrationNumber__c,Validity_Extension__r.Student_Number_Of_Account__c,
                                           Validity_Extension__r.Student_Program_Validity__c,Validity_Extension__r.Related_Account__r.Name,Validity_Extension__r.Related_Account__r.nm_Centers__r.Name,nm_Lead__c,
                                           nm_Lead__r.nm_RegistrationNo__c,nm_Lead__r.Name,nm_Lead__r.nm_InformationCenter__r.name,nm_Lead__r.nm_Year__c,nm_Lead__r.nm_Session__c,nm_Lead__r.nm_Program__r.name,nm_Lead__r.nm_Program__r.nm_Type__c
                                           From nm_Payment__c 
                                           where id=:PaymentId];

        System.debug('lstPayment-->'+lstPayment);
        if(lstPayment.size()>0)
        {
            for(nm_Payment__c objPayment :lstPayment)
            {
                mapOfPaymentRecord.put('StudentDetails',objPayment);
                 if(objPayment.nm_Lead__c != null ){
                 
                   programName2 = objPayment.nm_Lead__r.nm_Program2__r.name!=null?objPayment.nm_Lead__r.nm_Program2__r.name:'';
                   
                 }else if(objPayment.nm_OpportunityNew__c != null){
                 
                 programName2 = objPayment.nm_OpportunityNew__r.nm_Program2__r.name!=null?objPayment.nm_OpportunityNew__r.nm_Program2__r.name:'';
                 
                 }
            }
            

            //   For nm_Payment Configuration.

            nm_Payment__c PaymentRecord = lstPayment[0];
            if(PaymentRecord.nm_PaymentType__c == 'Installment'){

                String currentAdmissionYear;
                String programCategory;
                String programType = 'Admission';

                if(PaymentRecord.nm_Lead__c != null){
                    currentAdmissionYear = String.valueOf(PaymentRecord.nm_Lead__r.nm_Year__c);
                    programCategory = PaymentRecord.nm_Lead__r.nm_Program__r.nm_Type__c;
                    programName2 = PaymentRecord.nm_Lead__r.nm_Program2__r.name!=null?PaymentRecord.nm_Lead__r.nm_Program2__r.name:'';
                    System.debug('programName2 -->'+programName2 +'programType1-->'+programType+','+currentAdmissionYear+','+programCategory);
                }else{
                    currentAdmissionYear = String.valueOf(PaymentRecord.nm_OpportunityNew__r.nm_Year__c);
                    programCategory = PaymentRecord.nm_OpportunityNew__r.nm_Program__r.nm_Type__c;
                     programName2 = PaymentRecord.nm_OpportunityNew__r.nm_Program2__r.name!=null?PaymentRecord.nm_OpportunityNew__r.nm_Program2__r.name:'';
                    System.debug('programName2 -->'+programName2 +'programType2-->'+programType+','+currentAdmissionYear+','+programCategory);
                }

                System.debug('programType-->'+programType+','+currentAdmissionYear+','+programCategory);
                list<NM_Payment_Form_Configuration__c> lstPaymentConfiguration = [select id,Installment_Disclaimer__c from NM_Payment_Form_Configuration__c where Current_Admission_Year__c =:currentAdmissionYear and Program_Category__c =:programCategory  and Payment_Type__c =:programType];

                if(lstPaymentConfiguration.size() > 0){
                    InstallmentDisclaimer = lstPaymentConfiguration[0].Installment_Disclaimer__c;
                    System.debug('InstallmentDisclaimer-->'+InstallmentDisclaimer);
                }
                System.debug('InstallmentDisclaimer-->'+InstallmentDisclaimer);


            }
        }           
    }
}