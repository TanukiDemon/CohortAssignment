@isTest
public with sharing class cohortAssignmentController_TEST {
    
    @isTest
    static void testTimeOverlapCheck(){
        
        
        Program__c testProgram = new Program__c();
        Insert testProgram;

        Program_Participant__c testParticipant = new Program_Participant__c(
        Program__c= testProgram.Id,
        Name='Test Record',        
        Status__c='Awaiting Cohort Assignment',
        Promisingness_Score__c='8',
        Interview_Score__c='7',
        General_Excitement_Level__c='5');

        Insert testParticipant;

        List<Availability__c> availabilityList= new List<Availability__c>();
        //All availabilities will be compared to this first one to determine if they have both 
        //A) Overlap in time and B) A sufficiently long overlap for the program to take place (in this case 1 hour and 30 minutes)
        Availability__c testAvailability1= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(13, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(16, 0, 0, 0));
        availabilityList.add(testAvailability1);
        //This time is WITHIN the first availability, should pass
        Availability__c testAvailability2= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(14, 30, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(16, 0, 0, 0));
        availabilityList.add(testAvailability2);
        //This starts before the first availability and ends within it, with enough time for a session        
        Availability__c testAvailability3= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(11, 30, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 30, 0, 0));
        availabilityList.add(testAvailability3);     
        //This starts within the first availability and ends outside it, with enough time for a session   
        Availability__c testAvailability4= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(14, 30, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability4);     
        //This is on the same day but has no overlap, so should fail   
        Availability__c testAvailability5= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(04, 00, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(7, 0, 0, 0));
        availabilityList.add(testAvailability5);     
        //Different day; should fail   
        Availability__c testAvailability6= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(13, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(16, 0, 0, 0));
        availabilityList.add(testAvailability6);
        //Same day and overlaps first availability, but without enough time. Should fail.
        Availability__c testAvailability7= new Availability__c(Program_Participant__c= testParticipant.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(15, 30, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability7);

        
        Insert availabilityList;

    
        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability2,1,30));
        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability3,1,30));
        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability4,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability5,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability6,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability1,testAvailability7,1,30));

        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability2,testAvailability1,1,30));
        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability3,testAvailability1,1,30));
        System.assertEquals(true, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability4,testAvailability1,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability5,testAvailability1,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability6,testAvailability1,1,30));
        System.assertEquals(false, ProgramParticipantManagement.compareAvailabilityOverlap(testAvailability7,testAvailability1,1,30));  
    }

    @isTest
    static void firstAssignmentCheck(){
        Program__c testProgram = new Program__c();
        Insert testProgram;
        List<Availability__c> availabilityList= new List<Availability__c>();


        Program_Participant__c f1 = new Program_Participant__c( Program__c= testProgram.Id, Name='Facilitator1', Participant_Type__c = 'Facilitator', Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert f1;
        Availability__c testAvailability1= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability1);
        Availability__c testAvailability2= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability2);
        Availability__c testAvailability3= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(13, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability3);
        Availability__c testAvailability4= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability4);
        Availability__c testAvailability5= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Wednesday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability5);
        Availability__c testAvailability6= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability6);
        Availability__c testAvailability7= new Availability__c(Program_Participant__c= f1.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability7);

        Program_Participant__c f2 = new Program_Participant__c( Program__c= testProgram.Id, Name='Facilitator2', Participant_Type__c = 'Facilitator',  Promisingness_Score__c='10', Interview_Score__c='9', General_Excitement_Level__c='9');
        Insert f2;
        Availability__c testAvailability8= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(1, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(3, 0, 0, 0));
        availabilityList.add(testAvailability8);
        Availability__c testAvailability9= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(11, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(13, 0, 0, 0));
        availabilityList.add(testAvailability9);
        Availability__c testAvailability10= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability10);
        Availability__c testAvailability11= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Wednesday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability11);
        Availability__c testAvailability12= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(8, 0, 0, 0));
        availabilityList.add(testAvailability12);
        Availability__c testAvailability13= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Friday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability13);
        Availability__c testAvailability14= new Availability__c(Program_Participant__c= f2.Id, Name='TimeRecord',Weekday__c='Saturday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability14);
        


        Program_Participant__c f3 = new Program_Participant__c( Program__c= testProgram.Id, Name='Facilitator3', Participant_Type__c = 'Facilitator',  Promisingness_Score__c='8', Interview_Score__c='8', General_Excitement_Level__c='8');
        Insert f3;
        Availability__c testAvailability15= new Availability__c(Program_Participant__c= f3.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(7, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(10, 0, 0, 0));
        availabilityList.add(testAvailability15);        
        Availability__c testAvailability16= new Availability__c(Program_Participant__c= f3.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(13, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability16);          
        Availability__c testAvailability17= new Availability__c(Program_Participant__c= f3.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability17);          
        Availability__c testAvailability18= new Availability__c(Program_Participant__c= f3.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(19, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(20, 0, 0, 0));
        availabilityList.add(testAvailability18);          
        Availability__c testAvailability19= new Availability__c(Program_Participant__c= f3.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability19);  

        //Supposed to make up our first Cohort
        Program_Participant__c s1 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student1', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s1;
        Availability__c testAvailability20= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability20);  
        Availability__c testAvailability21= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(15, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(16, 0, 0, 0));
        availabilityList.add(testAvailability21);
        Availability__c testAvailability22= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability22);
        Availability__c testAvailability23= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(15, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(17, 0, 0, 0));
        availabilityList.add(testAvailability23);        
        Availability__c testAvailability24= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability24);        
        Availability__c testAvailability25= new Availability__c(Program_Participant__c= s1.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(15, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability25);

        Program_Participant__c s2 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student2', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s2;
        Availability__c testAvailability26= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability26);
        Availability__c testAvailability27= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(8, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability27);
        Availability__c testAvailability28= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability28);
        Availability__c testAvailability29= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability29);
        Availability__c testAvailability30= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Wednesday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability30);
        Availability__c testAvailability31= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Friday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability31);
        Availability__c testAvailability32= new Availability__c(Program_Participant__c= s2.Id, Name='TimeRecord',Weekday__c='Saturday', Availability_Start_Time_Time_Field__c=Time.newInstance(16, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(18, 0, 0, 0));
        availabilityList.add(testAvailability32);


        Program_Participant__c s3 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student3', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s3;
        Availability__c testAvailability33= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability33);        
        Availability__c testAvailability34= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(8, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(9, 0, 0, 0));
        availabilityList.add(testAvailability34);        
        Availability__c testAvailability35= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(10, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(12, 0, 0, 0));
        availabilityList.add(testAvailability35);        
        Availability__c testAvailability36= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(11, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(12, 0, 0, 0));
        availabilityList.add(testAvailability36);
        Availability__c testAvailability37= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Wednesday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability37);
        Availability__c testAvailability38= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability38);
        Availability__c testAvailability39= new Availability__c(Program_Participant__c= s3.Id, Name='TimeRecord',Weekday__c='Friday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability39);



        Program_Participant__c s4 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student4', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s4;
        Availability__c testAvailability40= new Availability__c(Program_Participant__c= s4.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability40);  

        Program_Participant__c s5 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student5', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s5;
        Availability__c testAvailability41= new Availability__c(Program_Participant__c= s5.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability41);  

        Program_Participant__c s6 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student6', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s6;
        Availability__c testAvailability42= new Availability__c(Program_Participant__c= s6.Id, Name='TimeRecord',Weekday__c='Monday', Availability_Start_Time_Time_Field__c=Time.newInstance(3, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(5, 0, 0, 0));
        availabilityList.add(testAvailability42);  

        //Supposed to make up our second Cohort
        Program_Participant__c s7 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student7', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s7;
        Availability__c testAvailability43= new Availability__c(Program_Participant__c= s7.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability43);
        Program_Participant__c s8 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student8', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s8;
        Availability__c testAvailability44= new Availability__c(Program_Participant__c= s8.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability44);
        Program_Participant__c s9 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student9', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s9;
        Availability__c testAvailability46= new Availability__c(Program_Participant__c= s9.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability46);
        Program_Participant__c s10 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student10', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s10;
        Availability__c testAvailability47= new Availability__c(Program_Participant__c= s10.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability47);
        Program_Participant__c s11 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student11', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s11;
        Availability__c testAvailability48= new Availability__c(Program_Participant__c= s11.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability48);
        Program_Participant__c s12 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student12', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s12;
        Availability__c testAvailability49= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Tuesday', Availability_Start_Time_Time_Field__c=Time.newInstance(9, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(11, 0, 0, 0));
        availabilityList.add(testAvailability49);

        //Supposed to make up our third Cohort
        Program_Participant__c s13 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student13', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s13;
        Availability__c testAvailability50= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability50);

        Program_Participant__c s14 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student14', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s14;
        Availability__c testAvailability51= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability51);

        Program_Participant__c s15 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student15', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s15;
        Availability__c testAvailability53= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability53);

        Program_Participant__c s16 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student16', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s16;
        Availability__c testAvailability54= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability54);

        Program_Participant__c s17 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student17', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s17;
        Availability__c testAvailability55= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability55);

        Program_Participant__c s18 = new Program_Participant__c( Program__c= testProgram.Id, Name='Student18', Participant_Type__c = 'Fellow',  Promisingness_Score__c='10', Interview_Score__c='10', General_Excitement_Level__c='10');
        Insert s18;
        Availability__c testAvailability56= new Availability__c(Program_Participant__c= s12.Id, Name='TimeRecord',Weekday__c='Thursday', Availability_Start_Time_Time_Field__c=Time.newInstance(12, 0, 0, 0),Availability_End_Time_Time_Field__c= Time.newInstance(14, 0, 0, 0));
        availabilityList.add(testAvailability56);

        insert availabilityList;

        List<Program_Participant__c> selectedFellows = [SELECT Id FROM Program_Participant__c WHERE Participant_Type__c= 'Fellow'];        
        List<Program_Participant__c> selectedFacilitators = [SELECT Id FROM Program_Participant__c WHERE Participant_Type__c= 'Facilitator'];
 
        List<String> fellowIds= new List<String>();
        for(Program_Participant__c fell: selectedFellows){
            fellowIds.add(fell.Id);
        }
        List<String> facilitatorIds= new List<String>();
        for(Program_Participant__c fac: selectedFacilitators){
            facilitatorIds.add(fac.Id);
        }
        Test.startTest();
        cohortAssignmentQueuable testQueuable= new cohortAssignmentQueuable(fellowIds, facilitatorIds, testProgram.Id, 6,1,30);
        system.enqueueJob(testQueuable);
        Test.stopTest();

        List<Cohort__c> generatedCohorts= [SELECT ID FROM Cohort__c];

        System.assertEquals(3, generatedCohorts.size());

    }

    public cohortAssignmentController_TEST() {

    }
}
