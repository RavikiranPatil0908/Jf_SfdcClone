public class nmMultipleFee
{
public string query{get;set;}
    public void createNextSemOpportunityOnClosedWonForMultipleSem(List<Opportunity> triggerNew, map<id, Opportunity> oldMap)
    {
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        List<nm_Payment__c> paymentListToInsert = new List<nm_Payment__c>();
        
        for(Opportunity newOpportunity : triggerNew)
        {
            Id opptyId = newOpportunity.Id;
            Opportunity oldOpportunity =  oldMap.get(opptyId);
            System.debug('New Opp stage ----->'+newOpportunity.StageName+' '+'old opp stage--------->'+oldOpportunity.StageName);
            System.debug('!!!!!newOpportunity!!!' + newOpportunity);
            if(newOpportunity.nm_Fee_Type__c == 'MultipleSemFee' && 
                newOpportunity.nm_Future_Sems_Created__c == false && 
                newOpportunity.StageName != oldOpportunity.StageName &&  
                newOpportunity.StageName == 'Closed Won'){
                
                opptyListToInsert = new List<Opportunity>();
                newOpportunity.nm_Future_Sems_Created__c = true;
                Opportunity sem2Opp = getNextSemOpportunity(newOpportunity);
                Opportunity sem3Opp = getNextSemOpportunity(sem2Opp);
                opptyListToInsert.add(sem2Opp);
                opptyListToInsert.add(sem3Opp);
                
                insert opptyListToInsert;
                system.debug('!!!!!opptyListToInsert!!!!!!'+opptyListToInsert);
                nm_Payment__c existingPaymentObj = getPaymentForOpportunity(newOpportunity.Id);
                system.debug('!!!!!existingPaymentObj!!!!!!'+existingPaymentObj);
                nm_Payment__c sem2Payment = existingPaymentObj.clone();
                sem2Payment.nm_OpportunityNew__c = sem2Opp.Id;
                sem2Payment.nm_Amount__c= 0;
                sem2Payment.ExportFeeReceipt__c=false;
                sem2Payment.Receipt_Number__c = null;
               
                nm_Payment__c sem3Payment = existingPaymentObj.clone();
                sem3Payment.nm_OpportunityNew__c = sem3Opp.Id;
                sem3Payment.nm_Amount__c= 0;
                sem3Payment.ExportFeeReceipt__c=false;
                sem3Payment.Receipt_Number__c = null;
                
                paymentListToInsert.add(sem2Payment);
                paymentListToInsert.add(sem3Payment);
               
                insert paymentListToInsert;
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
            
            query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where nm_OpportunityNew__c = \''+ id + '\' AND nm_PaymentType__c = \'Admission\' AND nm_PaymentStatus__c = \'Payment Approved\'';
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
            //return paymentList;
    }
    
    public Opportunity getNextSemOpportunity(Opportunity currentSemOpportunity){
        
       // Opportunity nextSemOpportunity = currentSemOpportunity.clone();
        Opportunity nextSemOpportunity = new Opportunity();
        if(currentSemOpportunity.nm_Session__c == 'January'){
            nextSemOpportunity.nm_Session__c = 'July';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c;
        }else if(currentSemOpportunity.nm_Session__c == 'July'){
            nextSemOpportunity.nm_Session__c = 'January';
            nextSemOpportunity.nm_Year__c = currentSemOpportunity.nm_Year__c + 1;
        }
        
        Integer nextSem = Integer.valueOf(currentSemOpportunity.nm_Semester__c ) + 1;
        nextSemOpportunity.Name = currentSemOpportunity.AccountId;
        nextSemOpportunity.StageName = 'Closed Won - Re-registration Pending';
        nextSemOpportunity.CloseDate =System.today();       
        nextSemOpportunity.nm_Fee_Type__c = 'MultipleSemFee-Considered';//Changing so that trigger does not fire again and future Opportunities are not further created
        nextSemOpportunity.nm_Semester__c = String.valueOf(nextSem);
        nextSemOpportunity.AccountId=currentSemOpportunity.AccountId;
        nextSemOpportunity.nm_StudentProgram__c=currentSemOpportunity.nm_StudentProgram__c;
        nextSemOpportunity.nm_Program__c=currentSemOpportunity.nm_Program__c;       
        nextSemOpportunity.Is_Re_Registration_Payment__c = true;
        nextSemOpportunity.nm_Future_Sems_Created__c = true;
        nextSemOpportunity.nm_Payment_Approved__c= true;
     /*   nextSemOpportunity.Fee_Receipt_Dispatched_Date__c =null;
        nextSemOpportunity.Processed__c =false;
        nextSemOpportunity.AdmissionPaymentID__c=null;
        nextSemOpportunity.Dispatch_Order_Number_For_Student__c=null;
        nextSemOpportunity.Synced_With_StudentZone__c =false;*/
        return nextSemOpportunity;
    }

}