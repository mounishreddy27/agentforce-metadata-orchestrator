public class RoutingAddressDeployer {
    
    @InvocableMethod(label='Execute Metadata Deployment' description='Safely deploys Case Routing Addresses' callout=true)
    public static List<String> executeDeployment(List<String> jsonPayloads) {
        String result = '';
        if (jsonPayloads == null || jsonPayloads.isEmpty()) {
            return new List<String>{ '{"error": "No JSON payload provided."}' }; 
        }
        
        try {
            // 1. SETUP SOAP CALLOUT
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			System.debug('RoutingAddressDeployer: before session usage'+ UserInfo.getUsername());
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = getAccessToken(); //UserInfo.getSessionId();

			System.debug('RoutingAddressDeployer: after session usage'+ UserInfo.getUsername());
            //service.endpoint_x = 'callout:Agentforce_Metadata_API/services/Soap/m/62.0';
            
            // 2. READ EXISTING SETTINGS
            MetadataService.IReadResult readResult = service.readMetadata('CaseSettings', new List<String>{ 'Case' });
            MetadataService.CaseSettings existingSettings = (MetadataService.CaseSettings) readResult.getRecords()[0];
            
            if (existingSettings.emailToCase == null) {
                existingSettings.emailToCase = new MetadataService.EmailToCaseSettings();
            }
            if (existingSettings.emailToCase.routingAddresses == null) {
                existingSettings.emailToCase.routingAddresses = new List<MetadataService.EmailToCaseRoutingAddress>();
            }
            
            Boolean hasValidData = false;
            
            String rawJsonString = jsonPayloads[0];

            // Deserialize into a generic object
            Object genericDeserialized = JSON.deserializeUntyped(rawJsonString);

            //check the type of data to process it
            if(genericDeserialized instanceof List<Object>){
                List<Object> payloadList = (List<Object>) genericDeserialized;

                for(Object item : payloadList){
                    Map<String, Object> payloadMap = (Map<String, Object>) item;
                    MetadataService.EmailToCaseRoutingAddress newAddress = mapRoutingAddress(payloadMap);
                    existingSettings.emailToCase.routingAddresses.add(newAddress);
                    hasValidData = true;
                }
            } else if (genericDeserialized instanceof Map<String, Object>) {
                Map<String, Object> payloadMap = (Map<String, Object>) genericDeserialized;                
                MetadataService.EmailToCaseRoutingAddress newAddress = mapRoutingAddress(payloadMap);
                existingSettings.emailToCase.routingAddresses.add(newAddress);
                hasValidData = true;
            }
            
            // 4. PERFORM A SINGLE DEPLOYMENT CALLOUT
            if (hasValidData) {
                List<MetadataService.SaveResult> saveResults = service.updateMetadata(new List<MetadataService.Metadata>{ existingSettings });
                
                if (saveResults[0].success) {
                    result = '{"status": "Success", "message": "Routing addresses created safely."}';
                } else {
                    result = '{"error": "Deployment failed: ' + saveResults[0].errors[0].message + '"}';
                }
            } else {
                result = '{"error": "No valid JSON payloads provided."}';
            }            
        } catch (Exception e) {
            result = '{"error": "Apex Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber() + '"}';
        }
        
        return new List<String>{ result };
    }

	public static String getAccessToken() {
        // 1. Fetch the Custom Metadata Type record from cache using getInstance()
        // 'Default_Config' is the DeveloperName of the record
        Agentforce_Auth_Setting__mdt authSetting = Agentforce_Auth_Setting__mdt.getInstance('Default_Config');

        // 2. Defensive Check: Ensure the record actually exists
        if (authSetting == null) {
            throw new CalloutException('Configuration Error: Agentforce_Auth_Setting__mdt record "Default_Config" not found. Please create this record in Setup.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(authSetting.Endpoint_URL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // 3. Construct the body using the queried credentials
        // URL Encoding is a best practice for form-urlencoded payloads
        String body = 'grant_type=client_credentials' 
            + '&client_id=' + EncodingUtil.urlEncode(authSetting.Client_Id__c, 'UTF-8') 
            + '&client_secret=' + EncodingUtil.urlEncode(authSetting.Client_Secret__c, 'UTF-8');
        
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // 4. Parse the token safely
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('access_token');
        } else {
            // Handle the error appropriately for your org
            throw new CalloutException('Failed to retrieve OAuth token. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
        }
    }

    private static MetadataService.EmailToCaseRoutingAddress mapRoutingAddress(Map<String, Object> payloadMap) {
        MetadataService.EmailToCaseRoutingAddress newAddress = new MetadataService.EmailToCaseRoutingAddress();
        
        // map all values
        newAddress.routingName      = (String) payloadMap.get('routingName');
        newAddress.emailAddress     = (String) payloadMap.get('emailAddress');
        newAddress.addressType      = (String) payloadMap.get('addressType');
        newAddress.caseOrigin       = (String) payloadMap.get('caseOrigin');
        newAddress.caseOwner        = (String) payloadMap.get('caseOwner');
        newAddress.caseOwnerType    = (String) payloadMap.get('caseOwnerType');
        newAddress.casePriority     = (String) payloadMap.get('casePriority');
        newAddress.createTask       = (Boolean) payloadMap.get('createTask');
        newAddress.isPermsetControlled = (Boolean) payloadMap.get('isPermsetControlled');        
        newAddress.saveEmailHeaders = (Boolean) payloadMap.get('saveEmailHeaders');

        return newAddress;
    }
}