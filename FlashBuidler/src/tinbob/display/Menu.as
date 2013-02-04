package tinbob.display
{

	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.NavigationInfo;
	import tinbob.data.PageInfo;
	import tinbob.data.PostInfo;

	public class Menu extends Sprite
	{
		public var rollOver:Signal;
		public var click:Signal;
		
		private var _logo:LogoMenu;
		private var _buttons:Vector.<Button>;
		private var _pageButtons:Vector.<Button>;
		
		private var _buttonsContainer:Sprite;
		
		private var curPost:int;
		private var curPage:int;
		
		private var _activeTimer:Timer;
		
		private var _isActive:Boolean;
		
		private static const buttonVSpace:int = 20;
		private static const buttonHOffset:int = -45;
		private static const pageButtonVOffset:int = -55;
		private var  buttonVOffset:int = pageButtonVOffset + 40;
		
		private static const activeLogoY:int = pageButtonVOffset - 20;
		
		private var isPagesLoaded:Boolean = false;
		private var isPostsLoaded:Boolean = false;
		private var loadedPages:Vector.<PageInfo>;
		private var loadedPosts:Vector.<PostInfo>;
		//private static const inactiveLogoY:int = activeLogoY;
		
		
		private var _inTransition:Boolean;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Menu() {
			rollOver = new Signal(NavigationInfo);
			click = new Signal(NavigationInfo);
			
			curPost = -1;
			curPage = -1;
			
			_inTransition = false;
			
			_logo = new LogoMenu();
			_logo.click.add(onButtonClick);
			_logo.x = 0;
			_logo.y = activeLogoY;
				
			_buttons = new Vector.<Button>();
			_pageButtons = new Vector.<Button>();
			_buttonsContainer = new Sprite();
			_buttonsContainer.visible = false;
			_buttonsContainer.alpha = 0;
			_buttonsContainer.x = buttonHOffset;
			
			_activeTimer = new Timer(400);
			
			_isActive = true;
			activate(false);
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			rollOver.removeAll();
			click.removeAll();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			if(_inTransition) transitionOut(true);
			if(!contains(_logo))addChild(_logo);
			if(!contains(_buttonsContainer))addChild(_buttonsContainer);
			_activeTimer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
			_activeTimer.start();
			this.mouseEnabled = true;
			this.mouseChildren  = true;			
			this.visible = true;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// activate ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function activate(value:Boolean):void
		{
			if(_isActive == value) return;
			if(value){
				_isActive = true;
				_logo.enable(true);
				//TweenMax.killTweensOf(_logo);	
				//TweenMax.to(_logo, 0.2, {y:activeLogoY, ease:Sine.easeOut});
				TweenMax.killTweensOf(_buttonsContainer);	
				TweenMax.to(_buttonsContainer, 0.2, {y:0, autoAlpha:1, ease:Sine.easeOut});
			}
			else
			{
				_isActive = false;
				_logo.enable(false);
				//TweenMax.killTweensOf(_logo);
				//TweenMax.to(_logo, 0.2, {y:inactiveLogoY, ease:Sine.easeOut});
				TweenMax.killTweensOf(_buttonsContainer);	
				TweenMax.to(_buttonsContainer, 0.2, {y:-20, autoAlpha:0, ease:Sine.easeOut});
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// isFocus ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function isFocus():Boolean
		{
			return (mouseX < 105);
		}
		
		/////////////////////////////////////////////////////////////////
		// transitionOut --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
			_inTransition = true;
			if(contains(_logo))removeChild(_logo);
			_activeTimer.reset();
			_activeTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setCurrentPost --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setCurrentPost(label:int):void {
			curPost = label;
			for each (var button:Button in _buttons)
			{
				if(button._navigationInfo.label == label) {
					button.open(true);					
				}
				else button.open(false);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setCurrentPage --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setCurrentPage(label:int):void {
			curPage = label;
			curPost = label;
			for each (var button:Button in _pageButtons)
			{
				if(button._navigationInfo.label == label) button.open(true);
				else button.open(false);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onTimerTick ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onTimerTick(e:TimerEvent):void
		{
			if(isFocus()) activate(true);
			else activate(false);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onLogosLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onLogosLoaded(logos:Vector.<BitmapData>):void {
			_logo.setBitmapData(logos[0]);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostsLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostsLoaded(posts:Vector.<PostInfo>):void {
			loadedPosts = posts;
			isPostsLoaded = true;
			if(isPagesLoaded && isPostsLoaded) onAllLoaded();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPagesLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPagesLoaded(pages:Vector.<PageInfo>):void {
			loadedPages = pages;
			isPagesLoaded = true;
			if(isPagesLoaded && isPostsLoaded) onAllLoaded();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onAllLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onAllLoaded():void {
			var nPages:uint = loadedPages.length;
			
			for (var i:int = 0; i<nPages; i++)
			{
				if(_pageButtons.length < i+1){
					var tempPostInfo:PostInfo = new PostInfo();
					tempPostInfo.label = loadedPages[i].label;
					tempPostInfo.title = loadedPages[i].title;
					tempPostInfo.slug = loadedPages[i].slug;
					var button:Button = new Button(tempPostInfo, false);
					button.y = pageButtonVOffset + buttonVSpace * i;
					button.rollOver.add(onButtonRollOver);
					button.click.add(onButtonClick);
					button.enable(true);
					_buttonsContainer.addChild(button);
					_pageButtons.push(button);
				}
			}
			
			var nPosts:uint = loadedPosts.length;
			buttonVOffset = pageButtonVOffset + _pageButtons.length * buttonVSpace + 20;
			for (var i:int = 0; i<nPosts; i++)
			{
				if(_buttons.length < i+1){
					var button:Button = new Button(loadedPosts[i], true);
					button.y = buttonVOffset + buttonVSpace * i;
					button.rollOver.add(onButtonRollOver);
					button.click.add(onButtonClick);
					button.enable(true);
					_buttonsContainer.addChild(button);
					_buttons.push(button);
				}
			}
			
			var linkButton:LinkButton = new LinkButton("http://testarea.tinbob.com", "Test Area");
			linkButton.y = buttonVOffset + buttonVSpace * nPosts + 20;
			linkButton.enable(true);
			_buttonsContainer.addChild(linkButton);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPageColorExtracted ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPageColorExtracted(label:int, colors:Array):void {
			/*for each (var button:Button in _pageButtons)
			{
				if(button._navigationInfo.label == label) button.enable(true);
			}*/
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onColorExtracted ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onColorExtracted(label:int, colors:Array):void {
			/*for each (var button:Button in _buttons)
			{
				if(button._navigationInfo.label == label) button.enable(true);
			}*/
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onButtonRollOver --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onButtonRollOver(navigationInfo:NavigationInfo):void {
			rollOver.dispatch(navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onButtonClick --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onButtonClick(navigationInfo:NavigationInfo):void {
			click.dispatch(navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostSelected -------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostSelected(navigationInfo:NavigationInfo):void	{
			for each (var button:Button in _buttons){
				button.onPostSelected(navigationInfo);
			}
				
			for each (var pageButton:Button in _pageButtons){
				pageButton.onPostSelected(navigationInfo);
			}
		}
		/////////////////////////////////////////////////////////////////
		// onVideoOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoOpened(id:String):void {

			_activeTimer.reset();
			_activeTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			this.mouseChildren  = false;
			this.mouseEnabled = false;
		}
		/////////////////////////////////////////////////////////////////
		// onVideoClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoClosed():void {
			setup();			
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryOpened():void {
			
			_activeTimer.reset();
			_activeTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			this.mouseChildren  = false;
			this.mouseEnabled = false;
		}
		/////////////////////////////////////////////////////////////////
		// onGalleryClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onGalleryClosed():void {
			setup();			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function resize (width:int, height:int):void	{
			this.x = int(width*0.08);
			this.y = int(height*0.5);
		}
	}
}