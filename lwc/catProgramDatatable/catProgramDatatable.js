import { LightningElement, wire} from 'lwc';
import getPrograms from '@salesforce/apex/cohortAssignmentController.getPrograms';

const columns = [
    { label: 'Name', fieldName: 'Name', editable: false },
    { label: 'Type of Program', fieldName: 'Type__c',type:'text', editable: false },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', editable: false },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date', editable: false },
    { label: 'Cycle', fieldName: 'Cycle__c', type: 'text', editable: false }
];

export default class catProgramDatatable extends LightningElement {
    error;
    columns = columns;

    @wire(getPrograms) 
    programs;



    handleRowSelection(event) {
        console.log('Handling row selection! Row is: ' + JSON.stringify(event.detail.selectedRows));

        var selectedRow=JSON.parse(JSON.stringify(event.detail.selectedRows));
        var programId =selectedRow[0].Id;
        console.log('Firing event! Program Id is: ' + programId);

        // Creates event with ID of Program for parent component
        const selectedEvent = new CustomEvent("programselected", {
        detail: programId
        });

        this.dispatchEvent(selectedEvent);

    }

}
