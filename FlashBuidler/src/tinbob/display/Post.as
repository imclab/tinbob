package tinbob.display
{

	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.ImageInfo;
	import tinbob.data.PostInfo;

	public class Post extends Sprite
	{
		public var videoOpened:Signal;
		public var galleryOpened:Signal;
		public var galleryImageDisplayRequested:Signal;
		public var dataPopulated:Signal; // used to request the galleryThumbnails only after the data is pouplated
		
		private var _posts:Vector.<PostInfo>;
		
		private var _thumbnail:VideoThubmbnail;
		private var _galleryThumbnails:Vector.<GalleryThumbnail>;		
		private var _title:TextField;
		private var _description:TextField;
		private var _clientTitle:TextField;
		private var _client:TextField;
		private var _agencyTitle:TextField;
		private var _agency:TextField;
		private var _creditsTitle:TextField;
		private var _credits:TextField;
		
		public const _imgW:int = 417;
		public const _imgH:int = 234;
		
		public const _galleryThumbnailW:int = 84;
		public const _galleryThumbnailH:int = 84;
		public const _galleryThumbnailWSpacer:int = 27;
		public const _galleryThumbnailHSpacer:int = 27;
		
		public const _textW:int = _imgW;
		public const _infoW:int = _textW*0.5 - 30;
		
		public const _imgX:int = -_imgW - 30 - 2;
		public const _imgY:int = -_imgH;//*0.33333)*2;
		public const _galleryThumbnailX:int = _imgX;
		public const _galleryThumbnailY:int = _imgY + _imgH + _galleryThumbnailHSpacer;
		public const _titleX:int = _imgX + _imgW + 30;
		public const _titleY:int = _imgY - 15;		
		public const _descriptionX:int = _titleX;
		public const _descriptionY:int = _titleY + 52;
		public const _creditsX:int = _titleX + _infoW  + 30;
		
		public const _transitonDuration:Number = 0.3;
		
		private var _curInfo:PostInfo;
		private var _nextInfo:PostInfo;
		
		private var _curPost:int;		
		
		private var _isOpen:Boolean;
		
		private var _inTransition:Boolean;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Post() {
			videoOpened = new Signal(String);
			galleryOpened = new Signal();
			galleryImageDisplayRequested = new Signal(int);
			dataPopulated = new Signal(int);
			
			var titleTf:TextFormat = new TextFormat ();
			titleTf.font = ExternalFonts.ENVY_CODE;
			titleTf.underline = true;
			titleTf.size = 28;
			titleTf.color = 0xffffff;
			
			_thumbnail = new VideoThubmbnail(_imgW,_imgH);
			_thumbnail.click.add(onThumbnailClick);
			
			_galleryThumbnails = new Vector.<GalleryThumbnail>();
			
			_title = new TextField (); 
			_title.embedFonts = true;
			_title.width = _textW;
			_title.defaultTextFormat = titleTf;
			
			var subTitleTf:TextFormat = new TextFormat ();
			subTitleTf.font = ExternalFonts.ENVY_CODE;
			//subTitleTf.underline = true;
			subTitleTf.size = 14;
			subTitleTf.letterSpacing = 1;
			subTitleTf.color = 0xffffff;
			
			var bodyTf:TextFormat = new TextFormat ();
			bodyTf.font = ExternalFonts.BODY;
			bodyTf.size = 11;
			bodyTf.leading = 5;
			bodyTf.color = 0xdddddd;
			
			var creditsTf:TextFormat = new TextFormat ();
			creditsTf.font = ExternalFonts.BODY;
			creditsTf.size = 11;
			creditsTf.leading = -4;
			creditsTf.color = 0xdddddd;
			
			_description = new TextField (); 
			_description.embedFonts = false;
			_description.width = _textW;
			_description.multiline = true;
			_description.autoSize = TextFieldAutoSize.LEFT;
			_description.wordWrap = true;
			_description.defaultTextFormat = bodyTf;
			
			_clientTitle = new TextField (); 
			_clientTitle.embedFonts = true;
			_clientTitle.width = _textW;
			_clientTitle.defaultTextFormat = subTitleTf;
			_clientTitle.text = "CLIENT";
			
			_agencyTitle = new TextField (); 
			_agencyTitle.embedFonts = true;
			_agencyTitle.width = _textW;
			_agencyTitle.defaultTextFormat = subTitleTf;
			_agencyTitle.text = "AGENCY";
			
			_creditsTitle = new TextField (); 
			_creditsTitle.embedFonts = true;
			_creditsTitle.width = _textW;
			_creditsTitle.defaultTextFormat = subTitleTf;
			_creditsTitle.text = "CREDITS";
			
			_client = new TextField (); 
			_client.embedFonts = false;
			_client.width = _infoW;
			_client.multiline = true;
			_client.autoSize = TextFieldAutoSize.LEFT;
			_client.wordWrap = true;
			_client.defaultTextFormat = bodyTf;
			
			_agency = new TextField (); 
			_agency.embedFonts = false;
			_agency.width = _infoW;
			_agency.multiline = true;
			_agency.autoSize = TextFieldAutoSize.LEFT;
			_agency.wordWrap = true;
			_agency.defaultTextFormat = bodyTf;
			
			_credits = new TextField (); 
			_credits.embedFonts = false;
			_credits.width = _infoW;
			_credits.multiline = true;
			_credits.autoSize = TextFieldAutoSize.LEFT;
			_credits.wordWrap = true;
			_credits.defaultTextFormat = creditsTf;			
			
			_curPost = -1;
			_isOpen = false;
			
			_inTransition = false;
			
			transitionOut(true);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			videoOpened.removeAll();
			galleryOpened.removeAll();
			galleryImageDisplayRequested.removeAll();
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
								_description,
								_clientTitle,
								_agencyTitle,
								_creditsTitle,
								_client,
								_agency,
								_credits],0.2,{x:"-40", alpha:0, ease:Sine.easeIn},0.1,onTransionOutComplete);
				for (var galleryThumbnail_index:int = 0; galleryThumbnail_index < this._galleryThumbnails.length; galleryThumbnail_index++){
					TweenMax.to(_galleryThumbnails[galleryThumbnail_index], 0.1, {y:"20", alpha:0, ease:Sine.easeIn, delay:0.1});
				}
			}
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onTransionOutComplete --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onTransionOutComplete():void {
			if(contains(_thumbnail)) removeChild(_thumbnail);
			if(contains(_title)) removeChild(_title);
			if(contains(_description)) removeChild(_description);
			if(contains(_clientTitle)) removeChild(_clientTitle);
			if(contains(_agencyTitle)) removeChild(_agencyTitle);
			if(contains(_creditsTitle)) removeChild(_creditsTitle);
			if(contains(_client)) removeChild(_client);
			if(contains(_agency)) removeChild(_agency);
			if(contains(_credits)) removeChild(_credits);
			for (var galleryThumbnail_index:int = 0; galleryThumbnail_index < this._galleryThumbnails.length; galleryThumbnail_index++){
				_galleryThumbnails[galleryThumbnail_index].click.removeAll();
				if(contains(_galleryThumbnails[galleryThumbnail_index])) removeChild(_galleryThumbnails[galleryThumbnail_index]);
			}
			_galleryThumbnails = new Vector.<GalleryThumbnail>(); //clearing the vector
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setCurrentPost --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setCurrentPost(label:int):void {
			_curPost = label;			
			
			var delay:Number;
			if(_isOpen) delay = _transitonDuration;
			else delay = 1;			
			TweenMax.killDelayedCallsTo(populateData);
			TweenMax.delayedCall(delay, populateData, [_posts[_curPost]]);	
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// populateData ---------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function populateData(info:PostInfo):void {
			visible = true;
			_isOpen = true;
			
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
			_title.text = info.title.toUpperCase();
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
			TweenMax.to(_description, 0.3, {x:_descriptionX, alpha:0.8, ease:Sine.easeOut, delay: 0.1});
			
			if(!contains(_clientTitle)) addChild(_clientTitle);
			TweenMax.killTweensOf(_clientTitle);
			var _clientTitleY:int = _descriptionY+_description.height;
			_clientTitle.alpha = 0;
			_clientTitle.x = _titleX + 40;
			_clientTitle.y = _clientTitleY;
			TweenMax.to(_clientTitle, 0.3, {x:_titleX, alpha:1, ease:Sine.easeOut, delay: 0.1});
			
			if(!contains(_client)) addChild(_client);
			TweenMax.killTweensOf(_client);
			_client.text = info.client;
			var _clientY:int = _clientTitleY+20;
			_client.alpha = 0;
			_client.x = _titleX + 40;
			_client.y = _clientY;
			TweenMax.to(_client, 0.3, {x:_titleX, alpha:0.8, ease:Sine.easeOut, delay: 0.2});
			
			if(!contains(_agencyTitle)) addChild(_agencyTitle);
			TweenMax.killTweensOf(_agencyTitle);
			var _agencyTitleY:int = _clientTitleY + 40;
			_agencyTitle.alpha = 0;
			_agencyTitle.x = _titleX + 40;
			_agencyTitle.y = _agencyTitleY;
			TweenMax.to(_agencyTitle, 0.5, {x:_titleX, alpha:1, ease:Sine.easeOut, delay: 0.1});
			
			if(!contains(_agency)) addChild(_agency);
			TweenMax.killTweensOf(_agency);
			_agency.text = info.agency;
			var _agencyY:int = _agencyTitleY+20;
			_agency.alpha = 0;
			_agency.x = _titleX + 40;
			_agency.y = _agencyY;
			TweenMax.to(_agency, 0.5, {x:_titleX, alpha:0.8, ease:Sine.easeOut, delay: 0.2})
			
			if(info.credits != null && info.credits != ""){
				if(!contains(_creditsTitle)) addChild(_creditsTitle);
				TweenMax.killTweensOf(_creditsTitle);
				var _creditsTitleY:int = _clientTitleY;
				_creditsTitle.alpha = 0;
				_creditsTitle.x = _creditsX + 40;
				_creditsTitle.y = _clientTitleY;
				TweenMax.to(_creditsTitle, 0.5, {x:_creditsX, alpha:1, ease:Sine.easeOut, delay: 0.2});
				
				if(!contains(_credits)) addChild(_credits);
				TweenMax.killTweensOf(_credits);
				_credits.htmlText = info.credits;
				var _creditsY:int = _creditsTitleY+20;
				_credits.alpha = 0;
				_credits.x = _creditsX + 40;
				_credits.y = _creditsY;
				TweenMax.to(_credits, 0.5, {x:_creditsX, alpha:0.8, ease:Sine.easeOut, delay: 0.3})
			}
			else{
				TweenMax.killTweensOf(_creditsTitle);
				TweenMax.killTweensOf(_credits);
				if(contains(_creditsTitle))removeChild(_creditsTitle);
				if(contains(_credits))removeChild(_credits);
			}
			
			// we need to create all the GalleryThumbnails object here (as they were the only elements not created in the constructor)
			// we don't need to worry about the vecotr being empy as it MUST be cleared on transitionOut (or in the first time it will empty anyway)
			// we also don't need to car about killing the tween
			var row:uint = 0;
			var col:uint = 0;
			var maxCol:uint = 4;
			for (var galleryThumbnail_index:int = 0; galleryThumbnail_index < info.images.length; galleryThumbnail_index++){
				var galleryThumbnail:GalleryThumbnail = new GalleryThumbnail(info.images[galleryThumbnail_index].index, _galleryThumbnailW, _galleryThumbnailH);
				addChild(galleryThumbnail);
				galleryThumbnail.click.add(onGalleryThumbnailClick);
				galleryThumbnail.alpha = 0;
		
				galleryThumbnail.x = _galleryThumbnailX + (_galleryThumbnailW+_galleryThumbnailWSpacer)*col;
				galleryThumbnail.y = _galleryThumbnailY + (_galleryThumbnailH + _galleryThumbnailHSpacer) * row;
				TweenMax.to(galleryThumbnail, 0.3, {alpha:1,
													ease:Sine.easeOut,
													delay:galleryThumbnail_index*0.05});
				_galleryThumbnails.push(galleryThumbnail);
				col ++;
				if(col >= maxCol){
					row++;
					col = 0;
				}
			}
			dataPopulated.dispatch(_curPost);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostsLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostsLoaded(posts:Vector.<PostInfo>):void {
			_posts = posts;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailLoaded ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailLoaded(label:int, bitmapData:BitmapData):void {
			if(_curPost == label) _thumbnail.setBitmapData(bitmapData);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryThumbnailLoaded ---------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onGalleryThumbnailLoaded(label:int, image:ImageInfo):void {
			if(_curPost == label) _galleryThumbnails[image.index].setBitmapData(image.tmbBitmapData);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailClick --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailClick():void{
			videoOpened.dispatch(_posts[_curPost].videoURL);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryThumbnailClick ----------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onGalleryThumbnailClick(index:int):void{
			galleryOpened.dispatch();
			galleryImageDisplayRequested.dispatch(index);
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
		/////////////////////////////////////////////////////////////////
		// onGalleryOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryOpened():void {
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryClosed():void {
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