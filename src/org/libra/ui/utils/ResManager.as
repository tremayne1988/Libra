package org.libra.ui.utils {
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import flash.display.BitmapData;
	import org.libra.utils.HashMap;
	/**
	 * <p>
	 * Description
	 * </p>
	 *
	 * @class ResManager
	 * @author Eddie
	 * @qq 32968210
	 * @date 08-31-2012
	 * @version 1.0
	 * @see
	 */
	public final class ResManager {
		
		private static var instance:ResManager;
		
		private var resMap:HashMap;
		
		private var uiLoader:SWFLoader;
		
		public function ResManager(singleton:Singleton) {
			resMap = new HashMap();
		}
		
		/*-----------------------------------------------------------------------------------------
		Public methods
		-------------------------------------------------------------------------------------------*/
		
		public function init():void {
			this.uiLoader = LoaderMax.getLoader('UI');
		}
		
		public function getBitmapData(bmdName:String):BitmapData {
			var bmd:BitmapData = resMap.get(bmdName);
			if (bmd) return bmd;
			var c:Class = uiLoader.getClass(bmdName);
			bmd = c ? new c() : null;
			resMap.put(bmdName, bmd);
			return bmd;
		}
		
		public static function getInstance():ResManager {
			return instance ||= new ResManager(new Singleton());
		}
		
		/*-----------------------------------------------------------------------------------------
		Private methods
		-------------------------------------------------------------------------------------------*/
		
		/*-----------------------------------------------------------------------------------------
		Event Handlers
		-------------------------------------------------------------------------------------------*/
		
	}

}
class Singleton{}