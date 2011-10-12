package tinbob.display
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class Footer extends Sprite
	{
		private var _inTransition:Boolean;
		
		//private var _copyright:TextField;
		private var _logo:Bitmap;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Footer() 
		{
			_inTransition = false;
			
			/*var copyTf:TextFormat = new TextFormat ();
			copyTf.font = ExternalFonts.BODY;
			copyTf.size = 10;
			copyTf.leading = -5;
			copyTf.letterSpacing =1;
			copyTf.color = 0xffffff;			
			
			_copyright = new TextField (); 
			_copyright.embedFonts = false;
			_copyright.multiline = true;
			_copyright.autoSize = TextFieldAutoSize.LEFT;
			_copyright.defaultTextFormat = copyTf;
			_copyright.height = 40;
			_copyright.htmlText = "<br/>© Tin Bob<br/>";
			_copyright.x = -_copyright.width -5;
			_copyright.alpha = 0.7;
			_copyright.y = -10;*/
			
			_logo = new Bitmap();
			_logo.alpha = 0.8;
			_logo.x = -106;
			_logo.y = -55;
			
			
			this.mouseEnabled  =false;
			this.mouseChildren = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			if(_inTransition) transitionOut(true);
			//if(!contains(_copyright))addChild(_copyright);
			if(!contains(_logo))addChild(_logo);
			this.visible = true;
		}
		/////////////////////////////////////////////////////////////////
		// transitionOut --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
			_inTransition = true;
			//if(contains(_copyright))removeChild(_copyright);
			if(contains(_logo))removeChild(_logo);
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onLogosLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onLogosLoaded(logos:Vector.<BitmapData>):void {
			_logo.bitmapData = logos[3];
			_logo.y = -_logo.height;
			_logo.x = -_logo.width;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function resize (width:int, height:int):void	{
			this.x = width -25;
			this.y = height -25;			
		}
	}
}