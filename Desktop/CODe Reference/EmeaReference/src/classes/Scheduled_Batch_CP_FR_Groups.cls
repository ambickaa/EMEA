global class Scheduled_Batch_CP_FR_Groups implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {        
        String q = 'SELECT Id FROM Account WHERE CountryRef__r.Name IN (\'France\', \'Belgium\') AND Influencer__c != null AND Influencer__r.GC_Integration_Key__c = null';
        Id JobId = Database.executeBatch(new Batch_CP_FR_Groups(q), 10);
    }
    
}