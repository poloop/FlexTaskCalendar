package
{
	import plo.flex.components.taskCalendar.TaskObject;
	
	[RemoteClass]
	[Bindable]
	public class BrandTaskObject extends TaskObject
	{
		
		private var _brand : String

		public function get brand():String
		{
			return _brand;
		}

		public function set brand(value:String):void
		{
			_brand = value;
		}

		
		public function BrandTaskObject(task:TaskObject=null)
		{
			super(task);
		}
	}
}