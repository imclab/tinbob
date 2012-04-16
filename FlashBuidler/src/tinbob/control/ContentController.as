package tinbob.control
{
	import __AS3__.vec.Vector;
	
	import com.adobe.serialization.json.JSON;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.INativeDispatcher;
	import org.osmf.utils.BinarySearch;
	
	import tinbob.data.ImageInfo;
	import tinbob.data.NavigationInfo;
	import tinbob.data.PageInfo;
	import tinbob.data.PostBackgroundInfo;
	import tinbob.data.PostInfo;
	
	import uk.co.soulwire.display.colour.ColourUtils;
	
	public class ContentController
	{
		private var _posts:Vector.<PostInfo>;
		private var _pages:Vector.<PageInfo>;		
		private var _sitemap:Vector.<NavigationInfo>;
		private var _logos:Vector.<BitmapData>;
		
		public var failed:Signal;	
		public var sitemapLoaded:Signal;
		public var logosLodaded:Signal;
		public var postsLoaded:Signal;
		public var pagesLoaded:Signal;			
		public var thumbnailLoaded:Signal;
		public var colorExtracted:Signal;		
		public var pageThumbnailLoaded:Signal;
		public var pageColorExtracted:Signal;
		public var galleryThumbnailLoaded:Signal;
		public var galleryImageLoaded:Signal;
		
		private var _mainContentLoadingQueue:LoaderMax;
		private var _thumbnailLoaders:Vector.<ImageLoader>;
		private var _pageThumbnailLoaders:Vector.<ImageLoader>;
		private var _galleryThumbnailLoaders:Vector.<ImageLoader>;
		
		private const MAX_IMG_PER_POST:int = 10;
		private const IMG_TMB_SUFIX:String = "-150x150";
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function ContentController()
		{
			_posts = new Vector.<PostInfo>();
			_pages = new Vector.<PageInfo>();
			_sitemap = new Vector.<NavigationInfo>();
			_logos = new Vector.<BitmapData>();
			
			
			
			failed = new Signal(String);
			sitemapLoaded = new Signal(Vector.<NavigationInfo>);
			logosLodaded = new Signal(Vector.<BitmapData>);
			postsLoaded = new Signal(Vector.<PostInfo>);
			pagesLoaded = new Signal(Vector.<PageInfo>);			
			thumbnailLoaded = new Signal(int, BitmapData);
			colorExtracted = new Signal(int, Array);
			pageThumbnailLoaded = new Signal(int, BitmapData);
			pageColorExtracted = new Signal(int, Array);
			// for now on decided that is better to dispach a whole ImageInfo in the loadedimages, instead of just the bimapdata.
			galleryThumbnailLoaded = new Signal(int, ImageInfo);
			galleryImageLoaded = new Signal(int, ImageInfo);
			
			_mainContentLoadingQueue = new LoaderMax({name:"_mainContentLoadingQueue"});
			_thumbnailLoaders = new Vector.<ImageLoader>();
			_pageThumbnailLoaders = new Vector.<ImageLoader>();
			_galleryThumbnailLoaders = new Vector.<ImageLoader>();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void
		{
			failed.removeAll();
			sitemapLoaded.removeAll();			
			postsLoaded.removeAll();
			pagesLoaded.removeAll();			
			thumbnailLoaded.removeAll();
			pageThumbnailLoaded.removeAll();
			colorExtracted.removeAll();
			pageColorExtracted.removeAll();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		// loadMainContent ------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function loadMainContent(domainPath:String):void {
			_mainContentLoadingQueue.empty(true,true);
			addMainContentLoadingQueueListeners();			
			_mainContentLoadingQueue.append( new DataLoader(domainPath+"api/get_recent_posts?" +
																		"include=" +
																			"title," +
																			"slug," +
																			"content," +
																			"custom_fields" +
																		"&custom_fields=" +
																			"thumbnail," +
																			"video," +
																			"image," +
																			"client," +
																			"agency," +
																			"credits," +
																			"img0," +
																			"img_d0," +
																			"img1," +
																			"img_d1," +
																			"img2," +
																			"img_d2," +
																			"img3," +
																			"img_d3," +
																			"img4," +
																			"img_d4," +
																			"img5," +
																			"img_d5," +
																			"img6," +
																			"img_d6," +
																			"img7," +
																			"img_d7," +
																			"img8," +
																			"img_d8," +
																			"img9," +
																			"img_d9" +
																		"&count=999&",
																		{noCache:true, name:"postsMap"}) );
			_mainContentLoadingQueue.append( new DataLoader(domainPath+"api/get_page_index?" +
																		"include=" +
																			"title," +
																			"slug," +
																			"content," +
																			"custom_fields" +
																		"&custom_fields=" +
																			"text_title," +
																			"thumbnail," +
																			"video," +
																			"contact" +
																		"&count=999&",
																		{noCache:true, name:"pagesMap"}) );
			_mainContentLoadingQueue.append( new ImageLoader(domainPath+"wp-content/themes/tinbob/img/logo-menu.png", {name:"logo-menu"}) );
			_mainContentLoadingQueue.append( new ImageLoader(domainPath+"wp-content/themes/tinbob/img/logo-about.jpg", {name:"logo-about"}) );
			_mainContentLoadingQueue.append( new ImageLoader(domainPath+"wp-content/themes/tinbob/img/logo-about-mask.jpg", {name:"logo-about-mask"}) );
			_mainContentLoadingQueue.append( new ImageLoader(domainPath+"wp-content/themes/tinbob/img/logo-contacts.png", {name:"logo-contacts"}) );
			_mainContentLoadingQueue.append( new ImageLoader(domainPath+"wp-content/themes/tinbob/img/logo-footer.png", {name:"logo-footer"}) );

			_mainContentLoadingQueue.load();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// addMainContentLoadingQueueListeners ----------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function addMainContentLoadingQueueListeners():void {
			_mainContentLoadingQueue.addEventListener(LoaderEvent.OPEN, onMainContentLoadingQueueOpen, false, 0, true);
			_mainContentLoadingQueue.addEventListener(LoaderEvent.ERROR, onMainContentLoadingQueueError, false, 0, true);
			_mainContentLoadingQueue.addEventListener(LoaderEvent.FAIL, onMainContentLoadingQueueError, false, 0, true);
			_mainContentLoadingQueue.addEventListener(LoaderEvent.IO_ERROR, onMainContentLoadingQueueError, false, 0, true);
			_mainContentLoadingQueue.addEventListener(LoaderEvent.SECURITY_ERROR, onMainContentLoadingQueueError, false, 0, true);
			_mainContentLoadingQueue.addEventListener(LoaderEvent.COMPLETE, onMainContentLoadingQueueComplete, false, 0, true);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeMainContentLoadingQueueListeners -----------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function removeMainContentLoadingQueueListeners():void {
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.INIT, onMainContentLoadingQueueOpen);
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.ERROR, onMainContentLoadingQueueError);
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.FAIL, onMainContentLoadingQueueError);
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.IO_ERROR, onMainContentLoadingQueueError);
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.SECURITY_ERROR, onMainContentLoadingQueueError);
			_mainContentLoadingQueue.removeEventListener(LoaderEvent.COMPLETE, onMainContentLoadingQueueComplete);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onMainContentLoadingQueueOpen --------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onMainContentLoadingQueueOpen(event:LoaderEvent):void {
			//trace("open: " + event.target);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onMainContentLoadingQueueError -------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onMainContentLoadingQueueError(event:LoaderEvent):void {
		 	//trace("error occured with " + event.target + ": " + event.text);
		 	failed.dispatch(event.text);

		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onMainContentLoadingQueueComplete ----------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onMainContentLoadingQueueComplete(event:LoaderEvent):void {

			if(_mainContentLoadingQueue.getContent("logo-menu").rawContent){
				var logoMenu:BitmapData;
				logoMenu = _mainContentLoadingQueue.getContent("logo-menu").rawContent.bitmapData.clone();
				_logos.push(logoMenu);
			} 
			else _logos.push(new BitmapData(10,10));
			
			if(_mainContentLoadingQueue.getContent("logo-about").rawContent && _mainContentLoadingQueue.getContent("logo-about-mask").rawContent){
				var bitmap:Bitmap = new Bitmap(_mainContentLoadingQueue.getContent("logo-about").rawContent.bitmapData);
				var logoAbout:BitmapData = new BitmapData(bitmap.width, bitmap.height);
				logoAbout.draw(bitmap);
	
				var logoAboutMask:BitmapData;
				logoAboutMask = _mainContentLoadingQueue.getContent("logo-about-mask").rawContent.bitmapData.clone();
							
				applyAlphaFromGray(logoAbout, logoAboutMask);
				_logos.push(logoAbout);
			}
			else _logos.push(new BitmapData(10,10));
				
			if(_mainContentLoadingQueue.getContent("logo-contacts").rawContent){
				var logoContacts:BitmapData;
				logoContacts = _mainContentLoadingQueue.getContent("logo-contacts").rawContent.bitmapData.clone();			
				_logos.push(logoContacts);
			}
			else _logos.push(new BitmapData(10,10));
			
			if(_mainContentLoadingQueue.getContent("logo-footer").rawContent){
				var logoFooter:BitmapData;
				logoFooter = _mainContentLoadingQueue.getContent("logo-footer").rawContent.bitmapData.clone();			
				_logos.push(logoFooter);
			}
			else _logos.push(new BitmapData(10,10));
			
			parseContent(_mainContentLoadingQueue.getContent("postsMap"),_mainContentLoadingQueue.getContent("pagesMap"));
			
			_mainContentLoadingQueue.empty(true,true);
			_mainContentLoadingQueue.dispose(true);
			removeMainContentLoadingQueueListeners();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostDataPopulated -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostDataPopulated(postLabel:int):void
		{
			requestGalleryThumbnails(postLabel);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailAnalized -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailAnalized(backgroundInfo:PostBackgroundInfo):void
		{
			_posts[backgroundInfo.label].colors = backgroundInfo.colors; 
			// dispatch the signal
			colorExtracted.dispatch(backgroundInfo.label, backgroundInfo.colors);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPageThumbnailAnalized -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPageThumbnailAnalized(backgroundInfo:PostBackgroundInfo):void
		{
			_pages[backgroundInfo.label].colors = backgroundInfo.colors; 
			// dispatch the signal
			pageColorExtracted.dispatch(backgroundInfo.label, backgroundInfo.colors);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailRequested -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailRequested(label:int):void
		{
			// if thubnail was already loaded, we dispatch the thumbnail loaded signal straigh away
			if(_posts[label].thumbnail.bitmapData != null)
			{
				// dispatch the signal
				thumbnailLoaded.dispatch(label, _posts[label].thumbnail.bitmapData);
				// dispatch the signal
				colorExtracted.dispatch(label, _posts[label].colors);
			}
			else
			{
				var loaderStatus:int = _thumbnailLoaders[label].status;
				switch(loaderStatus){
					case LoaderStatus.PAUSED:
						_thumbnailLoaders[label].resume();
						_thumbnailLoaders[label].prioritize();
						break;
					case LoaderStatus.LOADING:
						_thumbnailLoaders[label].prioritize();
						break;
					case LoaderStatus.READY:
						_thumbnailLoaders[label].load();
						break;
					case LoaderStatus.FAILED:
						_thumbnailLoaders[label].load();
						break;
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPageThumbnailRequested -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPageThumbnailRequested(label:int):void
		{
			// if thubnail was already loaded, we dispatch the thumbnail loaded signal straigh away
			if(_pages[label].thumbnail.bitmapData != null)
			{
				// dispatch the signal
				pageThumbnailLoaded.dispatch(label, _pages[label].thumbnail.bitmapData);
				// dispatch the signal
				pageColorExtracted.dispatch(label, _pages[label].colors);
				
			}
			else
			{	
				var loaderStatus:int = _pageThumbnailLoaders[label].status;
				switch(loaderStatus){
					case LoaderStatus.PAUSED:
						_pageThumbnailLoaders[label].resume();
						_pageThumbnailLoaders[label].prioritize();
						break;
					case LoaderStatus.LOADING:
						_pageThumbnailLoaders[label].prioritize();
						break;
					case LoaderStatus.READY:
						_pageThumbnailLoaders[label].load();
						break;
					case LoaderStatus.FAILED:
						_pageThumbnailLoaders[label].load();
						break;
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryThumbnailsRequested -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onGalleryThumbnailsRequested(label:int):void
		{
			// we don't care about any previous loading thumbnails, if we got to this point,
			// we just wanna clear anything and start loading from scrach.
			for(var loader_i:int = 0; loader_i<_galleryThumbnailLoaders.length ; loader_i++){
				_galleryThumbnailLoaders[0].removeEventListener(LoaderEvent.COMPLETE,onThumbnailLoadComplete);
				_galleryThumbnailLoaders[0].cancel();
				_galleryThumbnailLoaders[0].dispose(true);
				_galleryThumbnailLoaders[0].unload();
				_galleryThumbnailLoaders[0] = null;
				_galleryThumbnailLoaders.shift();				
			}
			
			// loop through all thumbnails in the post and the ones that were already loaded
			// if thumbnail was already loaded, we dispatch the thumbnail loaded signals straigh away
			for(var img_i:int = 0; img_i < _posts[label].images.length; img_i++){
				if(_posts[label].images[img_i].tmbBitmapData != null)
				{
					// dispatch the signal
					galleryThumbnailLoaded.dispatch(label, _posts[label].images[img_i]);
				}
				else{
					// if the thumbnail was not loaded we are going to put it in the loading vecotr and start loading
					var imgLoader:ImageLoader = new ImageLoader(_posts[label].images[img_i].URL,{name:label+"_"+img_i, noCache:false, alternateURL:_posts[label].images[img_i].URL});
					imgLoader.autoDispose = true;
					imgLoader.addEventListener(LoaderEvent.COMPLETE, onGalleryThumbnailLoadComplete, false, 0, true);
					imgLoader.load(true);
					_galleryThumbnailLoaders.push(imgLoader);
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryImageRequested -------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onGalleryImageRequested(label:int, imgIndex:int):void
		{
			// check if image was already loaded
			if(_posts[label].images[imgIndex].bitmapData != null)
			{
				// dispatch the signal
				galleryImageLoaded.dispatch(label, _posts[label].images[imgIndex]);
			}
			else{
				//if not, then we load the image
				var imgLoader:ImageLoader = new ImageLoader(_posts[label].images[imgIndex].URL,{name:label+"_"+imgIndex, noCache:false, alternateURL:_posts[label].images[imgIndex].URL});
				imgLoader.autoDispose = true;
				imgLoader.addEventListener(LoaderEvent.COMPLETE, onGalleryImageLoadComplete, false, 0, true);
				imgLoader.load(true);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailLoadError --------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailLoadError(event:LoaderEvent):void {

		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailLoadComplete --------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailLoadComplete(event:LoaderEvent):void {
			var postLabel:int = event.target.vars.name;
			// store the bitmapdata in the posts vector
			_posts[postLabel].thumbnail.bitmapData = event.currentTarget.content.rawContent.bitmapData.clone();
			// Clear the loader completly and remove it from the loading queue
			ImageLoader(event.target).removeEventListener(LoaderEvent.COMPLETE,onThumbnailLoadComplete);
			ImageLoader(event.target).unload();
			// dispatch the thumbnailLoaded signal
			thumbnailLoaded.dispatch(postLabel, _posts[postLabel].thumbnail.bitmapData );
			// extract the colors from the thumbnails
			_posts[postLabel].colors = extractColors(_posts[postLabel].thumbnail.bitmapData);
			// dispatch the colors extracted signal
			colorExtracted.dispatch(postLabel, _posts[postLabel].colors);
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPageThumbnailLoadComplete --------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onPageThumbnailLoadComplete(event:LoaderEvent):void {
			var pageLabel:int = event.target.vars.name;
			// store the bitmapdata in the posts vector
			_pages[pageLabel].thumbnail.bitmapData = event.currentTarget.content.rawContent.bitmapData.clone();
			// Clear the loader completly and remove it from the loading queue
			ImageLoader(event.target).removeEventListener(LoaderEvent.COMPLETE,onThumbnailLoadComplete);
			ImageLoader(event.target).unload();
			// dispatch the thumbnailLoaded signal
			pageThumbnailLoaded.dispatch(pageLabel, _pages[pageLabel].thumbnail.bitmapData );
			// extract the colors from the thumbnails
			_pages[pageLabel].colors = [0xC19570, 0xB4CCBA, 0xB4CCBA, 0x6E8F89,0xC19570,0xC19570,0xC19570, 0x93A495,0xC19570, 0xB4CCBA, 0xB4CCBA, 0x6E8F89, 0x93A495,0xC19570, 0xB4CCBA, 0xB4CCBA, 0x6E8F89, 0x93A495];
			// dispatch the colors extracted signal
			pageColorExtracted.dispatch(pageLabel, _pages[pageLabel].colors);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryThumbnailLoadComplete --------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onGalleryThumbnailLoadComplete(event:LoaderEvent):void {
			var fullName:String = event.target.vars.name;
			var separatorPos:int = fullName.lastIndexOf("_",(fullName.length));
			var postLabel:int = int(fullName.substring(0,separatorPos));
			var imgIndex:int = int(fullName.substring(separatorPos+1,fullName.length));
			
			// store the gallery thumbnail bitmapdata in the posts vector
			_posts[postLabel].images[imgIndex].tmbBitmapData = event.currentTarget.content.rawContent.bitmapData.clone();
			// Clear the loader completly and remove it from the loading queue
			ImageLoader(event.target).removeEventListener(LoaderEvent.COMPLETE,onThumbnailLoadComplete);
			ImageLoader(event.target).unload();
			// dispatch the galleryThumbnailLoaded signal
			galleryThumbnailLoaded.dispatch(postLabel, _posts[postLabel].images[imgIndex]);			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onGalleryImageLoadComplete --------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onGalleryImageLoadComplete(event:LoaderEvent):void {
			var fullName:String = event.target.vars.name;
			var separatorPos:int = fullName.lastIndexOf("_",(fullName.length));
			var postLabel:int = int(fullName.substring(0,separatorPos));
			var imgIndex:int = int(fullName.substring(separatorPos+1,fullName.length));
			
			// store the gallery thumbnail bitmapdata in the posts vector
			_posts[postLabel].images[imgIndex].bitmapData = event.currentTarget.content.rawContent.bitmapData.clone();
			// Clear the loader completly and remove it from the loading queue
			ImageLoader(event.target).removeEventListener(LoaderEvent.COMPLETE,onThumbnailLoadComplete);
			ImageLoader(event.target).unload();
			// dispatch the galleryThumbnailLoaded signal
			galleryImageLoaded.dispatch(postLabel, _posts[postLabel].images[imgIndex]);			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		// parseContent ---------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function parseContent(rawPostsMap:String, rawPagesMap:String):void
		{
			var postsMap:Array = JSON.decode("["+rawPostsMap+"]");
			var pagesMap:Array = JSON.decode("["+rawPagesMap+"]");
			
			// Check if the map is well formed and is not missing any propertie.
			var isPostsMapHealthy:Boolean = true;
			var isPagesMapHealthy:Boolean = true;
			// Validade posts
			if(postsMap && postsMap[0] && postsMap[0].hasOwnProperty("posts"))
			{
				for(var post_index:int; post_index<postsMap[0].posts.length; post_index++){
					if(	postsMap[0].posts[post_index].hasOwnProperty("slug") &&
						postsMap[0].posts[post_index].hasOwnProperty("title") &&
						postsMap[0].posts[post_index].hasOwnProperty("content") &&
						postsMap[0].posts[post_index].hasOwnProperty("custom_fields"))
					{
						if(	postsMap[0].posts[post_index].custom_fields.hasOwnProperty("thumbnail") &&
							postsMap[0].posts[post_index].custom_fields.hasOwnProperty("client") &&
							postsMap[0].posts[post_index].custom_fields.hasOwnProperty("agency") &&
							postsMap[0].posts[post_index].custom_fields.hasOwnProperty("video"))
						{
							isPostsMapHealthy = true;
						}
						else
						{
							isPostsMapHealthy = false;
							break;
						}
					}
					else
					{
						isPostsMapHealthy = false;
						break;
					}				
				}	
			} else isPostsMapHealthy = false;
			// Validade pages
			if(pagesMap && pagesMap[0] && pagesMap[0].hasOwnProperty("pages"))
			{
				for(var page_index:int; page_index<pagesMap[0].pages.length; page_index++){
					if(	pagesMap[0].pages[page_index].hasOwnProperty("slug") &&
						pagesMap[0].pages[page_index].hasOwnProperty("title") &&
						pagesMap[0].pages[page_index].hasOwnProperty("content") &&
						pagesMap[0].pages[page_index].hasOwnProperty("custom_fields"))
					{
						if(	pagesMap[0].pages[page_index].custom_fields.hasOwnProperty("thumbnail") &&
							pagesMap[0].pages[page_index].custom_fields.hasOwnProperty("video") &&
							pagesMap[0].pages[page_index].custom_fields.hasOwnProperty("contact") &&
							pagesMap[0].pages[page_index].custom_fields.hasOwnProperty("text_title"))
						{
							isPagesMapHealthy = true;
						}
						else
						{
							isPagesMapHealthy = false;
							break;
						}
					}
					else
					{
						isPagesMapHealthy = false;
						break;
					}				
				}	
			} else isPagesMapHealthy = false;
			
			// If they are healthy...
			if(isPostsMapHealthy && isPagesMapHealthy)
			{
				// Populate posts				
				for(var post_i:int; post_i<postsMap[0].posts.length; post_i++){
					// Create the thumbnail object
					var thumbnail:ImageInfo = new ImageInfo();
					thumbnail.URL = postsMap[0].posts[post_i].custom_fields.thumbnail[0];
					
					// Cretate the image vector, and populate it if the post has images
					var images:Vector.<ImageInfo> = new Vector.<ImageInfo>();
					// So, first loop through a MAX_IMG_PER_POST times, looking for "imgX" and "img_dX" in the "custom_fields"
					var imgIndex:int = 0;
					for(var img_i:int = 0; img_i<MAX_IMG_PER_POST; img_i++){
						var imgPropName:String = "img"+img_i;
						if (postsMap[0].posts[post_i].custom_fields.hasOwnProperty(imgPropName))
						{
							var image:ImageInfo = new ImageInfo();
							image.URL = postsMap[0].posts[post_i].custom_fields[imgPropName];
							// get the thumbnail url, byt appending IMG_TMB_SUFIX to the end of the image URL
							var tmbPos:int = image.URL.lastIndexOf(".",(image.URL.length));
							var tmbURLPre:String = image.URL.substring(0,tmbPos);
							var tmbURLSufix:String = image.URL.substring(tmbPos,image.URL.length);
							image.tmbURL = tmbURLPre + this.IMG_TMB_SUFIX + tmbURLSufix;
							// if there is URL than check is there is a description
							var imgDescriptionPropName:String = "img_d"+img_i;
							if (postsMap[0].posts[post_i].custom_fields.hasOwnProperty(imgDescriptionPropName)){
								image.description = postsMap[0].posts[post_i].custom_fields[imgDescriptionPropName];
							}
							else image.description = "";
							image.index = imgIndex;
							images.push(image);
							imgIndex++;
						}
						
					}
					// Create a temp credits
					var credits:String = "";
					if (postsMap[0].posts[post_i].custom_fields.hasOwnProperty("credits")){
						credits = postsMap[0].posts[post_i].custom_fields.credits[0];
					}
					// Finally add the post (and store its label)				
					var postLabel:int = addPost(postsMap[0].posts[post_i].slug,
												postsMap[0].posts[post_i].title,
												postsMap[0].posts[post_i].custom_fields.client[0],
												postsMap[0].posts[post_i].custom_fields.agency[0],
												credits,
												postsMap[0].posts[post_i].content,
												thumbnail,
												postsMap[0].posts[post_i].custom_fields.video[0],
												images
												)
					// Also add the post to the sitemap
					var post:NavigationInfo = new NavigationInfo();
					post.isPost = true;
					post.title = postsMap[0].posts[post_i].title;
					post.label = postLabel;
					post.slug = postsMap[0].posts[post_i].slug;
					_sitemap.push(post);
				}
				
				// Populate pages				
				for(var page_i:int; page_i<pagesMap[0].pages.length; page_i++){
					// Create the thumbnail object
					var pageThumbnail:ImageInfo = new ImageInfo();
					pageThumbnail.URL = pagesMap[0].pages[page_i].custom_fields.thumbnail[0];
					// Finally add the page	(and store its label)				
					var pageLabel:int = addPage(pagesMap[0].pages[page_i].slug,
												pagesMap[0].pages[page_i].title,
												pagesMap[0].pages[page_i].content,
												pageThumbnail,
												pagesMap[0].pages[page_i].custom_fields.video[0],
												pagesMap[0].pages[page_i].custom_fields.contact[0],
												pagesMap[0].pages[page_i].custom_fields.text_title[0]
												)
					// Also add the page to the sitemap
					var page:NavigationInfo = new NavigationInfo();
					page.isPost = false;
					page.title = pagesMap[0].pages[page_i].title;
					page.label = pageLabel;
					page.slug = pagesMap[0].pages[page_i].slug;
					_sitemap.push(page);
				}
							
				prepareThumbnailLoader();
				preparePageThumbnailLoader();
				sitemapLoaded.dispatch(_sitemap);
			}
			else failed.dispatch("Content is malformed.");	
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// prepareThumbnailLoader -----------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function prepareThumbnailLoader():void{
			for(var i:int = 0; i< _posts.length; i++){
				var imgLoader:ImageLoader = new ImageLoader(_posts[i].thumbnail.URL,{name:i, noCache:false, alternateURL:_posts[i].thumbnail.URL});
				imgLoader.autoDispose = true;
				imgLoader.addEventListener(LoaderEvent.COMPLETE, onThumbnailLoadComplete, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.ERROR, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.FAIL, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.IO_ERROR, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.SECURITY_ERROR, onThumbnailLoadError, false, 0, true);
				
				_thumbnailLoaders.push(imgLoader);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// preparePageThumbnailLoader -----------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function preparePageThumbnailLoader():void{
			for(var i:int = 0; i< _pages.length; i++){
				var imgLoader:ImageLoader = new ImageLoader(_pages[i].thumbnail.URL,{name:i, noCache:false, alternateURL:_pages[i].thumbnail.URL});
				imgLoader.autoDispose = true;
				imgLoader.addEventListener(LoaderEvent.COMPLETE, onPageThumbnailLoadComplete, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.ERROR, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.FAIL, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.IO_ERROR, onThumbnailLoadError, false, 0, true);
				imgLoader.addEventListener(LoaderEvent.SECURITY_ERROR, onThumbnailLoadError, false, 0, true);
				
				_pageThumbnailLoaders.push(imgLoader);
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		// addPost --------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function addPost(	slug:String = null,
									title:String = null,
									client:String = null,
									agency:String = null,
									credits:String = null,
									content:String = null,
		 							thumbnail:ImageInfo = null,
		 							videoURL:String = null,
		 							images:Vector.<ImageInfo> = null	 						
		 							):int
		{
			var post:PostInfo = new PostInfo();
			post.slug = slug;
			post.title = title;
			post.client = client;
			post.agency = agency;
			post.credits = credits;
			post.content = content;
			post.thumbnail = thumbnail;
			post.videoURL = videoURL;
			post.images = images;
			post.label = _posts.length;
				
			
			_posts.push(post);			
			return post.label;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// addPage --------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function addPage(	slug:String = null,
									title:String = null,
									content:String = null,
									thumbnail:ImageInfo = null,
									videoURL:String = null,
									contacts:String = null,
									textTitle:String = null
									):int
		{
			var page:PageInfo = new PageInfo();
			page.slug = slug;
			page.title = title;
			page.content = content;
			page.thumbnail = thumbnail;
			page.videoURL = videoURL;
			page.contacts = contacts;
			page.textTitle = textTitle;
			page.label = _pages.length;		
			
				
			_pages.push(page);			
			return page.label;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		// distribuiteLogos -----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function distribuiteLogos():void{
			logosLodaded.dispatch(_logos);			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// distribuitePosts -----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function distribuitePosts():void{
			postsLoaded.dispatch(_posts);			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		// distribuitePages -----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function distribuitePages():void{
			pagesLoaded.dispatch(_pages);			
		}	
		/////////////////////////////////////////////////////////////////////////////////////
		// requestThumbnails -----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function requestThumbnails(label:int = -1):void{
			if(label == -1){
				for(var i:int = 0; i < _posts.length; i++) onThumbnailRequested(i);
			}
			else{
				for(var j:int = 0; j < _posts.length; j++){
					if(_posts[j].label == label) {
						onThumbnailRequested(label);
						return;
					}					
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// requestPageThumbnails ------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function requestPageThumbnails(label:int = -1):void{
			if(label == -1){
				for(var i:int = 0; i < _pages.length; i++) onPageThumbnailRequested(i);
			}
			else{
				for(var j:int = 0; j < _pages.length; j++){
					if(j == label){
						onPageThumbnailRequested(label);
						return;
					}
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// requestGalleryThumbnails ---------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function requestGalleryThumbnails(label:int = -1):void{
			if(label == -1){
				return;
			}
			else{
				for(var j:int = 0; j < _posts.length; j++){
					if(_posts[j].label == label) {
						onGalleryThumbnailsRequested(label);
						return;
					}					
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// applyAlphaFromGray --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		private function applyAlphaFromGray (destination:BitmapData, mask:BitmapData):void
		{
			destination.copyChannel(mask, new Rectangle(0,0,mask.width,mask.height), new Point(0,0),BitmapDataChannel.BLUE,BitmapDataChannel.ALPHA);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// extractColors --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		private function extractColors (bitmapData:BitmapData):Array
		{
			//reduce the bitmap data to a 64x64 square
			var s:Sprite = new Sprite();
			var bm:Bitmap = new Bitmap(bitmapData);
			bm.width = 128;
			bm.height = 128;
			s.addChild(bm);
			var bmd:BitmapData = new BitmapData(128,128);
			bmd.draw(s);
			// and extract the colors
			var tmp_colors:Array = ColourUtils.colourPalette(bmd,10,0.02);
			tmp_colors.sort(Array.NUMERIC);
			
			return tmp_colors;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// getPosts -------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function getPosts(label:int = -1):Vector.<PostInfo>
		{
			if (label == -1) return _posts;
			var posts:Vector.<PostInfo>;
			if (_posts[label] != null){
				posts.push(_posts[label]);
				return posts;
			}
			else return null;
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// getPages -------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function getPages(label:int = -1):Vector.<PageInfo>
		{
			if (label == -1) return _pages;
			var pages:Vector.<PageInfo>;
			if (_pages[label] != null){
				pages.push(_pages[label]);
				return pages;
			}
			else return null;
		}
		
	}
}