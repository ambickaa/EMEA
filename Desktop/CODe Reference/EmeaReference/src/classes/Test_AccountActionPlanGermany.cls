@isTest
private class Test_AccountActionPlanGermany 
{
    
    private static testMethod void testAccountCP()
    {
        AccountActionPlanGermanyCPController cpController = new AccountActionPlanGermanyCPController();
        
        try{
            List<CampaignLineItem> cliList = cpController.tacticalPlans;
            Boolean excelDisplay = cpController.getIsDisplayExcel();
            Boolean displayButtons = cpController.getIsDisplayButtons();
            Map<String, Double> sumFields = cpController.sumOfNumberFields;
            cpController.excelToMail();
            
        }
        catch(Exception e)
        {
            
        }
        
    }
    private static testMethod void testAccountST()
    {
        
        try{
        AccountActionPlanGermanySTController stController = new AccountActionPlanGermanySTController();
            List<CampaignLineItem> cliList = stController.tacticalPlans;
            Boolean excelDisplay = stController.getIsDisplayExcel();
            Boolean displayButtons = stController.getIsDisplayButtons();
            Map<String, Double> sumFields = stController.sumOfNumberFields;
            stController.excelToMail();
    
        }
        catch(Exception e)
        {
            
        }
    }
    
    

}