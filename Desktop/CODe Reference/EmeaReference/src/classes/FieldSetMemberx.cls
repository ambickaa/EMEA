public virtual class FieldSetMemberx 
{
	public String label
	{
		get
		{
			if(label <> null)
			{
				return label;
			}
			else
			{
				return fieldSetMember.getLabel();
			}
			
		} 
		set;
	}
	public String fieldPath
	{
		get
		{
			if(fieldPath <> null)
			{
				return fieldPath;
			}
			else
			{
				return fieldSetMember.getFieldPath();
			}
		} 
		set;
	}
	
	public boolean required
	{
		get
		{
			if(required <> null)
			{
				return required;
			}
			else
			{
				return fieldSetMember.getDBRequired() || fieldSetMember.getRequired();
			}
		}
		set;
	}
	
	private Schema.FieldSetMember fieldSetMember;
	
	public FieldSetMemberx(Schema.FieldSetMember fieldSetMember)
	{
		this.fieldSetMember = fieldSetMember;
	}
}