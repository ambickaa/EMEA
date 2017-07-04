public with sharing class ConsignmentDetailController {
            
    public List<Consignment> consignmentLines {get; set;}
    public PageReference returned;
    public Boolean editMode {get;set;}
    public Boolean isAdmin {get;set;}
    public Boolean reloadPage {get;set;}
    public Boolean showEditDelete {get;set;}
    public Boolean onlyRejected {get;set;}
    public Id accountId {get;set;}
    public Account farm {get;set;}
    public Boolean hasCampaign{get;set;}
    public Map<Id,String> initCons{get;set;} // <Consignment Id, Product+Requested>>
    
    public ConsignmentDetailController()
    {
        farm = new Account();
        init(); 
    }
    public void init()
    {
        hasCampaign=true;
        onlyRejected=false;
        isAdmin=getIsAdmin();
        editMode=false;     
        showEditDelete=true;  
        consignmentLines = new List<Consignment>();
        
        if(farm.OwnerId==null || String.valueOf(farm.OwnerID).equals(''))
        {
            accountId=Util.urlParameters.get('id');
            if(accountId == null || String.valueOf(accountId).equals(''))
            {
                hasCampaign=false;
                Util.addErrorMessage('Please, select a Sales Representative.');
                return;
            }
            farm=[SELECT OwnerId from Account WHERE Id=:accountId]; 
        }

        initCons = new Map<Id,String>();
        Set<ID> activeSalesCatalogsRSA = getActiveSalesCatalogs(farm.OwnerID);
        if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID==Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('There is not any active Campaign. Please contact your manager.');
        }
        else if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID!=Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('Farm Owner has not got any active Campaign.');
        }   
            
        for(Consignment__c cons : [SELECT Id, ProductCatalogEntryRef__r.ProductRef__r.Name,  Status__c, 
                                   Requested__c, LastModifiedDate, WarehouseRef__r.StockLeft__c, 
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   ORDER BY LastModifiedDate ASC])
         {
            consignmentLines.add(new Consignment(cons));
            initCons.put(cons.id, cons.ProductCatalogEntryRef__r.ProductRef__c + String.Valueof(cons.Requested__c));
         }
    }
    public PageReference doDelete()
    { 
        
        List<Consignment__c> toDelete = new List<Consignment__c>();
        for (Consignment wrapped : consignmentLines)
        {
            if(wrapped.checked)
                toDelete.add(wrapped.record);
        }
        reloadPage=false;          
        Savepoint sp = Database.setSavepoint();         
        if(toDelete.size()>0){       
            try{   
                delete toDelete;                
                Util.addConfirmMessage('Records have been deleted successfully.');
            }catch(Exception e){ 
            	if(e.getmessage().contains('There are more bags sold than the Allocation'))
                	Util.addErrorMessage('Stock already sold cannot be deleted');
                else
                	Util.addErrorMessage('ERROR: '+e.getmessage());
                Database.rollback(sp);                              
                init();
                return null;} 
       }else
       		Util.addWarningMessage('No record has been selected');
       init();  
       return null;
    } 
    public PageReference doSave()
    { 
        reloadPage=false;   
        Map<Id,Id> prodVspce = new Map<Id,Id> (); // <product, productCatalogEntry>
        Set<Id> productIds = new Set<Id> ();
        Map<Id,String> toCheck = new Map<Id,String>();
        List<Consignment__c> toInsert = new List<Consignment__c>();
        List<Consignment__c> toUpdate = new List<Consignment__c>();
                
        for (Consignment cl : consignmentLines)
        {           
            if(cl.LookupValue.id != null && cl.LookupValue.id !='')
            {
                productIds.add(cl.LookupValue.Id);              
                if( (cl.record.id != null ) && !(String.Valueof(cl.record.id).equals('')) )
                {
                    toCheck.put(cl.record.id, cl.lookupValue.id + String.ValueOf(cl.record.Requested__c));              
                }
            }       
        }  

        for(ProductCatalogEntry__c pce: [SELECT Id, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductRef__c in: productIds 
                                         AND  ProductCatalogRef__c in : getactiveSalesCatalogs(farm.OwnerID)])
        {
            prodVspce.put(pce.ProductRef__c, pce.Id);
        }        
        
/* Checking consigment lines if they have to be inserted, updated or have any missing field*/        
        
        for(Consignment cl: consignmentLines)
        {
            if((cl.LookupValue.id!=null && cl.LookupValue.id!='') && (cl.record.id == null || (String.Valueof(cl.record.id).equals(''))))
            {
                cl.record.ProductCatalogEntryRef__c=prodVspce.get(cl.LookupValue.id); 
                cl.record.Status__c='Rejected';
                toInsert.add(cl.record);        
            }
            else if((cl.LookupValue.id!=null && cl.LookupValue.id!='') && !(cl.record.id == null && (String.Valueof(cl.record.id).equals(''))))
            {
                if(toCheck.get(cl.record.id)!=initCons.get(cl.record.id))
                    {
                        cl.record.ProductCatalogEntryRef__c=prodVspce.get(cl.LookupValue.id); 
                        toUpdate.add(cl.record);
                    }
            }       
            else
            {
                Util.addErrorMessage('Required field missing: Product.');
            }
        }
        
/* The following code join all consignment lines of a PCE in a single one */     
   
        List<Consignment__c> toInsertOpt = new List<Consignment__c>();
        Map< String, Consignment__c> Optimizer = new Map< String, Consignment__c>();
        
        for(Consignment__c cons : toInsert)
        {
            if(Optimizer.get(cons.ProductCatalogEntryRef__c)==null)
            {
                Optimizer.put(cons.ProductCatalogEntryRef__c,cons);
            }
            else
            {
                Consignment__c consig = Optimizer.get(cons.ProductCatalogEntryRef__c);
                consig.Requested__c=consig.Requested__c + cons.Requested__c;
                consig.ProductCatalogEntryRef__c=cons.ProductCatalogEntryRef__c;
                consig.UserRef__c = cons.UserRef__c;
                Optimizer.put(cons.ProductCatalogEntryRef__c, consig);
            }
        }
        for(String pce : Optimizer.keySet())
        {
            toInsertOpt.add(Optimizer.get(pce));
        }
        
/* Insertion of consignment lines. They will be inserted in status Rejected and then updated to Accepted if there is enough Stock*/
        
        if(toInsertOpt.size()>0)
        {  
            Database.SaveResult[] insertList = Database.insert(toInsertOpt, false);
            for (Database.SaveResult sr : insertList)
            {
                if(!(sr.isSuccess()))
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        if(String.valueof(err.getStatusCode()) != 'REQUIRED_FIELD_MISSING')
                            Util.addErrorMessage('The following error has occurred: ' + err.getMessage());
                        else
                            Util.addErrorMessage('There are products without Stock record.');   
                    }
                }
            }
            for(Consignment__c con : toInsertOpt)
            {
                if(con.id != null)
                {
                    con.Status__c='Accepted';
                    toUpdate.add(con);
                }
            }
        }
        
