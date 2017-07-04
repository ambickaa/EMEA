global class AccountUpdateBatchable implements Database.Batchable<sObject>
{
    //This batch update all summary fields of accounts 
    public al.SoqlBuilder soqlBuilder {get;set;}
    public Boolean changeYear {get; set;}
    public al.Condition condition {get; set;}
    
    global AccountUpdateBatchable(al.Condition theCondition){
        if (theCondition !=null) condition = theCondition;
        changeYear = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext theContext){
        
        soqlBuilder = new al.SoqlBuilder()
              .selectx(new List<String>{'Id', 'GC_is_Visited__c', 'Visited_PY__c, IsCreateCampaignLineItem__c',
                 //BEG New Development: France. Added new account fields to year change
                'FR_POG_CORN_MS_CY__c','FR_POG_CORN_MS_PY__c','FR_POG_OSR_MS_CY__c','FR_POG_OSR_MS_PY__c',
                //END New Development: France. Added new account fields to year change//
                // Ukraine CP Development 
                'CHK_AcreageSownCornPY__c','CHK_AcreageSownOsrPY__c','CHK_AcreageSownCornCY__c',' CHK_AcreageSownOsrCY__c',
                'CP_ACTIMUM_ZV_PY__c','CP_GUARDIAN_ZV_PY__c','CP_Harness_ZV_PY__c','DE_Monitor_ZV_PY__c',
                'DE_Roundup_ZV_PY__c','CP_ACTIMUM_ZV_CY__c','CP_GUARDIAN_ZV_CY__c','CP_Harness_ZV_CY__c',
                'DE_Monitor_ZV_CY__c','DE_Roundoup_ZV_CY__c'})
              .fromx('Account');
        
        if (condition != null) soqlBuilder.wherex(condition);

        return Database.getQueryLocator(soqlBuilder.toSoql()); 
    }
    
    global void execute(Database.BatchableContext theContext, List<sObject> theList)
    {
        //Select Account records which needs to update.
        List<Account> listAcc = (List<Account>)theList;
        Set<Id> anAccsList = new Set<ID>();
        for (Account anAccount: listAcc)
        {
            anAccsList.add(anAccount.Id);
        }
        
        AccountTriggerHelper.updateSummaryCampaignLineItem(anAccsList);
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}