public class nmPaymentDocUpload {

    
    public string paymentID{get;set;}
    
    public nmPaymentDocUpload ()
    {
        paymentID= ApexPages.currentPage().getParameters().get('id');
        
    }
}