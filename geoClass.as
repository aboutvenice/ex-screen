package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.StatusEvent;
	import flash.sensors.Geolocation;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class geoClass extends Sprite
	{
		public var geoTextField:TextField=new TextField()
		public var heading:Number;
		
		public function geoClass()
		{
			
			var geo:Geolocation; 
			geoTextField=new TextField()
			
			
			if (Geolocation.isSupported) 
			{ 
				geo = new Geolocation(); 
				
				geo.setRequestedUpdateInterval(200);
				
				if (!geo.muted) 
				{ 
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
			} 
			
			
			geoTextField.scaleX=geoTextField.scaleY=4
			geoTextField.autoSize= TextFieldAutoSize.LEFT
			addChild(geoTextField)
			
		}
		
		
		
		protected function geoStatusHandler(event:Event):void
		{
			trace("Main.geoStatusHandler(event)");
			
			
		}
		
		public function geoUpdateHandler(event:GeolocationEvent):void 
		{ 
			
			/*geoTextField.text = "latitude: " + event.latitude.toString() + "\n" 
				+ "longitude: " + event.longitude.toString() + "\n" 
				+ "altitude: " + event.altitude.toString() + "\n"
				+ "speed: " + event.speed.toString() + "\n"
				+ "heading: " + event.heading.toString() + "\n"
				+ "horizontal accuracy: " + event.horizontalAccuracy.toString()+ "\n" 
				+ "vertical accuracy: " + event.verticalAccuracy.toString() */
			
			geoTextField.text = "heading: " + event.heading.toFixed(2).toString() + "\n"
			heading=Number(event.heading.toFixed(2))
			//
			Main.onRun()
				
		}
	}
}