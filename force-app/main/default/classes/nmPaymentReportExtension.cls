/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-05-2021
 * @last modified by  : @BK
**/
public class nmPaymentReportExtension
{
    private static IC_Payment__c icp;
    public Transient Boolean renderReport{get;set;}
    public Transient String selectedFilter{get;set;} 
    public double Creditbefore31{get;set;}
    public double Creditafter31{get;set;}
    public double  AdmissionCancel{get;set;}
    public double  DebitAmount{get;set;}
    List<IC_Payment_Transaction__c> reportResultList {get;set;}
    public String month {get;set;}
    public String year {get;set;}
    public String fromMonthYear {get;set;}
    public String toMonthYear {get;set;}
    public String fromMonthYearOnForm {get;set;}
    public String toMonthYearOnForm {get;set;}
    ApexPages.StandardController stdCon;
    date startDate;
    date enddate;
    String Info;
    Integer totalAmt;
    Integer grossAmount ;   
    Integer SwachhBharat ;
    Integer serviceTax ;
    Integer KrishiKalyan ;
    Integer TotalAfterTax ;
    Integer NetAmount ;
    Integer TDSAmount ;   
    String IsPdf ;
    


    public nmPaymentReportExtension(ApexPages.StandardController controller)
    {
       totalAmt = 0;
       grossAmount  = 0;
       serviceTax =0;
       SwachhBharat =0;
       TotalAfterTax =0;
       NetAmount =0;
       TDSAmount =0;
       stdCon  = controller;
       fromMonthYearOnForm = null;
       toMonthYearOnForm = null;
       
       
       IsPdf=null;
       if(ApexPages.currentPage().getParameters().get('pdf')!=null)
       {
           IsPdf=ApexPages.currentPage().getParameters().get('pdf');
       }
       
       if(ApexPages.currentPage().getParameters().get('selectedFilter')!=null)
       {
           selectedFilter=ApexPages.currentPage().getParameters().get('selectedFilter');
       }
       
        if(ApexPages.currentPage().getParameters().get('startDate')!=null)
       {
           startDate=Date.valueOf(ApexPages.currentPage().getParameters().get('startDate'));
       }
       
        if(ApexPages.currentPage().getParameters().get('endDate')!=null)
       {
           enddate=Date.valueOf(ApexPages.currentPage().getParameters().get('endDate'));
       }

        if(ApexPages.currentPage().getParameters().get('filterMonth')!=null) {
            month = ApexPages.currentPage().getParameters().get('filterMonth');   
        }

        if(ApexPages.currentPage().getParameters().get('filterYear')!=null) {
            year = ApexPages.currentPage().getParameters().get('filterYear');   
        }

        if(ApexPages.currentPage().getParameters().get('fromMonthYear')!=null) {
            fromMonthYear = ApexPages.currentPage().getParameters().get('fromMonthYear');   
        }

        if(ApexPages.currentPage().getParameters().get('toMonthYear')!=null) {
            toMonthYear = ApexPages.currentPage().getParameters().get('toMonthYear');   
        }
       
       if(ApexPages.currentPage().getParameters().get('Info')!=null)
       {
           Info=ApexPages.currentPage().getParameters().get('Info');
           findReport();
       }
       
    }
    
    public List<SelectOption> getavailFilters()
    {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','None'));
            options.add(new SelectOption('DATE RANGE','DATE RANGE'));
            options.add(new SelectOption('MMYYYY','MMYYYY'));
            
         return options;
    }
    
