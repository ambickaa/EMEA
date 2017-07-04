public with sharing class ContactxFactory implements AccountListObjectFactory
{
	public Set<String>selectFields
	{
		get
		{
			if(selectFields == null)
			{
				selectFields = new Set<String> { 'id', 'OwnerId', 'Firstname','Lastname'};
			}
			return selectFields;
		}
		set;
	}
	
	public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
	{
		al.SoqlBuilder query = getSOQLBuilderForContactList()
			  .wherex(new al.AndCondition().add(new al.FieldCondition( 'AccountId' ).equals( accountId )))
			  .orderByx(new al.OrderBy('LastName'));
		
		List<Contactx>result = new List<Contactx>();

		for (Contact aContact : Database.query(query.toSOQL()))
		{
			result.add( new Contactx( aContact ) );
		}

		return result;
	}

	//NOTE: ON CREATION OF OPPORTUNITY, A TRIGGER WILL FIRE AND IT WILL LINK IT TO THE CORRECT CAMPAIGN
	private al.SoqlBuilder getSOQLBuilderForContactList()
	{
		return new al.SoqlBuilder().selectx( selectFields ).fromx( 'Contact' );
	}

	public AccountListObjectWrapper createAnEmptyRecord( String accountId )
	{
		return new Contactx( accountId );
	}
}