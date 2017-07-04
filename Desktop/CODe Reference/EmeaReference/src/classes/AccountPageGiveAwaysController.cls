//-------------------------------------------------------
// Apex class	AccountPageGiveAwaysController
// Test class	AccountPageGiveAwaysController_Test
// Author		Support Team
// Last update	30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageGiveAwaysController {

//-------------------------------------------------------
// Getting the set of fields to display for the records.
//-------------------------------------------------------
    public List<Schema.FieldSetMember> FieldSet_Component
    {
        get {
			if(FieldSet_Component == null)
			{
//-------------------------------------------------------
// A different fieldSet is obtained based on the type of
// the account and the country of the current user.
//-------------------------------------------------------
	            String AccountType = '';
	            if(isFarmAccount) AccountType = '_Farm_';
	            if(isDistAccount) AccountType = '_Dist_';
	            
				//system.debug('!Util.currentUser.CountryISOCode__c: ' + Util.currentUser.CountryISOCode__c);
				//system.debug('!Util.countryView.country.TXT_Country_ISO_Code__c: ' + Util.countryView.country.TXT_Country_ISO_Code__c);
		
				String countryISO = Util.countryView.country.TXT_Country_ISO_Code__c != null ? Util.countryView.country.TXT_Country_ISO_Code__c : (Util.currentUser.CountryISOCode__c != null ? Util.currentUser.CountryISOCode__c : '');
			  
	            if(countryISO != '')
	            {
	                if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_GiveAways' + AccountType + countryISO) != null)
	                    FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_GiveAways' + AccountType + countryISO).getFields();
	                else
	                    FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_GiveAways' + AccountType + 'Default').getFields();
	            } else {
	                FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_GiveAways' + AccountType + 'Default').getFields();
	            }
			}
            return FieldSet_Component;
        } protected set;
    }

//-------------------------------------------------------
// Initialization of the list of displayed records retrieved
// from the method getRecords() and other important maps and lists.
//-------------------------------------------------------
    public List<CampaignLineItem__c> List_Records {
        get {
            if(List_Records == null) {
                getRecords();
            }
            return List_Records;
        }
        private set;
    }
    private List<String> List_Records_Selected = new List<String>();
    private Map<Id, CampaignLineItem__c> Map_Records;

//-------------------------------------------------------
// Initialization of the list of records added by the product picker.
//-------------------------------------------------------
    public List<CampaignLineItem__c> List_Records_add {get; private set;}

//-------------------------------------------------------
// Initialization of the related catalogue for Give Aways.
//-------------------------------------------------------
    public transient Id Id_ProductCatalogue {get; private set;}

//-------------------------------------------------------
// Method to retrieve all the reports available.
//-------------------------------------------------------
    public List<Report> availableReports {
    	get {
    		if(availableReports == null)
    			availableReports = [SELECT Id, Name FROM Report WHERE DeveloperName LIKE 'AccountPage_GiveAways_%' ORDER BY LastModifiedDate DESC];
    		return availableReports;
    	} 
    	protected set;
    }

//-------------------------------------------------------
// Method to retrieve the current campaign for the Visualforce component.
//-------------------------------------------------------
    public Campaign currentCampaign {
    	get {
    		if(currentCampaign == null && Util.currentCampaign != null)
    			currentCampaign = Util.currentCampaign;
    		return currentCampaign;
    	} 
    	private set;
    }

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean modeAdd {get; set;}
    public Boolean modeNew {get; set;}
    public Boolean modeEdit {get; set;}
    public Boolean showGiveAwaysMessages {get; set;}
    public Boolean isOwner {get { return Util.isAccountOwner; } protected set;}
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
    	return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}

//-------------------------------------------------------
// Apex class constructor, calling the ini() method.
//-------------------------------------------------------
    public AccountPageGiveAwaysController()
    {
        ini();
    }

//-------------------------------------------------------
// Initial method that initializes some variables.
//-------------------------------------------------------
    private void ini()
    {
        system.debug('***INI: AccountPageGiveAwaysController');
        
        List_Records_add = new List<CampaignLineItem__c>();
        showGiveAwaysMessages = modeAdd = modeNew = modeEdit = false;
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
//-------------------------------------------------------
    private void getRecords()
    {
        Map_Records = new Map<Id, CampaignLineItem__c>();
        List_Records = new List<CampaignLineItem__c>();
        
        String q = 'SELECT Id, Name, ProductRef__r.Name';
//-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
        for(Schema.FieldSetMember f : FieldSet_Component)
        {
            if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Name' && f.getFieldPath() != 'ProductRef__r.Name')
                q += ', ' + f.getFieldPath();
        }
        q += ' FROM CampaignLineItem__c';
        q += ' WHERE FarmRef__c = \'' + Util.currentAccount.Id + '\'';
        q += ' AND ProductRef__c != null';
        q += ' AND CampaignRef__r.StatusCode__c = 200';
        q += ' AND CampaignRef__r.DivisionRef__c = \'' + Util.currentDivision.Id + '\'';
        q += ' AND RecordTypeId = \'' + Util.recordType.get('CampaignLineItem__c:GiveAway') + '\'';

        List_Records = (List<CampaignLineItem__c>)Database.query(q);
//-------------------------------------------------------
// Key map to recover data on update/insert actions.
//-------------------------------------------------------
        for(CampaignLineItem__c r : List_Records)
            Map_Records.put(r.Id, r);
    }

//-------------------------------------------------------
// Method to create virtual records that can be inserted
// based on the products selected from the product picker.
//-------------------------------------------------------
    private void getNew()
    {
//-------------------------------------------------------
// The current user is allowed to insert data only when
// it is related to an active campaign.
//-------------------------------------------------------
    	if(Util.currentCampaign != null)
    	{
            if(List_Records_Selected != null && List_Records_Selected.size() > 0)
            {
		    	for(String s : List_Records_Selected)
		    	{
		    		String Id0 = s.split('/')[0];
		    		String Id1 = s.split('/')[1];
			    	List_Records_add.add(
			    		new CampaignLineItem__c(
			    			RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway'),
			    			FarmRef__c = Util.currentAccount.Id,
			    			ProductRef__c = Id0,
			    			ProductCatalogEntryRef__c = Id1,
			    			CampaignRef__c = Util.currentCampaign.Id,
			    			OwnerId = Util.currentUser.Id
			    		)
			    	);
		    	}
            }
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_active_campaign));
    		
    		modeAdd = modeNew = modeEdit = false;
    		showGiveAwaysMessages = true;
    	}
    }

