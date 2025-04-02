/**
 * @File Name          : LiquiLoansRequestWrapper.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/3/2019   shubhranshu     Initial Version
**/
public class LiquiLoansRequestWrapper {

        public String loan_id;
        public String amount;
        public String disbursed_amount;
        public String product_amount;
        public String status;
        public String urn;
        public String utr;
        public String timestamp;
        public String checksum;
        public String tenure;
        public String emi;
        public String roi;
        
        public static LiquiLoansRequestWrapper parse(String json) {
            return (LiquiLoansRequestWrapper) System.JSON.deserialize(json, LiquiLoansRequestWrapper.class);
        }
    }