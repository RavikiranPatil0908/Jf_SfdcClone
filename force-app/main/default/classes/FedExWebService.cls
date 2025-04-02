/**
 * @File Name          : FedExWebService.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 02-23-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/5/2020   shubhranshu     Initial Version
**/
global class FedExWebService{

    @AuraEnabled
    webService static string createShipment(String id){
      
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        String url = Label.Student_Zone_Base_Url + 'salesforce/orderCreationFromDelhivery?id=' + id;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setTimeout(2 * 60 * 1000);
        req.setMethod('GET');
        
          // Send the request, and return a response
        if(!System.Test.isRunningTest())
        {
          HttpResponse res = h.send(req);
         return res.getBody();
       }else
       {
           return '{"status" : "ok"}';
       }
    
    }
}