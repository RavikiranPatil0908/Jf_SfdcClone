/**
  @description       : 
  @author            : @MonikaC
  @group             : 
  @last modified on  : 07-03-2024
  @last modified by  : @MonikaC

**/

public class StockSkuJunctionCSVController {
    public Blob csvFileBody { get; set; }
    public String csvAsString { get; set; }
    public String[] csvFileLines { get; set; }
    public List<StockSkuJunction__c> stockSkuJunctionList { get; set; } 
    public Boolean showModal { get; set; }
    public Boolean showCSVUpload { get; set; }
    public Boolean showStockSkuJunctions { get; set; }
    public String session { get; set; }
    public String year { get; set; }
    
    
    public StockSkuJunctionCSVController() {
        csvFileLines = new String[]{};
        showModal = true;
        showCSVUpload = false;
        showStockSkuJunctions = false;
    }
    
    public void submitSessionYear() {
        showModal = true; // Set showModal to true to display the modal panel again
        showCSVUpload = true;
        showStockSkuJunctions = false;
    }
    public List<SelectOption> getSessionOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('January', 'January'));
        options.add(new SelectOption('February', 'February'));
        options.add(new SelectOption('March', 'March'));
        options.add(new SelectOption('April', 'April'));
        options.add(new SelectOption('May', 'May'));
        options.add(new SelectOption('June', 'June'));
        options.add(new SelectOption('July', 'July'));
        options.add(new SelectOption('August', 'August'));
        options.add(new SelectOption('September', 'September'));
        options.add(new SelectOption('October', 'October'));
        options.add(new SelectOption('November', 'November'));
        options.add(new SelectOption('December', 'December'));
        return options;
    }
    
    public void filterRecords() {
        // Validate year input
        Integer currentYear = Date.today().year();
        Integer inputYear = Integer.valueOf(year);
        // if (session=='July' && inputYear > currentYear) {
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Year cannot be in the future.'));
        //     return;
        // }
        // Retrieve custom label values for session and year
        String currentSessionLabel = System.Label.Current_Session;
        String currentYearLabel = System.Label.Current_Year;
        
        // Check if selected session is "January" and year is "2024" based on custom labels
        if (!(session == currentSessionLabel && year == currentYearLabel)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected session must be "' + currentSessionLabel + '" and year must be "' + currentYearLabel + '".'));
            return;
        }
        
        // Query records based on selected session and year
        List<StockSkuJunction__c> junctions = [SELECT id, Year__c, Session__c, Assumption__c, Program_Type__c, Program_Structure__c, SEM__c, Base_Count__c, Expected_Count__c, Stock_Keeping_Units__r.Name, Stock_Keeping_Units__c  FROM StockSkuJunction__c WHERE Session__c = :session AND Year__c = :year];
        // Set the queried records to be displayed
        stockSkuJunctionList = junctions;

        // Check if any records are found
        if (stockSkuJunctionList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found for the selected session and year.'));
            return;
        }
        // Display the relevant section
        showCSVUpload = true;
        showStockSkuJunctions = false;
    }
    
    
    
    public void importCSVFile() {
        try {

            // Check if the uploaded file is a CSV
            // if (!csvAsString.endsWithIgnoreCase('.csv')) {
            //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only CSV files are allowed.'));
            //     return;
            // }
            
            // Read CSV file body and store it in variable
            csvAsString = csvFileBody.toString();

            // Split CSV String to lines
            csvFileLines = csvAsString.split('\n');

            
            List<String> lstHeaders = csvFileLines[0].split(',');
            
                
            // Validate if the CSV data matches the expected object
            if (!lstHeaders.contains('Stock Keeping Units') && !lstHeaders.contains('Assumption')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The uploaded CSV file does not contain the required columns.'));
                return;
            }

            // to find the column postion
            Integer columnNoSKU = 0;
            Integer columnNoAssumption = 0;
            Integer count = 0;
            for(String headerVal : lstHeaders) {
                if(headerVal.containsIgnoreCase('Stock Keeping Units')) {
                    columnNoSKU = count;
                }
                if(headerVal.containsIgnoreCase('Assumption')) {
                    columnNoAssumption = count;
                }
                count++;
            }


            // Displaying data table
            showCSVUpload = false;
            showStockSkuJunctions = true;

            // Map to store Stock_Keeping_Units__c ID and Assumption__c value from CSV
            Map<String, Decimal> skuAssumptionMap = new Map<String, Decimal>();

            // Iterate CSV file lines and retrieve Stock_Keeping_Units__c ID and Assumption__c value.
            for(Integer i = 1; i < csvFileLines.size(); i++) {
                String[] csvRecordData = csvFileLines[i].split(',');
                Decimal assumption = Decimal.valueOf(csvRecordData[columnNoAssumption].trim());
                String mapKey = csvRecordData[columnNoSKU].trim();
                skuAssumptionMap.put(mapKey, assumption);
                System.debug(mapKey + ' ==> ' + assumption);
            }

            System.debug('skuAssumptionMap Size ==>'+skuAssumptionMap.size());
            
            // Query StockSkuJunction__c records based on Stock_Keeping_Units__c ID from the map
            List<StockSkuJunction__c> junctionToUpdate = [SELECT id, Year__c, Session__c, Assumption__c, Program_Type__c, Program_Structure__c, SEM__c, Base_Count__c, Expected_Count__c, Stock_Keeping_Units__r.Name, Stock_Keeping_Units__c FROM StockSkuJunction__c WHERE Session__c = :session AND Year__c = :year AND  Stock_Keeping_Units__r.Name IN :skuAssumptionMap.keySet()];
            System.debug('junctionToUpdate Size ==>'+junctionToUpdate.size());
            
            // Update Assumption__c field based on the map values
            for (StockSkuJunction__c obj : junctionToUpdate) {
                obj.Assumption__c = skuAssumptionMap.get(obj.Stock_Keeping_Units__r.Name);
            }
   
            // Perform update
            update junctionToUpdate;

            // Set the list to display in the Visualforce page
            stockSkuJunctionList = junctionToUpdate;

            // Displaying data table
            System.debug('Stock_Keeping_Units__c ID | Assumption__c Value');
            for (StockSkuJunction__c junction : junctionToUpdate) {
                System.debug('==> '+junction.Stock_Keeping_Units__c + ' | ' + junction.Assumption__c);
            }
            
            // Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Assumptions imported successfully!'));

        } catch(Exception e) {
            system.debug('Error 1 is==>'+e.getMessage());
            system.debug('Error 2 is==>'+e.getLineNumber());
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while importing data into Salesforce. Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }
    }

    // Define the refreshPage method to refresh the page
    public PageReference refreshPage() {
        // Redirect to the current page to refresh it
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }

    // Define the backSessionYearPage method to back the page
    public PageReference backSessionYearPage() {
        // Redirect to the current page to back it
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
}