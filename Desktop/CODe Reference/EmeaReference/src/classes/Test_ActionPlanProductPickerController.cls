@isTest
private class Test_ActionPlanProductPickerController
{
    public static RecordType accountRecordType, productRecordType;
    public static List<Product2x> listProductx, productsSelectedTest;
    public static List<Product2> listProduct;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
    }
    
    static testMethod void myUnitTest()
    {
    init();
        Test.startTest();
        
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
          
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;        
        
        Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'product2', ProductSAPCode__c = 'SAPCode2', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod2;
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 catalog = new Pricebook2 (Name = 'Catalog', CP_Account_Type__c = 'Distributor', DivisionRef__c = d.Id, isActive = true, Integration_Key__c = 'Test');
        insert catalog;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        PageReference pageRef= Page.AccountProductPicker;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', acc.id);
        pageRef.getParameters().put('catalogs',pricebookId);
        pageRef.getParameters().put('mode','view');
        
        ActionPlanProductPickerController controller =new ActionPlanProductPickerController();
        
        controller.loadProducts();        
        controller.doCancel();
        
        //SELECTPRODUCTS
        listProductx = controller.allProducts;
        System.assertEquals(listProductx.size(),2);
        productsSelectedTest= new List<Product2x>();
        if(listProductx!=null)
        {
            for(Product2x px : listProductx)
            {
                if (px.checked == false)
                {
                    px.checked = true;
                    productsSelectedTest.add(px);
                }
            }
        }
        controller.listProduct2x = productsSelectedTest;
        
        controller.selectProducts();
        System.assertEquals(controller.productsSelected.size(),2);
        
        
        //DESELECTED
        listProductx = controller.allProducts;
        productsSelectedTest= new List<Product2x>();
        if(listProductx!=null)
        {
            for(Product2x px : listProductx)
            {
                if (px.checked == false)
                {
                    px.checked = true;
                    productsSelectedTest.add(px);
                }
            }
        }
        controller.productsSelected= productsSelectedTest;
        System.assertEquals(controller.productsSelected.size(),2);        
        controller.deselected();
        System.assertEquals(controller.productsSelected.size(),0);
        
        //ADDPRODUCTS
        listProductx = controller.allProducts;
        productsSelectedTest= new List<Product2x>();
        if(listProductx!=null)
        {
            for(Product2x px : listProductx)
            {
                if (px.checked == false)
                {
                    px.checked = true;
                    productsSelectedTest.add(px);
                }
            }
        }
        
        controller.productsSelected = productsSelectedTest;
        controller.addProducts();
        
        controller.searchProduct = prod.id;
        controller.searchSAPCode = prod.ProductSAPCode__c;
        controller.doFilter();
        
        controller.searchProduct = '';
        controller.searchSAPCode = prod.ProductSAPCode__c;
        controller.doFilter();
        
        controller.searchProduct = prod.id;
        controller.searchSAPCode = '';
        controller.doFilter();
        
        controller.searchProduct = '';
        controller.searchSAPCode = '';
        controller.doFilter();
        
        boolean b = controller.hasPrevious;
        System.assertEquals(b,false);
        b = controller.hasNext;
        System.assertEquals(b,false);
        integer i = controller.pagenumber;
        System.assertEquals(i,1);
        
        controller.previous();
        controller.next();
        
        //RESULTFIELDSET
        
        pageRef.getParameters().put('mode','trailEdit');
        //pageRef.getParameters().put('division',d.name);
        //Util.currentLookupMode= 'Sales';
        //Util.currentDivision.name = 'CP';
        FieldSetMemberxManager TestSet2 = controller.resultFieldSet;
        
        //Util.currentLookupMode = 'Marketing';
        //FieldSetMemberxManager TestSet = controller.resultFieldSet;
        
        
        //Other secondary methods
        
        ProductPicker pick = controller.picker;
        String URL = controller.backURL;
        
        Test.stopTest();
    
    }
}