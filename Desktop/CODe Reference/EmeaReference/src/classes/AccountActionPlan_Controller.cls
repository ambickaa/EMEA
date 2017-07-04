public with sharing class AccountActionPlan_Controller {

// Atributes from Component to Apex Controller
// It gets the Id of the current account
    public String Id_current_account {
        get {
            if(Id_current_account != null)
                return Id_current_account;
            else
                return apexPages.currentPage().getParameters().get('id');
        } set;
    }
// It gets the Id of the current user
    public String Id_current_user {get {return Util.currentUser.Id;} set;}
// Render variables
    private boolean isAPvisible = false;
    public boolean isSharingUser {get {return Util.isAccountOwner;} set;}
    public boolean isMarketingUser {get {return Util.currentUser.Profile.Name.contains('Marketing');} set;}
    public boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} set;}
    public boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} set;}
    public boolean isSoldTo {get { return Util.currentAccount.Category__c == 'Distributor';} set;}
    public boolean isItalian {get { return Util.countryView.country.Name == 'Italy';} set;}
    public boolean isFrench {get { return Util.countryView.country.Name == 'France';} set;}
    public boolean isBritish {get { return Util.countryView.country.Name == 'United Kingdom';} set;}

// String variable for Save action (insert, delete or edit)
    private transient String doAction = '';
// List with rows array from Visualforce component
    private transient List<String> list_Ids = new List<String>();
    
// List with CampaignLineItem__c called by the Visualforce Component AP_France
    public transient List<CampaignLineItem__c> List_CampaignLineItem {get; set;}
    public List<CampaignLineItem__c> List_CampaignLineItem_tmp {get; set;}
    
    public Map<Id, CampaignLineItem__c> Map_CampaignLineItem {get; set;}
// Map for summarized quantities for table footer in Visualforce Component AP_France
    public Map<String, Decimal> Map_Summarized_Fields {get; set;}
// Map for competitor products in transient lists
    public Map<String, Integer> Map_POGPY {get; set;}
// Map for competitor products in transient lists
    public Map<String, Boolean> Map_isCompetitor {get; set;}
    
// Parameters for current campaign, division and product catalogue
    public Campaign currentCampaign {get; set;}
    public Division__c currentDivision {get; set;}
    
    public String Id_SalesProductCatalogue {get; set;}
    public String Id_SalesRecordType {get; set;}
    public String String_POGPY {get; set;}
    
// List of fields to visualize in AP_France from corresponding FieldSet at CampaignLineItem__c level
    public List<Schema.FieldSetMember> FieldSet {
        get {
            String AccountType = '';
            if(isFarmAccount) AccountType = '_Farm';
            if(isDistAccount) AccountType = '_Dist';
            if(Util.currentUser.CountryISOCode__c != null) {
                //IT Distributor Action Plan modification (CR-00000347)
                //UK Account modification (CR-00000393)
                if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get('ActionPlan_' + Util.currentUser.CountryISOCode__c + AccountType) != null) {
                    return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('ActionPlan_' + Util.currentUser.CountryISOCode__c + AccountType).getFields();
                } else {
                    system.debug('+++ AccountActionPlan__CRITICAL Fieldset ActionPlan_' + Util.currentUser.CountryISOCode__c + AccountType + ' does not exist +++');
                    //Util.currentAccount.addError('Critical error - Fieldset ActionPlan_' + Util.currentUser.CountryISOCode__c + AccountType + ' does not exist.');
                    return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();
                }
            } else {
                system.debug('+++ AccountActionPlan__CRITICAL User ' + Util.currentUser.Name + ' has not Country ISO code associated +++');
                //Util.currentAccount.addError('Critical error - User ' + Util.currentUser.Name + ' has not Country ISO code associated.');
                return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();
            }
        } set;
    }

