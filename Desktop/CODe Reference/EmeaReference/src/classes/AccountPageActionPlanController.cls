//-------------------------------------------------------
// Apex class   AccountPageActionPlanController
// Test class   AccountPageActionPlanController_Test
// Author       Support Team
// Last update  30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageActionPlanController {

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
        
                String countryISO = Util.countryView.country.TXT_Country_ISO_Code__c != null ? Util.countryView.country.TXT_Country_ISO_Code__c : (Util.currentUser.CountryISOCode__c != null ? Util.currentUser.CountryISOCode__c : '');
              
                if(countryISO != '')
                {
                    if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO) != null)
                        FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO).getFields();
                    else
                        FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                } else {
                    FieldSet_Component = SObjectType.CampaignLineItem__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                }
            }
            return FieldSet_Component;
        } protected set;
    }

//-------------------------------------------------------
// Getting the set of fields to display for campaign section.
//-------------------------------------------------------
    public List<Schema.FieldSetMember> FieldSet_Detail
    {
        get {
            if(FieldSet_Detail == null)
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
                    if(SObjectType.Campaign.FieldSets.getMap().get('AccountPage' + AccountType + Util.currentUser.CountryISOCode__c) != null)
                        FieldSet_Detail = SObjectType.Campaign.FieldSets.getMap().get('AccountPage' + AccountType + Util.currentUser.CountryISOCode__c).getFields();
                    else
                        FieldSet_Detail = SObjectType.Campaign.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                } else {
                    FieldSet_Detail = SObjectType.Campaign.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                }
            }
            return FieldSet_Detail;
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
// Initialization of the map for products added by the product picker.
//-------------------------------------------------------
    public transient Map<String, Boolean> Map_isCompetitor {get; private set;}

//-------------------------------------------------------
// Initialization of the related catalogue for Sales.
//-------------------------------------------------------
    public transient Id Id_ProductCatalogue {get; private set;}
    
//-------------------------------------------------------
// Initialization of the map for type relationships
//-------------------------------------------------------
	private Map<String, String> Map_Types = new Map<String, String>();

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
// Method to retrieve all the reports available.
//-------------------------------------------------------
    public List<Report> availableReports {
        get {
            if(availableReports == null)
                availableReports = [SELECT Id, Name FROM Report WHERE DeveloperName LIKE 'AccountPage_ActionPlan_%' ORDER BY LastModifiedDate DESC];
            return availableReports;
        } 
        protected set;
    }

//-------------------------------------------------------
// Initialization of the list of SelectOptions for the
// enhanced picklist displayed in the Visualforce component.
//-------------------------------------------------------
    public List<SelectOption> Options_Type {get; private set;}

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean modeAdd {get; set;}
    public Boolean modeNew {get; set;}
    public Boolean modeEdit {get; set;}
    public Boolean showActionPlanMessages {get; set;}
    public Boolean isOwner {get { return Util.isAccountOwner;} protected set;}
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
        return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}

//-------------------------------------------------------
// Apex class constructor, calling the ini() method.
//-------------------------------------------------------
    public AccountPageActionPlanController()
    {
        ini();
    }

