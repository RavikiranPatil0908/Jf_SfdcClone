/**
 * @File Name          : upGradAPIController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/10/2019, 4:51:12 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    30/4/2019, 12:45:45 PM         @BK                      Initial Version
**/
public without sharing class upGradAPIController {
	// Variables 
	public Map<String,Object> mapOfResponseParameters {get;set;}
	public String source {get;set;}
	public String invalidfieldmsg {get;set;}
	public Student_Rating__c objStudentRating {get;set;}

	public upGradAPIController() {
		mapOfResponseParameters = new Map<String,Object>();
		objStudentRating = new Student_Rating__c();
		source = 'UpGrad';
		invalidfieldmsg='';
	}

	/**
	* @description
	* @author @BK | 7/5/2019
	* @param String KeyUrl
	* @param String jsonString
	* @return Blob
	*/
	public Blob redirectToURI(String keyUrl,String jsonString) {
		switch on keyUrl {
			when  'getAccessToken' {
				return getAccessToken(jsonString);
			}
			when 'updateScore' {
				return updateScore(jsonString);
			}
			when else {
				return invalidURI();
			}
		}
		return invalidURI();
	}

	/**
	* @description
	* @author @BK | 7/5/2019
	* @param String jsonString
	* @return Blob
	*/
	public Blob getAccessToken(String jsonString) {

		System.debug('jsonString--'+jsonString);

		Map<String,Object> mapOfAttributes = new Map<String,Object>();
		Map<String,String> mapOfRequiredValue = new Map<String,String>{'request'=>'auth_token','source'=>source};
		Set<String> setRequiredParam = new Set<String>{'email','password','request','source'};
		Map<String,Object> mapOfResponseParameters2 = new Map<String,Object>();
		Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
		
		Boolean invalidRequest = false;

		// To pass params
		mapOfAttributes.put('setRequiredParam',setRequiredParam);
		mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
		mapOfAttributes.put('mapOfRequiredValue',mapOfRequiredValue);

		invalidRequest = invalidRequest(mapOfAttributes);

		if(invalidRequest) 
		{
			mapOfResponseParameters.put('message','Invalid Request');
			mapOfResponseParameters.put('errorCode','422');
		}else{

			if(Schema.sObjectType.RestResource_API_Access__c.isAccessible()) {
				String email = String.valueOf(mapOfRequestParameters.get('email'));
				String password = String.valueOf(mapOfRequestParameters.get('password'));
				List<RestResource_API_Access__c> lstRRAPIAccess = [SELECT id, isActive__c, API_EncryptionKey__c FROM RestResource_API_Access__c WHERE Email__c=:email AND Password__c=:password AND source__c=:source AND isActive__c=true];

				if(lstRRAPIAccess.size() > 0) {
					// To set the Requested Parameters. 
					mapOfResponseParameters2.put('token',generateToken(lstRRAPIAccess[0].API_EncryptionKey__c));
					mapOfResponseParameters2.put('timestamp',DateTime.now());
					mapOfResponseParameters2.put('status','success');
					
					// To set the Requested Parameters.
					mapOfResponseParameters.put('response',mapOfResponseParameters2);
					mapOfResponseParameters.put('message','ok');
					mapOfResponseParameters.put('errorCode','200');
				}else{
					mapOfResponseParameters.put('message','Invalid credentials.');
					mapOfResponseParameters.put('errorCode','406');
				}
			}else{
				mapOfResponseParameters.put('message','Invalid Access.');
				mapOfResponseParameters.put('errorCode','406');
			}
		}
		// Serialize the map to json.
		List<Object> lstResponseParam = new List<Object>{mapOfResponseParameters};
		Blob result = Blob.valueOf(JSON.serialize(lstResponseParam));
		return result;
	}


	/**
	* @description
	* @author @BK | 18/7/2019
	* @param String jsonString
	* @return Blob
	*/
	public Blob updateScore(String jsonString) {
		System.debug('jsonString--'+jsonString);
		UpGradUpdateScoreRequestWrapper requestWrapper = UpGradUpdateScoreRequestWrapper.parse(jsonString);
        System.debug('requestWrapper -->'+requestWrapper);
		Map<String,Object> mapOfResponseParameters2 = new Map<String,Object>();
		if(String.isBlank(requestWrapper.authToken) || String.isBlank(requestWrapper.source) || !requestWrapper.source.equalsIgnoreCase(source) || requestWrapper.request == null) {
			mapOfResponseParameters.put('message','Invalid Request at header parameters for authToken or source or request');
            mapOfResponseParameters.put('errorCode','422');
        }else {
            if(!decryptToken(requestWrapper.authToken)) {
                mapOfResponseParameters.put('message','Invalid Token');
                mapOfResponseParameters.put('errorCode','405'); 
            }else {
				UpGradUpdateScoreRequestWrapper.Request requestObject = requestWrapper.request;
				DateTime testSubmittedDateTime = convertStringToDateTime(requestObject.submitted_at);
				if(requestObject.total_score == null || String.isBlank(requestObject.email) || String.isBlank(requestObject.report_url)
					|| (String.isBlank(requestObject.submitted_at) || testSubmittedDateTime == null) || String.isBlank(requestObject.time_taken)
					|| String.isBlank(requestObject.status) || requestObject.sectional_score == null || requestObject.sectional_score.size() < 0) {
					mapOfResponseParameters.put('message','Invalid Request at email or total_score or submitted_at');
                	mapOfResponseParameters.put('errorCode','422');	
				}else {
					try {
						if(sectionalScore(requestObject.sectional_score)) {
							mapOfResponseParameters.put('message','Invalid Request '+invalidfieldmsg);
							mapOfResponseParameters.put('errorCode','422');
						}else if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Student_Rating__c.isAccessible() && Schema.sObjectType.Student_Rating__c.isUpdateable() 
							&& Schema.sObjectType.Student_Rating__c.isCreateable() && mapOfResponseParameters.isEmpty()) {
							List<Account> lstAccount = [SELECT Id,PersonEmail,nm_Centers__r.Name,upGrad_Test_Score__c,upGrad_Score_Date_Time__c,nm_StudentStatus__c FROM Account WHERE PersonEmail=:requestObject.email AND nm_Centers__r.Name='upGrad' AND nm_StudentStatus__c!='Rejected' LIMIT 1];
							if(lstAccount.size() == 0) {
								mapOfResponseParameters.put('message','Invalid Request Email id does not exist');
								mapOfResponseParameters.put('errorCode','422');	
							} else if(lstAccount[0].nm_StudentStatus__c == 'Rejected' || lstAccount[0].nm_StudentStatus__c == 'Confirmed') {
								mapOfResponseParameters.put('message','Invalid Request candidate has already been '+lstAccount[0].nm_StudentStatus__c);
								mapOfResponseParameters.put('errorCode','422');	
							} else{
								Account objAccount = lstAccount[0];
								objAccount.upGrad_Test_Score__c = requestObject.total_score;
								objAccount.upGrad_Score_Date_Time__c = DateTime.now();

								update objAccount;

								List<Student_Rating__c> lstStudentRating = [SELECT Id,Report_URL__c,Status__c,Test_Score__c,Submitted_At__c,Verbal_Reasoning__c,Quantitative_Aptitude__c,Logical_Reasoning_Data_Interpretation__c,Student__c FROM Student_Rating__c WHERE Student__c=:objAccount.id AND Submitted_At__c=:testSubmittedDateTime LIMIT 1];
								
								if(lstStudentRating.size() > 0) {
									objStudentRating.Id = lstStudentRating[0].Id;
								}
								objStudentRating.Student__c = objAccount.Id;
								objStudentRating.Report_URL__c = requestObject.report_url;
								objStudentRating.Status__c = requestObject.status;
								objStudentRating.Submitted_At__c = testSubmittedDateTime;
								objStudentRating.time_taken__c = requestObject.time_taken;
								objStudentRating.Test_Score__c = requestObject.total_score;
								objStudentRating.Number_of_retakes__c = requestObject.number_of_retakes;

								upsert objStudentRating;

								System.debug('objStudentRating -->'+objStudentRating);
								
								mapOfResponseParameters2.put('timestamp',DateTime.now());
								mapOfResponseParameters2.put('status','success');
								mapOfResponseParameters.put('response', mapOfResponseParameters2);
								mapOfResponseParameters.put('message','ok');
								mapOfResponseParameters.put('errorCode','200');
							}
						}else {
							mapOfResponseParameters.put('message','Invalid Access.');
                			mapOfResponseParameters.put('errorCode','406');
						}
					} catch (Exception e) {
						mapOfResponseParameters.put('message','Score update failed '+e);
                		mapOfResponseParameters.put('errorCode','437');	
					}
					
				}
			}
		}

		// Serialize the map to json.
		List<Object> lstResponseParam = new List<Object>{mapOfResponseParameters};
		Blob result = Blob.valueOf(JSON.serialize(lstResponseParam));
		return result;
	}

	/**
	* @description
	* @author @BK | 7/5/2019
	* @return Blob
	*/
	public Blob invalidURI() {
		// To set the Requested Parameters.
		mapOfResponseParameters.put('message','Could not find a match for URL');
		mapOfResponseParameters.put('errorCode','NOT_FOUND');

		// Serialize the map to json.
		List<Object> lstResponseParam = new List<Object>{mapOfResponseParameters};
		Blob result = Blob.valueOf(JSON.serialize(lstResponseParam));
		return result;
	}


	/**
	* @description
	* @author @BK | 7/5/2019
	* @param Map<String, Object> mapOfAttributes
	* @return Boolean
	*/
	public Boolean invalidRequest(Map<String,Object> mapOfAttributes) {
		Boolean invalidRequest = false;
		Map<String,String> mapOfRequiredValue = new Map<String,String>();
		Map<String,Object> mapOfRequestParameters = (Map<String,Object>)mapOfAttributes.get('mapOfRequestParameters');
		Set<String> setRequiredParam = (Set<String>)mapOfAttributes.get('setRequiredParam');
		Set<String> setPresentParam = mapOfRequestParameters.keySet();

		if(mapOfAttributes.containsKey('mapOfRequiredValue')) {
		mapOfRequiredValue = (Map<String,String>)mapOfAttributes.get('mapOfRequiredValue');
		}

		if(setPresentParam.containsAll(setRequiredParam)) {
			for (String fieldName : setPresentParam) {
				if(mapOfRequestParameters.get(fieldName) == null || mapOfRequestParameters.get(fieldName) == '') {
					invalidRequest = true;
				}else if(mapOfRequiredValue.containsKey(fieldName)) {
					if(mapOfRequiredValue.get(fieldName) != String.valueOf(mapOfRequestParameters.get(fieldName))) {
						invalidRequest = true;
					}
				}
			}
		}else{
			invalidRequest = true;
		}
		return invalidRequest;
	}

	/**
	* @description
	* @author @BK | 7/5/2019
	* @param String API_EncryptionKey
	* @return String
	*/
	public String generateToken(String apiEncryptionKey) {
        Blob cryptoKey = EncodingUtil.base64Decode(apiEncryptionKey);
        DateTime expiryTime = DateTime.now().addHours(1);
        Blob token = Blob.valueOf(DateTime.now().format('dd/MM/yyyy hh:mm a')+'|'+expiryTime.format('dd/MM/yyyy hh:mm a')+'|success|auth_token');
		Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, token);
        String accessToken = EncodingUtil.base64Encode(encryptedData);
        return accessToken;
    }

	/**
	* @description
	* @author @BK | 7/5/2019
	* @param String Token
	* @return Boolean
	*/
	public Boolean decryptToken(String token) {
        try {
            List<RestResource_API_Access__c> lstRRAPIAccess = [SELECT id, isActive__c, API_EncryptionKey__c FROM RestResource_API_Access__c WHERE source__c=:source and isActive__c=true];
            if(lstRRAPIAccess.size() > 0) {
                Blob cryptoKey = EncodingUtil.base64Decode(lstRRAPIAccess[0].API_EncryptionKey__c);
                Blob encryptedData = EncodingUtil.base64Decode(token);
                Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
                String decryptedDataString = decryptedData.toString();
                List<String> lstResponse = decryptedDataString.split('\\|');
                String role = lstResponse[0];
                DateTime currentDateTime = System.now();
                DateTime expiryDateTime = DateTime.parse(lstResponse[1]);

                if((currentDateTime < expiryDateTime) || role == 'admin') {
                    return true;
                }else {
                    return false;
                }
            }else{
                return false;
            }
            
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
    }

	/**
	* @description
	* @author @BK | 19/7/2019
	* @param List<UpGradUpdateScoreRequestWrapper.Sectional_score> lstSectionalScore
	* @return Boolean
	*/
	public Boolean sectionalScore(List<UpGradUpdateScoreRequestWrapper.Sectional_score> lstSectionalScore) {
		Integer i = 1;
		Map<String,String> mapOfsectionKeyVsSectionName = new Map<String,String> {'Quantitative Aptitude' => 'Quantitative_Aptitude__c', 'Verbal Reasoning' => 'Verbal_Reasoning__c', 'Logical Reasoning and Data Interpretation' => 'Logical_Reasoning_Data_Interpretation__c'};
		for(UpGradUpdateScoreRequestWrapper.Sectional_score sectionScore: lstSectionalScore) {
			if(String.isNotBlank(sectionScore.section_name) && sectionScore.section_score != null) {
				if(mapOfsectionKeyVsSectionName.containsKey(sectionScore.section_name)) {
					objStudentRating.put(mapOfsectionKeyVsSectionName.get(sectionScore.section_name), sectionScore.section_score);
				}else{
					System.debug('Error : '+i+')');
					invalidfieldmsg ='Sectional score unknown section name.';
					return true;
				}
				System.debug('objStudentRating -->'+objStudentRating);
			}else{
				System.debug('Error : '+i+')');
				invalidfieldmsg ='Sectional score Field values is missing';
				return true;
			}
			i++;
		}
		return false;
	}


	/**
	* @description To convert datetime string field to datetime field.
	* @author @BK | 20/7/2019
	* @return DateTime
	*/
	public DateTime convertStringToDateTime(String dateTimeString) {
		try {
			if(String.isNotBlank(dateTimeString)) {
				DateTime currentDateTime = DateTime.valueOf(dateTimeString);
				return currentDateTime;
			}else {
				return null;
			}
		} catch (Exception e) {
			System.debug('Error at convertStringToDateTime: '+e.getMessage());
			return null;
		}
	}

}