/* -------------------------------------------------------------------------------------
* AccountTransfer Class: Controller for the AccountTransfer page
*
* Mass Account Transfer Controller Class
* - Used by the TransferContacts Page
* - Works with the TransferContactsSearchResults and searchCriteria Classes
*  ------------------------------------------------------------------------------------- */
public With Sharing class AccountTransfer{

    public string fromUserID { get; set; }
    public string toUserID { get; set; }

    public Account proxyAcctLookupTO = new Account();
    public Account proxyAcctLookupFROM = new Account();
    public Account gettoUserLookup()   { return proxyAcctLookupTO; }
    public Account getfromUserLookup() { return proxyAcctLookupFROM; }

    public boolean optSendeMailToOwner { get; set; }

    // If this is set to TRUE (by an InputHidden tag on the page) then show SOQL and other debug messages
    public boolean DebugMode = false;

    // Collection of search results for displaying
    public List<transferAccountSearchResults> searchResults = new List<transferAccountSearchResults>();

    // Collection of criteria line items using Wrapper class
    public List<searchCriteria> criteriaLine = New List<searchCriteria>();

    // Collection of fields for criteria picklist - build this once and reuse for each line
    public List<SelectOption> cacheFieldSelectValues = new List<SelectOption>();

    // Capture a Map and Set of Account Fields so we only do the Describe ONCE per instance
    private Map<String, Schema.SObjectField> accountFieldMap = null;

    // Checkboxes for transfer options:
    public Boolean transferAccounts {get;set;}
    public Boolean transferContacts {get;set;}
    public Boolean transferAcreages {get;set;}
    public Boolean transferCLIs {get;set;}
    public Boolean transferAll {get;set;}
    public Boolean transferTrials {get;set;}
    public Boolean transferVouchers {get;set;}
    public Boolean transferCases {get;set;}
    
    public Boolean queryInfo {get;set;}
    public String query {get;set;}
    public ApexPages.StandardSetController  ssc {get;set;}
    public String fieldSetName {get;set;}
    
    public List<SelectOption> AvailableYears{ get;set;}
    public List<SelectOption> AvailableDivisions{ get;set;}
    public List<SelectOption> SelectedYears {get;set;}
    public List<SelectOption> SelectedDivisions{get;set;}
    
    // Constructor
    public AccountTransfer() {
        
        AvailableYears = new List<SelectOption>();
        AvailableDivisions = new List<SelectOption>();
        SelectedYears = new List<SelectOption>();
        SelectedDivisions = new List<SelectOption>();       
        
        accountFieldMap = new Map<String, Schema.SObjectField>();    
        fieldSetName= fieldSetAssignment();
      // Build a cached list of Contact/Account fields for the criteria picklist
        BuildSearchFieldsList();
        ssc = new ApexPages.StandardSetController(new List<Account>());
      // Init the criteria object to be used on the page via <Apex:DataTable>
        for(integer j = 0; j < 5; j++) {
            searchCriteria critLine = new searchCriteria();
            critLine.SearchField = '';
            critLine.SearchOperator = '';
            critLine.SearchValue = '';
            if (j < 4) critLine.Logical = 'AND';
            criteriaLine.add(critLine);
        }
      // Transfer Options  
        transferAccounts = true;
        transferContacts = true;
        transferAcreages = true;
        transferCLIs = true;
        transferTrials = true;
        transferCases = false;
        transferVouchers = false;
        transferAll = false;
        //fieldSetName= fieldSetAssignment();
    }
    
// Create a SelectOption list Contact & Account fields for a select list
// Uses a method in the Criteria Class to build the select lists for the two objects
    private void BuildSearchFieldsList() {

        if (cacheFieldSelectValues.size() == 0) {

            // Create the Schema Lists for Account object
            //Schema.DescribeSObjectResult accountDescribe = Account.sObjectType.getDescribe();

            // Create the Maps of Fields for Account object
            Map<String, Schema.SObjectField> accountFieldsAll = Schema.SObjectType.Account.fields.getMap();
            
            for( Schema.FieldSetMember fsm : Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetName).getFields()){
                if(accountFieldsAll.get(fsm.getFieldPath()) <> null) {
                    accountFieldMap.put(fsm.getFieldPath(), accountFieldsAll.get(fsm.getFieldPath()) );
                }
            }
            searchCriteria critClass = new searchCriteria();
            // Return SelectOption lists for the Contact and Account objects
            List<SelectOption> sel2 = critClass.GetFieldsForObject(accountFieldMap, '', '');

            // Combine the two returned SelectOption[] lists into a single list
            List<SelectOption> options = new List<SelectOption>();
            options.add(new selectOption('', '- select field -'));
            for (Selectoption selOpt : sel2) {
                options.add(selOpt);
            }
            // Set the cached value so we only do this once per instance
            cacheFieldSelectValues = options;
        }
    }
    
// Returns a List<> of Criteria Objects for use with <Apex:DataTable>
// to allow multiple lines to be displayed and the values retrievable
    public list<searchCriteria> getsearchCriteria() {
        return criteriaLine;
    }

// Return the list of Contact/Account fields for the criteria picklists
    public List<SelectOption> getsearchFields() {
        return this.cacheFieldSelectValues;
    }
   
    // Get/Set methods to enable or disable DebugMode on the page.
    // This is called by an InputHidden tag on the page
    public boolean getSetDebugModeTRUE()    { this.DebugMode = true; return TRUE; }
    public boolean getSetDebugModeFALSE()   { this.DebugMode = false; return FALSE; }
    public void setSetDebugModeTRUE(boolean x)  { this.DebugMode = true; }
    public void setSetDebugModeFALSE(boolean x) { this.DebugMode = false; }

    // Returns the date format (MM/DD/YYYY, DD/MM/YYYY, etc.) that criteria should be entered in
    // This is determined in the CriteriaWrapper class by looking at the users Local settings
    public string getInputDateFormat() { return criteriaLine[0].getInputDateFormat() ; }


