@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        if (req.getEndpoint() == 'callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactexit') {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errors": []}');
            res.setStatusCode(200);
            return res;
        }
        
        if (req.getEndpoint() == 'callout:Salesforce_Marketing_Cloud/interaction/v1/interactions/contactMembership') {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"results": {"contactMemberships": [{"contactKey": "123","definitionKey": "0caa5edd-00df-d909-e50c-18bf82cebb1f","version": 2}],"contactsNotFound": []}}');
            res.setStatusCode(200);
            return res;
        }
        
        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id": "8dbabf43-04ed-40b0-beea-8851dd29b16f","key": "0caa5edd-00df-d909-e50c-18bf82cebb1f","name": "LWC Adventures"}');
        res.setStatusCode(200);
        return res;
    }
}