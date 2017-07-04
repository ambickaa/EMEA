/**
 * This class provides common methods for order/invoice and delivery inline pages
 * 
 * @author	Accenture
 * @version	1.0, 04/11/2016
 * 
 */ 
public virtual class ODICommons {
    public final Integer REC_LIMIT = 100;//holds value for record limit in search results
    public final Integer PAGESIZE = 5;//holds value for page size in pagination
    public String division{get;set;}
    public String salesOrg{get;set;}
    public String ALL_OPTION = 'All';
    //public String salesDistrictCode{get;set;}
    
    //Standard Controller
    public Apexpages.StandardSetController con{
        get{
            if(con == null){
                con = new Apexpages.StandardSetController(Database.getQueryLocator(getQuery()));
                con.setPageSize(PAGESIZE);
            }
            return con;
        }
        set;
    }
    //proeprty - total records in search result
    public Integer totalRecords{
        get{
            return con.getResultSize();
        }
        set;
    }
    
    /**
     * This method is overrided by subclass and returns query based on filter criteria
     * 
     * @param	Nothing
     * @returns	Query as String
     * @throws	Nothing
     * @since	1.0
     * 
     */ 
    public virtual String getQuery(){return null;}
    
    //property to hold calendar months list
    public List<SelectOption> lstMonths{
        get{
            if(lstMonths == null){
                lstMonths = new List<SelectOption>();
                lstMonths.add(new SelectOption('','All'));
                lstMonths.add(new SelectOption('01','January'));
                lstMonths.add(new SelectOption('02','February'));
                lstMonths.add(new SelectOption('03','March'));
                lstMonths.add(new SelectOption('04','April'));
                lstMonths.add(new SelectOption('05','May'));
                lstMonths.add(new SelectOption('06','June'));
                lstMonths.add(new SelectOption('07','July'));
                lstMonths.add(new SelectOption('08','August'));
                lstMonths.add(new SelectOption('09','September'));
                lstMonths.add(new SelectOption('10','October'));
                lstMonths.add(new SelectOption('11','November'));
                lstMonths.add(new SelectOption('12','December'));
            }
            return lstMonths;
        }
        set;
    }
    
    //property to hold account id from request parameters (id)
    public Id accountId{
        get{
            if(accountId == null){
                accountId = ApexPages.currentPage().getParameters().get('id');
            }
            return accountId;
        }
        set;
    }
    
    //property to hold sales area records related to account
    public List<Sales_Area__c> lstSalesArea{
        get{
            if(lstSalesArea == null){
                lstSalesArea = [SELECT Id,GC_Account_Integration_Key__c,Sales_Org_Code__c
                                      ,Distribution_Channel_Code__c,Divison_Code__c,Sales_District_Code__c
                                      ,Name
                                      FROM Sales_Area__c 
                                      WHERE GC_Account_Integration_Key__c = :accountId 
                                      AND is_Marked_For_Del__c = false];
            }
            return lstSalesArea;
        }
        set;
    }
    
    public Set<String> setSalesOrg{
        get{
            if(null == setSalesOrg){
                setSalesOrg = new Set<String>();
                for(Sales_Area__c salesArea : lstSalesArea){
                    if(null != salesArea.Sales_Org_Code__c)
                    	setSalesOrg.add(salesArea.Sales_Org_Code__c);
                }
            }
            return setSalesOrg;
        }
        set;
    }
    
    //property to hold sales org list related to sales area related to account for sales org drop down 
    public List<SelectOption> lstSalesOrg{
        get{
            if(lstSalesOrg == null){
                lstSalesOrg = new List<SelectOption>();
                lstSalesOrg.add(new SelectOption('',ALL_OPTION));
                for(String so : setSalesOrg){
                    lstSalesOrg.add(new SelectOption(so,so));
                }
                lstSalesOrg.sort();
            }
            return lstSalesOrg;
        }
        set;
    }
    
    public Set<String> setDivisionCode{
        get{
            if(null == setDivisionCode){
                setDivisionCode = new Set<String>();
                for(Sales_Area__c salesArea : lstSalesArea){
                    if(null != salesArea.Divison_Code__c)
                        setDivisionCode.add(salesArea.Divison_Code__c);
                }
            }
            return setDivisionCode;
        }
        set;
    }
    
    //property to hold division code list related to sales area related to account for division drop down 
    public List<SelectOption> lstDivisionCode{
        get{
            if(lstDivisionCode == null){
                lstDivisionCode = new List<SelectOption>();
                lstDivisionCode.add(new SelectOption('',ALL_OPTION));
                for(String dc : setDivisionCode){
                    lstDivisionCode.add(new SelectOption(dc,dc));
                }
                lstDivisionCode.sort();
            }
            return lstDivisionCode;
        }
        set;
    }
    
    /*public Set<SelectOption> setSalesDistrictCode{
        get{
            if(setSalesDistrictCode == null){
                setSalesDistrictCode = new Set<SelectOption>();
                setSalesDistrictCode.add(new SelectOption('','All'));
                for(Sales_Area__c salesArea : lstSalesArea){
                    setSalesDistrictCode.add(new SelectOption(salesArea.Sales_District_Code__c,salesArea.Sales_District_Code__c));
                }
            }
            return setSalesDistrictCode;
        }
        set;
    }*/
    
    //property states wether previous page is available for view
    public Boolean hasPrevious{
        get{
            return con.getHasPrevious();
        }
        set;
    }
    
    //property states whether next page is available for view
    public Boolean hasNext{
        get{
            return con.getHasNext();
        }
        set;
    }
    
    /**
     * This method shifts control to previous page
     * 
     * @param	Nothing
     * @returns	Nothing
     * @throws	Nothing
     * @since	1.0
     * 
     */ 
    public void previous(){
        con.previous();
    }
    
    /**
     * This method shifts control to next page
     * 
     * @param	Nothing
     * @returns	Nothing
     * @throws	Nothing
     * @since	1.0
     * 
     */ 
    public void next(){
        con.next();
    }
    
    /**
     * This method returns report record corrsponding to the developername 
     * 
     * @param	developerName Developer Name of the report
     * @returns	Report record
     * @throws	Nothing
     * @since	1.0
     * 
     */
    public Report getReport(String developerName){
        try{
            Report oReport = [SELECT Id,DeveloperName,Name FROM Report WHERE DeveloperName = :developerName];
            return oReport;
        }catch(Exception e){
            system.debug('ERROR: '+e.getMessage());
        }
        return null;
    }

}