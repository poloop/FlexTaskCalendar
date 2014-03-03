package plo.flex.components.taskCalendar
{
	
	[Event(name="createItem", type="flash.event.Event")]
	[Event(name="doubleClickItem", type="flash.event.Event")]
	[Event(name="moveTask", type="plo.flex.components.taskCalendar.events.TaskEvent")]
	[Event(name="scaleLeft", type="plo.flex.components.taskCalendar.events.TaskEvent")]
	[Event(name="scaleRight", type="plo.flex.components.taskCalendar.events.TaskEvent")]
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.supportClasses.ItemRenderer;
	
	public class TaskItemRenderer extends ItemRenderer
	{
		
		[Bindable]
		public var dataDisplay : Group;
		
		override public function set data(value:Object):void
		{
			super.data=null;
			super.data=value;
			if(value) super.data.renderer = this;
		}
		
		[Bindable]
		override public function get data():Object
		{
			return super.data;
		}
		
		public static const CREATECOMPLETE_ITEM:String="createItem";
		public static const ITEM_SELECTED:String="itemSelected";
		public static const DOUBLE_CLICK_ITEM:String="doubleClickItem";
		
		public var minWidthItem:Number=10;
		
		
		public function TaskItemRenderer()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var backgroundAlpha:Number;
			if (currentState == "normal" || currentState == "hovered")
				backgroundAlpha=0;
			else
				backgroundAlpha=.3;
			graphics.clear();
			graphics.beginFill(0x000000, backgroundAlpha);
			graphics.drawRect(0, 0, unscaledWidth - (owner as List).scroller.verticalScrollBar.measuredWidth, unscaledHeight);
			graphics.lineStyle(1, 0, 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER, 0);
			graphics.moveTo(0, unscaledHeight);
			graphics.lineTo(unscaledWidth - (owner as List).scroller.verticalScrollBar.measuredWidth , unscaledHeight);
			
			
		}
	}
}