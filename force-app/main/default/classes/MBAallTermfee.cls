/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 05-26-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-26-2021   shubhranshu   Initial Version
**/
public class MBAallTermfee
{   
    public string query{get;set;}
    public void createNextSemOpportunityOnClosedWonForFullFee(List<Opportunity> triggerNew, map<id, Opportunity> oldMap)
    {
        nmOpportunityTriggerHandler objCall = new nmOpportunityTriggerHandler();
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        List<nm_Payment__c> paymentListToInsert = new List<nm_Payment__c>();
        Map<String,String> mapOfFeeTypeVsFutureSem = new Map<String,String>{'MBAallTermfee' => 'All'};
        
        for(Opportunity newOpportunity : triggerNew)
        {
            Id opptyId = newOpportunity.Id;
            Opportunity oldOpportunity =  oldMap.get(opptyId);
            String feeType = newOpportunity.nm_Fee_Type__c;
            String LectureType = newOpportunity.LiveLecturesType__c;
            Integer semGap = Integer.valueOf(newOpportunity.Gap_Month__c);
            System.debug('!!!!!newOpportunity!!!' + newOpportunity);
            if(mapOfFeeTypeVsFutureSem.containsKey(feeType) && 
                newOpportunity.nm_Future_Sems_Created__c == false && 
                newOpportunity.StageName != oldOpportunity.StageName &&  
                newOpportunity.StageName == 'Closed Won'){
                Decimal totalSem = 0;
                if(mapOfFeeTypeVsFutureSem.get(feeType) == 'All') {
                    totalSem = newOpportunity.Total_Sem__c;
                } else if(mapOfFeeTypeVsFutureSem.get(feeType) == 'Half') {
                    totalSem = newOpportunity.IsTerm__c ? newOpportunity.Total_Sem__c/2 : 2 ;
                } else {
                    totalSem = Decimal.valueOf(mapOfFeeTypeVsFutureSem.get(feeType));
                }
                                
                // Decimal totalSem = mapOfFeeTypeVsFutureSem.get(feeType) == 'All' ? newOpportunity.Total_Sem__c 
                // : (mapOfFeeTypeVsFutureSem.get(feeType) == 'Half' ? (newOpportunity.Total_Sem__c/2 + 1) : Decimal.valueOf(mapOfFeeTypeVsFutureSem.get(feeType)));
                
                opptyListToInsert = new List<Opportunity>();
                newOpportunity.nm_Future_Sems_Created__c = true;
                Map<Decimal,Opportunity> mapOfTermVsOpportunity = new Map<Decimal,Opportunity>();
                for (Decimal i = 2; i <= totalSem; i++) {
                    Decimal previous = i - 1;
                    system.debug('previous--->'+previous);
                    
                   if(!mapOfTermVsOpportunity.containsKey(i))
                    {
                        Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(previous)? mapOfTermVsOpportunity.get(previous) : newOpportunity;
                        Opportunity futureSem = getNextSemOpportunity(nextOpportunity,semGap,feeType);
                        mapOfTermVsOpportunity.put(i,futureSem);
                    }
                }
                
                try{
                    insert mapOfTermVsOpportunity.values();
                }catch(DMLException e){
                    System.debug('Error ---'+e.getMessage());
                }

                system.debug('!!!!!opptyListToInsert!!!!!!'+opptyListToInsert);
                // nm_Payment__c existingPaymentObj = getPaymentForOpportunity(newOpportunity.Id);
                // // newOpportunity.IsTerm__c == false
                // // if(existingPaymentObj != null) {
                // if(newOpportunity.IsTerm__c == false) {
                // system.debug('<------------------------------existingPaymentObj ---------------->'+existingPaymentObj );
                // for (Decimal i = 2; i <= totalSem; i++) { 
                //     nm_Payment__c semPayment = existingPaymentObj.clone();
                //     semPayment.nm_OpportunityNew__c = mapOfTermVsOpportunity.get(i).Id;
                //     semPayment.nm_Amount__c= 0;
                //     semPayment.ExportFeeReceipt__c=false;
                //     semPayment.Receipt_Number__c = null;
                //     System.debug('<-------------------------sem'+i+'Payment-------------->'+semPayment);
                //     paymentListToInsert.add(semPayment);
                // }   
                // }
                         
                
                // try{
                //     insert paymentListToInsert;
                // }catch(DMLException e){
                //     System.debug('Error ---'+e.getMessage());
                // }
                         
            }

            if(newOpportunity.nm_Fee_Type__c == 'MBAallTermfee-Considered' && 
                newOpportunity.nm_Future_Sems_Created__c == false && 
                newOpportunity.StageName != oldOpportunity.StageName &&  
                newOpportunity.StageName == 'Closed Won'){
                    newOpportunity.nm_Future_Sems_Created__c = true;
                    //AccountId.add(newOpportunity.AccountID);
                 //   currentSem = newOpportunity.nm_Semester__c;
                 system.debug('newOpportunity.nm_Semester__c---->'+newOpportunity.nm_Semester__c);
                system.debug('newOpportunity.nm_Session__c---->'+newOpportunity.nm_Session__c);
                system.debug('newOpportunity.nm_Year__c---->'+newOpportunity.nm_Year__c);   
                updatefutureSessionyear(newOpportunity.AccountID,
                Integer.valueof(newOpportunity.nm_Semester__c),
                newOpportunity.nm_Session__c,
                Integer.valueof(newOpportunity.nm_Year__c));
            }
                
            if(newOpportunity.nm_Fee_Type__c == 'MBAallTermfee-Considered' && 
                newOpportunity.nm_Future_Sems_Created__c == true && 
                newOpportunity.StageName != oldOpportunity.StageName &&  
                newOpportunity.StageName == 'De-Registered'){
             //  system.debug('newOpportunity.Account.BatchStartD__c--->'+newOpportunity.Account.BatchStartD__c);
                //newOpportunity.nm_Semester__c = String.valueof(Integer.valueof(newOpportunity.nm_Semester__c) - 1);
               Opportunity sem2Opp = getNextSemOpportunity(newOpportunity, Integer.valueof(newOpportunity.nm_Semester__c),feeType);
                
                boolean validateDeregistered = Validity(newOpportunity.BatchStartD__c,sem2Opp,newOpportunity);
                if(validateDeregistered)
                {
                    opptyListToInsert.add(sem2Opp);
                    insert opptyListToInsert;
                    system.debug('!!!!!de-register!!!!!!'+opptyListToInsert);
                    
                    updatefutureSessionyear(opptyListToInsert[0].AccountID,
                                         Integer.valueof(opptyListToInsert[0].nm_Semester__c),
                                         opptyListToInsert[0].nm_Session__c,
                                         Integer.valueof(opptyListToInsert[0].nm_Year__c));
                }else{
                    
                     newOpportunity.addError('Opportunity cannot De register ');
                }
            }
               
        }
        
    }

