public class TriggerOrderCalculatePrice implements Triggers.Handler
{
  private static map<id, CampaignLineItem__c> campaignLineItemMap = new map<id, CampaignLineItem__c>();
  private static list<DiscountMasterTable_RSA__c> discountsList = null;
  public static boolean cacheCampaignLineItems = false;
  public static boolean isOffline=false;
  
  public static void setNewCampaignLineItems(list<CampaignLineItem__c> newElements) {
    campaignLineItemMap.putAll(newElements);
  }
  
  public static list<CampaignLineItem__c> getCliByFinalOrder(list<Id> finalOrdersIds) {
    list<CampaignLineItem__c> result = new list<CampaignLineItem__c>();
    
    list<Id> finalFilter = new list<Id>();
    for (Id element :finalOrdersIds) {
      boolean found = false;
      for (CampaignLineItem__c mapItem: campaignLineItemMap.values()) {
        if (mapItem.FinalOrderRef_RSA__c != null && !string.valueof(mapItem.FinalOrderRef_RSA__c).equals('') && mapItem.FinalOrderRef_RSA__c == element) {
          found = true;
          result.add(mapItem);
        }
      }
      if (!found) {
        finalFilter.add(element);
      }
    }
    if (finalFilter.size() > 0) {
      list<CampaignLineItem__c> newElements = new list<CampaignLineItem__c>(
        [SELECT POG__c, Price_copy__c, Ultrashort_Irrigation_RSA__c, PlantingDensity__c, finalOrderRef_RSA__c
               FROM CampaignLineItem__c 
               WHERE finalOrderRef_RSA__c in :finalFilter]);
      result.addAll(newElements);
      campaignLineItemMap.putAll(newElements);
    }
    return result;
  }
  
  public static list<DiscountMasterTable_RSA__c> getDiscounts() {
    
    //provisional fix to year issue
    discountsList = new list<DiscountMasterTable_RSA__c>();
    /*if (discountsList == null) {
      discountsList = new list<DiscountMasterTable_RSA__c>(
        [select AdditionalDiscount_RSA__c, Name
         from DiscountMasterTable_RSA__c
         where Type_RSA__c ='Volume' and Name like '%USDC%' and Year_RSA__c = :UtilREST.currentYearRSA]);
    }*/
    return discountsList;
  }
  
