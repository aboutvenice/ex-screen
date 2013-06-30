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
	import flash.text.ReturnKeyLabel;
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
		private var layerTag:Sprite=new Sprite()
			
		private var layerUISide:Sprite=new Sprite()
		private var layerCam:Sprite=new Sprite()
		private var butShowWeb:Sprite=new Sprite()
		private var butShowText:Sprite=new Sprite()
		private var butAddText:Sprite=new Sprite()
		private var butAddPhoto:Sprite=new Sprite()
		private var butSelectPhoto:Sprite=new Sprite()
		private var butClearAll:Sprite=new Sprite()
		private var butWorldMode:Sprite=new Sprite()
		private var butHudMode:Sprite=new Sprite()
//		private var butPin:Sprite=new Sprite()
		private var butKill:Sprite=new Sprite()
		private var butDrog:Sprite=new Sprite()
		private var butAlphaUp:Sprite=new Sprite()
		private var butAlphaDown:Sprite=new Sprite()
		private var bk_tag:Sprite=new Sprite()



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
		private var mouseRatoinX:Number=stage.stageWidth / 10 //手指移動的門檻值
		private var mouseRatoinY:Number=stage.stageHeight / 10
		private var diffX:Number=0;
		private var diffY:Number=0;
		private var nt:NativeText;
		private var array_tag:Array=new Array()






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

			butShowText.addEventListener(MouseEvent.CLICK, setText)
			butShowWeb.addEventListener(MouseEvent.CLICK, addWebHandler)
			butAddText.addEventListener(MouseEvent.CLICK, addTextHandler)
			butAddPhoto.addEventListener(MouseEvent.CLICK, addPhotoHandler)
			butSelectPhoto.addEventListener(MouseEvent.CLICK, addSelectPhotoHandler)
			butClearAll.addEventListener(MouseEvent.CLICK, clearAllHandler)
			butHudMode.addEventListener(MouseEvent.CLICK, hudModeHandler)
			butWorldMode.addEventListener(MouseEvent.CLICK, worldModeHandler)
			stage.addEventListener(MouseEvent.CLICK, chooseObjHandler)
			butKill.addEventListener(MouseEvent.CLICK, removeFrameObject)
			butDrog.addEventListener(MouseEvent.CLICK, drogFrame)
			butAlphaUp.addEventListener(MouseEvent.CLICK, alphaUp)
			butAlphaDown.addEventListener(MouseEvent.CLICK, alphaDown)


		}

		private function browserMode():void
		{
			if (tag_browserMode == "world")
			{
				stage.removeEventListener(Event.ENTER_FRAME, onRun)
				stage.addEventListener(MouseEvent.MOUSE_MOVE, worldMoveHandler)
				stage.addEventListener(MouseEvent.MOUSE_UP, resetFirstXHandler)

				freezRollYaw()
				//
				butHudMode.scaleX=butHudMode.scaleY=1
				butWorldMode.scaleX=butWorldMode.scaleY=.5
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
				butHudMode.scaleX=butHudMode.scaleY=.5
				butWorldMode.scaleX=butWorldMode.scaleY=1
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
				butHudMode.scaleX=butHudMode.scaleY=1
				butWorldMode.scaleX=butWorldMode.scaleY=1

			}

			trace("tag_browserMode= " + tag_browserMode)
		}

		protected function worldModeHandler(event:MouseEvent):void
		{
			if (tag_worldMode)
			{
				tag_worldMode=false
				tag_browserMode="object"
					//				butWorldMode.scaleX=butWorldMode.scaleY=1
			}
			else if ((!tag_worldMode) && (!tag_hudMode))
			{
				tag_worldMode=true
				tag_browserMode="world"
					//				butWorldMode.scaleX=butWorldMode.scaleY=.5

			}
			else if ((!tag_worldMode) && (tag_hudMode))
			{
				tag_worldMode=true
				tag_browserMode="world"
				//				butWorldMode.scaleX=butWorldMode.scaleY=.5
				//	
				//				butHudMode.scaleX=butHudMode.scaleY=1 //另一邊變大
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
//				butHudMode.scaleX=butHudMode.scaleY=1
			}
			else if ((!tag_hudMode) && (!tag_worldMode))
			{
				//如果還沒按
				tag_hudMode=true //變成按
				tag_browserMode="hud"
//				butHudMode.scaleX=butHudMode.scaleY=.5

			}
			else if ((!tag_hudMode) && (tag_worldMode))
			{
				tag_hudMode=true //變成按
				tag_browserMode="hud"
				butHudMode.scaleX=butHudMode.scaleY=.5
				//
//				butWorldMode.scaleX=butWorldMode.scaleY=1
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

				trace("Main.freezRollYaw()");
				trace("nowObj.obj_rotate.defaultYaw= " + nowObj.obj_rotate.defaultYaw.toFixed(3))
				trace("nowObj.obj_rotate.defaultRoll= " + nowObj.obj_rotate.defaultRoll.toFixed(3))

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
			trace("----------------")


			var _x:Number=event.target.mouseX
			var _y:Number=event.target.mouseY

			if (tag_startMove)
			{
				//如果是第一次點
				tag_startMove=false
				firstX=_x
				firstY=_y
			}
//				trace("firstX= " + firstX)
//				trace("_x= " + _x)
//				trace("firstY= " + firstY)
//				trace("_y= " + _y)

			var distanceX:Number=_x - firstX
			var distanceY:Number=_y - firstY

//				trace("distanceX= " + distanceX)
//				trace("mouseRatoinX= " + mouseRatoinX)
//				trace("distanceY= " + distanceY)
//				trace("mouseRatoinY= " + mouseRatoinY)

			diffX=distanceX / 200 * -1 //*-1 讓world模式的移動方向正確
			diffY=distanceY / 200
			trace("diffX= " + diffX)
			trace("diffY= " + diffY)
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

				trace("第 " + i + " 個物件 ----------")
				trace("defaultYaw= " + nowObj.obj_rotate.defaultYaw.toFixed(3))
				trace("defaultRoll= " + nowObj.obj_rotate.defaultRoll.toFixed(3))
//				//		
//				trace("saveRX= "+nowObj.obj_rotate.saveRX.toFixed(3))
//				trace("saveRY= "+nowObj.obj_rotate.saveRY.toFixed(3))
				//
//				diffYaw=nowObj.obj_rotate.saveRX - nowObj.obj_rotate.defaultYaw
//				diffRoll=nowObj.obj_rotate.saveRY - nowObj.obj_rotate.defaultRoll
				diffYaw=nowYaw - nowObj.obj_rotate.defaultYaw
				diffRoll=nowRoll - nowObj.obj_rotate.defaultRoll
				//	
				trace("diffYaw= " + diffYaw.toFixed(3))
				trace("diffRoll= " + diffRoll.toFixed(3))
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

					text_diff.text="diffYaw= " + diffYaw.toFixed(3) + "\n" + "diffRoll= " + diffRoll.toFixed(3) + "\n" + "Obj number= " + array_FrameObj.length + "\n"



				}

//				trace("array_FrameObj= "+array_FrameObj)
//				text_diff.Text("Obj number= " + array_FrameObj.length+"\n")

			}



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

		protected function clearAllHandler(event:MouseEvent):void
		{
			while (layerContent.numChildren > 0)
			{
				layerContent.removeChildAt(0)
				array_FrameObj.pop()

			}

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
				obj_photo.addEventListener("tagLoaded", onTagLoaded)
				


			}


			//有第一個建立成功了，開始啓動移動模式
			tag_loaded=true

		}
		
		protected function onTagLoaded(event:Event):void
		{
			addTag(obj_photo.tags.text)
			
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

			/*if(event.target=="[object NativeText]")
			{
				trace("I got tag")

//				var target:String=event.target.parent.parent.name
//				trace("target= "+target)

				nowObjSelect=event.target.parent
				nowObjSelect.nt.text="got"
				nowObjSelect.nt.unfreeze();

				trace("nowObjSelect= "+nowObjSelect)


			}*/


			if ((event.target.name !== "butKill") && (event.target != stage))
			{

				var target:String=event.target.parent.parent.name
			}
			{
//				trace("event.target= " + event.target)

			}

			if (target == "layerContent")
			{

				nowObjSelect=event.target.parent //photoClass

//				nowObjectIndex=int(nowObjSelect.name)
				nowObjSelect.addEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
//				ptScalePoint=new Point(nowObjSelect.x + nowObjSelect.width / 2, nowObjSelect.y + nowObjSelect.height / 2);



				//如果按的是同一個frame,原本看的到的UI就關掉
				if ((layerUISide.visible) && (preObjSelect == nowObjSelect))
				{
					layerUISide.visible=false
					//
					nowObjSelect.tags.x=0
					nowObjSelect.tags.y=0 - (nowObjSelect.tags.height)
//					nowObjSelect.nt.borderThickness=3
//					nowObjSelect.nt.borderCornerSize=3
//					nowObjSelect.nt.borderColor=0x0FFF00
					trace("nowObjSelect.tags.text= " + nowObjSelect.tags.text)
					addTag(nowObjSelect.tags.text)
					nowObjSelect.tags.freeze();

				}
				else
				{
					layerUISide.visible=true
					//	

					nowObjSelect.tags.x=bk_tag.x
					nowObjSelect.tags.y=bk_tag.y
//					nowObjSelect.nt.borderThickness=0
//					nowObjSelect.nt.borderCornerSize=0
//					nowObjSelect.nt.borderColor=0x000000
					nowObjSelect.tags.unfreeze();

				}

				preObjSelect=nowObjSelect


			}


		}

		private function addTag(_tag:String):void
		{

				
			while(array_tag.length>0)
			{
				//先將array清空
				array_tag.splice(0)
			
			}
			
			for (var i:int=0; i < array_FrameObj.length; i++)
			{
				var nowTagObj:*=array_FrameObj[i]
					
				var nowTag:String=nowTagObj.tags.text
				var nowResult:int=array_tag.indexOf(nowTag)
					
				if (array_tag.length > 0)
				{
					if (nowResult == -1)
					{
						//如果都沒有與之前相等的tag
						array_tag.push(nowTag)
						trace("push Array")
					}
					else
					{
						//之前已經有一樣的tag了
						trace("no push")
						
					}
				}else
				{
					//如果是第一次
					array_tag.push(nowTag)
					trace("first push Array")
				}
				
			}
			
			showTagedFrame()

		}
		
		
		private function showTagedFrame():void
		{
			trace("----------------")

			layerTag.visible=true
			
			while (layerTag.numChildren > 0) {
				layerTag.getChildAt(0).removeEventListener(MouseEvent.CLICK,callTagFrame)
				layerTag.removeChildAt(0);
			}
			
			
			for (var i:int=0; i < array_tag.length; i++)
			{
				
				var but_tag:Sprite=new Sprite()
				but_tag.graphics.beginFill(0x0000FF)
				but_tag.graphics.drawCircle(0,0,50)
				but_tag.x=(100*i)+50
				but_tag.y=stage.stageHeight-200
				but_tag.addEventListener(MouseEvent.CLICK,callTagFrame)
				but_tag.name=String(array_tag[i])
				//	
				text_but=new TextField()
				text_but.text=but_tag.name
				text_but.textColor=0xFFFF00
				//	
				but_tag.addChild(text_but)
				layerTag.addChild(but_tag)
					
			}	
			
			
		}
		
		public function callTagFrame(e:MouseEvent):void
		{
			var nowTag:String=e.target.name
			
			trace("nowTag= "+nowTag)	
			for (var i:int = 0; i < array_FrameObj.length; i++) 
			{
				var nowObj:*=array_FrameObj[i]
				trace("nowObj.tags.text= "+nowObj.tags.text)	
					
				if (nowObj.tags.text!==nowTag) 
				{
					trace("hide")
					nowObj.visible=false
				}
				else 
				{
					trace("show")
					nowObj.visible=true
						
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

		protected function drogFrame(event:MouseEvent):void
		{

			var nowRotateObj:*=nowObjSelect.obj_rotate //photo.rotateClass

			if (nowRotateObj.tag_run == true)
			{
				butDrog.scaleX=butDrog.scaleY=.8

				nowObjSelect.rotationX=nowObjSelect.rotationY=0 //frmae的翻轉角度回復水平
				nowObjSelect.x=nowObjSelect.y=0 //frame回復位置
				nowRotateObj.tag_run=false


			}
			else
			{
				nowObjSelect.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomHandler)
				//
				butDrog.scaleX=butDrog.scaleY=1
				//
				nowRotateObj.defaultYaw=nowYaw
				nowRotateObj.defaultRoll=nowRoll
				nowRotateObj.tag_run=true
				layerUISide.visible=false //關掉UI

			}


		}



		protected function alphaDown(event:MouseEvent):void
		{
			nowObjSelect.alpha-=.1
			trace("nowObjSelect.alpha= " + nowObjSelect.alpha)


		}

		protected function alphaUp(event:MouseEvent):void
		{
			nowObjSelect.alpha+=.1
			trace("nowObjSelect.alpha= " + nowObjSelect.alpha)

		}

		protected function removeFrameObject(event:MouseEvent):void
		{
			layerUISide.visible=false
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
			var posX:int=50
			var posY:int=550
			var dis:int=100

			butShowWeb.graphics.beginFill(0xFF0000)
			butShowWeb.graphics.drawCircle(0, 0, 50)
			butShowWeb.x=posX
			butShowWeb.y=posY
			text_but=new TextField()
			text_but.textColor=0xFFFFFF
			text_but.text="web"
			butShowWeb.addChild(text_but)
			//	
			butAddText.graphics.beginFill(0x0000FF)
			butAddText.graphics.drawCircle(0, 0, 50)
			butAddText.x=butShowWeb.x + dis
			butAddText.y=posY
			text_but=new TextField()
			text_but.text="text"
			text_but.textColor=0xFFFFFF
			butAddText.addChild(text_but)
			//	
			butAddPhoto.graphics.beginFill(0x0000F0)
			butAddPhoto.graphics.drawCircle(0, 0, 50)
			butAddPhoto.x=butAddText.x + dis
			butAddPhoto.y=posY
			text_but=new TextField()
			text_but.text="photo"
			text_but.textColor=0xFFFFFF
			butAddPhoto.addChild(text_but)
			//	
			butSelectPhoto.graphics.beginFill(0x0F00F0)
			butSelectPhoto.graphics.drawCircle(0, 0, 50)
			butSelectPhoto.x=butAddPhoto.x + dis
			butSelectPhoto.y=posY
			text_but=new TextField()
			text_but.text="select"
			text_but.textColor=0xFFFFFF
			butSelectPhoto.addChild(text_but)
			//
			butShowText.graphics.beginFill(0x00FF00)
			butShowText.graphics.drawCircle(0, 0, 50)
			butShowText.x=butSelectPhoto.x + dis
			butShowText.y=posY
			text_but=new TextField()
			text_but.text="show text"
			text_but.textColor=0xFFFFFF
			butShowText.addChild(text_but)
			//
			butClearAll.graphics.beginFill(0xF0FF00)
			butClearAll.graphics.drawCircle(0, 0, 50)
			butClearAll.x=butShowText.x + dis
			butClearAll.y=posY
			text_but=new TextField()
			text_but.text="clear all"
			text_but.textColor=0xFFFFFF
			butClearAll.addChild(text_but)
			//
			butWorldMode.graphics.beginFill(0xF0FF0F)
			butWorldMode.graphics.drawCircle(0, 0, 50)
			butWorldMode.x=butClearAll.x + dis
			butWorldMode.y=posY
			text_but=new TextField()
			text_but.text="worldMode"
			text_but.textColor=0xFFFFFF
			butWorldMode.addChild(text_but)
			//
			butHudMode.graphics.beginFill(0xF0FF0F)
			butHudMode.graphics.drawCircle(0, 0, 50)
			butHudMode.x=butWorldMode.x + dis
			butHudMode.y=posY
			butHudMode.scaleX=butHudMode.scaleY=.5
			text_but=new TextField()
			text_but.text="hudMode"
			text_but.textColor=0xFFFFFF
			butHudMode.addChild(text_but)
			//	cache
			butShowWeb.cacheAsBitmap=true
			butAddText.cacheAsBitmap=true
			butAddPhoto.cacheAsBitmap=true
			butSelectPhoto.cacheAsBitmap=true
			butShowText.cacheAsBitmap=true
			butClearAll.cacheAsBitmap=true
			//addChild
			layerUI.addChild(butShowWeb)
			layerUI.addChild(butAddText)
			layerUI.addChild(butAddPhoto)
			layerUI.addChild(butSelectPhoto)
			layerUI.addChild(butShowText)
			layerUI.addChild(butClearAll)
			layerUI.addChild(butWorldMode)
			layerUI.addChild(butHudMode)
			//
			//choice button
			butKill.graphics.beginFill(0x0F00F0)
			butKill.graphics.drawCircle(0, 0, 50)
			text_but=new TextField()
			text_but.text="kill"
			text_but.textColor=0xFFFFFF
			butKill.addChild(text_but)
			butKill.cacheAsBitmap=true
			butKill.name="butKill"
			//	
			butDrog.graphics.beginFill(0x0F00F0)
			butDrog.graphics.drawCircle(0, 0, 50)
			text_but=new TextField()
			text_but.text="Drog"
			text_but.textColor=0xFFFFFF
			butDrog.addChild(text_but)
			butDrog.cacheAsBitmap=true
			butDrog.name="butDrog"
			//
			butAlphaUp.graphics.beginFill(0x0F00F0)
			butAlphaUp.graphics.drawCircle(0, 0, 50)
			text_but=new TextField()
			text_but.text="+"
			text_but.textColor=0xFFFF00
			butAlphaUp.addChild(text_but)
			butAlphaUp.cacheAsBitmap=true
			butAlphaUp.name="butAlphaUp"

			butAlphaDown.graphics.beginFill(0x0F00F0)
			butAlphaDown.graphics.drawCircle(0, 0, 50)
			text_but=new TextField()
			text_but.text="-"
			text_but.textColor=0xFFFF00
			butAlphaDown.addChild(text_but)
			butAlphaDown.cacheAsBitmap=true
			butAlphaDown.name="butAlphaDown"
			//
			butKill.x=butDrog.x=butAlphaUp.x=butAlphaDown.x=800
			butKill.y=50
			butDrog.y=butKill.y + dis
			butAlphaUp.y=butDrog.y + dis
			butAlphaDown.y=butAlphaUp.y + dis
			//
			//background of tag
			bk_tag.graphics.beginFill(0xFFFFFF)
			bk_tag.graphics.drawRect(0, 0, 200, 100)
			bk_tag.x=butKill.x - dis
			bk_tag.y=butAlphaDown.y + dis

			//	
			layerUISide.addChild(butKill)
			layerUISide.addChild(butDrog)
			layerUISide.addChild(butAlphaUp)
			layerUISide.addChild(butAlphaDown)
			layerUISide.addChild(bk_tag)




		}


	}
}
