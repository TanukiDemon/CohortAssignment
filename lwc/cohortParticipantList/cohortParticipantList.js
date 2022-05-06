import { LightningElement, wire, api } from 'lwc';
import HUMAN_ICON from '@salesforce/resourceUrl/HumanIcon';

import getAllCohortParticipants from '@salesforce/apex/cohortAssignmentController.getAllCohortParticipants';

export default class cohortParticipantList extends LightningElement {

    @api fid;
    @api cohortid;
    @api cohortname;

    @wire(getAllCohortParticipants,{cohortId: '$cohortid'}) 
    cohortParticipants;

    participantIconSrc = HUMAN_ICON;

}