public with sharing class SFMCEService {

	@InvocableMethod(label='Add a contact into a Journey' description='Adds a contact into a Journey utilizing Marketing Cloud Engagement')
	public static void addToJourney(List<AddToJourneyRequest> requests)
	{
		for (AddToJourneyRequest req : requests) {
            addToJourneyFuture(req.contactKey, req.emailAddress, req.conversationDescription);
        }
	}

	private static void addToJourney(String contactKey, String emailAddress, String conversationDescription) {
		String authToken = authenticate();
       String sfmceDomain = 'YOUR_SFMCE_REST_DOMANI_HERE';
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        RequestBody messageRequest = new RequestBody();
        messageRequest.contactKey = contactKey;
        messageRequest.eventDefinitionKey = 'YOUR_EVENT_DEFINITION_KEY_HERE';
        messageRequest.data = new RequestData();
        messageRequest.data.emailAddress = emailAddress;
        messageRequest.data.conversationDescription = conversationDescription;
        messageRequest.data.contactKey = contactKey;
       
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://'+sfmceDomain+'.rest.marketingcloudapis.com/interaction/v1/events');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Bearer ' + authToken);
		request.setBody(JSON.serialize(messageRequest));
		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 202) {
			System.debug('#### API response: '+response.getBody());
		} else {
			System.debug(' SFMCE API Error: ' + response.getStatusCode() + ' ' + response.getStatus());
		}
	}
  
    public static String authenticate() {
		// You can also retrieve this information from Custom Metadata Objects (recommended)
		String sfmceDomain = 'YOUR_SFMCE_REST_DOMANI_HERE';
		String clientID = 'YOUR_SFMCE_CLIENT_ID';
		String clientSecret = 'YOUR_SFMCE_CLIENT_SECRET';
		String mid = 'YOUR_SFMCE_ACCOUNT_ID';

		MarketingCloudAuthRequest authRequest = new MarketingCloudAuthRequest(clientID,clientSecret,mid);
		

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://'+sfmceDomain+'.auth.marketingcloudapis.com/v2/token');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		request.setBody(JSON.serialize(authRequest));
		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
            MarketingCloudAuthResponse resp = (MarketingCloudAuthResponse) JSON.deserialize(response.getBody(), MarketingCloudAuthResponse.class);
            System.debug('#### MKT AUTH RESPONSE: '+resp);
            return resp.access_token;
		} else {
			System.debug('The status code returned by the Marketing Cloud auth API was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
			return null;
		}

	}

	@future(callout=true)
	public static void addToJourneyFuture(String contactKey, String emailAddress, String conversationDescription) {
    	addToJourney(contactKey, emailAddress, conversationDescription);
	}
	
    public class MarketingCloudAuthRequest {
		String client_id;
		String client_secret;
		String grant_type;
        String account_id;

		public MarketingCloudAuthRequest(String clientId, String clientSecret, String accountId) {
			this.client_id = clientId;
			this.client_secret = clientSecret;
			this.grant_type = 'client_credentials';
            this.account_id = accountId;
		}
	}

	public class MarketingCloudAuthResponse {
		String access_token;
		String token_type;
		String expires_in;
		String scope;
		String soap_instance_url;
		String rest_instance_url;
	}
    
    public  class RequestBody {
        public String contactKey;
        public String eventDefinitionKey;

		RequestData data;
        
	}

   public  class RequestData {
       public String contactKey;
		public String emailAddress;
        public String conversationDescription; 
	}
    
    public class AddToJourneyRequest {
   
    @InvocableVariable(label='EmailAddress' required=true)
    public String emailAddress;
    
    @InvocableVariable(label='ContactKey' required=true)
    public String contactKey;
        
         @InvocableVariable(label='Conversation Description' required=true)
        public String conversationDescription;
	}
}