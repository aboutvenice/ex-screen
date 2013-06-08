/**
 * @author milkmidi
 */
package {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	public class reSizeClass  {		
		public static const CENTER  		:String = "CENTER";
		public static const CENTER_CROP 	:String = "CENTER_CROP";
		public static const CENTER_INSIDE 	:String = "CENTER_INSIDE";
		public static const FIT_START	 	:String = "FIT_START";
		//public static const FIT_CENTER		:String = "FIT_CENTER";
		public static const FIT_END		 	:String = "FIT_END";
		public static const FIT_XY		 	:String = "FIT_XY";	
		public static var nowScale:Number
		
		/**
		 * 物件的縮放範圍
		 * @param	pSrcWidth 原始寬
		 * @param	pSrcHeight 原始高
		 * @param	pReqWidth 可視高度
		 * @param	pReqHeight 可視高度
		 * @param	pScaleModel 縮放的方式
		 * @return 
		 */
		public static function getResizeRect(pSrcWidth:uint, pSrcHeight:uint , pReqWidth:int , pReqHeight:int , pScaleModel:String = "CENTER_CROP"):Rectangle {				
			var srcW		:uint = pSrcWidth;
			var srcH		:uint = pSrcHeight;			
			var reqW		:int = pReqWidth;
			var reqH		:int = pReqHeight;			
			var scale		:Number = 1;
			var rect		:Rectangle = new Rectangle();
			var posX		:int = 0;
			var posY		:int = 0;
			switch (pScaleModel) {
				case CENTER_INSIDE:
				case FIT_START:
				case FIT_END:
					scale = Math.min ( reqW / srcW, reqH / srcH );									
					break;
				case CENTER_CROP:
					scale = Math.max ( reqW / srcW, reqH / srcH );
					nowScale=scale
					trace("scale= "+scale)
					break;
			}			
			srcW  *= scale;
			srcH  *= scale;	
			rect.x = reqW - srcW >> 1;
			rect.y = reqH - srcH >> 1;		
			rect.width = srcW;
			rect.height = srcH;		
			switch (pScaleModel) {
				case CENTER:
					rect.x = pReqWidth - pSrcWidth >> 1;					
					rect.y = pReqHeight - pSrcHeight >> 1;					
					rect.width = pSrcWidth;
					rect.height = pSrcHeight;
					break;
				case FIT_START:
					rect.x = 0;
					rect.y = 0;
					break;
				case FIT_END:
					rect.x = reqW - rect.width;
					rect.y = reqH - rect.height;
					break;
				case FIT_XY:
					rect.x = 0;
					rect.y = 0;
					rect.width = reqW;
					rect.height = reqH;
					break;
			}			
			return rect;
		}		
		public static function resize( pDisplay:DisplayObject , pContainer:DisplayObject , pScaleModel:String = "CENTER_CROP" ):void {
			var reqW:int;
			var reqH:int;
			if (pContainer is Stage) {
				reqW = Stage(pContainer).stageWidth;
				reqH = Stage(pContainer).stageHeight;
			}else {
				reqW = pContainer.width;
				reqH = pContainer.height;
			}
			var rect:Rectangle = getResizeRect( pDisplay.width , pDisplay.height , reqW, reqH , pScaleModel );			
			pDisplay.x = rect.x;
			pDisplay.y = rect.y;
			pDisplay.width = rect.width;
			pDisplay.height = rect.height;
		}	
		
		public static function get getScale():Number 
		{
			
			return nowScale;
		}
	}	
}