@isTest
private class Test_ExcelExportCornReportcontroller{
    private static Account testDistributoroAccount = TestInit.createNewDistributor();
    private static Account testCompetitorAccount = TestInit.createNewCompetitor();
    private static Account testAccount =TestInit.createNewFarmer();
    @isTest
    static void init()
    {
        Country__c toCountry= new Country__c(Name='Germany', TacticalPlanSetting__c='German', DE_EnableAccountSharing__c=true);
        insert toCountry;
        SystemSettings__c sys1 = new SystemSettings__c( Name='DE_MAIS_GrundMarge',Value__C='4');
        SystemSettings__c sys2 = new SystemSettings__c( Name='DE_MAIS_fruehkaufBis',Value__C='17.07.2013');
        SystemSettings__c sys3 = new SystemSettings__c( Name='DE_ExcelDekalb',Value__C='http://i.imgur.com/tQTjnO7.png');
        insert new list<SystemSettings__c>{sys1, sys2,sys3};
        Division__c toDivision= new Division__c();
        insert toDivision;
        Account toAccount= new Account(CountryRef__c=toCountry.ID, Name='DETestAccount');
        Account toAccount2= new Account(CountryRef__c=toCountry.ID, Name='DETestDist',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),Category__c='Distributor' );
        
        insert toAccount;          
        insert  toAccount2;

