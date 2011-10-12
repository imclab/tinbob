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
	
	import org.osflash.signals.Signal;
	
	public class GalleryThumbnail extends Sprite
	{
		public var click:Signal;
		
		public var _index:int;
		public var _bitmapData:BitmapData;
		public var _bitmap:Bitmap;
		private var _overlay:Shape;
		private var _border:Sprite;
		private var _base:Sprite;
		private var _preload:PreloaderAnimation;
		private var _w:int;
		private var _h:int;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function GalleryThumbnail(index:int, w:int, h:int)
		{
			_index = index;
			_w = w;
			_h = h;
			
			click = new Signal(int);
			_bitmapData = new BitmapData(_w,_h,true,0x00000000);
			_bitmap = new Bitmap(_bitmapData,"auto",true);
			
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
			
			_overlay = new Shape();
			_overlay.graphics.beginFill(0x000000,0.5);
			_overlay.graphics.drawRect(0,0,_w,_h);
			_overlay.graphics.endFill();
			
			
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
			}
			else {
				if(!contains(_base))addChild(_base);
				if(!contains(_preload))addChild(_preload);
				
				if(contains(_bitmap))removeChild(_bitmap);
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
			TweenMax.to(_border, 0.2, {scaleX:1+0.025, scaleY:1.025, ease:Sine.easeOut});
			
			if(!contains(_overlay))addChild(_overlay);
			TweenMax.killTweensOf(_overlay);
			_overlay.alpha = 0;
			TweenMax.to(_overlay, 0.35, {alpha:1});
			
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
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick --------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(event:MouseEvent):void
		{
			click.dispatch(_index);
		}
	}
}