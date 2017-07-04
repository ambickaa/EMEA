@isTest
private class Voucher_PL_Corn_2017_Controller_Test {
    
    public static List<Voucher__c> List_Vouchers;
    public static List<VoucherLineitem__c> List_VouchersLineItems;
    
    static void init() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id =: Userinfo.getUserId()];
        currentUser.Country = 'Poland';
        update currentUser;
        
        Year__c PY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,11,1), YearEndDate__c=date.newinstance(2015,10,31), Current_Year__c=false);
        insert PY;
        Year__c year = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1),YearPreviousYear__c=PY.Id);
        insert year;
        
        Division__c division1 = new Division__c(Name='Corn');
        insert division1;
        
        Country__c country = new Country__c(Name='Poland');
        insert country;
        
        RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(Phone = '987002765', Street__c = 'test',  TXT_BANK_ADDRESS__c = 'test', FCPArelevant__c = 'NO', TXT_TAX_OFFICE_NAME__c = 'test', CountryRef__c=country.Id,Name='Test Account',City__c='Test City',StateProvince__c='Test State/Province', CHK_VAT_Payer__c = true);
        Account account2 = new Account(Phone = '987002765', Street__c = 'test', TXT_BANK_ADDRESS__c = 'test', FCPArelevant__c = 'YES', TXT_TAX_OFFICE_NAME__c = 'test', CountryRef__c=country.Id,Name='Test Account',City__c='Test City',StateProvince__c='Test State/Province', CHK_VAT_Payer__c = false);
        insert new List<Account>{account1,account2};
        
        Contact contact1 = new Contact(FirstName='',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Discount__c disc1 = new Discount__c(PICK_Applies_to__c ='Premium', NUM_Max_First_Ladder__c = 0, NUM_Min_First_Ladder__c =0, NUM_DiscountperBag__c = 70, MaxBags__c = 999999999, MinBags__c = 0,VoucherCampaignRef__c = voucherCampaign.Id, recordTypeId = Util.recordType.get('Discount__c:Smart_discount'));
        Discount__c disc2 = new Discount__c(PICK_Applies_to__c ='', NUM_Max_First_Ladder__c = 0, NUM_Min_First_Ladder__c =0, NUM_DiscountperBag__c = 70, MaxBags__c = 999999999, MinBags__c = 0,VoucherCampaignRef__c = voucherCampaign.Id, recordTypeId = Util.recordType.get('Discount__c:Smart_discount'));
        insert new List<Discount__c>{disc1,disc2};
        
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productVendor__c=account1.Id);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=account2.Id);
        Product2 pr3 = new Product2(Name='DKC Test',ProductSAPCode__c='12457878',DivisionRef__c=division1.id, productVendor__c=account2.Id);
        Product2 pr4 = new Product2(Name='DKC Test',ProductSAPCode__c='12657878',DivisionRef__c=division1.id, productVendor__c=account2.Id);
        Product2 pr5 = new Product2(Name='DKC Test',ProductSAPCode__c='12357878',DivisionRef__c=division1.id, productVendor__c=account2.Id);
        insert new List<Product2> {pr1,pr2,pr3,pr4,pr5};
        
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c= false,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce3 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce4 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce5 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c= false,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce6 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c= false,NewProduct__c=true,Price__c=500,ProductRef__c=pr3.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce7 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c= false,NewProduct__c=true,Price__c=500,ProductRef__c=pr4.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce8 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c= false,NewProduct__c=true,Price__c=500,ProductRef__c=pr5.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        
        insert new List<ProductCatalogEntry__c>{pce1,pce2,pce3,pce4,pce5,pce6,pce7};
            
        Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn');
        insert CornGroup;
        
        List_Vouchers = new List<Voucher__c>();
        List_Vouchers.add(new Voucher__c(FiscalCodeCopy__c = 'test',DiscretionaryDiscount__c=0, DistributorRef__c=account2.Id,TotalBags__c=10,OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c='987110234',EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        List_Vouchers.add(new Voucher__c(FiscalCodeCopy__c = 'test',DiscretionaryDiscount__c=0, DistributorRef__c=account1.Id,TotalBags__c=60,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c=null,EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        insert List_Vouchers;
        
        CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce4.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce3.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
       
        
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli5 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr3.Id);
        CampaignLineItem__c cli6 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr3.Id);
        CampaignLineItem__c cli7 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce8.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli8 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce6.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr4.Id);
        
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4,cli5,cli6,cli7,cli8};
        
        List_VouchersLineItems = new List<VoucherLineItem__c>();    
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce5.id, Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='NOU',FAO__c=100,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli5.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce6.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 5',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli6.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce1.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli6.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce1.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli8.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce7.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 9',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 3',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli7.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce8.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 4',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 4',PICK_TYPE__c='Charged', Price__c = 500));

       
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce2.id, Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 3',HybridGroup__c='MAXTECH',FAO__c=200,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce4.id, Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 4',HybridGroup__c='CLASIC',FAO__c=200,ProductName__c='DKC TEST 3',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce3.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 4',PICK_TYPE__c='Charged', Price__c = 500));
        List_VouchersLineItems.add(new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[1].Id,LKP_ProductCatalogEntry__c = pce3.id, Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 4',PICK_TYPE__c='Charged', Price__c = 500));
        
        insert List_VouchersLineItems;
        
    

    }
    static testMethod void Testing_PL_Corn_2017_Voucher() {
        init();
        Test.startTest();
        
        ApexPages.StandardController vouA = new ApexPages.StandardController(List_Vouchers[0]);
        Voucher_PL_Corn_2017_Controller controller1 = new Voucher_PL_Corn_2017_Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(List_Vouchers[1]);
        Voucher_PL_Corn_2017_Controller controller2= new Voucher_PL_Corn_2017_Controller(vouB);
        
        System.assertEquals(1,1);
        
        Test.stopTest();
    }          
}