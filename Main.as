package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;

	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	import net.hires.debug.Stats;



	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="30")]
//	[SWF(width="1632", height="816", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		public var stats:Stats=new Stats()
		private var qr:QRZBar=new QRZBar();
		private var layerContent:Sprite=new Sprite();
		public var layerText:Sprite=new Sprite()
		private var layerUI:Sprite=new Sprite()
		private var layerCam:Sprite=new Sprite()
		private var butShowWeb:Sprite=new Sprite()
		private var butShowText:Sprite=new Sprite()
		private var butAddText:Sprite=new Sprite()
		private var butAddPhoto:Sprite=new Sprite()
		private var butSelectPhoto:Sprite=new Sprite()
//		private var butPin:Sprite=new Sprite()
		private var butKill:Sprite=new Sprite()

		public var text_but:TextField
		//tag
		private var tag_Text:Boolean=false; //show/hide text
		private var tag_mode:String;
		//euler angle
		public var obj_euler:eulerClass=new eulerClass()
		public var nowYaw:Number
		public var nowRoll:Number
		private var diffYaw:Number;
		private var diffRoll:Number;
		//
		public var obj_rotate:rotateClass
		public var array_FrameObj:Array=new Array() //sava all the display frame
		//web mode
		public var obj_web:webClass
		private var tag_loaded:Boolean=false; //web load complete
		//text mode
		public var obj_text:textClass
		//photo mode
		public var obj_photo:photoClass
		//camera
		public var cam:Camera
		public var vid:Video
		public var text_diff:TextField=new TextField()
		public var ball:Sprite
		//choice 
		public var nowObj:* //use in onRun()
		private var totalObj:int=0; //use in onRun()
		public var nowObjSelect:* //select by click
		public var nowObjectIndex:int

		private var ptScalePoint:Point;




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
			stage.quality=StageQuality.LOW;
			Multitouch.inputMode=MultitouchInputMode.GESTURE;
			stage.autoOrients=false
			stage.setOrientation(StageOrientation.ROTATED_RIGHT)
			//--------------------------------------------------
			// visual
			//--------------------------------------------------
			layerText.visible=true
			addChild(layerCam)
