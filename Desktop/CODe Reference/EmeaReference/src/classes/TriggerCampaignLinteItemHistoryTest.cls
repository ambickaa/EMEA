@isTest
private class TriggerCampaignLinteItemHistoryTest {

    static testMethod void myUnitTest() {
        
        /* General data insert: System Settings, Country, current and past Year, Division, Accounts, Campaign, Product, Product Catalog,
        Product Catalog Entry and a Preliminary Order */ 
        
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
                               
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.currentUser.id);
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id);
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        
        Order__c pOrder= new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));     
        insert pOrder;
        
        CampaignLineItem__c cLI = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                ProductCatalogEntryRef__c= pceS.id, PreliminaryOrderRef_RSA__c=null, 
                                                                Ownerid=Util.currentUser.ID, FarmRef__c= farm.id, CampaignRef__c= caYear.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prS.id); 
        insert cLI;
        
        Test.StartTest();
        
        /* Since we have inserted a CampaignLineItem, a CampaignLineItemHistory record related to it should have been created. This CLI is not
        related to any order, so AgreedCopy field should be null */
        
        CampaignLineItemHistory__c cLIH = [SELECT ID, Name, Agreed__c, AgreedCopy__c, PreliminaryOrderRef_RSA__c, 
                                           PreliminaryOrderRef_RSACopy__c, CampaignLineItem__c
                                           FROM CampaignLineItemHistory__c
                                           WHERE CampaignLineItem__c=:cLI.id];
                                           
        System.assertEquals(cLIH.AgreedCopy__c, null);      
        
        /* If this CLI is inserted in a closed Preliminary Order, the Agreed Field will be copied and saved in AgreedCopy field*/
        
        cLI.PreliminaryOrderRef_RSA__c=pOrder.id;
        update cLI;
        
        cLIH = [SELECT ID, Name, Agreed__c, AgreedCopy__c, PreliminaryOrderRef_RSA__c, 
                PreliminaryOrderRef_RSACopy__c, CampaignLineItem__c
                FROM CampaignLineItemHistory__c
                WHERE CampaignLineItem__c=:cLI.id];
                
        System.assertEquals(cLIH.AgreedCopy__c, 25);
        
        /* If Agreed field of the CLI is changed, AgreedCopy still keeps the first Agreed value*/
                
        cLI.Agreed__c=50;
        update cLI; 
        
        cLIH = [SELECT ID, Name, Agreed__c, AgreedCopy__c, PreliminaryOrderRef_RSA__c, 
                PreliminaryOrderRef_RSACopy__c, CampaignLineItem__c
                FROM CampaignLineItemHistory__c
                WHERE CampaignLineItem__c=:cLI.id];
                
        System.assertEquals(cLIH.AgreedCopy__c, 25);
        
        /* If the CLI is deleted, its related CampaignLineItemHistory record is not deleted and still keeps the first Agreed__c value*/
        
        delete cLI; 
        
        cLIH = [SELECT ID, Name, Agreed__c, AgreedCopy__c, PreliminaryOrderRef_RSA__c, 
                PreliminaryOrderRef_RSACopy__c, CampaignLineItem__c
                FROM CampaignLineItemHistory__c
                WHERE PreliminaryOrderRef_RSACopy__c=:pOrder.id];   
                
        System.assertEquals(cLIH.AgreedCopy__c, 25);
        System.assertEquals(cLIH.Agreed__c, 0);
        Test.StopTest();                                                                                    
    }
}