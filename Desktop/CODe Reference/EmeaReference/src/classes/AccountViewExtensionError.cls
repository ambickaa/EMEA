public virtual class AccountViewExtensionError
{

    private final ApexPages.StandardController controller;
    public String recordId {get;set;}
    public String accDeleted {get;set;}
    public boolean isDel {get;set;}

    public AccountViewExtensionError(ApexPages.StandardController sc){
        this.controller = sc;       
        recordId = sc.getId();
        accDeleted = System.currentPageReference().getParameters().get('IsDeleted');
        //system.debug('*Is the account deleted? ' + accDeleted);

        if(accDeleted == 'true'){
            isDel =  true;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, '<b>' + Label.AccountViewErrorDelete + '</b><br/><br/>') );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, '<b>Account Id</b><br/>' + recordId) );
            
        } else {
            isDel =  false;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, '<b>' + Label.AccountViewErrorLabel + '</b><br/>' + Label.AccountViewErrorText + '<br/><br/>' ));
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, '<b>Account Id</b><br/>' + recordId) );
        }

    }

}