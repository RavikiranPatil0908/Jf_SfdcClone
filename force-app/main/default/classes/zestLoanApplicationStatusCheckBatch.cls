/**
 * @File Name          : zestLoanApplicationStatusCheckBatch.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 02-01-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/11/2020   shubhranshu     Initial Version
**/
global class zestLoanApplicationStatusCheckBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    set<Opportunity> successList = new set<Opportunity>();
    Map<String,Opportunity> mapOfOpportunityIdVsOpportunity = new Map<String,Opportunity>();
    List<String> errorList = new List<String>();
    Map<String,Opportunity> mapOfOpportunityIdAndOpportunity = new Map<String,Opportunity>();
    ZestWebService objZestWebService = new ZestWebService();
    
    global void execute(SchedulableContext sc) {
      zestLoanApplicationStatusCheckBatch b = new zestLoanApplicationStatusCheckBatch();
      Database.executebatch(b, 20);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Started Loan Application Check Batch');
        String query = getQueryAllFieldSql('Opportunity', ' Loan_Type__c = \'Zest\' and Loan_Sanctioned__c = false and (NOT Loan_Order_Status__c Like \'%Cancelled%\') and (NOT Loan_Order_Status__c Like \'%Declined%\') and Down_Payment_Made__c = true ');
        return DataBase.getQueryLocator(query);
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString) {
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> scope){
        for(Sobject s : scope){
            Opportunity objOpportunity = (Opportunity)s;
            callGetLoanApplicationStatusByOrderIdAPI(objOpportunity);
            callDeliveredLoanApplicationAPI(objOpportunity);
            callCancelledLoanApplicationAPI(objOpportunity);
            callRefundAPI(objOpportunity);
        }
        
        if(!mapOfOpportunityIdVsOpportunity.isEmpty()){
           List<Opportunity> lstOppsToUpdate = new List<Opportunity>(successList);
           for(String opportunityId : mapOfOpportunityIdVsOpportunity.keySet()){
               lstOppsToUpdate.add(mapOfOpportunityIdVsOpportunity.get(opportunityId));
           }
           
           if(lstOppsToUpdate.size() > 0){ 
               update lstOppsToUpdate;
           }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Finished');
    }
    
    public void callGetLoanApplicationStatusByOrderIdAPI(Opportunity objOpportunity){
        System.debug('Loan Order Id --->'+objOpportunity.Loan_Order_Id__c);
        Boolean isSubventionScheme = String.isNotBlank(objOpportunity.Interest_Rate__c) && (objOpportunity.Interest_Rate__c == '0' || objOpportunity.Interest_Rate__c == '0.0') ? true : false;
        String jsonString = objZestWebService.getLoanApplicationStatusByOrderId(objOpportunity.Loan_Order_Id__c,isSubventionScheme);
        if(jsonString !=null && jsonString !=''){
            Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(jsonString);
            /*
                sample out put getOrder Status by Order Id
                {"ApplicationId":"dfae5fb8-04e1-440a-9f8e-dc896e1344a5","OrderStatus":"MerchantCancelled","DeliveryPinCode":"400043","BasketAmount":76000.00}
            */
            if(!mapOfResponseParameters.isEmpty()){
                for(String key : mapOfResponseParameters.keySet()){
                    System.debug('key :-'+key+'---value---'+mapOfResponseParameters.get(key));
                    objOpportunity.Loan_Application_Id__c = String.valueOf(mapOfResponseParameters.get('ApplicationId'));
                    objOpportunity.Loan_Order_Status__c =  String.valueOf(mapOfResponseParameters.get('OrderStatus'));
                }
            }
            if('Active'.equalsIgnoreCase(objOpportunity.Loan_Order_Status__c)){// active means they dispose Loan to our account 
                objOpportunity.Loan_Sanctioned__c = true;
            }else if(objOpportunity.Loan_Order_Status__c.contains('Cancelled') || objOpportunity.Loan_Order_Status__c.contains('Declined')){
                objOpportunity.Loan_Application_Cancelled__c = true;
            }
            
            mapOfOpportunityIdVsOpportunity.put(objOpportunity.id,objOpportunity);
        }
    }
    
    // send Notification to Zest as Loan is Approved from Our side Kindly proceed 
    public void callDeliveredLoanApplicationAPI(Opportunity objOpportunity){
        String DeliveryStatus = '';
        if(objOpportunity.Loan_Approved__c ){
            DeliveryStatus = 'Delivered';
        }else if(objOpportunity.Loan_Application_Cancelled__c){
            DeliveryStatus = 'Refused by customer';
        }
        
        if(DeliveryStatus !='' && DeliveryStatus !=null && 'Approved'.equalsIgnoreCase(objOpportunity.Loan_Order_Status__c) ){
            Boolean isSubventionScheme = String.isNotBlank(objOpportunity.Interest_Rate__c) && (objOpportunity.Interest_Rate__c == '0' || objOpportunity.Interest_Rate__c == '0.0') ? true : false;
            String jsonString = objZestWebService.getOrderDeliveryReportByOrderId(objOpportunity.Loan_Order_Id__c,DeliveryStatus,isSubventionScheme,objOpportunity.id,'Opportunity');
            if(jsonString !=null && jsonString !=''){
                objOpportunity.EduVanz_Current_Stage_Name__c = DeliveryStatus; // used Eduvanz field to remove the duplicacy of field for loan status purpose
                callGetLoanApplicationStatusByOrderIdAPI(objOpportunity);
            }
        }
    }
    
     // send Notification to Zest as Loan is Cancelled from Our side Kindly proceed 
    public void callCancelledLoanApplicationAPI(Opportunity objOpportunity){
        if(objOpportunity.Loan_Application_Cancelled__c && objOpportunity.Loan_Cancellation_Reason__c !=null && objOpportunity.Loan_Cancellation_Reason__c !='' && String.isNotBlank(objOpportunity.Loan_Order_Status__c) && !objOpportunity.Loan_Order_Status__c.contains('Cancelled') && !objOpportunity.Loan_Order_Status__c.contains('Declined')){
            Boolean isSubventionScheme = String.isNotBlank(objOpportunity.Interest_Rate__c) && (objOpportunity.Interest_Rate__c == '0' || objOpportunity.Interest_Rate__c == '0.0') ? true : false;
            String jsonString = objZestWebService.CancelledLoanApplicationByOrderId(objOpportunity.Loan_Order_Id__c,objOpportunity.Loan_Cancellation_Reason__c,isSubventionScheme);
            if(jsonString !=null && jsonString !=''){
                callGetLoanApplicationStatusByOrderIdAPI(objOpportunity);//to update Cancelled Order Status on Opportunity 
            }
        }
    }
    
    // send Notification to Zest as Loan Amount to be refund 
    public void callRefundAPI(Opportunity objOpportunity){
        if(objOpportunity.Refund_Loan_Payment__c){
            objOpportunity.Loan_Refund_Id__c = 'REF'+objOpportunity.Loan_Order_Id__c;
            String ReasonCode = 'BuyerRemorse';
            DateTime currentDateTime = System.now();
            String RefundDate = currentDateTime.format('YYYY-MM-dd');
            
            if(objOpportunity.Loan_Refund_Amount__c =='' || objOpportunity.Loan_Refund_Amount__c == null){
                objOpportunity.Loan_Refund_Amount__c = '0';
            }
            if(objOpportunity.Loan_Refund_Date__c == null){
                objOpportunity.Loan_Refund_Date__c = system.today();
            }
            Boolean isSubventionScheme = String.isNotBlank(objOpportunity.Interest_Rate__c) && (objOpportunity.Interest_Rate__c == '0' || objOpportunity.Interest_Rate__c == '0.0') ? true : false;
            String jsonString = objZestWebService.RefundsZestLoan(objOpportunity.Loan_Refund_Id__c,objOpportunity.Loan_Order_Id__c,ReasonCode,objOpportunity.Loan_Refund_IsPartial__c,objOpportunity.Loan_Refund_Amount__c, RefundDate,isSubventionScheme);
            if(jsonString !=null && jsonString !=''){
                callGetLoanApplicationStatusByOrderIdAPI(objOpportunity);//to update Refund Order Status on Opportunity 
            }
        }
    }
}