package react.back;

import react.ReactComponent.ReactFragment;
import react.ReactContext;
import react.ReactMacro.jsx;
import react.ReactType;

typedef BackButtonProps = {
	var register:(handler:Void->Bool)->Void;
	var unregister:(handler:Void->Bool)->Void;
}

typedef BackButtonProviderProps = {
	var value:BackButtonProps;
}

typedef BackButtonConsumerProps = {
	var children:BackButtonProps->ReactFragment;
}

class BackButtonContext {
	public static var Context(get, null):ReactContext<BackButtonProps>;
	public static var Provider(get, null):ReactTypeOf<BackButtonProviderProps>;
	public static var Consumer(get, null):ReactTypeOf<BackButtonConsumerProps>;

	public static function init() {
		var context = React.createContext();
		Consumer = context.Consumer;
		Provider = context.Provider;
	}

	public static function connect<TProps:{}>(Comp:ReactType):ReactType {
		return function(props:TProps) {
			return jsx(<Consumer>
				{value ->
					<Comp
						{...props}
						register={value.register}
						unregister={value.unregister}
					/>
				}
			</Consumer>);
		}
	}

	static function get_Context() {ensureReady(); return Context;}
	static function get_Provider() {ensureReady(); return Provider;}
	static function get_Consumer() {ensureReady(); return Consumer;}

	static function ensureReady() @:bypassAccessor {
		if (Context == null) {
			Context = React.createContext();
			Context.displayName = "BackButtonContext";
			Consumer = Context.Consumer;
			Provider = Context.Provider;
		}
	}
}
