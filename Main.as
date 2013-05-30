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
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.StageWebView;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;



	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]
//	[SWF(width="1632", height="816", backgroundColor="#FFFFFF", frameRate="31")]



	public class Main extends Sprite
	{

		private var qr:QRZBar;
		private var layerContent:Sprite=new Sprite();
		public var layerText:Sprite=new Sprite()
		private var layerUI:Sprite=new Sprite()
		private var layerCam:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
		private var butText:Sprite=new Sprite()
		private static var ball:Shape=new Shape()
		private static var center:Shape=new Shape()
		//
		public static var obj_accl:acclClass=new acclClass()
		public static var obj_geo:geoClass=new geoClass()
		public static var defaultX:Number=0
		public static var defaultY:Number=0
		public static var defaultZ:Number=0
		public static var defaultH:Number=0
		public static var timer_default:Timer
		public static var tag_start:Boolean=false
		//
		public static var difX:Number=0
		public static var difY:Number=0
		public static var difZ:Number=0
		public static var difH:Number=0 //the distance from last Heading Value
		public static var preH:Number=0 //pre Heading Value
		public static var disP:Number=0 //the distance website should move 
		private static var moveRate:int=6; //move distance,mapping to stage
		public static var basicMatrix:Matrix3D=new Matrix3D()
		//
		public static var obj_rotate:rotateClass
		public static var preZ:Number=0
		public static var disZ:Number=0
		//
		public static var webView:StageWebView
		private static var tag_loaded:Boolean=false; //web load complete
		public static var moveRect:Rectangle=new Rectangle(0, 0, 800 / 2, 600 / 2)
		private static var tag_Text:Boolean=false; //show/hide text
		//
		public var cam:Camera
		public var vid:Video
		//
		public static var text_diff:TextField=new TextField()



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
			layerText.visible=false
			addChild(layerCam)
			addChild(layerContent)
			addChild(layerText)
			addChild(layerUI)
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
			butText.addEventListener(MouseEvent.CLICK, setText)
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

		public static function onRun(e:Event):void
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
				basicMatrix=ball.transform.matrix3D //設定ball的matrix
				makeMovement()
				//	
				text_diff.text="diifX= " + difX.toFixed(2) + "\n" + "diifY= " + difY.toFixed(2) + "\n" + "diifZ= " + difZ.toFixed(2) + "\n" + "defaultH= " + defaultH + "\n" + "diifH= " + difH.toFixed(2) + "\n" + "disP= " + disP.toFixed(2) + "\n" + "defaultZ= " + defaultZ

			}

		}

		private static function makeMovement():void
		{
			

			if (obj_accl.rollingZ > 0)
			{
				disZ=obj_accl.rollingZ - preZ
				
			}
			else if (obj_accl.rollingZ < 0)
			{
				
				disZ=(Math.abs(obj_accl.rollingZ) - Math.abs(preZ))*-1
			}
			
			difZ*=-1*moveRate
			trace("difZ= "+difZ.toFixed(2))
			trace("--------------------------------------")
			
			
			obj_rotate.start(disP,disZ)  //call the left-right rotate matrix class's functoin
			
			preZ=obj_accl.rollingZ 




			if (tag_loaded)
			{
				//
				moveRect.x+=disP
				webView.viewPort=moveRect
			}

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
			webView=new StageWebView();
			webView.stage=this.stage;
			webView.loadURL(url)
			webView.addEventListener(Event.COMPLETE, loadFinishHandler)
		}

		protected function cancelHandler(event:QRZBarEvent):void
		{
//			setCamera()
			trace("cancel")

		}

		protected function loadFinishHandler(event:Event):void
		{

			tag_loaded=true

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
			butText.graphics.beginFill(0x00FF00)
			butText.graphics.drawCircle(150, 500, 50)
			//	
			layerUI.addChild(butScan)
			layerUI.addChild(butText)
			//

			ball.x=ball.y=ball.z=0
			ball.graphics.beginFill(0xFF0000, .5)
			ball.graphics.drawRect(0, (stage.stageHeight / 2) - (400 / 2), 400, 300)
			layerContent.addChild(ball)
			//
			center.graphics.beginFill(0x00FF00)
			center.graphics.drawCircle(400 - ball.width / 2, stage.stageHeight / 2, 3)
			layerContent.addChild(center)
			//
			obj_rotate=new rotateClass(ball, center)
			obj_rotate.setPointStart=ball.width / 2
			addChild(obj_rotate)


		}


	}
}
