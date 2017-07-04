public class TriggerOrderCloneFields implements Triggers.Handler
{
    public static boolean fromREST = false;
    private static Map<ID,DiscountMasterTable_RSA__c>  discountsStaticMap = new Map<ID,DiscountMasterTable_RSA__c> (); 
    private static Map<Id,Account> accountsStaticMap= new Map<Id,Account>();
 
    public static map<ID, DiscountMasterTable_RSA__c> getDiscounts(list<Id> discountsIdRefList) {
        map<ID, DiscountMasterTable_RSA__c> result = new map<ID, DiscountMasterTable_RSA__c>();
        list<Id> finalFilter = new list<Id>();
        for (Id element: discountsIdRefList) {
            if (!discountsStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, discountsStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<DiscountMasterTable_RSA__c> newElements = new list<DiscountMasterTable_RSA__c>([  SELECT
                                                                                                    Name,
                                                                                                    AdditionalDiscount_RSA__c
                                                                                                    FROM 
                                                                                                    DiscountMasterTable_RSA__c
                                                                                                    WHERE
                                                                                                     ID IN :finalFilter]);
            result.putAll(newElements);
            discountsStaticMap.putAll(newElements);
        }
        
        return result;
    }
  
    public static map<ID, Account> getAccounts(list<Id> accountIdRefList) {
        map<ID, Account> result = new map<ID, Account>();
        list<Id> finalFilter = new list<Id>();
        for (Id element: accountIdRefList) {
            if (!accountsStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, accountsStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Account> newElements = new list<Account>([  
                SELECT
                // fields to be copied
                BankAccountHolder_RSA__c,
                GC_Bank_Account_Number__c,
                Bank_Branch_RSA__c,
                GC_Bank_Name__c,
                Buyer_RSA__c,
                Buyer_RSA__r.MobilePhone,
                BuyerMobilePhone_RSA__c,
                Buyer_RSA__r.Name,
                BuyerName_RSA__c,
                Buyer_RSA__r.Officenumber_RSA__c,
                BuyerOfficenumber_RSA__c,
                City__c,
                CoopMember_RSA__c,
                CoopName_RSA__c,
                GC_Email_Address__c,
                Fax,
                IDNumber_RSA__c,
                GC_Latitude__c,
                GC_Longitude__c,
                Name,
                Office_number__c,
                PostalAddress_Region_RSA__c,
                SAP_Number_RSA__c,
                StateProvince__c,
                Trust_CC_Mpy_RSA__c,
                Trust_CC_Mpy_Value_RSA__c,
                GC_VATIN_Number__c,
                ZIPPostalCode__c
            FROM
                Account
            WHERE
                ID in :finalFilter                          
            ]);
            result.putAll(newElements);
            accountsStaticMap.putAll(newElements);
        }
        
        return result;
    }   
    
    public void handle()
    {
        if(fromRest) return;
        if(SystemSettings__c.getValues('RSA_DISABLE_COPY_FIELDS_YES_NO') == null || 'Yes'.equalsIgnoreCase(SystemSettings__c.getValues('RSA_DISABLE_COPY_FIELDS_YES_NO').Value__c)) return;
        // Get Related account and discount IDs
        Set<ID> discountIDs = new Set<ID>();
        Set<ID> accountIDs = new Set<ID>();

        for(Order__c o : (List<Order__c>)trigger.new){
            system.debug('estoy dentro?');
            if(o.EarlyPayment_RSA__c != ((Order__c)trigger.oldMap.get(o.ID)).EarlyPayment_RSA__c){
                discountIDs.add(o.EarlyPayment_RSA__c);
            }
            if(o.EarlyDelivery_RSA__c != ((Order__c)trigger.oldMap.get(o.ID)).EarlyDelivery_RSA__c){
                discountIDs.add(o.EarlyDelivery_RSA__c);
            }
            if(o.shouldCopy_RSA__c && o.Status_RSA__c == 'Draft'){
                accountIDs.add(o.AccountRef_RSA__c);
            }

        }
        
        Map<ID,DiscountMasterTable_RSA__c> discounts = getDiscounts(new List<Id> (discountIDs));
        /*new Map<ID,DiscountMasterTable_RSA__c>([
            SELECT
                Name,
                AdditionalDiscount_RSA__c
            FROM 
                DiscountMasterTable_RSA__c
            WHERE
                ID IN :discountIDs]);*/
                
        for(Order__c o : (List<Order__c>)trigger.new){
            if(o.EarlyPayment_RSA__c != ((Order__c)trigger.oldMap.get(o.ID)).EarlyPayment_RSA__c){
                o.earlyPaymentName_copy_RSA__c = o.EarlyPayment_RSA__c != null?discounts.get(o.EarlyPayment_RSA__c).Name:'';
                o.earlyPaymentDiscount_copy_RSA__c = o.EarlyPayment_RSA__c != null?discounts.get(o.EarlyPayment_RSA__c).AdditionalDiscount_RSA__c:0.00;
            }
            if(o.EarlyDelivery_RSA__c != ((Order__c)trigger.oldMap.get(o.ID)).EarlyDelivery_RSA__c){
                o.earlyDeliveryName_copy_RSA__c = o.EarlyDelivery_RSA__c != null?discounts.get(o.EarlyDelivery_RSA__c).Name:'';
                o.earlyDeliveryDiscount_copy_RSA__c = o.EarlyDelivery_RSA__c != null?discounts.get(o.EarlyDelivery_RSA__c).AdditionalDiscount_RSA__c:0.00;
            }
        }
        

        // Get Related account Information
        if(accountIDs.size() == 0) return;
        Map<ID,Account> accounts = getAccounts(new List<Id>(accountIDs));
        
        /* new Map<ID,Account>([
            SELECT
                // fields to be copied
                GC_Bank_Account_Number__c,
                Bank_Branch_RSA__c,
                GC_Bank_Name__c,
                Buyer_RSA__c,
                Buyer_RSA__r.MobilePhone,
                Buyer_RSA__r.Name,
                Buyer_RSA__r.Officenumber_RSA__c,
                City__c,
                CoopMember_RSA__c,
                CoopName_RSA__c,
                GC_Email_Address__c,
                Fax,
                IDNumber_RSA__c,
                GC_Latitude__c,
                GC_Longitude__c,
                Name,
                Office_number__c,
                PostalAddress_Region_RSA__c,
                SAP_Number_RSA__c,
                StateProvince__c,
                Trust_CC_Mpy_RSA__c,
                Trust_CC_Mpy_Value_RSA__c,
                GC_VATIN_Number__c,
                ZIPPostalCode__c
            FROM
                Account
            WHERE
                ID in :accountIDs]
        );*/

        for(Order__c o : (List<Order__c>)trigger.new){
            if(o.shouldCopy_RSA__c && o.Status_RSA__c == 'Draft'){
                // copy all fields we need
                o.BankAccountHolder_copy_RSA__c=  accounts.get(o.AccountRef_RSA__c).BankAccountHolder_RSA__c;
                o.Bank_Account_Number_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).GC_Bank_Account_Number__c;
                o.Bank_Branch_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).Bank_Branch_RSA__c ;
                o.Bank_Name_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).GC_Bank_Name__c ;
                o.Buyer_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).Buyer_RSA__c    ; 
                if(accounts.get(o.AccountRef_RSA__c).Buyer_RSA__c != null) o.Buyer_MobilePhone_Copy__c = accounts.get(o.AccountRef_RSA__c).BuyerMobilePhone_RSA__c;
                if(accounts.get(o.AccountRef_RSA__c).Buyer_RSA__c != null) o.Buyer_Name_Copy__c = accounts.get(o.AccountRef_RSA__c).BuyerName_RSA__c   ;
                if(accounts.get(o.AccountRef_RSA__c).Buyer_RSA__c != null) o.Buyer_Officenumber_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).BuyerOfficenumber_RSA__c    ;
                o.City_Copy__c = accounts.get(o.AccountRef_RSA__c).City__c ;
                o.CoopMember_RSA_Copy__c = accounts.get(o.AccountRef_RSA__c).CoopMember_RSA__c   ;
                o.CoopName_RSA_Copy__c = accounts.get(o.AccountRef_RSA__c).CoopName_RSA__c ;
                o.Email_Copy__c = accounts.get(o.AccountRef_RSA__c).GC_Email_Address__c;
                o.Fax_Copy__c = accounts.get(o.AccountRef_RSA__c).Fax ;
                o.IDNumber_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).IDNumber_RSA__c ;
                o.Latitude_Copy__c = String.ValueOf(accounts.get(o.AccountRef_RSA__c).GC_Latitude__c);
                o.Longitude_Copy__c = String.ValueOf(accounts.get(o.AccountRef_RSA__c).GC_Longitude__c);
                o.Name_Copy__c = accounts.get(o.AccountRef_RSA__c).Name    ;
                o.Office_number_Copy__c = accounts.get(o.AccountRef_RSA__c).Office_number__c    ;
                o.PostalAddress_Region_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).PostalAddress_Region_RSA__c ;
                o.SAP_Number_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).SAP_Number_RSA__c   ;
                o.StateProvince_Copy__c = accounts.get(o.AccountRef_RSA__c).StateProvince__c    ;
                o.Trust_CC_Mpy_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).Trust_CC_Mpy_RSA__c ;
                o.Trust_CC_Mpy_Value_Copy_RSA__c = accounts.get(o.AccountRef_RSA__c).Trust_CC_Mpy_Value_RSA__c   ;
                o.VAT_Copy__c = accounts.get(o.AccountRef_RSA__c).GC_VATIN_Number__c;
                o.ZIPPostalCode_Copy__c = accounts.get(o.AccountRef_RSA__c).ZIPPostalCode__c    ;
                o.shouldCopy_RSA__c = false;
                
            }
        }
    }
    
     public static testMethod void testHandle(){
        try{
            new TriggerOrderCloneFields().handle();
        }catch(Exception e){}
    }
}