    public Opportunity getNextSemOpportunity(Opportunity currentSemOpportunity,Integer sem,String feeType){
      
     /*  Opportunity nextSemOpportunity = new Opportunity();
        if(currentSemOpportunity.nm_Session__c == 'January'){
            nextSemOpportunity.nm_Session__c = 'April';
             nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c == 'April'){
            nextSemOpportunity.nm_Session__c = 'July';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c ;
        }else if(currentSemOpportunity.nm_Session__c == 'July'){
            nextSemOpportunity.nm_Session__c = 'October';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c == 'October'){
            nextSemOpportunity.nm_Session__c = 'January';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c + 1;         
        }*/
         Opportunity nextSemOpportunity = new Opportunity();
        if(currentSemOpportunity.nm_Session__c == 'January'){
            nextSemOpportunity.nm_Session__c = 'April';
             nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c == 'April'){
            nextSemOpportunity.nm_Session__c = 'July';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c ;
        }else if(currentSemOpportunity.nm_Session__c == 'July'){
            nextSemOpportunity.nm_Session__c = 'October';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c == 'October'){
            nextSemOpportunity.nm_Session__c = 'January';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c + 1;         
        }else if(currentSemOpportunity.nm_Session__c =='September'){
             nextSemOpportunity.nm_Session__c = 'December';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c =='June'){
             nextSemOpportunity.nm_Session__c = 'September';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c =='March'){
             nextSemOpportunity.nm_Session__c = 'June';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c =='December'){
             nextSemOpportunity.nm_Session__c = 'March';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c+1;
        }
        
        //Integer nextSem = sem >0? sem:Integer.valueOf(currentSemOpportunity.nm_Semester__c ) + 1;
         Decimal nextSem = Decimal.valueOf(currentSemOpportunity.nm_Semester__c ) + 1;
        nextSemOpportunity.StageName = 'Closed Won - Re-registration Pending';
        nextSemOpportunity.nm_Fee_Type__c = feeType+'-Considered';//Changing so that trigger does not fire again and future Opportunities are not further created
        nextSemOpportunity.nm_Semester__c = String.valueOf(nextSem);
        nextSemOpportunity.Is_Re_Registration_Payment__c = true;
        nextSemOpportunity.Dispatch_Order_For_Student__c = false;
        nextSemOpportunity.Fee_Receipt_Dispatched__c = false;
        nextSemOpportunity.Fee_Receipt_Dispatched_Date__c =null;
        nextSemOpportunity.Total_Amount_Received__c=null;
        nextSemOpportunity.nm_TotalApprovedPayment__c=null;     
        nextSemOpportunity.Dispatch_Order_Number_For_Student__c=null;
        nextSemOpportunity.Name = 'test';      
        nextSemOpportunity.CloseDate =System.today();
        nextSemOpportunity.AccountId=currentSemOpportunity.AccountId;
        nextSemOpportunity.nm_StudentProgram__c=currentSemOpportunity.nm_StudentProgram__c;
        nextSemOpportunity.nm_Program__c=currentSemOpportunity.nm_Program__c;   
        nextSemOpportunity.nm_Program2__c=currentSemOpportunity.nm_Program2__c!=null?currentSemOpportunity.nm_Program2__c:null;            
        nextSemOpportunity.nm_Future_Sems_Created__c = true;
        nextSemOpportunity.nm_Payment_Approved__c= true;
      //  nextSemOpportunity.Total_Sem__c = currentSemOpportunity.Total_Sem__c ;
     //   nextSemOpportunity.PVM__c = currentSemOpportunity.PVM__c ;
        return nextSemOpportunity;
    }
    
