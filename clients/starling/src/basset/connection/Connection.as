package basset.connection
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.setTimeout;

public class Connection extends EventDispatcher
{
	protected var socket:Socket;
	private var host:String;
	private var port:int;

	public function Connection(host:String, port:int)
	{
		this.host = host;
		this.port = port;

		init();
		connect();
	}

	public function dispose():void
	{
		socket.close();
		socket.removeEventListener(Event.CLOSE, reconnect);
		socket.removeEventListener(Event.CONNECT, connectHandler);
		socket.removeEventListener(IOErrorEvent.IO_ERROR, reconnect);
		socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, reconnect);
		socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}

	private function init():void
	{
		socket = new Socket();
		socket.addEventListener(Event.CLOSE, reconnect);
		socket.addEventListener(Event.CONNECT, connectHandler);
		socket.addEventListener(IOErrorEvent.IO_ERROR, reconnect);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, reconnect);
		socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}

	private function connect():void
	{
		trace("trying to connect to " + host + ":" + port);
		socket.connect(host, port);
	}

	private function reconnect(event:Event):void
	{
		trace("connection failed");
		setTimeout(connect, 5000);
	}

	private function connectHandler(event:Event):void
	{
		trace("connected");
	}

	private function socketDataHandler(event:ProgressEvent):void
	{
		var data:String = socket.readUTFBytes(socket.bytesAvailable);
		if(data == "refresh")
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.REFRESH));
		}
	}
}
}
