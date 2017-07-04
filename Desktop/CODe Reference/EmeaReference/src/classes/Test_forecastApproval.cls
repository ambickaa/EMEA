@isTest
private class Test_forecastApproval 
{
	
	private static testMethod void testForecast()
	{
		forecastApprovalController controller = new forecastApprovalController();
		
		try{
			
			Campaign aCampaign = controller.getCurrentForecast();
			forecastApprovalController.forecastDetails fd = new forecastApprovalController.forecastDetails();
			forecastApprovalController.Hybrid hy = new forecastApprovalController.Hybrid('dkc 123','F11','Thiram',50);
			controller.doApprove();
			controller.doReject();
		}
		catch(Exception e)
		{
			
		}
		
	}
	

}