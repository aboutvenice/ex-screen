package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	


	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		private var qr:QRZBar;
		private var layerUI:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
		//
		public var obj_accl:acclClass=new acclClass()
		public var obj_geo:geoClass=new geoClass()	
		public var layerText:Sprite=new Sprite()


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
			stage.autoOrients=false
			stage.setOrientation(StageOrientation.ROTATED_RIGHT)
			//
			addChild(layerText)	
			addChild(layerUI)
			//
			setAccl()
//			setUI()
			
			//
			butScan.addEventListener(MouseEvent.CLICK,setQRReader)
		}
		
		private function setAccl():void
		{
			layerText.addChild(obj_accl.accTextField)
			obj_geo.geoTextField.y=150
			layerText.addChild(obj_geo.geoTextField)
			
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
