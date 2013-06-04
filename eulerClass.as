package
{
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import de.ketzler.nativeextension.EulerGyroscope;
	import de.ketzler.nativeextension.EulerGyroscopeEvent;
	
	
	

	public class eulerClass extends MovieClip 
	{
		
		private var gyro:EulerGyroscope;
		public var textField:TextField=new TextField()
		public var timer_default:Timer
		//
		public var yaw:Number;
		public var roll:Number;
		public var pitch:Number;
		public var defaultYaw:Number;
		public var defaultRoll:Number;
		public var difYaw:Number;
		public var difRoll:Number;
		public var tag_start:Boolean=false
		//
			
		public function eulerClass()
		{
			
			gyro=new EulerGyroscope();
			gyro.setRequestedUpdateInterval(30);
			gyro.addEventListener(EulerGyroscopeEvent.UPDATE, handleUpdate)
			//
			addChild(textField)
			
			
			setDefaultValue()
		}
		
		protected function handleUpdate(event:EulerGyroscopeEvent):void
		{
//			trace("eulerClass.handleUpdate(event)");
			
			
			//   (Math.round(value/0.01)*0.01)  ---> 取小數位數到0.01位
			yaw=(Math.round(event.yaw * 100) / 0.01) * 0.01
			roll=(Math.round(event.roll* 100) / 0.01) * 0.01
			pitch=(Math.round(event.pitch* 100) / 0.01) * 0.01
			//
//			difYaw=yaw - defaultYaw
//			difRoll=roll - defaultRoll
			
			textField.text="yaw= " + yaw + "\n"
			    		  +"roll= " + roll + "\n" 
			
		}
		
		private function setDefaultValue():void
		{
			timer_default=new Timer(1000, 1)
			timer_default.addEventListener(TimerEvent.TIMER_COMPLETE, setValueHandler)
			timer_default.start()
			
		}
		
		protected function setValueHandler(event:TimerEvent):void
		{
			//--------------------------------------------------
			// 程式啓動後一段時間，才設定初始角度
			//--------------------------------------------------
			defaultYaw=yaw
			defaultRoll=roll
			//	
			timer_default.stop()
			timer_default.removeEventListener(TimerEvent.TIMER_COMPLETE, setValueHandler)
			trace("set complete")
			tag_start=true
			
			
		}
	}
}