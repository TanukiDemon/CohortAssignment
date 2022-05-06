import { LightningElement, wire, api } from 'lwc';

import getAllCohorts from '@salesforce/apex/cohortAssignmentController.getAllCohorts';

export default class DragableParticipantList extends LightningElement {

    @api fid;

    @wire(getAllCohorts,{fellowshipId: '$fid'}) 
    cohorts;


}