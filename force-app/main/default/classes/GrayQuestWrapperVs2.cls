public class GrayQuestWrapperVs2 {

    public Integer customer_id;
    public class Student_details {
        public String student_id;
        public String student_first_name;
     
    }

    public class Fee_details {
        public Integer loan_amount;
    }

    public Student_details student_details;
    public Fee_details fee_details;
    public Customer_details customer_details;
    public Notes notes;
   

    public class Customer_details {
        public String customer_first_name;      
    }
      public class Notes {
        public String location;
        public String program;
        public String programcode;
        public String aep;
        public String tenure ;
        public String interestRate ;       
        public Decimal subventionvalue;
       

    }
    
    public static GrayQuestWrapperVs2 parse(String json) {
        return (GrayQuestWrapperVs2) System.JSON.deserialize(json, GrayQuestWrapperVs2.class);
    }
}