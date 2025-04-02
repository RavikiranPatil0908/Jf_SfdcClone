global class AdditionalBookController {
    
    webService static boolean addBook(String stockJunctionId,String bookNames){
        boolean bkstk=false;
          try {
        system.debug('stockJunctionId==>'+stockJunctionId);
        system.debug('bookNames==>'+bookNames);
        List<string> bookNamelist=bookNames.split(';');
        system.debug('bookNamelist==>'+bookNamelist);
        
        String currentSessionLabel = System.Label.Current_Session;
        String currentYearLabel = System.Label.Current_Year;
        system.debug('currentSessionLabel==>'+currentSessionLabel);
        system.debug('currentYearLabel==>'+currentYearLabel);
        Map<String,id> mapBookNameVsBookStock=new Map<String,id>();
    Map<String,id> mapBookNameVsCM=new Map<String,id>();
        Map<String,Decimal> mapStockVsQty=new Map<String,Decimal>();
        List<Book_Stock__c> addBookStockList=new List<Book_Stock__c>();
        List<Book_Stock__c> updateBookStockList=new List<Book_Stock__c>();
        List<String> FinalBookStockList=new List<String>();
        List<Book_SKU_Junction__c> addBookSkuJunstionList=new List<Book_SKU_Junction__c>();
    StockSkuJunction__c sj=[select id,Stock__c,Stock_Keeping_Units__c,SJ_Unique_Key__c,Requirment__c from StockSkuJunction__c where id=:stockJunctionId];
//List<Book_Stock__c> bookList =[select id,Course_Master__r.Name,Stock__c,Book_Code__c,Publisher__c,Session__c,Year__c, SJ_Unique_Key__c from Book_Stock__c where Course_Master__r.Name in :bookNamelist and SJ_Unique_Key__c=null];
List<nm_CourseMaster__c> bookList =[select id,Name from nm_CourseMaster__c where Name in :bookNamelist];
     system.debug('bookList==>'+bookList);
     system.debug('bookList.size==>'+bookList.size());
  
        
//List<Book_Stock__c> chkBookExistList =[select id, SJ_Unique_Key__c from Order_Book__c where SJ_Unique_Key__c=:sj.SJ_Unique_Key__c /*and Session__c=:currentSessionLabel and Year__c=:currentYearLabel*/];
        //system.debug('chkBookExistList==>'+chkBookExistList);
        //system.debug('chkBookExistList.size==>'+chkBookExistList.size());
        
       /* List<String> bookNamechk=new List<String>();
        for(Book_Stock__c b:chkBookExistList)
        {
          bookNamechk.add(b.Course_Master__r.Name); 
        }
        system.debug('bookNamechk==>'+bookNamechk);*/
        for(nm_CourseMaster__c b:bookList)
        {
          //if(!bookNamechk.contains(b.Name))
             FinalBookStockList.add(b.Name); 
        }
        system.debug('FinalBookStockList==>'+FinalBookStockList);
        system.debug('FinalBookStockList size==>'+FinalBookStockList.size());
        for(nm_CourseMaster__c ob:bookList)
       {
           system.debug('ob==>'+ob);
           system.debug('ob.Course_Master__r.Name==>'+ob.Name);
         mapBookNameVsCM.put(ob.Name,ob.Id);
       }
        system.debug('mapBookNameVsBookStock==>'+mapBookNameVsBookStock);
    
    List<Stock__c> BookStockList=[select id,Course_Master__c,Course_Master_Name__c,Quantity__c from  Stock__c where Book_Name__c in:FinalBookStockList and Centers__r.Name='Repro - Bhiwandi'];
    for(Stock__c b:BookStockList)
    {
    mapBookNameVsBookStock.put(b.Course_Master_Name__c,b.id);
        mapStockVsQty.put(b.Course_Master_Name__c,b.Quantity__c);
        }
        List<Book_Stock__c> existingBookStock=[select id,Course_Master__r.Name,Stock__c,Book_Code__c,Final_Requirment__c,Publisher__c,Session__c,Year__c, SJ_Unique_Key__c from Book_Stock__c where Course_Master__r.Name in :bookNamelist and SJ_Unique_Key__c=:sj.SJ_Unique_Key__c and Type__c='Additional'];
        Map<string,Book_Stock__c> mapExistingBookStock =new Map<String,Book_Stock__c>();
       for(Book_Stock__c s:existingBookStock)
       {
          if(FinalBookStockList.contains(s.Course_Master__r.Name))
          mapExistingBookStock.put(s.Course_Master__r.Name,s); 
       }
        for(String s:FinalBookStockList)
        {
       
            if(mapExistingBookStock.containsKey(s))
            {
             Book_Stock__c ob=new Book_Stock__c();
             ob.id=mapExistingBookStock.get(s).id;
             ob.Final_Requirment__c=mapExistingBookStock.get(s).Final_Requirment__c+sj.Requirment__c;           
                updateBookStockList.add(ob);
                
            Book_SKU_Junction__c bk=new Book_SKU_Junction__c();
            bk.Book_Stock_Junction__c=mapExistingBookStock.get(s).id;
            bk.StockSkuJunction__c=sj.Id;
            addBookSkuJunstionList.add(bk);
               
            }
            else{
            system.debug('s==>'+s);
            Book_Stock__c ob=new Book_Stock__c();
            ob.Course_Master__c=mapBookNameVsCM.get(s);
            ob.Stock__c=mapBookNameVsBookStock.get(s);
            ob.Book_Stock__c=mapStockVsQty.get(s);
            ob.Session__c=currentSessionLabel;
            ob.Year__c=currentYearLabel;
            ob.SJ_Unique_Key__c=sj.SJ_Unique_Key__c;
            ob.Type__c='Additional';
            ob.Final_Requirment__c=sj.Requirment__c; 
             addBookStockList.add(ob);
            }
           
        }
        system.debug('addBookStockList==>'+addBookStockList);
        If(addBookStockList.size()>0)
        {
        insert addBookStockList;
        }
        
        If(updateBookStockList.size()>0)
        {
            update updateBookStockList;
        }
        for(Book_Stock__c ob:addBookStockList)
        {
            Book_SKU_Junction__c bk=new Book_SKU_Junction__c();
            bk.Book_Stock_Junction__c=ob.id;
            bk.StockSkuJunction__c=sj.Id;
            addBookSkuJunstionList.add(bk);
        }
        system.debug('addBookSkuJunstionList==>'+addBookSkuJunstionList);
        if(addBookSkuJunstionList.size()>0)
       {
            insert addBookSkuJunstionList;
             bkstk=true;
        }
        
        } catch (Exception error) {
            System.debug('Error ==>'+ error.getMessage());
            System.debug('Error Line No :==>'+ error.getLineNumber());
             bkstk=false;
        }
        system.debug('bkstk==>'+bkstk);
       return bkstk;
    }
    
}