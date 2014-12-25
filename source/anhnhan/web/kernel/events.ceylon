/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.utils.event {
    Event,
    DispatcherContext
}
import anhnhan.web {
    Request,
    Response
}

shared
interface KernelEventType
    of kernelRequest
        | kernelException
        | kernelView
        | kernelController
        | kernelResponse
        | kernelFinishRequest
{
    shared formal
    String eventName;
}
shared
object kernelRequest satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.request";
}
shared
object kernelException satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.exception";
}
shared
object kernelView satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.view";
}
shared
object kernelController satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.controller";
}
shared
object kernelResponse satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.response";
}
shared
object kernelFinishRequest satisfies KernelEventType
{
    shared actual
    String eventName = "kernel.finish_request";
}

shared
interface KernelEvent
    satisfies Event<KernelEvent>
{
    "The Request that was currently processing."
    shared formal
    Request request;

    "The HttpKernel this event was thrown in."
    shared formal
    HttpKernel httpKernel;

    "They type of the Request the kernel was currently handling."
    shared formal
    RequestType requestType;

    shared formal
    Boolean isMasterRequest;
}

shared
interface FilterResponseEvent
    satisfies KernelEvent
{
    shared formal
    Response response;
}

shared final sealed
class FilterResponseEventImpl(httpKernel, request, requestType, response)
    satisfies FilterResponseEvent
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;

    shared actual
    Response response;
}

shared
interface GetResponseEvent
    satisfies KernelEvent
{
    shared formal variable
    Response? response;
}

shared final sealed
class GetResponseEventImpl(httpKernel, request, requestType)
    satisfies GetResponseEvent
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;

    variable
    Response? _response = null;
    shared actual
    Response? response
    {
        return _response;
    }
    assign response
    {
        _response = response;
        stopPropagation();
    }
}

shared
interface GetControllerEvent<Controller, out ControllerReturn, in ControllerArguments>
    satisfies KernelEvent
    given Controller satisfies Callable<ControllerReturn, ControllerArguments>
    given ControllerArguments satisfies Anything[]
{
    shared formal variable
    Controller? controller;
}

shared final sealed
class GetControllerEventImpl<Controller, out ControllerReturn, in ControllerArguments>(httpKernel, request, requestType)
    satisfies GetControllerEvent<Controller, ControllerReturn, ControllerArguments>
    given Controller satisfies Callable<ControllerReturn, ControllerArguments>
    given ControllerArguments satisfies Anything[]
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;

    variable
    Controller? _controller = null;
    shared actual
    Controller? controller
    {
        return _controller;
    }
    assign controller
    {
        _controller = controller;
        stopPropagation();
    }
}

shared
interface ConvertControllerResult<Result>
    satisfies GetResponseEvent
{
    shared formal
    Result controllerResult;
}

shared final sealed
class ConvertControllerResultImpl<Result>(httpKernel, request, requestType, controllerResult)
    satisfies ConvertControllerResult<Result>
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Result controllerResult;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;

    variable
    Response? _response = null;
    shared actual
    Response? response
    {
        return _response;
    }
    assign response
    {
        _response = response;
        stopPropagation();
    }
}

shared
interface FinishRequestEvent
    satisfies KernelEvent {}
shared final sealed
class FinishRequestEventImpl(httpKernel, request, requestType)
    satisfies FinishRequestEvent
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;
}

shared
interface ExceptionResponseEvent<Exception>
    satisfies GetResponseEvent
    given Exception satisfies Throwable
{
    shared formal variable
    Exception exception;
}

shared final sealed
class ExceptionResponseEventImpl<Exception>(httpKernel, request, requestType, exception)
    satisfies ExceptionResponseEvent<Exception>
    given Exception satisfies Throwable
{
    late shared actual variable
    DispatcherContext<KernelEvent> dispatchContext;

    shared actual variable
    Boolean furtherPropagationPrevented = false;

    shared actual
    HttpKernel httpKernel;

    shared actual
    Request request;

    shared actual
    RequestType requestType;

    shared actual
    Boolean isMasterRequest = requestType == masterRequest;

    variable
    Response? _response = null;
    shared actual
    Response? response
    {
        return _response;
    }
    assign response
    {
        _response = response;
        stopPropagation();
    }

    shared actual variable
    Exception exception;
}