    public PageReference findReport()
    { 
       totalAmt = 0;
       icp = (IC_Payment__c)stdCon.getRecord();
       
       
       if(IsPdf =='true')
       {
           icp.Centers__c =Info;
       
           icp.Payment_Due_Date__c =startDate;
       
           icp.toDate__c =endDate;
       }
       else
       {
            Info=icp.Centers__c;
            startDate =icp.Payment_Due_Date__c;
            endDate =icp.toDate__c;
       }
       system.debug('Center-->'+icp.Centers__c+ 'Payment Month-->'+icp.Payment_Month__c+' Payment Year-->'+icp.Payment_Year__c +'--selectedFilter'+selectedFilter);
       /*
       if(icp.Payment_Month__c== NULL)
       {
           reportResultList = [select Date__c, Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c from IC_Payment_Transaction__c 
                            where IC_Payment__r.Centers__c = :icp.Centers__c AND IC_Payment__r.Payment_Year__c = : icp.Payment_Year__c];
       }
       
       else
       {
           system.debug('select Date__c, Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c from IC_Payment_Transaction__c where IC_Payment__r.Centers__c = :'+icp.Centers__c+' AND IC_Payment__r.Payment_Year__c = :'+icp.Payment_Year__c+' AND IC_Payment__r.Payment_Month__c = :'+ icp.Payment_Month__c);
                            
                            
           reportResultList = [select Date__c, Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c from IC_Payment_Transaction__c 
                            where IC_Payment__r.Centers__c = :icp.Centers__c AND IC_Payment__r.Payment_Year__c = : icp.Payment_Year__c AND IC_Payment__r.Pay_Month__c = : icp.Payment_Month__c];
       }
       */
       
       if(selectedFilter=='MMYYYY')
       {
           reportResultList = [select Date__c, Student_No__c,Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c,Transaction_Category__c
                               from IC_Payment_Transaction__c 
                               where IC_Payment__r.Centers__c = :icp.Centers__c 
                               AND IC_Payment__r.Payment_Year__c = : year
                               AND IC_Payment__r.Pay_Month__c = : month 
                               ORDER BY Date__c ASC];
       }
       
       else if(selectedFilter=='DATE RANGE')
       { 
           System.debug('Enter In Loop');
            reportResultList = [select Date__c, Student_No__c,Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c,Transaction_Category__c
                               from IC_Payment_Transaction__c 
                               where IC_Payment__r.Centers__c = :icp.Centers__c 
                               AND Due_Date__c  >= :icp.Payment_Due_Date__c 
                               AND Due_Date__c  <= :icp.toDate__c                                 
                               ORDER BY Date__c ASC];
            Creditbefore31 =  (decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                         where IC_Payment__r.Centers__c = :icp.Centers__c
                                         AND Due_Date__c  >= :icp.Payment_Due_Date__c 
                                         AND Due_Date__c  <= :icp.toDate__c  
                                         AND Transaction_Type__c ='Admission Commision - Credit'
                                         AND Date__c <=2017-03-31   
                                        ][0].get('total'); 
                                         System.debug('Creditbefore31'+Creditbefore31);
            Creditafter31 =  (decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                         where IC_Payment__r.Centers__c = :icp.Centers__c
                                         AND Due_Date__c  >= :icp.Payment_Due_Date__c 
                                         AND Due_Date__c  <= :icp.toDate__c  
                                         AND Transaction_Type__c ='Admission Commision - Credit'
                                         AND Date__c >=2017-04-01   
                                        ][0].get('total');  
            AdmissionCancel =  (decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                         where IC_Payment__r.Centers__c = :icp.Centers__c
                                         AND Due_Date__c  >= :icp.Payment_Due_Date__c 
                                         AND Due_Date__c  <= :icp.toDate__c  
                                         AND Transaction_Type__c ='Adjustment - Debit'
                                         AND (Narration__c like '%Admission Cancellation%' OR Narration__c like '%Subvention charge%')
                                        ][0].get('total'); 
            DebitAmount = (decimal) [select Sum(Amount__c)total from IC_Payment_Transaction__c 
                                         where IC_Payment__r.Centers__c = :icp.Centers__c
                                         AND Due_Date__c  >= :icp.Payment_Due_Date__c 
                                         AND Due_Date__c  <= :icp.toDate__c  
                                         AND Transaction_Type__c ='Adjustment - Debit'
                                        ][0].get('total'); 
                                                                    
                System.debug('icp.Payment_Due_Date__c'+icp.Payment_Due_Date__c);
                System.debug('icp.toDate__c'+icp.toDate__c);
                System.debug('icp.Centers__c'+icp.Centers__c);
        
       }
       else if(selectedFilter=='None')
       {    
           
           reportResultList = [select Date__c, Student_No__c,Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c,Transaction_Category__c from IC_Payment_Transaction__c 
                               where IC_Payment__r.Centers__c = :icp.Centers__c ORDER BY Date__c ASC];
       
       } else if(selectedFilter=='MonthYearRange') {
            Date fromDate = Date.valueOf(fromMonthYear + '-01');
            Date toDate = Date.valueOf(toMonthYear + '-01').addMonths(1);
            fromMonthYearOnForm = getMonthNameFromDate(Date.valueOf(fromMonthYear + '-01')) + ' ' + Date.valueOf(fromMonthYear + '-01').year();
            toMonthYearOnForm = getMonthNameFromDate(Date.valueOf(toMonthYear + '-01')) + ' ' + Date.valueOf(toMonthYear + '-01').year();
            reportResultList = [select Date__c, Student_No__c,Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c,Transaction_Category__c
                               from IC_Payment_Transaction__c 
                               where IC_Payment__r.Centers__c = :icp.Centers__c 
                               AND ic_payment__r.Payment_Month_and_Year_to_Date__c >= :fromDate
                               AND ic_payment__r.Payment_Month_and_Year_to_Date__c < :toDate
                               ORDER BY  ic_payment__r.Payment_Month_and_Year_to_Date__c ASC];
       }
                            
       if(!reportResultList.isEmpty())
       {                            
           for(IC_Payment_Transaction__c i : reportResultList)  
           {
                if(i.Transaction_Type__c.contains('Debit'))
               {
                   
                   totalAmt -= Integer.valueOf(i.Amount__c);
                   system.debug('Debit Entered. Total Amount is -->'+totalAmt);
                   
               }
               else if(i.Transaction_Type__c.contains('Credit'))
               {
                   totalAmt += Integer.valueOf(i.Amount__c);
                   system.debug('Credit Entered. Total Amount is -->'+totalAmt);
               }
              /* else if(i.Narration__c.contains(' Admission Cancellation') && i.Transaction_Type__c.contains('Debit'))
               {
                   AdmissionCancel += Integer.valueOf(i.Amount__c);
                   System.debug('AdmissionCancel'+AdmissionCancel);
               }*/
           }
           
            renderReport = TRUE;
       }
       else
       {
           renderReport = FALSE;
           Apexpages.AddMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'YOUR QUERY DID NOT FETCH ANY RESULTS'));
       }
                                 
      
       return null;
    }
    public List<IC_Payment_Transaction__c> getreportResultList()
    {
      
        system.debug('List-->'+reportResultList);
        return reportResultList;   
           
    }
    
    public PageReference reportFlagFalse()
    {
        renderReport = FALSE;
        return null;
    }
    
    public Integer gettotalAmount()
    {
     
         system.debug('GET TOTAL AMOUNT-->'+totalAmt);
         return totalAmt;
    }
    public double getDebitAmount()
    {
        if(DebitAmount>0)
        {
             system.debug('GET DebitAmount AMOUNT-->'+DebitAmount);
            return DebitAmount;          
        }
        else 
        {
            return 0;
        }   
         
    }
    public double getAdmissionCancel()
    {   if(AdmissionCancel>0)
        {
             system.debug('GET AdmissionCancel AMOUNT-->'+AdmissionCancel);
            return AdmissionCancel;          
        }
        else 
        {
            return 0;
        }   
        
    }
    public double getCreditafter31()
    {
        if(Creditafter31>0)
        {
            system.debug('GET Creditafter31 AMOUNT-->'+Creditafter31);
            return Creditafter31;
        }
        else
        {
            return 0;
        }
    }
    public double getCreditbefore31()
    {
        if(Creditbefore31>0)
        {
            system.debug('GET Creditbefore31 AMOUNT-->'+Creditbefore31);
            return Creditbefore31;
        }
        else
        {
            return 0;
        }
    }
    public Integer getGrossAmount()
    {      
        grossAmount = Integer.valueOf( getCreditafter31() - getAdmissionCancel());
        system.debug('GET Gross AMOUNT-->'+grossAmount );
        return grossAmount; 
    }
    public Integer getServiceAmount()
    {
        serviceTax = ((getGrossAmount()*18)/118);
        system.debug('GET serviceTax  AMOUNT-->'+serviceTax );
        return ServiceTax; 
    }
     public Integer getSwachhBharat()
    {
        SwachhBharat = Integer.valueOf((getGrossAmount()*0.5)/115);
        return SwachhBharat;
    }
     public Integer getKrishiKalyan()
    {
        KrishiKalyan = Integer.valueOf((getGrossAmount()*0.5)/115);
        return KrishiKalyan;
    }
    public Integer getTotalAfterTax()
    {
        TotalAfterTax = Integer.valueOf(getGrossAmount()-getServiceAmount());
        system.debug('GET TotalAfterTax  AMOUNT-->'+TotalAfterTax );
        return TotalAfterTax ;
    }
    public Integer getTDSAmount()
    {
        TDSAmount =Integer.valueOf((getCreditbefore31() +getTotalAfterTax())*0.05);
        system.debug('GET TDSAmount  AMOUNT-->'+TDSAmount);
        return TDSAmount;
    }
    public Integer getNetAmount()
    {
        NetAmount =Integer.valueOf(getCreditbefore31()+getGrossAmount()-getDebitAmount()-getTDSAmount()+getAdmissionCancel());
        system.debug('GET NetAmount  AMOUNT-->'+NetAmount);
        return NetAmount ;
    }
    public PageReference generatePDF()
    {
         System.debug('Method Called--->');
         PageReference p = new PageReference('/apex/ICPaymentReport?selectedFilter='+selectedFilter+'&startDate='+startDate+'&endDate='+endDate+'&Info='+Info+'&pdf=true');
         p.setRedirect(true);
         return p;
    }
    public static String getMonthNameFromDate(Date inputDate) {
        Datetime dt = Datetime.newInstance(inputDate.year(), inputDate.month(), 1, 0, 0, 0);
        String monthName = dt.format('MMMM');
        return monthName;
    }

}