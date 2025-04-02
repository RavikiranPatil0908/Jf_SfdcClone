/**
 * @File Name          : StoockDeduction.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 23/1/2020, 11:17:37 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/1/2020   shubhranshu     Initial Version
**/
global class StoockDeduction {
    webservice static String stockDeductionForBooks(String skuID,Integer deductionCount,String centerId){
       String result = '';
       Stock_Keeping_Units__c  sku = [Select Id ,Launch_Year__c,Program_Type__c,CM_Books__c from Stock_Keeping_Units__c where Id =:skuID LIMIT 1];

       if(sku != null){
        String CMBooks = String.isNotBlank(sku.CM_Books__c) ? sku.CM_Books__c : '';
        System.debug('CMBooks '+CMBooks);
        if(String.isNotBlank(CMBooks)){
            List<String> lstBooks = sku.CM_Books__c.split(';');
            System.debug(lstBooks +' centerId '+centerId);
            List<Stock__c> lstStocks = [select Id , Quantity__c , Course_Master__c,Course_Master__r.Name from Stock__c Where Course_Master__r.Name IN: lstBooks and Centers__c =:centerId];
            List<Stock__c> updatelstStocks = new List<Stock__c>();
            
            List<Stock__c> lstupdateStockforSKU  = [select Id , CenterName__c ,Outgoing_Quantity__c,Incoming_Quantity__c, Stock_Keeping_Unit__c , Quantity__c from Stock__c Where Stock_Keeping_Unit__c =: skuID and Centers__c =:centerId];
            List<Stock__c> lstinsertStockforSKU = new List<Stock__c>();

            System.debug('lstStocks '+lstStocks);
            if(lstStocks.size() > 0){ 
              for(Stock__c stk : lstStocks){
                  if(stk.Quantity__c >= deductionCount){
                      stk.Quantity__c = stk.Quantity__c - deductionCount;
                  }else{
                     result = 'Quantity is higher than stock in '+stk.Course_Master__r.Name; 
                     return result;
                  }
                   updatelstStocks.add(stk);
              }
            }

            if(updatelstStocks.size() > 0){
                try{
                   update updatelstStocks;
                   result = 'Stock has been updated.';
                }catch(DmlException e){
                    System.debug('Error '+e.getMessage());
                    result = e.getMessage();
                }
            }

            if(lstupdateStockforSKU.size() > 0){
                for(Stock__c stk : lstupdateStockforSKU){
                    stk.Quantity__c = stk.Quantity__c != null ? stk.Quantity__c + deductionCount : deductionCount; 
                }
            }else{
                Stock__c st = new Stock__c();
                st.Centers__c = centerId;
                st.Quantity__c = deductionCount;
                st.Stock_Keeping_Unit__c = skuID;
                st.Outgoing_Quantity__c = 0;
                st.Incoming_Quantity__c = 0;
                lstinsertStockforSKU.add(st);
            }

            System.debug('lstupdateStockforSKU '+lstupdateStockforSKU+' lstinsertStockforSKU '+lstinsertStockforSKU);
            if(lstupdateStockforSKU.size() > 0){
                try{
                    update lstupdateStockforSKU;
                }catch(DmlException e){
                    result = 'Internal error occured'+e.getMessage();
                }
            }else if(lstinsertStockforSKU.size() >0){
                try {
                   insert lstinsertStockforSKU;
                } catch (DmlException e) {
                    result = 'Internal error occured'+e.getMessage();
                }
            }
        }
       }
       return result;
    }
}