public with sharing class cohortAssignmentQueuable implements Queueable {
    
    public List<String> fellowIds;
    public List<String> facilitatorIds;
    public Id programId;
    public Integer maxCohortSize;
    public Integer numHours;
    public Integer numMinutes;


    public cohortAssignmentQueuable(List<String> fellowIds, List<String> facilitatorIds, Id programId, Integer maxCohortSize, Integer numHours, Integer numMinutes) {
        this.fellowIds= fellowIds;
        this.facilitatorIds= facilitatorIds;
        this.programId= programId;
        this.maxCohortSize= maxCohortSize;
        this.numHours= numHours;
        this.numMinutes= numMinutes;

    }


    public void execute(QueueableContext param1){

       Program__c currentProgram = [SELECT Name, Id, Session_Length_In_Minutes__c FROM Program__c WHERE Id =: programId ];
       
       //Pull the actual object records for our facilitators, fellows, and their availabilities
       //These queries and loops should be optimized so that they don't take as much CPU time
      List<Program_Participant__c> selectedFellows = [SELECT Id, Name, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, Participant_Type__c FROM Program_Participant__c WHERE ID IN: fellowIds ORDER BY Promisingness_Score__c,Interview_Score__c, General_Excitement_Level__c DESC NULLS LAST];
      List <Availability__c> fellowAvailabilities = [SELECT Id, Name, Program_Participant__c,Weekday__c, Availability_End_Time_Time_Field__c, Availability_Start_Time_Time_Field__c FROM Availability__c WHERE Program_Participant__c IN: selectedFellows ORDER BY Program_Participant__r.Promisingness_Score__c DESC NULLS LAST];
      
      List<Program_Participant__c> selectedFacilitators = [SELECT Id, Name, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, Participant_Type__c FROM Program_Participant__c WHERE ID IN: facilitatorIds ORDER BY Promisingness_Score__c,Interview_Score__c, General_Excitement_Level__c DESC NULLS LAST];
      List <Availability__c> facilitatorAvailabilities = [SELECT Id, Program_Participant__c, Name, Weekday__c, Availability_End_Time_Time_Field__c, Availability_Start_Time_Time_Field__c FROM Availability__c WHERE Program_Participant__c IN: selectedFacilitators ORDER BY Program_Participant__r.Promisingness_Score__c DESC NULLS LAST];

      Map<Availability__c, List<Availability__c>> matchingAvailabilities= new Map<Availability__c, List<Availability__c>>();       // Maybe just compare the availabilities straight up? Do you actually need all of this facilitator business? Maybe not!
       //Collect comleted facilitators and participants in lists that you can just check through once, and if they're there the you can skip the operation?
               for(Availability__c facAvail: facilitatorAvailabilities){
                   for(Availability__c fellAvail:fellowAvailabilities){
                       
                       Boolean availabilityMatches= ProgramParticipantManagement.compareAvailabilityOverlap(facAvail,fellAvail,numHours,numMinutes);
                           if(availabilityMatches){
                               System.debug('Two Availabilities Matched!: ' + facAvail.Id +' and '+ fellAvail.Id);
                               List<Availability__c> temp=  matchingAvailabilities.get(facAvail);
                               if(temp ==null){
                                    matchingAvailabilities.put(facAvail, new List<Availability__c>{fellAvail});
                                    System.debug('First availability inserted. Matchingavailabilities size is: ' + matchingAvailabilities.get(facAvail).size());

                               } else{
                                matchingAvailabilities.get(facAvail).add(fellAvail);
                                System.debug('Another availability was inserted. Matchingavailabilities size is: ' + matchingAvailabilities.get(facAvail).size());
                               }
                           }
                   }
               }
           
      Set<Id> matchedFacilitators = new Set<Id>();
      Set<Id> matchedFellows = new Set<Id>();
      Map<Id, List<Id>> completedCohorts= new Map<Id, List<Id>>();
      Map<Id, Id> fellToFacMap= new Map<Id, Id>();
               System.debug('Max cohort size is: ' + maxCohortSize);
      for(Availability__c facAvail: matchingAvailabilities.keySet()){
        if(matchingAvailabilities.get(facAvail).size()==maxCohortSize){
            List<Id> participantIDsForThisFacilitator= new List<Id>();

            if(!matchedFacilitators.contains(facAvail.Program_Participant__c)){
                for(Availability__c av: matchingAvailabilities.get(facAvail)){
                    fellToFacMap.put(av.Program_Participant__c,facAvail.Program_Participant__c);
                    System.debug('Put this fellow: ' + av.Program_Participant__c + ' to this fac: ' + facAvail.Program_Participant__c);
                    matchedFellows.add(av.Program_Participant__c);
                    participantIDsForThisFacilitator.add(av.Program_Participant__c);
                }
                matchedFacilitators.add(facAvail.Program_Participant__c);
            }
            completedCohorts.put(facAvail.Program_Participant__c, participantIDsForThisFacilitator);
        }
        //If this cohort is larger than the max cohort size, slice off the excess
        if(matchingAvailabilities.get(facAvail).size()>maxCohortSize){
            //Slice the matching availabilities down to the max cohort size
            List<Availability__c> avList = new List<Availability__c>(Utilities.avSlice(matchingAvailabilities.get(facAvail), 0, maxCohortSize));

            //Now proceed as above, with the smaller set of fellow availabilities
            matchingAvailabilities.put(facAvail, avList);
            List<Id> participantIDsForThisFacilitator= new List<Id>();

            if(!matchedFacilitators.contains(facAvail.Program_Participant__c)){
                for(Availability__c av: matchingAvailabilities.get(facAvail)){
                    fellToFacMap.put(av.Program_Participant__c,facAvail.Program_Participant__c);
                    System.debug('Put this fellow: ' + av.Program_Participant__c + ' to this fac: ' + facAvail.Program_Participant__c);
                    matchedFellows.add(av.Program_Participant__c);
                    participantIDsForThisFacilitator.add(av.Program_Participant__c);
                }
                matchedFacilitators.add(facAvail.Program_Participant__c);
            }
            completedCohorts.put(facAvail.Program_Participant__c, participantIDsForThisFacilitator);
        }
    }

    if(completedCohorts.size()>0){
    createCohorts(completedCohorts,fellToFacMap);
    }
    else {
        System.debug('CompletedCohorts is empty. No cohorts can be made');
    }
       System.debug('Printing cohorts: \n');

       for(Availability__c debugFac: matchingAvailabilities.keySet()){
           System.debug('Facilitator: ' + debugFac.Id);
           
           for(Availability__c debugFell: matchingAvailabilities.get(debugFac)){
               System.debug('Fellow: ' + debugFell.Id);                
           }
           System.debug('\n');
       }
       
       List<Cohort_Assignment_Completion__e> cohortCompletionList = new List<Cohort_Assignment_Completion__e>();
       Cohort_Assignment_Completion__e dmlAlert = new Cohort_Assignment_Completion__e(Program_Id__c=currentProgram.Id);
       cohortCompletionList.add(dmlAlert);
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(cohortCompletionList);

    }

    public static void createCohorts(Map<Id, List<Id>> completedCohorts, Map<Id, Id> fellToFacMap){
        List <Program_Participant__c> cohortFacilitators= [SELECT Id, Cohort__c, Program__c FROM Program_Participant__c WHERE Id IN: fellToFacMap.values()];
        //Map<Id,Program_Participant__c> facIdMap= new Map<Id,Program_Participant__c>(cohortFacilitators);
        List <Program_Participant__c> cohortFellows= [SELECT Id, Cohort__c  FROM Program_Participant__c WHERE Id IN: fellToFacMap.keySet()];
        Id programId= cohortFacilitators[0].Program__c;
        Map<Id,Id> facToCohortMap = new Map<Id,Id>();
        List<Program_Participant__c> recordsToUpdate= new List<Program_Participant__c>();
        List<Id> cohortKeySetToList = new List<Id>(completedCohorts.keySet());

        List<Cohort__c> cohortsToInsert= new List<Cohort__c>();

        Integer count=0;
        for (Id facId: completedCohorts.keyset()) {
            Cohort__c newCohort= new Cohort__c(Name='Cohort '+ (count+1), Facilitator_Group_Member_ID__c= facId, Program__c= programId,Status__c='Needs Review');
            count=count+1;
            cohortsToInsert.add(newCohort);
        }
        

        insert cohortsToInsert;

        //Map facilitators to the newly inserted cohorts
        for(Cohort__c insertedCohort: cohortsToInsert){
            facToCohortMap.put(insertedCohort.Facilitator_Group_Member_ID__c,insertedCohort.Id);
            System.debug('facToCohortMap put Fac: : ' + insertedCohort.Facilitator_Group_Member_ID__c + ' with cohort: ' + insertedCohort.Id);
        }

        //Update Facilitators with their cohorts
        for(Program_Participant__c facilitator: cohortFacilitators){
            facilitator.Cohort__c= facToCohortMap.get(facilitator.Id);
            facilitator.Status__c='Assigned to Cohort';
            recordsToUpdate.add(facilitator);
            System.debug('Updating Facilitator '+ facilitator.Id + 'with cohort: ' + facToCohortMap.get(facilitator.Id));

        }

        for(Program_Participant__c fellow: cohortFellows){
            fellow.Cohort__c= facToCohortMap.get(fellToFacMap.get(fellow.Id));
            fellow.Status__c='Assigned to Cohort';
            recordsToUpdate.add(fellow);
            System.debug('Updating Fellow '+ fellow.Id + 'with cohort: ' + facToCohortMap.get(fellToFacMap.get(fellow.Id)));

        }

        update recordsToUpdate;

    }
}
