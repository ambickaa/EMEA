public with sharing class Acreage implements AccountListObjectWrapper
{
	public boolean checked {get; set;}
	public Acreage__c acreage{get;set;}
	public Acreage__c prevAcreage{get;set;}
	public String rtName{get;set;}
	
	//The record is unchecked by default.
	{
		this.checked = false;
	}
	
	public Boolean isNewAcreage
	{
		get
		{
			return prevAcreage == null && acreage.Id == null;
		}
	}
	
	public Boolean isHasPrev
	{
		get
		{
			return acreage.PreviousAcreageRef__c != null;
		}
	}
	
	public Acreage(String theRTName)
	{
		this(null, false);
		acreage.RecordTypeId = Util.recordType.get('Acreage__c:' + theRTName);
	}
	
	public Acreage(Acreage__c theAcreage, Acreage__c thePrevAcreage)
	{
		acreage = theAcreage;
		prevAcreage = thePrevAcreage;
	}
	
	public Acreage(Acreage__c theAcreage, boolean theThisYear)
	{
		if (theThisYear)
		{
			acreage = theAcreage;
			prevAcreage = theAcreage.PreviousAcreageRef__r;
		}
		else
		{
			prevAcreage = theAcreage;
			acreage = generateNewAcreage(theAcreage);
		}
	}
	
	private Acreage__c generateNewAcreage(Acreage__c thePreviousAcreage)
	{
		Acreage__c aResult = new Acreage__c();
		aResult.AcrFarmRef__c = Util.currentAccount.Id;
		aResult.AcrYearRef__c = Util.currentYear.Id;
		aResult.AcrTotalAcreages__c = 0;
		if (thePreviousAcreage != null)
		{
			aResult.RecordTypeId = thePreviousAcreage.RecordTypeId;
			aResult.PreviousAcreageRef__c = thePreviousAcreage.Id;
			aResult.AcrProductGroupRef__c = thePreviousAcreage.AcrProductGroupRef__c;
			aResult.AcrProviderRef__c = thePreviousAcreage.AcrProviderRef__c;
			aResult.AcrProductTypeRef__c = thePreviousAcreage.AcrProductTypeRef__c;
			aResult.AcrProductRef__c = thePreviousAcreage.AcrProductRef__c;
			aResult.PreviousAcreageRef__r = thePreviousAcreage;
		}
		
		return aResult;
	}
	
	public List<sObject> getSelectedRecords()
	{
		List<sObject> aResult = new List<sObject>();
		
		if (acreage.Id != null && checked)
		{
			aResult.add(acreage);
		}
		return aResult;
	}
	
	public List<sObject> getFilledRecords()
	{
		List<sObject> aResult = new List<sObject>();
		if (acreage.Id != null || acreage.AcrTotalAcreages__c > 0)
		{
			aResult.add(acreage);
		}
		return aResult;
	}
}