public class nmICinvoice
{   
    public IC_Payment__c icPayment{get;set;} 
    public list<nm_UserMapping__c> lstUserMapping {get;set;}
    public String Roles {get;set;}
    public String SelectedCenter {get;set;}
    public String SelectedProgram {get;set;}
    public String currencyInWords {get;set;}
    public String ICMonth {get;set;}
    public double Credit1stApril {get;set;}
    public double  AdmissionCancel{get;set;}
    public List<nm_Centers__c>  lstLcRelatedInformationCenter{get;set;}
    public List<IC_Payment__c> lstIcPayment{get;set;}
    Set<String> ProgramBelongTo = new Set<String>();
    Integer grossAmount ;   
    Integer SwachhBharat ;
    Integer serviceTax ;
    Integer KrishiKalyan ;
    Integer TotalAfterTax ;
    public nmICinvoice() 
    {
        grossAmount  = 0;
        serviceTax =0;
        SwachhBharat =0;
        KrishiKalyan =0;
        TotalAfterTax =0;
        lstUserMapping  =new List<nm_UserMapping__c>();
        Roles ='';
        SelectedCenter = '';
        icPayment = new IC_Payment__c();
        lstLcRelatedInformationCenter = new List<nm_Centers__c>();  
        lstIcPayment = new List<IC_Payment__c> ();
        lstUserMapping=[select id,Name,nm_Centers__c,nm_User__r.UserRole.Name,nm_User__r.Profile.Name,nm_User__r.Name from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()];
        if(lstUserMapping.size()>0)
        {
            Roles = lstUserMapping[0].nm_User__r.Profile.Name; // checking role for hiding update Information Center option for IC User 
        } 
        else
        {
            Roles = 'Finance Department';
        }   
    }
    
    public List<SelectOption> getInfoCenterRelatedToLC() 
    {
        lstLcRelatedInformationCenter =new List<nm_Centers__c>();
        /*  if(lstUserMapping.size()>0)
             {
                if(lstUserMapping[0].nm_User__r.UserRole.Name.startsWith('Learning'))
                {
                System.debug('Enter in Lopp'); 
                   lstLcRelatedInformationCenter=[select name,id from nm_Centers__c where  nm_LearningCenter__c=:lstUserMapping[0].nm_Centers__c ];
                   System.debug('Related info'+lstLcRelatedInformationCenter.size());
                }
             }
             else if(lstUserMapping[0].nm_User__r.UserRole.Name.startsWith('System Administrator'))
             {
                 lstLcRelatedInformationCenter=[select name,id from nm_Centers__c];
             }
             else
             {
                lstLcRelatedInformationCenter=[select name,id from nm_Centers__c];
             } 
          */
          
          if(Roles =='Finance Department')
          {
               lstLcRelatedInformationCenter=[select name,id from nm_Centers__c order by name ASC];
          }
          else if(Roles.startsWith('Learning'))
          {
              lstLcRelatedInformationCenter=[select name,id from nm_Centers__c where  nm_LearningCenter__c=:lstUserMapping[0].nm_Centers__c and nm_LearningCenter__r.Invoice__c=true and Nm_Active__c = true];
          }
          else if(Roles.startsWith('Information'))
          {
              lstLcRelatedInformationCenter=[select name,id from nm_Centers__c where  id In (select nm_Centers__c from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()) and Invoice__c=true];
          }
          
         List<SelectOption> options = new List<SelectOption>();      
         options.add(new SelectOption('','-None-'));
         for(nm_Centers__c objCenter :lstLcRelatedInformationCenter) 
         {
             options.add(new SelectOption(objCenter.id,objCenter.Name));
         }
         
         return options;    
   }
   
   public void populateIcDetails()
   {
       lstIcPayment = getICpayment();
       currencytowords ob = new currencytowords();
       if(lstIcPayment.size()>0)
       {
           icPayment=lstIcPayment [0];
           currencyInWords = ('Rupees '+ob.convert((long)Math.floor(getGrossAmount()))+' only').toUpperCase();
           SYstem.debug('icPayment--->'+icPayment);
       }    

   }
   
