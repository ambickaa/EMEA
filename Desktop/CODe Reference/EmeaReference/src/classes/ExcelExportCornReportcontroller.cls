public with sharing class ExcelExportCornReportcontroller {

    public Map<String,Map<String,String>> premiumCorn  { get; set; }
    public Set<String> getPremiumCornSet (){ return premiumCorn.keySet();}

    public Map<String,Map<String,String>> standardCorn  { get; set; }
    public Set<String> getstandardCornSet (){ return standardCorn.keySet();}
    
    public Map<String,Map<String,String>> PYear{ get; set; }
    public Set<String> getPYearSet (){ return PYear.keySet();}

    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }

    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient Retoure__c Retoure{ get;set;}
    
    public Decimal SortenRabatt {get;set;}
    public Decimal SummeRabat { get;set;}
    //2017 ZVD variables
    public Decimal SortenRabatt2017 {get;set;}
    public Decimal Verkauf2016 {get;set;}
    public Decimal Ziel2017 {get;set;}
    public Decimal ExtrarabattEH2017 {get;set;}
    public Decimal Extrarabatt2017 {get;set;}
    public Decimal totalPrice2017 { get;set;}
    
    public Decimal MalusBeiRetoure { get;set;}
    public Decimal MalusTotal { get;set;}   
    public Decimal RetourePerCent { get;set;}
    public String MalusbeiRetourePercent { get;set;}
    public String minMalus { get;set;}
    public String maxMalus { get;set;}
    
    public Decimal V11 { get;set;}
    public Decimal Z12 { get;set;}
    public Decimal Marge { get;set;}
    
    public Decimal GesCornA { get;set;}
    public Decimal GesCornB { get;set;} 
    public Decimal GesCornT { get;set;}
        
    public Decimal AgreedCornA { get;set;} 
    public Decimal AgreedCornB { get;set;} 
    public Decimal AgreedCornT { get;set;} 
    
    public Decimal maxPercent { get;set;} 
    public Decimal minPercent { get;set;} 
    
    public Decimal PyPoGToT { get;set;}
    
    public Decimal Extrarabbat { get;set;}
    public Decimal Fruekauf { get;set;}
    public Decimal RabatMengen { get;set;}
    public Decimal MengeTax { get;set;}
    public Decimal aGesamt { get;set;}
    public Decimal gesamtRabatt { get;set;}

    public String getExcelDekalb (){return SystemSettings__c.getValues('DE_ExcelDekalb').Value__c;}
    public String getFruehkaufBis (){return SystemSettings__c.getValues('DE_MAIS_fruehkaufBis').Value__c;}
    public String getGrundMarge (){return SystemSettings__c.getValues('DE_MAIS_GrundMarge').Value__c;}
    
    public Integer QuantityClement { get;set;}
    public Decimal totalClemente { get;set;}
    
    public Decimal taxPerEH { get;set;}
    public Decimal totalGrundMarge { get;set;}
    public Decimal totalPrice { get;set;}

    public string xmlContent {get;set;}
    public string Alpha {get;set;}
    public string Omega {get;set;}

    private ApexPages.StandardController controller;
    
    public void initialize ()
    {
         SortenRabatt =0;
         MalusbeiRetoure =0;
         SortenRabatt2017=0;
         Verkauf2016=0;
         Ziel2017=0;
         ExtrarabattEH2017=0;
         Extrarabatt2017=0;
         totalPrice2017=0;
         
         V11 =0;
         Z12 =0;
         Marge =0;
         
         GesCornA =0;
         GesCornB =0;
         GesCornT=0;
         
         AgreedCornA =0;
         AgreedCornB =0;
         AgreedCornT =0;
    
         PyPoGToT =0;
         GesCornT =0;
         RetourePerCent =0;
         MalusBeiRetourePercent ='0';
         minMalus ='0';
         maxMalus ='0';
         
         SummeRabat=0;
         MalusTotal=0;
         
         maxPercent=0;
         minPercent=0;
                 
         RabatMengen=0;
         Fruekauf=0;
         Extrarabbat=0;        

         QuantityClement = 0;
         totalClemente=0;
         aGesamt=0;
         taxPerEH=0;
         gesamtRabatt=0;
         totalGrundMarge=0;
         totalPrice=0;
         
         Alpha='<!--';
         Omega='-->';
         
    }
    
    public ExcelExportCornReportcontroller(){
        this.controller = controller;

        premiumCorn = new Map<String,Map<String,String>>();
        standardCorn = new Map<String,Map<String,String>>();
        PYear= new Map<String,Map<String,String>>();

        OwnerID=Util.currentUser.ID;
        AccountID=Util.currentAccount.ID;
        DivisionID=Util.currentDivision.ID;
            
        xmlContent ='<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>ZVD</x:Name><x:WorksheetOptions><x:FitToPage/><x:Print><x:FitWidth>1</x:FitWidth><x:FitHeight>1</x:FitHeight><x:ValidPrinterInfo/><x:Scale>55</x:Scale><x:HorizontalResolution>600</x:HorizontalResolution><x:VerticalResolution>600</x:VerticalResolution></x:Print><x:Selected/><x:Panes><x:Pane><x:Number>3</x:Number><x:ActiveRow>22</x:ActiveRow><x:ActiveCol>9</x:ActiveCol></x:Pane></x:Panes><x:ProtectContents>False</x:ProtectContents><x:ProtectObjects>False</x:ProtectObjects><x:ProtectScenarios>False</x:ProtectScenarios></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets><x:WindowHeight>10005</x:WindowHeight><x:WindowWidth>10005</x:WindowWidth><x:WindowTopX>120</x:WindowTopX><x:WindowTopY>135</x:WindowTopY><x:ProtectStructure>False</x:ProtectStructure><x:ProtectWindows>False</x:ProtectWindows></x:ExcelWorkbook></xml>';
      
         /* Obtaining all parameters from the Custom label DE_MAIS2016_DISCOUNTS */
        List<String> discounts = (label.DE_MAIS2017_DISCOUNTS.replaceAll('(\\s+)', '')).split('#',0); 
        
        /*Obtaining the Nettosorten products that won't be used in the ZVD*/
        List<String> prodNotInZVD = label.DE_PRODUCTS_NOT_ZVD_2017.split('#',0);
              
        // date
        datetime myDateTime = datetime.now();
        datetime newDate = myDateTime .addYears(-1);
        string StartYearDate= String.valueof(newDate.year()) + '-' + String.valueof(newDate.month()) + '-' + String.valueof(newDate.day())+ ' ' + '00' + ':' + '00' + ':' + '00';
        string EndYearDate= String.valueof(newDate.year()) + '-' + String.valueof(newDate.month()) + '-' + String.valueof(newDate.day())+ ' ' + '00' + ':' + '00' + ':' + '00';
 
        // retoure
        List<Retoure__c> retoures = [ SELECT Account__c, Division__c, EximusRabat__c, Extrarabatt__c, FruekaufMenge__c, Clemente_Rabatt__c,
                                             FruekaufRabatt__c, RabattMenge__c, TXT_Bemerkung__c, NUM_MENGE_TAX__c, Id, Retoure2__c, Retoure1__c, 
                                             Retoure3__c, Vorlieferant2__r.Name, Vorlieferant1__r.Name, Vorlieferant3__r.Name, TXT_year__c 
                                             FROM Retoure__c WHERE ID=:Util.urlParameters.get('retoureId')];  
        
        if(retoures.size() > 0) Retoure = retoures.get(0);
        else Retoure = new Retoure__c(EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, 
                                      Retoure1__c = 0, Retoure3__c = 0, Clemente_Rabatt__c = 0);
        if(Retoure.Retoure1__c==null) Retoure.Retoure1__c=0;
        if(Retoure.Retoure2__c==null) Retoure.Retoure2__c=0;
        if(Retoure.Retoure3__c==null) Retoure.Retoure3__c=0;
        if(Retoure.FruekaufRabatt__c==null) Retoure.FruekaufRabatt__c=0;
        if(Retoure.RabattMenge__c==null) Retoure.RabattMenge__c=0;
        if(Retoure.NUM_MENGE_TAX__c==null) Retoure.NUM_MENGE_TAX__c=0;
        if(Retoure.FruekaufMenge__c==null) Retoure.FruekaufMenge__c=0;
        if(Retoure.Extrarabatt__c==null) Retoure.Extrarabatt__c=0;
        if(Retoure.Clemente_Rabatt__c==null) Retoure.Clemente_Rabatt__c=0;
        if(Retoure.TXT_Bemerkung__c==null) Retoure.TXT_Bemerkung__c='';
        if(Retoure.TXT_year__c==null) Retoure.TXT_year__c='';
        retoures.clear();
        retoures.add(Retoure);
        
        // user info
        UserInfo=[ SELECT Name, Phone,MobilePhone FROM User WHERE ID=:OwnerID];
        // account info 
        AccountInfo=[ SELECT Client_Code__c, Name, DE_ZIP_PLZ__c, City__c, DE_Ansprechpartner__r.Name, FR_PRIMARY_CONTACT__r.Name, DE_CustomerCornSeeds__c, DE_POGCornPY__c  
                      FROM Account WHERE ID=:AccountID];
                      
        initialize();
        // PY Summary 
        for(AggregateResult a0 : [ SELECT ProductRef__r.Name, max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID,max(LKP_DistributorRefST__r.Name) Distributor, sum(Agreed__c) Agreed , sum(POG__c) PoG, max(CampaignRef__r.YearV2__r.YearStartDate__c), max(CampaignRef__r.YearV2__r.YearEndDate__c) FROM CampaignLineItem__c 
                                   WHERE (FarmRef__r.ID=:AccountID) AND ( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                                   AND CampaignRef__r.StatusCode__c=300 AND (CampaignRef__r.DivisionRef__c=:DivisionID)
                                   AND ProductRef__r.Name NOT IN :prodNotInZVD AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null)) GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                                        
            if(PYear.get(a0.get('Name') + '_' + a0.get('ID') ) == null)
                PYear.put(a0.get('Name') + '_' + a0.get('ID'),new Map<String,String>{'Agreed'=> '0', 'PoG' => '0'});
            
            if(integer.valueOf(a0.get('Agreed'))!= null)
                PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Agreed',String.valueOf(integer.valueOf(a0.get('Agreed'))));
            
            if(integer.valueOf(a0.get('PoG'))!= null){
                PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('PoG',String.valueOf(integer.valueOf(a0.get('PoG')))); 
                PyPoGToT=PyPoGTot+integer.valueOf(a0.get('PoG')); 
            }    
            PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Name',String.valueOf(a0.get('ProductDisplayName')));
        }
        //premium and Thiram
        for(AggregateResult ag : [SELECT ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName,  LKP_DistributorRefST__r.ID, max(ProductRef__r.DE_FAO_2__c) FAO2,sum(Agreed__c) Agreed , sum(POG__c) POG, max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductMaturity__c) FAO FROM CampaignLineItem__c
        						  WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
        						  AND (DE_isPremium__c = true) AND (ProductRef__r.ProductTreatment__c='Thiram')
                                  AND (CampaignRef__r.DivisionRef__c=:DivisionID)
                                  AND ProductRef__r.Name NOT IN :prodNotInZVD AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null)) GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                                    
            if(premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID') ) == null)
                premiumCorn.put(ag.get('ProductDisplayName') + '_' + ag.get('ID'),new Map<String,String>{'AgreedStandard'=> '0', 'AgreedMesurol' => '0','PoGStandard'=> '0', 'PoGMesurol' => '0','FAO' => '','FAO2' => '','Distributor' => '','TotalAgreed' => '0','TotalPoG' => '0'});
                        
            if(integer.valueOf(ag.get('Agreed'))!= null){
                premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('AgreedStandard',String.valueOf(integer.valueOf(ag.get('Agreed'))));
                AgreedCornA = AgreedCornA + integer.valueOf(ag.get('Agreed'));
            }
            if(integer.valueOf(ag.get('PoG'))!= null) {
                premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('PoGStandard',String.valueOf(integer.valueOf(ag.get('POG'))));
                GesCornA = GesCornA + integer.valueOf(ag.get('POG'));
            }
            if(integer.valueOf(ag.get('FAO'))!= null)
                premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('FAO',String.valueOf(integer.valueOf(ag.get('FAO'))));
                
            if(integer.valueOf(ag.get('FAO2'))!= null)
                premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('FAO2',String.valueOf(integer.valueOf(ag.get('FAO2'))));        
                
            premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Name',String.valueOf(ag.get('ProductDisplayName')));
            
            if(String.valueOf(ag.get('Distributor'))!= null)
                premiumCorn.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Distributor',String.valueOf(ag.get('Distributor')));
        }
        //premium and Mesurol
        Integer ag1Agreed = 0;
        Integer ag1PoG = 0;
        for(AggregateResult ag1 : [ SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, 
                                            max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductMaturity__c) FAO, max(ProductRef__r.DE_FAO_2__c) FAO2,
                                            sum(Agreed__c) Agreed , sum(POG__c) POG
                                    FROM CampaignLineItem__c
                                    WHERE (CampaignRef__r.isActive=true) //(CampaignRef__r.Owner.ID=:OwnerID)
                                    AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (DE_isPremium__c = true) 
                                    AND ((ProductRef__r.ProductTreatment__c='Mesurol') OR (ProductRef__r.ProductTreatment__c='Sonido + Thiram') OR (ProductRef__r.ProductTreatment__c='Sonido + Maxim XL + Thiram')) AND (CampaignRef__r.DivisionRef__c=:DivisionID)
                                    AND ProductRef__r.Name NOT IN :prodNotInZVD
                                    AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                                    GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID
                                    ORDER BY ProductRef__r.Name]){
                                        
            if(premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID') ) == null) {
                premiumCorn.put(ag1.get('ProductDisplayName') + '_' + ag1.get('ID'),new Map<String,String>{'AgreedStandard'=> '0', 'AgreedMesurol' => '0','PoGStandard'=> '0', 'PoGMesurol' => '0','FAO' => '','FAO2' => '','Distributor' => '','TotalAgreed' => '0','TotalPoG' => '0'});
                ag1Agreed = 0;
                ag1PoG = 0;
            }
            if(premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID') ) != null) {
                if(premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).get('AgreedMesurol') == '0') ag1Agreed = 0;
                if(premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).get('PoGMesurol') == '0') ag1PoG = 0;
            }
            if(integer.valueOf(ag1.get('Agreed'))!= null){
                ag1Agreed = ag1Agreed + integer.valueOf(ag1.get('Agreed'));
                premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('AgreedMesurol',String.valueOf(ag1Agreed));
                AgreedCornA = AgreedCornA + integer.valueOf(ag1.get('Agreed'));
            }
            if(integer.valueOf(ag1.get('PoG'))!= null){
                ag1PoG = ag1PoG + integer.valueOf(ag1.get('PoG'));
                premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('PoGMesurol',String.valueOf(ag1PoG));
                GesCornA = GesCornA + integer.valueOf(ag1.get('POG'));
            }
            if(integer.valueOf(ag1.get('FAO'))!= null)
                premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('FAO',String.valueOf(integer.valueOf(ag1.get('FAO'))));
            
            if(integer.valueOf(ag1.get('FAO2'))!= null)
                premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('FAO2',String.valueOf(integer.valueOf(ag1.get('FAO2'))));

            premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Name',String.valueOf(ag1.get('ProductDisplayName')));
            
            if(String.valueOf(ag1.get('Distributor'))!= null)
                premiumCorn.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Distributor',String.valueOf(ag1.get('Distributor')));
        }        
        // Thiram and regular          
        for(AggregateResult ag2 : [  SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName,  
                                             max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductMaturity__c) FAO, 
                                             LKP_DistributorRefST__r.ID, max(ProductRef__r.DE_FAO_2__c) FAO2,sum(Agreed__c) Agreed , sum(POG__c) POG
                                     FROM CampaignLineItem__c
                                     WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) //(CampaignRef__r.Owner.ID=:OwnerID)
                                     AND( Type__c='Charged') AND (DE_isPremium__c = false) AND (ProductRef__r.ProductTreatment__c='Thiram')
                                     AND (CampaignRef__r.DivisionRef__c=:DivisionID)
                                     AND ProductRef__r.Name NOT IN :prodNotInZVD
                                    AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                                     GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                                        
            if(standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID') ) == null)
                standardCorn.put(ag2.get('ProductDisplayName') + '_' + ag2.get('ID'),new Map<String,String>{'AgreedStandard'=> '0', 'AgreedMesurol' => '0','PoGStandard'=> '0', 'PoGMesurol' => '0','FAO' => '','FAO2' => '','Distributor' => '','TotalAgreed' => '0','TotalPoG' => '0'});
            
            if(integer.valueOf(ag2.get('Agreed'))!= null) {
                standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('AgreedStandard',String.valueOf(integer.valueOf(ag2.get('Agreed'))));
                AgreedCornB= AgreedCornB + integer.valueOf(ag2.get('Agreed'));
            }
            if(integer.valueOf(ag2.get('PoG'))!= null) {
                standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('PoGStandard',String.valueOf(integer.valueOf(ag2.get('POG'))));
                GesCornB= GesCornB +integer.valueOf(ag2.get('POG'));
            }
            if(integer.valueOf(ag2.get('FAO'))!= null)
                standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('FAO',String.valueOf(integer.valueOf(ag2.get('FAO'))));
                
            if(integer.valueOf(ag2.get('FAO2'))!= null)
               standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('FAO2',String.valueOf(integer.valueOf(ag2.get('FAO2'))));

            standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Name',String.valueOf(ag2.get('ProductDisplayName')));
            
            if(String.valueOf(ag2.get('Distributor'))!= null)
            standardCorn.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Distributor',String.valueOf(ag2.get('Distributor')));
        }  
        //Regular and Mesurol
        Integer ag3Agreed = 0;
        Integer ag3PoG = 0;  
        for(AggregateResult ag3 : [ SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, 
                                            max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductMaturity__c) FAO, 
                                            max(ProductRef__r.DE_FAO_2__c) FAO2, sum(Agreed__c) Agreed , sum(POG__c) POG
                                    FROM CampaignLineItem__c
                                    WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                                    AND (DE_isPremium__c = false) AND ((ProductRef__r.ProductTreatment__c='Mesurol') OR (ProductRef__r.ProductTreatment__c='Sonido + Thiram') OR (ProductRef__r.ProductTreatment__c='Sonido + Maxim XL + Thiram')) AND (CampaignRef__r.DivisionRef__c=:DivisionID)
                                    AND ProductRef__r.Name NOT IN :prodNotInZVD
                                   AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                                    GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID
                                    ORDER BY ProductRef__r.Name]) {

            if(standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID') ) == null) {
                standardCorn.put(ag3.get('ProductDisplayName') + '_' + ag3.get('ID'),new Map<String,String>{'AgreedStandard'=> '0', 'AgreedMesurol' => '0','PoGStandard'=> '0', 'PoGMesurol' => '0','FAO' => '','FAO2' => '','Distributor' => '','TotalAgreed' => '0','TotalPoG' => '0'});
                ag3Agreed = 0;
                ag3PoG = 0;
            }
            if(standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID') ) != null) {
                if(standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).get('AgreedMesurol') == '0') ag3Agreed = 0;
                if(standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).get('PoGMesurol') == '0') ag3PoG = 0;
            }
            if(integer.valueOf(ag3.get('Agreed'))!= null){
                ag3Agreed = ag3Agreed + integer.valueOf(ag3.get('Agreed'));
                standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('AgreedMesurol',String.valueOf(ag3Agreed));
                AgreedCornB= AgreedCornB + integer.valueOf(ag3.get('Agreed'));              
            }
            if(integer.valueOf(ag3.get('PoG'))!= null){
                ag3PoG = ag3PoG + integer.valueOf(ag3.get('PoG'));
                standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('PoGMesurol',String.valueOf(ag3PoG));
                GesCornB= GesCornB +integer.valueOf(ag3.get('POG'));                
            }            
            if(integer.valueOf(ag3.get('FAO'))!= null)
                standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('FAO',String.valueOf(integer.valueOf(ag3.get('FAO'))));
                
            if(integer.valueOf(ag3.get('FAO2'))!= null)
                standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('FAO2',String.valueOf(integer.valueOf(ag3.get('FAO2'))));

            standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Name',String.valueOf(ag3.get('ProductDisplayName')));
            
            if(String.valueOf(ag3.get('Distributor'))!= null)   
                standardCorn.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Distributor',String.valueOf(ag3.get('Distributor')));
        }
        
         /* Total Agreed and Total PoG per Hybrid and Product type (Premium)*/
         for(String key: standardCorn.keySet()){
            Integer totAg = Integer.valueOf((standardCorn.get(key)).get('AgreedStandard'))+Integer.valueOf((standardCorn.get(key)).get('AgreedMesurol'));
            Integer totPoG = Integer.valueOf((standardCorn.get(key)).get('PoGStandard'))+Integer.valueOf((standardCorn.get(key)).get('PoGMesurol'));
            (standardCorn.get(key)).put('TotalAgreed',String.valueOf(totAg));
            (standardCorn.get(key)).put('TotalPoG',String.valueOf(totPoG));
         }
         for(String key: premiumCorn.keySet()){
            Integer totAg = Integer.valueOf((premiumCorn.get(key)).get('AgreedStandard'))+Integer.valueOf((premiumCorn.get(key)).get('AgreedMesurol'));
            Integer totPoG = Integer.valueOf((premiumCorn.get(key)).get('PoGStandard'))+Integer.valueOf((premiumCorn.get(key)).get('PoGMesurol'));
            (premiumCorn.get(key)).put('TotalAgreed',String.valueOf(totAg));
            (premiumCorn.get(key)).put('TotalPoG',String.valueOf(totPoG));
         }                
           
         if(AccountInfo.DE_CustomerCornSeeds__c=='MR'){   
            SortenRabatt=Decimal.valueOf(discounts.get(1));
            V11=Decimal.valueOf(discounts.get(13));
            Z12=Decimal.valueOf(discounts.get(7));
            SortenRabatt2017=Decimal.valueOf(4);
            Verkauf2016=1.5;
            Ziel2017=Decimal.valueOf(3);
            ExtrarabattEH2017=Decimal.valueOf(4);
        } else if (AccountInfo.DE_CustomerCornSeeds__c=='MR+'){   
            SortenRabatt=Decimal.valueOf(discounts.get(29));
            V11=Decimal.valueOf(discounts.get(33));
            Z12=Decimal.valueOf(discounts.get(31));
            SortenRabatt2017=Decimal.valueOf(4);
            Verkauf2016=1.5;
            Ziel2017=Decimal.valueOf(3);
            ExtrarabattEH2017=Decimal.valueOf(4);   
        } else if (AccountInfo.DE_CustomerCornSeeds__c=='A'){   
            SortenRabatt=Decimal.valueOf(discounts.get(3));
            V11=Decimal.valueOf(discounts.get(15));
            Z12=Decimal.valueOf(discounts.get(9));
            SortenRabatt2017=Decimal.valueOf(4);
            Verkauf2016=1.5;
            Ziel2017=Decimal.valueOf(3);
            ExtrarabattEH2017=Decimal.valueOf(2);
        } else if (AccountInfo.DE_CustomerCornSeeds__c=='B'){
            SortenRabatt=Decimal.valueOf(discounts.get(5));
            V11=Decimal.valueOf(discounts.get(17));
            Z12=Decimal.valueOf(discounts.get(11));
            SortenRabatt2017=2.5;
            Verkauf2016=Decimal.valueOf(1);
            Ziel2017=Decimal.valueOf(2);
            ExtrarabattEH2017=1.5;          
        } else {
            SortenRabatt=0;
            V11=0;
            Z12=0;
            SortenRabatt2017=0;
            Verkauf2016=0;
            Ziel2017=0;
            ExtrarabattEH2017=0;
        }

        for(Retoure__c rtr : retoures){
            MalusbeiRetoure=MalusbeiRetoure + (rtr.Retoure1__c);    
            MalusBeiRetoure=MalusBeiRetoure + (rtr.Retoure2__c);    
            MalusBeiRetoure=MalusBeiRetoure + (rtr.Retoure3__c);
            //2017 Extrarabatt calculation
            Extrarabatt2017 = ExtrarabattEH2017*rtr.RabattMenge__c; 
            if(rtr.Extrarabatt__c!=null && rtr.RabattMenge__c!=null)
                Extrarabbat=rtr.Extrarabatt__c*rtr.RabattMenge__c;
            if(rtr.FruekaufMenge__c!=null && rtr.FruekaufRabatt__c!=null)
                Fruekauf=rtr.FruekaufMenge__c*rtr.FruekaufRabatt__c;
            break;   
        }
                     
        GesCornT=GesCornA+GesCornB;
        AgreedCornT=AgreedCornA+AgreedCornB;
        //Z12 = AgreedCornT;
        
        if(MalusbeiRetoure > 0)
            RetourePerCent= ((MalusBeiRetoure*100)/(GesCornT+MalusBeiRetoure)).setScale(2,System.RoundingMode.HALF_UP);
        else 
            RetourePerCent=0;
            
        minMalus=discounts.get(21);
        maxMalus=discounts.get(23);    
        minPercent=Decimal.valueOf(discounts.get(25));
        maxPercent=Decimal.valueOf(discounts.get(27));
        if(RetourePerCent<=minPercent)
            MalusBeiRetourePercent='0';
        else if(RetourePerCent>minPercent && RetourePerCent<=maxPercent)
            MalusBeiRetourePercent=minMalus;
        else
            MalusBeiRetourePercent=maxMalus;
        
        if ((GesCornT)>=(AgreedCornT)) Marge=Ziel2017;
        else if ((GesCornT)>PyPoGToT) Marge=Verkauf2016;
        else Marge=0;    
        
        RabatMengen=(GesCornT)*Marge;
        SummeRabat=GesCornA*SortenRabatt;
        MalusTotal=(Retoure.Retoure1__c+Retoure.Retoure2__c+Retoure.Retoure3__c)*Decimal.valueof(MalusBeiRetourePercent)*-1;
        
        // CLEMENTE PRODUCTS
        for(AggregateResult ag4 : [ SELECT  sum(POG__c) POG
                                    FROM CampaignLineItem__c
                                    WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) //(CampaignRef__r.Owner.ID=:OwnerID)
                                    AND( Type__c='Charged') AND (ProductRef__r.Name Like '%CLEMENTE%')
                                    AND ProductRef__r.Name NOT IN :prodNotInZVD
                                    AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null)) ]) 
                                   {
                                        
            if(integer.valueOf(ag4.get('PoG'))!= null) QuantityClement= QuantityClement +integer.valueOf(ag4.get('POG'));          
        }
        
        aGesamt = GesCornA*SortenRabatt;
        if(QuantityClement !=null && QuantityClement >0 && Retoure.Clemente_Rabatt__c != null && Retoure.Clemente_Rabatt__c >0 ) 
            totalClemente = 0*QuantityClement*Retoure.Clemente_Rabatt__c; 
        else  
            totalClemente=0;
            
        // TAX
        taxPerEH=Decimal.valueOf(discounts.get(19));
        if(Retoure.NUM_MENGE_TAX__c != null || Retoure.NUM_MENGE_TAX__c > 0) 
            MengeTax = taxPerEH * Retoure.NUM_MENGE_TAX__c;
        System.Debug('TEST'+MengeTax + totalClemente + MalusTotal + Fruekauf + Extrarabbat + aGesamt);  
        gesamtRabatt= -MengeTax + totalClemente + MalusTotal + Fruekauf + Extrarabbat + RabatMengen +aGesamt;
        Decimal auxGM=0;
        if(getGrundMarge()!= null)
         auxGM=Decimal.valueOf(getGrundMarge());
        totalGrundMarge= auxGM*GesCornT;
        totalPrice= gesamtRabatt;

        //2017 change
        aGesamt = GesCornA*SortenRabatt2017;
        totalPrice2017=-MengeTax + Fruekauf + Extrarabatt2017 + RabatMengen +aGesamt;
    }
}