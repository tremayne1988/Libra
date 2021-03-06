package org.libra.ui.starling.core {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import org.libra.ui.invalidation.InvalidationFlag;
	import org.libra.ui.starling.component.JToolTip;
	import org.libra.ui.starling.managers.DragManager;
	import org.libra.ui.starling.managers.ToolTipManager;
	import org.libra.ui.starling.theme.DefaultTheme;
	import org.libra.utils.MathUtil;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	
	/**
	 * <p>
	 * 组件类，所有组件的顶级父类
	 * 继承自starling.display.Sprite
	 * </p>
	 *
	 * @class Component
	 * @author Eddie
	 * @qq 32968210
	 * @date 10/27/2012
	 * @version 1.0
	 * @see
	 */
	public class Component extends Sprite implements IComponent, IDragable { 
		
		private static var helperMatrix:Matrix = new Matrix();
		private static var helperPoint:Point = new Point();
		
		/**
		 * 组件背景
		 * 可以木有背景
		 * 如果有背景的话，背景永远在最下一层
		 * @private
		 */
		protected var background:DisplayObject;
		
		/**
		 * 组件是否可用
		 * @private
		 */
		protected var enabled:Boolean;
		
		/**
		 * 提示框里的文本内容
		 * @private
		 */
		protected var toolTipText:String;
		
		/**
		 * 是否初始化过了
		 * 只在组件第一次被添加到舞台上时进行初始化
		 * @private
		 */
		protected var inited:Boolean;
		
		/**
		 * 是否可以被拖拽
		 * @private
		 * @default false
		 */
		protected var dragEnabled:Boolean;
		
		/**
		 * 渲染队列的引用
		 * 渲染队列是单例
		 * @private
		 */
		protected var validationQueue:ValidationQueue;
		
		/**
		 * 需要被渲染的标签
		 * @private
		 */
		protected var invalidationFlag:InvalidationFlag;
		
		/**
		 * 碰撞范围
		 * @private
		 */
		protected var hitArea:Rectangle;
		
		/**
		 * 组件真实的宽度
		 * @private
		 */
		protected var actualWidth:Number;
		
		/**
		 * 组件真实的高度
		 * @private
		 */
		protected var actualHeight:Number;
		
		/**
		 * 像传统列表的mouseChildren，如果为true，那么子对象将不接受碰撞检测。
		 * @private false
		 */
		protected var quickHitAreaEnabled:Boolean;
		
		/**
		 * 构造函数
		 * @param	width
		 * @param	height
		 * @param	x
		 * @param	y
		 */
		public function Component(width:int, height:int, x:int = 0, y:int = 0) { 
			super();
			this.x = x;
			this.y = y;
			invalidationFlag = new InvalidationFlag();
			hitArea = new Rectangle();
			this.setSize(width, height);
			enabled = true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		/*-----------------------------------------------------------------------------------------
		Public methods
		-------------------------------------------------------------------------------------------*/
		
		/**
		 * 设置组件的大小
		 * @param	width 宽度
		 * @param	height 高度
		 */
		public function setSize(width:Number, height:Number):void {
			if (actualHeight != height  || actualWidth != width) {
				this.actualWidth = width;
				this.actualHeight = height;
				hitArea.width = width;
				hitArea.height = height;
				this.invalidate(InvalidationFlag.SIZE);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get width():Number {
			return actualWidth;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void {
			setSize(value, actualHeight);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get height():Number {
			return actualHeight;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set height(value:Number):void {
			setSize(actualWidth, value);
		}
		
		/**
		 * 设置组件坐标
		 * @param	x 横坐标
		 * @param	y 中坐标
		 */
		public function setLocation(x:int, y:int):void {
			this.x = x;
			this.y = y;
		}
		
		/**
		 * 设置组件是否可用
		 * @param	val
		 */
		public function setEnabled(val:Boolean):void {
			if (enabled == val) return;
			this.enabled = val;
			this.touchable = val;				
			this.invalidate(InvalidationFlag.STATE);
		}
		
		/**
		 * 获取组件当前是否可用
		 * @return 布尔值
		 */
		public function isEnabled():Boolean {
			return this.enabled;
		}
		
		/**
		 * 像传统列表的mouseChildren，如果为true，那么子对象将不接受碰撞检测。
		 * @param	val
		 */
		public function setQuickHitAreaEnabled(val:Boolean):void {
			this.quickHitAreaEnabled = val;
		}
		
		/**
		 * 像传统列表的mouseChildren，如果为true，那么子对象将不接受碰撞检测。
		 * @return
		 */
		public function isQuickHitAreaEnabled():Boolean {
			return this.quickHitAreaEnabled;
		}
		
		/**
		 * 设置背景，背景是
		 * @param	background 背景
		 * @param	disposeOld 如果之前已经有背景了，是否将之前的背景dispose掉
		 */
		public function setBackground(background:DisplayObject, disposeOld:Boolean = false):void { 
			if (this.background) this.background.removeFromParent(disposeOld);
			
			if (background) {
				this.addChildAt(background, 0);
			}
			this.background = background;
		}
		
		/**
		 * 将对象添加到
		 * @param	child
		 * @param	index
		 * @return 被添加的对象
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (this.background) {
				index = MathUtil.max(1, index);
			}
			return super.addChildAt(child, index);
		}
		
		/**
		 * 获取组件的范围
		 * @param	targetSpace
		 * @param	resultRect
		 * @return
		 */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle { 
			if (!resultRect) resultRect = new Rectangle();
			
			var minX:int, maxX:int, minY:int, maxY:int;
			if (targetSpace == this) {
				minX = this.hitArea.x;
				minY = this.hitArea.y;
				maxX = this.hitArea.x + this.hitArea.width;
				maxY = this.hitArea.y + this.hitArea.height;
			}else {
				this.getTransformationMatrix(targetSpace, helperMatrix);
				
				MatrixUtil.transformCoords(helperMatrix, this.hitArea.x, this.hitArea.y, helperPoint);
				minX = minX < helperPoint.x ? minX : helperPoint.x;
				maxX = maxX > helperPoint.x ? maxX : helperPoint.x;
				minY = minY < helperPoint.y ? minY : helperPoint.y;
				maxY = maxY > helperPoint.y ? maxY : helperPoint.y;
				
				MatrixUtil.transformCoords(helperMatrix, this.hitArea.x, this.hitArea.y + this.hitArea.height, helperPoint);
				minX = minX < helperPoint.x ? minX : helperPoint.x;
				maxX = maxX > helperPoint.x ? maxX : helperPoint.x;
				minY = minY < helperPoint.y ? minY : helperPoint.y;
				maxY = maxY > helperPoint.y ? maxY : helperPoint.y;
				
				MatrixUtil.transformCoords(helperMatrix, this.hitArea.x + this.hitArea.width, this.hitArea.y, helperPoint);
				minX = minX < helperPoint.x ? minX : helperPoint.x;
				maxX = maxX > helperPoint.x ? maxX : helperPoint.x;
				minY = minY < helperPoint.y ? minY : helperPoint.y;
				maxY = maxY > helperPoint.y ? maxY : helperPoint.y;
				
				MatrixUtil.transformCoords(helperMatrix, this.hitArea.x + this.hitArea.width, this.hitArea.y + this.hitArea.height, helperPoint);
				minX = minX < helperPoint.x ? minX : helperPoint.x;
				maxX = maxX > helperPoint.x ? maxX : helperPoint.x;
				minY = minY < helperPoint.y ? minY : helperPoint.y;
				maxY = maxY > helperPoint.y ? maxY : helperPoint.y;
			}
			
			resultRect.x = minX;
			resultRect.y = minY;
			resultRect.width  = maxX - minX;
			resultRect.height = maxY - minY;
			
			return resultRect;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject { 
			if(this.quickHitAreaEnabled) {
				if(forTouch && (!this.visible || !this.touchable)) {
					return null;
				}
				return this.hitArea.containsPoint(localPoint) ? this : null;
			}
			return super.hitTest(localPoint, forTouch);
		}
		
		/**
		 * 设置提示框的文本
		 * @param	text 文本
		 */
		public function setToolTipText(text:String):void {
			this.toolTipText = text;
			ToolTipManager.getInstance().setToolTip(this, text ? JToolTip.getInstance() : null);
		}
		
		/**
		 * 初始化文本提示框
		 * 因为文本提示框是单例，不同的组件的提示文本不同
		 * 所以当被提示组件更换时，都需要将文本提示框里的文本进行更新
		 */
		public function initToolTip():void {
			JToolTip.getInstance().setText(this.toolTipText);
		}
		
		/**
		 * 设置需要渲染的类别
		 * @param	flag 渲染的类别
		 * @see org.libra.ui.invalidation.InvalidationFlag
		 */
		public function invalidate(flag:int = -1):void {
			this.invalidationFlag.setInvalid(flag);
			if(this.stage)
				validationQueue.addControl(this, false);
		}
		
		/**
		 * 开始渲染
		 * 被validationQueue调用
		 */
		public function validate():void {
			draw();
			this.invalidationFlag.reset();
		}
		
		/**
		 * 设置是否可以拖拽
		 * @param	val
		 */
		public function setDragEnabled(val:Boolean):void {
			if (this.dragEnabled != val) {
				this.dragEnabled = val;
				dragEnabled ? addEventListener(TouchEvent.TOUCH, onDragStart) : removeEventListener(TouchEvent.TOUCH, onDragStart);
			}
		}
		
		/**
		 * 输出类名
		 * @return
		 */
		public function toString():String {
			return getQualifiedClassName(this);
		}
		
		/* INTERFACE org.libra.ui.starling.core.IDragable */
		
		/**
		 * 得到拖拽时的纹理
		 * @return
		 */
		public function getDragTexture():Texture {
			//TODO 暂时用按钮的纹理代替拖拽时的纹理
			return DefaultTheme.getInstance().getTexture(DefaultTheme.BTN.normal);
		}
		
		/*-----------------------------------------------------------------------------------------
		Private methods
		-------------------------------------------------------------------------------------------*/
		
		/**
		 * 初始化
		 * 在第一次被添加到舞台上时调用
		 * @private
		 */
		protected function init():void {
			inited = true;
			validationQueue = ValidationQueue.getInstance();
			this.invalidate();
		}
		
		/**
		 * 重绘
		 * 在validate方法中被调用
		 * @private
		 */
		protected function draw():void {
			if (this.invalidationFlag.isInvalid(InvalidationFlag.SIZE))
				resize();
			if (this.invalidationFlag.isInvalid(InvalidationFlag.DATA))
				refreshData();
			if (this.invalidationFlag.isInvalid(InvalidationFlag.STATE))
				refreshState();
			if (this.invalidationFlag.isInvalid(InvalidationFlag.STYLE))
				refreshStyle();
			if (this.invalidationFlag.isInvalid(InvalidationFlag.TEXT))
				refreshText();
		}
		
		/**
		 * 重绘文本
		 * @private
		 */
		protected function refreshText():void { }
		
		/**
		 * 重绘风格样式
		 * @private
		 */
		protected function refreshStyle():void { }
		
		/**
		 * 重绘状态
		 * @private
		 */
		protected function refreshState():void { }
		
		/**
		 * 重绘数据
		 * @private
		 */
		protected function refreshData():void { }
		
		/**
		 * 重绘大小
		 * @private
		 */
		protected function resize():void { }
		
		/*-----------------------------------------------------------------------------------------
		Event Handlers
		-------------------------------------------------------------------------------------------*/
		
		/**
		 * 添加到舞台的事件
		 * @private
		 * @param	e
		 */
		protected function onAddToStage(e:Event):void {
			if (e.target == this) { 
				removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
				this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
				
				if (!inited) {
					init();
				}
			}
		}
		
		/**
		 * 从舞台上移除的事件
		 * @private
		 * @param	e
		 */
		protected function onRemoveFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		/**
		 * 鼠标按下，开始拖拽
		 * @private
		 * @param	e
		 */
		protected function onDragStart(e:TouchEvent):void {
			var touch:Touch = e.getTouch(this);
			if (touch) {
				if (touch.phase == TouchPhase.BEGAN) {
					DragManager.startDrag(this);
				}
			}
		}
	}

}