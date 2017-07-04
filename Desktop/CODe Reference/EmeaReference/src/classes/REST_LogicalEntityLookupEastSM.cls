@RestResource(urlMapping='/getLogicalEntity/LookupEast_2SM/*')
global class REST_LogicalEntityLookupEastSM{

    @HttpPost
    global static REST_LogicalEntity_Lookup getLookups(REST_Request paramInfo)
    {
                    
        REST_Request lRequest = paramInfo;
        
        REST_LogicalEntity_Lookup returned = new REST_LogicalEntity_Lookup();
        returned.pagetimestamp=lRequest.pagetimestamp;        
        returned.lastItem=lRequest.lastItem;
        returned.mode=lRequest.mode;       
        returned.lastId='';
             
        
        
        lRequest.pagetimestamp=UtilREST.resetTimestamp(lRequest.pagetimestamp); 

              

        returned.years = new List<Year__c>();
        
        User current_us = [
            SELECT
                Country
            FROM
                User
            WHERE
                ID = :UserInfo.getUserID()
            LIMIT
                1
            ];
        
        for(Year__c y : [

            SELECT 
                Name,
                Current_Year__c,
                CurrentYear_RSA__c,
                YearStartDate__c,
                YearEndDate__c,
                YearNextYear__c,
                YearPreviousYear__c,
                LastModifiedDate
            FROM
                Year__c
            WHERE
                LastModifiedDate > :lRequest.pagetimestamp



                ])
            {
                if(y.Name.equalsIgnoreCase(Util.currentyear.Name))
                {       
                    y.Current_year__c=true;
                }
                else
                {
                    y.Current_year__c=false;

                }
                

                if(current_us.Country=='South Africa')
                {
                    y.Current_Year__c=y.CurrentYear_RSA__c;
                }   
                returned.years.add(y);
            }
                                                                       
        returned.divisions = [
            SELECT 
                Name,
                LastModifiedDate
            FROM
                Division__c
            WHERE
                LastModifiedDate > :lRequest.pagetimestamp AND (Name = 'Corn' OR Name = 'OSR')
            ];
            
        returned.countries = [
            SELECT
                Name,
                DE_EnableAccountSharing__c, 
                TacticalPlanSetting__c,
                Target_Accounts__c  ,
                LastModifiedDate,
                CHK_isUserArea__c

            FROM
                Country__c
            WHERE
                LastModifiedDate > :lRequest.pagetimestamp
            ];
            
            
        returned.users = [
            SELECT
                Name,
                UserName,
                ManagerId,
                Manager.Name,
                managers_manager__c,
                managers_manager__r.Name,
                LastModifiedDate,
                Is_Sales_Rep__c,
                Is_Regional_Manager__c,
                Is_Country_Manager__c,
                Contact_and_Account_approver__c,
                MobilePhone,
                Country,
                LanguageLocaleKey
            FROM
                User
            WHERE
                 LastModifiedDate > :lRequest.pagetimestamp
            
          /*  WHERE
                ID = :UserInfo.getUserID()*/
            ];
          
        returned.loggedUserCountry= (String) Util.currentCountry.ID;
        returned.shouldUpdateLayouts = ((lRequest.pagetimestamp.date()).daysBetween(Date.today()) > 100) || Util.currentCountry.CHK_should_Update_Layouts__c;
            
        returned.discounts = [
             SELECT 
                Active__c, 
                CreatedById, 
                CreatedDate,
                Name,  
                LastModifiedDate,
                MaxBags__c,
                MinBags__c, 
                OwnerId, 
                Id, 
                VoucherCampaignRef__c,
                PercentIncreaseInBags__c,
                DiscountInPrice__c,
                RecordTypeId,
                LastModifiedById,
                PercentIncreaseInPrice__c 
            FROM Discount__c      
            WHERE
                LastModifiedDate > :lRequest.pagetimestamp 
                AND Active__c=true 
                AND VoucherCampaignRef__c in:UtilREST.VoucherCampaigns
                ];
                
         returned.discountsRSA = new List<DiscountMasterTable_RSA__c>();
            
            if(UtilREST.currentYearRSA!=null)
              returned.discountsRSA = [
              SELECT 
                  Name,
                  AdditionalDiscount_RSA__c,
                  Type_RSA__c,
                  Year_RSA__c,
                  LastModifiedDate
              FROM
                  DiscountMasterTable_RSA__c
              WHERE
                  LastModifiedDate > :lRequest.pagetimestamp AND  
                  Year_RSA__c=:UtilREST.currentYearRSA
                  ];
            Set<Id> listaIdsTranslations = new Set<Id> ();
             for(ProductTranslation__c itemTranslation : [SELECT ProductGroupingRef__c from ProductTranslation__c where (LastModifiedDate > :lRequest.pagetimestamp or CountryRef__r.LastModifiedDate > :lRequest.pagetimestamp) AND CountryRef__r.name = : Util.currentUser.Country])
             {
                 listaIdsTranslations.add(itemTranslation.ProductGroupingRef__c);
             }
 
            returned.productgroups = [  
            SELECT   
                LastModifiedDate, 
                OwnerId, 
                Name, 
                (SELECT Translation__c FROM Product_Transalations__r WHERE CountryRef__r.ProductTranslation__c = true AND CountryRef__r.name = : Util.currentUser.Country )                           

            FROM 
                Product_Grouping__c
            WHERE 
                RecordTypeId=:Util.recordType.get('Product_Grouping__c:ProductGroup') AND (LastModifiedDate > :lRequest.pagetimestamp OR id in :listaIdsTranslations)
            ];

            for (Product_Grouping__c item : returned.productgroups)
            {
                if (item.Product_Transalations__r != null && item.Product_Transalations__r.size() > 0)
                {
                    item.name = item.Product_Transalations__r[0].Translation__c;
                }
            }

            returned.producttypes = [

            SELECT   
                LastModifiedDate, 
                OwnerId, 
                ProductGroupRef__c, 
                Name ,               
            (SELECT Translation__c FROM Product_Transalations__r WHERE CountryRef__r.ProductTranslation__c = true AND CountryRef__r.name = : Util.currentUser.Country )
            FROM 
                Product_Grouping__c
            WHERE 
                RecordTypeId=:Util.recordType.get('Product_Grouping__c:ProductType') AND (LastModifiedDate > :lRequest.pagetimestamp OR id in :listaIdsTranslations)
            ];
                
            for (Product_Grouping__c item : returned.producttypes)
            {
                if (item.Product_Transalations__r != null && item.Product_Transalations__r.size() > 0)
                {
                    item.name = item.Product_Transalations__r[0].Translation__c;
                }
            }

        Map<ID,String> recordTypeTranslation = new Map<ID,String> ();       
        
        for( RecordTypeLocalization rcl: [ SELECT  Language , ParentId,  Id, Value FROM RecordTypeLocalization WHERE Language=:Util.currentUser.LanguageLocaleKey])
        {
            recordTypeTranslation.put(rcl.ParentId,rcl.Value);
        }
        
        Map<Id,Schema.RecordTypeInfo> rtMapByIdTask = Schema.SObjectType.Task.getRecordTypeInfosById();
        Map<Id,Schema.RecordTypeInfo> rtMapByIdEvent = Schema.SObjectType.Event.getRecordTypeInfosById();
        
        returned.recordTypes = new Map<String,List<Map<String,String>>>();
        Set<String> objectTypes = new Set<String>{'Order__c','Account','Campaign','CampaignLineItem__c','CampaignLineItemGroup__c','ProductCatalog__c','Acreage__c','Discount__c', 'Event', 'Task'};
        for(RecordType rt : [SELECT Name, sObjectType FROM RecordType WHERE SOBJECTTYPE in :ObjectTypes]){
            if(returned.recordTypes.get(rt.sObjectType + '_Type') == null){
                returned.recordTypes.put(rt.sObjectType + '_Type',new List<Map<String,String>>());
            }
            if((rtMapByIdEvent.get(rt.ID) != null && rtMapByIdEvent.get(rt.ID).isAvailable() && rtMapByIdEvent.get(rt.ID).isDefaultRecordTypeMapping())
            || (rtMapByIdTask.get(rt.ID) != null && rtMapByIdTask.get(rt.ID).isAvailable() && rtMapByIdTask.get(rt.ID).isDefaultRecordTypeMapping())
            || (rtMapByIdEvent.get(rt.ID) == null && rtMapByIdTask.get(rt.ID) == null)
            )
            
                returned.recordTypes.get(rt.sObjectType + '_Type').add(new Map<String,String>{'Name'=>rt.Name,'Id'=>String.valueOf(rt.ID),'Translation'=>recordTypeTranslation.get(rt.Id)});
        }
             
        //IPAD issue: Resolution to problem with Contact and Account picklist synchronization
        
        List<String> stringObject = new List<String>{'Contact','Account', 'Order__c','CampaignLineItem__c','CampaignLineItemGroup__c','Product2', 'Event', 'Task','VoucherLineItem__c','VoucherCampaign__c'};

        Map<String,List<Schema.DescribeFieldResult>> picklistfields = new 
        Map<String,List<Schema.DescribeFieldResult>>{

        'Contact' => new List<Schema.DescribeFieldResult>{
        Contact.Salutation.getDescribe(),/*Contact.DE_CHECK_BEIZ__c.getDescribe(),Contact.ContactOrigin_ES__c.getDescribe(),
        Contact.DE_Ctproz__c.getDescribe(),Contact.DE_Data_Source__c.getDescribe(),Contact.DE_DEAR__c.getDescribe(),Contact.DE_Division__c.getDescribe(),Contact.DE_ENERGY_PICK__c.getDescribe(),
        Contact.ES_Position__c.getDescribe(),Contact.FR_Farmer_Qualification__c.getDescribe(),Contact.DE_Function__c.getDescribe(),Contact.Gender__c.getDescribe(),
        Contact.DE_Kein_Brief__c.getDescribe(),Contact.DE_Kein_E_Mail__c.getDescribe(),Contact.DE_Keine_SMS__c.getDescribe(),Contact.DE_Kein_Fax__c.getDescribe(),
        Contact.DE_Kein_Mail__c.getDescribe(),Contact.DE_Kein_Telemarketing__c.getDescribe(),*/Contact.GC_Highest_Educ_Lvl_Descr__c.getDescribe(),Contact.Loyalty__c.getDescribe(),
        /*Contact.DE_CORN_PICK__c.getDescribe(),Contact.MarithalStatus__c.getDescribe(),Contact.DE_MonsantoAffinity__c.getDescribe(),*/Contact.Position_picklist__c.getDescribe(),
        /*Contact.DE_Position__c.getDescribe(),Contact.FR_Contact_Position_1__c.getDescribe(),Contact.FR_Contact_Position_2__c.getDescribe(),Contact.DE_PreferredContact__c.getDescribe(),*/
        Contact.GC_Pref_Contact_Method_Descr__c.getDescribe()/*,Contact.DE_PICK_PS__c.getDescribe(),Contact.DE_OSR_PICK__c.getDescribe(),Contact.DE_PICK_ST__c.getDescribe()*/,Contact.DE_Sehr_geehrte__c.getDescribe(),
        Contact.Size__c.getDescribe(),Contact.Status__c.getDescribe(),Contact.Subtype__c.getDescribe(),Contact.Type__c.getDescribe(),Contact.GC_Type_Descr__c.getDescribe()   
        },
        'Account' => new List<Schema.DescribeFieldResult>{Account.iPadtab__c.getDescribe(),Account.Type.getDescribe(),Account.Type.getDescribe(),Account.Trust_CC_Mpy_RSA__c.getDescribe(),Account.GC_Status_Descr__c.getDescribe(),Account.Category__c.getDescribe(),Account.Level__c.getDescribe(),/*Account.ES_Level__c.getDescribe(),
        */Account.AccountSource.getDescribe(),Account.Industry.getDescribe(),Account.Ownership.getDescribe(),Account.Rating.getDescribe(),/*Account.DE_Absatzpotenzial__c.getDescribe(),Account.FR_Activity_Detail__c.getDescribe(),
        Account.FR_Alsace_Cantons__c.getDescribe(),*/Account.Cattle__c.getDescribe()/*,Account.FR_Centre_Cantons__c.getDescribe(),Account.Colaborador_ES__c.getDescribe(),Account.DE_Beiz__c.getDescribe(),Account.Collaboratore_IT__c.getDescribe(),   
        Account.DE_Absatzpotenzial__c.getDescribe(),Account.FR_Activity_Detail__c.getDescribe(),Account.FR_Alsace_Cantons__c.getDescribe(),Account.FR_Aquitaine_Cantons__c.getDescribe(),Account.Attivita_principale__c.getDescribe(),      
        Account.DE_CustomerCornSeeds__c.getDescribe(),Account.DE_Data_Source__c.getDescribe(),Account.FR_Department__c.getDescribe()*/,Account.Disease__c.getDescribe(),/*Account.FR_Distributor_Level__c.getDescribe(),    
        Account.DE_Responsable_TD_CP__c.getDescribe(),Account.DE_Responsable_TD_S_T__c.getDescribe(),Account.FR_Rhone_Alpes_Cantons__c.getDescribe(),Account.RO_Client_Segmentation__c.getDescribe(),Account.DE_IsSTCustomer__c.getDescribe(),Account.DE_CustomerOSRSeeds__c.getDescribe(),
        Account.SubType_IT__c.getDescribe(),*/Account.Type_IT__c.getDescribe(),/*Account.FR_Type_de_Ferme__c.getDescribe(),*/Account.Type_of_cattle__c.getDescribe(),Account.Type_of_irrigation__c.getDescribe(),Account.Virulence__c.getDescribe(),    
        Account.FieldTexture__c.getDescribe(),/*Account.DE_Geno__c.getDescribe(),Account.DE_ID_STATUS__c.getDescribe(),Account.FR_Main_Activity__c.getDescribe(),Account.FR_Midi_Pyrenees_Cantons__c.getDescribe(),Account.FR_Pays_De_Loire_Cantons__c.getDescribe(),
        Account.FR_Poitou_Charente_Cantons__c.getDescribe(),Account.DE_Potenzialausschoepfung__c.getDescribe(),Account.DE_PS__c.getDescribe(),*/Account.Purchase_channel__c.getDescribe(),Account.Rating__c.getDescribe()/*,Account.FR_Region__c.getDescribe()*/
                },
        'CampaignLineItem__c' => new List<Schema.DescribeFieldResult>{CampaignLineItem__c.Status__c.getDescribe(),CampaignLineItem__c.Type__c.getDescribe()},
        'CampaignLineItemGroup__c' => new List<Schema.DescribeFieldResult>{CampaignLineItemGroup__c.Status__c.getDescribe(),CampaignLineItemGroup__c.Type__c.getDescribe(),CampaignLineItemGroup__c.HarvestedBy__c.getDescribe()},
        'Product2' => new List<Schema.DescribeFieldResult>{Product2.ProductTreatment__c.getDescribe()},
        'Event' => new List<Schema.DescribeFieldResult>{Event.Subject.getDescribe(), Event.Type.getDescribe(), Event.TaskReminderTime__c.getDescribe()},
        'Task' => new List<Schema.DescribeFieldResult>{Task.CallType.getDescribe(), Task.Priority.getDescribe(), Task.Status.getDescribe(), Task.Subject.getDescribe(), Task.Type.getDescribe(), Task.NPSFollowUp__c.getDescribe(), Task.TaskReminderTime__c.getDescribe()},
           
        'Order__c' => new List<Schema.DescribeFieldResult>{Order__c.Reason__c.getDescribe()},
'VoucherLineItem__c' => new List<Schema.DescribeFieldResult>{voucherLineItem__c.PICK_PRODUCTFIELD1__c.getDescribe()}, 
        'VoucherCampaign__c' => new List<Schema.DescribeFieldResult>{voucherCampaign__c.MPICK_PRODUCTFIELDS__c.getDescribe()}
        };
        
        
       
       
        returned.pickListValues = new Map<String,Map<String,List<Map<String,String>>>>();
        
        MAP<String,String> categoryRecordTypes = new MAP<String,String>{'Group'=> 'Group/Farm/Site', 'Farm' => 'Group/Farm/Site', 'Site' => 'Group/Farm/Site', 'Distributor' => 'Dist./Ret./PoS', 
            'Retailer' => 'Dist./Ret./PoS', 'PoS' => 'Dist./Ret./PoS', 'Competitor' => 'Competitor', 'Organisation' => 'Dist./Ret./PoS', 'Influencer' => 'Dist./Ret./PoS'} ;
            
            List<Recordtype> rts = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task'];
            Schema.DescribeSObjectResult d = Schema.SObjectType.Task; 
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            List<Schema.RecordTypeInfo> rtInfoMaps = new List<Schema.RecordTypeInfo>();
            for(Recordtype prim : rts)
            {
                rtInfoMaps.add(rtMapById.get(prim.Id));
            }
            system.debug('testtttttt');
            system.debug(rtInfoMaps);
        
        for(integer i=0;i<picklistfields.size();i++){
        returned.pickListValues.put(stringObject[i],new Map<String,List<Map<String,String>>>());   
        
    
            for(integer j=0;j<picklistfields.get(stringObject[i]).size();j++){
                
                                
                List<Schema.PicklistEntry> values = picklistfields.get(stringObject[i])[j].getPicklistValues();
                List<Map<String,String>> values_maplist = new List<Map<String,String>>();
                
                if(picklistfields.get(stringObject[i])[j].getName()!='Category__c')
                {
                    for (Schema.PicklistEntry f: values)
                    {
                        values_maplist.add(new Map<String,String>{
                                              'name'=>f.getLabel(),
                                              'value'=>f.getValue()
                                        });
                    }
                }
                else
                {
                    for (Schema.PicklistEntry f: values)
                    {
                        values_maplist.add(new Map<String,String>{
                                              'name'=>f.getLabel(),
                                              'value'=>f.getValue(),
                                              'recordType' =>categoryRecordTypes.get(f.getValue())
                                        });
                    }
                
                }
               
            /*getName*/
            returned.pickListValues.get(stringObject[i]).put(picklistfields.get(stringObject[i])[j].getName(), values_maplist);
            }
            
       }  
                 
                
         returned.documents = new List<DocumentWrapper>();        
        
        for(EnhancedDocument__c doc : [SELECT Content__c,CountryRef__c,Id,Language__c,LastModifiedDate,Name,Type__c, TXT_Short_Description__c FROM EnhancedDocument__c WHERE CountryRef__r.Name='South Africa' AND LastModifiedDate > :lRequest.pagetimestamp])
        {
          String docName = '';
        if(doc.Language__c=='Afrikaans')
          docName = doc.TXT_Short_Description__c + '_za';
        else
          docName = doc.TXT_Short_Description__c + '_en';
          
        returned.documents.add(new DocumentWrapper(docName,EncodingUtil.base64Encode(Blob.valueOf(doc.Content__c)),doc.LastModifiedDate, doc.ID));          
        }
        
               
        returned.calculateTimestamp(lRequest.maxtimestamp);          

        return returned;
    }
    
    global class REST_LogicalEntity_Lookup{
        public List<Year__c> years {get;set;}
        public List<Division__c> divisions {get;set;}
        public List<Country__c> countries {get;set;}
        public List<User> users {get;set;}
        public List<Product_Grouping__c>  productgroups  {get;set;}
        public List<Product_Grouping__c>  producttypes  {get;set;}    
        public Map<String,List<Map<String,String>>> recordTypes {get;set;}
        public Map<String,Map<String,List<Map<String,String>>>> pickListValues {get;set;}
        public String loggedUserCountry  {get;set;}
        public List<Discount__c> discounts {get;set;}
        public List<DiscountMasterTable_RSA__c> discountsRSA {get;set;}
        public List<DocumentWrapper> documents{get;set;}    
        
        Decimal VAT=Decimal.valueof(SystemSettings__c.getValues('VAT_RSA').Value__c);           
        Decimal minVolumeDiscount=Decimal.valueof(SystemSettings__c.getValues('RSA_MIN_VOLUME_DISCOUNT').Value__c);
        Decimal stepsizeVolumeDiscount=Decimal.valueof(SystemSettings__c.getValues('RSA_STEPSIZE_VOLUME_DISCOUNT').Value__c);
        Decimal maxVolumeDiscount=Decimal.valueof(SystemSettings__c.getValues('RSA_MAX_VOLUME_DISCOUNT').Value__c);     
        boolean shouldUpdateLayouts;
                
        DateTime timestamp {get;set;}
        DateTime pagetimestamp {get;set;}
        DateTime maxtimestamp {get;set;}     
        Boolean queryMore {get;set;}        
        Integer mode {get;set;}         
        Integer lastItem {get;set;}  
        String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
            maxtimestamp=reqMaxTimestamp;         
                        
            for(Year__c y : years){
                if(maxtimestamp < y.LastModifiedDate)maxtimestamp = y.LastModifiedDate;
            }
            for(Division__c d : divisions){
                if(maxtimestamp < d.LastModifiedDate)maxtimestamp = d.LastModifiedDate;
            }
            for(Country__c c : countries){
                if(maxtimestamp < c.LastModifiedDate)maxtimestamp = c.LastModifiedDate;
            }
            for(User u : users){
                if(maxtimestamp < u.LastModifiedDate)maxtimestamp = u.LastModifiedDate;
            }  
            for(Discount__c dc : discounts){
                if(maxtimestamp < dc.LastModifiedDate)maxtimestamp = dc.LastModifiedDate;
            }                   
            for(Product_Grouping__c pg : productgroups){
                if(maxtimestamp < pg.LastModifiedDate)maxtimestamp = pg.LastModifiedDate;
            }     
            for(Product_Grouping__c pt : producttypes){
                if(maxtimestamp < pt.LastModifiedDate)maxtimestamp = pt.LastModifiedDate;
            } 
            for(DocumentWrapper dw : documents){
                if(maxtimestamp < dw.LastModifiedDate)maxtimestamp = dw.LastModifiedDate;
            }   
            
            timestamp=maxtimestamp;
            queryMore=false;                
            pagetimestamp=maxtimestamp;
            mode=0;
            lastItem=0;
            LastId='';
        }
    }
    
      global class DocumentWrapper
    {
      DocumentWrapper(String n,String b, DateTime d, Id Ids)
      {
        this.Name=n;
        this.body=b;
        this.LastModifiedDate=d;
        this.dId=ids;
      }
      Id dId;
      String Name;
      String body;
      Datetime LastModifiedDate;
      
    }
    
}