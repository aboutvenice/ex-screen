package
{
	import com.adobe.images.JPGEncoder;
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;
	
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	
	import net.hires.debug.Stats;



//	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="30")]
	[SWF(width="1024", height="768", backgroundColor="#FFFFFF", frameRate="30")]

//	[SWF(width="1632", height="816", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		public var stats:Stats=new Stats()
		private var qr:QRZBar=new QRZBar();
		private var layerContent:Sprite=new Sprite();
		public var layerText:Sprite=new Sprite()
		private var layerUI:Sprite=new Sprite()
		private var layerTag:Sprite=new Sprite()

		private var layerUISide:Sprite=new Sprite()
		private var layerCam:Sprite=new Sprite()
			
//		private var butShowWeb:Sprite=new Sprite()
		private var butTag:ButTag=new ButTag
		private var butAddPhoto:ButAddPhoto=new ButAddPhoto
		private var butSelectPhoto:ButSelectPhoto=new ButSelectPhoto
		private var butClearAll:ButClearAll=new ButClearAll
		private var butWorldMode:ButWorldMode=new ButWorldMode
		private var butHudMode:ButHudMode=new ButHudMode
		private var butSave:ButSave=new ButSave
		private var butLoadFrame:ButLoadFrame=new ButLoadFrame
		public var butKill:ButKill=new ButKill
		public var butDrog:ButDrog=new ButDrog
		public var butEye:ButEye=new ButEye
		public var butTag_small:ButTag_small=new ButTag_small
		public var bkTag:BkTag
		
		//
		private var butShowText:Sprite=new Sprite()
		private var butAddText:Sprite=new Sprite()
//		private var butLoadFrame:Sprite=new Sprite()


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
		public var preObjSelect:*
//		public var nowObjectIndex:int

		private var ptScalePoint:Point;
		//browserMode
		public var tag_hudMode:Boolean //=true
		private var tag_worldMode:Boolean //=false;
		private var tag_browserMode:String="hud";
		//
		private var tag_startMove:Boolean=true; //是第一次點嗎
		private var firstX:Number=0; //手剛點下去的第一個位置
		private var firstY:Number=0;
//		private var mouseRatoinX:Number=stage.stageWidth / 10 //手指移動的門檻值
//		private var mouseRatoinY:Number=stage.stageHeight / 10
		private var diffX:Number=0;
		private var diffY:Number=0;
		//frame tag
		private var nt:NativeText;
		private var array_tag:Array=new Array()
		//save	
		public var so:SharedObject=SharedObject.getLocal("myApp");
		public var readArray:ByteArray
		public var objLoaderInfo:LoaderInfo

		private var tag_drog:Boolean=false
			






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
			layerText.visible=false
			addChild(layerCam)
//			layerContent.cacheAsBitmap=true
//			layerContent.cacheAsBitmapMatrix=new Matrix()
			layerContent.name="layerContent"
			addChild(layerContent)
			addChild(layerText)
			addChild(layerUI)
			layerTag.visible=false
			layerUI.addChild(layerTag)
			layerUISide.visible=false
			addChild(layerUISide)
			stats.scaleX=stats.scaleY=2
			stats.x=-90
			stats.visible=false
			addChild(stats)
			//--------------------------------------------------
			// function runs here
			//--------------------------------------------------
			setAccl()
			setUI()
			setCamera()
			browserMode()
			//--------------------------------------------------
			// Listener
			//--------------------------------------------------			


			butAddPhoto.addEventListener(MouseEvent.CLICK, addPhotoHandler)
			butSelectPhoto.addEventListener(MouseEvent.CLICK, addSelectPhotoHandler)
			butClearAll.addEventListener(MouseEvent.CLICK, removeAllHandler)
			butHudMode.addEventListener(MouseEvent.CLICK, hudModeHandler)
			butWorldMode.addEventListener(MouseEvent.CLICK, worldModeHandler)
			//
			butSave.addEventListener(MouseEvent.CLICK,saveFrame)
			butLoadFrame.addEventListener(MouseEvent.CLICK, loadFrameHander)
			butTag.addEventListener(MouseEvent.CLICK,showTagHandler)	
			butShowText.addEventListener(MouseEvent.CLICK, setText)
			//			butShowWeb.addEventListener(MouseEvent.CLICK, addWebHandler)
			butAddText.addEventListener(MouseEvent.CLICK, addTextHandler)
			//
			stage.addEventListener(MouseEvent.CLICK, chooseObjHandler)
			butKill.addEventListener(MouseEvent.CLICK, removeFrameObject)
			butDrog.addEventListener(MouseEvent.CLICK, drogFrame)
			butEye.addEventListener(MouseEvent.CLICK, eyeHandler)


		}
		
		

		private function browserMode():void
		{
			if (tag_browserMode == "world")
			{
				stage.removeEventListener(Event.ENTER_FRAME, onRun)
				stage.addEventListener(MouseEvent.MOUSE_MOVE, worldMoveHandler)
				stage.addEventListener(MouseEvent.MOUSE_UP, resetFirstXHandler) //手放掉，下一次又是第一次點

				freezRollYaw()
				//
//				butHudMode.scaleX=butHudMode.scaleY=1
//				butWorldMode.scaleX=butWorldMode.scaleY=.5
				butHudMode.alpha=1
				butWorldMode.alpha=.5
				//
				tag_hudMode=false
				tag_worldMode=true

			}
			else if (tag_browserMode == "hud")
			{
				freezRollYaw()
				releaseRollYaw()
				//
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, worldMoveHandler)
				stage.addEventListener(Event.ENTER_FRAME, onRun)
				//	
//				butHudMode.scaleX=butHudMode.scaleY=.5
//				butWorldMode.scaleX=butWorldMode.scaleY=1
				butHudMode.alpha=.5
				butWorldMode.alpha=1
				tag_worldMode=false
				tag_hudMode=true

			}
			else if (tag_browserMode == "object")
			{

				stage.removeEventListener(MouseEvent.MOUSE_MOVE, worldMoveHandler)
				stage.removeEventListener(Event.ENTER_FRAME, onRun)
				//	
				freezRollYaw()
				//
//				butHudMode.scaleX=butHudMode.scaleY=1
//				butWorldMode.scaleX=butWorldMode.scaleY=1
				butHudMode.alpha=1
				butWorldMode.alpha=.5

			}

