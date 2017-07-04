/**
* @author: Accenture
* @date: 2015
* @project: Invoice PDF
*
* @group: ACS
*
* @description: Extension use to create and handle a web service to retrieve an Invoice PDF from SAP-DataPower.
* 				Extension is used in the ACSInvoicePDF_VFP visualforce page. 
*				Visualforce page is called by a button in the Invoice__c object.
*/
public class ACSInvoicePDF_Controller {
   
    private final Invoice__c invoiceRec;
    public String processingError {get;set;}    
    
    public ACSInvoicePDF_Controller(ApexPages.StandardController stdController) {
        this.invoiceRec = (Invoice__c)stdController.getRecord(); 
        processingError = '';                   
    } 
    public PageReference autoRun(){
        
        ACS_Invoice_PDF_CS__c CS = ACS_Invoice_PDF_CS__c.getOrgDefaults();//'ACS Invoice PDF'
        String attId = '';
        String invrecId = ApexPages.currentPage().getParameters().get('id');        
        for(Invoice__c inv : [SELECT Id, Name, GC_Integration_Key__c, Invoice_PDF_Att_Id__c FROM Invoice__c WHERE Id =: invrecId]){
            if(inv.Invoice_PDF_Att_Id__c == null){                
                attId = getHttpResponseHandler(inv);                              
            }else{                
                attId = inv.Invoice_PDF_Att_Id__c;                
            }
        }
        if(attId== null || attId=='hasError'){
            processingError = getErrorMessage(processingError);
            return null;           
        }
                
        PageReference pageRef = new PageReference(CS.View_PDF_URL__c + attId);//'/servlet/servlet.FileDownload?file='
        pageRef.setRedirect(true);
        System.debug('autoRun : pageRef: ' + pageRef);
        return pageRef;
    }  
    
    /*******************************************************************************************************
    * @description: Returns the results from the response of the web service (Base64 InvoicePDF or Errors)
    * @param: invoiceRec the record that in involved in the transaction.    
    * @return HttpResponseHandler the Base64 InvoicePDF or Errors
    * @example
    * 
    */    
    public String getHttpResponseHandler(Invoice__c invoiceRec){
        
        String HttpResponseHandler = 'hasError';
        String docXml = '<?xml version="1.0" encoding="UTF-8"?>'; 
        String envelopeEnd = '</SOAP:Envelope>';
        String base64Start = '<ns1:Base64Data>';
        String base64End = '</ns1:Base64Data>' ;
        String errorTextStart = '<ns1:ErrorMessageText>';
        String errorTextEnd = '</ns1:ErrorMessageText>';
        String faultStringStart = '<faultstring>';
        String faultStringEnd = '</faultstring>';
        String resStr = getHttpResponse(invoiceRec.GC_Integration_Key__c);
        System.debug('getHttpResponseHandler :'+resStr);
        
        if(resStr.contains(docXml)){        	
            if(resStr.contains(base64Start)){            	
                HttpResponseHandler = getAttachment(invoiceRec.GC_Integration_Key__c, resStr.substring(resStr.indexOf(base64Start)+base64Start.length(), resStr.indexOf(base64End)), invoiceRec.Id);                    
            }
            if(resStr.contains(errorTextStart)){              	                    
                processingError = resStr.substring(resStr.indexOf(errorTextStart )+ errorTextStart.length(), resStr.indexOf(errorTextEnd));         
            } 
            if(resStr.contains(faultStringStart)){              	                
                processingError = resStr.substring(resStr.indexOf(faultStringStart )+ faultStringStart.length(), resStr.indexOf(faultStringEnd));           
            }               
        }else{        	
            processingError = resStr;       
        }     
        return HttpResponseHandler;
    }  
    
