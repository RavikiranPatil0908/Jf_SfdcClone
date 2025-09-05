public class BulkStockDeductionController {

    public Blob fileBody { get; set; }
    public String fileName { get; set; }
    public String result { get; set; }

    public String processFile() {
        if (fileBody == null) {
            result = 'Please upload a valid CSV file.';
            return null;
        }

        String fileContent = fileBody.toString();
        List<String> lines = fileContent.split('\n');

        if (lines.size() <= 1) {
            result = 'The file appears empty or invalid.';
            return null;
        }

        Set<String> skuNames = new Set<String>();
        Set<String> centerNames = new Set<String>();
        List<Map<String, String>> csvRows = new List<Map<String, String>>();

        for (Integer i = 1; i < lines.size(); i++) {
            String[] columns = lines[i].replace('\r', '').split(',');

            if (columns.size() < 3) continue;

            String sku = columns[0].trim();
            String qty = columns[1].trim();
            String center = columns[2].trim();

            if (String.isBlank(sku) || String.isBlank(qty) || String.isBlank(center)) continue;

            csvRows.add(new Map<String, String>{
                'sku' => sku,
                'qty' => qty,
                'center' => center,
                'line' => String.valueOf(i + 1)
            });

            skuNames.add(sku.toLowerCase());
            centerNames.add(center.toLowerCase());
        }

        Map<String, Stock_Keeping_Units__c> skuMap = new Map<String, Stock_Keeping_Units__c>();
        for (Stock_Keeping_Units__c sku : [
            SELECT Id, Name, CM_Books__c FROM Stock_Keeping_Units__c
            WHERE Name IN :skuNames
        ]) {
            skuMap.put(sku.Name.toLowerCase(), sku);
        }

        Map<String, nm_Centers__c> centerMap = new Map<String, nm_Centers__c>();
        for (nm_Centers__c center : [
            SELECT Id, Name FROM nm_Centers__c
            WHERE Name IN :centerNames
        ]) {
            centerMap.put(center.Name.toLowerCase(), center);
        }

        // Collect all book names from SKUs
        Set<String> allBookNames = new Set<String>();
        for (Stock_Keeping_Units__c sku : skuMap.values()) {
            if (!String.isBlank(sku.CM_Books__c)) {
                for (String name : sku.CM_Books__c.split(';')) {
                    if (!String.isBlank(name)) {
                        allBookNames.add(name.trim());
                    }
                }
            }
        }

        // Preload all book stock records
        Map<String, Stock__c> bookStockMap = new Map<String, Stock__c>();
        if (!allBookNames.isEmpty() && !centerMap.isEmpty()) {
            List<Stock__c> allBookStocks = [
                SELECT Id, Quantity__c, Course_Master__r.Name, Centers__c
                FROM Stock__c
                WHERE Course_Master__r.Name IN :allBookNames
                AND Centers__c IN :centerMap.values()
            ];
            for (Stock__c book : allBookStocks) {
                String key = book.Centers__c + ':' + book.Course_Master__r.Name.toLowerCase();
                bookStockMap.put(key, book);
            }
        }

        Map<Id, Stock__c> stocksToUpdateMap = new Map<Id, Stock__c>();
        List<Stock__c> stocksToInsert = new List<Stock__c>();
        List<String> messages = new List<String>();

        // Load existing SKU stock
        Map<String, Stock__c> existingStockMap = new Map<String, Stock__c>();
        List<Stock__c> existingStocks = [
            SELECT Id, Centers__c, Stock_Keeping_Unit__c, Quantity__c
            FROM Stock__c
            WHERE Stock_Keeping_Unit__c IN :skuMap.values()
            AND Centers__c IN :centerMap.values()
        ];
        for (Stock__c stock : existingStocks) {
            String key = stock.Centers__c + ':' + stock.Stock_Keeping_Unit__c;
            existingStockMap.put(key, stock);
        }

        for (Map<String, String> row : csvRows) {
            String skuName = row.get('sku').trim();
            String centerName = row.get('center').trim();
            String qtyStr = row.get('qty').trim();
            Integer lineNo = Integer.valueOf(row.get('line'));

            if (!skuMap.containsKey(skuName.toLowerCase())) {
                messages.add('Line ' + lineNo + ': SKU "' + skuName + '" not found.');
                continue;
            }
            if (!centerMap.containsKey(centerName.toLowerCase())) {
                messages.add('Line ' + lineNo + ': Center "' + centerName + '" not found.');
                continue;
            }

            Integer qty;
            try {
                qty = Integer.valueOf(qtyStr);
            } catch (Exception e) {
                messages.add('Line ' + lineNo + ': Invalid quantity "' + qtyStr + '".');
                continue;
            }

            Stock_Keeping_Units__c sku = skuMap.get(skuName.toLowerCase());
            nm_Centers__c center = centerMap.get(centerName.toLowerCase());
            String stockKey = center.Id + ':' + sku.Id;

            // Book-level stock deduction (multi-SKU support)
            if (!String.isBlank(sku.CM_Books__c)) {
                List<String> bookNames = new List<String>();
                for (String name : sku.CM_Books__c.split(';')) {
                    if (!String.isBlank(name)) bookNames.add(name.trim());
                }

                Boolean hasSufficientStock = true;
                List<Stock__c> booksToUpdate = new List<Stock__c>();

                for (String bookName : bookNames) {
                    String bookKey = center.Id + ':' + bookName.toLowerCase();

                    if (!bookStockMap.containsKey(bookKey)) {
                        messages.add('Line ' + lineNo + ': Book stock for "' + bookName + '" at center "' + centerName + '" not found.');
                        hasSufficientStock = false;
                        break;
                    }

                    Stock__c book = bookStockMap.get(bookKey);
                    if ((book.Quantity__c == null ? 0 : book.Quantity__c) < qty) {
                        messages.add('Line ' + lineNo + ': Insufficient book stock for "' + bookName + '" at center "' + centerName + '".');
                        hasSufficientStock = false;
                        break;
                    }

                    book.Quantity__c -= qty;
                    booksToUpdate.add(book);
                }

                if (hasSufficientStock) {
                    for (Stock__c book : booksToUpdate) {
                        bookStockMap.put(center.Id + ':' + book.Course_Master__r.Name.toLowerCase(), book);
                        stocksToUpdateMap.put(book.Id, book);
                    }
                    messages.add('Line ' + lineNo + ': Book stock updated.');
                } else {
                    continue;
                }
            }

            // SKU-level stock update or insert
            if (existingStockMap.containsKey(stockKey)) {
                Stock__c stock = existingStockMap.get(stockKey);
                stock.Quantity__c = (stock.Quantity__c != null ? stock.Quantity__c : 0) + qty;
                stocksToUpdateMap.put(stock.Id, stock);
                messages.add('Line ' + lineNo + ': SKU stock updated.');
            } else {
                Stock__c newStock = new Stock__c(
                    Stock_Keeping_Unit__c = sku.Id,
                    Centers__c = center.Id,
                    Quantity__c = qty,
                    Outgoing_Quantity__c = 0,
                    Incoming_Quantity__c = 0
                );
                stocksToInsert.add(newStock);
                messages.add('Line ' + lineNo + ': New SKU stock record created.');
            }
        }

        try {
            if (!stocksToUpdateMap.isEmpty()) update stocksToUpdateMap.values();
            if (!stocksToInsert.isEmpty()) insert stocksToInsert;
        } catch (DmlException e) {
            messages.add('DML Error: ' + e.getMessage());
        }

        result = String.join(messages, '<br/>');
        return null;
    }
}