// Main method AP_France_Controller (Initial calls)
    public AccountActionPlan_Controller() {
        
        List_CampaignLineItem = new List<CampaignLineItem__c>();
        Id_SalesProductCatalogue = '';
        Id_SalesRecordType = '';
        String_POGPY = '';
        
        system.debug('Util.currentCampaign = ' + Util.currentCampaign);
        system.debug('isSharingUser = ' + isSharingUser);
        system.debug('isMarketingUser = ' + isMarketingUser);
        system.debug('isItalian = ' + isItalian);
        system.debug('isDistAccount = ' + isDistAccount);
        
        if(Util.currentCampaign != null && (isSharingUser || isMarketingUser || (isDistAccount && !isFrench))) {
            Id_SalesProductCatalogue = Util.currentCampaign.SalesPCMRef__c;
            Id_SalesRecordType = Util.recordType.get('CampaignLineItem__c:Sales');
            currentCampaign = Util.currentCampaign;
            currentDivision = Util.currentDivision;
            getCampaignLineItem();
        }
    }
    
// It prints all CampaignLineItem__c for corresponding Account, RecordType, Campaign, etc. based on FieldSet
    private void getCampaignLineItem() {
    // The first fields here are always retrieved because they are required by the Visualforce page
        String Query = 'SELECT Id, Owner.Name, OwnerId, Provider__c, ProductCatalogEntryRef__c, ProductRef__c, ProductRef__r.Name, HybridName__c, NUM_FARM_AGREED__c, NUM_FARM_FORECAST__c, POGPY__c, NUM_ORDERED_CY_QTY__c, NUM_ORDERED_PY_QTY__c, NUM_INVOICED_CY_QTY__c, NUM_INVOICED_PY_QTY__c';
        for(Schema.FieldSetMember f : FieldSet) {
        // Some fields are required by the Visualforce page, and hece they are always retrieved even if they are already included in the FieldSet
            if(f.getFieldPath() != 'Provider__c' && f.getFieldPath() != 'Owner.Name' && f.getFieldPath() != 'OwnerId' && f.getFieldPath() != 'ProductCatalogEntryRef__c' && f.getFieldPath() != 'ProductRef__c' && f.getFieldPath() != 'HybridName__c' && f.getFieldPath() != 'NUM_FARM_AGREED__c' && f.getFieldPath() != 'NUM_FARM_FORECAST__c' && f.getFieldPath() != 'POGPY__c' && f.getFieldPath() != 'NUM_ORDERED_CY_QTY__c' && f.getFieldPath() != 'NUM_ORDERED_PY_QTY__c' && f.getFieldPath() != 'NUM_INVOICED_CY_QTY__c' && f.getFieldPath() != 'NUM_INVOICED_PY_QTY__c')
                Query += ', ' + f.getFieldPath();
        }
        Query += ' FROM CampaignLineItem__c';
        Query += ' WHERE FarmRef__c = \'' + Id_current_account + '\'';

    // Lines from all active campaigns if current user is one of the owners (or Marketing profile for France)
        if(isSharingUser || isMarketingUser || (isDistAccount && !isFrench))
            Query += ' AND CampaignRef__r.StatusCode__c = 200';
        else
            Query += ' AND CampaignRef__c = \'' + currentCampaign.Id + '\'';
        Query += ' AND Division__c = \'' + currentDivision.Name + '\'';
        Query += ' AND RecordTypeId = \'' + Id_SalesRecordType + '\'';
        Query += ' ORDER BY Provider__c ASC, ProductRef__r.Name ASC, Type__c ASC, CreatedDate DESC';
        
        List_CampaignLineItem = new List<CampaignLineItem__c>();
        
        List<CampaignLineItem__c> List_CampaignLineItem_other = new List<CampaignLineItem__c>();
        List<CampaignLineItem__c> List_CampaignLineItem_tmp = (List<CampaignLineItem__c>)Database.query(Query);

        for(CampaignLineItem__c cli : List_CampaignLineItem_tmp) {
            if(cli.Provider__c != null) {
                if(cli.Provider__c.contains('Monsanto')) List_CampaignLineItem.add(cli);
                else List_CampaignLineItem_other.add(cli);
            } else {
                List_CampaignLineItem_other.add(cli);
            }
        }
        List_CampaignLineItem.addAll(List_CampaignLineItem_other);
        
        List<String> List_Products = new List<String>();
        Map_CampaignLineItem = new Map<Id, CampaignLineItem__c>();
        for(CampaignLineItem__c cli : List_CampaignLineItem) {
            List_Products.add(cli.ProductRef__c);
            Map_CampaignLineItem.put(cli.Id, cli);
        }
        
    // It gets summarized quantities for table footer in Visualforce Component AP_France
        getMapSummarizedFields(List_CampaignLineItem);
    // It gets POGPY quantities for each line for farms
        if(isFarmAccount)
            getMapPOGPY(List_CampaignLineItem, List_Products);
    }
    
