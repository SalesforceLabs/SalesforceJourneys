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
        resultJson.writeBooleanField('exitingFromJourney', false);
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
        List<String> journeyName = new List<String>{'123'};
        List<String> userId = new List<String>{'456'}; 
        List<Integer> versions = new List<Integer>{2};
        SalesforceJourneyData.ejectFromJourney(journeyName, userId, versions);
    }
    
    @isTest static void testExitStatus() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Boolean result = SalesforceJourneyData.getExitStatus('123', '456', 2);
        System.assertEquals(result, false);
    }
}