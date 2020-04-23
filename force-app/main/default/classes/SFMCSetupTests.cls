@isTest
public class SFMCSetupTests {
    @isTest static void testTses() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SFMCJourneysSetup s = new SFMCJourneysSetup();
        s.username = '123';
        try {
            s.getTses();
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'An error has occured retrieving the Tenant Specific Endpoints');
        }
        System.assertNotEquals('', s.username);
        System.assertNotEquals('', s.RSSCreateBody);
    }
    
    @isTest static void testAuthProvider() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SFMCJourneysSetup s = new SFMCJourneysSetup();
        try {
            s.setupAuthProvider();
        } catch(Exception e) {
            System.assertEquals(e.getMessage(), 'An error has occured retrieving the Tenant Specific Endpoints');
        }
        
        s.makeCalloutToCreateAuthProvider('123', '456');
    }
    
    @isTest static void testNamedCredential() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SFMCJourneysSetup s = new SFMCJourneysSetup();
        try {
            s.setupNamedCredentials();
        } catch(Exception e) {
            System.assertEquals(e.getMessage(), 'Error: Could not find the custom auth settings');
        }
        
        s.makeCalloutToCreateNamedCredential('123');
        s.generateLoginUrl();
    }
    
    @isTest static void testSetup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SFMCJourneysSetup s = new SFMCJourneysSetup();
        try {
            s.setUpMetadata();
        } catch(Exception e) {
            
        }
    }

}