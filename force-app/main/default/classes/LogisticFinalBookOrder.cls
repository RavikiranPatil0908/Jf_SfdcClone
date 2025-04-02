/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 06-17-2024
 * @last modified by  : @vickysahu
**/
global class LogisticFinalBookOrder {
    
    WebService static void updatefinalBooksOrder (String recordId, Integer newOrder, String oldOrder, String oldRemarks, String newRemark, String editor) {
        List<User> lstUser = [SELECT Id,Name FROM User WHERE Id=:editor LIMIT 1];
        String name = lstUser.size() > 0 ? lstUser[0].Name : '';
        Datetime currentDt = System.now();
        String dt = currentDt.format('dd-MM-yyyy hh:mm a');
        String comment = oldRemarks + '\n' + '\n' + 'Old Final Order: ' + oldOrder + '\n' +  'New Final Order: ' + newOrder + '\n' + 'Editor: ' + name  + '\n' + 'Date: ' + dt + '\n' + 'Remarks: ' + newRemark;
        Order_Book__c objOrder = new Order_Book__c();
        objOrder.Id = recordId;
        objOrder.Remarks__c = comment;
        objOrder.Final_Order__c = newOrder;
        update objOrder;
    }
}