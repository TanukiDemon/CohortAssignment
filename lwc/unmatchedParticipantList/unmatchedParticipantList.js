import { LightningElement, wire, api } from 'lwc';
import HUMAN_ICON from '@salesforce/resourceUrl/HumanIcon';

import getUnmatchedParticipants from '@salesforce/apex/cohortAssignmentController.getUnmatchedParticipants';

export default class cohortParticipantList extends LightningElement {

    @api fid;
    @api cohortname;

    @wire(getUnmatchedParticipants,{programId: '$fid'}) 
    unmatchedParticipants;

    participantIconSrc = HUMAN_ICON;

}