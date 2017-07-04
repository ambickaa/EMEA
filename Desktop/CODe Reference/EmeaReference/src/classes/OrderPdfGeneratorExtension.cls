public with sharing class OrderPdfGeneratorExtension {

    public transient Map<ID,CampaignLineItem__c> actionPlanInfo {get;private set;}
    public transient ID finalRecordType {get;private set;}
    public transient String DeliveryDate {get;private set;}
    public transient String PaymentDate {get;private set;}
    public transient String DeliveryInstructions {get;private set;}  
    public transient String Reason {get;private set;}
    public transient Order__c OrderRecord  {get;private set;}
    public List<String> values {get;set;}
    public String[] chars {get;set;}
      
    private ApexPages.StandardController controller;

    public OrderPdfGeneratorExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        
        ID orderID = controller.getRecord().ID;
        
        orderRecord = [SELECT ID, DeliveryDate__c, DeliveryInstructions__c, AccountRef_RSA__r.Txt_Delivery_Instructions__c, Reason__c, BagsQuantity_RSA__c,AccountRef_RSA__r.DATE_PaymentDate__c FROM Order__c WHERE  ID =:orderID ];
        
        if(orderRecord.DeliveryInstructions__c!=null)
        {
           
      
    
           
            List<String> strSplitted = orderRecord.DeliveryInstructions__c.split(' ');
            String tempAux='';
            String str1='';
            for(String str: strSplitted )
            {
                if(str.length()>=240)
                {
                    str1=str.substring(0,79)+' '+str.substring(80,159)+' '+str.substring(160,239)+' '+str.substring(240);
                }
                else if(str.length()>=160)
                {
                    str1=str.substring(0,79)+' '+str.substring(80,159)+' '+str.substring(160);
                }
                else if(str.length()>=80)
                {
                    str1=str.substring(0,79)+' '+str.substring(80);                 
                }
                else {str1=str;}
                
                tempAux=tempAux+' '+str1;
            }
            orderRecord.DeliveryInstructions__c=tempAux;
     
        }
        
        if(orderRecord.DeliveryDate__c!=null)
        {
            DeliveryDate = String.valueOf(orderRecord.DeliveryDate__c);       
            DeliveryDate= DeliveryDate.substringBefore(' ');
        }
        
        if(orderRecord.AccountRef_RSA__r.DATE_PaymentDate__c!=null)
        {
            PaymentDate = String.valueOf(orderRecord.AccountRef_RSA__r.DATE_PaymentDate__c);       
            PaymentDate = PaymentDate.substringBefore(' ');
        }

        if(orderRecord.DeliveryInstructions__c!=null)
        {
             DeliveryInstructions =orderRecord.DeliveryInstructions__c;
             Integer DeliverySize = DeliveryInstructions.length();
        }
        Integer counter=0;
        String temp='';  
        Reason ='';
        List<String> ReasonTemp = new List<String>();
        
        if(orderRecord.Reason__c!=null)
            if(orderRecord.Reason__C.length()>0)
            {
                 ReasonTemp = (orderRecord.Reason__c).split(';');   
                 counter=0;
                 for(String str: ReasonTemp)
                 {
                    counter++;
                    str=str.substringBefore(':');
                    Reason=Reason+str+' ';
                    if(counter==2)
                    {
                        Reason=Reason+'\n';
                        counter=0;
                    }
                    
                 }       
            }
     
        finalRecordType = Util.recordType.get('Order__c:FinalOrder');
        actionPlanInfo = new Map<ID,CampaignLineItem__c>([
            SELECT 
                ProductRef__r.Name,
                ProductRef__r.ProductDisplayName__c,
                ProductRef__r.ProductKernelSize__c,
                ProductRef__r.Product_Packing__c,
                ProductRef__r.ProductSAPCode__c,
                PlantingDensity__c,
                Agreed__c,
                POG__c,
                Price_Copy__c,
                TotalPrice__c
            FROM CampaignLineItem__c 
            WHERE
                (
                    PreliminaryOrderRef_RSA__c != null AND
                    PreliminaryOrderRef_RSA__c = :orderID 
                ) OR 
                (
                    FinalOrderRef_RSA__c != null AND
                    FinalOrderRef_RSA__c = :orderID
                )
                ]);
    }
    
    public void save(){
        Order__c ordeRecord= [select id,Status_RSA__c,AccountRef_RSA__r.GC_Email_Address__c,ownerID,Cancellation_Reason_RSA__c,AccountRef_RSA__r.DATE_PaymentDate__c from Order__c where Id= :controller.getRecord().id];
        
        if(Util.urlParameters.get('save') == null){
 
            final list<Attachment> relatedFiles = [select id, name from Attachment WHERE ParentID = :controller.getRecord().id];
            map<String,Attachment>fileNamesMap = new map<String,Attachment>();
            for (Attachment at:relatedFiles){
                fileNamesMap.put(at.Name,at);
            }
            
            Attachment newContract;
            string contractName;
            /*New development -Cancellation : include 'Cancelled' in pdf name */
            if(ordeRecord.Status_RSA__c=='Cancelled'){
                contractName='Contract - ' + controller.getRecord().get('Name')+' Cancelled' + '.pdf';
                newContract = new Attachment(name = contractName, parentID = controller.getRecord().ID, isprivate = false); 
            }else{
                contractName='Contract - ' + controller.getRecord().get('Name') + '.pdf';
            }
            newContract = new Attachment(name = contractName, parentID = controller.getRecord().ID, isprivate = false);
            PageReference pdf = Page.orderPdfGenerator;
            pdf.getParameters().put('id',controller.getRecord().ID);
            pdf.getParameters().put('renderAs','pdf');
            pdf.getParameters().put('save','1');
            if (fileNamesMap.get('Signature.png')!= null){
                pdf.getParameters().put('signature',''+fileNamesMap.get('Signature.png').id);
            }
            
            Blob body;
            
            try{
                body = pdf.getContent();
            } catch (VisualforceException e)
            {
                body = Blob.valueOf('Error while generating pdf' + e);
            }
            newContract.body = body;
            /* BEGIN FIX - No E-mais are sent for PDFs generated by the button */ 
            /*New Development -Cancellation : send mails in the same way as new Order  */
            /*if(ordeRecord.Status_RSA__c!='Cancelled'){
                sendMail(attach,UserInfo.getUserEmail());
            }else{
                 map<Id,String>CancelReason=new Map<Id,String>();
                 Cancelreason.put(ordeRecord.Id,ordeRecord.Cancellation_Reason_RSA__c);
                 map<String, String> paramCco = new map<String, String>();
                 User usersInfo = [SELECT Name, UserRole.Name, email FROM User WHERE Id =: ordeRecord.ownerID limit 1];
                 for(String region : Label.RSA_REGIONS_MAILS.replace('\n','').replace('\r','').split(';')) 
                     paramCco.put(region.split('#')[0].replace('\n',''),region.split('#')[1]);
                 
                 Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[usersInfo.UserRole.Name.split(' - RSA - ').size()-1];
                 emails[0]=REST_OrderPdfGenerator.sendToMail(attach,UserInfo.getUserEmail(),attach.description, CancelReason);
                 if(usersInfo.UserRole.Name.split(' - RSA - ').size()>1)
                    emails[1]=REST_OrderPdfGenerator.sendCCMail(attach,UserInfo.getUserEmail(),usersInfo.UserRole.Name.split(' - RSA - ')[usersInfo.UserRole.Name.split(' - RSA - ').size()-1],CancelReason);
                
                 try{
                      Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,false);
        
                      if(!r[0].isSuccess())
                        system.debug('Send mail error: '+r[0].getErrors().get(0).getMessage());
                 }
                 catch(Exception e) {
                 } 
            }*/
            /*End New Development -Cancellation */
            /* END FIX - No E-mais are sent for PDFs generated by the button */
            /*Delete old contract (if exists) and save the new one*/
            try{
                if (fileNamesMap.get(contractName)!= null){
                    delete fileNamesMap.get(contractName);
                }
                insert newContract;
            }catch(Exception e){
                system.debug('error saving contract, caused by: '+ e);
            }
        }
    }
    /* BEGIN FIX - No E-mais are sent for PDFs generated by the button */ 
    /*private void sendMail(Attachment paramAttach, String paramTo){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(paramAttach.name);
        efa.setBody(paramAttach.body);
        
        email.setSubject( 'A contract has been created' );
        email.setToAddresses( paramTo.split(':') );
        email.setPlainTextBody( 'This is the Contract you have just generated' );

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); // Sends the email 
    
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   

    }*/
    /* END FIX - No E-mais are sent for PDFs generated by the button */  
    
}