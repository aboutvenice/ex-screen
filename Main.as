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
		private var butShowWeb:Sprite=new Sprite()
		private var butShowText:Sprite=new Sprite()
		private var butAddText:Sprite=new Sprite()
		private var butAddPhoto:Sprite=new Sprite()
		private var butSelectPhoto:Sprite=new Sprite()
		public var text_but:TextField

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
		//photo mode
		public var obj_photo:photoClass
		
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
//			addChild(stats)
			//--------------------------------------------------
			// function runs here
			//--------------------------------------------------
			setAccl()
			setUI()
			setCamera()
			//--------------------------------------------------
			// Listener
			//--------------------------------------------------			
			
			butShowText.addEventListener(MouseEvent.CLICK, setText)
			butShowWeb.addEventListener(MouseEvent.CLICK, addWebHandler)
			butAddText.addEventListener(MouseEvent.CLICK, addTextHandler)
			butAddPhoto.addEventListener(MouseEvent.CLICK, addPhotoHandler)
			butSelectPhoto.addEventListener(MouseEvent.CLICK, addSelectPhotoHandler)
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
		
		protected function addWebHandler(event:MouseEvent):void
		{
			tag_mode="Web"
			setQRReader(null)

			
		}	
		
		
		
		protected function addPhotoHandler(event:MouseEvent):void
		{
			obj_photo=new photoClass(stage)
			obj_photo.initCamera()
			tag_mode="PhotoTake"

			defindMode(null)

			
		}
		
		protected function addSelectPhotoHandler(event:MouseEvent):void
		{
			obj_photo=new photoClass(stage)
			obj_photo.initCameraRoll()
			tag_mode="PhotoSelect"
			defindMode(null)
		}

		private function setQRReader(e:MouseEvent):void
		{
			qr=new QRZBar()
//			qr = QRZBar.getInstance(); 
			qr.scan();

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
			defindMode(url)
			
			
		}
		
		private function defindMode(_url):void
		{
			
			if (tag_mode == "Web")
			{
				obj_web=new webClass(_url,this)
				layerContent.addChild(obj_web)
				
				obj_rotate=new rotateClass(obj_web, null)
				arrray_rotate.push(obj_rotate)
			}
			else if (tag_mode == "Text")
			{
				//set text Object
				obj_text=new textClass(_url)
				obj_rotate=new rotateClass(obj_text, null)
				arrray_rotate.push(obj_rotate)
				layerContent.addChild(obj_text)
			}
			else if (tag_mode == "PhotoTake")
			{
//				obj_rotate=new rotateClass(obj_photo, null)
//				arrray_rotate.push(obj_rotate)
//				layerContent.addChild(obj_photo)
				
			}
			else if (tag_mode == "PhotoSelect")
			{
				obj_rotate=new rotateClass(obj_photo, null)
				arrray_rotate.push(obj_rotate)
				layerContent.addChild(obj_photo)
			
			}
			
			//有第一個建立成功了，開始啓動移動模式
			tag_loaded=true

			
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

			butShowText.graphics.beginFill(0x00FF00)
			butShowText.graphics.drawCircle(0, 0, 50)
			butShowText.x=550
			butShowText.y=500
			text_but=new TextField()
			text_but.text="show text"
			text_but.textColor=0xFFFFFF				
			butShowText.addChild(text_but)
			//	
			butShowWeb.graphics.beginFill(0xFF0000)
			butShowWeb.graphics.drawCircle(0, 0, 50)
			butShowWeb.x=150
			butShowWeb.y=500	
			text_but=new TextField()
			text_but.textColor=0xFFFFFF				
			text_but.text="web"
			butShowWeb.addChild(text_but)
			//	
			butAddText.graphics.beginFill(0x0000FF)
			butAddText.graphics.drawCircle(0, 0, 50)
			butAddText.x=250
			butAddText.y=500
			text_but=new TextField()
			text_but.text="text"
			text_but.textColor=0xFFFFFF				
			butAddText.addChild(text_but)
			//	
			butAddPhoto.graphics.beginFill(0x0000F0)
			butAddPhoto.graphics.drawCircle(0, 0, 50)
			butAddPhoto.x=350
			butAddPhoto.y=500
			text_but=new TextField()
			text_but.text="photo"
			text_but.textColor=0xFFFFFF				
			butAddPhoto.addChild(text_but)
			//	
			butSelectPhoto.graphics.beginFill(0x0F00F0)
			butSelectPhoto.graphics.drawCircle(0, 0, 50)
			butSelectPhoto.x=450
			butSelectPhoto.y=500
			text_but=new TextField()
			text_but.text="select"
			text_but.textColor=0xFFFFFF				
			butSelectPhoto.addChild(text_but)
				//	
			layerUI.addChild(butShowWeb)
			layerUI.addChild(butShowText)
			layerUI.addChild(butAddText)
			layerUI.addChild(butAddPhoto)
			layerUI.addChild(butSelectPhoto)


		}


	}
}