// It gets summarized quantities for table footer in Visualforce Component AP_France
    public void getMapSummarizedFields(List<CampaignLineItem__c> clis) {
        
        Schema.DescribeSObjectResult Object_Type = CampaignLineItem__c.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> Map_Object_Fields = Object_Type.fields.getMap();
        Map<String, Decimal> Map_Summarized_Fields_Temp = new Map<String, Decimal>();
        for(Schema.FieldSetMember f : FieldSet) {
            String fName =  f.getfieldPath();
            Map_Summarized_Fields_Temp.put(fName, Decimal.valueOf('0'));
        }
        for(Schema.FieldSetMember f : FieldSet) {
            String fName =  f.getfieldPath();
            String ObjType = Map_Object_Fields.get(fName).getDescribe().getType().name().toLowerCase();
            if(ObjType.equals('double') || objType.equals('integer') || objType.equals('currency')) {
                if(clis != null) {
                    for(CampaignLineItem__c cli : clis) {
                        Map_Summarized_Fields_Temp.put(fName, (Decimal)Map_Summarized_Fields_Temp.get(fName) + (Decimal)(cli.get(fName) == null ? Decimal.valueOf('0') : cli.get(fName)));
                    }
                }
            } else {
                Map_Summarized_Fields_Temp.put(fName, Map_Summarized_Fields_Temp.get(fName) + Decimal.valueOf('0'));
            }
        }
        Map_Summarized_Fields = Map_Summarized_Fields_Temp;
    }
    
// It gets POGPY quantities for each line based on previous campaign aggregate information
    public void getMapPOGPY(List<CampaignLineItem__c> clis, List<String> pr2list) {
        Map_POGPY = new Map<String, Integer>();
        for(String pr2 : pr2list)
            Map_POGPY.put(pr2, 0);
        if(Util.previewsCampaign != null) {
            String Query = 'SELECT sum(POG__c) POGPY, ProductRef__c pr2Id';
            Query += ' FROM CampaignLineItem__c';
            Query += ' WHERE ProductRef__c IN :pr2list';
            Query += ' AND CampaignRef__c = \'' + Util.previewsCampaign.Id + '\'';
            Query += ' AND RecordTypeId = \'' + Id_SalesRecordType + '\'';
            Query += ' AND POG__c != null';
            Query += ' GROUP BY ProductRef__c';
            List<AggregateResult> result = (List<AggregateResult>) Database.query(Query);
            Decimal Int_POGPY = 0;
            String_POGPY = '';
            for(AggregateResult ar : result) {
                Map_POGPY.put((String)ar.get('pr2Id'), Integer.valueOf((Decimal)ar.get('POGPY')));
                Int_POGPY = Int_POGPY + (Decimal)ar.get('POGPY');
            }
            if(Int_POGPY != 0)
                String_POGPY = String.valueOf(Integer.valueOf(Int_POGPY));
        }
    }
    
// Products in Product Picker or rows selected in Action Plan
    public void setRows(String Ids) {
        if(Ids != '')
            list_Ids = Ids.split(',');
    }
    public List<String> getRows() {
        return list_Ids;
    }
    
