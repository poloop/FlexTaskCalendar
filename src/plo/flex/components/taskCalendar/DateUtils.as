package plo.flex.components.taskCalendar
{
	

	public class DateUtils
	{
		public static function getDaysInMonthByYear( month : uint, year : uint) : uint{
			var _dayLength : Number = Date.UTC(1976, 11, 13) - Date.UTC(1976, 11, 12);
			var nb : uint = (month < 11) ? (Date.UTC(year, month + 1, 1) - Date.UTC(year, month, 1)) / _dayLength : (Date.UTC(year + 1, 0, 1) - Date.UTC(year, month, 1)) / _dayLength;
			return nb;
		}

		/**
		 *	ISO-8601 Week Number - V 1.1
		 *	Processes the week number of a date,
		 *	just like date("W") would do in PHP.
		 *
		 *	Procedure by Rick McCarty, 1999
		 *	Adapted to CVI by R.Bozzolo, 2006
		 *	Adapted to AS2/AS3 by A.Colonna, 2008
		 *
		 */
		public static function calculateISO8601WeekNumber(d:Date) : uint
		{
			// 1) Convert date to Y M D
			var Y:Number = d.getFullYear();
			var M:Number = d.getMonth();
			var D:Number = d.getDate();
			
			// 2) Find out if Y is a leap year
			var isLeapYear:Boolean = (Y % 4 == 0  &&  Y % 100 != 0) || Y % 400 == 0;
			if (isLeapYear)
			{
				//trace('Is a leap year');
			}
			
			// 3) Find out if Y-1 is a leap year
			var lastYear:Number = Y - 1;
			var lastYearIsLeap:Boolean = (lastYear % 4 == 0  &&  lastYear % 100 != 0) || lastYear % 400 == 0;
			if(lastYearIsLeap)
			{
				//trace('Is year after a leap year');
			}
			
			// 4) Find the Day of Year Number for Y M D
			var month : Array = [0,31,59,90,120,151,181,212,243,273,304,334];
			var DayOfYearNumber:Number = D + month[M];
			if(isLeapYear && M > 1)
				DayOfYearNumber++;
			//trace('Day of the year: ' + DayOfYearNumber);
			
			// 5) Find the weekday for Jan 1 (monday = 1, sunday = 7)
			var YY:Number = (Y-1) % 100; // ...
			var C:Number = (Y-1) - YY; // get century
			var G:Number = YY + YY/4; // ...
			var Jan1Weekday:Number = Math.floor(1 + (((((C / 100) % 4) * 5) + G) % 7));
			//trace('Day of the week for Jan 1 (1 = monday, 7 = sunday): ' + Jan1Weekday);
			
			// 6) Find the weekday for Y M D
			var H:Number = DayOfYearNumber + (Jan1Weekday - 1);
			var Weekday:Number = Math.floor(1 + ((H -1) % 7));
			//trace('Day of the week for date (1 = monday, 7 = sunday): ' + Weekday);
			
			var YearNumber : Number = Y;
			var WeekNumber : Number;
			// 7) Find if Y M D falls in YearNumber Y-1, WeekNumber 52 or 53
			if (DayOfYearNumber <= (8-Jan1Weekday) && Jan1Weekday > 4)
			{
				//trace('Date is within the last week of the previous year.');
				YearNumber = Y - 1;
				if (Jan1Weekday == 5 || (Jan1Weekday == 6 && isLeapYear))
				{
					WeekNumber = 53;
				} else
				{ 
					WeekNumber = 52;
				}
			}
			
			// 8) Find if Y M D falls in YearNumber Y+1, WeekNumber 1
			if (YearNumber == Y)
			{
				var I:Number = 365;
				if (isLeapYear)
				{ 
					I = 366;
				}
				if (I - DayOfYearNumber < 4 - Weekday)
				{
					//trace('Date is within the first week of the next year.');
					YearNumber = Y + 1;
					WeekNumber = 1;
				}
			}
			
			// 9) Find if Y M D falls in YearNumber Y, WeekNumber 1 through 53
			if (YearNumber == Y)
			{
				//trace('Date is within it\'s current year.');
				var J:Number = DayOfYearNumber + (7 - Weekday) + (Jan1Weekday -1);
				WeekNumber = J / 7;
				if (Jan1Weekday > 4)
				{
					WeekNumber--;
				}
			}
			
			return WeekNumber;
		};
		
	}
}