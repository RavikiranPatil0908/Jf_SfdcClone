/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-11-2024
 * @last modified by  : @BK
**/
public without sharing class AddStockQuantity {

    /**
    * @description 
    * @author @BK | 13-05-2024 
    * @param List<StockWrapperRequest> request 
    * @return List<StockWrapperResponse> 
    **/
    @InvocableMethod(label='Add Stock Quantity' description='To add stock quantity on stock records')
    public static List<StockWrapperResponse> addStockQuantity(List<StockWrapperRequest> request){
        System.debug('addStockQuantity ==>');
        List<Stock_Ledger__c> lstSTLToInsert = new List<Stock_Ledger__c>();
        // String recordId = request[0].orderLineItemId;
        StockWrapperRequest objRequest = request[0];
        StockWrapperResponse objWrapper = new StockWrapperResponse();
        objWrapper.isSuccess = false;
        List<StockWrapperResponse> lst = new List<StockWrapperResponse>();
        try {
            OrderDetails objDetails = getAttachmentData(objRequest);
            OrderLineItem__c orderLineItem = [SELECT Id,Recordtype.Name FROM OrderLineItem__c WHERE Id =: objRequest.orderLineItemId];
            Map<String, Decimal> mapOfBookQty = objDetails.orderBookQuantity;
            Map<String,Id> mapOfISBNVsBookStock = objDetails.mapOfISBNVsBookStock;
            
            if(!mapOfBookQty.isEmpty()) {
                List<Stock__c> lstSK = new List<Stock__c>();
                if(orderLineItem.Recordtype.Name == 'Book'){
                    lstSK = [SELECT id,Course_Master__r.ISBN__c,Quantity__c FROM Stock__c WHERE Course_Master__c!=null AND Stock_Keeping_Unit__c=null 
                    AND Course_Master__r.ISBN__c IN : mapOfBookQty.keySet() AND CenterName__c='Repro - Bhiwandi'];
                }else if(orderLineItem.Recordtype.Name == 'Kit'){
                    lstSK = [SELECT id,Stock_Keeping_Unit__r.Name,Quantity__c FROM Stock__c WHERE Course_Master__c=null AND Stock_Keeping_Unit__c!=null 
                    AND Stock_Keeping_Unit__r.Name IN : mapOfBookQty.keySet() AND CenterName__c='Repro - Bhiwandi'];
                }
                for (Stock__c obj : lstSK) {
                    String bookISBNKey =  (orderLineItem.Recordtype.Name == 'Book') ? obj.Course_Master__r.ISBN__c :
                     orderLineItem.Recordtype.Name == 'Kit' ? obj.Stock_Keeping_Unit__r.Name : null;
                    obj.Quantity__c = obj.Quantity__c!=null ? obj.Quantity__c + mapOfBookQty.get(bookISBNKey) : mapOfBookQty.get(bookISBNKey);
                    Stock_Ledger__c objSTL = new Stock_Ledger__c(
                                                Entry_Date__c=System.today(),
                                                Stock__c=obj.Id,
                                                Incoming_Quantity__c = mapOfBookQty.get(bookISBNKey),
                                                Quantity__c = obj.Quantity__c,
                                                Book_Stock__c = (orderLineItem.Recordtype.Name == 'Book') ? mapOfISBNVsBookStock.containsKey(bookISBNKey) ? mapOfISBNVsBookStock.get(bookISBNKey) : null :null,
                                                StockSkuJunction__c = (orderLineItem.Recordtype.Name == 'Kit') ? mapOfISBNVsBookStock.containsKey(bookISBNKey) ? mapOfISBNVsBookStock.get(bookISBNKey) : null :null,
                                                OrderLineItem__c = objRequest.orderLineItemId,
                                                Entity_Type__c = 'Order'
                                            );
                    
                    lstSTLToInsert.add(objSTL);
                }
                update lstSK;

                if(lstSTLToInsert.size() > 0) {
                    insert lstSTLToInsert;
                }

                objWrapper.isSuccess = true;
            }
        } catch (Exception error) {
            System.debug('error ==>'+error.getMessage());
            objWrapper.isSuccess = false;
        }

        lst.add(objWrapper);
        return lst;
    }

    /**
    * @description 
    * @author @BK | 13-05-2024 
    * @param String recordId 
    * @return Map<String, Decimal> 
    **/
    public static OrderDetails getAttachmentData(StockWrapperRequest objRequest) {
        OrderLineItem__c orderLineItem = [SELECT Id,Recordtype.Name FROM OrderLineItem__c WHERE Id =: objRequest.orderLineItemId];
        OrderDetails objDetails = new OrderDetails();

        // Map to store ISBN ID and Quantity value from CSV
        objDetails.orderBookQuantity = new Map<String, Decimal>();

        List<Attachment> lstattachmentRecord = [SELECT Id,Body,ContentType FROM Attachment WHERE ParentId=:objRequest.orderLineItemId AND Name='Order_Details.csv' LIMIT 1];
        if(lstattachmentRecord.size() < 1) {
            return objDetails;
        }

        String csvAsString;
        String[] csvFileLines;
        csvAsString = lstattachmentRecord[0].Body.toString();
        csvFileLines = csvAsString.split('\n'); 

        List<String> lstHeaders = csvFileLines[0].split(',');

        // to find the column postion
        Integer columnNoISBN = 0;
        Integer columnNoQty = 0;
        Integer count = 0;
        for(String headerVal : lstHeaders) {
            if(orderLineItem.Recordtype.Name == 'Book'){
                if(headerVal.containsIgnoreCase('ISBN')) {
                    columnNoISBN = count;
                }
            } else if(orderLineItem.Recordtype.Name == 'Kit'){
                if(headerVal.containsIgnoreCase('SKUName')) {
                    columnNoISBN = count;
                }
            }
            
            if(headerVal.containsIgnoreCase('Quantity')) {
                columnNoQty = count;
            }
            count++;
        }

        for(Integer i = 1; i < csvFileLines.size(); i++) {
            String[] csvRecordData = csvFileLines[i].split(',');
            Decimal qty = Decimal.valueOf(csvRecordData[columnNoQty].trim());
            String mapKey = csvRecordData[columnNoISBN].trim();
            objDetails.orderBookQuantity.put(mapKey, qty);
            System.debug(mapKey + ' ==> ' + qty);
        }

        List<Order_Book__c> lstOB = [SELECT id,Session__c,Type__c,Year__c,SJ_Unique_Key__c FROM Order_Book__c WHERE Id=:objRequest.orderBookId LIMIT 1];
        if(!lstOB.isEmpty()) {
            Order_Book__c objOB = lstOB[0];

            if(orderLineItem.Recordtype.Name == 'Book'){
                List<Book_Stock__c> lstBookStock = new List<Book_Stock__c>();
                if(objOB.Type__c == 'New') {
                    lstBookStock = [SELECT id,ISBN__c FROM Book_Stock__c WHERE Session__c=:objOB.Session__c AND Year__c=:objOB.Year__c AND SJ_Unique_Key__c=null AND ISBN__c IN: objDetails.orderBookQuantity.keySet()];
                } else {
                    lstBookStock = [SELECT id,ISBN__c FROM Book_Stock__c WHERE Session__c=:objOB.Session__c AND Year__c=:objOB.Year__c AND SJ_Unique_Key__c=:objOB.SJ_Unique_Key__c AND ISBN__c IN:objDetails.orderBookQuantity.keySet()];
                }

                for (Book_Stock__c obj : lstBookStock) {
                    objDetails.mapOfISBNVsBookStock.put(obj.ISBN__c,obj.Id);
                }
            } else if(orderLineItem.Recordtype.Name == 'Kit'){
                List<StockSkuJunction__c> lstBookStock = new List<StockSkuJunction__c>();
                if(objOB.Type__c == 'New') {
                    lstBookStock = [SELECT id,Stock_Keeping_Units__r.Name FROM StockSkuJunction__c WHERE Session__c=:objOB.Session__c AND Year__c=:objOB.Year__c AND SJ_Unique_Key__c=null AND Stock_Keeping_Units__r.Name IN: objDetails.orderBookQuantity.keySet()];
                } else {
                    lstBookStock = [SELECT id,Stock_Keeping_Units__r.Name FROM StockSkuJunction__c WHERE Session__c=:objOB.Session__c AND Year__c=:objOB.Year__c AND SJ_Unique_Key__c=:objOB.SJ_Unique_Key__c AND Stock_Keeping_Units__r.Name IN:objDetails.orderBookQuantity.keySet()];
                }

                for (StockSkuJunction__c obj : lstBookStock) {
                    objDetails.mapOfISBNVsBookStock.put(obj.Stock_Keeping_Units__r.Name,obj.Id);
                }
            }
            
        }

        return objDetails;
    }

    private class OrderDetails {

        private OrderDetails() {
            this.mapOfISBNVsBookStock = new Map<String,Id>();
            this.orderBookQuantity = new Map<String, Decimal>();
        }

        private Map<String,Id> mapOfISBNVsBookStock {get;set;}
        private Map<String, Decimal> orderBookQuantity {get;set;}
    }

    // Response
    public class StockWrapperResponse {
        @InvocableVariable(
            label = 'is Success'
            description = 'True/False returned from the response'
        )
        public Boolean isSuccess;
    } 
    
    // Request
    public class StockWrapperRequest {
		@InvocableVariable(
            label = 'OrderLineItem Id'
            description = 'OrderLineItem Record Id'
            required=true)
		public String orderLineItemId;
        @InvocableVariable(
            label = 'Order Book Id'
            description = 'Order Book Record Id'
            required=true)
        public String orderBookId;
	}
}