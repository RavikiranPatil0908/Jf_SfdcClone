public class MakeBookOrKitOrderController 
{
    
    public Map<String,integer> mapOfBookNameAndQuantityRequired{get;set;}
    public String selectedLaunchYearPG{get;set;}
    public integer numberOfRegistrationsPG{get;set;}
    
    public String selectedLaunchYearDiploma{get;set;}
    public integer numberOfRegistrationsDiploma{get;set;}
    public String selectedLaunchYearCCC{get;set;}
    public integer numberOfRegistrationsCCC{get;set;}
    public list<nm_Program__c> programList;
    public String selectedLaunchYearCDM{get;set;}
    public integer numberOfRegistrationsCDM{get;set;}
    public list<String> getlistOfSkuBooks{get;set;}
    public String selectedLaunchYearCBM{get;set;}
    public integer numberOfRegistrationsCBM{get;set;}
    public list<SelectOption> getLaunchYear{get;set;}
    public list<SelectOption> getSemester{get;set;}
    public String showDetailSection {get;set;}
    public integer booksToBeOrdered;
    public integer orderToBePlaced {get;set;}
    public set<String> pgProgNameSet = new set<String>();
    public set<String> dipProgNameSet = new set<String>();
    public map<String,integer> mapOfPgSem2 = new map<String,integer>();
    public map<String,integer> mapOfPgSem3 = new map<String,integer>();
    public map<String,integer> mapOfPgSem4 = new map<String,integer>();
    public map<String,integer> mapOfDiplomaSem2 = new map<String,integer>();
    public map<String,integer> mapOfPgSem2Book = new map<String,integer>();
    public map<String,integer> mapOfPgSem3Book = new map<String,integer>();
    public map<String,integer> mapOfPgSem4Book = new map<String,integer>();
    public map<String,integer> mapOfDiplomaSem2Book = new map<String,integer>();
    public integer numberOfRegistrationsForPgSem2;
    public list<Opportunity> listOfOpportunityForReRegisterForPGSem2 = new list<Opportunity>();
    public map<String,integer> finalMapOfStudentsAndAllPrograms = new map<String,integer>();
    public map<String,integer> finalMapOfBookNameAndExistingQty = new map<String,integer>();
    public MakeBookOrKitOrderController()
    {
        showDetailSection ='';
        listOfOpportunityForReRegisterForPGSem2 = [select name, nm_InformationCenters__c,nm_Program__r.name from Opportunity 
                                                   where StageName='Closed Won' and nm_Semester__c ='1' 
                                                   and nm_Program__r.name like 'PGD%' and name like '%2016'];
        numberOfRegistrationsForPgSem2 = listOfOpportunityForReRegisterForPGSem2.size();
        getlistOfSkuBooks = new list<String>();
        list<nm_Program__c> programListPG = [select id,name from nm_Program__c where nm_Type__c ='Post Graduate Diploma Programs'];
        for(nm_Program__c p:programListPG)
        {
             
             pgProgNameSet.add(p.name);
        }
        mapOfPgSem2 = mapProgramNameNumberOfStudents(pgProgNameSet,'2');
        mapOfPgSem3 = mapProgramNameNumberOfStudents(pgProgNameSet,'3');
        mapOfPgSem4 = mapProgramNameNumberOfStudents(pgProgNameSet,'4');
        mapOfPgSem3.putAll(mapOfPgSem2);
        mapOfPgSem4.putAll(mapOfPgSem3);
        mapOfPgSem2Book = mapOfLooseBookNameAndQuantity(pgProgNameSet,'2');
        mapOfPgSem3Book = mapOfLooseBookNameAndQuantity(pgProgNameSet,'3');
        mapOfPgSem4Book = mapOfLooseBookNameAndQuantity(pgProgNameSet,'4');
        mapOfPgSem3Book.putAll(mapOfPgSem2Book);
        mapOfPgSem4Book.putAll(mapOfPgSem3Book);
      
        list<nm_Program__c> programListDiploma = [select id,name from nm_Program__c where nm_Type__c ='Diploma Programs'];
        for(nm_Program__c d:programListDiploma)
        {
             dipProgNameSet.add(d.name);
        }
        mapOfDiplomaSem2 = mapProgramNameNumberOfStudents(dipProgNameSet,'2'); 
        mapOfPgSem4.putAll(mapOfDiplomaSem2);
        mapOfDiplomaSem2Book =mapOfLooseBookNameAndQuantity(dipProgNameSet,'2');
        mapOfPgSem4Book.putAll(mapOfDiplomaSem2Book);
        finalMapOfStudentsAndAllPrograms = mapOfPgSem4;
        finalMapOfBookNameAndExistingQty = mapOfPgSem4Book;
        System.debug('PreDefined Maps--->'+finalMapOfStudentsAndAllPrograms+' 2)'+finalMapOfBookNameAndExistingQty);
    }
    public PageReference ViewDetail()
    {  
       
       map<String,list<String>> emptyListBookName = new map<String,list<String>>();
       integer numberOfStudents;
       integer quantityOfBooks = 0;
       String keyForSearch = '';
       mapOfBookNameAndQuantityRequired = new map<String,integer>();
       
       if(selectedLaunchYearPG!='' && numberOfRegistrationsPG!=0)
       {
          System.debug('selectedLaunchYearPG--->'+selectedLaunchYearPG);
          //For Semester 1 Stock since it is common for Diploma And Post-Graduate//
          integer OrderToBePlacedForPGSem1 = integer.valueOf(numberOfRegistrationsPG - looseBookStockForCommonSku('Post Graduate Diploma Program','1',selectedLaunchYearPG));
          for(Stock_Keeping_Units__c sku :[select name,Semester__c from Stock_Keeping_Units__c where Type_Of_SKU__c='Book' and Semester__c ='1' and Program_Type__c like 'Post Graduate Diploma%'])
          {
              getlistOfSkuBooks.add(sku.name);
              mapOfBookNameAndQuantityRequired.put(sku.name,OrderToBePlacedForPGSem1);
          }
          //end for PG SEM1 Stock//
          //For Semester 2 Pg Since it is common//
          integer OrderToBePlacedForPGSem2 = integer.valueOf(numberOfRegistrationsForPgSem2 - looseBookStockForCommonSku('Post Graduate Diploma Program','2',selectedLaunchYearPG));
          map<String,list<String>> mapOfSem2BookAndKey = mapOfProgramKeyAndListOfBookName('PGDM-S2');
          System.debug('Map Returned--->'+mapOfProgramKeyAndListOfBookName('PGDM-S2')+'mapOfSem2BookAndKey---->'+mapOfSem2BookAndKey.get('PGDM-S2'));
          for(String nameOfSem2Book : mapOfSem2BookAndKey.get('PGDM-S2'))
          {
              getlistOfSkuBooks.add(nameOfSem2Book);
              mapOfBookNameAndQuantityRequired.put(nameOfSem2Book,OrderToBePlacedForPGSem2);
          }
          //Ends//
          System.debug('Map of Sem 1 books-->'+mapOfBookNameAndQuantityRequired);
          for(nm_Program__c prog : [select name from nm_Program__c where nm_Type__c!='Certificate Programs' and nm_Type__c!='Diploma Programs' and name!='BAJAJ-DBM'])
          {
              for(integer i=3;i<=4;i++)
              {
                  numberOfStudents = finalMapOfStudentsAndAllPrograms.get(prog.name+'-S'+string.valueOf(i));
                  System.debug('Key for mapOfProgramKeyAndListOfBookName--->'+prog.name+'-S'+string.valueOf(i));
                  emptyListBookName = mapOfProgramKeyAndListOfBookName(prog.name+'-S'+string.valueOf(i));
                  if(emptyListBookName!=null && numberOfStudents!=null)
                  {
                      System.debug('emptyListBookName-->'+emptyListBookName);
                     for(String bookName:emptyListBookName.get(prog.name+'-S'+string.valueOf(i)))
                      {
                          System.debug('Book Name-->'+bookName+'Student Count--->'+numberOfStudents);
                          System.debug(finalMapOfBookNameAndExistingQty.get(bookName));
                          if(finalMapOfBookNameAndExistingQty.get(bookName)!=null)
                          {
                              getlistOfSkuBooks.add(bookName);
                              mapOfBookNameAndQuantityRequired.put(bookName,(integer.valueOf((0.85*numberOfStudents))-finalMapOfBookNameAndExistingQty.get(bookName)));
                          }
                      }
                      System.debug('Key Value-->'+prog.name+'-'+string.valueOf(i)+'Number--->'+numberOfStudents);
                  }            
              }
          }
          System.debug('Values in the Map--->'+mapOfBookNameAndQuantityRequired.values());
          System.debug('Map Of Book Name And Order Quantity-->'+mapOfBookNameAndQuantityRequired.keySet());
          for(String g:getlistOfSkuBooks)
          {
              System.debug('g--->'+g);
          }
       }
       
       showDetailSection ='Yes';
       return null;
    }
    public list<SelectOption> getLaunchYear()
    {
        list<SelectOption> listOption = new list<SelectOption>();
        listOption.add(new SelectOption('','--None--'));
        listOption.add(new SelectOption('JUL2009','JUL2009'));
        listOption.add(new SelectOption('JUL2013','JUL2013'));
        listOption.add(new SelectOption('JUL2014','JUL2014'));
        return listOption;
    }
 
     public integer looseBookStockForCommonSku(String programType,String semesterForSearch,String launchYear)
    {
           integer totalLooseBooks =0;
           System.debug('Incoming Parameters for looseBookStockForCommonSku--->'+programType+'  '+launchYear+'  '+semesterForSearch);
           String programTypeForQuery = '%'+programType+'%';
            list<Stock__c> overAllCount = [select id,Quantity__c,Stock_Keeping_Unit__r.name from Stock__c
                                          where Stock_Keeping_Unit__r.Program_Type__c like:programTypeForQuery
                                          and Stock_Keeping_Unit__r.Semester__c=:semesterForSearch and 
                                          Stock_Keeping_Unit__r.Launch_Year__c=:launchYear];
                                          
           System.debug('Size of Stock--->'+overAllCount.size());                            
           for(Stock__c stock : overAllCount)
           {
               System.debug('Quantity Values-->'+stock.Quantity__c);
               totalLooseBooks = totalLooseBooks + integer.valueOf(stock.Quantity__c);  
           }
           System.debug('Total Loose Books--->'+totalLooseBooks);
           return totalLooseBooks;
    }

    public map<String,integer> mapOfLooseBookNameAndQuantity(set<String> programName,String semesterForSearch)
    {
           integer totalBooks = 0;
           list<SKU_Link__c> skuLink = new list<SKU_Link__c>();
           integer looseBooks=0;
           integer kitValue =0;
           set<id> setOfBooksAssociatedWithTheKit = new set<id>();
           map<String,Integer> mapOfBookNameAndCount = new map<String,Integer>();
           
           for(String progName : programName)
           {
                   String programNameForQuery = '%'+progName+'%';
                   skuLink = [select Stock_Keeping_Unit_Book__c from SKU_Link__c where
                                       Stock_Keeping_Unit_Kits__r.name like:programNameForQuery
                                       and Stock_Keeping_Unit_Kits__r.Semester__c=:semesterForSearch];
                   for(SKU_Link__c sku : skuLink)
                   {
                       setOfBooksAssociatedWithTheKit.add(sku.Stock_Keeping_Unit_Book__c);
                   }
           }
           
          mapOfBookNameAndCount = mapOfBookCountBasedOnSetOfBookIdHelper(setOfBooksAssociatedWithTheKit);
          return mapOfBookNameAndCount;
     }
    public map<String,integer> mapOfBookCountBasedOnSetOfBookIdHelper(set<id> bookId)
    {
          map<String,integer> mapOfBookAndCountAsPerId = new map<String,integer>();
          list<Stock__c> listOfLooseBooksBasedOnName = [select id,Quantity__c,Stock_Keeping_Unit__r.name 
                                                        from Stock__c where 
                                                        Stock_Keeping_Unit__c in : bookId];
         
           for(Stock__c book:listOfLooseBooksBasedOnName)
           {
              mapOfBookAndCountAsPerId.put(book.Stock_Keeping_Unit__r.name,integer.valueOf(book.Quantity__c)); 
           }
          return mapOfBookAndCountAsPerId; 
    }
    public map<String,integer> mapProgramNameNumberOfStudents(set<string> listOfBookName,String semester)
    {
        list<Opportunity> oppBasedOnProgram = new list<Opportunity>();
        map<String,integer> mapToBeSend = new map<String,integer>();
        String keyForMap;
        integer countOfStudentsProgramWise =0;
        for(String pname: listOfBookName)
        {
               keyForMap = '';
               oppBasedOnProgram = [select name, nm_InformationCenters__c,nm_Program__r.name from Opportunity 
                                               where StageName='Closed Won' and nm_Semester__c =:semester and nm_Program__r.name=:pname]; 
               keyForMap = pname+'-S'+semester;                               
               mapToBeSend.put(keyForMap,oppBasedOnProgram.size());
        }
                                               
        return mapToBeSend;
    }
    public map<String,list<String>> mapOfProgramKeyAndListOfBookName(String stringKey)
    {
       String key = '%'+stringKey+'%';
          map<String,list<String>> mapToReturn = new map<String,list<String>>();
        list<SKU_Link__c> sku  = [select Stock_Keeping_Unit_Book__r.name from SKU_Link__c where Stock_Keeping_Unit_Kits__r.name like:key];
        list<String> lstOfNames = new list<String>();
        for(SKU_Link__c s:sku)
        {
            lstOfNames.add(s.Stock_Keeping_Unit_Book__r.name);
        }
        mapToReturn.put(stringKey,lstOfNames);
        System.debug('Map of key and list of book names--->'+mapToReturn);
        return mapToReturn;
    }

   
}