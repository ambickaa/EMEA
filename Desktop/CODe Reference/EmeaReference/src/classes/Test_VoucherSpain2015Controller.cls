@isTest
private class Test_VoucherSpain2015Controller {
	
	public static List<Voucher__c> List_Vouchers;
	
	private static void Test_Ini() {
		
		User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'Spain';
		update currentUser;
		
		Year__c PY = new Year__c(Name='2014', YearStartDate__c=date.newinstance(2013,11,1), YearEndDate__c=date.newinstance(2014,10,31), Current_Year__c=false);
		insert PY;
		
		Year__c CY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2014,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
		insert CY;
		
		Division__c Corn = new Division__c(Name='Corn');
		insert Corn;
		    
		Country__c Spain = new Country__c(Name='Spain');
		insert Spain;
		
		ProductCatalog__c Spain_Corn_Sales_2015 = new ProductCatalog__c(Name='Spain - Corn - Sales - 2015', CountryRef__c=Spain.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
		insert Spain_Corn_Sales_2015;
		
		Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Spain.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Spain_Corn_Sales_2015.Id, DivisionRef__c=Corn.Id);
		Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Spain.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Spain_Corn_Sales_2015.Id, DivisionRef__c=Corn.Id);              
		insert new List<Campaign>{CampaignPY, CampaignCY};
		
		Account Account1 = new Account(CountryRef__c=Spain.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST');
		insert Account1;
		
		Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1.Id, Phone=null, MobilePhone='987002765');
		insert Contact1;
		
		VoucherCampaign__c Spain_Corn_2015 = new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=Corn.Id, BagSize__c=80, CountryRef__c=Spain.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=1, MinTotalBags__c=1);
		insert Spain_Corn_2015;
		
		Product2 pr1 = new Product2(Name='TEST1', ProductSAPCode__c='12123213', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		Product2 pr2 = new Product2(Name='TEST2', ProductSAPCode__c='12444444', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		insert new List<Product2> {pr1, pr2};
		
		ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Spain_Corn_Sales_2015.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id);
		ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=Spain_Corn_Sales_2015.Id, OwnerId=currentUser.Id, ProductRef__c=pr2.Id);
		insert new List<ProductCatalogEntry__c>{pce1, pce2};
		
		List_Vouchers = new List<Voucher__c>();
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Spain_Corn_2015.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234'));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Spain_Corn_2015.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null));
		insert List_Vouchers;
		
		CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=10, Agreed__c=5, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
		CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=20, Agreed__c=20, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=20, Status__c='Confirmed', Type__c='Charged');
		insert new List<CampaignLineItem__c>{cli1, cli2};
		
		Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn');
		insert CornGroup;
		
		Product_Grouping__c GrainType = new Product_Grouping__c(Name='Grain', ProductGroupRef__c=CornGroup.Id);
		insert GrainType;
		
		Acreage__c acr1 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Account1.Id, AcrYearRef__c=PY.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=CornGroup.Id, AcrProductTypeRef__c=GrainType.Id);
		insert acr1;
		
		VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=5,Bags__c=5,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=5,Bags__c=5,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		insert new List<VoucherLineItem__c>{vli1, vli2, vli3, vli4};

	}

    static testMethod void Testing_SP_Corn_2015_Voucher() {
    	
		Test_Ini();
		Test.StartTest();
		
		ApexPages.StandardController Voucher_0 = new ApexPages.StandardController(List_Vouchers[0]);
		VoucherSpain2015Controller Controller_0 = new VoucherSpain2015Controller(Voucher_0);
		
		ApexPages.StandardController Voucher_1 = new ApexPages.StandardController(List_Vouchers[1]);
		VoucherSpain2015Controller Controller_1 = new VoucherSpain2015Controller(Voucher_1);
		
		Test.StopTest();
    }
}