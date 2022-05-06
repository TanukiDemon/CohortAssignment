import { LightningElement, wire, track } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/CometD_Controller.getSessionId';


export default class Cometdlwc extends LightningElement {
 libInitialized = false;
 component= this;
 @track sessionId;
 @track error;

 @wire(getSessionId)
 wiredSessionId({ error, data }) {
  if (data) {
    console.log(data);
    this.sessionId = data;
    this.error = undefined;
    loadScript(this, cometdlwc)
    .then(() => {
        this.initializecometd()
    });
} else if (error) {
    console.log(error);
    this.error = error;
    this.sessionId = undefined;
  }
}

initializecometd() {
    var that=this;

  if (this.libInitialized) {
    return;
  }

 this.libInitialized = true;

 //inintializing cometD object/class
 var cometdlib = new window.org.cometd.CometD();
        
//Calling configure method of cometD class, to setup authentication which will be used in handshaking
  cometdlib.configure({
    url: window.location.protocol + '//' + window.location.hostname + '/cometd/47.0/',
    requestHeaders: { Authorization: 'OAuth ' + this.sessionId},
    appendMessageTypeToURL : false,
    logLevel: 'debug'
});

cometdlib.websocketEnabled = false;

cometdlib.handshake(function(status) {
    
    console.log('that value: ' + JSON.stringify(that));
    if (status.successful) {
        // Successfully connected to the server.
        // Now it is possible to subscribe or send messages
        console.log('Successfully connected to server');
        console.log('value of this: ', this);

        cometdlib.subscribe('/event/Cohort_Assignment_Completion__e', (message) => {
                console.log('subscribed to message!'+ message);           

                console.log('Program Id: ' + message.data.payload.Program_Id__c);
                
                // Creates the event with the data.
                const cohortProcessedEvent = new CustomEvent("cohortprocessedevent", {
                    detail: message.data.payload.Program_Id__c
                });
                // Dispatches event.
                console.log('dispatching event');

                try{
                    that.dispatchEvent(cohortProcessedEvent);
                }catch(error){
                    console.log(error.message);
                }

                console.log('Event dispatched');

       });
    } else {
        /// Cannot handshake with the server, alert user.
        console.error('Error in handshaking: ' + JSON.stringify(status));
     }
   });
  }

  
}