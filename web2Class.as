package
{
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	
	import es.xperiments.media.StageWebViewBridge;
	import es.xperiments.media.StageWebViewBridgeEvent;
	import es.xperiments.media.StageWebViewDisk;
	import es.xperiments.media.StageWebviewDiskEvent;
	
	public class web2Class extends MovieClip
	{
		public var view:StageWebViewBridge;
		private var URL:String;
		
		
		
		public function web2Class(_url:String,stage:Stage)
		{
			URL=_url
			
			StageWebViewDisk.addEventListener(StageWebviewDiskEvent.END_DISK_PARSING, onInit );
			StageWebViewDisk.setDebugMode( true );
			StageWebViewDisk.initialize(stage);
			
		}
		
		public function onInit( e:StageWebviewDiskEvent ):void
		{
			
			// create the view
			view = new StageWebViewBridge( 0,0, 320,240 );
			
			view.addEventListener(Event.COMPLETE,onDeviceReady)
			view.addEventListener( StageWebViewBridgeEvent.ON_GET_SNAPSHOT, onGetSnapShot );
			//
			view.loadURL(URL)
			
			
		}
		
		public function onGetSnapShot( e:StageWebViewBridgeEvent ):void
		{
			trace("web2Class.onGetSnapShot(e)");
			
			// remove listener
			view.removeEventListener( StageWebViewBridgeEvent.ON_GET_SNAPSHOT, onGetSnapShot );
			// set the bitmapdata visible, hides the stagewebview
			view.snapShotVisible = true; //set true for rotatoin
			//
			view.x=100
			view.y=100
			view.rotationY=10
			view.rotationX=10
			
		}			
		
		public function onDeviceReady( e:Event ):void
		{
			trace("web2Class.onDeviceReady(e)");
			view.getSnapShot()
			addChild( view );
			
		}
	}
}