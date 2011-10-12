package tinbob.display
{
	public class CloseButton extends ShapeButton
	{
		private const THICKNESS:Number = 5;
		private const MARGIN:Number = 8;
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function CloseButton(w:Number=60, h:Number=60)
		{
			super(w, h);
		}		
		/////////////////////////////////////////////////////////////////////////////////////
		// drawShape ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		override public function drawShape(color:uint):void
		{
			var cos45:Number = 0.525321989; // so we dont need to caclulate this
			var H_HOff:Number = (w*0.5)-MARGIN;
			var H_VOff:Number = h*0.5-MARGIN-(THICKNESS*cos45);
			var V_HOff:Number = w*0.5-MARGIN-(THICKNESS*cos45);
			var V_VOff:Number = (h*0.5)-MARGIN;
			shape.graphics.clear();
			shape.graphics.beginFill(color);
			shape.graphics.moveTo(-H_HOff, -H_VOff);
			shape.graphics.lineTo(V_HOff, V_VOff);
			shape.graphics.lineTo(H_HOff, H_VOff);
			shape.graphics.lineTo(-V_HOff, -V_VOff);
			shape.graphics.lineTo(-H_HOff, -H_VOff);
			shape.graphics.endFill();
			
			shape.graphics.beginFill(color);
			shape.graphics.moveTo(H_HOff, -H_VOff);
			shape.graphics.lineTo(-V_HOff, V_VOff);
			shape.graphics.lineTo(-H_HOff, H_VOff);
			shape.graphics.lineTo(V_HOff, -V_VOff);
			shape.graphics.lineTo(H_HOff, -H_VOff);
			shape.graphics.endFill();
		}
	}
}