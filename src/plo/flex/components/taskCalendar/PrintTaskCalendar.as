package plo.flex.components.taskCalendar
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.ScrollPolicy;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;

	public class PrintTaskCalendar extends TaskCalendar
	{
		public var pageHeight : Number;
		public var pageWidth : Number;
		
		public var indexPage : uint = 0;
		private var firstIndexToPrint : uint;
		private var lastIndexToPrint : uint;
		
		public var isMultiPage : Boolean = false;
		
		public static const PAGE_READY : String = "pageReady";
		
		public function PrintTaskCalendar(pW : Number, pH : Number, taskCalendar : TaskCalendar = null)
		{
			super();
			
			pageWidth = pW;
			pageHeight = pH;
			
			width = pageWidth;
			height = pageHeight;
			
			if(taskCalendar)
			{
				dateIn = taskCalendar.dateIn;
				dateOut = taskCalendar.dateOut;
				for(var i : uint = 0; i < taskCalendar.taskCollection.length; i++)
				{
					var task : TaskObject = new TaskObject(taskCalendar.taskCollection.getItemAt(i) as TaskObject);
					addTask(task);
				}
				
			}
			
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(dataDisplay)
			{
				dataDisplay.height = height - timeDisplay.measuredHeight;
				updateTimeDisplay();
			}
			
			if(datesSlider)
			{
				datesSlider.visible = false;
			}
			
		}
		
		public function checkMultiPage() : void
		{
			if(taskCollection.length > nbTaskVisibles){
				isMultiPage = true;
				firstIndexToPrint = 0;
				lastIndexToPrint = nbTaskVisibles - 1;
				dataDisplay.addEventListener(FlexEvent.UPDATE_COMPLETE, updateDataDisplayHandler);
				(taskCollection as ArrayCollection).filterFunction = checkIndexItem;
				(taskCollection as ArrayCollection).refresh();
			}else{
				firstIndexToPrint = 0;
				lastIndexToPrint = taskCollection.length - 1;
			}
		}
		
		public function getNextPages() : Boolean
		{
			if(lastIndexToPrint < (taskCollection as ArrayCollection).source.length)
			{
				firstIndexToPrint += nbTaskVisibles;
				lastIndexToPrint = Math.min( lastIndexToPrint + nbTaskVisibles, (taskCollection as ArrayCollection).source.length);
				(taskCollection as ArrayCollection).filterFunction = checkIndexItem;
				(taskCollection as ArrayCollection).refresh();
				return true;
			}
			return false;
		}
		
		protected function checkIndexItem(item : TaskObject) : Boolean
		{
			var index : uint = taskCollection.getItemIndex(item);
			return (index >= firstIndexToPrint && index <= lastIndexToPrint);
		}
		
		protected function updateDataDisplayHandler(event : FlexEvent) : void
		{
			
			dispatchEvent(new Event(PAGE_READY));
		}

	}
}