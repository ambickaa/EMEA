@isTest
private class TEST_AccountTacticalPlanController {
    
        public static List<Country__c> countries;
        public static Division__c aDivision;
        public static Account aFarmAccount;
        public static Account aDistAccount;
        public static Account anCompetitor;
        public static Campaign aPreviousCampaign;
        public static Campaign aCurrentCampaign;
        public static Product2 product;
        public static Product2 product2;
        public static List<CampaignLineItem__c> listCLI;
        public static List<Account> listAcc;

    private static void init(){
        TestInit.setYear(1);
        system.debug('DEER: '+TestInit.countries);
        //BEGIN Country
        countries = new List<Country__c>();
        countries.add(TestInit.getCountryByName('France'));
        countries.add(testInit.getCountryByName('United Kingdom'));
        //insert countries;
        //END Country
        aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        product = TestInit.products[1];
        insert product;
        

        
        listAcc = new List<Account>();
        aFarmAccount = TestInit.createNewFarmer();
        aFarmAccount.CountryRef__c = countries[0].Id;
        aFarmAccount.CountryID__c = countries[0].Id;
        listAcc.add(aFarmAccount);
        aDistAccount = TestInit.createNewDistributor();
        aDistAccount.CountryID__c = countries[0].Id;
        listAcc.add(aDistAccount);
        anCompetitor = TestInit.createNewCompetitor();
        listAcc.add(anCompetitor);
        insert listAcc;
        
        ProductCatalog__c prodCat = TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog');
        prodCat.YearRef__c = Util.currentYear.Id;
        prodCat.DivisionRef__c = aDivision.Id;
        prodCat.CountryID__c = countries[0].Id;
        prodCat.CountryRef__c = aFarmAccount.CountryRef__c;
        prodCat.OwnerId = aFarmAccount.OwnerId;
        update prodCat;
        
        Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
        {
          'CountryRef__c' => aFarmAccount.CountryRef__c,
          'OwnerId' => aFarmAccount.OwnerId,
          'DivisionRef__c' => aDivision.Id,
          'StartDate' => Date.today(),
          'EndDate' => Date.today(),
          'ArchiveDate__c' => Date.today().addDays(30),
          'YearV2__c' => Util.lastYear.Id
        };
        Map<String, Object> aCurrentCampaignParam = new Map<String, Object>
        {
          'CountryRef__c' => aFarmAccount.CountryRef__c,
          'OwnerId' => aFarmAccount.OwnerId,
          'DivisionRef__c' => aDivision.Id,
          'StartDate' => Date.today(),
          'EndDate' => Date.today().addDays(30),
          'ArchiveDate__c' => Date.today().addDays(60),
          'YearV2__c' => Util.currentYear.Id,
          'SalesPCMRef__c' => prodCat.Id
        };
        list<Campaign> campaignsToInsert = new list<Campaign>();
        aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
        campaignsToInsert.add(aPreviousCampaign);
        aCurrentCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrentCampaignParam);
        campaignsToInsert.add(aCurrentCampaign);
        insert campaignsToInsert;
        product2 = TestInit.products[0];
        
        product2.ProductVendor__c= listAcc[2].Id;
        
        insert product2;

        listCLI = new List<CampaignLineItem__c>();
        listCLI.add (new CampaignLineItem__c (RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            FarmRef__c = aFarmAccount.id, CampaignRef__c = aPreviousCampaign.id,Type__c = 'Free of charge',
            ProductRef__c = product.id));
        listCLI.add (new CampaignLineItem__c (RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            FarmRef__c = aFarmAccount.id, CampaignRef__c = aCurrentCampaign.id,Type__c = 'Charged',
            ProductRef__c = product.id));
        listCLI.add(new CampaignLineItem__c (RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            FarmRef__c = aFarmAccount.id, CampaignRef__c = aCurrentCampaign.id,Type__c = 'Charged',
            ProductRef__c = product2.id));
        System.debug('listCLI: '+listCLI);
        
        TacticalPlanConfigFields__c tpcf = new TacticalPlanConfigFields__c(Name = 'ProductVendor__c');
        tpcf.DisplayTypeCompetitor__c = '';
        tpcf.DisplayTypeMonsanto__c = '';
        insert  tpcf;
        
        Map<String, Object> aProductCatalogEntryParam = new Map<String, Object>
            {
                'ProductRef__c' => product.Id,
                'ProductCatalogRef__c' => prodCat.Id
            };
        
        ProductCatalogEntry__c prodCatEntry = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aProductCatalogEntryParam);
        insert prodCatEntry;
        
        //insert listCLI;
        
        
    }
    static testMethod void testFarm() {
        init();
        Test.setCurrentPage(Page.AccountViewFR);
        Account farmAccount = listAcc[0];
        Apexpages.currentPage().getParameters().put('id', farmAccount.Id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        Util.currentCampaign = aCurrentCampaign;
        Util.previewsCampaign = aPreviousCampaign;
        test.startTest();
        //test.stopTest();
        
        AccountTacticalPlanController tpCon = new AccountTacticalPlanController();
        tpCon.getConstructor();
        tpCon.doEdit();
        tpCon.doCancel();
        tpCon.doEdit();
        tpCon.doSave();
        tpCon.tacticalPlansToDelete = '';
        tpCon.doDelete();
        tpCon.tacticalPlansToDelete = '0';
        tpCon.doDelete();
        //tpCon.doAddMultipleLines();
        //tpCon.actionDef();
        //tpCon.isFarmAccount();
        //tpCon.getcurrentDivision();
        test.stopTest();
    }
   
}