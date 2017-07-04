public with sharing class AccountTacticalPlanComponentController extends AccountListVirtualController
{
	public static final String JUMPER_TACTICAL_PLANS = 'tacticalPlanList';
	public static final String MODE_EDIT = 'tacticalEdit';
	
	public AccountTacticalPlanComponentController(Campaign selectedCampaign)
	{
		TacticalPlanFactory tempFactory = new TacticalPlanFactory(selectedCampaign);
		fieldSetManager = new FieldSetMemberxManager(Schema.SObjectType.CampaignLineItem__c, JUMPER_TACTICAL_PLANS);
		
		for(String s : fieldSetManager.getSOQLFields())
		{
			tempFactory.selectFields.add(s);
		}
		
		objectFactory = tempFactory;
		
		mode = MODE_EDIT;
		jumperTag = JUMPER_TACTICAL_PLANS;
	}
	
	public List<CampaignLineItem> tacticalPlans
	{
		get
		{
			return ( List<CampaignLineItem> ) wrapperObjects;
		}
		set;
	}
}