public class SKUHelper
{



    // method to get SKU based on launchYear,program and semester//
    public Stock_Keeping_Units__c getSkuByNameAndYear(String program,String semester,String launchYear) 
    {
          
          list<Stock_Keeping_Units__c> listStock = [select id,Program__c,Semester__c,Launch_Year__c from Stock_Keeping_Units__c];
          System.debug('Values from opportunity------->Program'+program+'Semester----->'+semester+'LaunchYear------->'+launchYear);
          for(Stock_Keeping_Units__c sku:listStock)
          {
                      System.debug('SKU values------->Launch Year'+sku.Launch_Year__c+'Semester--------->'+sku.Semester__c);
                 if( sku.Launch_Year__c  ==  launchYear &&  sku.Semester__c ==  semester)
                 {
                      String programList = sku.Program__c;
                      System.debug('<---------------programList------------>'+programList);
                      list<String> programs = programList .split(';');
                      System.debug('<-------------listOfProg---------->'+programs);
                      for(String p : programs)
                      {
                          if(p == program)
                          {
                              System.debug('Entered Last loop');
                              return sku;
                          }
                      }
                  }
              
              }
          
          return null;

    }
       
    // method to get stock based on Center and Stock Keeping Unit //
   public Stock__c getStockByID(id centerid,id skuid)
    {
        System.debug('Input Parameters for getStockById CENTERID--->'+centerid+'<-----SKUID----->'+skuid);
        Stock__c stock=[select Quantity__c,Outgoing_Quantity__c,Incoming_Quantity__c from Stock__c where Centers__c=:centerid and Stock_Keeping_Unit__c=:skuid];
        return stock;
        
    }
    
      public map<string,Stock__c> MapgetStockByID()
        {
          system.debug('Enter in loop MapgetStockByID');
           list<Stock__c> lstStockExist = new list<Stock__c>();
          lstStockExist = [select Quantity__c,Outgoing_Quantity__c,Incoming_Quantity__c,BatchNo__c,Centers__c,Stock_Keeping_Unit__c from Stock__c where Stock_Keeping_Unit__c !=null ORDER BY BatchNo__c  ASC ];
          system.debug('lstStockExist StockById '+lstStockExist.size());
          map<string,Stock__c> getStockByID=new map<string,Stock__c>();
          string Key='';
          
          for(Stock__c obj:lstStockExist )
          {
            
                 system.debug('Enter in Stock by Id');
                 Key=obj.Centers__c+'-'+obj.Stock_Keeping_Unit__c;
                 getStockByID.put(Key,obj);
                 system.debug('getStockByID in loop'+getStockByID.get(Key));
             
             
          }
          return getStockByID;
    
        }
    // method to check Stock is exist at ToCenter or Not //
      public Map<String,boolean> checkIfStockExistsAtToCenter(Map<String,String> mapOfToCenterAndSKU,String centerid)
         {
            Map<String,boolean> mapOfStockExistAtCenter = new Map<String,boolean>();
            Map<String,Stock__c> mapOfStockAtCenter = new Map<String,Stock__c>();
            List<Stock__c> lstStockExist =new list<Stock__c>();
            lstStockExist.clear();
            lstStockExist = [select Quantity__c,Outgoing_Quantity__c,Incoming_Quantity__c,BatchNo__c,Centers__c,Stock_Keeping_Unit__c from Stock__c where Quantity__c >=0 and Stock_Keeping_Unit__c!=null and   Centers__c =:centerid ORDER BY BatchNo__c ASC ];
            if(lstStockExist.size()>0)
            {
                for(Stock__c objStock : lstStockExist)
                {
                    mapOfStockAtCenter.put(objStock.Centers__c+'-'+objStock.Stock_Keeping_Unit__c,objStock);
                }
            }
            
            // for loop for checking Stock at To Center Exist or Not
            for(String key : mapOfToCenterAndSKU.keyset())
            {
                if(mapOfStockAtCenter.containsKey(key))
                {
                    mapOfStockExistAtCenter.put(key,true);
                }else{
                    mapOfStockExistAtCenter.put(key,false);
                }
            }
            
            return mapOfStockExistAtCenter;
         }
 
 
  