   public List<IC_Payment__c> getICpayment()
   {
       List<IC_Payment__c> lst = [select id,Name,Credit_Amount__c,IC_Company_Name__c,Gross__c,Gross_after_ST__c,Service_Tax__c,Swachh_Bharat__c,Krishi_Kalyan__c,Payment_Due_Date__c,Debit_Amount__c,Pay_Month__c ,Gross_Amount__c,Centers__c,Payment_Month__c,Payment_Year__c from IC_Payment__c where Centers__c=:icPayment.NEFT_No__c and Payment_Year__c =: icPayment.Payment_Year__c and Pay_Month__c=: icPayment.Payment_Month__c];
     if(lst.size()>0)
     {
         ICMonth = lst[0].Pay_Month__c.toUpperCase();  
     }
     else 
     {
         ICMonth ='';
     }
      
       return lst;
   }
  /* public List<IC_Payment_Transaction__c> getICTransaction()
   { 
       if(SelectedProgram =='PGD')
       {
           List<IC_Payment_Transaction__c> lstPay = [select id,IC_Payment__c,Opportunity__r.Choose_a_Program__c,Transaction_Type__c from IC_Payment_Transaction__c where IC_Payment__c =:icPayment.id and (Opportunity__r.Choose_a_Program__c =: 'PGD' or Opportunity__r.Choose_a_Program__c = 'D')];
           return lstPay;
       }
       else if(SelectedProgram == 'C')
       {
           List<IC_Payment_Transaction__c> lstPay = [select id,IC_Payment__c,Opportunity__r.Choose_a_Program__c,Transaction_Type__c from IC_Payment_Transaction__c where IC_Payment__c =:icPayment.id and Opportunity__r.Choose_a_Program__c = 'C'];
          return lstPay;
       }
       return null;
   } */
     public Integer getGrossAmount()
    {  
       
       if(SelectedProgram =='POST GRADUATION AND DIPLOMA PROGRAM')
       { 
         ProgramBelongTo.add('PGD');  
         ProgramBelongTo.add('D');           
       }
       else if (SelectedProgram =='CERTIFICATE PROGRAM')
       {
        ProgramBelongTo.add('C');
       }
     /*  else
       {
         ProgramBelongTo.add('PGD');  
         ProgramBelongTo.add('D');
         ProgramBelongTo.add('C');  
         
       }*/
       system.debug('ProgramBelongTo-->'+ProgramBelongTo);
              Credit1stApril =(decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                         where IC_Payment__c =:icPayment.id 
                                         AND (Opportunity__r.Choose_a_Program__c =:ProgramBelongTo) 
                                         AND Transaction_Type__c ='Admission Commision - Credit'
                                         AND Date__c <2017-07-01   
                                           ][0].get('total');  
              AdmissionCancel =  (decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                             where IC_Payment__c =:icPayment.id 
                                             AND (Opportunity__r.Choose_a_Program__c =:ProgramBelongTo) 
                                             AND Transaction_Type__c ='Adjustment - Debit'
                                             AND Narration__c like '%Admission Cancellation%'
                                             ][0].get('total');  
                                             
            system.debug('Credit1stApril'+Credit1stApril);
            system.debug('AdmissionCancel'+AdmissionCancel);
         
            system.debug('');
            
                    if (Credit1stApril > 0)
                    {
                        return Integer.valueOf(Math.Round(Credit1stApril));
                    }   
                    else 
                    {
                        return 0;
                    }   
                    if (AdmissionCancel > 0)
                    {
                        return Integer.valueOf(Math.Round(AdmissionCancel));
                    }   
                    else 
                    {
                        return 0;
                    }       
                grossAmount =  Integer.valueOf(Math.Round(Credit1stApril - AdmissionCancel));
                
                system.debug('Round gross'+Math.Round(Credit1stApril - AdmissionCancel));
                system.debug('Integer gross'+grossAmount);                
              
              return grossAmount; 

                                                      
       

    }
      public Integer getServiceAmount()
    {
        decimal  totalservice = 0;
        decimal totalserviceTax = 0;
    
       // TotalAfterTax =Integer.valueOf( Math.Round((getGrossAmount()*100)/115));
        totalservice = getTotalAfterTax()*14;
        totalserviceTax = totalservice /100;
        ServiceTax =Integer.valueOf( Math.Round(totalserviceTax ));
        
        //serviceTax = Integer.valueOf( Math.Round((getTotalAfterTax()*14)/100)); 
        
        system.debug('Round serviceTax'+Math.Round((getTotalAfterTax()*14)/100));                   
        system.debug('GET serviceTax  AMOUNT-->'+serviceTax );
        
        return ServiceTax; 
    }
     public Integer getSwachhBharat()
    {
        decimal totalSwachhBharat = 0;
        decimal totalSwachhBharatTax = 0;
        totalSwachhBharat = getTotalAfterTax()*0.5;
        totalSwachhBharatTax = totalSwachhBharat / 100;
        SwachhBharat = Integer.valueOf( Math.Round(totalSwachhBharatTax));
        //SwachhBharat = Integer.valueOf(Math.Round((getTotalAfterTax()*0.5)/100));
        
        system.debug('Round SwachhBharat'+Math.Round((getTotalAfterTax()*0.5)/100));                    
        system.debug('GET SwachhBharat  AMOUNT-->'+SwachhBharat);
        
        return SwachhBharat;
    }
     public Integer getKrishiKalyan()
    {
        decimal totalKrishiKalyan = 0;
        decimal KrishiKalyanTax = 0;
        totalKrishiKalyan = getTotalAfterTax()*0.5;
        KrishiKalyanTax = totalKrishiKalyan/100;
        KrishiKalyan = Integer.valueOf( Math.Round(KrishiKalyanTax));
       // KrishiKalyan = Integer.valueOf(Math.Round((getTotalAfterTax()*0.5)/100));
        
        system.debug('Round KrishiKalyan'+Math.Round((getTotalAfterTax()*0.5)/100));                    
        system.debug('GET KrishiKalyan  AMOUNT-->'+KrishiKalyan);
        
        return KrishiKalyan;
    }
    public Integer getTotalAfterTax()
    {
    decimal  totalgross=0;
    decimal TotalAfterTax2 = 0;
    
       // TotalAfterTax =Integer.valueOf( Math.Round((getGrossAmount()*100)/115));
        totalgross = getGrossAmount()*100;
        TotalAfterTax2 = totalgross /115;
        TotalAfterTax =Integer.valueOf( Math.Round(TotalAfterTax2 ));
        /*TotalAfterTax = Integer.valueOf(getGrossAmount()-getServiceAmount()-getSwachhBharat()- getKrishiKalyan());
        system.debug('GET TotalAfterTax  AMOUNT-->'+TotalAfterTax );*/
        system.debug('getGrossAmount()'+getGrossAmount());
        system.debug('getGrossAmount()*100'+getGrossAmount()*100);
        system.debug('TotalAfterTax2'+TotalAfterTax2);
        system.debug('total after tax'+(getGrossAmount()*100)/115);
        system.debug('Round TotalAfterTax'+Math.Round((getGrossAmount()*100)/115));                 
        system.debug('GET TotalAfterTax  AMOUNT-->'+TotalAfterTax);
        
        return TotalAfterTax ;
    }
    public list<SelectOption> getChooseProgram()
    {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('','Choose Program'));
        options.add(new SelectOption('POST GRADUATION AND DIPLOMA PROGRAM','Post Graduation and Diploma Program'));
        options.add(new SelectOption('CERTIFICATE PROGRAM','Certificate Program'));
       
        return options;
    
    }
   public PageReference redirect()
   {
      system.debug('Center -->'+SelectedCenter);
      icPayment.NEFT_No__c =SelectedCenter;
      List<IC_Payment__c> lst = getICpayment();
      if(lst.size()>0)
      {
          PageReference pr = new PageReference('/apex/ICinvoicePdf');
          return pr;
      }
       else
      {
         // renderReport = FALSE;
          Apexpages.AddMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'YOUR QUERY DID NOT FETCH ANY RESULTS'));
      }
      RETURN NULL;
   } 
}