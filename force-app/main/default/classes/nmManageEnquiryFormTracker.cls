@istest
public class nmManageEnquiryFormTracker {
    public static testmethod void test1()
    {
        nmManageEnquiryForm objnm=new nmManageEnquiryForm();
        objnm.FillFieldsList();
        apexPages.currentPage().getParameters().put('rownumber','2');
        objnm.GetFieldDetails();
        objnm.UpdateFieldProperties();
        objnm.RemoveField();
        
    }

}