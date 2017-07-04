@isTest
public with sharing class Test_AccTacticalPlanElementController 
{
    private static testmethod void testAccTacticalPlanElementController()
    {
        TestInit.createAccountListController(); 
        
        retoure__c toRetoure= new retoure__c(Account__C=TestInit.AccountWrapper.accountRecord.id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0);
        insert toRetoure;
        
        CampaignLineItem__c cliPreviosCampaign = new CampaignLineItem__c(
            FarmRef__c = TestInit.AccountWrapper.accountRecord.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = TestInit.AccountWrapper.previosCampaignRecord.id);
        insert cliPreviosCampaign;
        
        CampaignLineItem__c cliCurrentCampaign = cliPreviosCampaign.clone(false, false);
        cliCurrentCampaign.CampaignRef__c = TestInit.AccountWrapper.campaignRecord.id;
        insert cliCurrentCampaign;
        
        Product2 product = TestInit.products[0];
        product.DivisionRef__c = TestInit.accountWrapper.campaignRecord.DivisionRef__c;
        insert product;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', TestInit.accountWrapper.accountRecord.id);
        Apexpages.currentPage().getParameters().put('division', 
                TestInit.accountWrapper.campaignRecord.DivisionRef__c);
                
        test.startTest();
        AccountTacticalPlanElementController controller = new AccountTacticalPlanElementController();
        System.assertEquals(false, controller.getIsItalianView());
        
        List<CampaignLineItem> previosClis = (List<CampaignLineItem>)controller.prevCampController.tacticalPlans;
        System.assertEquals(1, previosClis.size());
        
        List<CampaignLineItem> currentClis = (List<CampaignLineItem>)controller.currentCampController.tacticalPlans;
        System.assertEquals(1, currentClis.size());
        
        Test.setCurrentPage(TestInit.customRedirectModifier(controller.currentCampController.newrecord()));
        util.urlParameters = null;
        AccountTacticalPlanElementController newController = new AccountTacticalPlanElementController();
        for (CampaignLineItem CLI : (List<CampaignLineItem>)newController.currentCampController.tacticalPlans)
        {
            if (CLI.isNewCLI)
            {
                CLI.lookupValue = new LookupValue(product.id, 'product');
                CLI.record.Type__c = 'Free of charge';
                CLI.record.Status__c = 'Confirmed';
                CLI.record.Quantity__c = 1000;
            }
        }
        
        util.urlParameters = null;
        test.setCurrentPage(TestInit.customRedirectModifier(newController.currentCampController.save()));
        AccountTacticalPlanElementController controllerAfterSave = new AccountTacticalPlanElementController();
        for (CampaignLineItem CLI : (List<CampaignLineItem>)newController.currentCampController.tacticalPlans)
        {
            System.assertEquals(Util.recordType.get('CampaignLineItem__c:Sales'), CLI.record.RecordtypeId);
        }
        
        controllerAfterSave.currentCampController.tacticalPlans[0].checked = true;
        util.urlParameters = null;
        test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterSave.doCreateAcreages()));
        
        AccountAcreagesProductListController acreageController = new AccountAcreagesProductListController();
        System.assertEquals(1, acreageController.getMerchandiseManagements().size());
        test.stopTest();
    }
    
    private static testmethod void testAccItalyTacticalPlanElementController()
    {
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[0].Id;
        insert anAccount;
        Account anCompetitor = TestInit.createNewCompetitor();
        insert anCompetitor;
        
        Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today(),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.lastYear.Id
        };
        Campaign aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
        insert aPreviousCampaign;
        
        Product2 product = TestInit.products[0];
        insert product;
        
        CampaignLineItem__c cliPreviosCampaign = new CampaignLineItem__c(
            FarmRef__c = anAccount.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = aPreviousCampaign.id,
            Type__c = 'Free of charge',
            ProductRef__c = product.id);
        insert cliPreviosCampaign;
        
        CampaignLineItem__c cliChargeCampaign = cliPreviosCampaign.clone(false, false);
        cliChargeCampaign.Type__c = 'Charged';
        insert cliChargeCampaign;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        test.startTest();
        AccountTacticalPlanElementController controller = new AccountTacticalPlanElementController();
        //System.assertEquals(true, controller.getIsItalianView());
        
        List<CampaignLineItem> italyCLIs = (List<CampaignLineItem>)controller.italyController.tacticalPlans;
 //       System.assertEquals(1, italyCLIs.size());
  //      System.assertEquals('Charged', italyCLIs[0].nextPeriodeElement.record.Type__c);
  //      System.assertEquals(cliPreviosCampaign.Id, italyCLIs[0].freeOfChargeElement.record.Id);
        
        //Check that doesn't save
      //  System.assertEquals(true, italyCLIs[0].getFilledRecords().isEmpty());
        Map<String, Double>sumOfNumberFields = controller.italyController.sumOfNumberFields;
        
        delete aPreviousCampaign;
        
        Map<String, Object> aCurrentCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(1),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.currentYear.Id
        };
        Campaign aCurrentCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrentCampaignParam);
        insert aCurrentCampaign;
        
        CampaignLineItem__c cliCurrentCampaign = new CampaignLineItem__c(
            FarmRef__c = anAccount.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = aCurrentCampaign.id,
            Type__c = 'Free of charge',
            ProductRef__c = product.id,
            POG__c = 10,
            Forecast__c = 20,
            Agreed__c = 30);
        insert cliCurrentCampaign;
        
        CampaignLineItem__c cliCurrentChargeCampaign = cliCurrentCampaign.clone(false, false);
        cliCurrentChargeCampaign.Type__c = 'Charged';
        insert cliCurrentChargeCampaign;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Util.isCampaign = null;
        util.urlParameters = null;
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        AccountTacticalPlanElementController currentController = new AccountTacticalPlanElementController();
      //  System.assertEquals(true, currentController.getIsItalianView());
        
        List<CampaignLineItem> newItalyCLIs = (List<CampaignLineItem>)currentController.italyController.tacticalPlans;
      //  System.assertEquals(1, newItalyCLIs.size());
     //   System.assertEquals('Charged', newItalyCLIs[0].nextPeriodeElement.record.Type__c);
     //   System.assertEquals(null, newItalyCLIs[0].record.Id);
     //   System.assertEquals(cliCurrentChargeCampaign.Id, newItalyCLIs[0].nextPeriodeElement.record.Id);
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(currentController.italyController.newRecord()));
        AccountTacticalPlanElementController currentControllerAfterNewRecord = 
            new AccountTacticalPlanElementController();
       // System.assertEquals(2, currentControllerAfterNewRecord.italyController.tacticalPlans.size());
        
       // System.assertEquals(2, currentControllerAfterNewRecord.italyController.tacticalPlans[0].getFilledRecords().size());
        currentControllerAfterNewRecord.italyController.tacticalPlans[0].lookupValue = new LookupValue(product.id, 'product');
        currentControllerAfterNewRecord.italyController.tacticalPlans[0].record.Type__c = 'Free of charge';
        Util.urlParameters = null;
        System.debug('before save');
        test.setCurrentPage(TestInit.customRedirectModifier(currentControllerAfterNewRecord.italyController.save()));
        AccountTacticalPlanElementController controllerAfterSave = new AccountTacticalPlanElementController();
        
        //system.assertEquals(1, controllerAfterSave.italyController.tacticalPlans.size());
        Map<String, Double> sumOfNumberFieldsItaly = controllerAfterSave.italyController.sumOfNumberFields;
        test.stopTest();
    }

    private static testmethod void testAccUKTacticalPlanElementController()
    {
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[3].Id;
        insert anAccount;
        Account anCompetitor = TestInit.createNewCompetitor();
        insert anCompetitor;
        
        Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today(),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.lastYear.Id
        };
        Campaign aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
        insert aPreviousCampaign;
        
        Product2 product = TestInit.products[0];
        insert product;
        
        CampaignLineItem__c cliPreviosCampaign = new CampaignLineItem__c(
            FarmRef__c = anAccount.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = aPreviousCampaign.id,
            Type__c = 'Free of charge',
            ProductRef__c = product.id);
        insert cliPreviosCampaign;
        
        CampaignLineItem__c cliChargeCampaign = cliPreviosCampaign.clone(false, false);
        cliChargeCampaign.Type__c = 'Charged';
        insert cliChargeCampaign;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        test.startTest();
        AccountTacticalPlanElementController controller = new AccountTacticalPlanElementController();
       // System.assertEquals(true, controller.getIsUKView());
        
        List<CampaignLineItem> ukCLIs = (List<CampaignLineItem>)controller.ukController.tacticalPlans;
    //    System.assertEquals(2, ukCLIs.size());
        
        //Check that doesn't save
      //  System.assertEquals(true, ukCLIs[0].getFilledRecords().isEmpty());
        Map<String, Double>sumOfNumberFields = controller.ukController.sumOfNumberFields;
        
        delete aPreviousCampaign;
        
        Map<String, Object> aCurrentCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(1),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.currentYear.Id
        };
        Campaign aCurrentCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrentCampaignParam);
        insert aCurrentCampaign;
        
        CampaignLineItem__c cliCurrentCampaign = new CampaignLineItem__c(
            FarmRef__c = anAccount.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = aCurrentCampaign.id,
            Type__c = 'Free of charge',
            ProductRef__c = product.id,
            POG__c = 10,
            Forecast__c = 20,
            Agreed__c = 30);
        insert cliCurrentCampaign;
        
        CampaignLineItem__c cliCurrentChargeCampaign = cliCurrentCampaign.clone(false, false);
        cliCurrentChargeCampaign.Type__c = 'Charged';
        insert cliCurrentChargeCampaign;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Util.isCampaign = null;
        util.urlParameters = null;
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        AccountTacticalPlanElementController currentController = new AccountTacticalPlanElementController();
        //System.assertEquals(true, currentController.getIsUKView());
        
        List<CampaignLineItem> newUKCLIs = (List<CampaignLineItem>)currentController.ukController.tacticalPlans;
    //    System.assertEquals(2, newUKCLIs.size());
    //    System.assertEquals('Charged', newUKCLIs[0].nextPeriodeElement.record.Type__c);
    //    System.assertEquals(null, newUKCLIs[0].record.Id);
    //    System.assertEquals(cliCurrentChargeCampaign.Id, newUKCLIs[0].nextPeriodeElement.record.Id);
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(currentController.ukController.newRecord()));
        AccountTacticalPlanElementController currentControllerAfterNewRecord = 
            new AccountTacticalPlanElementController();
        //System.assertEquals(3, currentControllerAfterNewRecord.ukController.tacticalPlans.size());
         
        //System.assertEquals(1, currentControllerAfterNewRecord.ukController.tacticalPlans[0].getFilledRecords().size());
        currentControllerAfterNewRecord.ukController.tacticalPlans[0].lookupValue = new LookupValue(product.id, 'product');
        currentControllerAfterNewRecord.ukController.tacticalPlans[0].record.Type__c = 'Free of charge';
        Util.urlParameters = null;
        System.debug('before save');
        test.setCurrentPage(TestInit.customRedirectModifier(currentControllerAfterNewRecord.ukController.save()));
        AccountTacticalPlanElementController controllerAfterSave = new AccountTacticalPlanElementController();
        
        Map<String, Double> sumOfNumberFieldsUk = controllerAfterSave.ukController.sumOfNumberFields;
        test.stopTest();
    }
}