package
{
	import com.rancondev.extensions.qrzbar.QRZBar;
	import com.rancondev.extensions.qrzbar.QRZBarEvent;

	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;



	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]


	public class Main extends Sprite
	{

		private var qr:QRZBar;
		public var layerText:Sprite=new Sprite()
		private var layerUI:Sprite=new Sprite()
		private var butScan:Sprite=new Sprite()
		private static var ball:Sprite=new Sprite()
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
			addChild(layerText)
			addChild(layerUI)
			//--------------------------------------------------
			// function runs here
			//--------------------------------------------------
			setAccl()
			setUI()
			//--------------------------------------------------
			// Listener
			//--------------------------------------------------			
			butScan.addEventListener(MouseEvent.CLICK, setQRReader)
		}

		public static function onRun():void
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

				disP=(difH * -1)
				ball.x+=disP * 4 //<-網頁移動的距離
				preH=obj_geo.heading
				//	
				text_diff.text="diifX= " + difX.toFixed(2) + "\n" + "diifY= " + difY.toFixed(2) + "\n" + "diifZ= " + difZ.toFixed(2) + "\n" + "defaultH= " + defaultH + "\n" + "diifH= " + difH.toFixed(2) + "\n" + "disP= " + disP.toFixed(2)

			}



		}

		private function setAccl():void
		{

			setDefaultValue()
			//
			layerText.addChild(obj_accl.accTextField)
			obj_geo.geoTextField.y=150
			layerText.addChild(obj_geo.geoTextField)
			//
			text_diff.x=450
			text_diff.scaleX=text_diff.scaleY=4
			text_diff.autoSize=TextFieldAutoSize.LEFT
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
			butScan.graphics.drawCircle(100, 100, 100)
			//	
//			layerUI.addChild(butScan)
			//

			ball.graphics.beginFill(0xFF0000)
			ball.graphics.drawCircle(stage.stageWidth / 2, stage.stageHeight / 2, 50)
			addChild(ball)

		}

		private function setQRReader(e:MouseEvent):void
		{
			qr=new QRZBar();
			qr.scan();
			//
			qr.addEventListener(QRZBarEvent.SCANNED, scannedHandler);

		}

		protected function scannedHandler(event:QRZBarEvent):void
		{
			qr.removeEventListener(QRZBarEvent.SCANNED, scannedHandler);

			var url:String=event.result
			var webView:StageWebView=new StageWebView();

			webView.stage=this.stage;
			webView.viewPort=new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			webView.loadURL(url)

		}


	}
}
