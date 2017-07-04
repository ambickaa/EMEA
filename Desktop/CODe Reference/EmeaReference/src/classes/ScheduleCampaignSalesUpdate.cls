global class ScheduleCampaignSalesUpdate implements Schedulable {

    global void execute(SchedulableContext sc)
    {
        Id batchInstanceId = Database.executeBatch(new BatchCampaignSalesUpdate(), 2000);
    }
}