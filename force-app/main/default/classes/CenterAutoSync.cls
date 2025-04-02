/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 25--11--2024
 * @last modified by  : @Ravi
**/
global class CenterAutoSync {

	//Required Paramters
	global class CenterActionRequest {
		@InvocableVariable(required=true)
		global ID CenterId;

		@InvocableVariable(required=true)
		global String CenterName;

		@InvocableVariable(required=true)
		global String address;

		@InvocableVariable(required=true)
		global String state;

		@InvocableVariable(required=true)
		global String city;

		@InvocableVariable(required=true)
		global String LcName;

		@InvocableVariable(required=true)
		global Boolean Active;
	}

	@InvocableMethod(label='Sync Center with Portal' description='Inserts/Update the Center data with Portal from Process builder.')
	global static void syncCenter(List<CenterActionRequest> requests) {
		try {
			calloutmethod(JSON.serialize(requests));
		} catch (Exception e) {
			System.debug('Callout Exception AutoSync_API1 :'+e.getMessage());
		}
		
	}

	@future (callout=true)
	public static void calloutmethod(String jsonResults){
		// Your callout logic
		List<CenterActionRequest> requests = (List<CenterActionRequest>)JSON.deserialize(jsonResults, List<CenterActionRequest>.class);
		System.debug('results-->'+requests);
		for (CenterActionRequest request : requests) {
			//to covert boolean value into integer.
			String centerActive = '0';
			if(request.Active){
				centerActive = '1';
			} 
			String centerId = String.valueOf(request.CenterId); 
			String jsonBody = '{"centerCode":"'+centerId.left(15)+'","centerName":"'+request.CenterName+'",';
			jsonBody = jsonBody + '"sfdcId":"'+centerId.left(15)+'","address":"'+request.address+'","state":"'+request.state+'",';
			jsonBody = jsonBody + '"city":"'+request.city+'","lc":"'+request.LcName+'","active":"'+centerActive+'"}';

			System.debug('jsonBody--->'+jsonBody);

			HttpRequest req = new HttpRequest();
			HttpResponse resp = new HttpResponse();
			Http http = new Http();

			req.setEndpoint(Label.AutoSyncCenter);
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setBody(jsonBody);
			try{
				resp = http.send(req);
				Integer statusCode = resp.getStatusCode();
				System.debug('AutoSync_API:statusCode = '+statusCode);
				if(statusCode == 200) {
					System.debug('after insert/update  success--');
					String result = resp.getBody();
                	Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
					System.debug('mapOfResponseParameters-->'+mapOfResponseParameters);
				}
			}catch(Exception e){
				System.debug('Callout Exception AutoSync_API :'+e.getMessage());
			}
			System.debug('after insert/update  success1--');
		}
	}

	
}