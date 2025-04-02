public class MergeCourierShipmentController{

    private final ApexPages.StandardSetController cntr;
 //   private ApexPages.StandardSetController standardController;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public List<Dispatch_Order__c> lstOfSelectedRecords{get;set;}
    public list<string> lstDispatchRecord{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public List<String> lstOfUrls{get;set;}
    public String returnUrl{get;set;}

    public string getStep(){
        return currentStep;
    }
   
   /* public MergeCourierShipmentController(ApexPages.StandardSetController controller){
        lstOfSelectedRecords=new  List<Dispatch_Order__c>();
        currentStep='1';
        returnUrl = null;
        lstOfUrls = new List<String>();
        controller.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)controller;

        // checking records for Mass Merge Airwaybill
        list<string> lstDispatchRecord=new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        string RecordId='';
        for(SObject s:lstSObject){
            RecordId=s.id;
            lstDispatchRecord.add(RecordId);
            system.debug('lstDispatchRecord'+lstDispatchRecord);
            System.debug('Id Of Selected Record--->'+RecordId);
        }
        
        if(lstDispatchRecord.size()>0){
            lstOfSelectedRecords=cntr.getSelected();
            System.debug('lstOfSelectedRecords----->'+lstOfSelectedRecords.size());
        }
        // else{
        //     string msg='Please Select all those record whose Fedex Shipment not created';
        //     currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
        //     ApexPages.addMessage(currentMsg);
        // }

        fromPage=cntr.cancel();
        if(sizeOfRecordsToUpdate<1){
            string msg='No record was selected on the list view.  Please click Previous button and select records.';
            currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
        }else{
            string msg='Number of records selected for update: '+sizeOfRecordsToUpdate;
            currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,msg);
        }
        ApexPages.addMessage(currentMsg);
    }*/
     public MergeCourierShipmentController(ApexPages.StandardSetController cntr){
      this.cntr= cntr;
        Set<Id> disId = new Set<Id> ();
        lstOfSelectedRecords=new  List<Dispatch_Order__c>();
        currentStep='1';
        returnUrl = null;
        lstOfUrls = new List<String>();
        cntr.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)cntr;

        // checking records for Mass Merge Airwaybill
        list<string> lstDispatchRecord=new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        string RecordId='';
     /*   for(SObject s:lstSObject){
            RecordId=s.id;
            lstDispatchRecord.add(RecordId);
            system.debug('lstDispatchRecord'+lstDispatchRecord);
            System.debug('Id Of Selected Record--->'+RecordId);
        }
        
        if(lstDispatchRecord.size()>0){
            lstOfSelectedRecords=cntr.getSelected();
            System.debug('lstOfSelectedRecords----->'+lstOfSelectedRecords.size());
        }*/
       
        for (Dispatch_Order__c objdis : (List<Dispatch_Order__c>)cntr.getSelected()){ 
            disId.add(objdis.Id);
        }
        lstOfSelectedRecords = [SELECT id,name,Name_Of_Other_Courier_Service__c,CreatedDate,
                                           Semester__c,From_Address__c,Address__c,Tracking_Number__c,Program__c
                                           FROM Dispatch_Order__c WHERE ID IN: disId order by Tracking_Number__c asc];
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

    // First Page------------------------> 
    public PageReference step1(){
        currentStep='1';
        return ApexPages.currentPage();
    }

    //Second Page-----------------------------//
    public PageReference step2(){
        // system.debug('lstOfRecords in step2'+lstOfRecords);
        // if(lstOfRecords.size()<sizeOfRecordsToUpdate)return cancel();
        // currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Number of Per Document Page to be merged is :'+numberOfPage);
        // ApexPages.addMessage(currentMsg);
        currentStep='2';
        return ApexPages.currentPage();
    }

    // Third Page------------------------------//
    public PageReference step3(){
        // data type validation
        if(currentMsg!=null){
            ApexPages.Message msg=new  ApexPages.Message(ApexPages.severity.INFO,'');
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        string msg='Please review your selections before confirm: <br></br>';
        msg=msg+'<br><b>Records Selected:</b>    '+sizeOfRecordsToUpdate+'</br>';
        currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,msg);
        ApexPages.addMessage(currentMsg);
        currentStep='3';
        return ApexPages.currentPage();
    }

    // Four Page---------------------------------//
    public PageReference step4(){
        if(lstOfSelectedRecords.size()>0)
        {
            GenerateIndiaPostPdf();
        }else
        {
           return null;
        }
         return null;
    }

    public PageReference GenerateIndiaPostPdf(){
              
          if(lstOfSelectedRecords.size()>0)
        {
            PageReference report = Page.DispatchCourier;
            report.setRedirect(false);
            return report;    
        }
        else{
            return null;
        }     
    }
}