//			trace("tag_browserMode= " + tag_browserMode)
		}

		protected function worldModeHandler(event:MouseEvent):void
		{
			if (tag_worldMode)
			{
				tag_worldMode=false
				tag_browserMode="object"
			}
			else if ((!tag_worldMode) && (!tag_hudMode))
			{
				tag_worldMode=true
				tag_browserMode="world"

			}
			else if ((!tag_worldMode) && (tag_hudMode))
			{
				tag_worldMode=true
				tag_browserMode="world"
				tag_hudMode=false
			}

			browserMode()
		}


		protected function hudModeHandler(event:MouseEvent):void

		{
			if (tag_hudMode)
			{

				tag_hudMode=false //變成還沒按
				tag_browserMode="object"
			}
			else if ((!tag_hudMode) && (!tag_worldMode))
			{
				//如果還沒按
				tag_hudMode=true //變成按
				tag_browserMode="hud"

			}
			else if ((!tag_hudMode) && (tag_worldMode))
			{
				tag_hudMode=true //變成按
				tag_browserMode="hud"
//				butHudMode.scaleX=butHudMode.scaleY=.5
				//
				tag_worldMode=false

			}

			browserMode()

		}

		private function freezRollYaw():void
		{
			nowYaw=obj_euler.yaw
			nowRoll=obj_euler.roll

			for (var i:int=0; i < totalObj; i++)
			{
				nowObj=array_FrameObj[i]
				nowObj.obj_rotate.saveRX=nowObj.obj_rotate._x //將現在的位移量(位置)存起來(上次傳入的diffYaw)
				nowObj.obj_rotate.saveRY=nowObj.obj_rotate._y

//				trace("Main.freezRollYaw()");
//				trace("nowObj.obj_rotate.defaultYaw= " + nowObj.obj_rotate.defaultYaw.toFixed(3))
//				trace("nowObj.obj_rotate.defaultRoll= " + nowObj.obj_rotate.defaultRoll.toFixed(3))

			}

		}

		public function releaseRollYaw():void
		{


			nowYaw=obj_euler.yaw
			nowRoll=obj_euler.roll

			for (var i:int=0; i < totalObj; i++)
			{
				nowObj=array_FrameObj[i]
				nowObj.obj_rotate.defaultYaw=nowYaw - nowObj.obj_rotate.saveRX //把現在euler的位置減上次的位置，等於新的起始位置
				nowObj.obj_rotate.defaultRoll=nowRoll - nowObj.obj_rotate.saveRY


			}


		}


		protected function worldMoveHandler(event:MouseEvent):void
		{
//			if (event.target == stage)
//			{
//			trace("-------worldMoveHandler---------")


			var _x:Number=event.target.mouseX
			var _y:Number=event.target.mouseY

			if (tag_startMove)
			{
				//如果是第一次點
				tag_startMove=false
				firstX=_x
				firstY=_y
			}
			//
			var distanceX:Number=_x - firstX
			var distanceY:Number=_y - firstY
			//
			diffX=distanceX / 200 * -1 //*-1 讓world模式的移動方向正確
			diffY=distanceY / 200
//			trace("diffX= " + diffX)
//			trace("diffY= " + diffY)
			//
			worldRun()


//			}

		}

		private function worldRun():void
		{
			totalObj=array_FrameObj.length

			for (var i:int=0; i < totalObj; i++)
			{
				nowObj=array_FrameObj[i]
				nowObj.obj_rotate.defaultYaw+=diffX // effected by diffX
				nowObj.obj_rotate.defaultRoll+=diffY // effected by diffX

//				trace("第 " + i + " 個物件 ----------")
//				trace("defaultYaw= " + nowObj.obj_rotate.defaultYaw.toFixed(3))
//				trace("defaultRoll= " + nowObj.obj_rotate.defaultRoll.toFixed(3))
//				//		
				diffYaw=nowYaw - nowObj.obj_rotate.defaultYaw
				diffRoll=nowRoll - nowObj.obj_rotate.defaultRoll
				//	
//				trace("diffYaw= " + diffYaw.toFixed(3))
//				trace("diffRoll= " + diffRoll.toFixed(3))
				//	
				nowObj.obj_rotate.start(diffYaw, diffRoll)

			}

		}

		protected function resetFirstXHandler(event:MouseEvent):void
		{
			tag_startMove=true //手放掉，下一次又是第一次點
			firstX=0
			firstY=0
			diffX=0
			diffY=0
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
						nowObj.onRun()

					}

				}

