public class AccountaddMultipleLinesController
{
	public AccountaddMultipleLinesStrategy strategy {get; set;}
	
	public AccountaddMultipleLinesController()
	{
		if(Util.urlParameters.get('selectionMode') == 'enterValue')
		{
			strategy = new TacticalPlanAddMultipleLinesStrategy();
		}
		else if(Util.urlParameters.get('selectionMode') == 'checkbox')
		{
			
		}
	}
}