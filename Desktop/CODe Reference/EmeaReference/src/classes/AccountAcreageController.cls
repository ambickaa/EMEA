public with sharing class AccountAcreageController {

    private transient boolean dqa; // duplicate query avoider
    public transient String mode {get;set;}
    public transient String acreagesToDelete {get;set;}
    private ID accountID;
    public List<Acreage__c> acreages {get;set;}
    public transient Map<ID,UserRecordAccess> access {get;set;}
        
    public AccountAcreageController (){
        getConstructor();
    }
    
    public String getConstructor(){
        accountID = Util.currentAccount.Id;
        mode = 'View';
        reloadAcreages();
        return '';
    }
    private void reloadAcreages(){
        if(dqa == null){
            dqa = true;
            Util.setCurrentAccount(accountID);
            //apexpages.currentpage().getParameters().put('id',accountID);
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : getFields()) {
                query += f.getFieldPath() + ', ';
            }
            //ana ini 11/12/14
            if(!query.contains('AcrPrevTotalAcreages__c')){
                query += ' AcrPrevTotalAcreages__c,' ;
            }
            if(!query.contains('PreviousAcreageRef__c')){
                query += ' PreviousAcreageRef__c,' ;
            }                           
            //ana fin 11/12/14
            query += ' Name from Acreage__c WHERE AcrFarmRef__c = \'' + Util.currentAccount.ID + '\' AND AcrYearRef__c = \'' + Util.currentYear.ID + '\'' ;
            
            acreages = Database.query(query);
            /*if(access == null){
                access = new Map<ID,UserRecordAccess>();
                for(UserRecordAccess forUra : [SELECT recordID, HasDeleteAccess,HasEditAccess,HasReadAccess,HasTransferAccess FROM UserRecordAccess where userID = :UserInfo.getUserID() and recordID in :new List<ID>(new Map<ID,Acreage__c>(acreages).keyset())]){
                    access.put(forUra.RecordId, forUra);
                    Util.addConfirmMessage('hey');
                }
            }
            Util.addInfoMessage(access);                
            Util.addWarningMessage(new map<ID,Acreage__c>(acreages).keySet());*/
            doNew();
            mode = 'View';
        }
    }
    public static List<Schema.FieldSetMember> getFields() {
        String postfix = '';
        if (Util.currentUser.Country != null){
            /* check if the user's country is included in the Custom label Acreages_Generic_Countries */
            //if(Util.currentUser.Country.replace(' ','').trim() == 'Italy' || Util.currentUser.Country.replace(' ','').trim() == 'Slovakia' || Util.currentUser.Country.replace(' ','').trim() == 'Spain' || Util.currentUser.Country.replace(' ','').trim() == 'Russia' || Util.currentUser.Country.replace(' ','').trim() == 'CzechRepublic' || Util.currentUser.Country.replace(' ','').trim() == 'Hungary' || Util.currentUser.Country.replace(' ','').trim() == 'Turkey' || Util.currentUser.Country.replace(' ','').trim() == 'Romania' || Util.currentUser.Country.replace(' ','').trim() == 'Ukraine' || Util.currentUser.Country.replace(' ','').trim() == 'Bulgaria'){
            if (label.Acreages_Generic_Countries.contains(Util.currentUser.Country) ){
                postfix = 'Generic';
            }else{ 
                postfix = Util.currentUser.Country.replace(' ','').trim();
            }
        }
        
        if(SObjectType.Acreage__c.FieldSets.getMap().get('Acreage' + postfix) == null)
            return SObjectType.Acreage__c.FieldSets.getMap().get('AccountAcreageProductListStandard').getFields();
        else
            return SObjectType.Acreage__c.FieldSets.getMap().get('Acreage' + postfix).getFields();
    }
            
       
    public String productTypeWithGroup {
        get{
            if(productTypeWithGroup == null){
                productGroupMaping = new List<SelectOption>{};
                productTypeMaping = new Map<ID,List<SelectOption>>();
                
                Map<String,ID> productGroupTrMap = new Map<String,ID>();
                List<String> productGroupList = new List<String>();
                
                Map<String,ID> productTypeTrMap = new Map<String,ID>();
                List<String> productTypeList = new List<String>();  
                Map<String,ID> productTypeGroupMap = new Map<String,ID>();
                
               for(Product_Grouping__c forProdGr : [SELECT Name,ProductGroupRef__c, recordtypeId FROM Product_Grouping__c WHERE recordtype.name ='Product Group']){
                    String TranslateOption = ProdTransController.getTranslation(forProdGr.ID);
                    
                    System.debug(TranslateOption);
                    
                    //Recordtype=Product Group
                    if (TranslateOption != 'x' && TranslateOption != null)  {
                        productGroupTrMap.put(TranslateOption, forProdGr.ID);
                        productGroupList.add(TranslateOption);
                    }
                }
            
                if (productGroupList.size()>0){
                    productGroupList.sort();
                    
                    System.debug(productGroupList);
                    
                    for(String Translation : productGroupList) {                    
                        SelectOption currentSelectOption = new SelectOption(productGroupTrMap.get(Translation), Translation);
                        productGroupMaping.add(currentSelectOption);
                        productTypeMaping.put(productGroupTrMap.get(Translation),new List<SelectOption>{new SelectOption('','')});
                    }
                }

                for(Product_Grouping__c forProdGr : [SELECT Name,ProductGroupRef__c, recordtypeId FROM Product_Grouping__c WHERE recordtype.name ='Product Type']){
                    String TranslateOption = ProdTransController.getTranslation(forProdGr.ID);
                    
                    
                    if (TranslateOption != 'x' && TranslateOption != null)  {
                        productTypeList.add(TranslateOption);
                        productTypeGroupMap.put(TranslateOption, forProdGr.productGroupRef__c);
                        productTypeTrMap.put(TranslateOption, forProdGr.ID);
                    }
                }
                
                if (productTypeList.size()>0){
                    productTypeList.sort();
                
                    //Recordtype=Product type
                
                    for(String Translation : productTypeList) {                 
                        SelectOption currentSelectOption = new SelectOption(productTypeTrMap.get(Translation), Translation);
                        productTypemaping.get(productTypeGroupMap.get(Translation)).add(currentSelectOption);
                    }
                
                }
                
                productTypeWithGroup = String.valueOf(productTypeMaping.keySet());
            }
            return productTypeWithGroup;
            
        }set;
    }

    public List<SelectOption> productGroupMaping {get{ if(productGroupMaping == null)System.debug(ProductTypeWithGroup); return productGroupMaping;}private set;}
    public List<SelectOption> productGroupMap {get{ if(productGroupMap == null)System.debug(ProductTypeWithGroup); return productGroupMap;}private set;}
    public Map<ID,List<SelectOption>> productTypeMaping {get{ if(productTypeMaping == null)System.debug(ProductTypeWithGroup); return productTypeMaping;}private set;}
    
    public String getTranslationsMap(){
        ProdTransController.initMapTrans();
        String returned = '';
        
        for(ID forID : ProdTransController.mapTranslations.keySet()){
            returned += ',\'' + String.valueOf(forID).subString(0,15) + '\':\'' + ProdTransController.mapTranslations.get(forID) + '\'';
        }
        
        return '{' + returned.substring(1) + '}';
    }
    
    public void doEdit(){
        Util.setCurrentAccount(accountID);
        mode = 'Edit';
    }
    public void doNew(){
        Util.setCurrentAccount(accountID);
        
        for(Integer i = 0; i < 5; i++){
            acreages.add(new Acreage__c(AcrFarmRef__c = Util.currentAccount.ID, AcrYearRef__c = Util.currentYear.ID, AcrProductGroupRef__c = productGroupMaping.get(0).getValue()));
        }
        mode = 'Edit';
    }
    public void doSave(){
        Util.setCurrentAccount(accountID);
        doEdit();
        List<Acreage__c> toInsert = new List<Acreage__c>();
        List<Acreage__c> toUpdate = new List<Acreage__c>();
        
        for(Acreage__c forAcre : acreages){
            if(forAcre.id == null){
                if(forAcre.AcrProviderRef__c != null){
                    toInsert.add(forAcre);
                }
            } else {
                toUpdate.add(forAcre);
            }
        }

        System.savepoint sp = Database.setSavepoint();
        
        if(toInsert.size() > 0 || toUpdate.size() > 0) {

	        try{
	            insert toInsert.clone(); System.debug('***List of Acreages to insert: ' + toInsert);
	            update toUpdate; System.debug('***List of Acreages to update: ' + toUpdate);
	            mode = 'View';
	            reloadAcreages();
	            Util.addConfirmMessage(Label.msgSaved);
	        }catch(DMLException e){
	            if(e.getDmlType(0) == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY || e.getDmlType(0) == StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY){
	                Util.addErrorMessage('Not Authorised');
	            }else{
	                Util.addErrorMessage(e);
	            }
	            Database.rollback(sp);
	        }catch(Exception e){
	            mode = 'Edit';
	            Util.addErrorMessage(e);
	            Database.rollback(sp);
	        }
        
        } else {

        	Util.addErrorMessage('Please, check all mandatory fields are filled');
        	Database.rollback(sp);
        }
    }
    public void doCancel(){
        Util.setCurrentAccount(accountID);
        apexPages.currentPage().getParameters().put('id',accountID);
        mode = 'View';
        reloadAcreages();
    }
    public void doDelete(){
        Util.setCurrentAccount(accountID);
        Integer count = 0;
        List<sObject> toDelete = new List<sObject>();
        if(!acreagesToDelete.equals('')){
            for(String forIndex : acreagesToDelete.split(',')){
                Acreage__c acreageToDelete = acreages.remove(Integer.valueOf(forIndex) - count++);
                if(acreageToDelete.ID != null){
                    toDelete.add((sObject)new Acreage__c(id=acreageToDelete.ID)); 
                }
            }
            try{
              delete toDelete; 
              Util.addConfirmMessage(Label.msgRecordsDeleted);
            } catch (DMLException theDMLException){
              if((theDMLException.getMessage()).contains('insufficient access rights')){
                transient String owner = [SELECT Owner.Name From Acreage__c WHERE Id =:theDMLException.getDMLId(0) LIMIT 1].Owner.Name; 
                Util.addWarningMessage('You cannot delete records you do not own. Please, contact '+Owner+' to delete selected records.');
              } 
                else Util.addErrorMessage('Records have not been deleted due to: '+theDMLException.getMessage());
                reloadAcreages();
            } catch (Exception theException){
                Util.addErrorMessage('Records have not been deleted due to: '+theException.getMessage());
                reloadAcreages();
            }    
        }else{
            Util.addWarningMessage(Label.msgNoRecordsSelected);
        }
    }
    
    public boolean showNew {get{return Util.isAccountOwner;}}
    public boolean showEdit {get{return Util.isAccountOwner;}}
    public boolean showDelete {get{return Util.isAccountOwner;}}
    
}