public without sharing class DispatchTrackingOrder {
    public String DispatchOrderId { get; set; }
    public Dispatch_Order__c objDispatch { get; set; }
    public String trackingNo { get; set; }
    public String orderReceived {get;set;}
    public Boolean IsResponseSend {get;set;}
    public DispatchTrackingOrder() {
        IsResponseSend = false;
        orderReceived = '';
        trackingNo = '';
        DispatchOrderId = '';
         objDispatch = new Dispatch_Order__c ();
        if(ApexPages.currentPage().getParameters().get('trackingNo') != Null && ApexPages.currentPage().getParameters().get('trackingNo') != '') {
            trackingNo = ApexPages.currentPage().getParameters().get('trackingNo');     
        }
        if(ApexPages.currentPage().getParameters().get('isOrderReceived') != Null && ApexPages.currentPage().getParameters().get('isOrderReceived') != '')
        {
            orderReceived = ApexPages.currentPage().getParameters().get('isOrderReceived');     
        }
        if(String.isNotBlank(trackingNo) && String.isNotBlank(orderReceived)) {
            List<Dispatch_Order__c> lstDispatch =[SELECT Id, Tracking_Number__c, Name_Of_Other_Courier_Service__c FROM Dispatch_Order__c WHERE Tracking_Number__c = :trackingNo LIMIT 1];
            if(lstDispatch.size() > 0) {
                objDispatch = lstDispatch[0];
                DispatchOrderId = objDispatch.Id;
                objDispatch.id=null;
                // updateStudentResponse();
            }
        }
    }

    public void updateStudentResponse() {
        if(String.isNotBlank(DispatchOrderId) ) {
            system.debug('objDispatch --> ' + objDispatch);
            IsResponseSend = true;
            Dispatch_Order__c obDispatch = objDispatch.clone();
    
            obDispatch.Id = DispatchOrderId;
            obDispatch.Dispatch_Recieved__c = orderReceived;
            if(orderReceived.equalsIgnoreCase('Yes')) {
                if(objDispatch.Name_Of_Other_Courier_Service__c == 'Indian Post') {
                    obDispatch.Status_Of_Dispatch__c = 'Delivered';
                }
                obDispatch.Student_Response_Yes__c =Datetime.now();
            } else {
                obDispatch.Student_Response_No__c =Datetime.now();
            }
            update obDispatch;
        }
    }

    // public void SelectedNo() {
    //     IsResponseSend = true;
    //       if(objDispatch != null)
    //     {
    //     Dispatch_Order__c obDispatch = objDispatch.clone();
    //     obDispatch.Id = DispatchOrderId;
    //     obDispatch.Dispatch_Recieved__c = 'No';
    //     obDispatch.Student_Response_No__c =Datetime.now();
    //     update obDispatch;
    //     }
    // }

    // public void SelectedYes() {
    //     IsResponseSend = true;
    //     Dispatch_Order__c obDispatch = new Dispatch_Order__c();
    //     obDispatch.Id = DispatchOrderId;
    //     obDispatch.Dispatch_Recieved__c = 'Yes';
    //     obDispatch.Student_Response_Yes__c = Datetime.now();
    //     if(objDispatch!= null && objDispatch.Name_Of_Other_Courier_Service__c == 'Indian Post') {
    //         obDispatch.Status_Of_Dispatch__c = 'Delivered';
    //     }
        
    //     update obDispatch;
    // }
}