package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.Sprite;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.sensors.Accelerometer;
	import flash.sensors.Geolocation;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	


	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		private var qr:QRZBar;
		private var layerUI:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
//		private var butScan:Sprite=new Sprite()
		var geoTextField:TextField=new TextField()



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
			setGeo()
//			setAccelerometer()
//			setUI()
			//
			butScan.addEventListener(MouseEvent.CLICK,setQRReader)
			


		}
		
		private function setGeo():void
		{
			trace("Main.setGeo()");
			
			var geo:Geolocation; 
			 geoTextField=new TextField()

			
			if (Geolocation.isSupported) 
			{ 
				trace("support")
				geo = new Geolocation(); 
				
				geo.setRequestedUpdateInterval(1000);

				if (!geo.muted) 
				{ 
					trace("good")
					geo.addEventListener(GeolocationEvent.UPDATE, updateHandler); 
				}
				else
				{
					trace("muted")
				}
				geo.addEventListener(StatusEvent.STATUS, geoStatusHandler);  
			} 
			else 
			{ 
				geoTextField.text = "Geolocation feature not supported"; 
				trace("no")
			} 
			
			
			geoTextField.scaleX=geoTextField.scaleY=3
			geoTextField.autoSize= TextFieldAutoSize.LEFT
			addChild(geoTextField)
			
		}
		
		protected function geoStatusHandler(event:Event):void
		{
			trace("Main.geoStatusHandler(event)");
			
			
		}
		
		public function updateHandler(event:GeolocationEvent):void 
		{ 
			trace("Main.updateHandler(event)");
			
			geoTextField.text = "latitude: " + event.latitude.toString() + "\n" 
				+ "longitude: " + event.longitude.toString() + "\n" 
				+ "altitude: " + event.altitude.toString() + "\n"
				+ "speed: " + event.speed.toString() + "\n"
				+ "heading: " + event.heading.toString() + "\n"
				+ "horizontal accuracy: " + event.horizontalAccuracy.toString()+ "\n" 
				+ "vertical accuracy: " + event.verticalAccuracy.toString() 
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
