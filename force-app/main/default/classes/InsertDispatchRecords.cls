/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class InsertDispatchRecords implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

         
            public list<Dispatch_Order__c> dispatchesToAdd = new list<Dispatch_Order__c>();            
            public list<id> listOfError = new list<id>();
            public list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
            public set<String> setOfSuccessfullDispatchId =  new set<String>();
            public Map<string,id> mapSkuByElectiveSub = new  Map<string,id>();
            public Map<string,id> mapSkuByNameAndYear = new Map<string,id> ();
            public Map<string,boolean> mapforCheckStockExistorNot = new Map<string,boolean> ();
            public Map<String,Opportunity> mapOfSuccessOpportunityToUpdate  = new Map<String,Opportunity>();
            public Map<Id,Stock_Keeping_Units__c > mapOfStockIdVsStock =new  Map<Id,Stock_Keeping_Units__c> ();    
            public list<Stock_Keeping_Units__c > listStock = new list<Stock_Keeping_Units__c> ();   
            public Set<String> lstFailedRecords = new Set<String>();
            public Integer successCount = 0;
            public Integer failedCount = 0;
            public Integer totalCount = 0;
            
          //  public String valueToUpdate='a02O000000QUNk5IAH';
            
            public InsertDispatchRecords (){
                 
            }

            public void execute(SchedulableContext sc) {
            InsertDispatchRecords b = new InsertDispatchRecords();
            Database.executebatch(b, 50);
            }
            
             public Database.QueryLocator start(Database.BatchableContext bc) {
                mapSkuByElectiveSub = getmapSkuByElectiveSub();
                mapSkuByNameAndYear = getmapSkuByNameAndYear();
                mapforCheckStockExistorNot = getmapforCheckStockExistorNot();
                System.debug('Update DO list Batch started');
                /*
                mapSkuByElectiveSub = getmapSkuByElectiveSub();
                mapSkuByNameAndYear = getmapSkuByNameAndYear();
                mapforCheckStockExistorNot = getmapforCheckStockExistorNot();
                */
                String query = 'SELECT id,Dispatch_From_Center__c,OwnerId,AccountId,Program_Name__c,nm_Semester__c,Launch_Year__c,BookCChargeapplicable__c,Elective_Subject_Type__c,nm_SelfLearningMaterial__c,IC_ID__c,AutoCreateDispatchOrder__c,DispatchBatchError__c,Dispatch_Order_For_Student__c FROM Opportunity WHERE AutoCreateDispatchOrder__c=true and Dispatch_Order_For_Student__c=false AND StageName=\'Closed Won\'AND BookCChargeapplicable__c =true AND nm_SelfLearningMaterial__c!=\'\' AND nm_Program__c != null  Order by CreatedDate DESC LIMIT 50';
                
                 
                return Database.getQueryLocator(query);
            }

          public void execute(Database.BatchableContext bc, List<sObject> scope) {
            
           if(scope.size() > 0) {
               
            for(SObject sc : scope)
            {
                Opportunity ObjOpp = (Opportunity)sc;
                string DispatchownerId;
                id SkuId;
                
                system.debug('ObjOpp.Program_Name__c==>'+ObjOpp.Program_Name__c);
                system.debug('ObjOpp.nm_Semester__c==>'+ObjOpp.nm_Semester__c);
                system.debug('ObjOpp.Launch_Year__c==>'+ObjOpp.Launch_Year__c);
                system.debug('ObjOpp.BookCChargeapplicable__c==>'+ObjOpp.BookCChargeapplicable__c);
                system.debug('ObjOpp.Elective_Subject_Type__c==>'+ObjOpp.Elective_Subject_Type__c);
                
                if(ObjOpp.BookCChargeapplicable__c == True && ObjOpp.Elective_Subject_Type__c!=null) 
                {
                    system.debug('Inside elective');
                    system.debug('ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c==>'+ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                    
                    SkuId = mapSkuByElectiveSub.get(ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                }
                else{
                    SkuId = mapSkuByNameAndYear.get(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                }
             system.debug('SkuId'+SkuId);
          
            Boolean StockExist = MapForCheckStockExistorNot.get(ObjOpp.Dispatch_From_Center__c+'-'+SkuId);
            system.debug('MapForCheckStockExistorNot-->'+MapForCheckStockExistorNot);
           
            if(StockExist!=null && StockExist==true)
            {
                if(mapSkuByNameAndYear.containsKey(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c) || mapSkuByElectiveSub.containsKey(ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c) )                
               {
                   system.debug('Key exist');
                if(ObjOpp.nm_SelfLearningMaterial__c =='Send to my shipping address')
                {
                    system.debug('Enter in Shiffing address');
                    dispatchesToAdd.add(new Dispatch_Order__c(
                    Stock_Keeping_Unit__c = SkuId,
                    From_Centers__c = ObjOpp.Dispatch_From_Center__c,
                    To_Student__c = ObjOpp.AccountId,
                    Order_Type__c = 'Student Order',
                    Quantity__c = 1,
                    Opportunity__c = ObjOpp.id,
                    Status_Of_Dispatch__c = 'Study Kit assigned',
                    OwnerId = ObjOpp.OwnerId,
                    Generate_AirwayBill__c =true
                    ));
                    system.debug('dispatchesToAdd'+ dispatchesToAdd);
                }
                   
                else if(ObjOpp.nm_SelfLearningMaterial__c =='Send to my Information Centre. I will pick up.' || ObjOpp.nm_SelfLearningMaterial__c =='Send to my Corporate')
                { 
                    system.debug('Enter in Information address');
                    dispatchesToAdd.add(new Dispatch_Order__c(
                   
                    Stock_Keeping_Unit__c = SkuId,
                    From_Centers__c = ObjOpp.Dispatch_From_Center__c,
                    To_Centers__c = ObjOpp.IC_ID__c,
                       //To_Student__c = obj.Account.id,
                     Order_Type__c = 'Student Order',
                     Quantity__c = 1,
                    Opportunity__c = ObjOpp.id,
                    Status_Of_Dispatch__c = 'Study Kit assigned',
                    OwnerId = ObjOpp.OwnerId,
                    Generate_AirwayBill__c =true
                    ));
                      
                    System.debug('<------------dispatchesToAdd-------------->'+dispatchesToAdd);
                
                }
                     
                       ObjOpp.Dispatch_Order_For_Student__c = true;
                       
                      
                      // put records in map
                      mapOfSuccessOpportunityToUpdate.put(objOpp.id,objOpp);
              
                }
                else
                {
                  system.debug('inside 1st else');
                  ObjOpp.AutoCreateDispatchOrder__c = false;
                  ObjOpp.DispatchBatchError__c = 'Stock keeping Unit not available'; 
                  lstUpdateOpportunity.add(ObjOpp);
                 
                }
                    totalCount++; 
            }
              else
              {
                 system.debug('inside 2nd else');
                 ObjOpp.AutoCreateDispatchOrder__c = false;
                 ObjOpp.DispatchBatchError__c =  'Stock Does not exist at the Particular Learning Center'; 
                 lstUpdateOpportunity.add(ObjOpp);
              }         
           }
          }
            system.debug(dispatchesToAdd.size());
                    if(dispatchesToAdd.size()>0 )
                    {
                    
                            System.debug('Insert in');
                            Database.SaveResult[] srList = Database.insert(dispatchesToAdd,false);
                            system.debug('srList size '+srList.size());
                            system.debug('srList '+srList );
                            
                             
                            for (Database.SaveResult sr : srList) 
                            {
                               system.debug('sr.isSuccess()'+sr.isSuccess());
                                if (sr.isSuccess()) 
                                 {
                                     setOfSuccessfullDispatchId.add(sr.getId());
                                    // Operation was successful, so get the ID of the record that was processed
                                   successCount++;
                                    System.debug('Successfully updated opportunity. Opp ID: ' + sr.getId());
                                  }
                                  else 
                                  
                                     {
                                    // Operation failed, so get all errors                
                                        for(Database.Error err : sr.getErrors()) 
                                        {
                                            lstFailedRecords.add(sr.getId());
                                             failedCount++;
                                            System.debug('The following error has occurred.');                    
                                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                            System.debug('Opportunity fields that affected this error: ' + err.getFields());
                                        }
                                    } 
                              
                              }   
                              
                              // update Dispatch order created check box on Opportunity
                              if(setOfSuccessfullDispatchId.size()>0)
                              {
                                system.debug('setOfSuccessfullDispatchId'+setOfSuccessfullDispatchId.size());
                                List<Dispatch_Order__c> lstDispatch = [select id,Opportunity__c  from Dispatch_Order__c where id in :setOfSuccessfullDispatchId];
                                
                                if(lstDispatch.size()>0){
                                    for(Dispatch_Order__c objDispatch : lstDispatch)
                                    {
                                       
                                        Opportunity objOpps = mapOfSuccessOpportunityToUpdate.get(objDispatch.Opportunity__c);
                                         objOpps.Dispatch_Order_Number_For_Student__c = objDispatch.id;
                                          objOpps.AutoCreateDispatchOrder__c = false; 
                                         // String  response = FedExWebService.createShipment(objDispatch.id);
                                         // System.debug('response--->'+response);                                     
                                          lstUpdateOpportunity.add(objOpps);
                                     
                                    }    
                                    // CreateAirwayBill(setOfSuccessfullDispatchId); 
                                 }
                                 
                                 if(lstUpdateOpportunity.size()>0){
                                     update lstUpdateOpportunity;
                                 }
                              }                             
                    }
                                                                                              
        }
        public List<Stock_Keeping_Units__c> getlistStock(){
        if(listStock.isEmpty()){
            String queryAllStockKeepingUnit = getQueryAllFieldSql('Stock_Keeping_Units__c','Type_Of_SKU__c=\'Kit\' and  id !=null',null);                       
             mapOfStockIdVsStock = new Map<id,Stock_Keeping_Units__c>((List<Stock_Keeping_Units__c>)DataBase.query(queryAllStockKeepingUnit));
            listStock = mapOfStockIdVsStock.values() ;
            system.debug('listStock---query'+listStock );
        }       
        return listStock;
    }
     public map<string,id> getmapSkuByNameAndYear()
        {
            system.debug('Method skubynameyr');
              string key='';
              string Program;
              listStock = getlistStock();
             
                for(Stock_Keeping_Units__c obj:listStock)
                  {
                     if(obj.Program__c !=null)
                     {
                       system.debug('Method skubynameyr Program__c not null ');
                      Program = obj.Program__c;
                      list<string> Programlist = Program.split(';');
                      system.debug('Programlist'+Programlist);
                      for(string Prog :Programlist)
                      { 
                            key = Prog+obj.Semester__c+obj.Launch_Year__c;
                            mapSkuByNameAndYear.put(key,obj.id);
                            System.debug('Prog'+Prog); 
                      }
                                          
                       System.debug('mapSkuByNameAndYear'+mapSkuByNameAndYear);
                       }
                  }
               
               return mapSkuByNameAndYear ; 
        }
          public map<string,id> getmapSkuByElectiveSub()
         {
            string key='';
            string Program;
            listStock = getlistStock();
             for(Stock_Keeping_Units__c obj:listStock)
                  {

                     if(obj.Program__c !=null)
                     {
                      Program=obj.Program__c;
                      list<string> Programlist=Program.split(';');
                      system.debug('Programlist'+Programlist);
                      for(string Prog :Programlist)
                      {
                          If(Prog =='BBA - Finance' || Prog =='BBA - Marketing')
                          {
                          String str=Prog;
                          system.debug('str==>'+str);
                          String[] split=str.split(' - ');
                          String Value=split[0]+split[1];
                           // key=Prog+obj.Semester__c+obj.Launch_Year__c;
                         // key=Prog+Value+obj.Semester__c+obj.Launch_Year__c;
                          key=Value+obj.Semester__c+obj.Launch_Year__c;
                          system.debug('Value==>'+Value);
                          system.debug('key==>'+key);
                          mapSkuByElectiveSub.put(key,obj.id);
                          System.debug('Prog'+Prog); 
                          }
                      }
                      // System.debug('mapSkuByNameAndYear'+mapSkuByElectiveSub);
                       }
                  }
           return mapSkuByElectiveSub; 
        }
          public  map<string,boolean> getMapForCheckStockExistorNot()
        {
        system.debug('Insert stockdetail');
        string key='';
        
         list<Stock__c> StockExist =[select Centers__c,Stock_Keeping_Unit__c,Quantity__c from Stock__c where Stock_Keeping_Unit__c!='' ];
          for(Stock__c objStock: StockExist)
           {
              key = objStock.Centers__c+'-'+objStock.Stock_Keeping_Unit__c;
              system.debug('key'+key);
              if(objStock.Quantity__c>0)
              {
                system.debug('Enter in CheckStockExistorNot true');
                 this.MapForCheckStockExistorNot.put(key,true);
              }
              else
              {
                   system.debug('Enter in CheckStockExistorNot false');
                 this.MapForCheckStockExistorNot.put(key,false);
              }
           }
            return MapForCheckStockExistorNot;
        }
        public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
     public void finish(Database.BatchableContext bc) {
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
        //list<Dispatch_Order__c > lstdispatch = new list<Dispatch_Order__c> ();
        system.debug('Finished ===> ');
         if(setOfSuccessfullDispatchId.size()>0)
        {
        
//MassCreateDispatchOrderController.CreateAirwayBillvs2(setOfSuccessfullDispatchId);
            /*   for(String doid : setOfSuccessfullDispatchId)
               {
               Dispatch_Order__c objDispatch = new Dispatch_Order__c (id=doid);
               objDispatch.Generate_AirwayBill__c = true; 
               lstdispatch.add(objDispatch);
               
               }    
               if(lstdispatch.size()>0)
               {
                   update lstdispatch;
               }*/
               
                 for(String doid : setOfSuccessfullDispatchId)
                {
                    String   response = FedExWebService.createShipment(doid);
                    System.debug('response--->'+response);
                }        
           }
    }
    public void sendErrorMail() {
        String recordList = '';
        if(lstFailedRecords!=null && lstFailedRecords.size()>0) {
            for(String s: lstFailedRecords) {
                recordList += (recordList==''?'':',\n')+s;
            }
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('InsertDispatchRecords Error Mail');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below InsertDispatchRecords Class Error:\n'+
        'Here are the lists of failed records List:\n'+
          recordList +'\n\n'+
        'Total Records Processed: ' +totalCount +'\n'+
        'Sucess Records: '+ successCount +'\n'+
        'Error Records: '+ failedCount +'\n\n'+
       
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

     
    }

/*public static void CreateAirwayBill(Set<String> SuccessDoId){
           String response;
           if(SuccessDoId.size()>0)
           {
               for(String doid : SuccessDoId )
               {
                   response = FedExWebService.createShipment(doid);
                   System.debug('response--->'+response);
               }                   
           }
           
       }*/
}