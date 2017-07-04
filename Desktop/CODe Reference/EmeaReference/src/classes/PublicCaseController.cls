public without sharing class PublicCaseController
{
	public static final String EMAIL_TEMPLATE_DEVELOPER_NAME = 'CaseClosedByTdNotificationText';
	
	private CasexFactory cf;
	public Casex currentCase {get; set;}
	public boolean showCommentWindow {get; set;}
	public String newCommentBody {get; set;}
	
	public PublicCaseController()
	{
		String caseIdUrl = ApexPages.currentPage().getParameters().get('id');
		if (caseIdUrl != null)
		{
			init(caseIdUrl);
		}
	}
	
	public PublicCaseController(String id)
	{
		init(id);
	}
	
	private void init(String id)
	{
		// get case wrapper
		cf = new CasexFactory();
		currentCase = (Casex)cf.createObjectWrapperForCaseId(id);
	}
	
	public PageReference closeCase()
	{
		try
		{
			// upate the case status
			Case shadowCase = new Case(Id=currentCase.record.Id, Status = 'Closed');
			update shadowCase;
			
			// send emails
			notifyOwner();
			
			// reload the case
			currentCase = (Casex)cf.createObjectWrapperForCaseId(currentCase.id);
		}
		catch( Dmlexception ex )
		{
			ApexPages.addMessages( ex );
		}
		return null;
	}
	
	public PageReference openCommentWindow()
	{
		showCommentWindow = true;
		return null;
	}
	
	public PageReference closeCommentWindow()
	{
		showCommentWindow = false;
		return null;
	}
	
	public void addNewComment()
	{
		CaseComment comment = new CaseComment(ParentId = currentCase.record.Id, CommentBody = newCommentBody);
		insert comment;
		currentCase.readComments();
		closeCommentWindow();
	}
	
	private void notifyOwner()
	{
		List<EmailTemplate> templateList = [SELECT subject, body FROM EmailTemplate WHERE developerName = :EMAIL_TEMPLATE_DEVELOPER_NAME];
		if (templateList.isEmpty())
		{
			Util.addErrorMessage(Label.ErrorCaseNoEmailTemplate);
		}
		else
		{
			EmailTemplate et = templateList[0];
			try
			{
				// merge template fields
				mergeTemplate(et, currentCase.record);
				
				// prepare email message
				Messaging.SingleEmailMessage aMail = new Messaging.SingleEmailMessage();
				aMail.setSaveAsActivity(false);
				aMail.setSubject(et.subject);
				aMail.setPlainTextBody(et.body);
				aMail.setToAddresses(new String[]{currentCase.record.Owner.Email});
				
				// send email
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {aMail});
			}
			catch (Exception e)
			{
				Util.addErrorMessage(Label.ErrorCaseErrorSendingEmail + ' ' + e.getMessage());
			}
		}
	}
	
	public void mergeTemplate(EmailTemplate et, Case c)
	{
		// init merge fields
		Map<String, String> mergeFields = new Map<String, String>();
		mergeFields.put('Owner.FirstName', c.Owner.Name);
		mergeFields.put('Account.Name', c.Account.Name);
		mergeFields.put('Contact.Name', c.Contact.Name);
		mergeFields.put('Case.CaseNumber', c.CaseNumber);
		mergeFields.put('Case.Subject', c.Subject);
		mergeFields.put('Case.Description', c.Description);
		// merge fields
		for (String key : mergeFields.keySet())
		{
			
			et.subject = et.subject.replace('{!' + key + '}', mergeFields.get(key));
			et.body = et.body.replace('{!' + key + '}', mergeFields.get(key));
		}
	}
}