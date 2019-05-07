/**
* @author: Dmitry Prozorovskiy
* @date: 18-Feb-19
* @description: Reassign All Ope Tasks To New PI
**/

public with sharing class VT_R2_ChangedPITaskReassigner {
    private List<Case> changedCases;
    private Map<Id, Id> caseIdPrimaryPIMap;
    private List<Task> taskList;

    public VT_R2_ChangedPITaskReassigner(List<Case> changedCases) {
        this.changedCases = changedCases;
    }

    public void execute() {
        caseIdPrimaryPIMap = new Map<Id,Id>();

        for (Case item : this.changedCases) {
            this.caseIdPrimaryPIMap.put(item.Id, item.VTD1_PI_user__c);
        }

        this.taskList  = new List<Task>([
                SELECT Id, OwnerId, WhatId, VTD1_Case_lookup__c FROM Task
                WHERE (WhatId IN :caseIdPrimaryPIMap.keySet() OR
                VTD1_Case_lookup__c IN:caseIdPrimaryPIMap.keySet()) AND
                Owner.Profile.Name = 'Primary Investigator' AND
                IsClosed = false
        ]);

        Id caseId;
        for(Task item : taskList) {
            if(item.WhatId == null) {caseId = item.VTD1_Case_lookup__c;}
            else {caseId = item.WhatId;}
            if (caseIdPrimaryPIMap.containsKey(caseId)) {
                item.OwnerId = caseIdPrimaryPIMap.get(caseId);
            }
        }
        update taskList;
    }
}