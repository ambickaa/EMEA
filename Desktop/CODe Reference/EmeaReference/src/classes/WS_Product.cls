global with sharing class WS_Product {
	

	private static Map<String, String> mapFormulaFields{
		get{
			if (mapFormulaFields == null){
				mapFormulaFields = new Map<String, String>();
				mapFormulaFields.put('Treatment__c','ProductRef__r.ProductTreatment__c');
				mapFormulaFields.put('Provider__c','Vendor__c');
				mapFormulaFields.put('Humidity__c','ProdHumidity__c');
			}
			return mapFormulaFields;
		}
		set;
	}	
	
	private static String selectFields{
		get {
			if (selectFields == null){
				selectFields = '';
				for (String key : mapFormulaFields.keySet()){
					selectFields += mapFormulaFields.get(key) + ', ';
				}
				selectFields= selectFields.subString(0, selectFields.length() - 2);
			}
			return selectFields;
		}
		set;
	}
	
	private static Map<String, String> getPOGPYByProduct(String idProd, String accountId){ //agregar excepcion
		Util.setCurrentAccount(accountId);
		Map<String, String> mapPOG = new Map<String, String>();
		Decimal pogpy = Decimal.valueOf('0');
		if (Util.previewsCampaign != null){
			Id recordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'); 
			String pString = 'SELECT sum(POG__c) POGPY FROM CampaignLineItem__c WHERE ProductRef__c = \'' + idProd + '\'';
			pString += ' AND POG__c != null AND CampaignRef__c = \'' + Util.previewsCampaign.Id + '\'';
			pString += ' AND RecordTypeId = \'' + recordTypeId + '\'';
			List<AggregateResult> resultList = (List<AggregateResult>) Database.query(pString);
			if (resultList != null){
				if (resultList[0].get('POGPY') != null){
					pogpy = (Decimal) resultList[0].get('POGPY');
				}
			}
			
		}
		mapPOG.put('POGPY__c', pogpy.toPlainString());
		return mapPOG;
	}
	private static Map<String, String> getIsCompetitor(String idProd, String accountId){
		//ProductRef__r.ProductVendor__r.RecordTypeId
		Util.setCurrentAccount(accountId);
		Map<String, String> mapIsCompetitor = new Map<String, String>();
		String pString = 'SELECT ProductRef__r.ProductVendor__r.RecordTypeId FROM ProductCatalogEntry__c WHERE ProductRef__c = \'' +idProd+ '\' and ProductCatalogRef__c = \'' + Util.currentCampaign.SalesPCMRef__c+'\'';
		Map<Id, ProductCatalogEntry__c> mapOfPRecType= new Map<Id, ProductCatalogEntry__c>((List<ProductCatalogEntry__c>)Database.query(pString));
		ProductCatalogEntry__c prodRecType = new ProductCatalogEntry__c();
		
		if (mapOfPRecType.size() > 0){
			prodRecType = mapOfPRecType.values()[0];
		} else {
			return null;
		}
		mapIsCompetitor.put('isCompetitor', (prodRecType.ProductRef__r.ProductVendor__r.RecordTypeId == Util.recordType.get('Account:Competitor'))? 'True':'False');
		return mapIsCompetitor;
	}
	webservice static String getProductInjectFields(String idProd, String accountId, String div){
		System.debug('idProd: '+idProd +' accountId: '+accountId + ' div: '+div);
		Util.setCurrentAccount(accountId);
		if (div != null && div.trim().length() > 0){
			Util.urlParameters.put('division', div);
		}
		String pString = 'SELECT ' + selectFields;
		pString += ', ProductRef__c FROM ProductCatalogEntry__c WHERE ProductRef__c = \'' +idProd+ '\' and ProductCatalogRef__c = \'' + Util.currentCampaign.SalesPCMRef__c+'\'';
//		return pString;
		Map<Id, ProductCatalogEntry__c> mapOfP= new Map<Id, ProductCatalogEntry__c>((List<ProductCatalogEntry__c>)Database.query(pString));
		ProductCatalogEntry__c prodCatEntry = new ProductCatalogEntry__c();
		if (mapOfP.size() > 0){
			prodCatEntry = mapOfP.values()[0];
		} else {
			return JSON.serialize(prodCatEntry);
		}
		Map<String, String> mapValuesFormula = new Map<String,String>();
		for (String fieldKey : mapFormulaFields.keySet()){
			String fieldValue = mapFormulaFields.get(fieldKey);

			if (fieldValue.contains('.')){
				List<String> listFields = fieldValue.split('\\.');
				sObject so = prodCatEntry.getsObject(listFields[0]);
				

				mapValuesFormula.put(fieldKey, string.valueOf(so.get(listFields[1])));
				
			} else {

				mapValuesFormula.put(fieldKey, string.valueOf(prodCatEntry.get(fieldValue)));
			}

		}
		mapValuesFormula.putAll(getPOGPYByProduct(idProd, accountId));
		System.debug('mapValuesFormula getPOGPYByProduct : ' + mapValuesFormula);
		mapValuesFormula.putAll(getIsCompetitor(idProd, accountId));
		System.debug('mapValuesFormula getIsCompetitor : ' + mapValuesFormula);
		
		Map<String, Map<String, String>> mapJSONProduct = new Map<String, Map<String, String>>();
		mapJSONProduct.put(idProd,mapValuesFormula);
		
		return JSON.serialize(mapJSONProduct);
	}
	
}