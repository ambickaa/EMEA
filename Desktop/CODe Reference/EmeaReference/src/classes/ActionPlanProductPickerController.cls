public with sharing class ActionPlanProductPickerController
{
    public ProductPicker picker {get; set;}
    public String mode {get; set;}
    public String backURL {get; set;}
    public List<Product2x> productsSelected {get; set;}
    public List<Product2x> listProduct2x {get; set;}
    public String searchProduct {get; set;}
    public String searchSAPCode {get; set;}
    private List<Product2> listProducts;
    private List<Id> listIdProducts = new List<Id>();
    private List<Id> listIdProductsSelected;
    private List<ID> listaCatalogosFiltrada = new List <ID>();
    
    public static List<Product2> listProductsAdded {get; set;}
    
    //Instantiate the StandardSetController  
    public ApexPages.StandardSetController con {get; set;}
    
    //Constructor with standard controller.
    public ActionPlanProductPickerController()
    {
        listIdProductsSelected = new List<Id>();
        listProduct2x = new List<Product2x>();
        productsSelected = new List<Product2x>();

        loadProducts();
        mode = Util.urlParameters.get('mode');
    }
    
    public void loadProducts()
    {
       // mode = 'view';
       List<ID> listaCatalogosId = new List <ID>();      
              
       //Construct list products
       String param = ApexPages.currentPage().getParameters().get('catalogs');       
       listaCatalogosFiltrada = param.split('-');
       
                                                      
       con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name, DivisionRef__c, ProductVendor__c, ProductSAPCode__c, Description, ProductMONNr__c, 
                                                                ProductChemPrimPkgCont__c, ProductChemOuterCrtPal__c, ProductChemPrimPkgOutcrt__c, ProductChemOther__c, ProductChemPrimPkgType__c 
                                                                FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) order by name]));
       
       con.setPageSize(10);
    }
    
    public List<Product2x> allProducts
    {
        get
        {
            if(con != null)
            {
                listproducts = (List<Product2>)con.getRecords();
                listProduct2x.clear();
        
                for(Product2 p : listproducts)
                {
                    listProduct2x.add(new Product2x(p));
                }
                return listProduct2x;
            }
            else return null;
        }
        set;
    }
    
    public PageReference doCancel()
    {
        PageReference p = new PageReference('/' + Util.currentAccount.Id);
        return p;
    }
    
    public void selectProducts()
    {
        for(Product2x px : listProduct2x)
        {
            if(px.checked)
            {
                px.checked = false;
                productsSelected.add(px);
                listIdProductsSelected.add(px.Id);
            }
        }
        //Print possible Products
        listProduct2x.clear();        
        loadProducts();
    }
    
    public void deselected()
    {
        List<Integer> listIndex = new List<Integer>();
        listIdProductsSelected.clear();
        
        for(Integer i = productsSelected.size() - 1; i >= 0; i --)
        {
            if(productsSelected[i].checked)
            {
                productsSelected[i].checked = false;
                listIndex.add(i);
            }
            else listIdProductsSelected.add(productsSelected[i].Id);
        }
        
        for(Integer j : listIndex)
        {
            productsSelected.remove(j);
        }
        //Print possible Products
        listProduct2x.clear();
        loadProducts();        
    }
    
    public PageReference addProducts()
    {        
        mode = 'edit';
        List<Action_Plan_Line__c> multiActionPlanLines = new List<Action_Plan_Line__c>();
        String listProducts = '';
        for(Product2x p : productsSelected)
        {
            listProducts+=String.valueOf(p.Id)+'-';            
        }
        //insert multiActionPlanLines;
        PageReference p = new PageReference('/' + Util.currentAccount.Id + '?mode=' + mode + '&products=' + listProducts);
        return p;
    }
    
    public void doFilter()
    {
        if(searchProduct.length() > 0 && searchSAPCode.length() == 0)
        {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name, DivisionRef__c, ProductVendor__c, ProductSAPCode__c, Description, ProductMONNr__c, 
                                                            ProductChemPrimPkgCont__c, ProductChemOuterCrtPal__c, ProductChemPrimPkgOutcrt__c, ProductChemOther__c, ProductChemPrimPkgType__c 
                                                            FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) AND Name LIKE :'%'+searchProduct+'%' order by name]));                                               
        }
        else if(searchProduct.length() == 0 && searchSAPCode.length() > 0)
        {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name, DivisionRef__c, ProductVendor__c, ProductSAPCode__c, Description, ProductMONNr__c, 
                                                            ProductChemPrimPkgCont__c, ProductChemOuterCrtPal__c, ProductChemPrimPkgOutcrt__c, ProductChemOther__c, ProductChemPrimPkgType__c 
                                                            FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) AND ProductSAPCode__c LIKE :'%'+searchSAPCode+'%' order by name]));                                               
        }
        else if (searchProduct.length() > 0 && searchSAPCode.length() > 0)
        {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name, DivisionRef__c, ProductVendor__c, ProductSAPCode__c, Description, ProductMONNr__c, 
                                                            ProductChemPrimPkgCont__c, ProductChemOuterCrtPal__c, ProductChemPrimPkgOutcrt__c, ProductChemOther__c, ProductChemPrimPkgType__c 
                                                            FROM Product2 WHERE Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) AND ProductSAPCode__c LIKE :'%'+searchSAPCode+'%' AND Name LIKE :'%'+searchProduct+'%' order by name]));                                               
        }
        else loadProducts();

    }
    
    //Boolean to check if there are more records before the present displaying records  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return con.getHasPrevious();  
        }  
        set;  
    }
    
    //Returns the previous page of records  
    public void previous()  
    {  
        con.previous();  
    }
    
    //Boolean to check if there are more records after the present displaying records  
    public Boolean hasNext  
    {  
        get  
        {  
            return con.getHasNext();  
        }  
        set;  
    }
    
    //Returns the next page of records  
    public void next()  
    {  
        con.next();  
    }
    
    //Page number of the current displaying records  
    public Integer pageNumber  
    {  
        get  
        {  
            return con.getPageNumber();  
        }  
        set;  
    }
    
    public FieldSetMemberxManager resultFieldSet
    {
        get
        {
            if(resultFieldSet == null)
            {
                if(Util.currentLookupMode == 'Sales')
                {
                    try
                    {
                        resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult'+Util.currentDivision.name, '');
                    }catch(Exception e)
                    {
                        resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', Util.currentDivision.name);
                    }                    
                }
                else
                {
                    resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', '');
                }
            }
            return resultFieldSet;
        }
        set;
    }
}