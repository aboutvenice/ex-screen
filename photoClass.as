package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MediaEvent;
	import flash.media.CameraRoll;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.ReturnKeyLabel;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;


	public class photoClass extends MovieClip
	{
		
		public var cameraRoll:CameraRoll = new CameraRoll();
		public var cameraUI:CameraUI = new CameraUI();                
		public var loader:Loader;
		private var tag_mode:String;
		public var myParent:DisplayObject
		public var obj_rotate:rotateClass
		public var tag_load:Boolean=false;
		public var nowScale:Number
		public var tags:NativeText;
		//for Exif
		public var obj_exif:EXifClass=new EXifClass()
		public var dataSource:IDataInput 
		public var mediaPromiseForEXif:MediaPromise 
		public var mediaPromise:MediaPromise
			
		public function photoClass(_parent:DisplayObject)
		{
			myParent=_parent
			obj_exif.addEventListener("ROTATED_LEFT",rotateLeftHandler)
			
		}
		
		protected function rotateLeftHandler(event:Event):void
		{
			trace("執行旋轉");
			//打開可執行選轉，但是會lag,fps降到1，持續數秒
//			loader.rotationZ=90
//			loader.x=loader.width
			
			
		}		
	
		public function initCamera():void
		{
			trace("Starting Camera");
			
			if( CameraUI.isSupported )
			{
				tag_mode="take"
				cameraUI.addEventListener(MediaEvent.COMPLETE, imageUse);
				cameraUI.addEventListener(Event.CANCEL, browseCancelled);
				cameraUI.addEventListener(ErrorEvent.ERROR, mediaError);
				//
				cameraUI.launch(MediaType.IMAGE);
			}
			else
			{
				trace( "This device does not support Camera functions.")
			}
		}   
		
		
		public function initCameraRoll():void
		{
			
			if(CameraRoll.supportsBrowseForImage)
			{
//				trace("Opening Camera Roll.")
				tag_mode="select"
				// Add event listeners for camera roll events
				cameraRoll.addEventListener(MediaEvent.SELECT, imageUse);
				cameraRoll.addEventListener(Event.CANCEL, browseCancelled);
				cameraRoll.addEventListener(ErrorEvent.ERROR, mediaError);
				
				// Open up the camera roll
				cameraRoll.browseForImage();
			}
			else
			{
				trace("This device does not support CameraRoll functions.")
			}
		}
		
	
		
		protected function imageUse(event:MediaEvent):void
		{
			trace("photoClass.imageUse(event)");
			
//			var mediaPromise:MediaPromise = event.data;
			 mediaPromise = event.data;
//			var mediaPromiseForEXif:MediaPromise = event.data;
			mediaPromiseForEXif = event.data;
			
			
			
			if(mediaPromise.file == null){
				
				if( mediaPromise.isAsync )
				{
//					trace( "Asynchronous media promise." );
					// for show photo
					loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleted);
					loader.loadFilePromise(mediaPromise);
					
				}
				else
				{
					trace( "Synchronous media promise." );
				}
				

				return;
			}  

		}
		
		private function onMediaLoaded(e:Event):void
		{
			obj_exif.readMediaData(dataSource)
			
			
		}		
				
		
		private function loaderCompleted(e:Event):void{
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleted);
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			if(tag_mode=="take")
			{
				if(CameraRoll.supportsAddBitmapData){
					
					addChild(loader)
					reSizeClass.resize(loader,myParent)
					//
					var bitmapData:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height);
					bitmapData.draw(loaderInfo.loader);     
					var c:CameraRoll = new CameraRoll();
					c.addBitmapData(bitmapData);
					trace("photo save")
					dispatchEvent(new Event("photoSave"))
				}
			
			
			}else if(tag_mode=="select")
			{
//				loader.scaleX=loader.scaleY=.3
				addChild(loader)
				reSizeClass.resize(loader,myParent)
//				trace("photo select:loaded")
			
			}
			
			
			nowScale=reSizeClass.getScale
			//
			setTagText()	
//			trace("nowScale= "+nowScale)	
//			trace("photoClass.loaderCompleted(e)");
			tag_load=true
//			trace("loader.width= "+loader.width)
//			trace("loader.height= "+loader.height)
			// for Exif
			dataSource=mediaPromiseForEXif.open();
			var eventSource:IEventDispatcher = dataSource as IEventDispatcher;
			eventSource.addEventListener( Event.COMPLETE, onMediaLoaded );    


			
		}
		
		public  function setLoader(_bArray:ByteArray):void
		{
			loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, null);
			loaderContext.allowCodeImport=true
			loader.loadBytes(_bArray)//,loaderContext)
			addChild(loader)
			
		}
		
		private function setTagText():void
		{
			tags= new NativeText(1);
			tags.returnKeyLabel = ReturnKeyLabel.DONE;
			tags.autoCorrect = true;
			tags.fontSize = 40;
//			nt.borderThickness = 5;
//			nt.borderCornerSize=3
			tags.borderColor=0x0FFF00
			tags.fontFamily = "Arial";
			tags.text = "default";
			tags.width = 200
			tags.x =0// (myParent.stage.stageWidth / 2) - (nt.width / 2);
			tags.y =0- (tags.height); //(myParent.stage.stageHeight / 3) - (nt.height);
			addChild(tags);
			tags.freeze()
				
			dispatchEvent(new Event("tagLoaded"))

			
		}		
		
		protected function mediaError(event:ErrorEvent):void
		{
			trace("photoClass.mediaError(event)");
			//通知Main,這個class被取消了
			dispatchEvent(new Event("cancel"))


		}
		
		protected function browseCancelled(event:Event):void
		{
			trace("photoClass.browseCancelled(event)");
			//通知Main,這個class被取消了
			dispatchEvent(new Event("browserCancel"))
			
		}
		
		private function removeEvent():void
		{
			trace("photoClass.removeEvent()");
			
			cameraRoll.removeEventListener(MediaEvent.SELECT,imageUse)
			cameraRoll.removeEventListener(Event.CANCEL, browseCancelled);
			cameraRoll.removeEventListener(ErrorEvent.ERROR, mediaError);
			
		}
		
		public function setRotate(_yaw:Number,_roll:Number):void
		{
			obj_rotate=new rotateClass(this,_yaw,_roll)
			
		}
		
		
		public function removeSelf():void
		{
			this.parent.removeChild(this);
			
		}
			
	
	}
}