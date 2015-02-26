/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

shared interface DispatcherContext<EventType>
    given EventType satisfies Event<EventType>
{
    shared formal String eventName;
    shared formal Dispatcher<EventType> dispatcher;
}

// This is only parameterized because Dispatcher is parameterized.
shared interface Event<EventType> of EventType
    given EventType satisfies Event<EventType>
{
    shared formal variable DispatcherContext<EventType> dispatchContext;
    shared formal variable Boolean furtherPropagationPrevented;

    shared void stopPropagation()
        => furtherPropagationPrevented = true;
}

shared class BaseEvent()
    satisfies Event<BaseEvent>
{
    // FIXME: `DispatcherContext<BaseEvent>`? Seriously? What have I done!?
    late shared actual variable DispatcherContext<BaseEvent> dispatchContext;
    shared actual variable Boolean furtherPropagationPrevented = false;
}
