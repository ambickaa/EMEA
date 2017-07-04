public with sharing class TriggerVoucherDiscounts implements Triggers.Handler {
    
    //------------------------------
    // TriggerVoucherDiscounts:
    // - Triggered after inserting VoucherLineItems.
    // - It applies smart discounts for Vouchers and calculates the logics.
    // eCIP Support Team -> 19.11.2015 -> LastModifiedDate 12.12.2016
    //------------------------------
    public Map<VoucherLineItem__c, Id> Map_VLI_VoucherId = new Map<VoucherLineItem__c, Id>();
    public Map<Id, List<Discount__c>> Map_Campaign_List_Discount = new Map<Id, List<Discount__c>>();
    public Map<Id, List<VoucherLineItem__c>> Map_VoucherId_List_VLI = new Map<Id, List<VoucherLineItem__c>>();
    
    public Map<Id, Id> Map_VoucherId_Farm = new Map<Id, Id>();
    public Map<Id, Id> Map_VoucherId_Campaign = new Map<Id, Id>();
    public List<Voucher__c> List_Voucher = new List<Voucher__c>();
    
    public Map<Id, List<CampaignLineItem__c>> Map_FarmId_FOCCLIs = new Map<Id, List<CampaignLineItem__c>>();
    public Map<Id, List<CampaignLineItem__c>> Map_VoucId_FOCCLIs = new Map<Id, List<CampaignLineItem__c>>();
    
    public Set<String> Set_Discount_Type = new Set<String>();
    public Set<String> Set_Discount_Fields = new Set<String>();
    public Map<Id, Integer> Map_VoucherId_Bags = new Map<Id, Integer>();
    public Map<Id, VoucherLineItem__c> Map_VLI_Complete = new Map<Id, VoucherLineItem__c>();
    public Map<String, Map<String, Decimal>> Map_Discounts = new Map<String, Map<String, Decimal>>();
    
    public List<Voucher__c> vToUpdate = new List<Voucher__c>();
    public List<VoucherLineItem__c> vliToUpdate = new List<VoucherLineItem__c>();
    public List<VoucherLineItem__c> vliToInsert = new List<VoucherLineItem__c>();
    
    private Set<Id> Set_FarmId = new Set<Id>();
    
    //------------------------------
    // Needed for "Czech Republic - Corn - 2016"
    //------------------------------
    private Decimal TotalBags_Silage = 0;
    private Decimal TotalBags_Grain = 0;
    
    //------------------------------
    // Needed for "Hungary - Corn - 2016"
    //------------------------------
    private Map<Id, Map<String, Decimal>> Map_FarmId_EarlyOrder = new Map<Id, Map<String, Decimal>>();

    //------------------------------
    // Needed for "Romania - Corn - 2017"
    //------------------------------
    private Map<Id, Boolean> Map_FarmId_OldDiscounts = new Map<Id, Boolean>();

    //------------------------------
    // Needed for "Romania - OSR - 2016"
    //------------------------------
    private Integer j = 0;
    
    //------------------------------
    // START METHOD: handle()
    //------------------------------
    public void handle() {
        
        Map<Id, VoucherLineItem__c> Map_VLI = new Map<Id, VoucherLineItem__c>();
        //------------------------------
        // Loop for all VoucherLineItems inserted, coming from the trigger.
        // Different maps will be built to help on calculations.
        //------------------------------
        for(VoucherLineItem__c vli : (List<VoucherLineItem__c>)Trigger.new) {
            //------------------------------
            // Proccessing only those with type "Charged", coming directly from the Voucher.
            // The ones with type "Free of charge" have been created by this class and should not be processed again.
            //------------------------------
            if(vli.PICK_TYPE__c != 'Free of charge') {

                Map_VLI_VoucherId.put(vli, vli.VoucherRef__c);
                
                List<VoucherLineItem__c> List_VLI = Map_VoucherId_List_VLI.get(vli.VoucherRef__c);
                //------------------------------
                // It populates lists and maps with VoucherId and corresponding VoucherLineItems.
                //------------------------------
                if(List_VLI == null)
                    List_VLI = new List<VoucherLineItem__c>();

                List_VLI.add(vli);
                Map_VoucherId_List_VLI.put(vli.VoucherRef__c, List_VLI);
            }
            //------------------------------
            // It populates map with VoucherLineItems.
            //------------------------------
            Map_VLI.put(vli.Id, vli);
        }
        
        //------------------------------
        // - It retrieves all helpful information of the VoucherLineItems.
        // - It retrieves all discounts related to the VoucherCampaigns.
        //------------------------------
        if(Map_VLI_VoucherId.size() != 0 && Map_VLI_VoucherId.size() != null) {
          
            for(VoucherLineItem__c vli : [SELECT Id, Name,
                                                VoucherRef__c,
                                                VoucherRef__r.AccountRef__c,
                                                VoucherRef__r.VoucherCampaignRef__c,
                                                VoucherRef__r.VoucherCampaignRef__r.YearRef__r.Name,
                                                VoucherRef__r.VoucherCampaignRef__r.DivisionRef__r.Name,
                                                CampaignLineItemRef__c,
                                                CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                                LKP_ProductCatalogEntry__c
                                                FROM VoucherLineItem__c
                                                WHERE Id IN : Map_VLI.keyset()
                                                AND VoucherRef__r.VoucherCampaignRef__c != null
                                                AND VoucherRef__r.VoucherCampaignRef__r.YearRef__c != null
                                                AND VoucherRef__r.VoucherCampaignRef__r.DivisionRef__c != null]) {
                
                vli.LKP_ProductCatalogEntry__c = vli.CampaignLineItemRef__r.ProductCatalogEntryRef__c;              
                vliToUpdate.add(vli);
                
                Map_VoucherId_Campaign.put(vli.VoucherRef__c, vli.VoucherRef__r.VoucherCampaignRef__c);
                Map_VoucherId_Farm.put(vli.VoucherRef__c, vli.VoucherRef__r.AccountRef__c);
                
                Set_FarmId.add(vli.VoucherRef__r.AccountRef__c);
            }
            if(vliToUpdate.size() > 0)
                update vliToUpdate;
            
            //------------------------------
            // VoucherLineItems with the field LKP_ProductCatalogEntry__c updated.
            //------------------------------
            for(VoucherLineItem__c vli : [SELECT Id, Name,
                                                VoucherRef__c,
                                                CampaignLineItemRef__c,
                                                NUM_Price_Discount__c,
                                                VoucherRef__r.AccountRef__c,
                                                VoucherRef__r.DistributorRef__c,
                                                VoucherRef__r.VoucherCampaignRef__c,
                                                CampaignLineItemRef__r.ProductRef__c,
                                                CampaignLineItemRef__r.PlantingDensity__c,
                                                CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                                CampaignLineItemRef__r.CampaignRef__c,
                                                LKP_ProductCatalogEntry__c,
                                                LKP_ProductCatalogEntry__r.Name,
                                                LKP_ProductCatalogEntry__r.TXT_FAO__c,
                                                LKP_ProductCatalogEntry__r.NewProduct__c,
                                                LKP_ProductCatalogEntry__r.DE_isPremium__c,
                                                LKP_ProductCatalogEntry__r.ProductRef__r.ProductSAPCode__c,
                                                LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c,
                                                LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c,
                                                LKP_ProductCatalogEntry__r.ProductRef__r.ProductHybridGroup__c
                                                FROM VoucherLineItem__c
                                                WHERE Id IN : vliToUpdate]) {
                
                Map_VLI_Complete.put(vli.Id, vli);
                system.debug('***' + vli.Name + ' with LKP ' + vli.LKP_ProductCatalogEntry__r.Name + ' is (Premium, New) = (' + vli.LKP_ProductCatalogEntry__r.DE_isPremium__c + ', ' + vli.LKP_ProductCatalogEntry__r.NewProduct__c + ')');
            }
            system.debug('***Map of VLI completed: ' + Map_VLI_Complete);
            
            //------------------------------
            // START: Only for "Hungary - Corn - 2016":
            // - It retrieves all DiscretionaryDiscount amounts for Cancelled or Rejected vouchers with Early Order
            // - If Vouchers are not in Early Order phase, but previous Vouchers did, the Early Order is summed up
            //------------------------------
            for(Voucher__c v : [SELECT Id, AccountRef__c, EarlyOrderDiscount__c, TotalBags__c
                    FROM Voucher__c
                    WHERE AccountRef__c IN : Set_FarmId
                    AND Status__c != 'Closed' AND EarlyOrderDiscount__c > 0
                    AND VoucherCampaignRef__r.Name = 'Hungary - Corn - 2016'
                    ORDER BY CreatedDate ASC])
                Map_FarmId_EarlyOrder.put(v.AccountRef__c, new Map<String, Decimal>{'EarlyOrder'=>v.EarlyOrderDiscount__c,'TotalBags'=>v.TotalBags__c});
            //------------------------------
            // END: Only for "Hungary - Corn - 2016":
            //------------------------------
            
            //------------------------------
            // START: Only for "Romania - Corn - 2017":
            // - It retrieves all DiscretionaryDiscount amounts for Cancelled or Rejected vouchers with Early Order
            // - If Vouchers are not in Early Order phase, but previous Vouchers did, the Early Order is summed up
            //------------------------------
            for(Voucher__c v : [SELECT Id, AccountRef__c, CreatedDate
                    FROM Voucher__c
                    WHERE AccountRef__c IN : Set_FarmId
                    AND Status__c = 'Cancelled'
                    AND VoucherCampaignRef__r.Name = 'Romania - Corn - 2017'
                    ORDER BY CreatedDate ASC])
            {
                if(Map_FarmId_OldDiscounts.containsKey(v.AccountRef__c))
                {
                    if(Map_FarmId_OldDiscounts.get(v.AccountRef__c))
                    {
                        if(v.CreatedDate >= date.newInstance(2017, 1, 1))
                        {
                            Map_FarmId_OldDiscounts.remove(v.AccountRef__c);
                            Map_FarmId_OldDiscounts.put(v.AccountRef__c, false);
                        }
                    }
                        
                } else {
                    if(v.CreatedDate >= date.newInstance(2017, 1, 1))
                        Map_FarmId_OldDiscounts.put(v.AccountRef__c, false);
                    else
                        Map_FarmId_OldDiscounts.put(v.AccountRef__c, true);
                }               
            }
            system.debug('***Map old discounts: ' + Map_FarmId_OldDiscounts);
            //------------------------------
            // END: Only for "Romania - Corn - 2017":
            //------------------------------
            
            for(Discount__c d : [SELECT Id, Name, MinBags__c, MaxBags__c,
                                    VoucherCampaignRef__c,
                                    FRML_Enabled__c,
                                    NUM_DiscountperBag__c,
                                    PICK_Applies_to__c,
                                    DiscountInPrice__c,
                                    PercentIncreaseInPrice__c,
                                    PercentIncreaseInBags__c,
                                    NUM_Max_First_Ladder__c,
                                    TXT_Max_First_Ladder_Field__c,
                                    NUM_Min_First_Ladder__c,
                                    TXT_Min_First_Ladder_Field__c
                                    FROM Discount__c
                                    WHERE VoucherCampaignRef__c IN : Map_VoucherId_Campaign.values()
                                    AND RecordTypeId = : Util.recordType.get('Discount__c:Smart_discount')]) {
                
                List<Discount__c> List_Discount = Map_Campaign_List_Discount.get(d.VoucherCampaignRef__c);
                if(List_Discount == null)
                    List_Discount = new List<Discount__c>();
                    
                List_Discount.add(d);
                
                if(d.TXT_Max_First_Ladder_Field__c != null)
                    Set_Discount_Fields.add(d.TXT_Max_First_Ladder_Field__c);
                if(d.TXT_Min_First_Ladder_Field__c != null)
                    Set_Discount_Fields.add(d.TXT_Min_First_Ladder_Field__c);
                Map_Campaign_List_Discount.put(d.VoucherCampaignRef__c, List_Discount);
            }
            system.debug('***Smart discounts needed fields from all VoucherCampaigns: ' + Set_Discount_Fields);
        
            //------------------------------
            // It retrieves all helpful information of the Vouchers related to
            // the VoucherLineItems that reach the class.
            //------------------------------
            String List_Voucher_query = '';
            List_Voucher_query += 'SELECT Id, Name, Status__c, AccountRef__c, AccountRef__r.CHK_VAT_Payer__c, AccountRef__r.CHK_Protection_Program__c, CampaignRef__c, TotalBags__c, TotalBagsFOC__c, DistributorRef__c,';
            List_Voucher_query += ' CampaignRef__r.ParentId, CampaignRef__r.SalesPCMRef__c, CampaignRef__r.CountryRef__r.Name, VoucherCampaignRef__c, VoucherCampaignRef__r.Name,';
            List_Voucher_query += ' VoucherCampaignRef__r.BagSize__c, VoucherCampaignRef__r.Discount_Type__c, VoucherCampaignRef__r.CHCK_FOCBags_AP__c, VoucherCampaignRef__r.CHK_Ignore_bag_ladder__c, Price__c,';
            List_Voucher_query += ' VoucherCampaignRef__r.YearRef__r.Name, VoucherCampaignRef__r.DivisionRef__r.Name, Price_Coupon__c, DiscretionaryDiscount__c, EarlyOrderDiscount__c';
            
            if(Set_Discount_Fields.size() > 0) {
                for(String s : Set_Discount_Fields) {
                    if(s != 'TotalBags__c' && s != 'TotalBagsFOC__c')
                        List_Voucher_query += ', ' + s;
                }
            }
    
            List_Voucher_query += ' FROM Voucher__c WHERE Id IN (\'\'';
    
            for(Id s : Map_VLI_VoucherId.values())
                List_Voucher_query += ', \'' + s + '\'';
    
            List_Voucher_query += ') AND Status__c = \'Closed\'';
            //system.debug('***Query for Vouchers: ' + List_Voucher_query);
            
            List_Voucher = (List<Voucher__c>)Database.query(List_Voucher_query);        
        }
        
        vliToUpdate.clear();

        //------------------------------
        // START CALCULATIONS
        //------------------------------
        
        //------------------------------
        // Building a map with all FOC CampaignLineItems related to the different Accounts coming from VLIs
        //------------------------------
        for(CampaignLineItem__c cli : [SELECT Id,
                                                FarmRef__c,
                                                DistributorRef__c,
                                                year__c,
                                                Type__c,
                                                Agreed__c,
                                                Division__c,
                                                HybridName__c,
                                                ProductRef__r.Name,
                                                ProductRef__r.ProductBagSize__c,
                                                ProductRef__r.DivisionRef__r.Name,
                                                ProductCatalogEntryRef__r.Price__c,
                                                ProductCatalogEntryRef__r.ProductCatalogRef__r.DivisionRef__r.Name
                                                FROM CampaignLineItem__c
                                                WHERE Type__c = 'Free of charge'
                                                AND Agreed__c != 0
                                                AND Agreed__c != null
                                                AND FarmRef__c IN : Map_VoucherId_Farm.values()]) {
        
            if(Map_FarmId_FOCCLIs.get(cli.FarmRef__c) == null)
                Map_FarmId_FOCCLIs.put(cli.FarmRef__c, new List <CampaignLineItem__c>{cli});
            else
                Map_FarmId_FOCCLIs.get(cli.FarmRef__c).add(cli);
        }

        //------------------------------
        // Building a map with all FOC CampaignLineItems related to the different Vouchers coming from VLIs
        //------------------------------
        for(Voucher__c v : List_Voucher) {
            if(Map_FarmId_FOCCLIs.get(v.AccountRef__c) != null) {
                for(CampaignLineItem__c cli : Map_FarmId_FOCCLIs.get(v.AccountRef__c)) {
                    if(cli.year__c == v.VoucherCampaignRef__r.YearRef__r.Name && cli.Division__c == v.VoucherCampaignRef__r.DivisionRef__r.Name) {
                      
                        if(Map_VoucId_FOCCLIs.get(v.Id) == null)
                            Map_VoucId_FOCCLIs.put(v.Id, new List<CampaignLineItem__c>{cli});
                        else
                            Map_VoucId_FOCCLIs.get(v.Id).add(cli);
                    }
                }
            }
        }
        
        Map<Integer, List<SObject>> Map_CLI_VLI_FOC = new  Map<Integer, List<SObject>>();
            
        for(Voucher__c v : List_Voucher) {
            
          Map_Discounts.clear();
          
          system.debug(' ');
          system.debug('***START: Voucher ' + v.Name);
          system.debug('***');
            
            //------------------------------
            // For VoucherCampaigns with the flag "Include Action Plan FOC lines" checked, the following piece of code
            // creates VoucherLineItems of type "Free of charge" and includes them in the Voucher, according to
            // the existent FOC lines in the Action Plan at the moment the Voucher is submitted.
            //------------------------------
            if(v.VoucherCampaignRef__r.CHCK_FOCBags_AP__c) {
                
                Integer TotalBagsFOC = 0;
                if(Map_VoucId_FOCCLIs.get(v.Id) != null) {
                    for(CampaignLineItem__c cli : Map_VoucId_FOCCLIs.get(v.Id)) {
    
                        Boolean isMixingProducts = v.VoucherCampaignRef__r.DivisionRef__c != cli.ProductRef__r.DivisionRef__c ? true : false;
    
                        //------------------------------
                        // For Vouchers that mixes products from different divisions, the Agreed to Bags conversion should be turned off
                        //------------------------------
                        Double vliBags = cli.Agreed__c;
                        if(v.VoucherCampaignRef__r.BagSize__c != 0 && v.VoucherCampaignRef__r.BagSize__c != null && isMixingProducts == false)
                            vliBags = cli.Agreed__c * cli.ProductRef__r.ProductBagSize__c/v.VoucherCampaignRef__r.BagSize__c;
    
                        VoucherLineItem__c vli = new VoucherLineItem__c(VoucherRef__c = v.Id,
                                                                        Agreed__c = cli.Agreed__c,
                                                                        Bags__c = vliBags.intValue(),
                                                                        PICK_TYPE__c = 'Free of charge',
                                                                        CampaignLineItemRef__c = cli.Id,
                                                                        HybridName__c = cli.HybridName__c,
                                                                        ProductName__c = cli.ProductRef__r.Name,
                                                                        LKP_ProductCatalogEntry__c = cli.ProductCatalogEntryRef__c,
                                                                        Price__c = cli.ProductCatalogEntryRef__r.Price__c);
                        
                        vliToInsert.add(vli);
                        TotalBagsFOC = TotalBagsFOC + vliBags.intValue();
                    }
                }
                Map_VoucherId_Bags.put(v.Id, TotalBagsFOC);
            }
            //system.debug('***Smart discounts for Voucher Campaign ' + v.VoucherCampaignRef__c + ': ' + Map_Campaign_List_Discount.get(v.VoucherCampaignRef__c));
            //system.debug('***');
            
            //------------------------------
            // Calculations for Smart Discounts.
            // - Initializing the list for possible smart discounts after first condition.
            // - First condition.
            // - Second condition.
            // - Building the map that includes the possible smart discounts to apply for the Voucher.
            //------------------------------
            if(Map_Campaign_List_Discount.get(v.VoucherCampaignRef__c) != null) {
                    
                Set_Discount_Type = new Set<String>();
                
                List<Discount__c> List_Discounts = new List<Discount__c>();
                
                for(Discount__c d : Map_Campaign_List_Discount.get(v.VoucherCampaignRef__c)) {
                    
                    //------------------------------
                    // First condition:
                    // - Fields to compare need to be rebuilt to print real values.
                    // - Comparison between two fields.
                    // - Comparison using only one field.
                    //------------------------------
                    String MinField = d.TXT_Min_First_Ladder_Field__c != null ? d.TXT_Min_First_Ladder_Field__c : '';
                    String MaxField = d.TXT_Max_First_Ladder_Field__c != null ? d.TXT_Max_First_Ladder_Field__c : '';
                    
                    Decimal MinField_value = 0.0;
                    Decimal MaxField_value = 0.0;
                    
                    if(MinField.contains('.')) {
                        String[] Array_MinField = MinField.split('\\.');
                        if(Array_MinField.size() == 2) MinField_value = (Decimal)v.getSObject(Array_MinField[0]).get(Array_MinField[1]);
                        if(Array_MinField.size() == 3) MinField_value = (Decimal)v.getSObject(Array_MinField[0]).getSObject(Array_MinField[1]).get(Array_MinField[2]);
                    } else {
                        MinField_value = MinField != '' ? (Decimal)v.get(MinField) : 0.0;
                    }
                    if(MaxField.contains('.')) {
                        String[] Array_MaxField = MaxField.split('\\.');
                        if(Array_MaxField.size() == 2) MaxField_value = (Decimal)v.getSObject(Array_MaxField[0]).get(Array_MaxField[1]);
                        if(Array_MaxField.size() == 3) MaxField_value = (Decimal)v.getSObject(Array_MaxField[0]).getSObject(Array_MaxField[1]).get(Array_MaxField[2]);
                    } else {
                        MaxField_value = MaxField != '' ? (Decimal)v.get(MaxField) : 0.0;
                    }
                    
                    //------------------------------
                    // It checks that values are not null
                    //------------------------------
                    MinField_value = MinField_value != null ? MinField_value : 0.0;
                    MaxField_value = MaxField_value != null ? MaxField_value : 0.0;
                    
                    //------------------------------
                    // Comparison between two fields.
                    //------------------------------
                    if(MinField != '' && MaxField != '') {
                        
                        //------------------------------
                        // START: Only for "Romania - Corn - 2016":
                        // - For new customers (Total Corn Sales PY named as MaxField_value = 0) guarantee the minimum discount is applied
                        // - Force new values for MinField_value and MaxField_value
                        //------------------------------
                        if(v.VoucherCampaignRef__r.Name == 'Romania - Corn - 2016' && MaxField_value == 0) {
                            MinField_value = 0.0;
                            MaxField_value = 1.0;
                        }
                        //------------------------------
                        // END: Only for "Romania - Corn - 2016"
                        //------------------------------
                        
                        if(d.NUM_Max_First_Ladder__c != null) {
                            if(MinField_value >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round()) && MinField_value <= ((Integer)(d.NUM_Max_First_Ladder__c * MaxField_value).round()))
                                List_Discounts.add(d);
                        } else {
                            if(MinField_value >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round()))
                                List_Discounts.add(d);
                        }
                    }
                    
                    //------------------------------
                    // Comparison using only one field.
                    //------------------------------
                    if(MinField != '' && MaxField == '') {
                        
                        if(d.NUM_Max_First_Ladder__c != null) {
                            if(MinField_value >= d.NUM_Min_First_Ladder__c && MinField_value <= d.NUM_Max_First_Ladder__c)
                                List_Discounts.add(d);

                        } else {
                            if(MinField_value >= d.NUM_Min_First_Ladder__c)
                                List_Discounts.add(d);

                        }
                    }
                    
                }
                //system.debug('***Smart discount list after first comparison: ' + List_Discounts);
                //system.debug('***');
                
                //------------------------------
                // START: Only for "Czech Republic - Corn - 2016", there're two quantities to compare:
                // - The total bags of Silage products
                // - The total bags of Grain products
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Czech Republic - Corn - 2016') {
                  
                  TotalBags_Silage = 0.0;
                  TotalBags_Grain = 0.0;
                                        
                    for(VoucherLineItem__c vli : Map_VoucherId_List_VLI.get(v.Id)) {
                        if(Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.DE_isPremium__c)
                            TotalBags_Silage = TotalBags_Silage + vli.Bags__c;
                        else
                            TotalBags_Grain = TotalBags_Grain + vli.Bags__c;
                    }
                }
                //------------------------------
                // END: Only for "Czech Republic - Corn - 2016"
                //------------------------------
                
                //------------------------------
                // In case there's not first condition for smart discounts, all discounts are processed in second condition.
                // So, List_Discounts is populated with all smart discounts for the VoucherCampaign.
                //------------------------------
                if(List_Discounts.size() == 0 && !v.VoucherCampaignRef__r.CHK_Ignore_bag_ladder__c)
                    List_Discounts = Map_Campaign_List_Discount.get(v.VoucherCampaignRef__c);
                
                for(Discount__c d : List_Discounts) {
                    
                    //------------------------------
                    // Second condition:
                    // - Building the map with the final smart discounts.
                    // - Only for enabled discounts (Today is between start and end dates, or these dates are empty).
                    //------------------------------    
                    Boolean setDiscount = false;
                    Boolean enabledDiscount = d.FRML_Enabled__c;
                                    
                    if(d.MaxBags__c != null)
                        setDiscount = (v.TotalBags__c >= d.MinBags__c && v.TotalBags__c <= d.MaxBags__c) ? true : false;
                    else
                        setDiscount = (v.TotalBags__c >= d.MinBags__c) ? true : false;
                    
                    //------------------------------
                    // START: Only for "Czech Republic - Corn - 2016", comparison:
                    // - The total bags of Silage products
                    // - The total bags of Grain products
                    //------------------------------
                    if(v.VoucherCampaignRef__r.Name == 'Czech Republic - Corn - 2016') {
                        setDiscount = false;
                        
                        if(d.PICK_Applies_to__c == 'Premium') {
                            if(d.MaxBags__c != null)
                                setDiscount = (TotalBags_Silage >= d.MinBags__c && TotalBags_Silage <= d.MaxBags__c) ? true : false;
                            else
                                setDiscount = (TotalBags_Silage >= d.MinBags__c) ? true : false;
                        }
                        if(d.PICK_Applies_to__c == 'Classic') {
                            if(d.MaxBags__c != null)
                                setDiscount = (TotalBags_Grain >= d.MinBags__c && TotalBags_Grain <= d.MaxBags__c) ? true : false;
                            else
                                setDiscount = (TotalBags_Grain >= d.MinBags__c) ? true : false;
                        }
                    }
                    //------------------------------
                    // END: Only for "Czech Republic - Corn - 2016"
                    //------------------------------
                    
                    //------------------------------
                    // START: Only for "Romania - Corn - 2016", comparison:
                    // - The comparison takes into account the Total Agreed at Account level
                    //------------------------------
                    
                    if(v.VoucherCampaignRef__r.Name == 'Romania - Corn - 2016') {
                        setDiscount = false;
                        
                        if(d.MaxBags__c != null)
                          setDiscount = (v.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c && v.AccountRef__r.AgreedMTOCornSalesCY__c <= d.MaxBags__c) ? true : false;
                      else
                          setDiscount = (v.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c) ? true : false;
                    }
                    
                    //------------------------------
                    // END: Only for "Romania - Corn - 2016"
                    //------------------------------
                    
                    //------------------------------
                    // START: Only for "Romania - Corn - 2017":
                    // - Getting old discounts when there are previous cancelled vouchers before Jan 1st
                    //------------------------------
                    
                    if(v.VoucherCampaignRef__r.Name == 'Romania - Corn - 2017' && Map_FarmId_OldDiscounts.containsKey(v.AccountRef__c)) {
                        if(Map_FarmId_OldDiscounts.get(v.AccountRef__c))
                            enabledDiscount = d.FRML_Enabled__c ? false : true;
                    }
                    
                    //------------------------------
                    // END: Only for "Romania - Corn - 2017"
                    //------------------------------
                    
                    if(setDiscount && enabledDiscount) {
                            
                        Map<String, Decimal> Map_Discounts_Values = new Map<String, Decimal>();
                    
                        if(d.PercentIncreaseInBags__c != 0 && d.PercentIncreaseInBags__c != null) {
                            Map_Discounts_Values.put('Bags%', d.PercentIncreaseInBags__c);
                            Set_Discount_Type.add('Bags%');
                        }
                        if(d.PercentIncreaseInPrice__c != 0 && d.PercentIncreaseInPrice__c != null) {
                            Map_Discounts_Values.put('Price%', d.PercentIncreaseInPrice__c);
                            Set_Discount_Type.add('Price%');
                        }
                        if(d.DiscountInPrice__c != 0 && d.DiscountInPrice__c != null) {
                            Map_Discounts_Values.put('Price', d.DiscountInPrice__c);
                            Set_Discount_Type.add('Price');
                        }
                        if(d.NUM_DiscountperBag__c != 0 && d.NUM_DiscountperBag__c != null) {
                            Map_Discounts_Values.put('Price/Bag', d.NUM_DiscountperBag__c);
                            Set_Discount_Type.add('Price/Bag');
                        }
                        Map_Discounts.put(d.PICK_Applies_to__c, Map_Discounts_Values);
                    }
                    
                }

                system.debug('***Possible Smart discounts for Voucher ' + v.Name + ': ' + Map_Discounts);
                system.debug('***Different Types of discount for Voucher ' + v.Name + ': ' + Set_Discount_Type);
                system.debug('***');
            }
            
            //------------------------------
            // START: Only for "Hungary - Corn - 2016".
            //------------------------------
            if(v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2016' && Map_Discounts.get('All') != null) {
              if(Map_Discounts.get('All').get('Price/Bag') != null)
                  v.EarlyOrderDiscount__c = Map_Discounts.get('All').get('Price/Bag') * v.TotalBags__c;
                  
            } else if (v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2016' && Map_Discounts.get('All') == null) {
              v.EarlyOrderDiscount__c = (Map_FarmId_EarlyOrder.get(v.AccountRef__c) != null && v.TotalBags__c >= Map_FarmId_EarlyOrder.get(v.AccountRef__c).get('TotalBags')) ? Map_FarmId_EarlyOrder.get(v.AccountRef__c).get('EarlyOrder') : 0;
            }
            //------------------------------
            // END: Only for "Hungary - Corn - 2016".
            //------------------------------
            
            Decimal UpdatedPrice = 0;
            Decimal UpdatedBags = 0;
            Decimal vFOC_Bags = 0;
            
            Decimal vHA = 0;
            Boolean hasPremium = false;
            //------------------------------
            // Loop for all VoucherLineItems in this Voucher, in order to apply the corresponding discount.
            //------------------------------
            system.debug('**** Map_VoucherId_List_VLI: ' + Map_VoucherId_List_VLI);

            //------------------------------
            // Loop to find out if there is at least one Premium vli.
            //------------------------------
            for(VoucherLineItem__c vli : Map_VoucherId_List_VLI.get(v.Id)) {
                Boolean isPremium = Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.DE_isPremium__c;
                if(!hasPremium && isPremium)
                    hasPremium = true;
            }
            
            for(VoucherLineItem__c vli : Map_VoucherId_List_VLI.get(v.Id)) {
                
                Boolean isPremium = Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.DE_isPremium__c;
                Boolean isNew = Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.NewProduct__c;
                
                //------------------------------
                // START: Only for "Czech Republic - Corn - 2016".
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Czech Republic - Corn - 2016') isNew = false;
                //------------------------------
                // END: Only for "Czech Republic - Corn - 2016".
                //------------------------------
                
                //------------------------------
                // START: Only for "Hungary - Corn - 2017".
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2017')
                {
                    if(Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.PlantingDensity__c != null && Integer.valueOf(Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.PlantingDensity__c) != 0)
                        vHA += ((vli.Bags__c * Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c * 1000) / Integer.valueOf(Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.PlantingDensity__c)).setScale(2, RoundingMode.HALF_UP);
                }
                //------------------------------
                // END: Only for "Hungary - Corn - 2017".
                //------------------------------
                
                Boolean isClassic = (!isNew && !isPremium) ? true : false;
                                
                List<String> List_Discount_Types = new List<String>();
                
                if(isClassic) List_Discount_Types.add('Classic');
                if(isPremium) List_Discount_Types.add('Premium');
                if(isNew) List_Discount_Types.add('New');
                List_Discount_Types.add('All');

                system.debug('Map_Discounts: '+ Map_Discounts);
                
                for(String Type : List_Discount_Types) {
                    
                    if(Map_Discounts.get(Type) != null) {
                        
                        if(Map_Discounts.get(Type).get('Bags%') != null)
                            UpdatedBags = UpdatedBags + (Map_Discounts.get(Type).get('Bags%')/100.0) * vli.Bags__c;
                        
                        if(Map_Discounts.get(Type).get('Price%') != null) {
                            Decimal Discount_Plus = 0.0;
                            Discount_Plus = v.EarlyOrderDiscount__c != null ? (Discount_Plus + v.EarlyOrderDiscount__c) : Discount_Plus;
                            Discount_Plus = v.DiscretionaryDiscount__c != null ? (Discount_Plus + v.DiscretionaryDiscount__c) : Discount_Plus;
                            UpdatedPrice = UpdatedPrice + ((Map_Discounts.get(Type).get('Price%') + Discount_Plus)/100.0) * vli.Bags__c * vli.Price__c;
                            Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c += ((Map_Discounts.get(Type).get('Price%') + Discount_Plus)/100.0) * vli.Bags__c * vli.Price__c;
                            vliToUpdate.add(Map_VLI_Complete.get(vli.Id));
                        }
                        
                        if(Map_Discounts.get(Type).get('Price') != null)
                            UpdatedPrice = UpdatedPrice + Map_Discounts.get(Type).get('Price');
                        
                        if(Map_Discounts.get(Type).get('Price/Bag') != null) {
                            if((v.VoucherCampaignRef__r.Name != 'Romania - Corn - 2017' && v.VoucherCampaignRef__r.Name != 'Bulgaria - Corn - 2017') || (v.VoucherCampaignRef__r.Name == 'Romania - Corn - 2017' && Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__r.ProductRef__r.ProductHybridGroup__c != 'RETAIL' && hasPremium) || (v.VoucherCampaignRef__r.Name == 'Bulgaria - Corn - 2017' && hasPremium)|| (v.VoucherCampaignRef__r.Name == 'Romania - OSR - 2017'))
                            {
                                if(v.VoucherCampaignRef__r.Name == 'Poland - Corn - 2017' && v.AccountRef__r.CHK_VAT_Payer__c == false)
                                {
                                    Decimal newDiscount = Map_Discounts.get(Type).get('Price/Bag') + 16.5;
                                    
                                    UpdatedPrice = UpdatedPrice + newDiscount * vli.Bags__c;
                                    Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c += newDiscount;
                                } 
                                else if(v.VoucherCampaignRef__r.Name == 'Romania - OSR - 2017'){
                                    system.debug('Received voucher of voucher campaign Romania - OSR - 2017');
                                    if(v.TotalBags__c >= 3){
                                        if( v.EarlyOrderDiscount__c > 0){
                                            system.debug('Updated Price before: '+UpdatedPrice);
                                            UpdatedPrice = UpdatedPrice + v.EarlyOrderDiscount__c * vli.Bags__c;
                                            system.debug('Updated Price before: '+UpdatedPrice);                                        
                                            Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c += v.EarlyOrderDiscount__c;
                                        }
                                        else{
                                            system.debug('Voucher romania without early discount');
                                            if(v.AccountRef__r.CHK_Protection_Program__c){
                                                system.debug('Voucher romania without early discount + protection program');
                                                UpdatedPrice = UpdatedPrice + v.EarlyOrderDiscount__c * vli.Bags__c;
                                                Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c = 0;
                                            } else{
                                                system.debug('Voucher romania without early discount and without protection program');
                                                if(Map_Discounts.containsKey('All')) UpdatedPrice = UpdatedPrice + Map_Discounts.get(Type).get('Price/Bag') * vli.Bags__c;
                                                Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c += Map_Discounts.get(Type).get('Price/Bag');
                                            }
                                        }
                                    }
                                    else{
                                        //todo
                                        Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c = 0;
                                    }
                                }
                                else {
                                
                                    UpdatedPrice = UpdatedPrice + Map_Discounts.get(Type).get('Price/Bag') * vli.Bags__c;
                                    Map_VLI_Complete.get(vli.Id).NUM_Price_Discount__c += Map_Discounts.get(Type).get('Price/Bag');
                                }
                                vliToUpdate.add(Map_VLI_Complete.get(vli.Id));
                            }
                        }
                        
                    }
                }
                
                    //---------------------------------------------------------------------------------------------
                    // START: Only for "Romania - OSR - 2016", FOC lines:
                    // - The process creates FOC lines (VLI and CLI) when total bags is greater than 300. 
                    // - Assigns an extra 5% of the charged bags as FOC
                    //---------------------------------------------------------------------------------------------                    
                    if(v.VoucherCampaignRef__r.Name == 'Romania - OSR - 2016' && v.AccountRef__r.NUM_AGREED_OSR_CY__c >= 300) {
                            
                            Decimal vli_dFOCBags = (vli.Bags__c*5)/100;
                            Integer vli_iFOCBags = (Integer)vli_dFOCBags.round(System.RoundingMode.HALF_UP);
                            
                            if(vli_iFOCBags > 0)
                            {
                                j++;
                                vFOC_Bags += vli_iFOCBags;
                                CampaignLineItem__c cli_foc = new CampaignLineItem__c(
                                                                            RecordtypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
                                                                            OwnerId = vli.OwnerId,
                                                                            PlantingDensity__c = Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.PlantingDensity__c,
                                                                            ProductCatalogEntryRef__c =  Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__c,
                                                                            CampaignRef__c = Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.CampaignRef__c,
                                                                            ProductRef__c = Map_VLI_Complete.get(vli.Id).CampaignLineItemRef__r.ProductRef__c,
                                                                            DistributorRef__c = Map_VLI_Complete.get(vli.Id).VoucherRef__r.DistributorRef__c,
                                                                            FarmRef__c = Map_VLI_Complete.get(vli.Id).VoucherRef__r.AccountRef__c,
                                                                            Price__c = vli.Price__c,
                                                                            Agreed__c = vli_iFOCBags,
                                                                            Quantity__c = vli_iFOCBags,
                                                                            Status__c = 'Ordered / Discussed',
                                                                            Type__c = 'Free of charge');
                                
                                VoucherLineItem__c vli_foc = new VoucherLineItem__c(
                                                                            VoucherRef__c = v.Id,
                                                                            OwnerId = vli.OwnerId,
                                                                            Agreed__c = vli_iFOCBags,
                                                                            Bags__c = vli_iFOCBags,
                                                                            PICK_TYPE__c = 'Free of charge',
                                                                            LKP_ProductCatalogEntry__c = Map_VLI_Complete.get(vli.Id).LKP_ProductCatalogEntry__c,
                                                                            FAO__c = vli.FAO__c,
                                                                            ProductName__c = vli.ProductName__c,
                                                                            HybridGroup__c = vli.HybridGroup__c,
                                                                            HybridName__c = vli.HybridName__c,
                                                                            Price__c = vli.Price__c);

                                Map_CLI_VLI_FOC.put(j, new List<SObject>{(CampaignLineItem__c)cli_foc, (VoucherLineItem__c)vli_foc});
                            }
                    }
                    //-----------------------------------------------------
                    // END: Only for "Romania - OSR - 2016"
                    //-----------------------------------------------------
                
            }
            
            //-----------------------------------------------------
            // START: Only for "Romania - OSR - 2016"
            //-----------------------------------------------------
            if(vFOC_Bags > 0)
            {
                v.TotalBagsFOC__c = v.TotalBagsFOC__c == null ? 0 : v.TotalBagsFOC__c;
                v.TotalBagsFOC__c += vFOC_Bags;
            }
            //-----------------------------------------------------
            // END: Only for "Romania - OSR - 2016"
            //-----------------------------------------------------

            if(v.VoucherCampaignRef__r.Discount_Type__c == 'In Price') {
                v.Price_Coupon__c = UpdatedPrice;
                system.debug('***Updated Price = ' + UpdatedPrice);
            }
                
            if(v.VoucherCampaignRef__r.Discount_Type__c == 'In Bags') {
                v.TotalBagsFOC__c += UpdatedBags;
                system.debug('***Updated Bags = ' + UpdatedBags);
            }
                
            //------------------------------
            // Other discounts:
            // - Discretionary discount
            // - Early Order discount
            //------------------------------
            if(Set_Discount_Type.size() > 1)
                system.debug('***Smart discounts are inconsistent. Different types of discount for a given Voucher.');
            
            if(Set_Discount_Type.size() <= 1) {
                
                Decimal Discount_Plus = 0.0;
                Discount_Plus = v.EarlyOrderDiscount__c != null ? (Discount_Plus + v.EarlyOrderDiscount__c) : Discount_Plus;
                Discount_Plus = v.DiscretionaryDiscount__c != null ? (Discount_Plus + v.DiscretionaryDiscount__c) : Discount_Plus;
                
                //------------------------------
                // START: Only for "Hungary - Corn - 2016"
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2016')
                  Discount_Plus = (Map_FarmId_EarlyOrder.get(v.AccountRef__c) != null && v.TotalBags__c >= Map_FarmId_EarlyOrder.get(v.AccountRef__c).get('TotalBags')  && Map_Discounts.get('All') == null) ? (Discount_Plus / v.TotalBags__c) : 0.0;
                //------------------------------
                // END: Only for "Hungary - Corn - 2016"
                //------------------------------
                
                //------------------------------
                // START: Only for "Hungary - OSR - 2016" or "Hungary - Corn - 2017"
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Hungary - OSR - 2016' || v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2017') {
                  v.DiscretionaryDiscount__c = (Discount_Plus * 1000);
                  Discount_Plus = Discount_Plus * 1000;
                  
                  if(Set_Discount_Type.size() == 0)
                    v.Price_Coupon__c = Discount_Plus;
                }
                //------------------------------
                // END: Only for "Hungary - OSR - 2016" or "Hungary - Corn - 2017"
                //------------------------------
                
                 //------------------------------
                // START: Only for "Russia - Corn - 2017"
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Russia - Corn - 2017') {
                    v.Price_Coupon__c = Discount_Plus * v.TotalBags__c;
                }
                //------------------------------
                // END: Only for "Russia - Corn - 2017"
                //------------------------------
                
                Decimal FOCBags = v.TotalBagsFOC__c != null ? v.TotalBagsFOC__c : 0.0;
                Decimal PriceCoupon = v.Price_Coupon__c != null ? v.Price_Coupon__c : 0.0;
                
                if(Set_Discount_Type.contains('Bags%')) v.TotalBagsFOC__c = FOCBags + (Discount_Plus/100.0) * v.TotalBags__c;
                if(Set_Discount_Type.contains('Price')) v.Price_Coupon__c = PriceCoupon + Discount_Plus;
                if(Set_Discount_Type.contains('Price/Bag')) v.Price_Coupon__c = PriceCoupon + Discount_Plus * v.TotalBags__c;
                
                //------------------------------
                // START: Only for "Romania - OSR - 2017"
                //------------------------------
                if(v.VoucherCampaignRef__r.Name == 'Romania - OSR - 2017') {
                    v.Price_Coupon__c = UpdatedPrice;
                }
                //------------------------------
                // END: Only for "Romania - OSR - 2017"
                //------------------------------
                
                system.debug('***Additional discount of ' + Discount_Plus + ' of type ' + Set_Discount_Type);
            }
            
            //------------------------------
            // START: Only for "Hungary - Corn - 2017".
            //------------------------------
            if(v.VoucherCampaignRef__r.Name == 'Hungary - Corn - 2017')
            {
                system.debug('***HU: Acreages from Voucher: ' + vHA + ' ha');
                system.debug('***HU: Acreages from Account: ' + v.AccountRef__r.CornTotalAcreagesCY__c + ' ha');
                if(vHA > v.AccountRef__r.CornTotalAcreagesCY__c)
                {
                    v.Price_Coupon__c = 0;
                    system.debug('***HU: ' + vHA + ' > ' + v.AccountRef__r.CornTotalAcreagesCY__c + ' => No discount.');
                }
            }
            //------------------------------
            // END: Only for "Hungary - Corn - 2017".
            //------------------------------
            
            //------------------------------
            // START: Only for "Romania - Corn - 2017" and "Bulgaria - Corn - 2017"
            //------------------------------
            if(v.VoucherCampaignRef__r.Name == 'Romania - Corn - 2017' || v.VoucherCampaignRef__r.Name == 'Bulgaria - Corn - 2017')
            {
                if(!hasPremium)
                {
                    v.Price_Coupon__c = 0;
                    system.debug('***RO: There are not Premium products in the Voucher => No discount.');
                }
            }
            //------------------------------
            // END: Only for "Romania - Corn - 2017" and "Bulgaria - Corn - 2017".
            //------------------------------
            
            vToUpdate.add(v);
            system.debug('***END: Voucher ' + v.Name);
        }
        //------------------------------
        // It updates lists and clears them for following iterations.
        //------------------------------
        if(vToUpdate.size() > 0)
            update vToUpdate;

        vToUpdate.clear();
        
        Set<VoucherLineItem__c> vliToUpdate_Set = new Set<VoucherLineItem__c>();
        vliToUpdate_Set.addAll(vliToUpdate);
        vliToUpdate = new List<VoucherLineItem__c>();
        vliToUpdate.addAll(vliToUpdate_Set);   
        
        system.debug('***vliToUpdate: ' + vliToUpdate);     
        
        if(vliToUpdate.size() > 0)
            update vliToUpdate;

        vliToUpdate.clear();
        
        //------------------------------
        // END CALCULATIONS
        //------------------------------
        
        //------------------------------
        // At this point, Voucher Line Items are inserted and Vouchers are updated
        //------------------------------
        for(Voucher__c v : [SELECT Id, Name,
                  TotalBags__c,
                            TotalBagsFOC__c,
                            AccountRef__r.CHK_Protection_Program__c,
                            NUM_FOC_VOLUME__c,
                            NUM_EXTRA_VOLUME__c,
                            VoucherCampaignRef__r.Name,
                            AccountRef__r.HU_1TON_NEWPARTNER_CHECK__c
                            FROM Voucher__c
                            WHERE Id IN : Map_VoucherId_Bags.keyset()]) {
            
            //------------------------------
            // START: Only for "Bulgaria - Corn - 2016", NUM_FOC_VOLUME__c is set with:
            // - TotalBagsFOC__c + 1 (for more than 2 lines, 15 bags and POGPY = 0)
            // - TotalBagsFOC__c (if previous conditions are not met)
            //------------------------------
            if(v.VoucherCampaignRef__r.Name == 'Bulgaria - Corn - 2016') {
                if(Map_VoucherId_List_VLI.get(v.Id).size() >= 2 && v.TotalBags__c >= 15 && (v.AccountRef__r.HU_1TON_NEWPARTNER_CHECK__c))
                    v.NUM_EXTRA_VOLUME__c = 1;
                else
                    v.NUM_EXTRA_VOLUME__c = 0;

                v.NUM_FOC_VOLUME__c = v.TotalBagsFOC__c + v.NUM_EXTRA_VOLUME__c;
            }
            //------------------------------
            // END: Only for "Bulgaria - Corn - 2016"
            //------------------------------

            v.TotalBagsFOC__c = Map_VoucherId_Bags.get(v.Id);
            vToUpdate.add(v);
        }
        
        if(vliToInsert.size() > 0)
            insert vliToInsert;
            
        if(vToUpdate.size() > 0)
            update vToUpdate;
        
        
        //-----------------------------------------------------------------
        //  START: Inserts lists for ROMANIA - OSR - 2016
        //-----------------------------------------------------------------        
        List<CampaignLineItem__c> cliFOCToInsert = new List<CampaignLineItem__c>();
        List<VoucherLineItem__c> vliFOCToInsert = new List<VoucherLineItem__c>();
        
        for(List<SObject> SObject_list : Map_CLI_VLI_FOC.values())
        {
            cliFOCToInsert.add((CampaignLineItem__c)SObject_list[0]);
            vliFOCToInsert.add((VoucherLineItem__c)SObject_list[1]);
        }
        
        if(cliFOCToInsert.size() > 0)
            insert cliFOCToInsert;
        
        if(vliFOCToInsert.size() > 0)
            insert vliFOCToInsert;
            
        for(Integer i = 0; i < vliFOCToInsert.size(); i++)
            vliFOCToInsert[i].CampaignLineItemRef__c = cliFOCToInsert[i].Id;

        if(vliFOCToInsert.size() > 0)
            update vliFOCToInsert;
    //-----------------------------------------------------------------
    //  END: Inserts lists for ROMANIA - OSR - 2016
    //-----------------------------------------------------------------
    //------------------------------
    // END METHOD handle()
    //------------------------------
    }
}