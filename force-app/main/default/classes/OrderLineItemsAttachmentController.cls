/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-19-2024
 * @last modified by  : @vickysahu
**/
public without sharing class OrderLineItemsAttachmentController {

    public Order_Book__c orderBook { get; set; }
    public String parentId { get; set; }
    public Blob csvFile { get; set; }
    public Blob pdfFile { get; set; }
    public Boolean isVerified {get; set;}
    public String invoiceNo {get; set;}
    public String lineItemId {get; set;}
    public String recordType {get; set;}
    public String fileControlLabel {get; set;}


    
    public String getFileControlLabel() {
        return this.fileControlLabel;
    }
        
    public void setFileControlLabel() {
        this.fileControlLabel = System.Label.FileControlLabel;
    }

    // Constructor to initialize the Order_Book__c record based on the provided ID
    public OrderLineItemsAttachmentController() {
        this.fileControlLabel = System.Label.FileControlLabel;
        isVerified = false;
        invoiceNo = null;
        lineItemId = null;
        recordType = null;
        parentId = ApexPages.currentPage().getParameters().get('id');
        if(String.isBlank(parentId)) {
            parentId = getCookie();
        }

        if(String.isBlank(getCookie())) {
            setCookie();
        }

        List<Order_Book__c> lstOrderBook = [SELECT Id, Name, Session__c, Year__c, Type__c, Publisher__c, Order_Status__c, Final_Order__c, Total_Cost__c, Sum_of_Book_Quantity__c
                     FROM Order_Book__c WHERE Id = :parentId];

        if(lstOrderBook.size() > 0) {
            orderBook = lstOrderBook[0];
        } else {
            orderBook = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Order Request Found'));
        }
    }

    public void setCookie() {
        Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
        Blob data = Blob.valueOf(parentId);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);

        String sessionToken = EncodingUtil.base64Encode(encrypted);
        Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
        sessionId = new Cookie('JSESSIONID',sessionToken,null,3600,true);
        ApexPages.currentPage().setCookies(new Cookie[]{sessionId});
    }

    public String getCookie() {
        String id = null;
        Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
        String SessionToken = sessionId!=null ? sessionId.getValue() : null;
        if(String.isNotBlank(SessionToken)) {
            Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.base64Decode(SessionToken));
            id = decrypted.toString();
        }
        return id;
    }

    // Method to save CSV and PDF files as attachments to OrderLineItem__c
    public PageReference saveAttachments() {
        if (csvFile == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'please select csv file'));
            return null; // Abort saving attachments
        }

        if ((System.Label.FileControlLabel == 'yes' || recordType == 'Book') && pdfFile == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'please select pdf file'));
            return null; // Abort saving attachments
        }

        if(orderBook == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Order Request Found'));
            return null; // Abort saving attachments
        }

        // Check if the sum of Approved Book Quantity is greater than or equal to the Final Order
        if (orderBook!=null && orderBook.Sum_of_Book_Quantity__c > orderBook.Final_Order__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Final Order cannot be greater than or equal to Sum of Book Quantity.'));
            return null; // Abort saving attachments
        }
        
        OrderLineItem__c orderLineItem = new OrderLineItem__c(Id = lineItemId);
        
        // Save CSV file as attachment
        if (csvFile != null) {
            Attachment csvAttachment = new Attachment();
            csvAttachment.Name = 'Order_Details.csv';
            csvAttachment.Body = csvFile;
            csvAttachment.ParentId = orderLineItem.Id;
            csvAttachment.ContentType = 'application/csv';
            insert csvAttachment;
            //csvFile = null;
            //csvAttachment = null;
            
            // Calculate the sum of Book Quantity from the CSV file
            Decimal sumBookQuantity = calculateSumBookQuantity(csvFile);
            
            // Update the Order Line Object with the sumBookQuantity value
            orderLineItem.Book_Quantity__c = sumBookQuantity;
            update orderLineItem;
        }
        
        // Save PDF file as attachment
        if (pdfFile != null) {
            Attachment pdfAttachment = new Attachment();
            pdfAttachment.Name = 'Order_Details.pdf';
            pdfAttachment.Body = pdfFile;
            pdfAttachment.ParentId = orderLineItem.Id;
            pdfAttachment.ContentType = 'application/pdf';
            insert pdfAttachment;
            //pdfFile = null;
            //pdfAttachment = null;
        }

        orderLineItem.Status__c = 'Submitted';
        update orderLineItem;
        // Add success message
        isVerified = false;
        invoiceNo = null;
        csvFile = null;
        pdfFile = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Attachments saved successfully.'));
        return null; // Refresh the page after saving attachments
    }
    
    // Method to calculate the sum of Book Quantity from the CSV file
    private Decimal calculateSumBookQuantity(Blob csvFile) {
        Decimal sumBookQuantity = 0;
        
        try {
            // Convert CSV Blob to String
            String csvAsString = csvFile.toString();
            // Split CSV String to lines
            List<String> csvFileLines = csvAsString.split('\n');

            List<String> lstHeaders = csvFileLines[0].split(',');

            // to find the column postion
            Integer columnNoISBN = 0;
            Integer columnNoQty = 0;
            Integer count = 0;
            for(String headerVal : lstHeaders) {
                
                if (recordType == 'Book') {
                    if(headerVal.containsIgnoreCase('ISBN')) {
                        columnNoISBN = count;
                    }   
                }else if(recordType == 'Kit'){
                    if(headerVal.containsIgnoreCase('SKUName')) {
                        columnNoISBN = count;
                    }   
                }
                if(headerVal.containsIgnoreCase('Quantity')) {
                    columnNoQty = count;
                }
                count++;
            }

            // Iterate CSV file lines and calculate sum of Book Quantity
            for(Integer i = 1; i < csvFileLines.size(); i++) {
                String[] csvRecordData = csvFileLines[i].split(',');
                Decimal qty = Decimal.valueOf(csvRecordData[columnNoQty].trim());
                sumBookQuantity += qty;
                System.debug(qty + ' ==> ' + sumBookQuantity);
            }
            
            // for(Integer i = 1; i < csvFileLines.size(); i++) {
            //     String[] csvRecordData = csvFileLines[i].split(',');
            //     // Assuming the column index of Book Quantity is 0, adjust this index accordingly
            //     Decimal bookQuantity = Decimal.valueOf(csvRecordData[0].trim());
            //     sumBookQuantity += bookQuantity;
            // }
        } catch(Exception e) {
            // Handle any exceptions
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while calculating the sum of Book Quantity.'));
        }
        
        return sumBookQuantity;
    }

    /**
    * @description 
    * @author @BK | 17-05-2024 
    * @return PageReference 
    **/
    public PageReference verifyInvoiceNo() {
        // to check if Challan number is verified and updated.
        // if (isVerified) {
        //     isVerified = false;
        //     // createLineItem();
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Challan Number Verified.'));
        //     return null;
        // }

        if(orderBook==null || String.isBlank(invoiceNo)) {
            isVerified = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'InValid Challan Number Entered, Kindly enter again.'));
            return null;
        }

        // if(String.isBlank(orderBook.Invoice_Number__c)) {
        //     orderBook.Invoice_Number__c = invoiceNo;
        //     update orderBook;
        // }
        isVerified = true;

        // Create OrderLineItem for saving Attachment.
        createLineItem(invoiceNo);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Challan Number Verified'));
        // Boolean test = true;
        // String url = 'https://ngasce--dev5.sandbox.my.salesforce-sites.com/OrderLineItemsAttachment?id='+parentId+ '&isVerified=' + test ;
        // PageReference pageRef = new PageReference(url);
        // pageRef.setRedirect(true);
        return null; 
    }

    public void createLineItem(String invoiceNo) {
        Id recordTypeId = Schema.SObjectType.OrderLineItem__c.getRecordTypeInfosByName().get(this.recordType).getRecordTypeId();
        OrderLineItem__c orderLineItem = new OrderLineItem__c(Order_Book__c = parentId, Challan_Number__c = invoiceNo, RecordtypeId = recordTypeId);
        insert orderLineItem;
        lineItemId = orderLineItem.Id;
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Book','Book'));
        options.add(new SelectOption('Kit','Kit'));
        return options;
    }
        
    public String getRecordType() {
        return recordType;
    }
        
    public void setRecordType(String recordType) {
        this.recordType = recordType;
    }
}