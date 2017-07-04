@isTest
private class Test_ProductAllocationBatch {

    public static RecordType accountRecordType, productRecordType, opportunityRecordType;       

    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'Corn Sales Product' AND SobjectType = 'Product2'  LIMIT 1];
        opportunityRecordType = [SELECT Id FROM RecordType WHERE Name = 'Sales Order' AND SobjectType = 'Opportunity' LIMIT 1];
    }
    
    static testMethod void testProductAllocationBatch() 
    { 

        Id userid=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
   
        User cUser=new User(SAP_Partner_Code__c='0001234567', TXT_Division__c='17',TXT_Sales_Org__c='IT01',Username='test123zxcvsdoire@test.com', LastName='test', Country='Italy', Email='test@test.com', Alias='TEST', 
                            CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
         
         system.runAs(cUser){
        
            init();
            
            Country__c country = new Country__c(Name = cUser.Country, Units_of_Measurement__c = 'Basic Units');
                insert country;
          
            Account acc = new Account(Name = 'Account1', GC_Cust_Account_Grp_Descr__c='Sold-to party' , CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id, GC_SAP_ID__c = '9000000105' );
                //insert acc;

            Account vend = new Account(Name = 'Monsanto Vendor', GC_Cust_Account_Grp_Descr__c='Sold-to party', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id, GC_SAP_ID__c = '67890678908' );
                //insert vend;
                insert new List<Account>{acc,vend};

            Sales_Area__c area=new Sales_Area__c(name='IT01/00/17');
                insert Area; 
        

            Opportunity op=new Opportunity(recordTypeid=opportunityRecordType.id,accountId=acc.id,/* LKP_Partner_Function__c = partner.id,*/ TXTA_Delivery_block_code__c='125',
                    TXTA_Sales_Org__c='IT01',TXT_Distribution_Channel__c='00',PICK_Status__c='Not Submitted',TXTA_Division__c='17',
                    Name='Test-00000', StageName='STANDARD W DEL', CloseDate=Date.today(),
                    LKP_areaManager_Credit_OT__c=cUser.id,LKP_areaManager_Debit_OT__c=cUser.id,
                    LKP_soldTo_Source_OT__c=acc.Id,Pricebook2Id=Test.getstandardPricebookId(),
                    TXT_NewShipTo_Address__c='asdf',
                    TXT_NewShipTo_City__c='asdf',
                    TXT_NewShipTo_ZIP_Contact__c='asdf',
                    TXT_NewShipTo_ShipToName__c='asdf',
                    TXT_NewShipTo_ZIP_Phone__c='asdf',
                    TXT_NewShipTo_ZIP_Code__c='asdf',
                    PICK_COUNTRY__c='sda',
                    PICK_REGION__c='SDF'
                );
                
                //insert op;
            
            Opportunity op2=new Opportunity(recordTypeid=opportunityRecordType.id,accountId=acc.id,/* LKP_Partner_Function__c = partner.id,*/ TXTA_Delivery_block_code__c='125',
                    TXTA_Sales_Org__c='IT01',TXT_Distribution_Channel__c='00',PICK_Status__c='Submitted',TXTA_Division__c='17',
                    Name='Test-00002', StageName='STANDARD W DEL', CloseDate=Date.today(),Pricebook2Id=Test.getstandardPricebookId(),
                    TXT_NewShipTo_Address__c='asdf',
                    TXT_NewShipTo_City__c='asdf',
                    TXT_NewShipTo_ZIP_Contact__c='asdf',
                    TXT_NewShipTo_ShipToName__c='asdf',
                    TXT_NewShipTo_ZIP_Phone__c='asdf',
                    TXT_NewShipTo_ZIP_Code__c='asdf',
                    PICK_COUNTRY__c='sda',
                    PICK_REGION__c='SDF'
                );
            op2.LKP_areaManager_Credit_OT__c=cUser.id;
            op2.LKP_areaManager_Debit_OT__c=cUser.id;
            op2.chk_organized__C=true;
            op2.TXT_DDT_Number__c='112000999';
                //insert op2;
                insert new List<Opportunity>{op,op2};
                  
            Division__c d = new Division__c(Name = 'Corn');
                insert d;       

            Product2 prod = new Product2(isActive=true, ProductCartonPerPallet__c= 8, Name = 'product1', Family='Corn', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, DE_BasicUnits__c = 20);
                insert prod;
                      
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = system.Test.getstandardPricebookId(), gc_integration_key__c='ACS/SAP00001', Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
                insert standardPrice; 

            Pricebook2 pb = new Pricebook2(Name='Custom Pricebook', isActive=true, Integration_Key__c='ACS/testKey');
                insert pb;
            
            op.Pricebook2Id=pb.id;                    
            op2.Pricebook2Id=pb.id;  
                update new List<Opportunity>{op,op2};

            PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = op.Pricebook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
                insert customPrice;
            
            id catalogo=[select pricebook2id from opportunity where id=:op2.id].pricebook2id;
            id catalogo2=[select pricebook2id from opportunity where id=:op.id].pricebook2id;
            PricebookEntry customPricetoAssign=[select id,pricebook2.name from priceBookEntry where pricebook2Id =:catalogo  limit 1];
            PricebookEntry customPricetoAssign2=[select id,pricebook2.name from priceBookEntry where pricebook2Id =:catalogo2  limit 1];            

            OpportunityLineItem item =new OpportunityLineItem(OpportunityId=op.Id, TXT_PLANT_COPY__c='1315',TXTA_Comments__c='this is item text',NUM_Quantity_CP__c=2,Type__c='Free of Charge', PricebookEntryId=customPricetoAssign.ID ); 
                //insert item;

            OpportunityLineItem item2 =new OpportunityLineItem(OpportunityId=op2.Id, TXT_PLANT_COPY__c='1315',TXTA_Comments__c='this is item text',NUM_Quantity_CP__c=2,Type__c='Charge', PricebookEntryId=customPricetoAssign.ID ); 
                //insert item2; 
                insert new List<OpportunityLineItem>{item,item2};

            Order o1 = new Order(Opportunity = op, Order_Owner_Code__c = cUser.SAP_Partner_Code__c, accountId = acc.id, GC_Integration_Key__c = 'SAP00001', GC_Document_Type_Descr__c ='Ag-Eu Standard Order', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '17', GC_Doc_Creation_Date__c = System.today(), GC_Requested_Delivery_Date__c = System.today());
                //insert o1;
            
            Order o2 = new Order(Opportunity = op2, Order_Owner_Code__c = cUser.SAP_Partner_Code__c, accountId = acc.id, GC_Integration_Key__c = 'SAP00002', GC_Document_Type_Descr__c ='Ag-Eu Standard Order', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '17', GC_Doc_Creation_Date__c = System.today(), GC_Requested_Delivery_Date__c = System.today());
                //insert o2;
                insert new List<Order>{o1,o2};

            OrderItem oi = new OrderItem();
            oi.OrderId = o1.Id;
            oi.PricebookEntryId = standardPrice.id;
            oi.Quantity = 100;
            oi.GC_Delivered_Quantity__c = 100;
            oi.GC_Quantity__c = 100;
            oi.UnitPrice = 1;
                insert oi;

            String extid = cUser.id + '-' + oi.priceBookEntry.productcode + '-' + '2016';
            
            Allocation__c alloc = new Allocation__c (TXT_External_ID__c = extid);
                insert alloc;
            
            OrderItem oi2 = new OrderItem();
            oi2.OrderId = o2.Id;
            oi2.PricebookEntryId = standardPrice.id;
            oi2.Quantity = 200;
            oi2.GC_Delivered_Quantity__c = 100;
            oi2.GC_Quantity__c = 100;
            oi2.UnitPrice = 1;
                insert oi2;
        
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String newjobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ScheduledAllocationBatch());
            
            List<Allocation__c> AllocationList = [SELECT  Name FROM Allocation__c WHERE TXT_External_ID__c = : extid limit 1];

            String query = 'Select id from order where id=\''+oi.Id+'\'';
            ProductAllocationBatch job = new ProductAllocationBatch(10);
            id jobid= Database.executeBatch (job);
            
       }
    }
}