//-------------------------------------------------------
// Initial method that initializes some variables.
//-------------------------------------------------------
    private void ini()
    {
        system.debug('***INI: AccountPageActionPlanController');
        
        List_Records_add = new List<CampaignLineItem__c>();
        showActionPlanMessages = modeAdd = modeNew = modeEdit = false;
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
//-------------------------------------------------------
    private void getRecords()
    {       
        Map_Records = new Map<Id, CampaignLineItem__c>();
        List_Records = new List<CampaignLineItem__c>();
        
        String q = 'SELECT';
        q += ' Id, Name, ProductRef__c, ProductRef__r.Name, HybridName__c, Provider__c, ProductCatalogEntryRef__c, Type__c,';
        q += ' NUM_FARM_AGREED__c, NUM_FARM_FORECAST__c, POGPY__c, NUM_ORDERED_CY_QTY__c, NUM_ORDERED_PY_QTY__c, NUM_INVOICED_CY_QTY__c, NUM_INVOICED_PY_QTY__c, ProductCatalogEntryRef__r.DE_isPremium__c, Agreed__c';
//-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
        for(Schema.FieldSetMember f : FieldSet_Component)
        {
            if(f.getFieldPath() != 'Id'
            && f.getFieldPath() != 'Name'
            && f.getFieldPath() != 'ProductRef__c'
            && f.getFieldPath() != 'ProductRef__r.Name'
            && f.getFieldPath() != 'HybridName__c'
            && f.getFieldPath() != 'Provider__c'
            && f.getFieldPath() != 'ProductCatalogEntryRef__c'
            && f.getFieldPath() != 'Type__c'
            && f.getFieldPath() != 'NUM_FARM_AGREED__c'
            && f.getFieldPath() != 'NUM_FARM_FORECAST__c'
            && f.getFieldPath() != 'POGPY__c'
            && f.getFieldPath() != 'NUM_ORDERED_CY_QTY__c'
            && f.getFieldPath() != 'NUM_ORDERED_PY_QTY__c'
            && f.getFieldPath() != 'NUM_INVOICED_CY_QTY__c'
            && f.getFieldPath() != 'NUM_INVOICED_PY_QTY__c'
            && f.getFieldPath() != 'Agreed__c')
                q += ', ' + f.getFieldPath();
        }
        q += ' FROM CampaignLineItem__c';
        q += ' WHERE FarmRef__c = \'' + Util.currentAccount.Id + '\'';
        q += ' AND ProductRef__c != null';
        q += ' AND CampaignRef__r.StatusCode__c = 200';
        q += ' AND CampaignRef__r.DivisionRef__c = \'' + Util.currentDivision.Id + '\'';
        q += ' AND RecordTypeId = \'' + Util.recordType.get('CampaignLineItem__c:Sales') + '\'';
        q += ' ORDER BY Provider__c ASC, ProductRef__r.Name ASC, Type__c ASC, CreatedDate DESC';
//-------------------------------------------------------
// Using a temporal list of records, they can be displayed showing
// the ones related to Monsanto International Sarl at first place.
//-------------------------------------------------------
        List<CampaignLineItem__c> List_Records_other = new List<CampaignLineItem__c>();
        List<CampaignLineItem__c> List_Records_tmp = (List<CampaignLineItem__c>)Database.query(q);
        
        List<String> List_Products = new List<String>();
        
        for(CampaignLineItem__c r : List_Records_tmp)
        {
            List_Products.add(r.ProductRef__c);
            
            if(r.Provider__c != null && r.Provider__c.contains('Monsanto'))
                List_Records.add(r);
            else
                List_Records_other.add(r);
        }
        List_Records.addAll(List_Records_other);
        
        Map_isCompetitor = new Map<String, Boolean>();
//-------------------------------------------------------
// Building a map for each selected product with value:
// - true, for competitor products
// - false, for Monsanto products
//-------------------------------------------------------
        for(Product2 pr2 : [SELECT Id, ProductVendor__c, ProductVendor__r.RecordTypeId FROM Product2 WHERE Id IN :List_Products])
        {
            Boolean isCompetitor = true;
            if(pr2.ProductVendor__c != null)
                isCompetitor = pr2.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor') ? true : false;
            
            Map_isCompetitor.put(pr2.Id, isCompetitor);
        }
//-------------------------------------------------------
// Key map to recover data on update/insert actions.
//-------------------------------------------------------
        for(CampaignLineItem__c r : List_Records)
        {        	
            Map_Records.put(r.Id, r);
        }
    }

//-------------------------------------------------------
// Method to built the enhanced picklist for types.
//-------------------------------------------------------
    private void getTypes()
    {
        if(Options_Type == null)
        {
            Options_Type = new List<SelectOption>();
            
            Schema.DescribeFieldResult field = CampaignLineItem__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> values = field.getPicklistValues();
        
            for(Schema.PicklistEntry f : values)
            {
            	Options_Type.add(new SelectOption(f.getValue(), f.getLabel()));
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
//-------------------------------------------------------
// Firstly it is trying to get the default Planting Density
// values coming from the country definition.
//-------------------------------------------------------
            String pDensity = '';
            Boolean IspDensity = false;
            for(Schema.FieldSetMember f : FieldSet_Component)
            {
                if(f.getFieldPath() == 'PlantingDensity__c')
                    IspDensity = true;
            }
            if(IspDensity && Util.currentCountry != null)
            {
                if(Util.currentDivision.Name == Util.DIVISION_CORN && Util.currentCountry.TXT_Planting_Density_Corn__c != null)
                    pDensity = Util.currentCountry.TXT_Planting_Density_Corn__c;
                if(Util.currentDivision.Name == Util.DIVISION_OSR && Util.currentCountry.TXT_Planting_Density_OSR__c != null)
                    pDensity = Util.currentCountry.TXT_Planting_Density_OSR__c;
            }
            
            Map_isCompetitor = new Map<String, Boolean>();
            
            if(List_Records_Selected != null && List_Records_Selected.size() > 0)
            {
                List<String> List_Products = new List<String>();
                
                for(String s : List_Records_Selected)
                {
                    String Id0 = s.split('/')[0];
                    String Id1 = s.split('/')[1];
                    List_Records_add.add(
                        new CampaignLineItem__c(
                            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
                            FarmRef__c = Util.currentAccount.Id,
                            PlantingDensity__c = pDensity,
                            ProductRef__c = Id0,
                            ProductCatalogEntryRef__c = Id1,
                            CampaignRef__c = Util.currentCampaign.Id,
                            PoS__c = Util.currentAccount.PrimaryPoS__c,
                            DistributorRef__c = Util.currentAccount.PrimaryDistributor__c,
                            OwnerId = Util.currentUser.Id
                        )
                    );
                    
                    List_Products.add(Id0);
                }

//-------------------------------------------------------
// Building a map for each selected product with value:
// - true, for competitor products
// - false, for Monsanto products
//-------------------------------------------------------
                for(Product2 pr2 : [SELECT Id, ProductVendor__c, ProductVendor__r.RecordTypeId FROM Product2 WHERE Id IN :List_Products])
                {
                    Boolean isCompetitor = true;
                    if(pr2.ProductVendor__c != null)
                        isCompetitor = pr2.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor') ? true : false;
                    
                    Map_isCompetitor.put(pr2.Id, isCompetitor);
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_active_campaign));
            
            modeAdd = modeNew = modeEdit = false;
            showActionPlanMessages = true;
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
// Methods to retrieve the selected types for each record
//-------------------------------------------------------
    public void setSelectedTypes(String recordsId)
    {
        List<String> pair = (recordsId != '' && recordsId != null) ? recordsId.split('-') : new List<String>();
        for(String p : pair)
        {
        	List<String> split = (p != '' && p != null) ? p.split(':') : new List<String>();
        	if(split.size() == 2)
        	{
        		Map_Types.put(split[0], split[1]);
        	}
        }
    }
    public Map<String, String> getSelectedTypes()
    {
        return Map_Types;
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
            List<CampaignLineItem__c> List_Records_py = new List<CampaignLineItem__c>();
//-------------------------------------------------------
// It gets the records from the key map when they are selected.
//-------------------------------------------------------
            for(String Id : List_Records_Selected)
            {
                if(Map_Records.containsKey(Id))
                {
                    CampaignLineItem__c cli = Map_Records.get(Id);
                    Decimal qty = 0;
                    qty += cli.NUM_INVOICED_PY_QTY__c != null ? cli.NUM_INVOICED_PY_QTY__c : 0;
                    qty += cli.NUM_INVOICED_CY_QTY__c != null ? cli.NUM_INVOICED_CY_QTY__c : 0;
                    qty += cli.NUM_ORDERED_PY_QTY__c != null ? cli.NUM_ORDERED_PY_QTY__c : 0;
                    qty += cli.NUM_ORDERED_CY_QTY__c != null ? cli.NUM_ORDERED_CY_QTY__c : 0;
                    qty += cli.NUM_FARM_FORECAST__c != null ? cli.NUM_FARM_FORECAST__c : 0;
                    qty += cli.NUM_FARM_AGREED__c != null ? cli.NUM_FARM_AGREED__c : 0;
                    qty += cli.POGPY__c != null ? cli.POGPY__c : 0;
                    
                    if(qty == 0)
                        List_Records_tmp.add(Map_Records.get(Id));
                    else
                        List_Records_py.add(Map_Records.get(Id));
                }
            }
            
            if(List_Records_tmp.size() > 0)
            {
                try {
                    delete List_Records_tmp;
                    
                    if(List_Records_py.size() > 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_some_delete));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.AccountPage_msg_some_no_delete));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_delete));
                    }
                } catch(DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_removing));
                    for(Integer i = 0; i < e.getNumDml(); i++)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                }
            } else {
                if(List_Records_py.size() > 0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.AccountPage_msg_any_record_deleted_py));
            }
        }
