public class TriggerCampaignLineItemValidateForecast implements Triggers.Handler
{
	
	public void handle()
	{
		for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
		{
			if(cli.ForecastLow__c != null && cli.Forecast__c != null && cli.ForecastLow__c>cli.Forecast__c)
			{
				cli.ForecastLow__c.addError(Label.TacticalPlanValidateForecastLowHigh);
			}
		}
	}
}