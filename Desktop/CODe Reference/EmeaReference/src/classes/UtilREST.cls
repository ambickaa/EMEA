public class UtilREST
{ 
    //Name of division Corn.
    public static final String DIVISION_CORN = 'Corn';
    
    //Name of division OSR
    public static final String DIVISION_OSR = 'OSR';
    
    //Name of division CP.
    public static final String DIVISION_CP = 'CP';
    
    //Name of division Latitude.
    public static final String DIVISION_LATITUDE = 'Latitude';
    
    //Name of division Latitude.
    public static final String DIVISION_MONFAST = 'Monfast';
    
    //Name of division Latitude.
    public static final String DIVISION_MONITOR = 'Monitor';
    
    //Name of division Latitude.
    public static final String DIVISION_ROUNDUP = 'Roundup';
    
    public static SET<CampaignLineItem__Share> currentUserCliShared 
    {    
        get
        {
            if( currentUserCliShared== null )
            {
                currentUserCliShared=new SET<CampaignLineItem__Share>();
                
                for(CampaignLineItem__Share clis: [
                                        SELECT AccessLevel,Id,IsDeleted,LastModifiedById,
                                            LastModifiedDate,ParentId,RowCause,UserOrGroupId 
                                        FROM CampaignLineItem__Share 
                                        WHERE UserOrGroupId=:Util.currentUser.Id
                                ] )
                {
                    currentUserCliShared.add(clis);
                }
            }
            return currentUserCliShared;
        }
        set;
    
    }    
    
    public static SET<CampaignLineItemGroup__Share> currentUserCliGroupShared 
    {    
        get
        {
            if( currentUserCliGroupShared == null )
            {
                currentUserCliGroupShared = new SET<CampaignLineItemGroup__Share>();
                
                for(CampaignLineItemGroup__Share clis: [
                                         SELECT AccessLevel,Id,IsDeleted,LastModifiedById,
                                                LastModifiedDate,ParentId,RowCause,UserOrGroupId
                                         FROM CampaignLineItemGroup__Share 
                                         WHERE UserOrGroupId=:Util.currentUser.Id                               ] )
                {
                    currentUserCliGroupShared.add(clis);
                }
            }
            return currentUserCliGroupShared;
        }
        set;
    }    

    public static SET<AccountShare> currentUserAccountShared 
    {    
        get
        {
            if( currentUserAccountShared== null )
            {
                currentUserAccountShared=new SET<AccountShare>();
                
                for(AccountShare acc: [
                                        SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,Id,IsDeleted,LastModifiedById,
                                            LastModifiedDate,OpportunityAccessLevel,RowCause,UserOrGroupId 
                                        FROM AccountShare 
                                        WHERE UserOrGroupId=:Util.currentUser.Id
                                ] )
                {
                    currentUserAccountShared.add(acc);
                }
            }
            return currentUserAccountShared;
        }
        set;
    
    }    

    public static SET<ID> currentUserAccountSharedIds 
    {    
        get
        {
            if( currentUserAccountSharedIds== null )
            {
                currentUserAccountSharedIds=new SET<ID>();
                
                for(AccountShare acc: [
                                        SELECT AccountId
                                        FROM AccountShare 
                                        WHERE UserOrGroupId=:Util.currentUser.Id AND AccountAccessLevel='Edit'
                                ] )
                {
                    currentUserAccountSharedIds.add(acc.AccountId);
                }
            }
            return currentUserAccountSharedIds;
        }
        set;
    
    }    


    
    public static ID OSRCurrentCampaign
    {
        get
        {
            if( OSRCurrentCampaign== null )
            {
               // OSRCurrentCampaign = '';
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_OSR 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    OSRCurrentCampaign=cpg.Id;
                }
            }

            return OSRCurrentCampaign;
        }
        set;
     }
     
     public static ID MonfastCurrentCampaign
    {
        get
        {
            if( MonfastCurrentCampaign== null )
            {
               // OSRCurrentCampaign = '';
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_MONFAST
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    MonfastCurrentCampaign=cpg.Id;
                }
            }

            return MonfastCurrentCampaign;
        }
        set;
     }
     
     public static ID MonitorCurrentCampaign
    {
        get
        {
            if( MonitorCurrentCampaign== null )
            {
               // OSRCurrentCampaign = '';
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_MONITOR 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    MonitorCurrentCampaign=cpg.Id;
                }
            }

            return MonitorCurrentCampaign;
        }
        set;
     }
     
     public static ID LatitudeCurrentCampaign
    {
        get
        {
            if( LatitudeCurrentCampaign== null )
            {
               // OSRCurrentCampaign = '';
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_LATITUDE 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    LatitudeCurrentCampaign=cpg.Id;
                }
            }

            return LatitudeCurrentCampaign;
        }
        set;
     }
     
     public static ID RoundupCurrentCampaign
    {
        get
        {
            if( RoundupCurrentCampaign== null )
            {
               // OSRCurrentCampaign = '';
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_ROUNDUP 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    RoundupCurrentCampaign=cpg.Id;
                }
            }

            return RoundupCurrentCampaign;
        }
        set;
     }
    public static ID CornCurrentCampaign
    {
        get
        {
            if( CornCurrentCampaign== null )
            {
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, SalesPCMRef__c 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_CORN 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    CornCurrentCampaign=cpg.Id;
                }
            }

            return CornCurrentCampaign;
        }
        set;
     }

   public static Year__c currentVoucherYear
    {
        get
        {
            if( currentVoucherYear== null )
            {
                for( Year__c y : [   SELECT ID, Name
                                      FROM Year__c 
                                      WHERE ID in (SELECT YearRef__c FROM VoucherCampaign__c WHERE isActive__c=true AND CountryRef__r.Name=:Util.currentUser.Country)                                     
                                      LIMIT 1
                ] )
                {
                    currentVoucherYear=y;
                }
            }

            return currentVoucherYear;
        }
        set;
     }


    public static ID currentYearRSA
    {
        get
        {
            if( currentYearRSA== null )
            {
                for( Year__c y : [   SELECT ID 
                                      FROM Year__c 
                                      WHERE CurrentYear_RSA__c=true                                   
                                      LIMIT 1
                ] )
                {
                    currentYearRSA=y.Id;
                }
            }

            return currentYearRSA;
        }
        set;
     }

   public static Year__c currentYearRSA2
    {
        get
        {
            if( currentYearRSA2== null )
            {
                for( Year__c y : [   SELECT ID, YearStartDate__c, YearEndDate__c, CurrentYear_RSA__c, YearPreviousYear__c, YearPreviousYear__r.YearPreviousYear__r.YearStartDate__c
                                      FROM Year__c 
                                      WHERE CurrentYear_RSA__c=true                                   
                                      LIMIT 1
                ] )
                {
                    currentYearRSA2=y;
                }
            }

            return currentYearRSA2;
        }
        set;
     }
    
    public static SET<ID> activeSalesCatalogs
    {
        get
        {
            if( activeSalesCatalogs == null )
            {
                activeSalesCatalogs = new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c ,
                                        CompetitorPCMRef__r.Name, SalesPCMRef__r.Name
                                      FROM Campaign WHERE StatusCode__c =200
                                      AND OwnerId =: Util.currentUser.Id
                                      
                ] )
                {
                    if(cpg.CompetitorPCMRef__c!=null && cpg.CompetitorPCMRef__r.name!=null && !cpg.CompetitorPCMRef__r.Name.contains('Marketing'))                 
                        activeSalesCatalogs.add(cpg.CompetitorPCMRef__c);
                    if(cpg.SalesPCMRef__c!=null && cpg.SalesPCMRef__r.name!=null && !cpg.SalesPCMRef__r.Name.contains('Marketing'))                                          
                        activeSalesCatalogs.add(cpg.SalesPCMRef__c);
                }
                for( SM_Campaign__c smcpg : [ SELECT  ID, Name, LKP_Catalog__c, LKP_Catalog__r.Name, LKP_Year__c, LKP_Country__c
                                      FROM SM_Campaign__c WHERE (LKP_Year__c = :Util.currentYear.Id or LKP_Year__c = :Util.currentYear.YearPreviousYear__r.id)
                                      AND LKP_Country__r.Name=:Util.currentUser.Country
                                      
                ] ) 
                {
                    if(smcpg.LKP_Catalog__c!=null && smcpg.LKP_Catalog__r.name!=null)                 
                        activeSalesCatalogs.add(smcpg.LKP_Catalog__c);
                }               
            }
            return activeSalesCatalogs;
        }
        set;
     }
     
     public static SET<ID> activeSalesCatalogs_CLI
    {
        get
        {
            if( activeSalesCatalogs_CLI == null )
            {
                activeSalesCatalogs_CLI = new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c ,
                                        CompetitorPCMRef__r.Name, SalesPCMRef__r.Name
                                      FROM Campaign WHERE StatusCode__c =200
                                      AND OwnerId =: Util.currentUser.Id
                                      
                ] )
                {
                    if(cpg.CompetitorPCMRef__c!=null && cpg.CompetitorPCMRef__r.name!=null && !cpg.CompetitorPCMRef__r.Name.contains('Marketing'))                 
                        activeSalesCatalogs_CLI.add(cpg.CompetitorPCMRef__c);
                    if(cpg.SalesPCMRef__c!=null && cpg.SalesPCMRef__r.name!=null && !cpg.SalesPCMRef__r.Name.contains('Marketing'))                                          
                        activeSalesCatalogs_CLI.add(cpg.SalesPCMRef__c);
                }
            }
            return activeSalesCatalogs_CLI;
        }
        set;
     }
     
     public static SET<ID> activeSalesCatalogsRSA
    {
        get
        {
            if( activeSalesCatalogsRSA == null )
            {
                activeSalesCatalogsRSA = new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c, TaxSalesPCMRef_RSA__c, trialPCMRef__c
                                      FROM Campaign WHERE StatusCode__c = 200
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    if(cpg.CompetitorPCMRef__c!= null)
                        activeSalesCatalogsRSA.add(cpg.CompetitorPCMRef__c);
                    if(cpg.TrialPCMRef__c!= null)
                        activeSalesCatalogsRSA.add(cpg.trialPCMRef__c);    
                    activeSalesCatalogsRSA.add(cpg.SalesPCMRef__c);
                    activeSalesCatalogsRSA.add(cpg.TaxSalesPCMRef_RSA__c);                    
                }
                for( SM_Campaign__c smcpg : [ SELECT  ID, Name, LKP_Catalog__c, LKP_Catalog__r.Name, LKP_Year__c, LKP_Country__c
                                      FROM SM_Campaign__c WHERE (LKP_Year__c = :Util.currentYear.Id or LKP_Year__c = :Util.currentYear.YearPreviousYear__r.id)
                                      AND LKP_Country__r.Name=:Util.currentUser.Country
                                      
                ] ) 
                {
                    if(smcpg.LKP_Catalog__c!=null && smcpg.LKP_Catalog__r.name!=null)                 
                        activeSalesCatalogsRSA.add(smcpg.LKP_Catalog__c);
                }
                 
            }
            return activeSalesCatalogsRSA;
        }
        set;
     }
     
    public static SET<ID> activeSalesCatalogsRSA_CLI
    {
        get
        {
            if( activeSalesCatalogsRSA_CLI == null )
            {
                activeSalesCatalogsRSA_CLI = new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c, TaxSalesPCMRef_RSA__c, trialPCMRef__c
                                      FROM Campaign WHERE StatusCode__c = 200
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    if(cpg.CompetitorPCMRef__c!= null)
                        activeSalesCatalogsRSA_CLI.add(cpg.CompetitorPCMRef__c);
                    if(cpg.TrialPCMRef__c!= null)
                        activeSalesCatalogsRSA_CLI.add(cpg.trialPCMRef__c);    
                    activeSalesCatalogsRSA_CLI.add(cpg.SalesPCMRef__c);
                    activeSalesCatalogsRSA_CLI.add(cpg.TaxSalesPCMRef_RSA__c);                    
                }
                 
            }
            return activeSalesCatalogsRSA_CLI;
        }
        set;
     }
 
 public static SET<ID> activeRegularCatalogRSA
    {
        get
        {
            if( activeRegularCatalogRSA== null )
            {
                activeRegularCatalogRSA= new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c, TaxSalesPCMRef_RSA__c
                                      FROM Campaign WHERE StatusCode__c=200
                                      AND CountryRef__r.Name='South Africa'
                                      LIMIT 1
                ] )
                {
                    activeRegularCatalogRSA.add(cpg.SalesPCMRef__c);

                }
            }

            return activeRegularCatalogRSA;
        }
        set;
     }   
         
 public static SET<ID> activeTaxCatalogRSA
    {
        get
        {
            if( activeTaxCatalogRSA== null )
            {
                activeTaxCatalogRSA= new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c, TaxSalesPCMRef_RSA__c
                                      FROM Campaign WHERE StatusCode__c=200
                                      AND CountryRef__r.Name='South Africa'
                                      LIMIT 1
                ] )
                {
                    activeTaxCatalogRSA.add(cpg.TaxSalesPCMRef_RSA__c);

                }
            }

            return activeTaxCatalogRSA;
        }
        set;
     }
     
    public static SET<ID> activeTrialCatalogs
    {
        get
        {
            if( activeTrialCatalogs == null )
            {
                activeTrialCatalogs= new SET<ID>();
                
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, TrialPCMRef__c ,
                                    TrialPCMRef__r.Name, CompetitorPCMRef__r.Name, SalesPCMRef__r.Name
                                      FROM Campaign WHERE StatusCode__c=200
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    if(cpg.CompetitorPCMRef__c!=null && cpg.CompetitorPCMRef__r.name!=null && !cpg.CompetitorPCMRef__r.Name.contains('Marketing'))                 
                        activeTrialCatalogs.add(cpg.CompetitorPCMRef__c);
                    if(cpg.TrialPCMRef__r!=null && cpg.TrialPCMRef__r.name!=null && !cpg.TrialPCMRef__r.Name.contains('Marketing'))                                          
                        activeTrialCatalogs.add(cpg.TrialPCMRef__c);
                }
            }

            return activeTrialCatalogs;
        }
        set;
     }
    
    public static SET<ID> activeCatalogsAll
    {
        get
        {
            if( activeCatalogsAll == null )
            {
                activeCatalogsAll= new SET<ID>();
                
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, TrialPCMRef__c ,
                                    TrialPCMRef__r.Name, CompetitorPCMRef__r.Name,SalesPCMRef__r.Name,SalesPCMRef__c
                                      FROM Campaign WHERE StatusCode__c=200
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    if(!cpg.CompetitorPCMRef__r.Name.contains('Marketing'))                                 
                        activeCatalogsAll.add(cpg.CompetitorPCMRef__c);
                    if(!cpg.TrialPCMRef__r.Name.contains('Marketing'))                                                          
                        activeCatalogsAll.add(cpg.TrialPCMRef__c);
                    if(cpg.SalesPCMRef__c!=null && cpg.SalesPCMRef__r.Name !=null && !cpg.SalesPCMRef__r.Name.contains('Marketing'))                                          
                        activeSalesCatalogs.add(cpg.SalesPCMRef__c);
                        
                }
            }

            return activeCatalogsAll;
        }
        set;
     }

    
     public static Campaign currentCampaignRSA
    {
        get
        {
            if( currentCampaignRSA== null )
            {              
                for( Campaign cpg : [ SELECT ID, Name, StartDate, EndDate, CompetitorPCMRef__c, SalesPCMRef__c, TaxSalesPCMRef_RSA__c
                 
                                      FROM Campaign 
                                      WHERE StatusCode__c=200 
                                      AND DivisionRef__r.Name=:DIVISION_CORN 
                                      AND OwnerId=:Util.currentUser.Id
                                      LIMIT 1
                ] )
                {
                    currentCampaignRSA=cpg;
                }
            }

            return currentCampaignRSA;
        }
        set;
     }
  
    public static SET<ID> previousYearCatalogs
    {
        get
        {
            if( previousYearCatalogs== null )
            {
                previousYearCatalogs= new SET<ID>();
                for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c , TaxSalesPCMRef_RSA__c
                                      FROM Campaign WHERE StatusCode__c=300
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    previousYearCatalogs.add(cpg.CompetitorPCMRef__c);
                    previousYearCatalogs.add(cpg.SalesPCMRef__c);
                    previousYearCatalogs.add(cpg.TaxSalesPCMRef_RSA__c);
                    
                }
            } 

            return previousYearCatalogs;
        }
        set;
     }
     
    
    public static SET<ID> currentAndLastYearCampaignRSA
    {
        get
        {
            if( currentAndLastYearCampaignRSA == null )
            {
                currentAndLastYearCampaignRSA= new SET<ID>();
                
                for( Campaign cpg : [ SELECT ID, Name, CompetitorPCMRef__c, TrialPCMRef__c 
                                      FROM Campaign WHERE ( StatusCode__c=200 OR StatusCode__c=300)
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    currentAndLastYearCampaignRSA.add(cpg.id);
                }
            }

            return currentAndLastYearCampaignRSA;
        }
        set;
     }  
 
 
     
    public static SET<ID> activeCampaigns
    {
        get
        {
            if( activeCampaigns == null )
            {
                activeCampaigns= new SET<ID>();
                
                for( Campaign cpg : [ SELECT ID, Name, YearV2__c , DivisionRef__c , CompetitorPCMRef__c, TrialPCMRef__c 
                                      FROM Campaign WHERE StatusCode__c=200
                                      AND OwnerId=:Util.currentUser.Id
                ] )
                {
                    activeCampaigns.add(cpg.id);
                }
            }

            return activeCampaigns;
        }
        set;
     }  
    
    public static SET<ID> ValidPro
    {
        get
        {
            if( ValidPro == null )
            {
                ValidPro= new SET<ID>();
                
                for(ProductCatalogEntry__c pce : [ SELECT ID, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c in:activeTrialCatalogs or ProductCatalogRef__c in:activeSalesCatalogs ])
                {
                    ValidPro.add(pce.ProductRef__c);
                }
            }

            return ValidPro;
        }
        set;
     }  

    public static SET<ID> VoucherCampaigns
    {
        get
        {
            if( VoucherCampaigns == null )
            {
                VoucherCampaigns = new SET<ID>();
                
                for(VoucherCampaign__c vc : [ SELECT ID FROM VoucherCampaign__c WHERE isActive__c=true AND CountryRef__r.Name=:Util.currentUser.Country])
                {
                    VoucherCampaigns.add(vc.id);
                }
            }

            return VoucherCampaigns ;
        }
        set; 
     }  
 
    public static Boolean VoucherEnabled
    {
        get
        {
            if( VoucherEnabled == null )
            {
                VoucherEnabled = false;
                                
                for(VoucherCampaign__c vc : [ SELECT ID FROM VoucherCampaign__c WHERE isActive__c=true AND CountryRef__c=:Util.currentAccount.CountryRef__c LIMIT 1])
                {
                    VoucherEnabled = true;
                }
            }

            return VoucherEnabled ;
        }
        set; 
    }
 
    public static DateTime resetTimestamp(DateTime ts)
    {

            if(SystemSettings__c.getValues('EAST_RESET').Value__c!=null)
            {
                String resetDateCs =SystemSettings__c.getValues('EAST_RESET').Value__c;
                if(resetDateCs.equalsIgnoreCase('true') && SystemSettings__c.getValues('EAST_RESET_DATE').Value__c!=null)
                {
                    String resetDate = SystemSettings__c.getValues('EAST_RESET_DATE').Value__c;
                    
                    if(ts<DateTime.valueOf(resetDate))
                    {
                        ts=DateTime.newInstance(0);                         
                    }
                    
                }
                
            }
            return ts ;
       
     }  
 
 
   
    public static void sendStockMail(Order__c orderWoStock, List<CampaignLineItem__c> cliWoStock, Boolean isRegular, Boolean threshold, List<Stock__c> stk){
        
 
        String body='';
        String header='';
        if(threshold)
        {
            header=System.Label.RSA_THRESHOLD_MAIL_HEADER;          
            body=System.Label.RSA_THRESHOLD_MAIL;
        }else       
        {
            header=System.Label.RSA_STOCK_MAIL_HEADER;          
            body=System.Label.RSA_STOCK_MAIL;
        }
        String products='';
        
        products='<table style=" text-align:center;" ><tr><td style="background:#67DC25;  width:240px; font-weight:bold;  color:white; ">Product</td><td  style="background:#67DC25;   width:180px; font-weight:bold; color:white; ">Stock Left</td><td style="background:#67DC25;  width:180px; font-weight:bold;color:white;">Stock Requested</td></tr>';
        
        if(threshold)
        {   
            if(isRegular)
                for(CampaignLineItem__c cli: cliWoStock) 
                {
                    products=products+'<tr><td>' + cli.GlobalStock_RSA__r.HybridRef__r.Name + '</td><td>'+  cli.GlobalStock_RSA__r.HybridRef__r.StockLeft__c + '</td><td>'+ cli.POG__c +'</td></tr>';
                }
            else
                for(CampaignLineItem__c cli: cliWoStock)
                {
                    products=products+'<tr><td>' + cli.GlobalStock_RSA__r.HybridRef__r.Name + '</td><td>'+  cli.GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c + '</td><td>'+ cli.POG__c +'</td></tr>';
                }    
        }
        else
        {
            Map<ID,Integer> pcePoG = new Map<Id, Integer>();  // PCE / POG
            for(CampaignLineItem__c cli: cliWoStock)
            {
                pcePoG.put(cli.ProductCatalogEntryRef__c,Integer.valueof(cli.Pog__c));
            }
            if(isRegular)
                for(Stock__c st: stk)
                {   
                    if(st.HybridRef__r.StockLeft__c <pcePoG.get(st.ProductCatalogEntryRef_RSA__c))
                    products=products+'<tr><td>' + st.ProductName_RSA__c + '</td><td>'+  st.HybridRef__r.StockLeft__c + '</td><td>'+ pcePoG.get(st.ProductCatalogEntryRef_RSA__c) +'</td></tr>';
                }
            else
                for(Stock__c st: stk)
                {
                    if(st.HybridRef__r.TaxStockLeft__c <pcePoG.get(st.ProductCatalogEntryRef_RSA__c)    )               
                    products=products+'<tr><td>' + st.ProductName_RSA__c + '</td><td>'+  st.HybridRef__r.TaxStockLeft__c + '</td><td>'+ pcePoG.get(st.ProductCatalogEntryRef_RSA__c) +'</td></tr>';
                }
            
        } 
                
        products=products+'</table>';
        
            
        //if(isRegular)
            body=body.replace('[Manager]',Util.currentUser.Manager.Name);
        /*else          
            body=body.replace('[Manager]',Util.currentUser.Manager.Manager.Name);*/
            
        body=body.replace('[Sales Rep]', Util.currentUser.Name);
        body=body.replace('[Products]',products);
        
        List<Order__c> oList = new List<Order__C>();
        oList.add(orderWoStock);
        Map<Id,User> uMap = new Map<Id,User>(); 
        uMap.put(Util.currentUser.Id,Util.currentUser); 
        Map<Id,String> mailMap = getAdditionalMails(oList,uMap);
        
    
        String CcMails = '';
        if(mailMap.get(orderWoStock.Id)!=null)
            CcMails = mailMap.get(orderWoStock.Id);

        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        
        Integer counter=0;
              
     
        emails[counter++]=sendToMail(Util.currentUser.EMail,Util.currentUser.Manager.EMail+':'+CcMails, body,header);
       
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
        }
        catch(Exception e) {
            }
    }
 
    public static map<id,string> getAdditionalMails(list<Order__c>involvedOrders, map<ID, User> usersInfo){
        map<Id,String> returned = new map<Id,String>();
        map<String,String> mailsByRegion = new map<String,String>();
        //inform mailsByRegion
        for(String region : Label.RSA_FINAL_ORDER_STOCK_MAILS.replace('\n','').replace('\r','').split(';')) {
            if (region.split('#').size() == 2)
                mailsByRegion.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
            else
                system.debug('Wrong config for RSA additional mails for Final Orders: '+region);
        }
        
        
        for (Order__c o:involvedOrders){
            if (o.recordTypeId == Util.recordType.get('Order__c:FinalOrder') &&
            usersInfo.get(Util.currentUser.id).UserRole.Name.split(' - RSA - ').size() == 2) {
                String region = usersInfo.get(Util.currentUser.id).UserRole.Name.split(' - RSA - ')[1];
                returned.put(o.Id,mailsByRegion.get(region));
            }
        }
        return returned;
    } 
 
    
    private static Messaging.SingleEmailMessage sendToMail(String paramReplyTo, String paramTo, String body, String header){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
  
        email.setTargetObjectId(Util.currentUser.Id);
        
        email.setSubject(header);
        email.setToAddresses ( ((paramTo != null && paramTo != '')?paramTo:'').split(':'));

        email.setHtmlBody(body);       
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('RSA_ORDER_ORG_MAILER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        email.setSaveAsActivity(false);

        return email;
    }
    
    
 public static void BudgetUpdater (List<Id> products, List<id> userId)
 {  
        Map<String,Map<String,Integer>> Sales= new Map<String,Map<String,Integer>>();
        Map<String,Map<String,Integer>> Confirmed= new Map<String,Map<String,Integer>>();       
        List<Budget__c> BudgetToUpdate = new List<Budget__c> ();
        List<Budget__c> BudgetList = new List<Budget__c>();
        List<ID> SalesRepToQuery = new List<ID> ();
        List<ID> PCEtoQuery = new List<ID>();
            
        
        for(Budget__c b : [SELECT Id, ProductRef__c,SalesApril__c,SalesAugust__c,SalesDecember__c,SalesFebruary__c, SalesJanuary__c,SalesJuly__c,
        SalesJune__c,SalesMarch__c,SalesMay__c,SalesNovember__c,SalesOctober__c,SalesRep__c,SalesSeptember__c,YearRef__r.Name,
        AgreedApril__c,AgreedAugust__c,AgreedDecember__c,AgreedFebruary__c,AgreedJanuary__c,AgreedJuly__c,AgreedJune__c,AgreedMarch__c,AgreedMay__c,
        AgreedNovember__c,AgreedOctober__c,AgreedSeptember__c 
         FROM Budget__c
        WHERE ProductRef__c in:products AND SalesRep__c in:userId])
        {
                
                    PCEtoQuery.add(b.ProductRef__c);
                    SalesRepToQuery.add(b.SalesRep__c);
                    Sales.put((String)b.SalesRep__c+'_'+(String)b.ProductRef__c +'_'+(String)b.YearRef__r.Name,
                        new Map<String,Integer>{'Jan'=> 0, 'Feb' => 0,'Mar'=> 0, 'Apr' => 0, 'May' => 0,'Jun' => 0,
                                            'Jul' => 0,'Aug' =>0,'Sep'=>0,'Oct'=>0,'Nov'=>0,'Dec'=>0});    
                    Confirmed.put((String)b.SalesRep__c+'_'+(String)b.ProductRef__c +'_'+(String)b.YearRef__r.Name,
                        new Map<String,Integer>{'Jan'=> 0, 'Feb' => 0,'Mar'=> 0, 'Apr' => 0, 'May' => 0,'Jun' => 0,
                                            'Jul' => 0,'Aug' =>0,'Sep'=>0,'Oct'=>0,'Nov'=>0,'Dec'=>0});   
                    
                    
                    BudgetList.add(b);
        }
            
        Sales=SalesMap(Sales,PCEtoQuery,SalesRepToQuery);
        Confirmed=ConfirmedMap(Confirmed,PCEtoQuery,SalesRepToQuery);
                
            for(Budget__c b: BudgetList)
            {
                    if(b.ProductRef__c!=null && b.SalesRep__c!=null && b.YearRef__r.Name!=null)
                    {   
                        b=assignConfirmed(b,Confirmed); 
                        b=assignSales(b,Sales);
                                                
                        BudgetToUpdate.add(b);  
                    }     
            }  
            update BudgetToUpdate;   
 }    
    
private static Budget__c assignSales (Budget__c budget, Map<String,Map<String,Integer>> SalesMap)
{
    Budget__c bu=budget;
    
    bu.SalesJanuary__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jan');
    bu.SalesFebruary__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Feb');
    bu.SalesMarch__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Mar');
    bu.SalesApril__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Apr');
                        
    bu.SalesMay__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('May');
    bu.SalesJune__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jun');
    bu.SalesJuly__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jul');
    bu.SalesAugust__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Aug');
                        
    bu.SalesSeptember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Sep');
    bu.SalesOctober__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Oct');
    bu.SalesNovember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Nov');
    bu.SalesDecember__c=SalesMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Dec');
    
    return bu;
} 

private static Budget__c assignConfirmed (Budget__c budget, Map<String,Map<String,Integer>> ConfirmedMap)
{
    Budget__c bu=budget;
    
    bu.AgreedJanuary__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jan');
    bu.AgreedFebruary__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Feb');
    bu.AgreedMarch__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Mar');
    bu.AgreedApril__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Apr');
                        
    bu.AgreedMay__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('May');
    bu.AgreedJune__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jun');
    bu.AgreedJuly__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Jul');
    bu.AgreedAugust__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Aug');
                        
    bu.AgreedSeptember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Sep');
    bu.AgreedOctober__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Oct');
    bu.AgreedNovember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Nov');
    bu.AgreedDecember__c=ConfirmedMap.get(bu.SalesRep__c+'_'+bu.ProductRef__c+'_'+bu.YearRef__r.Name).get('Dec');
    
    return bu;
}


private static Map<String,Map<String,Integer>> ConfirmedMap (Map<String,Map<String,Integer>> ConfirmedMap, List<ID> PCE, List<ID> SalesRep)
{
            for(AggregateResult a0 : [
                      SELECT sum(Agreed__c) Agreed, ProductRef__c PCE, OwnerId OwnerCLI, CALENDAR_MONTH(CreatedDate) M,CALENDAR_YEAR(CreatedDate) Y
                      FROM CampaignLineItem__c WHERE PreliminaryOrderRef_RSA__r.Status_RSA__c='Closed' AND PreliminaryOrderRef_RSA__r.Signed_RSA__c=true
                            AND ProductRef__c in:PCE  AND OwnerId in: SalesRep
                      GROUP BY ProductRef__c, OwnerId, CALENDAR_MONTH(CreatedDate),CALENDAR_YEAR(CreatedDate) 
    
                                        ])
            {           
            if(a0.get('Agreed')!=null && ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y')))!=null  )
            {   if(a0.get('M')==1)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jan',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==2)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Feb',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==3)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Mar',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==4)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Abr',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==5)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('May',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==6)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jun',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==7)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jul',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==8)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Aug',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==9)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Sep',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==10)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Oct',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==11)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Nov',Integer.valueof(a0.get('Agreed')));
                if(a0.get('M')==12)
                    ConfirmedMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Dec',Integer.valueof(a0.get('Agreed')));
            }
                
                }
                return ConfirmedMap;
}