// Add new lines in the Action Plan based on selected products in Product Picker
    public void Temp_AP_Rows(String mode) {
        List_CampaignLineItem_tmp = new List<CampaignLineItem__c>();
        List<String> List_Products = new List<String>();
        Map_isCompetitor = new Map<String, Boolean>();
        system.debug('+++List of Ids: ' + list_Ids);
        if(list_Ids != null) {
            
            //----------------------------------------
            // START: CR-00000428 - 2016.06.15 Support Team
            //----------------------------------------
            String pDensity = '';
            
            Boolean IspDensity = false;
            for(Schema.FieldSetMember f : FieldSet) {
                if(f.getFieldPath() == 'PlantingDensity__c')
                    IspDensity = true;
            }
            if(IspDensity && Util.currentCountry != null)
            {
                if(Util.currentDivision.Name == 'Corn' && Util.currentCountry.TXT_Planting_Density_Corn__c != null)
                    pDensity = Util.currentCountry.TXT_Planting_Density_Corn__c;
                if(Util.currentDivision.Name == 'OSR' && Util.currentCountry.TXT_Planting_Density_OSR__c != null)
                    pDensity = Util.currentCountry.TXT_Planting_Density_OSR__c;
            }
            //----------------------------------------
            // END: CR-00000428 - 2016.06.15 Support Team
            //----------------------------------------
            
            if(mode == 'new') {
            system.debug('+++CLI is: ' + mode);
                for(String PR2vsPCE : list_Ids) {
                    List<String> PR2andPCE = PR2vsPCE.split('=');
                    List_Products.add(PR2andPCE[0]);
                    List_CampaignLineItem_tmp.add(new CampaignLineItem__c(
                        ProductRef__c = PR2andPCE[0],
                        ProductCatalogEntryRef__c = PR2andPCE[1],
                        OwnerId = Id_current_user,
                        Type__c = 'Charged',
                        FarmRef__c = Id_current_account,
                        CampaignRef__c = currentCampaign.Id,
                        PlantingDensity__c = pDensity,
                        RecordTypeId = Id_SalesRecordType)
                    );
                    system.debug('+++Id inserted is: ' + PR2vsPCE);
                }
            }
            if(mode == 'delete' || mode == 'edit') {
                for(String cliId : list_Ids) {
                    CampaignLineItem__c cli = Map_CampaignLineItem.get(cliId);
                    Decimal qty = 0;
                    qty += cli.NUM_ORDERED_PY_QTY__c != null ? cli.NUM_ORDERED_PY_QTY__c : 0;
                    qty += cli.NUM_INVOICED_PY_QTY__c != null ? cli.NUM_INVOICED_PY_QTY__c : 0;
                    qty += cli.NUM_FARM_FORECAST__c != null ? cli.NUM_FARM_FORECAST__c : 0;
                    qty += cli.NUM_INVOICED_CY_QTY__c != null ? cli.NUM_INVOICED_CY_QTY__c : 0;
                    qty += cli.NUM_ORDERED_CY_QTY__c != null ? cli.NUM_ORDERED_CY_QTY__c : 0;
                    qty += cli.NUM_FARM_AGREED__c != null ? cli.NUM_FARM_AGREED__c : 0;
                    qty += cli.POGPY__c != null ? cli.POGPY__c : 0;
                    
                    if(mode == 'delete' && qty > 0) {
                        Util.addInfoMessage(cli.ProductRef__r.Name + ' ' + Label.Dist_AP_Not_Allowed_to_delete_qty);
                    } else {
                        List_Products.add(cli.ProductRef__c);
                        List_CampaignLineItem_tmp.add(cli);
                    }
                }
            }
        // It creates a map for each product with true if it's competitor and false if it's Monsanto
            for(Product2 pr2 : [SELECT Id, ProductVendor__c, ProductVendor__r.RecordTypeId FROM Product2 WHERE Id IN :List_Products]) {
                system.debug('+++Product: ' + pr2);
                if(pr2.ProductVendor__c != null) {
                    Boolean isCompetitor = pr2.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor') ? true : false;
                    Map_isCompetitor.put(pr2.Id, isCompetitor);
                } else {
                    system.debug('+++ AccountActionPlan__CRITICAL Product without Vendor: ' + pr2.Id + ' +++');
                }
            }
        // It gives POGPY quantities for each line
            if(isFarmAccount)
                getMapPOGPY(List_CampaignLineItem_tmp, List_Products);
        }
    }
    
// Add new lines in the Action Plan based on selected products in Product Picker
    public PageReference newAPLines() {
        Temp_AP_Rows('new');
        return null;
    }
