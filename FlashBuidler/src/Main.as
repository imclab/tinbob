package
{
	import assets.PreloaderAnimation;
	
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	import com.greensock.events.LoaderEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	import tinbob.control.ContentController;
	import tinbob.control.NavigationController;
	import tinbob.data.NavigationInfo;
	import tinbob.display.Background;
	import tinbob.display.Footer;
	import tinbob.display.Gallery;
	import tinbob.display.Menu;
	import tinbob.display.Page;
	import tinbob.display.Player;
	import tinbob.display.Post;
	import tinbob.display.PostThumbnailGrid;
	
	[SWF(width="1200", height="700", backgroundColor="#000000", frameRate="30")]

	public class Main extends Sprite
	{
		private var _pre:PreloaderAnimation;
		private var _bg:Background;		
		private var _n:NavigationController;
		private var _c:ContentController;
		private var _t:PostThumbnailGrid;
		private var _m:Menu;
		private var _pl:Player;
		private var _gl:Gallery;
		private var _pt:Post;
		private var _pg:Page;
		private var _f:Footer;
		
		private var tracker:AnalyticsTracker;
		
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Main()
		{	
			tracker = new GATracker( this, "UA-6603360-7", "AS3", false ); 
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onAddedToStage -------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onAddedToStage (e:Event):void
		{	
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_bg = 						new Background(1920,1080);
			_c = 						new ContentController();
			_n = 						new NavigationController();
			
			_pre =						new PreloaderAnimation();
			
			addChild(_bg);
			_bg.onPostSelected(_bg.nullNavitationInfo);
			
			addChild(_pre);

			// Signals hooks
			_c.failed.addOnce			(onSitemapLoadingFailed);	
			_c.sitemapLoaded.addOnce	(onSitemapLoaded);
			_c.sitemapLoaded.addOnce	(_n.onSitemapLoaded);				
			_n.navigationChanged.add	(onNavigationChanged);
			
			// setup the embed branch
			_n.setup(this.loaderInfo.parameters.branch);
			// Load content
			_c.loadMainContent("http://tinbob.dev/");
			
			/// Stage rezize;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			stage.addEventListener(Event.RESIZE, onResize,false,0,true);
			onResize();
				
			
			// Keyboard interface
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);	
			
		}
		/*private function keyDownHandler ( e:KeyboardEvent ):void
		{
			//trace(e.charCode);
			switch (e.charCode)
			{
				case 49:
					_n.go(_n.home);
					break;
				case 50:
					
					break;
				case 51:
					
					break;
			}
		}*/
		//###################################################################################
		// onSitemapLoaded -----------------------------------------------------------
		//###################################################################################
		public function onSitemapLoaded (sitemap:Vector.<NavigationInfo>):void
		{
			removeChild(_pre);
			_pre = null;
		}
		//###################################################################################
		// onSitemapLoadingFailed -----------------------------------------------------------
		//###################################################################################
		public function onSitemapLoadingFailed (message:String):void
		{
			//trace(message);
		}
		//###################################################################################
		// onNavigationChanged -----------------------------------------------------------
		//###################################################################################
		public function onNavigationChanged (navigationInfo:NavigationInfo):void
		{
			// google analitycs
			var track:String;
			if(navigationInfo) track = navigationInfo.slug;
			if(track ==null)track = "";
			tracker.trackPageview("/"+navigationInfo.slug);
			
			// Clear all signal listeners...
			if(_bg) _bg.removeAllListeners();
			if(_c) _c.removeAllListeners();
			if(_n) _n.removeAllListeners();
			if(_t) _t.removeAllListeners();
			if(_m) _m.removeAllListeners();
			if(_pt) _pt.removeAllListeners();
			if(_pg) _pg.removeAllListeners();
			if(_pl) _pl.removeAllListeners();
			if(_gl) _gl.removeAllListeners();
			// but keep the main listening to navigation changed
			_n.navigationChanged.add (onNavigationChanged);
			
		
			if (navigationInfo == null || navigationInfo == _n.home){
				//trace("IS HOME");
				// clear the objects that will no be used
				if(_pt) _pt.transitionOut();
				if(_pg)	_pg.transitionOut();
				if(_pl) _pl.transitionOut(); 
				if(_gl) _gl.transitionOut(); 
				
				// Create (if needed) the objects that will be used
				if(!_t) _t = new PostThumbnailGrid();
				_t.setup();
				if(!_m) _m = new Menu();
				_m.setup();				
				if(!_f) _f = new Footer();
				_f.setup();
				// Add to display list (if needed) the objects tha will be used
				if(!contains(_t)) addChild(_t);
				if(!contains(_m)) addChild(_m);				
				if(!contains(_f)) addChild(_f);	
				
				onResize();
				
				// Signals hooks
				_bg.rollOver.add (_n.selectPost);
				
				_c.logosLodaded.add(_m.onLogosLoaded);				
				_c.logosLodaded.add(_f.onLogosLoaded);

				_c.postsLoaded.add(_bg.onPostsLoaded);
				_c.postsLoaded.add(_m.onPostsLoaded);
				_c.postsLoaded.add(_t.onPostsLoaded);

				_c.pagesLoaded.add(_bg.onPagesLoaded);
				_c.pagesLoaded.add(_m.onPagesLoaded);

				_c.thumbnailLoaded.add(_t.onThumbnailLoaded);

				_c.colorExtracted.add(_bg.onColorExtracted);

				_c.pageColorExtracted.add(_bg.onPageColorExtracted);
				_c.pageColorExtracted.add(_m.onPageColorExtracted);

				_n.postSelected.add(_bg.onPostSelected);
				_n.postSelected.add(_m.onPostSelected);
				_n.postSelected.add(_t.onPostSelected);

				_t.rollOver.add (_n.selectPost);
				_t.click.add (_n.go);
				
				_m.rollOver.add (_n.selectPost);
				_m.click.add (_n.go);
				
				// kick in action
				_c.distribuiteLogos();
				_c.distribuitePosts();
				_c.distribuitePages();
				_bg.disableColorize(false);
				_bg.onPostSelected(_bg.nullNavitationInfo); //simulate post was selected so we colorize the backgorund
				_bg.disableColorize(false);
				_m.setCurrentPage(-1);
				_m.setCurrentPost(-1);				
				_c.requestThumbnails();
				_c.requestPageThumbnails();				
			
			}
			else if(navigationInfo.isPost){
				//trace("IS POST");
				// clear the objects that will not be used
				if(_t) _t.transitionOut();
				if(_pg) _pg.transitionOut();
				
				// Create (if needed) the objects that will be used
				if(!_m) _m = new Menu();
				_m.setup();
				if(!_pt) _pt = new Post();
				_pt.setup();
				if(!_pl) _pl = new Player();
				_pl.setup();
				if(!_gl) _gl = new Gallery();
				_gl.setup();
				if(!_f) _f = new Footer();
				_f.setup();
				// Add to display list (if needed) the objects tha will be used
				if(!contains(_m)) addChild(_m);
				if(!contains(_pt)) addChild(_pt);
				if(!contains(_pl)) addChild(_pl);
				if(!contains(_gl)) addChild(_gl);
				if(!contains(_f)) addChild(_f);		
				this.setChildIndex(_pl, this.numChildren -1);
				this.setChildIndex(_gl, this.numChildren -1);
				onResize();
				
				// Signals hooks
				_bg.rollOver.add (_n.selectPost);
				
				_c.logosLodaded.add(_m.onLogosLoaded);
				_c.logosLodaded.add(_f.onLogosLoaded);
				
				_c.postsLoaded.add(_bg.onPostsLoaded);
				_c.postsLoaded.add(_m.onPostsLoaded);
				_c.postsLoaded.add(_pt.onPostsLoaded);
				_c.postsLoaded.add(_gl.onPostsLoaded);
				
				_c.pagesLoaded.add(_m.onPagesLoaded);
				
				_c.thumbnailLoaded.add(_pt.onThumbnailLoaded);
				
				_c.colorExtracted.add(_bg.onColorExtracted);
				
				_c.galleryThumbnailLoaded.add(_pt.onGalleryThumbnailLoaded);
				
				_c.galleryImageLoaded.add(_gl.onGalleryImageLoaded);
								
				_n.postSelected.add(_bg.onPostSelected);
				_n.postSelected.add(_m.onPostSelected);
				
				_m.rollOver.add (_n.selectPost);
				_m.click.add (_n.go);				
				
				_pt.videoOpened.add(_pl.onVideoOpened);
				_pt.videoOpened.add(_bg.onVideoOpened);
				_pt.videoOpened.add(_pt.onVideoOpened);
				_pt.videoOpened.add(_m.onVideoOpened);
				
				_pt.galleryOpened.add(_gl.onGalleryOpened);
				_pt.galleryOpened.add(_bg.onGalleryOpened);
				_pt.galleryOpened.add(_pt.onGalleryOpened);
				_pt.galleryOpened.add(_m.onGalleryOpened);
				
				_pt.dataPopulated.add(_c.onPostDataPopulated);
				
				_pt.galleryImageDisplayRequested.add(_gl.onGalleryImageDisplayRequested);
				
				_pl.videoClosed.add(_pl.onVideoClosed);
				_pl.videoClosed.add(_bg.onVideoClosed);
				_pl.videoClosed.add(_pt.onVideoClosed);
				_pl.videoClosed.add(_m.onVideoClosed);
				
				_gl.galleryClosed.add(_gl.onGalleryClosed);
				_gl.galleryClosed.add(_bg.onGalleryClosed);
				_gl.galleryClosed.add(_pt.onGalleryClosed);
				_gl.galleryClosed.add(_m.onGalleryClosed);
				
				_gl.galleryImageRequested.add(_c.onGalleryImageRequested);
								
				// kick in action
				_c.distribuiteLogos();
				_c.distribuitePosts();
				_c.distribuitePages();				
				_bg.disableColorize(false);
				_bg.onPostSelected(navigationInfo); //simulate post was selected so we colorize the backgorund
				_bg.disableColorize(true);				
				_m.setCurrentPage(-1);
				_m.setCurrentPost(navigationInfo.label);
				_pt.setCurrentPost(navigationInfo.label);
				_gl.setCurrentPost(navigationInfo.label);
				_c.requestThumbnails(navigationInfo.label);
				//_c.requestGalleryThumbnails(navigationInfo.label); // now is is being called inside _c itself, triggered by _pt.dataPopluated signal
				
			}
			else if (!navigationInfo.isPost){
				//trace("IS PAGE");
				// clear the objects that will not be used
				if(_t) _t.transitionOut();
				if(_pt) _pt.transitionOut();				
								
				// Create (if needed) the objects that will be used
				if(!_m) _m = new Menu();
				_m.setup();
				if(!_pg) _pg = new Page();
				_pg.setup();
				if(!_pl) _pl = new Player();
				_pl.setup();				
				if(!_f) _f = new Footer();
				_f.setup();
				// Add to display list (if needed) the objects tha will be used
				if(!contains(_m)) addChild(_m);
				if(!contains(_pg)) addChild(_pg);
				if(!contains(_pl)) addChild(_pl);
				if(!contains(_f)) addChild(_f);	
				this.setChildIndex(_pl, this.numChildren -1);
				onResize();
				
				// Signals hooks
				_bg.rollOver.add (_n.selectPost);
				
				_c.logosLodaded.add(_m.onLogosLoaded);
				_c.logosLodaded.add(_pg.onLogosLoaded);				
				_c.logosLodaded.add(_f.onLogosLoaded);
				
				_c.postsLoaded.add(_m.onPostsLoaded);								
				
				_c.pagesLoaded.add(_bg.onPagesLoaded);
				_c.pagesLoaded.add(_m.onPagesLoaded);
				_c.pagesLoaded.add(_pg.onPagesLoaded)
				
				_c.pageThumbnailLoaded.add(_pg.onPageThumbnailLoaded);
				
				_c.colorExtracted.add(_bg.onColorExtracted);
				
				_n.postSelected.add(_bg.onPostSelected);
				_n.postSelected.add(_m.onPostSelected);
				
				_m.rollOver.add (_n.selectPost);
				_m.click.add (_n.go);				
				
				_pg.videoOpened.add(_pl.onVideoOpened);
				_pg.videoOpened.add(_bg.onVideoOpened);
				_pg.videoOpened.add(_pg.onVideoOpened);
				_pg.videoOpened.add(_m.onVideoOpened);
				
				_pl.videoClosed.add(_pl.onVideoClosed);
				_pl.videoClosed.add(_bg.onVideoClosed);
				_pl.videoClosed.add(_pg.onVideoClosed);
				_pl.videoClosed.add(_m.onVideoClosed);
				
				// kick in action
				_c.distribuiteLogos();
				_c.distribuitePosts();
				_c.distribuitePages();				
				_bg.disableColorize(false);
				_bg.onPostSelected(navigationInfo); //simulate post was selected so we colorize the backgorund
				_bg.disableColorize(true);				
				_m.setCurrentPage(navigationInfo.label);
				_m.setCurrentPost(-1);
				_pg.setCurrentPage(navigationInfo.label);
				_c.requestPageThumbnails(navigationInfo.label);
			}
		}
		//###################################################################################
		// onResize -------------------------------------------------------------------------
		//###################################################################################
		public function onResize (e:Event = null):void
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			if(_pre) {
				_pre.x = int(w*0.5);
				_pre.y = int(h*0.5);
			}
			if(_bg) _bg.resize(w,h);
			if(_t) _t.resize(w,h);
			if(_m) _m.resize(w,h);
			if(_pt) _pt.resize(w,h);
			if(_pg) _pg.resize(w,h);
			if(_pl) _pl.resize(w,h);
			if(_gl) _gl.resize(w,h);
			if(_f) _f.resize(w,h);
		}
	}
}