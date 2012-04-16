package tinbob.display
{
	public class NavButton extends ShapeButton
	{
		public var next:Boolean;
		private const MARGIN:Number = 10;
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function NavButton(next:Boolean = true, w:Number=60, h:Number=60)
		{
			this.next = next;
			super(w, h);
			
		}		
		/////////////////////////////////////////////////////////////////////////////////////
		// drawShape ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		override public function drawShape(color:uint):void
		{
			shape.graphics.clear();
			shape.graphics.beginFill(color);
			if(next){
				shape.graphics.moveTo(-w*0.5+MARGIN, -h*0.5+MARGIN);
				shape.graphics.lineTo(w*0.5-MARGIN, 0);
				shape.graphics.lineTo(-w*0.5+MARGIN, h*0.5-MARGIN);
				shape.graphics.lineTo(-w*0.5+MARGIN, -h*0.5+MARGIN);
			} else {
				shape.graphics.moveTo(w*0.5-MARGIN, -h*0.5+MARGIN);
				shape.graphics.lineTo(-w*0.5+MARGIN, 0);
				shape.graphics.lineTo(w*0.5-MARGIN, h*0.5-MARGIN);
				shape.graphics.lineTo(w*0.5-MARGIN, -h*0.5+MARGIN);
			}
			shape.graphics.endFill();
		}
	}
}