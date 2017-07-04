/*
* To remove a Value from the status Dropdown use new Permission('ValueName', 'removeStatus');
* To disable quanity field and set the field to 0 use new Permission('ValueName', 'disableQuantity');
* To disbale a value that is part of the status Dropdown options use new Permission('ValueName', 'disableStatus') 
*/
public class AccountTacticalPlanStatusPermController 
{
	// permission Set
	private List<Permission> permissions = new List<Permission>();
	
	// construct permissions
	public AccountTacticalPlanStatusPermController()
	{
		
		// disable Quantity Field for cancel or hide status Value
		if(Util.countryView.isCancelledStatusValueForTacticalPlan)
		{
			permissions.add(new Permission('Cancelled', 'QuantityToZero'));
			permissions.add(new Permission('Cancelled', 'disableQuantity'));
		}
		else
		{
			permissions.add(new Permission('Cancelled', 'removeStatus'));
		}
		// disable Forecast based on campaign settings
		try
		{
		if(Util.currentCampaign.DisableForecastStatus__c <> null && Util.currentCampaign.DisableForecastStatus__c)
		{
			permissions.add(new Permission('Forecast', 'disableStatus'));
			permissions.add(new Permission('Forecast', 'disableQuantity'));
		}
		}catch(Exception e){}
	}
	
	public String getPermissions()
	{
		
		return Json.serialize(permissions);
	}
	
	/*
	*	PermissionSet for tacticalPlan
	*/
	
	public class Permission
	{
		public String name {get; set;}
		public String value {get; set;}
		public Permission()
		{
			
		}
		public Permission(String name, String value)
		{
			this.name = name;
			this.value = value;
		}
	}
}