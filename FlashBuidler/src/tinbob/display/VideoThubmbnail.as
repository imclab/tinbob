package tinbob.display
{
	import assets.PreloaderAnimation;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	public class VideoThubmbnail extends Sprite
	{
		public var click:Signal;
		
		private var _playText:Bitmap;
		private var _arrow:Shape;
		private var _overlay:Shape;
		private var _clientBitmap:Bitmap;
		public var _bitmapData:BitmapData;
		public var _bitmap:Bitmap;
		private var _border:Sprite;
		private var _base:Sprite;
		private var _preload:PreloaderAnimation;
		private var _w:int;
		private var _h:int;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function VideoThubmbnail(w:int, h:int)
		{
			_w = w;
			_h = h;
			
			click = new Signal();
			_bitmapData = new BitmapData(_w,_h,false);
			_bitmap = new Bitmap(new BitmapData(_w,_h,false),"auto",true);
			
			_border = new Sprite();
			_border.graphics.beginFill(0xffffff);
			_border.graphics.drawRect(-_w*0.5-4,-_h*0.5-4,_w+8,_h+8);
			_border.graphics.endFill();
			_border.scaleX = _border.scaleY = 1;
			_border.x = _w*0.5;
			_border.y = _h*0.5;
			addChild(_border);
			
			_base = new Sprite();
			_base.graphics.beginFill(0x000000);
			_base.graphics.drawRect(0,0,_w,_h);
			_base.graphics.endFill();
			
			_preload = new PreloaderAnimation();
			_preload.x = int(_w*0.5);
			_preload.y = int(_h*0.5);
			
			var playTf:TextFormat = new TextFormat ();
			playTf.font = ExternalFonts.ENVY_CODE;
			playTf.italic = true;
			playTf.size = 20;
			playTf.color = 0xffffff;
			
			var playField:TextField = new TextField ();			
			playField.embedFonts = true;
			playField.autoSize = TextFieldAutoSize.LEFT;
			playField.defaultTextFormat = playTf;			
			playField.text = "PLAY VIDEO";
			
			_playText = new Bitmap(new BitmapData(playField.width, playField.height, true, 0x000000));
			_playText.bitmapData.draw(playField);
			_playText.x = _w*0.5 - _playText.width;
			_playText.y = int(_h*0.5 - _playText.height*0.5);
			
			_overlay = new Shape();
			_overlay.graphics.beginFill(0x000000,0.5);
			_overlay.graphics.drawRect(0,0,_w,_h);
			_overlay.graphics.endFill();
			
			_arrow = new Shape();
			_arrow.graphics.beginFill(0x000000);
			_arrow.graphics.moveTo(-16, -18);
			_arrow.graphics.lineTo(14, 0);
			_arrow.graphics.lineTo(-16, 18);
			_arrow.graphics.lineTo(-16, -18);
			_arrow.graphics.endFill();
			_arrow.y = _h*0.5;
			_arrow.x = _w*0.5;
			addChild(_arrow);
			
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			this.buttonMode = true;
			this.useHandCursor = true;
			
			enable(false);
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// enable -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function enable(value:Boolean):void
		{
			if(value){
				if(contains(_base))removeChild(_base);
				if(contains(_preload))removeChild(_preload);
				
				if(!contains(_bitmap))addChild(_bitmap);
				this.setChildIndex(_arrow,this.numChildren-1);
			}
			else {
				if(!contains(_base))addChild(_base);
				if(!contains(_preload))addChild(_preload);
				
				if(contains(_bitmap))removeChild(_bitmap);
				this.setChildIndex(_arrow,this.numChildren-1);
			}
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setBitmapData ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setBitmapData(bitmapData:BitmapData):void
		{
			var s:Sprite = new Sprite();
			var bm:Bitmap = new Bitmap(bitmapData, "auto",true);
			bm.width = _w;
			bm.height = _h;
			s.addChild(bm);
			
			_bitmapData.draw(s);			
			enable(true);
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOver(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			TweenMax.killTweensOf(_border);
			TweenMax.to(_border, 0.2, {scaleX:1+0.025*(9/16), scaleY:1.025, ease:Sine.easeOut}); 
			
			if(!contains(_overlay))addChild(_overlay);
			TweenMax.killTweensOf(_overlay);
			_overlay.alpha = 0;
			TweenMax.to(_overlay, 0.35, {alpha:1});
			
			if(!contains(_playText))addChild(_playText);
			TweenMax.killTweensOf(_playText);
			_playText.alpha = 0;
			_playText.x = 0;
			TweenMax.to(_playText, 0.35, {x:_w*0.5-_playText.width*0.66, alpha:1, delay:0.1, ease:Sine.easeOut});
			
			TweenMax.killTweensOf(_arrow);
			TweenMax.to(_arrow, 0.3, {x:_w*0.5-_playText.width*0.66+_playText.width+15, scaleX:0.5, scaleY:0.5, ease:Sine.easeInOut});
			
			this.setChildIndex(_overlay,this.numChildren-1);
			this.setChildIndex(_playText,this.numChildren-1);
			this.setChildIndex(_arrow,this.numChildren-1);			
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOut ------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOut(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.removeEventListener(MouseEvent.CLICK, onClick);
			TweenMax.killTweensOf(_border);
			TweenMax.to(_border, 0.2, {scaleX:1, scaleY:1, ease:Sine.easeIn});
			
			TweenMax.killTweensOf(_overlay);
			TweenMax.to(_overlay, 0.35, {alpha:0, onComplete:removeChild, onCompleteParams:[_overlay]});
			
			TweenMax.killTweensOf(_playText);
			TweenMax.to(_playText, 0.3, {x:_w*0.5-_playText.width, alpha:0, ease:Sine.easeIn, onComplete:removeChild, onCompleteParams:[_playText]});
			
			TweenMax.killTweensOf(_arrow);
			TweenMax.to(_arrow, 0.35, {x:_w*0.5, scaleX:1, scaleY:1, delay:0.1, ease:Sine.easeInOut});
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick --------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(event:MouseEvent):void
		{
			click.dispatch();
		}
	}
}