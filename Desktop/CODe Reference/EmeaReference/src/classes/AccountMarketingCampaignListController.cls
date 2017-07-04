public class AccountMarketingCampaignListController extends AccountListVirtualController
{
	public AccountMarketingCampaignListController()
	{
		// Initialization standard factory for campaigns
		objectFactory = new CampaignxFactory();
		fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.Campaign, 'AccountMarketing');
	}
	// getter for marketing campaigns used by component
	public List<Campaignx> getCampaigns()
	{
		return ( List<Campaignx> ) wrapperObjects;
	}
}