/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

import ceylon.collection {
    TreeMap
}

shared interface Dispatcher<EventType>
    given EventType satisfies Event<EventType>
{
    shared alias EventListener => Callable<Anything, [EventType]>;
    shared alias CancelCallback => Callable<Anything, []>;

    shared formal EventType dispatch(String eventName, EventType event);

    shared formal CancelCallback addListener(String eventName, EventListener listener);

    shared default CancelCallback addListeners({<String->EventListener>*} listeners)
    {
        value callbacks = listeners.collect((entry) => addListener(entry.key, entry.item));
        return () => callbacks.collect((callable) => callable());
    }

    shared formal {EventListener+}? getListeners(String eventName);
    shared default Boolean hasListeners(String eventName) => getListeners(eventName) exists;

    shared formal Map<String, {EventListener+}> allListeners();
}

shared final class EventDispatcher<EventType>()
    satisfies Dispatcher<EventType>
    given EventType satisfies Event<EventType>
{
    value listeners = TreeMap<String, [EventListener+]>((String x, String y) => x <=> y);

    class DispatcherContextImpl(eventName, dispatcher)
        satisfies DispatcherContext<EventType>
    {
        shared actual String eventName;
        shared actual Dispatcher<EventType> dispatcher;
    }

    shared actual EventType dispatch(String eventName, EventType event)
    {
        value context = DispatcherContextImpl(eventName, this);
        event.dispatchContext = context;

        if (exists listeners = getListeners(eventName))
        {
            for (listener in listeners)
            {
                listener(event);
                if (event.furtherPropagationPrevented)
                {
                    break;
                }
            }
        }

        return event;
    }

    shared actual CancelCallback addListener(String eventName, EventListener listener)
    {
        listeners.put(eventName, [listener, *(getListeners(eventName) else [])]);
        print("called put!");
        print(listeners[eventName]?.size);

        return function ()
        {
            if (exists oldListeners = getListeners(eventName))
            {
                value newListeners = oldListeners.select(listener.equals);
                print(oldListeners.size);
                print(newListeners.size);
                if (nonempty newListeners)
                {
                    listeners.put(eventName, newListeners);
                }
                else
                {
                    listeners.remove(eventName);
                }
            }
            return null;
        };
    }

    shared actual Map<String, [EventListener+]> allListeners() => listeners;

    shared actual [EventListener+]? getListeners(String eventName) => listeners[eventName];
}
