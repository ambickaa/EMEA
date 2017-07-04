//-------------------------------------------------------
// Apex class  AccountPageController
// Test class  AccountPageController_Test
// Author    Support Team
// Last update  30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageController {
    
    private final ApexPages.StandardController stdController;

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean showDivisionSwitcher {get; private set;}
    public Boolean showActionPlan {get; private set;}
    public Boolean showGiveAways {get; private set;}
    public Boolean showAcreages {get; private set;}
    public Boolean showVouchers {get; private set;}
    public Boolean showRetoure {get; private set;}
    public Boolean showTrials {get; private set;}
    public Boolean showMarketingCampaigns {get; private set;}
    public Boolean showDetail {get; private set;}
    public Boolean showPageMessages {get; set;}
    public Boolean isOwner {get { return Util.isAccountOwner; } protected set;}
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
        return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}
    public String CurrentCountry {get;set;}
    
    public Map<String, AccountPageSettings__c> DisplayComponents = AccountPageSettings__c.getall();
    
    private Id accountId;
    
    public Account currentAccount{get; set;}
    
    public AccountPageController(ApexPages.StandardController stdController)
    {
//-------------------------------------------------------
// Do not call Visualforce components for non-accessible accounts.
//-------------------------------------------------------
        if(Util.currentAccount.Id == null)
        {
//-------------------------------------------------------
// It checks if the account has been removed from the system.
//-------------------------------------------------------
            Account[] accountInfo = [SELECT Id, Name, Client_Code__c, IsDeleted FROM Account WHERE Id = :stdController.getId() LIMIT 1 ALL ROWS];
            Boolean accountDeleted = accountInfo.size() > 0 ? accountInfo[0].IsDeleted : false;

            if(accountDeleted)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.AccountPage_msg_account_deleted_1 + accountInfo[0].Name + ' (' + accountInfo[0].Client_Code__c + ')' + Label.AccountPage_msg_account_deleted_2 + '<b>Id = ' + accountInfo[0].Id + '</b>' + Label.AccountPage_msg_account_deleted_3));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_access_not_allowed));
          
            showDivisionSwitcher = showActionPlan = showGiveAways = showAcreages = showVouchers = showTrials = showDetail = showRetoure = false;
//-------------------------------------------------------
// Call Visualforce components for accessible accounts.
//-------------------------------------------------------
        } else {
            accountId = stdController.getId();
            currentCountry = Util.currentUser.Country !=null? Util.currentUser.Country : '';

            for(Account a : [SELECT Id, NUM_Locale_Test__c FROM Account WHERE Id = :accountId])
            {
                currentAccount = a;
                currentAccount.NUM_Locale_Test__c = 100010/100;
            }
            if(currentAccount != null)
            {
//-------------------------------------------------------
// Page messages with info messages.
//-------------------------------------------------------
                if(!isOwner && !isAdmin)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_no_account_owner));
                }
                if(Util.currentCampaign == null && !isAdmin)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_no_active_campaign_available));
                }

//-------------------------------------------------------
// Get components to display from custom setting
//-------------------------------------------------------
                
                String countryName = Util.countryView.country != null ? Util.countryView.country.Name : (Util.currentUser.Country != null ? Util.currentUser.Country : '');
                String accountType = isFarmAccount ? '_Farm' : (isDistAccount ? '_Distributor' : '');
                
                String ViewKey = countryName + accountType;
                ViewKey = DisplayComponents.containsKey(ViewKey) ? ViewKey : countryName;
                
                Boolean ViewActionPlan = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Action_Plan__c : false;
                Boolean ViewAcreages = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Acreages__c : false;
                Boolean ViewVouchers = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Vouchers__c : false;
                Boolean ViewTrials = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Trials__c : false;
                Boolean ViewGiveAways = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Giveaways__c : false;
                Boolean ViewMarketingCampaigns = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Marketing_Campaigns__c : false;
                Boolean ViewRetoure = DisplayComponents.containsKey(ViewKey) ? DisplayComponents.get(ViewKey).Retoure__c : false;

//-------------------------------------------------------
// Logics to render or hide the different Visualforce components.
//-------------------------------------------------------
                
                showActionPlan = ((isFarmAccount || isDistAccount) && ViewActionPlan);
                showDivisionSwitcher = ((isFarmAccount || isDistAccount) && showActionPlan);
                showAcreages = ((isFarmAccount || isDistAccount) && ViewAcreages);
                showTrials = ((isFarmAccount || isDistAccount) && ViewTrials);
                showVouchers = ((isFarmAccount || isDistAccount) && ViewVouchers);
                showGiveAways = ((isFarmAccount || isDistAccount) && ViewGiveAways);
                showMarketingCampaigns = ((isFarmAccount || isDistAccount) && ViewMarketingCampaigns);
                showRetoure = ((isFarmAccount || isDistAccount) && ViewRetoure);
                showDetail = true;
          
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AccountPage_msg_access_not_allowed));
                showPageMessages = true;
            }
        }
        showPageMessages = true;
    }

//-------------------------------------------------------
// PageReference method to redirect to another page in some cases.
//-------------------------------------------------------
    public PageReference redirectPage()
    {
        String p = Util.currentUser.Profile.Name;
        String a = Util.currentAccount.RecordType.DeveloperName;
        Map<String, String> Map_Parameters = ApexPages.currentPage().getParameters();
        PageReference r = null;
    
        if(Util.currentAccount.Id != null && currentAccount != null)
        {
//-------------------------------------------------------
// It redirects to non-Visualforce account view when:
// - User profile is "Customer Services"
// - User profile is "System Administrator" and the record type of the record is "Account Global"
//-------------------------------------------------------
            if(Label.ProfileName.equals(p) || (Label.SystemAdminProfile.equals(p) && Label.Account_Global.equals(a)))
            {
                r = new PageReference('/' + accountId + '?nooverride=1');
            }
//-------------------------------------------------------
// It redirects to CP views (Germany or non-Germany) when the user division is CP.
//-------------------------------------------------------
            if(r == null && Util.currentUser.Division == 'CP')
            {
                r = Util.currentUser.Country != 'Germany' ? new PageReference('/apex/AccountViewCP') : new PageReference('/apex/AccountViewCPDE');
            }
//-------------------------------------------------------
// It redirects to custom views when they are set at country level.
//-------------------------------------------------------
            if(r == null && Util.countryView.country.AccountViewPage__c != 'AccountPage' && Util.countryView.country.AccountViewPage__c != null && !Label.SystemAdminProfile.equals(p) && !Label.DataManagementProfile.equals(p))
            {
                r = new PageReference('/apex/' + Util.countryView.country.AccountViewPage__c);
            }
//-------------------------------------------------------
// Populating page parameters
//-------------------------------------------------------
            if(Map_Parameters.containsKey('core.apexpages.devmode.url'))
                Map_Parameters.remove('core.apexpages.devmode.url');
            if(r != null)
            {
                r.getParameters().putAll(Map_Parameters);
                r.setRedirect(true);
            }
        }
    return r;
    }
}