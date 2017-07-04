public with sharing class CampaignManageTPPermissionsController
{
	public Campaign searchCampaign
	{
		get
		{
			if(searchCampaign == null)
			{
				searchCampaign = new Campaign();
				searchCampaign.Owner = new User();
			}
			return searchCampaign;
		}
		set;
	}
	private al.SoqlBuilder query
	{
		get;
		set
		{
			
			query = value;
		}
	}
	public List<Campaign>campaigns
	{
		get
		{
			return campaigns;
		}
		set;
	}
	
	
	public CampaignManageTPPermissionsController()
	{
		buildQuery();
	}
	
	public void buildQuery()
	{
		query = new al.SoqlBuilder();
		query.selectx(new Set<String>{'id', 'name', 'Owner.Name', 'CountryRef__c', 'DisableForecastStatus__c', 'DivisionRef__c'})
		.fromx('Campaign');
		
		al.AndCondition aCondition = new al.AndCondition();
		aCondition.add(new al.FieldCondition('StatusCode__c', 200));
		
		if(searchCampaign.DivisionRef__c <> null)
		{
			aCondition.add(new al.FieldCondition('DivisionRef__c', searchCampaign.DivisionRef__c));
		}
		query.wherex(aCondition);
		query.orderByx(new al.OrderBy('name'));
		campaigns = Database.query(query.toSOQL());
	}
	
	public void disableSelectedCampaigns()
	{
		if(campaigns.size()>0)
		{
			update campaigns;
		}
	}
	
	public PageReference backToHome()
	{
		return new PageReference('/home/home.jsp');
	}
}