@isTest
public class SFMCSetupTests {
    @isTest static void testTses() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SFMCJourneysSetup s = new SFMCJourneysSetup();
        s.username = '123';
        s.getTses();
        s.setupAuthProvider();
        s.generateLoginUrl();
        System.assertNotEquals('', s.username);
        System.assertNotEquals('', s.RSSCreateBody);
    }

}