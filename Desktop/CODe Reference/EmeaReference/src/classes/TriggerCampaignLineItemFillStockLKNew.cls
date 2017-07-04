/*
    Class that takes care of filling PersonalStock_RSA__c and GlobalStock_RSA__c lookup fields accordingly
*/
public class TriggerCampaignLineItemFillStockLKNew implements Triggers.Handler{

    public void handle(){
        Set<ID> accountsUsed = new Set<ID>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(cli.FarmRef__c != null)accountsUsed.add(cli.FarmRef__c);
        }
        TriggerCampaignLineItemHelper.add(accountsUsed);
        if(TriggerCampaignLineItemHelper.rsa.isEmpty())return;
        List<CampaignLineItem__c> toUpdate = new List<CampaignLineItem__c>();
         for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && ('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c))){
                toUpdate.add(new CampaignLineItem__c(id=cli.id));
            }    
        }
        update toUpdate;
    }

}