@IsTest
public class GrayQuestWrapperVs2Tracker{
    
    static testMethod void testParse() {
        String json = '{'+     
        '\"customer_id\": 20107,'+      
        '\"student_details\": {'+
        '\"student_id\": \"89561\",'+
        '\"student_first_name\": \"Nikki\"'+   
        '},'+
        '\"fee_details\": {'+
        '\"loan_amount\": \"72000\"'+
        '},'+
        '\"customer_details\": {'+
        '\"customer_first_name\": \"Sam\"'+
        '},'+      
        '\"notes\": {'+
        '\"location\": \"Mumbai\"'+
        '}'+
        '}';
       
        GrayQuestWrapperVs2 obj2 = GrayQuestWrapperVs2.parse(json);
        
         System.assert(obj2 != null);
    }
}