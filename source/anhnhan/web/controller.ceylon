/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    group,
    HashMap
}
import ceylon.language.meta.declaration {
    ClassDeclaration
}

shared alias HandlerResult => RequestResponse|RequestError;

shared alias RequestController => RequestHandler | HandlerResult(Request);

shared interface RequestHandler
{
    shared formal HandlerResult handleRequest(Request request);
}

shared interface RequestHandlerGroup
{
    //
}

shared interface Application
{
    shared formal String humanReadableName;
    shared formal String internalName;

    "Whether this application is enabled.

     Controls things like whether this applications should accept requests,
     functionality should be provided (modular extensions, event listeners,
     etc.), etc."
    shared formal Boolean applicationEnabled;

    shared formal ApplicationContext context;

    shared formal Service? getService<Service>(String? serviceName)
        given Service satisfies Object;

    shared formal Parameter? getParameter<Parameter>(String parameterName);

    shared formal {Route<Anything>*} routes;

    shared formal Controller? routeToController(Request request);
}

shared interface Controller
{
    shared formal Application app;

    shared formal RequestStack requestStack;
    shared formal Request request;
}

"Manages modularity of the application, and provides application context to
 its controllers/handlers.

 May be transient across requests. Please respect that."
shared abstract class BaseApplication(context, ClassDeclaration* controllerDeclarations)
    satisfies Application
{
    shared actual default Boolean applicationEnabled = true;

    shared actual ApplicationContext context;

    value controllerDescriptor = ControllerDescriptor(*controllerDeclarations);

    shared actual {Route<ClassDeclaration>*} routes = controllerDescriptor.routesToDeclarations.keys;

    shared actual Service? getService<Service>(String? serviceName)
        given Service satisfies Object
    {
        if (is Null serviceName)
        {
            return context.service<Service>();
        }
        "flow-sensitive typing will make this assert obselete in 1.1.5 or 1.2"
        assert(exists serviceName);

        value service = context.services[serviceName];
        if (is Service? service)
        {
            return service;
        }

        value t = `Service`;
        throw Exception("Service ``serviceName`` is misconfigured, expected service of type ``t`` but received object of type ``className(service else "<err>")``");
    }

    shared actual Parameter? getParameter<Parameter = String>(String parameterName)
    {
        value parameter = context.parameters[parameterName];
        if (is Parameter? parameter)
        {
            return parameter;
        }
        value t = `Parameter`;
        throw Exception("Parameter ``parameterName`` is misconfigured, expected service of type ``t`` but received object of type ``className(parameter else "<err>")``");
    }
}

"Assumable live-once, use-once for each request. If you do not want to stick
 with it, sure."
shared abstract class ApplicationHandler(app, requestStack)
    satisfies Controller
{
    shared actual default Application app;

    shared actual RequestStack requestStack;
    shared actual Request request { "No requests on the request stack!" assert(exists request = requestStack.top); return request; }
}

final class ControllerDescriptor(ClassDeclaration* controllerDeclarations)
{
    shared ClassDeclaration[] handlers = controllerDeclarations.select((decl) => !decl.annotations<Handler>().empty);
    Map<Handler, ClassDeclaration> mappedHandlers = HashMap { entries = handlers.map((decl) => (decl.annotations<Handler>().first else nothing) -> decl); };

    value _handlerMap = group(mappedHandlers, (Handler->ClassDeclaration entry) => entry.key.pattern);
    "Having handlers with missing routes!"
    assert(!("<err>" in _handlerMap));
    "Got handlers with duplicate routes!"
    assert(_handlerMap.every((String->[<Handler->ClassDeclaration>+] entry) => entry.item.size == 1));

    shared Map<String, [ClassDeclaration+]> handlerMap = HashMap { entries = _handlerMap.map((entry) => entry.key->entry.item.collect((entry) => entry.item)); };

    // We can be pretty sure that annotations are set up correct thanks to the above code
    shared Map<Route<ClassDeclaration>, ClassDeclaration> routesToDeclarations = HashMap { entries = handlers.map((decl) => StdRoute(decl.annotations<Handler>().first?.pattern else nothing, decl.annotations<SubHandler>().first?.subPattern, decl)->decl); };
}