//			layerContent.cacheAsBitmap=true
//			layerContent.cacheAsBitmapMatrix=new Matrix()
			layerContent.name="layerContent"
			addChild(layerContent)
			addChild(layerText)
			addChild(layerUI)
			stats.scaleX=stats.scaleY=2
			stats.x=-90
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

			butShowText.addEventListener(MouseEvent.CLICK, setText)
			butShowWeb.addEventListener(MouseEvent.CLICK, addWebHandler)
			butAddText.addEventListener(MouseEvent.CLICK, addTextHandler)
			butAddPhoto.addEventListener(MouseEvent.CLICK, addPhotoHandler)
			butSelectPhoto.addEventListener(MouseEvent.CLICK, addSelectPhotoHandler)
			stage.addEventListener(Event.ENTER_FRAME, onRun)
			stage.addEventListener(MouseEvent.CLICK, chooseObjHandler)
			butKill.addEventListener(MouseEvent.CLICK, removeFrameObject)



		}



		protected function onRun(event:Event):void
		{

			nowYaw=obj_euler.yaw
			nowRoll=obj_euler.roll

			if (tag_loaded)
			{


				totalObj=array_FrameObj.length

				for (var i:int=0; i < totalObj; i++)
				{
					nowObj=array_FrameObj[i]
					diffYaw=nowYaw - nowObj.obj_rotate.defaultYaw
					diffRoll=nowRoll - nowObj.obj_rotate.defaultRoll
					//
					nowObj.obj_rotate.start(diffYaw, diffRoll)

					if (nowObj == "[object webClass]")
					{
//						nowObj.onRun()

					}

				}

//				trace("array_FrameObj= "+array_FrameObj)
				text_diff.text="Obj number= " + array_FrameObj.length

			}


		}



		private function setCamera():void
		{

			/*while (layerCam.numChildren)
			{
				layerCam.removeChildAt(0)
			}

			var camW:int=stage.stageWidth
			var camH:int=stage.stageHeight

			// Create the camera
			cam=Camera.getCamera();
			cam.setMode(camW, camH, 30);
			cam.setQuality(0, 100)

			// Create a video <--------scene we see
			vid=new Video(camW, camH);
			vid.attachCamera(cam);
			layerCam.addChild(vid)*/


			while (layerCam.numChildren)
			{
				layerCam.removeChildAt(0)
			}

			var camW:int=stage.stageWidth / 1.6
			var camH:int=stage.stageHeight / 2

			// Create the camera
			cam=Camera.getCamera();
			cam.setMode(camW, camH, 10); //frameRate影響頗大
			cam.setQuality(0, 10)


			// Create a video <--------scene we see
			vid=new Video(camW, camH);
			vid.attachCamera(cam);
			vid.scaleX=vid.scaleY=2
//			vid.cacheAsBitmap=true
			vid.x=-90
			layerCam.addChild(vid)
			trace("layerCam.numChildren= " + layerCam.numChildren)
			//
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


		//--------------------------------------------------
		//
		// Handler Function
		//
		//--------------------------------------------------

		protected function addWebHandler(event:MouseEvent):void
		{
			tag_mode="Web"
			setQRReader(null)

		}

		protected function addTextHandler(event:MouseEvent):void
		{

			tag_mode="Text"
			//	
			setQRReader(null)

		}



		protected function addPhotoHandler(event:MouseEvent):void
		{
			obj_photo=new photoClass(stage)
			obj_photo.initCamera()
			tag_mode="PhotoTake"
			obj_photo.cacheAsBitmap=true
			obj_photo.cacheAsBitmapMatrix=obj_photo.transform.concatenatedMatrix
			defindMode(null)


		}

		protected function addSelectPhotoHandler(event:MouseEvent):void
		{
			obj_photo=new photoClass(stage)
			obj_photo.initCameraRoll()
			tag_mode="PhotoSelect"
			obj_photo.cacheAsBitmap=true
			obj_photo.cacheAsBitmapMatrix=obj_photo.transform.concatenatedMatrix
			defindMode(null)

		}

		private function setQRReader(e:MouseEvent):void
		{
//			qr=new QRZBar()
			qr.scan();

			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);

		}

		protected function scannedHandler(event:QRZBarEvent):void
		{


			qr.removeEventListener(QRZBarEvent.SCANNED, scannedHandler);

			var url:String=event.result
			defindMode(url)

			setCamera()

		}

		public function defindMode(_url):void
		{
			trace("Main.defindMode(_url)");

			if (tag_mode == "Web")
			{

				obj_web=new webClass(_url, this)
				obj_web.setRotate(nowYaw, nowRoll)
				array_FrameObj.push(obj_web)
				obj_web.name=String(array_FrameObj.length - 1)
				layerContent.addChild(obj_web)

			}
			else if (tag_mode == "Text")
			{

				obj_text=new textClass(_url)
				obj_text.setRotate(nowYaw, nowRoll)
				array_FrameObj.push(obj_text)
				obj_text.name=String(array_FrameObj.length - 1)
				layerContent.addChild(obj_text)

			}
			else if (tag_mode == "PhotoTake")
			{

				obj_photo.setRotate(nowYaw, nowRoll)
				array_FrameObj.push(obj_photo)
				obj_photo.name=String(array_FrameObj.length - 1)
				layerContent.addChild(obj_photo)
				//監聽來自photoClass的事件,圖片選擇是否取消	
				obj_photo.addEventListener("browserCancel", onCancel)
				obj_photo.addEventListener("photoSave", onSave)

			}
			else if (tag_mode == "PhotoSelect")
			{

				obj_photo.setRotate(nowYaw, nowRoll)
				array_FrameObj.push(obj_photo)
				obj_photo.name=String(array_FrameObj.length - 1)
				layerContent.addChild(obj_photo)
				//監聽來自photoClass的事件,圖片選擇是否取消
				obj_photo.addEventListener("browserCancel", onCancel)

			}


			//有第一個建立成功了，開始啓動移動模式
			tag_loaded=true

		}

		protected function onSave(event:Event):void
		{
			trace("來自photoClass的事件,圖片照完了")
			setCamera()


		}


		protected function onCancel(event:Event):void
		{
			trace("來自photoClass的事件,圖片選擇被取消")
			remove(array_FrameObj, removeCallback, obj_photo.name)
			obj_photo.removeSelf()
			setCamera()


		}

		protected function cancelHandler(event:QRZBarEvent):void
		{
			setCamera()
			trace("cancel")

		}

		protected function zoomHandler(event:TransformGestureEvent):void
		{
			//call the function and pass in the object to be rotated, the amount to scale X and Y (sx, sy), and the point object we created
//			scaleFromCenter(event.target, 2, 2, ptScalePoint);


			trace("-------------")
			trace("之前X= " + event.target.scaleX)
			trace("之前Y= " + event.target.scaleY)
			trace("縮放Ｘ= "+(event.scaleX+event.scaleY)/2)
			//
			event.target.scaleX*=(event.scaleX + event.scaleY) / 2
			event.target.scaleY*=(event.scaleX + event.scaleY) / 2
			//
			trace("之後X= " + event.target.scaleX)
			trace("之後Y= " + event.target.scaleY)


		}

		protected function chooseObjHandler(event:MouseEvent):void
		{


			if (event.target.name !== "butKill")
			{

				var target:String=event.target.parent.parent.name
			}
			else
			{
				trace("event.target= " + event.target)

			}

			if (target == "layerContent")
			{

				nowObjSelect=event.target.parent
				nowObjectIndex=int(nowObjSelect.name)
				nowObjSelect.addEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
//				stage.addEventListener(TransformGestureEvent.GESTURE_ZOOM,zoomHandler)
				ptScalePoint=new Point(nowObjSelect.x + nowObjSelect.width / 2, nowObjSelect.y + nowObjSelect.height / 2);


				var nowRotateObj:*=nowObjSelect.obj_rotate


				if (nowRotateObj.tag_run == true)
				{
					butKill.x=400
					butKill.y=-300
					nowObjSelect.addChild(butKill)
					//	
					nowRotateObj.tag_run=false
					nowRotateObj.radX=nowRotateObj.radY=0
					nowRotateObj.defaultYaw=0
					nowRotateObj.defaultRoll=0
					nowRotateObj.rotationX=nowRotateObj.rotationY=0
					nowRotateObj.x=nowRotateObj.y=nowRotateObj.z=0

				}
				else
				{
					nowObjSelect.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
					nowObjSelect.removeChild(butKill)
					nowRotateObj.defaultYaw=nowYaw
					nowRotateObj.defaultRoll=nowRoll
					nowRotateObj.tag_run=true
				}
			}


		}

		private function scaleFromCenter(ob:*, sx:Number, sy:Number, ptScalePoint:Point):void
		{
			var m:Matrix=ob.transform.matrix;
			m.tx-=ptScalePoint.x;
			m.ty-=ptScalePoint.y;
			m.scale(sx, sy);
			m.tx+=ptScalePoint.x;
			m.ty+=ptScalePoint.y;
			ob.transform.matrix=m;
		}

		protected function removeFrameObject(event:MouseEvent):void
		{
			remove(array_FrameObj, removeCallback, nowObjSelect.name)
			nowObjSelect.removeSelf()

		}

		protected function remove(list:Array, callback:Function, _name:String):Array
		{
			for (var i:int=list.length - 1; i >= 0; i--)
			{
				if (callback(list[i]) == _name)
				{
					list.splice(i, 1);
				}
			}
			return list;
		}

		protected function removeCallback(item:*):String
		{
			return item.name
		}




		//----------------------------------------------------------------------------------------------------
		//
		// set function
		//
		//----------------------------------------------------------------------------------------------------


		private function setAccl():void
		{
			obj_euler.textField.x=500
			layerText.addChild(obj_euler.textField)
			//
			text_diff.x=500
			text_diff.y=100
			text_diff.background=true
			text_diff.defaultTextFormat=new TextFormat(null, 30)
			text_diff.autoSize=TextFieldAutoSize.LEFT
			//	
			layerText.addChild(text_diff)

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
			//	cache
			butShowWeb.cacheAsBitmap=true
			butShowText.cacheAsBitmap=true
			butAddText.cacheAsBitmap=true
			butAddPhoto.cacheAsBitmap=true
			butSelectPhoto.cacheAsBitmap=true
			//addChild
			layerUI.addChild(butShowWeb)
			layerUI.addChild(butShowText)
			layerUI.addChild(butAddText)
			layerUI.addChild(butAddPhoto)
			layerUI.addChild(butSelectPhoto)
			//
			//choice button
			butKill.graphics.beginFill(0x0F00F0)
			butKill.graphics.drawCircle(0, 0, 150)
			text_but=new TextField()
			text_but.text="kill"
			text_but.textColor=0xFFFFFF
			butKill.addChild(text_but)
			butKill.cacheAsBitmap=true
			butKill.name="butKill"



		}


	}
}
