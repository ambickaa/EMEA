@isTest
private class Test_ExcelExportOSRReportControllerNew {
    
    private static Account testDistributoroAccount = TestInit.createNewDistributor();
    private static Account testCompetitorAccount = TestInit.createNewCompetitor();
    private static Account testAccount =TestInit.createNewFarmer();
    
    @isTest
    static void init()
    {
    
        Country__c Country= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert Country;
        
        Division__c Division= new Division__c();
        insert Division;
        Account Account= new Account(CountryRef__c=Country.ID, Name='DETestAccount', DE_CustomerOSRSeeds__c='A');
        Account Account2= new Account(CountryRef__c=Country.ID, Name='DETestDist',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Category__c='Distributor' );
        insert Account;                    
        insert  Account2;

        retoure__c Retoure= new retoure__c(Account__C=Account.id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure1__c = 0, Retoure2__c = 0, Retoure3__c = 0, TXT_year__c='2016', NUM_ExceptionRabatt__c=5, NUM_ExpansionRabatt__c=5, RabattMenge__c=4);
        insert Retoure;

        datetime myDateTime = datetime.now();
        datetime newDate = myDateTime .addYears(-1);
        datetime newDate2 = myDateTime .addYears(1);

         //previus year test
                         
        Year__c Year= new Year__c (Name='2017', Current_Year__c=true, YearEndDate__c=date.newinstance(2018, 12, 31), YearStartDate__c=date.newinstance(2017, 1, 1));
        Year__c Year2= new Year__c (Name='2016', Current_Year__c=false, YearEndDate__c=date.newinstance(2017, 12, 31), YearStartDate__c=date.newinstance(2016, 1, 1));
        Year__c Year3= new Year__c (Name='2015', Current_Year__c=false, YearEndDate__c=date.newinstance(2016, 12, 31), YearStartDate__c=date.newinstance(2015, 1, 1));

        insert Year;
        insert Year2;
        insert Year3;
        
        ID SalesRecordTypeID =  Util.recordType.get('ProductCatalog__c:SalesProductCatalog');
        
        ProductCatalog__c ProductCatalog =new ProductCatalog__c(RecordTypeID=SalesRecordTypeID, CountryRef__c=Country.ID,  DivisionRef__c=Division.ID, YearRef__c=Year.ID);
        insert ProductCatalog;
                       
        Product2 Product1  = new Product2(RecordTypeID= Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123123', Name='L DK DK EXCEPTION 2000MVK CT ZZ22', Description= 'DK EXCEPTION', DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram+DMM');
                    
        Product2 Product2= new Product2(RecordTypeID=Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123124', Name='L DK DK EXIMUS 1500MVK EB ZZ22', 
                    Description='DK EXIMUS', DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram');
                    
         Product2 Product3= new Product2(RecordTypeID= Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123125', Name='LT DK DK EXPANSION 500MKGTR EA', 
                    Description='DK EXPANSION', DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram+DMM');
                    
        Product2 Product4= new Product2(RecordTypeID=Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123126', Name='L DK DK CAMELOT 2000MVK CT ZZ22', 
                    DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram');                 
        
        Product2 Product5= new Product2(RecordTypeID= Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123127', Name='L DK DK EXQUISITE 1500MVK EB ZZ22', 
                    DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram+DMM');
                    
        Product2 Product6= new Product2(RecordTypeID=Util.recordType.get('Product2:OSRSalesProduct'), IsActive=true, ProductCode='A123123129', Name='LT DK DK CAMELOT 500MKGTR EA', 
                    DivisionRef__c=Division.ID, DE_ZVD_Typ__c='H', DE_ZVD_Reife__c='früh',ProductBagSize__c=1000, ProductTreatment__c='Thiram+DMM');                    
        
        
        insert new List<Product2>{Product1, Product2, Product3, Product4, Product5, Product6};
                    
        ProductCatalogEntry__c PCE1= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true, DE_Sorten__c ='A', ProductRef__c=Product1.ID);
        ProductCatalogEntry__c PCE2= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true, DE_Sorten__c ='A', ProductRef__c=Product2.ID);
        ProductCatalogEntry__c PCE3= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true,DE_Sorten__c ='A', ProductRef__c=Product3.ID);
        ProductCatalogEntry__c PCE4= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true, DE_Sorten__c ='A', ProductRef__c=Product4.ID);
        ProductCatalogEntry__c PCE5= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true, DE_Sorten__c ='B', ProductRef__c=Product5.ID);
        ProductCatalogEntry__c PCE6= new ProductCatalogEntry__c(ProductCatalogRef__c=ProductCatalog.ID,isActive__c=true, CHK_ZVD__c=true, DE_isPremium__c=true, DE_Sorten__c ='B', ProductRef__c=Product6.ID);

        insert new List<ProductCatalogEntry__c>{PCE1, PCE2, PCE3, PCE4, PCE5, PCE6};
            
        Campaign Campaign= new Campaign(RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=Year.ID, CountryRef__c=Country.ID, DivisionRef__c=Division.ID,TotalCampaignBudget__c=1000, StartDate=Year.YearStartDate__c, 
                    EndDate=Year.YearEndDate__c, ArchiveDate__c=Year.YearEndDate__c, isActive=true, SalesPCMRef__c=ProductCatalog.ID);
          
