/**
* @author: Dmitry Prozorovskiy
* @date: 25-Jan-19
* @description: Test for visit request process
**/

@IsTest
public class VT_D2_VisitRequestTest {

    @TestSetup
    private static void setupMethod() {
        HealthCloudGA__CarePlanTemplate__c study = VT_D1_TestUtils.prepareStudy(1);

        Test.startTest();
        VT_D1_TestUtils.createTestPatientCandidate(1);
        Test.stopTest();

        Case carePlan = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'CarePlan' ORDER BY CreatedDate DESC LIMIT 1];

        VTD1_ProtocolVisit__c pVisit = new VTD1_ProtocolVisit__c();
        insert pVisit;
        VTD1_Actual_Visit__c visit = new VTD1_Actual_Visit__c(VTD1_Case__c = carePlan.Id, VTD1_Protocol_Visit__c = pVisit.Id);
        insert visit;

        List<VTD2_Time_Slot__c> slots = new List<VTD2_Time_Slot__c>();
        for (Integer i = 1; i <= 3; i++) {
            slots.add(new VTD2_Time_Slot__c(
                VTD2_Actual_Visit__c = visit.Id,
                VTD2_Timeslot_Date_Time__c = Datetime.now().addHours(i),
                VTD2_Status__c = 'Proposed'
            ));
        }
        insert slots;

        insert new Task(
            WhatId = visit.Id,
            VTD1_Actual_Visit__c = visit.Id
        );
    }

    @IsTest
    private static void doTest() {
        Test.startTest();
        VTD1_Actual_Visit__c visit = [SELECT Id FROM VTD1_Actual_Visit__c];
        visit.VTD1_Status__c = VT_D1_ConstantsHelper.ACTUAL_VISIT_STATUS_REQUESTED;
        update visit;

        VTD2_Time_Slot__c slot = [SELECT Id FROM VTD2_Time_Slot__c ORDER BY CreatedDate DESC LIMIT 1];

        VT_D2_VisitRequestConfirmationController controller = new VT_D2_VisitRequestConfirmationController();
        ApexPages.currentPage().getParameters().put('id',slot.Id);
        ApexPages.currentPage().getParameters().put('action', controller.getSchedule_action());

        controller.onLoad();
        controller.onLoad(); // run a second time to cover already scheduled scenario

        ApexPages.currentPage().getParameters().put('action', VT_D2_VisitRequestConfirmationController.RESCHEDULE_ACTION);
        controller.onLoad();
        Test.stopTest();
    }
}