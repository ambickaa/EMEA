@isTest(seeAllData=true)
public class TEST_OpportunityViewExtension2 {
    
    
    public static testMethod void testController()
    {                
        /*----------- Test Data Creation----------------------*/
        
        
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
        RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' and Name='Sales Order CP' limit 1];
        RecordType opprt2=[Select id,Name from RecordType where SobjectType='Opportunity' and Name='Transfer Order' limit 1];
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User cUser=new user(country='France',TXT_Division__c='15',SAP_Partner_Code__c='',Division='CP',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
        insert cUser;
        system.runAs(cUser){
            Country__C counT=new Country__C(name='TestCountry');
            insert counT;
            
            Account testAccount1=new Account(RecordType=rt,GC_SAP_ID__c='7654321',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount2=new Account(RecordType=rt,GC_SAP_ID__c='3456789',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',TXT_Partners_Ids__c='111222333',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            insert testAccount1;
            insert testAccount2;
            
            
            RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
            RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
            Division__c d = new Division__c(Name = 'CP');
            insert d;    
            Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
            insert vend; 
            Product2 prod = new Product2(ProductCartonPerPallet__c= 8,Name = 'product1', Family='CP', ProductSAPCode__c = 'SAPCode1',/* DivisionRef__c = d.Id, ProductVendor__c = vend.Id,*/ recordTypeId = productRecordType.Id);
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            pricebook2 pStandard=[select id from pricebook2 where id=:pricebookId ];
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true,Integration_Key__c='testKey');
            insert customPB;
            
            // 2. Insert a price book entry with a custom price.
            
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
            insert customPrice;
            
            Sales_Area__c area=new Sales_Area__c(name='ES01/00/15');
            insert Area;    
            Partner_Function__c testShipTo2=new Partner_Function__c(Partner_function_descr__c='WE/Ship-to Party' ,Country_Name__c='France',Partner_Function_Code__c='WE',Relation_Type_Descr__c='Ship-to Party',name='testShipTo',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='3456789');            
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
            insert testShipTo2;
            
            Partner_Function__c testShipTo3=new Partner_Function__c(Partner_Function_Code__c='YB',Partner_function_descr__c='YB/Area Manager',Relation_Type_Descr__c='YB - Area Manager',name='testShipTo3',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='111222333');            
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
            insert testShipTo3;
            
            Opportunity o=new Opportunity(recordTypeid=oppRt.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125',
                                          TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='15',
                                          Name='Test-00000', StageName='STANDARD W DEL', CloseDate=Date.today(),
                                          LKP_areaManager_Credit_OT__c=cUser.id,LKP_areaManager_Debit_OT__c=cUser.id,LKP_ShipTo_Source_OT__c=testShipTo2.id,
                                          LKP_soldTo_Source_OT__c=testAccount1.Id,Pricebook2Id=customPb.Id,LKP_Price_Book__c=customPb.Id
                                         );
            insert o;
            system.debug(o.id );
            system.debug( [select id,Pricebook2Id,Product2Id,Product2.Name from PricebookEntry  where pricebook2id=:o.Pricebook2Id]);
            Opportunity o2=new Opportunity(recordTypeid=oppRt2.id,accountId=testAccount1.Id,LKP_Partner_Function__c=testShipTo2.id,TXTA_Delivery_block_code__c='125',
                                           TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00',PICK_Status__c='Submitted',TXTA_Division__c='15',Name='Test-00002', StageName='STANDARD W DEL', CloseDate=Date.today(),Pricebook2Id=customPb.Id,LKP_Price_Book__c=customPb.Id);
            o2.LKP_areaManager_Credit_OT__c=cUser.id;
            o2.LKP_areaManager_Debit_OT__c=cUser.id;
            o2.chk_organized__C=true;
            o2.TXT_DDT_Number__c='112';
            
            insert o2;
            
            
            OpportunityLineItem item =new OpportunityLineItem(PricebookEntryId=customPrice.ID,OpportunityId=o.Id, TXT_PLANT_COPY__c='1315',TXTA_Comments__c='this is item text',NUM_Quantity_CP__c=2,Type__c='Free of Charge' );        
            insert item;
            
            OpportunityLineItem item2 =new OpportunityLineItem(PricebookEntryId=customPrice.ID,OpportunityId=o2.Id, TXT_PLANT_COPY__c='1315',TXTA_Comments__c='this is item text',NUM_Quantity_CP__c=2,Type__c='Charge' );        
            insert item2;
            
            /*-------------------End Test Data creation for Order entry--------------------*/
            /*------------------- Test Data creation for Transfer Order entry--------------------*/
            
            Delivery__c delivery=new Delivery__c(GC_Account_Integration_Key__c=testAccount1.id,ShipTo_Acc_Integration_Key__c= testAccount2.id,
                                                 Name='123456',GC_Order_Number__c='123456',GC_Integration_Key__c='123456' );
            insert delivery;
            Delivery_Line_Item__c delI=new Delivery_Line_Item__c(
                Name='00001', GC_Dlvry_Integration_Key__c=delivery.id,
                GC_Integration_Key__c ='00001',GC_Batch_Number_Text__c='123455',GC_Item_Code__c='SAPCode1'
            );
            
            insert delI;                                
            /*------------------- END Test Data creation for Transfer Order entry--------------------*/
            
            Id idVariable=o.Id;
            PageReference pageRef= Page.OpportunityCopy2;
            
            Test.setCurrentPage(pageRef);
            
            System.currentPageReference().getParameters().put('id', idVariable);
            
            OpportunityViewExtension2 controller=new OpportunityViewExtension2(new ApexPages.StandardController(o)); 
            test.startTest();
            controller.addProducts();
            
            OpportunityViewExtension2.cOLI aux1 = new OpportunityViewExtension2.cOLI();            
            
            aux1.selected=True;
            aux1.OppLine=new OpportunityLineItem(Quantity=32,Type__c='Free of Charge');
            aux1.prodName='product1';           
            
            controller.allcOLIs.add(aux1);
            controller.save4();
            controller.newRow();    
            OpportunityViewExtension2.cOLI aux = new OpportunityViewExtension2.cOLI();
            
            aux.selected=True;
            aux.OppLine=new OpportunityLineItem(Quantity=32,Type__c='Free of Charge');
            aux.prodName='product1';
            controller.existingcOLIs.add(aux);
            controller.save4();
            
            controller.newRow();
            controller.cancel();

            
            //System.debug('@@@' + Database.countQuery);
            
            controller.deleteOLIs();
            controller.search();                                           /*----------------------------------------------------------------------------------------------------------*/
            controller.save4();
            controller.selectedField='Product Name';
            controller.selectedFilter='contains';
            controller.searchBox='prod';
            controller.search();
            controller.selectedField='Created Date';
            controller.selectedFilter='less than';      
            controller.searchBoxDate=date.newinstance(2080, 2, 17);
            
            controller.keyWord='product1';  
            controller.search();
            controller.selectedField='Active';
            controller.selectedFilter='equals';   
            controller.searchBox='True';
            controller.search();
            controller.newRow();    
            OpportunityViewExtension2.cOLI aux2 = new OpportunityViewExtension2.cOLI();
            
            aux2.selected=True;
            aux2.OppLine=new OpportunityLineItem(Quantity=32);
            aux2.prodName='product1';
            controller.existingcOLIs.add(aux2);
            /*Methods for oppviewex2*/
            controller.edit2();
            controller.save2();
            controller.debitSoldTo();
            controller.debitShipTo();
            controller.creditSoldTo();
            controller.creditShipTo();
            controller.cancel2();
            //  controller.save4();
            
           //test.startTest();

            Id idVariable2=o2.Id;
            PageReference pageRef2= Page.OpportunityCopy2;
            
            Test.setCurrentPage(pageRef2);
            
            System.currentPageReference().getParameters().put('id', idVariable2);
            
            OpportunityViewExtension2 controller2=new OpportunityViewExtension2(new ApexPages.StandardController(o2)); 
            
            
            controller2.addProducts();
            OpportunityViewExtension2.cOLI aux22 = new OpportunityViewExtension2.cOLI();
            
            
            
            aux22.selected=True;
            aux22.OppLine=new OpportunityLineItem(Quantity=32,Type__c='Free of Charge');
            aux22.prodName='product1';
            controller2.allcOLIs.add(aux22);
            controller2.save4();

            test.stopTest(); 
            
            /*Methods for oppviewex2*/
           /* controller2.edit2();
            controller2.save2();
           
            system.debug(o2.LKP_areaManager_Debit_OT__c);
            
            user pruebalog=[select name,id,SAP_Partner_Code__c from user where id=:o2.LKP_areaManager_Debit_OT__c];
 
            system.debug(pruebalog);
            controller2.selectSoldTo(o2.LKP_areaManager_Debit_OT__c);
            controller2.selectShipTo(o2.LKP_areaManager_Credit_OT__c);
            controller2.save();
            controller2.mode='edit';
            controller2.importStock();
            controller2.cancel2();
            //  controller.save4();
            test.stopTest();*/  
        }}
}