package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.Sprite;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.media.StageWebView;
	import flash.sensors.Accelerometer;
	import flash.text.TextField;
	


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
			setAccelerometer()
//			setUI()
			//
			butScan.addEventListener(MouseEvent.CLICK,setQRReader)
			


		}
		
		private function setAccelerometer():void
		{
			var accTextField:TextField=new TextField()
			/*var accl:Accelerometer; 
			if (Accelerometer.isSupported) 
			{ 
				accl = new Accelerometer(); 
				accl.addEventListener(AccelerometerEvent.UPDATE, updateHandler); 
			} 
			else 
			{ 
				accTextField.text = "Accelerometer feature not supported"; 
			} 
			function updateHandler(evt:AccelerometerEvent):void 
			{ 
				accTextField.text = "acceleration X: " + evt.accelerationX.toString() + "\n" 
					+ "acceleration Y: " + evt.accelerationY.toString() + "\n" 
					+ "acceleration Z: " + evt.accelerationZ.toString() 
			}
			*/
				
			var accl:Accelerometer; 
			var rollingX:Number = 0; 
			var rollingY:Number = 0; 
			var rollingZ:Number = 0; 
			const FACTOR:Number = 0.25; 
			
			if (Accelerometer.isSupported) 
			{ 
				accl = new Accelerometer(); 
				accl.setRequestedUpdateInterval(200); 
				accl.addEventListener(AccelerometerEvent.UPDATE, updateHandler); 
			} 
			else 
			{ 
				accTextField.text = "Accelerometer feature not supported"; 
			} 
			function updateHandler(event:AccelerometerEvent):void 
			{ 
				accelRollingAvg(event); 
				accTextField.text = rollingX + "\n" +  rollingY + "\n" + rollingZ + "\n"; 
			} 
			
			function accelRollingAvg(event:AccelerometerEvent):void 
			{ 
				rollingX = (event.accelerationX * FACTOR) + (rollingX * (1 - FACTOR)); 
				rollingY = (event.accelerationY * FACTOR) + (rollingY * (1 - FACTOR)); 
				rollingZ = (event.accelerationZ * FACTOR) + (rollingZ * (1 - FACTOR)); 
			}
				
			accTextField.scaleX=accTextField.scaleY=4
			addChild(accTextField)
			
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
