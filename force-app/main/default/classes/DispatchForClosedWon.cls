global class DispatchForClosedWon
{

       
       webservice static string CheckStockAtFromCenter(String program,String semester,String launchYear,String ICName)
       {
           
           System.debug('Values on call--------->'+program+'<-------semester---->'+semester+'<--------launchYear---->'+launchYear);
           boolean checkStock;
           nm_Centers__c objCenterFromName = [select id,nm_LearningCenter__c from nm_Centers__c where name=:ICName];
           System.debug('<------------objCenterFromName------>'+objCenterFromName);
           id skuId;
           Stock_Keeping_Units__c stock = getSkuByNameAndYear(program,semester,launchYear);
           System.debug('<--------------------stock-------------->'+stock);
           list<Stock_Keeping_Units__c> listStock = new list<Stock_Keeping_Units__c>();
           listStock.add(stock); 
           if(listStock!=null && listStock.size()>0)
           {
             skuId = listStock[0].id;
             System.debug('<--------stockId------->'+skuId);
           }
           // check String ICName is Learning Center Or Information Center 
           if(objCenterFromName.nm_LearningCenter__c !=null)
           {
             checkStock = checkIfStockExists(objCenterFromName.nm_LearningCenter__c,skuId);
           }
           else
           {
               checkStock = checkIfStockExists(objCenterFromName.id,skuId);
           } 
           System.debug('<----------------checkStock------------->'+checkStock);
           if(checkStock == true)
           {
             return 'Success';
           }
           
           else
           {
           
           return 'Fail';
           
           }
           
       
       
       
       }
       webservice static String UpdateFinalQuantityOnCenter(id centerId,id stockId)
       {
           
           SKUHelper ob = new SKUHelper();
           Stock__c icStockToUpdate = ob.getStockByID(centerId,stockId);
           System.debug('<----icStockToUpdate---->'+icStockToUpdate);
           icStockToUpdate.Quantity__c = 0 ;
           update icStockToUpdate;
           return 'Done';
       }
       
       
       
       webservice static void CreateDispatch(String oppId,String ICName) 
       {
                   String LearningCenterId;
                   string DispatchownerId;
                   SKUHelper ob = new SKUHelper();
                   nm_Centers__c objCenterFromName = [select id,nm_LearningCenter__c,OwnerId from nm_Centers__c where name=:ICName];
                  
                   Opportunity obj = [select id,IC_ID__c,Learning_Center__c,Account.id,nm_Program__r.name,nm_Semester__c,Launch_Year__c,Dispatch_Order_For_Student__c,nm_SelfLearningMaterial__c from Opportunity where id=:oppId];
                   Stock_Keeping_Units__c skuToCall = ob.getSkuByNameAndYear(obj.nm_Program__r.name,obj.nm_Semester__c,obj.Launch_Year__c);
                   nm_UserMapping__c objLearingCenterOwner=[select id,OwnerId,Name,nm_User__c from nm_UserMapping__c where nm_Centers__c =:obj.IC_ID__c];
                   //nm_Centers__c objLearingCenterOwner= [select id,Name,nm_LearningCenter__c,CenterName__c,OwnerId from nm_Centers__c where Name=:obj.Learning_Center__c];
                   
                   System.debug('<------skuToCall------->'+skuToCall);
                   System.debug('<---------------obj.nm_SelfLearningMaterial__c------------->'+obj.nm_SelfLearningMaterial__c);
                    // check String ICName is Learning Center Or Information Center 
                   if(objCenterFromName.nm_LearningCenter__c !=null)
                   {
                       LearningCenterId = objCenterFromName.nm_LearningCenter__c;
                       DispatchownerId=objLearingCenterOwner.nm_User__c;
               
                   }
                   else
                   {
                       LearningCenterId = objCenterFromName.id;
                       DispatchownerId=objLearingCenterOwner.nm_User__c;
                   }
                 list<Dispatch_Order__c> dispatchesToAdd = new list<Dispatch_Order__c>();
              
                  if(obj.nm_SelfLearningMaterial__c =='Send to my shipping address')
                  {
                   
            
                           dispatchesToAdd.add(new Dispatch_Order__c(
                           
                           Stock_Keeping_Unit__c =skuToCall.id,
                           From_Centers__c = LearningCenterId,
                           To_Student__c = obj.Account.id,
                           Order_Type__c = 'Student Order',
                           Quantity__c = 1,
                           Opportunity__c = obj.id,
                           Status_Of_Dispatch__c = 'Study Kit assigned',
                           OwnerId=DispatchownerId
                           
                           ));
                   }
                   
                   else if(obj.nm_SelfLearningMaterial__c =='Send to my Information Centre. I will pick up.' || obj.nm_SelfLearningMaterial__c =='Send to my Corporate')
                   {    
               
                       dispatchesToAdd.add(new Dispatch_Order__c(
                       
                       Stock_Keeping_Unit__c =skuToCall.id,
                       From_Centers__c = LearningCenterId,
                       To_Centers__c = obj.IC_ID__c,
                       //To_Student__c = obj.Account.id,
                       Order_Type__c = 'Student Order',
                       Quantity__c = 1,
                       Opportunity__c = obj.id,
                       Status_Of_Dispatch__c = 'Study Kit assigned',
                       OwnerId=DispatchownerId
                       ));
                   }
                  
                   System.debug('<------------dispatchesToAdd-------------->'+dispatchesToAdd);
                   obj.Dispatch_Order_For_Student__c = true;
                   update obj;
           
           insert dispatchesToAdd;
                   
         }
          public static Stock_Keeping_Units__c getSkuByNameAndYear(String program,String semester,String launchYear) // method to get SKU based on launchYear,program and semester//
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
    public static boolean checkIfStockExists(id centerId,id skuId)
    {
        //boolean val ;
        list<Stock__c> StockExist =[select Centers__c,Stock_Keeping_Unit__c,Quantity__c from Stock__c where Centers__c=:centerid AND Stock_Keeping_Unit__c=:skuId];
        if(StockExist.isEmpty() || StockExist[0].Quantity__c ==0)
        {
            return false;
        
        }
       
        else
        {
           return true;
        }   
    }
           
  
}