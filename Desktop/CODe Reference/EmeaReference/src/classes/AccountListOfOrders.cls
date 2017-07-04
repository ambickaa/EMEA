public with sharing class AccountListOfOrders
{

    public String orders { get; set; }

    public String getOrders() {
        return null;
    }

    public AccountListOfOrders rsaController {get; set;}
 
    public Campaign currentCampain {get { return Util.currentCampaign; } set;}
    public Division__c currentDivision {get{ return Util.currentDivision; } set;}
  
    public Account account
    {
        get
        {
           return Util.currentAccount;
        }
        set;
    }
}