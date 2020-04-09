public with sharing class SalesforceJourneyData {
    
    @AuraEnabled
    public static String getJourneyMembership(String userId) {
        if (String.isBlank(userId)) {
            return null;
        }

        // Callout to SFMC to get the list of all journeys a user is in
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactMembership');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        JSONGenerator requestJson = JSON.createGenerator(true);
        requestJson.writeStartObject();
        requestJson.writeFieldName('ContactKeyList');
        requestJson.writeStartArray();
        requestJson.writeString(userId);
        requestJson.writeEndArray();
        requestJson.writeEndObject();
        String requestBody = requestJson.getAsString();
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //check if the request failed
        if (checkResponseStatus(res.getStatusCode()) == false) {
            return '';
        }
        //Received a successful response
        
        JSONParser parser = JSON.createParser(res.getBody());
        
        JSONGenerator resultJson = JSON.createGenerator(true);
        
        resultJson.writeStartArray(); // [
        //parse the JSON response to get the values in Contact Membership
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'contactMemberships')) {
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
         			String name = '';
                    String key = '';
                    Integer version = 0;
                    while ((parser.nextToken() != null) && (parser.getCurrentToken() != JSONToken.END_ARRAY)) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'definitionKey')) {
                            parser.nextToken();
                            resultJson.writeStartObject(); // {
                            key = parser.getText();
                            resultJson.writeStringField('key', key);
                            name = getJourneyName(parser.getText());
                            resultJson.writeStringField('name', name);
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'version')) {
                            parser.nextToken();
                            version = parser.getIntegerValue();
                            resultJson.writeNumberField('version', version);
                            resultJson.writeBooleanField('exitingFromJourney', getExitStatus(key, userId, version));
                            resultJson.writeEndObject(); // }
                        }
                    }
                }
            }
        }
        
        resultJson.writeEndArray(); // ]
        return resultJson.getAsString();
    }
    
    @AuraEnabled
    public static String getJourneyName(String journeyKey) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/key:' + journeyKey);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (checkResponseStatus(res.getStatusCode()) == false) {
            return '';
        }
       
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'name')) {
                parser.nextToken();
                String journeyName = parser.getText();
                return journeyName;
            }
        }
        return '';
    }
    
    @AuraEnabled
    public static void getAPITriggeredJourneys() {
        //should we make this cachable?
    }
    
    @AuraEnabled
    public static void ejectFromJourney(List<String> journeyKey, List<String> userId, List<Integer> version) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactexit');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        JSONGenerator requestJson = JSON.createGenerator(true);
        requestJson.writeStartArray(); // [
        for (Integer i = 0; i < journeyKey.size(); i++) {
            requestJson.writeStartObject(); // {
            requestJson.writeStringField('ContactKey', userId[i]);
            requestJson.writeStringField('DefinitionKey', journeyKey[i]);
            requestJson.writeFieldName('Versions');
            requestJson.writeStartArray(); // [
            requestJson.writeNumber(version[i]);
            requestJson.writeEndArray(); // ]
            requestJson.writeEndObject(); // }
        }
        requestJson.writeEndArray(); // ]
        String requestBody = requestJson.getAsString();
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (checkResponseStatus(res.getStatusCode()) == false) {
            throw new SalesforceJourneyException('An error has occurred while ejecting from journey');
        }
    }
    
    @AuraEnabled
    public static Boolean getExitStatus(String journeyKey, String userId, Integer version) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactexit/status');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        JSONGenerator requestJson = JSON.createGenerator(true);
        requestJson.writeStartArray(); // [
        requestJson.writeStartObject(); // {
        requestJson.writeStringField('ContactKey', userId);
        requestJson.writeStringField('DefinitionKey', journeyKey);
        requestJson.writeFieldName('Versions');
        requestJson.writeStartArray(); // [
        requestJson.writeNumber(version);
        requestJson.writeEndArray(); // ]
        requestJson.writeEndObject(); // }
        requestJson.writeEndArray(); // ]
        String requestBody = requestJson.getAsString();
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (checkResponseStatus(res.getStatusCode()) == false) {
            throw new SalesforceJourneyException('An error has occurred while retrieving the exit status from this journey');
        }
        
        JSONParser parser = JSON.createParser(res.getBody());
        Boolean result = false;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) {
                parser.nextToken();
                if (parser.getText() == 'Exit process Completed.') {
                    return false;
                }
                if (parser.getText() == 'Exit request received for processing') {
                    result = true;
                }
                if (parser.getText() == 'Exit request Not Found') {
                    return false;
                }
            }
        }
        
        return result;
    }
    
    public static Boolean checkResponseStatus(Integer responseCode) {
        if ((responseCode > 299) || (responseCode < 200)) {
            return false;
        }
        return true;
    }

}