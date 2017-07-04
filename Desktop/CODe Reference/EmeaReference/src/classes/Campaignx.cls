public class Campaignx implements AccountListObjectWrapper
{
	public Campaign record {get; set;}
	public List<CampaignMemberx> members {get; set;}

	public Campaignx()
	{
		record = new Campaign();
	}

	public Campaignx( Campaign record )
	{
		this.record = record;
	}

	public List<sObject> getSelectedRecords()
	{
		return null;
	}
	public List<sObject> getFilledRecords()
	{
		return null;
	}
	
	
	/*
		@description Aggregation of duplicate campaigns
	 */
	public class CamapignDuplicates
	{
		public List<Campaignx>campaigns{get; set;}
		
		public Campaign getFirstCampaign()
		{
			return campaigns.get(0).record;
		}
		public CamapignDuplicates()
		{
			campaigns = new List<Campaignx>();
		}
		
		public void add(Campaign aCampaign)
		{
			campaigns.add(new Campaignx(aCampaign));
		}
	}
}