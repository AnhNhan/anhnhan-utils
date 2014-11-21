/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

import anhnhan.utils {
    acceptEntry,
    invokeAll
}

import ceylon.collection {
    TreeMap,
    MutableMap,
    HashMap
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
        value callbacks = listeners.collect(acceptEntry(addListener));
        return () => invokeAll(callbacks);
    }

    shared formal {EventListener+}? getListeners(String eventName);
    shared default Boolean hasListeners(String eventName) => getListeners(eventName) exists;

    shared formal Map<String, {EventListener+}> allListeners();
}

shared final class EventDispatcher<EventType>()
    satisfies Dispatcher<EventType>
    given EventType satisfies Event<EventType>
{
    "Tracks the id to be assigned to the next event listener added."
    variable value currentListenerId = 0;
    """Our internal map for eventName->{[[EventListener]]+}.

       Note: It turns out that equivalence checks of [[EventListener]] is
       kind of flaky, so we do not explicitly denote {[[EventListener]]+},
       but instead use [[Map]]<[[Integer]], [[EventListener]]>, with [[Integer]]
       being our own identity spawned during the call to [[addListener]],
       re-used for cancelation of an added event listener."""
    value listeners = TreeMap<String, MutableMap<Integer, EventListener>>((String x, String y) => x <=> y);

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
        // We use the id to track this specific addition, to be able to delete it later
        value currentId = currentListenerId++;
        value map = listeners[eventName] else HashMap<Integer, EventListener>();
        map.put(currentId, listener);
        listeners.put(eventName, map);

        return function ()
        {
            if (exists map = listeners[eventName])
            {
                map.remove(currentId);
                // Removing the entry should bring a noticable performance
                // benefit, as it may speed up [[allListeners]] / [[getListeners]]
                if (map.empty)
                {
                    listeners.remove(eventName);
                }
            }
            return null;
        };
    }

    // Note: Converting back from id-ed variant. See big comment above.
    // .sequence() call for nonempty check / casting. If somebody knows how to
    // 'cast' {T*} into {T+}? I'm not confident about assert/exists, since
    // I don't think that the compiler would actually assign those types at
    // runtime.
    shared actual Map<String, {EventListener+}> allListeners()
        => HashMap { for (listener in listeners) if (nonempty eventListeners = listener.item.items.sequence()) listener.key->eventListeners };

    shared actual {EventListener+}? getListeners(String eventName) => allListeners()[eventName];
}
