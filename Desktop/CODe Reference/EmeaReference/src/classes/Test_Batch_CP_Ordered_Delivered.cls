@isTest
private class Test_Batch_CP_Ordered_Delivered {
	
	public static Account acc;
	public static Product2 prod;
	public static OrderItem oi, oi2;
	public static Invoice_Line_Item__c ili, ili2;
	
	private static void Test_Ini()
	{
		User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
      
        acc = new Account(Name = 'Test Account', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', RecordTypeId = Util.recordType.get('Account:DistRetPoS'), 
                            GC_Integration_Key__c='0001009661', GC_Cust_Account_Grp_Descr__c = 'Sold-to party');

        Account vend = new Account(Name = 'Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        insert new List<Account>{acc,vend};
        
        Division__c d = new Division__c(Name = 'CP');
        insert d;       
        
        prod = new Product2(isActive=true, Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, RecordTypeId = Util.recordType.get('Product2:CPSalesProduct'), DE_BasicUnits__c = 20, ProductPrmyPkContent__c = '20KG');
        insert prod;
                        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), gc_integration_key__c='ACS/SAP00001', Product2Id = prod.Id, UnitPrice = 0, IsActive = true);
        insert standardPrice;             

        Order o = new Order(AccountId = acc.Id, GC_Integration_Key__c = 'SAP00001', GC_Document_Type_Descr__c ='Ag-Eu Credit for Qty', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '15', GC_Requested_Delivery_Date__c = date.newInstance(System.today().year()-1, 11, System.today().Day()));

        Order o2 = new Order(AccountId = acc.Id, GC_Integration_Key__c = 'SAP00002', GC_Document_Type_Descr__c ='Ag-Eu Standard Order', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '15', GC_Requested_Delivery_Date__c = date.newInstance(System.today().year(), 9, System.today().Day()));
        insert new List<Order>{o,o2};
        
        oi = new OrderItem();
        oi.OrderId = o.Id;
        oi.PricebookEntryId = standardPrice.id;
        oi.Quantity = 100;
        oi.GC_Delivered_Quantity__c = 100;
        oi.GC_Quantity__c = 100;
        oi.UnitPrice = 1;

        oi2 = new OrderItem();
        oi2.OrderId = o2.Id;
        oi2.PricebookEntryId = standardPrice.id;
        oi2.Quantity = 200;
        oi2.GC_Delivered_Quantity__c = 200;
        oi2.GC_Quantity__c = 200;
        oi2.UnitPrice = 1;
        insert new List<OrderItem>{oi,oi2};
        
        Invoice__c inv = new Invoice__c();
        inv.Name = 'INV00001';
        inv.GC_Account_Integration_Key__c = acc.Id;
        inv.GC_Order_Number__c = 'SAP00001';
        inv.GC_Integration_Key__c = 'KEY00001';
        inv.GC_Invoice_Creation_Date__c = System.today();
        inv.Divison_Code__c = '15';
        inv.GC_Invoice_Type_Descr__c = 'Credit Memo';
        
        Invoice__c inv2 = new Invoice__c();
        inv2.Name = 'INV00002';
        inv2.GC_Account_Integration_Key__c = acc.Id;
        inv2.GC_Order_Number__c = 'SAP00002';
        inv2.GC_Integration_Key__c = 'KEY00002';
        inv2.GC_Invoice_Creation_Date__c = System.today();
        inv2.Divison_Code__c = '15';
        inv2.GC_Invoice_Type_Descr__c = 'Invoice';
        insert new List<Invoice__c>{inv,inv2};

        ili = new Invoice_Line_Item__c();
        ili.Name = 'ILI0001';
        ili.GC_Invoice_Integration_Key__c = inv.Id;
        ili.GC_Quantity__c = 100;
        ili.GC_Integration_Key__c = 'KEY00001';
        ili.GC_Item_Code__c = 'SAPCode1';
        
        ili2 = new Invoice_Line_Item__c();
        ili2.Name = 'ILI0002';
        ili2.GC_Invoice_Integration_Key__c = inv2.Id;
        ili2.GC_Quantity__c = 300;
        ili2.GC_Integration_Key__c = 'KEY00002';
        ili2.GC_Item_Code__c = 'SAPCode1';
		ili2.GC_UOM_Line_Item_Descr__c = 'BT';
        insert new List<Invoice_Line_Item__c>{ili,ili2};
	}

	@isTest
	static void testingBatch()
    {
    	Test_Ini();
        Test.startTest();

        List<String> listAccounts = Label.Batch_CP_Acc_NoStd.split('\r\n');
        List<String> listDTstd = Label.Batch_CP_DocType_Std.split('\r\n');
        List<String> listDT = Label.Batch_CP_DocType_NoStd.split('\r\n');
        
        String query = 'SELECT Id FROM account WHERE ';
        query+='Id IN (SELECT AccountId FROM Order WHERE Divison_Code__c =\'15\'';
        query+=' AND (GC_Document_Type_Descr__c IN :listDTstd';
        query+=' OR (GC_Document_Type_Descr__c IN :listDT';     
        query+=' AND Account.GC_Integration_Key__c IN :listAccounts';       
        query+=')))';
        
        String jobIdBatch = Database.executeBatch(new Batch_CP_ordered_Delivered(query, 24), 10);

        Test.stopTest();      
    }

	@isTest
	static void testingSchedule()
    {
    	Test_Ini();
        Test.startTest();
        
        // Launch batch with scheduler       
        // CRON expression: midnight on March 15.
        // Because this is a test, job executes immediately after Test.stopTest()
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobIdSchedule = System.schedule('ScheduleApexClassTest', CRON_EXP, new Scheduled_Batch_CP_ordered_Delivered()); 
        

        list<Action_Plan_Line__c> listAPL = [SELECT Id, Num_delivered__c, LKP_Account__c, LKP_SKU__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c != null];
        
        for(Action_Plan_Line__c apl : listAPL)
        {
            System.AssertEquals(apl.LKP_Account__c, acc.Id);
            System.AssertEquals(apl.LKP_SKU__c, prod.Id);
            System.AssertEquals(apl.NUM_Ordered__c, oi.GC_Quantity__c + oi2.GC_Quantity__c);
            System.AssertEquals(apl.NUM_Delivered__c, ili.GC_Quantity__c + ili2.GC_Quantity__c);
        }

        Test.stopTest();      
    }
}