package basset.connection
{
import flash.events.Event;

public class ConnectionEvent extends Event
{
	public static const REFRESH:String = "basset.connection.ConnectionEvent.REFRESH";

	public function ConnectionEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	override public function clone():Event
	{
		return new ConnectionEvent(type, bubbles, cancelable);
	}
}
}
