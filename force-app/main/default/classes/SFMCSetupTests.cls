/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
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