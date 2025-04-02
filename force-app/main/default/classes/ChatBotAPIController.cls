/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 11-09-2022
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-20-2021   @BK   Initial Version
**/
public without sharing class ChatBotAPIController {

    public Map<String,Object> MapOfResponseParameters {get;set;}
    public List<Object> myResult {get;set;}

    public Map<String, String> AssignToLCFromList;
    


    public ChatBotAPIController() {
        MapOfResponseParameters = new Map<String,Object>();
        myResult = new List<Object>();
        AssignToLCFromList = new Map<String, String>();
        getICNameFromCity();
    }

    public Blob RedirectToURI(String KeyUrl,String jsonString) {
        switch on KeyUrl {
            when 'getRecord' {
                return getRecord(jsonString);
            } when 'getDocuments' {
                return getDocuments(jsonString);
            } when 'getDispatchOrder' {
                return getDispatchOrder(jsonString);
            }when 'getRefund' {
                return getRefund(jsonString);
            }when 'getLatestOpportunity' {
                return getLatestOpportunity(jsonString);
            }when 'CreateTask' {
                return CreateTask(jsonString);
            }when 'CreateCase' {
                return CreateCase(jsonString);
            }when 'getRecordFromEmailAndMobile' {
                return getRecordFromEmailAndMobile(jsonString);
            }
            when 'getRecordBySapId' {
                return getRecordBySapId(jsonString);
            }
            when else {
                return InvalidURI();
            }
        }
    }


    /**
    * @description 
    * @author @BK | 01-20-2021 
    * @return Blob 
    **/
    public Blob InvalidURI() {
        // To set the Requested Parameters.
        MapOfResponseParameters.put('message','Could not find a match for URL');
        MapOfResponseParameters.put('errorCode','NOT_FOUND');
        myResult.add(MapOfResponseParameters);

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(myResult));
        return Result;
    }

    public Blob getRecord(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'email','mobile','program','name','city'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            String emailId = String.valueOf(mapOfRequestParameters.get('email'));
            String mobileNo = String.valueOf(mapOfRequestParameters.get('mobile'));
            String program = String.valueOf(mapOfRequestParameters.get('program'));
            String programName = String.valueOf(mapOfRequestParameters.get('programName'));
            String firstname = String.valueOf(mapOfRequestParameters.get('name'));
            //String SapId = String.valueOf(mapOfRequestParameters.get('SapId'));
            Map<String, String> AssignToLCFromList1 = this.AssignToLCFromList;
            String city;
            System.debug(AssignToLCFromList1.get(String.valueOf(mapOfRequestParameters.get('city'))));
            if (AssignToLCFromList1.containsKey(String.valueOf(mapOfRequestParameters.get('city')))) {
                city = AssignToLCFromList1.get(String.valueOf(mapOfRequestParameters.get('city')));
            } else {
                city = String.valueOf(mapOfRequestParameters.get('city'));

            }
            String programType = mapOfRequestParameters.containsKey('programType') ? String.valueOf(mapOfRequestParameters.get('programType')) : null;
            String accountQuery = getQueryAllFieldSql('Account','(PersonEmail=:emailId OR PersonMobilePhone=:mobileNo) AND Active_account__c=true',null);
            String leadQuery = getQueryAllFieldSql('Lead','(Email=:emailId OR MobilePhone=:mobileNo) AND IsConverted=false',null);
            //String accountSapQuery = getQueryAllFieldSql('Account','(PersonEmail=:emailId OR PersonMobilePhone=:mobileNo) AND Active_account__c=true AND nm_StudentNo__c=:SapId',null);
            List<Account> lstAccount = DataBase.query(accountQuery);
           // List<Account> lstAccountSap = DataBase.query(accountSapQuery);
            try {
                if(lstAccount.size() > 0) {
                    Account objAccount = lstAccount[0];
                    MapOfResponseParameters.put('data', objAccount);
                } 
                else {
                    List<Lead> lstLead = DataBase.query(leadQuery);
                    Lead objLead = null;
                    if(lstLead.size() > 1) {
                        for (Lead objLeadRecord : lstLead) {
                            if(objLeadRecord.nm_ChooseaProgram__c == program && (String.isBlank(programType) || (objLeadRecord.Program_Type__c == programType))) {
                                objLead = objLeadRecord;
                            }
                        }
                        if(objLead == null) {
                            objLead = lstLead[0];
                        }
                    } else if(lstLead.size() > 0) {
                        objLead = lstLead[0];
                    } else {
                        objLead = new Lead();
                        objLead.Email = emailId;
                        objLead.MobilePhone = mobileNo;
                        objLead.nm_ChooseaProgram__c= program;
                        objLead.nm_SelectedProgram__c= programName;
                        objLead.FirstName = firstname;
                        objLead.LastName = '.';
                        objLead.nm_SelectedIC__c = city;
                        objLead.Program_Type__c = programType;
                        objLead.LeadSource='ChatBot';
                        objLead.Agency__c='ChatBot';
                        insert objLead;
                    }
                    MapOfResponseParameters.put('data', objLead);
                }
                MapOfResponseParameters.put('message','success');
                MapOfResponseParameters.put('errorCode','200');
            } catch (Exception e) {
                MapOfResponseParameters.put('message',e.getMessage());
                MapOfResponseParameters.put('errorCode','423');
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }
    
    public Blob getRecordBySapId(String jsonString){
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'SapId'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;
        
        String sapId = mapOfRequestParameters.containsKey('SapId')? String.valueOf(mapOfRequestParameters.get('SapId')):null;
        
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        
         InvalidRequest = InvalidRequest(mapOfAttributes);
        
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } 
         else {
               
             String SapIDQuery = getQueryAllFieldSql('Account','nm_StudentNo__c=:sapId',null); 
             String leadQuery = getQueryAllFieldSql('Lead','Student_Number_Lateral__c=:sapId',null);
             List<Account> lstAccount = DataBase.query(SapIDQuery);
               try {
                if(lstAccount.size() > 0) {
                    Account objAccount = lstAccount[0];
                    MapOfResponseParameters.put('data', objAccount);
                   } 
                else {
                    List<Lead> lstLead = DataBase.query(leadQuery);
                    Lead objLead = null;
                    if(lstLead.size() > 0) {
                        objLead = lstLead[0];
                    } 
                    MapOfResponseParameters.put('data', objLead);
                }
                MapOfResponseParameters.put('message','success');
                MapOfResponseParameters.put('errorCode','200');
            } catch (Exception e) {
                MapOfResponseParameters.put('message',e.getMessage());
                MapOfResponseParameters.put('errorCode','423');
            }        
            }
        
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }
    
     public Blob getDocuments(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters2 = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        // Set<String> setRequiredParam = new Set<String>{'AccountId','SapId'};
        //parameters can be AccountId or SapId 
        Set<String> setRequiredParam = new Set<String>{};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;
         
            String accId = mapOfRequestParameters.containsKey('AccountId')? String.valueOf(mapOfRequestParameters.get('AccountId')):null;
            String sapId = mapOfRequestParameters.containsKey('SapId')? String.valueOf(mapOfRequestParameters.get('SapId')):null;
         
         if(String.isNotBlank(accId))
         {
             setRequiredParam.add('AccountId') ;
         }
         else
         {
             setRequiredParam.add('SapId') ;   
         }
        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        
        InvalidRequest = InvalidRequest(mapOfAttributes);
        
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } 
         else {
            String DocumentQuery='';
            if(String.isNotBlank(accId))
            {
              DocumentQuery = getQueryAllFieldSql('nm_LinksForDocuments__c','nm_Account__c=:accId',null);
            }
            else
            {
               DocumentQuery = getQueryAllFieldSql('nm_LinksForDocuments__c','Student_Number__c=:sapId',null); 
            }
             List<nm_LinksForDocuments__c> lstDocument = DataBase.query(DocumentQuery);
               try {
                if(lstDocument.size() > 0) {
                    for (nm_LinksForDocuments__c objDocument:lstDocument)
                    {
                         mapOfRequestParameters2.put(objDocument.Name, objDocument);
                    }
                   MapOfResponseParameters.put('data', mapOfRequestParameters2);
                }
                    MapOfResponseParameters.put('message','success');
                    MapOfResponseParameters.put('errorCode','200');
                } catch (Exception e) {
                    MapOfResponseParameters.put('message',e.getMessage());
                    MapOfResponseParameters.put('errorCode','423');
                }            
            }
    // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;

 }
 // To check Dispatch order basedon Account ID
 public Blob getDispatchOrder (String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters2 = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        //Set<String> setRequiredParam = new Set<String>{'AccountId'};
        Set<String> setRequiredParam = new Set<String>{};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;
        
        String accId = mapOfRequestParameters.containsKey('AccountId')? String.valueOf(mapOfRequestParameters.get('AccountId')):null;
        String sapId = mapOfRequestParameters.containsKey('SapId')? String.valueOf(mapOfRequestParameters.get('SapId')):null;
         
         if(String.isNotBlank(accId))
         {
             setRequiredParam.add('AccountId') ;
         }
         else
         {
             setRequiredParam.add('SapId') ;   
         }
        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        
        InvalidRequest = InvalidRequest(mapOfAttributes);
        
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            
            String DocumentQuery='';
            if(String.isNotBlank(accId))
            {
                DocumentQuery = getQueryAllFieldSql('Dispatch_Order__c','To_Student__c=:accId and Status_Of_Dispatch__c !=\'Delivered\' and Status_Of_Dispatch__c!= \'Returned Back\' ',null);
           
            }
            else
            {
               DocumentQuery = getQueryAllFieldSql('Dispatch_Order__c','Student_Number__c=:sapId and Status_Of_Dispatch__c !=\'Delivered\' and Status_Of_Dispatch__c!= \'Returned Back\' ',null);
            }
            
            // String accId = String.valueOf(mapOfRequestParameters.get('AccountId'));
            //String DocumentQuery = getQueryAllFieldSql('Dispatch_Order__c','To_Student__c=:accId and Status_Of_Dispatch__c !=\'Delivered\' and Status_Of_Dispatch__c!= \'Returned Back\' ',null);
             List<Dispatch_Order__c> lstDispatchOrder = DataBase.query(DocumentQuery);
               try {
                if(lstDispatchOrder.size() > 0) {
                    for (Dispatch_Order__c objDispatchOrder:lstDispatchOrder)
                    {
                         mapOfRequestParameters2.put(objDispatchOrder.Name, objDispatchOrder);
                    }
                   MapOfResponseParameters.put('data', mapOfRequestParameters2);
                }
                    MapOfResponseParameters.put('message','success');
                    MapOfResponseParameters.put('errorCode','200');
                } catch (Exception e) {
                    MapOfResponseParameters.put('message',e.getMessage());
                    MapOfResponseParameters.put('errorCode','423');
                }            
            }
    // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;

 }
 //Get refund record 
 public Blob getRefund (String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters2 = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        //Set<String> setRequiredParam = new Set<String>{'AccountId'};
        Set<String> setRequiredParam = new Set<String>{};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;
     
       String accId = mapOfRequestParameters.containsKey('AccountId')? String.valueOf(mapOfRequestParameters.get('AccountId')):null;
       String sapId = mapOfRequestParameters.containsKey('SapId')? String.valueOf(mapOfRequestParameters.get('SapId')):null;
         
         if(String.isNotBlank(accId))
         {
             setRequiredParam.add('AccountId') ;
         }
         else
         {
             setRequiredParam.add('SapId') ;   
         }
        
        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        
        InvalidRequest = InvalidRequest(mapOfAttributes);
        
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            
            String RefundQuery='';
            if(String.isNotBlank(accId))
            {
              RefundQuery = getQueryAllFieldSql('nmRefund_Payment__c','Account__c=:accId',null);
            }
            else
            {
               RefundQuery = getQueryAllFieldSql('nmRefund_Payment__c','Student_Number__c=:sapId',null); 
            }
            
             //String accId = String.valueOf(mapOfRequestParameters.get('AccountId'));
            // String RefundQuery = getQueryAllFieldSql('nmRefund_Payment__c','Account__c=:accId',null);
             List<nmRefund_Payment__c> lstRefund = DataBase.query(RefundQuery);
               try {
                if(lstRefund.size() > 0) {
                      nmRefund_Payment__c objRefund = lstRefund[0];
                     MapOfResponseParameters.put('data', objRefund);
                }
                    MapOfResponseParameters.put('message','success');
                    MapOfResponseParameters.put('errorCode','200');
                } catch (Exception e) {
                    MapOfResponseParameters.put('message',e.getMessage());
                    MapOfResponseParameters.put('errorCode','423');
                }            
            }
    // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;

 }
 // Get Opportunity detail based on Account
 
 public Blob getLatestOpportunity (String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters2 = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        //Set<String> setRequiredParam = new Set<String>{'AccountId'};
        Set<String> setRequiredParam = new Set<String>{};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;
       String accId = mapOfRequestParameters.containsKey('AccountId')? String.valueOf(mapOfRequestParameters.get('AccountId')):null;
       String sapId = mapOfRequestParameters.containsKey('SapId')? String.valueOf(mapOfRequestParameters.get('SapId')):null;
         
         if(String.isNotBlank(accId))
         {
             setRequiredParam.add('AccountId') ;
         }
         else
         {
             setRequiredParam.add('SapId') ;   
         }
     
        
        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        
        InvalidRequest = InvalidRequest(mapOfAttributes);
        
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            
            String OpportunityQuery='';
            if(String.isNotBlank(accId))
            {
              OpportunityQuery = getQueryAllFieldSql('Opportunity','AccountId=:accId and StageName !=\'Closed Won\' and StageName!= \'Closed Won - Re-registration Pending\' ORDER BY Sem__c asc',null);
            
            }
            else
            {
               OpportunityQuery = getQueryAllFieldSql('Opportunity','Student_Number__c=:sapId and StageName !=\'Closed Won\' and StageName!= \'Closed Won - Re-registration Pending\' ORDER BY Sem__c asc',null);
            
            }
            
             //String accId = String.valueOf(mapOfRequestParameters.get('AccountId'));
             //String OpportunityQuery = getQueryAllFieldSql('Opportunity','AccountId=:accId and StageName !=\'Closed Won\' and StageName!= \'Closed Won - Re-registration Pending\' ORDER BY Sem__c asc',null);
             List<Opportunity> lstOpportunity = DataBase.query(OpportunityQuery);
               try {
                if(lstOpportunity.size() > 0) {
                      Opportunity objOpportunity = lstOpportunity[0];
                     MapOfResponseParameters.put('data', objOpportunity);
                }
                    MapOfResponseParameters.put('message','success');
                    MapOfResponseParameters.put('errorCode','200');
                } catch (Exception e) {
                    MapOfResponseParameters.put('message',e.getMessage());
                    MapOfResponseParameters.put('errorCode','423');
                }            
            }
    // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;

 }
        public Blob CreateTask(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'whoId','Subject','ReminderDateTime'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            //DateTime dt = DateTime.newInstance(2019, 02, 10, 12, 0, 0);
            String whoId = String.valueOf(mapOfRequestParameters.get('whoId'));
            String ReminderDateTime = String.valueOf(mapOfRequestParameters.get('ReminderDateTime'));
            system.debug('ReminderDateTime-->'+ReminderDateTime);
            DateTime testDate = DateTime.parse(ReminderDateTime );
         //String convertedDate = testDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
          //  System.debug('xxx'+convertedDate);
            
            String Subject = String.valueOf(mapOfRequestParameters.get('Subject'));
                
            String accountQuery = getQueryAllFieldSql('Account','Id=:whoId',null);
            String leadQuery = getQueryAllFieldSql('Lead','Id=:whoId AND IsConverted=false',null);
            List<Account> lstAccount = DataBase.query(accountQuery);
            Task objTask = new Task ();
            try {
                if(lstAccount.size() > 0) {
                    Account objAccount = lstAccount[0];
                    Contact objContact = [SELECT id, AccountId FROM Contact WHERE AccountId  = :whoId LIMIT 1 ];
                    
                       objTask.OwnerId = objAccount.OwnerId;
                       objTask.Subject = Subject;
                       objTask.WhatId = objAccount.id;
                       objTask.whoId = objContact.id;
                       objTask.ReminderDateTime = testDate;
                       objTask.IsReminderSet =true;
                       objTask.Status ='New';
                        insert objTask;                     
                   
                } else {
                    List<Lead> lstLead = DataBase.query(leadQuery);
                    Lead objLead = null;
                    if(lstLead.size() > 0) {
                        objLead = lstLead[0];
                                      
                       objTask.OwnerId = objLead.OwnerId;
                       objTask.Subject = Subject;
                       objTask.whoId = objLead.id;
                       objTask.IsReminderSet =true;
                       objTask.ReminderDateTime = testDate ;
                       objTask.Status ='New';
                        insert objTask;
                        system.debug(objTask);
                    }
                   
                }
                 MapOfResponseParameters.put('data', objTask);
                MapOfResponseParameters.put('message','success');
                MapOfResponseParameters.put('errorCode','200');
            } catch (Exception e) {
                MapOfResponseParameters.put('message',e.getMessage());
                MapOfResponseParameters.put('errorCode','423');
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }
      public Blob CreateCase(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
       // Set<String> setRequiredParam = new Set<String>{'AccountId','Subject','Description','Email','Name','Phone'};
       Set<String> setRequiredParam = new Set<String>{'Subject','Description'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            //DateTime dt = DateTime.newInstance(2019, 02, 10, 12, 0, 0);
            String AccountId = mapOfRequestParameters.containsKey('AccountId')? String.valueOf(mapOfRequestParameters.get('AccountId')):null;
            String Origin = 'Chatbot';
            String Subject = String.valueOf(mapOfRequestParameters.get('Subject'));
            String Description = String.valueOf(mapOfRequestParameters.get('Description'));
            String SuppliedEmail =  mapOfRequestParameters.containsKey('Email')? String.valueOf(mapOfRequestParameters.get('Email')):'';
            String SuppliedName =  mapOfRequestParameters.containsKey('Name')? String.valueOf(mapOfRequestParameters.get('Name')):'';
            String SuppliedPhone =  mapOfRequestParameters.containsKey('Phone')? String.valueOf(mapOfRequestParameters.get('Phone')):'';

            String accountQuery = getQueryAllFieldSql('Account','Id=:AccountId',null);          
            List<Account> lstAccount = DataBase.query(accountQuery);
           Case objCase = new Case ();
            try {
                if(lstAccount.size() > 0) {
                    Account objAccount = lstAccount[0];
                    Contact objContact = [SELECT id, AccountId FROM Contact WHERE AccountId  = :AccountId LIMIT 1 ];
                    
                       objCase.Description = Description;
                       objCase.Subject = Subject;
                       objCase.AccountId = objAccount.id;
                       objCase.ContactId = objContact.id;
                       objCase.Origin ='Chatbot';                    
                       objCase.Status ='New';
                      /* objCase.SuppliedEmail = SuppliedEmail;
                       objCase.SuppliedName = SuppliedName;
                       objCase.SuppliedPhone = SuppliedPhone;*/
                        insert objCase;                     
                   
                } else {
                       objCase.Description = Description;
                       objCase.Subject = Subject;                       
                       objCase.Origin ='Chatbot';                    
                       objCase.Status ='New';
                       objCase.SuppliedEmail = SuppliedEmail;
                       objCase.SuppliedName = SuppliedName;
                       objCase.SuppliedPhone = SuppliedPhone;
                        insert objCase; 
                    }
                   
                
                 MapOfResponseParameters.put('data', objCase);
                MapOfResponseParameters.put('message','success');
                MapOfResponseParameters.put('errorCode','200');
            } catch (Exception e) {
                MapOfResponseParameters.put('message',e.getMessage());
                MapOfResponseParameters.put('errorCode','423');
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }
    public Boolean InvalidRequest(Map<String,Object> mapOfAttributes) {
        Boolean InvalidRequest = false;
        Map<String,String> mapOfRequiredValue = new Map<String,String>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)mapOfAttributes.get('mapOfRequestParameters');
        Set<String> setPresentParam = mapOfRequestParameters.keySet();
        Set<String> setRequiredParam = (Set<String>)mapOfAttributes.get('setRequiredParam');

        if(mapOfAttributes.containsKey('mapOfRequiredValue')) {
            mapOfRequiredValue = (Map<String,String>)mapOfAttributes.get('mapOfRequiredValue');
        }

        if(setPresentParam.containsAll(setRequiredParam)) {
            for (String fieldName : setRequiredParam) {
                if(mapOfRequestParameters.get(fieldName) == null || mapOfRequestParameters.get(fieldName) == '') {
                    InvalidRequest = true;
                }else if(mapOfRequiredValue.containsKey(fieldName)) {
                    if(mapOfRequiredValue.get(fieldName) != String.valueOf(mapOfRequestParameters.get(fieldName)) ) {
                        InvalidRequest = true;
                    }
                }
            }
        }else{
            InvalidRequest = true;
        }
        return InvalidRequest;
    }

    public String getQueryAllFieldSql(String ObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'SELECT '+String.join( fieldNames, ',') +' FROM '+ ObjectAPIName +' WHERE '+conditionString;
        return query;
    }


    public Blob getRecordFromEmailAndMobile(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'email','mobile'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);
        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        } else {
            String emailId = String.valueOf(mapOfRequestParameters.get('email'));
            String mobileNo = String.valueOf(mapOfRequestParameters.get('mobile'));
            
            String accountQuery = getQueryAllFieldSql('Account','(PersonEmail=:emailId OR PersonMobilePhone=:mobileNo) AND Active_account__c=true',null);
            String leadQuery = getQueryAllFieldSql('Lead','(Email=:emailId OR MobilePhone=:mobileNo) AND IsConverted=false',null);
            List<Account> lstAccount = DataBase.query(accountQuery);
            List<Lead> lstLead = DataBase.query(leadQuery);
            try {
                if(lstAccount.size() > 0) {
                    Account objAccount = lstAccount[0];
                    MapOfResponseParameters.put('data', objAccount);
                } else {
                    //Lead objLead = null;
                    if(lstLead.size() > 0) {

                        // for (Lead objLeadRecord : lstLead) {
                        //     if(objLeadRecord.nm_ChooseaProgram__c == program && (String.isBlank(programType) || (objLeadRecord.Program_Type__c == programType))) {
                        //         objLead = objLeadRecord;
                        //     }
                        // }
                        // if(objLead == null) {
                        //     objLead = lstLead[0];
                        // }
                        Lead objLead = lstLead[0];
                        MapOfResponseParameters.put('data', objLead);
                    } 
                   // MapOfResponseParameters.put('data', objLead);
                }
                MapOfResponseParameters.put('message','success');
                MapOfResponseParameters.put('errorCode','200');
            } catch (Exception e) {
                MapOfResponseParameters.put('message',e.getMessage());
                MapOfResponseParameters.put('errorCode','423');
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }

    public void getICNameFromCity() {
        this.AssignToLCFromList.put('Indore', 'Indore');
        this.AssignToLCFromList.put('Kolkata', 'Kolkata');
        this.AssignToLCFromList.put('Delhi', 'Delhi');
        this.AssignToLCFromList.put('Bangalore', 'Bangalore');
        this.AssignToLCFromList.put('Hyderabad', 'Hyderabad');
        this.AssignToLCFromList.put('Ahmedabad', 'Ahmedabad');
        this.AssignToLCFromList.put('Pune', 'Pune');
        this.AssignToLCFromList.put('Chandigarh', 'Chandigarh');
        this.AssignToLCFromList.put('Mumbai', 'Mumbai');
        this.AssignToLCFromList.put('Navi Mumbai', 'Mumbai');
        this.AssignToLCFromList.put('Aurangabad', 'Pune');
        this.AssignToLCFromList.put('Gandhinagar', 'Ahmedabad');
        this.AssignToLCFromList.put('Goa', 'Pune');
        this.AssignToLCFromList.put('Nagpur', 'Pune');
        this.AssignToLCFromList.put('Rajkot', 'Ahmedabad');
        this.AssignToLCFromList.put('Surat', 'Ahmedabad');
        this.AssignToLCFromList.put('Vadodara', 'Ahmedabad');
        this.AssignToLCFromList.put('Bhopal', 'Indore');
        this.AssignToLCFromList.put('Gwalior', 'Ahmedabad');
        this.AssignToLCFromList.put('Jabalpur', 'Ahmedabad');
        this.AssignToLCFromList.put('Raipur', 'Ahmedabad');
        this.AssignToLCFromList.put('Bilaspur', 'Ahmedabad');
        this.AssignToLCFromList.put('Bhubaneswar', 'Kolkata');
        this.AssignToLCFromList.put('Patna', 'Kolkata');
        this.AssignToLCFromList.put('Chennai', 'Bangalore');
        this.AssignToLCFromList.put('Thiruvananthapuram', 'Bangalore');
        this.AssignToLCFromList.put('Kochi', 'Bangalore');
        this.AssignToLCFromList.put('Bikaner', 'Chandigarh');
        this.AssignToLCFromList.put('Faridabad', 'Delhi');
        this.AssignToLCFromList.put('Gurgaon', 'Delhi');
        this.AssignToLCFromList.put('Jaipur', 'Chandigarh');
        this.AssignToLCFromList.put('Kanpur', 'Delhi');
        this.AssignToLCFromList.put('Lucknow', 'Delhi');
        this.AssignToLCFromList.put('Ludhiana', 'Chandigarh');
        this.AssignToLCFromList.put('Mohali', 'Chandigarh');
        this.AssignToLCFromList.put('Noida', 'Delhi');
        this.AssignToLCFromList.put('Panchkula', 'Chandigarh');
        this.AssignToLCFromList.put('Sahibabad', 'Delhi');
        this.AssignToLCFromList.put('Ghaziabad', 'Delhi');
        this.AssignToLCFromList.put('Saharanpur', 'Delhi');
    }


}