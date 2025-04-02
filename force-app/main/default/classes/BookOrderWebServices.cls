/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 24-09-2024
 * @last modified by  : @BK
**/
global without sharing class BookOrderWebServices {

    /**
    * @description 
    * @author @BK | 17-04-2024 
    * @param String recordId 
    * @return String 
    **/
    @AuraEnabled
    webService static String fetchDetails(String recordId){ 
        try {
            List<Order_Book__c> lstOrderBooks = [SELECT id,Publisher__c,Session__c,Year__c,Type__c,Total_Cost__c,Final_Order__c,Order_Status__c,SJ_Unique_Key__c FROM Order_Book__c WHERE id = :recordId LIMIT 1];

            if(lstOrderBooks.size() == 0) {
                return 'Incorrect Id no Order record found';
            }
            Order_Book__c objOB = lstOrderBooks[0];
            if(objOB.Order_Status__c != 'Created') {
                return 'You can\'t update details at this stage.'; 
            }

            List<Book_Stock__c> lstBSK = getBookStockRecords(objOB);

            if(lstBSK.size() == 0) {
                return 'No Record Found, on Book Stock for Order';
            }
            List<String> lstPublishers = splitString(objOB.Publisher__c);
            System.debug('lstPublishers =>' + lstPublishers);
            Map<String,List<Book_Stock__c>> mapOfPublisherVsBooks = new Map<String,List<Book_Stock__c>>();
            List<String> csvRowValues = new List<String>();
            List<Map<String, Object>> lstFiles = new List<Map<String, Object>>();
            Decimal totalSumQuantity = 0;
            Decimal totalSumAmount = 0;
            for (Book_Stock__c obj : lstBSK) {
                String publisher = obj.Publisher__c.toLowerCase();
                System.debug('Publisher ==>'+publisher);
                if(lstPublishers.contains(publisher)) {
                    List<Book_Stock__c> lst = mapOfPublisherVsBooks.containsKey(publisher) ? mapOfPublisherVsBooks.get(publisher) : new List<Book_Stock__c>();
                    lst.add(obj);
                    mapOfPublisherVsBooks.put(publisher,lst);
        
                    String rowStr = obj.Course_Master__r.Name + ',' + obj.Number_Of_pages__c + ',' + obj.Publisher__c.toUpperCase() + ',' + obj.Final_Order__c;
                    csvRowValues.add(rowStr);
                    totalSumQuantity = totalSumQuantity + obj.Final_Order__c;
                    totalSumAmount = totalSumAmount + obj.Amount__c;
                }
            }

            csvRowValues.add('Total,' + ',' + ',' + totalSumQuantity);
            // To Create Repro Book Report
            String documentName = 'Order Details for Repro (' + objOb.Session__c + ' ' + objOB.Year__c + ').csv';
            String csvColumnHeader = 'Book, Number of Pages, Publisher, Final Order\n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            // Convert the input string to a Blob
            Blob binaryData = Blob.valueOf(csvFile);
            Map<String,Object> mapOfFiles = new Map<String,Object>{
                'pathOnClient' => documentName,
                'title' => documentName,
                'versionData' => EncodingUtil.base64Encode(binaryData)
            };
            lstFiles.add(mapOfFiles);
            System.debug('mapOfPublisherVsBooks 1=>' + mapOfPublisherVsBooks);
            lstFiles = insertPublisherFiles(mapOfPublisherVsBooks, lstFiles, objOB);
            // upload files
            Boolean isSuccess = UploadFiles.publishFiles(lstFiles,recordId);

            if(!isSuccess) {
                return 'Failed to save the details, Kindly check with System Administrator';
            } 

            // update total Quantity and Amount
            objOB.Final_Order__c = totalSumQuantity;
            objOB.Total_Cost__c = totalSumAmount;
            objOB.Order_Status__c = 'Ready for Order';
            update objOB;

            return 'success';
        } catch (Exception ex) {
            System.debug('Error Message ==> ' + ex.getMessage());
            System.debug('Error Line No ==> ' + ex.getLineNumber());
            return 'Failed to save the details, Kindly check with System Administrator';
        }
    }

    /**
    * @description 
    * @author @BK | 10-08-2024 
    * @param Order_Book__c objOB 
    * @return List<Book_Stock__c> 
    **/
    private static List<Book_Stock__c> getBookStockRecords(Order_Book__c objOB) {
        String session = objOB.Session__c;
        String year = objOB.Year__c;
        String uniqueKey = objOB.SJ_Unique_Key__c;
        String query ='';
        String subQuery = 'SELECT Id,Final_Order__c,Amount__c,Cost_Per_Book__c,Publisher__c,Rate_per_page__c,'+
                        'ISBN__c,Course_Master__r.Name,Number_Of_pages__c FROM Book_Stock__c '+
                        'WHERE Session__c=:session AND Year__c=:year AND Final_Order__c > 0 ';
        
        If(objOB.Type__c == 'New')
        {
           query= subQuery + 'AND Type__c =\'New\'' ;
        }
        else{
         query = (objOB.Type__c == 'Additional') 
                ? subQuery + ' AND SJ_Unique_Key__c=:uniqueKey AND Type__c =\'Additional\'' 
                : subQuery;
        }
        return Database.query(query);
    }

    /**
    * @description 
    * @author @BK | 17-04-2024 
    * @param Map<String List<Book_Stock__c>> mapOfPublisherVsBooks 
    * @param List<Map<String Object>> lstFiles 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> insertPublisherFiles(Map<String,List<Book_Stock__c>> mapOfPublisherVsBooks, List<Map<String, Object>> lstFiles, Order_Book__c objOB) {
        System.debug('mapOfPublisherVsBooks 2=>' + mapOfPublisherVsBooks);
        System.debug('File Size =>' + lstFiles.size());
        System.debug('objOB =>' + objOB);
        for (String publisher : mapOfPublisherVsBooks.keySet()) {
            List<Book_Stock__c> lst = mapOfPublisherVsBooks.get(publisher);
            List<String> csvRowValues = new List<String>();
            Decimal totalAmount = 0;
            Decimal totalQuantity = 0;
            for (Book_Stock__c obj : lst) {
                String rowStr = obj.Course_Master__r.Name + ',' + obj.Number_Of_pages__c + ',' + obj.Publisher__c.toUpperCase() + ',' + obj.Rate_per_page__c + ',' + obj.Cost_Per_Book__c + ',' + obj.Final_Order__c + ',' + obj.Amount__c;
                csvRowValues.add(rowStr);
                totalAmount = totalAmount + obj.Amount__c;
                totalQuantity = totalQuantity + obj.Final_Order__c;
            }
            csvRowValues.add('Total,' + ',' + ',' + ',' + ',' + totalQuantity + ',' + totalAmount);

            String documentName = publisher.capitalize() + ' Print Order for ' + objOb.Session__c + ' ' + objOB.Year__c + '.csv';
            String csvColumnHeader = 'Book, Number of Pages, Publisher, Rate Per Page, Cost Per Book, Final Order, Final Cost\n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            // Convert the input string to a Blob
            Blob binaryData = Blob.valueOf(csvFile);
            Map<String,Object> mapOfFilesDetails = new Map<String,Object>{
                'pathOnClient' => documentName,
                'title' => documentName,
                'versionData' => EncodingUtil.base64Encode(binaryData)
            };
            lstFiles.add(mapOfFilesDetails);
        }
        System.debug('File Size =>' + lstFiles.size());
        return lstFiles;
    }

    // /**
    // * @description 
    // * @author @BK | 18-04-2024 
    // * @param String recordId 
    // * @return String 
    // **/
    // @AuraEnabled
    // webService static String sendOrderToPublisher(String recordId) { 

    //     try {
    //         List<Order_Book__c> lstOrderBooks = [SELECT id,Publisher__c,Session__c,Year__c,Type__c,Total_Cost__c,Final_Order__c,Order_Status__c FROM Order_Book__c WHERE id = :recordId LIMIT 1];

    //         if(lstOrderBooks.size() == 0) {
    //             return 'Incorrect Id no Order record found';
    //         }
    //         Order_Book__c objOB = lstOrderBooks[0];
    //         List<ContentVersion> lstFiles = [SELECT Title,PathOnClient,FileType,VersionData FROM ContentVersion WHERE FirstPublishLocationId = :recordId];

    //         if(lstFiles.size() == 0) {
    //             return 'No Attachments found to send email.';
    //         }

    //         List<Messaging.SingleEmailMessage> lstEmailMessage = setEmailwithAttachment(lstFiles, objOB);
    //         if(lstEmailMessage == null) {
    //             return 'Failed to send email, Kindly check with System Administrator';
    //         }
    //         Messaging.sendEmail(lstEmailMessage);

    //         // update Status as Order Placed.
    //         objOB.Order_Status__c = 'Order Placed';
    //         update objOB;

    //     } catch (Exception ex) {
    //         System.debug('Error Message ==> ' + ex.getMessage());
    //         System.debug('Error Line No ==> ' + ex.getLineNumber());
    //         return 'Failed to save the details, Kindly check with System Administrator';
    //     }

    //     return 'success';
    // }

    // /**
    // * @description 
    // * @author @BK | 18-04-2024 
    // * @param List<ContentVersion> lstFiles 
    // * @param Order_Book__c objOB 
    // * @return List<Messaging.SingleEmailMessage> 
    // **/
    // public static List<Messaging.SingleEmailMessage> setEmailwithAttachment(List<ContentVersion> lstFiles, Order_Book__c objOB) {
    //     // List of all Mail to be send.
    //     List<Messaging.SingleEmailMessage> lstEmailMessage = new List<Messaging.SingleEmailMessage>();
    //     try {
    //         // Get Org Wide Email Address and then set it as Reply To address
    //         OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress where DisplayName='NMIMS CDOE' LIMIT 1];

    //         // Sets the TO addresses
    //         String[] ccaddr = new String[]{'deepali.shetty@nmims.edu.invalid','Ravindra.Pujari@nmims.edu.invalid','varsha.sawant@nmims.edu.invalid','rashmi.khedkar@nmims.edu.invalid'};
    //         Map<String,String[]> mapOfPuslisherVsListMailIds = new Map<String,String[]>{
    //             'Repro' => new string[]{'krishnabala771@gmail.com','nirbhay@reproindialtd.com.invalid','sunil_sawant@reproindialtd.com.invalid'},
    //             'Wiley' => new string[]{'krishnabala771@gmail.com','sbhabal@wiley.com.invalid','kghosh@wiley.com.invalid'},
    //             'Pearson' => new string[]{'krishnabala771@gmail.com','jyoti.chaudhary@pearson.com.invalid','varun.goenka@pearson.com.invalid'}
    //         };
    //         for (ContentVersion objFile : lstFiles) {
    //             // Define the email
    //             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //             email.setOrgWideEmailAddressId(owe.Id);
    //             email.setCcAddresses(ccaddr);
    //             email.setEntityAttachments(new Id[] {objFile.Id});
    //             String messageBody = '';
    //             if(objFile.PathOnClient.containsIgnoreCase('Order details for Repro')) {
    //                 email.setToAddresses(mapOfPuslisherVsListMailIds.get('Repro'));
    //                 email.setSubject('Require tentative date of printing of titles');
    //                 messageBody = '<html><p>Dear Team,</p><br>'
    //                                     +'<p>We have placed print order for attached Titles to the publisher, kindly check and provide us tentative date of printing of these titles</p><br>'
    //                                     +'<p>Thanks & Regards</p>'
    //                                     +'<p>NMIMS CDOE</p><br>';
    //             } else if(objFile.PathOnClient.containsIgnoreCase('Wiley') || objFile.PathOnClient.containsIgnoreCase('Pearson')) {
    //                 String publisher = objFile.PathOnClient.split(' ')[0].capitalize();
    //                 System.debug('publisher ==>'+publisher);
    //                 System.debug('mapOfPuslisherVsListMailIds ==>'+mapOfPuslisherVsListMailIds.get(publisher));
    //                 email.setToAddresses(mapOfPuslisherVsListMailIds.get(publisher));
    //                 email.setSubject('Print order for ' + publisher + ' - ' + objOB.Session__c +' '+ objOB.Year__c + ' drive');
    //                 messageBody = '<html><p>Dear Team,</p><br>'
    //                                     +'<p>Here, attached details of print order for ' + objOB.Session__c +' '+ objOB.Year__c + ' drive. Kindly release the PO to Repro on priority and keep us in loop.</p><br>'
    //                                     +'<p>Thanks & Regards</p>'
    //                                     +'<p>NMIMS CDOE</p><br>';
    //             } 
    //             // else if(objFile.PathOnClient.containsIgnoreCase('Pearson')) {
    //             //     email.setToAddresses(mapOfPuslisherVsListMailIds.get('Pearson'));
    //             //     email.setSubject('Print order for Pearson - ' + objOB.Session__c +' '+ objOB.Year__c + ' drive');
    //             //     messageBody = '<html><p>Dear Team,</p><br>'
    //             //                         +'<p>Here, attached details of print order for ' + objOB.Session__c +' '+ objOB.Year__c + ' drive. Kindly release the PO to Repro on priority and keep us in loop.</p><br>'
    //             //                         +'<p>Thanks & Regards</p>'
    //             //                         +'<p>NMIMS CDOE</p>';
    //             // }
    //             email.setHtmlBody(messageBody);
    //             lstEmailMessage.add(email);
    //         }
    //     } catch (Exception ex) {
    //         System.debug('Error Message on Email Attachment ==> ' + ex.getMessage());
    //         System.debug('Error Line No on Email Attachment ==> ' + ex.getLineNumber());
    //         return null;
    //     }
    //     return lstEmailMessage;
    // }

    /**
    * @description 
    * @author @BK | 18-04-2024 
    * @param String inputString 
    * @return List<String> 
    **/
    public static List<String> splitString(String inputString){
        List<String> splitStringList = new List<String>();
        String[] split = inputString.split(';');
        for(Integer i=0; i<split.size(); i++){
            split[i] = split[i].toLowerCase();
            splitStringList.add(split[i]);
        }
        return splitStringList;
    }
    
}