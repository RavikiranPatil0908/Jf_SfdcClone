public class AirWayBill implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
            public Set<String> lstFailedRecords = new Set<String>();
            public Integer successCount = 0;
            public Integer failedCount = 0;
            public Integer totalCount = 0;

            public AirWayBill (){
                 
            }

            public void execute(SchedulableContext sc) {
                AirWayBill b = new AirWayBill();
                Database.executebatch(b, 50);
            }
            
           public Database.QueryLocator start(Database.BatchableContext bc) {
               
               String query = 'SELECT id,Generate_AirwayBill__c,Airway_Bill_Image__c FROM Dispatch_Order__c WHERE Generate_AirwayBill__c =true and Airway_Bill_Image__c =\'\'  Order by CreatedDate DESC LIMIT 50';
                                 
                return Database.getQueryLocator(query);
           }
             public void execute(Database.BatchableContext bc, List<sObject> scope) {
            
               if(scope.size() > 0) {
                   
                    for(SObject sc : scope)
                    {
                        Dispatch_Order__c objDispatch = (Dispatch_Order__c)sc;
                        String response = FedExWebService.createShipment(objDispatch.id);
                       System.debug('response--->'+response);
                    }
               }
          }
          
        public void finish(Database.BatchableContext bc) {
            
            /*if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
                sendErrorMail();
            }

            system.debug('Finished ===> ');
*/
        }
       
     
   
 

}