---
source_url: https://docs.ros2.org/latest/api/rclcpp/classrclcpp_1_1Service.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp: rclcpp::Service< ServiceT > Class Template Reference

rclcpp: rclcpp::Service< ServiceT > Class Template Reference

rclcpp
master

C++ ROS Client Library API

- rclcpp
- Service

Public Types |
Public Member Functions |
List of all members

rclcpp::Service< ServiceT > Class Template Reference

`#include <service.hpp>`

Inheritance diagram for rclcpp::Service< ServiceT >:

[legend]

Collaboration diagram for rclcpp::Service< ServiceT >:

[legend]

Public Types

using CallbackType = std::function< void(const std::shared_ptr< typename ServiceT::Request >, std::shared_ptr< typename ServiceT::Response >)>

using CallbackWithHeaderType = std::function< void(const std::shared_ptr< rmw_request_id_t >, const std::shared_ptr< typename ServiceT::Request >, std::shared_ptr< typename ServiceT::Response >)>

Public Member Functions

Service (std::shared_ptr< rcl_node_t > node_handle, const std::string &service_name, AnyServiceCallback< ServiceT > any_callback, rcl_service_options_t &service_options)

Default constructor.  More...

Service (std::shared_ptr< rcl_node_t > node_handle, std::shared_ptr< rcl_service_t > service_handle, AnyServiceCallback< ServiceT > any_callback)

Default constructor.  More...

Service (std::shared_ptr< rcl_node_t > node_handle, rcl_service_t *service_handle, AnyServiceCallback< ServiceT > any_callback)

Default constructor.  More...

Service ()=delete

virtual ~Service ()

bool take_request (typename ServiceT::Request &request_out, rmw_request_id_t &request_id_out)

Take the next request from the service.  More...

std::shared_ptr< void > create_request () override

std::shared_ptr< rmw_request_id_t > create_request_header () override

void handle_request (std::shared_ptr< rmw_request_id_t > request_header, std::shared_ptr< void > request) override

void send_response (std::shared_ptr< rmw_request_id_t > req_id, std::shared_ptr< typename ServiceT::Response > response)

void send_response (rmw_request_id_t &req_id, typename ServiceT::Response &response)

Public Member Functions inherited from rclcpp::ServiceBase

ServiceBase (std::shared_ptr< rcl_node_t > node_handle)

virtual ~ServiceBase ()

const char * get_service_name ()

Return the name of the service.  More...

std::shared_ptr< rcl_service_t > get_service_handle ()

Return the rcl_service_t service handle in a std::shared_ptr.  More...

std::shared_ptr< const rcl_service_t > get_service_handle () const

Return the rcl_service_t service handle in a std::shared_ptr.  More...

bool take_type_erased_request (void *request_out, rmw_request_id_t &request_id_out)

Take the next request from the service as a type erased pointer.  More...

bool exchange_in_use_by_wait_set_state (bool in_use_state)

Exchange the "in use by wait set" state for this service.  More...

Additional Inherited Members

Protected Member Functions inherited from rclcpp::ServiceBase

rcl_node_t * get_rcl_node_handle ()

const rcl_node_t * get_rcl_node_handle () const

Protected Attributes inherited from rclcpp::ServiceBase

std::shared_ptr< rcl_node_t > node_handle_

std::shared_ptr< rcl_service_t > service_handle_

bool owns_rcl_handle_ = true

std::atomic< bool > in_use_by_wait_set_ {false}

Member Typedef Documentation

◆ CallbackType

template<typename ServiceT >

using rclcpp::Service< ServiceT >::CallbackType =  std::function< void ( const std::shared_ptr<typename ServiceT::Request>, std::shared_ptr<typename ServiceT::Response>)>

◆ CallbackWithHeaderType

template<typename ServiceT >

using rclcpp::Service< ServiceT >::CallbackWithHeaderType =  std::function< void ( const std::shared_ptr<rmw_request_id_t>, const std::shared_ptr<typename ServiceT::Request>, std::shared_ptr<typename ServiceT::Response>)>

