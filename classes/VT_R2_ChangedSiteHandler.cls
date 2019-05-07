/**
* @author: Dmitry Prozorovskiy
* @date: 12-Feb-19
* @description: Class takes list of changed Cases, get PI and the PIs backup PI for each virtual site and updated them on the Case.
**/

public with sharing class VT_R2_ChangedSiteHandler {

    private List<Case> changedSiteCases;
    private Map<Id, Study_Team_Member__c> piBackupPIIdMap;
    private Map<Id, Virtual_Site__c> virtualSiteIdMap;

    public VT_R2_ChangedSiteHandler(List<Case> changedVirtualSiteCases) {
        this.changedSiteCases = changedVirtualSiteCases;
    }

    public void execute() {
        List<Id> virtualSiteIds = new List<Id>();
        List<String> stmIDs  = new List<String>();
        piBackupPIIdMap = new Map<Id, Study_Team_Member__c>();

        for (Case item : this.changedSiteCases) {
            if (item.VTD1_Virtual_Site__c != null) { virtualSiteIds.add(item.VTD1_Virtual_Site__c); }
        }

        this.virtualSiteIdMap = new Map<Id, Virtual_Site__c>([
                SELECT Id, VTD1_Study_Team_Member__c, VTD1_Study_Team_Member__r.User__c,
                        VTD1_Study_Team_Member__r.User__r.ContactId
                FROM Virtual_Site__c
                WHERE Id IN :virtualSiteIds
        ]);

        for (Virtual_Site__c virtualSite : virtualSiteIdMap.values()) {
            if(virtualSite.VTD1_Study_Team_Member__c != null) {
                stmIDs.add(virtualSite.VTD1_Study_Team_Member__c);
            }
        }

        piBackupPIIdMap = VT_D1_HelperClass.getBackupStmsForPIs(stmIDs);
        Virtual_Site__c site;

        for (Case item : this.changedSiteCases) {
            if (virtualSiteIdMap.containsKey(item.VTD1_Virtual_Site__c))
            {
                site  = this.virtualSiteIdMap.get(item.VTD1_Virtual_Site__c);
                item.VTD1_PI_contact__c = site.VTD1_Study_Team_Member__r.User__r.ContactId;
                if (this.piBackupPIIdMap.containsKey(site.VTD1_Study_Team_Member__c)) {
                    item.VTD1_Backup_PI_Contact__c = this.piBackupPIIdMap.get(site.VTD1_Study_Team_Member__c).User__r.ContactId;
                }
            }

            item.Patient_Transfer_Date__c = Date.today();
        }
    }
}