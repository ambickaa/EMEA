public with sharing class TacticalPlanElementHistoryController {
	private TacticalPlanHistoryFactory factory = new TacticalPlanHistoryFactory();
	public List<CampaignLineItemHistory> history {get{
		if(history == null)
		{
			history = factory.createTacticalPlanElementHistoryForElement(Util.urlParameters.get('id'));
		}
		return history;
	} set;}
	
	
}