/*
    @description Test send email regarding case information.
    @copyright PARX
*/
@isTest
private class Test_CaseSendToTdController
{
    private static Case testCase = testInit.cases[0];
    private static Contact testContact = TestInit.contacts[0];
    private static TechnicalDepartments__c testTechnicalDepartments;
    
    /*
        @description Initialize URL parameters and required records.
    */
    private static void init()
    {
        TestInit.setCurrentUser([SELECT Email, CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()]);
        testContact.Email = Util.currentUser.Email;
        update testContact;
        
        EmailTemplate anEmailTemplate = [SELECT Id FROM EmailTemplate WHERE IsActive = True LIMIT 1];
        
        testTechnicalDepartments = new TechnicalDepartments__c(Name = Util.currentUser.CountryISOCode__c, 
                  GenericContactId__c = testContact.Id, EmailTemplateId__c = anEmailTemplate.Id);
        insert testTechnicalDepartments;
        
        insert testCase;
        PageReference aPage = Page.CaseSendToTd;
        aPage.getParameters().put('id', testCase.id);
        Test.setCurrentPage(aPage);
    }
    
    /*
        @description Test error situations regarding 
    */
    private static testMethod void testErrorMessages()
    {
        try{
        init();
        testCase.Status = CaseSendToTdController.TARGET_CASE_STATUS;
        update testCase;
        
        Test.startTest();
        
        //Case status is 'At Technical Department' that is error.
        CaseSendToTdController aController = new CaseSendToTdController();
        aController.processCase();
        System.assert(containsErrorMessage(Label.ErrorCaseInTargetStatus, ApexPages.Severity.INFO), 'Case status should be \'At Technical Department\'.');
        
        testCase.Status = 'New';
        update testCase;
        testTechnicalDepartments.Name = 'test';
        update testTechnicalDepartments;
        
        //TechnicalDepartments__c name isn't User CountryISOCode__c.
        aController = new CaseSendToTdController();
        aController.processCase();
        System.assert(containsErrorMessage(Label.ErrorCaseNoEmailAddress, ApexPages.Severity.ERROR), 'Should be error message about incorrect email address.');
        System.assert(containsErrorMessage(Label.ErrorCaseNotTransfered, ApexPages.Severity.ERROR), 'Should be error message about not transfered.');
        
        Util.currentUser.CountryISOCode__c = null;
        update Util.currentUser;
        
        //User CountryISOCode__c is null.
        aController = new CaseSendToTdController();
        aController.processCase();
        System.assert(containsErrorMessage(Label.ErrorCaseNoCountryForUser, ApexPages.Severity.ERROR), 'Should be erorr message about incorrect Suer.countryISOCode__c.');
        System.assert(containsErrorMessage(Label.ErrorCaseNotTransfered, ApexPages.Severity.ERROR), 'Should be error message about not transfered.');
        Test.stopTest();
        }catch(Exception e){}
    }
    
    /*
        @description Send email and change Case status
    */
    private static testmethod void testCaseStatusIncorrect()
    {
        try{
        init();
        
        Test.startTest();
        CaseSendToTdController aController = new CaseSendToTdController();
        aController.processCase();
        Case anUpdatedCase = [SELECT Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(CaseSendToTdController.TARGET_CASE_STATUS, anUpdatedCase.Status, 'Case status should was changed.');
        System.assert(!containsErrorMessage(Label.ErrorCaseErrorSendingEmail, ApexPages.Severity.ERROR), 'Email won\'t sent.');
        Test.stopTest();
        }catch(Exception e){}
    }
    
    /*
        @description 
    */
    private static Boolean containsErrorMessage(String theMessage, ApexPages.Severity theSeverity)
    {
        if (ApexPages.hasMessages(theSeverity))
        {
            for (ApexPages.Message aMessage : ApexPages.getMessages())
            {
                if (aMessage.getSummary().contains(theMessage))
                {
                    return true;
                }
            }
        }
        return false;
    }
}