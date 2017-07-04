//-------------------------------------------------------
// Apex class	AccountPageTrialsController
// Test class	AccountPageTrialsController_Test
// Author		Support Team
// Last update	30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageTrialsController {

//-------------------------------------------------------
// Getting the set of fields to display for the parent records.
//-------------------------------------------------------
    public List<Schema.FieldSetMember> FieldSet_Parents
    {
        get {
			if(FieldSet_Parents == null)
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
	                if(SObjectType.CampaignLineItemGroup__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + countryISO) != null)
	                    FieldSet_Parents = SObjectType.CampaignLineItemGroup__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + countryISO).getFields();
	                else
	                    FieldSet_Parents = SObjectType.CampaignLineItemGroup__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + 'Default').getFields();
	            } else {
	                FieldSet_Parents = SObjectType.CampaignLineItemGroup__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + 'Default').getFields();
	            }
			}
            return FieldSet_Parents;
        } protected set;
    }

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
	            if(Util.currentUser.CountryISOCode__c != null)
	            {
	                if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + Util.currentUser.CountryISOCode__c) != null)
	                    FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + Util.currentUser.CountryISOCode__c).getFields();
	                else
	                    FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + 'Default').getFields();
	            } else {
	                FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage_Trials' + AccountType + 'Default').getFields();
	            }
			}
            return FieldSet_Component;
        } protected set;
    }

//-------------------------------------------------------
// Initialization of the list of displayed records/parents retrieved
// from the method getRecords() and other important maps and lists.
//-------------------------------------------------------
    public List<CampaignLineItemGroup__c> List_Parents {
        get {
            if(List_Parents == null) {
                getRecords();
            }
            return List_Parents;
        }
        private set;
    }
    public List<CampaignLineItem__c> List_Records {
        get {
            if(List_Records == null) {
                getRecords();
            }
            return List_Records;
        }
        private set;
    }
//-------------------------------------------------------
// Map_Key links each parent with its children.
//-------------------------------------------------------
    public Map<Id, List<CampaignLineItem__c>> Map_Key {get; private set;}
    private List<String> List_Parents_Selected = new List<String>();
    private List<String> List_Records_Selected = new List<String>();
    private Map<Id, CampaignLineItemGroup__c> Map_Parents;
    private Map<Id, CampaignLineItem__c> Map_Records;

//-------------------------------------------------------
// Initialization of the list of records added by the product picker.
//-------------------------------------------------------
    public List<CampaignLineItemGroup__c> List_Parents_add {get; private set;}
    public List<CampaignLineItem__c> List_Records_add {get; private set;}

//-------------------------------------------------------
// Initialization of the related catalogues for Trials.
//-------------------------------------------------------
    public transient Id Id_ProductCatalog_Trial {get; private set;}
    public transient Id Id_ProductCatalog_Competitor {get; private set;}

