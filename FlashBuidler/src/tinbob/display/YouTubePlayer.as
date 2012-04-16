package tinbob.display{
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLVariables;
  import flash.system.Security;
  import flash.text.TextField;
  
  import org.osflash.signals.Signal;


  public class YouTubePlayer extends Sprite {
    // Member variables.
	public var isReady:Boolean;
    public var player:Object;
    private var playerLoader:Loader;
    private var youtubeApiLoader:URLLoader;
	public var state:int;
	public var ready:Signal;
	public var destroyed:Signal;
	
	// gui
	private var seekbar:Seekbar;
	private var playButton:PlayButton;
	private var pauseButton:PauseButton;

    // CONSTANTS.
    private static const PLAYER_URL:String = "http://www.youtube.com/apiplayer?version=3";
    private static const SECURITY_DOMAIN:String = "http://www.youtube.com";
    private static const YOUTUBE_API_PREFIX:String = "http://gdata.youtube.com/feeds/api/videos/";
    private static const YOUTUBE_API_VERSION:String = "2";
    private static const YOUTUBE_API_FORMAT:String = "5";
    private static const STATE_ENDED:int = 0;
    private static const STATE_PLAYING:int = 1;
    private static const STATE_PAUSED:int = 2;
    private static const STATE_CUED:int = 5;

    public function YouTubePlayer():void {
		isReady = false;
		ready = new Signal();
		destroyed = new Signal();
    }

	public function setup():void {
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		Security.allowDomain(SECURITY_DOMAIN);	
		setupGui();
		setupPlayerLoader();
		setupYouTubeApiLoader();
	}
	
	public function setupGui():void {
		seekbar = new Seekbar(480,10, 0, 25);
		addChild(seekbar);
		
		playButton = new PlayButton(60,60);
		addChild(playButton);
		
		pauseButton = new PauseButton(60,60);
	}
	
    public function setupPlayerLoader():void {
      playerLoader = new Loader();
      playerLoader.contentLoaderInfo.addEventListener(Event.INIT, playerLoaderInitHandler);
      playerLoader.load(new URLRequest(PLAYER_URL));
    }

    private function playerLoaderInitHandler(event:Event):void {
		playerLoader.contentLoaderInfo.removeEventListener(Event.INIT, playerLoaderInitHandler);
      addChild(playerLoader);
      playerLoader.content.addEventListener("onReady", onPlayerReady);
      playerLoader.content.addEventListener("onError", onPlayerError);
      playerLoader.content.addEventListener("onStateChange", onPlayerStateChange);
      playerLoader.content.addEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
    }

	public function setupYouTubeApiLoader():void {
      youtubeApiLoader = new URLLoader();
      youtubeApiLoader.addEventListener(IOErrorEvent.IO_ERROR, youtubeApiLoaderErrorHandler);
      youtubeApiLoader.addEventListener(Event.COMPLETE, youtubeApiLoaderCompleteHandler);
    }

    private function youtubeApiLoaderCompleteHandler(event:Event):void {
      var atomData:String = youtubeApiLoader.data;

      // Parse the YouTube API XML response and get the value of the
      // aspectRatio element.
	  
      var atomXml:XML = new XML(atomData);
      var aspectRatios:XMLList = atomXml..*::aspectRatio;
    }

	public function loadDataApiById(id:String):void {
      var request:URLRequest = new URLRequest(YOUTUBE_API_PREFIX + id);

      var urlVariables:URLVariables = new URLVariables();
      urlVariables.v = YOUTUBE_API_VERSION;
      urlVariables.format = YOUTUBE_API_FORMAT;
      request.data = urlVariables;

      try {
        youtubeApiLoader.load(request);
      } catch (error:SecurityError) {
        //trace("A SecurityError occurred while loading", request.url);
      }
    }

    private function youtubeApiLoaderErrorHandler(event:IOErrorEvent):void {
      //trace("Error making YouTube API request:", event);
    }

    private function onPlayerReady(event:Event):void {
      player = playerLoader.content;
	  seekbar.hookPlayer(player);
	  
	  pauseButton.click.add(pauseVideo);
	  playButton.click.add(playVideo);
	  
	  
	  isReady = true;
      player.visible = true;
	  ready.dispatch();
    }
	
	

    private function onPlayerError(event:Event):void {
     // trace("Player error:", Object(event).data);
    }

    private function onPlayerStateChange(event:Event):void {
    // trace("State is", Object(event).data);
	  
	  state = Object(event).data;

      switch (Object(event).data) {
        case STATE_ENDED:
			player.seekTo(0);
			if(!contains(playButton))addChild(playButton);
			if(contains(pauseButton))removeChild(pauseButton)
          break;

        case STATE_PLAYING:
			if(!contains(pauseButton))addChild(pauseButton);
			if(contains(playButton))removeChild(playButton);
          break;

        case STATE_PAUSED:
			if(!contains(playButton))addChild(playButton);
			if(contains(pauseButton))removeChild(pauseButton);
          break;

        case STATE_CUED:
          	if(!contains(playButton))addChild(playButton);
		  	if(contains(pauseButton))removeChild(pauseButton)
          break;
      }
    }

    private function onVideoPlaybackQualityChange(event:Event):void {
     // trace("Current video quality:", Object(event).data);
    }
	
	private function playVideo():void {
		if(isReady)player.playVideo();
	}
	private function pauseVideo():void {
		if(isReady)player.pauseVideo();
	}
	
	public function resize(w:Number, h:Number):void {
		if(isReady)player.setSize(w,h);
		
		seekbar.x = 60;
		seekbar.y = h;		
		seekbar.resize(int(w-seekbar.x), 10);
		
		playButton.x = playButton.w*0.5;
		playButton.y = h+playButton.h*0.5;
		pauseButton.x = pauseButton.w*0.5;
		pauseButton.y = h+pauseButton.h*0.5;
	}
	
	public function destroy():void {
		while(this.numChildren>0)
		{
			this.removeChildAt(0);
		}
		
		playerLoader.contentLoaderInfo.removeEventListener(Event.INIT, playerLoaderInitHandler);
		playerLoader.content.removeEventListener("onReady", onPlayerReady);
		playerLoader.content.removeEventListener("onError", onPlayerError);
		playerLoader.content.removeEventListener("onStateChange", onPlayerStateChange);
		playerLoader.content.removeEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
		if(isReady)player.destroy();
		player = null;		
		seekbar.destroy();
		seekbar = null;
		
		playButton.click.removeAll();
		playButton = null;
		
		pauseButton.click.removeAll();
		pauseButton = null;
		
		isReady = false;
		
		destroyed.dispatch();
	}
  }
}