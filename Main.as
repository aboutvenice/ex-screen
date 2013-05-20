package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.net.navigateToURL; 


	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		private var qr:QRZBar;
		private var layerUI:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
//		private var butScan:Sprite=new Sprite()
		var html:HTMLLoader = new HTMLLoader();



		public function Main()
		{


			if (stage)
			{
				init()
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		public function init(e:Event=null):void
		{
			addChild(layerUI)
			//
			setUI()
			//
			butScan.addEventListener(MouseEvent.CLICK,setQRReader)
			


		}
		
		private function setUI():void
		{
			
			butScan.graphics.beginFill(0xFF0000)
			butScan.graphics.drawCircle(100, 100, 100)
			//	
			layerUI.addChild(butScan)


		}

		private function setQRReader(e:MouseEvent):void
		{
			qr=new QRZBar();
			qr.scan();
			//
			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);

		}

		protected function scannedHandler(event:QRZBarEvent):void
		{
			qr.removeEventListener(QRZBarEvent.SCANNED, scannedHandler);
			
			var url:String=event.result
			var webView:StageWebView = new StageWebView(); 

			webView.stage = this.stage; 
			webView.viewPort = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ); 
			webView.loadURL(url) 
		
		}
		

	}
}
