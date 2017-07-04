global with sharing class ExportOrderTransferData {
    
  webservice static String convertOrders(id toConvertId)
    {
      
        
        opportunity toConvert=[Select Id,name,owner.TXT_Sales_Org__c, owner.SAP_Partner_Code__c, Account.GC_SAP_ID__c,LKP_Partner_Function__r.Partner_SAP_ID__c,TXT_Additional_Comments__C,
                               TXTA_Delivery_block_code__c,PICK_Order_Type__c,TXTA_Sales_Org__c,TXT_Distribution_Channel__c,TXTA_Division__c,
                               StageName,TXT_NewShipTo_ZIP_Contact__c,CloseDate,TXT_NewShipTo_ZIP_Phone__c,PICK_Status__c,TXT_NewShipTo_City__c,
                               GC_Comments_Txt__c,TXT_jsonFromSAP__c,FRML_Early_payment__c,TXT_NewShipTo_ShipToName__c,TXT_NewShipTo_ZIP_Code__c,
                               TXT_NewShipTo_Address__c,TXT_SAP_status_description__c, LKP_soldTo_Source_OT__r.GC_SAP_ID__c,LKP_ShipTo_Source_OT__r.Partner_SAP_ID__c,
                               LKP_areaManager_Credit_OT__r.manager.SAP_Partner_Code__c,LKP_areaManager_Debit_OT__r.manager.SAP_Partner_Code__c,LKP_areaManager_Credit_OT__r.SAP_Partner_Code__c,LKP_areaManager_Debit_OT__r.SAP_Partner_Code__c,PICK_REGION__c,PICK_COUNTRY__c,
                               TXT_Credit_SAP_Order_Number__c,TXT_Debit_SAP_Order_Number__c
                       from Opportunity where Id=:toConvertId limit 1];
       
        String ordToRet;
        String output=' '; 
        integer status=0;
        
        if(toConvert.PICK_Status__c=='Submitted'&& status==0)
        { 
            output='The order is already submitted';
        }
        if(toConvert.PICK_Status__c!='Submitted')
        {
            status ++;
            OrderToSend ord=new OrderToSend();
        
            /*--------------Header assignment--------------*/            
      
            IsHeader h=new IsHeader();
            
            h.customerPoNumber=toConvert.Name;/*  Mandatory */
            h.reqDeliveryDate=String.valueOf(toConvert.CloseDate); /* Optional */
            if(toConvert.TXTA_Sales_Org__c=='FR24' || toConvert.TXTA_Sales_Org__c=='BG01')
            {
                if(String.isNotBlank(toConvert.GC_Comments_Txt__c))h.headerText1=string.valueOf(h.reqDeliveryDate +' - '+ toConvert.GC_Comments_Txt__c);
                else h.headerText1=string.valueOf(h.reqDeliveryDate +' - ');
            }
            else h.headerText1=toConvert.GC_Comments_Txt__c;  /* Optional */
            h.headerText2=toConvert.TXT_Additional_Comments__C;  /* Optional *//* NO EXIST */ 
            
            /*--------------END assignment--------------*/
            
            /*--------------Source assignment--------------*/            
            IsCredit cr=new IsCredit();    
            
            cr.soldTo =toConvert.LKP_soldTo_Source_OT__r.GC_SAP_ID__c; /* Optional */
            cr.shipTo =toConvert.LKP_ShipTo_Source_OT__r.Partner_SAP_ID__c; /* Optional */
            cr.division =toConvert.TXTA_Division__c; /* Optional */
            cr.distChannel =toConvert.TXT_Distribution_Channel__c; /* Optional */
            cr.areaManager =toConvert.LKP_areaManager_Credit_OT__r.manager.SAP_Partner_Code__c; /* Optional */
            cr.salesRep=toConvert.LKP_areaManager_Credit_OT__r.SAP_Partner_Code__c; /* Optional */
            cr.salesOrg =toConvert.owner.TXT_Sales_Org__c; /* Optional */           

            system.debug('IsCredit ' + cr);
            /*--------------END assignment--------------*/         
                   
            /*--------------Target assignment--------------*/
            IsDebit d=new IsDebit();
         
            d.shiptoCountry =toConvert.PICK_COUNTRY__c; /* Optional */
            d.soldTo =toConvert.Account.GC_SAP_ID__c; /* Optional */
            d.shiptoContact =toConvert.TXT_NewShipTo_ZIP_Contact__c; /* Optional */
            d.shiptoRegion =toConvert.PICK_REGION__c; /* Optional */
            d.shipTo =toConvert.LKP_Partner_Function__r.Partner_SAP_ID__c; /* Optional */
            d.shiptoPhone =toConvert.TXT_NewShipTo_ZIP_Phone__c; /* Optional */
            d.shiptoCity =toConvert.TXT_NewShipTo_City__c; /* Optional */
            d.division =toConvert.TXTA_Division__c; /* Optional */
            d.distChannel =toConvert.TXT_Distribution_Channel__c; /* Optional */
            d.areaManager =toConvert.LKP_areaManager_Debit_OT__r.manager.SAP_Partner_Code__c; /* Optional */

            //If the Country is 'Italy' and the ship to is one time customer IT, the Salesrep is the owner Partner
            if (toConvert.owner.TXT_Sales_Org__c == 'IT01' && (toConvert.LKP_Partner_Function__r.Partner_SAP_ID__c == '9000000130' || toConvert.LKP_Partner_Function__r.Partner_SAP_ID__c == '9000000301'))
            {
                d.salesRep=toConvert.Owner.SAP_Partner_Code__c;
            }
            else
            {
                d.salesRep=toConvert.LKP_areaManager_Debit_OT__r.SAP_Partner_Code__c; /* Optional */ 
            }

            d.shiptoName =toConvert.TXT_NewShipTo_ShipToName__c; /* Optional */
            d.shiptoZipCode =toConvert.TXT_NewShipTo_ZIP_Code__c; /* Optional */
            d.shiptoStreetAddr =toConvert.TXT_NewShipTo_Address__c; /* Optional */
            d.salesOrg =toConvert.owner.TXT_Sales_Org__c; /* Optional */

            system.debug('IsDebit ' + d);          

            /*--------------END assignment--------------*/ 
            
            ord.IsHeader=h;
            ord.IsDebit=d;
            ord.IsCredit=cr;            
         
            /*---------------Order items assignment-------------*/        
            list<Item> i=new list<Item>();
               
            list<OpportunityLineItem> items=[select TXT_PLANT_COPY__c,Quantity,TXTA_Comments__c,NUM_Quantity_CP__c,Type__c,
                                             TXT_SAP_Order_number__c, Product2.ProductSAPCode__c,TXT_BatchNumber_OT__c,Opportunity.stagename from OpportunityLineItem where OpportunityId=:toConvert.Id];
            integer u=10;
            for(OpportunityLineItem item:items)
            {   
                
                Item it=new Item();
                it.plant=item.TXT_PLANT_COPY__c;            
                //START Fix bug on Feb 28th: if there is no batchnumber the split throws an error
                //it.batch=item.TXT_BatchNumber_OT__c.split('-')[0].trim();
                //if(item.TXT_BatchNumber_OT__c != null) it.batch=item.TXT_BatchNumber_OT__c.split('-')[0].trim();
                if(item.TXT_BatchNumber_OT__c != null) it.batch=item.TXT_BatchNumber_OT__c.split('\\\\')[0].trim();
                else it.batch='';
                system.debug('batch: ' + it.batch);
                //END Fix bug
                it.quantity=item.Quantity; /*Mandatory*/

                it.deliveryPriority='';//item.?
                it.clientOrderLineId='ITEM'+String.valueOf(u);      //item.?         /*Mandatory*/
                if(item.Type__c=='Free of charge')it.itemType='FOC Debit';
                else it.itemType=''; /*Mandatory*/
                it.productCode=item.Product2.ProductSAPCode__c; /*Mandatory*/
                
                ord.ItItems.Item.add(it);
                item.TXT_SAP_Order_line_ID__c='ITEM'+String.valueOf(u);
                u=u+10;
                
            }
            /*-----------------------END assignment---------------------------------*/
       
            OrdToRet= Json.serialize(ord) ;
            OrdToRet=OrdToRet.replaceAll('null','""');
        
            system.debug(OrdToRet); 
            map<string,Server_Urls__c> urls= Server_Urls__c.getall();
       
            //Start request                
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint(urls.get('Auth URL').url__C);
            req.setMethod('POST');
            req.setHeader('Cache-Control', 'no-cache');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('client_id=SalesForce-EMEA-SVC&client_secret='+urls.get('Auth URL').value__C+'&grant_type=client_credentials');
     
            try 
            {
                res = http.send(req);
            } 
            catch(System.CalloutException e) 
            {
               
                System.debug('Callout error: '+ e);
                System.debug('msj: '+res.getBody());
            }
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String token = (String)m.get('access_token');
        
            //Una vez está el token, se puede llamar al WS            
            string endpoint =urls.get('Transfer Order Entry').url__C;
            
            req = new HttpRequest(); 
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setEndpoint(endpoint);
        
            req.setMethod('POST');
            req.setTimeOut(100000) ;
            req.setHeader('Authorization', 'Bearer '+token );
            string prueba2='{"OrderHeader":{"shiptoCountry":"","headerText":"thisisthetestheadertext","salesDistrict":"","orderReason":"","shiptoContact":"","deliveryBlock":"","poNumber":"EMEATEST-20150903-6","shiptoRegion":"","deliveryDate":"015-09-30","billingBlock":"","shiptoPhone":"","shiptoCity":"","division":"15","paymentTerms":"","distChannel":"00","shiptoName":"","shiptoParty":"1001589","shiptoZipCode":"","orderType":"Standard","soldtoParty":"1001589","shiptoStreetAddr":"","salesOrg":"ES01"},"OrderItems":{"item":[{"plant":"1315","itemText":"thisisitemtext","quantity":2,"deliveryPriority":"datePriority","clientOrderLineId":"thisisitemtext","orderType":"FreeofCharge","productCode":"10043267"}]}}';
            // string prueba='{"OrderHeader":{"shiptoCountry":" ","headerText":"","salesDistrict":" ","orderReason":" ","shiptoContact":" ","deliveryBlock":"","poNumber":"IS-00001","shiptoRegion":" ","deliveryDate":"2015-09-30","billingBlock":" ","shiptoPhone":" ","shiptoCity":" ","division":"15","paymentTerms":" ","distChannel":"00","shiptoName":" ","shiptoParty":"1009201","shiptoZipCode":" ","orderType":"Standard","soldtoParty":"1009201","shiptoStreetAddr":" ","salesOrg":"ES01"},"OrderItems":{"item":[{"plant":"5922","itemText":" ","quantity":2,"deliveryPriority":"02","clientOrderLineId":"10","orderType":"Charged","productCode":"000000000010109251"}]}}';
            string prueba='{"OrderHeader":{"shiptoCountry":" ","headerText":"this is the test header text","salesDistrict":" ","orderReason":" ","shiptoContact":" ","deliveryBlock":" ","poNumber":"EMEATEST-20150903-6","shiptoRegion":" ","deliveryDate":"2015-09-30","billingBlock":" ","shiptoPhone":" ","shiptoCity":" ","division":"17","paymentTerms":" ","distChannel":"00","shiptoName":" ","shiptoParty":"1001589","shiptoZipCode":" ","orderType":"Standard","soldtoParty":"1009201","shiptoStreetAddr":" ","salesOrg":"ES01"},"OrderItems":{"item":[{"plant":"1315","itemText":"this is item text","quantity":2,"deliveryPriority":"02","clientOrderLineId":"this is item text","orderType":"Free of Charge","productCode":"10043267"}]}}';
            //   string prueba='{"OrderItems":{"item":[{"plant":"1315","itemText":"this is item text","quantity":2,"deliveryPriority":"02","clientOrderLineId":"this is item text","orderType":"Free of Charge","productCode":"10043267"}]},"OrderHeader":{"shiptoCountry":" ","headerText":"this is the test header text","salesDistrict":" ","orderReason":" ","shiptoContact":" ","deliveryBlock":" ","poNumber":"EMEATEST-20150903-6","shiptoRegion":" ","deliveryDate":"2015-09-30","billingBlock":" ","shiptoPhone":" ","shiptoCity":" ","division":"15","paymentTerms":" ","distChannel":"00","shiptoName":" ","shiptoParty":"1001589","shiptoZipCode":" ","orderType":"Standard","soldtoParty":"1001589","shiptoStreetAddr":" ","salesOrg":"ES01"}}';
            string prueba3='{"OrderItems":{"item":[{"quantity":34.00,"productCode":"000000000010043267","plant":"1315","orderType":"Charged","itemText":" ","deliveryPriority":"","clientOrderLineId":"ITEM10"}]},"OrderHeader":{"soldtoParty":"1001589","shipToZipCode":" ","shiptoStreetAddr":" ","shiptoRegion":"","shiptoPhone":" ","shiptoParty":"1009201","shiptoName":" ","shiptoCountry":"","shiptoContact":" ","shiptoCity":" ","salesOrg":"ES01","salesDistrict":"","poNumber":"IS-10014","paymentTerms":"","orderType":"Standard","orderReason":"","headerText":"This is comment header","division":"15","distChannel":"00","deliveryDate":"2015-10-06","deliveryBlock":"","billingBlock":""}}';
            req.setBody(OrdToRet);
            // req.setCompressed(true);
        
            system.debug(req.getBody());            
            
            try 
            {
                res = http.send(req);
                 toConvert.TXT_jsonFromSAP__c=res.getBody();
            } 
            catch(System.CalloutException e) 
            {
                System.debug('Callout error: '+ e);
                 System.debug('msj: '+res.getBody() + 'fin');
                 toConvert.TXT_jsonFromSAP__c=' response'+ res.getBody();
                toConvert.TXT_SAP_Status_description__c=res.getBody();
                /* Response in case of server connection error */
                item errServ=new item();
                errServ.errorMessage='Error trying to connect to server: '+ e;
               
                Response failConnection =new Response();
                failConnection.error.item.add(errServ);
                res.setBody(Json.serialize(failConnection));
            }
            
            system.debug(res.getBody() +res.getStatusCode() + res.getStatusCode()); 
            Response Resp=new Response();
            
            if(res.getStatusCode()==200)
            {
                Resp = (response)JSON.deserialize(res.getBody(), response.class);
            }
            else
            {
                 /* Response in case of server connection error */
                item errJson=new item();
                errJson.errorMessage='Error trying to connect to the server. Server Status code '+ res.getStatusCode();
                toConvert.CHK_Error_SAP_Check__c=true;
                Response failSerialization =new Response();
                failSerialization.error.item.add(errJson);
                res.setBody(Json.serialize(failSerialization));
                Resp = (response)JSON.deserialize(res.getBody(), response.class);    
            }
            
            integer c=0;
            for(item it:resp.success.item )
            {                
                if(c==0)
                {
                    output=output+'Succesfully submitted to SAP';                                    
                    c++;                
                }
                for(OpportunityLineItem item:items)
                {
                    if(item.TXT_SAP_Order_line_ID__c==it.clientOrderLineId)
                    {
                        item.TXT_Line_SAP_status__c='Succesfully submitted';
                        if(it.documentType=='Debit')
                        {
                            item.TXT_SAP_Order_line_ID__c=it.clientOrderLineId;
                            item.TXT_SAP_Order_Number__c=it.sapOrderNumber;
                        }  
                    }                        
                }
                if(it.documentType=='Debit')
                {
                    toConvert.TXT_Debit_SAP_Order_Number__c=it.sapOrderNumber;
                    output= output + '\r\n \r\n DEBIT: \r\n \r\n SAP order number: '  + it.sapOrderNumber +'\r\n\r\n Client Order Line Id: '  + it.clientOrderLineId +'\r\n' ;
                }
                if(it.documentType=='Credit')
                {
                    toConvert.TXT_Credit_SAP_Order_Number__c=it.sapOrderNumber;
                    output= output + '\r\n \r\n CREDIT: \r\n \r\n SAP order number: '  + it.sapOrderNumber +'\r\n' ;
                }
                    
                toConvert.PICK_Status__c='Submitted';
                toConvert.CHK_Error_SAP_Check__c=False;
                toConvert.TXT_SAP_Status_description__c=output;
                
                if(toConvert.TXT_SAP_Order_number__c==null || toConvert.TXT_SAP_Order_number__c.length()==0)
                {                    
                    toConvert.TXT_SAP_Order_number__c=it.sapOrderNumber;
                }
                else
                {
                    if(!toConvert.TXT_SAP_Order_number__c.contains(it.sapOrderNumber))
                    {
                        toConvert.TXT_SAP_Order_number__c+=';'+it.sapOrderNumber;      
                    }                   
                }                    
            }

            integer e=0;
            for(item it:resp.error.item )
            {
                if(e==0 && toConvert.PICK_Status__c=='Not Submitted')
                {
                    output=output+'Insert in SAP failed';
                    toConvert.CHK_Error_SAP_Check__c=true;
                    e++;                    
                }
                output= output +'\r\n \r\n'  + it.errorMessage+'\r\n\r\n' ;
                for(OpportunityLineItem item:items)
                {
                    item.TXT_Line_SAP_status__c=it.errorMessage;                    
                }                   
            }
            toConvert.TXT_SAP_Status_description__c=output;
            

            update items;
        }
         
        update toConvert;
        return output;
    }

    public class OrderToSend
    {  
        public IsHeader IsHeader=new IsHeader();
        public ItItems ItItems=new ItItems();
        public IsDebit IsDebit=new IsDebit();
        public IsCredit IsCredit=new IsCredit();        
    } 

    class IsHeader
    {
        public string customerPoNumber {get;set;}
        public string reqDeliveryDate {get;set;}
        public string headerText1 {get;set;}
        public string headerText2 {get;set;}
    }

    public class IsDebit
    {        
        public string shiptoCountry {get;set;}
        public string soldTo {get;set;}
        public string shiptoContact {get;set;}
        public string shiptoRegion {get;set;}
        public string shipTo {get;set;}
        public string shiptoPhone {get;set;}
        public string shiptoCity {get;set;}
        public string division {get;set;}
        public string distChannel {get;set;}
        public string areaManager {get;set;}
        public string salesRep{get;set;} 
        public string shiptoName {get;set;}
        public string shiptoZipCode {get;set;}
        public string shiptoStreetAddr {get;set;}
        public string salesOrg {get;set;}  
    }

    public class IsCredit
    {       
        public string soldTo {get;set;}
        public string shipTo {get;set;}
        public string division {get;set;}
        public string distChannel {get;set;}
        public string areaManager {get;set;}
        public string salesRep{get;set;} 
        public string salesOrg {get;set;}   
    }

    public class ItItems
    {
        public list<Item> item=new list<Item>(); 
    }

    public class Item
    {        
        public string plant{get;set;}
        public decimal quantity {get;set;}
        public string deliveryPriority{get;set;}
        public string clientOrderLineId{get;set;}
        public string batch{get;set;}        
        public string itemType {get;set;} 
        public string productCode{get;set;} 
        public string documentType{get;set;}
        public string errorMessage{get;set;}
        public string sapOrderNumber{get;set;}
        public string sapOrderItemNumber{get;set;}        
    }

    public class response
    {
        public error Error=new error();   
        public success Success=new success();
    }
    public class error
    {
        public list<Item> item=new list<Item>();
    }
    public class success
    {
        public list<Item> item=new list<Item>();
    }
}