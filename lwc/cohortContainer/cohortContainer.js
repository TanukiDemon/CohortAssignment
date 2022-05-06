import { LightningElement, wire, api } from 'lwc';

/** cohortAssignmentDatatableController.getBears() Apex method */
import getAllCohorts from '@salesforce/apex/cohortAssignmentController.getAllCohorts';

export default class cohortContainer extends LightningElement {

    @api fid;

    @wire(getAllCohorts,{programId: '$fid'}) 
    cohorts;


}