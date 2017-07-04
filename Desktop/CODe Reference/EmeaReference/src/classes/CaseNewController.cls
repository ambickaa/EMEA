public virtual class CaseNewController
{
    public Casex currentCase {get; set;}
    public String mode = 'edit';
    
    public CaseNewController( ApexPages.StandardController stdController )
    {
        CasexFactory cf = new CasexFactory();
        currentCase = (Casex)cf.createAnEmptyRecord(Util.urlParameters.get('accountId'));
        
        currentCase.record = (Case)stdController.getRecord();
        currentCase.record.AccountId = Util.urlParameters.get('accountId');
        currentCase.record.OwnerId = UserInfo.getUserId();
    }
    
    public PageReference save()
    {
        if (currentCase.lookupValue.id == null || currentCase.lookupValue.id.length() < 15)
        {
            Util.addErrorMessage(Label.ErrorCaseNoProduct);
        }
        else
        {
            try
            {
                currentCase.record.GC_Product_SFID__c = currentCase.lookupValue.id;
                insert currentCase.record;
                return new PageReference('/' + currentCase.record.Id);
            }
            catch (Exception e)
            {
                Util.addErrorMessage(Label.ErrorCaseCannotSave + e.getMessage());
            }
        }
        
        return null;
    }
    
    public PageReference cancel()
    {
        // redirect back to account view
        return new PageReference('/' + Util.urlParameters.get('accountId'));
    }
}