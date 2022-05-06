public with sharing class cohortAssignmentController {

    @AuraEnabled(cacheable=true)
    public static List<Program__c> getPrograms() {
        return [SELECT Name, Type__c, Start_Date__c, End_Date__c, Cycle__c FROM Program__c ];
    }

    @AuraEnabled(cacheable=true)
    public static List<	Program_Participant__c> getFacilitators(Id programId) {
        return [SELECT Id, Name, Status__c, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, CreatedDate FROM Program_Participant__c Where Participant_Type__c = 'Facilitator' AND Program__c =: programId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Program_Participant__c> getFellows(Id programId) {
        return [SELECT Id, Name,Status__c, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, CreatedDate FROM Program_Participant__c Where Participant_Type__c = 'Fellow' AND Program__c =: programId];

    }

    @AuraEnabled(cacheable=true)
    public static List<	Program_Participant__c> getAllParticipants(Id programId) {
        return [SELECT Id, Name, Status__c, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, Participant_Type__c, CreatedDate FROM Program_Participant__c Where Program__c =: programId];

    }
    @AuraEnabled(cacheable=true)
    public static List<	Cohort__c> getAllCohorts(Id programId) {
        return [SELECT Id, Name, CreatedDate FROM Cohort__c Where Program__c =: programId ORDER BY Name ASC];

    }

    @AuraEnabled(cacheable=true)
    public static List<	Program_Participant__c> getAllCohortParticipants(Id cohortId) {
        return [SELECT Id, Name, Status__c, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, Participant_Type__c, CreatedDate FROM Program_Participant__c Where Cohort__c =: cohortId];

    }

    @AuraEnabled(cacheable=true)
    public static List<	Program_Participant__c> getUnmatchedParticipants(Id programId) {
        return [SELECT Id, Name, Status__c, Promisingness_Score__c, Interview_Score__c, General_Excitement_Level__c, Participant_Type__c, CreatedDate FROM Program_Participant__c Where Program__c =: programId AND Cohort__c = NULL];

    }

    @AuraEnabled(cacheable=true)
    public static void assignCohorts(List<String> fellowIds, List<String> facilitatorIds, Id programId, Integer maxCohortSize) {

       Program__c currentProgram = [SELECT Name, Id, Session_Length_In_Hours__c, Session_Length_In_Minutes__c FROM Program__c WHERE Id =: programId ];
       Integer sessionHours=currentProgram.Session_Length_In_Hours__c.intValue();
       Integer sessionMinutes=currentProgram.Session_Length_In_Minutes__c.intValue();

       cohortAssignmentQueuable assignmentQueuable= new cohortAssignmentQueuable(fellowIds, facilitatorIds, currentProgram.Id, maxCohortSize,sessionHours, sessionMinutes);
       system.enqueueJob(assignmentQueuable);

    }




}