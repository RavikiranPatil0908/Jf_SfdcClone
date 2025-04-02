public class UpdateBookStockQtyController{

    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public List<Book_Stock__c> lstOfSelectedRecords{get;set;}
    public list<string> lstDispatchRecord{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public List<String> lstOfUrls{get;set;}
    public String returnUrl{get;set;}

    public string getStep(){
        return currentStep;
    }
   
     public UpdateBookStockQtyController(ApexPages.StandardSetController cntr){
        this.cntr= cntr;
        Set<Id> disId = new Set<Id> ();
        lstOfSelectedRecords=new  List<Book_Stock__c>();
        currentStep='1';
        returnUrl = null;
        lstOfUrls = new List<String>();
        cntr.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)cntr;

        list<string> lstDispatchRecord=new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        string RecordId='';
     
        for (Book_Stock__c objdis : (List<Book_Stock__c>)cntr.getSelected()){ 
            disId.add(objdis.Id);
        }
        lstOfSelectedRecords = [SELECT id,Name,Book_Code__c , ISBN__c , Session__c , Year__c ,Stock__c , Book_Stock__c, Stock__r.Quantity__c, 
                                           Order__c,Additional__c,Final_Order__c ,Amount__c
                                           FROM Book_Stock__c WHERE ID IN: disId order by Order__c asc];
                                           lstSObject.sort();

        fromPage=cntr.cancel();
        if(sizeOfRecordsToUpdate<1){
            string msg='No record was selected on the list view.  Please click Previous button and select records.';
            currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
        }else{
            string msg='Number of records selected for update: '+sizeOfRecordsToUpdate;
            currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,msg);
        }
        ApexPages.addMessage(currentMsg);
    }

    public PageReference cancel(){
        return fromPage;
    }

    public PageReference step1(){
        currentStep='1';
        return ApexPages.currentPage();
    }

    public PageReference step2(){
        currentStep='2';
        return ApexPages.currentPage();
    }

    public PageReference updateBookStock(){
        if(lstOfSelectedRecords != null && !lstOfSelectedRecords.isEmpty()){
            List<Id> stockIds = new List<Id>();
            for(Book_Stock__c record : lstOfSelectedRecords){
                stockIds.add(record.Stock__c);
            }
            List<Stock__c> stocksToUpdate = [SELECT Id, Quantity__c FROM Stock__c WHERE Id IN :stockIds];
            for(Stock__c stock : stocksToUpdate){
                for(Book_Stock__c record : lstOfSelectedRecords){
                    if(record.Stock__c == stock.Id){
                        record.Book_Stock__c = stock.Quantity__c;
                    }
                }
            }
            update lstOfSelectedRecords;
            currentStep = '2'; // Set current step to show the success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Records updated successfully.'));
            return null;
        }
        return null;
    }
    
}