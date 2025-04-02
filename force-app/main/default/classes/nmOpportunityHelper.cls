global  class nmOpportunityHelper {
    
    //@AuraEnabled
    webService static void doUndoReregistrationCancellation(String opportunityId, String accountId){
        try{

          //  Set<Id> opportunityIds = new Set<Id>();

        List<Opportunity> lstOpportunity = [SELECT Id ,AccountId,nm_Semester__c,StageName,PreviousStageName__c,Is_Re_Registration_Payment__c, nm_Program__r.nm_Type__c, nm_Program__r.Specialisation__c,(Select Id, name,ListPrice,UnitPrice,ActualSalePrice__c,Product_Name_text__c,ProgramName2__c From OpportunityLineItems) FROM Opportunity WHERE AccountId =: accountId];
        Map<Id,Opportunity> mapOfOppIdVsOpps = new Map<Id,Opportunity>();
        for(Opportunity accObj : lstOpportunity) {

                
            mapOfOppIdVsOpps.put(accObj.Id,accObj);
            
          //  opportunityIds.add(accObj.Id);
        }

        List<Career_Service_Program__c> careerServicelst = [SELECT Id , Stage__c, Opportunity__c,Account__c, CareerServiceProgram__c,Current_semester__c FROM Career_Service_Program__c WHERE Opportunity__c  =: opportunityId AND Stage__c = 'Cancelled'];
        
        Map<Id,Career_Service_Program__c> mapOFCareerseriIdVsCareerService= new Map<Id,Career_Service_Program__c>();
        if(careerServicelst != null){
            for(Career_Service_Program__c csObj : careerServicelst)
            {
                    mapOFCareerseriIdVsCareerService.put(csObj.Id,csObj);
            }
        }
        

        List<nmRefund_Payment__c> refundPaymentlst = [SELECT Id,Opportunity__c,Account__c, Type_of_Refund__c,Status__c FROM nmRefund_Payment__c WHERE Opportunity__c IN : mapOfOppIdVsOpps.keySet() ];
        Map<Id,List<nmRefund_Payment__c>> mapOfOppIdVsRefundPayment = new Map<Id,List<nmRefund_Payment__c>>();
        if(refundPaymentlst != null && refundPaymentlst.size() >0){
        for(nmRefund_Payment__c accObj : refundPaymentlst) {

            if(mapOfOppIdVsRefundPayment.containsKey(accObj.Opportunity__c))
            {
                mapOfOppIdVsRefundPayment.get(accObj.Opportunity__c).add(accObj);
            }
            else
            {
                List<nmRefund_Payment__c> oppList = new List<nmRefund_Payment__c>();
                oppList.add(accObj);
                mapOfOppIdVsRefundPayment.put(accObj.Opportunity__c,oppList);
            }
        }
        Set<String> validStatuses = new Set<String>{
            'Refund Request Created','Application Send to Student','Refund form Submitted','Refund Submitted to Finance'
        };
        //'Refund Request Created','Application send to student','Refund form submitted','Refund submitted to Finance','Payment Refunded';
        //'Refund submitted to Finance','Payment Refunded'  --- check at button level
        List<nmRefund_Payment__c> refundUpdateBucket = new List<nmRefund_Payment__c>();
        List<Opportunity> OpportunityUpdateBucket = new List<Opportunity>();
        
            if(mapOfOppIdVsRefundPayment != null && mapOfOppIdVsRefundPayment.get(opportunityId).size() > 0 && mapOfOppIdVsOpps.get(opportunityId).StageName == 'Re-registration Cancelled' && mapOfOppIdVsOpps.get(opportunityId).Is_Re_Registration_Payment__c == true){
                List<nmRefund_Payment__c> refundList = mapOfOppIdVsRefundPayment.get(opportunityId);
                for(nmRefund_Payment__c refundObj : refundList){
                    if(validStatuses.contains(refundObj.Status__c)){
                        refundObj.Status__c = 'Application Rejected By Student';
                        refundUpdateBucket.add(refundObj);
                    } 
                }  
            }
            for(Opportunity oppObj : lstOpportunity)
            {
                if(oppObj.nm_Semester__c > mapOfOppIdVsOpps.get(opportunityId).nm_Semester__c )
                {

                    oppObj.StageName = 'Closed Won - Re-registration Pending';
                    OpportunityUpdateBucket.add(oppObj);
                }
                else if(oppObj.nm_Semester__c == mapOfOppIdVsOpps.get(opportunityId).nm_Semester__c ){
                    oppObj.StageName = oppObj.PreviousStageName__c;
                    oppObj.PreviousStageName__c = '';
                    OpportunityUpdateBucket.add(oppObj); 
                }
            }

        if(refundUpdateBucket != null && refundUpdateBucket.size() > 0)
        {
            update refundUpdateBucket;
        }
        
        if(OpportunityUpdateBucket != null && OpportunityUpdateBucket.size() > 0)
        {
            update OpportunityUpdateBucket;
        }

        if(careerServicelst != null && careerServicelst.size() > 0){
            Career_Service_Program__c careerService = [SELECT Id , Stage__c, Opportunity__c,Account__c, CareerServiceProgram__c,Current_semester__c FROM Career_Service_Program__c WHERE Opportunity__c =: opportunityId AND Stage__c = 'Cancelled'];
            if(careerService != null){
                careerService.Stage__c = 'Payment Done';
                if(careerService != null)
                {
                    update careerService;
                }
            }
            List<nmRefund_Payment__c> refundPaymentCareerServicelst = [SELECT Id,Opportunity__c,Account__c, Type_of_Refund__c,Status__c FROM nmRefund_Payment__c WHERE CareerServiceProgram__c  =: careerService.Id  AND Account__c =: careerService.Account__c AND Type_of_Refund__c = 'Career Service Cancellation'];
            List<nmRefund_Payment__c> refundcareerservicesUpdateBucket = new List<nmRefund_Payment__c>();
                if(refundPaymentCareerServicelst != null)
                {
                    // refundPaymentCareerService.Status__c = 'Application Rejected By Student';
                    // update refundPaymentCareerService;

                    
                for(nmRefund_Payment__c refundObj : refundPaymentCareerServicelst){
                    if(validStatuses.contains(refundObj.Status__c)){
                        refundObj.Status__c = 'Application Rejected By Student';
                        refundcareerservicesUpdateBucket.add(refundObj);
                    } 
                } 
                }
                if(refundcareerservicesUpdateBucket != null && refundcareerservicesUpdateBucket.size() > 0)
                {
                    update refundcareerservicesUpdateBucket;
                }
        

        }
        
    } 
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }

        
    }


}