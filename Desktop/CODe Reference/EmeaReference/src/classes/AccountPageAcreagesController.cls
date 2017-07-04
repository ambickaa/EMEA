//-------------------------------------------------------
  // Apex class  AccountPageAcreagesController
  // Test class  AccountPageAcreagesController_Test
  // Author    Support Team
  // Last update  30/03/2017 by Support Team
  //-------------------------------------------------------
  public with sharing class AccountPageAcreagesController {

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
                  if(SObjectType.Acreage__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO) != null)
                    FieldSet_Component = SObjectType.Acreage__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO).getFields();
                  else
                    FieldSet_Component = SObjectType.Acreage__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                } else {
                  FieldSet_Component = SObjectType.Acreage__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
                }
        }
        return FieldSet_Component;
      } protected set;
    }

  //-------------------------------------------------------
  // Initialization of the list of displayed records retrieved
  // from the method getRecords() and other important maps and lists.
  //-------------------------------------------------------
    public List<Acreage__c> List_Records {
      get {
        if(List_Records == null) {
          getRecords();
        }
        return List_Records;
      }
      private set;
    }
    private List<String> List_Records_Selected = new List<String>();
    private Map<Id, Acreage__c> Map_Records;

  //-------------------------------------------------------
  // Initialization of the list of SelectOptions for the enhanced picklist
  // displayed in the Visualforce component and the JSON array that links
  // each product group with its corresponding children types.
  //-------------------------------------------------------
    public List<SelectOption> Options_ProductGroups {get; private set;}
    public List<SelectOption> Options_ProductTypes {get; private set;}
    public String JSON_ProductGroupWithTypes {get; private set;}
    public String acreagesYear {get; private set;}

  //-------------------------------------------------------
  // Method to retrieve all the reports available.
  //-------------------------------------------------------
      public List<Report> availableReports {
        get {
          if(availableReports == null)
            availableReports = [SELECT Id, Name FROM Report WHERE DeveloperName LIKE 'AccountPage_Acreages_%' ORDER BY LastModifiedDate DESC];
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
      public Boolean modeNew {get; private set;}
      public Boolean modeEdit {get; private set;}
      public Boolean showAcreagesMessages {get; set;}
      public Boolean isOwner {get { return Util.isAccountOwner;} protected set;}
      public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
      public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
      public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
          return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}
      public Boolean isCPUser {get { return Util.currentUser.Division == 'CP';} protected set;}

  //-------------------------------------------------------
  // Apex class constructor, calling the ini() method.
  //-------------------------------------------------------
      public AccountPageAcreagesController()
      {
          system.debug('++++ isOwner: ' + isOwner);
          system.debug('++++ isAdmin: ' + isAdmin);
          system.debug('++++ isCPUser: ' + isCPUser);
          ini();
      }

  //-------------------------------------------------------
  // Initial method that initializes some variables.
  //-------------------------------------------------------
      private void ini()
      {
          system.debug('***INI: AccountPageAcreagesController');
          
          acreagesYear = Util.currentYear.Name;
          
          JSON_ProductGroupWithTypes = '';
          showAcreagesMessages = modeNew = modeEdit = false;
      }

  //-------------------------------------------------------
  // Method to retrieve the existent records.
  //-------------------------------------------------------
      private void getRecords()
      {
        Map_Records = new Map<Id, Acreage__c>();
        List_Records = new List<Acreage__c>();
        
      String q = 'SELECT Id, Name, PreviousAcreageRef__c, AcrProviderRef__r.Name';
  //-------------------------------------------------------
  // Using the fieldSet to query all necessary fields, taking some of them out
  // when they are essential for the Visualforce page to avoid duplicate values.
  //-------------------------------------------------------
      for(Schema.FieldSetMember f : FieldSet_Component)
      {
              if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Name' && f.getFieldPath() != 'PreviousAcreageRef__c' && f.getFieldPath() != 'AcrProviderRef__r.Name')
                  q += ', ' + f.getFieldPath();
          }
          q += ' FROM Acreage__c';
          q += ' WHERE AcrFarmRef__c = \'' + Util.currentAccount.Id + '\' AND AcrYearRef__c = \'' + Util.currentYear.Id + '\'';
          q += ' ORDER BY AcrProviderRef__r.Name DESC, AcrProductGroupRef__r.Name DESC, AcrProductTypeRef__r.Name DESC, CreatedDate DESC';
  //-------------------------------------------------------
  // Using a temporal list of records, they can be displayed showing
  // the ones related to Monsanto International Sarl at first place.
  //-------------------------------------------------------
      List<Acreage__c> List_Records_other = new List<Acreage__c>();
      List<Acreage__c> List_Records_tmp = (List<Acreage__c>)Database.query(q);
      
          for(Acreage__c r : List_Records_tmp)
          {
            if(r.AcrProviderRef__c != null && r.AcrProviderRef__r.Name != null && r.AcrProviderRef__r.Name.contains('Monsanto'))
              List_Records.add(r);
            else
              List_Records_other.add(r);
          }
          List_Records.addAll(List_Records_other);
  //-------------------------------------------------------
  // Key map to recover data on update/insert actions.
  //-------------------------------------------------------
          for(Acreage__c r : List_Records)
            Map_Records.put(r.Id, r);
      }

  //-------------------------------------------------------
  // Method to built the enhanced picklist of Product Group and Product Type
  // in the Visualforce page and also the JSON array that links each group
  // with its children types.
  //-------------------------------------------------------
      private void getProductGroups()
      {
        if(Options_ProductGroups == null || Options_ProductTypes == null)
        {
          Options_ProductGroups = new List<SelectOption>();
          Options_ProductTypes = new List<SelectOption>();
  //-------------------------------------------------------
  // Temporal variables needed during the construction.
  //-------------------------------------------------------
          List<String> List_ProductGroup = new List<String>();
          List<String> List_ProductType = new List<String>();
          Set<String> Set_ProductGroup = new Set<String>();
          Set<String> Set_ProductType = new Set<String>();
          Map<String, List<Id>> Map_ProductGroup = new Map<String, List<Id>>();
          Map<String, List<Id>> Map_ProductType = new Map<String, List<Id>>();
          Map<Id, List<Id>> Map_ProductGroupWithTypes = new Map<Id, List<Id>>();
  //-------------------------------------------------------
  // Since the variables that the method is building are not transient variables,
  // they will be kept in the Apex context and the following query will be executed
  // only the first time.
  //-------------------------------------------------------
          for(Product_Grouping__c g : [SELECT Name, ProductGroupRef__c, RecordType.Name FROM Product_Grouping__c])
          {
  //-------------------------------------------------------
  // Getting translated values from the Apex class ProdTransController
  // and removing values that are not translated or translated with "x" or "-".
  //-------------------------------------------------------
            String tr = ProdTransController.getTranslation(g.Id);
            if(tr != 'x' && tr != '-' && tr != null)
          {          
              if(g.RecordType.Name == 'Product Group')
              {
                List_ProductGroup.add(tr);
                if(Map_ProductGroup.containsKey(tr))
                  Map_ProductGroup.get(tr).add(g.Id);
                else              
                  Map_ProductGroup.put(tr, new List<Id>{g.Id});
              }
              if(g.RecordType.Name == 'Product Type')
              {
                List_ProductType.add(tr);
                if(Map_ProductType.containsKey(tr))
                  Map_ProductType.get(tr).add(g.Id);
                else 
                  Map_ProductType.put(tr, new List<Id>{g.Id});
                if(Map_ProductGroupWithTypes.containsKey(g.ProductGroupRef__c))
                  Map_ProductGroupWithTypes.get(g.ProductGroupRef__c).add(g.Id);
                else
                  Map_ProductGroupWithTypes.put(g.ProductGroupRef__c, new List<Id>{g.Id});
              }
          }
          }
          
          JSON_ProductGroupWithTypes = JSON.serialize(Map_ProductGroupWithTypes);
  //-------------------------------------------------------
  // Sorting picklists by the translated values and populating them.
  //-------------------------------------------------------
          if(List_ProductGroup.size() > 0)
          {
            List_ProductGroup.sort();
            Set_ProductGroup.addAll(List_ProductGroup);
            for(String tr : Set_ProductGroup)
            {
              for(Id pg : Map_ProductGroup.get(tr))
              {
                Options_ProductGroups.add(new SelectOption(pg, tr));
              }            
            }
          }
          if(List_ProductType.size() > 0)
          {
            List_ProductType.sort();
            Set_ProductType.addAll(List_ProductType);
            for(String tr : Set_ProductType)
            {
              for(Id pt : Map_ProductType.get(tr))
              {
                Options_ProductTypes.add(new SelectOption(pt, tr));
              }            
            }
          }
        }
      }

  //-------------------------------------------------------
  // Method to get translations for Product Group and Product Type values.
  // These values will be displayed on the "view" mode of the Visualforce component.
  //-------------------------------------------------------
      public String getMap_ProductTranslations()
      {
          ProdTransController.initMapTrans();
          String returned = '';
          
          for(Id t : ProdTransController.mapTranslations.keySet())
              returned += ',\'' + String.valueOf(t).subString(0,15) + '\':\'' + ProdTransController.mapTranslations.get(t) + '\'';
          
          return '{' + returned.substring(1) + '}';
      }

  //-------------------------------------------------------
  // Method to create 5 virtual records that can be inserted.
  //-------------------------------------------------------
      private void getNew()
      {
        for(Integer i = 0; i < 5; i++)
          List_Records.add(
            new Acreage__c(
              RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup'),
              AcrProviderRef__c = Label.DefaultAcreagesProvider,
              AcrFarmRef__c = Util.currentAccount.Id,
              AcrYearRef__c = Util.currentYear.Id,
              OwnerId = Util.currentUser.Id
            )
          );
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
          List<Acreage__c> List_Records_tmp = new List<Acreage__c>();
          List<Acreage__c> List_Records_py = new List<Acreage__c>();
  //-------------------------------------------------------
  // It gets the records from the key map when they are selected
  // and they do not have a previous year record related.
  //-------------------------------------------------------
          for(String Id : List_Records_Selected)
          {
            if(Map_Records.containsKey(Id))
            {
              if(Map_Records.get(Id).PreviousAcreageRef__c == null)
                List_Records_tmp.add(Map_Records.get(Id));
              else
                List_Records_py.add(Map_Records.get(Id));
            }
          }
  //-------------------------------------------------------
  // It only deletes when some of the selected records
  // (or all of them) have not previous year references.
  //-------------------------------------------------------
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
        showAcreagesMessages = true;
      }

  //-------------------------------------------------------
  // This method enables the New mode, where the getNew()
  // method is called and the new lines are editable.
  // - It unselects all records via setRows('')
  // - It gets picklists, records and new lines through get functions
  // - It enables the New and the Edit modes
  //-------------------------------------------------------
      public void modeNew()
      {
        setRows('');
        getProductGroups();
        getRecords();
        getNew();
        modeNew = modeEdit = true;
      }

  //-------------------------------------------------------
  // This method enables the Edit mode, where the selected
  // records are editable.
  // - It gets picklists, records and new lines through get functions
  // - It enables the Edit mode
  //-------------------------------------------------------
      public void modeEdit()
      {
        getProductGroups();
        getRecords();
        modeEdit = true;
      }

  //-------------------------------------------------------
  // This method disables the New and the Edit modes.
  // - It unselects all records via setRows('')
  // - It gets records through getRecords()
  // - It disables the New and the Edit modes
  //-------------------------------------------------------
      public void cancelModes()
      {
        setRows('');
        getRecords();
        modeNew = modeEdit = false;
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
          List<Acreage__c> List_Records_tmp = new List<Acreage__c>();
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
            cancelModes();
          }
  //-------------------------------------------------------
  // Inserting new records when there are not selected lines.
  //-------------------------------------------------------
        } else {
          List<Acreage__c> List_Records_tmp = new List<Acreage__c>();
  //-------------------------------------------------------
  // Loop for all new records, identified by those:
  // - Without Id
  // - With CY quantity filled
  //-------------------------------------------------------
          for(Acreage__c r : List_Records)
          {
            if(r.Id == null && r.AcrTotalAcreages__c != null){    
            
                  
              List_Records_tmp.add(r);
              }
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
          } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_any_record_inserted));
            cancelModes();
          }
        }
        showAcreagesMessages = true;
      }
  }