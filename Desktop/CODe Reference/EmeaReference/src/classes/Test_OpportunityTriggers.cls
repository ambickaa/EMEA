@isTest(seeAllData=true)
public class Test_OpportunityTriggers {

    @isTest static void test(){
        
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
   
        User cUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', country='Italy', Email='test@test.com', Alias='TEST', 
                            CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
         
        system.runAs(cUser){
        
    /* ---------------- Test Data creation ----------------*/
            RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1]; 
            RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
            RecordType oppRecordType = [SELECT Id FROM RecordType WHERE Name = 'Sales Order CP Italy' AND SobjectType = 'Opportunity' LIMIT 1];
             RecordType oppRecordType2 = [SELECT Id FROM RecordType WHERE Name = 'Sales Order' AND SobjectType = 'Opportunity' LIMIT 1];
            RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' limit 1];
            Country__C c=new Country__C(name='TestCountry');
            insert c;
            Profile pIT = [SELECT Id FROM Profile WHERE Name='IT_Sales Representative'];
            Account acc=new Account(RecordType=accountRecordType, GC_SAP_ID__c='7654321', GC_Cust_Account_Grp_Descr__c='Sold-to party', Name='Account',Category__c='Distributor', 
                                    GC_Status_Descr__c='Active',CountryRef__c=c.id, CornTotalAcreagesCY__c=40, OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            insert acc;     
            Opportunity o=new Opportunity(recordTypeid=oppRt.id,accountId=acc.Id, /*LKP_Partner_Function__c=testShipTo2.id,*/ TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00', 
                                          PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00000', CHK_FullTruckDiscount__c=True, StageName='Fast warehouse', CloseDate=Date.newInstance(2024, 2, 17));
            list<opportunity> oppsToIns=new list<opportunity>();
            oppsToIns.add(o);
            Opportunity oIT=new Opportunity(accountId=acc.Id, RecordTypeId=oppRecordType.Id, TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00', 
                                          PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00000', CHK_FullTruckDiscount__c=True, StageName='Fast warehouse', CloseDate=Date.newInstance(2024, 2, 17));
            oppsToIns.add(oIT);
            insert  oppsToIns;
            
            Division__c d = new Division__c(Name = 'CP');
            insert d;        
            Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
            insert vend; 
            Product2 prod = new Product2(Name = 'product1', Family='CP', ProductCartonPerPallet__c=17, DE_BasicUnits__c=10, ProductSAPCode__c = 'SAPCode1', 
                                         DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            pricebook2 pStandard=[select id from pricebook2 where id=:pricebookId ];
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id, /*StandardPrice=250,*/
                UnitPrice = 10000, UseStandardPrice = False, IsActive = true);
            insert standardPrice;
            Pricebook2 pb = new Pricebook2(Name='Custom Pricebook', isActive=true,Integration_Key__c='testKey');
        	insert pb;
            o.Pricebook2Id=pb.id;
            
            
            list<opportunity> oppsToUpd=new list<opportunity>();
            oppsToUpd.add(o);
            oIT.pricebook2Id=pb.id;
            oit.LKP_Price_Book__c=pb.id;
             oppsToUpd.add(oIT);
            update oppsToUpd;
            PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = o.Pricebook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        	insert customPrice;
            SystemSettings__c catalogAssigned=SystemSettings__c.getInstance('Pricebook_'+cUser.Country+'_'+cUser.TXT_Division__c);
            system.Debug('weeeeeeeeeeeeeeeee'+catalogAssigned.name);
            SystemSettings__c catalog=new SystemSettings__c(name='Pricebook_'+cUser.Country+'_'+cUser.TXT_Division__c,value__c=pb.id);
            if (catalogAssigned==null)
            {
                catalogAssigned.Value__c=catalog.Value__c;
                insert catalogAssigned;
            }
            system.Debug('weeeeeeeeeeeee'+catalogAssigned.value__c +''+ oit.Pricebook2Id);    
            id catalogo=[select pricebook2id from opportunity where id=:oit.id].pricebook2id;
            id catalogo2=[select pricebook2id from opportunity where id=:o.id].pricebook2id;
    		PricebookEntry customPricetoAssign=[select id,pricebook2.name from priceBookEntry where pricebook2Id =:catalogo  limit 1];
            PricebookEntry customPricetoAssign2=[select id,pricebook2.name from priceBookEntry where pricebook2Id =:catalogo2  limit 1];
            system.debug('oleoleole'+customPricetoAssign.pricebook2+' '+ oit.Pricebook2Id );
            
            list<OpportunityLineItem> items=new list<OpportunityLineItem>();
			OpportunityLineItem item =new OpportunityLineItem(PricebookEntryId=customPricetoAssign.ID, OpportunityId=oIT.Id,Num_discount__c=5, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', 
                                                              NUM_Quantity_litres_CP__c=24,Type__c='Charged' );        
            items.add(item) ;        
            OpportunityLineItem item3 =new OpportunityLineItem(PricebookEntryId=customPricetoAssign.ID, OpportunityId=oIT.Id,Num_discount__c=5, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item text', 
                                                              NUM_Quantity_palets_CP__c=24,Type__c='Charged' );        
            items.add(item3) ;        
            OpportunityLineItem item2 =new OpportunityLineItem(PricebookEntryId=customPricetoAssign2.ID, OpportunityId=o.Id, TXT_PLANT_COPY__c='1315', TXTA_Comments__c='this is item2 text', 
                                                              NUM_Quantity_litres_CP__c=24,Type__c='Charged' );        
            items.add(item2) ;
            insert items;
            o.PICK_Status__c='Pending Manager';
            update o;
            test.startTest();
			cUser.country='Spain';
            
            update cUser;
            test.stopTest();
            Opportunity oIT2=new Opportunity(RecordTypeId=oppRecordType.Id,accountId=acc.Id, TXTA_Delivery_block_code__c='125', TXTA_Sales_Org__c='ES01',TXT_Distribution_Channel__c='00', 
                                             PICK_Status__c='Not Submitted',TXTA_Division__c='15',Name='Test-00000', CHK_FullTruckDiscount__c=True, StageName='Fast warehouse', CloseDate=Date.newInstance(2024, 2, 17));
            insert oIT2;
            
            
            }
     
     }
}