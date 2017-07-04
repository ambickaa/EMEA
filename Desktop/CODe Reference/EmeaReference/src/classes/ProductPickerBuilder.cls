/*
    Create ProductPicker with required parameters.
*/
public with sharing class ProductPickerBuilder
{
    //Create ProductPicker as GiveAwayPicker by AccountId
    public static ProductPicker createGiveAwaysPicker(Id theAccountId)
    {
        ProductPicker aPicker = new GiveAwayProductPicker(theAccountId);
        aPicker.filters = generateCatalogCondition(Util.currentCampaign.GiveAwayPCMRef__c);
        return aPicker; 
    }
    
    //Create ProductPicker as TrialsPicker by AccountId
    public static ProductPicker createTrialsPicker(Id theAccountId)
    {
        ProductPicker aPicker = new TrialProductPicker(theAccountId);
        al.OrCondition aCondition = new al.OrCondition();
        aCondition.add(generateCatalogCondition(Util.currentCampaign.TrialPCMRef__c));
        aCondition.add(generateCatalogCondition(Util.currentCampaign.CompetitorPCMRef__c));
        aPicker.filters = aCondition;
        return aPicker; 
    }
    
    //Create ProductPicker as TacticalPlanPicker by AccountId
    public static ProductPicker createTacticalPlanPicker(Id theAccountId)
    {
        ProductPicker aPicker = new TacticalPlanProductPicker(theAccountId);

        aPicker.filters = generateCatalogCondition(Util.currentCampaign.SalesPCMRef__c);

        return aPicker; 
    }
    
    //Create ProductPicker as TacticlaPlanPicker by AccountID but using previous campaign catalog
    public static ProductPicker createTacticalPlanPickerTax(Id theAccountId)
    {
        ProductPicker aPicker = new TacticalPlanProductPicker(theAccountId);
        
        al.AndCondition aCondition = new al.AndCondition();
        aCondition.add(generateCatalogCondition(Util.currentCampaign.TaxSalesPCMRef_RSA__c));
        aCondition.add(new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0));      
     
        aPicker.filters = aCondition;
        return aPicker;
    }
    
    public static ProductPicker createTacticalPlanPickerRegular(Id theAccountId)
    {
        ProductPicker aPicker = new TacticalPlanProductPicker(theAccountId);
        
        al.AndCondition aCondition = new al.AndCondition();
        aCondition.add(generateCatalogCondition(Util.currentCampaign.SalesPCMRef__c));
        aCondition.add(new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0));      
     
        aPicker.filters = aCondition;
        return aPicker;
    }
    
    public static ProductPicker createTacticalPlanPickerConsignment(Id theAccountId)
    {
        ProductPicker aPicker = new TacticalPlanProductPicker(theAccountId);
        
        Account theAccount=[SELECT OwnerId FROM Account WHERE Id=:theAccountId];
        list<String> consignedProducts= new list<String>(); 
        for(Consignment__c con:[SELECT id, ProductCatalogEntryRef__r.ProductRef__c FROM Consignment__c 
        						WHERE UserRef__c=:theAccount.OwnerId AND Status__c='Accepted']){
        	consignedProducts.add(con.ProductCatalogEntryRef__r.ProductRef__c);
        }
        al.AndCondition aCondition = new al.AndCondition();
        aCondition.add(generateCatalogCondition(Util.currentCampaign.SalesPCMRef__c));
        aCondition.add(new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0));      
        aCondition.add(new al.SetCondition('ProductRef__c',al.Operator.INX,consignedProducts));
        System.Debug('Enric'+consignedProducts);      
        aPicker.filters = aCondition;
        return aPicker;
    }    
  
    public static ProductPicker createTacticalPlanPickerFebReceipt(Id theAccountId)
    {
        ProductPicker aPicker = new TacticalPlanProductPicker(theAccountId);
        
  		al.AndCondition aCondition = new al.AndCondition();
        aCondition.add(generateCatalogCondition(Util.currentCampaign.SalesPCMRef__c));
        aCondition.add(new al.FieldCondition('PriceOld__c', al.Operator.GREATER_THAN,0));      
        
        aPicker.filters = aCondition;
        return aPicker;
    } 
 
    
    //Add ProductCatalogRef__c field to condition filter.
    private static al.Condition generateCatalogCondition(Id theCatalogId)
    {
        return new al.FieldCondition('ProductCatalogRef__c', theCatalogId);
    }
    
    //Abstract class AccountProductPicker
    public abstract class AccountProductPicker extends ProductPicker
    {
        protected Id accountId;
        
        public AccountProductPicker(Id theAccountId)
        {
            accountId = theAccountId;
        }
    }
    
    //Class GiveAwayProductPicker for ProductPicker
    public class GiveAwayProductPicker extends AccountProductPicker
    {
        public GiveAwayProductPicker(Id theAccountId)
        {
            super(theAccountId);
        }
        
        public override void saveResults()
        {
            List<CampaignLineItem__c> aResList = new List<CampaignLineItem__c>();
            for (Product2 aProduct: selectedProducts)
            {
                CampaignLineItem__c aCLI = new CampaignLineItem__c();
                aCLI.RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway');
                aCLI.FarmRef__c = accountId;
                aCLI.CampaignRef__c = Util.currentCampaign.id;
                aCLI.ProductRef__c = aProduct.Id;
                aResList.add(aCLI);
            }
            insert aResList;
        }
    }
    
    //Class TrialProductPicker for ProductPicker
    public class TrialProductPicker extends AccountProductPicker
    {
        public TrialProductPicker(Id theAccountId)
        {
            super(theAccountId);
        }
        
        public override void saveResults()
        {
            CampaignLineItemGroup__c aTrial = new CampaignLineItemGroup__c();
            aTrial.CampaignRef__c = Util.currentCampaign.id;
            aTrial.AccountRef__c = accountId;
            insert aTrial;
            List<CampaignLineItem__c> aResList = new List<CampaignLineItem__c>();
            for (Product2 aProduct: selectedProducts)
            {
                CampaignLineItem__c aCLI = new CampaignLineItem__c();
                aCLI.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial');
                aCLI.CampaignLineItemGroupRef__c = aTrial.id;
                aCLI.FarmRef__c = accountId;
                aCLI.CampaignRef__c = Util.currentCampaign.id;
                aCLI.ProductRef__c = aProduct.Id;
                aResList.add(aCLI);
            }
            insert aResList;
        }
    }
    
    //Class TacticalPlanProductPicker for ProductPicker
    public class TacticalPlanProductPicker extends AccountProductPicker
    {
        public TacticalPlanProductPicker(Id theAccountId)
        {
            super(theAccountId);
        }
        
        public override void saveResults()
        {
            List<CampaignLineItem__c> aResList = new List<CampaignLineItem__c>();
            for (Product2 aProduct: selectedProducts)
            {
                CampaignLineItem__c aCLI = new CampaignLineItem__c();
                aCLI.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
                aCLI.FarmRef__c = accountId;
                aCLI.CampaignRef__c = Util.currentCampaign.id;
                aCLI.ProductRef__c = aProduct.Id;
                if(Util.urlParameters.get('Catalog') != null)
                {
                    aCli.CatalogType_RSA__c = Util.urlParameters.get('Catalog');
                    if(Util.urlParameters.get('Catalog').equalsIgnoreCase('FreeOfCharge')){
                        aCli.Type__c = 'Free of charge';
                    }else{
                        aCli.Type__c = 'Charged';
                    }
                }
                if(Util.urlParameters.get('consignment')!=null && Util.urlParameters.get('consignment').equalsIgnoreCase('true'))
                	aCLI.Consigned__c=true;
                aResList.add(aCLI);
            }
            insert aResList;
        }
    }
}