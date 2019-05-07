/**
 * Created by Dmitry Prozorovskiy on 3/26/2019.
 */
public without sharing class VT_R2_AssignmentHistoryTriggerHandler {

    public void onAfterInsert(List<VTD1_Assignment_History__c> recs) {

        rollupAssignmentHistory(recs);
    }

    public void onAfterUpdate(List<VTD1_Assignment_History__c> recs, Map<Id, VTD1_Assignment_History__c> oldMap) {
        List<VTD1_Assignment_History__c> newAssignmentHistoriesList = new List<VTD1_Assignment_History__c>();
        VTD1_Assignment_History__c oldAssignmentHistory;

        for(VTD1_Assignment_History__c assignmentHistory : recs)
        {
            oldAssignmentHistory = oldMap.get(assignmentHistory.Id);
            if(assignmentHistory.Assignment_History_Status__c != oldAssignmentHistory.Assignment_History_Status__c)
            {
                newAssignmentHistoriesList.add(oldAssignmentHistory);
            }
        }

        if (! newAssignmentHistoriesList.isEmpty()) { rollupAssignmentHistory(newAssignmentHistoriesList); }
    }

    public void onAfterDelete(List<VTD1_Assignment_History__c> recs) {
        rollupAssignmentHistory(recs);
    }

    public void onAfterUndelete(List<VTD1_Assignment_History__c> recs) {
        rollupAssignmentHistory(recs);
    }

    public void rollupAssignmentHistory(List<VTD1_Assignment_History__c> recs) {
        Set<Id> pgCapacityIds = new Set<Id>();

        for (VTD1_Assignment_History__c assignmentHistory : recs) {
            if ( assignmentHistory.VTR2_PatientGuideCapacity__c != null) {
                pgCapacityIds.add(assignmentHistory.VTR2_PatientGuideCapacity__c);
            }
        }

        if (! pgCapacityIds.isEmpty()) {
            Map<Id, Integer> assignmentHistoryMap = new Map<Id, Integer>();

            for (AggregateResult aggRes : [
                SELECT VTR2_PatientGuideCapacity__c, COUNT(Id) numofAssignmentHistory FROM VTD1_Assignment_History__c
                WHERE VTR2_PatientGuideCapacity__c IN:pgCapacityIds AND Assignment_History_Status__c = 'Current'
                GROUP BY VTR2_PatientGuideCapacity__c
            ]) {
                Id pgCapId = (Id) aggRes.get('VTR2_PatientGuideCapacity__c');
                Integer numofAssignHistory = (Integer) aggRes.get('numofAssignmentHistory');
                assignmentHistoryMap.put(pgCapId, numofAssignHistory);
            }

            List<VTD1_Patient_Guide_Capacity__c> pgCapacityResultList = new List<VTD1_Patient_Guide_Capacity__c>();
            for (Id pgCapId : pgCapacityIds) {
                pgCapacityResultList.add(new VTD1_Patient_Guide_Capacity__c(
                    Id = pgCapId,
                    VTR2_Rollup_Assignment_History__c = assignmentHistoryMap.containsKey(pgCapId) ? assignmentHistoryMap.get(pgCapId) : 0
                ));
            }
            if (!pgCapacityResultList.isEmpty()) {
                update pgCapacityResultList;
            }
        }
    }
}