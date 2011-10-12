package tinbob.display
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.NavigationInfo;
	import tinbob.data.PostInfo;
	
	public class LinkButton extends Sprite
	{
		public var url:String;
		public var rollOver:Signal;
		public var click:Signal;
		
		private var _enabled:Boolean;
		private var _selected:Boolean;
		private var _opened:Boolean;
		
		private var _title:Bitmap;
		private var _bar:Sprite;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function LinkButton(url:String, title:String)
		{
			this.url = url;
			rollOver = new Signal();
			click = new Signal(String);
					
			_title = new Bitmap();
			
			var titleTf:TextFormat = new TextFormat ();
			titleTf.font = ExternalFonts.ENVY_CODE_ITALIC;
			titleTf.size = 13;
			titleTf.color = 0xffffff;
			
			var titleField:TextField = new TextField (); 
			titleField.autoSize = TextFieldAutoSize.LEFT
			titleField.embedFonts = true;
			titleField.defaultTextFormat = titleTf;			
			titleField.text = title.toUpperCase();
			
			var titleBmd:BitmapData = new BitmapData(titleField.width, titleField.height, true, 0x000000);
			titleBmd.draw(titleField);
			
			_title.bitmapData = titleBmd;
			
			_title.x = 0;//-int(_title.width/2); // now we are aling the text to the left
			_title.y = -int(_title.height/2);
			_title.alpha = 1;
			
			_bar = new Sprite();
			_bar.graphics.beginFill(0xffffff,0.2);
			//_bar.graphics.drawRect(-int(_title.width/2)-10, -3, _title.width+20, 7); // now we are aling the text to the left
			_bar.graphics.drawRect(-10, -3, _title.width+20, 7);
			_bar.graphics.endFill();
			
			addChild(_bar);
			addChild(_title);
			
			enable(false);
			select(false);
			open(false);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// enable ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function enable(value:Boolean = true):void
		{
			_enabled = value;
			if(_enabled){
				this.buttonMode = true;
				this.useHandCursor = true;
				this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
				this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				this.alpha = 1;
			}
			else{
				this.buttonMode = false;
				this.useHandCursor = false;
				this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				this.removeEventListener(MouseEvent.CLICK, onClick);
				this.alpha = 0.2;
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// select -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function select(value:Boolean):void
		{
			_selected = value;
			if(_selected){				
				TweenMax.killTweensOf(_bar);
				TweenMax.to(_bar, 0.3,{scaleX:1, scaleY:1, ease:Sine.easeOut});
			}
			else if(!_opened){
				TweenMax.killTweensOf(_bar);
				TweenMax.to(_bar, 0.3,{scaleX:0, scaleY:1, ease:Sine.easeOut});
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// open -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function open(value:Boolean):void
		{
			_opened = value;
			if(_opened){
				TweenMax.killTweensOf(_bar);
				TweenMax.to(_bar, 0.4,{scaleX:1, scaleY:2, ease:Sine.easeOut});
			}
			else{
				select(false);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOver(event:MouseEvent):void
		{
			if(_enabled && !_opened) {
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
				select(true);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOut(event:MouseEvent):void
		{
			if(_enabled && !_opened) {
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
				select(false);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(event:MouseEvent):void
		{
			if(_enabled && !_opened && !_opened){
				click.dispatch(url);
				var request:URLRequest = new URLRequest(url); 
				try {
					navigateToURL(request, '_self');
				} catch (e:Error) {
					trace("Error occurred!");
				}
			}
		}
			
	}
}