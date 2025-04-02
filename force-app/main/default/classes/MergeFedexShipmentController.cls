/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-03-2022
 * @last modified by  : @BK
**/
public class MergeFedexShipmentController{
    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public List<Dispatch_Order__c> lstOfSelectedRecords{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public String numberOfPage{get;set;}
    public List<String> lstOfUrls{get;set;}
    public String returnUrl{get;set;}

    public string getStep(){
        return currentStep;
    }
    public MergeFedexShipmentController(ApexPages.StandardSetController controller){
        lstOfSelectedRecords = new List<Dispatch_Order__c>();
        currentStep='1';
        returnUrl = null;
        lstOfUrls = new List<String>();
        controller.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)controller;

        // checking records for Mass Merge Fedex Airwaybill
        list<string> lstDispatchRecord = new list<string>();
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
            lstOfSelectedRecords = [SELECT Id,Name,Airway_Bill_Image__c FROM Dispatch_Order__c WHERE Id IN :lstDispatchRecord ORDER BY Student_Number__c ASC];
            System.debug('lstOfSelectedRecords----->'+lstOfSelectedRecords.size());
        }

        fromPage=cntr.cancel();
        if(sizeOfRecordsToUpdate<1){
            string msg='No record was selected on the list view.  Please click Previous button and select records for mass update.';
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
        if(lstOfSelectedRecords.size()>0)MergeShipmentFedex(lstOfSelectedRecords);
        ApexPages.addMessage(currentMsg);
        currentStep='4';
        return ApexPages.currentPage();
    }

    public ApexPages.Message MergeShipmentFedex(List<Dispatch_Order__c> lstOfSelectedRecords){
        string result;
        System.Debug('lstOfSelectedRecords--->'+lstOfSelectedRecords);
        for(Dispatch_Order__c objorder:lstOfSelectedRecords){
            if(objorder.Airway_Bill_Image__c != ''){
                lstOfUrls.add(objorder.Airway_Bill_Image__c);
                currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Added '+objorder.Name+' Records, Url:'+objorder.Airway_Bill_Image__c);
                ApexPages.addMessage(currentMsg);
            }else{
                currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Empty Url found for '+objorder.Name+'  Records');
                ApexPages.addMessage(currentMsg);
            }
        }
        result=FedexShipmentPostMethod();
        return currentMsg;
    }

    public string FedexShipmentPostMethod(){
        String urls = generateUrlArray();
        String jsonBody = '{ "url":'+urls+', "pageNo":"'+numberOfPage+'" }';
        System.debug('jsonBody-->');
        System.debug(jsonBody);
        // Instantiate a new http object
        Http h=new  Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        string url=System.Label.dispatchOrderDocumnetMerge;
        HttpRequest req=new  HttpRequest();
        req.setEndpoint(url);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        // Send the request, and return a response
        if(!System.Test.isRunningTest()){
            HttpResponse res=h.send(req);
            String result = res.getBody();
            System.debug('result-->'+result);
            Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
            if(!mapOfResponseParameters.isEmpty()){
                returnUrl = String.valueOf(mapOfResponseParameters.get('url')); 
                System.debug('returnUrl-->'+returnUrl);
                return 'Success';
            }else{
                return 'Error';
            }
            
        }
        else return 'Error';
    }

    public string generateUrlArray(){
        Integer size = lstOfUrls.size();
        String urls = '[';
        for(Integer i = 0; i < size; i++){
            urls += '"' +lstOfUrls.get(i)+ '"';
            if(i != (size - 1)){
                urls += ',';
            }
        }
        urls += ']';
        return urls;
    }



}