package react.back;

import react.ReactComponent;

private typedef Props = {
	var handler:Void->Bool;
	@:optional var children:Empty;
}

@:context(BackButtonContext.Context)
class BackButtonHandler extends ReactComponent<Props> {
	override function render():ReactFragment return null;
	override function componentDidMount():Void context.register(props.handler);
	override function componentWillUnmount():Void context.unregister(props.handler);
}
