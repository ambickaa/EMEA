/*
 * Class takes care about filling the Quantity field with the right value
 *
 */
public class TriggerCampaignLineItemFillQuantityField implements Triggers.Handler
{
    //Map for status values and field to be set into quantity.
    private static final Map<String, String> statusFieldValuesToCLIFieldsMapping = 
            new Map<String, String>{'Forecast' => 'Forecast__c',
                                    'Confirmed' => 'POG__c',
                                    'Ordered / Discussed' => 'Agreed__c'};
    public void handle()
    {
    	/* 20130425 - BEGIN: To reduce number of queries */
    	Id CampaignLineItemSalesRecorTypeID = Util.recordType.get('CampaignLineItem__c:Sales');
	    /* 20130425 - END: To reduce number of queries */
        // fill quantity__c field with value from field that depends of Status field value.
        for(CampaignLineItem__c aCampaignLineItem : (List<CampaignLineItem__c>)trigger.new)
        {
        	
	    	/* 20130425 - BEGIN: To reduce number of queries */
            if (aCampaignLineItem.RecordTypeId == CampaignLineItemSalesRecorTypeID)
            {
		    	/* 20130425 - END: To reduce number of queries */
                aCampaignLineItem.Quantity__c = 0;
                if (statusFieldValuesToCLIFieldsMapping.keySet().contains(aCampaignLineItem.Status__c))
                {
                    aCampaignLineItem.Quantity__c = (Decimal)aCampaignLineItem.get(statusFieldValuesToCLIFieldsMapping.get(aCampaignLineItem.Status__c));
                }else if (aCampaignLineItem.CatalogType_RSA__c == 'Feb Receipt' || aCampaignLineItem.CatalogType_RSA__c == 'Tax' || aCampaignLineItem.CatalogType_RSA__c == 'Regular'|| aCampaignLineItem.CatalogType_RSA__c == 'General'){
                    if(aCampaignLineItem.PoG__c != null)
                        aCampaignLineItem.Quantity__c = aCampaignLineItem.PoG__c;
                    else if(aCampaignLineItem.Agreed__c != null)
                        aCampaignLineItem.Quantity__c = aCampaignLineItem.Agreed__c;
                    else if(aCampaignLineItem.Forecast__c != null)
                        aCampaignLineItem.Quantity__c = aCampaignLineItem.Forecast__c;
                }
            }
        }
    }
}