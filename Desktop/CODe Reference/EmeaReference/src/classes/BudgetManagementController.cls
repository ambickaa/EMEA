public with sharing class BudgetManagementController {
	public ProductCatalogEntry__c product{get;set;}
	public ProductCatalogEntry__c productFilter{get;set;}
	public User user{get;set;}
	public Budget__c budget{get;set;}
	public Budget__c budgetFilter{get;set;}
	public Budget__c budgetNewFilter{get;set;}
	public Budget__c budgetNew{get;set;}
	
	public BudgetManagementController(){
		product = new ProductCatalogEntry__c();
		productFilter = new ProductCatalogEntry__c();
		budget = new Budget__c();
		budgetNew = new Budget__c();
		budgetNewFilter = new Budget__c();
		budgetFilter = new Budget__c();
		budgetListTemp = new List<Budget__c>();
		ssc = new ApexPages.StandardSetController(budgetListTemp);
		budgetListNew = new List<Budget__c>();
		isbudgetNew = false;
	}	
	
	/* BEGIN: Delete budget from search table */
	public string SelectedBudgetId { get; set; }
	
	public void doDelete(){ //Done
		if (SelectedBudgetId != null){
			Budget__c bgtDel = new Budget__c(Id=SelectedBudgetId);
			System.savepoint sp = Database.setSavepoint();
			try{
				delete bgtDel;
            	Util.addConfirmMessage('Budget has been deleted successfully');
			}
			catch(Exception e){
				Util.addErrorMessage(e);
				Database.rollback(sp);
			}
			Integer pageNum = ssc.getPageNumber();
			searchBudget();
			ssc.setPageNumber(pageNum);
		}
		
	}

	/* END: Delete budget from search table */
	
	/* BEGIN: budgets Search List */
	public ApexPages.StandardSetController ssc{get;set;}
	
	public List<Schema.FieldSetMember> budgetFields{ //Done
		get{
			String fsPrefix='budgetStandardManagement';
	
	        if(SObjectType.Budget__c.FieldSets.getMap().get(fsPrefix) != null){
	            budgetFields= SObjectType.Budget__c.FieldSets.getMap().get(fsPrefix).getFields();

	        } else{
	            budgetFields= new List<Schema.FieldSetMember>();
	        }
			return budgetFields;
		}
		set;
	}

	
	public void searchBudget(){ //Done
		if (budgetFilter.ProductRef__c != null || budgetFilter.SalesRep__c != null){ 
			
			Id prod = budgetFilter.ProductRef__c;
			System.debug('prod: '+ prod);
			Id usr = budgetFilter.SalesRep__c;
			Id year = UtilREST.currentYearRSA;
			
			String pString = 'SELECT ';
			for (Schema.FieldSetMember field: budgetFields){
				pString += field.getFieldPath() + ', ';
			}
			pString += ' Id FROM Budget__c WHERE ';
			
			if (prod != null){
				pString += ' ProductRef__c = :prod ';
			} 
			if (budgetFilter.ProductRef__c != null && budgetFilter.SalesRep__c != null){
				pString += ' AND ';
			}
			if (budgetFilter.SalesRep__c != null){
				pString += ' SalesRep__c = :usr ';
				
			} 
			pString += ' AND YearRef__c =:year ';
			
			budgetListTemp = Database.query(pString);
			if (budgetListTemp.size() <= 0){
				Util.addWarningMessage(Label.NoBudgetFound);
			}
			ssc = new ApexPages.StandardSetController(budgetListTemp);
			
			ssc.setPageSize(50);
		} 
		
	}
	
	public List<Budget__c> budgetList{ //Done
		get{
			if (ssc != null){
				return (List<Budget__c>) ssc.getRecords();
			} else {
				return new List<Budget__c>();
			}
		}
	 	set;
	}
	
	public List<Budget__c> budgetListTemp{get;set;}
	
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
    	ssc.previous();
    }
    
    public void next(){ //Done
    	ssc.next();
    }
    
    /*** BEGIN: Buttons */
	public void doSave(){ //Done
		System.savepoint sp = Database.setSavepoint();
		try{
			update budgetList;
            Util.addConfirmMessage('Budget has been modified successfully');
		}
		catch (DmlException e){
			if(e.getDmlType(0) == StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY){
				
                Util.addErrorMessage(e.getMessage());
                
            }else if(e.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                Util.addErrorMessage(Label.DupBudgetValue);
            }
            Database.rollback(sp);
		}
		catch(Exception e){
			Util.addErrorMessage(e);
			Database.rollback(sp);
		}
		Integer pageNum = ssc.getPageNumber();
		searchBudget();
		ssc.setPageNumber(pageNum);
	}	
	
	/*** END: Buttons */
	/* END: budgets Search List */
	
	/* BEGIN: budgets New Line List */
	public boolean isBudgetNew{get;set;}
	public List<Budget__c> budgetListNew{get;set;}
	

	public void searchPCE(){ //Done
		Id year = UtilREST.currentYearRSA;
		Id prod = budgetNewFilter.ProductRef__c;
		if (prod == null){
			budgetNewFilter.ProductRef__c.addError(Label.NoProductSel);
		} else {
			String pString = 'SELECT ';
			pString += ' Id FROM ProductCatalogEntry__c WHERE ';
			pString += ' ProductCatalogRef__r.YearRef__c =:year ';
			pString += ' AND ProductRef__c = :prod ';
			If(Label.Is_PCE_Country_Filter == '1'){
				String country = Label.PCE_Country_Filter;
				pString += ' AND ProductCatalogRef__r.CountryRef__r.Name = :country ';
			}
			prodCatEntryList = Database.query(pString);
			isPCE = True;
			if (prodCatEntryList.size() <=0){
				budgetNewFilter.ProductRef__c.addError(Label.NoPCEFound);
			} else {
				budgetListNew.add(new Budget__c(ProductRef__c=budgetNewFilter.ProductRef__c, YearRef__c=UtilREST.currentYearRSA));
			}
		}
	}
	public List<ProductCatalogEntry__c> prodCatEntryList{get;set;}
	public boolean isPCE{get;set;}
	
	public boolean showDelLast{ //Done
		get{
			return budgetListNew.size() >0;
		}
		set;
	}
	/*** BEGIN: Buttons */
	public void doSaveNew(){ //Done
		System.savepoint sp = Database.setSavepoint();
		List<Budget__c> budgetListNewToInsert = new List<Budget__c>();
		
		for(Budget__c bu: budgetListNew){
			if(bu.SalesRep__c==null){
				Util.addWarningMessage('Sales Rep field cannot be blank for Product Id: '+bu.ProductRef__c);
			} else {
				budgetListNewToInsert.add(bu);				
			}
		}		
		
		if(budgetListNewToInsert.size()>0){
			try{
				insert budgetListNewToInsert;
            	Util.addConfirmMessage('Budget has been allocated successfully');
			}
			catch (DmlException e){
				if(e.getDmlType(0) == StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY){
				
               	 Util.addErrorMessage(e.getMessage());
                
            	}else if(e.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
               	 Util.addErrorMessage(Label.DupBudgetValue);
            	}
            	Database.rollback(sp);
			}
			catch(Exception e){
				Util.addErrorMessage(e);
				Database.rollback(sp);
			}
		
		budgetListNew = new List<Budget__c>();
		isBudgetNew=false;
		isPCE = false;	
		searchBudget();
		}
	}
	public void doNew(){ //Done
		isBudgetNew = true;
	}
	
	public void doCancelNew(){ //Done
		isBudgetNew = false;
		isPCE = false;
		budgetListNew = new List<Budget__c>();
	}	
	
	public void delLastNew(){ //Done
		budgetListNew.remove(budgetListNew.size()-1);
	}

	/*** END: Buttons */
	/* END: budgets New Line List */
	

}