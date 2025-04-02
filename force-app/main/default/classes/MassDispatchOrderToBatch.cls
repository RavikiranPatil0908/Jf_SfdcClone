public  class MassDispatchOrderToBatch
  {

       private final ApexPages.StandardSetController cntr;
       public Map<String,Opportunity> mapOfSuccessOpportunityToUpdate;
       private final PageReference fromPage {get;set;}
       private transient ApexPages.Message currentMsg {get;set;}
       private String currentStep{get;set;}
       public List<Opportunity> lstOfSelectedRecords {get;set;}
       public String fieldName {get;set;}
       public Opportunity objopp {get;set;}
       public String valueToUpdate {get;set;}
       public integer sizeOfRecordsToUpdate {get;set;}
       public String Roles {get;set;}
       public list<nm_UserMapping__c> lstUserMapping {get;set;}
       public string oppid;
       public list<Stock_Keeping_Units__c > listStock;
       public Map<string,id> mapSkuByNameAndYear {get;set;}
       public Map<string,id> mapSkuByElectiveSub {get;set;}
       public Map<string,id> mapLearingCenterOwner {get;set;}
       public Map<string,boolean> mapforCheckStockExistorNot{get;set;}
       public list<nm_UserMapping__c> lstLearingCenterOwner; 
       public list<Opportunity> lstOfRecords {get;set;}
       public list<Stock__c> StockExist{get;set;}
       public String getStep() {
        return currentStep;
      }
      
   public MassDispatchOrderToBatch(ApexPages.StandardSetController controller) 
       {
           lstLearingCenterOwner = [select id,OwnerId,Name,nm_User__c,nm_Centers__c from nm_UserMapping__c] ;
           listStock = [select id,Name,Program__c,Semester__c,Launch_Year__c from Stock_Keeping_Units__c where Type_Of_SKU__c='Kit'];
           mapLearingCenterOwner =new map<string,id>();
           mapforCheckStockExistorNot=new map<string,boolean>();
           mapSkuByNameAndYear=new map<string,id>();
           mapSkuByElectiveSub=new map<string,id>();
           lstOfSelectedRecords =new List<Opportunity>();
           lstOfRecords =new list<Opportunity>(); 
           lstUserMapping  =new List<nm_UserMapping__c>();
           mapSkuByNameAndYear=getmapSkuByNameAndYear();
           mapSkuByElectiveSub=getmapSkuByElectiveSub();
           mapLearingCenterOwner=getLearingCenterOwner();
           mapforCheckStockExistorNot=getmapforCheckStockExistorNot();
           currentStep = '1';
           fieldName ='';
           Roles ='';
           oppid='';
           mapOfSuccessOpportunityToUpdate = new Map<String,Opportunity>();
           objopp =new Opportunity();
           controller.setPageSize(1000);
           cntr = (ApexPages.StandardSetController)controller;
           
           
           lstUserMapping=[select id,nm_Centers__c,nm_User__r.UserRole.Name,nm_User__r.Profile.Name from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()];
           if(lstUserMapping.size()>0)
            {
                if(lstUserMapping.size()>0  && lstUserMapping[0].nm_User__r.UserRole.Name !=null)
                {
                Roles = lstUserMapping[0].nm_User__r.UserRole.Name; // checking role for hiding update Information Center option for IC User 
                }
                else
                {
                Roles = 'System Administrator';
                }
            } 
           else
            {
            Roles = 'System Administrator';
            }   
        
           // checking records for Mass Update dispatch order
           list<string> lstOpportunityRecord = new list<string>();
            List<SObject> lstSObject = cntr.getSelected(); 
            system.debug('lstSObject '+lstSObject.size());
            sizeOfRecordsToUpdate = lstSObject.size();
            String RecordId ='';
            for(SObject s : lstSObject)
            {
                RecordId = s.id;
                lstOpportunityRecord.add(RecordId);
                system.debug('lstOpportunityRecord'+lstOpportunityRecord);
               
            }
            System.debug('Id Of Selected Record--->'+RecordId);
         lstOfRecords =[select id,nm_SelfLearningMaterial__c,nm_InformationCenters__c,nm_Program__r.name,nm_Semester__c,Launch_Year__c,IC_ID__c,nm_Program2__c,Elective_Subject_Type__c,nm_Program2__r.Name,BookCChargeapplicable__c
                                               from Opportunity where id=:lstOpportunityRecord and StageName='Closed Won' 
                                               and Dispatch_Order_For_Student__c=false];
                                               system.debug('lstOfRecords '+lstOfRecords.size());
                                             
               if(lstOfRecords.size()>0)
               {
                       system.debug('cntr.getSelected()==>'+cntr.getSelected());              
                   lstOfSelectedRecords = cntr.getSelected();
                   System.debug('lstOfRecords----->'+lstOfRecords.size());
               }
               else
               {
                   String msg = 'Opportunity Stage must be closed Won and No Dispatch Order must have been created for the Student.'; 
                   currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
                   ApexPages.addMessage(currentMsg);
                  
               } 
               
               fromPage = cntr.cancel();

           if (sizeOfRecordsToUpdate<1) 
            {
                String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
                currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            } 
           else 
           {
                String msg = 'Number of records selected for update: ' + sizeOfRecordsToUpdate; 
                currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
            }
           ApexPages.addMessage(currentMsg);
        }
   
   public PageReference cancel() 
     {
        return fromPage;
     }
    
    
       // First Page------------------------> 
   public PageReference step1() 
    { 
       
        currentStep='1';          
        return ApexPages.currentPage();
    }
    
    
    //Second Page-----------------------------//
    public PageReference step2() 
    {
      system.debug('lstOfRecords in step2'+lstOfRecords);
       if(lstOfRecords.size()<sizeOfRecordsToUpdate)
           {
               return cancel(); 
           }
                currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Field type of selected field:'+fieldName);
            ApexPages.addMessage(currentMsg);
        
            currentStep='2';          
            return ApexPages.currentPage();
    }

    
    // Third Page------------------------------//
    public PageReference step3() 
    {
        // data type validation
           if (currentMsg!=null) 
           {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, '');
                ApexPages.addMessage(msg);
                ApexPages.addMessage(currentMsg);
                return ApexPages.currentPage();
           }
            
            String msg = 'Please review your selections before confirm: <br></br>'; 
            msg = msg + '<br><b>Records Selected:</b>    ' + sizeOfRecordsToUpdate +'</br>';
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
            ApexPages.addMessage(currentMsg);
            currentStep='3';  
            return ApexPages.currentPage();        
    }
    // Four Page---------------------------------//
      public PageReference step4() 
            {
               if(lstOfSelectedRecords.size()>0)
                {
                    UpdateDispatchRecords(lstOfSelectedRecords);
                }
                system.debug('currentMsg==>'+currentMsg);
                 ApexPages.addMessage(currentMsg);
                currentStep='4';          
                return ApexPages.currentPage();
                   
            }
    
  
    // Update Selected Dispatch Record-----------------//
    public ApexPages.Message UpdateDispatchRecords(List<Opportunity> lstOfSelectedRecords)
        {

              
                list<id> listOfError=new list<id>();
                list<Opportunity> lstUpdateOpportunity=new list<Opportunity>();
                set<String> setOfSuccessfullDispatchId = new Set<String>();
        
            for(Opportunity ObjOpp:lstOfSelectedRecords)
            {
         
                string DispatchownerId;
                id SkuId;
                
                system.debug('ObjOpp.Program_Name__c==>'+ObjOpp.Program_Name__c);
                system.debug('ObjOpp.nm_Semester__c==>'+ObjOpp.nm_Semester__c);
                system.debug('ObjOpp.Launch_Year__c==>'+ObjOpp.Launch_Year__c);
                system.debug('ObjOpp.BookCChargeapplicable__c==>'+ObjOpp.BookCChargeapplicable__c);
                system.debug('ObjOpp.Elective_Subject_Type__c==>'+ObjOpp.Elective_Subject_Type__c);
                If(ObjOpp.BookCChargeapplicable__c==True && ObjOpp.Elective_Subject_Type__c!=null) 
                {
                    system.debug('Inside elective');
                    system.debug('ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c==>'+ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                    SkuId=mapSkuByElectiveSub.get(ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                }
                else{
                    SkuId=mapSkuByNameAndYear.get(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c);
                }
             system.debug('SkuId'+SkuId);
            //Stock_Keeping_Unit__c =mapSkuByNameAndYear.get(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c)
            Boolean StockExist = MapForCheckStockExistorNot.get(valueToUpdate+'-'+SkuId);
            system.debug(StockExist);
            //if(StockExist=true)
            if(StockExist!=null && StockExist==true)
            {
                if(mapSkuByNameAndYear.containsKey(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c) || mapSkuByElectiveSub.containsKey(ObjOpp.Program_Name__c+ObjOpp.Elective_Subject_Type__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c) )
                //if(mapSkuByNameAndYear.containsKey(ObjOpp.Program_Name__c+ObjOpp.nm_Semester__c+ObjOpp.Launch_Year__c))
               {
                    system.debug('Key exist');
                    if(ObjOpp.nm_SelfLearningMaterial__c !='' && ObjOpp.nm_SelfLearningMaterial__c !=null)
                    {
                          ObjOpp.AutoCreateDispatchOrder__c = true;
                          ObjOpp.Dispatch_From_Center__c = valueToUpdate;
                          lstUpdateOpportunity.add(objOpp);
                    }
                                  
                }
                else
                {
                    system.debug('inside 1st else');
                 String msg = 'Stock keeping Unit not available'; 
                 currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
                 ApexPages.addMessage(currentMsg);
                }
            }
              else
              {
                 system.debug('inside 2nd else');
                 String msg = 'Stock Does not exist at the Particular Learning Center'; 
                 currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
                 ApexPages.addMessage(currentMsg);
              }         
           }
            system.debug(lstUpdateOpportunity.size());
                    if(lstUpdateOpportunity.size()>0 )
                    {
                    
                              System.debug('Update in');
                            Database.SaveResult[] srList = Database.update(lstUpdateOpportunity,false);
                            system.debug('srList size '+srList.size());
                            system.debug('srList '+srList );
                           
                             
                            for (Database.SaveResult sr : srList) 
                            {
                               system.debug('sr.isSuccess()'+sr.isSuccess());
                                if (sr.isSuccess()) 
                                 {
                                     setOfSuccessfullDispatchId.add(sr.getId());
                                    // Operation was successful, so get the ID of the record that was processed
                                   currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated' + sr.getId()+ ' Records');
                                   ApexPages.addMessage(currentMsg );
                                    System.debug('Successfully updated opportunityID: ' + sr.getId());
                                  }
                                  else 
                                  
                                     {
                                    // Operation failed, so get all errors                
                                        for(Database.Error err : sr.getErrors()) 
                                        {
                                        
                                           
                                            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Failed to update' +err.getMessage() + ' Records');
                                            ApexPages.addMessage(currentMsg );
                                            System.debug('The following error has occurred.');                    
                                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                            System.debug('Account fields that affected this error: ' + err.getFields());
                                        }
                                    } 
                              
                              }   
                              
                              // update Dispatch order created check box on Opportunity
                             /* if(setOfSuccessfullDispatchId.size()>0)
                              {
                                 
                                 if(lstUpdateOpportunity.size()>0){
                                     update lstUpdateOpportunity;
                                 }
                              }*/
                             
                    }
                          
                              
                             
             return currentMsg ;  
        }     
         
                
      
        
    
    // Get All LC------------------------// 
    public List<SelectOption> getLC() {
        List<nm_Centers__c> lstLcRelatedInformationCenter = new List<nm_Centers__c>();
        // if(lstUserMapping.size() > 0){ 
        //     System.debug('lstUserMapping'+lstUserMapping.size());
        //     System.debug('lstUserMapping[0].nm_User__r.Profile.Name '+lstUserMapping[0].nm_User__r.Profile.Name);
        //     if(lstUserMapping.size() > 0  && lstUserMapping[0].nm_User__r.UserRole.Name !=null && lstUserMapping[0].nm_User__r.UserRole.Name.startsWith('Learning')){
        //         lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c WHERE id IN (SELECT nm_Centers__c FROM nm_UserMapping__c WHERE nm_User__c=:UserInfo.getUserId())];
        //     }else if(lstUserMapping[0].nm_User__r.Profile.Name.startsWith('System Administrator') || lstUserMapping[0].nm_User__r.Profile.Name.startsWith('Logistics') ){
        //         lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c WHERE RecordType.Name='Learning Center'];
        //         system.debug('lstLcRelatedInformationCenter'+ lstLcRelatedInformationCenter.size());
        //     }else if(lstUserMapping[0].nm_User__r.Profile.Name.startsWith('Repro')){
        //         lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c where CenterName__c LIKE '%Repro'];
        //     }
        // } else {
        //     lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c];
        // }

        if(lstUserMapping.size() > 0) {
            if(lstUserMapping[0].nm_User__r.Profile.Name.startsWith('Repro')) {
                lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c where CenterName__c LIKE '%Repro%'];
            } else {
                lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c WHERE RecordType.Name='Learning Center'];
            }
        } else {
            lstLcRelatedInformationCenter = [SELECT name,id FROM nm_Centers__c WHERE RecordType.Name='Learning Center'];
        }
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('','-None-'));
        for(nm_Centers__c objCenter :lstLcRelatedInformationCenter) {
            options.add(new SelectOption(objCenter.id,objCenter.Name));
           // System.debug('Option'+ options);
        }
        return options;    
    }
       
   
    // get StockKeepingUnit.id VS Semester,LauchYear,Program--------------//
    public map<string,id> getmapSkuByNameAndYear()
        {
            system.debug('Method skubynameyr');
              string key='';
              string Program;
             
                for(Stock_Keeping_Units__c obj:listStock)
                  {
                     if(obj.Program__c !=null)
                     {
                          system.debug('Method skubynameyr Program__c not null ');
                      Program=obj.Program__c;
                      list<string> Programlist=Program.split(';');
                      system.debug('Programlist'+Programlist);
                      for(string Prog :Programlist)
                      { 
                            key=Prog+obj.Semester__c+obj.Launch_Year__c;
                            mapSkuByNameAndYear.put(key,obj.id);
                            System.debug('Prog'+Prog); 
                      }
                      
                       //System.debug('obj.Semester__c'+obj.Semester__c);
                       //System.debug('obj.Launch_Year__c'+obj.Launch_Year__c);
                       System.debug('mapSkuByNameAndYear'+mapSkuByNameAndYear);
                       }
                  }
               
               return mapSkuByNameAndYear ; 
        }
      public map<string,id> getmapSkuByElectiveSub()
        {
            string key='';
            string Program;
             for(Stock_Keeping_Units__c obj:listStock)
                  {
                     // String str='FIMCF-S5-Jul2024-Kit';
                      //String str=obj.Name;
                      //String[] split=str.split('-');
                      //String Value=split[0]+'-'+split[1];
                      //String Value=split[0];

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
        
         //Get Learning center user
          public map<string,id> getLearingCenterOwner()
        {
               system.debug('lstLearingCenterOwner'+lstLearingCenterOwner.size());
               for(nm_UserMapping__c obj: lstLearingCenterOwner)
                  {
                     mapLearingCenterOwner.put(obj.nm_Centers__c,obj.nm_User__c);
                     system.debug('LearingCenterOwner'+mapLearingCenterOwner );   
                  }
                  return mapLearingCenterOwner ;
        }
        
        public  map<string,boolean> getMapForCheckStockExistorNot()
        {
        string key='';
        //  list<Stock__c> StockExist =[select Centers__c,Stock_Keeping_Unit__c,Quantity__c from Stock__c where Stock_Keeping_Unit__c!=null];
         list<Stock__c> StockExist =[select Centers__c,Stock_Keeping_Unit__c,Quantity__c from Stock__c ];
          for(Stock__c objStock: StockExist)
           {
              key=objStock.Centers__c+'-'+objStock.Stock_Keeping_Unit__c;
              system.debug('key'+key);
              if(objStock.Quantity__c>0)
              {
                system.debug('Enter in CheckStockExistorNot true');
                 MapForCheckStockExistorNot.put(key,true);
              }
              else
              {
                   system.debug('Enter in CheckStockExistorNot false');
                 MapForCheckStockExistorNot.put(key,false);
              }
           }
            return MapForCheckStockExistorNot;
        }
     
            
   }