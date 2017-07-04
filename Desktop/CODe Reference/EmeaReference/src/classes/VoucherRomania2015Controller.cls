public with sharing class VoucherRomania2015Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}

    public ApexPages.StandardController controller;

    public Integer status{get;set;}
    
    public List<String> HYB_NAME_NOU{get;set;}
    public List<Integer> HYB_FAO1_NOU{get;set;}
    public List<Integer> HYB_BAGS_NOU{get;set;}
    public Integer HYB_NUM_NOU{get;set;}
    
    public List<String> HYB_NAME_HD{get;set;}
    public List<Integer> HYB_FAO1_HD{get;set;}
    public List<Integer> HYB_BAGS_HD{get;set;}
    public Integer HYB_NUM_HD{get;set;}
    
    public List<String> HYB_NAME_MAXTECH{get;set;}
    public List<Integer> HYB_FAO1_MAXTECH{get;set;}
    public List<Integer> HYB_BAGS_MAXTECH{get;set;}
    public Integer HYB_NUM_MAXTECH{get;set;}
    
    public List<String> HYB_NAME_CLASIC{get;set;}
    public List<Integer> HYB_FAO1_CLASIC{get;set;}
    public List<Integer> HYB_BAGS_CLASIC{get;set;}
    public Integer HYB_NUM_CLASIC{get;set;}
    
    public List<String> HYB_NAME_YIELDGARD{get;set;}
    public List<Integer> HYB_FAO1_YIELDGARD{get;set;}
    public List<Integer> HYB_BAGS_YIELDGARD{get;set;}
    public Integer HYB_NUM_YIELDGARD{get;set;}
    
    public List<Integer> DISCOUNTS{get;set;}
    public List<String> DISPLAY{get;set;}
    public Integer STYLELINES{get;set;}

    public String FOCHybrid {get;set;}
    public String Data {get;set;}
    public String Phones {get;set;}
    public String cuenta {get;set;}

    public VoucherRomania2015Controller(ApexPages.StandardController controller) {
            this.controller = controller;
            Id VoucherID = controller.getRecord().ID;
            
            voucher = new Voucher__c();
            AccContact = new Contact();
            STYLELINES = 0;
        
            if(VoucherID!=null){  
                voucher=[SELECT AddressCopy__c,DistributorNameCopy__c,EmailCopy__c,PhoneCopy__c,FarmNameCopy__c, AccountRef__r.Province_lckp__r.Name, Name,
                         AccountRef__r.Buyer_RSA__r.Name, AccountRef__r.Buyer_RSA__r.Phone, AccountRef__r.Buyer_RSA__r.Email, AccountRef__r.Client_Code__c,
                         AccountRef__r.TotalAcreagesCY__c, AccountRef__r.City_lckp__r.Name, AccountRef__r.CornTotalAcreagesCY__c,Owner.Name, LastModifiedDate,
                         AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.Street__c, Status__c, LKP_CONTACT__c, LKP_CONTACT__r.Name,
                         AccountRef__r.DE_POGCornPY__c, AccountRef__r.CornTotalSalesPY__c,FiscalCodeCopy__c, TotalBags__c, TotalBagsFOC__c,
                         AccountRef__r.Region_lckp__r.Name, VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name
                         FROM Voucher__c
                         WHERE id=:VoucherID];
                
                DISCOUNTS = new List<Integer>{0,0,0,0};
                
                if(voucher.TotalBags__c >= 25 && voucher.TotalBags__c <= 100)
                    DISCOUNTS[0] = voucher.TotalBagsFOC__c.intValue();
                if(voucher.TotalBags__c >= 101 && voucher.TotalBags__c <= 300)
                    DISCOUNTS[1] = voucher.TotalBagsFOC__c.intValue();
                if(voucher.TotalBags__c >= 301 && voucher.TotalBags__c <= 1000)
                    DISCOUNTS[2] = voucher.TotalBagsFOC__c.intValue();
                if(voucher.TotalBags__c > 1000)
                    DISCOUNTS[3] = voucher.TotalBagsFOC__c.intValue();
                
                if(voucher.AccountRef__c!=null){
                     try{
                         AccContact=[SELECT Id, Name, MobilePhone, Phone, DE_MonsantoID__c, Decision_Maker__c
                         FROM Contact
                         WHERE AccountId=:voucher.AccountRef__c
                         ORDER BY Decision_Maker__c DESC LIMIT 1];} catch( Exception e ) {System.debug(e);}
                }

            Data = voucher.LastModifiedDate.format('dd/MM/yyyy');
            
            HYB_NAME_NOU = new List<String>();
            HYB_FAO1_NOU = new List<Integer>();
            HYB_BAGS_NOU = new List<Integer>();
            HYB_NUM_NOU = 0;
            
            HYB_NAME_HD = new List<String>();
            HYB_FAO1_HD = new List<Integer>();
            HYB_BAGS_HD = new List<Integer>();
            HYB_NUM_HD = 0;
            
            HYB_NAME_MAXTECH = new List<String>();
            HYB_FAO1_MAXTECH = new List<Integer>();
            HYB_BAGS_MAXTECH = new List<Integer>();
            HYB_NUM_MAXTECH = 0;
            
            HYB_NAME_CLASIC = new List<String>();
            HYB_FAO1_CLASIC = new List<Integer>();
            HYB_BAGS_CLASIC = new List<Integer>();
            HYB_NUM_CLASIC = 0;
            
            HYB_NAME_YIELDGARD = new List<String>();
            HYB_FAO1_YIELDGARD = new List<Integer>();
            HYB_BAGS_YIELDGARD = new List<Integer>();
            HYB_NUM_YIELDGARD = 0;
            
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
            
            FOCHybrid = '';
            if(voucher.status__c=='Cancelled'){
                status=1;
            } else {
                status=0;
                List<VoucherLineItem__c> FOCvli = [SELECT Agreed__c,Bags__c,HybridName__c,Id,LastModifiedDate,Name,ProductName__c,PICK_TYPE__c
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c='Free of charge'
                                LIMIT 1];
                                
                if(FOCvli.size() > 0)
                    FOCHybrid = FOCvli[0].HybridName__c;
            }
                DISPLAY = new List<String>{'','','',''};
              
                for(VoucherLineItem__c vli : [SELECT Agreed__c,Bags__c,CreatedDate,HybridName__c,HybridGroup__c,Id,LastModifiedDate,Name,OwnerId,ProductName__c,FAO__c,PICK_TYPE__c
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c!='Free of charge'
                                ORDER BY HybridGroup__c DESC]){

                    if(vli.HybridGroup__c.equalsIgnoreCase('NOU')) {
                        DISPLAY[0] = 'display:table-cell;';
                        HYB_NAME_NOU.add(vli.HybridName__c);
                        HYB_FAO1_NOU.add(vli.FAO__c.intValue());
                        HYB_BAGS_NOU.add(vli.Bags__c.intValue());
                        HYB_NUM_NOU = HYB_NUM_NOU + 1;
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('HD')) {
                        DISPLAY[1] = 'display:table-cell;';
                        HYB_NAME_HD.add(vli.HybridName__c);
                        HYB_FAO1_HD.add(vli.FAO__c.intValue());
                        HYB_BAGS_HD.add(vli.Bags__c.intValue());
                        HYB_NUM_HD = HYB_NUM_HD + 1;
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('MAXTECH')) {
                        DISPLAY[2] = 'display:table-cell;';
                        HYB_NAME_MAXTECH.add(vli.HybridName__c);
                        HYB_FAO1_MAXTECH.add(vli.FAO__c.intValue());
                        HYB_BAGS_MAXTECH.add(vli.Bags__c.intValue());
                        HYB_NUM_MAXTECH = HYB_NUM_MAXTECH + 1;
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('CLASIC')) {
                        DISPLAY[3] = 'display:table-cell;';
                        HYB_NAME_CLASIC.add(vli.HybridName__c);
                        HYB_FAO1_CLASIC.add(vli.FAO__c.intValue());
                        HYB_BAGS_CLASIC.add(vli.Bags__c.intValue());
                        HYB_NUM_CLASIC = HYB_NUM_CLASIC + 1;
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('YIELDGARD')) {
                        HYB_NAME_YIELDGARD.add(vli.HybridName__c);
                        HYB_FAO1_YIELDGARD.add(vli.FAO__c.intValue());
                        HYB_BAGS_YIELDGARD.add(vli.Bags__c.intValue());
                        HYB_NUM_YIELDGARD = HYB_NUM_YIELDGARD + 1;
                    }
                                
                }
                STYLELINES = HYB_NUM_NOU + HYB_NUM_HD + HYB_NUM_MAXTECH + HYB_NUM_CLASIC + HYB_NUM_YIELDGARD;
        }
    }
}