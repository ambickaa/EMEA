public with sharing class VoucherUkraine2015Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}

    public String CC0 {get;set;}
    public String CC1 {get;set;}
    public String CC2 {get;set;}
    public String CC3 {get;set;}
    public String CC4 {get;set;}
    public String CC5 {get;set;}
    
    public String HYB_DISPLAY {get;set;}
    public String FOC_DISPLAY {get;set;}

    public Integer status{get;set;}

    public Integer HYB_NUM_BAGS{get;set;}
    public Integer FOC_NUM_BAGS{get;set;}
    
    public List<String> HYB_NAME{get;set;}
    public List<Integer> HYB_BAGS{get;set;}
    public List<String> FOC_NAME{get;set;}
    public List<Integer> FOC_BAGS{get;set;}

    public String Data {get;set;}
    public String Phones {get;set;}
    public String cuenta {get;set;}

	public ApexPages.StandardController controller;

    public VoucherUkraine2015Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        
        voucher = new Voucher__c();
        AccContact = new Contact();
    
        if(VoucherID!=null){
            voucher=[SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,Status__c,Owner.Name,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name
                     FROM Voucher__c
                     WHERE Id=:VoucherID];
             
            if(voucher.AccountRef__c!=null){
                 try{
                     AccContact=[SELECT Id,Name,MobilePhone,Phone,Decision_Maker__c,AccountId
                     FROM Contact
                     WHERE AccountId=:voucher.AccountRef__c
                     ORDER BY Decision_Maker__c DESC LIMIT 1];} catch( Exception e ) {System.debug(e);}
            }
             
            CC0 = '';
            CC1 = '';
            CC2 = '';
            CC3 = '';
            CC4 = '';
            CC5 = ''; 
            
            List<String> clientCode = new List<String>();
            if(voucher.AccountRef__r.Client_Code__c !=null){          
                clientCode = String.valueof(voucher.AccountRef__r.Client_Code__c).split('');
                                 
		        try { CC0 = clientCode.get(4); }catch( Exception e ){}
		        try { CC1 = clientCode.get(5); }catch( Exception e ){}
		        try { CC2 = clientCode.get(6); }catch( Exception e ){}
		        try { CC3 = clientCode.get(7); }catch( Exception e ){}
		        try { CC4 = clientCode.get(8); }catch( Exception e ){}
		        try { CC5 = clientCode.get(9); }catch( Exception e ){}
            }
	        Data = voucher.LastModifiedDate.format('dd/MM/yyyy');
	        
	        HYB_NAME = new List<String>();
	        HYB_BAGS = new List<Integer>();
	        FOC_NAME = new List<String>();
	        FOC_BAGS = new List<Integer>();
	        Integer i = 0;
	        Integer j = 0;
	        HYB_NUM_BAGS = 0;
	        FOC_NUM_BAGS = 0;
	        
	        if(AccContact.MobilePhone!=null && voucher.PhoneCopy__c!=null){
	            Phones = AccContact.MobilePhone + ' / ' + voucher.PhoneCopy__c;
	        }
	        if(AccContact.MobilePhone!=null && voucher.PhoneCopy__c==null){
	            Phones = AccContact.MobilePhone;
	        }
	        if(AccContact.MobilePhone==null && voucher.PhoneCopy__c!=null){
	            Phones = voucher.PhoneCopy__c;
	        }
	        if(AccContact.MobilePhone==null && voucher.PhoneCopy__c==null){
	            Phones = '';
	        }
	        
	        if(voucher.Status__c=='Cancelled'){
	            status=1;
	        } else {
	            status=0;
	        }
            for(VoucherLineItem__c vli : [SELECT Agreed__c,Bags__c,CreatedDate,HybridName__c,Id,LastModifiedDate,Name,OwnerId,ProductName__c,PICK_TYPE__c
                            FROM VoucherLineItem__c
                            WHERE VoucherRef__c=:VoucherID
                            ORDER BY Bags__c DESC]){
                            
                if(vli.PICK_TYPE__c == 'Free of charge'){
                    FOC_NAME.add(vli.HybridName__c);
                    FOC_BAGS.add(vli.Bags__c.intValue());
                    FOC_NUM_BAGS = FOC_NUM_BAGS + vli.Bags__c.intValue();
                    j++;
                } else {
                    HYB_NAME.add(vli.HybridName__c);
                    HYB_BAGS.add(vli.Bags__c.intValue());
                    HYB_NUM_BAGS = HYB_NUM_BAGS + vli.Bags__c.intValue();
                    i++;
                }
            }
        if(i==0){HYB_DISPLAY = 'display:none;';} else {HYB_DISPLAY = '';}
        if(j==0){FOC_DISPLAY = 'display:none;';} else {FOC_DISPLAY = '';}
    	}
    }
}