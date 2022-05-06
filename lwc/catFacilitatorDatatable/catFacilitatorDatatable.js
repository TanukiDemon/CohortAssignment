import { LightningElement, wire, api} from 'lwc';
import getFacilitators from '@salesforce/apex/cohortAssignmentController.getFacilitators';

const columns = [
    { label: 'Name', fieldName: 'Name', editable: false },
    { label: 'Status', fieldName: 'Status__c', type: 'text', editable: true },
    { label: 'Promisingness Score', fieldName: 'Promisingness_Score__c', type: 'text', editable: true },
    { label: 'General Excitement Level', fieldName: 'General_Excitement_Level__c',type:'text', editable: true },
    { label: 'Interview Score', fieldName: 'Interview_Score__c', type: 'text', editable: true },
    { label: 'Submission Date', fieldName: 'CreatedDate', type: 'date', editable: true }
];

export default class DatatableWithInlineEdit extends LightningElement {
    _error;
    columns = columns;
    saveDraftValues = [];

    @api fid;

    @wire(getFacilitators,{programId: '$fid'}) 
    facilitators;
    
    @api
    displayFacilitators(){
        console.log(this.fid);
    }
    get error() {
        return this._error;
    }
    set error(value) {
        this._error = value;
    }

    handleSave(event) {
        console.log(event);
        console.log(event.detail.draftValues);
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                })
            );
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured: ' + error.message,
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }

        // This function is used to refresh the table once data updated
        async refresh() {
            await refreshApex(this.facilitators);
        }

        @api getUserSelectedRows() {
            return this.template.querySelector('lightning-datatable').getSelectedRows();
        }
}
