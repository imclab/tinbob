package tinbob.control
{
	import __AS3__.vec.Vector;
	
	import org.osflash.signals.Signal;

	public class SelectionController
	{
	
		public var labelSelected:Signal;
		public var labelDeselected:Signal;
		
		public var catSelected:Signal;
		public var catDeselected:Signal;
	
		private var _postsLabels:Vector.<int>;
		private var _postsCats:Vector.<int>;
		
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function SelectionController()
		{
			labelSelected = new Signal(int);
			labelDeselected = new Signal(int);
			
			catSelected = new Signal(int);
			catDeselected = new Signal(int);
			
			_postsLabels = new Vector.<int>();
			_postsCats = new Vector.<int>();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// addLabel -------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function addLabel(label:int):void
		{
			_postsLabels.push(label);			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// addCat ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function addCat(cat:int):void
		{
			_postsCats.push(cat);			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// selectLabel ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function selectLabel(label:int):void
		{
			if(doesLabelExists(label)){
				labelSelected.dispatch(label);
				for(var i:int = 0; i<_postsLabels.length; i++){
					if (_postsLabels[i] != label) labelDeselected.dispatch(_postsLabels[i]);
				}	
			}			
			else throw new Error("PostSelectionController.selectPost: passed label don't exist.");
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// selectCat ------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function selectCat(cat:int):void
		{
			if(doesCatExists(cat)){
				catSelected.dispatch(cat);
				for(var i:int = 0; i<_postsCats.length; i++){
					if (_postsCats[i] != cat) catDeselected.dispatch(_postsCats[i]);
				}	
			}			
			else throw new Error("PostSelectionController.selectCat: passed cat don't exist.");
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// deselectAllLabels ----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function deselectAllLabels():void
		{
			for(var i:int = 0; i<_postsLabels.length; i++) labelDeselected.dispatch(_postsLabels[i]);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// deselectAllCats -----------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function deselectAllCats():void
		{
			for(var i:int = 0; i<_postsCats.length; i++) catDeselected.dispatch(_postsCats[i]);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// doesLabelExists ------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function doesLabelExists(label:int):Boolean
		{
			for(var i:int = 0; i<_postsLabels.length; i++){
				if (_postsLabels[i] == label) return true;
			}
			return false;	
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// doesCatExists --------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function doesCatExists(cat:int):Boolean
		{
			for(var i:int = 0; i<_postsCats.length; i++){
				if (_postsCats[i] == cat) return true;
			}
			return false;	
		}
		
		
		
	}
}