private static Map<String,Map<String,Integer>> SalesMap (Map<String,Map<String,Integer>> SalesMap, List<ID> PCE, List<ID> SalesRep)
{
            for(AggregateResult a0 : [
                      SELECT sum(PoG__c) PoG, ProductRef__c PCE, OwnerId OwnerCLI, CALENDAR_MONTH(CreatedDate) M,CALENDAR_YEAR(CreatedDate) Y
                      FROM CampaignLineItem__c WHERE (FinalOrderRef_RSA__r.Status_RSA__c='Closed' OR FinalOrderRef_RSA__r.Status_RSA__c='Approved')
                            AND FinalOrderRef_RSA__r.Signed_RSA__c=true AND ProductRef__c in:PCE  AND OwnerId in: SalesRep
                      GROUP BY ProductRef__c, OwnerId, CALENDAR_MONTH(CreatedDate),CALENDAR_YEAR(CreatedDate) 
    
                                        ])
            {           
            if(a0.get('PoG')!=null && SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y')))!=null  )
            {   if(a0.get('M')==1)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jan',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==2)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Feb',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==3)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Mar',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==4)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Abr',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==5)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('May',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==6)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jun',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==7)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Jul',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==8)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Aug',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==9)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Sep',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==10)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Oct',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==11)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Nov',Integer.valueof(a0.get('PoG')));
                if(a0.get('M')==12)
                    SalesMap.get((String)a0.get('OwnerCLI')+'_'+(String)a0.get('PCE')+'_'+String.valueof(a0.get('Y'))).put('Dec',Integer.valueof(a0.get('PoG')));
            }
                
            }
          return SalesMap;
}    
    

