@RESTResource(urlMapping='/RaiseTickets/*')
global class CreateCaseAPI {
	@HTTPPost
    global static void doPost(){
        String sno, rno, email, mobile, queryType, category, subCategory, subject, description, file, source;
        Blob fileBody;
        String fieldName, fieldValue;
        String result;
        Map<String,String> studentMap = new Map<String,String>();
        Map<String,String> caseMap = new Map<String,String>();
        Map<String, Object> responseMap = new Map<String, Object>();
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonBody = req.requestBody.toString();
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        if(jsonMap.containsKey('queryType') && jsonMap.containsKey('subject') && jsonMap.containsKey('category') && jsonMap.containsKey('subCategory') && jsonMap.containsKey('description')){
        	for (String key : jsonMap.keySet()) {               
            	fieldName = key;
            	fieldValue = (String)jsonMap.get(key);
           
                if(fieldName == 'sapid' && fieldValue != ''){
                   	sno = fieldValue; 
                    studentMap = getStudentDetails(sno, rno, email, mobile);
            		if(studentMap == null || studentMap.isEmpty()){
                        responseMap.put('status', 'error');
        				responseMap.put('message', 'We could not find these details in our database. Please ensure you are using the correct Sap Id.');
                		res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                        return;
            		}
                }else if(fieldName == 'registrationNo' && fieldValue != ''){
                   	rno = fieldValue; 
                    System.debug('rno1 '+fieldValue);
                    studentMap = getStudentDetails(sno, rno, email, mobile);
                    if(studentMap == null || studentMap.isEmpty()){
                        responseMap.put('status', 'error');
        				responseMap.put('message', 'We could not find these details in our database. Please ensure you are using the correct Registration Number.');
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                        return;
                	}
                }else if(fieldName == 'email' && fieldValue != ''){
                   	email = fieldValue; 
                }else if(fieldName == 'mobile' && fieldValue != ''){
                   	mobile = fieldValue; 
                    studentMap = getStudentDetails(sno, rno, email, mobile);
                    if(studentMap == null || studentMap.isEmpty()){
                        responseMap.put('status', 'error');
        				responseMap.put('message', 'We could not find these details in our database. Please ensure you are using the registered Email ID and Mobile Number combination.');
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                        return;
                	}
                }else if(fieldName == 'origin' && fieldValue != ''){                   	                  
                    source = fieldValue;                    
                }else if(fieldName == 'queryType' && fieldValue != ''){                   	
                    if(fieldValue == 'Feedback' && sno == null){
                        responseMap.put('status', 'error');
        				responseMap.put('message', 'Feedback cannot be raised for registrants/lead.');
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                        return;                        
                    }else{
                        queryType = fieldValue;
                    }
                }else if(fieldName == 'category'){
                   	category = fieldValue; 
                }else if(fieldName == 'subCategory' && fieldValue != ''){
                    List<String> subCatList = MyCasesController.getDependentPicklistValues(category, studentMap.get('program'));
                    if(subCatList.size() != 0){
                        if(subCatList.contains(fieldValue)){
                            subCategory = fieldValue;
                        }else{
                            responseMap.put('status', 'error');
                            responseMap.put('message', 'The entered sub-category does not match with the student program. Please refer the list given in the documentation for reference.');
                            res.addHeader('Content-Type', 'application/json');
                            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                            return;                
                        }
                    }else{
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'The entered category does not exist in the database. Please refer the list given in the documentation for reference.');
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                        return;
                    }
                }else if(fieldName == 'subject'){
                   	subject = fieldValue; 
                }else if(fieldName == 'description'){
                   	description = fieldValue; 
                }else if(fieldName == 'file'){
                   	file = fieldValue;
                    Http http = new Http();
					HttpRequest request = new HttpRequest();
					request.setEndpoint(file);
					request.setMethod('GET');
					HttpResponse response = http.send(request);
					fileBody = response.getBodyAsBlob();                    
                }
        	}
        }else{
            responseMap.put('status', 'error');
        	responseMap.put('message', 'Please enter all the mandatory fields.');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return;
        }
        
        if(sno != null && sno.length() != 0){      
            	caseMap.put('source', source);
                caseMap.put('purpose', queryType);
                caseMap.put('category', category);
                caseMap.put('subcat', subCategory);
                caseMap.put('sub', subject);
                caseMap.put('description', description);
                caseMap.put('studentNo', sno);
                result = MyCasesController.CreateCase(caseMap);
            
        }else if(rno != null && rno.length() != 0){
            
                if(studentMap.containsKey('converted')){
                    caseMap.put('converted', caseMap.get('converted'));
                }                
            	
            	caseMap.put('source', source);
                caseMap.put('purpose', queryType);
                caseMap.put('category', category);
                caseMap.put('subcat', subCategory);
                caseMap.put('sub', subject);
                caseMap.put('description', description);
                caseMap.put('regNo', rno);
                result = MyCasesController.CreateCase(caseMap);
            
        }else if(email != null && mobile.length() != 0){
            
                if(studentMap.containsKey('converted')){
                    caseMap.put('converted', caseMap.get('converted'));
                }
            	caseMap.put('source', source);
                caseMap.put('purpose', queryType);
                caseMap.put('category', category);
                caseMap.put('subcat', subCategory);
                caseMap.put('sub', subject);
                caseMap.put('description', description);
                caseMap.put('email', email);
                caseMap.put('mobile', mobile);
                result = MyCasesController.CreateCase(caseMap);
            
        }else{
            responseMap.put('status', 'error');
        	responseMap.put('message', 'Please enter the details of student/lead.');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return;
        }
        if(file != null && file != ''){			
            if(result != null){
                //MyCasesController.uploadFiles(fileBody, result.split(' ')[0]);
                ContentVersion newVersion = new ContentVersion();
				newVersion.Title = 'My File';
				newVersion.PathOnClient = 'myfile.pdf';
				newVersion.VersionData = fileBody;
				newVersion.FirstPublishLocationId = result.split(' ')[0];
                
				insert newVersion;
            }
        }
        if(result != null){
            responseMap.put('status', 'success');
            responseMap.put('caseId', result.split(' ')[0]);
            res.addHeader('Content-Type', 'application/json');
            if(queryType == 'Feedback'){
                responseMap.put('message', 'Thank you for your feedback for ' + subject +'. We have taken note of it and forwarded it to the relevant teams.');
            }else{            
                responseMap.put('message', 'Your ticket has been raised successfully. Please use Ticket No - #'+ result.split(' ')[1] +' TicketNo in all future correspondences ');        	                
            }
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return;
        }
        
    }
    
    @AuraEnabled
    public static Map<String,String> getStudentDetails(String sno, String rno, String email, String mobile){
        Map<String,String> studentMap = new Map<String,String>();
        List<Account> acc = new List<Account>();
        List<Lead> lead = new List<Lead>();
        try{                        
        	if(rno != null){
                //acc = [SELECT Id, PersonMobilePhone, PersonEmail, nm_Program__r.Name, nm_StudentNo__c FROM Account WHERE nm_RegistrationNumber__c like :'%'+rno limit 1];
                lead = [SELECT Id, MobilePhone, Email, nm_Program__r.Name, IsConverted FROM Lead WHERE nm_RegistrationNo__c like :'%'+rno limit 1]; 
            }
            if(email != null && mobile != null){
            	//acc = [SELECT Id, PersonMobilePhone, PersonEmail, nm_Program__r.Name, nm_StudentNo__c FROM Account WHERE (PersonEmail = :email AND PersonMobilePhone = :mobile) limit 1];
            	lead = [SELECT Id, MobilePhone, Email, nm_Program__r.Name, IsConverted FROM Lead WHERE (Email = :email AND MobilePhone = :mobile) limit 1];
            }
            if(sno != null){               
            	acc = [SELECT Id, PersonMobilePhone, PersonEmail, nm_Program__r.Name, nm_StudentNo__c FROM Account WHERE nm_StudentNo__c like :'%'+sno limit 1];
            }
            system.debug('lead1 '+lead);
            system.debug('acc '+acc);
            if(!lead.isEmpty()){
                if(lead[0].nm_Program__r.Name != null || lead[0].nm_Program__r.Name != ''){
                    studentMap.put('mobile', lead[0].MobilePhone);
                    studentMap.put('email', lead[0].Email);
                    studentMap.put('program', lead[0].nm_Program__r.Name);
                    studentMap.put('converted', String.valueOf(lead[0].IsConverted));
                }
            }
            if(!acc.isEmpty()){
                if(acc[0].nm_Program__r.Name != ''){
                    studentMap.put('mobile', acc[0].PersonMobilePhone);
                    studentMap.put('email', acc[0].PersonEmail);
                    studentMap.put('program', acc[0].nm_Program__r.Name);
                    studentMap.put('sno', acc[0].nm_StudentNo__c);
                }
            }
            
        }catch(Exception e){
            system.debug(e);
        } 
        return studentMap;
    }
}