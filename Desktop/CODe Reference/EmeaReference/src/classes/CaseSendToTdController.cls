public virtual class CaseSendToTdController
{
	public static final String TARGET_CASE_STATUS = 'At Technical Department';
	
	private String userCountryIsoCode;
	public String emailContactId;
	public String emailTemplateId;
	
	public Casex currentCase {get; set;}
	public String status {get; set;}
	
	public CaseSendToTdController()
	{
		// fetch information on the actual case
		CasexFactory cf = new CasexFactory();
		currentCase = (Casex)cf.createObjectWrapperForCaseId(Util.urlParameters.get('id'));
		
		// read country pref for the current user
		User anUser = [SELECT CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId()];
		userCountryIsoCode = anUser.CountryISOCode__c;
		
		// get email address and template based on user prefs
		if (userCountryIsoCode != null)
		{
			TechnicalDepartments__c aTechDepartments = TechnicalDepartments__c.getInstance(userCountryIsoCode);
			if (aTechDepartments != null)
			{ 
				emailContactId = aTechDepartments.GenericContactId__c;
				emailTemplateId = aTechDepartments.EmailTemplateId__c;
			}
		}
	}
	
	public PageReference processCase()
	{
		PageReference aTargetPage;
		
		// check preconditions
		if (userCountryIsoCode == null)
		{
			Util.addErrorMessage(Label.ErrorCaseNoCountryForUser);
			Util.addErrorMessage(Label.ErrorCaseNotTransfered);
		}
		else if (emailContactId == null)
		{
			Util.addErrorMessage(Label.ErrorCaseNoEmailAddress);
			Util.addErrorMessage(Label.ErrorCaseNotTransfered);
		}
		else if (emailTemplateId == null)
		{
			Util.addErrorMessage(Label.ErrorCaseNoEmailTemplate);
			Util.addErrorMessage(Label.ErrorCaseNotTransfered);
		}
		else if (currentCase.record.Status == TARGET_CASE_STATUS)
		{
			Util.addInfoMessage(Label.ErrorCaseInTargetStatus);
		}
		// all good, continue
		else
		{
			// update case status
			Case anUpdatedCase = new Case (Id = currentCase.Id, Status = TARGET_CASE_STATUS);
			update anUpdatedCase;
			
			// send email notification to technical department
			try
			{
				Messaging.SingleEmailMessage aMail = new Messaging.SingleEmailMessage();
				aMail.setTargetObjectId(emailContactId);
				aMail.setWhatId(currentCase.Id);
				aMail.setTemplateId(emailTemplateId);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {aMail});
				
				//Redirect back to account view
				aTargetPage = new PageReference('/' + currentCase.record.AccountId);
				aTargetPage.setAnchor('AccountComplaintList');
			}
			catch (Exception e)
			{
				Util.addErrorMessage(Label.ErrorCaseErrorSendingEmail + ' ' + e.getMessage());
			}
		}
		
		//Redirect if possible
		return aTargetPage;
	}
	
	public PageReference returnToCase()
	{
		return new PageReference('/' + currentCase.Id);
	}
	
	public PageReference returnToAccount()
	{
		PageReference aTargetPage = new PageReference('/' + currentCase.record.AccountId);
		aTargetPage.setAnchor('AccountComplaintList');
		return aTargetPage;
	}
	
}