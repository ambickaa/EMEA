@isTest
public class Test_Batch_ORD_INV_toCampaignLineItem {
       
    public static testMethod void testORDBatch()
    {
        //Inserting data for batch test execution
        //Inserting Country data from Custom Label
        String strCountries = System.Label.Dist_AP_Countries;
        List<String> countryList = new List <String>();
        countryList = strCountries.split('\r\n');
        String strCountry = countryList.get(0);
        List<String> labelData = new List<String>();
        labelData = countryList.get(0).split('-');
        Country__c country = new Country__c(Name = labelData.get(0));
        String countrycode = labelData.get(1);
        String ownerID = labelData.get(2);
        //Gets country Italy
        insert country;

        //Inserting Division data from Custom Label
        String strDiv = System.Label.Dist_AP_Division;
        List<String> divList = new List <String>();
        divList = strDiv.split('\r\n');
        Division__c division = new Division__c(Name = divList.get(0));
        //Gets division Corn
        insert division;

        //Insert query data
        String query = 'SELECT Id, OwnerId FROM Account WHERE RecordType.Name = ' + '\'' + 'Dist./Ret./PoS' + '\'' + ' AND CountryRef__r.Name = ' + '\'' + string.valueof(country.Name) + '\'';

        //Recovering Document Type
        String strDoc = System.Label.Dist_AP_OrderDocType;
        List<String> docList = strDoc.split('\n');

        //Recovering UoM
        String strUoM = System.Label.Dist_AP_UoM;
        List<String> uomList = strUoM.split('\n');

        //Recovering current year and creating dates for campaigns
        //Date thisFY = Date.today();
        //Date pastFY = Date.newInstance((thisFY.year()-1), thisFY.month(), thisFY.day());
        List<String> datesList = (System.Label.Dist_AP_Dates).split(',');
        String iniCampaign = datesList.get(0);
        String endCampaign = datesList.get(1);

        Date iniCampaignDate = Date.parse(iniCampaign);
        Date endCampaignDate = Date.parse(endCampaign);

        Date iniCampaignPYDate = iniCampaignDate.addYears(-1);
        Date endCampaignPYDate = endCampaignDate.addYears(-1);
        
        Boolean IsLast=false;
        
        //Inserting account data
        //Distributor
        Account account=new Account(Name = 'aasd',CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        Account account3=new Account(Name = 'aasd3',CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        Account account4=new Account(Name = 'aasd4',CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        //Farm
        Account account2=new Account(Name = 'aasd2',CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:GroupFarmSite'));
        insert new List<Account>{account,account2,account3,account4};

        //Insert product data        
        Product2 prod = new Product2(Name = 'product1',ProductCode='SAPCode1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = division.Id, ProductVendor__c = '001D000000vG1zp', RecordTypeId = Util.recordType.get('Product2:CornSalesProduct'));
        Product2 prod2 = new Product2(Name = 'product2',ProductCode='SAPCode2', ProductSAPCode__c = 'SAPCode2', DivisionRef__c = division.Id, ProductVendor__c = '001D000000vG1zp', RecordTypeId = Util.recordType.get('Product2:CornSalesProduct'));
        Product2 prod3 = new Product2(Name = 'product3',ProductCode='SAPCode3', ProductSAPCode__c = 'SAPCode3', DivisionRef__c = division.Id, ProductVendor__c = '001D000000vG1zp', RecordTypeId = Util.recordType.get('Product2:CornSalesProduct'));
        insert new List<Product2>{prod,prod2,prod3};

        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1, IsActive = true, GC_Integration_Key__c='ACS/SAP00001');
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 1, IsActive = true, GC_Integration_Key__c='ACS/SAP00002');
        insert new List<PricebookEntry>{standardPrice,standardPrice2};
       
        //Inserting Order data
        //Current FY Order
        Order order1 = new Order();
            order1.AccountID=account.Id;
            order1.ShipTo_Acc_Integration_Key__c = account.Id;
            order1.Status='Draft';
            order1.Divison_Code__c='17';
            order1.Sales_District_Code__c='SD1';
            order1.Sales_Org_Code__c=countrycode;
            order1.GC_Doc_Creation_Date__c = Date.parse(iniCampaign);
            order1.GC_Integration_Key__c='SAP00001';
            order1.GC_Document_Type_Descr__c = docList.get(0);
            order1.EffectiveDate = Date.parse(iniCampaign)-1;

        Order order1b = new Order();
            order1b.AccountID=account.Id;
            order1b.ShipTo_Acc_Integration_Key__c = account3.Id;
            order1b.Status='Draft';
            order1b.Divison_Code__c='17';
            order1b.Sales_District_Code__c='SD1';
            order1b.Sales_Org_Code__c=countrycode;
            order1b.GC_Doc_Creation_Date__c = Date.parse(iniCampaign);
            order1b.GC_Integration_Key__c='SAP00002';
            order1b.GC_Document_Type_Descr__c = docList.get(0);
            order1b.EffectiveDate = Date.parse(iniCampaign)-1;

        Order order1c = new Order();
            order1c.AccountID=account2.Id;
            order1c.ShipTo_Acc_Integration_Key__c = account3.Id;
            order1c.Status='Draft';
            order1c.Divison_Code__c='17';
            order1c.Sales_District_Code__c='SD1';
            order1c.Sales_Org_Code__c=countrycode;
            order1c.GC_Doc_Creation_Date__c = Date.parse(iniCampaign);
            order1c.GC_Integration_Key__c='SAP00005';
            order1c.GC_Document_Type_Descr__c = docList.get(0);
            order1c.EffectiveDate = Date.parse(iniCampaign)-1;

        //Last FY Order
        Order order2 = new Order();
            order2.AccountID=account.Id;
            order2.ShipTo_Acc_Integration_Key__c = account.Id;
            order2.Status='Draft';
            order2.Divison_Code__c='17';
            order2.Sales_District_Code__c='SD1';
            order2.Sales_Org_Code__c=countrycode;
            order2.GC_Doc_Creation_Date__c = Date.parse(endCampaign);
            order2.GC_Integration_Key__c='SAP00003';
            order2.GC_Document_Type_Descr__c = docList.get(0);
            order2.EffectiveDate = Date.parse(endCampaign)-1;

        Order order2b = new Order();
            order2b.AccountID=account.Id;
            order2b.ShipTo_Acc_Integration_Key__c = account3.Id;
            order2b.Status='Draft';
            order2b.Divison_Code__c='17';
            order2b.Sales_District_Code__c='SD1';
            order2b.Sales_Org_Code__c=countrycode;
            order2b.GC_Doc_Creation_Date__c = Date.parse(endCampaign);
            order2b.GC_Integration_Key__c='SAP00004';
            order2b.GC_Document_Type_Descr__c = docList.get(0);
            order2b.EffectiveDate = Date.parse(endCampaign)-1;

        Order order3 = new Order();
            order3.AccountID=account.Id;
            order3.ShipTo_Acc_Integration_Key__c = account3.Id;
            order3.Status='Draft';
            order3.Divison_Code__c='17';
            order3.Sales_District_Code__c='SD1';
            order3.Sales_Org_Code__c=countrycode;
            order3.GC_Doc_Creation_Date__c = iniCampaignPYDate;
            order3.GC_Integration_Key__c='SAP00006';
            order3.GC_Document_Type_Descr__c = docList.get(0);
            order3.EffectiveDate = iniCampaignPYDate.addYears(-1);

        system.debug('Order3 creation date: ' + order3.GC_Doc_Creation_Date__c);

        insert new List<Order>{order1,order1b,order1c,order2,order2b,order3};
        //Inserting Invoice Data
        Invoice__c invoice1=new Invoice__c();
            invoice1.Name = 'Invoice1';
            invoice1.ShipTo_Acc_Integration_Key__c=account.Id;
            invoice1.GC_Order_Number__c='SAP00001';
            invoice1.GC_Integration_Key__c='sdjsk';
            invoice1.GC_Invoice_Number_Text__c='sadskj';
            invoice1.GC_Invoice_Creation_Date__c = Date.parse(iniCampaign);
            invoice1.GC_Account_Integration_Key__c=account.Id;
            invoice1.Divison_Code__c='17';
            invoice1.Sales_District_Code__c='SD1';
            invoice1.Sales_Org_Code__c=countrycode;

        Invoice__c invoice2=new Invoice__c();
            invoice2.Name = 'Invoice2';
            invoice2.ShipTo_Acc_Integration_Key__c=account3.Id;
            invoice2.GC_Order_Number__c='SAP00002';
            invoice2.GC_Integration_Key__c='sdjsk2';
            invoice2.GC_Invoice_Number_Text__c='sadskj2';
            invoice2.GC_Invoice_Creation_Date__c = Date.parse(iniCampaign);
            invoice2.GC_Account_Integration_Key__c=account.Id;
            invoice2.Divison_Code__c='17';
            invoice2.Sales_District_Code__c='SD1';
            invoice2.Sales_Org_Code__c=countrycode;

        Invoice__c invoice3=new Invoice__c();
            invoice3.Name = 'Invoice3';
            invoice3.ShipTo_Acc_Integration_Key__c=account3.Id;
            invoice3.GC_Order_Number__c='SAP00005';
            invoice3.GC_Integration_Key__c='sdjsk3';
            invoice3.GC_Invoice_Number_Text__c='sadskj3';
            invoice3.GC_Invoice_Creation_Date__c = Date.parse(iniCampaign);
            invoice3.GC_Account_Integration_Key__c=account2.Id;
            invoice3.Divison_Code__c='17';
            invoice3.Sales_District_Code__c='SD1';
            invoice3.Sales_Org_Code__c=countrycode;

        Invoice__c invoice4=new Invoice__c();
            invoice4.Name = 'Invoice4';
            invoice4.ShipTo_Acc_Integration_Key__c=account3.Id;
            invoice4.GC_Order_Number__c='SAP00003';
            invoice4.GC_Integration_Key__c='sdjsk4';
            invoice4.GC_Invoice_Number_Text__c='sadskj4';
            invoice4.GC_Invoice_Creation_Date__c = iniCampaignPYDate;
            invoice4.GC_Account_Integration_Key__c=account4.Id;
            invoice4.Divison_Code__c='17';
            invoice4.Sales_District_Code__c='SD1';
            invoice4.Sales_Org_Code__c=countrycode;
            invoice4.GC_Invoice_Type_Descr__c = 'Cancellation of Inv';

        Invoice__c invoice5=new Invoice__c();
            invoice5.Name = 'Invoice5';
            invoice5.ShipTo_Acc_Integration_Key__c=account4.Id;
            invoice5.GC_Order_Number__c='SAP00004';
            invoice5.GC_Integration_Key__c='sdjsk5';
            invoice5.GC_Invoice_Number_Text__c='sadskj5';
            invoice5.GC_Invoice_Creation_Date__c = iniCampaignDate;
            invoice5.GC_Account_Integration_Key__c=account4.Id;
            invoice5.Divison_Code__c='17';
            invoice5.Sales_District_Code__c='SD1';
            invoice5.Sales_Org_Code__c=countrycode;
            invoice5.GC_Invoice_Type_Descr__c = 'Cancellation of Inv';
        insert new List<Invoice__c>{invoice1,invoice2,invoice3,invoice4,invoice5};

        //Inserting OrderItems
        //Insert Order line item
        //Current FY
        OrderItem oi = new OrderItem();
        oi.OrderId = order1.Id;
        oi.PricebookEntryId = standardPrice.id;
        oi.Quantity = 100;
        oi.GC_Delivered_Quantity__c = 100;
        oi.GC_Quantity__c = 100;
        oi.UnitPrice = 1;
        oi.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oib = new OrderItem();
        oib.OrderId = order1b.Id;
        oib.PricebookEntryId = standardPrice2.id;
        oib.Quantity = 100;
        oib.GC_Delivered_Quantity__c = 100;
        oib.GC_Quantity__c = 100;
        oib.UnitPrice = 1;
        oib.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oic = new OrderItem();
        oic.OrderId = order1b.Id;
        oic.PricebookEntryId = standardPrice.id;
        oic.Quantity = 90;
        oic.GC_Delivered_Quantity__c = 90;
        oic.GC_Quantity__c = 90;
        oic.UnitPrice = 1;
        oic.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oid = new OrderItem();
        oid.OrderId = order1c.Id;
        oid.PricebookEntryId = standardPrice.id;
        oid.Quantity = 60;
        oid.GC_Delivered_Quantity__c = 60;
        oid.GC_Quantity__c = 60;
        oid.UnitPrice = 1;
        oid.GC_Sales_UoM_Text__c = uomList.get(0);

        //Last FY
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = order2.Id;
        oi2.PricebookEntryId = standardPrice.id;
        oi2.Quantity = 100;
        oi2.GC_Delivered_Quantity__c = 100;
        oi2.GC_Quantity__c = 100;
        oi2.UnitPrice = 1;
        oi2.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oi2b = new OrderItem();
        oi2b.OrderId = order2b.Id;
        oi2b.PricebookEntryId = standardPrice.id;
        oi2b.Quantity = 50;
        oi2b.GC_Delivered_Quantity__c = 50;
        oi2b.GC_Quantity__c = 50;
        oi2b.UnitPrice = 1;
        oi2b.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oi2c = new OrderItem();
        oi2c.OrderId = order2b.Id;
        oi2c.PricebookEntryId = standardPrice.id;
        oi2c.Quantity = 50;
        oi2c.GC_Delivered_Quantity__c = 50;
        oi2c.GC_Quantity__c = 50;
        oi2c.UnitPrice = 1;
        oi2c.GC_Sales_UoM_Text__c = uomList.get(0);

        OrderItem oi3 = new OrderItem();
        oi3.OrderId = order3.Id;
        oi3.PricebookEntryId = standardPrice.id;
        oi3.Quantity = 50;
        oi3.GC_Delivered_Quantity__c = 50;
        oi3.GC_Quantity__c = 50;
        oi3.UnitPrice = 1;
        oi3.GC_Sales_UoM_Text__c = uomList.get(0);
        insert new List<OrderItem>{oi,oib,oic,oid,oi2,oi2b,oi2c,oi3};
        
        //Inserting Invoice Line Items
        //Insert Invoice line 
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Name = 'ILI0001';
        ili.GC_Invoice_Integration_Key__c = invoice1.Id;
        ili.GC_Quantity__c = 100;
        ili.GC_Integration_Key__c = 'KEY00001';
        ili.GC_Item_Code__c = 'SAPCode1';
        ili.GC_Item_Descr__c = 'description';
        ili.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ilib = new Invoice_Line_Item__c();
        ilib.Name = 'ILI0001';
        ilib.GC_Invoice_Integration_Key__c = invoice1.Id;
        ilib.GC_Quantity__c = 70;
        ilib.GC_Integration_Key__c = 'KEY00001b';
        ilib.GC_Item_Code__c = 'SAPCode2';
        ilib.GC_Item_Descr__c = 'descriptionb';
        ilib.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
        ili2.Name = 'ILI0002';
        ili2.GC_Invoice_Integration_Key__c = invoice2.Id;
        ili2.GC_Quantity__c = 50;
        ili2.GC_Integration_Key__c = 'KEY00002';
        ili2.GC_Item_Code__c = 'SAPCode1';
        ili2.GC_Item_Descr__c = 'description2';
        ili2.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili2b = new Invoice_Line_Item__c();
        ili2b.Name = 'ILI0002b';
        ili2b.GC_Invoice_Integration_Key__c = invoice2.Id;
        ili2b.GC_Quantity__c = 50;
        ili2b.GC_Integration_Key__c = 'KEY00002b';
        ili2b.GC_Item_Code__c = 'SAPCode2';
        ili2b.GC_Item_Descr__c = 'description2b';
        ili2b.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili3 = new Invoice_Line_Item__c();
        ili3.Name = 'ILI0003';
        ili3.GC_Invoice_Integration_Key__c = invoice3.Id;
        ili3.GC_Quantity__c = 80;
        ili3.GC_Integration_Key__c = 'KEY00003';
        ili3.GC_Item_Code__c = 'SAPCode1';
        ili3.GC_Item_Descr__c = 'description1';
        ili3.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili3b = new Invoice_Line_Item__c();
        ili3b.Name = 'ILI0003b';
        ili3b.GC_Invoice_Integration_Key__c = invoice3.Id;
        ili3b.GC_Quantity__c = 80;
        ili3b.GC_Integration_Key__c = 'KEY00003b';
        ili3b.GC_Item_Code__c = 'SAPCode1';
        ili3b.GC_Item_Descr__c = 'description3b';
        ili3b.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili3c = new Invoice_Line_Item__c();
        ili3c.Name = 'ILI0003c';
        ili3c.GC_Invoice_Integration_Key__c = invoice3.Id;
        ili3c.GC_Quantity__c = 60;
        ili3c.GC_Integration_Key__c = 'KEY00003c';
        ili3c.GC_Item_Code__c = 'SAPCode3';
        ili3c.GC_Item_Descr__c = 'description3c';
        ili3c.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili4 = new Invoice_Line_Item__c();
        ili4.Name = 'ILI0004';
        ili4.GC_Invoice_Integration_Key__c = invoice4.Id;
        ili4.GC_Quantity__c = 60;
        ili4.GC_Integration_Key__c = 'KEY00004';
        ili4.GC_Item_Code__c = 'SAPCode4';
        ili4.GC_Item_Descr__c = 'description4';
        ili4.GC_UOM_Line_Item_Descr__c = uomList.get(0);

        Invoice_Line_Item__c ili5 = new Invoice_Line_Item__c();
        ili5.Name = 'ILI0005';
        ili5.GC_Invoice_Integration_Key__c = invoice5.Id;
        ili5.GC_Quantity__c = 60;
        ili5.GC_Integration_Key__c = 'KEY00005';
        ili5.GC_Item_Code__c = 'SAPCode5';
        ili5.GC_Item_Descr__c = 'description5';
        ili5.GC_UOM_Line_Item_Descr__c = uomList.get(0);
        insert new List<Invoice_Line_Item__c>{ili5,ili4,ili3c,ili3b,ili3,ili2b,ili2,ilib,ili};

        //Campaign and Product Catalog creation
        ProductCatalog__c testPCM = new ProductCatalog__c(Name = 'Corn');
        insert testPCM;

        id campRecordTypeId=[Select id,Name from RecordType where SobjectType='Campaign' and Name='Sales Campaign' limit 1].id;
        Campaign newCamp = new Campaign (Name = 'testCamp', OwnerId = ownerId, StartDate = Date.parse(iniCampaign), EndDate = Date.parse(iniCampaign)+1, StatusCode__c = 200, isActive = true, RecordTypeId = campRecordTypeId, CountryRef__c = country.Id, DivisionRef__c = division.Id, SalesPCMRef__c = testPCM.Id);
        insert newCamp;

        //PCEs for CLI creation
        ProductCatalogEntry__c pce = new ProductCatalogEntry__c(ProductRef__c = prod.Id, ProductCatalogRef__c = testPCM.Id, Allocation__c=200);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductRef__c = prod2.Id, ProductCatalogRef__c = testPCM.Id);
        insert new List<ProductCatalogEntry__c>{pce,pce2};

        //CLIs for Dist Accounts
        id RecordTypeId=[Select id,Name from RecordType where SobjectType='CampaignLineItem__c' and Name='Sales' limit 1].id;
        CampaignLineItem__c cli1 = new CampaignLineItem__c(OwnerId = ownerId, CampaignRef__c = newCamp.Id, RecordTypeId = RecordTypeId, FarmRef__c = account.Id, ProductCatalogEntryRef__c = pce.Id, ProductRef__c = prod.Id, Type__c = 'Charged', Status__c = 'Forecast', agreed__c=20);
        insert cli1;

        //Test Batch
        //Run batch test
        Test.startTest();
        Id batchTest = Database.executeBatch (new Batch_ORD_INV_toCampaignLineItem(query,country.Name,uomList,docList,strDiv,countrycode,ownerID,iniCampaign,endCampaign, IsLast),1000);
        Test.stopTest();

    }
}