public class CampaignLineItemGroup  implements AccountListObjectWrapper
{
    public boolean checked {get; set;}

    public CampaignLineItemGroup__c record {get; set;}
    public List<CampaignLineItem> lineItems {get; set;}
	
	//The record is unchecked by default.
	{
		checked = false;
	}

    public CampaignLineItemGroup()
    {
        this.record = new CampaignLineItemGroup__c();
        this.lineItems = new List<CampaignLineItem>();

    }
	
	public Boolean isNewRecord
	{
		get
		{
			return record.Id == null;
		}
	}
	
    public CampaignLineItemGroup(CampaignLineItemGroup__c record)
    {
        this();
        this.record = record;
        for(CampaignLineItem__c cli : record.campaignLineItems__r)
        {
            lineItems.add(new CampaignLineItem(cli));
        }
    }

    public PageReference addNewProductLine()
    {
    	lineItems.add(new CampaignLineItem());
        for(CampaignLineItem item : lineItems)
        {
        	item.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial');
        }
        Set<Id>productIds = new Set<Id>();
        for(CampaignLineItem i : lineItems)
        {
        	if(i.lookupValue.text == null && i.lookupValue.id != null)
        	{
        		productIds.add(i.lookupValue.id);
        	}
        }
        if(!productIds.isEmpty())
        {
        	Map<Id, Product2>products = new Map<Id, Product2>([SELECT ID, Name From Product2 WHERE ID IN :productIds]);
        	for(CampaignLineItem i : lineItems)
	        {
	        	if(i.lookupValue.text == null && i.lookupValue.id != null)
	        	{
	        		i.lookupValue.text = products.get(i.lookupValue.id).name;
	        	}
	        }
        }
        return null;
    }


    public boolean getisProduct()
    {
        return lineItems.size()>0;
    }

    public List<sObject> getSelectedRecords()
    {
        List<sObject> result = new List<sObject>();
        if(this.checked)
        {
            result.add(record);
            
        }
        
        for(CampaignLineItem l : lineItems)
        {
        	if(l.checked || this.checked)
        	{
        		result.add(l.record);
        		if(this.lineItems.size() == 1 && !this.checked)
        		{
        			result.add(this.record);
        		}
        	}
        }
        
        return result;
    }

    public List<sObject> getFilledRecords()
    {
        List<sObject> result = new List<CampaignLineItem__c>();
        for(CampaignLineItem cli: lineItems)
        {
            result.addAll(cli.getFilledRecords());
        }
        if(result.size()>0)
        {
            record.CampaignRef__c = Util.currentCampaign.id;
            record.AccountRef__c = Util.currentAccount.id;
            upsert record;
            for(CampaignLineItem__c cli :(List<CampaignLineItem__c>)result)
            {
                cli.FarmRef__c = Util.currentAccount.id;
                cli.CampaignRef__c = Util.currentCampaign.id;
                cli.CampaignRef__c = Util.currentCampaign.id;
                if (record.id != null)
                {
                	cli.CampaignLineItemGroupRef__c = record.id;
                }
            }
        }
        return result;
    }
}