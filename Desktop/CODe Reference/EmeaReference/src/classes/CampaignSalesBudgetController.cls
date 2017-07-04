public with sharing class CampaignSalesBudgetController
{
	/**
	* Is owner flag.
	*/
	public boolean isOwner{get;set;}
	
	public CampaignSalesManager campaignManager{get;set;}
	
	/**
	* General constructor. Collects data about campaign, fires initialization.
	*/
	public CampaignSalesBudgetController(ApexPages.StandardController theController)
	{
		campaignManager = new CampaignSalesManager(theController.getRecord().Id);
		isOwner = true;
		if (campaignManager.getCurrentCampaign() == null)
		{
			//Util.addErrorMessage(System.Label.ErrorCampaignSalesWrongCampaign +  theController.getRecord().Id);
		} else if (campaignManager.getCurrentCampaign().OwnerId != Userinfo.getUserId())
		{
			isOwner = false;
			//Util.addErrorMessage(System.Label.ErrorCampaignSalesNotOwner +  theController.getRecord().Id);
		} else
		{
			campaignManager.loadFullCampaignsList();
		}
	}
	
	/*
	* Saves current budget allocation.
	*/
	public PageReference doSave()
	{
		try
		{
			campaignManager.saveChildrenCampaign();
		} catch (CampaignSalesManager.SalesCampaignSaveException theException)
		{
			Util.addErrorMessage(theException.getMessage());
			return null;
		}
		//return new Pagereference('/' + campaignManager.getCurrentCampaign().Id);
		Util.addConfirmMessage(System.Label.ConfirmCampaignSalesSave);
		return null;
	}
	
	/**
	* Checks if the budget was allocated correctly. If so, sends notification emails to the all children campaigns' owners.
	*/
	public PageReference doSendNotifications()
	{
		try
		{
			campaignManager.notifyUsers();
		} catch (CampaignSalesManager.SalesCampaignSaveException theException)
		{
			Util.addErrorMessage(theException.getMessage());
			return null;
		}
		Util.addConfirmMessage(System.Label.ConfirmCampaignSalesNotified);
		return null;
	}
	
	/**
	* Cancels the current allocation.
	*/
	public PageReference doCancel()
	{
		return new Pagereference('/' + campaignManager.getCurrentCampaign().Id);
	}

}