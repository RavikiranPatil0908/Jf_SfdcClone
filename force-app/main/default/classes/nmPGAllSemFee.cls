/**
 * @File Name          : nmPGAllSemFee.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 14-08-2024
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    29/5/2020   shubhranshu     Initial Version
**/
public class nmPGAllSemFee
{   
    public string query{get;set;}
    public void createNextSemOpportunityOnClosedWonForFullFee(List<Opportunity> triggerNew, map<id, Opportunity> oldMap)
    {
        nmOpportunityTriggerHandler objCall = new nmOpportunityTriggerHandler();
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        List<nm_Payment__c> paymentListToInsert = new List<nm_Payment__c>();
        Map<String,String> mapOfFeeTypeVsFutureSem = new Map<String,String>{'PGAllSemFee' => 'All', 'AnnualFee' => 'Half', '2TermFee' => 'Half',
        'FullFee' => 'All', '3SemFee' => '3','3TermFee' => '3', '4SemFee' => '4', '5SemFee'=>'5', 'MultipleSemFee' => '3','FullFeeLoan' => 'All', 'AnnualFeeLoan' => 'Half'};
        
          Map<String,String> mapOfLectureTypeVsFutureSem = new Map<String,String>{'2SemLecturesFee' => '2','3SemLecturesFee' => '3', '4SemLecturesFee' => '4'};
        
        for(Opportunity newOpportunity : triggerNew) {
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
                Decimal waiverSemforLec =0;
                if(mapOfFeeTypeVsFutureSem.get(feeType) == 'All') {
                    totalSem = newOpportunity.Total_Sem__c;
                } else if(mapOfFeeTypeVsFutureSem.get(feeType) == 'Half') {
                    totalSem = newOpportunity.IsTerm__c ? newOpportunity.Total_Sem__c/2 : 2 ;
                } else {
                    totalSem = Decimal.valueOf(mapOfFeeTypeVsFutureSem.get(feeType));
                }
                                
                // Decimal totalSem = mapOfFeeTypeVsFutureSem.get(feeType) == 'All' ? newOpportunity.Total_Sem__c 
                // : (mapOfFeeTypeVsFutureSem.get(feeType) == 'Half' ? (newOpportunity.Total_Sem__c/2 + 1) : Decimal.valueOf(mapOfFeeTypeVsFutureSem.get(feeType)));
                
                //Lecture type
                if(mapOfLectureTypeVsFutureSem.containsKey(LectureType))
                {
                    waiverSemforLec = Decimal.valueOf(mapOfLectureTypeVsFutureSem.get(LectureType));
                }
                system.debug('waiverSemforLec-->'+waiverSemforLec);
                opptyListToInsert = new List<Opportunity>();
                newOpportunity.nm_Future_Sems_Created__c = true;
                Map<Decimal,Opportunity> mapOfTermVsOpportunity = new Map<Decimal,Opportunity>();
                for (Decimal i = 2; i <= totalSem; i++) {
                    Decimal previous = i - 1;
                    system.debug('previous--->'+previous);
                    
                    for(Decimal j = 2; j <= waiverSemforLec; j++)
                    {
                        Decimal previous1 = j - 1;
                        system.debug('previous1-->'+previous1);
                        Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(previous1) ? mapOfTermVsOpportunity.get(previous1) : newOpportunity;
                        Opportunity futureSem = getNextSemOpportunity(nextOpportunity,semGap,feeType,LectureType);
                        mapOfTermVsOpportunity.put(j,futureSem);
                    }
                   if(!mapOfTermVsOpportunity.containsKey(i))
                    {
                        Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(previous)? mapOfTermVsOpportunity.get(previous) : newOpportunity;
                        Opportunity futureSem = getNextSemOpportunity(nextOpportunity,semGap,feeType,'');
                        mapOfTermVsOpportunity.put(i,futureSem);
                    }
                }
                
                try{
                    insert mapOfTermVsOpportunity.values();
                }catch(DMLException e){
                    System.debug('Error ---'+e.getMessage());
                }

                system.debug('!!!!!opptyListToInsert!!!!!!'+opptyListToInsert);
                nm_Payment__c existingPaymentObj = getPaymentForOpportunity(newOpportunity.Id);
                // newOpportunity.IsTerm__c == false
                // if(existingPaymentObj != null) {
                if(newOpportunity.IsTerm__c == false) {
                system.debug('<------------------------------existingPaymentObj ---------------->'+existingPaymentObj );
                for (Decimal i = 2; i <= totalSem; i++) { 
                    nm_Payment__c semPayment = existingPaymentObj.clone();
                    semPayment.nm_OpportunityNew__c = mapOfTermVsOpportunity.get(i).Id;
                    semPayment.nm_Amount__c= 0;
                    semPayment.ExportFeeReceipt__c=false;
                    semPayment.Receipt_Number__c = null;
                    System.debug('<-------------------------sem'+i+'Payment-------------->'+semPayment);
                    paymentListToInsert.add(semPayment);
                }   
                }
                         
                
                try{
                    insert paymentListToInsert;
                }catch(DMLException e){
                    System.debug('Error ---'+e.getMessage());
                }
                         
            }//Run When Fee type Consideration opportunity change the Live lecture type while re-registering 
            else if(mapOfLectureTypeVsFutureSem.containsKey(LectureType)
                && newOpportunity.nm_Future_Sems_Created__c == true
                && newOpportunity.nm_Fee_Type__c.contains('Considered') 
                && newOpportunity.StageName != oldOpportunity.StageName  
                && newOpportunity.StageName == 'Closed Won')
            {
                system.debug('Live lecture update');
                Decimal waiverSemforLec =0;
                 Map<Decimal,Opportunity> mapOfTermVsOpportunity = new Map<Decimal,Opportunity>();
                 List<Opportunity> lstCloseWonRegPendingupdate  = new List<Opportunity>();
                
                  if(mapOfLectureTypeVsFutureSem.containsKey(LectureType))
                {
                    waiverSemforLec = Decimal.valueOf(mapOfLectureTypeVsFutureSem.get(LectureType));
                }
                if(waiverSemforLec>0)
                {
                    List<Opportunity> lstCloseWonRegPending  = [select id,Sem__c,LiveLecturesType__c, nm_Fee_Type__c,nm_Future_Sems_Created__c from Opportunity where nm_Fee_Type__c like '%-Considered%' and AccountID = :newOpportunity.AccountId AND nm_Semester__c > :newOpportunity.nm_Semester__c  AND StageName = 'Closed Won - Re-registration Pending' ];
                    
                    if(lstCloseWonRegPending.size()>0)
                    {
                        for (Opportunity objoppor : lstCloseWonRegPending)
                        {
                            mapOfTermVsOpportunity.put(objoppor.Sem__c,objoppor);
                        }
                    }
                    
                    for(Decimal j = 2; j <= waiverSemforLec; j++)
                    {
                        Decimal previous1 = j - 1;
                        Decimal NextSem = newOpportunity.Sem__c+previous1;
                        system.debug('previous1-->'+previous1);
                        system.debug('NextTargetSm-->'+NextSem);
                       // Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(previous1) ? mapOfTermVsOpportunity.get(previous1) : null;
                       Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(NextSem) ? mapOfTermVsOpportunity.get(NextSem) : null;
                       if(nextOpportunity!=null)
                        {
                             nextOpportunity.LiveLecturesType__c = LectureType!=null && LectureType!=''  && LectureType!='No'  && LectureType!='Custom'? LectureType+'-Considered':'';
                             //mapOfTermVsOpportunity.put(j,nextOpportunity);
                             lstCloseWonRegPendingupdate.add(nextOpportunity);
                        }
                      
                    }
                         try{
                             if(lstCloseWonRegPendingupdate.size()>0)
                             {
                                update lstCloseWonRegPendingupdate;
                             }
                        
                    }catch(DMLException e){
                        System.debug('Error ---'+e.getMessage());
                    }
                }
                
            }
            
        }
        
    }
           
    
    public nm_Payment__c getPaymentForOpportunity(Id id){
            List<nm_Payment__c> paymentList = new List<nm_Payment__c>();
            //nm_Payment__c paymentList = new nm_Payment__c();
            String SobjectApiName = 'nm_Payment__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
            String commaSepratedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            }
            
            query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where nm_OpportunityNew__c = \''+ id + '\' AND nm_PaymentType__c = \'Admission\' AND nm_PaymentStatus__c = \'Payment Approved\' AND nm_OpportunityNew__r.IsTerm__c = false';
            system.debug('!!!!!!!query!!!!!!!'+query);
            paymentList = Database.query(query);
            system.debug('!!!!!!!paymentList!!!!!!!'+paymentList);
            if(paymentList.size() > 0)
            {
            return paymentList[0];
            }
            else
            {
            return null;
            }
            
    }
    
    public Opportunity getNextSemOpportunity(Opportunity currentSemOpportunity,Integer semGap,String feeType,String LectureType){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                                    6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
                                                                    11=>'November', 12=>'December'};
        Map<String,Integer> monthNumberMap = new Map<String,Integer>{'January'=>1,'February'=>2,'March'=>3,'April'=>4,'May'=>5,
                                                                    'June'=>6,'July'=>7,'August'=>8,'September'=>9,'October'=>10,
                                                                    'November'=>11,'December'=>12};
                                                                    System.debug('currentSemOpportunity.nm_Year__c-->'+currentSemOpportunity.nm_Year__c);
        Integer year = Integer.valueOf(currentSemOpportunity.nm_Year__c);                                                   
        Date firstDate = Date.newInstance(year, monthNumberMap.get(currentSemOpportunity.nm_Session__c), 1);
        Date newDate = firstDate.addMonths(semGap);
        Integer month = newDate.month();
        year = newDate.year();
        Opportunity nextSemOpportunity = new Opportunity();
        nextSemOpportunity.nm_Session__c = monthNameMap.get(month);
        nextSemOpportunity.nm_Year__c = year;
        
        Decimal nextSem = Decimal.valueOf(currentSemOpportunity.nm_Semester__c ) + 1;
        nextSemOpportunity.Name = 'test';
        nextSemOpportunity.StageName = 'Closed Won - Re-registration Pending';
        nextSemOpportunity.CloseDate =System.today();
        nextSemOpportunity.nm_Fee_Type__c = feeType+'-Considered';//Changing so that trigger does not fire again and future Opportunities are not further created
        nextSemOpportunity.nm_Semester__c = String.valueOf(nextSem);
        nextSemOpportunity.LiveLecturesType__c = LectureType!=null && LectureType!=''  && LectureType!='No'  && LectureType!='Custom'? LectureType+'-Considered':'';
        nextSemOpportunity.AccountId=currentSemOpportunity.AccountId;
        nextSemOpportunity.nm_StudentProgram__c=currentSemOpportunity.nm_StudentProgram__c;
        nextSemOpportunity.nm_Program__c=currentSemOpportunity.nm_Program__c;       
        nextSemOpportunity.Is_Re_Registration_Payment__c = true;
        nextSemOpportunity.nm_Future_Sems_Created__c = true;
        nextSemOpportunity.nm_Payment_Approved__c= true;
     
        return nextSemOpportunity;
    }

}