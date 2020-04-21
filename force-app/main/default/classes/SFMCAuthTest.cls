/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@IsTest 
public class SFMCAuthTest { 
    
    private static final String OAUTH_TOKEN = 'testToken'; 
    private static final String STATE = 'mocktestState'; 
    private static final String REFRESH_TOKEN = 'refreshToken'; 
    private static final String LOGIN_ID = 'testLoginId'; 
    private static final String USERNAME = 'testUsername'; 
    private static final String FIRST_NAME = 'testFirstName'; 
    private static final String LAST_NAME = 'testLastName'; 
    private static final String EMAIL_ADDRESS = 'testEmailAddress'; 
    private static final String LOCALE_NAME = 'testLocalName'; 
    private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
    private static final String PROVIDER = 'SFMC'; 
    private static final String REDIRECT_URL = 
    'http://localhost/services/authcallback/orgId/SFMC'; 
    private static final String KEY = 'testKey'; 
    private static final String SECRET = 'testSecret'; 
    private static final String STATE_TO_PROPOGATE = 'testState'; 
    private static final String ACCESS_TOKEN_URL = 
    'http://www.dummyhost.com/accessTokenUri'; 
    private static final String API_USER_VERSION_URL = 
    'http://www.dummyhost.com/user/20/1'; 
    private static final String AUTH_URL = 
    'http://www.dummy.com/authurl'; 
    private static final String API_USER_URL = 
    'www.mc.exacttarget.com/user/api'; 
    
    // In the real world scenario, the key and value would be read 
    // from the (custom fields in) custom metadata type record. 
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put('Key__c', KEY); 
        authProviderConfiguration.put('Auth_Url__c', AUTH_URL); 
        authProviderConfiguration.put('Secret__c', SECRET); 
        authProviderConfiguration.put('Access_Token_Url__c', ACCESS_TOKEN_URL); 
        authProviderConfiguration.put('API_User_Url__c',API_USER_URL); 
        authProviderConfiguration.put('API_User_Version_Url__c',
        API_USER_VERSION_URL); 
        authProviderConfiguration.put('Redirect_Url__c',REDIRECT_URL); 
        return authProviderConfiguration; 
    
    } 
    
    static testMethod void testInitiateMethod() 
    { 
        String stateToPropogate = 'mocktestState'; 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        SFMCAuthJourney sfmc = new SFMCAuthJourney(); 
        sfmc.redirectUri = authProviderConfiguration.get('Redirect_Url__c'); 
    PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Auth_Url__c') + '?client_id='+ 
    authProviderConfiguration.get('Key__c') +'&scope=USER,EXPRPT,LIST&redirect_uri='+ 
    authProviderConfiguration.get('Redirect_Url__c') + '&state=' + 
    STATE_TO_PROPOGATE); 
        PageReference actualUrl = sfmc.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assertNotEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    } 
    
    static testMethod void testHandleCallback() 
    { 
        Map<String,String> authProviderConfiguration = 
        setupAuthProviderConfig(); 
        SFMCAuthJourney sfmc = new SFMCAuthJourney();
        sfmc.redirectUri = authProviderConfiguration.get
        ('Redirect_Url_c'); 
    
        Test.setMock(HttpCalloutMock.class, new 
        SFMCMockHttpResponseGenerator()); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',authProviderConfiguration.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = 
        new Auth.AuthProviderCallbackState(null,null,queryParams); 
        Auth.AuthProviderTokenResponse actualAuthProvResponse = 
        sfmc.handleCallback(authProviderConfiguration, cbState); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = 
        new Auth.AuthProviderTokenResponse(
        'SFMC', OAUTH_TOKEN, REFRESH_TOKEN, null); 

    } 
    
    static testMethod void testRefreshToken() 
    { 
        Map<String,String> authProviderConfiguration = 
        setupAuthProviderConfig(); 
        SFMCAuthJourney sfmc = new SFMCAuthJourney();
        sfmc.redirectUri = authProviderConfiguration.get
        ('Redirect_Url_c'); 
    
        Test.setMock(HttpCalloutMock.class, new 
        SFMCMockHttpResponseGenerator()); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('auth','auth'); 
        queryParams.put('refresh','refresh'); 
        Auth.OAuthRefreshResult actualAuthProvResponse = 
        sfmc.refresh(authProviderConfiguration, '123'); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = 
        new Auth.AuthProviderTokenResponse(
        'SFMC', OAUTH_TOKEN, REFRESH_TOKEN, null); 

    } 
     
    static testMethod void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = 
        setupAuthProviderConfig(); 
        SFMCAuthJourney sfmc = new SFMCAuthJourney();
    
        Test.setMock(HttpCalloutMock.class, new 
        SFMCMockHttpResponseGenerator()); 
    
        Auth.AuthProviderTokenResponse response = 
        new Auth.AuthProviderTokenResponse(
        PROVIDER, OAUTH_TOKEN ,'sampleOauthSecret', STATE); 
        Auth.UserData actualUserData = sfmc.getUserInfo(
        authProviderConfiguration, response) ; 

    } 
    
    
    public class SFMCMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        { 
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"subject": "acct:test-account","links": [{"rel": "auth_instance_url","href": "https://mc.auth.marketingcloudapis.com/"},{"rel": "rest_instance_url","href": "https://mc.rest.marketingcloudapis.com/"}]}');
            res.setStatusCode(200);
            return res;
        } 
    
    } 
}