        retoure__c toRetoure= new retoure__c(Account__C=toAccount.id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure;

        datetime myDateTime = datetime.now();
        datetime newDate = myDateTime .addYears(-1);
        datetime newDate2 = myDateTime .addYears(1);


        Year__c toYear= new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.valueof(newDate2), YearStartDate__c=date.valueof(newDate));
        insert toYear;
        // PY Year
        Year__c toYear2= new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), YearStartDate__c=date.newinstance(2012, 1, 1));
        insert toYear2;

        ID SalesRecordTypeID =  Util.recordType.get('ProductCatalog__c:SalesProductCatalog');
        
        ProductCatalog__c toProductCatalog =new ProductCatalog__c(RecordTypeID=SalesRecordTypeID, CountryRef__c=toCountry.ID,  DivisionRef__c=toDivision.ID, YearRef__c=toYear.ID);
        insert toProductCatalog;
                       
        ProductCatalog__c toProductCatalog2 =new ProductCatalog__c(RecordTypeID=SalesRecordTypeID, CountryRef__c=toCountry.ID,  DivisionRef__c=toDivision.ID, YearRef__c=toYear2.ID);
        insert toProductCatalog2;
        
        Product2 toProduct1= new Product2(RecordTypeID= Util.recordType.get('Product2:CornSalesProduct'), IsActive=true, ProductCode='A123123123', Name='TEST CORN', 
                    DivisionRef__c=toDivision.ID,ProductTreatment__c='Mesurol', ProductMaturity__c=100, DE_FAO_2__c=200);
                    
        Product2 toProduct2= new Product2(RecordTypeID=Util.recordType.get('Product2:CornSalesProduct'), IsActive=true, ProductCode='A123123124', Name='TEST CORN 2', 
                    DivisionRef__c=toDivision.ID,ProductTreatment__c='Thiram', ProductMaturity__c=100, DE_FAO_2__c=200);
                    
         Product2 toProduct3= new Product2(RecordTypeID= Util.recordType.get('Product2:CornSalesProduct'), IsActive=true, ProductCode='A123123125', Name='TEST CORN 3', 
                    DivisionRef__c=toDivision.ID,ProductTreatment__c='Mesurol', ProductMaturity__c=100, DE_FAO_2__c=200);
                    
        Product2 toProduct4= new Product2(RecordTypeID=Util.recordType.get('Product2:CornSalesProduct'), IsActive=true, ProductCode='A123123126', Name='TEST CORN 4', 
                    DivisionRef__c=toDivision.ID,ProductTreatment__c='Thiram', ProductMaturity__c=100, DE_FAO_2__c=200);                 
                    
        insert toProduct1;
        insert toProduct2;
        insert toProduct3;
        insert toProduct4;
            
        ProductCatalogEntry__c toPCM1= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, DE_isPremium__c=true, ProductRef__c=toProduct1.ID);
        ProductCatalogEntry__c toPCM2= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, DE_isPremium__c=true, ProductRef__c=toProduct2.ID);
        ProductCatalogEntry__c toPCM3= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, DE_isPremium__c=false, ProductRef__c=toProduct3.ID);
        ProductCatalogEntry__c toPCM4= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog.ID,isActive__c=true, DE_isPremium__c=false, ProductRef__c=toProduct4.ID);
		ProductCatalogEntry__c toPCM5= new ProductCatalogEntry__c(ProductCatalogRef__c=toProductCatalog2.ID,isActive__c=true, DE_isPremium__c=false, ProductRef__c=toProduct4.ID);
        insert new List<ProductCatalogEntry__c>{toPCM1, toPCM2, toPCM3, toPCM4, toPCM5};
            
        Campaign toCampaign= new Campaign(isActive=true, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=toYear.ID, CountryRef__c=toCountry.ID, DivisionRef__c=toDivision.ID,TotalCampaignBudget__c=1000, StartDate=toYear.YearStartDate__c,
                    EndDate=toYear.YearEndDate__c, ArchiveDate__c=toYear.YearEndDate__c, SalesPCMRef__c=toProductCatalog.ID);
        // campaign PY //
        Campaign toCampaign2= new Campaign(isActive=false, RecordTypeID=Util.recordType.get('Campaign:Sales_camp'),YearV2__c=toYear2.ID, CountryRef__c=toCountry.ID, DivisionRef__c=toDivision.ID,TotalCampaignBudget__c=1000, StartDate=toYear2.YearStartDate__c,
                    EndDate=toYear2.YearEndDate__c,	StatusCode__c = 300, ArchiveDate__c=toYear2.YearEndDate__c, SalesPCMRef__c=toProductCatalog2.ID);
        
        insert toCampaign;
		insert toCampaign2;
        CampaignLineItem__c CLI1=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), DE_isPremium__c = true, Agreed__c=100, POG__c=200,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct1.ID,FarmRef__c=toAccount.ID, Type__c='Charged', ProductCatalogEntryRef__c=toPCM1.ID, DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI2=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), DE_isPremium__c = true, Agreed__c=101, POG__c=201,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct2.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM2.ID,DE_DistributorRef__c=toAccount2.ID);

        CampaignLineItem__c CLI3=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=102, POG__c=202,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct3.ID, FarmRef__c=toAccount.ID, Type__c='Charged', ProductCatalogEntryRef__c=toPCM3.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI4=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=103, POG__c=203,
                    CampaignRef__c=toCampaign.ID, ProductRef__c=toProduct4.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM4.ID,DE_DistributorRef__c=toAccount2.ID);
        
        CampaignLineItem__c CLI5=new CampaignLineItem__c( RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=103, POG__c=203,
                    CampaignRef__c=toCampaign2.ID, ProductRef__c=toProduct4.ID, FarmRef__c=toAccount.ID, Type__c='Charged',ProductCatalogEntryRef__c=toPCM5.ID,DE_DistributorRef__c=toAccount2.ID);

        
        CountryAdapter.allCountryMap=null;
        insert new List<CampaignLineItem__c >{CLI1, CLI2, CLI3, CLI4, CLI5};

      
        ApexPages.currentPage().getParameters().put('id', toAccount.ID); 
        ApexPages.currentPage().getParameters().put('division', toDivision.ID); 
        ApexPages.currentPage().getParameters().put('retoureId', toRetoure.ID); 

        ExcelExportCornReportcontroller controller = new ExcelExportCornReportcontroller();
        
        SystemSettings__c s1 = new SystemSettings__c( Name='DE_MAIS_fruehkaufBis',Value__C='10.10.2013');
        SystemSettings__c s2 = new SystemSettings__c( Name='DE_MAIS_GrundMarge',Value__C='4');
		
        insert s1;
        insert s2;
        System.assertEquals(controller.getFruehkaufBis(),'10.10.2013');
        System.assertEquals(controller.getGrundMarge(),'4');
        System.assertEquals(controller.getExcelDekalb(),'http://i.imgur.com/tQTjnO7.png');
        System.debug('******Content PYear: ' + controller.PYear);
        System.debug('******PYearSet: ' + controller.getPYearSet()); 
        System.debug('******PremiumCornSet: ' + controller.getstandardCornSet()); 
        System.debug('******standardCornSet: ' + controller.getPremiumCornSet()); 

        if(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID) !=null){
            System.assertEquals(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID).get('AgreedMesurol'),'100');
            System.assertEquals(controller.PYear.get('TEST CORN 2' + '_' + toAccount2.ID).get('AgreedStandard'),'101');
            System.assertEquals(controller.PYear.get('TEST CORN 3' + '_' + toAccount2.ID).get('AgreedMesurol'),'102');
            System.assertEquals(controller.PYear.get('TEST CORN 4' + '_' + toAccount2.ID).get('AgreedStandard'),'103');
    
            System.assertEquals(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID).get('PoGMesurol'),'200');
            System.assertEquals(controller.PYear.get('TEST CORN 2' + '_' + toAccount2.ID).get('PoGStandard'),'201');
            System.assertEquals(controller.PYear.get('TEST CORN 3' + '_' + toAccount2.ID).get('PoGMesurol'),'202');
            System.assertEquals(controller.PYear.get('TEST CORN 4' + '_' + toAccount2.ID).get('PoGStandard'),'203');
               
            
            System.assertEquals(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.PYear.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.PYear.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.PYear.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO'),'100'); 
            
            System.assertEquals(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.PYear.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.PYear.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.PYear.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO2'),'200'); 
    
            System.assertEquals(controller.PYear.get('TEST CORN' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.PYear.get('TEST CORN 2' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.PYear.get('TEST CORN 3' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.PYear.get('TEST CORN 4' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');      
       }
	   if(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID) !=null){
            System.assertEquals(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID).get('AgreedMesurol'),'100');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('AgreedStandard'),'101');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('AgreedMesurol'),'102');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('AgreedStandard'),'103');
    
            System.assertEquals(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID).get('PoGMesurol'),'200');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('PoGStandard'),'201');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('PoGMesurol'),'202');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('PoGStandard'),'203');
               
            
            System.assertEquals(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO'),'100');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO'),'100'); 
            
            System.assertEquals(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO2'),'200');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO2'),'200'); 
    
            System.assertEquals(controller.premiumCorn.get('TEST CORN' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
            System.assertEquals(controller.premiumCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');      
       }       
        
        
        
        
       if(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID)!=null){
        System.assertEquals(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID).get('AgreedMesurol'),'100');
        System.assertEquals(controller.standardCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('AgreedStandard'),'101');
        System.assertEquals(controller.standardCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('AgreedMesurol'),'102');
        System.assertEquals(controller.standardCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('AgreedStandard'),'103');

        System.assertEquals(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID).get('PoGMesurol'),'200');
        System.assertEquals(controller.standardCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('PoGStandard'),'201');
        System.assertEquals(controller.standardCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('PoGMesurol'),'202');
        System.assertEquals(controller.standardCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('PoGStandard'),'203');
           
        
        System.assertEquals(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID).get('FAO'),'100');
        System.assertEquals(controller.standardCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO'),'100');
        System.assertEquals(controller.standardCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO'),'100');
        System.assertEquals(controller.standardCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO'),'100'); 
        
        System.assertEquals(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID).get('FAO2'),'200');
        System.assertEquals(controller.standardCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('FAO2'),'200');
        System.assertEquals(controller.standardCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('FAO2'),'200');
        System.assertEquals(controller.standardCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('FAO2'),'200'); 

        System.assertEquals(controller.standardCorn.get('TEST CORN' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
        System.assertEquals(controller.standardCorn.get('TEST CORN 2' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
        System.assertEquals(controller.standardCorn.get('TEST CORN 3' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');
        System.assertEquals(controller.standardCorn.get('TEST CORN 4' + '_' + toAccount2.ID).get('Distributor'),'DETestDist');      
       }
      }
}