/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
public class BatchClassForPreOrderStock implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Program__c,Launch_Year__c,Semester__c,Program_Type__c,CM_Books__c FROM Stock_Keeping_Units__c WHERE Type_Of_SKU__c=\'Kit\' AND InActive__c=FALSE';
        System.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Stock_Keeping_Units__c> lstKits) { 
        String session = System.Label.Current_Session;
        String year = System.Label.Current_Year;

        List<StockSkuJunction__c> kitSKuList = new List<StockSkuJunction__c>();
        List<Book_Stock__c> bookList = new List<Book_Stock__c>();
        List<Book_SKU_Junction__c> skuJunction = new List<Book_SKU_Junction__c>();

        Set<String> prgName = new Set<String>();
        Set<String> skuId = new Set<String>();
        Map<Id,Stock_Keeping_Units__c> mapOfIdVsKit = new Map<Id,Stock_Keeping_Units__c>();
        Map<Id,Id> mapOfKitIdVsStkId = new Map<Id,Id>();
        Map<String,Set<Id>> mapOfBookVsKitsId = new Map<String,Set<Id>>();
        Map<Id,List<String>> mapOfKitsIdVsBooks = new Map<Id,List<String>>();
        Map<String,Stock__c> bookNameVsSTK = new Map<String,Stock__c>();
        Set<String> setOfUniqueKeys = new Set<String>();
        Map<String,Book_Stock__c> mapOfKeyBsBookSTK = new Map<String,Book_Stock__c>();
        Map<String,Id> mapOfBookNameVsBookSKUId = new Map<String,Id>();
        Map<Id,String> mapOfIdVsCourseName = new Map<Id,String>();

        for (Stock_Keeping_Units__c objKit : lstKits) {
            prgName.add(objKit.Program__c);
            skuId.add(objKit.Id);
            mapOfIdVsKit.put(objKit.Id,objKit);
        }

        // to remove already created kitsStock
        List<StockSkuJunction__c> lstKitSKU = [SELECT id,Unique_Stock_Sku__c,Stock_Keeping_Units__c,Session__c,Year__c FROM StockSkuJunction__c WHERE Stock_Keeping_Units__c IN :mapOfIdVsKit.keySet() AND Session__c=:session AND Year__c=:year AND Stock__c!=null];
        for (StockSkuJunction__c obj : lstKitSKU) {
            if(mapOfIdVsKit.containsKey(obj.Stock_Keeping_Units__c)) {
                mapOfIdVsKit.remove(obj.Stock_Keeping_Units__c);
            }
        }

        System.debug('Size of KitSKU already exists ==>'+mapOfIdVsKit.size());

        // To insert Books
        for (Stock_Keeping_Units__c objKit : lstKits) {
            List<String> lstBookSmallCase = objKit.CM_Books__c != null ? splitString(objKit.CM_Books__c) : new List<String>();
            mapOfKitsIdVsBooks.put(objKit.Id,lstBookSmallCase);
            if(lstBookSmallCase.size() > 0 ) {
                List<String> lstBooks = objKit.CM_Books__c.split(';');
                for (String bookName : lstBooks) {
                    Set<Id> setOfKitsId = mapOfBookVsKitsId.containsKey(bookName) ? mapOfBookVsKitsId.get(bookName) : new Set<Id>();
                    setOfKitsId.add(objKit.Id);
                    mapOfBookVsKitsId.put(bookName,setOfKitsId);
                    System.debug('Book Name==>'+bookName);
                }
            }
        }

        System.debug('mapOfBookVsKitsId Size ==>'+mapOfBookVsKitsId.size());

        System.debug('mapOfBookVsKitsId Size ==>'+mapOfBookVsKitsId.keySet());
        

        // To query Stock for both Kit and Books
        // Map<Id,Stock__c> mapOfIdVsSTK = new Map<Id,Stock__c>([SELECT id,Quantity__c,Stock_Keeping_Unit__c,Course_Master__c,Course_Master__r.Name,Centers__r.Name,
        //     Course_Master__r.Book_Code__c FROM Stock__c 
        //     WHERE IsActive__c=TRUE AND ((Stock_Keeping_Unit__c!=null AND Stock_Keeping_Unit__c IN :mapOfIdVsKit.keySet()) 
        //     OR (Course_Master__c!=null AND Course_Master__r.Name IN :mapOfBookVsKitsId.keySet()))]);


        Map<Id,Stock__c> mapOfIdVsSTK = new Map<Id,Stock__c>([SELECT id,Quantity__c,Stock_Keeping_Unit__c,Course_Master__c,Course_Master__r.Name,Centers__r.Name,
            Course_Master__r.Book_Code__c FROM Stock__c 
            WHERE Centers__r.Name='Repro - Bhiwandi' AND ((Stock_Keeping_Unit__c!=null AND Stock_Keeping_Unit__c IN :mapOfIdVsKit.keySet()) 
            OR (IsActive__c=true AND Course_Master__c!=null AND Course_Master__r.Name IN :mapOfBookVsKitsId.keySet()))]);

        for (Id mapKey : mapOfIdVsSTK.keySet()) {
            Stock__c obj = mapOfIdVsSTK.get(mapKey);
            if(obj.Stock_Keeping_Unit__c!=null && obj.Course_Master__c==null) { // for KitSKU
                mapOfKitIdVsStkId.put(obj.Stock_Keeping_Unit__c,mapKey);
            } else if(obj.Course_Master__c!=null) { // for BookSKU
                System.debug('Entered Course condititon');
                bookNameVsSTK.put(obj.Course_Master__r.Name, obj);
                String uniqueKey = String.valueOf(mapKey).subString(0,15)+'-'+String.valueOf(obj.Course_Master__c).subString(0,15)+'-'+session+'-'+year;
                setOfUniqueKeys.add(uniqueKey);
                mapOfIdVsCourseName.put(obj.Course_Master__c,obj.Course_Master__r.Name.toLowerCase());
            }

        }

        System.debug('bookNameVsSTK Size ==>'+bookNameVsSTK.size());
        System.debug('mapOfIdVsCourseName Size ==>'+mapOfIdVsCourseName.size());

        // to skip existing Book Stock.
        for (Book_Stock__c obj : [SELECT id,Unique_Book_Stock__c,Course_Master__r.Name FROM Book_Stock__c WHERE Unique_Book_Stock__c IN :setOfUniqueKeys]) {
             // to add existing Book Stock to map.
            mapOfBookNameVsBookSKUId.put(obj.Course_Master__r.Name,obj.Id);
             // to remove existing Book Stock.
            mapOfKeyBsBookSTK.put(obj.Unique_Book_Stock__c,obj);
        }

        System.debug('Book SKU already exists ==>');
        System.debug('mapOfKeyBsBookSTK ==>'+mapOfKeyBsBookSTK.size());

        // To insert KitSKU
        kitSKuList = setSKUJunctionToInsert(mapOfIdVsKit, mapOfKitIdVsStkId, mapOfIdVsSTK);
        if(kitSKuList.size() > 0) {
            insert kitSKuList;
        }


        // To insert Book SKU
        bookList = setBookSKUToInsert(bookNameVsSTK, mapOfKeyBsBookSTK);
        if(bookList.size() > 0) {
            insert bookList;
            for (Book_Stock__c obj : bookList) {
                String bookName = mapOfIdVsCourseName.get(obj.Course_Master__c);
                mapOfBookNameVsBookSKUId.put(bookName,obj.Id);
            }
        }

        // To Insert Book Junction
        skuJunction = setBookJunctionToInsert(kitSKuList, mapOfKitsIdVsBooks, mapOfBookNameVsBookSKUId);
        if(skuJunction.size() > 0) {
            insert skuJunction;
        }

    }

    /**
    * @description 
    * @author @BK | 14-02-2024 
    * @param Map<Id Stock_Keeping_Units__c> mapOfIdVsKit 
    * @param Map<Id Id> mapOfKitIdVsStkId 
    * @return List<StockSkuJunction__c> 
    **/
    public List<StockSkuJunction__c> setSKUJunctionToInsert(Map<Id,Stock_Keeping_Units__c> mapOfIdVsKit, Map<Id,Id> mapOfKitIdVsStkId, Map<Id,Stock__c> mapOfIdVsSTK) {
        String session = System.Label.Current_Session;
        String year = System.Label.Current_Year;
        Map<Id,Integer> mapOfSkuReturnVsCount = new Map<Id,Integer>();
        List<StockSkuJunction__c> kitSKuList = new List<StockSkuJunction__c>();
        // To calculate return Back
        if(mapOfIdVsKit.size() > 0) {
            mapOfSkuReturnVsCount = getReturnBackCount();
        }

        for(Stock_Keeping_Units__c objKit : mapOfIdVsKit.values()) { 
            if(mapOfKitIdVsStkId.containsKey(objKit.Id)) {
                String stkId = mapOfKitIdVsStkId.get(objKit.Id);
                System.debug('mapOfKitIdVsStkId.get(objKit.Id)==>'+stkId);
                StockSkuJunction__c sj = new StockSkuJunction__c();
                sj.Stock_Keeping_Units__c = objKit.Id;
                sj.Stock__c = stkId;
                sj.Type__c='New';
                sj.Study_Kit_Stock__c = mapOfIdVsSTK.get(stkId).Quantity__c;
                sj.Session__c = session; // Current Session
                sj.Year__c = year; // Current Year;
                sj.PrevDriveStockCount__c = mapOfSkuReturnVsCount.containsKey(objKit.Id) ? mapOfSkuReturnVsCount.get(objKit.Id) : 0;
                kitSKuList.add(sj);
            }
        }

        return kitSKuList;
    }

    /**
    * @description 
    * @author @BK | 14-02-2024 
    * @return Map<Id, Integer> 
    **/
    public Map<Id,Integer> getReturnBackCount() {
        Map<Id,Integer> mapOfSkuReturnVsCount = new Map<Id,Integer>();
        Set<Id> setOfDispatchId = new Set<Id>();
        Set<Id> skuIds = new set<Id>();
        String previousDriveName = System.Label.Previous_Session + '_' + System.Label.Previous_Year;
        System.debug('previousDriveName ==>'+previousDriveName);

        List<Opportunity> lstOpp = [SELECT id,Name,Dispatch_Order_Number_For_Student__c,Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c FROM Opportunity 
            WHERE Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c='Returned Back' AND Name LIKE :'%'+previousDriveName+'%'];
        
        for (Opportunity ob : lstOpp) {
            setOfDispatchId.add(ob.Dispatch_Order_Number_For_Student__c);
            skuIds.add(ob.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c);
        }

        List<Dispatch_Order__c> dList=[SELECT id,Name,Status_Of_Dispatch__c,Opportunity__r.Final_Status_Of_Dispatch__c,Stock_Keeping_Unit__c FROM Dispatch_Order__c WHERE id IN :setOfDispatchId];
        System.debug('dList '+dList);
        if(dList.size() > 0) {
            for(Id strId : skuIds) {
                for(Dispatch_Order__c ob : dList) {
                    Id skuId = ob.Stock_Keeping_Unit__c;
                    if(skuId == strId) {
                        Integer count = mapOfSkuReturnVsCount.containsKey(skuId) ? mapOfSkuReturnVsCount.get(skuId) : 0;
                        count++; 
                        mapOfSkuReturnVsCount.put(skuId,count);
                    }
                }
            }
        }
        return mapOfSkuReturnVsCount;
    }

    /**
    * @description 
    * @author @BK | 14-02-2024 
    * @param Map<String Stock__c> bookNameVsSTK 
    * @param Map<String Book_Stock__c> mapOfKeyBsBookSTK 
    * @return List<Book_Stock__c> 
    **/
    public List<Book_Stock__c> setBookSKUToInsert(Map<String,Stock__c> bookNameVsSTK, Map<String,Book_Stock__c> mapOfKeyBsBookSTK) {
        List<Book_Stock__c> bookList = new List<Book_Stock__c>();
        String session = System.Label.Current_Session;
        String year = System.Label.Current_Year;

        for (String bookName : bookNameVsSTK.keySet()) {
            Stock__c obj = bookNameVsSTK.get(bookName);
            String mapKey = String.valueOf(obj.Id).subString(0,15)+'-'+String.valueOf(obj.Course_Master__c).subString(0,15)+'-'+session+'-'+year;
            System.debug('mapKey ==>'+mapkey);
            if(!mapOfKeyBsBookSTK.containsKey(mapKey)) {
                Book_Stock__c bSTK = new Book_Stock__c();
                bSTK.Course_Master__c = obj.Course_Master__c;
                bSTK.Stock__c = obj.Id;
                bSTK.Book_Stock__c = obj.Quantity__c;
                bSTK.Type__c = 'New';
                // bSTK.Final_Requirment__c=CmVsFinalReq.get(cm.Name);
                bSTK.Session__c = session;
                bSTK.Year__c = year;
                System.debug('String.valueOf(Bk.Stock__c)==>'+String.valueOf(bSTK.Stock__c));
                System.debug('String.valueOf(Bk.Course_Master__c)==>'+String.valueOf(bSTK.Course_Master__c));
                System.debug('bSTK.Session__c==>'+bSTK.Session__c);
                System.debug('bSTK.Year__c==>'+bSTK.Year__c);
                bookList.add(bSTK);
            }
        }

        return bookList;
    }

    /**
    * @description 
    * @author @BK | 14-02-2024 
    * @param List<StockSkuJunction__c> kitSKuList 
    * @param Map<Id List<String>> mapOfKitsIdVsBooks 
    * @return List<Book_SKU_Junction__c> 
    **/
    public List<Book_SKU_Junction__c> setBookJunctionToInsert(List<StockSkuJunction__c> kitSKuList, Map<Id,List<String>> mapOfKitsIdVsBooks, Map<String,Id> mapOfBookNameVsBookSKUId) {
        List<Book_SKU_Junction__c> skuJunction = new List<Book_SKU_Junction__c>();
        System.debug('kitSKuList Size==>'+kitSKuList.size());
        System.debug('mapOfKitsIdVsBooks Size ==>'+mapOfKitsIdVsBooks.size());
        for (StockSkuJunction__c obj : kitSKuList) {
            System.debug('obj Id==>'+obj.Id);
            List<String> lstBooks = mapOfKitsIdVsBooks.get(obj.Stock_Keeping_Units__c);

            for (String bookName : lstBooks) {
                Id bookSTKID = mapOfBookNameVsBookSKUId.containsKey(bookName) ? mapOfBookNameVsBookSKUId.get(bookName) : null;
                System.debug('obj.Id_bookSTKID==>'+obj.Id+'_'+bookSTKID);
                System.debug('bookSTKID==>'+bookSTKID);
                System.debug('bookName==>'+bookName);
                if(bookSTKID!=null) {
                    Book_SKU_Junction__c objJunction = new Book_SKU_Junction__c(
                        StockSkuJunction__c = obj.Id,
                        Book_Stock_Junction__c = bookSTKID
                    );
                    skuJunction.add(objJunction);
                }
               
            }
        }

        return skuJunction;
    }

    /**
    * @description 
    * @author @BK | 27-04-2024 
    * @param String inputString 
    * @return List<String> 
    **/
    public static List<String> splitString(String inputString){
        List<String> splitStringList = new List<String>();
        String[] split = inputString.split(';');
        for(Integer i=0; i<split.size(); i++){
            split[i] = split[i].toLowerCase();
            splitStringList.add(split[i]);
        }
        return splitStringList;
    }

    public void finish(Database.BatchableContext bc){
        // Calculate Base Count
        System.debug('Calculate Base Count');

        BatchClassForStockRequirement b = new BatchClassForStockRequirement();
        Database.executeBatch(b);

        System.debug('Base Count Calculated');
    }
}