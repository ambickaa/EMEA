public with sharing class ProdTransController{
    //Store translation for only one Country
    public static Map<id, String> mapTranslations;
    //Store default translation
    public static Map<id, String> mapDefaults;
    //Store user's Country
    private static String country;
    
    //Initializate translation map for the user
    public static void initMapTrans(){
        initMapTrans(UserInfo.getUserId());
    }
    
    public static void initMapTrans(id user){
        if (mapTranslations == null){ 
        	mapTranslations = new Map<id,String>();
            //Check if this user's country is translatable
            if (isTranslatable(user)){
                List<ProductTranslation__c> listProdTrans = [select ProductGroupingRef__c, Translation__c from ProductTranslation__c where CountryRef__r.Name = :country];
                Map<id, String> mapProdTrans = new Map<id, String>();
                for (ProductTranslation__c pTrans: listProdTrans){
                    mapProdTrans.put(pTrans.ProductGroupingRef__c, pTrans.Translation__c);
                }
                mapTranslations=mapProdTrans.clone();
            }
        }
        if (mapDefaults == null){ //Extract the default values for translation
            List<Product_Grouping__c> listProdDefault = [select Id, Name from Product_Grouping__c];
            Map<id, String> mapProdDefault = new Map<id, String>();
            for (Product_Grouping__c pDefault: listProdDefault ){
                mapProdDefault.put(pDefault.Id, pDefault.Name);
            }
            mapDefaults=mapProdDefault.clone();
            mapProdDefault.putAll(mapTranslations);
            mapTranslations=mapProdDefault.clone();
        }
    }
    
    //get translation for one id
    public static String getTranslation(Id idProd){
        return getTranslation(idProd, UserInfo.getUserId());
    }
    
    public static String getTranslation(Id idProd, Id user){
        initMapTrans(user);
        if (mapTranslations.get(idProd) != null){
            return  mapTranslations.get(idProd);
        }
        else{ //in case there is no translation return the Product Grouping Name
            return mapDefaults.get(idProd);
        }
    }
    
    //get translation for a list of ids
    public static Map<id, String> getTranslation(List<Id> listIdProd){
        return getTranslation(listIdProd, UserInfo.getUserId());
    }
    
    public static Map<id, String> getTranslation(List<Id> listIdProd, Id user){
       initMapTrans(user);
       Map<id, String> mapTrans = new Map<id, String>();
       for (Id idProd: listIdProd){
           String prodTrans = getTranslation(idProd, user);
           mapTrans.put(idProd,prodTrans);
       }
       return mapTrans;
    }
    
    //Check is the user's country is translatable
    public static boolean isTranslatable(){
        return isTranslatable(UserInfo.getUserId());
    }
       
    public static boolean isTranslatable(Id user){  
        if (country == null) {
            List<User> listUser= [select Country from User where id = :user];
            if (listUser.size()==0){
            	
            	return false;
            }
            country = listUser[0].Country;
            if (country == null){ //If the country does not exists 
                return False;
            }
        }
        String pString = 'select ProductTranslation__c from Country__c where Name =\'' + country+ '\'';
        
        //List<Country__c> listCountries= [select ProductTranslation__c from Country__c where Name = :country];
        List<Country__c> listCountries= (List<Country__c>) Database.query(pString);
        if (listCountries.size() == 0){
        	return false;
        }
        return listCountries[0].ProductTranslation__c;
   }
}