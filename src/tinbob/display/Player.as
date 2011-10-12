package tinbob.display
{

	import com.greensock.TweenMax;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import tinbob.display.YouTubePlayer;

	public class Player extends Sprite
	{
		public var videoClosed:Signal;
		
		public var yt:YouTubePlayer;
		
		private var _base:Sprite;
		
		private var _closeBtn:CloseButton;
		
		private var _id:String;
		private var _openedWhileLoading:Boolean;
		
		private var _w:int;
		private var _h:int;
		
		private static const vidW:int = 853;
		private static const vidH:int = 480;
		
		
		private var _inTransition:Boolean;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Player() {
			videoClosed = new Signal();
			videoClosed.add(onVideoClosed);
			
			
				
			_inTransition = false;
			_openedWhileLoading = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			videoClosed.removeAll();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			transitionOut(true);
			_id = null;
			_openedWhileLoading = false;
			
			_base = new Sprite();
			_base.graphics.beginFill(0x000000, 0.7);
			_base.graphics.drawRect(-100,-100,200,200);
			_base.graphics.endFill();
			
			_closeBtn = new CloseButton(35,35);
			_closeBtn.x = vidW*0.5 + _closeBtn.w*0.5;
			_closeBtn.y = -vidH*0.5 + _closeBtn.h*0.5;			
			
			yt = new YouTubePlayer();
			yt.ready.add(onPlayerReady);
			yt.setup();
			yt.x = -int(vidW*0.5);
			yt.y = -int(vidH*0.5);
			this.visible = true;
		}
		/////////////////////////////////////////////////////////////////
		// transitionOut --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false):void {
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
			if(yt){
				if(yt.isReady) {
					yt.player.destroy();
				}
				if(contains(yt))removeChild(yt);
				yt = null
			}
			if(_base) {
				if(contains(_base))removeChild(_base);
				_base = null;
			}
			if(_closeBtn) {
				if(contains(_closeBtn))removeChild(_closeBtn);
				_closeBtn = null;
			}
			
			_inTransition = false;
			this.visible = false;
		}
		/////////////////////////////////////////////////////////////////
		// loadVideo ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function loadVideo():void {
			yt.player.loadVideoById(_id, 0, "large");
		}
		/////////////////////////////////////////////////////////////////
		// onPlayerReady --------------------------------------------------
		/////////////////////////////////////////////////////////////////
		private function onPlayerReady ():void
		{
			yt.resize(vidW, vidH);
			if(_openedWhileLoading) {
				_openedWhileLoading = false;
				if(!contains(yt))addChild(yt);
				loadVideo();
				if(!contains(_closeBtn))addChild(_closeBtn);
				_closeBtn.click.add(onCloseClick);
			}
		}
		
		/////////////////////////////////////////////////////////////////
		// onVideoOpened ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoOpened(id:String):void {
			setup();
			_id = id;
			if(yt.isReady) {
				if(!contains(yt))addChild(yt);
				loadVideo();
				if(!contains(_closeBtn))addChild(_closeBtn);
				_closeBtn.click.add(onCloseClick);
			}
			else _openedWhileLoading = true;
			
			if(!contains(_base))addChild(_base);
			
			
			this.alpha = 0;
			TweenMax.to(this, 0.4,{alpha:1});
			
			resize(_w,_h);
			visible = true;
		}
		/////////////////////////////////////////////////////////////////
		// onCloseClick ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onCloseClick():void {
			videoClosed.dispatch();
		}
		/////////////////////////////////////////////////////////////////
		// onVideoClosed ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function onVideoClosed():void {
			transitionOut();
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
		}
	}
}