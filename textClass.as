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
			
			frame=new Sprite()
			frame.x=frame.y=frame.z=0
			frame.graphics.beginFill(0xFFFFFF, .5)
			frame.graphics.drawRect(0, 0, 400, 300)
			addChild(frame)
			
			//set text
			obj_text=new TextField()
			obj_text.autoSize=TextFieldAutoSize.LEFT
			obj_text.defaultTextFormat=new TextFormat(null,40)
			addChild(obj_text)
			//
			obj_text.text=_url
		}
	}
}