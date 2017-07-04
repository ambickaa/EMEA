//-------------------------------------------------------
// Apex class	AccountPageVouchersController
// Test class	AccountPageVouchersController_Test
// Author		Support Team
// Last update	30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageVouchersController {

//-------------------------------------------------------
// Initialization of the list of displayed records
// retrieved from the method getRecords().
//-------------------------------------------------------
    public List<Voucher__c> List_Records {
        get {
            if(List_Records == null) {
                getRecords();
            }
            return List_Records;
        }
        private set;
    }

//-------------------------------------------------------
// Method to retrieve all the reports available.
//-------------------------------------------------------
    public List<Report> availableReports {
    	get {
    		if(availableReports == null)
    			availableReports = [SELECT Id, Name FROM Report WHERE DeveloperName LIKE 'AccountPage_Vouchers_%' ORDER BY LastModifiedDate DESC];
    		return availableReports;
    	} 
    	protected set;
    }

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
    	return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}

//-------------------------------------------------------
// Apex class constructor, calling the empty ini() method.
//-------------------------------------------------------
    public AccountPageVouchersController()
    {
        ini();
    }

//-------------------------------------------------------
// Initial empty method.
//-------------------------------------------------------
    private void ini()
    {
        system.debug('***INI: AccountPageVouchersController');
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
// Even though the Visualforce component is usually not rendered for distributor accounts,
// the method takes into account this possibility and it would only show the vouchers on the
// current account and also on the current campaign.
//-------------------------------------------------------
    private void getRecords()
    {
    	List_Records = new List<Voucher__c>();
    	
    	String q = '';
    	
        q += 'SELECT Id, Name, CampaignRef__r.DivisionRef__r.Name, CreatedBy.Name, CreatedDate, LastModifiedDate, Status__c,';
        q += ' AccountRef__c, FarmNameCopy__c, DistributorRef__c, DistributorNameCopy__c, Signed__c, sentMail__c,';
        q += ' TotalBags__c, TotalBagsFOC__c, (SELECT Id, Name FROM Attachments ORDER BY bodylength DESC)';
        q += ' FROM Voucher__c';
//-------------------------------------------------------
// The query is different for farms and distributors.
//-------------------------------------------------------
        if(isFarmAccount)
        	q += ' WHERE AccountRef__c = \'' + Util.currentAccount.Id + '\' ORDER BY CreatedDate DESC, Status__c DESC';
        if(isDistAccount && Util.currentCampaign != null)
        	q += ' WHERE DistributorRef__c = \'' + Util.currentAccount.Id + '\' AND CampaignRef__c = \'' + Util.currentCampaign.Id + '\' ORDER BY CreatedDate DESC, Status__c DESC';
//-------------------------------------------------------
// The list of records is populated only when the current account
// is a farm or a distributor with an existent current campaign.
//-------------------------------------------------------
		if(isFarmAccount || (isDistAccount && Util.currentCampaign != null))
        	List_Records = (List<Voucher__c>)Database.query(q);
    }

}