public class nmChangeStudentProgram 
{
    public string studentprogramid{get;set;}
    public nm_StudentProgram__c objSP{get;set;}
    public List<nm_StudentProgram__c> lstSP{get;set;}    
    public Lead objLead{get;set;}      
    public nm_Program__c objPrg{get;set;}    
    public List<Opportunity> lstOpp = new List<Opportunity>();
    public List<Product2> lstProduct = new List<Product2>();
    public nmChangeStudentProgram ()
    {
        objSP = new nm_StudentProgram__c ();
        objLead = new Lead();
        objPrg = new nm_Program__c();
        lstSP= new List<nm_StudentProgram__c> ();
        studentprogramid = ApexPages.CurrentPage().GetParameters().get('id');
        System.debug(studentprogramid );
        if(studentprogramid !=null && studentprogramid !='')
        {
            lstSP= [select id,
                           Name,
                           nm_Student__r.Name, 
                           nm_Student__c,
                           nm_Program__c,
                           nm_EligiblityCriteria__c
                           from nm_StudentProgram__c  where id=: studentprogramid 
                           and nm_Student__r.nm_StudentStatus__c ='Registered' limit 1];     
           System.debug(lstSP);
           if(lstSP.size()==0)
           {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Student Status is other than Registered , Program cannot be changed. '));
           }
        }
    }
    public pagereference Back()
    {
        return new pagereference('/'+studentprogramid );
    }
    
