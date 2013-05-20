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
		private var geoTextField:TextField=new TextField()
		private var accTextField:TextField=new TextField()
		private var rollingX:Number = 0; 
		private var rollingY:Number = 0; 
		private var rollingZ:Number = 0; 
		private const FACTOR:Number = 0.25; 
		private var ball:Sprite=new Sprite()





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
//			setGeo()
			setAccelerometer()
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
				
				geo.setRequestedUpdateInterval(100);

				if (!geo.muted) 
				{ 
					trace("good")
					geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler); 
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
		
		public function geoUpdateHandler(event:GeolocationEvent):void 
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
				
			var accl:Accelerometer; 
			
			if (Accelerometer.isSupported) 
			{ 
				accl = new Accelerometer(); 
				accl.setRequestedUpdateInterval(200); 
				accl.addEventListener(AccelerometerEvent.UPDATE, acclUpdateHandler); 
			} 
			else 
			{ 
				accTextField.text = "Accelerometer feature not supported"; 
			} 
			
		
				
			accTextField.scaleX=accTextField.scaleY=4
			accTextField.autoSize= TextFieldAutoSize.LEFT
			addChild(accTextField)
			//
			ball.graphics.beginFill(0xFF0000)
			ball.graphics.drawCircle(stage.stageWidth/2, stage.stageHeight/2, 30)
			addChild(ball)
			
		}
		
		public function acclUpdateHandler(event:AccelerometerEvent):void 
		{ 
			accelRollingAvg(event); 
		}
		
		public function accelRollingAvg(event:AccelerometerEvent):void 
		{ 
			rollingX = (event.accelerationX * FACTOR) + (rollingX * (1 - FACTOR)); 
			rollingY = (event.accelerationY * FACTOR) + (rollingY * (1 - FACTOR)); 
			rollingZ = (event.accelerationZ * FACTOR) + (rollingZ * (1 - FACTOR)); 
			
			accTextField.text = "acceleration X: " + rollingX.toFixed(2).toString() + "\n" 
				+ "acceleration Y: " + rollingY.toFixed(2).toString() + "\n" 
				+ "acceleration Z: " + rollingZ.toFixed(2).toString()
				
				ball.x+=rollingX*100*-1
				ball.y+=rollingY*100
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
