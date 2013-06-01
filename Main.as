package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import net.hires.debug.Stats;
	



	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]
//	[SWF(width="1632", height="816", backgroundColor="#FFFFFF", frameRate="31")]



	public class Main extends Sprite
	{

		public var stats:Stats=new Stats()	
		private var qr:QRZBar;
		private var layerContent:Sprite=new Sprite();
		public var layerText:Sprite=new Sprite()
		private var layerUI:Sprite=new Sprite()
		private var layerCam:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
		private var butShowText:Sprite=new Sprite()
		private var butAddText:Sprite=new Sprite()
		private var butAddPic:Sprite=new Sprite()
		//
		public var obj_accl:acclClass=new acclClass()
		public var obj_geo:geoClass=new geoClass()
		public var defaultX:Number=0
		public var defaultY:Number=0
		public var defaultZ:Number=0
		public var defaultH:Number=0
		public var timer_default:Timer
		public var tag_start:Boolean=false
		//
		public var difX:Number=0
		public var difY:Number=0
		public var difZ:Number=0
		public var difH:Number=0 //the distance from last Heading Value
		public var preH:Number=0 //pre Heading Value
		public var disP:Number=0 //the distance website should move 
		private var moveRate:int=6; //move distance,mapping to stage
		//
		public var obj_rotate:rotateClass
		public var arrray_rotate:Array=new Array()
		public var preZ:Number=0
		public var disZ:Number=0
		//web mode
		public var obj_web:webClass
		private var tag_loaded:Boolean=false; //web load complete
		public var moveRect:Rectangle=new Rectangle(0, 0, 800 / 2, 600 / 2)
		private var tag_Text:Boolean=false; //show/hide text
		//text mode
		private var tag_mode:String;
		public var obj_text:textClass
		//
		public var cam:Camera
		public var vid:Video
		public var text_diff:TextField=new TextField()



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
			//--------------------------------------------------
			// visual
			//--------------------------------------------------
			layerText.visible=true
			addChild(layerCam)
			addChild(layerContent)
			addChild(layerText)
			addChild(layerUI)
			stats.scaleX=stats.scaleY=2
			addChild(stats)
			//--------------------------------------------------
			// function runs here
			//--------------------------------------------------
			setAccl()
			setUI()
			setCamera()
			//--------------------------------------------------
			// Listener
			//--------------------------------------------------			
			butScan.addEventListener(MouseEvent.CLICK, setQRReader)
			butShowText.addEventListener(MouseEvent.CLICK, setText)
			butAddText.addEventListener(MouseEvent.CLICK, addTextHandler)
			butAddPic.addEventListener(MouseEvent.CLICK, addPicHandler)
			stage.addEventListener(Event.ENTER_FRAME, onRun)
		}


		private function setCamera():void
		{

			while (layerCam.numChildren)
			{
				layerCam.removeChildAt(0)
			}

			var camW:int=stage.stageWidth
			var camH:int=stage.stageHeight

			// Create the camera
			cam=Camera.getCamera();
			cam.setMode(camW, camH, stage.frameRate);
			cam.setQuality(0, 100)

			// Create a video <--------scene we see
			vid=new Video(camW, camH);
			vid.attachCamera(cam);
//			vid.y=-102
			layerCam.addChild(vid)
		}

		protected function setText(event:MouseEvent):void
		{
			if (!tag_Text)
			{
				tag_Text=true
				layerText.visible=true
			}
			else
			{
				tag_Text=false
				layerText.visible=false

			}

		}

		public function onRun(e:Event):void

		{
			if (tag_start)
			{
				difX=defaultX - obj_accl.rollingX
				difY=defaultY - obj_accl.rollingY
				difZ=defaultZ - obj_accl.rollingZ
				//
				if (preH <= 90 && obj_geo.heading >= 270)
				{
//					trace("H減少，從90經過0，到350")
					difH=(obj_geo.heading - 360) - preH

				}
				else if (preH >= 270 && obj_geo.heading <= 90)
				{
//					trace("Ｈ增加，從270經過0，到90")
					difH=(obj_geo.heading + 360) - preH

				}
				else
				{
					//上一個heading的位置值減掉現在的
					difH=obj_geo.heading - preH
				}

				disP=(difH * -1) //乘負數，網頁移動位置與視角相反
				disP*=moveRate //<-網頁移動的距離比率
				preH=obj_geo.heading
				//
//				basicMatrix=frame.transform.matrix3D //設定ball的matrix
				makeMovement()
				//	
				text_diff.text="diifX= " + difX.toFixed(2) + "\n" + "diifY= " + difY.toFixed(2) + "\n" + "diifZ= " + difZ.toFixed(2) + "\n" + "defaultH= " + defaultH + "\n" + "diifH= " + difH.toFixed(2) + "\n" + "disP= " + disP.toFixed(2) + "\n" + "defaultZ= " + defaultZ

			}

		}

		public function makeMovement():void
		{

			if (tag_loaded)
			{

				if (obj_accl.rollingZ > 0)
				{
					disZ=obj_accl.rollingZ - preZ

				}
				else if (obj_accl.rollingZ < 0)
				{

					disZ=(Math.abs(obj_accl.rollingZ) - Math.abs(preZ)) * -1
				}

				difZ*=-1 * moveRate
				//
				
				for (var i:int = 0; i < arrray_rotate.length; i++) 
				{	
					var nowObj:Object=arrray_rotate[i]
					nowObj.start(disP, disZ) //call the left-right rotate matrix class's functoin

				}
				
				preZ=obj_accl.rollingZ

//				webView.viewPort=frame.getBounds(this)
//				tag_loaded=false

			}

		}

		//--------------------------------------------------
		//
		// Handler Function
		//
		//--------------------------------------------------
		protected function addTextHandler(event:MouseEvent):void
		{
			tag_mode="Text"
			//	
			setQRReader(null)
			
		}
		
		
		
		protected function addPicHandler(event:MouseEvent):void
		{
			
			
		}

		private function setQRReader(e:MouseEvent):void
		{
			qr=new QRZBar()
//			qr = QRZBar.getInstance(); 
			qr.scan();

			tag_mode="Web"

			//
//			qr.addEventListener(QRZBarEvent.SCANNED_BAR_CODE, scannedHandler);
//			qr.addEventListener(QRZBarEvent.CANCELED_SCAN, cancelHandler);
			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);
