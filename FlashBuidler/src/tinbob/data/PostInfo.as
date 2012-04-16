package tinbob.data
{
	import __AS3__.vec.Vector;
	
	public class PostInfo
	{
		public var label:int;
		public var slug:String;
		public var title:String;
		public var client:String;
		public var agency:String;
		public var content:String;
		public var credits:String;
		//public var cat:int;
		public var thumbnail:ImageInfo;
		public var videoURL:String;
		public var images:Vector.<ImageInfo>;
		
		public var vAlign:int;
		public var hAlign:int;
		public var col:int;
		public var row:int;
		
		public var colors:Array;
	}
}