@isTest
private class Test_TriggerVoucherFOCBags {
    
    public static List<Voucher__c> List_Vouchers;
    public static List<Voucher__c> List_VouchersRO;
    
    @isTest
     static void Test1_Ini() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
        currentUser.Country = 'Czech Republic';
        update currentUser;
        
        Year__c PY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2014,11,1), YearEndDate__c=date.newinstance(2015,10,31), Current_Year__c=false);
        insert PY;
        
        Year__c CY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
        insert CY;
        
        Division__c Corn = new Division__c(Name='Corn');
        insert Corn;
            
        Country__c Czech_Republic = new Country__c(Name='Czech Republic');
        insert Czech_Republic;
        
        ProductCatalog__c Czech_Republic_Corn_Sales_2016 = new ProductCatalog__c(Name='Czech Republic - Corn - Sales - 2016', CountryRef__c=Czech_Republic.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
        insert Czech_Republic_Corn_Sales_2016;
        
        Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Czech_Republic.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Czech_Republic_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);
        Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Czech_Republic.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Czech_Republic_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);              
        insert new List<Campaign>{CampaignPY, CampaignCY};
        
        Test.StartTest();
        
        Account Account1 = new Account(CountryRef__c=Czech_Republic.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST', CornTotalSalesPY__c=10, NUM_AGREED_CORN_CHARGED_CY__c=140, CornTotalAcreagesCY__c=140);
        Account Account2 = new Account(CountryRef__c=Czech_Republic.Id, Name='TEST2', City__c='TEST', StateProvince__c='TEST', CornTotalSalesPY__c=10, NUM_AGREED_CORN_CHARGED_CY__c=25, CornTotalAcreagesCY__c=50);
        insert new List<Account>{Account1, Account2};
        
        Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1.Id,  Decision_Maker__c=true, Phone=null, MobilePhone='987002765', Position_picklist__c='CEO');
        Contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', AccountId=Account2.Id,  Decision_Maker__c=true, Phone=null, MobilePhone=null, Position_picklist__c='Other');
        insert new List<Contact>{Contact1, Contact2};
        
        VoucherCampaign__c Czech_Republic_Corn_2016 = new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=Corn.Id, BagSize__c=80, CountryRef__c=Czech_Republic.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=1, MinTotalBags__c=1, CHCK_FOCBags_AP__c=true);
        insert Czech_Republic_Corn_2016;
        
        Discount__c d1 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Premium', MinBags__c=0, MaxBags__c=99, TXT_Min_First_Ladder_Field__c='AccountRef__r.CornTotalSalesCY__c', NUM_Min_First_Ladder__c=50, NUM_Max_First_Ladder__c=149);
        Discount__c d2 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, PercentIncreaseInBags__c=5, PICK_Applies_to__c='Premium', MinBags__c=100, TXT_Min_First_Ladder_Field__c='AccountRef__r.CornTotalSalesCY__c', NUM_Min_First_Ladder__c=50, NUM_Max_First_Ladder__c=149);
        Discount__c d3 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Classic', MinBags__c=0, MaxBags__c=99);
        Discount__c d4 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Classic', MinBags__c=100);
        insert new List<Discount__c> {d1, d2, d3, d4};
        
        Product2 pr1 = new Product2(Name='TEST1', ProductSAPCode__c='12123213', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
        Product2 pr2 = new Product2(Name='TEST2', ProductSAPCode__c='12444444', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
        insert new List<Product2> {pr1, pr2};
        
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Czech_Republic_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id, Price__c=500, NewProduct__c=true);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=Czech_Republic_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr2.Id, Price__c=500, DE_isPremium__c=true);
        insert new List<ProductCatalogEntry__c>{pce1, pce2};
        
        List_Vouchers = new List<Voucher__c>();
        List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234'));
        List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=5, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null));
        List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=2, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c='987110234'));
        List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Czech_Republic_Corn_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Closed', PhoneCopy__c=null));
        insert List_Vouchers;
        
        CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Free of charge');
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignPY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Free of charge');
        insert new List<CampaignLineItem__c>{cli1, cli2, cli3, cli4};
        
        Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn');
        insert CornGroup;
        
        Product_Grouping__c GrainType = new Product_Grouping__c(Name='Grain', ProductGroupRef__c=CornGroup.Id);
        insert GrainType;
        
        Acreage__c acr1 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Account1.Id, AcrYearRef__c=CY.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=CornGroup.Id, AcrProductTypeRef__c=GrainType.Id);
        insert acr1;
        
        VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[2].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli6 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli7 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli8 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Free of charge');
        insert new List<VoucherLineItem__c>{vli1, vli2, vli3, vli4, vli5, vli6, vli7, vli8};
        
        List_Vouchers[0].Status__c = 'Cancelled';
        update List_Vouchers[0];
        
        Test.StopTest();

    }
    
    @isTest
    static void Test2_Ini() {
        
        User RomanianUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
        RomanianUser.Country = 'Romania';
        RomanianUser.CountryISOCode__c = 'RO';
        update RomanianUser;
        
        Year__c PY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2015,1,1), YearEndDate__c=date.newinstance(2015,12,31), Current_Year__c=false);
        insert PY;
        
        Year__c CY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2016,1,1), YearEndDate__c=date.newinstance(2999,12,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
        insert CY;
        
        Division__c OSR = new Division__c(Name='OSR');
        insert OSR;
        
        Country__c C_Romania = new Country__c(Name='Romania');
        insert C_Romania;
        
        ProductCatalog__c Romania_OSR_Sales_2016 = new ProductCatalog__c(Name='Romania - OSR - Sales - 2016', CountryRef__c=C_Romania.Id, DivisionRef__c=OSR.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
        insert Romania_OSR_Sales_2016;
        
        Campaign CampaignRO = new Campaign(YearV2__c=CY.Id, CountryRef__c=C_Romania.Id, OwnerId=RomanianUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Romania_OSR_Sales_2016.Id, DivisionRef__c=OSR.Id, RecordTypeId=Util.RecordType.get('Campaign:Sales_camp'));
        insert CampaignRO;
        
        Test.StartTest();
        
        Account Account1_RO = new Account(CountryRef__c=C_Romania.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST', CornTotalSalesPY__c=10, NUM_AGREED_OSR_CY__c=300, CornTotalAcreagesCY__c=140, OwnerId=RomanianUser.id, RecordTypeId=Util.RecordType.get('Account:GroupFarmSite'), Category__c='Farm');
        Account Account2_RO = new Account(CountryRef__c=C_Romania.Id, Name='TEST2', City__c='TEST', StateProvince__c='TEST', CornTotalSalesPY__c=10, NUM_AGREED_OSR_CY__c=500, CornTotalAcreagesCY__c=500, OwnerId=RomanianUser.id, RecordTypeId=Util.RecordType.get('Account:GroupFarmSite'), Category__c='Farm');
        Account AccountDist = new Account(CountryRef__c=C_Romania.Id, Name='TEST3', City__c='TEST', StateProvince__c='TEST', OwnerId=RomanianUser.id, RecordTypeId=Util.RecordType.get('Account:DistRetPoS'), Category__c='Distributor');
        insert new List<Account>{Account1_RO, Account2_RO, AccountDist};
        
        Contact contact1_RO = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1_RO.Id,  Decision_Maker__c=true, Phone=null, MobilePhone='987002765', Position_picklist__c='CEO');
        Contact contact2_RO = new Contact(FirstName='TEST', LastName='TEST2', AccountId=Account2_RO.Id,  Decision_Maker__c=true, Phone=null, MobilePhone=null, Position_picklist__c='Other');
        insert new List<Contact>{Contact1_RO, Contact2_RO};
        
        VoucherCampaign__c Romania_OSR_2016 = new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=OSR.Id, BagSize__c=1500, CountryRef__c=C_Romania.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=2, MinTotalBags__c=1, CHCK_FOCBags_AP__c=false);
        insert Romania_OSR_2016;
        
         Discount__c d1_RO = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_OSR_2016.Id, NUM_DiscountperBag__c=50, PICK_Applies_to__c='Premium', MinBags__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.NUM_AGREED_OSR_CY__c', NUM_Min_First_Ladder__c=3, NUM_Max_First_Ladder__c=299);
        Discount__c d2_RO = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_OSR_2016.Id, PercentIncreaseInBags__c=70, PICK_Applies_to__c='Premium', MinBags__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.NUM_AGREED_OSR_CY__c', NUM_Min_First_Ladder__c=300);
        Discount__c d3_RO = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_OSR_2016.Id, NUM_DiscountperBag__c=0, PICK_Applies_to__c='Premium', MinBags__c=0,  TXT_Min_First_Ladder_Field__c='AccountRef__r.NUM_AGREED_OSR_CY__c', NUM_Min_First_Ladder__c=0, NUM_Max_First_Ladder__c=2);
        Discount__c d4_RO = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Volume'), VoucherCampaignRef__c=Romania_OSR_2016.Id, NUM_DiscountperBag__c=0,     PercentIncreaseInBags__c = 0, PercentIncreaseInPrice__c = 0,    DiscountInPrice__c = 0, PICK_Applies_to__c='Premium', MinBags__c=0, MaxBags__c = 99999999);
        insert new List<Discount__c> {d1_RO, d2_RO, d3_RO, d4_RO};
        
        Product2 pr1_RO = new Product2(Name='TEST3', ProductSAPCode__c='13131313', DivisionRef__c=OSR.Id, productBagSize__c=1500, ProductMaturity__c=200, RecordTypeId=Util.recordType.get('Product2:OSRSalesProduct'), ProductHybridGroup__c = 'CLASIC', ProductVendor__c = AccountDist.Id);
        Product2 pr2_RO = new Product2(Name='TEST4', ProductSAPCode__c='65464654', DivisionRef__c=OSR.Id, productBagSize__c=1500, ProductMaturity__c=200, RecordTypeId=Util.recordType.get('Product2:OSRSalesProduct'), ProductHybridGroup__c = 'CLASIC', ProductVendor__c = AccountDist.Id);
        insert new List<Product2> {pr1_RO, pr2_RO};
        
        ProductCatalogEntry__c pce1_RO = new ProductCatalogEntry__c(ProductCatalogRef__c=Romania_OSR_Sales_2016.Id, OwnerId=RomanianUser.Id, ProductRef__c=pr1_RO.Id, Price__c=699, NewProduct__c=true, VoucherProduct__c=true,     Allocation__c = 10000, IsActive__c = true);
        ProductCatalogEntry__c pce2_RO = new ProductCatalogEntry__c(ProductCatalogRef__c=Romania_OSR_Sales_2016.Id, OwnerId=RomanianUser.Id, ProductRef__c=pr2_RO.Id, Price__c=500, DE_isPremium__c=true, VoucherProduct__c=true,   Allocation__c = 10000, IsActive__c = true);
        insert new List<ProductCatalogEntry__c>{pce1_RO, pce2_RO};
        
        List_VouchersRO = new List<Voucher__c>();
        List_VouchersRO.add(new Voucher__c(OwnerId=RomanianUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact1_RO.Id, AccountRef__c=Account1_RO.Id, CampaignRef__c=CampaignRO.Id, VoucherCampaignRef__c=Romania_OSR_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=500, Status__c='Cancelled', PhoneCopy__c='987110234'));
        List_VouchersRO.add(new Voucher__c(OwnerId=RomanianUser.Id, DiscretionaryDiscount__c=5, LKP_CONTACT__c=Contact1_RO.Id, AccountRef__c=Account1_RO.Id, CampaignRef__c=CampaignRO.Id, VoucherCampaignRef__c=Romania_OSR_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=300, Status__c='Closed', PhoneCopy__c=null));
        List_VouchersRO.add(new Voucher__c(OwnerId=RomanianUser.Id, DiscretionaryDiscount__c=2, LKP_CONTACT__c=Contact2_RO.Id, AccountRef__c=Account2_RO.Id, CampaignRef__c=CampaignRO.Id, VoucherCampaignRef__c=Romania_OSR_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=300, Status__c='Closed', PhoneCopy__c='987110234'));
        List_VouchersRO.add(new Voucher__c(OwnerId=RomanianUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact2_RO.Id, AccountRef__c=Account2_RO.Id, CampaignRef__c=CampaignRO.Id, VoucherCampaignRef__c=Romania_OSR_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Closed', PhoneCopy__c=null));
        insert List_VouchersRO;
        
        CampaignLineItem__c cli1_RO = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=500, ProductCatalogEntryRef__c=pce1_RO.Id, OwnerId=RomanianUser.Id, FarmRef__c=Account1_RO.Id, CampaignRef__c=CampaignRO.Id, PlantingDensity__c='30000', ProductRef__c=pr1_RO.Id, Quantity__c=500, Status__c='Ordered / Discussed', Type__c='Charged');
        CampaignLineItem__c cli2_RO = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=300, ProductCatalogEntryRef__c=pce1_RO.Id, OwnerId=RomanianUser.Id, FarmRef__c=Account2_RO.Id, CampaignRef__c=CampaignRO.Id, PlantingDensity__c='30000', ProductRef__c=pr1_RO.Id, Quantity__c=300, Status__c='Ordered / Discussed', Type__c='Charged');
        CampaignLineItem__c cli3_RO = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=300, ProductCatalogEntryRef__c=pce2_RO.Id, OwnerId=RomanianUser.Id, FarmRef__c=Account1_RO.Id, CampaignRef__c=CampaignRO.Id, PlantingDensity__c='30000', ProductRef__c=pr2_RO.Id, Quantity__c=300, Status__c='Ordered / Discussed', Type__c='Charged');
        CampaignLineItem__c cli4_RO = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=300, ProductCatalogEntryRef__c=pce2_RO.Id, OwnerId=RomanianUser.Id, FarmRef__c=Account2_RO.Id, CampaignRef__c=CampaignRO.Id, PlantingDensity__c='30000', ProductRef__c=pr2_RO.Id, Quantity__c=300, Status__c='Ordered / Discussed', Type__c='Charged');
        insert new List<CampaignLineItem__c>{cli1_RO, cli2_RO, cli3_RO, cli4_RO};
        
        Product_Grouping__c OSRGroup = new Product_Grouping__c(Name='OSR');
        insert OSRGroup;
        
        Product_Grouping__c GrainTypeRO = new Product_Grouping__c(Name='Grain', ProductGroupRef__c=OSRGroup.Id);
        insert GrainTypeRO;
        
        Acreage__c acr1_RO = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Account1_RO.Id, AcrYearRef__c=CY.Id, AcrTotalAcreages__c=1000, AcrProductGroupRef__c=OSRGroup.Id, AcrProductTypeRef__c=GrainTypeRO.Id);
        insert acr1_RO;
        
        VoucherLineItem__c vli1_RO = new VoucherLineItem__c(CampaignLineItemRef__c=cli1_RO.Id,VoucherRef__c=List_VouchersRO[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=500,Bags__c=500,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2_RO = new VoucherLineItem__c(CampaignLineItemRef__c=cli2_RO.Id,VoucherRef__c=List_VouchersRO[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli3_RO = new VoucherLineItem__c(CampaignLineItemRef__c=cli3_RO.Id,VoucherRef__c=List_VouchersRO[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=500,Bags__c=500,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4_RO = new VoucherLineItem__c(CampaignLineItemRef__c=cli4_RO.Id,VoucherRef__c=List_VouchersRO[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');

        insert new List<VoucherLineItem__c>{vli1_RO, vli2_RO, vli3_RO, vli4_RO};
        
        List_VouchersRO[0].Status__c = 'Cancelled';
        update List_VouchersRO[0];
        
        Test.StopTest();
    }
}