//			qr.addEventListener(QRZBarEvent.CANCELED_SCAN, scannedHandler);

		}

		protected function scannedHandler(event:QRZBarEvent):void
		{

//			qr.removeEventListener(QRZBarEvent.SCANNED_BAR_CODE, scannedHandler);

			qr.removeEventListener(QRZBarEvent.SCANNED, scannedHandler);
//			setCamera()

//			trace("cam= "+cam.activityLevel)
//			trace("vid= "+vid)
//			vid.attachCamera(cam)
//			trace("cam= "+cam.activityLevel)
//			trace("vid stage= "+vid.stage)

			var url:String=event.result

				
			if (tag_mode == "Web")
			{
				obj_web=new webClass(url,this)
				layerContent.addChild(obj_web)

				obj_rotate=new rotateClass(obj_web, null)
				arrray_rotate.push(obj_rotate)
//				//
				tag_loaded=true
	

				
			}
			else if (tag_mode == "Text")
			{
				//set text Object
				obj_text=new textClass(url)
				obj_rotate=new rotateClass(obj_text, null)
				arrray_rotate.push(obj_rotate)
				layerContent.addChild(obj_text)
				//	
				tag_loaded=true

			}	
		}

		protected function cancelHandler(event:QRZBarEvent):void
		{
//			setCamera()
			trace("cancel")

		}


		


		//----------------------------------------------------------------------------------------------------
		//
		// set function
		//
		//----------------------------------------------------------------------------------------------------


		private function setAccl():void
		{

			setDefaultValue()
			//
			obj_geo.geoTextField.y=150
			//
			text_diff.x=450
			text_diff.scaleX=text_diff.scaleY=4
			text_diff.autoSize=TextFieldAutoSize.LEFT
			//	
			layerText.addChild(obj_accl.accTextField)
			layerText.addChild(obj_geo.geoTextField)
			layerText.addChild(text_diff)

		}

		private function setDefaultValue():void
		{
			timer_default=new Timer(3000, 1)
			timer_default.addEventListener(TimerEvent.TIMER_COMPLETE, setValueHandler)
			timer_default.start()

		}

		protected function setValueHandler(event:TimerEvent):void
		{
			//--------------------------------------------------
			// 程式啓動後一段時間，才設定初始角度
			//--------------------------------------------------
			defaultX=obj_accl.rollingX
			defaultY=obj_accl.rollingY
			defaultZ=obj_accl.rollingZ
			defaultH=obj_geo.heading
			preH=defaultH
			preZ=defaultZ
			//	
			timer_default.stop()
			timer_default.removeEventListener(TimerEvent.TIMER_COMPLETE, setValueHandler)
			trace("set complete")
			trace("defaultX= " + defaultX)
			trace("defaultY= " + defaultY)
			trace("defaultZ= " + defaultZ)
			trace("defaultH= " + defaultH)
			trace("default preH= " + preH)
			trace("default Heading= " + obj_geo.heading)
			trace("-------")
			tag_start=true


		}


		private function setUI():void
		{

			butScan.graphics.beginFill(0xFF0000)
			butScan.graphics.drawCircle(50, 500, 50)
			butShowText.graphics.beginFill(0x00FF00)
			butShowText.graphics.drawCircle(150, 500, 50)
			butAddText.graphics.beginFill(0x0000FF)
			butAddText.graphics.drawCircle(250, 500, 50)
			butAddPic.graphics.beginFill(0x0000F0)
			butAddPic.graphics.drawCircle(350, 500, 50)
			//	
			layerUI.addChild(butScan)
			layerUI.addChild(butShowText)
			layerUI.addChild(butAddText)
			layerUI.addChild(butAddPic)


		}


	}
}
