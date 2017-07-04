@isTest
private class AccountTacticalPlanStatusPermControlTest {

    static testMethod void myUnitTest() {
    	Country__c c = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
        Year__c Year= new Year__c (Name='2013-2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
            YearStartDate__c=date.newinstance(2013, 1, 1), CurrentYear_RSA__c=true); 
            insert Year;
        Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
            insert Divi;
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                           Category__c='Farm');  
       insert farm;
       RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        RecordType taC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'TrialsProductCatalog'];
        
        ProductCatalog__c prcat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c pastcat = new ProductCatalog__c(name = 'Product Catalog Past',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c trcat = new ProductCatalog__c(name = 'Product Trial Catalog',countryRef__c=c.id,RecordTypeId=taC.id);
        ProductCatalog__c procat = new ProductCatalog__c(name = 'Catalog ii',countryRef__c=c.id);
           
        insert new List<ProductCatalog__c> { prcat, pastcat, trcat, procat} ;
            
        Campaign ca = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2014,11,11), statuscode__c=300, SalesPCMRef__c=prcat.id,
                          StartDate=Date.newinstance(2013,02,02), DivisionRef__c = Divi.id, CompetitorPCMRef__c=procat.id,
                          TrialPCMRef__c=trcat.id);
         insert ca;
         Util.currentCampaign = ca;
       Util.currentCountry = c;
       Util.currentAccount = farm;
    	
    	Util.countryView.isCancelledStatusValueForTacticalPlan = true;
    	Util.currentCampaign.DisableForecastStatus__c=false;
        AccountTacticalPlanStatusPermController controller1 = new AccountTacticalPlanStatusPermController();
        String str = controller1.getPermissions();
        List<AccountTacticalPlanStatusPermController.Permission> permissions = new List<AccountTacticalPlanStatusPermController.Permission>();
        permissions.add(new AccountTacticalPlanStatusPermController.Permission('Cancelled', 'QuantityToZero'));
		permissions.add(new AccountTacticalPlanStatusPermController.Permission('Cancelled', 'disableQuantity'));
        system.assertEquals(str, Json.serialize(permissions));
        AccountTacticalPlanStatusPermController.Permission perm = new AccountTacticalPlanStatusPermController.Permission();
        Util.countryView.isCancelledStatusValueForTacticalPlan = false;
        Util.currentCampaign.DisableForecastStatus__c=true;
        AccountTacticalPlanStatusPermController controller2 = new AccountTacticalPlanStatusPermController();
        String str2 = controller2.getPermissions();
        List<AccountTacticalPlanStatusPermController.Permission> permissions2 = new List<AccountTacticalPlanStatusPermController.Permission>();
        permissions2.add(new AccountTacticalPlanStatusPermController.Permission('Cancelled', 'removeStatus'));
        permissions2.add(new AccountTacticalPlanStatusPermController.Permission('Forecast', 'disableStatus'));
		permissions2.add(new AccountTacticalPlanStatusPermController.Permission('Forecast', 'disableQuantity'));
        system.assertEquals(str2, Json.serialize(permissions2));
    }
}