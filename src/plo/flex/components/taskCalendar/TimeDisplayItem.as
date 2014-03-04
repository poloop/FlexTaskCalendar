package plo.flex.components.taskCalendar
{
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class TimeDisplayItem extends SkinnableComponent implements IFocusManagerComponent
	{
		
		[SkinPart(required="false")]
		public var label : Label;
		
		private var _date : Date;
		
		public function get date():Date
		{
			return _date;
		}
		
		public function set date(value : Date) : void
		{
			_date = value;
		}
		
		private var _text : String;
		
		[Bindable]
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value : String) : void
		{
			_text = value;
		}
		
		public function TimeDisplayItem()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
		}
	}
}