public with sharing class ConsignmentRequestProcessController {
            
    public List<Consignment> consignmentLines {get; set;}
    public PageReference returned;
    public Boolean editMode {get;set;}
    public Boolean isAdmin {get;set;}
    public Boolean isRM {get;set;}
    public Boolean reloadPage {get;set;}
    public Boolean showEditDelete {get;set;}
    public Boolean onlyRejected {get;set;}
    public Boolean onlyPending {get;set;}
    public Id accountId {get;set;}
    public Account farm {get;set;}
    public Boolean hasCampaign{get;set;}
    public Map<Id,String> initCons{get;set;} // <Consignment Id, Product+Requested>>
    
    public String OptionsToChoose{get;set;}
    public SelectOption All = new SelectOption('All', 'All');
    public SelectOption Pending = new SelectOption('Pending', 'Pending');
    public SelectOption Rejected = new SelectOption('Rejected', 'Rejected');
    public SelectOption Accepted = new SelectOption('Accepted', 'Accepted');
    public  List<SelectOption> options{get;set;}// = new List<SelectOption>{All, Pending, Rejected, Accepted};
    
    public List<SelectOption> optionsUser {get;set;}
    
    public Boolean isAccepted{get;set;}
    
    public String com{get;set;}
    public String valueOne { get; set; }
    public boolean displayPopup {get; set;} 
    public boolean Acc {get; set;}
    public boolean Rej {get; set;}
    public boolean AccAll {get; set;}
    public boolean RejAll {get; set;} 
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopupAcc() {        
        displayPopup = true;  
        Acc=true;
        Rej=false;
        AccAll=false;
        RejAll=  false;
    }	
    
    public void showPopupRej() {        
        displayPopup = true; 
        Acc=false;
        Rej=true;
        AccAll=false;
        RejAll=  false;  
    }	
    
    public void showPopupAccAll() {        
        displayPopup = true;
        Acc=false;
        Rej=false;
        AccAll=true;
        RejAll=  false;    
    }	
    
    public void showPopupRejAll() {        
        displayPopup = true; 
        Acc=false;
        Rej=false;
        AccAll=false;
        RejAll=  true;   
    }	
   		 
    
    
    public ConsignmentRequestProcessController()
    {
        farm = new Account();
        options = new List<SelectOption>{All, Pending, Rejected, Accepted};
        optionsUser = new List<SelectOption>();
        for(User us : [SELECT Id, Name, Manager.id FROM User WHERE Manager.id=:Util.currentuser.id AND isActive = true])
        {
        	system.debug('¿?¿?¿?¿ '+us);
        	SelectOption opt = new SelectOption (us.id, us.Name);
        	optionsUser.add(opt);
        }
        com='';
        init(); 
    }
    public void init()
    {
        hasCampaign=true;
        onlyRejected=false;
        isAdmin=getIsAdmin();
        isRM=getIsRM();
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
            Util.addErrorMessage('TEST  ' +farm.ownerID);
            Util.addErrorMessage('Wrong Sales Representative. Select a new one.');
        }   
            
        for(Consignment__c cons : [SELECT Id, ProductCatalogEntryRef__r.ProductRef__r.Name,  Status__c, 
                                   Requested__c, LastModifiedDate, WarehouseRef__r.StockLeft__c, 
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c, UserRef__c,
                                   GlobalStockRef__r.HybridRef__r.Stockleft__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   ORDER BY LastModifiedDate DESC])
         {
            consignmentLines.add(new Consignment(cons));
            initCons.put(cons.id, cons.ProductCatalogEntryRef__r.ProductRef__c + String.Valueof(cons.Requested__c));
         }
         if(consignmentLines.size()==0)
         {
         Util.addWarningMessage('This Sales Representative does not have any related consignment request.');	
         }
    }
    
    
    public PageReference doReject()
    { 
        List<UpdateHistory__c> historyList = new List<UpdateHistory__c>();
        List<Consignment__c> toReject = new List<Consignment__c>();
        for (Consignment wrapped : consignmentLines)
        {
        	UpdateHistory__c upItem = new UpdateHistory__c();
            if(wrapped.checked==true && wrapped.record.status__c=='Pending')
            	{
            		upItem.ConsignmentRef__c=wrapped.record.Id;
            		upItem.Approver__c=util.currentUser.Id;
            		upItem.ApprovalDate__c=datetime.now();
            		upItem.Details__c='Status: Rejected.   Requested: '+wrapped.record.requested__c+'. Stock in the approval moment: '+wrapped.record.GlobalStockRef__r.HybridRef__r.StockLeft__c;
            		upItem.Process__c='Consignment Process';
            		upItem.Comments__c=com;
            		
            		wrapped.record.status__c='Rejected';
            		wrapped.record.TXT_ApprovalComments__c=com;
                	
                	historyList.add(upItem);
                	toReject.add(wrapped.record);
            	}
        }
        system.debug('TEST ToReject: '+toReject);
        displayPopup = false;
        reloadPage=false;          
        Savepoint sp = Database.setSavepoint();         
        if(toReject.size()>0){       
            try{   
                update toReject;         
                utilRest.sendConsApprovetMail(toReject, false);  
                insert historyList;
                     
                Util.addConfirmMessage('The selected Consignment Requests have been successfully rejected');
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
    
    public PageReference doRejectAll()
    { 
        List<UpdateHistory__c> historyList = new List<UpdateHistory__c>();
        List<Consignment__c> toReject = new List<Consignment__c>();
        for (Consignment wrapped : consignmentLines)
        {
        	UpdateHistory__c upItem = new UpdateHistory__c();
            if(wrapped.record.status__c=='Pending')
            	{
            		upItem.ConsignmentRef__c=wrapped.record.Id;
            		upItem.Approver__c=util.currentUser.Id;
            		upItem.ApprovalDate__c=datetime.now();
            		upItem.Details__c='Status: Rejected.   Requested: '+wrapped.record.requested__c+'. Stock in the approval moment: '+wrapped.record.GlobalStockRef__r.HybridRef__r.StockLeft__c;
            		upItem.Process__c='Consignment Process';
            		upItem.Comments__c=com;
            		
            		
            		wrapped.record.status__c='Rejected';
            		wrapped.record.TXT_ApprovalComments__c=com;
                	toReject.add(wrapped.record);
                	historyList.add(upItem);
            	}
        }
        system.debug('TEST ToReject: '+toReject);
        displayPopup = false;
        reloadPage=false;          
        Savepoint sp = Database.setSavepoint();         
        if(toReject.size()>0){       
            try{   
                update toReject;                
                utilRest.sendConsApprovetMail(toReject, false);
                insert historyList;
                
                Util.addConfirmMessage('All pending Consignment Requests have been successfully rejected');
            }catch(Exception e){ 
            	if(e.getmessage().contains('There are more bags sold than the Allocation'))
                	Util.addErrorMessage('Stock already sold cannot be deleted');
                else
                	Util.addErrorMessage('ERROR: '+e.getmessage());
                Database.rollback(sp);                              
                init();
                return null;} 
       }else
       		Util.addWarningMessage('There is no pending requests.');
       init();  
       return null;
    } 
    
    public PageReference doAccept()
    { 
    
        List<UpdateHistory__c> historyList = new List<UpdateHistory__c>();
        List<Consignment__c> toAccept = new List<Consignment__c>();
        for (Consignment wrapped : consignmentLines)
        {
        	UpdateHistory__c upItem = new UpdateHistory__c();
            if(wrapped.checked==true && wrapped.record.status__c=='Pending')
            {
            	upItem.ConsignmentRef__c=wrapped.record.Id;
        		upItem.Approver__c=util.currentUser.Id;
        		upItem.ApprovalDate__c=datetime.now();
        		upItem.Details__c='Status: Accepted.   Requested: '+wrapped.record.requested__c+'. Stock in the approval moment: '+wrapped.record.GlobalStockRef__r.HybridRef__r.StockLeft__c;
        		upItem.Process__c='Consignment Process';
        		upItem.comments__c=com;
            		
            		
            	
            	wrapped.record.status__c='Accepted';
            	wrapped.record.TXT_ApprovalComments__c=com;
                toAccept.add(wrapped.record);
                historyList.add(upItem);
            }    
        }
        displayPopup = false;
        reloadPage=false;          
        Savepoint sp = Database.setSavepoint();         
        if(toAccept.size()>0){       
            try{
            	   
                update toAccept;
                utilRest.sendConsApprovetMail(toAccept, true);       
                insert historyList;
                         
                Util.addConfirmMessage('The selected Consignment Requests have been successfully accepted');
            }catch(Exception e){ 
            	if(e.getmessage().contains('There are more bags sold than the Allocation'))
                	Util.addErrorMessage('Stock already sold cannot be deleted');
                else
                	Util.addErrorMessage('ERROR: '+e.getStackTraceString());
                	Util.addErrorMessage('ERROR: '+e.getCause());
                	Util.addErrorMessage('ERROR: '+e.getMessage());
                Database.rollback(sp);                              
                init();
                return null;} 
       }else
       		Util.addWarningMessage('No record has been selected');
       init();  
       return null;
    } 
    
    public PageReference doAcceptAll()
    { 
        List<UpdateHistory__c> historyList = new List<UpdateHistory__c>();
        List<Consignment__c> toAccept = new List<Consignment__c>();
        for (Consignment wrapped : consignmentLines)
        {
            UpdateHistory__c upItem = new UpdateHistory__c();
            if(wrapped.record.status__c=='Pending')
            {
            	upItem.ConsignmentRef__c=wrapped.record.Id;
        		upItem.Approver__c=util.currentUser.Id;
        		upItem.ApprovalDate__c=datetime.now();
        		upItem.Details__c='Status: Accepted.   Requested: '+wrapped.record.requested__c+'. Stock in the approval moment: '+wrapped.record.GlobalStockRef__r.HybridRef__r.StockLeft__c;
        		upItem.Process__c='Consignment Process';
        		upItem.Comments__c=com;
            		
            		
            	wrapped.record.status__c='Accepted';
            	wrapped.record.TXT_ApprovalComments__c=com;
            	
                toAccept.add(wrapped.record);
                historyList.add(upItem);
            }    
        }
        reloadPage=false; 
        displayPopup = false;         
        Savepoint sp = Database.setSavepoint();         
        if(toAccept.size()>0){       
            try{   
                update toAccept;
                utilRest.sendConsApprovetMail(toAccept, true);  
                insert historyList;
                                 
                Util.addConfirmMessage('All pending Consignment Requests have been successfully approved');
            }catch(Exception e){ 
            	if(e.getmessage().contains('There are more bags sold than the Allocation'))
                	Util.addErrorMessage('Stock already sold cannot be deleted');
                else
                	Util.addErrorMessage('ERROR: '+e.getmessage());
                Database.rollback(sp);                              
                init();
                return null;} 
       }else
       		Util.addWarningMessage('There is no pending requests.');
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
        isRM=getIsRM();
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
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c, UserRef__c,
                                   GlobalStockRef__r.HybridRef__r.Stockleft__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   AND Status__c='Accepted'
                                   ORDER BY LastModifiedDate DESC])
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
        isRM=getIsRM();
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
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c, userRef__c,
                                   GlobalStockRef__r.HybridRef__r.Stockleft__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   AND Status__c='Rejected'
                                   ORDER BY LastModifiedDate DESC])
         {
            consignmentLines.add(new Consignment(cons));
            initCons.put(cons.id, cons.ProductCatalogEntryRef__r.ProductRef__r.Name + String.Valueof(cons.Requested__c));
         }
         return null;
    }
    public PageReference onlyPending()
    {
        onlyRejected=false;
        onlyPending=true;
        isAdmin=getIsAdmin();
        isRM=getIsRM();
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
                                   ProductCatalogEntryRef__r.ProductRef__c, WarehouseRef__r.Consumed__c, UserRef__c,
                                   GlobalStockRef__r.HybridRef__r.Stockleft__c
                                   FROM Consignment__c
                                   WHERE UserRef__c=:farm.OwnerID
                                   AND ProductCatalogEntryRef__r.ProductCatalogRef__c IN :activeSalesCatalogsRSA
                                   AND Status__c='Pending'
                                   ORDER BY LastModifiedDate DESC])
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
    
    
    
    
   public String getOptionsChoosen() {
            return optionsToChoose;
        }
        
   
   public void goToView() {
   		if(getOptionsChoosen()!= null && getOptionsChoosen()!='')
   		{
   			if(getOptionsChoosen()=='ALL')
   			viewAll();
   			else if(getOptionsChoosen()=='Pending')
   			onlyPending();
   			else if(getOptionsChoosen()=='Rejected')
   			onlyRejected();
   			else if(getOptionsChoosen()=='Accepted')
   			onlyAccepted();
   		}
   		


   		
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
    
    private static Boolean getIsRM(){
        return Util.isRegionalManagerRSA;
    } 
    
    
}