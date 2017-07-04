/* He intentado optimizar el proceso al máximo para evitar el timeout de las Visualforce */

public class importDataFromCSVController {
    
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public Campaign caSel{get;set;}
    public Id folderId {get;set;}
    
    public importDataFromCSVController(){
        folderId=Id.ValueOf(SystemSettings__c.getValues('NFULOADS_FOLDERID').Value__c);
        init();
    }
    public void init(){
        caSel=new Campaign();
        csvFileBody=null;
        csvAsString=null;
    }
    public PageReference importCSVFile(){
        if(caSel.CountryRef__c <> null && caSel.YearV2__c <> null && caSel.DivisionRef__c <> null && csvFileBody <> null && csvAsString <> null){
            if([SELECT Id FROM Document WHERE FolderId=:folderId AND DeveloperName LIKE 'NFUSalesToInsert%'].size()>0){
                Util.AddErrorMessage('There is already an NFU sales upload process. Please wait it finishes to start a new one.');
                init();
                return null;
            } else {      
                Document doc= new Document(Name = 'NFU Sales To Insert', 
                                           body=csvFileBody,
                                           developerName='NFUSalesToInsert'+(String.valueOf(System.now())).remove(':').remove(' ').remove('-'), 
                                           IsPublic = true, 
                                           FolderId=folderId, 
                                           contentType='csv');      
                insert doc;
                System.debug('***** Doc insertado:'+doc);
                importdatafromCSVBatch bc = new importdatafromCSVBatch(doc.id, caSel.CountryRef__c,caSel.YearV2__c, caSel.DivisionRef__c, system.now());
                Database.executeBatch(bc,1);
                Util.addConfirmMessage('The CSV file has been uploaded. The upload process may take a while.'); 
                init(); 
                return null;
            }
        }
        else Util.AddWarningMessage('Please, fill in all required fields and/or attach a CSV file.');   
        return null;
    }
}