public with sharing class StockManagementController {
	public final String modeRegular='Regular';
	public final String modeTax='Tax';

	public ProductCatalogEntry__c product{get;set;}
	public ProductCatalogEntry__c productFilter{get;set;}
	public User user{get;set;}
	public Stock__c stock{get;set;}
	public Stock__c stockNew{get;set;}
	
	public StockManagementController(){
		product = new ProductCatalogEntry__c();
		productFilter = new ProductCatalogEntry__c();
		stock = new Stock__c();
		stockNew = new Stock__c();
		stockListTemp = new List<Stock__c>();
		ssc = new ApexPages.StandardSetController(stockListTemp);
		stockListNew = new List<Stock__c>();
		isStockNew = false;
	}	
	
	/* BEGIN: Stock Allocation Mode: Regular or Tax*/
	public String mode{
		get{
			if (mode == null){
				if (Util.urlParameters.get('Catalog') == null){
					mode = modeRegular;	
				} else {
					mode = Util.urlParameters.get('Catalog');
				}
			}
			return mode;
		}
		set;
	}
	/* END: Stock Allocation Mode: Regular or Tax*/

	/* BEGIN: Delete Stock from search table */
	public string SelectedStockId { get; set; }
	
	public void doDelete(){
		if (SelectedStockId != null){
			Stock__c stkDel = new Stock__c(Id=SelectedStockId);
			System.savepoint sp = Database.setSavepoint();
			try{
				delete stkDel;
				Util.addConfirmMessage('Stock has been deleted successfully');
			}
			catch(Exception e){
				Util.addErrorMessage(e);
				Database.rollback(sp);
			}
			Integer pageNum = ssc.getPageNumber();
			searchStock();
			ssc.setPageNumber(pageNum);
		}
		
	}

	/* END: Delete Stock from search table */
	
	/* BEGIN: Stocks Search List */
	public ApexPages.StandardSetController ssc{get;set;}
	
	public List<Schema.FieldSetMember> stockFields{
		get{
			String fsPrefix='stockStandardRegular';
	        String taxPrefix = 'stockStandardTax';
	
	        String postfix = '';
	        if (Util.currentUser.Country != null){
	            postfix = Util.currentUser.Country.replace(' ','').trim();
	        }
	        If (mode != modeRegular){
	            fsPrefix = taxPrefix;
	        }
	        if(SObjectType.Stock__c.FieldSets.getMap().get(fsPrefix + postfix) == null){
	            if (SObjectType.Stock__c.FieldSets.getMap().get('stockStandardRegularsouthafrica') != null){
	                stockFields= SObjectType.Stock__c.FieldSets.getMap().get('stockStandardRegularsouthafrica').getFields();
	            }else {
	                stockFields= new List<Schema.FieldSetMember>();
	            }
	        } else{
	            stockFields= SObjectType.Stock__c.FieldSets.getMap().get(fsPrefix + postfix).getFields();
	        }
			return stockFields;
		}
		set;
	}
	public void searchStock(){
		if (productFilter.ProductRef__c != null || stock.User_RSA__c != null){ 
			Set<Id> pceIds = new Set<Id>();
			Id prod = productFilter.ProductRef__c;
			Id usr = stock.User_RSA__c;
			Id year = (mode == modeRegular)?UtilREST.currentYearRSA2.Id:UtilREST.currentYearRSA2.YearPreviousYear__c;
			String pString = 'SELECT ';
			for (Schema.FieldSetMember field: stockFields){
				pString += field.getFieldPath() + ', ';
			}
			pString += ' Id FROM Stock__c WHERE ';
			
			if (prod != null){
				List<ProductCatalogEntry__c> pceList = 
				[SELECT Id 
					FROM ProductCatalogEntry__c
						WHERE ProductCatalogRef__r.YearRef__c =:year
							AND ProductRef__c = :prod];
				for (ProductCatalogEntry__c pce : pceList){
					pceIds.add(pce.Id);
				}
				pString += ' ProductCatalogEntryRef_RSA__c in :pceIds';
			} 
			if (productFilter.ProductRef__c != null && stock.User_RSA__c != null){
				pString += ' AND ';
			}
			if (stock.User_RSA__c != null){
				pString += ' User_RSA__c = :usr ';
				pString += ' AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c =:year ';
			} 
			
			stockListTemp = Database.query(pString);
			if (stockListTemp.size() <= 0){
				Util.addWarningMessage(Label.NoStockFound);
			}
			ssc = new ApexPages.StandardSetController(stockListTemp);
			
			//ssc.setPageSize(Integer.valueOf(Label.StockPageSizeLimit));
			ssc.setPageSize(50);
			
		} 
		
	}
	public List<Stock__c> stockList{
		get{
			if (ssc != null){
				return (List<Stock__c>) ssc.getRecords();
			} else {
				return new List<Stock__c>();
			}
		}
	 	set;
	}
	public List<Stock__c> stockListTemp{get;set;}
	
	public Boolean hasPrevious{  
        get{  
            return ssc.getHasPrevious();  
        }  
        set;  
    }
    
	public Integer pageNumber{
		get{
			return ssc.getPageNumber();
		}
		set;
	}
	
    public Boolean hasNext{  
        get{  
            return ssc.getHasNext();  
        }  
        set;  
    }  
    
    public void previous(){
    	ssc.previous();
    }
    
    public void next(){
    	ssc.next();
    }
    /*** BEGIN: Buttons */
	public void doSave(){
		System.savepoint sp = Database.setSavepoint();
		try{
			update stockList;
			Util.addConfirmMessage('Stock has been modified successfully');
		}
		catch (DmlException e){
			if(e.getDmlType(0) == StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY){
				
                Util.addErrorMessage(e.getMessage());
                
            }else if(e.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                Util.addErrorMessage(Label.DupStockValue);
            }
            Database.rollback(sp);
		}
		catch(Exception e){
			Util.addErrorMessage(e);
			Database.rollback(sp);
		}
		Integer pageNum = ssc.getPageNumber();
		searchStock();
		ssc.setPageNumber(pageNum);
	}	
	
	/*** END: Buttons */
	/* END: Stocks Search List */
	
	/* BEGIN: Stocks New Line List */
	public boolean isStockNew{get;set;}
	public List<Stock__c> stockListNew{get;set;}
	
	public List<Schema.FieldSetMember> stockFieldsNew{
		get{
			String fsPrefix='stockStandardRegular';
	        String taxPrefix = 'stockStandardTax';
	
	        String postfix = '';
	        if (Util.currentUser.Country != null){
	            postfix = Util.currentUser.Country.replace(' ','').trim();
	        }
	        If (mode != modeRegular){
	            fsPrefix = taxPrefix;
	        }
	        if(SObjectType.Stock__c.FieldSets.getMap().get(fsPrefix + postfix) == null){
	            if (SObjectType.Stock__c.FieldSets.getMap().get('stockStandardRegularsouthafrica') != null){
	                stockFieldsNew= SObjectType.Stock__c.FieldSets.getMap().get('stockStandardRegularsouthafrica').getFields();
	            }else {
	                stockFieldsNew= new List<Schema.FieldSetMember>();
	            }
	        } else{
	            stockFieldsNew= SObjectType.Stock__c.FieldSets.getMap().get(fsPrefix + postfix).getFields();
	        }
			return stockFieldsNew;
		}
		set;
	}
	public void searchPCE(){
		Id year = (mode == modeRegular)?UtilREST.currentYearRSA2.Id:UtilREST.currentYearRSA2.YearPreviousYear__c;
		Id prod = product.ProductRef__c;
		if (prod == null){
			prodCatEntryList = new List<ProductCatalogEntry__c>();
			product.ProductRef__c.addError(Label.NoProductSel);
		} else {
			String pString = 'SELECT ';
			for (Schema.FieldSetMember field: prodCatFields){
				pString += field.getFieldPath() + ', ';
			}
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
				Util.addWarningMessage(Label.NoPCEFound);
			}
		}
	}
	public List<ProductCatalogEntry__c> prodCatEntryList{get;set;}
	public boolean isPCE{get;set;}

	public List<Schema.FieldSetMember> prodCatFields{
		get{
			String fsPrefix='PCEStandardFieldSet';

	        if(SObjectType.ProductCatalogEntry__c.FieldSets.getMap().get(fsPrefix) != null){
	        	prodCatFields= SObjectType.ProductCatalogEntry__c.FieldSets.getMap().get(fsPrefix).getFields();
            }else {
                prodCatFields= new List<Schema.FieldSetMember>();
	        }
			return prodCatFields;
		}
		set;
	}
	
	public boolean showDelLast{
		get{
			return stockListNew.size() >0;
		}
		set;
	}
	/*** BEGIN: Buttons */
	public void doSaveNew(){
		System.savepoint sp = Database.setSavepoint();
		List<Stock__c> stockListNewFiltered=new List<Stock__c>();
		
		for(Stock__c sto : stockListNew){
			if(sto.User_RSA__c==null){
				if(sto.ProductCatalogEntryRef_RSA__c==null){
					Util.addWarningMessage('Missing required fields: User and ProductCatalogEntry');
				}else{
					Util.addWarningMessage('Missing required field: User on ProductCatalogEntryId:'+sto.ProductCatalogEntryRef_RSA__c);
				}
			}else if(sto.ProductCatalogEntryRef_RSA__c==null){
				Util.addWarningMessage('Missing required field: ProductCatalogEntry on UserId:'+sto.User_RSA__c);
			}else{ 
				stockListNewFiltered.add(sto);}
		}
				
		if(stockListNewFiltered.size()>0){		
			try{
				insert stockListNewFiltered;
				Util.addConfirmMessage('Stock has been allocated successfully');
			}
			catch (DmlException e){
				if(e.getDmlType(0) == StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY){
                	Util.addErrorMessage(e.getMessage());
            	}else if(e.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                	Util.addErrorMessage(Label.DupStockValue);
            	}
            	Database.rollback(sp);
			}
			catch(Exception e){
				Util.addErrorMessage(e);
				Database.rollback(sp);
			}	
		}
		
		stockListNew = new List<Stock__c>();
		isStockNew=false;
		isPCE = false;
		searchStock();
	}
	
	public void doNew(){
		isStockNew = true;
	}
	
	public void doCancelNew(){
		isStockNew = false;
		isPCE = false;
		stockListNew = new List<Stock__c>();
	}	
	
	public String selectedPCE{get;set;}
	public void selectPCE(){
		if (selectedPCE != null){
			isStockNew = true;
			Stock__c stck = new Stock__c(ProductCatalogEntryRef_RSA__c = selectedPCE);
			stockListNew.add(stck);
		}
	}
	public void delLastNew(){
		stockListNew.remove(stockListNew.size()-1);
	}

	public void addNewStockLine(){
		stockListNew.add(new Stock__c());
	}
	/*** END: Buttons */
	/* END: Stocks New Line List */
	
	/* BEGIN: Switch Catalog Redirect */
	public PageReference switchToRegular(){
		return getSwitchPage(modeRegular);
	}
	public PageReference switchToTax(){
		return getSwitchPage(modeTax);
	}
	public PageReference getSwitchPage(String catalog){
		PageReference pageRef = ApexPages.currentPage();
		pageRef.getParameters().clear();
		pageRef.getParameters().put('catalog', catalog);
		pageRef.setRedirect(true);
		return pageRef;
	}
	public boolean isRegular{
		get{
			isRegular = mode==modeRegular;
			return isRegular;
		}
		set;
	}
		
	/* END: Switch Catalog Redirect */
}