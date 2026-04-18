---
source_url: https://docs.ros2.org/latest/api/rclcpp/classrclcpp_1_1Client.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp: rclcpp::Client< ServiceT > Class Template Reference

rclcpp: rclcpp::Client< ServiceT > Class Template Reference

rclcpp
master

C++ ROS Client Library API

- rclcpp
- Client

Public Types |
Public Member Functions |
List of all members

rclcpp::Client< ServiceT > Class Template Reference

`#include <client.hpp>`

Inheritance diagram for rclcpp::Client< ServiceT >:

[legend]

Collaboration diagram for rclcpp::Client< ServiceT >:

[legend]

Public Types

using SharedRequest = typename ServiceT::Request::SharedPtr

using SharedResponse = typename ServiceT::Response::SharedPtr

using Promise = std::promise< SharedResponse >

using PromiseWithRequest = std::promise< std::pair< SharedRequest, SharedResponse > >

using SharedPromise = std::shared_ptr< Promise >

using SharedPromiseWithRequest = std::shared_ptr< PromiseWithRequest >

using SharedFuture = std::shared_future< SharedResponse >

using SharedFutureWithRequest = std::shared_future< std::pair< SharedRequest, SharedResponse > >

using CallbackType = std::function< void(SharedFuture)>

using CallbackWithRequestType = std::function< void(SharedFutureWithRequest)>

Public Member Functions

Client (rclcpp::node_interfaces::NodeBaseInterface *node_base, rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph, const std::string &service_name, rcl_client_options_t &client_options)

Default constructor.  More...

virtual ~Client ()

bool take_response (typename ServiceT::Response &response_out, rmw_request_id_t &request_header_out)

Take the next response for this client.  More...

std::shared_ptr< void > create_response () override

Create a shared pointer with the response type.  More...

std::shared_ptr< rmw_request_id_t > create_request_header () override

Create a shared pointer with a rmw_request_id_t.  More...

void handle_response (std::shared_ptr< rmw_request_id_t > request_header, std::shared_ptr< void > response) override

Handle a server response.  More...

SharedFutureasync_send_request (SharedRequest request)

template<typename CallbackT , typename std::enable_if< rclcpp::function_traits::same_arguments< CallbackT, CallbackType >::value >::type *  = nullptr>

SharedFutureasync_send_request (SharedRequest request, CallbackT &&cb)

template<typename CallbackT , typename std::enable_if< rclcpp::function_traits::same_arguments< CallbackT, CallbackWithRequestType >::value >::type *  = nullptr>

SharedFutureWithRequestasync_send_request (SharedRequest request, CallbackT &&cb)

Public Member Functions inherited from rclcpp::ClientBase

ClientBase (rclcpp::node_interfaces::NodeBaseInterface *node_base, rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph)

virtual ~ClientBase ()

bool take_type_erased_response (void *response_out, rmw_request_id_t &request_header_out)

Take the next response for this client as a type erased pointer.  More...

const char * get_service_name () const

Return the name of the service.  More...

std::shared_ptr< rcl_client_t > get_client_handle ()

Return the rcl_client_t client handle in a std::shared_ptr.  More...

std::shared_ptr< const rcl_client_t > get_client_handle () const

Return the rcl_client_t client handle in a std::shared_ptr.  More...

bool service_is_ready () const

Return if the service is ready.  More...

template<typename RepT  = int64_t, typename RatioT  = std::milli>

bool wait_for_service (std::chrono::duration< RepT, RatioT > timeout=std::chrono::duration< RepT, RatioT >(-1))

Wait for a service to be ready.  More...

bool exchange_in_use_by_wait_set_state (bool in_use_state)

Exchange the "in use by wait set" state for this client.  More...

Additional Inherited Members

Protected Member Functions inherited from rclcpp::ClientBase

bool wait_for_service_nanoseconds (std::chrono::nanoseconds timeout)

rcl_node_t * get_rcl_node_handle ()

const rcl_node_t * get_rcl_node_handle () const

Protected Attributes inherited from rclcpp::ClientBase

rclcpp::node_interfaces::NodeGraphInterface::WeakPtr node_graph_

std::shared_ptr< rcl_node_t > node_handle_

std::shared_ptr< rclcpp::Context > context_

std::shared_ptr< rcl_client_t > client_handle_

std::atomic< bool > in_use_by_wait_set_ {false}

Member Typedef Documentation

◆ SharedRequest

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedRequest =  typename ServiceT::Request::SharedPtr

◆ SharedResponse

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedResponse =  typename ServiceT::Response::SharedPtr

◆ Promise