     // method to check Stock is exist at From Center or Not //
    public map<string,boolean> getMapcheckIfStockExistsAtFromCenter(map<string,string> mapOfFromCenterAndsSKUD,Integer DispatchCount)
     {
             list<Stock__c> lstStockExist = new list<Stock__c>();
            lstStockExist =[select Centers__c,Quantity__c ,Stock_Keeping_Unit__c ,IsLearningCenter__c from Stock__c where Quantity__c >0 and IsLearningCenter__c=true ORDER BY BatchNo__c  ASC];
            //  lstStockExist =[select Centers__c,Quantity__c ,Stock_Keeping_Unit__c ,IsLearningCenter__c from Stock__c where Quantity__c >0 ORDER BY BatchNo__c  ASC];
             map<string,boolean> MapcheckIfStockExistsAtFromCenter=new map<string,boolean>();
             map<string,Stock__c> mapofStockexitatFromCenter=new map<string,Stock__c>();
             if(lstStockExist.size()>0)
             {
               for(Stock__c  objStock:lstStockExist)
                 {
                   if(objStock.Quantity__c >= DispatchCount)
                   {
                        mapofStockexitatFromCenter.put(objStock.Centers__c+'-'+objStock.Stock_Keeping_Unit__c,objStock);
                        system.debug('mapofStockexitatFromCenter'+mapofStockexitatFromCenter);
                    }
                 }
             }
             for(string key: mapOfFromCenterAndsSKUD.keyset())
             {
               if(mapofStockexitatFromCenter.containsKey(key))
                {
                  MapcheckIfStockExistsAtFromCenter.put(key,true);
                  system.debug('MapcheckIfStockExistsAtFromCenter in true'+MapcheckIfStockExistsAtFromCenter);
                }
                else
                {
                  MapcheckIfStockExistsAtFromCenter.put(key,false);
                   system.debug('MapcheckIfStockExistsAtFromCenter in false'+MapcheckIfStockExistsAtFromCenter);
                }
             }
             
            return MapcheckIfStockExistsAtFromCenter;  
    }
    
