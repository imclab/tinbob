package tinbob.display
{
	import flash.display.Sprite;
	
	import tinbob.display.ExternalGraphics;

	public class Shape1 extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Shape1()
		{
			var shape:Sprite = new ExternalGraphics.SHAPE_1() as Sprite;
			addChild(shape);
			
			shape.rotation = Math.random()*360;
		}
		
	}
}