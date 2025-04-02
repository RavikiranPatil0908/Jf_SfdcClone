/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 27-04-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class BatchClassForPreOrderStockTracker {

    @testSetup
    public static void setUpData(){ 
        nm_Centers__c objCen =  new nm_Centers__c();
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
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

        List<String> lstBooks = new List<String>{'Commercial Banking System & Role of RBI','Corporate Finance; Cost & Management Accounting','Marketing of Financial Services','Retail Banking','Taxation - Direct and Indirect'};
        List<nm_CourseMaster__c> lstCourseMaster = new List<nm_CourseMaster__c>();
        List<Stock__c> lstSK = new List<Stock__c>();


        for (String bookName : lstBooks) {
            nm_CourseMaster__c obj = new nm_CourseMaster__c(
                Name = bookName.toLowerCase(),
                nm_CourseID__c = 'Test_'+bookName,
                Book_Code__c = 'Test_'+bookName,
                Number_Of_pages__c = 318,
                Publisher__c = 'Wiley'
                // Final_Order__c = 100
            );
            lstCourseMaster.add(obj);
        }
        insert lstCourseMaster;
        
        for (nm_CourseMaster__c obj : lstCourseMaster) {
            Stock__c sk = new Stock__c();
            sk.Quantity__c = 10;
            sk.Stock_Quantity_history__c = '';
            sk.Course_Master__c=obj.id;
            sk.Centers__c=objcen.id;
            sk.IsActive__c = true;
            lstSK.add(sk);
        }


        Stock_Keeping_Units__c  stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'Jul2019';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        stockUnit.CM_Books__c = String.join(lstBooks,';');
        insert stockUnit;

        
        Stock__c st = new Stock__c();
        st.Quantity__c = 10;
        st.Stock_Quantity_history__c = '';
        st.Stock_Keeping_Unit__c=stockUnit.id;
        st.Centers__c=objcen.id;
        st.IsActive__c = true;
        lstSK.add(st);

        insert lstSK;
        
        nmGenericTracker.CreateCalender();

        Book_Stock__c objBS = new Book_Stock__c(
            Course_Master__c = lstCourseMaster[0].id,
            Stock__c = lstSK[0].Id,
            Book_Stock__c = 20,
            Session__c = System.Label.Current_Session,
            Year__c = System.Label.Current_Year
        );

        insert objBS;
        
        // StockSkuJunction__c sj=new StockSkuJunction__c();
        // sj.Stock__c=st.id;
        // sj.Stock_Keeping_Units__c=stockUnit.Id;
        // sj.Session__c='July';
        // sj.Year__c='2023';
        // insert sj;
    }

    @isTest 
    static void unitTest1() {
        Test.startTest();
            BatchClassForPreOrderStock batchClass = new BatchClassForPreOrderStock();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }
}