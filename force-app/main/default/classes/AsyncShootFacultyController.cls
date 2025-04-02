public class AsyncShootFacultyController {
    public String facultyEmail { get; set; }
    public String facultyName { get; set; }
   // public List<SelectOption> facultyOptions { get; set; }
   // public String selectedFaculty { get; set; }
    public List<Async_Shoot_Post_Production__c> records { get; set; }
    public String videoLink { get; set; }
    public Boolean showMsg  { get; set; }
    
    // Pagination Variables
    public Integer pageSize { get; set; }
    public Integer pageNumber { get; set; }
    public Integer totalRecords { get; set; }
    public Integer totalPages { get; set; }
    
    
    public AsyncShootFacultyController() {
        pageSize = 20; // Records per page
        pageNumber = 1; // Starting page
        // loadFacultyOptions();
        showMsg=false;
        records = new List<Async_Shoot_Post_Production__c>();
        facultyEmail = ApexPages.currentPage().getParameters().get('facultyEmail');
        
        if (facultyEmail != null) {
            loadRecords();
        }
    }
    
    // Load faculty options for the dropdown
    /*public void loadFacultyOptions() {
        
        facultyOptions = new List<SelectOption>();
        facultyOptions.add(new SelectOption('', '--Select Faculty--'));
        
        // Specify the object and field name
        String objectName = 'Async_Shoot_Post_Production__c';
        String fieldName = 'Faculty_Name__c';
        
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
        
        // Loop through picklist values and add them to the list
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            facultyOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        
    }*/
    
    // Load records based on the selected faculty
    public void loadRecords() {
        system.debug('loadRecords called');
        try{
            if (String.isNotBlank(facultyEmail)) {
                totalRecords = [SELECT COUNT()  FROM Async_Shoot_Post_Production__c WHERE Faculty_Email__c = :facultyEmail];
                system.debug('totalRecords==>'+totalRecords);
                system.debug('pageSize==>'+pageSize);
                // totalPages = (Integer)Math.ceil(totalRecords / pageSize);
                totalPages = (Integer)Math.ceil((Double)totalRecords / pageSize);
                
                system.debug('totalPages==>'+totalPages);
                
                records = [
                    SELECT Id, Name, Faculty_Email__c,Faculty_Name__c, Chapter_Name__c,Current_Download_Link__c,Subject__c,Post_Production_Status__c,Status_Sort__c,Video_Link_Version_2__c,Video_Link_Version_1__c FROM Async_Shoot_Post_Production__c
                    WHERE Faculty_Email__c = :facultyEmail  ORDER BY Status_Sort__c ASC,Post_Production_Status__c DESC LIMIT :pageSize OFFSET :((pageNumber - 1) * pageSize)];
                //ORDER BY Status_Sort__c ASC,Post_Production_Status__c DESC
                facultyName=records[0].Faculty_Name__c;
                system.debug('records.size()==>'+records.size());
                If(records.size()==0)
                {
                    showMsg=true;
                    
                }
                system.debug('showMsg==>'+showMsg);
            } /*else {
records.clear();
}*/
            
        }
        catch (Exception error) {
            System.debug('error ==>'+error.getMessage());
        }
    }
    
    
    
    // Pagination actions
    public void nextPage() {
        if (pageNumber < totalPages) {
            pageNumber++;
            loadRecords();
        }
    }
    
    public void previousPage() {
        if (pageNumber > 1) {
            pageNumber--;
            loadRecords();
        }
    }
}