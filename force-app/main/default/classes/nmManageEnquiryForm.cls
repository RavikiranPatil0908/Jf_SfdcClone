public class nmManageEnquiryForm 
{
    public list<wraperFieldSet> lstSelectedFields{get;set;}
    public wraperFieldSet objFieldProperties{get;set;}
    
    public nmManageEnquiryForm()
    {
        lstSelectedFields = new List<wraperFieldSet>();
        objFieldProperties = new wraperFieldSet();
        FillFieldsList();
    }
    
    public void FillFieldsList()
    {
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Lead.fields.getMap();
        
        for(string fName : m.keyset())
        {
            Schema.SObjectField sfield = m.get(fName); 
            schema.describefieldresult dfield = sfield.getDescribe();
            
            wraperFieldSet objFieldSet = new wraperFieldSet();
            objFieldSet.strLabel = dfield.getLabel();
            objFieldSet.strApiName = fName;
            objFieldSet.strType = 'Field';
            objFieldSet.strSizeClass = 'onecolumnrow';
            
            lstSelectedFields.add(objFieldSet);
        }
    }
    
    public void GetFieldDetails()
    {
        string rowNumber = apexPages.currentPage().getParameters().get('rownumber');
        objFieldProperties = new wraperFieldSet();
        
        if(rowNumber != null)
        {
            integer rowno = integer.valueOf(rowNumber);
            objFieldProperties.strLabel = lstSelectedFields[rowno].strLabel;
            objFieldProperties.strApiName = lstSelectedFields[rowno].strApiName;
            objFieldProperties.strType = lstSelectedFields[rowno].strType;
            objFieldProperties.strSizeClass = lstSelectedFields[rowno].strSizeClass;
            objFieldProperties.rowNumber = rowno;
        }
    }
    
    public void UpdateFieldProperties()
    {
        if(objFieldProperties.rowNumber != null)
        {
            integer rowno = objFieldProperties.rowNumber;
            lstSelectedFields[rowno].strLabel = objFieldProperties.strLabel;
            lstSelectedFields[rowno].strApiName = objFieldProperties.strApiName;
            lstSelectedFields[rowno].strType = objFieldProperties.strType;
            lstSelectedFields[rowno].strSizeClass = objFieldProperties.strSizeClass;
        }
    }
    
    public void RemoveField()
    {
        string rowNumber = apexPages.currentPage().getParameters().get('rownumber');
        
        if(rowNumber != null)
        {
            integer rowno = integer.valueOf(rowNumber);
            lstSelectedFields.remove(rowno);
        }
    }
    
    public class wraperFieldSet
    {
        public string strLabel{get;set;}
        public string strApiName{get;set;}
        public string strType{get;set;}
        public string strSizeClass{get;set;}
        public integer rowNumber{get;set;}
    }
}