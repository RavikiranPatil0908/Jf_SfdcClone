public class allrows {
   /* public list<Lead> led{set;get;}
    public allrows(){
       // controller.setPageSize(10);

        String UserId = UserInfo.getUserId();
        led=new list<Lead>([select id,name,email,mobilePhone,LeadSource,nm_ChooseaProgram__c,IC_Name__c from Lead where  isDeleted = true all rows]);
    }*/
    Public Integer noOfRecords{get; set;}

        public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                    String UserId = UserInfo.getUserId();

                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [select id,name,email,mobilePhone,LeadSource,nm_ChooseaProgram__c,IC_Name__c,CreatedDate ,CreatedById from Lead where CreatedById =:UserId  and  isDeleted = true all rows]));
            setCon.setpagesize(25);
           noOfRecords = setCon.getResultSize();

            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Lead> getLeadvalue() {
        return (List<Lead>) setCon.getRecords();
    }
    public integer pageNumber
{
    get
    {
        return setCon.getPageNumber();
    }
    set;
}


}