//-------------------------------------------------------
// Method to retrieve all the reports available.
//-------------------------------------------------------
    public List<Report> availableReports {
    	get {
    		if(availableReports == null)
    			availableReports = [SELECT Id, Name FROM Report WHERE DeveloperName LIKE 'AccountPage_Trials_%' ORDER BY LastModifiedDate DESC];
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
// Initialization of the list of SelectOptions for the
// enhanced picklist displayed in the Visualforce component.
//-------------------------------------------------------
    public List<SelectOption> Options_Type {get; private set;}
    public List<SelectOption> Options_Status {get; private set;}
    public List<SelectOption> Options_Products {get; private set;}
    public List<SelectOption> Options_HarvestedBy {get; private set;}

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean modeAdd {get; set;}
    public Boolean modeNew {get; set;}
    public Boolean modeEdit {get; set;}
    public Boolean modeNewLines {get; set;}
    public Boolean showTrialsMessages {get; set;}
    public Boolean isOwner {get { return Util.isAccountOwner; } protected set;}
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
    	return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}

//-------------------------------------------------------
// Apex class constructor, calling the ini() method.
//-------------------------------------------------------
    public AccountPageTrialsController()
    {
        ini();
    }

//-------------------------------------------------------
// Initial method that initializes some variables.
//-------------------------------------------------------
    private void ini()
    {
        system.debug('***INI: AccountPageTrialsController');
        
        List_Parents_add = new List<CampaignLineItemGroup__c>();
        List_Records_add = new List<CampaignLineItem__c>();
        showTrialsMessages = modeAdd = modeNew = modeEdit = modeNewLines = false;
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
//-------------------------------------------------------
    private void getRecords()
    {
        Map_Records = new Map<Id, CampaignLineItem__c>();
        List_Records = new List<CampaignLineItem__c>();

        Map_Parents = new Map<Id, CampaignLineItemGroup__c>();
        List_Parents = new List<CampaignLineItemGroup__c>();
        Map_Key = new Map<Id, List<CampaignLineItem__c>>();
        
        String q = 'SELECT Id, Name, ProductRef__r.Name, CampaignLineItemGroupRef__c, ProductCatalogEntryRef__c';
//-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
        for(Schema.FieldSetMember f : FieldSet_Component)
        {
            if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Name' && f.getFieldPath() != 'ProductRef__r.Name' && f.getFieldPath() != 'CampaignLineItemGroupRef__c' && f.getFieldPath() != 'ProductCatalogEntryRef__c')
                q += ', ' + f.getFieldPath();
        }
        q += ' FROM CampaignLineItem__c';
        q += ' WHERE FarmRef__c = \'' + Util.currentAccount.Id + '\'';
        q += ' AND ProductRef__c != null AND CampaignLineItemGroupRef__c != null';
        q += ' AND CampaignRef__r.StatusCode__c = 200';
        q += ' AND CampaignRef__r.DivisionRef__c = \'' + Util.currentDivision.Id + '\'';
        q += ' AND RecordTypeId = \'' + Util.recordType.get('CampaignLineItem__c:Trial') + '\'';

        List_Records = (List<CampaignLineItem__c>)Database.query(q);
//-------------------------------------------------------
// Key map to recover data on update/insert actions.
// Also populating the map key with all possible parent references.
//-------------------------------------------------------
        for(CampaignLineItem__c r : List_Records)
        {
            Map_Records.put(r.Id, r);
            if(Map_Key.containsKey(r.CampaignLineItemGroupRef__c))
            	Map_Key.get(r.CampaignLineItemGroupRef__c).add(r);
            else
            	Map_Key.put(r.CampaignLineItemGroupRef__c, new List<CampaignLineItem__c>{r});
        }
//-------------------------------------------------------
// Retrieving parents only if some of the records have related parents.
//-------------------------------------------------------
        if(Map_Key.size() > 0)
        {
        	Set<Id> m = Map_Key.keySet();
        	
	        String x = 'SELECT Id, Name';
//-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
	        for(Schema.FieldSetMember f : FieldSet_Parents)
	        {
	            if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Name')
	                x += ', ' + f.getFieldPath();
	        }
	        x += ' FROM CampaignLineItemGroup__c';
	        x += ' WHERE Id IN :m';
	
	        List_Parents = (List<CampaignLineItemGroup__c>)Database.query(x);
//-------------------------------------------------------
// Key map to recover data on update/insert actions.
//-------------------------------------------------------
	        for(CampaignLineItemGroup__c p : List_Parents)
	            Map_Parents.put(p.Id, p);
        }
    }

//-------------------------------------------------------
// Method to built the enhanced picklists for CampaignLineItemGroup fields:
// - Type
// - Status
// - Harvested by
//-------------------------------------------------------
    private void getOptions()
    {
    	if(Options_Type == null)
    	{
	    	Options_Type = new List<SelectOption>();
	    	
	    	Schema.DescribeFieldResult field = CampaignLineItemGroup__c.Type__c.getDescribe();
			List<Schema.PicklistEntry> values = field.getPicklistValues();
        
			for(Schema.PicklistEntry f : values)
			{
				if(f.getLabel() != 'x' && f.getLabel() != '-')
					Options_Type.add(new SelectOption(f.getValue(), f.getLabel()));
			}
    	}
    	if(Options_Status == null)
    	{
	    	Options_Status = new List<SelectOption>();
	    	
	    	Schema.DescribeFieldResult field = CampaignLineItemGroup__c.Status__c.getDescribe();
			List<Schema.PicklistEntry> values = field.getPicklistValues();
        
			for(Schema.PicklistEntry f : values)
			{
				if(f.getLabel() != 'x' && f.getLabel() != '-')
					Options_Status.add(new SelectOption(f.getValue(), f.getLabel()));
			}
    	}
    	if(Options_HarvestedBy == null)
    	{
	    	Options_HarvestedBy = new List<SelectOption>();
	    	
	    	Schema.DescribeFieldResult field = CampaignLineItemGroup__c.HarvestedBy__c.getDescribe();
			List<Schema.PicklistEntry> values = field.getPicklistValues();
        
			for(Schema.PicklistEntry f : values)
			{
				if(f.getLabel() != 'x' && f.getLabel() != '-')
					Options_HarvestedBy.add(new SelectOption(f.getValue(), f.getLabel()));
			}
    	}
    }

//-------------------------------------------------------
// Method to built the enhanced picklist for the list of available products.
//-------------------------------------------------------
    private void getProducts()
    {
    	if(Options_Products == null)
    	{
	    	Options_Products = new List<SelectOption>();
	    	if(Util.currentCampaign != null)
	    	{
	    		List<ProductCatalogEntry__c> List_pce = new List<ProductCatalogEntry__c>();
	    		List<ProductCatalogEntry__c> List_other = new List<ProductCatalogEntry__c>();
		    	for(ProductCatalogEntry__c itm : [SELECT Id, ProductRef__c, Product_Name__c, Vendor__c
		    		FROM ProductCatalogEntry__c
		    		WHERE (ProductCatalogRef__c = :Util.currentCampaign.TrialPCMRef__c OR ProductCatalogRef__c = :Util.currentCampaign.CompetitorPCMRef__c)
		    		AND IsActive__c = true
		    		AND Vendor__c != null
		    		AND ProductRef__c != null
		    		AND ProductRef__r.IsActive = true
		    		ORDER BY Vendor__c ASC, Product_Name__c ASC])
		    		{
		    			if(itm.Vendor__c.contains('Monsanto'))
		    				List_pce.add(itm);
		    			else
		    				List_other.add(itm);
		    		}
//-------------------------------------------------------
// Monsanto products are populated first and a small trick helps to group the items by vendors
//-------------------------------------------------------
	        	List_pce.addAll(List_other);
				for(ProductCatalogEntry__c itm : List_pce)
					Options_Products.add(new SelectOption(itm.ProductRef__c, String.format('{0}/{1}', new String[]{itm.Vendor__c, itm.Product_Name__c})));
	    	}
    	}
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
//-------------------------------------------------------
// First, a unique parent is created.
//-------------------------------------------------------
	        	List_Parents_add.add(
	        		new CampaignLineItemGroup__c(
	        			RecordTypeId = Util.recordType.get('CampaignLineItemGroup__c:Trial'),
	        			AccountRef__c = Util.currentAccount.Id,
	        			CampaignRef__c = Util.currentCampaign.Id,
	        			OwnerId = Util.currentUser.Id
	        		)
	        	);
//-------------------------------------------------------
// Then, a list of children is created based on the selected records.
//-------------------------------------------------------
	            for(String s : List_Records_Selected)
	            {
	                String Id0 = s.split('/')[0];
	                String Id1 = s.split('/')[1];
	                List_Records_add.add(
	                    new CampaignLineItem__c(
	                        RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial'),
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
            showTrialsMessages = true;
        }
    }

//-------------------------------------------------------
// Method to create virtual records that can be inserted
// from the enhanced picklist with the list of products.
//-------------------------------------------------------
	private void getNewLines()
	{
        if(Util.currentCampaign != null)
        {
        	if(List_Parents_Selected != null)
        	{
	            for(String ParentId : List_Parents_Selected)
	            {
	            	if(Map_Key.containsKey(ParentId))
	            	{
		            	for(Integer i = 0; i < 5; i++)
		            	{
					    	CampaignLineItem__c r = new CampaignLineItem__c(
					    			RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial'),
					    			CampaignLineItemGroupRef__c = ParentId,
					    			FarmRef__c = Util.currentAccount.Id,
					    			CampaignRef__c = Util.currentCampaign.Id,
					    			OwnerId = Util.currentUser.Id
					    		);
					    	List_Records_add.add(r);
					    	Map_Key.get(ParentId).add(r);
		            	}
	            	}
	            }
        	}
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_active_campaign));
            
            modeNewLines = false;
            showTrialsMessages = true;
        }
	}

//-------------------------------------------------------
// Methods to retrieve the selected parents from the Visualforce component.
//-------------------------------------------------------
    public void setRowsParents(String recordsId)
    {
        List_Parents_Selected = (recordsId != '' && recordsId != null) ? recordsId.split(',') : null;
    }
    public List<String> getRowsParents()
    {
        return List_Parents_Selected;
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
// It is only handled if the list of selected records is not empty
// (it is not possible to select a parent without any child record).
//-------------------------------------------------------
    public void doDelete()
    {        
        if(List_Records_Selected != null && List_Records_Selected.size() > 0)
        {
        	List<CampaignLineItemGroup__c> List_Parents_tmp = new List<CampaignLineItemGroup__c>();
        	List<CampaignLineItem__c> List_Records_tmp = new List<CampaignLineItem__c>();
//-------------------------------------------------------
// It gets the parents from the key map when they are selected.
//-------------------------------------------------------
            if(List_Parents_Selected != null)
            {
	            for(String Id : List_Parents_Selected)
	            {
	                if(Map_Parents.containsKey(Id))
	                    List_Parents_tmp.add(Map_Parents.get(Id));
	            }
            }
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
                    
                    if(List_Parents_tmp.size() > 0)
                    	delete List_Parents_tmp;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_delete));
                } catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_removing));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                }
            }
        }
