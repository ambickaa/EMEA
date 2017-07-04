@isTest(seeAllData=true)
public class Test_ExportOrderData {

    @isTest static void Test1(){
        /*----------- Test Data Creation----------------------*/

        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User cUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00', Username='testUser1324@test.com', LastName='test', country='France', Email='test@test.com', Alias='TEST', CommunityNickname='comm', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1]; 
        RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' limit 1];
        system.runAs(cUser){

            Country__C counT=new Country__C(name='TestCountry');
            insert counT;
    
            Account testAccount1=new Account(RecordType=rt,GC_SAP_ID__c='7654321',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount2=new Account(RecordType=rt,GC_SAP_ID__c='7654322',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', RecordType=rt);
            insert new List<Account> {testAccount1,testAccount2,vend};
            
            Sales_Area__c area=new Sales_Area__c(name='ES01/00/15');
            insert Area;
        
            Partner_Function__c testShipTo2=new Partner_Function__c(TXT_Partners_Ids__c='111222333',country_name__c='France',Partner_function_descr__c='WE/Ship-to Party',Partner_Function_Code__c='WE',Relation_Type_Descr__c='Ship-to Party',name='testShipTo',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='123456789');
        
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
    
    
            insert testShipTo2;      
            Opportunity o= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00000',  StageName='FOC ORDER', CloseDate=Date.newInstance(2024, 2, 17));
            
            Opportunity o2= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00002',CHK_FullTruckDiscount__c=True,  StageName='FOC ORDER', CloseDate=Date.newInstance(2024, 2, 17));
            insert new List<Opportunity>{o,o2};
            
            RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
            Division__c d = new Division__c(Name = 'CP');
            insert d;        
            
            Product2 prod = new Product2(Name = 'product1', Family='CP', ProductCartonPerPallet__c=17, DE_BasicUnits__c=10, ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            pricebook2 pStandard=[select id from pricebook2 where id=:pricebookId ];
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true,Integration_Key__c='testKey');  /* CountryRef__c.Name='Spain', DivisionRef__r.name='CP'*/
            insert customPB;
            if(SystemSettings__c.getInstance('Pricebook_'+cUser.country+'_'+cUser.TXT_Division__c)==null )
            {
                SystemSettings__c setPriceBook=new SystemSettings__c(name='Pricebook_'+cUser.country+'_'+cUser.TXT_Division__c,value__c=customPb.Id);
                insert setPriceBook;
            }                
            // 2. Insert a price book entry with a custom price.
            o.Pricebook2Id=customPB.id;
            update o;
            opportunity op1=[select pricebook2.name from opportunity where id=:o.id];
            system.debug('El pricebook asignado es: '+ op1.pricebook2.name );
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = o.Pricebook2Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
            insert customPrice;

            OpportunityLineItem item =new OpportunityLineItem(PricebookEntryId = customPrice.Id, OpportunityId=o.Id, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', NUM_Quantity_litres_CP__c=24,Type__c='Free of Charge' );        
            OpportunityLineItem item2 =new OpportunityLineItem(PricebookEntryId = customPrice.Id, OpportunityId=o.Id, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', NUM_Quantity_litres_CP__c=24,Type__c='Free of Charge' );        
            insert new List<OpportunityLineItem>{item,item2};
            o=[select NUM_Total_Quantity_palets_FOC__c,NUM_Total_Quantity_palets_charged__c,CHK_FullTruckDiscount__c,CHK_HalfTruckDiscount__c from opportunity where id=:o.id];
            o2=[select NUM_Total_Quantity_palets_FOC__c,NUM_Total_Quantity_palets_charged__c,CHK_FullTruckDiscount__c,CHK_HalfTruckDiscount__c from opportunity where id=:o2.id];
            exportOrderData.DiscountSelected(o);
            exportOrderData.DiscountSelected(o2);
            list<opportunityLineItem> OLIs=new list<opportunityLineItem> ();
            OLIs.add(item);
            OLIs.add(item2);
            exportOrderData.quantityMultipleBasicUnits(OLIs);
                
            /*-------------------End Test Data creation--------------------*/
            
            /*  For generating a fake response to an http request we 
                use the MultiStaticResourceCalloutMock class. These 
                class allows to add many responses bodies as Static 
                resources. With setStaticResource we determinate the 
                body(as an Static resource) for the diferent Urls Request  */
           if(server_urls__c.getInstance('Order Entry')==null){
                Server_Urls__c url=new Server_Urls__c(name='Order Entry',url__c='https://gsc-customer-care-orders-np.agro.services/gsc-emea-order/v1/orders');
                insert url;
            }
            
            MultiStaticResourceCalloutMock multimock  = new MultiStaticResourceCalloutMock();
            multimock.setStaticResource(server_urls__c.getInstance('Auth URL').url__c, 'testWStoken');
            multimock.setStaticResource(server_urls__c.getInstance('Order Entry').url__c, 'testWSOrder');
            
            multimock.setStatusCode(200);        
            multimock.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            ExportOrderData cl=new ExportOrderData();
            test.startTest();
            
            Test.setMock(HttpCalloutMock.class, multimock);
            string var=ExportOrderData.convertOrders(o.Id);

            string var2=ExportOrderData.convertOrders(o2.Id); 
            ExportOrderData.response resp = new ExportOrderData.response();

            Opportunity o3= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Submitted',TXTA_Division__c='15',Name='Test-00000', CHK_FullTruckDiscount__c=True, StageName='STANDARD W DEL', CloseDate=Date.newInstance(2024, 2, 17));
            Opportunity o4= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Submitted',TXTA_Division__c='15',Name='Test-00002', CHK_HalfTruckDiscount__c=True, StageName='STANDARD W DEL', CloseDate=Date.newInstance(2024, 2, 17));
            insert new List<Opportunity>{o3,o4};
            string var3=ExportOrderData.convertOrders(o3.Id);
            string var4=ExportOrderData.convertOrders(o4.Id);
            ExportOrderData.response resp2 = new ExportOrderData.response();
            test.stopTest();
            
            /* Testing for delete submitted orders control */
            o.pick_status__c = 'Submitted';
            update o;
            try
            {
                delete o;
            }
            catch(Exception e)
            {
            }
            system.assert([SELECT id from opportunity where id=:o.id].size()==1);               
        }      
    }


 @isTest static void Test2(){
        /*----------- Test Data Creation----------------------*/

        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User cUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00', Username='testUser1324@test.com', LastName='test', country='France', Email='test@test.com', Alias='TEST', CommunityNickname='comm', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1]; 
        RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' limit 1];
        system.runAs(cUser){

            Country__C counT=new Country__C(name='TestCountry');
            insert counT;
        
            Account testAccount1=new Account(RecordType=rt,GC_SAP_ID__c='7654321',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount2=new Account(RecordType=rt,GC_SAP_ID__c='7654322',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', RecordType=rt);
            insert new List<Account> {testAccount1,testAccount2,vend};
                
            Sales_Area__c area=new Sales_Area__c(name='ES01/00/15');
            insert Area;
            
            Partner_Function__c testShipTo2=new Partner_Function__c(TXT_Partners_Ids__c='111222333',country_name__c='France',Partner_function_descr__c='WE/Ship-to Party',Partner_Function_Code__c='WE',Relation_Type_Descr__c='Ship-to Party',name='testShipTo',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='123456789');
            
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
        
        
            insert testShipTo2;      
            Opportunity o= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125',
                                      TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00000',  StageName='FOC ORDER', CloseDate=Date.newInstance(2024, 2, 17));
                
            Opportunity o2= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00002',CHK_FullTruckDiscount__c=True,  StageName='FOC ORDER', CloseDate=Date.newInstance(2024, 2, 17));
            insert new List<Opportunity>{o,o2};
                
            RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
            Division__c d = new Division__c(Name = 'CP');
            insert d;        
                
            Product2 prod = new Product2(Name = 'product1', Family='CP', ProductCartonPerPallet__c=17, DE_BasicUnits__c=10, ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            pricebook2 pStandard=[select id from pricebook2 where id=:pricebookId ];
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true,Integration_Key__c='testKey');  /* CountryRef__c.Name='Spain', DivisionRef__r.name='CP'*/
            insert customPB;
            if(SystemSettings__c.getInstance('Pricebook_'+cUser.country+'_'+cUser.TXT_Division__c)==null )
            {
                SystemSettings__c setPriceBook=new SystemSettings__c(name='Pricebook_'+cUser.country+'_'+cUser.TXT_Division__c,value__c=customPb.Id);
                insert setPriceBook;
            }                
            // 2. Insert a price book entry with a custom price.
            o.Pricebook2Id=customPB.id;
            update o;
            opportunity op1=[select pricebook2.name from opportunity where id=:o.id];
            system.debug('El pricebook asignado es: '+ op1.pricebook2.name );
            PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = o.Pricebook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
                insert customPrice;
            OpportunityLineItem item =new OpportunityLineItem(PricebookEntryId = customPrice.Id, OpportunityId=o.Id, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', NUM_Quantity_litres_CP__c=24,Type__c='Free of Charge' );        
            OpportunityLineItem item2 =new OpportunityLineItem(PricebookEntryId = customPrice.Id, OpportunityId=o.Id, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', NUM_Quantity_litres_CP__c=24,Type__c='Free of Charge' );        
            insert new List<OpportunityLineItem>{item,item2};
            o=[select NUM_Total_Quantity_palets_FOC__c,NUM_Total_Quantity_palets_charged__c,CHK_FullTruckDiscount__c,CHK_HalfTruckDiscount__c from opportunity where id=:o.id];
            o2=[select NUM_Total_Quantity_palets_FOC__c,NUM_Total_Quantity_palets_charged__c,CHK_FullTruckDiscount__c,CHK_HalfTruckDiscount__c from opportunity where id=:o2.id];
            exportOrderData.DiscountSelected(o);
            exportOrderData.DiscountSelected(o2);
            list<opportunityLineItem> OLIs=new list<opportunityLineItem> ();
            OLIs.add(item);
            OLIs.add(item2);
            exportOrderData.quantityMultipleBasicUnits(OLIs);
                    
            /*-------------------End Test Data creation--------------------*/
                
            /*  For generating a fake response to an http request we 
                use the MultiStaticResourceCalloutMock class. These 
                class allows to add many responses bodies as Static 
                resources. With setStaticResource we determinate the 
                body(as an Static resource) for the diferent Urls Request  */
            if(server_urls__c.getInstance('Order Entry')==null){
                Server_Urls__c url=new Server_Urls__c(name='Order Entry',url__c='https://gsc-customer-care-orders-np.agro.services/gsc-emea-order/v1/orders');
                insert url;
            }
                
            MultiStaticResourceCalloutMock multimock  = new MultiStaticResourceCalloutMock();
            multimock.setStaticResource(server_urls__c.getInstance('Auth URL').url__c, 'testWStoken');
            multimock.setStaticResource(server_urls__c.getInstance('Order Entry').url__c, 'testWSOrder');
                
            multimock.setStatusCode(404);        
            multimock.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            ExportOrderData cl=new ExportOrderData();
            test.startTest();
                
            Test.setMock(HttpCalloutMock.class, multimock);
            string var=ExportOrderData.convertOrders(o.Id);

            string var2=ExportOrderData.convertOrders(o2.Id); 
            ExportOrderData.response resp = new ExportOrderData.response();

            Opportunity o3= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01', TXT_Distribution_Channel__c='00', PICK_Status__c='Submitted', TXTA_Division__c='15',Name='Test-00000', CHK_FullTruckDiscount__c=True, StageName='STANDARD W DEL', CloseDate=Date.newInstance(2024, 2, 17));
            Opportunity o4= new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Submitted',TXTA_Division__c='15',Name='Test-00002', CHK_HalfTruckDiscount__c=True, StageName='STANDARD W DEL', CloseDate=Date.newInstance(2024, 2, 17));
            insert new List<Opportunity>{o3,o4};
            string var3=ExportOrderData.convertOrders(o3.Id);
            string var4=ExportOrderData.convertOrders(o4.Id);
            ExportOrderData.response resp2 = new ExportOrderData.response();
            test.stopTest();
                
            /* Testing for delete submitted orders control */
            o.pick_status__c = 'Submitted';
            update o;
            try
            {
                delete o;
            }
            catch(Exception e)
            {
            }
            system.assert([SELECT id from opportunity where id=:o.id].size()==1);                
        }       
    }
}