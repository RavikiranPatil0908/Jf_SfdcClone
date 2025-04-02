@isTest(SeeAllData=false)
public class AdditionalBookControllerTracker {
    
     @testSetup
    public static void setUpData(){ 
       nm_Centers__c objCen =  new nm_Centers__c();
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        List<String> lstBooks = new List<String>{'Commercial Banking System & Role of RBI','Business Communication','Corporate Finance; Cost & Management Accounting','Marketing of Financial Services','Retail Banking','Taxation - Direct and Indirect'};

              List<nm_CourseMaster__c> lstCourseMaster = new List<nm_CourseMaster__c>();
        List<Stock__c> lstSK = new List<Stock__c>();
            
            
            
        objCen.Nm_Active__c = true;
        objCen.Name='Repro - Bhiwandi';
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = '002';
        objCen.nm_CenterCity__c = 'test';
        objCen.nm_City__c = 'test';
        objCen.nm_StateProvince__c = 'test';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objcen.Allow_Degree__c = true;
        objcen.Allow_MBA_WX__c = true;
        insert objCen;
        
         for (String bookName : lstBooks) {
            nm_CourseMaster__c obj = new nm_CourseMaster__c(
                Name = bookName,
                nm_CourseID__c = 'Test_'+bookName,
                Book_Code__c = 'Test_'+bookName,
                Number_Of_pages__c = 318,
                Publisher__c = 'Wiley'
            );
            lstCourseMaster.add(obj);
        }
        insert lstCourseMaster;
        
        for (nm_CourseMaster__c obj : lstCourseMaster) {
            Stock__c sk = new Stock__c();
            sk.Quantity__c = 10;
            sk.Stock_Quantity_history__c = '';
            sk.Course_Master__c=obj.id;
            sk.Centers__c=objCen.id;
            lstSK.add(sk);
        }

            
        
        Stock_Keeping_Units__c  stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'Jul2019';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Book';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.CM_Books__c='Business Communication';
        stockUnit.Semester__c='3';
        
        insert stockUnit;
        
        Stock__c st = new Stock__c();
        st.Quantity__c = 10;
        st.Stock_Quantity_history__c = '';
        st.Stock_Keeping_Unit__c=stockUnit.id;
        st.Centers__c=objcen.id;
        insert st;
        
        nmGenericTracker.CreateCalender();
        
      StockSkuJunction__c sj=new StockSkuJunction__c();
        sj.Stock__c=st.id;
        sj.Stock_Keeping_Units__c=stockUnit.Id;
        sj.Session__c='January';
        sj.Year__c='2024';
        sj.SJ_Unique_Key__c='Addsj';
        insert sj;
        
        
          Book_Stock__c bSTK = new Book_Stock__c();
                bSTK.Course_Master__c = lstCourseMaster[0].Id;
                bSTK.Stock__c = st.Id;
                bSTK.Book_Stock__c = 44;
                // bSTK.Final_Requirment__c=CmVsFinalReq.get(cm.Name);
                bSTK.Session__c = 'January';
                bSTK.Year__c = '2024';
               // bSTK.SJ_Unique_Key__c='Addsj1';
        insert bSTK;
        
    }
    
     @isTest 
    static void unitTest1(){ 
        StockSkuJunction__c s=[select id from StockSkuJunction__c limit 1];
        AdditionalBookController ob=new AdditionalBookController();
        AdditionalBookController.addBook(s.Id,'Commercial Banking System & Role of RBI');
    }

}