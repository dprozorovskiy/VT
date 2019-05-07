/*
 * Created by Michael Dmitry Prozorovskiy on 07.08.2018.
 */
public class VT_D2_EmailController {
    private User currentUser;
	public  Id usrId {get; set;}
    public String getStudyPhoneNumber() {
        return [SELECT Id, VTD2_Study_Phone_Number__c FROM Case WHERE VTD1_Patient_User__c = :usrId].VTD2_Study_Phone_Number__c;
    }
    public String getCommunityPatientUrl() {
        return VTD1_RTId__c.getInstance().VTD2_Patient_Community_URL__c;
    }
    public String getCommunityPiUrl() {
        return VTD1_RTId__c.getInstance().PI_URL__c;
    }
    public String getFirstNameWelcome() {
        return getUserInfo().FirstName;
    }
    public String getLastNameWelcome() {
        return getUserInfo().LastName;
    }
    public String getStudyNickname() {
        return getUserInfo().Contact.Account.Candidate_Patient__r.Study__r.VTD1_Protocol_Nickname__c;
    }
    private User getUserInfo() {
        if(currentUser == null) {
            currentUser = [SELECT Id, FirstName, LastName, Contact.Account.Candidate_Patient__r.Study__r.VTD1_Protocol_Nickname__c
            FROM User WHERE Id = :usrId];
        }
        return currentUser;
    }
}