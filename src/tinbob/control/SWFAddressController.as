package tinbob.control
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	
	import org.osflash.signals.Signal;
	
	public class SWFAddressController
	{
		public var changed:Signal;
		
		private var validBranches:Array;
		private var validBranchesTitles:Array;
		private var embedBranch:String;		
		private var currentBranch:String;
		
		public const NOT_FOUND_BRANCH:String = "/404";
		public const ROOT_BRANCH:String = "/";
		
		private var firstChange:Boolean;		
		private var ready:Boolean;
		private var changedBeforeReady:Boolean;
		private var tempBranch:String;
		
		/////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------
		/////////////////////////////////////////////////////////////
		public function SWFAddressController()
		{
			changed = new Signal(String);
			
			firstChange = true;
			ready = false;
			changedBeforeReady = false;
			
			validBranches=[];
			validBranchesTitles=[];
			
			pushBranch(ROOT_BRANCH, "");
			
			// We first need to listen for the swf init, and then start listening for the change (otherwise it won't be available)
			SWFAddress.addEventListener(SWFAddressEvent.INIT, onSWFAddressInit, false,0,true);
		}
		/////////////////////////////////////////////////////////////
		// pushBranch -----------------------------------------------
		/////////////////////////////////////////////////////////////
		public function pushBranch(branch:String, title:String):void
		{
			validBranches.push(branch);
			validBranchesTitles.push(title);
		}
		/////////////////////////////////////////////////////////////
		// setEmbedBranch -------------------------------------------
		/////////////////////////////////////////////////////////////
		public function setEmbedBranch(branch:String):void
		{
			embedBranch = validateBranch(branch);
		}
		/////////////////////////////////////////////////////////////
		// flagAsReady ----------------------------------------------
		/////////////////////////////////////////////////////////////
		public function flagAsReady():void
		{
			ready = true;
			embedBranch = validateBranch(embedBranch);
			
			
			
			if(changedBeforeReady)processSWFAddressChange(tempBranch)
		}
		/////////////////////////////////////////////////////////////
		// goToBranch -----------------------------------------------
		/////////////////////////////////////////////////////////////
		public function goToBranch(branch:String):void
		{
			  SWFAddress.setValue(branch);
			  
			  var branchTitle:String = "";
			  for(var i:int = 0; i<validBranches.length; i++){
				  if(validBranches[i] == branch) branchTitle = validBranchesTitles[i];
			  }
			  if(branchTitle != "") branchTitle = " - "+branchTitle;
			  SWFAddress.setTitle("Tin Bob"+branchTitle);
		}	
		/////////////////////////////////////////////////////////////
		// validateBranch -------------------------------------------
		/////////////////////////////////////////////////////////////
		public function validateBranch(branch:String):String
		{
			var validBranch:String = NOT_FOUND_BRANCH;
			
			if(branch==null)branch="";
			if(branch.indexOf("/",branch.length-1)!=branch.length-1||branch.indexOf("/",branch.length-1)==-1)branch+="/";
			
			for(var i:int; i<validBranches.length; i++)
			{
				if(branch==validBranches[i])
				{
					validBranch = branch;
					break;
				}
			}
			return validBranch;
		}
		/////////////////////////////////////////////////////////////
		// onSWFAddressInit ----------------------------------------
		/////////////////////////////////////////////////////////////
		private function onSWFAddressInit(e:SWFAddressEvent):void
		{
			SWFAddress.removeEventListener(SWFAddressEvent.INIT, onSWFAddressInit);
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange, false,0,true);		
		}
		/////////////////////////////////////////////////////////////
		// onSWFAddressChange --------------------------------------
		/////////////////////////////////////////////////////////////
		private function onSWFAddressChange(e:SWFAddressEvent):void
		{
			processSWFAddressChange(e.value);		
		}
		/////////////////////////////////////////////////////////////
		// processSWFAddressChange ----------------------------------
		/////////////////////////////////////////////////////////////
		private function processSWFAddressChange(eventRawBranch:String):void
		{
			var eventBranch:String = validateBranch(eventRawBranch);
			
			if(!ready){
				changedBeforeReady = true;
				tempBranch = eventRawBranch;
			}
			else {
				if(firstChange)
				{
					firstChange=false;
					
					if(eventBranch==ROOT_BRANCH)currentBranch=embedBranch;
					else currentBranch=eventBranch;
				}
				else currentBranch = eventBranch;
				
				changed.dispatch(currentBranch);
				
				//Set
				//trace(validBranches);
			}			
		}

	}
}