package
{
	import flash.display.Sprite;
	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class acclClass extends Sprite
	{
		
		public var accTextField:TextField=new TextField()
		public var rollingX:Number = 0; 
		public var rollingY:Number = 0; 
		public var rollingZ:Number = 0; 
		public const FACTOR:Number = 0.25; 

		
		public function acclClass()
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
			//
			rollingX=Number(rollingX.toFixed(2))
			rollingY=Number(rollingY.toFixed(2))
			rollingZ=Number(rollingZ.toFixed(2))
			
			accTextField.text = "acceleration X: " + rollingX.toFixed(2).toString() + "\n" 
				+ "acceleration Y: " + rollingY.toFixed(2).toString() + "\n" 
				+ "acceleration Z: " + rollingZ.toFixed(2).toString()
			
		}
	}
}