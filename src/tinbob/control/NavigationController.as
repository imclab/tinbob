package tinbob.control
{
	import __AS3__.vec.Vector;
	
	import org.osflash.signals.Signal;
	
	//import tinbob.data.CatInfo;
	import tinbob.data.NavigationInfo;
	
	public class NavigationController
	{
		public var navigationChanged:Signal;		
		public var postSelected:Signal;
				
		private var _sitemap:Vector.<NavigationInfo>;
		public  const home:NavigationInfo = new NavigationInfo ();
		
		
		private var _SWFAdressController:SWFAddressController;
		private var _lastBranch:String = "NOT_INITIALIZED";
		private var _embedBranch:String;
		
		
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function NavigationController()
		{
			navigationChanged = new Signal(NavigationInfo);
			postSelected = new Signal(NavigationInfo);
			
			_SWFAdressController = new SWFAddressController();
			
			home.isHome = true;
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// removeAllListeners ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function removeAllListeners():void {
			navigationChanged.removeAll();
			postSelected.removeAll();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setup ----------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setup(embedBranch:String = ""):void {
			_embedBranch = embedBranch;;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onSitemapLoaded --------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onSitemapLoaded(sitemap:Vector.<NavigationInfo>):void {
			_sitemap = sitemap;	
			for(var i:int; i<_sitemap.length; i++) _SWFAdressController.pushBranch("/"+_sitemap[i].slug+"/", _sitemap[i].title);	
			_SWFAdressController.setEmbedBranch(_embedBranch);
			_SWFAdressController.changed.add(onSWFAdressChanged)
			_SWFAdressController.flagAsReady();		
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// go -------------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function go(where:NavigationInfo):void {
			if (where == null) 				_SWFAdressController.goToBranch(_SWFAdressController.NOT_FOUND_BRANCH);
			else if (where.slug == null)	_SWFAdressController.goToBranch(_SWFAdressController.ROOT_BRANCH);
			else 						 	_SWFAdressController.goToBranch("/"+where.slug+"/");
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// selectPost -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function selectPost(post:NavigationInfo):void {
			postSelected.dispatch(post);
		}

		/////////////////////////////////////////////////////////////////////////////////////
		// onSWFAdressChanged ---------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function onSWFAdressChanged(branch:String):void {
		 	if(_lastBranch!=branch) {
				switch (branch)
		 		{
		 			case _SWFAdressController.NOT_FOUND_BRANCH:
		 				navigationChanged.dispatch(null);
		 				break;
		 			case _SWFAdressController.ROOT_BRANCH:
		 				navigationChanged.dispatch(home);
		 				break;
		 			default:
		 				navigationChanged.dispatch(getNavigationInfoByBranch(branch));
		 				break;
		 		}		 		
		 	}
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// getNavigationInfoByBranch --------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		private function getNavigationInfoByBranch(branch:String):NavigationInfo {
			for each ( var item:NavigationInfo in _sitemap)
		 	{
		 		if (item.slug == branch.substring(1,branch.length-1)) return item;
		 	}
		 	return  home;
		}
	}
}