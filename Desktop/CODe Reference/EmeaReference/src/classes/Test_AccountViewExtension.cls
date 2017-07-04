// AccountViewExtension
@isTest
private class Test_AccountViewExtension {      
    
    
    private static testmethod void testAccountViewExtension()
    {
        // Controller test
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_CP);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[2].Id;
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        
        insert anAccount;
        
        Test.setCurrentPage(Page.AccountViewFR);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Test.startTest();
        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        //System.debug('ver aStdController: '+aStdController.getRecord());
        AccountViewExtension accountView= new AccountViewExtension(aStdController);
        accountView.getGiveAways();        
       
        //Test the auxiliar methods
        String color = accountView.divisionColor;
        System.assertEquals(color , aDivision.Color__C);
        String div = accountView.divisionId;
        System.assertEquals(div, aDivision.id);
        
        boolean testIsGerman = accountView.getIsGermanView();
        System.assertEquals(testIsGerman, false);
        boolean testIsRSA = accountView.getIsRSAView();
        System.assertEquals(testIsRSA, false);
        boolean testIsGermanCPview = accountView.getIsGermanCPview();
        System.assertEquals(testIsGermanCPview, false);
        boolean testIsCpStandard = accountView.getIsCpStandard();
        System.assertEquals(testIsCpStandard, true);
        boolean testIsCpUser = accountView.getIsCpUser();
        System.assertEquals(testIsCpUser, true);
        string testUserCountry = accountView.getUserCountry();
        System.assertEquals(testUserCountry, currentUser.Country);
        boolean testIsStandard = accountView.getIsStandardTrial();
        System.assertEquals (testIsStandard, false);
        
        boolean testIsAutoCreateAcreages = accountView.getIsAutoCreateAcreages();
        //System.assertEquals (testIsAutoCreateAcreages, false);
        boolean testIsMoreThanOneCampaign = accountView.getIsMoreThanOneCampaign();
        System.assertEquals (testIsMoreThanOneCampaign, false);
        boolean testIsVoucherEnabled = accountView.getIsVoucherEnabled();
        //System.assertEquals (testIsVoucherEnabled, false);
        boolean testIsGermanyAc = accountView.getIsGermanyAcreages();
        
        Util.countryView.isGermanActionPlan = true;
        boolean testIsGermanyAc2 = accountView.getIsGermanyAcreages();
        
        accountView.isCpStandard = false;
        accountView.currentDivision = 'CP';
   
        Test.stopTest();  
    }
    
    private static testmethod void testAccountViewExtension2()
    {
        // Controller test
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_CP);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[2].Id;
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        
        insert anAccount;
        
        Test.setCurrentPage(Page.AccountViewFR);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Test.startTest();
        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        //System.debug('ver aStdController: '+aStdController.getRecord());
        AccountViewExtension accountView= new AccountViewExtension(aStdController);
        //accountView.AccountViewExtension();
        accountView.getGiveAways();        
       
        //Test the auxiliar methods
        
        
        boolean testIsFrenchAcreages = accountView.getIsFrenchAcreages();
        //System.assertEquals(testIsFrenchAcreages, false);
        boolean testIsFrenchTacticalPlan = accountView.getIsFrenchTacticalPlan();
        //System.assertEquals(testIsFrenchTacticalPlan, true);
        
        boolean testIsGenericAcreages = accountView.getIsGenericAcreages();
        //System.assertEquals(testIsGenericAcreages, false);
        boolean testIsGenericTacticalPlan = accountView.getIsGenericTacticalPlan();
        //System.assertEquals(testIsGenericTacticalPlan, false);
        
        Test.stopTest();  
    }    
    
}