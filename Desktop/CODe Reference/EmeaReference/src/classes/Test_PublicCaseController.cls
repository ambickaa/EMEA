/*
    @description Test addition case comments
    @copyright PARX
*/
@isTest
private class Test_PublicCaseController
{
    private static final String CASE_COMMENT_BODY = 'New Commnet Body';
    
    private static Case testCase = testInit.cases[0];
    private static Map<String, Object> testCaseParams;
    private static Map<String, String> testResultEmailTemplate;
    
    /*
        @description Initialize parameters and records
    */
    private static void init()
    {
        Account anAccount = TestInit.createNewFarmer();
        anAccount.Name = 'Test Account' + al.RandomStringUtils.randomUUID()+Math.random();
        insert anAccount;
        
        User anUser = [SELECT FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId()];
        anUser.FirstName = UserInfo.getFirstName();
        anUser.LastName = UserInfo.getLastName();
        update anUser;
        
        Product2 aProduct = TestInit.products[0];
        insert aProduct;
        
        testCaseParams = new Map<String, Object>
        {
            'OwnerId' => UserInfo.getUserId(), 'AccountId' => anAccount.Id, 
            'ContactId' => TestInit.contacts[0].Id, 'Status' => 'New', 'Priority' => 'High', 
            'Subject' => '{!Account.Name}', 'Description' => '{!Case.Description}', 
            'GC_Product_SFID__c' => aProduct.Id
        };
        testCase = (Case)SmartFactory.createSObject('Case', testCaseParams);
        insert testCase;
        
        //result fields on EmailtTemplate after merge
        testResultEmailTemplate = new Map<String, String> {'Subject' => anAccount.Name, 'Body' => testCase.Description};
        
        PageReference aPage = Page.CaseSendToTd;
        aPage.getParameters().put('id', testCase.id);
        Test.setCurrentPage(aPage);
    }
    
    /*
        @description test addition case comments
    */
    private static testMethod void testAddCaseComment()
    {
        init();
        
        Test.startTest();
        PublicCaseController aController = new PublicCaseController();
        checkFillCaseFields(aController.currentCase.record);
        
        //Show case comment section
        aController.openCommentWindow();
        System.assert(aController.showCommentWindow, 'Case comment section should be appear.');
        
        //Add case coment and close case comment section.
        aController.newCommentBody = CASE_COMMENT_BODY;
        aController.addNewComment();
        aController.closeCommentWindow();
        System.assert(!aController.showCommentWindow, 'Case comment section should be disappear.');
        
        checkCreatedCaseComment();
        
        //Check chnages on EmailTemplate.
        EmailTemplate anEmailTemplate = [SELECT subject, body FROM EmailTemplate WHERE IsActive = True LIMIT 1];
        anEmailTemplate.subject = '{!Account.Name}';
        anEmailTemplate.body = '{!Case.Description}';
        aController.mergeTemplate(anEmailTemplate, aController.currentCase.record);
        checkResultEmailTemplateFields(anEmailTemplate);
        
        aController.closeCase();
        aController = new PublicCaseController(testCase.Id);
        Test.stopTest();
    }
    
    /*
        @description check filling case fields
    */
    private static void checkFillCaseFields(Case theCase)
    {
        for (String aField : testCaseParams.keySet())
        {
            System.assertEquals(testCaseParams.get(aField), theCase.get(aField), 'Case field ' + aField + ' was filled incorrect.');
        }
    }
    
    /*
        @description check result EmailTemplate fields
    */
    private static void checkResultEmailTemplateFields(EmailTemplate theEmailTemplate)
    {
        for (String aField : testResultEmailTemplate.keySet())
        {
            System.assertEquals(testResultEmailTemplate.get(aField), theEmailTemplate.get(aField), 'EmailTemplate field ' + aField + ' was filled incorrect.');
        }
    }
    
    /*
        @description check contains error message
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
    
    /*
        @description check created case comment
    */
    private static void checkCreatedCaseComment()
    {
        Boolean anIsExistReauiredCaseComment = false;
        for (CaseComment aCaseComment : [SELECT CommentBody FROM CaseComment WHERE parentId = :testCase.Id])
        {
            if (aCaseComment.CommentBody == CASE_COMMENT_BODY)
            {
                anIsExistReauiredCaseComment = true;
            }
        }
        System.assert(anIsExistReauiredCaseComment, 'CaseComment won\'t created!');
    }
}