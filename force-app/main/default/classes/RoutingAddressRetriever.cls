public class RoutingAddressRetriever {
    
    @InvocableMethod(label='Get Template Routing Address' description='Retrieves template or fallback JSON instantly.')
    public static List<String> getRoutingAddress(List<String> routingName) {
        
        // 1. FAST FAIL / SHORT CIRCUIT: If no prefix is provided, skip the Metadata API entirely.
        if (routingName == null || routingName.isEmpty() || String.isBlank(routingName[0])) {
            return new List<String>{ getFallbackJson() };
        }
        
        String prefix = routingName[0];
        String jsonResult = '{}';
        
        try {
            // 2. Only run the heavy Metadata Service if a specific prefix was requested
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = RoutingAddressDeployer.getAccessToken();
            //service.SessionHeader.sessionId = UserInfo.getSessionId();
            
            MetadataService.IReadResult readResult = service.readMetadata('CaseSettings', new String[] { 'Case' });
            MetadataService.Metadata[] records = readResult.getRecords();
            
            if (records != null && records.size() > 0) {
                MetadataService.CaseSettings caseSettings = (MetadataService.CaseSettings) records[0];
                
                if (caseSettings.emailToCase != null && caseSettings.emailToCase.routingAddresses != null) {
                    for (MetadataService.EmailToCaseRoutingAddress address : caseSettings.emailToCase.routingAddresses) {
                        if (address.routingName != null && address.routingName.startsWith(prefix)) {
                            jsonResult = JSON.serialize(address);
                            break; 
                        }
                    }
                }
            }
            
            // 3. If a prefix was provided but no match was found, use fallback
            if (jsonResult == '{}' || String.isBlank(jsonResult)) {
                jsonResult = getFallbackJson();
            }
            
        } catch (Exception e) {
            jsonResult = '{"error": "Failed to retrieve metadata: ' + e.getMessage() + '"}';
        }
        
        return new List<String>{ jsonResult };
    }

    // Helper method to keep the JSON block clean
    private static String getFallbackJson() {
        return '{' +
            '"addressType": "EmailToCase",' +
            '"caseOrigin": "Email",' +
            '"caseOwner": "Email_Support",' +
            '"caseOwnerType": "Queue",' +
            '"casePriority": "Medium",' +
            '"createTask": false,' +
            '"emailAddress": "",' +
            '"isPermsetControlled": true,' +
            '"routingName": "qwertyA",' +
            '"saveEmailHeaders": false' +
        '}';
    }
}