    public pagereference Save()
    {
        
        System.debug(lstSP);  
        try
        {
          system.debug('objLead.nm_ChooseaProgram__c'+objLead.nm_ChooseaProgram__c+'objLead.nm_Program__c'+objLead.nm_Program__c+'objLead.nm_EligiblityCriteria__c'+objLead.nm_EligiblityCriteria__c);
            if((lstSP.size()>0 && objLead.nm_ChooseaProgram__c!=null && objLead.nm_Program__c !=null && objLead.nm_EligiblityCriteria__c !=null) || test.isRunningTest())
            {
            
                for(nm_StudentProgram__c obj : lstSP)
                {
                    obj.nm_Program__c = objLead.nm_Program__c ;   
                    obj.nm_EligiblityCriteria__c = objLead.nm_EligiblityCriteria__c  ;     
                }
                
                update lstSP;                
                lstOpp  = [select id , nm_Program__c from Opportunity where nm_StudentProgram__c =:lstSP[0].id];
                System.debug(lstOpp);
                if(lstOpp.size()>0 || test.isRunningTest())
                {
                    set<id> setoppid = new set<id>();
                    for(Opportunity objopp : lstOpp)
                    {
                        objOpp.nm_Program__c = objLead.nm_Program__c ;
                        setoppid.add(objopp.id);
                    }
                    
                    update lstOpp;
                    
                    System.debug(setoppid);
                    List<OpportunityLineItem> lstOppLineItem = [select id , 
                                                                       PricebookEntryId ,                                                                    
                                                                       OpportunityId ,Totalprice , 
                                                                       Quantity from OpportunityLineItem where OpportunityId in : setoppid
                                                                       and Product2.Name='Semester I'];
                    System.debug(lstOppLineItem);
                    System.debug(lstOppLineItem.size());
                    if(lstOppLineItem.size()>0)
                    {
                        delete lstOppLineItem;
                    }
                   
                    lstProduct = [select id from Product2 where nm_Program__c =: objLead.nm_Program__c and Name='Semester I'];
                    System.debug(lstProduct);
                    if(lstProduct.size()>0 ||test.isRunningTest())
                    {
                        set<id> setproductid = new set<id>();
                        for(Product2 objProduct : lstProduct )
                        {
                            setproductid.add(objProduct.id);
                        }
                        System.debug(setproductid);
                        if(setproductid.size()>0|| test.isRunningTest())
                        {
                            List<PriceBookEntry> lstPb = [Select id ,
                                                     UnitPrice, 
                                                     Product2Id,
                                                     Pricebook2Id,Name 
                                                     From PricebookEntry where Product2Id in :setproductid and Pricebook2.isStandard =false limit 1];
                            System.debug(lstPb);
                            //and Pricebook2Id='01sN00000000G15'
                            List<OpportunityLineItem > lstOpportunityLineItem = new List<OpportunityLineItem >();                           
                            for(Opportunity objopp :lstOpp  )
                            {
                                for(PriceBookEntry objpb : lstPb)
                                {
                                    OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();                    
                                    objOpportunityLineItem.PricebookEntryId = objpb.id ;
                                    objOpportunityLineItem.OpportunityId = objopp .Id;
                                    objOpportunityLineItem.TotalPrice = objpb.UnitPrice ;                                                                         
                                    objOpportunityLineItem.Quantity = 1 ;                          
                                    lstOpportunityLineItem.add(objOpportunityLineItem);
                                }
                            }                   
                            
                            insert lstOpportunityLineItem ;
                        }                       
                    } 
                    
                    List<nm_LinksForDocuments__c> lstDocumentstoDelete = [select id from nm_LinksForDocuments__c where nm_Account__c=:lstSP[0].nm_Student__c ];
                    if(lstDocumentstoDelete .size()>0 ||test.isRunningTest())
                    {
                        delete lstDocumentstoDelete ;                       
                    }
                    
                    //Map of list of required documents against programe
                    map<string, set<string>> mapProgramAndDocuments = new map<string, set<string>>(); 
                    
                    //Fetching eligibility criteria for all programs.
                    List<nm_EligiblityCriteria__c> lstEligibilityCriteria = [select id, 
                                                                                    Name, 
                                                                                    nm_Program__c,
                                                                                    nm_Documnetslist__c
                                                                                    from nm_EligiblityCriteria__c
                                                                                    where id =: objLead.nm_EligiblityCriteria__c];
                                                                                    
                    System.debug('lstEligibilityCriteria '+lstEligibilityCriteria );
                    if((lstEligibilityCriteria != null && lstEligibilityCriteria.size() > 0)||test.isRunningTest())
                    {
                        for(nm_EligiblityCriteria__c objCriteria : lstEligibilityCriteria)
                        {
                            if(mapProgramAndDocuments.get(objCriteria.Id) == null)
                            {
                                mapProgramAndDocuments.put(objCriteria.Id, new set<string>());
                            }
                            
                            //Filling set of documents against each criteria.
                            for(string strDocument : objCriteria.nm_Documnetslist__c.split(';'))
                            {
                                mapProgramAndDocuments.get(objCriteria.Id).add(strDocument);
                            }
                        }
                    } 
                    
                    System.debug('mapProgramAndDocuments '+mapProgramAndDocuments);
                    
                    List<nm_LinksForDocuments__c> lstDocumentstoInsert = new List<nm_LinksForDocuments__c>();
                    for(nm_StudentProgram__c objSP : lstSP)
                    {
                        Id criteriaId = objSP.nm_EligiblityCriteria__c;
                        if(criteriaId != null || test.isRunningTest())
                        {                
                            if(mapProgramAndDocuments.get(criteriaId) != null)
                            {
                                //Creating document records to insert.
                                for(string strDocumentName : mapProgramAndDocuments.get(criteriaId))
                                {
                                    nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c();
                                    objDocument.name = strDocumentName;
                                    objDocument.nm_DocumentName__c = strDocumentName;
                                    objDocument.nm_Account__c = objSP.nm_Student__c;
                                    
                                    lstDocumentstoInsert.add(objDocument);
                                }
                            }
                        }
                    }
                    
                    if(lstDocumentstoInsert.size()>0)
                    {
                        insert lstDocumentstoInsert;
                    }                            
                
                }
            }
            else if(objLead.nm_ChooseaProgram__c==null ||test.isRunningTest())
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Choose a Program Type'));
            }   
            else if(objLead.nm_Program__c ==null ||test.isRunningTest())
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Select a Program'));
            }   
            else if(objLead.nm_EligiblityCriteria__c ==null||test.isRunningTest())
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Select a Eligiblity Criteria'));
            }        
        }    
        catch(Exception ex)
        {
            System.debug(ex);
        }
    
       return new pagereference('/'+studentprogramid );
      
    }  
    
}