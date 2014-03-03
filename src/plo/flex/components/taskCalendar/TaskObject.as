package plo.flex.components.taskCalendar
{
	import spark.components.IItemRenderer;

	[RemoteClass]
	[Bindable]
	public class TaskObject extends Object
	{
		private var _label : String;
		
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value : String) : void
		{
			_label = value;
		}
		
		private var _dateIn : Date;
		
		public function get dateIn():Date
		{
			return _dateIn;
		}
		
		public function set dateIn(value : Date) : void
		{
			_dateIn = value;
		}
		
		private var _dateOut : Date;
		
		public function get dateOut():Date
		{
			return _dateOut;
		}
		
		public function set dateOut(value : Date) : void
		{
			_dateOut = value;
		}
		
		private var _color : uint = 0x0000FF;
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value : uint) : void
		{
			_color = value;
		}
		
		public var renderer : IItemRenderer;
		
		public function TaskObject(task : TaskObject = null)
		{
			super();
			if(task != null)
			{
				_label = task.label; 
				_color = task.color; 
				_dateIn = (task.dateIn != null) ? new Date(task.dateIn.time) : null; 
				_dateOut = (task.dateOut != null) ? new Date(task.dateOut.time) : null;
			} 
		}
	}
}