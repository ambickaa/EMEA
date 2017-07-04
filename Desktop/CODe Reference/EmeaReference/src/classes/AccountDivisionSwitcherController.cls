//--------------------------------------------------
// AccountDivisionSwitcherController.cls
// Related to: AccountDivisionSwitcher.component
//
// It retrieves the possible divisions to display based on the
// active campaigns of the current user and on the different divions
// of the sales lines included in the account, and it switches
// between divisions when the user chooses a given option.
//
// Last modified by Support Team on 2016.07.29
//--------------------------------------------------
public with sharing class AccountDivisionSwitcherController
{
	public String DivisionSelected {get; set;}

	public List<SelectOption> getListDivisions()
	{
		Set<String> Division_current = new Set<String>();
		Set<String> Division_other = new Set<String>();
		
		system.debug('***INI: AccountDivisionSwitcher');
		//--------------------------------------------------
		// Different divisions from the active campaigns of the current user
		//--------------------------------------------------
		AggregateResult[] fromCampaign = [SELECT DivisionRef__r.Name div
			FROM Campaign
			WHERE isActive = true
			AND DivisionRef__c != null
			AND OwnerId = :Util.currentUser.Id
			AND RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')
			GROUP BY DivisionRef__r.Name];

		//--------------------------------------------------
		// Different divisions from the sales lines included in the account
		//--------------------------------------------------
		AggregateResult[] fromCampaignLineItem = [SELECT CampaignRef__r.DivisionRef__r.Name div
			FROM CampaignLineItem__c
			WHERE FarmRef__c = :Util.currentAccount.Id
			AND CampaignRef__c != null
			AND CampaignRef__r.YearV2__c = :Util.currentYear.Id
			AND RecordTypeId = :Util.recordType.get('CampaignLineItem__c:Sales')
			GROUP BY CampaignRef__r.DivisionRef__r.Name];
		
		//--------------------------------------------------
		// Populating sets in order to remove duplicate values from both results
		// The current division is saved in a different set, in order to print it as default value
		//--------------------------------------------------
		for(AggregateResult ar : fromCampaign)
		{
			if(ar.get('div') == Util.currentDivision.Name)
				Division_current.add((String)ar.get('div'));
			else
				Division_other.add((String)ar.get('div'));
		}

		for(AggregateResult ar : fromCampaignLineItem)
		{
			if(ar.get('div') == Util.currentDivision.Name)
				Division_current.add((String)ar.get('div'));
			else
				Division_other.add((String)ar.get('div'));
		}

		//--------------------------------------------------
		// Populating final set with the current division as default value
		//--------------------------------------------------
		Set<String> Division_all = new Set<String>();
		
		Division_all.addAll(Division_current);
		Division_all.addAll(Division_other);

		//--------------------------------------------------
		// Building the list of SelectOption that will appear on the page
		//--------------------------------------------------
		List<SelectOption> List_options = new List<SelectOption>();
		
		if(Util.currentDivision != null && !Division_all.contains(Util.currentDivision.Name))
			List_options.add(new SelectOption(Util.currentDivision.Name, Util.currentDivision.Name));
		
		for(String div : Division_all)
			List_options.add(new SelectOption(div, div));
		
		return List_options;
    }

	//--------------------------------------------------
	// Selected value of division from the Visualforce component
	//--------------------------------------------------
	public String getDivisionSelected()
	{
		return DivisionSelected;
	}

	//--------------------------------------------------
	// Method to switch the division, based on the selected value
	//--------------------------------------------------
	public PageReference goToDivision()
	{
		if(getDivisionSelected() != null && getDivisionSelected() != '')
		{
			system.debug('***Selected division: ' + getDivisionSelected());
			
			Boolean isCPdiv;
			for(String div : new List<String> {'CP','Roundup','Latitude','Monitor','Monfast','Guardian Tetra','Harness','Actimum'})
				isCPdiv = getDivisionSelected() == div ? true : false;

			if(isCPdiv)
				return URLx.setURL('/apex/AccountViewCPDE?id='+Util.urlParameters.get('id')+'&division='+Util.divisions.get(getDivisionSelected()).id+'#DivisionSwitcher');
			else
				return URLx.setURL('/apex/AccountPage?id='+Util.urlParameters.get('id')+'&division='+Util.divisions.get(getDivisionSelected()).id+'#DivisionSwitcher');
		}
		else
			return null;
	}
}