// -------------------------------------------------------------------------------------
// SEARCH BUTTON:
// Builds SOQL Statement based on selection criteria
// Fills searchResults[] list
// -------------------------------------------------------------------------------------
    public pageReference doSearch() {

        // Retrieve the To & From user ID's from the lookup field
        this.toUserID = proxyAcctLookupTO.OwnerID;
        
        // if not showing InActive users, then get the FROM user from the LOOKUP
        // otherwise, just use the value from the picklist of Inactive users
           //if (!this.optShowInactiveUsers) 
           this.fromUserID = proxyAcctLookupFROM.OwnerId;

        // If no TOUser selected, then show error and return
        if (toUserID == null) {
            Util.addWarningMessage('Please, select the User whose data will be transferred');
            return null;
        }

        // Build a list of ALL Account Fields for the Query. This allows the user to modify the VisualForce page to show any
        // columns they want in the display without having to modify the Class in a development environment.
        Set <String> accountFlds = accountFieldMap.keySet();
        string accountFieldsList = '';
        for (string f : accountFlds) {
            string fldType = ('' + accountFieldMap.get(f).getDescribe().getType()).replace('Schema.DisplayType.', '') ;
            if (fldType <> 'REFERENCE' && f <> 'IsDeleted' && f <> 'SystemModstamp') {
                if (accountFieldsList <> '') accountFieldsList += ', ';
                accountFieldsList += f;
            }
        }
        queryInfo=true;
        // Build the base SOQL String, querying the standard Account fields WHERE the current OwnerID = the selected value
        query = 'SELECT ' + accountFieldsList + ', Owner.Name, Owner.Alias, CreatedBy.Name, CreatedBy.Alias, LastModifiedBy.Name, RecordType.Name, LastModifiedBy.Alias ' + 'FROM Account WHERE OwnerID <> \'' + toUserID + '\' ';

        // If a From User was selected, add this to the critiera
        if (fromUserID <> null) query += ' AND OwnerID = \'' + fromUserID + '\' ';

        // For each criteria line item, call the method to build the where clause component
        for (searchCriteria cl : criteriaLine) {
                query += cl.buildWhereClause(DebugMode);
        }
        query += ' ORDER BY Name, Name LIMIT 10000' ;
        // Debug: Display the SOQL Query string
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, query));
        
        AvailableYears.clear();
        AvailableDivisions.clear();
        SelectedYears.clear();
        SelectedDivisions.clear();

        // Run the database query and place results into the TransferAccountSearchResults class
        try {
            searchResults.clear();
            
            ssc = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            ssc.setPageSize(200); 
            if(ssc.getResultSize() <= 0 && queryInfo) Util.addInfoMessage('Your query does not return any result. Please, check your filter criteria');
            else if(ssc.getResultSize() >= 10000)Util.addInfoMessage('Your query returns too many results, and only the first 10.000 will be displayed. Please, try with more restrictive search criteria.');
                       
            // Build the searchResults[] list used by the Apex:DataTable tag on the page
            for (Account c : (List<Account>) ssc.getRecords()) {
                searchResults.add( new transferAccountSearchResults(c) ) ;
            }
            
            List<string> IDs = New List<string>();
            for (transferAccountSearchResults c : searchResults) {
                IDs.add(c.account.ID);
            }
            System.debug('*** IDs' + IDs);
            
            // CR-00000375 Start Oriol 17/05/2016
            set<String> SetSelectedYears = new set<String>();
            set<String> SetSelectedDivisions = new set<String>();
            
            if(ssc.getResultSize()>0 && ssc.getResultSize()<10000){
                
                // Get Acreages Years and Divisions
                for (Acreage__c Acr : [SELECT id, AcrYearRef__c, AcrYearRef__r.name, AcrProductGroupRef__c, AcrProductGroupRef__r.name FROM Acreage__c WHERE    AcrFarmRef__c IN :IDs]){
                    if(Acr.AcrYearRef__r.name != null){
                        SetSelectedYears.add(Acr.AcrYearRef__r.name);
                    }
                    If(Acr.AcrProductGroupRef__r.name != null){
                        SetSelectedDivisions.add(Acr.AcrProductGroupRef__r.name);
                    }
                }
                // Get CLIs Years and Divisions
                for (Campaignlineitem__c CLI : [SELECT id, year__c,     Division__c FROM Campaignlineitem__c WHERE FarmRef__c IN :IDs]){
                    if(CLI.year__c != null){
                        SetSelectedYears.add(CLI.year__c);
                    }
                    if (CLI.Division__c != null){
                        SetSelectedDivisions.add(CLI.Division__c);
                    }
                }
                // Get Vouchers Years and Divisions
                for (VoucherLineItem__c Vouch : [SELECT id, CampaignLineItemRef__r.year__c,  CampaignLineItemRef__r.Division__c FROM VoucherLineItem__c WHERE VoucherRef__r.AccountRef__c IN :IDs]){
                    if (Vouch.CampaignLineItemRef__r.year__c != null){
                        SetSelectedYears.add(Vouch.CampaignLineItemRef__r.year__c);
                    }
                    if(Vouch.CampaignLineItemRef__r.Division__c != null){
                        SetSelectedDivisions.add(Vouch.CampaignLineItemRef__r.Division__c);
                    }
                }
                // Get NPS cases Years and Divisions
                for (Case NPSCase : [SELECT id, NPS_CAMPAIGN__r.YearV2__r.name, NPS_CAMPAIGN__r.DivisionRef__r.name FROM Case WHERE RecordTypeId='012D00000003Bof' AND AccountId IN :IDs]){
                    if (NPSCase.NPS_CAMPAIGN__r.YearV2__r.name != null){
                        SetSelectedYears.add(NPSCase.NPS_CAMPAIGN__r.YearV2__r.name);
                    }
                    if(NPSCase.NPS_CAMPAIGN__r.DivisionRef__r.name != null){
                        SetSelectedDivisions.add(NPSCase.NPS_CAMPAIGN__r.DivisionRef__r.name);
                    }
                }
                List<String> ListSelectedYears = new List<String>();
                ListSelectedYears.addAll(SetSelectedYears);
                ListSelectedYears.sort();
                
                for (String SY : ListSelectedYears){
                    SelectedYears.add(new SelectOption(SY,SY));
                }
                for (String SD : SetSelectedDivisions){
                    SelectedDivisions.add(new SelectOption(SD,SD));
                }
                
                System.debug('***List years: ' + SelectedYears);
                System.debug('***List Divisions: ' + SelectedDivisions);
            }
        
            // CR-00000375 End Oriol 17/05/2016
            
        } catch (Exception ex) {
                // ERROR! Display message on screen
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query Error: ' + ex.getMessage()));
        }        
        return null;
    }
    
    // Used with the Style attribute on the OutputPanel tag show the search results if there are any
    public string getShowBlockIfResults() {
        if (this.searchResults.size() > 0) return 'display: block;' ;
        else return 'display: none;' ;
        return null;
    }
    
    // ----------------------------------------------------------------------
    // Transfer Button:
    // - Query the selected Accounts
    // - Change the OwnerID
    // - Call database.update()
    // - Check for errors
    // - Send an eMail if needed
    // - Rerun the query to display any remaining Accounts
    // ----------------------------------------------------------------------
    
    /*** TRANSFER SELECTED ***/
    
    public pageReference doTransfer() {
        
        if (toUserID == '' || toUserID == null) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: A "To User" must be specified'));
            return null;
        }

        // Build a list of Contact ID's to transfer ownership for
        List<string> IDs = New List<string>();
        
        //Map<Id, Account> TransAc = new Map<Id, Account>();
        String accountIds='';
        for (transferAccountSearchResults c : searchResults) {
            if (c.selected){
                IDs.add(c.account.ID);
                accountIds+= c.account.ID + ',';
            }   
        }
        
        if(IDs.size()<=0){
            Util.addWarningMessage('You have not selected any row. Please, select rows to be transferred');
            return null;
        }   
             
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Count: ' + IDs.size()));
        
        //Get selected divisions and years
        List<String> ListYears = new List<String>();
        List<String> ListDivisions = new List<String>();
        if (SelectedYears.size()>0){
            for (selectoption Yrs : SelectedYears){
                ListYears.add(Yrs.getvalue());
            }
        }
        if (SelectedDivisions.size()>0){
            for (selectoption Dvs : SelectedDivisions){
                ListDivisions.add(Dvs.getvalue());
            }
        }
        system.debug('Years list: ' + ListYears);
        system.debug('Divisions list: ' + ListDivisions);
        // set a database savepoint that can be used to rollback the changes if it fails
        SavePoint sp = database.setSavepoint();
        
        List<database.saveresult> srs = null;
        Integer transferCount = 0;
        
        List<Contact> txfrContact = New List<Contact>();
        List<Acreage__c> txfrAcreage = New List<Acreage__c>();
        List<CampaignLineItem__c> txfrCLI = New List<CampaignLineItem__c>();
        List<CampaignLineItem__c> txfrTrial = New List<CampaignLineItem__c>();
        List<CampaignLineItemGroup__c> txfrTrialGroup = New List<CampaignLineItemGroup__c>();
        List<Case> txfrCase = New List<Case>();
        List<Voucher__c> txfrVoucher = New List<Voucher__c>();
        List<VoucherLineItem__c> txfrVLI = New List<VoucherLineItem__c>();
        string whereAmI='';
        
        //Transfer Account
        // Moved the account update to later so that we can compare original account owner in Tasks/Notes transfer instead of using unreliably populated fromUserId variable  
        List<Account> accounts = [SELECT ID, OwnerID, Name, Owner.Alias FROM Account WHERE ID IN :IDs];
        for (Account c : accounts) {
            c.ownerID = toUserID;
        }
        
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Query Size: ' + accounts.size()));
        
        //Transfer Contacts
        if(transferContacts){
            if(transferAll) txfrContact = [SELECT ID, OwnerID, Name FROM Contact WHERE AccountID IN :IDs];
            else if (fromUserID != null) txfrContact = [SELECT ID, OwnerID, Name FROM Contact WHERE OwnerId=:fromUserID AND AccountID IN :IDs];      
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Contact c : txfrContact) {
                c.OwnerId = toUserID;
            }
        }
        
        //Transfer Acreages
        if(transferAcreages){
            if (transferAll) txfrAcreage = [SELECT ID, OwnerID, Name FROM Acreage__c WHERE AcrFarmRef__c IN :IDs AND AcrYearRef__r.name IN :ListYears AND AcrProductGroupRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrAcreage = [SELECT ID, OwnerID, Name FROM Acreage__c WHERE OwnerId=:fromUserID AND AcrFarmRef__c IN :IDs AND AcrYearRef__r.name IN :ListYears AND AcrProductGroupRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Acreage__c c : txfrAcreage) {
                c.OwnerId = toUserID;
            }
        }
        
        //Transfer CLIs
        Map<id, id> caTransf = new Map<id, id>();
        if(transferCLIs){
            if (transferAll) txfrCLI = [SELECT ID, OwnerID, Name, CampaignRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B2' AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else if (fromUserID != null) txfrCLI = [SELECT ID, OwnerID, Name, CampaignRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B2' AND OwnerId=:fromUserID AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> idCam = new set<id>();
            for (CampaignLineItem__c c : txfrCLI) {
                c.OwnerId = toUserID;
                idCam.add(c.CampaignRef__c);
            }
            
          if(txfrCLI.size()>0){
            List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by the FromUserID.
            List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by the ToUserID.
            List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : idCam]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
               Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){ // Homologous Campaign creation for the ToUserID.
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca);                 //Adding new Campaigns to txfrNewCam.
                }
            }
                    
            Savepoint sp2 = Database.setSavepoint(); //The Savepoint stores the current database.
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                }
                    
                    if(NewID.size() > 0){
                      String msg = 'Action Plan. Created Campaigns:<br/>';
                        for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                            //Query which selects some info to be shown.
                            msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                        }
                    Util.addConfirmMessage(msg);
                    }
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp2); //Restore the database as saved in Savepoint "sp2".
                return null;
            }   
            
            txfrCamTo.addAll(txfrNewCam);
            
            for(Campaign cF : txfrCamFROM){
                for(Campaign cT : txfrCamTo){
                    if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                       && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                       caTransf.put(cF.id, cT.id); //Save "from user" id and "to user" id.
                }
            }
          }
        }  

        //Transfer Trials
    Map<id, id> trialTransf = new Map<id, id>();
        if(transferTrials){
            if (transferAll) txfrTrial = [SELECT ID, OwnerID, Name, CampaignRef__c, CampaignLineItemGroupRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B3' AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else if (fromUserID != null) txfrTrial = [SELECT ID, OwnerID, Name, CampaignRef__c, CampaignLineItemGroupRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B3' AND OwnerId=:fromUserID AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> idTrialCampaigns = new set<id>();
            set<id> IDTrialGroups = new set<id>();
            for (CampaignLineItem__c c : txfrTrial) {
                c.OwnerId = toUserID;
                if(c.CampaignRef__c !=null) idTrialCampaigns.add(c.CampaignRef__c);
                if(c.CampaignLineItemGroupRef__c !=null) IDTrialGroups.add(c.CampaignLineItemGroupRef__c);
            }
         
          if(txfrTrial.size()>0){
            List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by the FromUserID.
            List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by the ToUserID.
            List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : idTrialCampaigns]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
               Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){ // Homologous Campaign creation for the ToUserID.
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca); //Adding new Campaigns to txfrNewCam.
                }
            }
                    
            Savepoint sp3 = Database.setSavepoint(); //The Savepoint stores the current database.
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                    }
                    
                    if(NewID.size() > 0){
                      String msg = 'Trial. Created Campaigns:<br/>';
                        for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                            //Query which selects some info to be shown.
                            msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                        }
                    Util.addConfirmMessage(msg);
                    }
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp3); //Restore the database as saved in Savepoint "sp3".
                return null;
            }
            
            txfrCamTo.addAll(txfrNewCam);
            
            for(Campaign cF : txfrCamFROM){
                for(Campaign cT : txfrCamTo){
                    if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                       && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                       trialTransf.put(cF.id, cT.id); //Save "from user" id and "to user" id.
                }
            }
          }
          
          if(IDTrialGroups!=null){
            if (transferAll) txfrTrialGroup = [SELECT ID, OwnerID, CampaignRef__c FROM CampaignLineItemGroup__c WHERE recordtypeid='012D000000035B0' AND ID IN :IDTrialGroups];
            else if (fromUserID != null) txfrTrialGroup = [SELECT ID, OwnerID, CampaignRef__c FROM CampaignLineItemGroup__c WHERE recordtypeid='012D000000035B0' AND OwnerId=:fromUserID AND ID IN :IDTrialGroups];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (CampaignLineItemGroup__c c : txfrTrialGroup) {
                c.OwnerId = toUserID;
            }
          }
        }

        //Transfer NPS cases
        if (transferCases){
            if (transferAll) txfrCase = [SELECT ID, OwnerID FROM Case WHERE RecordTypeId='012D00000003Bof' AND AccountId IN :IDs AND NPS_CAMPAIGN__r.YearV2__r.name IN :ListYears AND NPS_CAMPAIGN__r.DivisionRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrCase = [SELECT ID, OwnerID FROM Case WHERE RecordTypeId='012D00000003Bof' AND OwnerId=:fromUserID AND AccountId IN :IDs AND NPS_CAMPAIGN__r.YearV2__r.name IN :ListYears AND NPS_CAMPAIGN__r.DivisionRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Case c : txfrCase) {
              c.OwnerId = toUserID;
            }           
        }
        
        //Transfer Vouchers
        Map<id, id> VoucherTransf = new Map<id, id>();
        if(transferVouchers){
            if (transferAll) txfrVoucher = [SELECT ID, OwnerID, Name, CampaignRef__c, VoucherCampaignRef__c FROM Voucher__c WHERE AccountRef__c IN :IDs AND CampaignRef__r.YearV2__r.name IN :ListYears AND CampaignRef__r.DivisionRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrVoucher = [SELECT ID, OwnerID, Name, CampaignRef__c, VoucherCampaignRef__c FROM Voucher__c WHERE OwnerId=:fromUserID AND AccountRef__c IN :IDs AND CampaignRef__r.YearV2__r.name IN :ListYears AND CampaignRef__r.DivisionRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> IdVoucherCampaigns = new set<id>();
            set<id> IdVouchers = new set<id>();
            for (Voucher__c c : txfrVoucher) {
                c.OwnerId = toUserID;
                if(c.CampaignRef__c !=null) IdVoucherCampaigns.add(c.CampaignRef__c);
                IdVouchers.add(c.id);
            }
            
            if(txfrVoucher.size()>0){
                List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by FromUserID.
                List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by ToUserID.
                List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : IdVoucherCampaigns]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
                Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){ // Homologous Campaign creation for ToUserID.
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca); //Adding new Campaigns to txfrNewCam.
                }
            }
                    
            Savepoint sp3 = Database.setSavepoint(); //The Savepoint stores the current database.
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                }
                    
                if(NewID.size() > 0){
                  String msg = 'Voucher. Created Campaigns:<br/>';
                    for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                        //Query which selects some info to be shown.
                        msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                    }
                Util.addConfirmMessage(msg);
                }
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp3); //Restore the database as saved in Savepoint "sp3".
                return null;
            }
            
            txfrCamTo.addAll(txfrNewCam);
            
                for(Campaign cF : txfrCamFROM){
                    for(Campaign cT : txfrCamTo){
                        if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                        VoucherTransf.put(cF.id, cT.id); //Save "from user" id and "to user" id.
                    }
                }
            }
          
          //Voucher line items
            if(txfrVoucher.size()>0){
                txfrVLI = [SELECT ID, OwnerID, VoucherRef__c FROM VoucherLineItem__c WHERE VoucherRef__c IN :IdVouchers];
                for (VoucherLineItem__c c : txfrVLI) {
                c.OwnerId = toUserID;
                }
            }
        }
        
        try {
            if(transferAcreages && txfrAcreage.size() > 0){
                whereAmI='Acreages';
                Database.SaveResult[] updateList = Database.update(txfrAcreage, true); //Update Acreages.          
            }
            if(transferCLIs && txfrCLI.size()>0){
                whereAmI='Action Plan';
                for(CampaignLineItem__c cLI : txfrCLI){
                  if(cLI.CampaignRef__C!=null) cLI.CampaignRef__c=caTransf.get(cLI.CampaignRef__C);
                }
                Database.SaveResult[] updateList = Database.update(txfrCLI, true);
            }
            if(transferTrials && txfrTrial.size()>0){
                whereAmI='Trials';
                for(CampaignLineItem__c Trial : txfrTrial){
                  if(Trial.CampaignRef__C!=null) Trial.CampaignRef__c=TrialTransf.get(Trial.CampaignRef__C);
                }
                Database.SaveResult[] updateList = Database.update(txfrTrial, true);
                
                for(CampaignLineItemGroup__c TrialGroup : txfrTrialGroup){
                  if(TrialGroup.CampaignRef__C!=null) TrialGroup.CampaignRef__c=TrialTransf.get(TrialGroup.CampaignRef__C);
                }
                Database.SaveResult[] updateList1 = Database.update(txfrTrialGroup, true);
            }

            if(transferContacts && txfrContact.size()>0){
                whereAmI='Contacts';
                Database.SaveResult[] updateList = Database.update(txfrContact, true);
            }   
            if(transferCases && txfrCase.size()>0){
                whereAmI='Cases';
                Database.SaveResult[] updateList = Database.update(txfrCase, true);
            }
            if(transferVouchers && txfrVoucher.size()>0){
                whereAmI='Vouchers';
                for(Voucher__c Voucher : txfrVoucher){
                  if(Voucher.CampaignRef__C!=null) Voucher.CampaignRef__c=VoucherTransf.get(Voucher.CampaignRef__C);
                } 
                Database.SaveResult[] updateList = Database.update(txfrVoucher, true);
                if(txfrVLI.size()>0) Database.SaveResult[] updateList1 = Database.update(txfrVLI, true);
            }           
            if(transferAccounts){
                whereAmI='Accounts';
                Database.SaveResult[] updateList = Database.update(accounts, true);
            }
            whereAmI='History';
            if(AccountIds <> null && AccountIds!=''){
                insert new updateHistory__c (
                    Process__c='Mass Transfer',
                    UpdateDate__c=System.now(),
                    FromRef__c=fromUserID,
                    ToRef__c=toUserId,
                    Query__c=(query.split('FROM Account ')).get(1),
                    AccountIds__c= accountIds.Substring(0,accountIds.length()-1),
                    Acreages__c=transferAcreages,
                    CampaignLineItems__c=transferCLIs,
                    CHK_TRIALS__c=transferTrials,
                    CHK_VOUCHERS__c=transferVouchers,
                    CHK_CASES__c=transferCases,
                    Contacts__c=transferContacts,
                    TransferAll__c=transferAll
                );
            }
        } catch (exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error Transferring ' + whereAmI + ':' + e.getMessage() ));
            database.rollback(sp);
            return null;
        }
        Util.addConfirmMessage('Data have been transferred Successfully');
        queryInfo=false;
        doSearch();
        return null;
    }

    // Return searchResults to the DATAGRID
    public list<transferAccountSearchResults> getSearchResults() {
        if (fromUserID != '') {
            return this.searchResults;
        } else {
            return null ;
        }
    }
    
  /*** TRANSFER ALL ***/
  
  public pageReference doTransferAll() {
        
        if (toUserID == '' || toUserID == null) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: A "To User" must be specified'));
            return null;
        }

        List<string> IDs = New List<string>();
        
        String accountIds='';
        for (Account c :(List<Account>) Database.query(query)) {
                IDs.add(c.Id);
                accountIds+= c.Id + ',';
        }
        
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Count: ' + IDs.size()));
        
        //Get selected divisions and years
        List<String> ListYears = new List<String>();
        List<String> ListDivisions = new List<String>();
        if (SelectedYears.size()>0){
            for (selectoption Yrs : SelectedYears){
                ListYears.add(Yrs.getvalue());
            }
        }
        if (SelectedDivisions.size()>0){
            for (selectoption Dvs : SelectedDivisions){
                ListDivisions.add(Dvs.getvalue());
            }
        }
        system.debug('Years list: ' + ListYears);
        system.debug('Divisions list: ' + ListDivisions);
        
        SavePoint sp = database.setSavepoint();
        
        List<database.saveresult> srs = null;
        Integer transferCount = 0;
        
        List<Contact> txfrContact = New List<Contact>();
        List<Acreage__c> txfrAcreage = New List<Acreage__c>();
        List<CampaignLineItem__c> txfrCLI = New List<CampaignLineItem__c>();
        List<CampaignLineItem__c> txfrTrial = New List<CampaignLineItem__c>();
        List<CampaignLineItemGroup__c> txfrTrialGroup = New List<CampaignLineItemGroup__c>();
        List<Case> txfrCase = New List<Case>();
        List<Voucher__c> txfrVoucher = New List<Voucher__c>();
        List<VoucherLineItem__c> txfrVLI = New List<VoucherLineItem__c>();
        string whereAmI='';
        
        //Transfer Account
        // Moved the account update to later so that we can compare original account owner in Tasks/Notes transfer instead of using unreliable populated fromUserId variable  
        List<Account> accounts = [SELECT ID, OwnerID, Name, Owner.Alias FROM Account WHERE ID IN :IDs];
        for (Account c : accounts) {
            c.ownerID = toUserID;
        }
        if (DebugMode) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Query Size: ' + accounts.size()));
        
        //Transfer Contacts
        if(transferContacts){
            if(transferAll) txfrContact = [SELECT ID, OwnerID, Name FROM Contact WHERE AccountID IN :IDs];
            else if (fromUserID != null) txfrContact = [SELECT ID, OwnerID, Name FROM Contact WHERE OwnerId=:fromUserID AND AccountID IN :IDs];      
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Contact c : txfrContact) {
                c.OwnerId = toUserID;
            }
        }
        
        //Transfer Acreages
        if(transferAcreages){
            if (transferAll) txfrAcreage = [SELECT ID, OwnerID, Name FROM Acreage__c WHERE AcrFarmRef__c IN :IDs AND AcrYearRef__r.name IN :ListYears AND AcrProductGroupRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrAcreage = [SELECT ID, OwnerID, Name FROM Acreage__c WHERE OwnerId=:fromUserID AND AcrFarmRef__c IN :IDs AND AcrYearRef__r.name IN :ListYears AND AcrProductGroupRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Acreage__c c : txfrAcreage) {
                c.OwnerId = toUserID;
            }
        }
        
        //Transfer CLIs
        Map<id, id> caTransf = new Map<id, id>();
        if(transferCLIs){
            if (transferAll) txfrCLI = [SELECT ID, OwnerID, Name, CampaignRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B2' AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else if (fromUserID != null) txfrCLI = [SELECT ID, OwnerID, Name, CampaignRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B2' AND OwnerId=:fromUserID AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> idCam = new set<id>();
            for (CampaignLineItem__c c : txfrCLI) {
                c.OwnerId = toUserID;
                idCam.add(c.CampaignRef__c);
            }
            
          if(txfrCLI.size()>0){
            List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by FromUserID.
            List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by ToUserID.
            List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : idCam]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
               Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca);
                }
            }
                    
            Savepoint sp2 = Database.setSavepoint();  
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                    }
                    
                    if(NewID.size() > 0){
                      String msg = 'Action Plan. Created Campaigns:<br/>';
                        for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                            //Query which selects some info to be shown.
                            msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                        }
                    Util.addConfirmMessage(msg);
                    }     
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp2);
                return null;
            }   
            
            txfrCamTo.addAll(txfrNewCam);
            
            for(Campaign cF : txfrCamFROM){
                for(Campaign cT : txfrCamTo){
                    if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                       && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                       caTransf.put(cF.id, cT.id);
                }
            }
          }
        }

    //Transfer Trials
    Map<id, id> trialTransf = new Map<id, id>();
        if(transferTrials){
            if (transferAll) txfrTrial = [SELECT ID, OwnerID, Name, CampaignRef__c, CampaignLineItemGroupRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B3' AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else if (fromUserID != null) txfrTrial = [SELECT ID, OwnerID, Name, CampaignRef__c, CampaignLineItemGroupRef__c FROM CampaignLineItem__c WHERE RecordTypeId='012D000000035B3' AND OwnerId=:fromUserID AND FarmRef__c IN :IDs AND Year__c IN :ListYears AND Division__c IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> idTrialCampaigns = new set<id>();
            set<id> IDTrialGroups = new set<id>();
            for (CampaignLineItem__c c : txfrTrial) {
                c.OwnerId = toUserID;
                if(c.CampaignRef__c !=null) idTrialCampaigns.add(c.CampaignRef__c);
                if(c.CampaignLineItemGroupRef__c !=null) IDTrialGroups.add(c.CampaignLineItemGroupRef__c);
            }
            
        if(txfrTrial.size()>0){
            List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by FromUserID.
            List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by ToUserID.
            List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : idTrialCampaigns]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
               Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){ // Homologous Campaign creation for the ToUserID.
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca); //Adding new Campaigns to txfrNewCam.
                }
            }
                    
            Savepoint sp3 = Database.setSavepoint(); //The Savepoint stores the current database.
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                    }
                    
                    if(NewID.size() > 0){
                      String msg = 'Trial. Created Campaigns:<br/>';
                        for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                            //Query which selects some info to be shown.
                            msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                        }
                    Util.addConfirmMessage(msg);
                    }                     
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp3); //Restore the database as saved in Savepoint "sp3".
                return null;
            }   
            
            txfrCamTo.addAll(txfrNewCam);
            
            for(Campaign cF : txfrCamFROM){
                for(Campaign cT : txfrCamTo){
                    if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                       && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                       trialTransf.put(cF.id, cT.id); //Save "from user" id and "to user" id.
                }
            }
          }
          if(IDTrialGroups!=null){
            if (transferAll) txfrTrialGroup = [SELECT ID, OwnerID, CampaignRef__c FROM CampaignLineItemGroup__c WHERE recordtypeid='012D000000035B0' AND ID IN :IDTrialGroups];
            else if (fromUserID != null) txfrTrialGroup = [SELECT ID, OwnerID, CampaignRef__c FROM CampaignLineItemGroup__c WHERE recordtypeid='012D000000035B0' AND OwnerId=:fromUserID AND ID IN :IDTrialGroups];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (CampaignLineItemGroup__c c : txfrTrialGroup) {
                c.OwnerId = toUserID;
            }
          }
        }
        
        //Transfer NPS cases
        if (transferCases){
            if (transferAll) txfrCase = [SELECT ID, OwnerID FROM Case WHERE RecordTypeId='012D00000003Bof' AND AccountId IN :IDs AND NPS_CAMPAIGN__r.YearV2__r.name IN :ListYears AND NPS_CAMPAIGN__r.DivisionRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrCase = [SELECT ID, OwnerID FROM Case WHERE RecordTypeId='012D00000003Bof' AND OwnerId=:fromUserID AND AccountId IN :IDs AND NPS_CAMPAIGN__r.YearV2__r.name IN :ListYears AND NPS_CAMPAIGN__r.DivisionRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            for (Case c : txfrCase) {
              c.OwnerId = toUserID;
            }           
        }
        
        //Transfer Vouchers
        Map<id, id> VoucherTransf = new Map<id, id>();
        if(transferVouchers){
            if (transferAll) txfrVoucher = [SELECT ID, OwnerID, Name, CampaignRef__c, VoucherCampaignRef__c FROM Voucher__c WHERE AccountRef__c IN :IDs AND CampaignRef__r.YearV2__r.name IN :ListYears AND CampaignRef__r.DivisionRef__r.name IN :ListDivisions];
            else if (fromUserID != null) txfrVoucher = [SELECT ID, OwnerID, Name, CampaignRef__c, VoucherCampaignRef__c FROM Voucher__c WHERE OwnerId=:fromUserID AND AccountRef__c IN :IDs AND CampaignRef__r.YearV2__r.name IN :ListYears AND CampaignRef__r.DivisionRef__r.name IN :ListDivisions];
            else {Util.addWarningMessage('Please select "From User" or check "Include related records from other owners" and click "Find" again');
            return null;
            }
            set<id> IdVoucherCampaigns = new set<id>();
            set<id> IdVouchers = new set<id>();
            for (Voucher__c c : txfrVoucher) {
                c.OwnerId = toUserID;
                if(c.CampaignRef__c !=null) IdVoucherCampaigns.add(c.CampaignRef__c);
                IdVouchers.add(c.id);
            }
            if(txfrVoucher.size()>0){
                List<Campaign> txfrCamFROM = New List<Campaign>(); //Campaigns owned by the FromUserID.
                List<Campaign> txfrCamTO = New List<Campaign>(); //Campaigns owned by the ToUserID.
                List<Campaign> txfrNewCam = New List<Campaign>(); //New campaigns if homologous doesn't exist.
            
            set<id> idYearCam = new set<id>();
            set<id> idDivisionCam = new set<id>();
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE id IN : IdVoucherCampaigns]){
                txfrCamFROM.add(Cam);
                idYearCam.add(cam.YearV2__c);
                idDivisionCam.add(cam.DivisionRef__c);
            }
            
            for(Campaign Cam : [SELECT id,StartDate, EndDate, ArchiveDate__c,YearV2__c,DivisionRef__c,CompetitorPCMRef__c,SalesPCMRef__c,TaxSalesPCMRef_RSA__c,TrialPCMRef__c,GiveAwayPCMRef__c, CountryRef__c, parentId FROM Campaign WHERE ownerId =: toUserID and YearV2__c IN: idYearCam and DivisionRef__c IN: idDivisionCam]){
                txfrCamTo.add(Cam);
            }
            
            for(Campaign cF : txfrCamFROM){ 
                Boolean entra=false;
                for(Campaign cT : txfrCamTo){
                    if( cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c) entra=true;
                }
                if(!entra){ // Homologous Campaign creation for the ToUserID.
                    Campaign Ca = new Campaign( Name = 'this field will be recalculated',YearV2__c=cF.YearV2__c,DivisionRef__c=cF.DivisionRef__c,CompetitorPCMRef__c = cF.CompetitorPCMRef__c,
                                    TaxSalesPCMRef_RSA__c=cF.TaxSalesPCMRef_RSA__c,TrialPCMRef__c=cF.TrialPCMRef__c,GiveAwayPCMRef__c = cF.GiveAwayPCMRef__c,OwnerId = ToUserId,
                                                SalesPCMRef__c=cF.SalesPCMRef__c, CountryRef__c=cF.CountryRef__c, TotalCampaignBudget__c=1, StartDate=cF.StartDate, EndDate=cF.EndDate, ArchiveDate__c=cF.ArchiveDate__c, ParentId=cF.ParentId);
                    txfrNewCam.add(Ca); //Adding new Campaigns to txfrNewCam.
                }
            }
                    
            Savepoint sp3 = Database.setSavepoint(); //The Savepoint stores the current database.
            try{
                  Database.SaveResult[] insertList = Database.insert(txfrNewCam, true);
                  List<string> NewID = New List<string>(); //New IDs list
                for (Database.SaveResult CreatedCampaigns : insertList) {
                    if (CreatedCampaigns.isSuccess()) {                 
                    NewID.add(CreatedCampaigns.getId());
                    //Operation was successful, so get the ID of the record that was processed  
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : CreatedCampaigns.getErrors()) {
                            System.debug('DTCLI1: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DTCLI1: Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    
                }
                    
                if(NewID.size() > 0){
                  String msg = 'Voucher. Created Campaigns:<br/>';
                    for(Campaign Camp : [SELECT id, Name, TXT_PARENT_CAMP_OWNER__c FROM Campaign WHERE id IN : NewID]){
                        //Query which selects some info to be shown.
                        msg+='Campaign: ' + Camp.Name + ' with ID: ' + Camp.Id + ' and ' + Camp.TXT_PARENT_CAMP_OWNER__c + ' as Manager' + '<br/>';
                    }
                Util.addConfirmMessage(msg);
                }
            }catch(Exception e){
                Util.addErrorMessage('The transfer process has failed due to new Campaign insertion : '+e.getmessage()+'Please, contact Support Team');
                Database.rollback(sp3); //Restore the database as saved in Savepoint "sp3".
                return null;
            }
            
            txfrCamTo.addAll(txfrNewCam);
            
                for(Campaign cF : txfrCamFROM){
                    for(Campaign cT : txfrCamTo){
                        if(cF.YearV2__c == cT.YearV2__c && cF.DivisionRef__c == cT.DivisionRef__c && cF.CountryRef__c == cT.CountryRef__c && cF.CompetitorPCMRef__c == cT.CompetitorPCMRef__c 
                        && cF.SalesPCMRef__c == cT.SalesPCMRef__c && cF.TrialPCMRef__c == cT.TrialPCMRef__c && cF.GiveAwayPCMRef__c == cT.GiveAwayPCMRef__c)
                        VoucherTransf.put(cF.id, cT.id); //Save "from user" id and "to user" id.
                    }
                }
            }
          // Voucher line items
            if(txfrVoucher.size()>0){
                txfrVLI = [SELECT ID, OwnerID, VoucherRef__c FROM VoucherLineItem__c WHERE VoucherRef__c IN :IdVouchers];
                for (VoucherLineItem__c c : txfrVLI) {
                c.OwnerId = toUserID;
                }
            }
        }
        
        try {
            if(transferAcreages && txfrAcreage.size() > 0){
                whereAmI='Acreages';
                Database.SaveResult[] updateList = Database.update(txfrAcreage, true);          
            }
            if(transferCLIs && txfrCLI.size()>0){
                whereAmI='Action Plan';
                for(CampaignLineItem__c cLI : txfrCLI){
                  if(cLI.CampaignRef__C!=null) cLI.CampaignRef__c=caTransf.get(cLI.CampaignRef__C);
                }
                Database.SaveResult[] updateList = Database.update(txfrCLI, true);              
            }
            if(transferTrials && txfrTrial.size()>0){
                whereAmI='Trials';
                for(CampaignLineItem__c Trial : txfrTrial){
                  if(Trial.CampaignRef__C!=null) Trial.CampaignRef__c=TrialTransf.get(Trial.CampaignRef__C);
                }
                Database.SaveResult[] updateList = Database.update(txfrTrial, true);
                
                for(CampaignLineItemGroup__c TrialGroup : txfrTrialGroup){
                  if(TrialGroup.CampaignRef__C!=null) TrialGroup.CampaignRef__c=TrialTransf.get(TrialGroup.CampaignRef__C);
                }
                Database.SaveResult[] updateList1 = Database.update(txfrTrialGroup, true);              
            }           
            if(transferContacts && txfrContact.size()>0){
                whereAmI='Contacts';
                Database.SaveResult[] updateList = Database.update(txfrContact, true);              
            }
            if(transferCases && txfrCase.size()>0){
                whereAmI='Cases';
                Database.SaveResult[] updateList = Database.update(txfrCase, true);
            }
            if(transferVouchers && txfrVoucher.size()>0){
                whereAmI='Vouchers';
                for(Voucher__c Voucher : txfrVoucher){
                  if(Voucher.CampaignRef__C!=null) Voucher.CampaignRef__c=VoucherTransf.get(Voucher.CampaignRef__C);
                } 
                Database.SaveResult[] updateList = Database.update(txfrVoucher, true);
                if(txfrVLI.size()>0) Database.SaveResult[] updateList1 = Database.update(txfrVLI, true);
            }   
            if(transferAccounts){
                whereAmI='Accounts';
                Database.SaveResult[] updateList = Database.update(accounts, true);
            }
            whereAmI='History';
            if(AccountIds <> null && AccountIds!=''){
                insert new updateHistory__c (
                    Process__c='Mass Transfer',
                    UpdateDate__c=System.now(),
                    FromRef__c=fromUserID,
                    ToRef__c=toUserId,
                    Query__c=(query.split('FROM Account ')).get(1),
                    AccountIds__c= accountIds.Substring(0,accountIds.length()-1),
                    Acreages__c=transferAcreages,
                    CampaignLineItems__c=transferCLIs,
                    CHK_TRIALS__c=transferTrials,
                    Contacts__c=transferContacts,
                    TransferAll__c=transferAll
                );
            }
        } catch (exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error Transferring ' + whereAmI + ':' + e.getMessage() ));
            database.rollback(sp);
            return null;
        }
        Util.addConfirmMessage('Data have been transferred Successfully');
        queryInfo=false;
        doSearch();        
        return null;
    }

    private boolean sendEMail(List<Account> TransferedAccounts) {
        string htmlBody = '<HTML><BODY><h3>';
        string textBody = '';

        htmlbody += 'The following Accounts were just transferred to you by ' + UserInfo.getName() + '</h3>';
        textBody += 'The following Accounts were just transferred to you ' + UserInfo.getName() + ':\r\r';

        // Build table/list of Contacts Transferred
        htmlBody += '<Table width="100%"><TR><TD width="25%"><B>Account Name</B></TD>' +
           '<TD><B>Old Owner</B></TD></TR>';
        textBody += 'ACCOUNT NAME\t\t\tOLD OWNER\r';

        // Use this to get the base URL of the SalesForce instance
        string BaseURL = ApexPages.currentPage().getHeaders().get('Host');

        // Build the table/list of contacts
        // Make the Name field a link to the contact
        for (Account c : TransferedAccounts) {
            pageReference cView = new ApexPages.StandardController(c).view();
            htmlBody += '<TR><TD><a href="' + BaseURL + cView.getUrl() + '">' + null2String(c.Name) + '</a></TD><TD>' + c.Owner.Alias + '</TD></TR>';
            textBody += null2String(c.Name) + '\t\t\t' + c.Owner.Alias + '\r';
        }
        htmlBody += '</Table>';

        // Get the target user eMail address
        User user = [SELECT ID, eMail FROM User Where ID = :toUserID Limit 1];

        // Create the eMail object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Set the TO address
        String[] toAddresses = new String[] {user.Email};
        mail.setToAddresses(toAddresses);

        // Specify the name used as the display name.
        mail.setSenderDisplayName(UserInfo.getName());

        // Specify the subject line for your email address.
        mail.setSubject(TransferedAccounts.size() + ' Accounts Transferred To You');

        // Set options
        mail.setBccSender(false);
        mail.setUseSignature(false);

        // Specify the text content of the email.
        mail.setPlainTextBody(textBody);
        mail.setHtmlBody(htmlBody);

        // Send the email
        Messaging.SendEmailResult [] sr = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        if (!sr[0].isSuccess()) {
            // Error sending the message; display the error on the page
            Messaging.SendEmailError r = sr[0].getErrors()[0];
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Sending Message: ' + sr[0].getErrors()[0].getMessage() ));
            return false;
        } else { return true; }

    }
    //Method to retrieve the Fieldset
    public String fieldSetAssignment(){
        String returned = 'MassTransferFields'+Util.CurrentUser.CountryISOCode__c;
        //System.Debug('Enric'+returned+Schema.SObjectType.Account.fieldSets.getMap().get(returned));
        if (Schema.SObjectType.Account.fieldSets.getMap().get(returned) <> null) return returned;
        else return 'MassTransferFields';
    }
    
    //Pagination Methods
    public Boolean hasPrevious{  //Done
        get{  
            return ssc.getHasPrevious();  
        }  
        set;  
    }
    
    public Integer pageNumber{ //Done
        get{
            return ssc.getPageNumber();
        }
        set;
    }
    
    public Boolean hasNext{  //Done
        get{  
            return ssc.getHasNext();  
        }  
        set;  
    }  
    
    public void previous(){ //Done
        searchResults.clear();
        ssc.previous();
        for (Account c : (List<Account>) ssc.getRecords()) {
            searchResults.add( new transferAccountSearchResults(c) ) ;
        }
    }
    
    public void next(){ //Done
        searchResults.clear();
        ssc.next();
        for (Account c : (List<Account>) ssc.getRecords()) {
            searchResults.add( new transferAccountSearchResults(c) ) ;
        }
    }
  
    // Simple function to convert NULL to ''
    private string null2String(string s) { if (s == null) return ''; else return s; }
    
    /* -------------------------------------------------------------------------------------
    * TransferAccountSearchResults: Mass Transfer Search Results Wrapper Class
    * - Used by the TransferAccounts Class and Page
    * - Main purpose is to return a LIST of Accounts along with a custom checkbox that can
    *   be used to let the user select which rows to transfer and which to ignore.
    *  ------------------------------------------------------------------------------------- */
    Public Class transferAccountSearchResults{

        public boolean selected = false;
        public Account account = null;

        public transferAccountSearchResults() { }
        public transferAccountSearchResults(Account c) { account = c; }

        public account getaccount()         { return this.account ; }
        public void setaccount(account c)   { this.account = c; }

        public boolean getselected()        { return this.selected; }
        public void setselected(boolean s)  { this.selected = s; }

        // Returns these DateTime fields as Date types formatted based on the current users Locale setting in SalesForce
        public string getCreatedDate()      { return date.newInstance(this.account.CreatedDate.year(), this.account.CreatedDate.month(), this.account.CreatedDate.day()).format() ; }
        public string getLastModifiedDate() { return date.newInstance(this.account.LastModifiedDate.year(), this.account.LastModifiedDate.month(), this.account.LastModifiedDate.day()).format() ; }
    }
}