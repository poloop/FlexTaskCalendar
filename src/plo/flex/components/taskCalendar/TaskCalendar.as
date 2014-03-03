package plo.flex.components.taskCalendar
{
	import com.adobe.utils.DateUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.DragSource;
	import mx.core.IFactory;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.utils.ObjectUtil;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import plo.flex.components.slider.MultiDataHSlider;
	import plo.flex.components.taskCalendar.TaskItemRenderer;
	import plo.flex.components.taskCalendar.events.TaskEvent;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.RendererExistenceEvent;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  @copy spark.components.Scroller#style:horizontalScrollPolicy
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="horizontalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]
	
	/**
	 *  @copy spark.components.Scroller#style:verticalScrollPolicy
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="verticalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]
	
	[Event(name="selectTask", type="flash.events.Event")]
	[Event(name="dateChange", type="flash.events.Event")]
	[Event(name="doubleClickItem", type="flash.events.Event")]
	/**
	 * 
	 * @author p.long
	 */
	public class TaskCalendar extends SkinnableComponent implements IFocusManagerComponent
	{
		
		/**
		 * 
		 * @default 
		 */
		public static const DATE_CHANGE : String = "dateChange";
		/**
		 * 
		 * @default 
		 */
		public static const SELECT_TASK : String = "selectTask";
		
		/**
		 *  @private
		 */
		private var horizontalScrollPolicyChanged:Boolean = false;
		
		/**
		 *  @private
		 */
		private var verticalScrollPolicyChanged:Boolean = false;
		
		private var _dateIn : Date;
		
		/**
		 * 
		 * @return 
		 */
		public function get dateIn():Date
		{
			return _dateIn;
		}
		
		[Bindable(event="dateChange")]
		/**
		 * 
		 * @param value
		 */
		public function set dateIn(value : Date) : void
		{
			_dateIn = value;
			_dateViewIn = new Date(_dateIn.getTime());
			if(_dateOut)
			{
				nbDays = getNumberOfDaysBetween2Dates(_dateIn, _dateOut);
				nbMonthes = getNumberOfMonthesBetween2Dates(_dateIn, _dateOut);
			}
			dispatchEvent(new Event(DATE_CHANGE, true));
		}
		
		private var _dateOut : Date;
		
		/**
		 * 
		 * @return 
		 */
		public function get dateOut():Date
		{
			return _dateOut;
		}
		
		[Bindable(event="dateChange")]
		/**
		 * 
		 * @param value
		 */
		public function set dateOut(value : Date) : void
		{
			_dateOut = value;
			_dateViewOut = new Date(_dateOut.getTime());
			if(_dateIn)
			{
				nbDays = getNumberOfDaysBetween2Dates(_dateIn, _dateOut);
				nbMonthes = getNumberOfMonthesBetween2Dates(_dateIn, _dateOut);
			}
			dispatchEvent(new Event(DATE_CHANGE, true));
		}
		
		private var _dateViewIn : Date;
		
		/**
		 * 
		 * @return 
		 */
		public function get dateViewIn():Date
		{
			return _dateViewIn;
		}
		
		/**
		 * 
		 * @param value
		 */
		public function set dateViewIn(value : Date) : void
		{
			_dateViewIn = value;
		}
		
		private var _dateViewOut : Date;
		
		/**
		 * 
		 * @return 
		 */
		public function get dateViewOut():Date
		{
			return _dateViewOut;
		}
		
		/**
		 * 
		 * @param value
		 */
		public function set dateViewOut(value : Date) : void
		{
			_dateViewOut = value;
		}
		
		private var _taskCollection : IList = new ArrayCollection();
		
		[Bindable]
		/**
		 * 
		 * @return 
		 */
		public function get taskCollection():IList
		{
			return _taskCollection;
		}
		
		/**
		 * 
		 * @param value
		 */
		public function set taskCollection(value : IList) : void
		{
			_taskCollection = value;
		}
		
		private var _selectedTask : TaskObject;
		
		/**
		 * 
		 * @return 
		 */
		public function get selectedTask():TaskObject
		{
			return _selectedTask;
		}
		
		[Bindable(event="selectTask")]
		/**
		 * 
		 * @param value
		 */
		public function set selectedTask(value : TaskObject) : void
		{
			_selectedTask = value;
		}
		
		private var nbDays : uint;
		private var nbWeeks : uint;
		private var nbMonthes : uint;
		private var nbQuarters : uint;
		private var nbYears : uint;
		
		private var daysArr : Array;
		private var weeksArr : Array;
		private var monthesArr : Array;
		private var quartersArr : Array;
		private var yearsArr : Array;
		
		[SkinPart(required="true")]
		/**
		 * 
		 * @default 
		 */
		public var dataDisplay : List;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var graphicsDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var timeDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var topTimeDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var bottomTimeDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var monthDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var dayDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var weekDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var quarterDisplay : Group;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var yearDisplay : Group;

		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var timeDisplayItem : IFactory;
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var datesSlider : MultiDataHSlider;
		
		
		[SkinPart(required="false")]
		/**
		 * 
		 * @default 
		 */
		public var vDropIndicatorDisplay : Group;
		/**
		 * 
		 * @default 
		 */
		public var dayItemWidth : Number = 50;
		
		
		/**
		 * default task duration in days
		 * @default 
		 */
		public var defaultTaskDuration : Number = 3;
		
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_TIMEDISPLAY : String = "updateTimeDisplay";
		
		
		private var classItemRenderer : Class;
		/**
		 * 
		 */
		public function TaskCalendar()
		{
			super();
			_taskCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, taskCollectionChangeHandler);
		}
		
		private function getNumberOfDaysBetween2Dates(earlier : Date, later : Date) : uint
		{
			var date : Date;
			date = new Date(earlier.fullYear, earlier.month, earlier.date);
			var days : uint = 0;
			while(date < later)
			{
				date.date++;
				days++;
			}
			return days;
		}
		
		private function getNumberOfMonthesBetween2Dates(earlier : Date, later : Date) : uint
		{
			var date : Date;
			date = new Date(earlier.fullYear, earlier.month, earlier.date);
			var monthes : uint = 0;
			while(date < later)
			{
				date.month++;
				monthes++;
			}
			return monthes;
		}
		
		private function buildTimeDisplay() : void
		{
			var date : Date;
			date = new Date(dateIn.fullYear, dateIn.month, dateIn.date);
			
			daysArr = [];
			
			for(var d : uint = 0; d <= nbDays; d++)
			{
				var itemD : TimeItem = new TimeItem();
				itemD.date = new Date(date.time);
				daysArr.push(itemD);
				date.date++;
			}
			
			updateTimeDisplay();
		}
		
		/**
		 * 
		 */
		private var itemsArr : Array = [];
		
		/**
		 * 
		 */
		public function updateTimeDisplay() : void
		{
			
			for(var i : uint = 0; i < itemsArr.length; i++)
			{
				removeDynamicPartInstance("timeDisplayItem", itemsArr[i]);
				(itemsArr[i].parent as Group).removeElement(itemsArr[i]);
				itemsArr[i] = null;
			}
			itemsArr = [];
			
			//trace("updateTimeDisplay");
			var start : int = daysArr.indexOf(getItemDayByDate(dateViewIn));
			var end : int = daysArr.indexOf(getItemDayByDate(dateViewOut));
			
			topTimeDisplay.graphics.clear();
			bottomTimeDisplay.graphics.clear();
			if(graphicsDisplay) graphicsDisplay.graphics.clear();
			
			topTimeDisplay.graphics.lineStyle(1, 0x000000);
			bottomTimeDisplay.graphics.lineStyle(1, 0x000000);
			if(graphicsDisplay) graphicsDisplay.graphics.lineStyle(1, 0x000000);
			
			dayItemWidth = timeDisplay.width / (end - start + 1);
			
			var nbDaysView : uint = end - start;
			
			for(var d : uint = 0; d <= nbDays; d++)
			{
				var item : TimeItem = daysArr[d];
				item.posX = (d - start) * dayItemWidth;
				if(d >= start && d <= end)
				{
					if(nbDaysView < 16)
					{
						dayDisplay = bottomTimeDisplay;
						var itemD : TimeDisplayItem = TimeDisplayItem(createDynamicPartInstance("timeDisplayItem"));
						itemD.x = item.posX;
						itemD.width = dayItemWidth;
						itemD.date = item.date;
						itemD.text = DateUtil.getShortDayName(itemD.date) + " " + item.date.date.toString();
						dayDisplay.graphics.moveTo((d - start + 1) * dayItemWidth, 0);
						dayDisplay.graphics.lineTo((d - start + 1) * dayItemWidth, dayDisplay.height);
						dayDisplay.addElement(itemD);
						itemsArr.push(itemD);
						if(graphicsDisplay)
						{
							graphicsDisplay.graphics.moveTo((d - start + 1) * dayItemWidth, 0);
							graphicsDisplay.graphics.lineTo((d - start + 1) * dayItemWidth, graphicsDisplay.explicitHeight);
						}
					}
					if(nbDaysView < 93)
					{
						if(item.date.day == 1 || item.date.time == dateIn.time)
						{
							if(nbDaysView >= 16) weekDisplay = bottomTimeDisplay;
							else weekDisplay = topTimeDisplay;
							var itemW : TimeDisplayItem = TimeDisplayItem(createDynamicPartInstance("timeDisplayItem"));
							itemW.date = item.date;
							itemW.text = "W" + DateUtils.calculateISO8601WeekNumber(itemW.date) + " " + itemW.date.fullYear.toString();
							itemW.x = item.posX;
							itemW.width = 7 * dayItemWidth;
							weekDisplay.graphics.moveTo(item.posX, 0);
							weekDisplay.graphics.lineTo(item.posX, weekDisplay.height);
							weekDisplay.addElement(itemW);
							itemsArr.push(itemW);
							if(graphicsDisplay && weekDisplay == bottomTimeDisplay)
							{
								graphicsDisplay.graphics.moveTo(item.posX, 0);
								graphicsDisplay.graphics.lineTo(item.posX, graphicsDisplay.explicitHeight);
							}
						}
					}
					if(nbDaysView >= 16 && nbDaysView < 366)
					{
						if(item.date.date == 1 || item.date.time == dateIn.time)
						{
							if(nbDaysView >= 93) monthDisplay = bottomTimeDisplay;
							else monthDisplay = topTimeDisplay;
							var itemM : TimeDisplayItem = TimeDisplayItem(createDynamicPartInstance("timeDisplayItem"));
							itemM.date = item.date;
							itemM.text = DateUtil.getShortMonthName(itemM.date) + " " + itemM.date.fullYear.toString();
							itemM.x = item.posX;
							monthDisplay.graphics.moveTo(item.posX, 0);
							monthDisplay.graphics.lineTo(item.posX, monthDisplay.height);
							monthDisplay.addElement(itemM);
							itemsArr.push(itemM);
							if(graphicsDisplay && monthDisplay == bottomTimeDisplay)
							{
								graphicsDisplay.graphics.moveTo(item.posX, 0);
								graphicsDisplay.graphics.lineTo(item.posX, graphicsDisplay.explicitHeight);
							}
						}
					}
					if(nbDaysView >= 93)
					{
						if((item.date.date == 1  && item.date.month % 3 == 0) || item.date.time == dateIn.time)
						{
							if(nbDaysView >= 366) quarterDisplay = bottomTimeDisplay;
							else quarterDisplay = topTimeDisplay;
							var itemQ : TimeDisplayItem = TimeDisplayItem(createDynamicPartInstance("timeDisplayItem"));
							itemQ.date = item.date;
							itemQ.text = "Q" + Math.floor((1 + itemQ.date.month / 3)).toString() + " " + itemQ.date.fullYear.toString();
							itemQ.x = item.posX;
							quarterDisplay.graphics.moveTo(item.posX, 0);
							quarterDisplay.graphics.lineTo(item.posX, quarterDisplay.height);
							quarterDisplay.addElement(itemQ);
							itemsArr.push(itemQ);
							if(graphicsDisplay && quarterDisplay == bottomTimeDisplay)
							{
								graphicsDisplay.graphics.moveTo(item.posX, 0);
								graphicsDisplay.graphics.lineTo(item.posX, graphicsDisplay.explicitHeight);
							}
						}
					}
					if(nbDaysView >= 366)
					{
						if((item.date.month == 0 && item.date.date == 1) || item.date.time == dateIn.time)
						{
							yearDisplay = topTimeDisplay;
							var itemY : TimeDisplayItem = TimeDisplayItem(createDynamicPartInstance("timeDisplayItem"));
							itemY.date = item.date;
							itemY.text = itemY.date.fullYear.toString();
							itemY.x = item.posX;
							yearDisplay.graphics.moveTo(item.posX, 0);
							yearDisplay.graphics.lineTo(item.posX, yearDisplay.height);
							yearDisplay.addElement(itemY);
							itemsArr.push(itemY);
						}
					}
				}
				
			}
			dispatchEvent(new Event(UPDATE_TIMEDISPLAY, true, true));
			updateTaskItems();
		}
		
		private function getItemDayByDate(date : Date) : TimeItem
		{	
			for(var i : uint = 0; i < daysArr.length; i++)
			{
				var item : TimeItem = daysArr[i];
				if(item.date.fullYear == date.fullYear && item.date.month == date.month && item.date.date == date.date) return item;
			}
			return null;
		}
		
		private function datesSlider_changeHandler(event : Event) : void
		{
			//trace("datesSlider_changeHandler");
			dateViewIn.setTime(datesSlider.values[0]);
			dateViewOut.setTime(datesSlider.values[1]);
			updateTimeDisplay();
		}
		
		/**
		 * 
		 * @param task
		 */
		public function addTask(task : TaskObject) : void
		{
			taskCollection.addItem(task);
		}
		
		/**
		 * 
		 * @param task
		 * @param index
		 */
		public function addTaskAt(task : TaskObject, index : uint) : void
		{
			taskCollection.addItemAt(task, index);
		}
		
		protected function taskCollectionChangeHandler(event : CollectionEvent) : void
		{
			//trace(event.kind);
		}
		
		/**
		 * 
		 * @param task
		 */
		public function removeTask(task : TaskObject) : void
		{
			_taskCollection.removeItemAt(_taskCollection.getItemIndex(task));
			if(task == _selectedTask)
			{
				_selectedTask = null;
			}
		}
		
		/**
		 * 
		 * @default 
		 */
		protected var nbTaskVisibles : uint;
		
		
		private function createTaskItemHandler(event : Event) : void
		{
			trace("createTaskItem " + (event.target as TaskItemRenderer));
			var taskItem : TaskItemRenderer = event.target as TaskItemRenderer;
			
				taskItem.addEventListener(FlexEvent.DATA_CHANGE, dataItemChangeHandler);
				if((taskItem.data as TaskObject).dateOut < _dateViewIn || (taskItem.data as TaskObject).dateIn > _dateViewOut)
				{
					taskItem.dataDisplay.visible = false;
					
				}else{
					taskItem.dataDisplay.visible = true;
					
					taskItem.dataDisplay.x = getXPosByDate(new Date(Math.max((taskItem.data as TaskObject).dateIn.time, dateIn.time)));
					taskItem.dataDisplay.width = getXPosByDate(new Date(Math.min((taskItem.data as TaskObject).dateOut.time, dateOut.time))) - taskItem.dataDisplay.x + dayItemWidth;
				}
				taskItem.width = dataDisplay.width;
				taskItem.minWidthItem = dayItemWidth;
				
				taskItem.addEventListener(TaskEvent.MOVE_TASK, moveTaskItemHandler);
				taskItem.addEventListener(TaskEvent.SCALE_LEFT, moveTaskItemHandler);
				taskItem.addEventListener(TaskEvent.SCALE_RIGHT, moveTaskItemHandler);
				
				taskItem.addEventListener(TaskItemRenderer.ITEM_SELECTED, selectTaskItemHandler);
				taskItem.addEventListener(MouseEvent.MOUSE_DOWN, selectTaskItemHandler);
				_selectedTask = taskItem.data as TaskObject;
				dispatchEvent(new Event(SELECT_TASK));
			
			
		}
		
		[Bindable(event="doubleClickItem")]
		private function doubleClickItemHandler(event : Event) : void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param date
		 * @return 
		 */
		public function getXPosByDate(date : Date) : Number
		{
			var xPos : Number = getItemDayByDate(date).posX;
			return xPos;
		}
		
		/**
		 * 
		 * @param xPos
		 * @return 
		 */
		public function getDateByXPos(xPos : Number) : Date
		{
			var date : Date;
			for(var i : uint; i < daysArr.length; i++)
			{		
				if(i < daysArr.length -1)
				{
					if(xPos >= daysArr[i].posX && xPos < daysArr[i + 1].posX)
					{
						date = new Date(daysArr[i].date.time);
						return date;
					}
				} else {
					if(xPos >= daysArr[i].posX)
					{
						date = new Date(daysArr[daysArr.length -1].date.time);
						return date;
					}
				}
			}
			return null;
		}
		
		/**
		 * 
		 */
		public function updateTaskItems() : void
		{
			
			for(var i : uint = 0; i < taskCollection.length; i++)
			{
				var taskItem : TaskItemRenderer = (taskCollection[i] as TaskObject).renderer as TaskItemRenderer;
				if(taskItem)
				{
					taskItem.minWidthItem = dayItemWidth;
					if((taskItem.data as TaskObject).dateOut < _dateViewIn || (taskItem.data as TaskObject).dateIn > _dateViewOut)
					{
						taskItem.dataDisplay.visible = false;
					}else{
						taskItem.dataDisplay.visible = true;
						taskItem.dataDisplay.x = getXPosByDate(new Date(Math.max((taskItem.data as TaskObject).dateIn.time, dateIn.time)));
						taskItem.dataDisplay.width = getXPosByDate(new Date(Math.min((taskItem.data as TaskObject).dateOut.time, dateOut.time))) - taskItem.dataDisplay.x + dayItemWidth;
					}
				}
			}
		}
		
		private function dataItemChangeHandler(event : FlexEvent) : void
		{
			var taskItem : TaskItemRenderer = event.currentTarget as TaskItemRenderer;
			if(taskItem && taskItem.data)
			{
				taskItem.minWidthItem = dayItemWidth;
				if((taskItem.data as TaskObject).dateOut < _dateViewIn || (taskItem.data as TaskObject).dateIn > _dateViewOut)
				{
					taskItem.dataDisplay.visible = false;
				}else{
					taskItem.dataDisplay.visible = true;
					taskItem.dataDisplay.x = getXPosByDate(new Date(Math.max((taskItem.data as TaskObject).dateIn.time, dateIn.time)));
					taskItem.dataDisplay.width = getXPosByDate(new Date(Math.min((taskItem.data as TaskObject).dateOut.time, dateOut.time))) - taskItem.dataDisplay.x + dayItemWidth;
				}
			}
		}
		
		/**
		 * 
		 * @param event
		 */
		protected function moveTaskItemHandler(event : TaskEvent) : void{
			//trace(event.type);
			var taskItem : TaskItemRenderer = event.target as TaskItemRenderer;
			var dI : Date;
			var dO : Date;
			
			if(event.type == TaskEvent.SCALE_RIGHT)
			{
				
				if(event.position.x <= (daysArr[daysArr.length - 1] as TimeItem).posX + dayItemWidth)
				{
					
					dO = getDateByXPos(event.position.x);
					if(dO != null) (taskItem.data as TaskObject).dateOut = new Date(dO.time);
					else (taskItem.data as TaskObject).dateOut = new Date(dateOut.time);
					
					taskItem.dataDisplay.width = event.position.x - taskItem.dataDisplay.x;
					
				}else
				{
					(taskItem.data as TaskObject).dateOut = new Date(dateOut.time);
					
					taskItem.dataDisplay.width = (daysArr[daysArr.length - 1] as TimeItem).posX + dayItemWidth - taskItem.dataDisplay.x;
				}
			}
			if(event.type == TaskEvent.SCALE_LEFT)
			{
				var w:Number=taskItem.dataDisplay.x + taskItem.dataDisplay.width;
				
				if(event.position.x >= (daysArr[0] as TimeItem).posX)
				{
					taskItem.dataDisplay.x = event.position.x;
					taskItem.dataDisplay.width = w - event.position.x;
					
					dI = getDateByXPos(taskItem.dataDisplay.x);
					if(dI != null) (taskItem.data as TaskObject).dateIn = new Date(dI.time);
					else (taskItem.data as TaskObject).dateIn = new Date(dateIn.time);
					
					
					
				}else
				{
					taskItem.dataDisplay.x = (daysArr[0] as TimeItem).posX;
					taskItem.dataDisplay.width = w - (daysArr[0] as TimeItem).posX;
					
					(taskItem.data as TaskObject).dateIn = new Date(dateIn.time);
					
					
				}
			}
			if(event.type == TaskEvent.MOVE_TASK)
			{
				if(event.position.x >= (daysArr[0] as TimeItem).posX && event.position.x <= (daysArr[daysArr.length - 1] as TimeItem).posX - taskItem.dataDisplay.width + dayItemWidth)
				{
					taskItem.dataDisplay.x = event.position.x;
					
					dI = getDateByXPos(Math.min(taskItem.dataDisplay.x, getXPosByDate(dateOut) - taskItem.dataDisplay.width + dayItemWidth));
					if(dI != null) (taskItem.data as TaskObject).dateIn = new Date(dI.time);
					else (taskItem.data as TaskObject).dateIn = new Date(dateIn.time);
					
					dO = getDateByXPos(taskItem.dataDisplay.x + taskItem.dataDisplay.width);
					if(dO != null) (taskItem.data as TaskObject).dateOut = new Date(dO.time);
					else (taskItem.data as TaskObject).dateOut = new Date(dateOut.time);
				}
				if(event.position.x < (daysArr[0] as TimeItem).posX)
				{
					taskItem.dataDisplay.x = (daysArr[0] as TimeItem).posX;
					
					(taskItem.data as TaskObject).dateIn = new Date(dateIn.time);
										
					dO = getDateByXPos(taskItem.dataDisplay.x + taskItem.dataDisplay.width);
					if(dO != null) (taskItem.data as TaskObject).dateOut = new Date(dO.time);
					else (taskItem.data as TaskObject).dateOut = new Date(dateOut.time);
				}
				if(event.position.x > (daysArr[daysArr.length - 1] as TimeItem).posX - taskItem.dataDisplay.width + dayItemWidth)
				{
					taskItem.dataDisplay.x = (daysArr[daysArr.length - 1] as TimeItem).posX - taskItem.dataDisplay.width + dayItemWidth;
					
					dI = getDateByXPos(Math.min(taskItem.dataDisplay.x, getXPosByDate(dateOut) - taskItem.dataDisplay.width + dayItemWidth));
					if(dI != null) (taskItem.data as TaskObject).dateIn = new Date(dI.time);
					else (taskItem.data as TaskObject).dateIn = new Date(dateIn.time);
					
					
					(taskItem.data as TaskObject).dateOut = new Date(dateOut.time);
				}
			}
			//TODO Dispatch Event 
		}
		
		/**
		 * 
		 * @param event
		 */
		protected function selectTaskItemHandler(event : Event) : void
		{
			trace("SELECT");
			dataDisplay.selectedItem = (event.currentTarget as TaskItemRenderer).data;
			_selectedTask = (event.currentTarget as TaskItemRenderer).data as TaskObject;
			dispatchEvent(new Event(SELECT_TASK));
		}
		
		//----------------------------------
		//  dragEnabled
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the dragEnabled property.
		 */
		private var _dragEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		
		/**
		 *
		 */
		public function get dragEnabled():Boolean
		{
			return _dragEnabled;
		}
		
		/**
		 *  @private
		 */
		public function set dragEnabled(value:Boolean):void
		{
			if (value == _dragEnabled)
				return;
			_dragEnabled = value;
			if(dataDisplay)
				dataDisplay.dragEnabled = true;
			
		}
		
		//----------------------------------
		//  dragMoveEnabled
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the dragMoveEnabled property.
		 */
		private var _dragMoveEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		
		/**
		 *
		 */
		public function get dragMoveEnabled():Boolean
		{
			return _dragMoveEnabled;
		}
		
		/**
		 *  @private
		 */
		public function set dragMoveEnabled(value:Boolean):void
		{
			_dragMoveEnabled = value;
			if(dataDisplay)
				dataDisplay.dragMoveEnabled = true;
			
		}
		
		//----------------------------------
		//  dropEnabled
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the <code>dropEnabled</code> property.
		 */
		private var _dropEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		
		/**
		 *
		 */
		public function get dropEnabled():Boolean
		{
			return _dropEnabled;
		}
		
		/**
		 *  @private
		 */
		public function set dropEnabled(value:Boolean):void
		{
			if (value == _dropEnabled)
				return;
			_dropEnabled = value;
			if(dataDisplay)
				dataDisplay.dropEnabled = true;
			
		}
		
		
		private function dropHandler(event : DragEvent) : void
		{
			event.isDefaultPrevented();
			if(vDropIndicatorDisplay)
			{
				vDropIndicatorDisplay.graphics.clear();
			}
			if(event.action == "move")
			{
				trace("MOVE");
				event.stopPropagation();
				return;
			}
			
			var dragSource:DragSource = event.dragSource;
			var items:Vector.<Object> = dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			
			var caretIndex:int = -1;
			if (dragSource.hasFormat("caretIndex"))
				caretIndex = event.dragSource.dataForFormat("caretIndex") as int;
			
			var p : Point = dataDisplay.globalToLocal(new Point(event.stageX, event.stageY));
			
			items[0] = ObjectUtil.copy(items[0]);
			var task : TaskObject = items[0] as TaskObject;
			if(task.dateIn == null)
			{
				task.dateIn = new Date(getDateByXPos(p.x).time);
				if(task.dateOut == null)
				{
					var date : Date = new Date(task.dateIn.time);
					date.date += defaultTaskDuration - 1;
					task.dateOut = date;
				}
			}
			
		}
		
		private function dragOverHandler(event : DragEvent) : void
		{
			if(vDropIndicatorDisplay && event.dragInitiator != event.currentTarget)
			{
				var p : Point = dataDisplay.globalToLocal(new Point(event.stageX, event.stageY));
				vDropIndicatorDisplay.graphics.clear();
				vDropIndicatorDisplay.graphics.lineStyle(1, 0x000000);
				vDropIndicatorDisplay.graphics.moveTo(p.x, 0);
				vDropIndicatorDisplay.graphics.lineTo(p.x, vDropIndicatorDisplay.height);
			}
		}
		
		private function dragExitHandler(event : DragEvent) : void
		{
			if(vDropIndicatorDisplay)
			{
				vDropIndicatorDisplay.graphics.clear();
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Pushes various TextInput properties down into the RichEditableText. 
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			
			
			if (horizontalScrollPolicyChanged)
			{
				horizontalScrollPolicyChanged = false;
			}
			
			if (verticalScrollPolicyChanged)
			{
				verticalScrollPolicyChanged = false;
			}
			
			if(dataDisplay)
			{
				dataDisplay.dragEnabled = _dragEnabled;
				dataDisplay.dragMoveEnabled = _dragMoveEnabled;
				dataDisplay.dropEnabled = _dropEnabled;
			}
		}
		
		/**
		 *  @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
			super.styleChanged(styleProp);
			
			if (allStyles || styleProp == "horizontalScrollPolicy")
			{
				horizontalScrollPolicyChanged = true;
				invalidateProperties();
			}
			if (allStyles || styleProp == "verticalScrollPolicy")
			{
				verticalScrollPolicyChanged = true;
				invalidateProperties();
			}
			
			
		}
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == dataDisplay)
			{
				dataDisplay.addEventListener(TaskItemRenderer.CREATECOMPLETE_ITEM, createTaskItemHandler);
				dataDisplay.addEventListener(TaskItemRenderer.DOUBLE_CLICK_ITEM, doubleClickItemHandler);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			
			if(instance == dataDisplay)
			{
				dataDisplay.removeEventListener(TaskItemRenderer.CREATECOMPLETE_ITEM, createTaskItemHandler);
			}
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(_dateViewIn && _dateViewOut)
			{
				updateTimeDisplay();
			}
			
			if(datesSlider){
				
				datesSlider.invalidateDisplayList();
			}
			
			if(dataDisplay)
			{
				dataDisplay.dragEnabled = _dragEnabled;
				dataDisplay.dragMoveEnabled = _dragMoveEnabled;
				dataDisplay.dropEnabled = _dropEnabled;
				if(_taskCollection.length > 0)
				{
					updateTaskItems();
				}
				
			}
			
		}
		
		override protected function initializationComplete() : void
		{
			super.initializationComplete();
			if(_dateIn && _dateOut){
				buildTimeDisplay();
				datesSlider.minimum = _dateIn.getTime();
				datesSlider.maximum = _dateOut.getTime();
				datesSlider.values = [_dateViewIn.getTime(), _dateViewOut.getTime()];
				datesSlider.stepSize = 1000 * 3600 * 24;
				datesSlider.addEventListener(Event.CHANGE, datesSlider_changeHandler);
			}
			
			if(dataDisplay)
			{
				if(_dropEnabled)
				{
					dataDisplay.addEventListener(DragEvent.DRAG_DROP, dropHandler);
					dataDisplay.addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
					dataDisplay.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
				}
				dataDisplay.addEventListener(RendererExistenceEvent.RENDERER_ADD, addRendererHandler);
			}
			addEventListener(DATE_CHANGE, dateChangeHandler);
			
		}
		
		/**
		 * 
		 * @param event
		 */
		protected function addRendererHandler(event : RendererExistenceEvent) : void
		{
			nbTaskVisibles = Math.floor(dataDisplay.height / (event.renderer as ItemRenderer).measuredHeight);
			//trace("nbTaskVisibles : " + nbTaskVisibles);
		}
		
		
		/**
		 * 
		 * @param event
		 */
		protected function dateChangeHandler(event : Event) : void
		{
			trace("dateChangeHandler");
			buildTimeDisplay();
			datesSlider.minimum = _dateIn.getTime();
			datesSlider.maximum = _dateOut.getTime();
			datesSlider.values = [_dateViewIn.getTime(), _dateViewOut.getTime()];
		}
		
	}
}