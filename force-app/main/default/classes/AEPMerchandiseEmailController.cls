public  class AEPMerchandiseEmailController {
    public Id objPaymentId;
    public Decimal TotalPriceOfCart {get;set;}
    // public List<Map<String, String>> mapProductAndPrice {get;set;}
    public List<List<String>> mapProductAndPrice {get;set;}
    public String JsonMapProductAndPrice {get;set;}
    public String siteUrl {get;set;}
    public String paymentRecord {get;set;}
    public String PaymentReceipt {get;set;}
    public nm_Centers__c objCenter {get;set;}
    public Boolean isAlreadyCalled = false;
    public AEPMerchandiseEmailController() {
        //  this.mapProductAndPrice = new List<Map<String, String>>();
         this.mapProductAndPrice = new List<List<String>>();
         this.TotalPriceOfCart = 0;
    }
    public ID getObjPaymentId() {
		return this.objPaymentId;
	}
    public void setObjPaymentId(Id objPaymentId) {
        system.debug('setObjPaymentId --> ' );
        this.objPaymentId = objPaymentId;
        getRecordOfPayment(this.objPaymentId);
        this.TotalPriceOfCart = this.TotalPriceOfCart.setScale(2);
	}
    
    public void getRecordOfPayment(Id payId) {
        if(String.isNotBlank(payId) && !isAlreadyCalled) {
            isAlreadyCalled = true;
            List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); 
            Map<String, Decimal> mapOfAEPMerchandiseAndPrice = new Map<String, Decimal>();
            Decimal totalPrice = 0;
            String PriceBookEntry = 'select id, UnitPrice,Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c,product2.Id,Product2Id, product2.Family, product2.Name, product2.nm_Program__c, product2.nm_Semester__c'+
                    +' from PriceBookEntry where product2.isActive = true '+
                    +'and pricebook2.isStandard = false and Pricebook2.nmSession_Start_Date__c !=null '+
                    +'and Pricebook2.nmSession_End_Date__c !=null ' +
                    +'and product2.Family = \'AEP Merchandise\' ' +
                    +'and Pricebook2.IsActive=true ';
            System.debug('Query = '+PriceBookEntry);
            lstPriceBookEntry = DataBase.query(PriceBookEntry);
            System.debug('lstPriceBookEntry ---> ' + lstPriceBookEntry);
            if(lstPriceBookEntry.size() > 0) {
                for(PriceBookEntry objPriceBook :lstPriceBookEntry) {
                    system.debug('objPriceBook --> ' + objPriceBook);
                    system.debug('objPriceBook.Product2Id --> ' + objPriceBook.Product2Id);
                    system.debug('objPriceBook.UnitPrice --> ' + objPriceBook.UnitPrice);
                    Decimal unitPriceWithGst5per = objPriceBook.UnitPrice + (objPriceBook.UnitPrice * 0.05);
                    mapOfAEPMerchandiseAndPrice.put(objPriceBook.Product2Id, unitPriceWithGst5per );
                }
            }
            nm_Payment__c objPayment = [SELECT Id,AEP__c, Merchendise__c FROM nm_Payment__c WHERE Id =:payId LIMIT 1];
             if(objPayment != null) {
                    List<String> lstOrder = String.isNotBlank(objPayment.Merchendise__c) ? objPayment.Merchendise__c.split('\n') : new List<String>();            
                    String orderString = lstOrder.size() > 0 ? lstOrder[lstOrder.size() -1] : '';
                    if(String.isNotBlank(orderString)) {
                        List<Object> lstJsonObject = (List<Object>) JSON.deserializeUntyped(orderString);
                        system.debug('lstJsonObject.size --> ' + lstJsonObject.size());
                        for (Object obj : lstJsonObject) {
                            Map<String, Object> mapOfObject = (Map<String,Object>) obj;
                            Map<String, String> mapOfProduct = new Map<String, String>();
                            if(mapOfObject.containsKey('ProductId')) {
    
                                mapOfProduct.put('Name', String.ValueOf(mapOfObject.get('ProductName')));
                                String Size = mapOfObject.containsKey('selectedSize') && String.isNotBlank((String) mapOfObject.get('selectedSize'))  ? String.valueOf(mapOfObject.get('selectedSize')) : '-';
                        
                                mapOfProduct.put('Size', Size);
                                mapOfProduct.put('Number', String.valueOf(mapOfObject.get('NumberOfProduct')));
                                Decimal priceOfProduct = (Decimal) Decimal.valueOf((Integer) mapOfObject.get('NumberOfProduct')) * mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId'));
                                mapOfProduct.put('Price', String.valueOF(priceOfProduct.setScale(2)) );
    
    
                                system.debug((Decimal) Decimal.valueOf(String.valueOf(mapOfObject.get('NumberOfProduct')) ) );
                                system.debug( mapOfObject.get('ProductId') );
                                system.debug( mapOfAEPMerchandiseAndPrice.get((String) mapOfObject.get('ProductId')) );
                                List<String> cartInList = new List<String>();
                                cartInList.add(mapOfProduct.get('Name'));
                                cartInList.add(mapOfProduct.get('Size'));
                                cartInList.add(mapOfProduct.get('Number'));
                                cartInList.add(mapOfProduct.get('Price'));
                                system.debug('this.TotalPriceOfCart --> ' +  this.TotalPriceOfCart);
                                
                                this.TotalPriceOfCart = this.TotalPriceOfCart + priceOfProduct;
                                // this.mapProductAndPrice.add(mapOfProduct);
                                this.mapProductAndPrice.add(cartInList);
                            }
                        }
                    }
                    nm_Centers__c nmObjCenter = [SELECT id, Name, Address__c FROM nm_Centers__c WHERE id=:objPayment.AEP__c Limit 1];
                    if(nmObjCenter != null ) {
                        this.objCenter = nmObjCenter;
                        this.siteUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + nmObjCenter.Id;
                        this.paymentRecord = URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.objPaymentId;
                        this.PaymentReceipt = system.Label.Site_Url + 'nmRegistrationThankYou?id=' + this.objPaymentId;
                    }
            }
            this.JsonMapProductAndPrice = JSON.serialize(this.mapProductAndPrice);
    
    
            system.debug(' this.mapProductAndPrice --> ' +  this.mapProductAndPrice);
            system.debug(' this.TotalPriceOfCart --> ' +  this.TotalPriceOfCart);

        }


    
    }   
}