/*
 * Class which avoids duplicate PK
 *
 */
public class TriggerVoucherCampaignPK implements Triggers.Handler
{
    SET <String> VoucherCampaignPK; 
    
    public TriggerVoucherCampaignPK()
    {
    	VoucherCampaignPK = new SET<String>();
    	List<ID> vcToAvoid = new List<ID>();
    	
    	for(VoucherCampaign__c vc: (List<VoucherCampaign__C>)trigger.new)
    	{
    		vcToAvoid.add(vc.id);
    	}
    	for(VoucherCampaign__c vc: [SELECT CountryRef__c, DivisionRef__c, YearRef__c FROM VoucherCampaign__c WHERE id not in: vcToAvoid])
    	{
    		VoucherCampaignPK.add(vc.CountryRef__c+'-'+vc.DivisionRef__c+'-'+vc.YearRef__c);
    	} 	
    }
 
    public void handle()
    {
    	String PK='';
    	for(VoucherCampaign__c vc: (List<VoucherCampaign__C>)trigger.new)
    	{
    		PK=vc.CountryRef__c+'-'+vc.DivisionRef__c+'-'+vc.YearRef__c;
    		if(VoucherCampaignPK.contains(PK))
    			vc.Name.addError(System.label.VoucherCampaignPK);
    	}   	
    }    	
}