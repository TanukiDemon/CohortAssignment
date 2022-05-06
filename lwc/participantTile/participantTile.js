import { LightningElement, api } from 'lwc';
import HUMAN_ICON from '@salesforce/resourceUrl/HumanIcon';

export default class ParticipantTile extends LightningElement {
	@api participant;

    participantIconSrc = HUMAN_ICON;
    
    drag(event){
        event.dataTransfer.setData("divId", event.target.id);
    }
    allowDrop(event){
        event.preventDefault();
    }
    drop(event){
        event.preventDefault();
        var divId = event.dataTransfer.getData("divId");
        var draggedElement = this.template.querySelector('#' +divId);
        draggedElement.classList.add('completed'); 
        event.target.appendChild(draggedElement);
    }
}