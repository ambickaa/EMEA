@isTest
private class VouchersGeneratorControllerTest {

    static testMethod void testConstructor() {
        /*creating some data background*/

        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                
        Country__c c = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1)); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id); 
        insert year;
        
        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id );
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert salesCat;

        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2015,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,02,02));      
        insert caYearSR;         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Regular',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        insert prS;   
                                    
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
        insert pceS;
 
        Test.startTest();        
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, Forecast__c=15,
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=Util.currentUser.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, 
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id, POGPY__c=12);
        insert cliSales;   
        
        Product_Grouping__c pgt = new Product_Grouping__c(name = 'CornSilage', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
        Product_Grouping__c pgg = new Product_Grouping__c(name = 'Corn', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c>{pgg,pgt};
        RecordType App = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProduct'];
        RecordType Appg = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProductGroup'];
        
        List<Acreage__c> acreages = new List<Acreage__c>();  
        for(Integer i=0; i<5; i++){
            Acreage__c acr=new Acreage__c( AcrFarmRef__c=farm.id, AcrProviderRef__c=Provider.id, AcrTotalAcreages__c=100,
                            Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, AcrSecondHarvest__c=false,
                            RecordTypeId=App.Id, idDevice__c=100+i,
                            AcrYearRef__c=Year.ID, AcrProductGroupRef__c=pgg.id, AcrProductTypeRef__c=pgt.id);
           acreages.add(acr);
        }
        insert acreages;
        
        VoucherCampaign__c vca = new VoucherCampaign__c (Name='vCA', YearRef__c = Year.id, StartDate__c = Date.newinstance(2014,02,02), 
                                                         EndDate__c= Date.newinstance(2019,11,11), CountryRef__c= c.id, BagSize__c=80, 
                                                         DivisionRef__c= Divi.id, MinProducts__c=1, MinTotalBags__c=1);
        insert vca; 

        Discount__c Disc = new Discount__c(MaxBags__c=59, MinBags__c=10,Ownerid=Util.currentUser.ID,VoucherCampaignRef__c=vca.id,
                                           PercentIncreaseInBags__c=5, DiscountInPrice__c=125);
        insert Disc;
        
        TriggerVoucherNameCreator.fromTest=true;
        String longString='';
        for(Integer i=0; i<25; i++){
            longString+='0123456789';
        }
        String shortString='';
        for(Integer i=0; i<4; i++){
            shortString+='0123456789';
        }        
        Voucher__c vou = new Voucher__c(AccountRef__c=farm.Id, CampaignRef__c=caYearSR.Id, DistributorRef__c = provider.Id, VoucherCampaignRef__c= vca.Id,OwnerId=Util.currentUser.Id, 
                                        DiscountRef__c=disc.Id, Name='VoucherTest', status__c='closed',AddressCopy__c=longString, FarmNameCopy__c=shortString, 
                                        DistributorNameCopy__c=longString );
        insert vou; 
        VoucherLineItem__c vli = new VoucherLineItem__c( Agreed__c=1, Bags__c=1,CampaignLineItemRef__c=cliSales.id, FAO__c=3,HybridGroup__c='HD',OwnerId=Util.currentUser.ID,
                                                        VoucherRef__c=vou.id);
        VoucherLineItem__c vli2 = new VoucherLineItem__c( Agreed__c=1, Bags__c=1,CampaignLineItemRef__c=cliSales.id, FAO__c=3,HybridGroup__c='MAXTECH',OwnerId=Util.currentUser.ID,
                                                        VoucherRef__c=vou.id);   
        VoucherLineItem__c vli3 = new VoucherLineItem__c( Agreed__c=1, Bags__c=1,CampaignLineItemRef__c=cliSales.id, FAO__c=3,HybridGroup__c='CLASIC',OwnerId=Util.currentUser.ID,
                                                        VoucherRef__c=vou.id);  
        VoucherLineItem__c vli4 = new VoucherLineItem__c( Agreed__c=1, Bags__c=1,CampaignLineItemRef__c=cliSales.id, FAO__c=3,HybridGroup__c='YIELDGARD',OwnerId=Util.currentUser.ID,
                                                        VoucherRef__c=vou.id);                                                          
        insert new List<VoucherLineItem__c>{vli,vli2,vli3,vli4};
        Voucher__c voucher=[SELECT AccountRef__c,AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c,EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c,VoucherCampaignRef__c, Owner.Name, DiscountRef__c FROM Voucher__c
                  WHERE id=:vou.ID];
        ApexPages.StandardController sc = new ApexPages.StandardController(voucher);
        VouchersGeneratorController controller= new VouchersGeneratorController(sc);
    }
}