/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty

    Inspired by the Symfony Framework
 */

import de.anhnhan.utils.event {
    Dispatcher
}
import de.anhnhan.web {
    Response,
    Request,
    RequestStackImpl,
    RequestStack,
    CustomStatusCode
}

shared
interface RequestType
    of masterRequest | subRequest {}
shared
object masterRequest satisfies RequestType {}
shared
object subRequest satisfies RequestType {}

"The HttpKernel handles a [[Request]] and converts it to a [[Response]]."
shared
interface HttpKernel
{
    shared formal
    Response handle(
        "The request to be handled."
        Request request,
        "Whether this request is a master request (top-level), or a
         sub-request (initiated during processing of another request)."
        RequestType type = masterRequest,
        "Whether to catch exceptions that happen during request handling."
        Boolean catchExceptions = true
    );
}

shared final
class DefaultHttpKernel<Controller, ControllerReturn>(dispatcher, requestStack = RequestStackImpl({}))
    satisfies HttpKernel
    given Controller satisfies Callable<ControllerReturn, [Request]>
{
    Dispatcher<KernelEvent> dispatcher;
    "A stack for master-/sub-requests."
    RequestStack requestStack;

    shared actual Response handle(Request request, RequestType type, Boolean catchExceptions)
    {
        try
        {
            return actualHandle(request, type);
        }
        catch (Exception exc)
        {
            if (catchExceptions)
            {
                return convertException(exc, request, type);
            }
            else
            {
                throw exc;
            }
        }
    }

    Response actualHandle(Request request, RequestType type)
    {
        requestStack.push(request);

        value getRespEvent = GetResponseEventImpl(this, request, type);
        dispatcher.dispatch(kernelRequest.eventName, getRespEvent);
        if (exists response = getRespEvent.response)
        {
            return filterResponse(response, request, type);
        }

        value getContrEvent = GetControllerEventImpl<Controller, ControllerReturn, [Request]>(this, request, type);
        dispatcher.dispatch(kernelController.eventName, getContrEvent);

        if (exists controller = getContrEvent.controller)
        {
            Response response;
            ControllerReturn controllerResult = controller(request);

            if (is Response controllerResult)
            {
                response = controllerResult;
            }
            else
            {
                value convContrResEvent = ConvertControllerResultImpl(this, request, type, controllerResult);
                dispatcher.dispatch(kernelView.eventName, convContrResEvent);
                if (exists convResponse = convContrResEvent.response)
                {
                    response = convResponse;
                }
                else
                {
                    throw Exception("Failed to produce a response for controller result.");
                }
            }

            return filterResponse(response, request, type);
        }
        else
        {
            throw Exception("Could not retrieve an controller for path ``request.pathInfo``");
        }
    }

    void finishRequest(Request request, RequestType type)
    {
        value event = FinishRequestEventImpl(this, request, type);
        dispatcher.dispatch(kernelFinishRequest.eventName, event);
        requestStack.pop();
    }

    Response filterResponse(Response response, Request request, RequestType type)
    {
        value event = FilterResponseEventImpl(this, request, type, response);
        dispatcher.dispatch(kernelResponse.eventName, event);
        finishRequest(request, type);
        return event.response;
    }

    Response convertException(Exception e, Request request, RequestType type)
    {
        value event = ExceptionResponseEventImpl(this, request, type, e);
        dispatcher.dispatch(kernelException.eventName, event);

        value exception = event.exception;

        if (exists response = event.response)
        {
            if (exists newStatusCode = response.headers["X-Status-Code"])
            {
                response.httpCode = CustomStatusCode(parseInteger(newStatusCode) else nothing);
                response.headers.remove("X-Status-Code");
            }

            try
            {
                return filterResponse(response, request, type);
            }
            catch (Exception _)
            {
                return response;
            }
        }
        else
        {
            finishRequest(request, type);
            throw exception;
        }
    }
}