template<typename ServiceT >

using rclcpp::Client< ServiceT >::Promise =  std::promise<SharedResponse>

◆ PromiseWithRequest

template<typename ServiceT >

using rclcpp::Client< ServiceT >::PromiseWithRequest =  std::promise<std::pair<SharedRequest, SharedResponse> >

◆ SharedPromise

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedPromise =  std::shared_ptr<Promise>

◆ SharedPromiseWithRequest

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedPromiseWithRequest =  std::shared_ptr<PromiseWithRequest>

◆ SharedFuture

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedFuture =  std::shared_future<SharedResponse>

◆ SharedFutureWithRequest

template<typename ServiceT >

using rclcpp::Client< ServiceT >::SharedFutureWithRequest =  std::shared_future<std::pair<SharedRequest, SharedResponse> >

◆ CallbackType

template<typename ServiceT >

using rclcpp::Client< ServiceT >::CallbackType =  std::function<void (SharedFuture)>

◆ CallbackWithRequestType

template<typename ServiceT >

using rclcpp::Client< ServiceT >::CallbackWithRequestType =  std::function<void (SharedFutureWithRequest)>

Constructor & Destructor Documentation

◆ Client()

template<typename ServiceT >

rclcpp::Client< ServiceT >::Client(rclcpp::node_interfaces::NodeBaseInterface * node_base,

rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph,

const std::string & service_name,

rcl_client_options_t & client_options

)

inline

Default constructor.

The constructor for a Client is almost never called directly. Instead, clients should be instantiated through the function rclcpp::create_client().
Parameters

[in]node_baseNodeBaseInterface pointer that is used in part of the setup.

[in]node_graphThe node graph interface of the corresponding node.

[in]service_nameName of the topic to publish to.

[in]client_optionsoptions for the subscription.

◆ ~Client()

template<typename ServiceT >

virtual rclcpp::Client< ServiceT >::~Client()

inlinevirtual

Member Function Documentation

◆ take_response()

template<typename ServiceT >

bool rclcpp::Client< ServiceT >::take_response (typename ServiceT::Response & response_out,

rmw_request_id_t & request_header_out

)

inline

Take the next response for this client.
See alsoClientBase::take_type_erased_response().Parameters

[out]response_outThe reference to a Service Response into which the middleware will copy the response being taken.

[out]request_header_outThe request header to be filled by the middleware when taking, and which can be used to associte the response to a specific request.

Returnstrue if the response was taken, otherwise false. Exceptions

rclcpp::exceptions::RCLErrorbased exceptions if the underlying rcl function fail.

◆ create_response()

template<typename ServiceT >

std::shared_ptr<void> rclcpp::Client< ServiceT >::create_response ()

inlineoverridevirtual

Create a shared pointer with the response type.
Returnsshared pointer with the response type
Implements rclcpp::ClientBase.

◆ create_request_header()

template<typename ServiceT >

std::shared_ptr<rmw_request_id_t> rclcpp::Client< ServiceT >::create_request_header ()

inlineoverridevirtual

Create a shared pointer with a rmw_request_id_t.
Returnsshared pointer with a rmw_request_id_t
Implements rclcpp::ClientBase.

◆ handle_response()

template<typename ServiceT >

void rclcpp::Client< ServiceT >::handle_response (std::shared_ptr< rmw_request_id_t > request_header,

std::shared_ptr< void > response

)

inlineoverridevirtual

Handle a server response.
Parameters

[in]request_headerused to check if the secuence number is valid

[in]responsemessage with the server response

Implements rclcpp::ClientBase.

◆ async_send_request() [1/3]

template<typename ServiceT >

SharedFuturerclcpp::Client< ServiceT >::async_send_request (SharedRequestrequest)

inline

◆ async_send_request() [2/3]

template<typename ServiceT >

template<typename CallbackT , typename std::enable_if< rclcpp::function_traits::same_arguments< CallbackT, CallbackType >::value >::type *  = nullptr>

SharedFuturerclcpp::Client< ServiceT >::async_send_request (SharedRequestrequest,

CallbackT && cb

)

inline

◆ async_send_request() [3/3]

template<typename ServiceT >

template<typename CallbackT , typename std::enable_if< rclcpp::function_traits::same_arguments< CallbackT, CallbackWithRequestType >::value >::type *  = nullptr>

SharedFutureWithRequestrclcpp::Client< ServiceT >::async_send_request (SharedRequestrequest,

CallbackT && cb

)

inline

The documentation for this class was generated from the following file:

- include/rclcpp/client.hpp

Generated by   1.8.17
