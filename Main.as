package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		private var qr:QRZBar;
		private var layerUI:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
//		private var butScan:Sprite=new Sprite()



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


			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);

		}

		protected function scannedHandler(event:QRZBarEvent):void
		{
			qr.removeEventListener(QRZBarEvent.SCANNED, scannedHandler);
			trace(event.result);
		}

	}
}
