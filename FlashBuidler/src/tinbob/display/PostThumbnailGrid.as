package tinbob.display
{
	import __AS3__.vec.Vector;
	
	import com.greensock.TweenMax;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.NavigationInfo;
	import tinbob.data.PostInfo;

	public class PostThumbnailGrid extends Sprite
	{
		public var rollOver:Signal;
		public var click:Signal;
		
		public var _thumbnails:Vector.<PostThumbnail>;
		private var _gridW:uint;
		private var _gridH:uint;
		private var _thumbnailW:uint;
		private var _thumbnailH:uint;
		
		private var _cols:uint = 4;
		private var _rows:uint;
		private var _thumbnailGutter:uint = 10;
		
		private var _w:int;
		private var _h:int;
		
		private var _inTransition:Boolean;
		
		public const MARGIN_H:uint = 240;
		public const MARGIN_V:uint = 50;

		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function PostThumbnailGrid()
		{
			rollOver = new Signal(NavigationInfo);
			click = new Signal(NavigationInfo);
			
			_thumbnails = new Vector.<PostThumbnail>();
			
			_inTransition = false;
			
			_thumbnailW = 0;
			_thumbnailH = 0;
			
			_w = 0;
			_h = 0;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup():void
		{
			if(_inTransition) transitionOut(true);
			this.visible = true;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void
		{
			rollOver.removeAll();
			click.removeAll();
		}

		/////////////////////////////////////////////////////////////////
		// transitionOut ------------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function transitionOut(imediate:Boolean = false, delay:Number = 0):void {
			TweenMax.killDelayedCallsTo(startTransitionOut);
			TweenMax.killDelayedCallsTo(endTransitionOut);
			
			_inTransition = true;
			
			if (imediate){
				for(var i:int = 0; i<_thumbnails.length; i++)
					_thumbnails[i].transitionOut(imediate);
				while(_thumbnails.length > 0)
					_thumbnails.pop();
				while(this.numChildren > 0)
					this.removeChildAt(0);
				this.visible = false;
				
				_inTransition = false;
			}
			else if(delay == 0){
				startTransitionOut();
			}
			else{
				TweenMax.delayedCall(delay,startTransitionOut);
			}
		}
		/////////////////////////////////////////////////////////////////
		// startTransitionOut -------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function startTransitionOut():void {
			TweenMax.delayedCall(1.,endTransitionOut);
			for(var i:int = 0; i<_thumbnails.length; i++)
				_thumbnails[i].transitionOut();
		}
		/////////////////////////////////////////////////////////////////
		// endTransitionOut -------------------------------------------
		/////////////////////////////////////////////////////////////////
		public function endTransitionOut():void {
			while(_thumbnails.length > 0)
				_thumbnails.pop();
			this.visible = false;
			_inTransition = false;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostsLoaded --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostsLoaded(posts:Vector.<PostInfo>):void {
			transitionOut(true);
			this.visible = true;
			
			var nPosts:uint = posts.length;
			_rows = Math.ceil(nPosts / _cols);
			var c:uint = 0;
			var r:uint = 0;
			for (var i:int = 0; i<nPosts; i++)
			{
				// set the cols and rows
				posts[i].col = c;
				posts[i].row = r;
				
				// set the hAlign
				if (c == 0)	posts[i].hAlign = 3; //L
				else if (c == _cols-1) posts[i].hAlign = 4; //R
				else posts[i].hAlign = 0; //C
	
				// set the vAlign
				if (r == 0) posts[i].vAlign = 1; //T
				else if (r == _rows-1) posts[i].vAlign = 2; //B
				else posts[i].vAlign = 0; //C
				
				var thumbnail:PostThumbnail = new PostThumbnail(posts[i]);
				
				thumbnail.rollOver.add(onThumbnailRollOver);
				thumbnail.click.add(onThumbnailClick);
				
				thumbnail.transitionIn();
				addChild(thumbnail);
				_thumbnails.push(thumbnail);
				
				if (i == 0) {
					_thumbnailW = thumbnail.medW;
					_thumbnailH = thumbnail.medH;
					_gridW = _cols*(_thumbnailW + _thumbnailGutter) - _thumbnailGutter;
					_gridH = _rows*(_thumbnailH + _thumbnailGutter) - _thumbnailGutter;
				}
				
				thumbnail.x = c*(_thumbnailW + _thumbnailGutter) - int(_gridW *0.5) + int(_thumbnailW * 0.5);
				thumbnail.y = r*(_thumbnailH + _thumbnailGutter) - int(_gridH *0.5) + int(_thumbnailH * 0.5);
			
			
				// row/col logic
				c++;
				if(c > (_cols-1)){
					c = 0;
					r++;
				} 
			}
			resize(_w,_h);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailRollOver --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailRollOver(navigationInfo:NavigationInfo):void {
			rollOver.dispatch(navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailClick --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onThumbnailClick(navigationInfo:NavigationInfo):void {
			click.dispatch(navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onNavigationChanged --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onNavigationChanged(navigationInfo:NavigationInfo):void
		{
			for each (var thumbnail:PostThumbnail in _thumbnails)thumbnail.onNavigationChanged(navigationInfo);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onPostSelected -------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onPostSelected(navigationInfo:NavigationInfo):void
		{
			for each (var thumbnail:PostThumbnail in _thumbnails)
				thumbnail.onPostSelected(navigationInfo);
		}

		/////////////////////////////////////////////////////////////////////////////////////
		// onThumbnailLoaded ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onThumbnailLoaded(label:int, bitmapData:BitmapData):void
		{
			for each (var thumbnail:PostThumbnail in _thumbnails)
			{
				if(thumbnail.label == label) thumbnail.onThumbnailLoaded(bitmapData);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onColorExtracted ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onColorExtracted(label:int, colors:Array):void
		{
			for each (var thumbnail:PostThumbnail in _thumbnails)
			{
				if(thumbnail.label == label) thumbnail.onThumbnailAnalized(colors);
			}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////				
		public function resize (width:int, height:int):void
		{
			
			_w = width;
			_h = height;
			x = int(_w*0.5);
			y = int(_h*0.5);
			
			var realViewW:Number = Number(_w) - Number(MARGIN_H)*2;
			var realViewH:Number= Number(_h) - Number(MARGIN_V)*2;
			
			var viewRatio:Number = realViewW/realViewH;
			var gridRatio:Number = Number(_gridW)/Number(_gridH);
			
			if(viewRatio<gridRatio)	scaleX = scaleY = realViewW / Number(_gridW);
			else scaleX = scaleY = realViewH / Number(_gridH);
			
			
			if(scaleX > 1) scaleX = scaleY = 1;
			else if (scaleX < 0.4) scaleX = scaleY = 0.4;
			
			/*_w = width;
			_h = height;
			x = int(_w*0.5);
			y = int(_h*0.5);
			
			if(_w<1500){
				x+= int((1500 - _w)/5);
			}
			
			var isLandscape:Boolean = (_w>_h);
			var d:uint;
			var D:uint;
			if(isLandscape)
			{
				d = _w;
				D = _gridW+MARGIN+MARGIN;
			}
			else
			{
				d = _h;
				D = _gridH+MARGIN+MARGIN;
			}
			
			if (d < D) scaleX = scaleY = d/D;*/
			//this.x = int (_w * 0.5 - (_thumbnails.length * _thumbnailW) * 0.5 + _thumbnailW * 0.5);
    		//
			//this.y = int (_h * 0.5);
		}
		
	}
}