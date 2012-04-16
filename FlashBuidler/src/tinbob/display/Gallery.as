package tinbob.display
{

	import assets.PreloaderAnimation;
	
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.ImageInfo;
	import tinbob.data.PostInfo;
	import tinbob.display.YouTubePlayer;

	public class Gallery extends Sprite
	{
		public var galleryClosed:Signal;
		public var galleryImageRequested:Signal;
		public var galleryImageDisplayRequested:Signal;
		
		private var _posts:Vector.<PostInfo>;	
		private var _curPost:int;
		private var _curImage:int;
		
		private var _base:Sprite;
		private var _imgBase:Sprite;
		private var _bitmap:Bitmap;
		private var _preload:PreloaderAnimation;
		private var _closeBtn:CloseButton;
		private var _nextBtn:NavButton;
		private var _prevBtn:NavButton;
		private var _description:TextField;
		
		private var _w:int;
		private var _h:int;
		private var _intW:int;
		private var _intH:int;
		private var _footerH:int;
		
		private var _inTransition:Boolean;
		
		private var _unloaded:Boolean;
		private const DEFAULT_W:int = 16;
		private const DEFAULT_H:int = 9;
		private const FOOTER_OFFSET:int = 30;
		private const MARGIN:int = 120;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Gallery() {
			galleryClosed = new Signal();
			galleryClosed.add(onGalleryClosed);
			
			galleryImageRequested = new Signal(int, int);
			
			galleryImageDisplayRequested = new Signal(int);
			galleryImageDisplayRequested.add(onGalleryImageDisplayRequested);
			
			_curPost = -1;
			
			_curImage = -1;
				
			_unloaded = true;
			_inTransition = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			galleryClosed.removeAll();
			galleryImageRequested.removeAll();
			//galleryImageDisplayRequested.removeAll(); // as this is only internal, we dont want to remove incase we are just swithcing posts
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			transitionOut(true);
			
			_unloaded = true;
			
			_base = new Sprite();
			_base.graphics.beginFill(0x000000, 0.7);
			_base.graphics.drawRect(-100,-100,200,200);
			_base.graphics.endFill();
			
			_closeBtn = new CloseButton(35,35);
			
			_nextBtn = new NavButton(true, 35,35);
			_prevBtn = new NavButton(false, 35,35);
			
			_bitmap = new Bitmap(null, "auto", true);
			
			this.visible = true;
		}
		/////////////////////////////////////////////////////////////////
		// transitionOut --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
			_unloaded = true;
			_inTransition = true;
			if(imediate)endTransitionOut();
			else{
				TweenMax.killTweensOf(this);
				TweenMax.to(this, 0.4,{alpha:0, onComplete:endTransitionOut, onCompleteParams:[]});
			}
		}
		/////////////////////////////////////////////////////////////////
		// endTransitionOut ---------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function endTransitionOut():void {
			
			if(_base) {
				if(contains(_base))removeChild(_base);
				_base = null;
			}
			if(_closeBtn) {
				TweenMax.killTweensOf(_closeBtn);
				if(contains(_closeBtn))removeChild(_closeBtn);
				_closeBtn = null;
			}
			if(_nextBtn) {
				TweenMax.killTweensOf(_nextBtn);
				if(contains(_nextBtn))removeChild(_nextBtn);
				_nextBtn = null;
			}
			if(_prevBtn) {
				TweenMax.killTweensOf(_prevBtn);
				if(contains(_prevBtn))removeChild(_prevBtn);
				_prevBtn = null;
			}
			if(_description) {
				TweenMax.killTweensOf(_description);
				if(contains(_description))removeChild(_description);
				_description = null;
			}
			if(_imgBase) {
				TweenMax.killTweensOf(_imgBase);
				if(contains(_imgBase))removeChild(_imgBase);
				_imgBase = null;
			}
			if(_bitmap) {
				TweenMax.killTweensOf(_bitmap);
				if(contains(_bitmap))removeChild(_bitmap);
				_bitmap = null;
			}
			
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostsLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostsLoaded(posts:Vector.<PostInfo>):void {
			_posts = posts;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setCurrentPost --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setCurrentPost(label:int):void {
			_curPost = label;				
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryOpened():void {
			setup();
			if(!contains(_base))addChild(_base);
			
			if(!contains(_closeBtn))addChild(_closeBtn);
			_closeBtn.click.add(onCloseClick);
			
			if(!contains(_nextBtn))addChild(_nextBtn);
			_nextBtn.click.add(onNextClick);
			
			if(!contains(_prevBtn))addChild(_prevBtn);
			_prevBtn.click.add(onPrevClick);
			
			
			this.alpha = 0;
			TweenMax.to(this, 0.4,{alpha:1});
			
			resize(_w,_h);
			visible = true;
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryImageDisplayRequested -------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryImageDisplayRequested(index:int):void {
			if(index > -1 && index < _posts[_curPost].images.length){
				_curImage = index;
				if(!_imgBase) _imgBase = new Sprite();
				if(!contains(_imgBase))addChild(_imgBase);
				_imgBase.graphics.clear();
				_imgBase.graphics.beginFill(0x000000, 0.7);
				_imgBase.graphics.drawRect(-50,-50,100,100);
				_imgBase.graphics.endFill();
				
				if(!_preload) _preload = new PreloaderAnimation();
				if(!contains(_preload))addChild(_preload);
				
				if(!_description) _description = new TextField();
				if(contains(_description))removeChild(_description);
				var descriptionTf:TextFormat = new TextFormat ();
				descriptionTf.font = ExternalFonts.BODY;
				descriptionTf.size = 11;
				descriptionTf.leading = 5;
				descriptionTf.leftMargin = 15;
				descriptionTf.rightMargin = 15;
				descriptionTf.color = 0x999999;
				_description.embedFonts = false;
				_description.multiline = true;
				_description.autoSize = TextFieldAutoSize.LEFT;
				_description.wordWrap = true;
				_description.defaultTextFormat = descriptionTf;
				_description.text = _posts[_curPost].images[index].description;
					
				this.setChildIndex(_preload, this.numChildren -1);
				
				if(contains(_bitmap)) removeChild(_bitmap);
				_bitmap.bitmapData = null;
				
				if(index == 0) _prevBtn.visible = false;
				else _prevBtn.visible = true;
				
				if(index == (_posts[_curPost].images.length - 1)) _nextBtn.visible = false;
				else _nextBtn.visible = true;
				
				if(_unloaded) {
					findInternalDimensions(DEFAULT_W, DEFAULT_H);
					internalResize(_intW, _intH);
				}
				
				galleryImageRequested.dispatch(_curPost, index);
			}
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryImageLoaded --------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryImageLoaded(postLabel:int, image:ImageInfo):void {
			if(_curPost == postLabel){
				_unloaded = false;
				if(contains(_preload)) removeChild(_preload);
				if(_preload) _preload = null;
				
				if(!contains(_bitmap)) addChild(_bitmap);
				_bitmap.bitmapData = image.bitmapData;
				_bitmap.alpha = 0;
				TweenMax.to(_bitmap, 0.1,{alpha:1, delay:0.2});
				
				if(!contains(_description))addChild(_description);
				_description.alpha = 0;
				TweenMax.to(_description, 0.1,{alpha:1, delay:0.2});
				
				findInternalDimensions(_bitmap.bitmapData.width, _bitmap.bitmapData.height);
				internalResize(_intW, _intH, false);
			}
		}
		/////////////////////////////////////////////////////////////////
		// onCloseClick ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onCloseClick():void {
			galleryClosed.dispatch();
		}
		/////////////////////////////////////////////////////////////////
		// onNextClick ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onNextClick():void {
			galleryImageDisplayRequested.dispatch(_curImage+1);
		}
		/////////////////////////////////////////////////////////////////
		// onPrevClick ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onPrevClick():void {
			galleryImageDisplayRequested.dispatch(_curImage-1);
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryClosed():void {
			transitionOut();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// findInternalDimensions --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function findInternalDimensions (contentWidth:Number, contentHeight:Number):void	{
			var realViewW:Number = Number(_w) - MARGIN * 2; 
			var realViewH:Number = Number(_h) - MARGIN * 2; 
			var viewRatio:Number = realViewW / realViewH;
			var imgRatio:Number = contentWidth/contentHeight;
			
			if(viewRatio<imgRatio){
				_intW = realViewW;
				_intH = _intW / imgRatio;
			}
			else {
				_intH = realViewH;
				_intW = _intH * imgRatio;
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// internalResize ---------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function internalResize (width:int, height:int, imediate:Boolean = true):void	{
			if(_bitmap){
				_bitmap.width = width;
				_bitmap.height = height;
				_bitmap.y = -height*0.5;
				_bitmap.x = -width*0.5;
			}
			if(_description){
				_description.width = width;
				_description.x = -width*0.5;
				_description.y = height*0.5 + 15;
				
				if(_description.text == "") _footerH = 0;
				else _footerH = _description.height + 30;
			}
			
			if(imediate){
				if(_imgBase){
					_imgBase.width = width;
					_imgBase.height = height+_footerH;
					_imgBase.y = _footerH*0.5;
				}
				if(_nextBtn){
					_nextBtn.x = width*0.5+_nextBtn.w*0.5;
				}
				if(_prevBtn){
					_prevBtn.x = -width*0.5-_prevBtn.w*0.5;
				}
				if(_closeBtn){
					_closeBtn.x = width*0.5+_closeBtn.w*0.5;
					_closeBtn.y = -height*0.5+_closeBtn.h*0.5;
				}
			}
			else{
				if(_imgBase)TweenMax.to(_imgBase, 0.2,{width:width, height:height+_footerH, y:_footerH*0.5});
				if(_nextBtn)TweenMax.to(_nextBtn, 0.2,{x:width*0.5+_nextBtn.w*0.5});
				if(_prevBtn)TweenMax.to(_prevBtn, 0.2,{x:-width*0.5-_prevBtn.w*0.5});
				if(_closeBtn)TweenMax.to(_closeBtn, 0.2,{x:width*0.5+_closeBtn.w*0.5, y:-height*0.5+_closeBtn.h*0.5});
			}			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function resize (width:int, height:int):void	{
			_w = width;
			_h = height;
			if(_base)_base.width = _w;
			if(_base)_base.height = _h+2;
			this.x = int(width*0.5);
			this.y = int(height*0.5);
			
			if(!_unloaded) {
				findInternalDimensions(_bitmap.bitmapData.width, _bitmap.bitmapData.height);
				internalResize(_intW, _intH);
			}
		}
	}
}