//-------------------------------------------------------
// It unselects all records and parents, and retrieves all
// the existent ones through the inital query method getRecords().
//-------------------------------------------------------
        setRowsParents('');
        setRows('');
        getRecords();
        showTrialsMessages = true;
    }

//-------------------------------------------------------
// This method enables the NewLines mode to display virtual lines.
// - It gets enhanced picklist values for the list of products
// - It gets records through getRecords()
// - It gets the virtual lines
// - It enables the NewLines modes
//-------------------------------------------------------
	public void modeNewLines()
	{
		getProducts();
		getRecords();
		getNewLines();
		modeNewLines = true;
	}

//-------------------------------------------------------
// This method enables the Add mode to display the product picker.
// - It gets the Trial catalogue from the current campaign
// - It unselects all records and parents via setRows('') and setRowsParents('')
// - It gets records through getRecords()
// - It enables the Add, New and Edit modes
//-------------------------------------------------------
    public void modeAdd()
    {
        if(Util.currentCampaign != null)
        {
            Id_ProductCatalog_Trial = Util.currentCampaign.TrialPCMRef__c;
            Id_ProductCatalog_Competitor = Util.currentCampaign.CompetitorPCMRef__c;
        }
        
        setRowsParents('');
        setRows('');
        getRecords();
        modeAdd = modeNew = modeEdit = true;
    }

