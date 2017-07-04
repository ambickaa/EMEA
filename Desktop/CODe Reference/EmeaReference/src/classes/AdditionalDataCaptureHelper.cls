/**
 * This class provides methods for Additional Data Capture functionality.
 * 
 * @author  Accenture
 * @version  1.0
 * 
 */ 
public class AdditionalDataCaptureHelper{

    /**
     * This method insert/update additional data capture on case update
     * 
     * @param  lstcase  List of cases
     * @param  mapOldCase  Map of cases with old values
     * @returns  Nothing
     * @throws  Nothing
     * @since  1.0
     * 
     */ 
    public static void caseupdate(List<Case> lstcase,Map<Id,Case> mapOldCase){
        String[] adcstr = new String[]{};
        Set<String> setCaseIDs = new Set<String>();
        String strSelectFlds = '';
        SObjectType objType = Schema.getGlobalDescribe().get('Additional_Data_capture__c');
        List<Additional_Data_capture__c> lstSObject = new List<Additional_Data_capture__c>();
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        Map<String,String> mapLabelAPIName = new Map<String,String>();
        Map<String,String> mapLabelDataType = new map<String,String>();
        Map<Id,Additional_Data_capture__c> mapAddCap = new Map<Id,Additional_Data_capture__c>();
        List<Additional_Data_capture__c> lstAddionalDatCap = new List<Additional_Data_capture__c>();
        Additional_Data_capture__c sObj;
        
        //get the label and field name map for Additional_Data_Capture object
        //create a list of fields api names separated by comma

        for(string fieldName : mfields.keySet()){
            mapLabelAPIName.put(mfields.get(fieldName).getDescribe().getLabel(),fieldName);
            mapLabelDataType.put(mfields.get(fieldName).getDescribe().getLabel(),String.valueOf(mfields.get(fieldName).getDescribe().getType()));
            strSelectFlds = strSelectFlds + fieldName + ','; 
        }
        //remove comma at the end of fields string
        if (strSelectFlds.length() > 0) {
            strSelectFlds = strSelectFlds.left(strSelectFlds.length()-1);
         }
        //if case is having additional data capture field filled up consider the case for updating the related additional data capture object record
        for(Case c:lstcase){
            if(c.GC_Additional_Data_Capture_Descr__c != null){
        setCaseIDs.add(c.id);                     
            }
            
        }
        //get existing additional data capture related to the cases
        if (setCaseIds!=null){
            if (setCaseIds.size()>0){
                lstAddionalDatCap = (List<Additional_Data_capture__c>) Database.query('SELECT ' + strSelectFlds + ' FROM Additional_Data_capture__c WHERE Case_ADC__c IN :setCaseIDs');
                for (Additional_Data_capture__c addRec:lstAddionalDatCap ){
                    mapAddCap.put(addRec.Case_ADC__c,addRec);  
                }
            }
        }
        //if case has additional data capture associated with it, consider the record for an update, insert new record otherwise
        for(Case c:lstcase){
            if(c.GC_Additional_Data_Capture_Descr__c != null 
               && mapOldCase.get(c.Id).GC_Additional_Data_Capture_Descr__c != c.GC_Additional_Data_Capture_Descr__c){
                if (mapAddCap.containsKey(c.Id)){
                    sObj = mapAddCap.get(c.Id); 
                }
                else {
                  sObj = (Additional_Data_capture__c)Schema.getGlobalDescribe().get('Additional_Data_capture__c').newSObject() ;
                    sObj.put('Case_ADC__c',c.Id);
                }
                   
                adcstr = c.GC_Additional_Data_Capture_Descr__c.split('\n');
                for(Integer i=0;i<adcstr.size();i++){
                    String[] stradcvalue=adcstr[i].split(': ');
                    if(stradcvalue.size()>1 ){ 
                        if(mapLabelDataType.get(stradcvalue[0])=='BOOLEAN'){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),boolean.valueOf(stradcvalue[1]));
                        }else if(mapLabelDataType.get(stradcvalue[0])=='STRING'){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),stradcvalue[1]);
                        }else if(mapLabelDataType.get(stradcvalue[0])=='DOUBLE'){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),Integer.valueOf(stradcvalue[1]));
                        }else if(mapLabelDataType.get(stradcvalue[0])=='date'){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),stradcvalue[1]);
                        }else if(mapLabelDataType.get(stradcvalue[0])=='PICKLIST'){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),stradcvalue[1]);
                        }else if(mapLabelAPIName.containsKey(stradcvalue[0]) && null != stradcvalue[1]){
                            sObj.put(mapLabelAPIName.get(stradcvalue[0]),stradcvalue[1]);
                        }
                    }
                }
                lstSObject.add(sObj);
            }
        }
        if(!lstSObject.isEmpty())
          Database.upsert(lstSObject);
    }
}