public with sharing class AccountFreeOfChargeController extends AccountListVirtualController {

    public Division__c currentDivision {get{ return Util.currentDivision; } set;}
    
    public boolean getIsRSAView()
    {
        return Util.countryView.isRSATacticalPlan;
    }
    
    private FreeOfCharge theFreeOfCharge;

    public FreeOfCharge getFreeOfCharge()
    {
        if(theFreeOfCharge == null)
        {
            theFreeOfCharge = new FreeOfCharge();
        }
        return theFreeOfCharge;
    }

    public class FreeOfCharge
    {

        public List<OrderItem> productFOC {get;set;}
        public List<CampaignLineItem__c> toDelete {get;set;}   
        
        private ID currentAccountID {get;set;}
        
        public Boolean editMode {get{if(editMode == null) editMode = false; return editMode;}set;}
               
        public FreeOfCharge()
        {
            init();
        }    
    
        public void init()
        {    
           Campaign currentCampaign = Util.currentCampaign;
           if(currentCampaign == null) return; 
           List<CampaignLineItem__c> allItems = 
            [
                SELECT 
                    CatalogType_RSA__c,
                    ProductRef__c,
                    Forecast__c,
                    QuantityFOC__c,
                    ProductRef__r.Name,
                    ProductRef__r.ProductKernelSize__c,
                    ProductRef__r.ProductTreatment__c
                FROM CampaignLineItem__c 
                WHERE FarmRef__c = :Util.currentAccount.ID
                  AND CampaignRef__c = :currentCampaign.ID
                  AND Type__c = 'Free of Charge'
                ORDER BY CreatedDate ASC
            ];
           currentAccountID = Util.currentAccount.ID;
           if(!editMode)productFOC = new List<OrderItem>();
            
          for(CampaignLineItem__c cli : allItems)
           {
                if(!editMode)
                {
                    productFOC.add(new OrderItem(cli));
                }
           } 
        }
        
        public void edit(){
            editMode = true;
            toDelete = new List<CampaignLineItem__c>();
        }
         public void addNew(){
            productFOC.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, Type__c = 'Free of Charge', CampaignRef__c = Util.currentCampaign.ID)));
            edit();
        }       
        public void cancel(){
            editMode = false;
            init();
        }     
        public void save(){
            List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
            List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
            for(OrderItem oi : productFOC)
            {
              if(oi.lookupValue.id!=null && oi.lookupValue.id != ''){
                oi.item.ProductRef__c = oi.lookupValue.id;
                  (oi.item.id == null?toInsert:toModify).add(oi.item);
              }
            }
            insert toInsert;
            update toModify;
            delete toDelete;
            editMode = false;
            init();
        }        
        public void deleteSelected(){
          if(!editMode) toDelete = new List<CampaignLineItem__c>();
            List<OrderItem> newProductFOC = new List<OrderItem>();
            for(OrderItem oi : productFOC)
            {
                if(oi.selected)
                {
                    if(oi.item.id != null){
                        toDelete.add(oi.item);
                    }
                }else{
                    newProductFOC .add(oi);
                }
            }
            productFOC= newProductFOC ;
            if(!editMode)save();
        }        
           
    }
    
    
    public class OrderItem
    {
        public CampaignLineItem__c item {get;set;}
        public LookupValue lookupValue {get;set;}
        public Boolean selected {get;set;}
        public OrderItem(CampaignLineItem__c item)
        {
            this.item = item;
            this.selected = false;
            if(item.ProductRef__c != null) lookupvalue = new LookupValue(item.ProductRef__c,item.ProductRef__r.Name);
            else lookupValue = new LookupValue();
        }
    }
    
    public PageReference doLoadProductPickerRegular(){
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',AccountTacticalPlanComponentController.JUMPER_TACTICAL_PLANS);
        returned.getParameters().put('mode','tacticalEdit');
        returned.getParameters().put('catalog','FreeOfCharge');
        return returned;
    }

}