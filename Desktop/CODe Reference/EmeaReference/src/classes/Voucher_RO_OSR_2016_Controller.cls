public with sharing class Voucher_RO_OSR_2016_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}

    public ApexPages.StandardController controller;

    public Integer status{get;set;}
    
    public List<String> HYB_NAME_CLASIC{get;set;}
    public List<Integer> HYB_BAGS_CLASIC{get;set;}
    public List<Integer> HYB_PRICE_CLASIC{get;set;}
    public List<Integer> HYB_DISCOUNT_CLASIC{get;set;}
    public List<Boolean> HYB_NEW_CLASIC{get;set;}
    public Integer HYB_NUM_CLASIC{get;set;}
    
    public List<String> HYB_NAME_CLEARFIELD{get;set;}
    public List<Integer> HYB_BAGS_CLEARFIELD{get;set;}
    public List<Integer> HYB_PRICE_CLEARFIELD{get;set;}
    public List<Boolean> HYB_NEW_CLEARFIELD{get;set;}
    public Integer HYB_NUM_CLEARFIELD{get;set;}
    
    public Integer TOTAL_ROUNDUP_CANS{get;set;}
    public Integer TOTAL_CLEARFIELD_BAGS{get;set;}
    
    public Map<String,Integer> MAP_FOC{get;set;}
    public String truncatedNote{get;set;}

    public String Data {get;set;}
    public String Phones {get;set;}
    
    public Boolean CHK_PROTECTION_PROGRAM {get;set;}

    public Voucher_RO_OSR_2016_Controller(ApexPages.StandardController controller) {
            this.controller = controller;
            Id VoucherID = controller.getRecord().ID;
            
            voucher = new Voucher__c();
            AccContact = new Contact();
            
            HYB_NAME_CLASIC = new List<String>();
            HYB_BAGS_CLASIC = new List<Integer>();
            HYB_PRICE_CLASIC = new List<Integer>();
            HYB_DISCOUNT_CLASIC = new List<Integer>();
            HYB_NEW_CLASIC = new List<Boolean>();
            HYB_NUM_CLASIC = 0;

            HYB_NAME_CLEARFIELD = new List<String>();
            HYB_BAGS_CLEARFIELD = new List<Integer>();
            HYB_PRICE_CLEARFIELD = new List<Integer>();
            HYB_NEW_CLEARFIELD = new List<Boolean>();
            HYB_NUM_CLEARFIELD = 0;
            
            TOTAL_ROUNDUP_CANS = 0;
            TOTAL_CLEARFIELD_BAGS = 0;
            
            CHK_PROTECTION_PROGRAM = false;
            
            MAP_FOC = new Map<String,Integer>();
        
            if(VoucherID!=null){  
                voucher=[SELECT AddressCopy__c,DistributorNameCopy__c,EmailCopy__c,PhoneCopy__c,FarmNameCopy__c, AccountRef__r.Province_lckp__r.Name, Name,
                         AccountRef__r.Buyer_RSA__r.Name, AccountRef__r.Buyer_RSA__r.Phone, AccountRef__r.Buyer_RSA__r.Email, AccountRef__r.Client_Code__c,
                         AccountRef__r.TotalAcreagesCY__c, AccountRef__r.City_lckp__r.Name, AccountRef__r.CornTotalAcreagesCY__c,Owner.Name, LastModifiedDate,
                         AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.Street__c, Status__c, LKP_CONTACT__c, LKP_CONTACT__r.Name,
                         AccountRef__r.DE_POGCornPY__c, AccountRef__r.CornTotalSalesPY__c,FiscalCodeCopy__c, TotalBags__c, TotalBagsFOC__c, Price_Coupon__c,
                         AccountRef__r.Region_lckp__r.Name, VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name, AccountRef__r.County__c, TXT_NOTES__c, CreatedDate
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
              
                for(VoucherLineItem__c vli : [SELECT Agreed__c,Bags__c,CreatedDate,HybridName__c,HybridGroup__c,Id,LastModifiedDate,Name,OwnerId,ProductName__c,PICK_TYPE__c, price__c,     LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.DE_isPremium__c, NUM_Price_Discount__c 
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c!='Free of charge'
                                ORDER BY HybridGroup__c DESC]){

                    if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c==true) {
                        HYB_NAME_CLASIC.add(vli.HybridName__c);
                        HYB_BAGS_CLASIC.add(vli.Bags__c.intValue());
                        HYB_PRICE_CLASIC.add(integer.valueof(vli.price__c));
                        HYB_NUM_CLASIC = HYB_NUM_CLASIC + 1;
                        HYB_NEW_CLASIC.add(vli.LKP_ProductCatalogEntry__r.NewProduct__c);
                        if (vli.NUM_Price_Discount__c == null)
                            HYB_DISCOUNT_CLASIC.add(0);
                        else
                        HYB_DISCOUNT_CLASIC.add(integer.valueof(vli.NUM_Price_Discount__c));
                        MAP_FOC.put(vli.HybridName__c,0);
                    }
                    if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c == false) {
                        HYB_NAME_CLEARFIELD.add(vli.HybridName__c);
                        HYB_BAGS_CLEARFIELD.add(vli.Bags__c.intValue());
                        HYB_PRICE_CLEARFIELD.add(integer.valueof(vli.price__c));
                        HYB_NUM_CLEARFIELD = HYB_NUM_CLEARFIELD + 1;
                        HYB_NEW_CLEARFIELD.add(vli.LKP_ProductCatalogEntry__r.NewProduct__c);
                        MAP_FOC.put(vli.HybridName__c,0);
                        TOTAL_CLEARFIELD_BAGS += vli.Bags__c.intValue();
                    }
                }
                
                String[] str = label.RO_OSR_2016_Protection_Program_Date.split('/');
                Date PP_Deadline = date.newinstance(Integer.valueof(str[0]), Integer.valueof(str[1]), Integer.valueof(str[2]));
                system.debug('*** Protection Program Deadlinedate: ' + PP_Deadline);
                
                If(Voucher.CreatedDate <= PP_Deadline && Voucher.TotalBags__c>=3 && (HYB_NUM_CLASIC + HYB_NUM_CLEARFIELD)>=2) CHK_PROTECTION_PROGRAM=true;
                
                String[] str1 = label.RO_OSR_2016_Clearfield_Program_Date.split('/');
                Date CF_Deadline = date.newinstance(Integer.valueof(str1[0]), Integer.valueof(str1[1]), Integer.valueof(str1[2]));
                system.debug('*** Clearfield Deadlinedate: ' + CF_Deadline);
                
                if (Voucher.CreatedDate <= CF_Deadline){
                TOTAL_ROUNDUP_CANS = TOTAL_CLEARFIELD_BAGS/3;
                }
                
                for(VoucherLineItem__c vli_foc : [SELECT Agreed__c,Bags__c,CreatedDate,HybridName__c,HybridGroup__c,Id,LastModifiedDate,Name,OwnerId,ProductName__c,PICK_TYPE__c, price__c,     LKP_ProductCatalogEntry__r.NewProduct__c, NUM_Price_Discount__c 
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c='Free of charge' AND (HybridName__c IN: HYB_NAME_CLASIC OR HybridName__c IN: HYB_NAME_CLEARFIELD)
                                ORDER BY HybridGroup__c DESC]){

                            MAP_FOC.put(vli_foc.HybridName__c,vli_foc.Bags__c.intValue());
                }
                
                String myNote = Voucher.TXT_NOTES__c;
                if(myNote != null){
                    truncatedNote = this.truncateNotes(myNote, 650);
                }
                system.debug(truncatedNote); // This is the truncated note
                
        }
    }
    
                    // Method which truncates notes             
    private String truncateNotes(String note, Integer numChars)
    {
        // Temporary variable to store the new note (word by word)
        String tempNote = '';
    
        // For each of the words in the original note (split by whitespace)
        for (String word : note.split(' '))
        {
            // Check whether our temporary note + the new word exceeds the limit of chars
            if (tempNote.length() + word.length() > numChars)
            {
                // We've reached the max, don't include the next word and return the new note
                tempNote += '(...)';
                break;
            }
    
            // We still haven't reached the max, append the word and keep going
            tempNote += word + ' ';
        }
    
        // Return the truncated note
        return tempNote;
    }
}