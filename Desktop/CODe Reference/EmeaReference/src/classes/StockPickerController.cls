/*
  @description
  @copyright everis
*/
public with sharing class StockPickerController
{

    public Stock2Pick Stockpicker {get; set;}
    
    public List<Stock2Pick> stpAdded {get; set;}
    public List<Stock2Pick> stpResult {get; set;}  
    
    public Product2 filter {get;set;}
    public String filterName {get;set;}
    /*
    @description Constructor
    */
    public StockPickerController ()  {
        stpResult  = new List<Stock2Pick>();
        stpAdded = new List<Stock2Pick>();
//        for(Product2 pce :  [Select Id, Name, ProductKernelSize__c, ProductTreatment__c, ProductBagSize__c, ProductMaturity__c, ProductPrmyPkType__c, ProductVendor__c, ProductBagWeight__c From Product2 LIMIT 5]){
//            stpResult.add(new Stock2Pick(pce));
//        }
        filter = new Product2();
        filterName = '';
        doFilter();
    }
   
    //al dar añadir se recorre la de abajo y se añade a la lista de arriba
    //
    public void doAddSelected()
    {
        List<Stock2Pick> stpNewResult = new List<Stock2Pick>();
        for (Stock2Pick a: stpResult  )  {
            if (a.selected){
                a.selected = false;
                stpAdded.add(a);
            }else{
                stpNewResult.add(a);
            }
        } 
        stpResult = stpNewResult;
    }

    public void doDeleteSelected()
    {
        List<Stock2Pick> stpNewAdded = new List<Stock2Pick>();
        for (Stock2Pick a: stpAdded  )  {
            if (a.selected){
                a.selected = false;
                stpResult.add(a);
            }else{
                stpNewAdded.add(a);
            }
        } 
        stpAdded = stpNewAdded;

    }
    public void doFilter() {
       
        stpResult.clear();
        ID year = (Util.urlParameters.get('Catalog') == null || Util.urlParameters.get('Catalog') == 'Regular'?Util.currentYear.id:Util.lastYear.id);
        String condition = 'WHERE ProductCatalogRef__r.YearRef__c = \'' + year + '\' AND ProductCatalogRef__r.CountryRef__r.Name = \'South Africa\' ';
        
        if(filterName != null && filterName != '')
            condition += 'AND ProductRef__r.name LIKE \''+ filterName.replace('*','%') + '\' ';
        if(filter.ProductKernelSize__c != null)
            condition += 'AND ProductRef__r.ProductKernelSize__c LIKE \''+ filter.ProductKernelSize__c.replace('*','%') +'\' ';
        if(filter.ProductTreatment__c != null)
            condition += 'AND ProductRef__r.ProductTreatment__c = \''+ filter.ProductTreatment__c +'\' ';
        if(filter.ProductBagSize__c != null)
            condition += 'AND ProductRef__r.ProductBagSize__c = '+ filter.ProductBagSize__c +' ';
        if(filter.ProductMaturity__c != null)
            condition += 'AND ProductRef__r.ProductMaturity__c LIKE \'%'+ filter.ProductMaturity__c +'%\' ';
        if(filter.ProductPrmyPkType__c != null)
            condition += 'AND ProductRef__r.ProductPrmyPkType__c = \''+ filter.ProductPrmyPkType__c +'\' ';
        if(filter.ProductVendor__c != null)
            condition += 'AND ProductRef__r.ProductVendor__c = \''+ filter.ProductVendor__c +'\' ';
        if(filter.ProductBagWeight__c != null)
            condition += 'AND ProductRef__r.ProductBagWeight__c = '+ filter.ProductBagWeight__c;
      
//        condition += 'AND ProductRef__c NOT IN (SELECT ProductCatalogEntryRef_RSA__c FROM stock__c)';
//        List<Object> dbResultStock = Database.query('SELECT ProductCatalogEntryRef_RSA__c FROM stock__c');
        //new Map<ID,Object>(['SELECT ProductCatalogEntryRef_RSA__c FROM stock__c']).keySet(); 


//       String sql = 'Select Id, Name, ProductKernelSize__c, ProductTreatment__c, ProductBagSize__c, ProductMaturity__c, ProductPrmyPkType__c, ProductVendor__c, ProductBagWeight__c From Product2 ' + condition + ' LIMIT 50';
       String sql = 'Select ProductRef__r.ProductVendor__c, ProductRef__r.ProductTreatment__c, ProductRef__r.ProductPrmyPkType__c, ProductRef__r.ProductMaturity__c, ProductRef__r.ProductKernelSize__c, ProductRef__r.ProductBagWeight__c, ProductRef__r.ProductBagSize__c, ProductRef__r.Name, ProductRef__r.Id, ProductRef__c, ProductCatalogRef__r.YearRef__c, ProductCatalogRef__r.CountryRef__c, ProductCatalogRef__c From ProductCatalogEntry__c ' + condition + ' LIMIT 1000';
       List<ProductCatalogEntry__c> dbResult = Database.query(sql);
       Set<ID> pceAdded = new Set<ID>();
       for(Stock2Pick s2p : stpAdded){
           pceAdded.add(s2p.pce.id);
       }
       for(Stock__c s : [SELECT ProductCatalogEntryRef_RSA__c FROM Stock__c WHERE ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c = :year AND ProductCatalogEntryRef_RSA__c IN :new Map<ID,ProductCatalogEntry__c>(dbResult).keySet() ]){
           pceAdded.add(s.ProductCatalogEntryRef_RSA__c);
       }
       for(ProductCatalogEntry__c pce : dbResult){
           if(!pceAdded.contains(pce.id)){
              stpResult.add(new Stock2Pick(pce));
           }
       }

    }
    
  
    public PageReference doCancel() {
        PageReference returned = Page.Stock.setRedirect(true);
        if(Util.urlParameters.get('catalog') == null || Util.urlParameters.get('catalog') == 'Regular'){
            returned.getParameters().put('catalog','Regular');
        }else{
            returned.getParameters().put('catalog','Tax');
        }
        return returned;
    }
    
    
    public PageReference doSave() {

        List<User> users;        
        ID adminProfileID = '00eD0000001lv5N';
        if(UserInfo.getProfileId() == adminProfileID){
            users = [SELECT ID FROM User WHERE Is_Country_Manager__c = true AND CountryISOCode__c = 'RSA' ];
        }else{
            users = [SELECT ID FROM User WHERE ManagerID = :UserInfo.getUserId()];
        }
        
        List<Stock__c> stocksToInsert = new List<Stock__c>();

        for(Stock2Pick s2p : stpAdded){
            for(User u : users){
                stocksToInsert.add(new Stock__c(ProductCatalogEntryRef_RSA__c=s2p.pce.id, Allocation_RSA__c = 0,  TaxAllocation_RSA__c = 0, User_RSA__c = u.ID, Quantity_RSA__c = 0, TaxQuantity_RSA__c = 0));
            }
        }
        insert stocksToInsert;
        
        return doCancel();
    }
    public static testMethod void testStockPickerController(){
        StockPickerController controller = new StockPickerController();
        controller.doAddSelected();
        controller.doDeleteSelected();
        controller.doCancel();
        controller.doSave();
    }
}