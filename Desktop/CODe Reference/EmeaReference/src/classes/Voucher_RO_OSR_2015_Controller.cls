public with sharing class Voucher_RO_OSR_2015_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}

    public ApexPages.StandardController controller;

    public Integer status{get;set;}
    
    public List<String> HYB_NAME_CLASIC{get;set;}
    public List<Integer> HYB_BAGS_CLASIC{get;set;}
    public Integer HYB_NUM_CLASIC{get;set;}
    
    public List<String> HYB_NAME_CLEARFIELD{get;set;}
    public List<Integer> HYB_BAGS_CLEARFIELD{get;set;}
    public Integer HYB_NUM_CLEARFIELD{get;set;}
    
    public List<String> DISPLAY{get;set;}
    public Integer STYLELINES{get;set;}

    public String Data {get;set;}
    public String Phones {get;set;}
    
    public Boolean Checked {get;set;}

    public Voucher_RO_OSR_2015_Controller(ApexPages.StandardController controller) {
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
                         AccountRef__r.DE_POGCornPY__c, AccountRef__r.CornTotalSalesPY__c,FiscalCodeCopy__c, TotalBags__c, TotalBagsFOC__c, Price_Coupon__c,
                         AccountRef__r.Region_lckp__r.Name, VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name
                         FROM Voucher__c
                         WHERE id=:VoucherID];
                
                if(voucher.AccountRef__c!=null && voucher.LKP_CONTACT__c==null){
                 try{
                     AccContact=[SELECT Id, Name, MobilePhone, Phone, DE_MonsantoID__c, Decision_Maker__c
                     FROM Contact
                     WHERE AccountId=:voucher.AccountRef__c
                     ORDER BY Decision_Maker__c DESC LIMIT 1];
                     } catch( Exception e ) {System.debug(e);}
                }
                if(voucher.LKP_CONTACT__c != null){
                  try{
                     AccContact=[SELECT Id, Name, MobilePhone, Phone
                     FROM Contact
                     WHERE Id=:voucher.LKP_CONTACT__c];
                     } catch( Exception e ) {System.debug(e);}
                }

            Data = voucher.LastModifiedDate.format('dd/MM/yyyy');
            
            if(voucher.LastModifiedDate <= DateTime.newInstanceGMT(2015,8,21,23,59,59)) Checked = true;
            
            HYB_NAME_CLASIC = new List<String>();
            HYB_BAGS_CLASIC = new List<Integer>();
            HYB_NUM_CLASIC = 0;
            
            HYB_NAME_CLEARFIELD = new List<String>();
            HYB_BAGS_CLEARFIELD = new List<Integer>();
            HYB_NUM_CLEARFIELD = 0;
            
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
            
            if(voucher.status__c=='Cancelled')
                status=1;
            else
                status=0;

                DISPLAY = new List<String>{''};
              
                for(VoucherLineItem__c vli : [SELECT Agreed__c,Bags__c,CreatedDate,HybridName__c,HybridGroup__c,Id,LastModifiedDate,Name,OwnerId,ProductName__c,PICK_TYPE__c
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c!='Free of charge'
                                ORDER BY HybridGroup__c DESC]){

                    if(vli.HybridGroup__c.equalsIgnoreCase('CLASIC')) {
                        HYB_NAME_CLASIC.add(vli.HybridName__c);
                        HYB_BAGS_CLASIC.add(vli.Bags__c.intValue());
                        HYB_NUM_CLASIC = HYB_NUM_CLASIC + 1;
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('CLEARFIELD')) {
                        HYB_NAME_CLEARFIELD.add(vli.HybridName__c);
                        HYB_BAGS_CLEARFIELD.add(vli.Bags__c.intValue());
                        HYB_NUM_CLEARFIELD = HYB_NUM_CLEARFIELD + 1;
                    }
                                
                }
                if(HYB_NUM_CLASIC > 0 && HYB_NUM_CLEARFIELD > 0) DISPLAY[0] = 'display:table-cell;';
                STYLELINES = HYB_NUM_CLASIC + HYB_NUM_CLEARFIELD;
        }
    }
}