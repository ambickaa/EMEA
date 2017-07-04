global with sharing class WSProductsBatch implements Database.batchable<String>,Database.AllowsCallouts{
    
    
    public List<productReceived> listaProducts {get; set;} 
    public List<product2> connectarToWS(String filter)
    {   
        //Define the variables for make the filter
        string[] parameters=filter.split('#',-1);
        string sCountry=parameters[0];
        string sDivision=parameters[1];        
        string sYear=parameters[2];
        string ssOrg=parameters[3];
        string disChannel=parameters[4];

        map<string,Server_Urls__c> urls= Server_Urls__c.getall();
        Map<String, REL_Factor__c> Map_REL_Factor = REL_Factor__c.getall();
     
        //start request        
        // Primero obtenemos el token
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
     
        req.setEndpoint(urls.get('Auth URL').url__C);
        //req.setEndpoint('https://amp.monsanto.com/as/token.oauth2');
        req.setMethod('POST');
        req.setHeader('Cache-Control', 'no-cache');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('client_id=SalesForce-EMEA-SVC&client_secret='+urls.get('Auth URL').value__C+'&grant_type=client_credentials');
        //req.setBody('client_id=SalesForce-EMEA-SVC&client_secret=deSFQtYNtzSR6SaidDkCeobEexKEQq29pz1MpaOJnS3fP9TTRss1gOw4rpkA79bm&grant_type=client_credentials');
        
        try 
        {
            res = http.send(req);
        } 
        catch(System.CalloutException e) 
        {
            System.debug('Callout error token: '+ e);
            System.debug('msj: '+res.getBody());
        }
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('response: '+res.getBody());
        String token = (String)m.get('access_token');

        //Una vez está el token, se puede llamar al WS        

        req = new HttpRequest();
        req.setTimeout(80000);

        string endpoint =urls.get('Product List').url__C;
        

        // https://gsc-customer-care-orders-np.agro.services/gsc-emea-product/v1/products/sales-district/AG-ES/year/2015?lob=CP&sales-org=ES01&dist-channel=00
        String url=sCountry+'/year/'+sYear+'?lob='+ sDivision+'&sales-org='+sSOrg+'&dist-channel='+disChannel;
        //String url='https://gsc-customer-care-orders.agro.services/gsc-emea-product/v1/products/sales-district/'+sCountry+'/year/'+sYear+'?lob='+ sDivision+'&sales-org='+sSOrg+'&dist-channel='+disChannel;
        req.setEndpoint(endpoint+url);
        //req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+token );        
        
        try 
        {
            res = http.send(req);
        } 
        catch(System.CalloutException e) 
        {
            System.debug('Callout error: '+ e);
            
        }
        
        //End request
        system.debug(res.getBody());        
        
        if(string.valueof(res.getBody()) == 'No results found'){
            return null;
        }
        else{
            listaProducts = (List<productReceived>)JSON.deserialize(res.getBody(), List<productReceived>.class);
            System.debug('response: '+res.getBody()); 
            RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
            account vendor=[select id,name from account where name='Monsanto International Sàrl' limit 1];
            
            /*----External data for the lookups----------*/
            
            map<String,Division__c> divisions=new map<String,Division__c>();
            map<String,Product_Grouping__c> productGroups=new map<String,Product_Grouping__c>();
            map<String,id> recordTypes=new map<String,id>();
            divisions=Util.divisions;
            productGroups=Util.productGroups;
            recordTypes=Util.recordType;   

            /*----External data for the lookups----------*/
            
             
            set<product2> prodToUpsSet=new set<product2>();
            list<product2> prodToUps=new list<product2>();
            for (productReceived element:listaProducts )
            {
                product2 prod=new product2();
                
                 /*------------------Product Div,RT,ProdGroup Assignment-----------------*/
                if(sDivision=='CP')
                {
                    prod.RecordTypeId=recordTypes.get('Product2:CPSalesProduct'); 
                    prod.DivisionRef__c=divisions.get('CP').id;
                }                        
                if(element.productFamily=='Corn')
                { 
                    prod.DivisionRef__c=divisions.get('Corn').id;
                    prod.RecordTypeId=recordTypes.get('Product2:CornSalesProduct');
                    prod.ProductGroupRef__c=productGroups.get('Corn').id;
                }
                if(element.productFamily=='Canola/Oilseed Rape')
                {
                    prod.DivisionRef__c=divisions.get('OSR').id;
                    prod.RecordTypeId=recordTypes.get('Product2:OSRSalesProduct');
                    prod.ProductGroupRef__c=productGroups.get('OSR').id;
                }            
                /*------------------END Div,RT,ProdGroup Assignment-----------------*/
                
                prod.ProductCode=element.sapCode.replaceFirst('^0+','');
                prod.ProductSAPCode__c=element.sapCode.replaceFirst('^0+','');
                prod.ProductTreatment__c=element.treatment;
                prod.ProductChemPrimPkgOutcrt__c=element.chemPrimPkgOutcrt;               
                prod.ProductChemPrimPkgType__c=element.chemPrimPkgType;
                
                //---------------------------------------------------------------------------
                //  Get REL factor values from custom setting for existing Product SAP codes
                //---------------------------------------------------------------------------

                prod.DE_RelFactor__c=element.relConvFactor;

                if(Map_REL_Factor.containskey(prod.ProductCode)){

                    List<String> List_REL_Factor = Map_REL_Factor.get(prod.ProductCode).REL_Factor__c.split('/');

                    try{

                        if (List_REL_Factor.size()==2){
                            

                                Decimal Numerator_REL= decimal.valueOf(List_REL_Factor[0]);
                                Decimal Denominator_REL=decimal.valueOf(List_REL_Factor[1]);
                                prod.DE_RelFactor__c = Denominator_REL != 0 ? Numerator_REL / Denominator_REL : prod.DE_RelFactor__c;


                        }else if (List_REL_Factor.size()==1){

                            prod.DE_RelFactor__c = decimal.valueOf(List_REL_Factor[0]);

                        }

                    } catch(TypeException e){

                        system.debug(e.getMessage());

                    }
                }

                prod.ProductBrandName__c=element.brandName;
                prod.ProductTagGroup__c=element.tagGroup;
                prod.DE_BasicUnits__c=element.basicUnits;
                prod.Description=element.productDescription; 
                prod.IsActive=true;
                    
                 /*------------------New fields assignments-----------------*/
                prod.TXT_Hybrid__c=element.productDescription;
                prod.ProductBagSize__c=(element.bagSize.replaceAll('[a-zA-Z/#$]', '') == '' ? null : Double.valueOf(element.bagSize.replaceAll('[a-zA-Z/#$]', '')));
                prod.ProductVendor__c=vendor.id;            
                prod.productMaturity__c=0;
                /* 
                    if(prod.Family==null){
                    if(element.productFamily.length() == 0 || element.productFamily==null || string.isBlank(element.productFamily) )prod.family = prod.family;
                    else prod.family =element.productFamily;
                    }*/
                    if(element.salesText.length() == 0 || element.salesText==null || string.isBlank(element.salesText))prod.TXT_commercial_name__c = element.productName;
                    else prod.TXT_commercial_name__c =element.salesText;
                
                 /*------------------END New fields assignments-----------------*/
                
                   prod.ProductChemistry__c=element.productChemistry;
                   prod.ProductPkgSizCD__c=element.packageSizeCode;
                   prod.ProductGrdSizCD__c=element.gradeSizeCode;
                   prod.ProductChemOuterCrtPal__c=string.valueOf(element.chemOuterCrtPal);
                   prod.ProductPrmyPkContent__c=element.chemPrimPkgCont;
                   prod.ProductPkgTypCD__c=element.packageTypeCode;
                   prod.Name=element.productName;
                    
                   prodToUpsSet.add(prod);           
                     
            }
            
            prodToUps.addALL(prodToUpsSet);
            return prodToUps;
        }
    }
    
     global iterable<String> start(Database.BatchableContext bc)
    {
        //String productFilter='AG-ES#2015#CP';
        List<String> productsFilter = new List<String>(active_pricebooks__c.getall().keyset());
        return productsFilter;
    }
    global void execute(Database.BatchableContext BC,list<String> scope)
    {   
        
        Pricebook2 standardPB = [select ID from Pricebook2 where IsStandard = TRUE limit 1];
        for(String filter:scope)
        {   system.debug('el filtro es:'+ filter);
            List<product2> prodUps=connectarToWS(filter);
            system.debug('prodUps: ' + prodUps);
            if (prodUps == null){
                continue;
            }
            else {
              //  Schema.SObjectField f = Account.Fields.Key__c;

            Schema.SObjectField f= Product2.Fields.ProductSAPCode__c;
                Database.UpsertResult [] cr = Database.upsert(prodUps, f, false);
            

                
                
                //Filter for pricebooks & pricebookentries upsert
                string[] parameters=filter.split('#');
                string sCountry=parameters[0];
                string sDivision=parameters[1];
                string sYear=parameters[2];
                string ssOrg=parameters[3];
                string disChannel=parameters[4];
                

                
                //pricebook upsert
                pricebook2 catToUps=new pricebook2(IsActive = true);
                catToUps.Integration_Key__c=sCountry+sYear+'/'+sDivision;
                catToUps.name=sCountry+' - '+sDivision+'- Sales - '+sYear;
                
                Schema.SObjectField g= pricebook2.Fields.Integration_Key__c;
                Database.UpsertResult cr2 = Database.upsert(catToUps, g, false);
                
                //pricebookentries upsert

                set<pricebookentry> linesToUpsSet=new set<pricebookentry>();
                list<pricebookentry> linesToUps= new list<pricebookentry>();
                for(product2 prod:prodUps)
                {
                    PriceBookEntry standardPrice= new PriceBookEntry(GC_Integration_Key__c='ACS/'+(prod.ProductSAPCode__c.leftPad(18).replaceAll(' ','0')), Pricebook2Id=standardPB.Id,Product2Id=prod.Id,UnitPrice=0,IsActive=true,UseStandardPrice=false); 
                    linesToUpsSet.add(standardPrice);
                    
                    PriceBookEntry line= new PriceBookEntry(GC_Integration_Key__c=sCountry+ sDivision + sYear +'/' +(prod.ProductSAPCode__c.leftPad(18).replaceAll(' ','0')),product2id=prod.Id,UnitPrice=0,pricebook2id=catToUps.Id,UseStandardPrice=FALSE,IsActive = true);
                    
                    linesToUpsSet.add(line);   
                }
                
             linesToUps.addAll(linesToUpsSet);
             Schema.SObjectField h= PriceBookEntry.Fields.GC_Integration_Key__c;
             Database.UpsertResult [] cr3 = Database.upsert(linesToUps, h, false);
            }
        }
        

       
       
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }


    public class productReceived
    {
        public String sapCode{get; set;}
        public String treatment{get; set;}
        public String chemPrimPkgOutcrt{get; set;}
        public String lob{get; set;}
        public String chemPrimPkgType{get; set;}
        public Double relConvFactor{get; set;}
        public String bagSize{get; set;}  
        public String brandName{get; set;}
        public String tagGroup{get; set;}
        public Double basicUnits{get; set;}
        public String productDescription{get; set;}
        public String productChemistry{get; set;}
        public String packageSizeCode{get; set;}
        public String gradeSizeCode{get; set;}
        public Double chemOuterCrtPal{get; set;}
        public String chemPrimPkgCont{get; set;}
        public String packageTypeCode{get; set;}
        public String productName{get; set;}
        public String productFamily{get; set;}
        public String salesText{get; set;}
        
    }
    
}