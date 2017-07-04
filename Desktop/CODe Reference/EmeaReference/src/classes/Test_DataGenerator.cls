public class Test_DataGenerator 
{
	public static void generateCountries()
	{
		if([SELECT ID FROM COUNTRY__C].size()==0)
		{
			List<Country__c>countries = new List<Country__c>();
			countries.add(new Country__c(name='France'));//0
			countries.add(new Country__c(name='Germany'));//1
			countries.add(new Country__c(name='Hungary'));//2
			countries.add(new Country__c(name='Italy'));//3
			countries.add(new Country__c(name='Romania'));//4
			countries.add(new Country__c(name='South Africa'));//5
			countries.add(new Country__c(name='Spain'));//6
			countries.add(new Country__c(name='Switzerland'));//7
			countries.add(new Country__c(name='Turkey'));//8
			countries.add(new Country__c(name='Ukraine'));//9
			countries.add(new Country__c(name='United Kingdom'));//10
			countries.add(new Country__c(name='Ireland'));//11
			countries.add(new Country__c(name='Austria'));//12
			countries.add(new Country__c(name='Bulgaria'));//13
			countries.add(new Country__c(name='Denmark'));//14
			countries.add(new Country__c(name='Estonia'));//15
			countries.add(new Country__c(name='Finland'));//16
			countries.add(new Country__c(name='Latvia'));//17
			countries.add(new Country__c(name='Lithuania'));//18
			countries.add(new Country__c(name='Norway'));//19
			countries.add(new Country__c(name='Portugal'));//20
			countries.add(new Country__c(name='Sweden'));//21
			
			
			insert countries;
			countries.get(7).Area__c = countries.get(1).id;
			countries.get(11).Area__c = countries.get(10).id;
			countries.get(12).Area__c = countries.get(1).id;
			countries.get(13).Area__c = countries.get(4).id;
			countries.get(14).Area__c = countries.get(10).id;
			countries.get(15).Area__c = countries.get(10).id;
			countries.get(16).Area__c = countries.get(10).id;
			countries.get(17).Area__c = countries.get(10).id;
			countries.get(18).Area__c = countries.get(10).id;
			countries.get(19).Area__c = countries.get(10).id;
			countries.get(20).Area__c = countries.get(6).id;
			countries.get(21).Area__c = countries.get(10).id;
			update countries;
		}
	}
	
	public static void generateDivisions()
	{
		if([SELECT ID FROM DIVISION__C].size()==0)
		{
			List<Division__c>divisions = new List<Division__c>();
			divisions.add(new Division__c(name = 'OSR'));
			divisions.add(new Division__c(name = 'Corn'));
			divisions.add(new Division__c(name = 'CP'));
			insert divisions;
		}
	}
	
	
	public static void generateYears()
	{
		if([SELECT ID FROM YEAR__c].size()==0)
		{
			List<Year__c>years = new List<Year__c>();
			Integer aYear = Date.today().year()-2;
			for(Integer i = 0; i<100; i++)
			{
				years.add(new Year__c(name=String.valueOf(aYear+i), YearStartDate__c = Date.newInstance(aYear+i, 1, 1), YearEndDate__c= Date.newInstance(aYear+i, 12, 31)));
			}
			insert years;
			
			for(Integer i = 1; i<years.size()-1; i++)
			{
				years.get(i).YearPreviousYear__c = years.get(i-1).id;
				years.get(i-1).YearNextYear__c = years.get(i).id;
			}
			years.get(2).Current_Year__c = true;
			update years;
			
		}
	}
	
	
	public static void generateProductCatalog()
	{
		if([SELECT ID FROM ProductCatalog__c].size()==0)
		{
			List<ProductCatalog__c>productCatalogs = new List<ProductCatalog__c>();
			
			List<Division__c>divisions = [SELECT ID FROM Division__c];
			for(Country__c c : [SELECT ID FROM Country__c])
			{
				productCatalogs.add(new ProductCatalog__c(name='xyz', RecordTypeId = Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog'), YearRef__c = Util.currentYear.id, CountryRef__c = c.id));
				productCatalogs.add(new ProductCatalog__c(name='xyz', RecordTypeId = Util.recordType.get('ProductCatalog__c:MarketingProductCatalog'), YearRef__c = Util.currentYear.id, CountryRef__c = c.id));
				for(Division__c d : divisions)
				{
					productCatalogs.add(new ProductCatalog__c(name= 'xyz', CountryRef__c = c.id, DivisionRef__c = d.id, YearRef__c = Util.currentYear.id, RecordTypeId = Util.recordType.get('ProductCatalog__c:SalesProductCatalog')));
					productCatalogs.add(new ProductCatalog__c(name= 'xyz', CountryRef__c = c.id, DivisionRef__c = d.id, YearRef__c = Util.currentYear.id, RecordTypeId = Util.recordType.get('ProductCatalog__c:TrialsProductCatalog')));
				}
			}
			insert productCatalogs;
			update productCatalogs;
		}
	}
	
}