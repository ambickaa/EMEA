public class CampaignCorrectorController
{
	
	
	public FieldSetMemberxManager fieldSetManager {get; set;}
	public List<Campaignx.CamapignDuplicates>duplicateCampaigns
	{
		get
		{
			if(duplicateCampaigns == null)
			{
				CampaignxFactory factory = new CampaignxFactory();
				duplicateCampaigns = factory.getCampaignDuplicates(fieldSetManager);
			}
			return duplicateCampaigns;
		}
		set;
	}
	
	
	public CampaignCorrectorController()
	{
		fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.Campaign, '', 'CampaignDuplicateCorrector', '');
	}
	
}