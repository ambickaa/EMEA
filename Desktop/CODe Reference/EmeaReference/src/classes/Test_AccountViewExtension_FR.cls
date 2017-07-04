// AccountViewExtension
@isTest
private class Test_AccountViewExtension_FR {
    
    
        
    
    
    private static testmethod void testAccountViewExtension()
    {
        // crear cuenta FRANCIA
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[2].Id;
        
        insert anAccount;
        
        Test.setCurrentPage(Page.AccountViewFR);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Test.startTest();
        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        System.debug('ver aStdController: '+aStdController.getRecord());
        AccountViewExtension accountView= new AccountViewExtension(aStdController);
         
       
        boolean testIsGerman = accountView.getIsGermanView();
        System.assertEquals(testIsGerman, false);
        boolean testIsRSA = accountView.getIsRSAView();
        System.assertEquals(testIsRSA, false);
        boolean testIsAuto = accountView.getisAutoCreateAcreages();
        System.assertEquals (testIsAuto, false);
        boolean testIsStandard = accountView.getIsStandardTrial();
        System.assertEquals (testIsStandard, false);
        boolean testIsGermanyAc = accountView.getIsGermanyAcreages();
        String divcolor= accountView.divisionColor;
        
        System.assertEquals(divcolor, aDivision.Color__C);
        String divId=accountView.divisionId;
        System.assertEquals (divId, aDivision.Id);
        
        
        
        Test.stopTest();
        
    }
    
    private static testmethod void testAccountViewExtension2()
    {
        // crear cuenta ALEMANIA
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[1].Id;
        
        // the record type of the German Account is not checked
        anAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dist./Ret./PoS').getRecordTypeId(); 
        
        
        insert anAccount;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Test.startTest();
        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        System.debug('ver aStdController: '+aStdController.getRecord());
        AccountViewExtension accountView= new AccountViewExtension(aStdController);
         
       
        boolean testIsGerman = accountView.getIsGermanyAcreages();
        System.assertEquals(testIsGerman, true);
        
        
        
        
        Test.stopTest();
        
    }

}