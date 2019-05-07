/**
* @author: Dmitry Prozorovskiy
* @date: 26-Mar-19
* @description: Used to get access tokens and base URIs for Docusign
**/

trigger VT_R2_AssignmentHistoryTrigger on VTD1_Assignment_History__c (after insert, after update, after delete, after undelete) {

    VT_R2_AssignmentHistoryTriggerHandler handler = new VT_R2_AssignmentHistoryTriggerHandler();

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            handler.onAfterDelete(Trigger.old);
        }

        if (Trigger.isUndelete) {
            handler.onAfterUndelete(Trigger.new);
        }

        if(trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
