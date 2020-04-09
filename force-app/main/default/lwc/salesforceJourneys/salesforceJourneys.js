import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getJourneyMembership from '@salesforce/apex/SalesforceJourneyData.getJourneyMembership';

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

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiName'})
    wiredRecordData({ error, data }) {
        if (error) {
            this.showNotification('Error', 'An error occurred while loading the contact key', 'error');
        } else if (data) {
            this.contactKey = data.fields[this.contactKeyField].value;
            this.fetchJourneys();
        }
    };

    // Transform raw data from Marekting Cloud
    get journeyList() {
        console.log(this.journeys);
        let journeysList = this.journeys
            .map(j => ({
                ...j,
                version: `V${j.version}`,
                id: `${j.key}-${j.version}`
            }))
            .sort((a, b) => {
                let lowercaseA = a.name.toLowerCase();
                let lowercaseB = b.name.toLowerCase();
                return (lowercaseA < lowercaseB) ? -1 : (lowercaseA > lowercaseB) ? 1 : 0;
            });

        let uniqueIds = [];
        for (let journey of journeysList) {
            if (uniqueIds.indexOf(journey.id) === -1) {
                uniqueIds.push(journey.id);
            } else {
                journey.id = `${journey.id}-${uniqueIds.length}`;
                uniqueIds.push(journey.id);
            }
        }

        return journeysList;
    }

    get prettyObjectName() {
        return this.objectApiName.toLowerCase();
    }

    fetchJourneys() {
        this.loading = true;
        getJourneyMembership({ userId: this.contactKey })
            .then(result => {
                this.journeys = JSON.parse(result);
            })
            .catch(error => {
                console.log('Error', error);
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
        // Remove user from journey here
        this.showNotification(`${this.objectApiName} Removed!`, `The ${this.prettyObjectName} has been removed from ${this.journeyForRemoval.name}.`, 'success');

        this.handleDialogClose();
    }

    handleDialogClose() {
        this.confirmRemovalModalOpen = false;
        this.journeyForRemoval = null;
    }

    connectedCallback() {
        this.fieldApiName = `${this.objectApiName}.${this.contactKeyField}`;
    };
}