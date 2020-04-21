/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global class SFMCAuthJourney extends Auth.AuthProviderPluginClass {
  
    // Use this URL for the endpoint that the 
    // authentication provider calls back to for configuration.
    private String CLIENT_ID;
    public String redirectUri;
    private String CLIENT_SECRET;
  
    private String authUrl;  
    
    // URI to get the new access token from concur using the GET verb.
    private String accessTokenUrl; 
    
    // Api name for the custom metadata type created for this auth provider.
    private String customMetadataTypeApiName = 'CustomAuth__c';
    
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    } 
      
    global PageReference initiate(Map<string,string> 
      authProviderConfiguration, String stateToPropagate) 
      { 
          authUrl = 'https://mc.login.exacttarget.com/hub-cas/login';
          SFMC_Journey_Auth_Settings__mdt[] baseurl = [SELECT Base_Url__c, ClientId__c FROM SFMC_Journey_Auth_Settings__mdt WHERE Label = 'Config'];
          if (baseurl.size() > 0) {
              authUrl = baseurl[0].Base_Url__c + '/v2/authorize';
              CLIENT_ID = baseurl[0].ClientId__c;
          }
          redirectUri = 'https://login.salesforce.com/services/authcallback/' + UserInfo.getOrganizationId() + '/SFMC_Journeys';
          
          String url = authUrl + '?response_type=code&client_id=' + CLIENT_ID + '&redirect_uri=' + redirecturi + '&state=' + stateToPropagate;
  
          return new PageReference(url);
      } 
      
      global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> 
      authProviderConfiguration, Auth.AuthProviderCallbackState state ) 
      { 
          // Here, the developer will get the callback with actual protocol. 
          // Their responsibility is to return a new object called 
          // AuthProviderTokenResponse. 
          // This will contain an optional accessToken and refreshToken 
          SFMC_Journey_Auth_Settings__mdt[] baseurl = [SELECT Base_Url__c, ClientId__c, ClientSecret__c FROM SFMC_Journey_Auth_Settings__mdt WHERE Label = 'Config'];
          if (baseurl.size() > 0) {
              authUrl = baseurl[0].Base_Url__c + '/v2/authorize';
              CLIENT_ID = baseurl[0].ClientId__c;
              CLIENT_SECRET = baseurl[0].ClientSecret__c;
          }
          accessTokenUrl = authProviderConfiguration.get('AuthUrl__c') + '/v2/token';
          redirectUri = 'https://login.salesforce.com/services/authcallback/' + UserInfo.getOrganizationId() + '/SFMC_Journeys';
          
          Map<String,String> queryParams = state.queryParameters;
          String code = queryParams.get('code'); 
          String sfdcState = queryParams.get('state'); 
      
          HttpRequest req = new HttpRequest(); 
          String url = accessTokenUrl; 
          req.setEndpoint(url); 
          req.setHeader('Content-Type','application/json'); 
          req.setMethod('POST'); 
          
          JSONGenerator requestJson = JSON.createGenerator(true);
          requestJson.writeStartObject();
          requestJson.writeStringField('code', code);
          requestJson.writeStringField('grant_type', 'authorization_code');
          requestJson.writeStringField('client_id', CLIENT_ID);
          requestJson.writeStringField('client_secret', CLIENT_SECRET);
          requestJson.writeStringField('redirect_uri', redirectUri);
          requestJson.writeEndObject();        
          String requestBody = requestJson.getAsString();
          req.setBody(requestBody);
      
          Http http = new Http(); 
          HTTPResponse res = http.send(req); 
          String responseBody = res.getBody();
          JSONParser parser = JSON.createParser(responseBody);
          String access_token;
          String refresh_token;
          while (parser.nextToken() != null) {
              if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                  parser.nextToken();
                  access_token = parser.getText();
              }
              if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'refresh_token')) {
                  parser.nextToken();
                  refresh_token = parser.getText();
              }
          }
      
          return new Auth.AuthProviderTokenResponse('SFMCAuthJourney', access_token, 
          refresh_token, sfdcState); 
      } 
                 
      global Auth.UserData getUserInfo(Map<string,string> 
      authProviderConfiguration, 
      Auth.AuthProviderTokenResponse response) 
      {
          Map<String,String> provMap = new Map<String,String>(); 
          provMap.put('what1', 'noidea1'); 
          provMap.put('what2', 'noidea2'); 
          return new Auth.UserData('id', 'fname', 'lname', 'flname', 
          'uname', 'what', 'Marketing Cloud', null, 'sfmc', null, provMap); 
      } 
      
      global override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
          SFMC_Journey_Auth_Settings__mdt[] baseurl = [SELECT Base_Url__c, ClientId__c, ClientSecret__c FROM SFMC_Journey_Auth_Settings__mdt WHERE Label = 'Config'];
          if (baseurl.size() > 0) {
              authUrl = baseurl[0].Base_Url__c + '/v2/authorize';
              CLIENT_ID = baseurl[0].ClientId__c;
              CLIENT_SECRET = baseurl[0].ClientSecret__c;
          }
          accessTokenUrl = authProviderConfiguration.get('AuthUrl__c') + '/v2/token';
          
          HttpRequest req = new HttpRequest(); 
          req.setEndpoint(accessTokenUrl); 
          req.setHeader('Content-Type','application/json'); 
          req.setMethod('POST'); 
          
          JSONGenerator requestJson = JSON.createGenerator(true);
          requestJson.writeStartObject();
          requestJson.writeStringField('grant_type', 'refresh_token');
          requestJson.writeStringField('client_id', CLIENT_ID);
          requestJson.writeStringField('client_secret', CLIENT_SECRET);
          requestJson.writeStringField('refresh_token', refreshToken);
          requestJson.writeEndObject();        
          String requestBody = requestJson.getAsString();
          req.setBody(requestBody);
      
          Http http = new Http(); 
          HTTPResponse res = http.send(req); 
          String responseBody = res.getBody();
          JSONParser parser = JSON.createParser(responseBody);
          String access_token;
          String refresh_token;
          while (parser.nextToken() != null) {
              if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                  parser.nextToken();
                  access_token = parser.getText();
              }
              if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'refresh_token')) {
                  parser.nextToken();
                  refresh_token = parser.getText();
              }
          }
  
          return new Auth.OAuthRefreshResult(access_token, refresh_token);
      }
      
  }