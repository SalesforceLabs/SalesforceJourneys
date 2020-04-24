/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public class SFMCJourneysSetup {
    public String username {get;set;}
    public String tseAuth {get;set;}
    public String tseRest {get;set;}
    public String loginUrl {get;set;}
    public String endpoint {
        get {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/48.0/' + String.valueOf(UserInfo.getOrganizationId()).substring(0,15);
        }
        set {
            endpoint = value;
        }
    }
    public String RSSCreateBody {
        get {
            return '<?xml version="1.0" encoding="utf-8"?>' +
                      '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                       '<env:Header>' +
                          '<met:SessionHeader>' +
                             '<met:sessionId>' + UserInfo.getSessionId() +'</met:sessionId>' +
                          '</met:SessionHeader>' +
                       '</env:Header>' +
                       '<env:Body>' +
                          '<met:createMetadata>' +
                             '<met:metadata xsi:type="met:RemoteSiteSetting">' +
                                '<met:fullName>SFMC_CurrentOrg</met:fullName>' +
                                '<met:description>Remote Site Setting for the current org</met:description>' +
                                '<met:disableProtocolSecurity>false</met:disableProtocolSecurity>' +
                                '<met:isActive>true</met:isActive>' +
                                '<met:url>' + URL.getSalesforceBaseUrl().toExternalForm() + '</met:url>' +
                             '</met:metadata>' +
                          '</met:createMetadata>' +
                       '</env:Body>' +
                    '</env:Envelope>';
        }
        set {
            RSSCreateBody = value;
        }
    }
    
    public void getTses() {
        //Get the tenant specific endpoints for a given user
        String endpoint;
        if (String.isBlank(this.username)) {
            throw new SalesforceJourneyException('An error has occurred due to a missing user name');
        }
        //Get the base credentials from our custom meta data type and use that to get the users TSEs
        SFMC_Journey_Auth_Settings__mdt[] baseurl = [SELECT Base_Url__c, ClientId__c FROM SFMC_Journey_Auth_Settings__mdt WHERE Label = 'Config'];
        if (baseurl.size() > 0) {
            endpoint = baseurl[0].Base_Url__c + '/v2/discovery';
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint +'?client_id=' + baseurl[0].ClientId__c + '&resource=acct:' + this.username);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //Extract the Auth & Rest endpoints
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'rel')) {
                parser.nextToken();
                if (parser.getText() == 'auth_instance_url') {
                    parser.nextToken();
                    parser.nextToken();
                    this.tseAuth = parser.getText();
                }
                if (parser.getText() == 'rest_instance_url') {
                    parser.nextToken();
                    parser.nextToken();
                    this.tseRest = parser.getText();
                }
            }
        }
        this.setUpCustomSettings(this.tseAuth, this.tseRest);
    }
    
    public void setUpCustomSettings(String authurl, String resturl) {
        //Need to create a custom setting
        //Which is used to create an auth provider
        //Which is used to create a named credential
        
        if (String.isBlank(authurl) || String.isBlank(resturl)) {
        	throw new SalesforceJourneyException('An error has occured retrieving the Tenant Specific Endpoints');
        }
        
        //Check if a custom setting record already exists
        //if it does, update it, if it doesn't create it
        CustomAuth__c[] c = [SELECT Id, AuthUrl__c, Rest_Url__c, Internal_Name__c FROM CustomAuth__c WHERE Internal_Name__c = 'SFMC_Journeys_Config' LIMIT 1];
        if (c.size() > 0) {
            //update
            c[0].AuthUrl__c = authurl;
            c[0].Rest_Url__c = resturl;
            update c[0];
        } else {
            //create
            CustomAuth__c cauth = new CustomAuth__c();
            cauth.AuthUrl__c = authurl;
            cauth.Rest_Url__c = resturl;
            cauth.Name = 'SFMC_Journeys_Config';
            cauth.Internal_Name__c = 'SFMC_Journeys_Config';
            cauth.SetupOwnerId = UserInfo.getProfileId();
            insert cauth;
        }   
    }
    
    public void setUpMetadata() {
        //This calls the methods to setup the auth provider & the named credential
        //This should only be done after the custom settings are populated
        this.setupAuthProvider();
        this.setupNamedCredentials();
    }
    
    public void setupAuthProvider() {
        //create the auth provider using the custom setting created earlier
        ApexClass[] plugin = [SELECT Id FROM ApexClass WHERE Name = 'SFMCAuthJourney'];
        CustomAuth__c[] cauth = [SELECT Id FROM CustomAuth__c WHERE Internal_Name__c = 'SFMC_Journeys_Config'];

        if (cauth.size() == 0 || plugin.size() == 0) {
        	throw new SalesforceJourneyException('An error has occured retrieving the Tenant Specific Endpoints');
        }
        
        //Check if this auth provider already exists
        //If it does exist, there's nothing to be done since the config is in custom settings
        
		AuthProvider[] nc = [SELECT Id FROM AuthProvider WHERE FriendlyName = 'SFMC_Journeys'];
        
        if (nc.size() > 0) {
            return;
        }
        
        HttpRequest req = new HttpRequest();  
        req.setMethod('POST');   
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/sobjects/AuthProvider/');  
        JSONGenerator requestJson = JSON.createGenerator(true);
        requestJson.writeStartObject();
        requestJson.writeStringField('friendlyName', 'SFMC_Journeys');
        requestJson.writeStringField('developerName', 'SFMC_Journeys');
        requestJson.writeStringField('providerType', 'Custom');
        requestJson.writeStringField('executionUserId', UserInfo.getUserId());
        requestJson.writeStringField('customMetadataTypeRecord', String.valueOf(cauth[0].Id).substring(0, 15));
        requestJson.writeStringField('pluginId', plugin[0].Id);
		requestJson.writeEndObject();        
        String requestBody = requestJson.getAsString();
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
    }
    
    public void setupNamedCredentials() {
        //create the named credential using the auth provider created earlier
        CustomAuth__c[] cauth = [SELECT Id, Rest_Url__c FROM CustomAuth__c WHERE Internal_Name__c = 'SFMC_Journeys_Config'];
        if (cauth.size() == 0) {
        	throw new SalesforceJourneyException('Error: Could not find the custom auth settings');
        }
        
        //Upsert named credential, no need to check if it already exists
        HttpRequest req = new HttpRequest(); 
        req.setHeader('Content-Type', 'text/xml');
        req.setMethod('POST');   
        req.setHeader('SOAPAction', 'Upsert'); 
            
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/48.0/' + String.valueOf(UserInfo.getOrganizationId()).substring(0,15));
        String body = '<?xml version="1.0" encoding="utf-8"?>' +
                          '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                           '<env:Header>' +
                              '<met:SessionHeader>' +
                                 '<met:sessionId>' + UserInfo.getSessionId() +'</met:sessionId>' +
                              '</met:SessionHeader>' +
                           '</env:Header>' +
                           '<env:Body>' +
                              '<met:upsertMetadata>' +
                                 '<met:metadata xsi:type="met:NamedCredential">' +
                                    '<met:fullName>Salesforce_Marketing_Cloud</met:fullName>' +
                                    '<met:protocol>Oauth</met:protocol>' +
                                    '<met:endpoint>' + cauth[0].Rest_Url__c + '</met:endpoint>' +
                                    '<met:label>Salesforce_Marketing_Cloud</met:label>' +
                                    '<met:principalType>NamedUser</met:principalType>' +
                                    '<met:authProvider>SFMC_Journeys</met:authProvider>' +
                                 '</met:metadata>' +
                              '</met:upsertMetadata>' +
                           '</env:Body>' +
                        '</env:Envelope>';
        
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        NamedCredential[] nc = [SELECT Id FROM NamedCredential WHERE MasterLabel = 'Salesforce_Marketing_Cloud'];
        
        this.loginUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/auth/xds/SFMC_Journeys?startURL=%2F';
        
        if (nc.size() > 0) {
            loginUrl += String.valueOf(nc[0].Id).substring(0,15);
            loginUrl+= '%3Fisdtp%3Dp1';
        }
        
    }
}