/* Update of consignment lines.*/   

        if(toUpdate.size()>0)
        {  
            Database.SaveResult[] updateList = Database.update(toUpdate, false);
            for (Database.SaveResult sr : updateList)
            {
                if(!(sr.isSuccess()))
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        if(String.valueof(err.getStatusCode()) != 'FIELD_CUSTOM_VALIDATION_EXCEPTION')
                            Util.addErrorMessage('The following error has occurred: ' + err.getMessage());
                        else	
                            Util.addWarningMessage('There is not enough Stock.'); 

                    }
                }
            }
        }
        init();
        return null;
    }     
    public PageReference doCancel() {   
        init(); 
        editMode=false; 
        showEditDelete=true;
        return null;
    }
    public PageReference doEdit(){   
        showEditDelete=false;
        editMode=true;  
        return null;
    }
    public PageReference doAdd()
    {
        editMode=true;
        showEditDelete=false;  
        
        List<Id> prodIds = new List<Id>();
        Map<Id,String> prodNames = new Map<Id,String>();
        
        for(Consignment con: consignmentLines)
        {
            if(con.lookupValue.id!=null && con.lookupValue.id!='')
                prodIds.add(con.lookupValue.id);
        }
        for(Product2 prod: [SELECT ID, Name FROM Product2 WHERE id in: prodIds])
        {
            prodNames.put(prod.Id,prod.Name);           
        }  
        for(Consignment con: consignmentLines)
        {
            if(con.lookupValue.id!=null && con.lookupValue.id !='' && con.lookupvalue.text==null)
            {
                con.lookupvalue.text=prodNames.get(con.lookupvalue.id);
            }
        }         
        consignmentLines.add(new Consignment(new Consignment__c(UserRef__c=farm.OwnerID, Status__c='Pending', Requested__c=0)));
        return null;
    }
    public PageReference checkConsignedStock(){
        //   
        return null;    
    }
    public PageReference onlyAccepted()
    {
        onlyRejected=false;
        isAdmin=getIsAdmin();
        editMode=false;     
        showEditDelete=true;  
        consignmentLines = new List<Consignment>();
        
        if(farm.OwnerID == null || String.valueOf(farm.OwnerID).equals(''))
        {
            init();
            return null;
        }
            
        initCons = new Map<Id,String>();
        Set<ID> activeSalesCatalogsRSA = getActiveSalesCatalogs(farm.OwnerID);
        if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID==Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('There is not any active Campaign. Please contact your manager.');
        }
        else if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID!=Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('Farm Owner has not got any active Campaign.');
        }   
            
        for(Consignment__c cons : [SELECT Id, ProductCatalogEntryRef__r.ProductRef__r.Name,  Status__c, 
                                   Requested__c, LastModifiedDate, WarehouseRef__r.StockLeft__c, 
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   AND Status__c='Accepted'
                                   ORDER BY LastModifiedDate ASC])
         {
            consignmentLines.add(new Consignment(cons));
            initCons.put(cons.id, cons.ProductCatalogEntryRef__r.ProductRef__r.Name + String.Valueof(cons.Requested__c));
         }
         return null;
    }
    public PageReference onlyRejected()
    {
        onlyRejected=true;
        isAdmin=getIsAdmin();
        editMode=false;     
        showEditDelete=true;  
        consignmentLines = new List<Consignment>();
        
        if(farm.OwnerID == null || String.valueOf(farm.OwnerID).equals(''))
        {
            init();
            return null;
        }
                    
        initCons = new Map<Id,String>();
        Set<ID> activeSalesCatalogsRSA = getActiveSalesCatalogs(farm.OwnerID);
        if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID==Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('There is not any active Campaign. Please contact your manager.');
        }
        else if(activeSalesCatalogsRSA.size()==0 && farm.OwnerID!=Util.currentUser.id)
        {
            hasCampaign=false;
            Util.addErrorMessage('Farm Owner has not got any active Campaign.');
        }   
        for(Consignment__c cons : [SELECT Id, ProductCatalogEntryRef__r.ProductRef__r.Name,  Status__c, 
                                   Requested__c, LastModifiedDate, WarehouseRef__r.StockLeft__c, 
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   AND Status__c='Rejected'
                                   ORDER BY LastModifiedDate ASC])
         {
            consignmentLines.add(new Consignment(cons));
            initCons.put(cons.id, cons.ProductCatalogEntryRef__r.ProductRef__r.Name + String.Valueof(cons.Requested__c));
         }
         return null;
    }
    public PageReference viewAll()
    {
        init();
        return null;
    }
/* Private helper Methods*/    
    
    private static Set<Id> getActiveSalesCatalogs(Id ownerCatalogs){
        Set<Id> activeSalesCatalogs=new SET<ID>();
        for( Campaign cpg : [ SELECT  ID, SalesPCMRef__c FROM Campaign WHERE StatusCode__c=200 AND OwnerId=:ownerCatalogs])
        {
            activeSalesCatalogs.add(cpg.SalesPCMRef__c);
        }
        return activeSalesCatalogs;
    } 
    private static Boolean getIsAdmin(){
        return UtilREST.hasAdminPermissionsRSA;
    } 
}