//-------------------------------------------------------
// This method enables the New mode, where the getNew()
// method is called and the new lines are editable.
// - It gets enhanced picklists values for different fields
// - It gets records through getRecords()
// - It creates the virtual new lines to be edited and inserted
// - It unselects all records and parents via setRows('') and setRowsParents('')
// - It enables the New and the Edit modes and disabled the Add mode
//-------------------------------------------------------
    public void modeNew()
    {
    	getOptions();
        getRecords();
        getNew();
//-------------------------------------------------------
// It is critical to unselect records and parents via setRows('') and setRowsParents('')
// just after calling the getNew() function, where the selected records are used.
//-------------------------------------------------------
        setRowsParents('');
        setRows('');
        modeAdd = false;
        modeNew = modeEdit = true;
    }

//-------------------------------------------------------
// This method enables the Edit mode, where the selected
// records are editable.
// - It gets enhanced picklists values for different fields
// - It gets records through getRecords()
// - It enables the Edit mode
//-------------------------------------------------------
    public void modeEdit()
    {
    	getOptions();
        getRecords();
        modeEdit = true;
    }

//-------------------------------------------------------
// This method disables the Add, New and Edit modes.
// - It unselects all records and parents via setRows('') and setRowsParents('')
// - It gets records through getRecords()
// - It clears the product picker (list of records and parents to be added)
// - It disables the Add, New and Edit modes.
//-------------------------------------------------------
    public void cancelModes()
    {
    	setRowsParents('');
        setRows('');
        getRecords();
        List_Parents_add.clear();
        List_Records_add.clear();
        modeAdd = modeNew = modeEdit = modeNewLines = false;
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
        	List<CampaignLineItemGroup__c> List_Parents_tmp = new List<CampaignLineItemGroup__c>();
            List<CampaignLineItem__c> List_Records_tmp = new List<CampaignLineItem__c>();
//-------------------------------------------------------
// It gets the parents from the key map when they are selected.
//-------------------------------------------------------
            if(List_Parents_Selected != null)
            {
	            for(String Id : List_Parents_Selected)
	            {
	                if(Map_Parents.containsKey(Id))
	                    List_Parents_tmp.add(Map_Parents.get(Id));
	            }
            }
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
                    
                    if(List_Parents_tmp.size() > 0)
                    	update List_Parents_tmp;
                    
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
            if(List_Parents_add.size() > 0)
            {
            	Boolean success = false;
//-------------------------------------------------------
// Insertion of parents is needed first because their Id
// are needed to insert the children records with the lookups.
//-------------------------------------------------------
                try {
                    insert List_Parents_add;
                    
                    success = true;
                    
                } catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_inserting));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                }
	            if(success && List_Records_add.size() > 0)
	            {
	                try {
	                	for(CampaignLineItem__c r : List_Records_add)
	                		r.CampaignLineItemGroupRef__c = List_Parents_add[0].Id;

	                    insert List_Records_add;	 
	                                       
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_insert));
	                    cancelModes();
	                } catch(DmlException e) {
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_inserting));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
	                }
	            }
            } else {
            	if(List_Records_add.size() > 0)
            	{
            		List<CampaignLineItem__c> List_Records_tmp = new List<CampaignLineItem__c>();
            		for(CampaignLineItem__c r : List_Records_add)
            		{
            			if(r.ProductRef__c != null) List_Records_tmp.add(r);
            		}
            		if(List_Records_tmp.size() > 0)
            		{
            			try {
            				insert List_Records_tmp;
            				
            				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_insert));
            				cancelModes();
            			} catch(DmlException e) {
            				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_inserting));
    				for(Integer i = 0; i < e.getNumDml(); i++)
    					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
            			}
            		}
            	} else {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_any_record_inserted));
            	}
            }
        }
        showTrialsMessages = true;
    }
}