//				trace("array_FrameObj= "+array_FrameObj)
//				text_diff.Text("Obj number= " + array_FrameObj.length+"\n")

			}

			text_diff.text="diffYaw= " + diffYaw.toFixed(3) + "\n" + "diffRoll= " + diffRoll.toFixed(3) + "\n" + "Obj number= " + totalObj + "\n"


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
			cam.setMode(camW, camH, 5);
			cam.setQuality(0, 100)

			// Create a video <--------scene we see
			vid=new Video(camW, camH);
			vid.attachCamera(cam);
			layerCam.addChild(vid)


		/*while (layerCam.numChildren)
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
//			layerCam.addChild(vid)
		trace("layerCam.numChildren= " + layerCam.numChildren)*/
			//
		}

		protected function setText(event:MouseEvent):void
		{
			if (!tag_Text)
			{
				tag_Text=true
				layerText.visible=true
				stats.visible=true
			}
			else
			{
				tag_Text=false
				layerText.visible=false
				stats.visible=false

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

			/*tag_mode="Text"
			//
			setQRReader(null)*/

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

		protected function removeAllHandler(event:MouseEvent):void
		{
			//把drog button恢復
			butDrog.scaleX=1
			layerUISide.visible=false
			//
			while (layerContent.numChildren > 0)
			{
				layerContent.removeChildAt(0)
			}

			//clean all array
			array_FrameObj.splice(0)

		}

		private function setQRReader(e:MouseEvent):void
		{
//			qr=new QRZBar()
			//
//			obj_web=new webClass("https://www.facebook.com/", this)
//			obj_web.setRotate(nowYaw, nowRoll)
//			array_FrameObj.push(obj_web)
//			obj_web.name=String(array_FrameObj.length - 1)
//			layerContent.addChild(obj_web)
//			tag_loaded=true

//			showTagedFrame()

//			qr.scan();
//			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);


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

//				var obj_web2=new web2Class("https://www.facebook.com/",stage)
//				layerContent.addChild(obj_web2)

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
//				obj_photo.alpha=.6
				layerContent.addChild(obj_photo)
				//監聽來自photoClass的事件,圖片選擇是否取消
				obj_photo.addEventListener("browserCancel", onCancel)
				obj_photo.addEventListener("tagLoaded", onTagLoaded)  //tag建立好了
				//	

				if (tag_worldMode)
				{
					//如果是世界模式的話，照片一出來也要進行角度調整。 hud模式的話自己會執行onRun()來調整
					//					
					diffYaw=nowYaw - obj_photo.obj_rotate.defaultYaw
					diffRoll=nowRoll - obj_photo.obj_rotate.defaultRoll
					//	
					obj_photo.obj_rotate.start(diffYaw, diffRoll)
				}


			}


			//有第一個建立成功了，開始啓動移動模式
			tag_loaded=true

		}

		protected function onTagLoaded(event:Event):void
		{
//			addTag(obj_photo.tags.text)
			addTag()

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
			trace("縮放Ｘ= " + (event.scaleX + event.scaleY) / 2)
			//
			event.target.scaleX*=(event.scaleX + event.scaleY) / 2
			event.target.scaleY*=(event.scaleX + event.scaleY) / 2
			//
			trace("之後X= " + event.target.scaleX)
			trace("之後Y= " + event.target.scaleY)


		}

		public function chooseObjHandler(event:MouseEvent):void
		{

//			trace("event.target= " + event.target)


			if ((event.target.name !== "butKill") && (event.target != stage))
			{

				var target:String=event.target.parent.parent.name
			}
			else
			{
//				trace("event.target= " + event.target)

			}

			if (target == "layerContent")
			{

				nowObjSelect=event.target.parent //photoClass
//				nowObjectIndex=int(nowObjSelect.name)
				nowObjSelect.addEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
//				ptScalePoint=new Point(nowObjSelect.x + nowObjSelect.width / 2, nowObjSelect.y + nowObjSelect.height / 2);

				var nowLayer:*=event.target.parent.parent

				if ((layerUISide.visible) && (preObjSelect == nowObjSelect))
				{
					//選了一個，又按同一個frame,原本看的到的UI就關掉
					layerUISide.visible=false
					//
					if(!nowObjSelect.obj_rotate.tag_run)
					{  
						//如果剛剛有按過drop，導致tag_run＝false
						//將frame的位置恢復
						butDrog.alpha=1	
						nowObjSelect.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)

						nowObjSelect.obj_rotate.defaultYaw=nowYaw  //photo.rotateClass
						nowObjSelect.obj_rotate.defaultRoll=nowRoll 
						nowObjSelect.obj_rotate.tag_run=true
					}
//					addTag(nowObjSelect.tags.text)
					//reset tag position
					resetTag(nowObjSelect)
				
					//選到的frame變透明
					setFrameAlpha(nowLayer, null)


				}
				else if (((layerUISide.visible) && (preObjSelect !== nowObjSelect)) && (preObjSelect))
				{
					//先選了一個，又再按了另一個
					layerUISide.visible=true
					
					if (!preObjSelect.obj_rotate.tag_run) 
					{
						//如果剛剛有按過drop，導致tag_run＝false
						//將frame的位置恢復
						//將上個選擇的frame的tag放回frame旁
						butDrog.alpha=1	
						preObjSelect.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
						preObjSelect.obj_rotate.defaultYaw=nowYaw  //photo.rotateClass
						preObjSelect.obj_rotate.defaultRoll=nowRoll 
						preObjSelect.obj_rotate.tag_run=true
					}
					//	
					resetTag(preObjSelect)
					//
					nowObjSelect.tags.x=butTag_small.x
					nowObjSelect.tags.y=butTag_small.y
					nowObjSelect.tags.color=0xFFFFFF
					nowObjSelect.tags.fontSize=20 //讓layerUI的tag文字小一點
					//
					nowObjSelect.tags.unfreeze();
					//選到的frame變透明
					setFrameAlpha(nowLayer, nowObjSelect)


				}
				else
				{
					//第一次選
					layerUISide.visible=true
					//
					//
					nowObjSelect.tags.x=butTag_small.x
					nowObjSelect.tags.y=butTag_small.y
					nowObjSelect.tags.color=0xFFFFFF
					nowObjSelect.tags.fontSize=20 //讓layerUI的tag文字小一點
					//解開freeze，才能進行輸入
					nowObjSelect.tags.unfreeze();
					//
					//選到的frame變透明
					setFrameAlpha(nowLayer, nowObjSelect)
				}

				preObjSelect=nowObjSelect
				addTag() //編輯完tag後，點任何一個fram，都要重新產生tag

			}


		}
		
		protected function drogFrame(event:MouseEvent):void
		{
			trace("Main.drogFrame(event)");
			
			var nowRotateObj:*=nowObjSelect.obj_rotate //photo.rotateClass
			
			if (nowRotateObj.tag_run == true)
			{
				trace("drog 1")
				//第一次按drog
				butDrog.alpha=.5 //選到變透明
				//
				nowObjSelect.rotationX=nowObjSelect.rotationY=0 //frmae的翻轉角度回復水平
				nowObjSelect.x=nowObjSelect.y=0 //frame回復位置
				
				nowRotateObj.tag_run=false
				tag_drog=true
				
				
			}
			else if ((nowRotateObj.tag_run == false) && (preObjSelect == nowObjSelect))
			{
				trace("drog 2")
				//如果這個frame已經按過drog而且跟上一個選的物件是同一個的話=同一個物件內按drog兩次
				nowObjSelect.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
				//
				butDrog.alpha=1
				//
				nowRotateObj.defaultYaw=nowYaw
				nowRotateObj.defaultRoll=nowRoll
				nowRotateObj.tag_run=true
				layerUISide.visible=false //關掉UI
				//reset tag position	
				resetTag(preObjSelect)
				
				//
				//選到的frame變透明
				setFrameAlpha(layerContent, null)
				tag_drog=false
			}
			
		}
		
		private function resetTag(_nowObjSelect:*):void
		{
			//reset tag position
			_nowObjSelect.tags.x=0 //tag出現的位置
			_nowObjSelect.tags.y=0 //- (nowObjSelect.tags.height)
			_nowObjSelect.tags.color=0x000000
			_nowObjSelect.tags.fontSize=40 //讓layerUI的tag文字恢復原來大小
			_nowObjSelect.tags.freeze();
			
		}
		
		private function setFrameAlpha(_nowLayer:*, _nowObjSelect:*):void
		{
			for (var i:int=0; i < _nowLayer.numChildren; i++)
			{
				//把全部的frame都恢復透明度
				var nowObj:*=_nowLayer.getChildAt(i)
				nowObj.alpha=1
			}

			if (_nowObjSelect != null)
			{
				//選到的frame變透明
				_nowObjSelect.alpha=.8
			}


		}