    public void handle()
    {
        String type;

        Set<Id> orderIDs = Trigger.newMap.keyset();

        List<AggregateResult> sumTable = [
            SELECT sum (TotalPrice_RSA__c) , sum(POG__c), sum (POG_60kke__c), finalOrderRef_RSA__c, sum(Price_copy__c)
            FROM CampaignLineItem__c 
            WHERE 
                finalOrderRef_RSA__c in: orderIDs
                group by finalOrderRef_RSA__c];
        
    List<CampaignLineItem__c> prices = new List<CampaignLineItem__c>();
    if (!cacheCampaignLineItems) {
          prices = [SELECT POG__c, Price_copy__c, Ultrashort_Irrigation_RSA__c, PlantingDensity__c, finalOrderRef_RSA__c
              FROM CampaignLineItem__c 
              WHERE finalOrderRef_RSA__c in: orderIDs];
    }
    else {
      prices = getCliByFinalOrder(new list<Id>(orderIDs));
    }
    
        set <ID> ordersUSDC = new set <ID>();

        for (CampaignLineItem__c cli : prices){
            if( cli.get('Ultrashort_Irrigation_RSA__c') == true &&  Integer.valueOf(((String)cli.get('PlantingDensity__c')).trim()) >= 70000){
                ordersUSDC.add(cli.finalOrderRef_RSA__c);
            }
        }

        Map<ID,Map<String,Double>>dataQuery = new Map<ID,Map<String,Double>>(); // Map<finalOrderID,Map<SUMTYPE,VALUE>>
        Double totalPrice;
        for(AggregateResult agre : sumTable){
            totalPrice = agre.get('expr0') == null?0.00:Double.valueOf(agre.get('expr0'));
            dataQuery.put((ID)agre.get('finalOrderRef_RSA__c'),new Map<String,Double>());
            
            dataQuery.get((ID)agre.get('finalOrderRef_RSA__c')).put('TOTAL_PRICE',totalPrice);
            dataQuery.get((ID)agre.get('finalOrderRef_RSA__c')).put('BAGS_QUANTITY', Double.valueOf(agre.get('expr1')));
            dataQuery.get((ID)agre.get('finalOrderRef_RSA__c')).put('BAGS_QUANTITY_60kke', Double.valueOf(agre.get('expr2')));
            

            /*  NO LONGER OLD VOLUME DISCOUNTS ARE NEEDED
            
            if (ordersUSDC.contains((ID)agre.get('finalOrderRef_RSA__c'))){
                List<DiscountMasterTable_RSA__c> discounts = getDiscounts();
                for(DiscountMasterTable_RSA__c disc : discounts){
                    Integer low = Integer.valueOf(disc.Name.split(' - ')[0]);
                    Integer high = Integer.valueOf(disc.Name.split(' - ')[1]);
                    System.debug('Check: ' + agre.get('expr1') + ' >= ' + low + ' && ' + agre.get('expr1') + ' <= ' + high);
                    if(Integer.valueOf(agre.get('expr1')) >= low && Integer.valueOf(agre.get('expr1')) <= high){
                        dataQuery.get((ID)agre.get('finalOrderRef_RSA__c')).put('TOTAL_BAGS_DISCOUNT', Double.valueOf(disc.get('AdditionalDiscount_RSA__c')));
                    }
                }
            }
            else{
                List<DiscountMasterTable_RSA__c> discounts = getDiscounts();
                for(DiscountMasterTable_RSA__c disc : discounts){
                  if (disc.Name.split(' - ').size() > 2 && disc.Name.split(' - ')[0].isNumeric() && disc.Name.split(' - ')[1].isNumeric()) {
                      Integer low = Integer.valueOf(disc.Name.split(' - ')[0]);
                      Integer high = Integer.valueOf(disc.Name.split(' - ')[1]);
                      System.debug('Check: ' + agre.get('expr1') + ' >= ' + low + ' && ' + agre.get('expr1') + ' <= ' + high);
                      if(Integer.valueOf(agre.get('expr1')) >= low && Integer.valueOf(agre.get('expr1')) <= high){
                          dataQuery.get((ID)agre.get('finalOrderRef_RSA__c')).put('TOTAL_BAGS_DISCOUNT', Double.valueOf(disc.get('AdditionalDiscount_RSA__c')));
                      }
                  }
                  else {
                    system.debug('[TriggerOrderCalculatePrice]Discount is bad formed: "' + disc.Name + '"');
                  }
                }
            } 
            */
        }
        
        

        for (Order__c o : (List<Order__c>)Trigger.new)
        {
            if(dataQuery.get(o.id) != null){
                o.Price_RSA__c = dataQuery.get(o.id).get('TOTAL_PRICE');
                if(!isOffline)
                {    
                    if(o.New_VolumeDiscount_RSA__c!=null)
                       o.VolumeDiscount_RSA__c=Decimal.valueOf(o.New_VolumeDiscount_RSA__c.substringBefore(' %'));
                }    
                else
                {
                	//to check...
                    if(o.VolumeDiscount_RSA__c!=null)
                    {
                        String VDiscount=String.valueOf(o.VolumeDiscount_RSA__c);
                        String T1=VDiscount.substringBefore('.');
                        String T2=VDiscount.substringAfter('.');
                        if(T2.startsWith('0'))
                              o.New_VolumeDiscount_RSA__c=T1+' %';                
                        else
                        {
                              o.New_VolumeDiscount_RSA__c=VDiscount.removeEndIgnoreCase('0')+' %';                
                        }                
                    }
                }
                o.BagsQuantity_RSA__c = dataQuery.get(o.id).get('BAGS_QUANTITY');
                o.BagsQuantity_RSA_60kke__c = dataQuery.get(o.id).get('BAGS_QUANTITY_60kke');
                if(type == 'USDC'){
                  o.IsUltrashort_RSA__c = true;
                }
                else{
                  o.IsUltrashort_RSA__c = false;
                }
            }
        }
    }
    public static testMethod void testHandle(){
        try{
            new TriggerOrderCalculatePrice().handle();
        }catch(Exception e){}
    }
}