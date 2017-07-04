@isTest
public class Test_ScheduledWhiteLabelsLines {
    
    // CRON expression: midnight on March 15.Because this is a test, job executes immediately after Test.stopTest().
   	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    public static Pricebook2 pb;
    public static PricebookEntry  customPrice;
    
    public static testMethod void ScheduledWhiteLabels()
    {
        //Inserting Country data
        Country__c country=new Country__c();
        country.Name='Spain';
        insert country;
        
        //Inserting account data
        Account account=new Account();
        account.Name='aasd';
        account.CountryRef__c=country.Id;
        insert account;
        
        //Inserting sales data
        Sales_Area__c sales=new Sales_Area__c();
        sales.Divison_Code__c='DIV5';
        sales.Sales_District_Code__c='SD1';
        sales.Sales_Org_Code__c='SO1';
        sales.GC_Account_Integration_Key__c=account.Id;
        
        insert sales;
        
        //Inserting Report Data
        Report lstReport = new Report();
        
        //Inserting Order data
        Order order=new Order();
        for(Integer i=1;i<=20;i++){
            order.AccountID=account.Id;
            order.Name='testing'+i;
            order.GC_Integration_Key__c='sdhjshjasd';
            order.Status='Draft';
            order.Divison_Code__c='DIV5';
            order.Sales_District_Code__c='SD1';
            order.Sales_Org_Code__c='SO1';
            order.EffectiveDate=date.newInstance(2014, 9, 15);
        }
        insert order;
        
        //Inserting Delivery data
        Delivery__c dev1=new Delivery__c();
        for(Integer i=1;i<=20;i++){
            dev1.Name='abc'+i;
            dev1.GC_Order_Number__c='sdgskjd';
            dev1.GC_Integration_Key__c='sdfhsjd';
            dev1.GC_Delivery_Number_Text__c='hdfjsd';
            dev1.GC_Account_Integration_Key__c=account.Id;
            dev1.Divison_Code__c='DIV5';
            dev1.Sales_District_Code__c='SD1';
            dev1.Sales_Org_Code__c='SO1';
        }
        insert dev1;
        
        //Inserting Invoice Data
        Invoice__c invoice1=new Invoice__c();
        for(Integer i=1;i<=20;i++){
            invoice1.ShipTo_Acc_Integration_Key__c=account.Id;
            invoice1.GC_Order_Number__c='Inv'+i;
            invoice1.GC_Integration_Key__c='sdjsk';
            invoice1.GC_Invoice_Number_Text__c='sadskj';
            invoice1.GC_Account_Integration_Key__c=account.Id;
            invoice1.Divison_Code__c='DIV5';
            invoice1.Sales_District_Code__c='SD1';
            invoice1.Sales_Org_Code__c='SO1';
        }
        insert invoice1;
        
        //Contract Data
        Contract cntract=new Contract();
        for(Integer i=1;i<=20;i++){
            cntract.Name='Cont'+i;
            cntract.ShipTo_Acc_Integration_Key__c=account.Id;
            cntract.GC_Integration_Key__c='jdfjdsfhhfcn';
            cntract.Contract_Order_Text__c='dfhduh';
            cntract.Status='Draft';
            cntract.Divison_Code__c='DIV5';
            cntract.Sales_District_Code__c='SD1';
            cntract.Sales_Org_Code__c='SO1';
            cntract.AccountId=account.Id;
        }
        insert cntract;
        
        //Insert product data in order to insert Related list lines
        recordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        recordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
         Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend; 
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;              
        Product2 prod = new Product2(Name = 'product1',ProductCode='SAPCode1', ProductSAPCode__c = 'SAPCode1',CHK_White_label_prods__c=True, DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, DE_BasicUnits__c = 20);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        pb = new Pricebook2(Name = 'test pb', PICK_Product_family__c = 'ROUNDUP', isActive = true, Integration_Key__c = 'TESTPB', CP_Account_Type__c = 'Distributor');
        insert pb;
        customPrice = new PricebookEntry(Pricebook2Id = pb.Id,Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert customPrice;
        
        
        
        //Insert Order line item
        OrderItem oi = new OrderItem();
        oi.OrderId = order.Id;
        oi.PricebookEntryId = standardPrice.id;
        oi.Quantity = 100;
        oi.GC_Delivered_Quantity__c = 100;
        oi.GC_Quantity__c = 100;
        oi.UnitPrice = 1;
        insert oi;
        
        //Insert Invoice line 
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Name = 'ILI0001';
        ili.GC_Invoice_Integration_Key__c = invoice1.Id;
        ili.GC_Quantity__c = 100;
        ili.GC_Integration_Key__c = 'KEY00001';
        ili.GC_Item_Code__c = 'SAPCode1';
        insert ili;
        
        //Insert Delivery Line
        Delivery_line_item__c dli=new Delivery_line_item__c();
        Dli.GC_Dlvry_Integration_Key__c = dev1.Id;
        Dli.GC_Delivered_Quantity__c = 100;
        Dli.GC_Integration_Key__c = 'KEY00001';
        Dli.GC_Item_Code__c = 'SAPCode1';
        insert Dli;
        
        //Insert Contract Line
        Contract_Line_Item__c Cli=new Contract_Line_Item__c();
        cli.GC_Contrct_Integration_Key__c = cntract.Id;
        cli.Order_Qty__c = 100;
        cli.GC_Integration_Key__c = 'KEY00001';
        cli.Material_Number_Text__c = 'SAPCode1';
        insert cli;
        
        //Test Batch
        
        
        Test.startTest();
        BatchWhiteLabelLines tBatch=new BatchWhiteLabelLines();
        Database.executeBatch(tBatch);
        Test.stopTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new ScheduledWhiteLabelsLines());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
    }
}