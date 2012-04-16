package tinbob.display
{
	import assets.PreloaderAnimation;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Sine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.NavigationInfo;
	import tinbob.data.PostInfo;

	public class PostThumbnail extends Sprite
	{
		public var rollOver:Signal;
		public var click:Signal;
		
		public var label:int;
		public var colors:Array;
		public var _navigationInfo:NavigationInfo;
		private var _lastNavigationInfo:NavigationInfo;
		private var _nullNavigationInfo:NavigationInfo;
		
		private var _client:Sprite;
		private var _clientBitmap:Bitmap;
		private var _title:Sprite;
		private var _titleBitmap:Bitmap;
		private var _bitmap:Bitmap;
		private var _base:Sprite;
		private var _borderT:Shape;
		private var _borderB:Shape;
		private var _borderL:Shape;
		private var _borderR:Shape;
		private var _preload:PreloaderAnimation;
		
		private var _ready:Boolean;
		private var _selected:Boolean;
		
		private var _toX:int;
		private var _toY:int;
		
		
		
		public const border:int = 4;
		public const titlesVOffset:int = 40;
		
		public const borderColor:uint = 0xffffff;
		
		public const minW:int = 120;
		public const minH:int = 68;
		
		public const medW:int = 218;//240;
		public const medH:int = 124;//135;
		
		public const maxW:int = 328;
		public const maxH:int = 184;
		
		public const maxWAdjust:int = maxW - border;
		public const maxHAdjust:int = maxH - border;
		
		
		//public var col:uint;
		//public var row:uint;
		//public var hAlign:uint;
		//public var vAlign:uint;
		public const C:uint = 0;
		public const T:uint = 1;
		public const B:uint = 2;
		public const L:uint = 3;
		public const R:uint = 4;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function PostThumbnail(postInfo:PostInfo) 
		{
			rollOver = new Signal(NavigationInfo);
			click = new Signal(NavigationInfo);
			
			_lastNavigationInfo = new NavigationInfo();
			_lastNavigationInfo.label = -1;
			
			_navigationInfo = new NavigationInfo();
			_navigationInfo.label = postInfo.label;
			_navigationInfo.slug = postInfo.slug;
			_navigationInfo.isPost = true;
			_navigationInfo.row = postInfo.row;
			_navigationInfo.col = postInfo.col;
			_navigationInfo.vAlign = postInfo.vAlign;
			_navigationInfo.hAlign = postInfo.hAlign;
			
			_nullNavigationInfo = new NavigationInfo();
			_nullNavigationInfo.label = -1;
			_nullNavigationInfo.hAlign = -1;
			_nullNavigationInfo.vAlign = -1;
			_nullNavigationInfo.col = -1;
			_nullNavigationInfo.row = -1;
			
			label = postInfo.label;						
			_ready = false;
			_selected = false;
			
			_base = new Sprite();
			_base.graphics.beginFill(0x000000);
			_base.graphics.drawRect(0,0,medW, medH);
			_base.graphics.endFill();
			_base.x = -int(medW*0.5);
			_base.y = -int(medH*0.5);
			
			_preload = new PreloaderAnimation();
			_preload.x = int(_base.width*0.5)+0.5;
			_preload.y = int(_base.height*0.5)+0.5;
			_base.addChild(_preload);
			
			_borderT = new Shape();
			_borderT.graphics.beginFill(borderColor);
			_borderT.graphics.drawRect(border*0.5,-border*0.5, maxW + border, border);
			_borderT.graphics.beginFill(borderColor);
			var _borderTY:int;
			if (_navigationInfo.vAlign == T) _borderTY = - medH*0.5;
			else if (_navigationInfo.vAlign == C) _borderTY = -maxH*0.5;
			else if (_navigationInfo.vAlign == B) _borderTY = -maxH + medH*0.5;
			_borderT.x = int(-maxW*0.5)-border;
			_borderT.y = _borderTY;	
			
			_borderB = new Shape();
			_borderB.graphics.beginFill(borderColor);
			_borderB.graphics.drawRect(border*0.5,-border*0.5, maxW + border, border);
			_borderB.graphics.beginFill(borderColor);
			var _borderBY:int;
			if (_navigationInfo.vAlign == T) _borderBY = - medH*0.5 + maxH ;
			else if (_navigationInfo.vAlign == C) _borderBY = -maxH*0.5 + maxH;
			else if (_navigationInfo.vAlign == B) _borderBY = -maxH + Math.ceil(medH*0.5) + maxH;
			_borderB.x = int(-maxW*0.5)-border;
			_borderB.y = _borderBY;
			
			_borderL = new Shape();
			_borderL.graphics.beginFill(borderColor);
			_borderL.graphics.drawRect(-border*0.5,border*0.5, border, maxH + border);
			_borderL.graphics.beginFill(borderColor);
			var _borderLY:int;
			if (_navigationInfo.vAlign == T) _borderLY = - medH*0.5 - border;
			else if (_navigationInfo.vAlign == C) _borderLY = -maxH*0.5 - border;
			else if (_navigationInfo.vAlign == B) _borderLY = -maxH + medH*0.5 - border;
			_borderL.x = int(-maxW*0.5);
			_borderL.y = _borderLY;	
			
			_borderR = new Shape();
			_borderR.graphics.beginFill(borderColor);
			_borderR.graphics.drawRect(-border*0.5,border*0.5, border, maxH + border);
			_borderR.graphics.beginFill(borderColor);
			var _borderRY:int;
			if (_navigationInfo.vAlign == T) _borderRY = - medH*0.5 - border;
			else if (_navigationInfo.vAlign == C) _borderRY = -maxH*0.5 - border;
			else if (_navigationInfo.vAlign == B) _borderRY = -maxH + medH*0.5 - border;
			_borderR.x = int(maxW*0.5);
			_borderR.y = _borderRY;	
			
			_bitmap = new Bitmap(new BitmapData(maxW,maxH, false),"auto",true);
						
			_client = new Sprite();
			var clientY:int;
			if (_navigationInfo.vAlign == T) clientY = -medH*0.5 - 40;
			else if (_navigationInfo.vAlign == C) clientY = -maxH*0.5 - 40;
			else if (_navigationInfo.vAlign == B) clientY = -maxH + medH*0.5 - 40;
			_client.x = int(-maxW*0.5);
			_client.y = clientY;
			_clientBitmap = new Bitmap(new BitmapData(maxW, 20, true, 0x000000), "auto", true);
			_client.addChild(_clientBitmap);
			
			var clientMask:Shape = new Shape;
			clientMask.graphics.beginFill(0xff000000);
			clientMask.graphics.drawRect(0,0,_client.width, _client.height);
			clientMask.graphics.endFill();
			clientMask.x = _client.x;
			clientMask.y = _client.y;
			addChild(clientMask);
			_client.mask = clientMask;
			
			
			var clientTf:TextFormat = new TextFormat ();
			clientTf.font = ExternalFonts.ENVY_CODE_ITALIC;
			clientTf.italic = true;
			clientTf.size = 12;
			clientTf.color = 0xffffff;
			
			var clientField:TextField = new TextField (); 
			clientField.width = _client.width;
			clientField.embedFonts = true;
			clientField.defaultTextFormat = clientTf;			
			clientField.text = postInfo.client.toUpperCase();
			_clientBitmap.bitmapData.draw(clientField);
			_clientBitmap.x = -maxW;
			
			_title = new Sprite();
			var titleY:int;
			if (_navigationInfo.vAlign == T) titleY = -medH*0.5 - 30;
			else if (_navigationInfo.vAlign == C) titleY = -maxH*0.5 - 30;
			else if (_navigationInfo.vAlign == B) titleY = -maxH + medH*0.5 - 30;
			_title.x = int(-maxW*0.5);
			_title.y = titleY;
			_titleBitmap = new Bitmap(new BitmapData(maxW, 40, true, 0x000000), "auto", true);
			_title.addChild(_titleBitmap);
			
			var titleMask:Shape = new Shape;
			titleMask.graphics.beginFill(0xff000000);
			titleMask.graphics.drawRect(0,0,_title.width, _title.height);
			titleMask.graphics.endFill();
			titleMask.x = _title.x;
			titleMask.y = _title.y;
			addChild(titleMask);
			_title.mask = titleMask;
			
			var titleTf:TextFormat = new TextFormat ();
			titleTf.font = ExternalFonts.ENVY_CODE;
			titleTf.size = 24;
			titleTf.color = 0xffffff;
			
			var titleField:TextField = new TextField (); 
			titleField.width = _title.width;
			titleField.embedFonts = true;
			titleField.defaultTextFormat = titleTf;			
			titleField.text = postInfo.title.toUpperCase();
			_titleBitmap.x = -2;
			_titleBitmap.bitmapData.draw(titleField);
			_titleBitmap.x = -maxW;

			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);	
			this.buttonMode  = true;
			this.useHandCursor = true;
		}
		/////////////////////////////////////////////////////////////////
		// transitionIn-------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionIn(imediate:Boolean = false):void {
			if(!contains(_base)) addChild(_base);
			if(imediate){
				this.visible = true;
				this.scaleX = this.scaleY = 1;
			}
			else{
				this.visible = true;
				this.scaleX = this.scaleY = 0;
				this.alpha = 0;
				TweenMax.to(this,0.2,{scaleX:1, scaleY:1, alpha:1, ease:Expo.easeOut, delay:Math.random()*0.6+1});
			}				
		}
		/////////////////////////////////////////////////////////////////
		// transitionOut -------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.removeEventListener(MouseEvent.CLICK, onClick);
			rollOver = null;
			click = null;
			_navigationInfo = null;
			_lastNavigationInfo = null;
			colors = null;
			
			TweenMax.killChildTweensOf(this);
			if(imediate){
				while(numChildren > 0){
					removeChildAt(0);
				}
				
				_client = null;
				_clientBitmap = null;
				_title = null;
				_titleBitmap = null;
				_bitmap = null;
				_base = null;
				_preload = null;
				_borderT = null;
				_borderB = null;
				_borderL = null;
				_borderR = null;
			}
			else{
				if (!_selected){
					safeRemoveAndNullChild(_client);
					safeRemoveAndNullChild(_clientBitmap);
					safeRemoveAndNullChild(_title);
					safeRemoveAndNullChild(_titleBitmap);
					safeRemoveAndNullChild(_borderT);
					safeRemoveAndNullChild(_borderB);
					safeRemoveAndNullChild(_borderL);
					safeRemoveAndNullChild(_borderR);
					var target;
					if(_ready) target = _bitmap;
					else target = _base;
					TweenMax.to(target,0.2,{width:0, height:0, alpha:0, x:_toX+(medW*0.5), y:_toY+(medH*0.5),onComplete:safeRemoveChild, onCompleteParams:[target], ease:Expo.easeIn, delay:Math.random()*0.6});
				} 
				else{
					TweenMax.to(_bitmap,0.3,{width:0, height:0, alpha:0, x:_toX+(maxW*0.5), y:_toY+(maxH*0.5),onComplete:safeRemoveChild, onCompleteParams:[_bitmap], ease:Expo.easeIn, delay:0.7});
					// animate the titles
					TweenMax.to(_clientBitmap,0.4,{x:-maxW,ease:Sine.easeIn, onComplete:safeRemoveChild, onCompleteParams:[_client], delay:0.5});
					TweenMax.to(_titleBitmap,0.3,{x:-maxW,ease:Sine.easeIn, onComplete:safeRemoveChild, onCompleteParams:[_title], delay:0.5});
					
					// animate the borders
					TweenMax.to(_borderT,0.2,{alpha:0, onComplete:removeChild, onCompleteParams:[_borderT], delay:0.4});
					TweenMax.to(_borderB,0.2,{alpha:0, onComplete:removeChild, onCompleteParams:[_borderB], delay:0.4});
					TweenMax.to(_borderL,0.2,{alpha:0, onComplete:removeChild, onCompleteParams:[_borderL], delay:0.4});
					TweenMax.to(_borderR,0.2,{alpha:0, onComplete:removeChild, onCompleteParams:[_borderR], delay:0.4});
				}
			}				
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onNavigationChanged --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onNavigationChanged(navigationInfo:NavigationInfo):void
		{
			if(	_navigationInfo.isPost == navigationInfo.isPost &&
				_navigationInfo.label == navigationInfo.label
				)
			{}
			else {};
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostSelected -------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostSelected(navigationInfo:NavigationInfo):void
		{
			if(navigationInfo){
				if(navigationInfo.isPost && _navigationInfo.label == navigationInfo.label) {
					if(!_selected) select(navigationInfo);
				}
				else {
					deselect(navigationInfo);
				}
			}
			
			
			_lastNavigationInfo = navigationInfo;
		}

		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailLoaded ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailLoaded(bitmapData:BitmapData):void
		{
			 TweenMax.delayedCall(0.5, applyThumbnailBitmapData,[bitmapData]);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// applyThumbnailBitmapData ---------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function applyThumbnailBitmapData(bitmapData:BitmapData):void
		{
			var s:Sprite = new Sprite();
			var bm:Bitmap = new Bitmap(bitmapData, "auto",true);
			bm.width = maxW;
			bm.height = maxH;
			s.addChild(bm);
			
			_bitmap.bitmapData.draw(s);
			_bitmap.width = medW;
			_bitmap.height = medH;
			// make sure the bitmap is in the same place as the base
			_bitmap.x = _base.x;
			_bitmap.y = _base.y;
			_bitmap.width = _base.width;
			_bitmap.height = _base.height;
			_bitmap.alpha = 0;						
			if(!contains(_bitmap))addChild(_bitmap);
			
			//trnasition in
			onPostSelected(_lastNavigationInfo);
			TweenMax.to(_bitmap,0.4,{alpha:1, onComplete:removeBaseAndPreloader, onCompleteParams:[]});
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeBaseAndPreloader -----------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeBaseAndPreloader():void
		{
			_ready = true;
			if(_base){
				if(contains(_base))removeChild(_base);
			}
			_base = null;
			_preload = null;
			//deselect(_lastNavigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailAnalized ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailAnalized(colors:Array):void
		{
			this.colors = colors;
			_navigationInfo.colors = colors;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOver(e:MouseEvent):void
		{
			//if(_ready){
				rollOver.dispatch(_navigationInfo);
				this.addEventListener(MouseEvent.CLICK, onClick, false,0,true);
			//}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick --------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(e:MouseEvent):void
		{
			click.dispatch(_navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// select ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function select(navigationInfo:NavigationInfo):void
		{
			_selected = true;
			
			var realNavigationInfo:NavigationInfo;
			
			if(navigationInfo.label != -1 && PostThumbnailGrid(parent)._thumbnails.length >=navigationInfo.label+1)
			{
				if(PostThumbnailGrid(parent)._thumbnails[navigationInfo.label]){
					realNavigationInfo = PostThumbnailGrid(parent)._thumbnails[navigationInfo.label]._navigationInfo;
				}
			}
			else realNavigationInfo = _nullNavigationInfo;
			
			_toX = -maxWAdjust*0.5;
			if (realNavigationInfo.vAlign == T) _toY = -medH*0.5 + border *0.5;
			else if (realNavigationInfo.vAlign == C) _toY = -maxH*0.5 + border *0.5;
			else if (realNavigationInfo.vAlign == B) _toY = -maxH + medH*0.5 + border *0.5;
			
			var target;
			if(_ready) target = _bitmap;
			else target = _base;
			
			TweenMax.killTweensOf(target);
			TweenMax.to(target,0.2,{width:maxWAdjust, height:maxHAdjust, x:_toX, y:_toY, colorMatrixFilter:{colorize:0x000000, amount:0},ease:Sine.easeOut});
			parent.swapChildrenAt(parent.getChildIndex(this), parent.numChildren-1);
			
			if(!_ready){
				_preload.scaleX = _preload.scaleY = Number(medW)/Number(maxW);
			} 
			
			// animate the titles
			if(!contains(_client))addChild(_client);
			TweenMax.killTweensOf(_clientBitmap);
			TweenMax.to(_clientBitmap,0.3,{x:0,ease:Sine.easeOut, delay:0.1});
			
			if(!contains(_title))addChild(_title);
			TweenMax.killTweensOf(_titleBitmap);
			TweenMax.to(_titleBitmap,0.3,{x:0,ease:Sine.easeOut});
			
			// animate the borders
			if(!contains(_borderT))addChild(_borderT);
			TweenMax.killTweensOf(_borderT);
			_borderT.scaleX = 0;
			_borderT.alpha = 0;
			TweenMax.to(_borderT,0.1,{scaleX:1, alpha:1, ease:Sine.easeOut, delay:0.2});
			
			if(!contains(_borderB))addChild(_borderB);
			TweenMax.killTweensOf(_borderB);
			_borderB.scaleX = 0;
			_borderB.alpha = 0;
			TweenMax.to(_borderB,0.1,{scaleX:1, alpha:1,ease:Sine.easeIn, delay:0.3});
			
			if(!contains(_borderL))addChild(_borderL);
			TweenMax.killTweensOf(_borderL);
			_borderL.scaleY = 0;
			_borderL.alpha = 0;
			TweenMax.to(_borderL,0.1,{scaleY:1, alpha:1,ease:Sine.easeOut, delay:0.2});
			
			if(!contains(_borderR))addChild(_borderR);
			TweenMax.killTweensOf(_borderR);
			_borderR.scaleY = 0;
			_borderR.alpha = 0;
			TweenMax.to(_borderR,0.1,{scaleY:1, alpha:1,ease:Sine.easeIn, delay:0.3});
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// deselect ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function deselect(navigationInfo:NavigationInfo):void
		{
			_selected = false;
			var realNavigationInfo:NavigationInfo;
			
			if(navigationInfo.label != -1 && navigationInfo.isPost && PostThumbnailGrid(parent)._thumbnails.length >=navigationInfo.label+1)
			{
				if(PostThumbnailGrid(parent)._thumbnails[navigationInfo.label]){
					realNavigationInfo = PostThumbnailGrid(parent)._thumbnails[navigationInfo.label]._navigationInfo;
				}
			}
			else realNavigationInfo = _nullNavigationInfo;
				
			
			if (realNavigationInfo.col == _navigationInfo.col){
				if (realNavigationInfo.vAlign == T) _toY = 0;
				else if (realNavigationInfo.vAlign == C) _toY = (realNavigationInfo.row > _navigationInfo.row) ? -medH*0.75 -titlesVOffset: -medH*0.25;
				else if (realNavigationInfo.vAlign == B) _toY = -maxH + medH*0.5 - titlesVOffset;
			}
			else _toY = -medH*0.5;
			
			if (realNavigationInfo.row != -1){
				if (realNavigationInfo.hAlign == L) _toX = -medW*0.25;
				else if (realNavigationInfo.hAlign == C) {
					if(realNavigationInfo.col == _navigationInfo.col) _toX = -medW*0.5;
					else _toX = (realNavigationInfo.col > _navigationInfo.col) ? -medW*0.75 : -medW*0.25;
				}
				else if (realNavigationInfo.hAlign == R) _toX = -medW*0.75;
			}
			else _toX = -medW*0.5;
			
			var color:uint;
			//if(navigationInfo.label != -1) color = (navigationInfo.colors) ? navigationInfo.colors[0]:0x000000;
			//else color = 0x000000;
			color = 0x000000;
			
			var colorizeValue:Number;
			if(realNavigationInfo.label == -1) colorizeValue = 0;
			else colorizeValue = 0.5;
			
			var contrastValue:Number;
			if(realNavigationInfo.label == -1) contrastValue = 1;
			else contrastValue = 0.8;
			
			var target;
			if(_ready) target = _bitmap;
			else target = _base;
			
			TweenMax.killTweensOf(target);
			TweenMax.to(target,0.2,{width:medW, height:medH, x:_toX, y:_toY, colorMatrixFilter:{colorize:color, amount:colorizeValue, contrast:contrastValue},ease:Sine.easeIn});
			
			if(!_ready){
				_preload.scaleX = _preload.scaleY = 1;
			} 
			
			// animate the titles
			if(contains(_client)){
				TweenMax.killTweensOf(_clientBitmap);
				TweenMax.to(_clientBitmap,0.2,{x:-maxW,ease:Sine.easeIn, onComplete:safeRemoveChild, onCompleteParams:[_client]});
			}
			if(contains(_title)){
				TweenMax.killTweensOf(_titleBitmap);
				TweenMax.to(_titleBitmap,0.1,{x:-maxW,ease:Sine.easeIn, onComplete:safeRemoveChild, onCompleteParams:[_title]});
			}
			
			// animate the borders
			if(contains(_borderT)){
				TweenMax.killTweensOf(_borderT);
				TweenMax.to(_borderT,0.1,{alpha:0, onComplete:safeRemoveChild, onCompleteParams:[_borderT]});
			}
			
			if(contains(_borderB)){
				TweenMax.killTweensOf(_borderB);
				TweenMax.to(_borderB,0.1,{alpha:0, onComplete:safeRemoveChild, onCompleteParams:[_borderB]});
			}
			
			if(contains(_borderL)){
				TweenMax.killTweensOf(_borderL);
				TweenMax.to(_borderL,0.1,{alpha:0, onComplete:safeRemoveChild, onCompleteParams:[_borderL]});
			}
			
			if(contains(_borderR)){
				TweenMax.killTweensOf(_borderR);
				TweenMax.to(_borderR,0.1,{alpha:0, onComplete:safeRemoveChild, onCompleteParams:[_borderR]});
			}
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// safeRemoveChild ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function safeRemoveChild(child:DisplayObject):void
		{
			if(child){
				if(contains(child))removeChild(child);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// safeRemoveAndNullChild ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function safeRemoveAndNullChild(child:DisplayObject):void
		{
			safeRemoveChild(child);
			child = null;
		}

		
		
	}
}