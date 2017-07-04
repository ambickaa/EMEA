// AccountViewExtensionError
@isTest
private class Test_AccountViewExtensionError {        
    
    private static testmethod void testAccountViewExtensionError()
    {
        // Controller test
        Account anAccount = TestInit.createNewFarmer();

        insert anAccount;
        
        Test.setCurrentPage(Page.AccountViewError);
        
        Test.startTest();

        Apexpages.currentPage().getParameters().put('id', anAccount.id);        
        Apexpages.StandardController aStdController = new Apexpages.StandardController(anAccount);
        AccountViewExtensionError accountViewError= new AccountViewExtensionError(aStdController);    

        Apexpages.currentPage().getParameters().put('IsDeleted', 'true');        
        Apexpages.StandardController aStdControllerDel = new Apexpages.StandardController(anAccount);
        AccountViewExtensionError accountViewErrorDel= new AccountViewExtensionError(aStdControllerDel);    
       
        //Test the auxiliar methods
        Test.stopTest();  
    }  
    
}