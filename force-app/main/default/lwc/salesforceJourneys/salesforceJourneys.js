import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getJourneyMembership from '@salesforce/apex/SalesforceJourneyData.getJourneyMembership';
import ejectFromJourney from '@salesforce/apex/SalesforceJourneyData.ejectFromJourney';

import NO_JOURNEYS_IMAGE from '@salesforce/resourceUrl/noJourneys';

export default class SalesforceJourneys extends LightningElement {
    noJourneysImage = NO_JOURNEYS_IMAGE;

    journeys = [];
    loading = true;
    confirmRemovalModalOpen = false;
    journeyForRemoval;
    contactKey;
    @api objectApiName;
    @api contactKeyField;
    @api recordId;
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
    }

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
    }

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
        let journeyId = event.target.dataset.journey;
        this.journeyForRemoval = this.journeys.find(j => j.id === journeyId);
        this.confirmRemovalModalOpen = true;
    }

    handleRemoveFromJourney() {
        this.loading = true;
        this.confirmRemovalModalOpen = false;
        ejectFromJourney({
            journeyKey: [this.journeyForRemoval.key],
            userId: [this.contactKey],
            version: [this.journeyForRemoval.version]
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
    };

    handleDialogClose() {
        this.confirmRemovalModalOpen = false;
        this.journeyForRemoval = null;
    }

    connectedCallback() {
        this.fieldApiName = `${this.objectApiName}.${this.contactKeyField}`;
    };
}