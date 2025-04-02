public class StockDeductionsTriggerHandler
{
    SKUHelper skuHelper = new  SKUHelper();
    public nm_Centers__c transitCenterId = [SELECT id                                           
                                            FROM nm_Centers__c
                                            WHERE name  =  'Transit Center'];
    Stock__c toCenterStock = new  Stock__c();
    Stock__c transitStock = new  Stock__c();
    boolean checkIfStockExistsAtTransitCenter;
    boolean checkIfStockExistsAtFromCenter;
    public list<Account> lstAccount;
    public list<Dispatch_Order__c> lstDispatchUpdate;
    public map<string, boolean> MapforIfRecordIsInfoCenter;
    public map<string, boolean> MapcheckStockExistsAtTransitCenter;
    public map<string, boolean> MapcheckIfStockExistsAtFromCenter;
    public map<string, Stock__c> MapcreateFreshStock;
    public map<string, Stock__c> MapforgetStockByID{get;set;}   
    public map<string, boolean> MapcheckIfStockExistsAtToCenter;
    public map<string, boolean> MapCheckIfStockExitAtFromCenter;
    public map<string, Stock__c> MapStockExistsAtTransitCenter;
    public map<id, string> MapforGetBatch;
    public map<string, boolean> mapCheckAlreadyDispatchOrderCreated;
    
    private transient ApexPages.Message currentMsg{get;set;}   
    
    public void BeforeInsert(list<Dispatch_Order__c> triggerNew)
    {
        InsertDispatch(triggerNew);
    }
    public void AfterUpdate(list<Dispatch_Order__c> triggerNew, map<id, Dispatch_Order__c> triggerOldMap)
    {
        UpdateStockValuesOnStatus(triggerNew, triggerOldMap);
        SendSMSOnFedExShipmentCreation(triggerNew, triggerOldMap);
        updateCourierServiceChargeOnOtherCourierService2(triggerNew, triggerOldMap);
       // updatePreviousDriveReturnBack();
    }
    public void InsertDispatch(list<Dispatch_Order__c> triggerNew)
    {
        Stock__c fromCenterStock;
        System.debug('list Dispatch size-->' + triggerNew.size());
        Stock__c transitStock;
        
        boolean mapcheckIfFromCenterIsIC = false;
        boolean checkIfStockExistsAtTransitCenter = false;
        boolean checkIfStockExistsAtFromCenter = false;
        boolean checkIfStockExistsAtToCenter = false;
        
        MapforIfRecordIsInfoCenter = skuHelper.GetMapforIfRecordIsInfoCenter();
        MapcheckStockExistsAtTransitCenter = skuHelper.getMapcheckStockExistsAtTransitCenter();
        MapforgetStockByID = skuHelper.MapgetStockByID();
        MapforGetBatch = skuHelper.MapforBatchName();
        map<string, Stock__c> MapofgetStockByID = new  map<string, Stock__c>();
        Map<string, string> mapOfToCenterAndSKUID = new  Map<string, string>();
        Map<string, string> mapOfFormCenterAndsSKUD = new  Map<string, string>();
        Integer DispatchCount = 0;
        for(Dispatch_Order__c dispatchOnInsert: triggerNew)
        {
            mapOfToCenterAndSKUID.put(dispatchOnInsert.To_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c, '');
            mapOfFormCenterAndsSKUD.put(dispatchOnInsert.From_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c, '');
            DispatchCount = triggerNew.size();
        }
        MapCheckIfStockExitAtFromCenter = skuHelper.getMapcheckIfStockExistsAtFromCenter(mapOfFormCenterAndsSKUD, DispatchCount);
        system.debug('MapCheckIfStockExitAtFromCenter' + MapCheckIfStockExitAtFromCenter);
        for(Dispatch_Order__c dispatchOnInsert: triggerNew)
        {
            System.debug('list Dispatch size-->' + triggerNew.size());
            if(dispatchOnInsert.From_Centers__c != null)
            {
                mapcheckIfFromCenterIsIC = MapforIfRecordIsInfoCenter.get(dispatchOnInsert.From_Centers__c);
            }
            if(dispatchOnInsert.To_Centers__c != null)
            {
                MapcheckIfStockExistsAtToCenter = skuHelper.checkIfStockExistsAtToCenter(mapOfToCenterAndSKUID,dispatchOnInsert.To_Centers__c);
                system.debug('MapcheckIfStockExistsAtToCenter' + MapcheckIfStockExistsAtToCenter);
            }
            checkIfStockExistsAtTransitCenter = MapcheckStockExistsAtTransitCenter.get(dispatchOnInsert.Stock_Keeping_Unit__c);
            checkIfStockExistsAtFromCenter = MapCheckIfStockExitAtFromCenter.get(dispatchOnInsert.From_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
            System.debug('<--------checkIfStockExistsAtTransitCenter---------->' + checkIfStockExistsAtTransitCenter + '<----checkIfStockExistsAtFromCenter----->' + checkIfStockExistsAtFromCenter);
            system.debug('mapcheckIfFromCenterIsIC ' + mapcheckIfFromCenterIsIC);
            if(mapcheckIfFromCenterIsIC == false && dispatchOnInsert.Order_Type__c == 'Student Order')
            {
                dispatchOnInsert.addError('Order cannot be made from an Information Center');
                return;
            }
            if(checkIfStockExistsAtFromCenter == false && dispatchOnInsert.Order_Type__c == 'Student Order')
            {
                try
                {
                    System.debug('Enter false block');
                    dispatchOnInsert.addError('Stock does not Exist at the "From Center" value. Please check   ' + dispatchOnInsert.Program__c + '-' + dispatchOnInsert.Semester__c + 'Semester' + dispatchOnInsert.From_Centers__c);
                    //return;
                }
                catch(Exception e)
                {
                    dispatchOnInsert.addError(e.getMessage());
                }
            }
            if(checkIfStockExistsAtTransitCenter == false)
            {
                transitStock = skuHelper.createFreshStock(transitCenterId.id, dispatchOnInsert.Stock_Keeping_Unit__c);
                system.debug('transitStock--->' + transitStock);
                if(transitStock != null)
                {
                    Insert transitStock;
                }
            }
            if(dispatchOnInsert.From_Centers__c != null || dispatchOnInsert.To_Centers__c != null)
            {
                if(dispatchOnInsert.Status_Of_Dispatch__c == 'Study Kit assigned' && dispatchOnInsert.To_Centers__c == null)
                {
                    System.debug('Entered block for "Send it to my shipping Address"--->');
                    
                    fromCenterStock = MapforgetStockByID.get(dispatchOnInsert.From_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    
                    system.debug('fromCenterStock ' + MapforgetStockByID.get(dispatchOnInsert.From_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c));
                    system.debug('OpportunityId' + dispatchOnInsert.Opportunity__c);
                    System.debug('dispatchOnInsert.From_Centers__c' + dispatchOnInsert.From_Centers__c);
                    System.debug('dispatchOnInsert.Stock_Keeping_Unit__c' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    
                    transitStock = MapforgetStockByID.get(transitCenterId.id + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    
                    system.debug('transitStock' + MapforgetStockByID.get(transitCenterId.id + '-' + dispatchOnInsert.Stock_Keeping_Unit__c));
                    SYSTEM.DEBUG('transist Center id' + transitCenterId.id);
                    SYSTEM.DEBUG('Sku' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    
                    if(fromCenterStock != null)
                    {
                       /* string Batch = MapforGetBatch.get(fromCenterStock.id);
                        dispatchOnInsert.BatchNo__c = Batch;
                        lstDispatchUpdate.add(dispatchOnInsert);
                        System.debug('Batch'+Batch);*/
                        System.debug('lstDispatchUpdate' + lstDispatchUpdate);
                        System.debug('id' + dispatchOnInsert.id);
                       // System.debug('<---------transitStock---->' + transitStock.id);
                        System.debug('<-----------fromCenterStock--------------->' + fromCenterStock);
                        System.debug('<-----------dispatchOnInsert.Quantity__c--------------->' + dispatchOnInsert.Quantity__c);
                        System.debug('<-----------dispatchOnInsert.Stock_Keeping_Unit__c--------------->' + dispatchOnInsert.Stock_Keeping_Unit__c);
                        
                        skuHelper.transitstage(fromCenterStock, transitStock, dispatchOnInsert.Quantity__c, dispatchOnInsert.Stock_Keeping_Unit__c);
                    }
                }
                else if(dispatchOnInsert.Status_Of_Dispatch__c == 'Study Kit assigned' && dispatchOnInsert.To_Centers__c != null)
                {
                    System.debug('Entered block for "send to my information type"--->');
                    // check Stock AT to Center if Does not exist then create new Stock
                    checkIfStockExistsAtToCenter = MapcheckIfStockExistsAtToCenter.get(dispatchOnInsert.To_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    system.debug('checkIfStockExistsAtToCenter' + checkIfStockExistsAtToCenter);
                    system.debug('checkIfStockExistsAtToCenter with Center' + dispatchOnInsert.To_Centers__c);
                    system.debug('checkIfStockExistsAtToCenter with sku' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    transitStock = MapforgetStockByID.get(transitCenterId.id + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
                    fromCenterStock = MapforgetStockByID.get(dispatchOnInsert.From_Centers__c + '-' + dispatchOnInsert.Stock_Keeping_Unit__c);
                   /* string Batch = MapforGetBatch.get(fromCenterStock.id);
                    dispatchOnInsert.BatchNo__c = Batch;
                    lstDispatchUpdate.add(dispatchOnInsert);
                   System.debug('Batch'+Batch);*/
                   
                    System.debug('Transit Value---->' + transitStock + 'From Center Value------>' + fromCenterStock);
                         if(checkIfStockExistsAtToCenter == false)
                            {
                            
                                System.debug('<-------FromCenterValuePresent--------->');
                                // to avoid creating multiple SKU Kit of Same Type 
                                MapcheckIfStockExistsAtToCenter.put(dispatchOnInsert.To_Centers__c +'-'+dispatchOnInsert.Stock_Keeping_Unit__c,true);
                                toCenterStock = skuHelper.createFreshStock(dispatchOnInsert.To_Centers__c,dispatchOnInsert.Stock_Keeping_Unit__c);
                                insert toCenterStock;
                                System.debug('<-----------toCenterStock--------->'+toCenterStock+'<---------------fromCenterStock----->'+fromCenterStock);
                                skuHelper.transitstage(fromCenterStock,transitStock,dispatchOnInsert.Quantity__c,dispatchOnInsert.Stock_Keeping_Unit__c);
                            }
                            else
                            {
                                skuHelper.transitstage(fromCenterStock,transitStock,dispatchOnInsert.Quantity__c,dispatchOnInsert.Stock_Keeping_Unit__c);    
                            }                 
                    
                    
                }
            }
        }
    }
    //This Method Updates Opportunity with the Corresponding Dispatch OrderNumber.Done For Report Purpose//
       public void SendSMSOnFedExShipmentCreation(list<Dispatch_Order__c> triggerNew, map<id, Dispatch_Order__c> triggerOldMap)
    {
        string msg = '';
        string Name = '';
        list<Dispatch_Order__c> lstUpdateDispatch = new  list<Dispatch_Order__c>();
        for(Dispatch_Order__c dOrder: triggerNew)
        {
            Dispatch_Order__c oldDispatchRecord = triggerOldMap.get(dOrder.id);
              
                if(oldDispatchRecord.Fed_Ex_Shipment_Created__c == false && dOrder.Fed_Ex_Shipment_Created__c == true)
                {
                    Dispatch_Order__c objDispatch = new  Dispatch_Order__c(id = dOrder.id);
                    objDispatch.Status_Of_Dispatch__c = 'AWB created';
                    lstUpdateDispatch.add(objDispatch);
                    sendSMS(dOrder.MobilePhone__c, msg, dOrder.StudentName__c);
                }
         
        }
        if(lstUpdateDispatch.size() > 0)
        {
            Update lstUpdateDispatch;
        }
    }
    @future (callout = true )
    public static void sendSMS(string mobile, string message, string StudentName)
    {
        SMSSenderWebService.sendSMSAfterDispatchOrderCreated(mobile, message, StudentName);
    }
    //<-----------------------------------------Before Update Ends here-------------------------------------------->//
    //This is to update the stock values on Status Change//
    public void UpdateStockValuesOnStatus(list<Dispatch_Order__c> triggerNew, map<id, Dispatch_Order__c> triggerOldMap)
    {
        string oldStatusOfDispatch = '';
        Stock__c fromStockFinal;
        Stock__c toStockFinal;
        Stock__c transitStockFinal;
        boolean checkIfStockExistsAtToCenter = false;
        Map<string, string> mapOfToCenterAndSKUID = new  Map<string, string>();
        map<string, string> mapOfFormCenterAndsSKUD = new  map<string, string>();
        MapforgetStockByID = skuHelper.MapgetStockByID();
        integer DispatchCount = 0;
        //MapcheckIfStockExistsAtFromCenter = skuHelper.getMapcheckIfStockExistsAtFromCenter();
        for(Dispatch_Order__c dOrder: triggerNew)
        {
            Dispatch_Order__c oldDispatchValue = triggerOldMap.get(dOrder.id);
            system.debug('oldDispatchValue ' + oldDispatchValue);
            oldStatusOfDispatch = oldDispatchValue.Status_Of_Dispatch__c;
            system.debug('oldStatusOfDispatch' + oldStatusOfDispatch);
            mapOfToCenterAndSKUID.put(dOrder.To_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c, '');
            if(dOrder.To_Centers__c!=null)
            {
                MapcheckIfStockExistsAtToCenter = skuHelper.checkIfStockExistsAtToCenter(mapOfToCenterAndSKUID,dOrder.To_Centers__c);
            }
            
            
            mapOfFormCenterAndsSKUD.put(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c, '');
            MapCheckIfStockExitAtFromCenter = skuHelper.getMapcheckIfStockExistsAtFromCenter(mapOfFormCenterAndsSKUD, triggerNew.size());
            transitStockFinal = MapforgetStockByID.get(transitCenterId.id + '-' + dOrder.Stock_Keeping_Unit__c);
            system.debug('transitStockFinal ' + transitStockFinal);
            system.debug('transitCenterId.id' + transitCenterId.id);
            system.debug('dOrder.Stock_Keeping_Unit__c' + dOrder.Stock_Keeping_Unit__c);
            System.debug('Values for Compare--->' + oldStatusOfDispatch + '<---dOrder.Status_Of_Dispatch__c---->' + dOrder.Status_Of_Dispatch__c + '<----dOrder.To_Centers__c---->' + dOrder.To_Centers__c);
            if(oldStatusOfDispatch == 'Study Kit assigned' && dOrder.Status_Of_Dispatch__c == 'AWB created' && dOrder.Self_Learning_Material_For_Student__c == 'Send to my Information Centre. I will pick up.')
            {
                checkIfStockExistsAtToCenter = MapcheckIfStockExistsAtToCenter.get(dOrder.To_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                system.debug('checkIfStockExistsAtToCenter ' + checkIfStockExistsAtToCenter);
                system.debug('dOrder.To_Centers__c' + dOrder.To_Centers__c);
                system.debug('dOrder.Stock_Keeping_Unit__c' + dOrder.Stock_Keeping_Unit__c);
                if(!checkIfStockExistsAtToCenter)
                {
                    system.debug('Insert Record');
                    toCenterStock = skuHelper.createFreshStock(dOrder.To_Centers__c, dOrder.Stock_Keeping_Unit__c);
                    Insert toCenterStock;
                }
            }
            else if(oldStatusOfDispatch == 'Transit' && dOrder.Status_Of_Dispatch__c == 'Delivered' && dOrder.Self_Learning_Material_For_Student__c == 'Send to my shipping address' && dOrder.Order_Type__c == 'Student Order')
            {
                System.debug('<----------To Center is Null---->');
                fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                skuHelper.deliverystagewithouttocentre(fromStockFinal, transitStockFinal, dOrder.Quantity__c);
            }
            else if(oldStatusOfDispatch == 'Transit' && dOrder.Status_Of_Dispatch__c == 'Delivered' && dOrder.Self_Learning_Material_For_Student__c == 'Send to my Information Centre. I will pick up.' && dOrder.Order_Type__c == 'Student Order')
            {
                System.debug('<-------------both Centers are not null---->');
                fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                toStockFinal = MapforgetStockByID.get(dOrder.To_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                System.debug('TransitStockVal---->' + transitStockFinal);
                system.debug('fromStockFinal' + fromStockFinal);
                system.debug('toStockFinal ' + toStockFinal);
                system.debug('dOrder.To_Centers__c' + dOrder.To_Centers__c);
                system.debug('dOrder.Stock_Keeping_Unit__c' + dOrder.Stock_Keeping_Unit__c);
                skuHelper.deliverystage(fromStockFinal, toStockFinal, transitStockFinal, dOrder.Quantity__c);
            }
            else if(oldStatusOfDispatch == 'Transit' && dOrder.Status_Of_Dispatch__c == 'Delivered' && dOrder.Self_Learning_Material_For_Student__c == 'Send to my Corporate' && dOrder.Order_Type__c == 'Student Order')
            {
                System.debug('<-------------both Centers are not null---->');
                fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                toStockFinal = MapforgetStockByID.get(dOrder.To_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                System.debug('TransitStockVal---->' + transitStockFinal);
                skuHelper.deliverystage(fromStockFinal, toStockFinal, transitStockFinal, dOrder.Quantity__c);
            }
             else if(dOrder.Status_Of_Dispatch__c == 'Delivered' && dOrder.Self_Learning_Material_For_Student__c == 'Send to my Information Centre. I will pick up.' && dOrder.Order_Type__c == 'Student Order' && dOrder.Student_Picked_up_Material__c =='Yes' )
            {
                System.debug('<-------------both Centers are not null---->');
                fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                toStockFinal = MapforgetStockByID.get(dOrder.To_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                transitStock = MapforgetStockByID.get(transitCenterId.id + '-' + dOrder.Stock_Keeping_Unit__c);
                System.debug('TransitStockVal---->' + transitStockFinal);
                system.debug('fromStockFinal' + fromStockFinal);
                system.debug('toStockFinal ' + toStockFinal);
                system.debug('dOrder.To_Centers__c' + dOrder.To_Centers__c);
                system.debug('dOrder.Stock_Keeping_Unit__c' + dOrder.Stock_Keeping_Unit__c);
              //  skuHelper.deliverystage(fromStockFinal, toStockFinal, transitStockFinal, dOrder.Quantity__c);
                 skuHelper.transitstage(toStockFinal,transitStockFinal,dOrder.Quantity__c,dOrder.Stock_Keeping_Unit__c);
            }
            else if((oldStatusOfDispatch == 'Transit' || oldStatusOfDispatch == 'AWB created' || oldStatusOfDispatch == 'Study Kit assigned') && dOrder.Status_Of_Dispatch__c == 'Returned Back' && dOrder.Order_Type__c == 'Student Order')
            {
                fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c + '-' + dOrder.Stock_Keeping_Unit__c);
                system.debug('fromStockFinal ' + fromStockFinal);
                skuHelper.ifStageIsCancelled(fromStockFinal, transitStockFinal, dOrder.Quantity__c);
            }
            else if(oldStatusOfDispatch  == 'Returned Back' && dOrder.Status_Of_Dispatch__c == 'Transit' && dOrder.Order_Type__c=='Student Order')
             {
                 fromStockFinal = MapforgetStockByID.get(dOrder.From_Centers__c+'-'+dOrder.Stock_Keeping_Unit__c);                                         
                 transitStockFinal= MapforgetStockByID.get(transitCenterId.id+'-'+dOrder.Stock_Keeping_Unit__c);
                  system.debug('fromStockFinal Transit to Returned Back'+fromStockFinal );
                   system.debug('transitStockFinal  Transit to Returned Back'+transitStockFinal);                                        
                 skuHelper.transitstage(fromStockFinal,transitStockFinal,dOrder.Quantity__c,dOrder.Stock_Keeping_Unit__c);
                 
             }
        }
    }

    /* public void updatePreviousDriveReturnBack()
    {
        system.debug('updatePreviousDriveReturnBack called');
        String PreviousDriveNameValue = System.Label.Previous_Drive_Name;
        set<String> skuId=new set<String>();
        set<String> dispatchId=new set<String>();
        set<String> doId=new set<String>();
        List<Stock_Keeping_Units__c> updateSkuList=new List<Stock_Keeping_Units__c>();
        List<Stock_Keeping_Units__c> updateSkuListNew=new List<Stock_Keeping_Units__c>();
        map<String,integer> SkuReturnCountMap=new map<String,integer>();
        integer count;
        // List<Dispatch_Order__c> dList=[select id, Name,Status_Of_Dispatch__c,Opportunity__r.Final_Status_Of_Dispatch__c,Stock_Keeping_Unit__c from Dispatch_Order__c where Opportunity__r.Final_Status_Of_Dispatch__c='Returned Back' and Opportunity__r.Name like '%July_2023%'];
        List<Opportunity> oppList=[select id,Name,Dispatch_Order_Number_For_Student__c,Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c from Opportunity where Dispatch_Order_Number_For_Student__r.Status_Of_Dispatch__c='Returned Back' and Name like :'%'+PreviousDriveNameValue+'%'];
        system.debug('oppList '+oppList);
        for(Opportunity ob:oppList)
        {
            dispatchId.add(ob.Dispatch_Order_Number_For_Student__c);
            skuId.add(ob.Dispatch_Order_Number_For_Student__r.Stock_Keeping_Unit__c) ;  
        }
        List<Dispatch_Order__c> dList=[select id, Name,Status_Of_Dispatch__c,Opportunity__r.Final_Status_Of_Dispatch__c,Stock_Keeping_Unit__c from Dispatch_Order__c where id in:dispatchId];
        system.debug('dList '+dList);
        for(String str:skuId)
        {count=0;
         for(Dispatch_Order__c ob:dList)
         {
             
             if(ob.Stock_Keeping_Unit__c==str)
             {
                 count++; 
                 SkuReturnCountMap.put(ob.Stock_Keeping_Unit__c,count);
             }
         }
        }
        system.debug('SkuReturnCountMap size==>'+SkuReturnCountMap.size());
       /* for(String key: SkuReturnCountMap.keySet()){
            System.debug('key: ' + key + '  Value: ' + SkuReturnCountMap.get(key));
        }
        List<Stock_Keeping_Units__c> skuList=[select id from Stock_Keeping_Units__c where id in:skuId];
        
        for(Stock_Keeping_Units__c sku:skuList)
        {
            Stock_Keeping_Units__c ob=new Stock_Keeping_Units__c();
            ob.Id=sku.Id;
            ob.Previous_Drive_Returned_Stock__c=SkuReturnCountMap.get(sku.Id);
            updateSkuList.add(ob);
            doId.add(ob.Id);
        }
        if(updateSkuList.size()>0)
        {
            update updateSkuList;
        }
         List<Stock_Keeping_Units__c> skuListNew=[select id from Stock_Keeping_Units__c where id Not in:doId];
        for(Stock_Keeping_Units__c sku:skuListNew)
        {
            Stock_Keeping_Units__c ob=new Stock_Keeping_Units__c();
            ob.Id=sku.Id;
            ob.Previous_Drive_Returned_Stock__c=0;
            updateSkuListNew.add(ob);
        }
        if(updateSkuListNew.size()>0)
        {
            update updateSkuListNew;
        }
    }*/
    
    
      // Method to Change nmPaymentTransation Amount when courier service is not fedex
    public void updateCourierServiceChargeOnOtherCourierService2(list<Dispatch_Order__c> triggerNew,map<id,Dispatch_Order__c> oldMap) {
        Map<Id, Dispatch_Order__c> mapOppIdVsDispatch = new Map<Id, Dispatch_Order__c>();
        Decimal CourierCharge;     
        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;
        List<IC_Payment_Transaction__c> lstTransactionUoupdate = new List<IC_Payment_Transaction__c>();
        List<IC_Payment_Transaction__c> lstTransactionToDelete = new List<IC_Payment_Transaction__c>();
        
        for(Dispatch_Order__c dispatchOrder : triggerNew) {
            if (dispatchOrder.Other_Courier_Services_Dispatch__c == 'Yes' && dispatchOrder.Name_Of_Other_Courier_Service__c != 'Fedex' && dispatchOrder.Cost_Of_Shipement__c != oldMap.get(dispatchOrder.Id).Cost_Of_Shipement__c && dispatchOrder.Opportunity__c != null) {
                mapOppIdVsDispatch.put(dispatchOrder.Opportunity__c, dispatchOrder);
            }
        }
        CourierCharge = Integer.ValueOf(Label.Courier_charge); 
        if(mapOppIdVsDispatch.size() > 0) {
        
            List<Opportunity>  lstopps =[Select Id, Account.Name, AccountId ,IC__c ,            
                                    (Select id,IC_name__c,Amount__c,Opportunity__c,Share_Processed__c,Transaction_Type__c
                                  from IC_Payment_Transactions__r where Narration__c LIKE '%Book Courier Charges' )                                 
                                    From Opportunity Where Id = :mapOppIdVsDispatch.keySet() ];

            if(lstopps.size() > 0) {
                system.debug('lstopps --------> ' + lstopps);
                
                for (Opportunity objOpp : lstopps)
                {
                     String IcTransationToUpdateForSharedProcessFalse = '';                     
                    Decimal AmounFetchedFromGetAEPDispatchAmountForOtherService = getAEPDispatchAmountForOtherService2(objOpp.id);
                    Decimal AmountToBeUpdate = AmounFetchedFromGetAEPDispatchAmountForOtherService;
                    String ICName = objOpp.IC__c;
                    String Narration = 'Book Courier Charges';
                    nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();

                    if(today.day() <= 10 ){
                        CurrentMonth =today.Month();
                    }else{
                        CurrentMonth = today.Month() + 1;
                    }
                    if(CurrentMonth >=13)
                    {
                        CurrentMonth = CurrentMonth - 12;
                        CurrentYear = today.Year()+1;
                    }


                    if(objOpp.IC_Payment_Transactions__r.size() > 0) {
                        system.debug('objOpp.IC_Payment_Transactions__r ----> ' + objOpp.IC_Payment_Transactions__r);

                        
                        for(IC_Payment_Transaction__c icPayTran : objOpp.IC_Payment_Transactions__r ) {
                            if(icPayTran.Share_Processed__c) {
                                if(icPayTran.Transaction_Type__c == 'Adjustment - Debit'){
                                    AmountToBeUpdate = AmountToBeUpdate - icPayTran.Amount__c;
                                } else if(icPayTran.Transaction_Type__c == 'Admission Commision - Credit') {
                                    AmountToBeUpdate = AmountToBeUpdate + icPayTran.Amount__c;
                                }
                            } else {
                                IcTransationToUpdateForSharedProcessFalse = icPayTran.Id;
                            }
                        }
                        if (String.isNotBlank(IcTransationToUpdateForSharedProcessFalse)) {
                            IC_Payment_Transaction__c icPayTra = new IC_Payment_Transaction__c(id= IcTransationToUpdateForSharedProcessFalse );
                            //icPayTra.Id = IcTransationToUpdateForSharedProcessFalse;
                            if(AmountToBeUpdate > 0) {
                                icPayTra.Transaction_Type__c = 'Adjustment - Debit';
                            } else if(AmountToBeUpdate< 0) {
                                icPayTra.Transaction_Type__c = 'Admission Commision - Credit';
                            }
                            icPayTra.Amount__c = AmountToBeUpdate.abs();
                            if(icPayTra.Amount__c == 0) {
                                lstTransactionToDelete.add(icPayTra);
                            } else {
                                lstTransactionUoupdate.add(icPayTra);
                            }
                        } else { 
                            
                            if (AmountToBeUpdate>=1 && AmounFetchedFromGetAEPDispatchAmountForOtherService >= 1)
                            {                            
                                handler.createICTransactionDebitEntry(objOpp, CurrentYear, CurrentMonth,AmountToBeUpdate,ICName,Narration);
                            } else if(AmountToBeUpdate<=0 && AmounFetchedFromGetAEPDispatchAmountForOtherService >= 1) {
                                handler.createICTransactionCreditEntry(objOpp, CurrentYear, CurrentMonth,AmountToBeUpdate.abs(),ICName,Narration);
                            }
                        }
                    } else {
                        if(AmountToBeUpdate>=1 && AmounFetchedFromGetAEPDispatchAmountForOtherService >= 1) {
                            handler.createICTransactionDebitEntry(objOpp, CurrentYear, CurrentMonth,AmountToBeUpdate,ICName,Narration);
                        }
                    }
                }                                          
            }
            if(lstTransactionUoupdate.size()>0)
            {
                update lstTransactionUoupdate;
            }
            if(lstTransactionToDelete.size()>0)
            {
                Delete lstTransactionToDelete;
            }
        }
    }

    public Decimal getAEPDispatchAmountForOtherService2(String oppId) {
        Decimal totalAmount = 0.0;      
        totalAmount = (Decimal)[select sum(Cost_Of_Shipement__c)shipmentcost from Dispatch_Order__c WHERE Opportunity__c = :oppId AND Cost_Of_Shipement__c> 0 ][0].get('shipmentcost');

        return totalAmount > 0 ? totalAmount / 2 : totalAmount;
    }

}