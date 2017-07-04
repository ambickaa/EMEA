@isTest
private class Test_ExcelExportMonitorReportController {
    
    private static Account testDistributoroAccount = TestInit.createNewDistributor();
    private static Account testCompetitorAccount = TestInit.createNewCompetitor();
    private static Account testAccount =TestInit.createNewFarmer();
    
    @isTest
    static void init()
    {
    
        Country__c toCountry= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert toCountry;

                Division__c toDivision= new Division__c();
        insert toDivision;
        Account toAccount= new Account(CountryRef__c=toCountry.ID, Name='DETestAccount');
        Account toAccount2= new Account(CountryRef__c=toCountry.ID, Name='DETestDist',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Category__c='Distributor' );
        Account Monsanto= new Account(CountryRef__c=toCountry.ID, Name='Monsanto');
        insert toAccount;  
                  
        insert  toAccount2;
        insert Monsanto;

        retoure__c toRetoure= new retoure__c(Account__C=toAccount.id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure;

        datetime myDateTime = datetime.now();
         datetime newDate = myDateTime .addYears(-1);
         datetime newDate2 = myDateTime .addYears(1);

         //previus year test
                         
        Year__c toYear2= new Year__c (Name='2011', Current_Year__c=false, YearEndDate__c=date.newinstance(2011, 12, 31), YearStartDate__c=date.newinstance(2011, 1, 1));
        Year__c toYear3= new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), YearStartDate__c=date.newinstance(2012, 1, 1));

