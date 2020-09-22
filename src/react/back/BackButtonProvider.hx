package react.back;

import js.Browser;
import js.html.Event;

import eventtypes.SessionHistoryEventType;
import react.ReactComponent;
import react.ReactMacro.jsx;

#if react_router_4
import history.Action;
import history.Location;
import react.router.ReactRouter;
import react.router.Route.RouteRenderProps;

private typedef Props = {
	> PublicProps,
	> RouteRenderProps,
}

private typedef PublicProps = {
	var children:ReactFragment;
}
#else
private typedef Props = {
	var children:ReactFragment;
}
#end

private typedef Handler = Void->Bool;

private typedef State = {
	var handlers:Array<Handler>;
}

#if react_router_4
@:publicProps(PublicProps)
@:wrap(ReactRouter.withRouter)
#end
class BackButtonProvider extends ReactComponent<Props, State> {
	#if react_router_4
	static final PREVENT_BACK = '__PREVENT_BACK__';
	var unblock:Void->Void;
	#end

	public function new(props:Props) {
		super(props);

		state = {
			handlers: []
		};
	}

	override function render():ReactFragment {
		return jsx(
			<BackButtonContext.Provider value={{
				register: registerHandler,
				unregister: unregisterHandler
			}}>
				{props.children}
			</BackButtonContext.Provider>
		);
	}

	override function componentDidMount():Void {
		Browser.window.history.pushState(getState(), Browser.document.title, Browser.window.location.href);
		Browser.window.addEventListener(SessionHistoryEventType.PopState, onBack);

		#if react_router_4
		unblock = props.history.block(catcher);
		#end
	}

	#if react_router_4
	function catcher(l:Location, a:Action):String {
		if (a == Pop && abort()) return PREVENT_BACK;
		return null;
	}
	#end

	override function componentWillUnmount():Void {
		Browser.window.removeEventListener(SessionHistoryEventType.PopState, onBack);

		#if react_router_4
		if (unblock != null) unblock();
		#end
	}

	function abort():Bool {
		for (h in state.handlers) if (h()) return true;
		return false;
	}

	function onBack(_:Event):Void {
		if (abort() && !checkState(Browser.window.history.state)) {
			Browser.window.history.pushState(getState(), Browser.document.title, Browser.window.location.href);
		}
	}

	function getState():Dynamic return {__backbutton__: true};

	function checkState(s:Dynamic):Bool {
		if (!Reflect.hasField(s, "__backbutton__")) return false;
		return s.__backbutton;
	}

	function registerHandler(handler:Handler):Void {
		if (Lambda.has(state.handlers, handler)) return;
		return setState((state:State) -> {handlers: withHandler(state.handlers, handler)});
	}

	function unregisterHandler(handler:Handler):Void {
		if (!Lambda.has(state.handlers, handler)) return;
		return setState((state:State) -> {handlers: withoutHandler(state.handlers, handler)});
	}

	static function withHandler(handlers:Array<Handler>, handler:Handler):Array<Handler> {
		var ret = handlers.copy();
		ret.push(handler);
		return ret;
	}

	#if react_router_4
	public static function confirmLeave(msg:String, cb:Bool->Void):Void {
		if (msg == PREVENT_BACK) return cb(false);
		cb(Browser.window.confirm(msg));
	}
	#end

	static function withoutHandler(handlers:Array<Handler>, handler:Handler):Array<Handler> {
		return [for (h in handlers) {
			if (h == handler) continue;
			h;
		}];
	}
}
