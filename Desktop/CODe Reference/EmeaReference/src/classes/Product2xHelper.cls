public with sharing class Product2xHelper
{
	public static al.AndCondition getAndConditionForProduct(String basicRelation, Product2 searchProduct)
	{
		// add search fields from Product
		al.AndCondition andConditions = new al.AndCondition();
		for (String field : Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet())
		{
			if (searchProduct.get(field) != null)
			{
				if (field == 'Name' && searchProduct.name != null)
				{
					String searchTerm = searchProduct.name.replace('*', '%');
					andConditions.add( new al.FieldCondition(basicRelation + field ).likex(searchTerm));
				} else
				{
					andConditions.add(new al.FieldCondition(basicRelation + field).equals(searchProduct.get(field)));
				}
			}
		}
		return andConditions;
	}
}