//-------------------------------------------------------
// Methods to retrieve the selected records from the Visualforce component.
//-------------------------------------------------------
    public void setRows(String recordsId)
    {
        List_Records_Selected = (recordsId != '' && recordsId != null) ? recordsId.split(',') : null;
    }
    public List<String> getRows()
    {
        return List_Records_Selected;
    }

//-------------------------------------------------------
// Method to delete the selected records from the Visualforce component.
// It is only handled if the list of selected records is not empty.
//-------------------------------------------------------
    public void doDelete()
    {
        if(List_Records_Selected != null && List_Records_Selected.size() > 0)
        {
            List<CampaignLineItem__c> List_Records_tmp = new List<CampaignLineItem__c>();
//-------------------------------------------------------
// It gets the records from the key map when they are selected.
//-------------------------------------------------------
            for(String Id : List_Records_Selected)
            {
                if(Map_Records.containsKey(Id))
                    List_Records_tmp.add(Map_Records.get(Id));
            }
            
            if(List_Records_tmp.size() > 0)
            {
                try {
                    delete List_Records_tmp;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_delete));
                } catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_removing));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                }
            }
        }
//-------------------------------------------------------
// It unselects all records and retrieves all the existent
// ones through the inital query method getRecords().
//-------------------------------------------------------
        setRows('');
        getRecords();
        showGiveAwaysMessages = true;
    }

//-------------------------------------------------------
// This method enables the Add mode to display the product picker.
// - It gets the Give Aways catalogue from the current campaign
// - It unselects all records via setRows('')
// - It gets records through getRecords()
// - It enables the Add, New and Edit modes
//-------------------------------------------------------
	public void modeAdd()
	{
		if(Util.currentCampaign != null)
			Id_ProductCatalogue = Util.currentCampaign.GiveAwayPCMRef__c;
		
		setRows('');
    	getRecords();
    	modeAdd = modeNew = modeEdit = true;
	}

//-------------------------------------------------------
// This method enables the New mode, where the getNew()
// method is called and the new lines are editable.
// - It gets records through getRecords()
// - It creates the virtual new lines to be edited and inserted
// - It unselects all records via setRows('')
// - It enables the New and the Edit modes and disabled the Add mode
//-------------------------------------------------------
    public void modeNew()
    {
    	getRecords();
    	getNew();
//-------------------------------------------------------
// It is critical to unselect records via setRows('') just after
// calling the getNew() function, where the selected records are used.
//-------------------------------------------------------
    	setRows('');
    	modeAdd = false;
    	modeNew = modeEdit = true;
    }

//-------------------------------------------------------
// This method enables the Edit mode, where the selected
// records are editable.
// - It gets records through getRecords()
// - It enables the Edit mode
//-------------------------------------------------------
    public void modeEdit()
    {
        getRecords();
        modeEdit = true;
    }

//-------------------------------------------------------
// This method disables the Add, New and Edit modes.
// - It unselects all records via setRows('')
// - It gets records through getRecords()
// - It clears the product picker (list of records to be added)
// - It disables the Add, New and Edit modes.
//-------------------------------------------------------
    public void cancelModes()
    {
        setRows('');
        getRecords();
        List_Records_add.clear();
        modeAdd = modeNew = modeEdit = false;
    }

//-------------------------------------------------------
// This method saves the changes when inserting or updating records.
// Only when succeed, it calls cancelModes().
//-------------------------------------------------------
    public void doSave()
    {
//-------------------------------------------------------
// Updating existent records when some lines are selected.
//-------------------------------------------------------
        if(List_Records_Selected != null && List_Records_Selected.size() > 0)
        {
            List<CampaignLineItem__c> List_Records_tmp = new List<CampaignLineItem__c>();
//-------------------------------------------------------
// It gets the records from the key map when they are selected.
//-------------------------------------------------------
            for(String Id : List_Records_Selected)
            {
                if(Map_Records.containsKey(Id))
                    List_Records_tmp.add(Map_Records.get(Id));
            }
            
            if(List_Records_tmp.size() > 0)
            {
                try {
                    update List_Records_tmp;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_update));
                    cancelModes();
                } catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_saving));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                }
            } else {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_any_record_updated));
            }
//-------------------------------------------------------
// Inserting new records when there are not selected lines.
//-------------------------------------------------------
        } else {
    		if(List_Records_add.size() > 0)
    		{
    			try {
    				insert List_Records_add;
    				
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_insert));
    				cancelModes();
    			} catch(DmlException e) {
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_inserting));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
    			}
    		} else {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_any_record_inserted));
    		}
        }
        showGiveAwaysMessages = true;
    }
}