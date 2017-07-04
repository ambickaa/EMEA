public virtual class CaseEditController
{
    public Casex currentCase {get; set;}
    public String mode = 'edit';
    
    public CaseEditController( ApexPages.StandardController stdController )
    {
        CasexFactory cf = new CasexFactory();
        currentCase = (Casex)cf.createObjectWrapperForCaseId(stdController.getRecord().Id);
    }
    
    public PageReference save()
    {
        if (currentCase.lookupValue != null && currentCase.lookupValue.id != null)
        {
            currentCase.record.GC_Product_SFID__c = currentCase.lookupValue.id;
        }
        update currentCase.record;
        
        // redirect back to account view
        return new PageReference('/' + currentCase.Id);
    }
    
    public PageReference cancel()
    {
        // redirect back to account view
        return new PageReference('/' + currentCase.Id);
    }
    
}