package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class textClass extends MovieClip
	{
		
		private var frame:Sprite
		public var obj_text:TextField
		public var obj_rotate:rotateClass



		public function textClass(_url:String)
		{
			
			//set text
			obj_text=new TextField()
			obj_text.width=800
			obj_text.height=800
			obj_text.alpha=.5
			obj_text.background=true
			obj_text.autoSize=TextFieldAutoSize.NONE
			obj_text.defaultTextFormat=new TextFormat(null,80)
			obj_text.multiline = true; //多行
			obj_text.wordWrap = true; //自動換行
			var format:TextFormat = obj_text.getTextFormat();
			format.kerning = true;
			format.leading=5;//設置行距為5
			
			addChild(obj_text)
			//
			obj_text.text=_url
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