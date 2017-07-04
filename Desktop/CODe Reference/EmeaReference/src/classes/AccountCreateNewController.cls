public class AccountCreateNewController
{

    public static final String ACCOUNT_CREATE_NEW = '/001/e';
    
    //Constructor with standard controller
    public AccountCreateNewController(ApexPages.StandardController theController)
    {
        
    }
    
    //Method which added some parameters and redirect to another page.
    public PageReference doRedirect()
    {
        PageReference aResult = new PageReference(ACCOUNT_CREATE_NEW);
        aResult.setRedirect(true);
        aResult.getParameters().putAll(Apexpages.currentPage().getParameters());
        aResult.getParameters().put('nooverride', '1');

        aResult.getParameters().remove('sfdc.override');
        aResult.getParameters().remove('save_new');
        if (Util.currentCountry != null)
        {
            aResult.getParameters().put('CF00ND0000004V0qz',Util.currentCountry.name);
            aResult.getParameters().put('CF00ND0000004V0qz_lkid',Util.currentCountry.ID);
        }
        return aResult;
    }
}