Constructor & Destructor Documentation

◆ Service() [1/4]

template<typename ServiceT >

rclcpp::Service< ServiceT >::Service(std::shared_ptr< rcl_node_t > node_handle,

const std::string & service_name,

AnyServiceCallback< ServiceT > any_callback,

rcl_service_options_t & service_options

)

inline

Default constructor.

The constructor for a Service is almost never called directly. Instead, services should be instantiated through the function rclcpp::create_service().
Parameters

[in]node_handleNodeBaseInterface pointer that is used in part of the setup.

[in]service_nameName of the topic to publish to.

[in]any_callbackUser defined callback to call when a client request is received.

[in]service_optionsoptions for the subscription.

◆ Service() [2/4]

template<typename ServiceT >

rclcpp::Service< ServiceT >::Service(std::shared_ptr< rcl_node_t > node_handle,

std::shared_ptr< rcl_service_t > service_handle,

AnyServiceCallback< ServiceT > any_callback

)

inline

Default constructor.

The constructor for a Service is almost never called directly. Instead, services should be instantiated through the function rclcpp::create_service().
Parameters

[in]node_handleNodeBaseInterface pointer that is used in part of the setup.

[in]service_handleservice handle.

[in]any_callbackUser defined callback to call when a client request is received.

◆ Service() [3/4]

template<typename ServiceT >

rclcpp::Service< ServiceT >::Service(std::shared_ptr< rcl_node_t > node_handle,

rcl_service_t * service_handle,

AnyServiceCallback< ServiceT > any_callback

)

inline

Default constructor.

The constructor for a Service is almost never called directly. Instead, services should be instantiated through the function rclcpp::create_service().
Parameters

[in]node_handleNodeBaseInterface pointer that is used in part of the setup.

[in]service_handleservice handle.

[in]any_callbackUser defined callback to call when a client request is received.

◆ Service() [4/4]

template<typename ServiceT >

rclcpp::Service< ServiceT >::Service()

delete

◆ ~Service()

template<typename ServiceT >

virtual rclcpp::Service< ServiceT >::~Service()

inlinevirtual

Member Function Documentation

◆ take_request()

template<typename ServiceT >

bool rclcpp::Service< ServiceT >::take_request (typename ServiceT::Request & request_out,

rmw_request_id_t & request_id_out

)

inline

Take the next request from the service.
See alsoServiceBase::take_type_erased_request().Parameters

[out]request_outThe reference to a service request object into which the middleware will copy the taken request.

[out]request_id_outThe output id for the request which can be used to associate response with this request in the future.

Returnstrue if the request was taken, otherwise false. Exceptions

rclcpp::exceptions::RCLErrorbased exceptions if the underlying rcl calls fail.

◆ create_request()

template<typename ServiceT >

std::shared_ptr<void> rclcpp::Service< ServiceT >::create_request ()

inlineoverridevirtual

Implements rclcpp::ServiceBase.

◆ create_request_header()

template<typename ServiceT >

std::shared_ptr<rmw_request_id_t> rclcpp::Service< ServiceT >::create_request_header ()

inlineoverridevirtual

Implements rclcpp::ServiceBase.

◆ handle_request()

template<typename ServiceT >

void rclcpp::Service< ServiceT >::handle_request (std::shared_ptr< rmw_request_id_t > request_header,

std::shared_ptr< void > request

)

inlineoverridevirtual

Implements rclcpp::ServiceBase.

◆ send_response() [1/2]

template<typename ServiceT >

void rclcpp::Service< ServiceT >::send_response (std::shared_ptr< rmw_request_id_t > req_id,

std::shared_ptr< typename ServiceT::Response > response

)

inline

◆ send_response() [2/2]

template<typename ServiceT >

void rclcpp::Service< ServiceT >::send_response (rmw_request_id_t & req_id,

typename ServiceT::Response & response

)

inline

The documentation for this class was generated from the following file:

- include/rclcpp/service.hpp

Generated by   1.8.17