public static Boolean hasAdminPermissionsRSA    {
        get
        {
            if( hasAdminPermissionsRSA == null )
            {
                hasAdminPermissionsRSA = false;
                
                if(Util.currentUser.Profile.Name.equalsIgnoreCase('System Administrator') || Util.currentUser.Profile.Name.equalsIgnoreCase('RSA_CRM_Responsible'))
                    hasAdminPermissionsRSA = true; 
            }

            return hasAdminPermissionsRSA ;
        }
        set; 
}  

public static Boolean isRegionalManagerRSA    {
        get
        {
            if( isRegionalManagerRSA == null )
            {
                isRegionalManagerRSA = false;
                
                if(Util.currentUser.Profile.Name.equalsIgnoreCase('RSA Regional Manager'))
                    isRegionalManagerRSA = true; 
            }

            return isRegionalManagerRSA ;
        }
        set; 
}  





public static void sendConsignmentMail(Map<Id,Consignment__c> consToSend){
    
    
   // Builds a map with Hybrid Name and related consignment lines.      
   Map<String, Map<ID, Consignment__c>> HybCons= new Map<String, Map<ID, Consignment__c>>();
   
    for(ID iter: consToSend.keyset())
    {
        if (HybCons.get(consToSend.get(iter).GlobalStockRef__r.HybridRef__r.Name)==null)
        {
            HybCons.put(consToSend.get(iter).GlobalStockRef__r.HybridRef__r.Name, new Map<ID,Consignment__c>());
            HybCons.get(consToSend.get(iter).GlobalStockRef__r.HybridRef__r.Name).put(iter,consToSend.get(iter));
        }
        else
        {
            HybCons.get(consToSend.get(iter).GlobalStockRef__r.HybridRef__r.Name).put(iter,consToSend.get(iter));   
        }
    }
    
    //Sum the total consignment requested quantities by hybrid
    
    Map<Id,Integer> totalRequested = new Map<Id,Integer>();
    
    for(Consignment__c cns: consToSend.values())
    {
        if(totalRequested.get(cns.GlobalStockRef__r.HybridRef__c)==null)
            totalRequested.put(cns.GlobalStockRef__r.HybridRef__c, (Integer)cns.Requested__c);
        else
        {
            Integer sum = (Integer)cns.Requested__c + totalRequested.get(cns.GlobalStockRef__r.HybridRef__c);
            totalRequested.put(cns.GlobalStockRef__r.HybridRef__c, sum);    
        }       
    }
    
    
    String body='';
    String header='';
    String colorHeadTable='';
    String colorHeadHybrid='';
                
    header=System.Label.RSA_CONSIGNMENT_MAIL_HEADER;                      
    body=System.Label.RSA_CONSIGNMENT_MAIL;
    colorHeadTable=System.Label.RSA_COLOR_HEAD_TABLE;
    colorHeadHybrid=System.Label.RSA_COLOR_HEAD_HYBRID;
    
    String products='';
    String status='';
    products='<table style=" text-align:center;" ><tr><td style="background:'+colorHeadTable+';  width:240px; font-weight:bold;  color:white; ">Product</td><td  style="background:'+colorHeadTable+';   width:180px; font-weight:bold; color:white; ">Stock Left</td><td style="background:'+colorHeadTable+';  width:180px; font-weight:bold;color:white;">Consignment Requested</td><td style="background:'+colorHeadTable+';  width:240px; font-weight:bold;  color:white; ">Status</td></tr>';
   
    
    Consignment__c firstCons = new Consignment__c();
    
    for(String hybName: HybCons.keyset())
    {
        firstCons=HybCons.get(hybName).values()[0];
        products=products+'<tr><td style="background:'+colorHeadHybrid+'">' +hybName+ '</td><td style="background:'+colorHeadHybrid+'">'+ 'Total: ' + firstCons.GlobalStockRef__r.HybridRef__r.Stockleft__c + '</td><td style="background:'+colorHeadHybrid+'">'+'Total: '+ totalRequested.get(firstCons.GlobalStockRef__r.HybridRef__c) /*totalRequested.get(con.consignment.ProductCatalogEntryRef__c)*/+ '</td><td style="background:'+colorHeadHybrid+'">' + ' ' +'</td></tr>';
                    
        for(id idCons: HybCons.get(hybName).keyset())
        {
            if(HybCons.get(hybName).get(idCons).Status__c=='Rejected')
                status='Pending';
            else status='Pending';  
            products=products+'<tr><td style="font-size:80% ">' + HybCons.get(hybName).get(idCons).ProductCatalogEntryRef__r.ProductRef__r.Name + '</td><td>'+ '  ' /*HybCons.get(hybName).get(idCons).GlobalStockRef__r.HybridRef__r.Stockleft__c*/ + '</td><td>'+ HybCons.get(hybName).get(idCons).Requested__c+ '</td><td>' +  status +'</td></tr>';
            
        }
    }
                                                   
    products=products+'</table>';                          
    body=body.replace('[Manager]',Util.currentUser.Manager.Name);
    body=body.replace('[Sales Rep]', Util.currentUser.Name);
    body=body.replace('[Products]',products);
    
    map<String,String> mailsByRegion = new map<String,String>();
        //inform mailsByRegion
    for(String region : Label.RSA_CONSIGNMENT_MAILS.replace('\n','').replace('\r','').split(';')) 
    {
        if (region.split('#').size() == 2)
            mailsByRegion.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
        else
            system.debug('Wrong config for RSA additional mails for Final Orders: '+region);
       }
        
      
       
    String region =Util.currentUser.UserRole.Name.split(' - RSA - ')[1];
    String CcMails='';
               
    if(mailsByRegion.get(region)!=null)
            CcMails = mailsByRegion.get(region);

    Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        
    Integer counter=0;
    emails[counter++]=sendToMail(Util.currentUser.EMail,Util.currentUser.Manager.EMail+':'+CcMails, body,header);
    
 
    try{
        Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
        }
    catch(Exception e)
    { }

}