//		private function addTag(_tag:String):void
		private function addTag():void
		{
			//提取obj_photo中的tag，加到array_tag陣列中			

			//先將array清空
			array_tag.splice(0)


//			trace("array_tag.length = " + array_tag.length)

			var total:int=array_FrameObj.length	
			trace("現在有 "+total+"個物件")
			for (var i:int=0; i < total; i++)
			{
				var nowTagObj:*=array_FrameObj[i]

				var nowTag:String=nowTagObj.tags.text
				var nowResult:int=array_tag.indexOf(nowTag)
				var length:int=array_tag.length
					
				if (length > 0)
				{
					if (nowResult == -1)
					{
						//如果都沒有與之前相等的tag
						array_tag.push(nowTag)
//						trace("push Array")
					}
					else
					{
						//之前已經有一樣的tag了
//						trace("no push")

					}
				}
				else
				{
					//如果是第一次
					array_tag.push(nowTag)
//					trace("first push Array")
				}

			}

			setTagButton()

		}


		protected function showTagHandler(event:MouseEvent):void
		{
			if (layerTag.visible==false) 
			{
				layerTag.visible=true
			}
			else 
			{
				layerTag.visible=false
			}
			
		}
		
		private function setTagButton():void
		{
			//新增tag的button實體


			while (layerTag.numChildren > 0)
			{
				layerTag.getChildAt(0).removeEventListener(MouseEvent.CLICK, callTagFrame)
				layerTag.removeChildAt(0);
			}
			
			var length:int=array_tag.length
			//build tag button
			for (var i:int=0; i < length; i++)
			{
				trace("總共有 "+length+"個tag")
				bkTag=new BkTag
				bkTag.x=0+i*200//stage.stageWidth-bkTag.width-(i*length)
				bkTag.y=0//700
				bkTag.addEventListener(MouseEvent.CLICK, callTagFrame) // addEventListener to tag button
				bkTag.name=String(array_tag[i])
				//
				text_but=new TextField()
				text_but.mouseEnabled=false //disable click
				text_but.tabEnabled=false; //disable click	
				text_but.text=bkTag.name
				text_but.textColor=0xFFFFFF
				bkTag.addChild(text_but)
				//	
				layerTag.addChild(bkTag)

			}


		}
		


		public function callTagFrame(e:MouseEvent):void
		{

			//呼叫指定選擇的tag的frame，並排序
			var nowTag:String=e.target.name
			var dis:int=0;

//			trace("nowTag= " + nowTag)
			var total:int=array_FrameObj.length

			for (var i:int=0; i < total; i++)
			{
				var nowObj:*=array_FrameObj[i]

				if (nowObj.tags.text !== nowTag)
				{
//					trace("hide")
					nowObj.visible=false
				}
				else
				{

//					trace("show tagged frames")
//					trace("nowObj.tags.text= " + nowObj.tags.text)
					nowObj.visible=true
					var leftLim:int=10 //排序後frame往左的極限
					var space:int=30; //frame之間的間距
					//
					nowObj.obj_rotate.defaultYaw=(nowYaw + leftLim) - dis * space //sort the distance between frames
					nowObj.obj_rotate.defaultRoll=nowRoll


					if (tag_worldMode)
					{
						//如果是世界模式的話，因為沒有onRun一直在跑，所以要自己呼叫函式來改變defaultYaw與defaultRoll
						diffX=0.0001 //一定要給一些值，不然位置一開始會跑掉，摸一摸才會變好
						diffY=0.0001
						worldRun()
						worldRun() //一定要呼叫兩次，不然最後一個frame的位置會跑掉，摸一摸才會變好
					}

					//	
					dis++

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


		



		protected function eyeHandler(event:MouseEvent):void
		{
			
			//開啟/關閉圖層
			if (nowObjSelect.visible) 
			{
				nowObjSelect.visible=false

			}
			else 
			{
				nowObjSelect.visible=true
			}

		}


		protected function removeFrameObject(event:MouseEvent):void
		{
			butDrog.alpha=1
			layerUISide.visible=false
			//	
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


		private function saveFrame(e:MouseEvent):void
		{
			tag_loaded=false

			for (var i:int=0; i < totalObj; i++)
			{
				nowObj=array_FrameObj[i]
				//
				var jpg_Encoder:JPGEncoder;
				jpg_Encoder=new JPGEncoder(100);
				//
				var bmpData:BitmapData=new BitmapData(nowObj.loader.content.width, nowObj.loader.content.height)
				bmpData.draw(nowObj.loader.content)
				//
				readArray=new ByteArray()
				readArray=jpg_Encoder.encode(bmpData)
				//
				so.data['byteArray']=readArray
				so.flush()

			}
			tag_loaded=true
		}

		protected function loadFrameHander(event:MouseEvent):void
		{
			trace("Main.loadFrameHander(event)");

			var loadArray:ByteArray=new ByteArray()
			loadArray=so.data['byteArray']
			loadArray.position=0
//			trace("loadArray= "+loadArray)
			//
			obj_photo=new photoClass(stage)
			obj_photo.setLoader(loadArray)
			obj_photo.setRotate(nowYaw, nowRoll)
			array_FrameObj.push(obj_photo)
			obj_photo.name=String(array_FrameObj.length - 1)
			layerContent.addChild(obj_photo)

		}



		//----------------------------------------------------------------------------------------------------
		//
		// set function
		//
		//----------------------------------------------------------------------------------------------------


		private function setAccl():void
		{
			obj_euler.textField.x=700 //textField of yaw and roll
			layerText.addChild(obj_euler.textField)
			//
			text_diff.x=obj_euler.textField.x //follow upper x
			text_diff.y=100
			text_diff.background=true
			text_diff.defaultTextFormat=new TextFormat(null, 30)
			text_diff.autoSize=TextFieldAutoSize.LEFT
			//	
			layerText.addChild(text_diff)

		}



		private function setUI():void
		{
			butAddPhoto.x=0
			butAddPhoto.y=stage.stageHeight-butAddPhoto.height
			butSelectPhoto.x=butAddPhoto.x+butAddPhoto.width
			butSelectPhoto.y=butAddPhoto.y
			butClearAll.x=butSelectPhoto.x+butSelectPhoto.width
			butClearAll.y=butAddPhoto.y
			butWorldMode.x=butClearAll.x+butClearAll.width
			butWorldMode.y=butAddPhoto.y
			butHudMode.x=butWorldMode.x+butWorldMode.width
			butHudMode.y=butAddPhoto.y
			butShowText.x=butHudMode.x+butHudMode.width
			butShowText.y=butAddPhoto.y
			butSave.x=butShowText.x+butShowText.width
			butSave.y=butAddPhoto.y	
			butLoadFrame.x=	butSave.x+butSave.width
			butLoadFrame.y=butAddPhoto.y
			butTag.x=butLoadFrame.x+butLoadFrame.width	
			butTag.y=butAddPhoto.y
			//
			butShowText.x=stage.stageWidth

			
			//
			layerUI.addChild(butAddPhoto)
			layerUI.addChild(butSelectPhoto)
			layerUI.addChild(butClearAll)
			layerUI.addChild(butWorldMode)
			layerUI.addChild(butHudMode)
			layerUI.addChild(butShowText)
			layerUI.addChild(butSave)
			layerUI.addChild(butLoadFrame)
			layerUI.addChild(butTag)
				
			//	
			layerUI.addChild(butShowText)
			//	
			//Side UI
			butKill.name="butKill"
			butKill.x=stage.stageWidth-butKill.width
			butKill.y=stage.stageHeight/2-300
			butDrog.x=butKill.x
			butDrog.y=butKill.y+butKill.height
			butEye.x=butKill.x
			butEye.y=butDrog.y+butDrog.height	
			butTag_small.x=butKill.x
			butTag_small.y=butEye.y+butEye.height
			//	
			layerUISide.addChild(butKill)
			layerUISide.addChild(butDrog)
			layerUISide.addChild(butEye)
			layerUISide.addChild(butTag_small)
				



		}


	}
}
