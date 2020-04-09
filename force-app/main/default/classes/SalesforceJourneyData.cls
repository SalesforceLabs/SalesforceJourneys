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
        //List<String> listOfJourneys = new List<String>();
        
        JSONParser parser = JSON.createParser(res.getBody());
        
        JSONGenerator resultJson = JSON.createGenerator(true);
        
        resultJson.writeStartArray(); // [
        //parse the JSON response to get the values in Contact Membership
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'contactMemberships')) {
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while ((parser.nextToken() != null) && (parser.getCurrentToken() != JSONToken.END_ARRAY)) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'definitionKey')) {
                            parser.nextToken();
                            //listOfJourneys.add(parser.getText());
                            resultJson.writeStartObject(); // {
                            resultJson.writeStringField('key', parser.getText());
                            resultJson.writeStringField('name', getJourneyName(parser.getText()));
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'version')) {
                            parser.nextToken();
                            resultJson.writeNumberField('version', parser.getIntegerValue());
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
    public static void ejectFromJourney(String journeyKey, String userId, Integer version) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactexit');
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
            throw new SalesforceJourneyException('An error has occurred while ejecting from journey');
        }
    }
    
    public static Boolean checkResponseStatus(Integer responseCode) {
        if ((responseCode > 299) || (responseCode < 200)) {
            return false;
        }
        return true;
    }

}
