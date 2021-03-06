package org.libra.ui.flash.components {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import org.libra.ui.Constants;
	import org.libra.ui.flash.core.Component;
	import org.libra.ui.style.Style;
	import org.libra.utils.GraphicsUtil;
	import org.libra.utils.MathUtil;
	
	/**
	 * <p>
	 * 滑动器
	 * </p>
	 *
	 * @class JSlider
	 * @author Eddie
	 * @qq 32968210
	 * @date 09/02/2012
	 * @version 1.0
	 * @see
	 */
	public class JSlider extends Component {
		
		/**
		 * 滑动块
		 */
		//protected var block:JButton;
		protected var block:Sprite;
		
		/**
		 * 背景
		 */
		protected var back:Sprite;
		
		protected var backClick:Boolean;
		
		protected var value:Number = 0;
		protected var max:Number = 100;
		protected var min:Number = 0;
		protected var orientation:int;
		//protected var _tick:Number = 0.01;
		
		public function JSlider(orientation:int = 1, x:int = 0, y:int = 0) { 
			super(x, y);
			this.orientation = orientation;
			setBackClick(true);
			orientation == Constants.HORIZONTAL ? setSize(100, 18) : setSize(18, 100);
		}
		
		/*-----------------------------------------------------------------------------------------
		Public methods
		-------------------------------------------------------------------------------------------*/
		
		public function setSliderParams(min:Number, max:Number, value:Number):void { 
			this.min = min;
			this.max = max;
			this.value = value;
			this.correctValue();
			positionBlock();
		}
		
		public function setBackClick(b:Boolean):void {
			backClick = b;
		}
		
		public function setValue(v:Number):void {
			if (this.value != v) {
				value = v;
				correctValue();
				positionBlock();
			}
		}
		
		public function getValue():Number {
			return value;
		}
		
		public function setMax(m:Number):void {
			max = m;
			correctValue();
			positionBlock();
		}
		
		public function getMax():Number{
			return max;
		}
		
		public function setMin(m:Number):void {
			min = m;
			correctValue();
			positionBlock();
		}
		
		public function getMin():Number {
			return min;
		}
		
		override public function destroy():void {
			super.destroy();
			if (this.back.hasEventListener(MouseEvent.MOUSE_DOWN))
				this.back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackClicked);
		}
		
		/*-----------------------------------------------------------------------------------------
		Private methods
		-------------------------------------------------------------------------------------------*/
		
		override protected function init():void {
			super.init();
			drawBack();
			drawBlock();
		}
		
		protected function drawBack():void {
			this.back = new Sprite();
			this.setBackground(back);
		}
		
		protected function drawBlock():void {
			this.block = new Sprite();
			this.block.buttonMode = true;
			this.addChild(block);
		}
		
		override protected function resize():void {
			renderBack();
			renderBlock();
		}
		
		protected function renderBack():void {
			GraphicsUtil.drawRect(back.graphics, 0, 0, actualWidth, actualHeight, Style.BACKGROUND);
		}
		
		protected function renderBlock():void {
			if (this.orientation == Constants.HORIZONTAL)
				GraphicsUtil.drawRect(block.graphics, 1, 1, actualHeight - 2, actualHeight - 2, Style.BUTTON_FACE);
			else 
				GraphicsUtil.drawRect(block.graphics, 1, 1, actualWidth - 2, actualWidth - 2, Style.BUTTON_FACE);
			positionBlock();
		}
		
		override protected function onAddToStage(e:Event):void {
			super.onAddToStage(e);
			this.block.addEventListener(MouseEvent.MOUSE_DOWN, onDragBlock);
			if (backClick) this.back.addEventListener(MouseEvent.MOUSE_DOWN, onBackClicked);
		}
		
		override protected function onRemoveFromStage(e:Event):void {
			super.onRemoveFromStage(e);
			this.block.removeEventListener(MouseEvent.MOUSE_DOWN, onDragBlock);
			if (backClick) this.back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackClicked);
		}
		
		/**
		 * Adjusts position of handle when value, maximum or minimum have changed.
		 * TODO: Should also be called when slider is resized.
		 */
		protected function positionBlock():void {
			var range:Number;
			if(orientation == Constants.HORIZONTAL) {
				range = actualWidth - actualHeight;
				block.x = (value - min) / (max - min) * range;
			} else {
				range = actualHeight - actualWidth;
				block.y = actualHeight - actualWidth - (value - min) / (max - min) * range;
			}
		}
		
		/**
		 * 修正值
		 */
		protected function correctValue():void {
			if(max > min) {
				value = MathUtil.min(value, max);
				value = MathUtil.max(value, min);
			} else {
				value = MathUtil.max(value, max);
				value = MathUtil.min(value, min);
			}
		}
		
		/*-----------------------------------------------------------------------------------------
		Event Handlers
		-------------------------------------------------------------------------------------------*/
		protected function onDragBlock(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			if(orientation == Constants.HORIZONTAL) {
				block.startDrag(false, new Rectangle(0, 0, actualWidth - actualHeight, 0));
				//block.startDrag(false, new Rectangle(0, 0, actualWidth - block.width, 0));
			} else {
				block.startDrag(false, new Rectangle(0, 0, 0, actualHeight - actualWidth));
				//block.startDrag(false, new Rectangle(0, 0, 0, actualHeight - block.height));
			}
		}
		
		/**
		 * Internal mouseUp handler. Stops dragging the handle.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onDrop(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			block.stopDrag();
		}
		
		protected function onSlide(event:MouseEvent):void {
			var oldValue:Number = value;
			if(orientation == Constants.HORIZONTAL) {
				value = block.x / (actualWidth - actualHeight) * (max - min) + min;
			} else {
				value = (actualHeight - actualWidth - block.y) / (height - actualWidth) * (max - min) + min;
			}
			if(value != oldValue) {
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		protected function onBackClicked(e:MouseEvent):void {
			if(orientation == Constants.HORIZONTAL) {
				block.x = mouseX - actualHeight / 2;
				block.x = MathUtil.max(block.x, 0);
				block.x = MathUtil.min(block.x, actualWidth - actualHeight);
				value = block.x / (width - actualHeight) * (max - min) + min;
			} else {
				block.y = mouseY - actualWidth / 2;
				block.y = MathUtil.max(block.y, 0);
				block.y = MathUtil.min(block.y, actualHeight - actualWidth);
				value = (actualHeight - actualWidth - block.y) / (height - actualWidth) * (min - min) + min;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
	}

}