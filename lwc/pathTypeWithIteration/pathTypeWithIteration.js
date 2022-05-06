import { LightningElement, api } from 'lwc';

export default class ProgressIndicatorPathTypeWithIteration extends LightningElement {
    
    @api stepValue= 'step-1';
    
    steps = [
        { label: 'Cohort Assignment', value: 'step-1' },
        { label: 'Select Facilitators and Participants', value: 'step-2' },
        { label: 'Run Assignment', value: 'step-3' },
        { label: 'Review Results', value: 'step-4' },
    ];

    @api
    nextStep(newStep) {
        console.log('In path element, stepValue was: ' + this.stepValue)
        this.stepValue=newStep;
        console.log('In path element, stepValue is newly: ' + this.stepValue)

    }

    @api
    prevStep(newStep) {
        console.log('In path element, stepValue was: ' + this.stepValue)
        this.stepValue=newStep;
        console.log('In path element, stepValue is newly: ' + this.stepValue)

    }
}
