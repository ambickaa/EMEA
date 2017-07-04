public interface AccountaddMultipleLinesStrategy
{
	List<CampaignLineItem> getTemporaryCampaignLineItems();
	PageReference save();
}