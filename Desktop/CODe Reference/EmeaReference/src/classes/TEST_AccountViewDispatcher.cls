@isTest
private class TEST_AccountViewDispatcher {
    

    static testMethod void myUnitTest() {
        TestInit.setYear(1);
        Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[2].Id;
        Account anAccount3 = TestInit.createNewFarmer();
        
        insert anAccount;
        insert anAccount3;
        Test.setCurrentPage(Page.AccountView);
        Apexpages.currentPage().getParameters().put('id', anAccount.id);
        Apexpages.currentPage().getParameters().put('id', anAccount3.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Test.startTest();
        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        Apexpages.StandardController aStdController3 = new Apexpages.StandardController(anAccount3);
        AccountViewDispatcher ad = new AccountViewDispatcher(aStdController);
        AccountViewDispatcher ad3 = new AccountViewDispatcher(aStdController3);
        ad.accountRedirect();
        delete anAccount3;
        ad3.accountRedirect();

        TestInit.setYear(2);
        Account anAccount2 = TestInit.createNewFarmer();
        anAccount.CountryRef__c = TestInit.countries[1].Id;
        User currentuser = [SELECT Id, Name, Country FROM User where Country =: TestInit.countries[0].Name AND isActive = true  limit 1];
        
        insert anAccount2;
        
        System.RunAs(currentuser){

        Test.setCurrentPage(Page.AccountView);
        Apexpages.currentPage().getParameters().put('id', anAccount2.id);
        Apexpages.currentPage().getParameters().put('division', aDivision.id); 
        
        Apexpages.StandardController aStdController2 = new Apexpages.StandardController(anAccount2);
        AccountViewDispatcher ad2 = new AccountViewDispatcher(aStdController);
        ad2.accountRedirect();
        }
        Test.stopTest();

    }
}