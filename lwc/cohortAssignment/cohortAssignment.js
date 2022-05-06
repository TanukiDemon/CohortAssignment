import { LightningElement,wire, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
import assignCohorts from '@salesforce/apex/cohortAssignmentController.assignCohorts';

export default class CohortAssignment extends LightningElement {

    @api stepValue='step-1';
    @api leftFirstPage;
    @api secondPage;
    @api thirdPage;
    @api fourthPage;
    @api fifthPage;
    @api programId = '';
    @api facilitatorList;
    @api fellowList;
    @api maxCohortSize= 6;
    @api cohortsLoaded;
    hideNextButton;
    channelName = '/event/Cohort_Assignment_Completion__e';



    sendParticipants(){
        try{
        this.handleSubscribe();
        }catch(error){
            console.log(error.message);
        }
        console.log('In sendParticipants');
        console.log('Fac list: ' + this.facilitatorList);
        console.log('Fell list: ' + this.fellowList);
        console.log('TruthValue: ' + (this.facilitatorList && this.fellowList));
        if(this.facilitatorList && this.fellowList){
            let facilitatorIds= [];
            let fellowIds= [];
                this.facilitatorList.forEach(function (facilitator) {
                    console.log('Pushing Facilitator Id: ', facilitator.Id);
                    facilitatorIds.push(facilitator.Id);
                });            
                this.fellowList.forEach(function (fellow) {
                    console.log('Pushing Fellow Id: ', fellow.Id);
                    fellowIds.push(fellow.Id);
                });  
                try{
                    assignCohorts({fellowIds: fellowIds,facilitatorIds: facilitatorIds, programId: this.programId, maxCohortSize: this.maxCohortSize});
                }catch(error){
                    console.log(error);
                }
        }else if(error){
            console.log(error.message);
        }

        this.stepValue='step-4';
        this.thirdPage=false;
        this.fourthPage=true;
        this.template.querySelector('c-path-type-with-iteration').nextStep(this.stepValue);

    }


    handlePrevClick(){

        switch(this.stepValue) {
            case 'step-1':
                break;
            case 'step-2':
                this.stepValue='step-1';
                this.leftFirstPage=false;
                this.secondPage=false;
                break;
            case 'step-3':
                this.stepValue='step-2';
                this.secondPage=true;
                this.thirdPage=false;
                this.hideNextButton=false;
                break;
            case 'step-4':
                this.stepValue='step-3';
                this.thirdPage=true;
                this.fourthPage=false;
                this.hideNextButton=false;

                break;
            default:
                this.stepValue=this.stepValue;
            }

      this.template.querySelector('c-path-type-with-iteration').prevStep(this.stepValue);

    }

    handleNextClick(){

        if(this.stepValue!= undefined){
        switch(this.stepValue) {
            case 'step-1':
                this.stepValue='step-2';
                this.leftFirstPage=true;
                this.secondPage=true;
                break;
            case 'step-2':
                //Get fellows and facilitators here
                try{
                this.fellowList= this.template.querySelector('c-cat-fellows-datatable').getUserSelectedRows();
                this.facilitatorList = this.template.querySelector('c-cat-facilitator-datatable').getUserSelectedRows();
                } catch(error){
                        console.log('Error!: ',error.message);
                }
                console.log(this.fellowList);
                console.log(this.facilitatorList);

                
                this.stepValue='step-3';
                this.secondPage=false;
                this.thirdPage=true;
                this.hideNextButton=true;
                break;
            case 'step-3':
                this.stepValue='step-4';
                this.thirdPage=false;
                this.fourthPage=true;
                break;
            default:
                this.stepValue=this.stepValue;
            }

        this.template.querySelector('c-path-type-with-iteration').nextStep(this.stepValue);

        }
    } 
    
    handleProgramSelection(event) {
        const eventDetail= event.detail;
        this.programId = event.detail;
        console.log('A program was selected! The received events detail value is: [' + eventDetail + '] while the this.programId value is: ' + this.programId);
      }
    
    handleButtonClick(event) {
        this.clickedButtonLabel = this.template.querySelector('c-cat-facilitator-datatable').displayFacilitators();
    }

    handleSizeInputChange(event){
        this.maxCohortSize = event.detail.value;
        console.log(this.maxCohortSize)
    }

    handleCohortProcessedEvent(event){
        console.log('Handling cohort processed event');
        this.cohortsLoaded=true;
    }

    messageReceived(event) {
        const message = event.detail;
        console.log(message);

    }


}        
