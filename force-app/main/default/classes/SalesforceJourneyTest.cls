/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
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
        String userId = '456'; 
        List<Integer> versions = new List<Integer>{2};
        SalesforceJourneyData.ejectFromJourney(journeyName, userId, versions);
    }
    
    @isTest static void testExitStatus() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Boolean result = SalesforceJourneyData.getExitStatus('123', '456', 2);
        System.assertEquals(result, false);
    }
    
    @isTest static void testEmptyUserIdInput() {
        String res = SalesforceJourneyData.getJourneyMembership('');
        System.assertEquals(res, '[]');
    }
    
    @isTest static void testInvalidListSizeForEject() {
        List<String> names = new List<String>{'123', '456'};
        String user = 'abc';
        List<Integer> version = new List<Integer>{2};
        try {
        	SalesforceJourneyData.ejectFromJourney(names, user, version);
        }
        catch (Exception e) {
            System.assertEquals(e.getMessage(), 'An error has occurred while ejecting from journey');
        }
    }
    
    @isTest static void testResponseStatus() {
        Boolean res = SalesforceJourneyData.checkResponseStatus(400);
        System.assertEquals(res, false);
    }
}