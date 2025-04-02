public class nmEnquiryForm 
{

    public nmEnquiryForm(ApexPages.StandardController controller) {

    }

    public date dtToday{get;set;}
    
    public nmEnquiryForm()
    {
        dtToday = date.Today();
    }
}