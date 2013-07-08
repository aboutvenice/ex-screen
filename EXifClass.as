package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.IFD;

	public class EXifClass extends MovieClip
	{
		
		public var dataSource:IDataInput;
		private var exif:ExifInfo;
		private var output:TextField=new TextField();


		public function EXifClass()
		{
		}
		
		
		public function readMediaData(_dataSource:IDataInput):void
		{
			
			dataSource=_dataSource
			
			var data:ByteArray = new ByteArray();
			dataSource.readBytes( data );
			data.position=0
//			trace("data= "+data)	
//			trace("data.bytesAvailable in EXifClass= "+data.bytesAvailable)
//			trace("data.position= "+data.position)
			exif = new ExifInfo(data);
//			output.text = displayIFD(exif.ifds.exif); // This stores some properties like resolutionX, resolutionY,.etc.
//			output.text = displayIFD(exif.ifds.primary); // This one stores the orientation data.
//			output.text = getOrientation(exif.ifds.primary)
			
			trace("-------------------getOrientation(exif.ifds.primary)= "+getOrientation(exif.ifds.primary))
			
		}
		
		public function displayIFD(ifd:IFD):String {
			//trace(" --- " + ifd.level + " --- ");
			var str:String = "";
			for (var entry:String in ifd) {
//				trace(entry + ": " + ifd[entry]);
				str += (entry + ": " + ifd[entry] + "\n")
			}
			
			return str;
		}
		
		
		public function getOrientation(ifd:IFD):String{
			var str:String = "";
			for (var entry:String in ifd) {
				if(entry == "Orientation"){
					str = ifd[entry];
				}
			}
			
			switch(str){
				case "1": //normal
					str = "NORMAL";
					dispatchEvent(new Event("NORMAL"))
					break;
				case "3": //rotated 180 degrees (upside down)
					str = "UPSIDE_DOWN";
					break;
				case "6": //rotated 90 degrees CW
					str = "ROTATED_LEFT"
					dispatchEvent(new Event("ROTATED_LEFT"))
					break;
				case "8": //rotated 90 degrees CCW
					str = "ROTATED_RIGHT"
					break;
				case "9": //unknown
					str = "UNKNOWN"
					break;
			}
			
			return str;
		}
		
	}
}