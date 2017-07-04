public with sharing class AccountTacticalPlanController {

  private Id IDthisAccount;
  public Campaign OBJthisCampaign{get;set;}
  public Division__c OBJthisDivision{get;set;}
  public Id IDthisPC{get;set;}
  public List<CampaignLineItem__c> LISTtacticalPlans {get;set;}
  public List<Schema.FieldSetMember> LISTFieldSetCLI{get;set;}  
  public Map<String, Decimal> MAPSumCLI{get;set;}
  public Map<String, Decimal> MAPpr2POGPY{get;set;}
  
  public Map<String, Map<String, String>> MAPfieldCfg{get;set;}
  public String MAPfieldCfgJSON{get;set;}
  
  public Map<String,Map<String,String>> mapProviderField{get;set;}
  public String jsonProviderField{get;set;}
  
  public Map<String, String> isCompetitor{get;set;}  
  public String isCompetitorJSON{get;set;}   
  
  public boolean isSharingUser{get { return Util.isAccountOwner; } set;} // Check if user is into the sharing list of the account Owners and OwnersFlat
  public boolean isFarmAccount{get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite'); } set;} // Check if the account is a Farm
  public String isPr2Competitor{get { return Util.recordType.get('Account:Competitor'); } set;} // It gives the Record Type for Competitor products
  
  public String pageMode {get;set;}
  public String IDnewProduct {get;set;}
  
  public transient String tacticalPlansToDelete {get;set;}

  public AccountTacticalPlanController() {

    getConstructor();
  
  }
  
  public PageReference myNewProduct() { return null; }

  public void getConstructor() {
    
    IDthisAccount = Util.currentAccount.Id;
    OBJthisCampaign = Util.currentCampaign;
    pageMode = 'View';
    IDnewProduct = '';

    if(OBJthisCampaign != null) {
      OBJthisDivision = Util.currentDivision;
      IDthisPC = Util.currentCampaign.SalesPCMRef__c;
      LISTFieldSetCLI = getTacticalPlanFields(); // Get FieldSet for Campaign Line Items in Action Plan
      getTacticalPlans(); // Get Campaign Line Items and their totals at the bottom of the Action Plan
      setMapProviderFields();
      setIsCompetitor(LISTtacticalPlans);
      setFieldDisabled();
      
      MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
      //getAllMapSumFields(tacticalPlans);
    }
    //refreshPermission();
  }
  
  public void doNew() {
    //Util.setCurrentAccount(accountID);
    
    if(OBJthisCampaign != null) {
      Boolean BOOcheckNew = false;
      for(Integer i=0; i < LISTtacticalPlans.size(); i++){
        if(LISTtacticalPlans[i].Id == null) BOOcheckNew = true;
      }
      
      if(!BOOcheckNew) LISTtacticalPlans.add(new CampaignLineItem__c(CampaignRef__c = OBJthisCampaign.Id, FarmRef__c = IDthisAccount, RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales')));
      pageMode = 'New';
      MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
      //ApexPages.currentPage().getParameters().put('id',IDthisAccount);
    }
  }
  
  public void doEdit() {
    //Util.setCurrentAccount(accountID);
        
    if(OBJthisCampaign != null) {
      IDnewProduct = '';
      pageMode = 'Edit';
      MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
      //ApexPages.currentPage().getParameters().put('id',IDthisAccount);
    }
  }
  
  public void doCancel() {
    //Util.setCurrentAccount(accountID);
    apexPages.currentPage().getParameters().put('id',IDthisAccount);
    
    if(OBJthisCampaign != null) {
      IDnewProduct = '';
      pageMode = 'View';
      getTacticalPlans();
      setIsCompetitor(LISTtacticalPlans);
      setFieldDisabled();
      MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
    }
  }
  
  
  public void doSave() {
    //Util.setCurrentAccount(accountID);
    
    if(OBJthisCampaign != null) {
      //doEdit();
      List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
      List<CampaignLineItem__c> toUpdate = new List<CampaignLineItem__c>();
     
      for(CampaignLineItem__c forTP : LISTtacticalPlans){
        if(forTP.Id == null) {
          if(forTP.ProductRef__c != null) {
            if(isFarmAccount)
              forTP.OwnerId = Util.CurrentAccount.OwnerId; // Only France
            toInsert.add(forTP);
          }
        } else {
       	  //forTP = setStatusByQuantityValue(forTP);
          if(isSharingUser)
            toUpdate.add(forTP);
        }
      }
     
      System.savepoint sp = Database.setSavepoint();

      try {
        system.debug('AP_LINES_TO_UPDATE: ' + toUpdate + 'AP_LINES_TO_INSERT: ' + toInsert);
         
        if(toInsert.size() > 0) {
          insert toInsert.clone();
          Util.addConfirmMessage(Label.ConfirmMsgLinesAdded);
        }
        if(toInsert.size() == 0 && toUpdate.size() > 0) {
          update toUpdate;
          Util.addConfirmMessage(Label.ConfirmMsgLinesEdited);
        }
         
        IDnewProduct = '';         
        pageMode = 'View';
        getTacticalPlans();
        setIsCompetitor(LISTtacticalPlans);
        setFieldDisabled();
        MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
        //refreshPermission();
        
        if(Test.isRunningTest()) {
          insert new Order__c(); // Cause DMLException
        }
                
      } catch(DMLException theDMLException) {
                    
        Util.addErrorMessage(theDMLException.getMessage());
        Database.rollback(sp);
            
        pageMode = 'Edit';
        getTacticalPlans();
        setIsCompetitor(LISTtacticalPlans);
        setFieldDisabled();
        MAPpr2POGPY = getPOGPYByProduct(LISTtacticalPlans);
        //refreshPermission();    
      } catch(Exception e) {
                    
        pageMode = 'Edit';
        Util.addErrorMessage(e.getMessage());
        Database.rollback(sp);
        ApexPages.currentPage().getParameters().put('id',IDthisAccount);            
      }
    }
  }
  
  public void doDelete() {
    //Util.setCurrentAccount(accountID);
    
    if(OBJthisCampaign != null){
      Integer count = 0;
      Boolean errPogPy = false; // For France, so far, deleting Action Plan lines with POGPY > 0 is allowed
      List<sObject> toDelete = new List<sObject>();
            
      if(!tacticalPlansToDelete.equals('')){
        Integer ContDel = 0;
        for(String forIndex : tacticalPlansToDelete.split(',')){
            
          CampaignLineItem__c tacticalPlanToDelete = LISTtacticalPlans.get(Integer.valueOf(forIndex)- ContDel);
          if(tacticalPlanToDelete.ID != null){
            toDelete.add((sObject)new CampaignLineItem__c(id=tacticalPlanToDelete.ID)); 
            LISTtacticalPlans.remove(Integer.valueOf(forIndex)- ContDel); // Delete Record from VF
            ContDel++;
          }
        }
        try{
          delete toDelete; 
          if(errPogPy) Util.addWarningMessage('Some records have not been deleted because: You cannot delete a Campaign Line Item when the POG PY is above zero.');
          else Util.addConfirmMessage(Label.msgRecordsDeleted);
          
          getTacticalPlans();
          
          if(Test.isRunningTest()) {
            insert new Order__c(); // Cause DMLException
          }
          
        } catch (DMLException theDMLException) {
          if((theDMLException.getMessage()).contains('insufficient access rights')){
            transient String owner = [SELECT Owner.Name From CampaignLineItem__c WHERE Id =:theDMLException.getDMLId(0) LIMIT 1].Owner.Name; 
            Util.addWarningMessage('You cannot delete records you do not own. Please, contact '+Owner+' to delete selected records.');
          } 
          else Util.addErrorMessage('Records have not been deleted due to: '+theDMLException.getMessage());
          getTacticalPlans();
          
        } catch (Exception theException){
          Util.addErrorMessage('Records have not been deleted due to: '+theException.getMessage());
          getTacticalPlans();
          
        }  
        //getAllMapSumFields(tacticalPlans);
      } else {
        Util.addWarningMessage(Label.msgNoRecordsSelected);
      }
    }
  }
  
  // This function gets the fields included in the correspondant Field Set
  public static List<Schema.FieldSetMember> getTacticalPlanFields() {

    String strAccRTId = Util.currentAccount.RecordTypeId;
    String strRTFarm = Util.recordType.get('Account:GroupFarmSite');
        
    if(Util.currentUser.Country != null){
      String strTP;
        if(Util.currentAP != null) strTP = Util.currentAP.PICK_FieldSets__c;//Recovering: Country.PICK_FieldSets__c
          String strAccRTPrefix;
          String strCountry = Util.currentUser.Country.replace(' ','').trim();
            
          if(strAccRTId == strRTFarm) strAccRTPrefix = 'Farm';//Recovering: Account.RecordType
          else strAccRTPrefix = 'Dist';
            
          if(strTP  != null) {
            if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get(strTP + strAccRTPrefix) != null) { // Validation: Check if the value in the picklist exist as FieldSet.
              return SObjectType.CampaignLineItem__c.FieldSets.getMap().get(strTP + strAccRTPrefix).getFields();  
            } else {
              system.debug('*** Error: The field set:' +strTP + strAccRTPrefix+' does not exist.');
              Util.currentAccount.addError('The field set:' +strTP + strAccRTPrefix+' does not exist.');
              return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();
            }
          } else {
            system.debug('*** Error: This Country has not a FieldSet filled out.');
            Util.currentAccount.addError('Error: This Country has not a FieldSet filled out.');
            return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();
          }
      } else {
        system.debug('*** Error: The user has not Country associated.');
        Util.currentAccount.addError('Error: The user has not Country associated.');
        return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();
      }
    }
    
    // This function gets the Campaign Line Items of this Account
    public void getTacticalPlans() {
        if(pageMode == 'View' && OBJthisCampaign != null) {
            //Util.setCurrentAccount(accountID);
            
            Id RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'); 
            String pString = 'SELECT ';
            for(Schema.FieldSetMember f : LISTFieldSetCLI) {
                pString += f.getFieldPath() + ', ';
            }
            pString +=' Id, Name, OwnerId, Division__c, year__c,';
            pString +=' ProductCatalogEntryRef__r.isFOCallowed__c, ProductRef__r.Name,ProductRef__r.ProductTypeRef__r.Name,';
            pString +=' ProductRef__r.ProductDisplayName__c, ProductRef__r.ProductVendor__r.RecordTypeId ';
            pString +=' FROM CampaignLineItem__c WHERE FarmRef__c = \'' + IDthisAccount + '\'';
            
            if(isSharingUser || Util.currentUser.Profile.Name.contains('Marketing')) // User is into the sharing list of the account Owners and OwnersFlat or Marketing Profile
                pString += ' AND CampaignRef__r.StatusCode__c = 200';
            else
                pString += ' AND CampaignRef__c = \'' + OBJthisCampaign.Id + '\'';
            pString += ' AND Division__c = \'' + OBJthisDivision.Name + '\'';
            pString += ' AND RecordTypeId = \'' + RecordTypeId + '\'';            
            //pString += 'ORDER BY ProductRef__r.Name ASC ';
            pString += 'ORDER BY CreatedDate ASC '; // It puts the last submitted line at the end
            LISTtacticalPlans = (List<CampaignLineItem__c>)Database.query(pString);
            getAllMapSumFields(LISTtacticalPlans);
            
            doNew();
            pageMode = 'View';
            
        }
    }
    
  // It creates the MAP mapProviderField
    public void setMapProviderFields() {
      if(mapProviderField == null) {
        Map <String, Map<String, String>> mapFieldCfg2 = new Map <String, Map<String, String>>();
        Map<String, TacticalPlanConfigFields__c> m = (Map<String, TacticalPlanConfigFields__c>)TacticalPlanConfigFields__c.getAll();
        for(String key : m.keySet()) {
          TacticalPlanConfigFields__c tpcf = TacticalPlanConfigFields__c.getInstance(key);
          Map <String , String> fieldConfig = new Map<String,String>();
          if(!isFarmAccount) {
            fieldConfig.put('DisplayTypeCompetitor',tpcf.DisplayTypeCompetitor__c);
            fieldConfig.put('DisplayTypeMonsanto',tpcf.DisplayTypeMonsanto__c);
          } else {
            fieldConfig.put('DisplayTypeCompetitor','');
            fieldConfig.put('DisplayTypeMonsanto','');
          }
          mapFieldCfg2.put(key, fieldConfig);
        }
        mapProviderField = mapFieldCfg2;
        jsonProviderField = JSON.serialize(mapFieldCfg2);
      }
    }
    
  // It checks if the provider of the CLI is Competitor or Monsanto
    public void setIsCompetitor(List<CampaignLineItem__c> tPs) {
      isCompetitor = new Map<String,String>();
        if(tPs != null) {
          for(CampaignLineItem__c cli : tPs) { 
            if(cli.ProductRef__c != null) {
              String isComp = (cli.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor'))? 'True':'False';
              isCompetitor.put(cli.ProductRef__c, isComp);
            }
          }
      }
      isCompetitorJSON = JSON.serialize(isCompetitor);
    }
    
  // It disables some fields based on the provider
    public void setFieldDisabled() {
      MAPfieldCfg = new map<String, map<String, String>>();
      for(String idKey : isCompetitor.keySet()){ //loop by Product.Id
        Map<String, String> mapField = new Map<String, String>(); 
        Boolean isComp = Boolean.valueOf(isCompetitor.get(idKey));

          for(Schema.FieldSetMember FieldSetM: LISTFieldSetCLI) {
            String fieldName = FieldSetM.getFieldPath();
            if(mapProviderField.containsKey(fieldName)) {
              Map<String,String> mapFieldCfg2 = mapProviderField.get(fieldName);
              if(isComp) {
                mapField.put(fieldName, (mapFieldCfg2.get('DisplayTypeCompetitor') == 'R' || mapFieldCfg2.get('DisplayTypeCompetitor') == 'D') ? 'True': 'False');
              } else {
                mapField.put(fieldName, (mapFieldCfg2.get('DisplayTypeMonsanto') == 'R' || mapFieldCfg2.get('DisplayTypeMonsanto') == 'D') ? 'True': 'False');
              }
            } else {
              mapField.put(fieldName, 'False');
            }
          }
          MAPfieldCfg.put(idKey , mapField);
        }
      MAPfieldCfgJSON = JSON.serialize(MAPfieldCfg);
    }
    
  // It retrieves the POGPY for each Campaign Line Item
    public Map<String, Decimal> getPOGPYByProduct(List<CampaignLineItem__c> tPs) { 
      Map<String, Decimal> mapPOG = new Map<String, Decimal>();
      List<Id> LISTpr2ID = new List<Id>();
      if(tPs != null) {
        for(CampaignLineItem__c cli : tPs) {
          if(cli.ProductRef__c != null) {
            LISTpr2ID.add(cli.ProductRef__c);
            mapPOG.put(cli.ProductRef__c,Decimal.valueOf('0'));
          }
        }
      }
      if(!isFarmAccount) return mapPOG;
        
      Decimal pogpy = Decimal.valueOf('0');
      if(Util.previewsCampaign != null) {
        Id recordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'); 
        String pString = 'SELECT sum(POG__c) POGPY, ProductRef__c pr2ID FROM CampaignLineItem__c WHERE ProductRef__c IN :LISTpr2ID';
        pString += ' AND POG__c != null AND CampaignRef__c = \'' + Util.previewsCampaign.Id + '\'';
        pString += ' AND RecordTypeId = \'' + recordTypeId + '\'';
        pString += 'GROUP BY ProductRef__c';
        List<AggregateResult> resultList = (List<AggregateResult>) Database.query(pString);
        for(AggregateResult ar : resultList) {
          mapPOG.put((String) ar.get('pr2ID'),((Decimal) ar.get('POGPY')));
        }
      }
      return mapPOG;
    }

    // This function gets the summarized fields at the bottom of the Action Plan
    public void getAllMapSumFields(List<CampaignLineItem__c> tPs) {
        
        Schema.DescribeSObjectResult dsor = CampaignLineItem__c.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
        Map<String, Decimal> mapSumFields = new Map<String, Decimal>();
        Map<String, String> mapSumFieldsStr = new Map<String, String> ();
        for (Schema.FieldSetMember fsm : LISTFieldSetCLI) {
          String fsmStr =  fsm.getfieldPath();
          mapSumFields.put(fsmStr, Decimal.valueOf('0'));
        }

        for (Schema.FieldSetMember fsm : LISTFieldSetCLI) {
            String fsmStr =  fsm.getfieldPath();
            String objType = objectFields.get(fsmStr).getDescribe().getType().name().toLowerCase();
            if ( objType.equals('double') || objType.equals('integer') || objType.equals('currency')) {
                if (tPs != null){
                    for (CampaignLineItem__c cli : tPs) {
                        mapSumFields.put(fsmStr, (Decimal)mapSumFields.get(fsmStr) + (Decimal) (cli.get(fsmStr)== null ? Decimal.valueOf('0') : cli.get(fsmStr)));
                    }
                }
            }
            else {
              mapSumFields.put(fsmStr, mapSumFields.get(fsmStr) + Decimal.valueOf('0'));
            }
        }
        MAPSumCLI = mapSumFields;
    }

}