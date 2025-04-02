/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-23-2022
 * @last modified by  : @BK
**/
public class MassFedexShipmentController{
    private final ApexPages.StandardSetController cntr;
    public Map<string,Dispatch_Order__c> mapOfSuccessDispatchCreate;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public string oppid;
    public List<Dispatch_Order__c> lstOfSelectedRecords{get;set;}
    public string fieldName{get;set;}
    public Dispatch_Order__c objdord{get;set;}
    public string valueToUpdate{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public list<Dispatch_Order__c> lstOfRecords{get;set;}

    public string getStep(){
        return currentStep;
    }
    public MassFedexShipmentController(ApexPages.StandardSetController controller){
        lstOfSelectedRecords=new  List<Dispatch_Order__c>();
        lstOfRecords=new  list<Dispatch_Order__c>();
        currentStep='1';
        fieldName='';
        oppid='';
        mapOfSuccessDispatchCreate=new  Map<string,Dispatch_Order__c>();
        objdord=new  Dispatch_Order__c();
        controller.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)controller;
// checking records for Mass Update Fedex order
        list<string> lstDispatchRecord=new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        string RecordId='';
        for(SObject s:lstSObject){
            RecordId=s.id;
            lstDispatchRecord.add(RecordId);
            system.debug('lstDispatchRecord'+lstDispatchRecord);
        }
        System.debug('Id Of Selected Record--->'+RecordId);
        lstOfRecords=[SELECT id,DispatchID__c,Name,Opportunity__c,Order_Type__c,Status_Of_Dispatch__c,Fed_Ex_Shipment_Created__c,Program__c,Name_Of_Other_Courier_Service__c,Semester__c,Learning_Center_Name__c,Student_Number__c FROM Dispatch_Order__c WHERE Status_Of_Dispatch__c='Study Kit assigned' AND Fed_Ex_Shipment_Created__c=false AND AirWay_Bill_Image__c=''];
        system.debug('lstOfRecords '+lstOfRecords.size());
        if(lstOfRecords.size()>0){
            lstOfSelectedRecords=cntr.getSelected();
            System.debug('lstOfRecords----->'+lstOfRecords.size());
        }
        else{
            string msg='Please Select all those record whose Fedex Shipment not created';
            currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
            ApexPages.addMessage(currentMsg);
        }
        fromPage=cntr.cancel();
        if(sizeOfRecordsToUpdate<1){
            string msg='No record was selected on the list view.  Please click Previous button and select records for mass update.';
            currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
        }
        else{
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
        system.debug('lstOfRecords in step2'+lstOfRecords);
        if(lstOfRecords.size()<sizeOfRecordsToUpdate)return cancel();
        currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Field type of selected field:'+fieldName);
        ApexPages.addMessage(currentMsg);
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
        if(lstOfSelectedRecords.size()>0)CreateShipmentFedex(lstOfSelectedRecords);
        ApexPages.addMessage(currentMsg);
        currentStep='4';
        return ApexPages.currentPage();
    }
    public ApexPages.Message CreateShipmentFedex(List<Dispatch_Order__c> lstOfSelectedRecords){
        string result;
        System.Debug('lstOfSelectedRecords--->'+lstOfSelectedRecords);
        for(Dispatch_Order__c objorder:lstOfSelectedRecords){
            result=FedexShipmentGetMethod(objorder.id);
            if(result=='success'){
                currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Inserted '+objorder.Name+' Records');
                ApexPages.addMessage(currentMsg);
            }
            else{
                currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Failed '+objorder.Name+'  Records');
                ApexPages.addMessage(currentMsg);
            }
        }
        return currentMsg;
    }

    public string FedexShipmentGetMethod(string DispatchID){
        // Instantiate a new http object
        Http h=new  Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        string url = Label.Student_Zone_Base_Url + 'salesforce/orderCreationFromDelhivery?id='+DispatchID;
        HttpRequest req=new  HttpRequest();
        req.setEndpoint(url);
        req.setTimeout(2*60*1000);
        req.setMethod('GET');
        // Send the request, and return a response
        if(!System.Test.isRunningTest()){
            HttpResponse res=h.send(req);
            return res.getBody();
        }
        else return 'Error';
    }



}