@isTest
public class SalesforceJourneyTest {
     @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String res = SalesforceJourneyData.getJourneyMembership('123');
 		JSONGenerator resultJson = JSON.createGenerator(true);
        resultJson.writeStartArray(); // [
        resultJson.writeStartObject();
        resultJson.writeStringField('key', '0caa5edd-00df-d909-e50c-18bf82cebb1f');
        resultJson.writeStringField('name', 'LWC Adventures');
        resultJson.writeNumberField('version', 2);
        resultJson.writeEndObject();
        resultJson.writeEndArray();
        System.assertEquals(resultJson.getAsString(), res);
    }
    
    @isTest static void testEjectFromJourney() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        SalesforceJourneyData.ejectFromJourney('123', '456', 2);
    }
}