        Campaign Campaign2= new Campaign(isActive=false, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=Year2.ID, CountryRef__c=Country.ID, DivisionRef__c=Division.ID,TotalCampaignBudget__c=1000, StartDate=Year2.YearStartDate__c,
                    EndDate=Year2.YearEndDate__c, ArchiveDate__c=Year2.YearEndDate__c, SalesPCMRef__c=ProductCatalog.ID);
        Campaign Campaign3= new Campaign(isActive=false, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=Year3.ID, CountryRef__c=Country.ID, DivisionRef__c=Division.ID,TotalCampaignBudget__c=1000, StartDate=Year3.YearStartDate__c,
                    EndDate=Year3.YearEndDate__c, ArchiveDate__c=Year.YearEndDate__c, SalesPCMRef__c=ProductCatalog.ID, StatusCode__c=300);

          
        insert Campaign;
        insert Campaign2;
        insert Campaign3;

        CampaignLineItem__c CLI1=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=100, POG__c=200,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product1.ID, FarmRef__c=Account.ID, Type__c='Charged', ProductCatalogEntryRef__c=PCE1.ID, DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        
        CampaignLineItem__c CLI2=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=101, POG__c=201,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product2.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE2.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=false);

        CampaignLineItem__c CLI3=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=102, POG__c=202,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product3.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE3.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=false);
        
        CampaignLineItem__c CLI4=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=103, POG__c=203,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product4.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE4.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);

        CampaignLineItem__c CLI5=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=104, POG__c=204,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product5.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE5.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        
        CampaignLineItem__c CLI6=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=105, POG__c=205,
                    CampaignRef__c=Campaign.ID, ProductRef__c=Product6.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE6.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
                    
        //pre previus year

 CampaignLineItem__c CLI1a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=111, POG__c=222,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product1.ID, FarmRef__c=Account.ID, Type__c='Charged', ProductCatalogEntryRef__c=PCE1.ID, DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        
        CampaignLineItem__c CLI2a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=101, POG__c=201,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product2.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE2.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=false);

        CampaignLineItem__c CLI3a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=102, POG__c=202,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product3.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE3.ID,DE_DistributorRef__c=Account2.ID);
        
        CampaignLineItem__c CLI4a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=103, POG__c=203,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product4.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE4.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);

        CampaignLineItem__c CLI5a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=104, POG__c=204,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product5.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE5.ID,DE_DistributorRef__c=Account2.ID);
        
        CampaignLineItem__c CLI6a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=333, POG__c=444,
                    CampaignRef__c=Campaign2.ID, ProductRef__c=Product6.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE6.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        // previus year
        
         CampaignLineItem__c CLI1b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=666, POG__c=777,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product1.ID, FarmRef__c=Account.ID, Type__c='Charged', ProductCatalogEntryRef__c=PCE1.ID, DE_DistributorRef__c=Account2.ID);
        
        CampaignLineItem__c CLI2b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=101, POG__c=201,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product2.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE2.ID,DE_DistributorRef__c=Account2.ID);

        CampaignLineItem__c CLI3b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=102, POG__c=202,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product3.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE3.ID,DE_DistributorRef__c=Account2.ID);
        
        CampaignLineItem__c CLI4b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=103, POG__c=203,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product4.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE4.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);

        CampaignLineItem__c CLI5b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=104, POG__c=204,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product5.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE5.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        
        CampaignLineItem__c CLI6b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=888, POG__c=999,
                    CampaignRef__c=Campaign3.ID, ProductRef__c=Product6.ID, FarmRef__c=Account.ID, Type__c='Charged',ProductCatalogEntryRef__c=PCE6.ID,DE_DistributorRef__c=Account2.ID, DE_isPremium__c=true);
        
        CountryAdapter.allCountryMap=null;
        insert new List<CampaignLineItem__c >{cli1, cli2, cli3, cli4, cli5, cli6, cli1a, cli2a, cli3a, cli4a, cli5a, cli6a, cli1b, cli2b, cli3b, cli4b, cli5b, cli6b};

        Product_Grouping__c OSRGroup = new Product_Grouping__c(Name='OSR');
        insert OSRGroup;

        Acreage__c OSRAcreage = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Account.ID, AcrYearRef__c=Year.ID, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.ID);
        insert OSRAcreage;
        
        ApexPages.currentPage().getParameters().put('id', Account.ID); 
        ApexPages.currentPage().getParameters().put('division', Division.ID); 
        ApexPages.currentPage().getParameters().put('retoureId', Retoure.ID); 
        
        SystemSettings__c s1 = new SystemSettings__c( Name='DE_OSR_fruehkaufBis',Value__C='22.07.2016');
        SystemSettings__c s2 = new SystemSettings__c( Name='DE_ExcelDekalb',Value__C='http://i.imgur.com/tQTjnO7.png');
        SystemSettings__c s3 = new SystemSettings__c( Name='DE_OSR_GrundMarge',Value__C='5');
        
      insert s1;
      insert s2;
      insert s3;
      
        ExcelExportOSRReportControllerNew controller = new ExcelExportOSRReportControllerNew();
     }
}