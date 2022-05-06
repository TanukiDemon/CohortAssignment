public with sharing class cohortAssignmentController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getFellowships() {
        return [SELECT Name, FirstName, LastName, Title, Phone, Email FROM Contact LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getPossibleFacilitators(Id fellowshipID) {
        return [SELECT Id, FirstName, LastName, Title, Phone, Email FROM Contact LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getPossibleParticipants(Id fellowshipID) {
        return [SELECT Id, FirstName, LastName, Title, Phone, Email FROM Contact LIMIT 10];
        /*
        { label: 'Name', fieldName: 'Name', editable: true },
        { label: 'Promisingness Score', fieldName: 'Promisingness_Score__c', editable: true },
        { label: 'Interview Score', fieldName: 'Interview_Score__c', type: 'url', editable: true },
        { label: 'General Excitement Level', fieldName: 'General_Excitement_Level__c', type: 'phone', editable: true },
        { label: 'Submission Date', fieldName: 'CreatedDate', type: 'phone', editable: false }
        */
    }


}