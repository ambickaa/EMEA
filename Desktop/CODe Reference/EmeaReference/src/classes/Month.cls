public class Month 
{
	private List<Week> weeks; 
	public Date firstDate; // always the first of the month
	public Date lastDate; // always the last day of the last week of the month
	private Date upperLeft; 
	private Integer numSemanas;

	public List<Date> getValidDateRange() 
	{ 
		// return one date from the upper left, and one from the lower right
		List<Date> ret = new List<Date>();
		ret.add(upperLeft);
		ret.add(upperLeft.addDays(numSemanas*7) );
		system.debug('numero semanas: '+numSemanas);
		return ret;
	}

	public String getMonthName() 
	{ 
		if(firstDate.month()==lastDate.month())
			return DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).formatgmt('MMMM');
		else
			return DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).formatgmt('MMMM')+' - '+DateTime.newInstance(lastDate.year(),lastdate.month(),lastdate.day()).formatgmt('MMMM');
	} 

	public String getYearName() 
	{ 
		return DateTime.newInstance(
		firstDate.year(),firstdate.month(),firstdate.day()).format('yyyy');
	} 

	public String[] getWeekdayNames()
	{ 
		Date today = system.today().toStartOfWeek();
		DateTime dt = DateTime.newInstanceGmt(today.year(),today.month(),today.day());		
		list<String> ret = new list<String>();
		for(Integer i = 0; i < 5;i++)
		{ 
			ret.add( dt.formatgmt('EEEE') );
			dt= dt.addDays(1);
		} 
		return ret;
	}

	public Date getfirstDate() 
	{
		return firstDate;
	} 
	
	public Date getLastDate()
	{
		return lastDate;
	}

	public Month( Date value, Integer num ) 
	{
		numSemanas = num;
		if(numSemanas == 1)
		{
			//Mostraremos solo la semana actual
			weeks = new List<Week>();
			firstDate = value.toStartOfWeek();
			upperLeft = firstDate.toStartOfWeek();
			Date tmp = upperLeft;
			Week w = new Week(1,tmp,value.month());	
			system.assert(w!=null); 
			this.weeks.add( w );
			tmp = tmp.addDays(7);
		}
		else
		{
			weeks = new List<Week>();
			firstDate = value.toStartOfWeek();
			upperLeft = firstDate.toStartOfWeek();
			Date tmp = upperLeft;
			for (Integer i = 0; i < numSemanas; i++) 
			{
				Week w = new Week(i+1,tmp,value.month());	
				system.assert(w!=null); 
				this.weeks.add( w );
				tmp = tmp.addDays(7);
			}
				lastDate = tmp.addDays(-3);
				
		}
	}

	public void setCases(List<Change_Request__c> cases) 
	{ 
		// merge these events into the proper day 
		for(Change_Request__c r:cases) 
		{ 
			for(Week w:weeks) 
			{ 
				for(Day d: w.getDays() ) 
				{ 
					if (r.StartTestDate__c.isSameDay(d.theDate))  
					{ 
						// add this event to this calendar date
						d.casesToday.add(new CaseItem(r));
						// add only three events, then a More... label if there are more
					} 
				} 
			} 
		}
	}

	public List<Week> getWeeks() 
	{ 
		system.assert(weeks!=null,'could not create weeks list');
		return this.weeks; 
	}

	/* 
	* helper classes to define a month in terms of week and day
	*/
	public class Week 
	{
		public List<Day> days;
		public Integer weekNumber; 
		public Date startingDate; // the date that the first of this week is on
		// so sunday of this week

		public List<Day> getDays()
		{ 
			return this.days;
		}

		public Week () 
		{ 
			days = new List<Day>(); 	
		}
		public Week(Integer value,Date sunday,Integer month)
		{ 
			this();
			weekNumber = value;
			startingDate = sunday;
			Date tmp = startingDate;
			for (Integer i = 0; i < 5; i++) {
			Day d = new Day( tmp,month ); 
			tmp = tmp.addDays(1);
			d.dayOfWeek = i+1;  		
			//	system.debug(d);
			days.add(d);
			} 
		}
		public Integer getWeekNumber() { return this.weekNumber;}
		public Date getStartingDate() { return this.startingDate;}
	}
	
	public class Day 
	{

		public Date 		theDate;
		public List<CaseItem> 	casesToday; // list of events for this date
		public Integer 		month, dayOfWeek;
		public String 		formatedDate; // for the formated time 	
		private String 		cssclass = 'resActive';

		public Date 		getDate() { return theDate; }
		public Integer 		getDayOfMonth() { return theDate.day(); }
		public String 		getDayOfMonth2() 
		{ 
			if ( theDate.day() <= 9 ) 
				return '0'+theDate.day(); 
			return String.valueof( theDate.day()); 
		}
		public Integer getDayOfYear() { return theDate.dayOfYear(); }
		public List<CaseItem> 	getDayAgenda() { return casesToday; }
		public String 		getFormatedDate() { return formatedDate; }
		public Integer 		getDayNumber() { return dayOfWeek; }
		public List<CaseItem> 	getcasesToday() { return casesToday; }
		public String 		getCSSName() { 	return cssclass; }

		public Day(Date value,Integer vmonth) 
		{ 
			theDate=value; month=vmonth; 		
			formatedDate = '12 21 08';// time range..
			//9:00 AM - 1:00 PM
			casesToday = new List<CaseItem>();  
			// three possible Inactive,Today,Active	 
			if ( theDate.daysBetween(System.today()) == 0 ) 
				cssclass ='resToday';
			// define inactive, is the date in the month?
			if ( theDate.month() != month) 
				cssclass = 'resInactive';
		}
	}
}