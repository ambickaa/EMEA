public class TriggerVoucherLadderCopy  implements Triggers.Handler{

  Map<Id,String> Discounts = new Map<Id,String>();
  List<Id> DiscountIds = new List<ID>();
  
 public void handle()
 {
    for(Voucher__c d: (List<Voucher__C>)trigger.new)
    {
    	DiscountIds.add(d.VoucherCampaignRef__c);
    }
    
    Integer counter=1;
    String IntervalCopy='';
    
    for(Discount__c d: [ SELECT Id, MaxBags__c, MinBags__c, DiscountinPrice__C, PercentIncreaseinBags__c FROM Discount__c WHERE VoucherCampaignRef__c in: DiscountIds ORDER BY minBags__c ASC])
    {
    	IntervalCopy=IntervalCopy+'I::'+string.valueOf(counter)+' MIN='+string.valueOf(d.MinBags__c) + ' MAX='+string.valueOf(d.MaxBags__c) + ' DP='+string.valueOf(d.DiscountinPrice__C) +' PI='+ string.valueOf(d.PercentIncreaseinBags__c) +'--'; 
    	counter++;
    }
    
    for(Voucher__c d: (List<Voucher__C>)trigger.new)
    {
    	d.IntervalCopy__c=IntervalCopy;  
    }    
    
    
 }
}