      // method to check Stock is exist at Transit Center or Not // 
    public map<string,boolean> getMapcheckStockExistsAtTransitCenter()
        {
           map<string,boolean> MapcheckStockExistsAtTransitCenter=new map<string,boolean>();
           
            nm_Centers__c transitCenterId = [select id from nm_Centers__c where name ='Transit Center'];
            list<Stock__c> lststockExistsAtTransitCenter=[select Centers__c,Quantity__c,Stock_Keeping_Unit__c from Stock__c where Centers__c=:transitCenterId.id ];
           
            for(Stock__c obj:lststockExistsAtTransitCenter)
            {   
                 if(obj.Quantity__c==0)
                 {
                     system.debug('enter in transist True');
                    MapcheckStockExistsAtTransitCenter.put(obj.Stock_Keeping_Unit__c,true);
                 }
                 else
                 {
                   system.debug('enter in transist false');
                  MapcheckStockExistsAtTransitCenter.put(obj.Stock_Keeping_Unit__c,false);
                 }
                
            }
             return MapcheckStockExistsAtTransitCenter;
        }       
     // method to create Fresh Stock //
      public Stock__c createFreshStock(id centerid,id skuid)
        {
        
            Stock__c insertStock=new Stock__c();
            insertStock.Stock_Keeping_Unit__c=skuid;
            insertStock.Centers__c=centerid;
            insertStock.Quantity__c=0;
            insertStock.Outgoing_Quantity__c=0;
            insertStock.Incoming_Quantity__c=0;
            return insertstock;
        
        }
    
    
    public void opportunityupdate(id accountid)                    
        {  
                Opportunity checkBoxTrue=[select Dispatch_Order_For_Student__c from Opportunity where Account.id =: accountid];
                checkBoxTrue.Dispatch_Order_For_Student__c= true;
                update checkBoxTrue;
                
        }  
     public void transitstage(Stock__c fromc,Stock__c transit,decimal quantityAtDo,id skuIdOnDo)
        {
            
                fromc.Quantity__c = fromc.Quantity__c-quantityAtDo;
                fromc.Outgoing_Quantity__c = fromc.Outgoing_Quantity__c + quantityAtDo;
                transit.Incoming_Quantity__c = transit.Incoming_Quantity__c + quantityAtDo;
                transit.Stock_Keeping_Unit__c= skuIdOnDo;
                update transit;
                update  fromc;
               
        }
   // <----------------------------------------------------------------------------------------------------->//
   //method initialized in order to reuse code
   public void deliverystage(Stock__c fromc,Stock__c to,Stock__c transit,decimal qauntityAtDispatch)                 
        {
            
            fromc.Outgoing_Quantity__c = fromc.Outgoing_Quantity__c - qauntityAtDispatch;
            transit.Incoming_Quantity__c = transit.Incoming_Quantity__c - qauntityAtDispatch;
            to.Quantity__c = to.Quantity__c + qauntityAtDispatch;
            update fromc;
            update transit;
            update to;
        }
    
    
 // <---------------------------------------------------------------------------------------------------------------> //
    // seperate method made since For student "To center" deductions wont matter.
     public void deliverystagewithouttocentre(Stock__c fromc,Stock__c transit,decimal qauntityAtDispatch)               
        {
           fromc.Outgoing_Quantity__c = fromc.Outgoing_Quantity__c - qauntityAtDispatch;
           transit.Incoming_Quantity__c = transit.Incoming_Quantity__c - qauntityAtDispatch;
           update transit;
           update fromc;
        }
  //<------------------------------------------------------------------------------------------------->//  
    public void ifStageIsCancelled(Stock__c fromc,Stock__c transit,decimal quantityAtDo)
        {
        
            fromc.Quantity__c = fromc.Quantity__c+quantityAtDo;
            fromc.Outgoing_Quantity__c = fromc.Outgoing_Quantity__c-quantityAtDo;
            transit.Incoming_Quantity__c = transit.Incoming_Quantity__c-quantityAtDo;
            update fromc;
            update transit;   
        
        }
   
    //<---------------------------------------------------------------------------------->//
   // method to check RecordType of Center.
    public map<string,Boolean> GetMapforIfRecordIsInfoCenter()
        {
               list<nm_Centers__c> lstfromCenterId=new list<nm_Centers__c>();
               lstfromCenterId = [select id,recordtype.name from nm_Centers__c ];
               system.debug('lstfromCenterId '+lstfromCenterId.size());
               map<string,Boolean> MapforIfRecordIsInfoCenter=new map<string,Boolean>();
               for(nm_Centers__c obj:lstfromCenterId)
               {
                 if(obj.recordtype.name == 'Information Center')
                 {
                   MapforIfRecordIsInfoCenter.put(obj.id,false);
                 }
                 else
                 {
                 
                   MapforIfRecordIsInfoCenter.put(obj.id,true);
                    system.debug('enter in True Information Center'+MapforIfRecordIsInfoCenter);
                 }
               
               }
               return MapforIfRecordIsInfoCenter;
               
        
        }
   // Method to create stock with Batch number
    public map<id,string> MapforBatchName()
        {
            list<Stock__c> lstStockBatchName = [select id,BatchNo__c from Stock__c];
            map<id,string> MapforBatch=new map<id,string>();
            
            for(Stock__c obj:lstStockBatchName )
            {
               MapforBatch.put(obj.id,obj.BatchNo__c);
            }
            return MapforBatch;
          
        }
    
    // method to check already dispatch order created or not.
   
 }