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
		
		public function webClass(_url:String,_parent:DisplayObject)
		{
			
			webView=new StageWebView();
			webView.stage=_parent.stage
			myParent=_parent
			webView.loadURL(_url)
			webView.addEventListener(Event.COMPLETE, loadFinishHandler)
		}
		
		protected function loadFinishHandler(event:Event):void
		{
			
			frame=new Sprite()
			frame.x=frame.y=frame.z=0
			frame.graphics.beginFill(0xFFFFFF, .5)
			frame.graphics.drawRect(0, 0, 600, 400)
			addChild(frame)
			//
			webView.viewPort=frame.getBounds(myParent)

				
			this.addEventListener(Event.ENTER_FRAME,onRun)
			
		}
		
		protected function onRun(event:Event):void
		{
			webView.viewPort=frame.getBounds(myParent)

			
		}
	}
}