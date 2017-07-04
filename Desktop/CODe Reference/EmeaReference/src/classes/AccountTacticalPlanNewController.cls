public with sharing class AccountTacticalPlanNewController {
    private ID accountID;
    public String mode {get;set;}
    public boolean isGeneric {get;set;} 
    public transient String tacticalPlansToDelete {get;set;}
    public List<CampaignLineItem__c> tacticalPlans {get;set;}
    public Map<String,Map<String,String>> mapProviderField{get;set;}  
    public Map<String, Decimal> mapTPSumFields{get;set;}
    public String jsonProviderField{get;set;}  
    public Map<String, String> isCompetitor{get;set;}  
    public String isCompetitorJSON{get;set;}   
    public Map<String, Decimal> mapProdPOGPY{get;set;}
    public List<Schema.FieldSetMember> listFieldsCLI{get;set;}        
    public Map<String, Map<String, String>> mapFieldConfig{get;set;}
    public String mapFieldConfigJSON{get;set;}
    public transient Map<Id, ProductCatalogEntry__c> listProducts{get;set;} 
    public Map<Integer, List<SelectOption>> optProducts{get;set;} 
    public Campaign currentCampaign{get;set;}
    public Division__c currentDivision{get;set;}
    public Map<Id, Boolean> editPermission {get; set;}
    public Campaign currentCampain {get { return Util.currentCampaign; } set;}
    
     public String productsInCurrentPC 
    {
        get
        {
            productsInCurrentPC='';
            for (ProductCatalogEntry__c pce : [SELECT id, ProductRef__r.Name, DE_isPremium__c FROM ProductCatalogEntry__c Where ProductCatalogRef__c=:currentCampain.SalesPCMRef__c])
            {
                productsInCurrentPC=productsInCurrentPC+pce.ProductRef__r.Name;
            }
            
            if(productsInCurrentPC!='')
            return productsInCurrentPC;
            else return 'NO PRODUCTS';
        }
        
        set;}
    
    
    
    
    public AccountTacticalPlanNewController(){
      // Generic Change
        if (Util.countryView.isFRTacticalPlan || Util.countryView.isGenericTacticalPlan){
            getConstructor();
        }
      // Generic Change
    }
    public void getConstructor(){
        accountID = Util.currentAccount.Id;
        
        mode = 'View';
        currentCampaign = Util.currentCampaign;

        if (currentCampaign != null){
            listFieldsCLI = getTacticalPlanFields();
            currentDivision = Util.currentDivision;
            // Generic Changes
            if(isCountriesEast()){
                isGeneric = true;
            }else{ 
                isGeneric = false;
            }
            // Generic Changes
            getTacticalPlans();
            setMapProviderFields();
            listProducts = getListProducts();
            optProducts = getOptProducts();
            setIsCompetitor(tacticalPlans);
            setIsFieldDisabled();
            mapProdPOGPY=getPOGPYByProduct(tacticalPlans);
            //getAllMapSumFields(tacticalPlans);
        
        }
        refreshPermission();
    }
    public void refreshPermission(){
        editPermission = new Map <Id, Boolean>();
        if(tacticalPlans <> null && tacticalPlans.size()>0){
            Set<Id> auxCli = new Set<Id>();
            for(CampaignLineItem__c cli : tacticalPlans){
                auxCli.add(cli.id);
                editPermission.put(cli.id, false);
            }
            for (CampaignLineItem__Share clis : [SELECT AccessLevel, UserOrGroupId, ParentId FROM CampaignLineItem__Share WHERE ParentId IN :auxCli]){
                if(clis.AccessLevel=='Edit' && clis.UserOrGroupId==UserInfo.getUserId()) editPermission.put(clis.ParentId,true);
            }
        }
    }
    public boolean getIsFrenchTacticalPlan(){
        return Util.countryView.isFRTacticalPlan;
    }
    public Campaign getcurrentCampain(){
        return currentCampaign;
    }
    public Division__c getcurrentDivision(){
        return currentDivision;
    }

    public void setMapProviderFields(){
        if (mapProviderField == null){
            Map <String, Map<String, String>> mapFieldCfg = new Map <String, Map<String, String>>();
            Map<String, TacticalPlanConfigFields__c> m = (Map<String, TacticalPlanConfigFields__c>)TacticalPlanConfigFields__c.getAll();
            for (String key : m.keySet()){
                TacticalPlanConfigFields__c tpcf = TacticalPlanConfigFields__c.getInstance(key);
                Map <String , String> fieldConfig = new Map<String,String>();
                if (!isFarmAccount()){
                    fieldConfig.put('DisplayTypeCompetitor',tpcf.DisplayTypeCompetitor__c);
                    fieldConfig.put('DisplayTypeMonsanto',tpcf.DisplayTypeMonsanto__c);
                }else {
                    fieldConfig.put('DisplayTypeCompetitor','');
                    fieldConfig.put('DisplayTypeMonsanto','');
                }
                mapFieldCfg.put(key, fieldConfig);
            }
            mapProviderField = mapFieldCfg;
            jsonProviderField = JSON.serialize(mapFieldCfg);
        }
    }
    
    public boolean isFarmAccount(){
        return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');
    }
    public boolean getisFarmAccount(){
        return  isFarmAccount();
    }
    
    public boolean isCountriesEast(){
        if (Util.currentUser.Country != null){
          /* check if the user's country is included in the Custom label AP_East_Countries */
          if(Util.currentUser.Country.replace(' ','').trim() == 'Russia' || Util.currentUser.Country.replace(' ','').trim() == 'Spain'||Util.currentUser.Country.replace(' ','').trim() == 'Italy'|| Util.currentUser.Country.replace(' ','').trim() == 'Slovakia' || Util.currentUser.Country.replace(' ','').trim() == 'CzechRepublic'|| Util.currentUser.Country.replace(' ','').trim() == 'Poland' || Util.currentUser.Country.replace(' ','').trim() == 'Hungary' || Util.currentUser.Country.replace(' ','').trim() == 'Turkey' || Util.currentUser.Country.replace(' ','').trim() == 'Romania' || (Util.currentUser.Country.replace(' ','').trim() == 'Ukraine' && ( Util.DIVISION_CORN.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_OSR.equalsIgnoreCase(Util.currentDivision.Name)) ) || Util.currentUser.Country.replace(' ','').trim() == 'Bulgaria' ){
          //***if ( label.AP_East_Countries.contains(Util.currentUser.Country) || (Util.currentUser.Country.replace(' ','').trim() == 'Ukraine' && ( Util.DIVISION_CORN.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_OSR.equalsIgnoreCase(Util.currentDivision.Name)) )){
            return  true;
          }else if (Util.currentUser.Country.replace(' ','').trim() == 'Ukraine' && (Util.DIVISION_ROUNDUP.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_GUARDIAN.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_HARNESS.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_ACTIMUM.equalsIgnoreCase(Util.currentDivision.Name))){
            return  Util.countryView.isGermanActionPlan;
          }else return false;
        }else return false;
    }
    
    public boolean getisCountriesEast(){
        return  isCountriesEast();
    }
    
    public void getTacticalPlans(){
        if(mode == 'View' && currentCampaign != null){
            Util.setCurrentAccount(accountID);
            
            Id recordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'); 
            String pString = 'SELECT ';
            for(Schema.FieldSetMember f : listFieldsCLI) {
                pString += f.getFieldPath() + ', ';
            }
            pString +=' Id, Name, OwnerId, year__c, Division__c, ProductCatalogEntryRef__r.isFOCallowed__c, ProductRef__r.Name,ProductRef__r.ProductTypeRef__r.name,ProductRef__r.ProductDisplayName__c, ProductRef__r.ProductVendor__r.RecordTypeId ';
            if(isCountriesEast() ){
              pString +=' ,treatment__c ';
            }
            pString +=' FROM CampaignLineItem__c WHERE FarmRef__c = \'' + accountID + '\'';
            
            if(Util.CountryView.isFRTacticalPlan || Util.isAccountOwner){
                pString += ' AND CampaignRef__r.StatusCode__c = 200';
            }
            else{
                pString += ' AND CampaignRef__c = \'' + currentCampaign.Id + '\'';
            }
            pString += ' AND Division__c = \'' + util.currentDivision.Name + '\'';
            pString += ' AND RecordTypeId = \'' + recordTypeId + '\'';
            pString += 'ORDER BY ProductRef__r.Name ASC ';
            List<CampaignLineItem__c> tpList = (List<CampaignLineItem__c>)Database.query(pString);
            system.debug('*** tpList: '+tpList);
            tacticalPlans =tpList;
            getAllMapSumFields(tacticalPlans);
            doNew();
            mode = 'View';
            
        }
    }
    
    public static List<Schema.FieldSetMember> getTacticalPlanFields() {
        String fsPrefix='tacticalPlanList'; //tacticalPlanListStandard
        String farmPrefix = 'tacticalPlanFarm';
        String distPrefix = 'tacticalPlanDist';
        String postfix = '';
        String strAccRTId = Util.currentAccount.RecordTypeId;
        String strRTFarm = Util.recordType.get('Account:GroupFarmSite');
        
        
        if (Util.currentUser.Country != null){
            // Start: CR-00000213. 11/03/2015
            String strTP;
            if(Util.currentAP != null) strTP = Util.currentAP.PICK_FieldSets__c;//Recovering: Country.PICK_FieldSets__c
            String strAccRTPrefix;
            String strCountry = Util.currentUser.Country.replace(' ','').trim();
            
            if (strAccRTId == strRTFarm) strAccRTPrefix = 'Farm';//Recovering: Account.RecordType
            else strAccRTPrefix = 'Dist';
            
            if (strTP  != null){
                if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get(strTP + strAccRTPrefix) != null){//Validation: Check if the value in the picklist exist as FieldSet.
                    return SObjectType.CampaignLineItem__c.FieldSets.getMap().get(strTP + strAccRTPrefix).getFields();  
                }else{
                    system.debug('The field set:' +strTP + strAccRTPrefix+' does not exist.');
                    Util.currentAccount.addError('The field set:' +strTP + strAccRTPrefix+' does not exist.');
                }
            // End: CR-00000213. 11/03/2015
            }else{
                // check if the user's country is included in the Custom label AP_Generic_Countries 
                if(strCountry == 'Russia' || strCountry == 'Slovakia' || strCountry == 'Poland' || strCountry == 'Hungary' || strCountry == 'Turkey' || strCountry == 'Romania' || (strCountry == 'Ukraine' && ( Util.DIVISION_CORN.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_OSR.equalsIgnoreCase(Util.currentDivision.Name)) ) || strCountry == 'Bulgaria' || strCountry == 'CzechRepublic'){
                    postfix = 'Generic';
                }else if(strCountry == 'Ukraine' && (Util.DIVISION_ROUNDUP.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_GUARDIAN.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_HARNESS.equalsIgnoreCase(Util.currentDivision.Name) || Util.DIVISION_ACTIMUM.equalsIgnoreCase(Util.currentDivision.Name))){
                    postfix = 'German';
                }else if(strCountry == 'Italy'){
                    postfix = 'Italy';
                }else{ 
                    postfix = strCountry;
                }     
            }
        }
            
        //Switch for Farm/Dist FieldSets 
        if (strAccRTId == strRTFarm){
            fsPrefix = farmPrefix;
        } else if (strAccRTId == Util.recordType.get('Account:DistRetPoS')){
            fsPrefix = distPrefix;
        }else if (strAccRTId == Util.recordType.get('Account:Competitor')){
            fsPrefix = farmPrefix;
        }
            
        if(SObjectType.CampaignLineItem__c.FieldSets.getMap().get(fsPrefix+ 'Standard' + postfix) == null){
            if (SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard') != null){
                return SObjectType.CampaignLineItem__c.FieldSets.getMap().get('tacticalPlanListStandard').getFields();                          
            }else {
                return new List<Schema.FieldSetMember>();

            }
        }else{
            return SObjectType.CampaignLineItem__c.FieldSets.getMap().get(fsPrefix+ 'Standard' + postfix).getFields(); 
        }
    }
    
    
    
    public void doNew(){
        Util.setCurrentAccount(accountID);
        
        if (currentCampaign != null)
        {

        	//----------------------------------------
        	// START: CR-00000428 - 2016.06.15 Support Team
        	//----------------------------------------
        	String pDensity = '';
        	
        	Boolean IspDensity = false;
        	for(Schema.FieldSetMember f : listFieldsCLI) {
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

            Id recordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
            for(Integer i = 0; i < 5; i++)
            {
                tacticalPlans.add(new CampaignLineItem__c(CampaignRef__c = currentCampaign.Id, FarmRef__c = accountID, RecordTypeId = recordTypeId, PlantingDensity__c = pDensity));
            }

            mode = 'Edit';
        }
        mapProdPOGPY=getPOGPYByProduct(tacticalPlans);
        System.debug('Set Parameters Account doNew: ' + accountID);
        ApexPages.currentPage().getParameters().put('id',accountID);
    }
    
    public void doEdit(){
        Util.setCurrentAccount(accountID);
        if (currentCampaign != null){
            mode = 'Edit'; 
        }
    }
    public void doCancel(){
        Util.setCurrentAccount(accountID);
        apexPages.currentPage().getParameters().put('id',accountID);
        mode = 'View';
        getTacticalPlans();
    }
    
    public void doSave(){
        Util.setCurrentAccount(accountID);
        if (currentCampaign != null){
            doEdit();
            List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
            List<CampaignLineItem__c> toUpdate = new List<CampaignLineItem__c>();
            for(CampaignLineItem__c forTP : tacticalPlans){
                forTP = setStatusByQuantityValue(forTP);
                if(forTP.id == null){
                    if(forTP.ProductRef__c != null){
                        if(Util.currentUser.Country.replace(' ','').trim() == 'France' && isFarmAccount()){
                            forTP.OwnerID = Util.CurrentAccount.OwnerId;
                        }
                        toInsert.add(forTP);
                    }
                }else{
                    system.debug('*** Update forTP'+forTP);
                    if(forTP.OwnerId == userInfo.getUserID() || editPermission.get(forTP.Id))
                        toUpdate.add(forTP);
                }
            }
          
            System.savepoint sp = Database.setSavepoint();
            try{
                insert toInsert.clone(); System.debug('TO INSERT :' + toInsert);
                update toUpdate; System.debug('TO UPDATE: ' +toUpdate);
                mode = 'View';
                getTacticalPlans();
                setIsCompetitor(tacticalPlans);
                setIsFieldDisabled();
                mapProdPOGPY=getPOGPYByProduct(tacticalPlans);
                refreshPermission();
                if(util.currentUser.Country.equalsIgnoreCase('Italy')){
                    Util.currentCampaign=null;
                    Util.isCampaign=null;
                    currentCampaign = Util.currentCampaign;
                    // if( (Util.currentCampaign.TotalCampaignBudgetFOC__c < currentCampaign.TotalForecastFOC__c))
                       // util.addWarningMessage(system.label.ITA_ForecastFOC_over_Budget);
                     if( (Util.currentCampaign.TotalCampaignBudgetFOC__c < currentCampaign.TotalSalesFOC__c))
                        util.addWarningMessage(system.label.ITA_POGFOC_over_Budget);    
                    
                }   
                //getAllMapSumFields(tacticalPlans); 
                
                
            }catch (DMLException theDMLException){
                
               if((theDMLException.getMessage()).contains(system.label.ITA_validation_FOC_allowed)){
                
                    
                    set<ID> cliWithError = new set<ID>();
                    
                    for (Integer index = 0; index < theDMLException.getNumDml(); index++)
                    {   
                        
                        if(theDMLException.getDMLid(index)!=null)
                        cliWithError.add(theDMLException.getDmlId(index));
                    }
                    
                    List<campaignLineItem__c> prodErr = [SELECT productRef__r.Name FROM campaignLineItem__c WHERE id IN :cliWithError ];
                    
                    if(prodErr.size()!=0 && prodErr.size() <= cliWithError.size()){
                        for ( campaignLineItem__c pr : prodErr)
                        {
                            Util.currentAccount.addError(system.label.ITA_validation_FOC_allowed);
                        }
                           if(prodErr.size()!=cliWithError.size())
                           Util.currentAccount.addError(system.label.ITA_validation_FOC_allowed);
                    }
                    
                    else if ( prodErr.size()==0)
                    {
                          Util.currentAccount.addError(system.label.ITA_validation_FOC_allowed);
                    }
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, theDMLException.getMessage() ));
                    //Util.addErrorMessage(theDMLException.getMessage());
                    
                    Database.rollback(sp);
                }
                
                else if((theDMLException.getMessage()).contains(system.label.ITA_ERROR_ACCOUNT2))
                {
                    Database.rollback(sp);
                }
                  else if((theDMLException.getMessage()).contains(system.label.ITA_agreedFOC_over_budget))
                {
                    
                    Util.currentAccount.addError(system.label.ITA_agreedFOC_over_budget);
                    Database.rollback(sp);
                }
                else if ((theDMLException.getMessage()).contains(system.label.ITA_ERROR_ACCOUNT)) 
                {
                    Database.rollback(sp);
                 }
                
                else {
                    
                    Util.addErrorMessage(theDMLException.getMessage());
                    Database.rollback(sp);
               }
               
               
                 mode = 'Edit';
                getTacticalPlans();
                setIsCompetitor(tacticalPlans);
                setIsFieldDisabled();
                mapProdPOGPY=getPOGPYByProduct(tacticalPlans);
                refreshPermission();    
                    
              } 
                catch(Exception e){
                    
                   mode = 'Edit';
                   Util.addErrorMessage(e.getMessage());
                   Database.rollback(sp);
                   ApexPages.currentPage().getParameters().put('id',accountID);
                   
            }
        
        }
    }
    public void doDelete(){
        Util.setCurrentAccount(accountID);
        if (currentCampaign != null){
            Integer count = 0;
            Boolean errPogPy=false;
            List<sObject> toDelete = new List<sObject>();
            
            if(!tacticalPlansToDelete.equals('')){
                integer ContDel = 0;
                for(String forIndex : tacticalPlansToDelete.split(',')){
                    //CampaignLineItem__c tacticalPlanToDelete = tacticalPlans.remove(Integer.valueOf(forIndex) - count++);
                    CampaignLineItem__c tacticalPlanToDelete = tacticalPlans.get(Integer.valueOf(forIndex)- ContDel);
                    if(tacticalPlanToDelete.ID != null){
                      if(isCountriesEast()){
                        if(tacticalPlanToDelete.POGPY__c >0){
                            errPogPy = true;
                        }
                        else{
                            toDelete.add((sObject)new CampaignLineItem__c(id=tacticalPlanToDelete.ID));
                            tacticalPlans.remove(Integer.valueOf(forIndex)- ContDel);//Delete Record from VF
                            ContDel++;
                        }
                      }else{
                           toDelete.add((sObject)new CampaignLineItem__c(id=tacticalPlanToDelete.ID)); 
                           tacticalPlans.remove(Integer.valueOf(forIndex)- ContDel);//Delete Record from VF
                           ContDel++;
                       }
                    }
                }
                try{
                  delete toDelete; 
                  if(errPogPy) Util.addWarningMessage('Some records have not been deleted because: You cannot delete a Campaign Line Item when the POG PY is above zero.');
                  else Util.addConfirmMessage(Label.msgRecordsDeleted);
              } catch (DMLException theDMLException){
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
                getAllMapSumFields(tacticalPlans);
            }else{
                Util.addWarningMessage(Label.msgNoRecordsSelected);
            }
        }
    }
    public Map<Integer, List<SelectOption>> getOptProducts(){
        Map<Integer, List<SelectOption>> listOpProd = new Map<Integer, List<SelectOption>>(); 
        List<SelectOption> optProd =new List<SelectOption>{new SelectOption('','')};
        //optProd.clear();
        Integer i = Integer.valueOf('0');
        listOpProd.put(0, new List<SelectOption>());
        listOpProd.put(1, new List<SelectOption>());
        listOpProd.put(2, new List<SelectOption>());
        listOpProd.put(3, new List<SelectOption>());
        listOpProd.put(4, new List<SelectOption>());
        listOpProd.put(5, new List<SelectOption>());
        listOpProd.put(6, new List<SelectOption>());
        listOpProd.put(7, new List<SelectOption>());
        if (listProducts != null){
            for (ProductCatalogEntry__c prod : listProducts.values()){
                //optProd.add(new SelectOption(prod.ProductRef__c, (prod.prodDesc__c==null)? prod.Product_Name__c : prod.prodDesc__c));
                optProd.add(new SelectOption(prod.ProductRef__c, prod.Product_Name__c));
                if (optProd.size() > 999){
                    
                    listOpProd.put(i,optProd);
                    i++;
                    optProd = new List<SelectOption>();
                }
                
            }
            listOpProd.put(i,optProd);
        }
        return listOpProd;

    }

    public void setIsCompetitor(List<CampaignLineItem__c> tPs){
        isCompetitor = new Map<String,String>();
        if (tPs != null){
            for (CampaignLineItem__c cli : tPs){ 
                if (cli.ProductRef__c != null){
                    String isComp = (cli.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor'))? 'True':'False';
                    isCompetitor.put(cli.ProductRef__c, isComp);
                }
            }
        }
        isCompetitorJSON = JSON.serialize(isCompetitor);
    }
    public void setIsFieldDisabled(){
        mapFieldConfig = new map<String, map<String, String>>();
        for (String idKey : isCompetitor.keySet()){ //loop by Product.Id
            Map<String, String> mapField = new Map<String, String>(); 
            Boolean isComp = Boolean.valueOf(isCompetitor.get(idKey));
            //for (String fieldName : mapProviderField.keySet()) //Loop by FieldName
            for (Schema.FieldSetMember FieldSetM: listFieldsCLI){
                String fieldName = FieldSetM.getFieldPath();
                if (mapProviderField.containsKey(fieldName)){
                    Map<String,String> mapFieldCfg = mapProviderField.get(fieldName);
                    if (isComp){
                        mapField.put(fieldName, (mapFieldCfg.get('DisplayTypeCompetitor') == 'R' || mapFieldCfg.get('DisplayTypeCompetitor') == 'D')? 'True': 'False');
    
                    }else {
                        mapField.put(fieldName, (mapFieldCfg.get('DisplayTypeMonsanto') == 'R' || mapFieldCfg.get('DisplayTypeMonsanto') == 'D')? 'True': 'False');
                    }
                } else {
                    mapField.put(fieldName, 'False');
                }
            }
            mapFieldConfig.put(idKey , mapField);
            
        }
        mapFieldConfigJSON = JSON.serialize(mapFieldConfig);
        
    }
    public Map<Id, ProductCatalogEntry__c> getListProducts(){
        if (currentCampaign != null &&  Util.currentCampaign.SalesPCMRef__c != null){
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.ProductCatalogEntry__c.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

            String theQuery = 'SELECT Id, Name, ';
            //for(Schema.SObjectField s : fldObjMapValues)
            //{
            //   String theLabel = s.getDescribe().getLabel(); 
            //   String theName = s.getDescribe().getName();
            
               // Continue building your dynamic query string
            //   theQuery += theName + ',';
            //}
            
            // Trim last comma
            //theQuery = theQuery.subString(0, theQuery.length() - 1);
            
            // Finalize query string
            theQuery += 'ProductRef__c, Product_Name__c';
            theQuery += ', ProductRef__r.ProductTreatment__c, ProductRef__r.ProductVendor__r.RecordTypeId FROM ProductCatalogEntry__c WHERE IsActive__c = true AND ProductRef__c!=null AND ProductCatalogRef__c = \'' + Util.currentCampaign.SalesPCMRef__c+'\'';
            //theQuery += 'ORDER BY Product_Name__c DESC';
            //theQuery += ' LIMIT ' +Label.Temp_Limit_prod;
            // Make your dynamic call
            Map<Id, ProductCatalogEntry__c> mapOfP= new Map<Id, ProductCatalogEntry__c>((List<ProductCatalogEntry__c>)Database.query(theQuery));
            //return  
            return mapOfP;
        }
        return null;
    }
    public PageReference actionDef(){
        return null;
    }
    public boolean showNew {get{return Util.isAccountOwner;}}
    public boolean showEdit {get{return Util.isAccountOwner;}}
    public boolean showDelete {get{return Util.isAccountOwner;}}
    
    public PageReference doAddMultipleLines(){
        String jumperTag = 'tacticalPlanList';
        String ppMode = 'tacticalEdit';
        return URLx.setURL( '/apex/AccountProductPicker?id=' + accountId + '&division=' + Util.divisionId + '&jumperTag=' + jumperTag + '&mode='+ppMode );
    }
    
    public CampaignLineItem__c setStatusByQuantityValue(CampaignLineItem__c cli){
        cli.Status__c = null;
        if (cli.POG__c != null){
            cli.Status__c = 'Confirmed';
        } else if (cli.Agreed__c != null){
            cli.Status__c = 'Ordered / Discussed';
        } else if (cli.Forecast__c != null){
            cli.Status__c = 'Forecast';
        }
        return cli;
    }
    public Map<String, Decimal> getPOGPYByProduct(List<CampaignLineItem__c> tPs){ 
        Map<String, Decimal> mapPOG = new Map<String, Decimal>();
        List<Id> prodIds = new List<Id>();
        if (tPs != null){
            for (CampaignLineItem__c cli : tPs){
                if (cli.ProductRef__c != null){
                    prodIds.add(cli.ProductRef__c);
                    mapPOG.put(cli.ProductRef__c,Decimal.valueOf('0'));
                }
            }
        }

        if (!isFarmAccount()){
            return mapPOG;
        }
        Decimal pogpy = Decimal.valueOf('0');
        if (Util.previewsCampaign != null){
            Id recordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'); 
            String pString = 'SELECT sum(POG__c) POGPY, ProductRef__c prodid FROM CampaignLineItem__c WHERE ProductRef__c in :prodIds';
            pString += ' AND POG__c != null AND CampaignRef__c = \'' + Util.previewsCampaign.Id + '\'';
            pString += ' AND RecordTypeId = \'' + recordTypeId + '\'';
            pString += 'GROUP BY ProductRef__c';
            List<AggregateResult> resultList = (List<AggregateResult>) Database.query(pString);
            for (AggregateResult ar : resultList){
                mapPOG.put((String) ar.get('prodid'),((Decimal) ar.get('POGPY')));
                
            }

        }
        return mapPOG;
    }
    
    public void getAllMapSumFields(List<CampaignLineItem__c> tPs){
        Schema.DescribeSObjectResult dsor = CampaignLineItem__c.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
        Map<String, Decimal> mapSumFields = new Map<String, Decimal>();
        Map<String, String> mapSumFieldsStr = new Map<String, String> ();
        for (Schema.FieldSetMember fsm : listFieldsCLI){
            String fsmStr =  fsm.getfieldPath();
            mapSumFields.put(fsmStr, Decimal.valueOf('0'));
        }

        for (Schema.FieldSetMember fsm : listFieldsCLI){
            String fsmStr =  fsm.getfieldPath();
            String objType = objectFields.get(fsmStr).getDescribe().getType().name().toLowerCase();
            if ( objType.equals('double') || objType.equals('integer') || objType.equals('currency')){
                if (tPs != null){
                    for (CampaignLineItem__c cli : tPs){
                        mapSumFields.put(fsmStr, (Decimal)mapSumFields.get(fsmStr) + (Decimal) (cli.get(fsmStr)== null ? Decimal.valueOf('0') : cli.get(fsmStr) ));
                    }
                }
            }
            else {
                    mapSumFields.put(fsmStr, mapSumFields.get(fsmStr) + Decimal.valueOf('0'));
            }
            
        }
        mapTPSumFields=mapSumFields;
    }
}