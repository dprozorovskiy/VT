/**
* @author: Dmitry Prozorovskiy
* @date: 08-May-19
* @description: Test class for VT_D2_EmailController
**/

@IsTest
public class VT_D2_EmailControllerTest {
    @TestSetup
    private static void setupMethod() {
        HealthCloudGA__CarePlanTemplate__c study = VT_D1_TestUtils.prepareStudy(1);
        Test.startTest();
        VT_D1_TestUtils.createTestPatientCandidate(1);
        Test.stopTest();

        VTD2_Study_Geography__c studyGeography = new VTD2_Study_Geography__c(VTD2_Study__c = study.Id, Name='Geo');
        insert studyGeography;

        VTR2_StudyPhoneNumber__c phoneNumber = new VTR2_StudyPhoneNumber__c(VTR2_Study__c = study.Id, VTR2_Study_Geography__c = studyGeography.Id, Name ='8888888888');
        insert phoneNumber;

        Case carePlan = [
            SELECT Id, VTR2_StudyPhoneNumber__c, VTD1_Patient_User__c
            FROM Case
            WHERE RecordType.DeveloperName = 'CarePlan'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        carePlan.VTR2_StudyPhoneNumber__c = phoneNumber.Id;
        update carePlan;
    }
    @IsTest
    private static void  testBehavior() {
        Test.startTest();
        Case carePlan = [
            SELECT Id, VTD2_Study_Phone_Number__c, VTD1_Patient_User__c
            FROM Case
            WHERE RecordType.DeveloperName = 'CarePlan'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        VT_D2_EmailController controller = new VT_D2_EmailController();
        controller.usrId = carePlan.VTD1_Patient_User__c;

        User patientUser = [SELECT Id, FirstName, LastName, Contact.Account.Candidate_Patient__r.Study__r.VTD1_Protocol_Nickname__c
                            FROM User
                            WHERE Id = :carePlan.VTD1_Patient_User__c];

        System.assertEquals(VTD1_RTId__c.getInstance().PI_URL__c, controller.getCommunityPatientUrl());
        System.assertEquals(VTD1_RTId__c.getInstance().PI_URL__c, controller.getCommunityPiUrl());
        System.assertEquals(carePlan.VTD2_Study_Phone_Number__c, controller.getStudyPhoneNumber());
        System.assertEquals(patientUser.FirstName, controller.getFirstNameWelcome());
        System.assertEquals(patientUser.LastName, controller.getLastNameWelcome());
        System.assertEquals(patientUser.Contact.Account.Candidate_Patient__r.Study__r.VTD1_Protocol_Nickname__c, controller.getStudyNickname());
        Test.stopTest();
    }
}