global with sharing class ExportOrderData {
    
    webservice static String convertOrders(id toConvertId)
    {
        
        user currUser=[Select country,division from User where id=:userInfo.getUserId()];
        
        opportunity toConvert=[Select Id,name,owner.SAP_Partner_Code__c, owner.manager.SAP_Partner_Code__c, owner.TXT_Sales_Org__c,Account.GC_SAP_ID__c,LKP_Partner_Function__r.Partner_SAP_ID__c,TXTA_Delivery_block_code__c,
                               PICK_Order_Type__c,TXTA_Sales_Org__c,TXT_Distribution_Channel__c,PICK_COUNTRY__c,owner.division,owner.country,
                               TXTA_Division__c,StageName,TXT_NewShipTo_ZIP_Contact__c,CloseDate,TXT_NewShipTo_ZIP_Phone__c,PICK_Status__c,
                               TXT_NewShipTo_City__c,PICK_REGION__c,GC_comments_Txt__c,TXT_jsonFromSAP__c,FRML_Early_payment__c,TXT_NewShipTo_ShipToName__c,
                               TXT_NewShipTo_ZIP_Code__c,TXT_NewShipTo_Address__c,TXT_SAP_status_description__c ,CHK_FullTruckDiscount__c,CHK_HalfTruckDiscount__c,
                               NUM_Total_Quantity_palets_FOC__c,NUM_Total_Quantity_palets_charged__c,DATE_Pricing_Date__c,LKP_Order__c,LKP_Order__r.GC_Integration_Key__c,LKP_Contract__c,LKP_Contract__r.GC_Integration_Key__c,  RecordType.Name
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

            /*-----Italy truck validation before submission-----*/

            //If truck discount is selected and quantity does not qualify the order can not be submitted to SAP
            //
            list<OpportunityLineItem> itemsAux=[select TXT_PLANT_COPY__c,Quantity,TXTA_Comments__c,NUM_Quantity_CP__c,Type__c,NUM_Quantity_litres_CP__c,
                                             TXT_SAP_Order_number__c,Product2id, Product2.ProductSAPCode__c,PCK_Line_Status__c from OpportunityLineItem where OpportunityId=:toConvert.Id];
            string exceptProd;
            if(toConvert.owner.country=='Italy' && toConvert.owner.division=='CP' ){
            exceptProd=quantityMultipleBasicUnits(itemsAux);
            system.debug('except:'+ exceptProd+'End');
            }
            if( (String.isNotBlank(exceptProd)|| DiscountSelected(toConvert))){
                toConvert.TXT_SAP_Status_description__c='';
                toConvert.CHK_Error_SAP_Check__c=True;
                if(DiscountSelected(toConvert)) toConvert.TXT_SAP_Status_description__c='Truck discount Error: \r\n\n  Quantity does not qualify for the truck discount selected.\r\n\n';
                

               if(String.isNotBlank(exceptProd))toConvert.TXT_SAP_Status_description__c+='\t \r'+exceptProd;
            }
            else{             
            
            status ++;
            OrderToSend ord=new OrderToSend(); 
            
            /*--------------Header assignment--------------*/
            
            
            
            OrderHeader h=new OrderHeader();
            h.poNumber=toConvert.Name;
            h.salesDistrict=''; //  ----nO EXISTE------- /*Optional*/
            h.deliveryBlock='';//toConvert.TXTA_Delivery_block_code__c; 
            h.billingBlock='';  //  ----nO EXISTE-------
            h.orderType=toConvert.StageName; /*Mandatory*/  

            if(toConvert.RecordType.Name == 'Sales Italy FOC'){
                h.orderReason='E27'; //toConvert.orderReason
            }else{
                h.orderReason='';
            }
                system.debug('@@ Record type' + toConvert.RecordType.Name);
                System.debug('@@ Order reason de FOC o Charged' + h.orderReason);
                
                
            h.salesOrg=toConvert.TXTA_Sales_Org__c; /*Mandatory*/
            if(toConvert.RecordType.Name == 'Sales Italy FOC' || toConvert.RecordType.Name == 'Sales Italy Charged'){
            
                h.salesRep=toConvert.owner.SAP_Partner_Code__c;
                h.areaManager=toConvert.owner.manager.SAP_Partner_Code__c;
            }
            
            h.distChannel=toConvert.TXT_Distribution_Channel__c; /*Mandatory*/
            h.division=toConvert.TXTA_Division__c; /*Mandatory*/
            h.soldtoParty=toConvert.Account.GC_SAP_ID__c; /*Mandatory*/
            h.shipmentDetails.shiptoParty=toConvert.LKP_Partner_Function__r.Partner_SAP_ID__c;
            h.paymentTerms=toConvert.FRML_Early_payment__c; 
            h.deliveryDate=String.valueOf(toConvert.CloseDate); /*Mandatory*/
            h.headerText=toConvert.GC_comments_Txt__c;  
            h.shipmentDetails.shiptoCountry=toConvert.PICK_COUNTRY__c;//toConvert.
            h.shipmentDetails.shiptoContact=toConvert.TXT_NewShipTo_ZIP_Contact__c;
            h.shipmentDetails.shiptoRegion=toConvert.PICK_REGION__c;//toConvert.
            h.shipmentDetails.shiptoPhone=toConvert.TXT_NewShipTo_ZIP_Phone__c;
            h.shipmentDetails.shiptoCity=toConvert.TXT_NewShipTo_City__c;
            h.shipmentDetails.shiptoName=toConvert.TXT_NewShipTo_ShipToName__c;
            h.shipmentDetails.shiptoZipCode=toConvert.TXT_NewShipTo_ZIP_Code__c;        
            h.shipmentDetails.shiptoStreetAddr=toConvert.TXT_NewShipTo_Address__c;
                
                // Fields of  the contract or order copy.
                if(toConvert.LKP_Contract__c!=null)
                {
                    h.extorderDetails.referenceOrder=toConvert.LKP_Contract__r.GC_Integration_Key__c;
                }
                else if(toConvert.LKP_Order__c!=null)
                {
                    h.extorderDetails.referenceOrder=toConvert.LKP_Order__r.GC_Integration_Key__c;
                }
                
            
            /*Only for turkey*/
                
            h.priceDate=String.valueOf(toConvert.DATE_Pricing_Date__c);
                
            ord.OrderHeader=h; 
            /*---------------Order Partner assignment [Only for orders with One time customer as a SOLD-TO]-------*/
            if(toConvert.StageName=='FOC ORDER')
            {
                Item YY=new Item();
                    YY.partnerFn='YY';
                    YY.partnerNo='1885936';
                
                ord.orderHPartner.Item.add(YY);
                
                Item YS=new Item();
                    YS.partnerFn='YS';
                    YS.partnerNo='1885936';
                
                ord.orderHPartner.Item.add(YS);
                
                Item YZ=new Item();
                    YZ.partnerFn='YZ';
                    YZ.partnerNo='1885936';
                
                ord.orderHPartner.Item.add(YZ);
                
             }   
            /*---------------Order items assignment-------------*/
            
            list<Item> i=new list<Item>();
            
            list<OpportunityLineItem> items=[select TXT_PLANT_COPY__c,Quantity,TXTA_Comments__c,NUM_Quantity_CP__c,Type__c,NUM_Quantity_litres_CP__c,
                                             TXT_SAP_Order_number__c,Product2id,PCK_Line_Status__c,Product2.ProductSAPCode__c from OpportunityLineItem where OpportunityId=:toConvert.Id];
                                             

            
                                             
            integer u=10;
            for(OpportunityLineItem item:items)
            {   
                
                Item it=new Item();
                it.plant=item.TXT_PLANT_COPY__c;
                it.itemText=item.TXTA_Comments__c;
               if(item.PCK_Line_Status__c!='Inactive') it.quantity=item.Quantity; /*Mandatory*/
                else it.Quantity=0;
                it.deliveryPriority='';//item.?
                it.clientOrderLineId='ITEM'+String.valueOf(u);      //item.?         /*Mandatory*/
                it.orderType=item.Type__c; /*Mandatory*/
                it.productCode=item.Product2.ProductSAPCode__c; /*Mandatory*/
                it.extItemNo='000010';
                ord.OrderItems.Item.add(it);
                item.TXT_SAP_Order_line_ID__c='ITEM'+String.valueOf(u);
                u=u+10;
                
            }
            /*-----------------------------------------------------------------------*/
            
            OrdToRet= Json.serialize(ord) ;
            OrdToRet=OrdToRet.replaceAll('null','""');
            
            system.debug(OrdToRet); 
            
            //Start request
            map<string,Server_Urls__c> urls= Server_Urls__c.getall();
            string endpoint =urls.get('Order Entry').url__C;
                
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
        req.setEndpoint(urls.get('Auth URL').url__C);
        req.setMethod('POST');
        req.setHeader('Cache-Control', 'no-cache');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('client_id=SalesForce-EMEA-SVC&client_secret='+urls.get('Auth URL').value__C+'&grant_type=client_credentials');
        System.debug('client_id=SalesForce-EMEA-SVC&client_secret='+urls.get('Auth URL').value__C+'&grant_type=client_credentials');
            
            try 
            {
                res = http.send(req);
            } 
            catch(System.CalloutException e) 
            {
                
                System.debug('Callout error: '+ e);
                System.debug('msj: '+res.getBody());
            }
                system.debug(res.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String token = (String)m.get('access_token');
            
            //Una vez está el token, se puede llamar al WS
            
                

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
                system.debug('***Response: ' + res.toString());
            } 
            catch(System.CalloutException e) 
            {

                //***************************************************
                // SAVE DOCUMENT: CONNECTION FAILED
                //***************************************************
                String reason = '_Connection_failed_';
                generateBackupDocument(req, res, reason);

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
            system.debug('***Response1: ' + res.toString());
            Response Resp=new Response();
            system.debug('***Response2: ' + res.toString());
            if(res.getStatusCode()==200)
            {
                Resp = (response)JSON.deserialize(res.getBody(), response.class);
            }
            else
            {
                //***************************************************
                // SAVE DOCUMENT: RESPONSE FAILED
                //***************************************************
                system.debug('*** RES1: ' + res.getBody());
                String reason = '_Response_failed_';
                generateBackupDocument(req, res, reason);

                /* Response in case of server connection error */
                item errJson=new item();
                errJson.errorMessage='Error trying to connect to the server ';
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
                        item.TXT_SAP_Order_Number__c=it.sapOrderNumber;
                        item.TXT_SAP_Order_line_ID__c=it.sapOrderItemNumber;
                    }
                    
                }
                output= output + '\r\n \r\n SAP order number: '  + it.sapOrderNumber +'\r\n\r\n Client Order Line Id: '  + it.clientOrderLineId +' || SAP Order item number: '  + it.sapOrderItemNumber+'\r\n' ;
                toConvert.PICK_Status__c='Submitted';
                toConvert.CHK_Error_SAP_Check__c=False;
                toConvert.TXT_SAP_Status_description__c=output;
                
                if(toConvert.TXT_SAP_Order_number__c==null || toConvert.TXT_SAP_Order_number__c.length()==0)
                {
                    toConvert.TXT_SAP_Order_number__c=it.sapOrderNumber;
                }else
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
        
        /*----------------Exceptions for Italy----------------
            
            
        / the sum of every SKU quantity has to be multiple of the SKU Basic Units--/
        
        
        if(currUser.country=='Italy' && toConvert.Pick_Status__c=='Submitted')
        {
            list<OpportunityLineItem> items=[select TXT_PLANT_COPY__c,Quantity,TXTA_Comments__c,NUM_Quantity_CP__c,Type__c,NUM_Quantity_litres_CP__c,
                                             TXT_SAP_Order_number__c,Product2id, Product2.ProductSAPCode__c from OpportunityLineItem where OpportunityId=:toConvert.Id];
 
            string exceptionProd=quantityMultipleBasicUnits(items);
            system.debug('except:'+ exceptionProd+'End');
            if(String.isNotBlank(exceptionProd)) sendEmail(toConvert.id,'Product Quantity Error');
            
        if(productsFOCexception(items,toConvert))sendEmail(toConvert.id,'Order Entry FOC lines Exception');
            
        }
        

         ----------------End Exceptions for Italy----------------*/
       } 
        update toConvert;
        return '';
    }
    @future(callout=true) Webservice Static Void futureConvertOrders(Id toConvertId)
    {
        ExportOrderData.convertOrders(toConvertId)  ;
    }
    /*
    public static void sendEmail(ID recipient, string customException) {
        
        //map for all emails exceptions
         
        Order_emails_exceptions__c custException=Order_emails_exceptions__c.getInstance(customException);
        string templateName=custException.Template_Name__c;
        string[] emails =custException.Email_recipients__c.split(';');
         id template =[Select id from EmailTemplate where name=:templateName limit 1].id;
        
        //New instance of a single email message
        
        Messaging.SingleEmailMessage mail =
            
            new Messaging.SingleEmailMessage();
        
        
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        
        
       
        
        
        
        // The email template ID used for the email
        
        mail.setTemplateId(Template);
        
        // Who you are sending the email to
        String[] toAddresses = emails;
         mail.setWhatId(recipient);   
        
        mail.setBccSender(false);
        
        mail.setUseSignature(false);
        
        mail.setToAddresses(toAddresses);        
        
       // mail.setSenderDisplayName(userName);
        
        mail.setSaveAsActivity(false); 
        
        mail.setTargetObjectId([select id, Email from Contact where email <> null limit 1].id);
        
        lstMsgs.add(mail);
        
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());

            emailToSend.setSubject(email.getSubject());
            lstMsgsToSend.add(emailToSend);
        }
        Messaging.sendEmail(lstMsgsToSend);
        
       
       
        
        
    } */ 
    public static boolean DiscountSelected(opportunity ord)
    {
        boolean result=false;
        if(ord.CHK_FullTruckDiscount__c)
        {
            Double totalPallets=ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c;
            Integer aux=integer.valueOf(totalPallets) ;
            if( ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c<24 )result=true;
           
        }
            
        if(ord.CHK_HalfTruckDiscount__c)
        {
            Double totalPallets=(ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c);
            Integer aux=integer.valueOf(totalPallets) ;
            system.debug((ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c));
            if((ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c)<12 && (ord.NUM_Total_Quantity_palets_FOC__c+ord.NUM_Total_Quantity_palets_charged__c)!=12)result=true;
            
        }
         return result;   
    } 
  /* public static boolean productsFOCexception(list<opportunityLineItem> OLIs,opportunity ord)
    {
        boolean throwError=False;
        map<string,IT_Products_Order_Exceptions__c> prods= IT_Products_Order_Exceptions__c.getall();
        
        Map<string,decimal> ChargedProds=new Map<string,decimal>();
        Map<string,decimal> FOCProds=new Map<string,decimal>();
        
        for(opportunityLineItem Oli:Olis)
        {
            if(prods.containsKey(Oli.Product2.ProductSAPCode__c))
            {
                string[] additionalMonths=new String[]{''};
                system.debug(prods.get(OLi.Product2.ProductSAPCode__c));
                string[] range=prods.get(OLi.Product2.ProductSAPCode__c).Range__c.split('-');
                integer startMonth=integer.valueOf(range[0]);
                integer endMonth=integer.valueOf(range[1]);
                if(string.isNotBlank(prods.get( OLi.Product2.ProductSAPCode__c).Additional_Months__c))additionalMonths=prods.get(OLi.Product2.ProductSAPCode__c).Additional_Months__c.split('#');
               
                
                system.debug(range+' '+ startMonth+' '+ endMonth + ' ' + additionalMonths);
                
                integer monthOrder= ord.CloseDate.month();
                
                

                if (monthOrder < startMonth  || monthOrder > endMonth )throwError=True;
                for(string addMonth:additionalMonths) 
                {
                    
                    if(addMonth==string.valueOf( monthOrder))throwError=False;
                }
                
                if(oli.Type__c=='Charged')chargedProds.put(OLi.Product2.ProductSAPCode__c, OLI.quantity);                    
                if(oli.Type__c=='Free of charge')FOCProds.put(OLi.Product2.ProductSAPCode__c, OLI.quantity);
                
            }
        }
        for(string FOCprod: FOCProds.keySet())
        {
            if(chargedProds.containsKey(FOCprod))
            {
                decimal discountLine=(FOCProds.get(FOCprod) / chargedProds.get(FOCprod) )*100;
                decimal discprod=prods.get(FOCprod).Discount__c;
                if (discountLine < (discprod- 1)   || discountLine > (discprod +1 )) throwError=True;
            }
        }
        return throwError;
    }*/
    public static string quantityMultipleBasicUnits(list<opportunityLineItem> OLIs)
    {
        string unitException;
        map<id,decimal> productsTotalQuantity=new map<id,decimal>();
        
        for(opportunityLineItem OLI:OLIS)
        {
            if(productsTotalQuantity.containsKey(OLI.product2Id) && OlI.Quantity!=null)
            {
                decimal total=productsTotalQuantity.get(OLI.product2ID) + OLI.NUM_Quantity_litres_CP__c;
                system.debug(productsTotalQuantity.get(OLI.product2ID) +'-'+OLI.NUM_Quantity_litres_CP__c);
                productsTotalQuantity.put(OLI.product2ID, total);    
            }else{
                
                productsTotalQuantity.put(OLI.product2ID, OLI.NUM_Quantity_litres_CP__c);
                
            }      
        
        }
        
        list<product2> usedProds=new list<product2>();
        
        usedProds=[Select id,name,DE_BasicUnits__c from Product2 where id IN:productsTotalQuantity.keySet()];
        
        for(product2 prod:usedProds)
        {
            if(Math.Mod(integer.valueOF(productsTotalQuantity.get(prod.id)),integer.valueOF(prod.DE_BasicUnits__c)) !=0)
            {
               if(String.isNotBlank(unitException)) unitException+='\r\n\n The quantity in litres for '+prod.name+' has to be multiple of '+prod.DE_BasicUnits__c + '. ';
               else unitException='\r\n\n The quantity in litres for '+prod.name+' has to be multiple of '+prod.DE_BasicUnits__c + '. ';
            } 
        }
        if(string.isnotBlank(unitException))unitException=' Errors in opportunity lines:'+  unitException;
        return unitException;
    
    }

    private static void generateBackupDocument(HttpRequest req, HttpResponse res, String reason){

        String documentName=Util.currentUser.Alias + reason + string.valueOf(system.currentTimeMillis());
        String req_URL = req.getEndpoint();
        String req_Body = req.getBody();
        String res_status = res.toString(); 
        String res_Body = res.getBody();       
        String[] List_body_header_keys=res.getHeaderKeys();
        Map<String,String> Map_Key_Header = new Map<String,String>();                
        for (String header_key : List_body_header_keys){
            if(header_key != null){
                Map_Key_Header.put(header_key, res.getHeader(header_key));
            }
        }

        String body = '[REQUEST]\n' +'\n[REQUEST URL]\n' + req_URL + '\n[REQUEST BODY]\n' + req_Body + '\n\n[RESPONSE]\n' + '\n[RESPONSE STATUS]\n' + res_status + '\n[RESPONSE HEADER]\n' +System.JSON.serializePretty(Map_Key_Header) + '\n[RESPONSE BODY]\n' + res_Body;
        Blob documentBody= Blob.valueOf(body);
        Document doc= new Document(Name = documentName , body=documentBody, developerName=documentName, IsPublic = true, FolderId=label.OE2_0_Conn_Error_Logs, contentType='text/plain',type='json' );
        insert doc;
    }
    
    public class MyException extends Exception {}
    

    public class OrderToSend
    {  
        public OrderHeader OrderHeader=new OrderHeader();
        public OrderItems OrderItems=new OrderItems();
        public orderHPartner orderHPartner=new orderHPartner();
    } 
    class OrderHeader
    {
        public string salesDistrict {get;set;}
        public string deliveryBlock {get;set;}        
        public string billingBlock {get;set;}                
        public string orderType {get;set;}
        public string orderReason {get;set;}
        public string salesOrg {get;set;}
        public string distChannel {get;set;}
        public string division {get;set;}
        public string soldtoParty {get;set;}        
        public string poNumber {get;set;}
        public string salesRep {get; set;}
        public String areaManager {get; set;}
        public string paymentTerms {get;set;}
        public string deliveryDate {get;set;}
        public string headerText {get;set;} 
        /*Only for turkey*/ public string priceDate {get;set;}
        
        public shipmentDetails shipmentDetails=new shipmentDetails();
        public extOrderDetails extOrderDetails = new extOrderDetails();
        
    }
    public class shipmentDetails
    {
        public string shiptoParty {get;set;}
        public string shiptoCountry {get;set;}
        public string shiptoContact {get;set;}
        public string shiptoRegion {get;set;}
        public string shiptoPhone {get;set;}
        public string shiptoCity {get;set;}
        public string shiptoName {get;set;}
        public string shiptoZipCode {get;set;}
        public string shiptoStreetAddr {get;set;}
    }
    public class extOrderDetails
    {
        public string extOrder{get;set;}
        public string extOrderSfdcId{get;set;}
        public string referenceOrder{get;set;}        
    }
    public class OrderItems
    {
        public list<Item> item=new list<Item>(); 
    }
    public class orderHPartner
    {
        public list<Item> item=new list<Item>(); 
    }
    public class Item
    {
        
        public string plant{get;set;}
        public string itemText{get;set;}
        public decimal quantity {get;set;}
        public string deliveryPriority{get;set;}
        public string clientOrderLineId{get;set;}        
        public string orderType {get;set;} 
        public string productCode{get;set;} 
        public string errorMessage{get;set;}
        public string sapOrderNumber{get;set;}
        public string sapOrderItemNumber{get;set;}
        public string partnerFn{get;set;}
        public string partnerNo{get;set;}
        public string extItemNo{get; set;}
        
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