//-------------------------------------------------------
// It unselects all records and retrieves all the existent
// ones through the inital query method getRecords().
//-------------------------------------------------------
        setRows('');
        getRecords();
        showActionPlanMessages = true;
    }

//-------------------------------------------------------
// This method enables the Add mode to display the product picker.
// - It gets the Sales catalogue from the current campaign
// - It unselects all records via setRows('')
// - It gets records through getRecords()
// - It enables the Add, New and Edit modes
//-------------------------------------------------------
    public void modeAdd()
    {
        if(Util.currentCampaign != null)
            Id_ProductCatalogue = Util.currentCampaign.SalesPCMRef__c;
        
        setRows('');
        getRecords();
        modeAdd = modeNew = modeEdit = true;
    }

//-------------------------------------------------------
// This method enables the New mode, where the getNew()
// method is called and the new lines are editable.
// - It gets enhanced picklists values for type
// - It gets records through getRecords()
// - It creates the virtual new lines to be edited and inserted
// - It unselects all records via setRows('')
// - It enables the New and the Edit modes and disabled the Add mode
//-------------------------------------------------------
    public void modeNew()
    {
        getTypes();
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
// - It gets enhanced picklists values for type
// - It gets records through getRecords()
// - It enables the Edit mode
//-------------------------------------------------------
    public void modeEdit()
    {
        getTypes();
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
                for(CampaignLineItem__c r : List_Records_tmp)
                {
                	if(Map_Types.containsKey(r.Id) && Map_Types.get(r.Id) != r.Type__c)
                		r.Type__c = Map_Types.get(r.Id);
                	
                    calculateStatus(r);
                }
                
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
                for(CampaignLineItem__c r : List_Records_add)
                    calculateStatus(r);
                    
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
//-------------------------------------------------------
// The variable currentCampaign needs to be updated in order to refresh its values.
//-------------------------------------------------------
        if(Util.currentCampaign != null)
            currentCampaign = Util.currentCampaign;

        showActionPlanMessages = true;
    }

//-------------------------------------------------------
// Method to calculate the Status__c value for each line based on the quantity filled.
//-------------------------------------------------------
     public CampaignLineItem__c calculateStatus(CampaignLineItem__c r) {
        r.Status__c = null;
        if(r.POG__c != null) r.Status__c = 'Confirmed';
        else if (r.Agreed__c != null) r.Status__c = 'Ordered / Discussed';
        else if (r.Forecast__c != null) r.Status__c = 'Forecast';
        
        return r;
    }

//-------------------------------------------------------
// Auxiliar methods for ZVD functionality
//-------------------------------------------------------

    public virtual Boolean getZVDButtons()
    {
        Boolean isAgreed = false;
        for(CampaignLineItem__c c : List_Records)
        {
            if(c.Agreed__c != null && c.Agreed__c > 0)
            {
                isAgreed = true;
                break;
            }
        }
        Boolean isDE = Util.currentCampaign != null ? Util.currentCampaign.Name.contains('Germany') : false;
        Boolean isRegionalManager = Util.currentUser.Is_Regional_Manager__c;
        Boolean isZVDFound = getZVDURL() != null;
        
        if(isAgreed && !isRegionalManager && isZVDFound && isDE && isDistAccount)
            return true;
        else
            return false;
    }

    private static Retoure__c retoure
    {
        get
        {
            String year;
            if(Util.currentCampaign != null) year = Util.CurrentCampaign.YearV2__r.Name;
            else if(Util.currentCampaign == null) year = Util.currentYear.Name;
            
            List<Retoure__c> retoures = [SELECT Id, TXT_year__c
                FROM Retoure__c
                WHERE Account__c =: Util.currentAccount.Id
                AND Division__c =: Util.currentDivision.Id
                AND TXT_year__c =:year];
                         
            if(retoures.size() > 0)
                retoure = retoures[0];
            else
                retoure = new Retoure__c (Account__c = Util.currentAccount.Id, Division__c = Util.currentDivision.Id, TXT_year__c = year);

            return retoure;
        } set;
    }

    private String getZVDURL()
    {
        String result;
        
        if(SystemSettings__c.getValues('ZVD_' + Util.currentDivision.Name + '_' + retoure.TXT_year__c) != null)
            result = SystemSettings__c.getValues('ZVD_' + Util.currentDivision.Name + '_' + retoure.TXT_year__c).Value__c;
        else if(SystemSettings__c.getValues('ZVD_' + Util.currentDivision.Name) != null)
            result = SystemSettings__c.getValues('ZVD_' + Util.currentDivision.Name).Value__c;

        return result;
    }

    public PageReference getZVD()
    {
        String URLString = '/apex/' + getZVDURL() + '?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id;
        PageReference URL = new PageReference(URLString);
        
        if(getZVDURL() == null)
        {
            URL = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.AccountPage_msg_ZVDNotFound));
        }
        
        showActionPlanMessages = true;
        
        return URL;
    }
 
    public void getZVDEmail()
    {
        String URLString = '/apex/' + getZVDURL() + '?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id;
        PageReference URL = new PageReference(URLString);
        
        String userMail = Util.currentUser.Email;
        String excelName;

        if(Util.currentDivision.Name.equalsIgnoreCase(Util.DIVISION_CORN))
             excelName = Label.AccountPage_ExcelName_Corn+retoure.TXT_year__c;
        else if(Util.currentDivision.Name.equalsIgnoreCase(Util.DIVISION_OSR))
             excelName = Label.AccountPage_ExcelName_OSR+retoure.TXT_year__c;

        Attachment attach  = new Attachment(Name = excelName + ' [' + Util.currentAccount.Name + ']' + '.xls',  isPrivate = false);
        
        Blob body;
        try {
           body = URL.getContent();
        } catch (VisualforceException e) {
           body = Blob.valueOf('Error while generating excel' + e);
           attach.name = 'Error.txt';
           userMail = 'everis.salesforce@gmail.com';
        }
        attach.body = body;       

        Integer counter = 0;    
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
                
        emails[counter++] = sendToMail(attach, userMail, userMail, Util.currentAccount.Name);
        try {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails, false);
            for(Messaging.SendEmailResult mser: (List<Messaging.SendEmailResult>)r)
            {
                if(mser.Success)
                    Util.addConfirmMessage('ZVD an die Email ['+Util.currentUser.eMail+ '] versendet');
                    
                system.debug('Email result ' + mser.IsSuccess());
                //system.debug('mail='+r.get(0).getErrors()[0].getMessage());
            }
        }
        catch(Exception e) {
            system.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        showActionPlanMessages = true;
    }
    
    public static Messaging.SingleEmailMessage sendToMail(Attachment paramAttach, String paramReplyTo, String paramTo, String AccountName)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        efa.setFileName(paramAttach.name);
        efa.setBody(paramAttach.body);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); 
        email.setTargetObjectId(Util.currentUser.Id);
        
        if(String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Header').Value__c) == null)
            email.setSubject('A new Excel file for [' + AccountName + ']');
        else
            email.setSubject(String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Header').Value__c) + ' [' + Util.currentDivision.Name + ']' + '[' + AccountName + ']');

        email.setToAddresses(((paramTo != null && paramTo != '') ? paramTo : '').split(':'));
        
        if(String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Body').Value__c) == null)
            email.setPlainTextBody('Please find attached the Excel file that has just been created');
        else 
            email.setPlainTextBody( String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Body').Value__c) );          
        
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('DE_ORG_MAILER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        email.setSaveAsActivity(false);

        return email;
    }
}