    public Boolean Validity(Date BatchStart,Opportunity objopps,Opportunity currentopps) {
        
       Date expectedDate;
       Date ValidityExpiryDate;
       Integer SessionMonth;
       Integer SingleSem ;
        Map<String,Integer> MonthStringvsInteger = new Map<String,Integer>();
        
         if( MonthStringvsInteger.IsEmpty() )
        {
            MonthStringvsInteger.put('January',01);
            MonthStringvsInteger.put('February',02);
            MonthStringvsInteger.put('March',03);
            MonthStringvsInteger.put('April',04);
            MonthStringvsInteger.put('May',05);
            MonthStringvsInteger.put('June',06);
            MonthStringvsInteger.put('July',07);
            MonthStringvsInteger.put('August',08);
            MonthStringvsInteger.put('September',09);
            MonthStringvsInteger.put('October',10);
            MonthStringvsInteger.put('November',11);
            MonthStringvsInteger.put('December',12);
        }
        
        if(BatchStart!=null )
        {
            SessionMonth = MonthStringvsInteger.get(objopps.nm_Session__c);
             expectedDate = date.newinstance(Integer.valueof(objopps.nm_Year__c),SessionMonth,01);
            SingleSem = Integer.valueof(currentopps.PVM__c) / Integer.valueof(currentopps.Total_Sem__c);
            SingleSem = Integer.valueof(currentopps.Sem__c )* SingleSem;
            system.debug('SingleSem---->'+SingleSem );
         
           
            
           //system.debug('add month'+(()-1));
            ValidityExpiryDate =  BatchStart.addMonths(SingleSem);
            system.debug('ValidityExpiryDate--->'+ValidityExpiryDate);
            system.debug('expectedDate--->'+expectedDate);
        }
       
        if(ValidityExpiryDate>expectedDate)
        {
            return true;
        }else
        {
            return false;
        }

       
    }
       @future
    public static  void updatefutureSessionyear (Id AcctID,Integer currentSem,String currentsession,Integer currentyear)
    {   list<Opportunity> lstopportunitytoupdate = new list<Opportunity>();
        list<Opportunity> lstopportunity = [select id,nm_Session__c,nm_Year__c,Sem__c from Opportunity where accountid=:AcctID  ORDER BY Sem__c asc];
        if(lstopportunity.size()>0)
        {
            for(Opportunity objopps : lstopportunity)
            {
               system.debug('objopps--->'+objopps);
                if(objopps.Sem__c>currentSem)
                {
                system.debug('objopps.Sem__c--->'+objopps.Sem__c);
                system.debug('currentSem--->'+currentSem);
                system.debug('currentsession--->'+currentsession);
                system.debug('currentyear--->'+currentyear);
                    if(currentsession=='January')   
                  {
                      objopps.nm_Session__c =  'April';
                      currentsession = 'April';
                      objopps.nm_Year__c = currentyear;
                       system.debug('s1');
                    //  break;
                  }else if(currentsession == 'April'){
                      objopps.nm_Session__c = 'July';
                      currentsession = 'July';
                      objopps.nm_Year__c = currentyear;
                       system.debug('s2');
                      // break;
                      
                  }else if(currentsession == 'July'){
                      objopps.nm_Session__c = 'October';
                      currentsession = 'October';
                      objopps.nm_Year__c = currentyear;
                       system.debug('s3');
                     //  break;
                  }else if(currentsession == 'October'){
                      currentsession = 'January';
                      currentyear = currentyear+1;
                      objopps.nm_Session__c = 'January';                      
                      objopps.nm_Year__c = currentyear;
                       system.debug('s4');
                     //  break;
                      
                  }else if(currentsession == 'September'){
                      currentsession = 'December';
                      currentyear = currentyear;
                      objopps.nm_Session__c = 'December';                      
                      objopps.nm_Year__c = currentyear;
                       system.debug('s4');
                     //  break;
                      
                  }else if(currentsession == 'June'){
                      currentsession = 'September';
                      currentyear = currentyear;
                      objopps.nm_Session__c = 'September';                      
                      objopps.nm_Year__c = currentyear;
                       system.debug('s4');
                     //  break;
                      
                  }else if(currentsession == 'March'){
                      currentsession = 'June';
                      currentyear = currentyear;
                      objopps.nm_Session__c = 'June';                      
                      objopps.nm_Year__c = currentyear;
                       system.debug('s4');
                     //  break;
                      
                  }else if(currentsession == 'December'){
                      currentsession = 'March';
                      currentyear = currentyear+1;
                      objopps.nm_Session__c = 'March';                      
                      objopps.nm_Year__c = currentyear;
                       system.debug('s4');
                     //  break;
                      
                  }
                }
                  
              lstopportunitytoupdate.add(objopps);
              system.debug(lstopportunitytoupdate);
            }
        }
        if(lstopportunitytoupdate.size()>0)
        {
            update lstopportunitytoupdate;
        }
    }

}