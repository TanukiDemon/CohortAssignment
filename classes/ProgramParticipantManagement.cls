public with sharing class ProgramParticipantManagement {
    public ProgramParticipantManagement() {

    }


    public static Boolean compareAvailabilityOverlap(Availability__c firstAvailability, Availability__c secondAvailability, Integer fellowshipHours, Integer fellowshipMinutes){
        Boolean availabilityOverlaps = false;
        Boolean sufficientTime=false;

            //Time logic is similar to the date range overlap found here: https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
            //Obviously the weekday must be the same
            //If the start range of a given availability is earlier OR EQUAL to the start range of another, AND the end range of that availability goes into the 
            //other availability for at least the amount of time of the fellowship, then they have overlap. 
            //This should be compared both ways; i.e. check firstAvailability overlapping secondAvailability and then secondAvailability overlapping firstAvailability
            if (firstAvailability.Weekday__c != secondAvailability.Weekday__c) {
                return false;
            }

            Time fEnd= firstAvailability.Availability_End_Time_Time_Field__c;
            Time sStart= secondAvailability.Availability_Start_Time_Time_Field__c;

            Time fStart= firstAvailability.Availability_Start_Time_Time_Field__c;
            Availability__c tempAvailability = new Availability__c();

            //Need to ensure that the first availabilities start time is before or equal to the second availabilities start time
            if(fStart > sStart){
                tempAvailability = firstAvailability;
                firstAvailability= secondAvailability;
                secondAvailability = tempAvailability;

                fEnd= firstAvailability.Availability_End_Time_Time_Field__c;
                sStart= secondAvailability.Availability_Start_Time_Time_Field__c;
            }

            Integer timeDifference= (fEnd.hour() * 60 + fEnd.minute()) - (sStart.hour() * 60 + sStart.minute());
            Integer timeRequired= (fellowshipHours*60) + fellowshipMinutes;

            sufficientTime=(timeRequired<= timeDifference);


            
            if((firstAvailability.Availability_Start_Time_Time_Field__c<= secondAvailability.Availability_End_Time_Time_Field__c) && firstAvailability.Availability_End_Time_Time_Field__c>= secondAvailability.Availability_Start_Time_Time_Field__c){
                availabilityOverlaps=true;
            }
            if((secondAvailability.Availability_Start_Time_Time_Field__c<= firstAvailability.Availability_End_Time_Time_Field__c) && secondAvailability.Availability_End_Time_Time_Field__c>= firstAvailability.Availability_Start_Time_Time_Field__c){
                availabilityOverlaps=true;
            }
            return availabilityOverlaps && sufficientTime; 
    }

    public static List <ParticipantProfile> convertToParticipantProfiles(List<Program_Participant__c> participantList, List<Availability__c> availabilityList){

        List<ParticipantProfile> returnedProfiles= new List<ParticipantProfile>();

        for (Program_Participant__c fellow : participantList) {
            List<Availability__c> availabilities = new List<Availability__c>();

            for(Availability__c av : availabilityList){
                if (av.Program_Participant__c == fellow.Id) {
                    availabilities.add(av);
                }
            }

            returnedProfiles.add(new ParticipantProfile(fellow, availabilities));
        
        }

        return returnedProfiles;
    }
    /*Public List <Cohort__c> cohortAssigner(List<ParticipantProfile> facilitators, List<ParticipantProfile> fellows){
        

    }*/
}


