package org.libra.tick {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.sampler.NewObjectSample;
	import flash.utils.getTimer;
	import org.libra.utils.MathUtil;
	
	/**
	 * EnterFrame事件管理类。所有需要注册EnterFrame事件的对象都可以通过该类管理。
	 * @author Eddie
	 */
	public final class Tick {
		
		/**
		 * 单例模式
		 * @private
		 */
		private static var instance:Tick;
		
		/**
		 * 事件的载体。可以是主类Main，也可以是一个shape。
		 * 只要是EventDispatcher的子类即可。
		 * @private
		 */
		private var shape:Shape;
		
		/**
		 * 是否暂停。默认不暂停。
		 * @private
		 * @default false
		 */
		private var pause:Boolean;
		
		/**
		 * 需要注册EnterFrame事件的ITickable的集合
		 * @private
		 */
		private var tickEnabledList:Vector.<ITickable>;
		
		/**
		 * 最大两帧间隔（防止待机后返回卡死） 
		 * @private
		 */
		static public const MAX_INTERVAL:int = 3000;
		
		/**
		 * @private
		 */
		static public const MIN_INTERVAL:int = 0;
		
		/**
		 * 速度系数
		 * 可由此实现慢速播放
		 * @private
		 */		
		public var speed:Number = 1.0;
		
		/**
		 * 上次记录的时间
		 * @private
		 */
		private var prevTime:int;
		
		/**
		 * 构造函数
		 * @private
		 * @param	shape，事件的载体。EventDispatcher的子类
		 */
		public function Tick(shape:Shape, singleton:Singleton) { 
			this.shape = shape;
			tickEnabledList = new Vector.<ITickable>();
			instance = this;
			pause = true;
			setPause(false);
		}
		
		/**
		 * 增加一个需要注册EnterFrame事件的ITickable
		 * @param	r ITickable
		 */
		public function addItem(item:ITickable):Boolean {
			if (hasItem(item)) return false;
			this.tickEnabledList[this.tickEnabledList.length] = item;
			return true;
		}
		
		/**
		 * 移除一个需要注册EnterFrame事件的ITickable
		 * @param	r ITickable
		 */
		public function removeItem(item:ITickable):Boolean {
			var index:int = this.tickEnabledList.indexOf(item);
			if (index != -1) {
				this.tickEnabledList.splice(index, 1);
				return true;
			}
			return false;
		}
		
		/**
		 * 清除对象
		 */
		public function clearItem():void {
			this.tickEnabledList.length = 0;
		}
		
		/**
		 * 清除掉积累的时间（在暂停之后）
		 */
		public function clear():void {
			this.prevTime = 0;
		}
		
		/**
		 * 判断该ITickable是否已经存在
		 * @param	i 被判断的ITickable
		 * @return Boolean
		 */
		public function hasItem(i:ITickable):Boolean {
			return this.tickEnabledList.indexOf(i) != -1;
		}
		
		/**
		 * 设置是否暂停。true：暂停。false：不暂停
		 * @param	v
		 */
		public function setPause(v:Boolean):void {
			if (pause == v) {
				return;
			}
			this.pause = v;
			if (v) {
				this.shape.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}else {
				this.shape.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}
		}
		
		/**
		 * 获取是否暂停信息
		 * @return
		 */
		public function isPause():Boolean {
			return this.pause;
		}
		
		/**
		 * EnterFrame事件循环。
		 * @private
		 * @param	e
		 */
		private function onEnterFrameHandler(e:Event):void {
			var nextTime:int = getTimer();
			if (!pause) {
				var interval:int;
				if (prevTime == 0) interval = 0;
				else {
					interval = MathUtil.max(MIN_INTERVAL, MathUtil.min(nextTime - prevTime, MAX_INTERVAL));
					//var e:TickEvent = new TickEvent(TickEvent.TICK);
					//e.interval = interval * speed;
					//dispatchEvent(e);
					interval *= speed;
					for each(var r:ITickable in tickEnabledList) {
						r.tick(interval);
					}
				}
			}
			prevTime = nextTime;
		}
		
		
		/**
		 * 获取当前实例。
		 * @private
		 * @return Tick
		 */
		public static function getInstance():Tick {
			return instance ||= new Tick(new Shape(), new Singleton());
		}
		
	}

}

/**
 * 单例模式
 * @private
 */
final class Singleton{}