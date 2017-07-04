public with sharing class CampaignLineItemHistory
{
    public CampaignLineItemHistory__c record {get; set;}


    public CampaignLineItemHistory()
    {

    }

    public CampaignLineItemHistory (CampaignLineItemHistory__c record)
    {
        this.record = record;
    }


}