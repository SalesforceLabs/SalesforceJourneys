/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkNamedCredentials from '@salesforce/apex/SalesforceJourneyData.checkNamedCredentials';
import getJourneyMembership from '@salesforce/apex/SalesforceJourneyData.getJourneyMembership';
import ejectFromJourney from '@salesforce/apex/SalesforceJourneyData.ejectFromJourney';

import NO_JOURNEYS_IMAGE from '@salesforce/resourceUrl/noJourneys';

export default class SalesforceJourneys extends LightningElement {
    noJourneysImage = NO_JOURNEYS_IMAGE;

    journeys = [];
    loading = true;
    confirmRemovalModalOpen = false;
    confirmRemovalAllModalOpen = false;
    isConfigured = false;
    journeyForRemoval;
    contactKey;
    @api objectApiName;
    @api contactKeyField;
    @api recordId;
    @api supportEject;
    // @api journeyStats;
    @track fieldApiName;

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiName' })
    wiredRecordData({ error, data }) {
        if (error) {
            this.showNotification('Error', 'An error occurred while loading the contact key', 'error');
        } else if (data) {
            this.contactKey = data.fields[this.contactKeyField].value;
            this.fetchJourneys();
        }
    };

    get prettyObjectName() {
        return this.objectApiName.toLowerCase();
    };

    get showMenu() {
        return !this.loading && this.journeys.filter(j => !j.exitingFromJourney).length > 0;
    };

    getJourneys() {
        return getJourneyMembership({ userId: this.contactKey })
            .then(result => {
                let journeys = JSON.parse(result);
                journeys = journeys
                    .map(j => ({
                        ...j,
                        prettyVersion: `V${j.version}`,
                        id: `${j.key}_${j.version}`
                    }))
                    .sort((a, b) => {
                        let lowercaseA = a.name.toLowerCase();
                        let lowercaseB = b.name.toLowerCase();
                        return (lowercaseA < lowercaseB) ? -1 : (lowercaseA > lowercaseB) ? 1 : 0;
                    });

                let uniqueIds = [];
                for (let journey of journeys) {
                    if (uniqueIds.indexOf(journey.id) === -1) {
                        uniqueIds.push(journey.id);
                    } else {
                        journey.id = `${journey.id}_${uniqueIds.length}`;
                        uniqueIds.push(journey.id);
                    }
                }

                this.journeys = journeys;
            });
    };

    fetchJourneys() {
        this.loading = true;
        return this.getJourneys()
            .catch(error => {
                console.error('Error', error);
                this.showNotification('Error', 'An error occurred while loading journeys.', 'error');
            })
            .then(() => {
                this.loading = false;
            });
    };

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    };

    removeUserFromJourney(event) {
        if (this.supportEject) {
            let journeyId = event.target.dataset.journey;
            this.journeyForRemoval = this.journeys.find(j => j.id === journeyId);
            this.confirmRemovalModalOpen = true;
        }
    }

    removeUserFromAllJourneys() {
        if (this.supportEject) {
            this.confirmRemovalAllModalOpen = true;
        }
    }

    handleRemoveFromJourney() {
        if (this.supportEject) {
            this.loading = true;
            this.confirmRemovalModalOpen = false;
            ejectFromJourney({
                journeyKey: [this.journeyForRemoval.key],
                userId: this.contactKey,
                version: [this.journeyForRemoval.version], 
                namedCredential: [this.journeyForRemoval.namedCredential]
            })
                .then(() => {
                    this.showNotification(`${this.objectApiName} Removed!`, `The ${this.prettyObjectName} has been removed from ${this.journeyForRemoval.name}.`, 'success');
                    return this.getJourneys();
                })
                .catch(error => {
                    console.error(error);
                    this.showNotification('Error', 'An error has occurred while removing from journey. Try again later.', 'error');
                })
                .then(() => {
                    this.loading = false;
                    this.journeyForRemoval = null;
                });
        }
    };

    handleRemoveFromAllJourneys() {
        if (this.supportEject) {
            let journeysForRemoval = this.journeys.filter(j => !j.exitingFromJourney);
    
            this.loading = true;
            this.confirmRemovalAllModalOpen = false;
            ejectFromJourney({
                journeyKey: journeysForRemoval.map(j => j.key),
                userId: this.contactKey,
                version: journeysForRemoval.map(j => j.version),
                namedCredential: journeysForRemoval.map(j => j.namedCredential)
            })
                .then(() => {
                    this.showNotification(`${this.objectApiName} Removed!`, `The ${this.prettyObjectName} has been removed from all journeys.`, 'success');
                    return this.getJourneys();
                })
                .catch(error => {
                    console.error(error);
                    this.showNotification('Error', 'An error has occurred while removing from journey. Try again later.', 'error');
                })
                .then(() => {
                    this.loading = false;
                });
        }
    };

    handleDialogClose() {
        this.confirmRemovalModalOpen = false;
        this.confirmRemovalAllModalOpen = false;
        this.journeyForRemoval = null;
    };

    migrateOldConfigs() {
        if (this.supportEject === undefined) {
            this.supportEject = true;
        }

        // if (this.journeyStats === undefined) {
        //     this.journeyStats = false;
        // }
    }

    checkConfiguration() {
        this.loading = true;
        checkNamedCredentials()
            .then((result) => {
                this.isConfigured = result;
                this.loading = false;
            });
    }

    connectedCallback() {
        this.fieldApiName = `${this.objectApiName}.${this.contactKeyField}`;
        this.migrateOldConfigs();
        this.checkConfiguration();
    };
}