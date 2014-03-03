package plo.flex.components.taskCalendar.events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class TaskEvent extends Event
	{
		
		public var position : Point;
		
		public static const MOVE_TASK : String = "moveTask";
		public static const SCALE_LEFT : String = "scaleLeft";
		public static const SCALE_RIGHT : String = "scaleRight";
		
		public function TaskEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, pos:Point = null)
		{
			super(type, bubbles, cancelable);
			position = pos;
		}
	}
}