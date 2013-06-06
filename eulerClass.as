package
{
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import de.ketzler.nativeextension.EulerGyroscope;
	import de.ketzler.nativeextension.EulerGyroscopeEvent;
	

	public class eulerClass extends MovieClip 
	{
		
		private var gyro:EulerGyroscope;
		public var textField:TextField=new TextField()
		//
		public var yaw:Number;
		public var roll:Number;
		public var pitch:Number;
			
		public function eulerClass()
		{
			
			gyro=new EulerGyroscope();
			gyro.setRequestedUpdateInterval(30)
			gyro.addEventListener(EulerGyroscopeEvent.UPDATE, handleUpdate)
			//
			addChild(textField)
			
			
		}
		
		protected function handleUpdate(event:EulerGyroscopeEvent):void
		{
//			trace("------------------------")
//			trace("eulerClass.handleUpdate(event)");
			
			
			//   (Math.round(value/0.01)*0.01)  ---> 取小數位數到0.01位
//			yaw=(Math.round((event.yaw * 100) / 0.01) * 0.01)
//			roll=(Math.round((event.roll* 100) / 0.01) * 0.01)
//			pitch=(Math.round((event.pitch* 100) / 0.01) * 0.01)
			yaw=event.yaw * 100
			roll=event.roll* 100
			pitch=event.pitch* 100
				
				
//			trace("yaw= "+yaw)
//			trace("roll= "+roll)
			
			textField.background=true
			textField.autoSize=TextFieldAutoSize.LEFT
			textField.defaultTextFormat=new TextFormat(null,30)
			textField.text="yaw= " + yaw + "\n"
			    		  +"roll= " + roll + "\n" 
			
		}
		
	}
}