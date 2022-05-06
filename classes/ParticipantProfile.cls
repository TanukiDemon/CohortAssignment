public with sharing class ParticipantProfile {

        Program_Participant__c participant;
        String Id;
        String Name;
        String ParticipantType;
        Integer PromisingnessScore;
        Integer InterviewScore;
        Integer GeneralExcitementLevel;

        public List<Availability__c> Availabilities;

        public ParticipantProfile(Program_Participant__c particpant, List<Availability__c> Availabilities){
            this.participant= particpant;
            //It's probably duplicative to have all of these extra 
            //class properties when the participant record stores them itself?
            this.Id = participant.Id;
            this.Name= participant.Name;
            this.ParticipantType= participant.Participant_Type__c;
            this.PromisingnessScore = Integer.valueof(participant.Promisingness_Score__c);
            this.InterviewScore= Integer.valueof(participant.Interview_Score__c);
            this.GeneralExcitementLevel= Integer.valueof(participant.General_Excitement_Level__c);
            this.Availabilities= Availabilities;
        }
    
}
