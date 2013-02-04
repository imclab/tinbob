package tinbob.display
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.PageInfo;
	
	public class Page extends Sprite
	{
		public var videoOpened:Signal;
		
		private var _pages:Vector.<PageInfo>;
		
		private var _tinbob:Sprite;
		private var _tinbobBitmap:Bitmap;
		private var _logo:Sprite;
		private var _logoBitmap:Bitmap;
		private var _thumbnail:VideoThubmbnail;
		private var _title:TextField;
		private var _contact:TextField;
		private var _description:TextField;
		
		public const _imgW:int = 440;
		public const _imgH:int = 250;
		public const _textW:int = _imgW;
		
		public const _imgX:int = -_imgW;
		public const _imgY:int = -_imgH;
		public const _tinbobX:int = 270;		
		public const _titleX:int = _imgX - 2;
		public const _titleY:int = _imgY - 50;		
		public const _descriptionX:int = _titleX;
		public const _descriptionY:int = _imgY + _imgH + 20;
		
		public const _contactX:int = 247;
		
		public const _transitonDuration:Number = 0.3;
		
		private var _curInfo:PageInfo;
		private var _nextInfo:PageInfo;
		
		private var _curPage:int;		
		
		private var _isOpen:Boolean;
		
		private var _inTransition:Boolean;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Page() {
			videoOpened = new Signal();
			
			var titleTf:TextFormat = new TextFormat();
			titleTf.font = ExternalFonts.ENVY_CODE;
			titleTf.size = 28;
			titleTf.underline = true;
			titleTf.color = 0xffffff;
			
			var bodyTf:TextFormat = new TextFormat ();
			bodyTf.font = ExternalFonts.BODY;
			bodyTf.size = 11;
			bodyTf.leading = 5;
			bodyTf.color = 0xffffff;
			
			var contactTf:TextFormat = new TextFormat ();
			contactTf.font = ExternalFonts.BODY;
			contactTf.size = 10;
			contactTf.leading = -5;
			contactTf.letterSpacing =1;
			contactTf.color = 0xffffff;
			
			_title = new TextField (); 
			_title.embedFonts = true;
			_title.width = _textW;
			_title.defaultTextFormat = titleTf;
			
			_description = new TextField (); 
			_description.embedFonts = false;
			_description.width = _textW;
			_description.multiline = true;
			_description.autoSize = TextFieldAutoSize.LEFT;
			_description.wordWrap = true;
			_description.defaultTextFormat = bodyTf;	
			
			_contact = new TextField (); 
			_contact.embedFonts = false;
			_contact.width = _textW;
			_contact.multiline = true;
			_contact.autoSize = TextFieldAutoSize.LEFT;
			_contact.wordWrap = false;
			_contact.defaultTextFormat = contactTf;
			
			_thumbnail = new VideoThubmbnail(_imgW,_imgH);
			_thumbnail.click.add(onThumbnailClick);
			
			_tinbobBitmap = new Bitmap(null, "auto", true);
			_tinbob = new Sprite();
			_tinbob.addChild(_tinbobBitmap);
			
			_logoBitmap = new Bitmap(null, "auto", true);
			_logo = new Sprite();
			_logo.addChild(_logoBitmap);
			
			_curPage = -1;
			_isOpen = false;
			
			_inTransition = false;
			
			transitionOut(true);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			videoOpened.removeAll();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			if(_inTransition) transitionOut(true);
			if(_isOpen) transitionOut();
		}
		/////////////////////////////////////////////////////////////////
		// transitionOut --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
			_isOpen = false;
			_inTransition = true;
			TweenMax.killChildTweensOf(this);
			TweenMax.killDelayedCallsTo(populateData);
			if(imediate){		
				onTransionOutComplete();
			}
			else{
				TweenMax.killTweensOf(_thumbnail);			
				TweenMax.to(_thumbnail, 0.2, {x:"20", y:"20", scaleX:0.8, scaleY:0.8, alpha:0, ease:Sine.easeIn, delay:0.2});
				TweenMax.allTo([_title,
					_description],0.2,{x:"-40", alpha:0, ease:Sine.easeIn},0.1,onTransionOutComplete);
			}			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onTransionOutComplete --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onTransionOutComplete():void {
			if(contains(_thumbnail)) removeChild(_thumbnail);
			if(contains(_title)) removeChild(_title);
			if(contains(_description)) removeChild(_description);
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setCurrentPage --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setCurrentPage(label:int):void {
			_curPage = label;		
			
			var delay:Number;
			if(_isOpen) delay = _transitonDuration;
			else delay = 1;			
			TweenMax.killDelayedCallsTo(populateData);
			TweenMax.delayedCall(delay, populateData, [_pages[_curPage]]);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// populateData ---------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function populateData(info:PageInfo):void {
			visible = true;
			_isOpen = true;
			
			var isAbout:Boolean = (info.slug == 'about');
			
			if(!contains(_thumbnail)) addChild(_thumbnail);
			_thumbnail._bitmap.bitmapData = _thumbnail._bitmapData.clone();
			TweenMax.killTweensOf(_thumbnail);
			_thumbnail.alpha = 0;
			_thumbnail.x = _imgX + (_thumbnail.width - _thumbnail.width*0.8)*0.5;
			_thumbnail.y = _imgY + (_thumbnail.height - _thumbnail.height*0.8)*0.5			
			_thumbnail.scaleX = 0.8;
			_thumbnail.scaleY = 0.8;
			TweenMax.to(_thumbnail, 0.3, {x:_imgX, y:_imgY, scaleX:1, scaleY:1, alpha:1, ease:Sine.easeOut});
			
			if(!contains(_title)) addChild(_title);
			_title.text = info.textTitle.toUpperCase();
			TweenMax.killTweensOf(_title);
			_title.alpha = 0;
			_title.x = _titleX + 40;
			_title.y = _titleY;
			TweenMax.to(_title, 0.3, {x:_titleX, alpha:1, ease:Sine.easeOut});
			
			if(!contains(_description)) addChild(_description);
			_description.htmlText = info.content;			
			TweenMax.killTweensOf(_description);
			_description.alpha = 0;
			_description.x = _descriptionX + 40;
			_description.y = _descriptionY;
			TweenMax.to(_description, 0.3, {x:_descriptionX, alpha:1, ease:Sine.easeOut, delay: 0.1});
			
			var tinbobY:int;
			if(!contains(_tinbob) && isAbout) addChild(_tinbob);			
			TweenMax.killTweensOf(_tinbob);
			_tinbob.alpha = 0;
			_tinbob.x = _tinbobX;
			tinbobY = _description.y +_description.height - 60;
			_tinbob.y = tinbobY + 60;;
			TweenMax.to(_tinbob, 0.3, {y:tinbobY, alpha:1, ease:Sine.easeOut, delay: 0.1});		
			
			if(!contains(_contact) && isAbout) addChild(_contact);
			_contact.htmlText = info.contacts;			
			TweenMax.killTweensOf(_contact);
			_contact.alpha = 0;
			_contact.x = _contactX + 40;
			_contact.y = tinbobY + 10;
			TweenMax.to(_contact, 0.3, {x:_contactX, alpha:1, ease:Sine.easeOut, delay: 0.1});
			
			if(!contains(_logo) && isAbout) addChild(_logo);			
			TweenMax.killTweensOf(_logo);
			_logo.alpha = 0;
			_logo.x = _contactX + 40;
			tinbobY = _description.y +_description.height - 60;
			_logo.y = tinbobY + 10;
			TweenMax.to(_logo, 0.3, {x:_contactX, alpha:1, ease:Sine.easeOut, delay: 0.1});		
			
			
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onLogosLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onLogosLoaded(logos:Vector.<BitmapData>):void {
			_tinbobBitmap.bitmapData = logos[1];
			_tinbobBitmap.y = - _tinbobBitmap.bitmapData.height;
			_tinbobBitmap.x = - int(_tinbobBitmap.bitmapData.width*0.5);
			
			
			_logoBitmap.bitmapData = logos[2];
			_logoBitmap.y = - int(_logoBitmap.bitmapData.height*0.5);
			_logoBitmap.x = - _logoBitmap.bitmapData.width;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPagesLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPagesLoaded(pages:Vector.<PageInfo>):void {
			_pages = pages;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPageThumbnailLoaded ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPageThumbnailLoaded(label:int, bitmapData:BitmapData):void {
			if(_curPage == label) _thumbnail.setBitmapData(bitmapData);
		}
		/////////////////////////////////////////////////////////////////
		// onVideoOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoOpened(id:String):void {
			
		}
		/////////////////////////////////////////////////////////////////
		// onVideoClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoClosed():void {
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailClick --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailClick():void{
			videoOpened.dispatch(_pages[_curPage].videoURL);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function resize (width:int, height:int):void	{
			this.x = int(width*0.5);
			this.y = int(height*0.5);
			if(width<1500) x+= int((1500 - width)/5);
		}		
	}
}