        Year__c toYear= new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2013, 12, 31), YearStartDate__c=date.newinstance(2013, 1, 1));
        insert toYear;
        insert toYear2;
        insert toYear3;
        
        ID SalesRecordTypeID =  Util.recordType.get('ProductCatalog__c:SalesProductCatalog');
        
        ProductCatalog__c toProductCatalog =new ProductCatalog__c(RecordTypeID=SalesRecordTypeID, CountryRef__c=toCountry.ID,  DivisionRef__c=toDivision.ID, YearRef__c=toYear.ID);
        insert toProductCatalog;
                       
        Product2 toProduct1= new Product2(RecordTypeID= Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123123', Name='LAT100', DE_BasicUnits__c=100,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);
                    
        Product2 toProduct2= new Product2(RecordTypeID=Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123124', Name='LAT200', DE_BasicUnits__c=200,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);
                    
         Product2 toProduct3= new Product2(RecordTypeID= Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123125', Name='LAT300', DE_BasicUnits__c=300,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);
                    
        Product2 toProduct4= new Product2(RecordTypeID=Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123126', Name='LAT400', DE_BasicUnits__c=400,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);                 
        
        Product2 toProduct5= new Product2(RecordTypeID= Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123127', Name='LAT500', DE_BasicUnits__c=500,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);
                    
        Product2 toProduct6= new Product2(RecordTypeID=Util.recordType.get('Product2:CPSalesProduct'), IsActive=true, ProductCode='A123123129', Name='LAT600', DE_BasicUnits__c=600,
                    DivisionRef__c=toDivision.ID, ProductVendor__c=Monsanto.ID);                    
        
        
        insert new List<Product2>{toProduct1, toProduct2, toProduct3, toProduct4, toProduct5, toProduct6};
                    
        ProductCatalogEntry__c toPCM1= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct1.ID);
        ProductCatalogEntry__c toPCM2= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct2.ID);
        ProductCatalogEntry__c toPCM3= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct3.ID);
        ProductCatalogEntry__c toPCM4= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct4.ID);
        ProductCatalogEntry__c toPCM5= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct5.ID);
        ProductCatalogEntry__c toPCM6= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, ProductRef__c=toProduct6.ID);

        insert new List<ProductCatalogEntry__c>{toPCM1, toPCM2, toPCM3, toPCM4, toPCM5, toPCM6};
            
        Campaign toCampaign= new Campaign(isActive=true, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=toYear.ID, CountryRef__c=toCountry.ID, DivisionRef__c=toDivision.ID,TotalCampaignBudget__c=1000, StartDate=toYear.YearStartDate__c,
                    EndDate=toYear.YearEndDate__c, ArchiveDate__c=toYear.YearEndDate__c, SalesPCMRef__c=toProductCatalog.ID);
          
        Campaign toCampaign2= new Campaign(isActive=false, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=toYear2.ID, CountryRef__c=toCountry.ID, DivisionRef__c=toDivision.ID,TotalCampaignBudget__c=1000, StartDate=toYear2.YearStartDate__c,
                    EndDate=toYear2.YearEndDate__c, ArchiveDate__c=toYear2.YearEndDate__c, SalesPCMRef__c=toProductCatalog.ID);
        Campaign toCampaign3= new Campaign(isActive=false, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=toYear3.ID, CountryRef__c=toCountry.ID, DivisionRef__c=toDivision.ID,TotalCampaignBudget__c=1000, StartDate=toYear3.YearStartDate__c,
                    EndDate=toYear3.YearEndDate__c, ArchiveDate__c=toYear3.YearEndDate__c, SalesPCMRef__c=toProductCatalog.ID);

          
        insert toCampaign;
        insert toCampaign2;
        insert toCampaign3;

        CampaignLineItem__c CLI1=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=100, POG__c=200,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct1.ID, FarmRef__c=toAccount.ID, Type__c='Charged', ProductCatalogEntryRef__c=toPCM1.ID, DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI2=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=101, POG__c=201,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct2.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM2.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI3=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=102, POG__c=202,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct3.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM3.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI4=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=103, POG__c=203,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct4.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM4.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI5=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=104, POG__c=204,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct5.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM5.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI6=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=105, POG__c=205,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct6.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM6.ID,DE_DistributorRef__c=toAccount2.ID);
                    
        //pre previus year

 CampaignLineItem__c CLI1a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=111, POG__c=222,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct1.ID, FarmRef__c=toAccount.ID, Type__c='Charged', ProductCatalogEntryRef__c=toPCM1.ID, DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI2a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=101, POG__c=201,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct2.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM2.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI3a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=102, POG__c=202,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct3.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM3.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI4a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=103, POG__c=203,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct4.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM4.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI5a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=104, POG__c=204,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct5.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM5.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI6a=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=333, POG__c=444,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct6.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM6.ID,DE_DistributorRef__c=toAccount2.ID);
        // previus year
        
         CampaignLineItem__c CLI1b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=666, POG__c=777,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct1.ID, FarmRef__c=toAccount.ID, Type__c='Charged', ProductCatalogEntryRef__c=toPCM1.ID, DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI2b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=101, POG__c=201,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct2.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM2.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI3b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=102, POG__c=202,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct3.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM3.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI4b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=103, POG__c=203,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct4.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM4.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI5b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=104, POG__c=204,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct5.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM5.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI6b=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=888, POG__c=999,
                    CampaignRef__c=toCampaign3.ID, ProductRef__c=toProduct6.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM6.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CountryAdapter.allCountryMap=null;
        insert new List<CampaignLineItem__c >{cli1, cli2, cli3, cli4, cli5, cli6, cli1a, cli2a, cli3a, cli4a, cli5a, cli6a, cli1b, cli2b, cli3b, cli4b, cli5b, cli6b};

      
            
        
        ApexPages.currentPage().getParameters().put('id', toAccount.ID); 
        ApexPages.currentPage().getParameters().put('division', toDivision.ID); 
        ApexPages.currentPage().getParameters().put('retoureId', toRetoure.ID); 

        ExcelExportMonitorReportController controller = new ExcelExportMonitorReportController ();
        
        SystemSettings__c s1 = new SystemSettings__c( Name='DE_BonusMON',Value__C='10.5');

       insert s1;
       /*
       System.assertEquals(controller.getMON_FOC (),10.5);       

 
        //current year asserts
        System.assertEquals(controller.MonitorInfo.get(cli1.ID).get('Forecast'),100);
        System.assertEquals(controller.MonitorInfo.get(cli1.ID).get('PoG'),200);
        System.assertEquals(controller.MonitorInfo.get(cli1.ID).get('BasicUnits'),100);

        System.assertEquals(controller.MonitorInfo.get(cli2.ID).get('Forecast'),101);
        System.assertEquals(controller.MonitorInfo.get(cli2.ID).get('PoG'),201);
        System.assertEquals(controller.MonitorInfo.get(cli2.ID).get('BasicUnits'),200);
        
        System.assertEquals(controller.MonitorInfo.get(cli3.ID).get('Forecast'),102);
        System.assertEquals(controller.MonitorInfo.get(cli3.ID).get('PoG'),202);
        System.assertEquals(controller.MonitorInfo.get(cli3.ID).get('BasicUnits'),300);
        
        
        System.assertEquals(controller.MonitorInfo.get(cli4.ID).get('Forecast'),103);
        System.assertEquals(controller.MonitorInfo.get(cli4.ID).get('PoG'),203);
        System.assertEquals(controller.MonitorInfo.get(cli4.ID).get('BasicUnits'),400);
        
        
        System.assertEquals(controller.MonitorInfo.get(cli5.ID).get('Forecast'),104);
        System.assertEquals(controller.MonitorInfo.get(cli5.ID).get('PoG'),204);
        System.assertEquals(controller.MonitorInfo.get(cli5.ID).get('BasicUnits'),500);
        
        System.assertEquals(controller.MonitorInfo.get(cli6.ID).get('Forecast'),105);
        System.assertEquals(controller.MonitorInfo.get(cli6.ID).get('PoG'),205);
        System.assertEquals(controller.MonitorInfo.get(cli6.ID).get('BasicUnits'),600);
     */
  }   
}