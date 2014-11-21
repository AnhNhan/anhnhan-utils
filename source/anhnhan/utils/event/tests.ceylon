/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

import anhnhan.utils.event {
    Event,
    BaseEvent,
    DispatcherContext,
    EventDispatcher
}

import ceylon.test {
    beforeTest,
    assertTrue,
    assertFalse,
    test,
    assertEquals
}

// Tests taken from the Symfony project

String preFoo = "pre.foo";
String postFoo = "post.foo";

class TestEventListener()
{
    shared variable Boolean preFooInvoked = false;
    shared variable Boolean postFooInvoked = false;

    shared void preFoo<EventType>(EventType event)
        given EventType satisfies Event<EventType>
    {
        preFooInvoked = true;
    }

    shared void postFoo<EventType>(EventType event)
        given EventType satisfies Event<EventType>
    {
        postFooInvoked = true;

        event.stopPropagation();
    }

    shared void reset()
    {
        preFooInvoked = false;
        postFooInvoked = false;
    }
}

class TestWithDispatcher()
{
    shared variable DispatcherContext<BaseEvent>? dispatchContext = null;

    shared void foo<EventType>(EventType event)
        given EventType satisfies Event<BaseEvent>
    {
        dispatchContext = event.dispatchContext;
    }

    shared void reset() => dispatchContext = null;
}

[TestEventListener, {<String->Callable<Anything, [EventType]>>+}] createListeners<EventType>(TestEventListener? eventListener)
    given EventType satisfies Event<EventType>
{
    value obj = eventListener else TestEventListener();
    return [obj, {
        preFoo->obj.preFoo<EventType>,
        postFoo->obj.postFoo<EventType>
    }];
}

// Actual tests

class DispatcherTest()
{
    late
    variable Dispatcher<BaseEvent> dispatcher;
    late
    variable TestEventListener listener;

    beforeTest shared void setUp()
    {
        dispatcher = EventDispatcher<BaseEvent>();
        listener = TestEventListener();
    }

    test
    shared void initialState()
    {
        assertTrue(dispatcher.allListeners().empty);
        assertFalse(dispatcher.hasListeners(preFoo));
        assertFalse(dispatcher.hasListeners(postFoo));
    }

    test
    shared void listenerMutation()
    {
        dispatcher.addListener(preFoo, listener.preFoo<BaseEvent>);
        dispatcher.addListener(postFoo, listener.postFoo<BaseEvent>);

        value deleteEventBar = dispatcher.addListener("event.bar", (event) => event);
        dispatcher.addListener("event.bar", (event) => event);
        dispatcher.addListener("event.bar", (event) => event);
        dispatcher.addListener("event.bar", (event) => event);

        assertTrue(dispatcher.hasListeners(preFoo));
        assertTrue(dispatcher.hasListeners(postFoo));
        assertTrue(dispatcher.hasListeners("event.bar"));

        assertEquals(dispatcher.getListeners(preFoo)?.size, 1);
        assertEquals(dispatcher.getListeners(postFoo)?.size, 1);
        assertEquals(dispatcher.getListeners("event.bar")?.size, 4);
        assertEquals(dispatcher.allListeners().size, 3);

        print("pre");

        print(dispatcher.getListeners("event.bar"));
        deleteEventBar();
        print(dispatcher.getListeners("event.bar"));

        print("post");

        assertFalse(dispatcher.hasListeners("event.bar"));
        assertEquals(dispatcher.getListeners("event.bar")?.size, null);
        assertEquals(dispatcher.allListeners().size, 2);
    }
}
