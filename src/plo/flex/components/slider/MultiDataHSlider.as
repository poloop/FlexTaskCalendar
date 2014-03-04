package plo.flex.components.slider
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.SandboxMouseEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TrackBaseEvent;
	
	[Event(name="change", type="flash.events.Event")]
	
	public class MultiDataHSlider extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		public var track : Button;
		
		[SkinPart(required="true")]
		public var thumb : IFactory;
		
		[SkinPart(required="true")]
		public var thumbsDisplay : Group;
		
		[SkinPart(required="false")]
		public var interThumbsDisplay : Group;
		
		[SkinPart(required="false")]
		public var interThumb : IFactory;
		
		[SkinPart(required="true")]
		public var dataTip : IFactory;
		
		/**
		 *  @private
		 */
		private var dataTipInstance:IDataRenderer;
		
		private var _minimum : Number = 0;
		
		public function get minimum():Number
		{
			return _minimum;
		}
		
		public function set minimum(value : Number) : void
		{
			_minimum = value;
		}
		
		private var _maximum : Number = 100;
		
		public function get maximum():Number
		{
			return _maximum;
		}
		
		public function set maximum(value : Number) : void
		{
			_maximum = value;
		}
		
		private var _stepSize : Number = 1;
		
		public function get stepSize():Number
		{
			return _stepSize;
		}
		
		public function set stepSize(value : Number) : void
		{
			_stepSize = value;
		}
		
		private var _thumbCount : uint = 1;
		
		public function get thumbCount():uint
		{
			return _thumbCount;
		}
		
		public function set thumbCount(value : uint) : void
		{
			_thumbCount = value;
		}
		
		private var _values : Array;
		
		public function get values():Array
		{
			return _values;
		}
		
		public function set values(value : Array) : void
		{
			_values = value;
			_thumbCount = _values.length;
			if(thumb)
			{
				addThumbs();
			}
		}
		
		protected var thumbs : Array = [];
		protected var interThumbs : Array = [];
		
		private var _interDataThumbEnabled : Boolean = false;
		
		public function get interDataThumbEnabled():Boolean
		{
			return _interDataThumbEnabled;
		}
		
		public function set interDataThumbEnabled(value : Boolean) : void
		{
			_interDataThumbEnabled = value;
		}
		
		
		
		public function MultiDataHSlider()
		{
			super();
		}
		
		protected function addThumbs() : void
		{
			if(thumbs.length > 0)
			{
				thumbsDisplay.removeAllElements();
				thumbs = [];
			}
			if(interThumbs.length > 0)
			{
				interThumbsDisplay.removeAllElements();
				interThumbs = [];
			}
			for(var i : uint = 0; i < _values.length; i++)
			{
				var thumbInstance : IVisualElement = IVisualElement(createDynamicPartInstance("thumb"));
				thumbInstance.x = (track.width / (_maximum - _minimum)) * (_values[i] - _minimum) - thumbInstance.width / 2;
				thumbsDisplay.addElement(thumbInstance);
				thumbInstance.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				thumbs.push(thumbInstance);
				
				if(_interDataThumbEnabled && interThumb)
				{
					if(_values.length > 1 && i > 0){
						var interThumbInstance : IVisualElement = IVisualElement(createDynamicPartInstance("interThumb"));
						interThumbInstance.x = (thumbs[i - 1] as IVisualElement).x + (thumbs[i - 1] as IVisualElement).width;
						interThumbInstance.width = (thumbs[i] as IVisualElement).x - ((thumbs[i - 1] as IVisualElement).x + (thumbs[i - 1] as IVisualElement).width);
						interThumbsDisplay.addElement(interThumbInstance);
						interThumbInstance.addEventListener(MouseEvent.MOUSE_DOWN, interThumb_mouseDownHandler);
						interThumbs.push(interThumbInstance);
					}
				}
			}
		}
		
		public function updateThumbs() : void
		{
			for(var i : uint = 0; i < thumbs.length; i++)
			{
				var thumbInstance : IVisualElement = IVisualElement(thumbs[i]);
				thumbInstance.x = (track.width / (_maximum - _minimum)) * (_values[i] - _minimum) - thumbInstance.width / 2;				
			}
			if(_interDataThumbEnabled && interThumb)
			{
				updateInterThumb();
			}
		}
		
		/**
		 *  @private
		 *  Location of the mouse down event on the thumb, relative to the thumb's origin.
		 *  Used to update the value property when the mouse is dragged. 
		 */
		private var clickOffset:Point;
		
		//--------------------------------- 
		//  showDataTip
		//---------------------------------
		
		/**
		 *  If set to <code>true</code>, shows a data tip during user interaction
		 *  containing the current value of the slider. In addition, the skinPart,
		 *  <code>dataTip</code>, must be defined in the skin in order to 
		 *  display a data tip. 
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var showDataTip:Boolean = true;
		
		/**
		 *  @private
		 */
		private var dataTipInitialPosition:Point;
		
		private var currentThumb : IFlexDisplayObject;
		private var currentInterThumb : IFlexDisplayObject;
		
		protected function thumb_mouseDownHandler(event:MouseEvent):void
		{
			
			var thumbInstance : IFlexDisplayObject = IFlexDisplayObject(event.currentTarget);
			currentThumb = thumbInstance;
			currentInterThumb = null;
			
			clickOffset = thumbInstance.globalToLocal(new Point(event.stageX, event.stageY));
			
			thumbsDisplay.swapElements(thumbInstance as IVisualElement, thumbsDisplay.getElementAt(thumbsDisplay.numElements - 1));
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, 
				system_mouseMoveHandler, true);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
				system_mouseUpHandler, true);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				system_mouseUpHandler);
			
			
			dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_PRESS));
			dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
			
			var pendingValue : Number = setValueByIndex(thumbs.indexOf(currentThumb), _minimum + (currentThumb.x + currentThumb.width / 2) / (track.width / (_maximum - _minimum)));
			// Popup a dataTip only if we have a SkinPart and the boolean flag is true
			if (dataTip && showDataTip && enabled)
			{
				dataTipInstance = IDataRenderer(createDynamicPartInstance("dataTip"));
				
				dataTipInstance.data = pendingValue.toString();
				
				var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent;
				
				// Allow styles to be inherited from SliderBase.
				if (tipAsUIComponent)
				{
					tipAsUIComponent.owner = this;
					tipAsUIComponent.isPopUp = true;
				}
				
				systemManager.toolTipChildren.addChild(DisplayObject(dataTipInstance));
				
				// Force the dataTip to render so that we have the correct size since
				// updateDataTip might need the size
				if (tipAsUIComponent)
				{
					tipAsUIComponent.validateNow();
					tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),
						tipAsUIComponent.getExplicitOrMeasuredHeight());
				}
				
				dataTipInitialPosition = new Point(DisplayObject(dataTipInstance).x, 
					DisplayObject(dataTipInstance).y);   
				updateDataTip(dataTipInstance, dataTipInitialPosition);
			}
		}
		
		protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
		{
			var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
			
			if (tipAsDisplayObject && thumb)
			{
				var relX:Number = (currentThumb as IVisualElement).getLayoutBoundsX() - 
					(tipAsDisplayObject.width - (currentThumb as IVisualElement).getLayoutBoundsWidth()) / 2;
				var o:Point = new Point(relX, initialPosition.y);
				var r:Point = (currentThumb as IVisualElement).parent.localToGlobal(o);     
				
				// Get the screen bounds
				var screenBounds:Rectangle = systemManager.getVisibleApplicationRect();
				// Get the tips bounds. We only care about the dimensions.
				var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);
				
				// Make sure the tip doesn't exceed the bounds of the screen
				r.x = Math.floor( Math.max(screenBounds.left, 
					Math.min(screenBounds.right - tipBounds.width, r.x)));
				r.y = Math.floor( Math.max(screenBounds.top, 
					Math.min(screenBounds.bottom - tipBounds.height, r.y)));
				
				r = tipAsDisplayObject.parent.globalToLocal(r);
				
				tipAsDisplayObject.x = r.x;
				tipAsDisplayObject.y = r.y;
			}
		}
		
		
		
		protected function interThumb_mouseDownHandler(event : MouseEvent) : void
		{
			var interThumbInstance : IFlexDisplayObject = IFlexDisplayObject(event.currentTarget);
			currentThumb = null;
			currentInterThumb = interThumbInstance;
			
			clickOffset = interThumbInstance.globalToLocal(new Point(event.stageX, event.stageY));
			
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, 
				system_mouseMoveHandler, true);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
				system_mouseUpHandler, true);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				system_mouseUpHandler);
		}
		
		/**
		 *  @private
		 *  Capture mouse-move events anywhere on or off the stage.
		 *  First, we calculate the new value based on the new position
		 *  using calculateNewValue(). Then, we move the thumb to 
		 *  the new value's position. Last, we set the value and
		 *  dispatch a "change" event if the value changes. 
		 */
		protected function system_mouseMoveHandler(event:MouseEvent):void
		{
			if (!track)
				return;
			if(currentThumb)
			{
				var currentIndex : uint = thumbs.indexOf(currentThumb);
				var localXmax : Number;
				var localXmin : Number;
				if(interDataThumbEnabled)
				{
					localXmax = (currentIndex == thumbs.length - 1) ? track.width : thumbs[currentIndex + 1].x;
					localXmin = (currentIndex == 0) ? 0 : thumbs[currentIndex - 1].x + thumbs[currentIndex - 1].width;
				} else
				{
					localXmax = track.width;
					localXmin = 0;
				}
				
				var p:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
				if(p.x >= localXmin && p.x <= localXmax) currentThumb.x = p.x - currentThumb.width / 2;
				else if(p.x > localXmax) currentThumb.x = localXmax - currentThumb.width / 2;
				else if(p.x < localXmin) currentThumb.x = localXmin - currentThumb.width / 2;
				
				var pendingValue : Number = setValueByIndex(currentIndex, _minimum + (currentThumb.x + currentThumb.width / 2) / (track.width / (_maximum - _minimum)));
				
				updateInterThumb();
				
				if (dataTipInstance && showDataTip)
				{ 
					dataTipInstance.data = pendingValue.toString();
					
					// Force the dataTip to render so that we have the correct size since
					// updateDataTip might need the size
					var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent; 
					if (tipAsUIComponent)
					{
						tipAsUIComponent.validateNow();
						tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),tipAsUIComponent.getExplicitOrMeasuredHeight());
					}
					
					updateDataTip(dataTipInstance, dataTipInitialPosition);
				}
			}
			if(currentInterThumb)
			{
				var currentIndexIT : uint = interThumbs.indexOf(currentInterThumb);
				var localXmaxIT : Number = (currentIndexIT == interThumbs.length - 1) ? track.width - currentInterThumb.width - thumbs[currentIndexIT + 1].width / 2 : thumbs[currentIndexIT + 2].x - currentInterThumb.width;
				var localXminIT : Number = (currentIndexIT == 0) ? thumbs[currentIndexIT].width / 2 : thumbs[currentIndexIT - 1].x  + thumbs[currentIndexIT - 1].width;
				
				var pIT:Point = track.globalToLocal(new Point(event.stageX - clickOffset.x, event.stageY - clickOffset.y));
				
				if(pIT.x >= localXminIT && pIT.x <= localXmaxIT) currentInterThumb.x = pIT.x;
				else if(pIT.x > localXmaxIT) currentInterThumb.x = localXmaxIT;
				else if(pIT.x < localXminIT) currentInterThumb.x = localXminIT;
				thumbs[currentIndexIT].x = currentInterThumb.x - thumbs[currentIndexIT].width;
				thumbs[currentIndexIT + 1].x = currentInterThumb.x + currentInterThumb.width;
				setValueByIndex(currentIndexIT, _minimum + (thumbs[currentIndexIT].x + thumbs[currentIndexIT].width / 2) / (track.width / (_maximum - _minimum)));
				setValueByIndex(currentIndexIT + 1, _minimum + (thumbs[currentIndexIT + 1].x + thumbs[currentIndexIT + 1].width / 2) / (track.width / (_maximum - _minimum)));
				
				updateInterThumb();
				
			}
			
			event.updateAfterEvent();
		}
		
		protected function updateInterThumb() : void
		{
			if(_interDataThumbEnabled && interThumb)
			{
				for(var i : uint = 0; i < interThumbs.length; i++)
				{
					var interThumbInstance : IVisualElement = interThumbs[i];
					interThumbInstance.x = (thumbs[i] as IVisualElement).x + (thumbs[i] as IVisualElement).width;
					interThumbInstance.width = (thumbs[i + 1] as IVisualElement).x - ((thumbs[i] as IVisualElement).x + (thumbs[i] as IVisualElement).width);
					if (interThumbInstance.width <= 0) interThumbInstance.visible = false;
					else interThumbInstance.visible = true;
				}
			}
		}
		
		public function setValueByIndex(i : uint, val : Number) : Number
		{
			values[i] = nearestValidValue(val, stepSize);
			
			thumbs[i].x = (track.width / (_maximum - _minimum)) * (values[i] - _minimum) - thumbs[i].width / 2;
			dispatchEvent(new Event(Event.CHANGE));
			return values[i];
			
		}
		
		/**
		 *  @private
		 *  Handle mouse-up events anywhere on or off the stage.
		 */
		protected function system_mouseUpHandler(event:Event):void
		{
			if (dataTipInstance)
			{
				removeDynamicPartInstance("dataTip", dataTipInstance);
				systemManager.toolTipChildren.removeChild(DisplayObject(dataTipInstance));
				dataTipInstance = null;
			}
			
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, 
				system_mouseMoveHandler, true);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
				system_mouseUpHandler, true);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				system_mouseUpHandler);
			
			dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
		}
		
		//---------------------------------
		// Track down handlers
		//---------------------------------
		
		private var mouseDownTarget:DisplayObject;
		
		/**
		 *  @private
		 *  Handle mouse-down events for the scroll track. Subclasses
		 *  should override this method if they want the track to
		 *  recognize mouse clicks on the track.
		 */
		protected function track_mouseDownHandler(event:MouseEvent):void { }
		
		//---------------------------------
		// Mouse click handlers
		//---------------------------------
		
		/**
		 *  @private
		 *  Capture any mouse down event and listen for a mouse up event
		 */  
		private function mouseDownHandler(event:MouseEvent):void
		{
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
				system_mouseUpSomewhereHandler, true);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				system_mouseUpSomewhereHandler);
			
			mouseDownTarget = DisplayObject(event.target);      
		}
		
		/**
		 *  @private
		 */
		private function system_mouseUpSomewhereHandler(event:Event):void
		{
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
				system_mouseUpSomewhereHandler, true);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				system_mouseUpSomewhereHandler);
			
			// If we got a mouse down followed by a mouse up on a different target in the skin, 
			// we want to dispatch a click event. 
			if (mouseDownTarget != event.target && event is MouseEvent && contains(DisplayObject(event.target)))
			{ 
				var mEvent:MouseEvent = event as MouseEvent;
				// Convert the mouse coordinates from the target to the TrackBase
				var mousePoint:Point = new Point(mEvent.localX, mEvent.localY);
				mousePoint = globalToLocal(DisplayObject(event.target).localToGlobal(mousePoint));
				
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, mEvent.bubbles, mEvent.cancelable, mousePoint.x,
					mousePoint.y, mEvent.relatedObject, mEvent.ctrlKey, mEvent.altKey,
					mEvent.shiftKey, mEvent.buttonDown, mEvent.delta));
			}
			
			mouseDownTarget = null;
		}
		
		protected function nearestValidValue(value:Number, interval:Number):Number
		{ 
			if (interval == 0)
				return Math.max(minimum, Math.min(maximum, value));
			
			var maxValue:Number = maximum - minimum;
			var scale:Number = 1;
			
			value -= minimum;
			
			// If interval isn't an integer, there's a possibility that the floating point 
			// approximation of value or value/interval will be slightly larger or smaller 
			// than the real value.  This can lead to errors in calculations like 
			// floor(value/interval)*interval, which one might expect to just equal value, 
			// when value is an exact multiple of interval.  Not so if value=0.58 and 
			// interval=0.01, in that case the calculation yields 0.57!  To avoid problems, 
			// we scale by the implicit precision of the interval and then round.  For 
			// example if interval=0.01, then we scale by 100.    
			
			if (interval != Math.round(interval)) 
			{ 
				const parts:Array = (new String(1 + interval)).split("."); 
				scale = Math.pow(10, parts[1].length);
				maxValue *= scale;
				value = Math.round(value * scale);
				interval = Math.round(interval * scale);
			}   
			
			var lower:Number = Math.max(0, Math.floor(value / interval) * interval);
			var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
			var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
			
			return (validValue / scale) + minimum;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(_values && _values.length > 0) updateThumbs();
		}
		
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function initializationComplete() : void
		{
			super.initializationComplete();
			if(_values && _values.length > 0) addThumbs();
		}
	}
}