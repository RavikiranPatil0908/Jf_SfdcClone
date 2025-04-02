/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 29-08-2024
 * @last modified by  : @BK
**/
public class ValidityExtension
{
    public string IC {get;set;}
    public String strAccID{get;set;}
    public Account objAccount {get;set;}
    public nm_StudentProgram__c objStudentProg{get;set;}
    public Validity_Extension__c objValidity{get;set;}
    public Validity_Extension__c objValidityExtension{get;set;}
    public decimal extensionFeeAmount{get;set;}
    public boolean checkIfValidityRecordExistsAgainstAccount;
    public Opportunity objOpps{get;set;}
    public boolean IsDefence {get;set;}
    public String months {get;set;}

    public List<PriceBookEntry> lstPriceBookEntry;
    
    public ValidityExtension()
    {
        objAccount =new Account();
        objOpps =new Opportunity();
        objStudentProg = new nm_StudentProgram__c();
        lstPriceBookEntry =new List<PriceBookEntry>();
        objValidity = new Validity_Extension__c();
        extensionFeeAmount=0;
        objValidityExtension =new Validity_Extension__c();
        months = '6 months';
        strAccID=  ApexPages.currentPage().getParameters().get('id');
        IC =ApexPages.currentPage().getParameters().get('IC');
        if(strAccID !=null && strAccID!='')
        {
            // call query block to query all records related to class
            QueryBlock();
        }
    }
    
    public void QueryBlock()
    {
        // query all Basic details related to Account 
        objAccount = [Select id, Name,nm_HouseNumber__c,nm_LocalityName__c,BillingStreet,nm_NearestLandmark__c,nm_ChooseaProgram__c,BillingCity,BillingState,
                         nm_Tagged_Pricebook__c,nm_DefencePersonnel__c,nm_StudentImageUrl__c,nm_Batch_Name2__c,Expiry_Year__c,nmStudent_Program__c,
                         FirstName, lastname, nm_StudentNo__c, nm_DateOfBirth__c, nm_Centers__c, nm_Gender__c,PersonMobilePhone,
                         IsPersonAccount,BillingCountry,nm_Centers__r.Name,nm_Centers__r.nm_CenterGroup__c, nm_Program__r.IsTerm__c,
                         BillingPostalCode,PersonEmail from Account where id=:strAccID];
        objStudentProg = [select id,nm_Program__r.nm_ProgramName__c from nm_StudentProgram__c where nm_Student__c=:strAccID limit 1];       
        
        lstPriceBookEntry = [SELECT id,UnitPrice,product2.Name, product2.nm_Program__c,product2.nm_Program__r.id,product2.nm_Semester__c FROM PriceBookEntry 
            WHERE Pricebook2.IsStandard=false AND product2.nm_Semester__c!=null AND ((product2.isActive=true AND product2.nm_Program__c=:objStudentProg.nm_Program__c)) 
            AND Pricebook2.id=:objAccount.nm_Tagged_Pricebook__c];

        months = objAccount.nm_Program__r.IsTerm__c == true ? '3 months' : months;
        
        //objOpps = [select id,nm_Fee_Type__c,nm_Semester__c from Opportunity where Account.Id=:strAccID and nm_Semester__c ='1'];
        //list<OpportunityLineItem> lstLineItem=[select product2.id,ListPrice,ProgramName2__c,Product_Name__c,UnitPrice,Quantity,OpportunityId from OpportunityLineItem where OpportunityId =:objOpps.id and ProgramName2__c ='Tuition Fees'];
       
        if(lstPriceBookEntry.size()>0)
        {
           extensionFeeAmount = 0.5*(lstPriceBookEntry[0].UnitPrice); // calculate extension fee amount 50% of Admission fee
             IsDefence = objAccount.nm_DefencePersonnel__c =='Yes'?true:false;
           system.debug('lstPriceBookEntry[0].UnitPrice'+lstPriceBookEntry[0].UnitPrice);
           if(objAccount.nmStudent_Program__c.startsWith('Certificate') || objAccount.nmStudent_Program__c.startsWith('Advance'))
           {
              extensionFeeAmount =(extensionFeeAmount+(0.18*extensionFeeAmount)).setScale(2);
           }
           else
           {
               extensionFeeAmount  = IsDefence ? (0.8*extensionFeeAmount).setScale(2) :extensionFeeAmount.setScale(2);

            // extensionFeeAmount  = extensionFeeAmount.setScale(2);
           }  
           
           
        }
        
       
        
    }
   
    public pageReference Logout()
    {   
        pageReference pg = new pageReference('/apex/nmLogin_new?type=reregistration');
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference ProceedToPaymentPage()
    {
        list<Validity_Extension__c> objValidity = [select id from Validity_Extension__c where Related_Account__c=:strAccID];
        System.debug('Enter In Loop of Validity--->'+objValidity.size());
        if(objValidity.size() ==0)
        {
            CopyFieldsFromAccountToValidityObject(objAccount);
        }
        string Amount=string.valueOf(extensionFeeAmount );
        Blob beforeblob = Blob.valueOf(Amount);
        // base64 encode the blob that contains our url param value
        string extensionFeesparamvalue = EncodingUtil.base64Encode(beforeblob); 
        system.debug('extensionFeesparamvalue '+extensionFeesparamvalue );
        System.debug('ExtensionFeeAmount--->'+extensionFeeAmount);
        system.debug('strAccID'+strAccID);
        // Url Change By Sachin as Combine This Class with Additional Charge
        pageReference pg = new pageReference('/apex/nmAdditonalCharge?&id='+strAccID+'&extensionFees='+extensionFeesparamvalue +'&IC='+IC);
        pg.setRedirect(true);
        return pg;
    }
    
    public void CopyFieldsFromAccountToValidityObject(Account acc)
    {
        System.debug('Entered CopyFieldsBlock');
        objValidityExtension.Batch_Name__c = acc.nm_Batch_Name2__c;
        objValidityExtension.Expiry_Date_Of_Program__c = string.valueOf(acc.Expiry_Year__c);
        objValidityExtension.Mobile_Number__c = acc.PersonMobilePhone;
        objValidityExtension.Name_Of_Account__c = acc.Name;
        objValidityExtension.Name = acc.Name;
        objValidityExtension.Related_Account__c = acc.id;
        objValidityExtension.Student_Number_Of_Account__c = acc.nm_StudentNo__c;
        objValidityExtension.Student_Program_Validity__c = acc.nmStudent_Program__c;
        objValidityExtension.student_Email__c = acc.PersonEmail;
        objValidityExtension.validity_Extension_details_submitted__c=true;
       insert objValidityExtension;
    
    }
}