package plo.utils
{
	import flash.utils.ByteArray;

	public class ObjectUtils
	{
		public static function clone( source:Object ) :*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject( source );
			myBA.position = 0;
			return( myBA.readObject() );
		}
	}
}