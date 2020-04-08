import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NO_JOURNEYS_IMAGE from '@salesforce/resourceUrl/noJourneys';

export default class SalesforceJourneys extends LightningElement {
    noJourneysImage = NO_JOURNEYS_IMAGE;

    journeys = [];
    loading = true;
    confirmRemovalModalOpen = false;
    journeyForRemoval;
    @api objectApiName;
    @api contactKeyField;
    @api recordId;
    @track fieldApiName;

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldApiName'})
    recordData;

    // Transform raw data from Marekting Cloud
    get journeyList() {
        return this.journeys.map(j => ({
            ...j,
            version: `V${j.version}`
        }));
    }

    get contactKey() {
        return this.recordData.data.fields[this.contactKeyField].value;
    }

    get prettyObjectName() {
        return this.objectApiName.toLowerCase();
    }

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
        setTimeout(() => {
            this.journeys = [
                {
                    "id": "3cdc7a0f-eacd-43c0-b893-e1544d8e341a",
                    "key": "a2f50f56-4e74-adc4-d396-4bd0f2fbfb53",
                    "name": "Media - Acquisition Journey",
                    "lastPublishedDate": "0001-01-01T00:00:00",
                    "description": "",
                    "version": 3,
                    "workflowApiVersion": 1.0,
                    "createdDate": "2016-11-17T07:20:53.18",
                    "modifiedDate": "2017-01-18T05:39:13.6",
                    "goals": [
                        {
                            "id": "23a80e2b-af09-478f-b6fb-20e99b64b3d9",
                            "key": "GOAL",
                            "name": "New Subscriber",
                            "description": "get paid subscription",
                            "type": "ContactEvent",
                            "outcomes": [],
                            "arguments": {
                                "serializedObjectType": 2,
                                "eventDefinitionId": "d5ee8c95-d9a9-45da-a7c9-3ed73a4db2e1",
                                "eventDefinitionKey": "ContactEvent-0c573e8a-9eb1-a742-1604-bbbc18d6639a",
                                "dataExtensionId": "3d312514-679e-e511-bcdd-3c4a92e5524c"
                            },
                            "configurationArguments": {
                                "criteria": "<FilterDefinition><ConditionSet Operator=\"AND\" ConditionSetName=\"Individual Filter Grouping\"><Condition ID=\"68d5b834-968b-4517-a9f0-b2277d8aa7d4\" Operator=\"IsNotNull\"><Value><![CDATA[]]></Value></Condition></ConditionSet></FilterDefinition>",
                                "schemaVersionId": 218
                            },
                            "metaData": {
                                "scheduleState": "No Schedule",
                                "isExitCriteria": false,
                                "conversionUnit": "percentage",
                                "conversionValue": "30",
                                "eventDefinitionId": "D5EE8C95-D9A9-45DA-A7C9-3ED73A4DB2E1",
                                "eventDefinitionKey": "ContactEvent-0c573e8a-9eb1-a742-1604-bbbc18d6639a",
                                "configurationDescription": "SubscriberKey IsNotNull",
                                "chainType": "none",
                                "configurationRequired": false,
                                "iconUrl": "/events/images/icon_journeyBuilder-event-person-blue.svg",
                                "title": "",
                                "category": "Event"
                            },
                            "schema": {
                                "arguments": {
                                    "conditionOutcome": {
                                        "dataType": "Boolean",
                                        "isNullable": false,
                                        "direction": "Out",
                                        "readOnly": false,
                                        "access": "Hidden"
                                    },
                                    "startActivityKey": {
                                        "dataType": "Text",
                                        "isNullable": true,
                                        "direction": "In",
                                        "readOnly": false,
                                        "access": "Hidden"
                                    },
                                    "dequeueReason": {
                                        "dataType": "Text",
                                        "isNullable": true,
                                        "direction": "In",
                                        "readOnly": false,
                                        "access": "Hidden"
                                    },
                                    "lastExecutedActivityKey": {
                                        "dataType": "Text",
                                        "isNullable": true,
                                        "direction": "In",
                                        "readOnly": false,
                                        "access": "Hidden"
                                    },
                                    "filterResult": {
                                        "dataType": "Boolean",
                                        "isNullable": true,
                                        "direction": "In",
                                        "readOnly": true,
                                        "access": "Hidden"
                                    }
                                }
                            }
                        }
                    ],
                    "exits": [],
                    "stats": {
                        "currentPopulation": 0,
                        "cumulativePopulation": 0,
                        "metGoal": 0,
                        "metExitCriteria": 0,
                        "goalPerformance": 0.0
                    },
                    "entryMode": "MultipleEntries",
                    "definitionType": "Multistep",
                    "channel": "",
                    "defaults": {
                        "email": [
                            "{{Event.ContactEvent-2d0228f2-01c5-2895-6f2a-f33cd746e09a.\"Email\"}}",
                            "{{Contact.Default.Email}}"
                        ],
                        "properties": {}
                    },
                    "metaData": {},
                    "executionMode": "Production",
                    "categoryId": 726757,
                    "status": "Draft",
                    "definitionId": "6e688a09-9d2a-4846-9d0a-a121f8eaf120",
                    "scheduledStatus": "Draft"
                },
                {
                    "id": "3cdc7a0f-eacd-43c0-b893-e1544d8e341a",
                    "key": "a2f50f56-4e74-adc4-d396-4bd0f2fbfb53",
                    "name": "The Economist - Acquisition Journey",
                    "lastPublishedDate": "2016-11-14T11:32:52",
                    "description": "",
                    "version": 2,
                    "workflowApiVersion": 1.0,
                    "createdDate": "2016-11-14T11:30:39.13",
                    "modifiedDate": "2016-11-14T11:32:52.54",
                    "goals": [],
                    "exits": [],
                    "stats": {
                        "currentPopulation": 112,
                        "cumulativePopulation": 56,
                        "metGoal": 0,
                        "metExitCriteria": 0,
                        "goalPerformance": 0.00
                    },
                    "entryMode": "MultipleEntries",
                    "definitionType": "Multistep",
                    "channel": "",
                    "defaults": {
                        "email": [
                            "{{Event.ContactEvent-2d0228f2-01c5-2895-6f2a-f33cd746e09a.\"Email\"}}",
                            "{{Contact.Default.Email}}"
                        ],
                        "properties": {}
                    },
                    "metaData": {},
                    "executionMode": "Production",
                    "categoryId": 726757,
                    "status": "Published",
                    "definitionId": "e16f93c5-022f-4d8b-8f89-5ba0860754f8",
                    "scheduledStatus": "Draft"
                }
            ];
            this.loading = false;
        }, 3000);
    }
}