/*
    Controller for AccountProductPicker page.
*/
public with sharing class AccountProductPickerController extends AccountViewExtension
{
    public ProductPicker picker {get; set;}
    public String jumperTag {get; set;}
    public String mode {get; set;}
    public String catalog {get;set;}
    public String consignment {get;set;}
    
    
    // fields for the search section
    public FieldSetMemberxManager searchFieldSet
    {
        get
        {
            if(searchFieldSet == null)
            {
                if(Util.currentLookupMode == 'Sales')
                {
                    try
                    {
                    searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup'+Util.currentDivision.name, '');
                    }catch(Exception e)
                    {
                        searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup', Util.currentDivision.name);
                    }
                }
                else
                {
                    searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup', '');
                }
            }
            return searchFieldSet;
        }
        set;
    }
    
    public FieldSetMemberxManager resultFieldSet
    {
        get
        {
            if(resultFieldSet == null)
            {
                if(Util.currentLookupMode == 'Sales')
                {
                    try
                    {
                        resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult'+Util.currentDivision.name, '');
                    }catch(Exception e)
                    {
                        resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', Util.currentDivision.name);
                    }
                    
                }
                else
                {
                    resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', '');
                }
            }
            return resultFieldSet;
        }
        set;
    }
    
    //Constructor with standard controller.
    public AccountProductPickerController(ApexPages.StandardController theController)
    {
        super (theController);
        jumperTag = Util.urlParameters.get('jumperTag');
        mode = Util.urlParameters.get('mode');
        catalog = Util.urlParameters.get('catalog');
        consignment=Util.urlParameters.get('consignment');
        
        if (jumperTag == AccountGiveAwaysController.JUMPER_GIVEAWAYS)
        {
            picker = ProductPickerBuilder.createGiveAwaysPicker(Util.currentAccount.Id);
        } else if (jumperTag == AccountTrialManagementListController.JUMPER_TRIALS)
        {
            picker = ProductPickerBuilder.createTrialsPicker(Util.currentAccount.Id);
        } else if (jumperTag == AccountTacticalPlanComponentController.JUMPER_TACTICAL_PLANS)
        {
            if('true'.equals(consignment)){ 
                picker = ProductPickerBuilder.createTacticalPlanPickerConsignment(Util.currentAccount.Id);
            }else if('Tax'.equals(catalog) || 'General'.equals(catalog)){
                picker = ProductPickerBuilder.createTacticalPlanPickerTax(Util.currentAccount.Id);  
            }else if('Regular'.equals(catalog)){
                picker = ProductPickerBuilder.createTacticalPlanPickerRegular(Util.currentAccount.Id); 
            }else if('Feb Receipt'.equals(catalog)){
                picker = ProductPickerBuilder.createTacticalPlanPickerFebReceipt(Util.currentAccount.Id);
            }else{
                picker = ProductPickerBuilder.createTacticalPlanPicker(Util.currentAccount.Id);
            }
        }
        
        for(String s : resultFieldSet.getSOQLFields())
        {
            picker.fieldsToSelect.add('ProductRef__r.'+s);
        }
        
        picker.doFilter();
        //Util.addInfoMessage(picker);
    } 
    
    //Create CampaignLineItems by selected Products and redirect to AccountView page.
    public PageReference doSave()
    {
        try{
            picker.saveResults();
        }catch(DMLException e) {
            return null;
        }
        return generateckBackLink(true);
    }
    
    //Redirect to AccountView page with mode='view'.
    public PageReference doCancel()
    {
        return generateckBackLink(false);
    }
    
    private PageReference generateckBackLink(boolean theIsSave)
    {
        return URLx.setURL('/apex/'+Util.countryView.country.AccountViewPage__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId + '&mode='
                  + (theIsSave ? mode : 'view') + '#'+jumperTag );
    }
}