// Delete selected lines in the Action Plan
    public PageReference deleteAPLines() {
        Temp_AP_Rows('delete');
        return null;
    }
// Edit selected lines in the Action Plan
    public PageReference editAPLines() {
        Temp_AP_Rows('edit');
        return null;
    }
// Render variables for Action Plan tmp section
    public void setAPSectionTmpRendered(boolean rendered) {
        isAPvisible = rendered;
    }
    public boolean getAPSectionTmpRendered() {
        return isAPvisible;
    }
    
    public PageReference reRenderSection() {
        return null;
    }
// Set and get methods for Action variable
    public void setAction(String calledAction) {
        doAction = calledAction;
    }
    public String getAction() {
        return doAction;
    }
// Save lines inserted, deleted or updated into the Action Plan and refresh table values
    public void doSave() {
        
        for(CampaignLineItem__c cli : List_CampaignLineItem_tmp) {
            if(doAction == 'Insert' || doAction == 'Edit') setStatusByQuantityValue(cli);
        }
    
    System.savepoint sp = Database.setSavepoint();
    try {
        if(List_CampaignLineItem_tmp.size() > 0) {
            if(doAction == 'Insert') {
                insert List_CampaignLineItem_tmp.clone();
                Util.addConfirmMessage(Label.ConfirmMsgLinesAdded);
            }
            if(doAction == 'Delete') {
                delete List_CampaignLineItem_tmp;
                Util.addConfirmMessage(Label.msgRecordsDeleted);
            }
            if(doAction == 'Edit') {
                update List_CampaignLineItem_tmp;
                Util.addConfirmMessage(Label.ConfirmMsgLinesEdited);
            }
        } else {
            Util.addErrorMessage('Low error - No rows to process.');
        }
        
        // Test - It triggers DML exception
        if(Test.isRunningTest())
            insert new Order__c();

    } catch(DMLException DMLe) {
        if(!isFrench && isDistAccount && doAction == 'Delete') {
            Util.addErrorMessage(Label.Dist_AP_Not_Allowed_to_delete);
            for(CampaignLineItem__c cli : List_CampaignLineItem_tmp) {
                if(cli.OwnerId != Id_current_user)
                    Util.addErrorMessage(cli.HybridName__c);
            }
        } else {
            Util.addErrorMessage('Critical error - No rows processed: ' + DMLe.getMessage());
        }

        Database.rollback(sp);
    } catch(Exception e) {
        Util.addErrorMessage('Critical error - No rows processed: ' + e.getMessage());
        Database.rollback(sp);
    }
    getCampaignLineItem();
    
    // This line is needed to update current campaign info instantly
    currentCampaign = Util.currentCampaign;
    }
    
    // Function to fill the Status field in the Campaign Line Item
    public CampaignLineItem__c setStatusByQuantityValue(CampaignLineItem__c cli) {
        cli.Status__c = null;
        if(cli.POG__c != null) cli.Status__c = 'Confirmed';
        else if (cli.Agreed__c != null) cli.Status__c = 'Ordered / Discussed';
        else if (cli.Forecast__c != null) cli.Status__c = 'Forecast';
        return cli;
    }
    
    public static Account currentActionPlanAccount
    {
        get
        {
            system.debug('***** current Action Plan Account Start');
            if(currentActionPlanAccount == null) {
                setcurrentActionPlanAccount(Util.urlParameters.get('id'));
            }

            return currentActionPlanAccount;
        } set;
    }

    public static void setcurrentActionPlanAccount(String id)
    {
        currentActionPlanAccount = [SELECT ID, OwnerId, Owner.Alias, Owner.UserRoleId, DE_ID_STATUS__c, DE_Owners__c, CountryRef__c, PrimaryDistributor__c, PrimaryPoS__c, ImportId__c, Owner.Name, Name, GC_VATIN_Number__c, Street__c,  ZIPPostalCode__c, City__c, GC_Mobile_Phone__c, RecordTypeId, RecordType.name, IsCreateCampaignLineItem__c, Phone, Category__c FROM Account WHERE ID = :id];
        
    }
    
}