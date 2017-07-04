public class VoucherItalyController 
{
    public Account currentAccount
    {
        get
        {
            if(currentAccount == null)
            {
                currentAccount = Util.currentAccount;
            }
            return currentAccount;
        } 
        set;
    }
    
    public List<CampaignLineItem__c>lineItems
    {
        get
        {
            if(lineItems == null)
            {
                lineItems = [SELECT ID, ProductRef__c, ProductRef__r.name, Quantity__c, PlantingDensity__c, DistributorRef__c, DistributorRef__r.Name From CampaignLineItem__c WHERE FarmRef__c = :Util.urlParameters.get('id') AND ProductRef__r.DivisionRef__c = :Util.urlParameters.get('division') AND CampaignRef__c = :Util.currentCampaign.id AND DistributorRef__c = :Util.urlParameters.get('distributor') AND Status__c = 'Ordered / Discussed' AND Type__c='Charged'];
            }
            return lineItems;
        }
        set;
    }
    public String dateToday
    {
        get
        {
            return Date.today().format();
        }
        set;
    }
}