    /*******************************************************************************************************
    * @description: Returns response from the web service
    * @param: invoiceId the number of the Invoice to be rerieved from SAP.    
    * @return the HttpResonse string or Exception
    * @example
    * 
    */
    public String getHttpResponse(String invoiceId){
         
        String httpResponse = '';        
        ACS_Invoice_PDF_CS__c CS = ACS_Invoice_PDF_CS__c.getOrgDefaults();        
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(CS.End_Point_URL__c);//'https://mongateway-d.monsanto.com:8443/PDFReportingService'
            req.setMethod('POST');
            req.setBody(getRequestStr(invoiceId));
            req.setClientCertificateName(CS.Certificate_Name__c);//'MON_US_SFDC_CastIron_Integration_Certificate_1'
            req.setTimeout(Integer.valueOf(CS.Request_Time_Out__c));//3000
            Http http = new Http();           
            HTTPResponse res = http.send(req);            
            httpResponse = res.getBody();                       
        }catch(Exception e){httpResponse = e.getMessage();}               
        return httpResponse; 
    }
    
    /*******************************************************************************************************
    * @description: Returns the id string when the Invoice PDF was succesfully attached to the Invoice__c record.
    * @param: invoiceId the number of the Invoice to be rerieved from SAP.
    * @param: blobString HttpResponse from the web service.
    * @param: parentId he record id to attach the Invoice PDF
    * @return attId the attachent Id to show in the visualforce page.
    * @example
    * 
    */
    public String getAttachment(String invoiceId, String blobString, String parentId){        
        
        String attId = 'hasError';
        transient Blob blbPDFContent = EncodingUtil.base64Decode(blobString);
        transient Attachment attachmentPDF = new Attachment();
        attachmentPdf.ParentId = parentId;
        attachmentPdf.Name = invoiceId+'.pdf ';
        attachmentPdf.ContentType = 'application/pdf';
        attachmentPdf.IsPrivate = false;
        attachmentPdf.Body = blbPDFContent;
        try{
            insert attachmentPDF;
            attId = String.valueOf(attachmentPDF.Id);
        }catch(Exception e){attId = 'hasError';System.debug('getAttachment hasError : ' + e.getMessage());}         
        System.debug('getAttachment : attId ' + attId);
        return attId; 
    } 
    
    /*******************************************************************************************************
    * @description: Returns Error string in the Visualforce page in case of an error
    * @param: processingError the error that was return by SAP in the web service.
    * @return the {!processingError} String
    * @example
    * 
    */
    public String getErrorMessage(String processingError){
        
        ACS_Invoice_PDF_CS__c CS = ACS_Invoice_PDF_CS__c.getOrgDefaults();
        String errorMessage = CS.Message_Condition_Default__c;
        if(CS.Error_Condition_1__c != null){
	        if(processingError.contains(CS.Error_Condition_1__c)){        	
	            errorMessage = CS.Message_Condition_1__c;           
	        }
        }        
        if(CS.Error_Condition_2__c != null){
	        if(processingError.contains(CS.Error_Condition_2__c)){        	
	            errorMessage = CS.Message_Condition_2__c;           
	        }
        }
        if(CS.Error_Condition_3__c != null){
	        if(processingError.contains(CS.Error_Condition_3__c)){        	
	            errorMessage = CS.Message_Condition_3__c;           
	        }
        }
        if(CS.Error_Condition_4__c != null){
	        if(processingError.contains(CS.Error_Condition_4__c)){        	
	            errorMessage = CS.Message_Condition_4__c;           
	        }  
        }
        if(CS.Error_Condition_5__c != null){     
	        if(processingError.contains(CS.Error_Condition_5__c)){        	
	            errorMessage = CS.Message_Condition_5__c;           
	        } 
        } 
        System.debug('getErrorMessage' + errorMessage);     
        return errorMessage;    
    }
    
    /*******************************************************************************************************
    * @description: Returns xml string to be used in the HttpRequest to be sent to Cast Iron
    * @param: invoiceId the number of the Invoice to be rerieved from SAP.
    * @return the xml String
    * @example
    * 
    */
    public String getRequestStr(String invoiceId) {     
        //String invoiceNumber = '0100118782';
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String urn ='urn:otc:schema:reportrequest:request:1:0';
        String urn1='urn:cidx:names:specification:ces:schema:all:5:0';
        String xmlns = 'urn:otc:schema:reportresponse:response:1:0';
        String timeStr = String.valueOf(System.now());
        String partnerIdentifierFrom  = '123456789';
        String partnerIdentifierTo = '0062668030000';
        
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        xmlW.writeStartDocument('UTF-8','1.0');
        xmlW.writeStartElement('soapenv','Envelope', soapNS);
        xmlW.writeAttribute('xmlns',soapNS,'soapenv',soapNS);
        xmlW.writeAttribute('xmlns',urn,'urn',urn);
        xmlW.writeAttribute('xmlns',urn1,'urn1',urn1);
        xmlW.writeStartElement('soapenv','Header',soapNS);//Open Header 1
        xmlW.writeEndElement(); //Close Header  1           
        xmlW.writeStartElement('soapenv','Body',soapNS);//Open Body
        xmlW.writeStartElement('ns3','ReportRequest',soapNS);//Open ReportRequest
        xmlW.writeAttribute(null,null,'Version','1.0');                 
        xmlW.writeAttribute('xmlns',urn,'ns2',urn1);
        xmlW.writeAttribute(null,null,'xmlns',xmlns);
        xmlW.writeAttribute('xmlns',urn,'ns3',urn);
        xmlW.writeStartElement('ns2','Header',soapNS);//Open Header
        xmlW.writeStartElement('ns2','ThisDocumentIdentifier',soapNS);//Open ThisDocumentIdentifier
        xmlW.writeStartElement('ns2','DocumentIdentifier',soapNS);//Open DocumentIdentifier
        xmlW.writeCharacters('ACS Invoice Output_'+timeStr);
        xmlW.writeEndElement(); //Close DocumentIdentifier
        xmlW.writeEndElement(); //Close ThisDocumentIdentifier
        xmlW.writeStartElement('ns2','ThisDocumentDateTime',soapNS);//Open ThisDocumentDateTime
        xmlW.writeStartElement('ns2','DateTime',soapNS);//Open DateTime
        xmlW.writeAttribute(null,null,'DateTimeQualifier','On');    
        xmlW.writeCharacters(timeStr);                  
        xmlW.writeEndElement(); //Close DateTime
        xmlW.writeEndElement(); //Close ThisDocumentDateTime                    
        xmlW.writeStartElement('ns2','RequestingDocumentIdentifier',soapNS);//Open RequestingDocumentIdentifier
        xmlW.writeStartElement('ns2','DocumentIdentifier',soapNS);//Open DocumentIdentifier
        xmlW.writeCharacters('base64'); 
        xmlW.writeEndElement(); //Close DocumentIdentifier                  
        xmlW.writeEndElement(); //Close RequestingDocumentIdentifier
        xmlW.writeStartElement('ns2','From',soapNS);//Open From
        xmlW.writeStartElement('ns2','PartnerInformation',soapNS);//Open PartnerInformation
        xmlW.writeStartElement('ns2','PartnerName',soapNS);//Open PartnerName
        xmlW.writeCharacters('SFDC-ACS');
        xmlW.writeEndElement(); //Close PartnerName
        xmlW.writeStartElement('ns2','PartnerIdentifier',soapNS);//Open PartnerIdentifier
        xmlW.writeAttribute(null,null,'Agency','AGIIS-EBID');
        xmlW.writeCharacters(partnerIdentifierFrom);
        xmlW.writeEndElement(); //Close PartnerIdentifier
        xmlW.writeEndElement(); //Close PartnerInformation
        xmlW.writeEndElement(); //Close From
        xmlW.writeStartElement('ns2','To',soapNS);//Open To
        xmlW.writeStartElement('ns2','PartnerInformation',soapNS);//Open PartnerInformation
        xmlW.writeStartElement('ns2','PartnerName',soapNS);//Open PartnerName
        xmlW.writeCharacters('SAP ECC');
        xmlW.writeEndElement(); //Close PartnerName
        xmlW.writeStartElement('ns2','PartnerIdentifier',soapNS);//Open PartnerIdentifier
        xmlW.writeAttribute(null,null,'Agency','AGIIS-EBID');
        xmlW.writeCharacters(partnerIdentifierTo);
        xmlW.writeEndElement(); //Close PartnerIdentifier
        xmlW.writeEndElement(); //Close PartnerInformation
        xmlW.writeEndElement(); //Close To
        xmlW.writeEndElement(); //Close Header
        xmlW.writeStartElement('ns3','ReportRequestBody',soapNS);//Open ReportRequestBody
        xmlW.writeStartElement('ns3','ReportName',soapNS);//Open ReportName 
        xmlW.writeCharacters('ACS_INVOICE_OUTPUT');
        xmlW.writeEndElement(); //Close ReportName                  
        xmlW.writeStartElement('ns3','BrandInformation',soapNS);//Open BrandInformation
        xmlW.writeStartElement('ns3','BrandIdentifier',soapNS);//Open BrandIdentifier   
        xmlW.writeCharacters('NA');
        xmlW.writeEndElement(); //Close BrandIdentifier
        xmlW.writeEndElement(); //Close BrandInformation
        xmlW.writeStartElement('ns3','ReportSelectionItems',soapNS);//Open ReportSelectionItems
        xmlW.writeStartElement('ns3','ReportVariableName',soapNS);//Open ReportVariableName 
        xmlW.writeCharacters('INVOICE_NUMBER');
        xmlW.writeEndElement(); //Close ReportVariableName
        xmlW.writeStartElement('ns3','ReportVariableValue',soapNS);//Open ReportVariableValue   
        xmlW.writeCharacters(invoiceId);
        xmlW.writeEndElement(); //Close ReportVariableValue
        xmlW.writeEndElement(); //Close ReportSelectionItems
        xmlW.writeEndElement(); //Close ReportRequestBody           
        xmlW.writeEndElement(); //Close ReportRequest
        xmlW.writeEndElement(); //Close Body    
        xmlW.writeEndElement(); //Close Envelope
        xmlW.writeEndDocument(); //Close XML document

        String xmlStringxmlRes = xmlW.getXmlString();      
        xmlW.close();
        //System.debug('xmlStringxmlRes' + xmlStringxmlRes);
        return xmlStringxmlRes;
    }      
}