public static void sendConsApprovetMail(List<Consignment__c> consToSend, Boolean isAccepted){
    
    
   // Builds a map with Hybrid Name and related consignment lines.      
   Map<Id, String> ConsProduct= new Map<ID, String>();
   Map<Id, Decimal> ConsStock = new Map<ID, Decimal>();
   Map<Id, Decimal> ConsPrice = new Map<ID, Decimal>();
   
   for(Consignment__c cons : [SELECT id, ProductCatalogEntryRef__r.ProductRef__r.Name,ProductCatalogEntryRef__r.Price__c,GlobalStockRef__r.HybridRef__r.Stockleft__c  FROM Consignment__c where ID IN :ConsToSend])
   {
    ConsProduct.put(cons.id, cons.productCatalogEntryRef__r.ProductRef__r.Name);
    ConsStock.put(cons.id, cons.GlobalStockRef__r.HybridRef__r.Stockleft__c);
	ConsPrice.put(cons.id, cons.ProductCatalogEntryRef__r.Price__c);
   }
   
  
    User SalesRepInfo = [SELECT Id, Name, email, Manager.Name, Manager.email from User where id=: consToSend[0].UserRef__c]; 
   
  
    String body='';
    String header='';
    String colorHeadTable='';
    String colorHeadHybrid='';
    
    String prodName='';
    String result='';
    String RSAConsignmentEmailAddress='';      
                
    header=System.Label.RSA_CONSIGNMENT_MAIL_HEADER;                      
    body=System.Label.RSA_CONSIGNMENT_APPROVE_MAIL;
    colorHeadTable=System.Label.RSA_COLOR_HEAD_TABLE;
    colorHeadHybrid=System.Label.RSA_COLOR_HEAD_HYBRID;
    RSAConsignmentEmailAddress=System.Label.RSA_CONSIGNMENT_EMAIL_ADDRESS;
    
    Decimal TotalPrice = 0.00;
    String TotalAmount = '';
    String products='';
    String status='';
    products='<table style=" text-align:center;" ><tr><td style="background:'+colorHeadTable+';  width:40%; font-weight:bold;  color:white; ">Product</td><td  style="background:'+colorHeadTable+';   width:180px; font-weight:bold; color:white; ">Stock Left</td><td style="background:'+colorHeadTable+';  width:180px; font-weight:bold;color:white;">Consignment Requested</td><td style="background:'+colorHeadTable+';   width:180px; font-weight:bold;  color:white; ">Price</td><td style="background:'+colorHeadTable+';  width:240px; font-weight:bold;  color:white; ">Status</td></tr>';
   	
    
    Consignment__c firstCons = new Consignment__c();
    
    for(Consignment__c consToPrint: ConsToSend)
    {
        firstCons=ConsToSend[0];
        prodName = consProduct.get(consToPrint.id);
        products=products+'<tr height="28px"><td style="background:'+colorHeadHybrid+'">' +prodName+ '</td><td style="background:'+colorHeadHybrid+'">'+ ConsStock.get(consToPrint.id) + '</td><td style="background:'+colorHeadHybrid+'">'+ consToPrint.requested__c /*totalRequested.get(con.consignment.ProductCatalogEntryRef__c)*/+ '</td><td style="background:'+colorHeadHybrid+'">' +ConsPrice.get(consToPrint.id)+ '</td><td style="background:'+colorHeadHybrid+'">' + consToPrint.status__c +'</td></tr>';
        TotalPrice += ConsPrice.get(consToPrint.id);
    }
    
    TotalAmount = String.valueOf(TotalPrice);
        
    if(isAccepted==true)
        result='accepted';
    else 
        result='rejected';
                                                   
    products=products+'</table>';
    body=body.replace('[Sales Rep]', SalesRepInfo.Name);
    body=body.replace('[Regional Manager]', SalesRepInfo.Manager.Name);
    body=body.replace('[Products]',products);
    body=body.replace('[isAccepted]', result);
    body=body.replace('[TotalPrice]',TotalAmount);
    
    Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        
    Integer counter=0;
    emails[counter++]=sendToMail(SalesRepInfo.Manager.EMail, salesRepInfo.email+':'+SalesRepInfo.Manager.EMail+':'+RSAConsignmentEmailAddress, body,header);
    
 
    try{
        Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
        }
    catch(Exception e)
    { }

}




    public static REST_SendLogicalEntityOrder stockErrorMessages(REST_SendLogicalEntityOrder paramInfo){
    /** Declaration of local variables **/
        Set<Integer> idConsignedOrders = new Set<Integer>();
        Set<Integer> idFSOrders = new Set<Integer>();
        Set<Integer> idOrders = new Set<Integer>();
        Set<Integer> idGOrders = new Set<Integer>();
        
        Set<Integer> involvedOrders = new Set<Integer>();
        Set<Integer> involvedOrdersWL = new Set<Integer>();
        Set<Integer> draftOrders = new Set<Integer>();
        
        Set<String> hybPK = new Set<String>(); // Set of campaignLineItems primary keys without Stock
        
        Set<String> pceWithoutStockR = new Set<String>();
        Set<String> pceWithoutStockFS = new Set<String>();
        Set<String> pceWithoutStockCon = new Set<String>();
        Set<String> pceWithoutStockG = new Set<String>();
        
        Map<id, Decimal> pcevsPoG = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGFS = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGCon = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGR = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGG = new Map<id, Decimal>();
                
        Map<String, Decimal> hybPKvsPoGFS = new Map<String, Decimal>();
        Map<String, Decimal> hybPKvsPoGCon = new Map<String, Decimal>();
        Map<String, Decimal> hybPKvsPoGR = new Map<String, Decimal>();
        Map<String, Decimal> hybPKvsPoGG = new Map<String, Decimal>();
        
        Map<id, Decimal> pcevsPoGFSH = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGConH = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGRH = new Map<id, Decimal>();
        Map<id, Decimal> pcevsPoGGH = new Map<id, Decimal>();   
                
        Map<id, String> pcevsHybPK = new Map<id, String>(); 
        Map<id, String> pcevsHybPKCon = new Map<id, String>();
         
        Map<String,Double> hybvsStock = new Map<String,Double>(); 
        Map<String,Double> hybvsStockCon = new Map<String,Double>(); 
        
        Map<id, Double> pcevsStock = new Map<id, Double>();
        Map<id, Double> pcevsStockCon = new Map<id, Double>();
        
        Map<id, String> productNames = new Map<id, String>();
        
        Map<String,Map<Decimal,Decimal>> mailRegular = new Map<String,Map<Decimal,Decimal>>();
        Map<String,Map<Decimal,Decimal>> mailFS = new Map<String,Map<Decimal,Decimal>>();
        Map<String,Map<Decimal,Decimal>> mailCon = new Map<String,Map<Decimal,Decimal>>();
        Map<String,Map<Decimal,Decimal>> mailG = new Map<String,Map<Decimal,Decimal>>();
        
    /** Looking for out of stock orders and sorting them by type **/
        Id finalOrderTypeId = Util.recordtype.get('Order__c:FinalOrder');
        for(REST_OrderObject roo : paramInfo.orders){
            if(roo.order.RecordTypeId==finalOrderTypeId && roo.order.Status_RSA__c!='Cancelled' && roo.order.Type_RSA__c=='Tax')
                idFSOrders.add(roo.order.idDevice__c.intValue());
            else if(roo.order.RecordTypeId==finalOrderTypeId && roo.order.Status_RSA__c!='Cancelled' && roo.order.Type_RSA__c=='General')
                idGOrders.add(roo.order.idDevice__c.intValue());
            else if(roo.order.RecordTypeId==finalOrderTypeId && roo.order.Status_RSA__c!='Cancelled' && roo.order.Consigned__c==true)
                idConsignedOrders.add(roo.order.idDevice__c.intValue());
            else if(roo.order.RecordTypeId==finalOrderTypeId && roo.order.Status_RSA__c!='Cancelled' && roo.order.Consigned__c==false)
                idOrders.add(roo.order.idDevice__c.intValue());
            if(roo.order.RecordTypeId==finalOrderTypeId && roo.order.Status_RSA__c=='Draft')
                draftOrders.add(roo.order.idDevice__c.intValue());  
        }
        
    /** Looking for their related CLIs and building a map pairing PCE with POG **/
        for (REST_CampaignLineItemObject rclio: paramInfo.campaignLineItems){
                if(idOrders.contains(rclio.FinalOrderIdDevice)){
                        pcevsPoGR.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, 0);                 
                }else if(idFSOrders.contains(rclio.FinalOrderIdDevice)){
                        pcevsPoGFS.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, 0);
                }else if(idGOrders.contains(rclio.FinalOrderIdDevice)){
                        pcevsPoGG.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, 0);
                }else if(idConsignedOrders.contains(rclio.FinalOrderIdDevice)){
                        pcevsPoGCon.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, 0);
                }   
        }

    /** Grouping the POG for PCEs in final Orders **/
        for (REST_CampaignLineItemObject rclio: paramInfo.campaignLineItems){
            if(!draftOrders.contains(rclio.FinalOrderIdDevice)){
                if(idOrders.contains(rclio.FinalOrderIdDevice)){
                    Decimal sum = rclio.campaignLineItem.POG__c + pcevsPoGR.get(rclio.campaignLineItem.ProductCatalogEntryRef__c);
                    pcevsPoGR.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, sum);   
                }else if(idFSOrders.contains(rclio.FinalOrderIdDevice)){
                    Decimal sum = rclio.campaignLineItem.POG__c + pcevsPoGFS.get(rclio.campaignLineItem.ProductCatalogEntryRef__c);
                    pcevsPoGFS.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, sum);
                }else if(idGOrders.contains(rclio.FinalOrderIdDevice)){
                    Decimal sum = rclio.campaignLineItem.POG__c + pcevsPoGG.get(rclio.campaignLineItem.ProductCatalogEntryRef__c);
                    pcevsPoGG.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, sum);  
                }else if(idConsignedOrders.contains(rclio.FinalOrderIdDevice)){
                    Decimal sum = rclio.campaignLineItem.POG__c + pcevsPoGCon.get(rclio.campaignLineItem.ProductCatalogEntryRef__c);
                    pcevsPoGCon.put(rclio.campaignLineItem.ProductCatalogEntryRef__c, sum); 
                }
            }                       
        }

        Id ManagerId=Util.currentUser.ManagerId;
        Id ManagersManagerId=Util.currentUser.Manager.ManagerID;    
        
        Set<Id> pceWithStock = new Set<ID>();
        Set<Id> pceWithoutStockLine = new Set<ID>();
        
        for(Stock__c stk: [SELECT ProductCatalogEntryRef_RSA__c, User_RSA__c FROM Stock__C 
                           WHERE (ProductCatalogEntryRef_RSA__c IN:pcevsPoGR.keyset() AND User_RSA__c=:ManagerId)
                           OR (ProductCatalogEntryRef_RSA__c in:pcevsPoGFS.keyset() AND User_RSA__c=:ManagersManagerId)
                           OR (ProductCatalogEntryRef_RSA__c in:pcevsPoGG.keyset() AND User_RSA__c=:ManagersManagerId)
                           ]){
            pceWithStock.add(stk.ProductCatalogEntryRef_RSA__c);
        }
        
        pceWithoutStockLine.addAll(pcevsPoGR.keyset());
        pceWithoutStockLine.addAll(pcevsPoGFS.keyset());
        pceWithoutStockLine.addAll(pcevsPoGG.keyset());
        pceWithoutStockLine.removeAll(pceWithStock);
        
        pcevsPOG.putAll(pcevsPOGR);
        pcevsPOG.putAll(pcevsPOGFS);
        pcevsPOG.putAll(pcevsPOGG);
        pcevsPOG.putAll(pcevsPOGCon);
        
    /** Building the PK for the involved CLIs to find their Stock on Hybrid/ConsignmentWarehouse entities **/
        for(ProductCatalogEntry__c pce : [SELECT Id, ProductCatalogRef__c, ProdDesc__c, FRML_ProductCode__c, ProductRef__r.TXT_Hybrid__c FROM ProductCatalogEntry__c WHERE Id IN:pcevsPOG.KeySet()]){
        //for(ProductCatalogEntry__c pce : [SELECT Id, ProductCatalogRef__c, ProdDesc__c FROM ProductCatalogEntry__c WHERE Id IN:pcevsPOG.KeySet()]){
            productNames.put(pce.Id, pce.ProdDesc__c);
            if(pceVsPOGFS.containsKey(pce.id)){
                String pK= pce.ProdDesc__c+'-'+ManagersManagerId+'-'+pce.ProductCatalogRef__c;
                pcevsHybPK.put(pce.id, pK);
                hybPK.add(pK);
            } else if(pceVsPOGG.containsKey(pce.id)){
                String pK= pce.FRML_ProductCode__c+'_'+pce.ProductRef__r.TXT_Hybrid__c+'-'+ManagersManagerId+'-'+pce.ProductCatalogRef__c;
                pcevsHybPK.put(pce.id, pK);
                hybPK.add(pK);
            } else if (pceVsPOGCon.containsKey(pce.id)){
                String pK= pce.ProdDesc__c+'-'+Util.currentUser.Id+'-'+pce.ProductCatalogRef__c;
                pcevsHybPKcon.put(pce.id, pK);
                hybPK.add(pK);
            } else if (pceVsPOGR.containsKey(pce.id)){
                String pK= pce.ProdDesc__c+'-'+Util.currentUser.ManagerId+'-'+pce.ProductCatalogRef__c;
                pcevsHybPK.put(pce.id, pK);
                hybPK.add(pK);
            }
        }

    /** finding their Stock on Hybrid/Consignment Warehouse entities **/
        for (Hybrid__c hyb: [SELECT PK__c, UserRef__c, TaxStockleft__c, Stockleft__c FROM Hybrid__c WHERE PK__c IN:hybPK]){
            hybvsStock.put(hyb.PK__c, (hyb.UserRef__c==ManagerId?hyb.Stockleft__c:hyb.TaxStockleft__c));
        }
        for(Id iter : pcevsHybPK.keySet()){
            pcevsStock.put(iter, hybvsStock.get(pcevsHybPK.get(iter)));
        }   
                    
        for (ConsignmentWarehouse__c cW: [SELECT PK__c, Stockleft__c FROM ConsignmentWarehouse__c WHERE PK__c IN:hybPK]){
            hybvsStockCon.put(cW.PK__c, cW.Stockleft__c);
        }       
        for(Id iter : pcevsHybPKcon.keySet()){
            pcevsStockCon.put(iter, hybvsStockCon.get(pcevsHybPKcon.get(iter)));        
        }

    /** Creating maps pairing PCE with POG at Hybrid level sorting by ordertype **/
        for(Id iter :PCEvsPOGR.KeySet()){
            if(!hybPKvsPoGR.containsKey(pcevsHybPK.get(iter)))
                hybPKvsPoGR.put(pcevsHybPK.get(iter),PCEvsPOGR.get(iter));
            else{
                Decimal sum = PCEvsPOGR.get(iter) + hybPKvsPoGR.get(pcevsHybPK.get(iter));
                hybPKvsPoGR.put(pcevsHybPK.get(iter),sum);
            }
        }
        for(Id iter :PCEvsPOGFS.KeySet()){
            if(!hybPKvsPoGFS.containsKey(pcevsHybPK.get(iter)))
                hybPKvsPoGFS.put(pcevsHybPK.get(iter),PCEvsPOGFS.get(iter));
            else{
                Decimal sum = PCEvsPOGFS.get(iter) + hybPKvsPoGFS.get(pcevsHybPK.get(iter));
                hybPKvsPoGFS.put(pcevsHybPK.get(iter),sum);
            }
        }
        for(Id iter :PCEvsPOGG.KeySet()){
            if(!hybPKvsPoGG.containsKey(pcevsHybPK.get(iter)))
                hybPKvsPoGG.put(pcevsHybPK.get(iter),PCEvsPOGG.get(iter));
            else{
                Decimal sum = PCEvsPOGG.get(iter) + hybPKvsPoGG.get(pcevsHybPK.get(iter));
                hybPKvsPoGG.put(pcevsHybPK.get(iter),sum);
            }
        }
        for(Id iter :PCEvsPOGCon.KeySet()){
            if(!hybPKvsPoGCon.containsKey(pcevsHybPKCon.get(iter)))
                hybPKvsPoGCon.put(pcevsHybPKCon.get(iter),PCEvsPOGCon.get(iter));
            else{
                Decimal sum = PCEvsPOGCon.get(iter) + hybPKvsPoGCon.get(pcevsHybPKCon.get(iter));
                hybPKvsPoGCon.put(pcevsHybPKCon.get(iter),sum);
            }
        }
        for(Id iter :PCEvsPOGR.KeySet()){
            PCEvsPOGRH.put(iter, hybPKvsPoGR.get(pcevsHybPK.get(iter)));    
        }
        for(Id iter :PCEvsPOGFS.KeySet()){
            PCEvsPOGFSH.put(iter, hybPKvsPoGFS.get(pcevsHybPK.get(iter)));  
        }
        for(Id iter :PCEvsPOGG.KeySet()){
            PCEvsPOGGH.put(iter, hybPKvsPoGG.get(pcevsHybPK.get(iter)));  
        }
        for(Id iter :PCEvsPOGCon.KeySet()){
            PCEvsPOGConH.put(iter, hybPKvsPoGCon.get(pcevsHybPKCon.get(iter))); 
        }

    /** Stock vs POG comparision **/
        for(id iter:PCEvsPOGRH.KeySet()){
            if(!pcevsStock.containsKey(iter) && PCEvsPOGRH.get(iter)>0)
                pceWithoutStockR.add(iter);
            else if(pcevsStock.get(iter) < PCEvsPOGRH.get(iter))
                pceWithoutStockR.add(iter);
        }
        for(id iter:PCEvsPOGFSH.KeySet()){
            if(!pcevsStock.containsKey(iter) && PCEvsPOGFSH.get(iter)>0)
                pceWithoutStockFS.add(iter);
            else if(pcevsStock.get(iter) < PCEvsPOGFSH.get(iter))
                pceWithoutStockFS.add(iter);
        }
        for(id iter:PCEvsPOGGH.KeySet()){
            if(!pcevsStock.containsKey(iter) && PCEvsPOGGH.get(iter)>0)
                pceWithoutStockG.add(iter);
            else if(pcevsStock.get(iter) < PCEvsPOGGH.get(iter))
                pceWithoutStockG.add(iter);
        }
        for(id iter:PCEvsPOGConH.KeySet()){
            if(!pcevsStockCon.containsKey(iter) && PCEvsPOGConH.get(iter)>0)
                pceWithoutStockCon.add(iter);
            else if(pcevsStockCon.get(iter) < PCEvsPOGConH.get(iter))
                pceWithoutStockCon.add(iter);
        } 
        
    /** Building the JSON CampaignLineItem error message **/
        Map<Integer, String> additional = new Map<Integer, String>();
        for (REST_CampaignLineItemObject rclio: paramInfo.campaignLineItems){
            if(!pceWithoutStockLine.contains(rclio.campaignLineItem.ProductCatalogEntryRef__c) && !draftOrders.contains(rclio.FinalOrderIdDevice) )
            {
                if(pceWithoutStockR.contains(rclio.campaignLineItem.ProductCatalogEntryRef__c) && rclio.campaignLineItem.Consigned__c==false && idOrders.contains(rclio.FinalOrderIdDevice)){
                    rclio.statusDescription=System.label.RSA_Stock_iPadErrorMessage2;
                    rclio.statusCode=104;
                    involvedorders.add(rclio.FinalOrderIdDevice);
                    rclio.statusDescription=rclio.statusDescription.replace('[HYBRID]', productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[REQUESTED]', String.valueOf(rclio.campaignLineItem.PoG__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[TOTALREQUESTED]', String.valueOf(pcevsPoGRH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    rclio.statusDescription=rclio.statusDescription.replace('[AVAILABLE]', String.valueOf((pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    if(!additional.containskey(rclio.FinalOrderIdDevice))
                        additional.put(rclio.FinalOrderIdDevice,'\n'+rclio.StatusDescription);
                    else
                        additional.put(rclio.FinalOrderIdDevice, additional.get(rclio.FinalOrderIdDevice)+'\n'+rclio.StatusDescription);    
                    Map<Decimal, Decimal> Aux = new Map<Decimal, Decimal>{(pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c) => pcevsPoGRH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)};
                    mailRegular.put(productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c), Aux);
                } else if(pceWithoutStockFS.contains((String)rclio.campaignLineItem.ProductCatalogEntryRef__c)&& idFSOrders.contains(rclio.FinalOrderIdDevice)){
                    rclio.statusCode=104;       
                    involvedorders.add(rclio.FinalOrderIdDevice);
                    rclio.statusDescription=System.label.RSA_Stock_iPadErrorMessage2;
                    rclio.statusDescription=rclio.statusDescription.replace('[HYBRID]', productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[REQUESTED]', String.valueOf(rclio.campaignLineItem.PoG__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[TOTALREQUESTED]', String.valueOf(pcevsPoGFSH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    rclio.statusDescription=rclio.statusDescription.replace('[AVAILABLE]', String.valueOf((pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    if(!additional.containskey(rclio.FinalOrderIdDevice))
                        additional.put(rclio.FinalOrderIdDevice,'\n'+rclio.StatusDescription);
                    else
                        additional.put(rclio.FinalOrderIdDevice, additional.get(rclio.FinalOrderIdDevice)+'\n'+rclio.StatusDescription);                        
                    Map<Decimal, Decimal> Aux = new Map<Decimal, Decimal>{(pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c) => pcevsPoGFSH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)};
                    mailFS.put(productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c), Aux);
                } else if(pceWithoutStockG.contains((String)rclio.campaignLineItem.ProductCatalogEntryRef__c)&& idGOrders.contains(rclio.FinalOrderIdDevice)){
                    rclio.statusCode=104;       
                    involvedorders.add(rclio.FinalOrderIdDevice);
                    rclio.statusDescription=System.label.RSA_Stock_iPadErrorMessage2;
                    rclio.statusDescription=rclio.statusDescription.replace('[HYBRID]', productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[REQUESTED]', String.valueOf(rclio.campaignLineItem.PoG__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[TOTALREQUESTED]', String.valueOf(pcevsPoGGH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    rclio.statusDescription=rclio.statusDescription.replace('[AVAILABLE]', String.valueOf((pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    if(!additional.containskey(rclio.FinalOrderIdDevice))
                        additional.put(rclio.FinalOrderIdDevice,'\n'+rclio.StatusDescription);
                    else
                        additional.put(rclio.FinalOrderIdDevice, additional.get(rclio.FinalOrderIdDevice)+'\n'+rclio.StatusDescription);                        
                    Map<Decimal, Decimal> Aux = new Map<Decimal, Decimal>{(pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStock.get(rclio.campaignLineItem.ProductCatalogEntryRef__c) => pcevsPoGGH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)};
                    mailG.put(productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c), Aux);                   
                } else if(pceWithoutStockCon.contains(rclio.campaignLineItem.ProductCatalogEntryRef__c) && rclio.campaignLineItem.Consigned__c==true && idConsignedOrders.contains(rclio.FinalOrderIdDevice)){
                    rclio.statusCode=104;   
                    involvedorders.add(rclio.FinalOrderIdDevice);
                    rclio.statusDescription=System.label.RSA_Stock_iPadErrorMessage2;
                    rclio.statusDescription=rclio.statusDescription.replace('[HYBRID]', productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[REQUESTED]', String.valueOf(rclio.campaignLineItem.PoG__c));
                    rclio.statusDescription=rclio.statusDescription.replace('[TOTALREQUESTED]', String.valueOf(pcevsPoGConH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    rclio.statusDescription=rclio.statusDescription.replace('[AVAILABLE]', String.valueOf((pcevsStockCon.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStockCon.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)));
                    if(!additional.containskey(rclio.FinalOrderIdDevice))
                        additional.put(rclio.FinalOrderIdDevice,'\n'+rclio.StatusDescription);
                    else
                        additional.put(rclio.FinalOrderIdDevice, additional.get(rclio.FinalOrderIdDevice)+'\n'+rclio.StatusDescription);                        
                    Map<Decimal, Decimal> Aux = new Map<Decimal, Decimal>{(pcevsStockCon.get(rclio.campaignLineItem.ProductCatalogEntryRef__c))==null? 0 : pcevsStockCon.get(rclio.campaignLineItem.ProductCatalogEntryRef__c) => pcevsPoGConH.get(rclio.campaignLineItem.ProductCatalogEntryRef__c)};
                    mailCon.put(productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c), Aux);           
                }   
            }
            else if(pceWithoutStockLine.contains(rclio.campaignLineItem.ProductCatalogEntryRef__c))
            {
                rclio.statusCode=103;
                involvedordersWL.add(rclio.FinalOrderIdDevice);
                rclio.statusDescription= System.label.RSA_Stock_iPadErrorMessage3;
                rclio.statusDescription=rclio.statusDescription.replace('[HYBRID]', productNames.get(rclio.campaignLineItem.ProductCatalogEntryRef__c));
                    if(!additional.containskey(rclio.FinalOrderIdDevice))
                        additional.put(rclio.FinalOrderIdDevice,'\n'+rclio.StatusDescription);
                    else
                        additional.put(rclio.FinalOrderIdDevice, additional.get(rclio.FinalOrderIdDevice)+'\n'+rclio.StatusDescription);                    
            }
        }
        
    /** Building the JSON order error message **/ 
        for(REST_OrderObject roo : paramInfo.orders){
            if(involvedOrders.contains(roo.order.idDevice__c.intValue())){
                roo.statusCode=104;
                roo.statusDescription=System.label.RSA_Stock_iPadErrorMessage;  
                roo.statusDescription=roo.statusDescription.replace('[ORDER]', roo.order.Name);
                roo.statusDescription=roo.statusDescription.replace('[ACCOUNT]', roo.order.Name_Copy__c);
            } else if (involvedOrdersWL.contains(roo.order.idDevice__c.intValue())){
                roo.statusCode=103;
                roo.statusDescription=System.label.RSA_Stock_iPadErrorMessage;  
                roo.statusDescription=roo.statusDescription.replace('[ORDER]', roo.order.Name);
                roo.statusDescription=roo.statusDescription.replace('[ACCOUNT]', roo.order.Name_Copy__c);
            }
        }
        
        for(REST_OrderObject roo : paramInfo.orders){
            if(additional.containskey(roo.order.idDevice__c.intValue()))
                roo.statusDescription = roo.statusDescription+additional.get(roo.order.idDevice__c.intValue());
        }       
        
    /** Calling the mail sender method **/
        String activeMails= String.valueOf(SystemSettings__c.getValues('RSA_STOCK_MAILS').Value__c);
        if(activeMails.equalsignorecase('true'))
            sendStockMail(mailRegular,mailFS, mailCon);
        return paramInfo;                       
    }
        
        
private static void sendStockMail(Map<String,Map<Decimal,Decimal>> hybReg, Map<String,Map<Decimal,Decimal>> hybTax, Map<String,Map<Decimal,Decimal>> hybCon){
        
        
        String body='';
        String header='';
        header=System.Label.RSA_STOCK_MAIL_HEADER;          
        body=System.Label.RSA_STOCK_MAIL_RTC;  
        String colorHeadTableReg='#00dc53';
        String colorHeadHybridReg='#38fd82';
        String colorHeadTableTax='#f90337';
        String colorHeadHybridTax='#ffa1b5';
        String colorHeadTableCon='#2371dc';
        String colorHeadHybridCon='#9ac3fb';
        
        String productsReg='';
        String productsTax='';
        String productsCon='';
        
        if((hybReg.keyset()).size()>0){
            productsReg='<table style=" text-align:center; " ><tr style="text-align:center; background:'+colorHeadTableReg+';  width:240px; font-weight:bold;  color:white; ">REGULAR ORDERS</tr><tr><td style="background:'+colorHeadHybridReg+';  width:240px; font-weight:bold;  color:white; ">Hybrid</td><td  style="background:'+colorHeadHybridReg+';   width:180px; font-weight:bold; color:white; ">Stock Left</td><td style="background:'+colorHeadHybridReg+';  width:180px; font-weight:bold;color:white;">Stock Requested</td></tr>';
   
   
            for(String hybName: hybReg.keyset())
            {
                    
                for(Decimal sLeft: hybReg.get(hybName).keyset())
                {
                    productsReg=productsReg+'<tr><td>' +hybName+ '</td><td>'+ (Integer)sLeft + '</td><td>'+ (Integer)hybReg.get(hybName).get(sLeft)+'</td></tr>';
                }
            }
                                                   
            productsReg=productsReg+'</table></br></br>';  
        }
        
        
        if((hybTax.keyset()).size()>0){
            productsTax='<table style=" text-align:center; " ><tr style="text-align:center; background:'+colorHeadTableTax+';  width:240px; font-weight:bold;  color:white; ">TAX ORDERS</tr><tr><td style="background:'+colorHeadHybridTax+';  width:240px; font-weight:bold;  color:white; ">Hybrid</td><td  style="background:'+colorHeadHybridTax+';   width:180px; font-weight:bold; color:white; ">Stock Left</td><td style="background:'+colorHeadHybridTax+';  width:180px; font-weight:bold;color:white;">Stock Requested</td></tr>';

   
            for(String hybName: hybTax.keyset())
            {       
                for(Decimal sLeft: hybTax.get(hybName).keyset())
                {
                    productsTax=productsTax+'<tr><td>' +hybName+ '</td><td>'+ (Integer)sLeft + '</td><td>'+ (Integer)hybTax.get(hybName).get(sLeft)+'</td></tr>';
                }
            }
                                                   
            productsTax=productsTax+'</table></br></br>';  
        }
        
        if((hybCon.keyset()).size()>0){
            productsCon='<table style=" text-align:center; " ><tr style="text-align:center; background:'+colorHeadTableCon+';  width:240px; font-weight:bold;  color:white; ">CONSIGNMENT ORDERS</tr><tr><td style="background:'+colorHeadHybridCon+';  width:240px; font-weight:bold;  color:white; ">Hybrid</td><td  style="background:'+colorHeadHybridCon+';   width:180px; font-weight:bold; color:white; ">Consigned stock Left</td><td style="background:'+colorHeadHybridCon+';  width:180px; font-weight:bold;color:white;">Stock Requested</td></tr>';

   
            for(String hybName: hybCon.keyset())
            {
                    
                for(Decimal sLeft: hybCon.get(hybName).keyset())
                {
                    productsCon=productsCon+'<tr><td>' +hybName+ '</td><td>'+ (Integer)sLeft + '</td><td>'+ (Integer)hybCon.get(hybName).get(sLeft)+'</td></tr>';
                }
            }
                                                   
            productsCon=productsCon+'</table></br></br>';  
        }
        
                
        
        if(!(((hybReg.keyset()).size()==0) && ((hybTax.keyset()).size()==0) && ((hybCon.keyset()).size()==0)))
        {
            
        
        body=body.replace('[Manager]',Util.currentUser.Manager.Name);   
        body=body.replace('[Sales Rep]', Util.currentUser.Name);
        body=body.replace('[ProductsReg]',productsReg);
        body=body.replace('[ProductsTax]',productsTax);
        body=body.replace('[ProductsCon]',productsCon);
        
        
        map<String,String> mailsByRegion = new map<String,String>();
        //inform mailsByRegion
    for(String region : Label.RSA_CONSIGNMENT_MAILS.replace('\n','').replace('\r','').split(';')) 
    {
        if (region.split('#').size() == 2)
            mailsByRegion.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
        else
            system.debug('Wrong config for RSA additional mails for Final Orders: '+region);
       }
        
      
       
    String region =Util.currentUser.UserRole.Name.split(' - RSA - ')[1];
    String CcMails='';
               
    if(mailsByRegion.get(region)!=null)
            CcMails = mailsByRegion.get(region);

    Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        
    Integer counter=0;
    emails[counter++]=sendToMail(Util.currentUser.EMail,Util.currentUser.Manager.EMail+':'+CcMails, body,header);
    
 
    try{
        Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,true);
        }
    catch(Exception e)
    { }
        
    }
        
        }
    
}