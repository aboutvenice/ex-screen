package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;

	public class webClass extends MovieClip
	{
		
		public var webView:StageWebView
		public var frame:Sprite
		public var bound:Rectangle=new Rectangle()
		public var myParent:DisplayObject
		public var obj_rotate:rotateClass

		private var tag_load:Boolean=false
		
		public function webClass(_url:String,_parent:DisplayObject)
		{
			
			webView=new StageWebView();
			webView.stage=_parent.stage
			myParent=_parent
			webView.loadURL(_url)
			webView.addEventListener(Event.COMPLETE, loadFinishHandler)
		}
		
		public function loadFinishHandler(event:Event):void
		{
			
			frame=new Sprite()
			frame.x=frame.y=frame.z=0
			frame.graphics.beginFill(0xFFFFFF, .5)
			frame.graphics.drawRect(0, 0, 800, 800)
			addChild(frame)
			//
			webView.viewPort=frame.getBounds(myParent)
				tag_load=true

				
//			this.addEventListener(Event.ENTER_FRAME,onRun)
			
		}
		
//		protected function onRun(event:Event):void
		public function onRun():void
		{
			if (tag_load) 
			{
				trace("webClass.onRun()");
				trace("webView.viewPort= "+webView.viewPort)
				trace("frame= "+frame)
				trace("myParent= "+myParent)
				
				webView.viewPort=frame.getBounds(myParent)

			}
		
			
		}
		
		public function setRotate(_yaw:Number,_roll:Number):void
		{
			obj_rotate=new rotateClass(this,_yaw,_roll)
			
		}
		
		public function removeSelf():void
		{
			this.parent.removeChild(this);
			
		}
	}
}