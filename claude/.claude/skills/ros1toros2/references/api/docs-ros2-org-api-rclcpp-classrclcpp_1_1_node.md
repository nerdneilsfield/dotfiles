---
source_url: https://docs.ros2.org/latest/api/rclcpp/classrclcpp_1_1Node.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp: rclcpp::Node Class Reference

rclcpp: rclcpp::Node Class Reference

rclcpp
master

C++ ROS Client Library API

- rclcpp
- Node

Public Types |
Public Member Functions |
Protected Member Functions |
List of all members

rclcpp::Node Class Reference

Node is the single point of entry for creating publishers and subscribers.
More...

`#include <node.hpp>`

Inheritance diagram for rclcpp::Node:

[legend]

Collaboration diagram for rclcpp::Node:

[legend]

Public Types

using OnSetParametersCallbackHandle = rclcpp::node_interfaces::OnSetParametersCallbackHandle

using OnParametersSetCallbackType = rclcpp::node_interfaces::NodeParametersInterface::OnParametersSetCallbackType

Public Member Functions

Node (const std::string &node_name, const NodeOptions &options=NodeOptions())

Create a new node with the specified name.  More...

Node (const std::string &node_name, const std::string &namespace_, const NodeOptions &options=NodeOptions())

Create a new node with the specified name.  More...

virtual ~Node ()

const char * get_name () const

Get the name of the node.  More...

const char * get_namespace () const

Get the namespace of the node.  More...

const char * get_fully_qualified_name () const

Get the fully-qualified name of the node.  More...

rclcpp::Loggerget_logger () const

Get the logger of the node.  More...

rclcpp::CallbackGroup::SharedPtr create_callback_group (rclcpp::CallbackGroupType group_type)

Create and return a callback group.  More...

const std::vector< rclcpp::CallbackGroup::WeakPtr > & get_callback_groups () const

Return the list of callback groups in the node.  More...

template<typename MessageT , typename AllocatorT  = std::allocator<void>, typename PublisherT  = rclcpp::Publisher<MessageT, AllocatorT>>

std::shared_ptr< PublisherT > create_publisher (const std::string &topic_name, const rclcpp::QoS &qos, const PublisherOptionsWithAllocator< AllocatorT > &options=PublisherOptionsWithAllocator< AllocatorT >())

Create and return a Publisher.  More...

template<typename MessageT , typename CallbackT , typename AllocatorT  = std::allocator<void>, typename CallbackMessageT  = typename rclcpp::subscription_traits::has_message_type<CallbackT>::type, typename SubscriptionT  = rclcpp::Subscription<CallbackMessageT, AllocatorT>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<      CallbackMessageT,      AllocatorT    >>

std::shared_ptr< SubscriptionT > create_subscription (const std::string &topic_name, const rclcpp::QoS &qos, CallbackT &&callback, const SubscriptionOptionsWithAllocator< AllocatorT > &options=SubscriptionOptionsWithAllocator< AllocatorT >(), typename MessageMemoryStrategyT::SharedPtr msg_mem_strat=(MessageMemoryStrategyT::create_default()))

Create and return a Subscription.  More...

template<typename DurationRepT  = int64_t, typename DurationT  = std::milli, typename CallbackT >

rclcpp::WallTimer< CallbackT >::SharedPtr create_wall_timer (std::chrono::duration< DurationRepT, DurationT > period, CallbackT callback, rclcpp::CallbackGroup::SharedPtr group=nullptr)

Create a timer.  More...

template<typename ServiceT >

rclcpp::Client< ServiceT >::SharedPtr create_client (const std::string &service_name, const rmw_qos_profile_t &qos_profile=rmw_qos_profile_services_default, rclcpp::CallbackGroup::SharedPtr group=nullptr)

Create and return a Client.  More...

template<typename ServiceT , typename CallbackT >

rclcpp::Service< ServiceT >::SharedPtr create_service (const std::string &service_name, CallbackT &&callback, const rmw_qos_profile_t &qos_profile=rmw_qos_profile_services_default, rclcpp::CallbackGroup::SharedPtr group=nullptr)

Create and return a Service.  More...

const rclcpp::ParameterValue & declare_parameter (const std::string &name, const rclcpp::ParameterValue &default_value=rclcpp::ParameterValue(), const rcl_interfaces::msg::ParameterDescriptor ¶meter_descriptor=rcl_interfaces::msg::ParameterDescriptor(), bool ignore_override=false)

Declare and initialize a parameter, return the effective value.  More...

template<typename ParameterT >

auto declare_parameter (const std::string &name, const ParameterT &default_value, const rcl_interfaces::msg::ParameterDescriptor ¶meter_descriptor=rcl_interfaces::msg::ParameterDescriptor(), bool ignore_override=false)

Declare and initialize a parameter with a type.  More...

template<typename ParameterT >

std::vector< ParameterT > declare_parameters (const std::string &namespace_, const std::map< std::string, ParameterT > ¶meters, bool ignore_overrides=false)

Declare and initialize several parameters with the same namespace and type.  More...

template<typename ParameterT >

std::vector< ParameterT > declare_parameters (const std::string &namespace_, const std::map< std::string, std::pair< ParameterT, rcl_interfaces::msg::ParameterDescriptor > > ¶meters, bool ignore_overrides=false)

Declare and initialize several parameters with the same namespace and type.  More...

void undeclare_parameter (const std::string &name)

Undeclare a previously declared parameter.  More...

bool has_parameter (const std::string &name) const

Return true if a given parameter is declared.  More...

rcl_interfaces::msg::SetParametersResult set_parameter (const rclcpp::Parameter ¶meter)

Set a single parameter.  More...

std::vector< rcl_interfaces::msg::SetParametersResult > set_parameters (const std::vector< rclcpp::Parameter > ¶meters)

Set one or more parameters, one at a time.  More...

rcl_interfaces::msg::SetParametersResult set_parameters_atomically (const std::vector< rclcpp::Parameter > ¶meters)

Set one or more parameters, all at once.  More...

rclcpp::Parameterget_parameter (const std::string &name) const

Return the parameter by the given name.  More...

bool get_parameter (const std::string &name, rclcpp::Parameter ¶meter) const

Get the value of a parameter by the given name, and return true if it was set.  More...

template<typename ParameterT >

bool get_parameter (const std::string &name, ParameterT ¶meter) const

Get the value of a parameter by the given name, and return true if it was set.  More...

template<typename ParameterT >

bool get_parameter_or (const std::string &name, ParameterT ¶meter, const ParameterT &alternative_value) const

Get the parameter value, or the "alternative_value" if not set, and assign it to "parameter".  More...

std::vector< rclcpp::Parameter > get_parameters (const std::vector< std::string > &names) const

Return the parameters by the given parameter names.  More...

template<typename ParameterT >

bool get_parameters (const std::string &prefix, std::map< std::string, ParameterT > &values) const

Get the parameter values for all parameters that have a given prefix.  More...

rcl_interfaces::msg::ParameterDescriptor describe_parameter (const std::string &name) const

Return the parameter descriptor for the given parameter name.  More...

std::vector< rcl_interfaces::msg::ParameterDescriptor > describe_parameters (const std::vector< std::string > &names) const

Return a vector of parameter descriptors, one for each of the given names.  More...

std::vector< uint8_t > get_parameter_types (const std::vector< std::string > &names) const

Return a vector of parameter types, one for each of the given names.  More...

rcl_interfaces::msg::ListParametersResult list_parameters (const std::vector< std::string > &prefixes, uint64_t depth) const

Return a list of parameters with any of the given prefixes, up to the given depth.  More...

RCUTILS_WARN_UNUSED OnSetParametersCallbackHandle::SharedPtr add_on_set_parameters_callback (OnParametersSetCallbackType callback)

Add a callback for when parameters are being set.  More...

void remove_on_set_parameters_callback (const OnSetParametersCallbackHandle *const handler)

Remove a callback registered with `add_on_set_parameters_callback`.  More...

OnParametersSetCallbackTypeset_on_parameters_set_callback (rclcpp::Node::OnParametersSetCallbackType callback)

Register a callback to be called anytime a parameter is about to be changed.  More...

std::vector< std::string > get_node_names () const

Get the fully-qualified names of all available nodes.  More...

std::map< std::string, std::vector< std::string > > get_topic_names_and_types () const

Return a map of existing topic names to list of topic types.  More...

std::map< std::string, std::vector< std::string > > get_service_names_and_types () const

Return a map of existing service names to list of service types.  More...

std::map< std::string, std::vector< std::string > > get_service_names_and_types_by_node (const std::string &node_name, const std::string &namespace_) const

Return the number of publishers that are advertised on a given topic.  More...

size_t count_publishers (const std::string &topic_name) const

size_t count_subscribers (const std::string &topic_name) const

Return the number of subscribers who have created a subscription for a given topic.  More...

std::vector< rclcpp::TopicEndpointInfo > get_publishers_info_by_topic (const std::string &topic_name, bool no_mangle=false) const

Return the topic endpoint information about publishers on a given topic.  More...

std::vector< rclcpp::TopicEndpointInfo > get_subscriptions_info_by_topic (const std::string &topic_name, bool no_mangle=false) const

Return the topic endpoint information about subscriptions on a given topic.  More...

rclcpp::Event::SharedPtr get_graph_event ()

Return a graph event, which will be set anytime a graph change occurs.  More...

void wait_for_graph_change (rclcpp::Event::SharedPtr event, std::chrono::nanoseconds timeout)

Wait for a graph event to occur by waiting on an Event to become set.  More...

rclcpp::Clock::SharedPtr get_clock ()

Get a clock as a non-const shared pointer which is managed by the node.  More...

rclcpp::Clock::ConstSharedPtr get_clock () const

Get a clock as a const shared pointer which is managed by the node.  More...

Timenow () const

Returns current time from the time source specified by clock_type.  More...

rclcpp::node_interfaces::NodeBaseInterface::SharedPtr get_node_base_interface ()

Return the Node's internal NodeBaseInterface implementation.  More...

rclcpp::node_interfaces::NodeClockInterface::SharedPtr get_node_clock_interface ()

Return the Node's internal NodeClockInterface implementation.  More...

rclcpp::node_interfaces::NodeGraphInterface::SharedPtr get_node_graph_interface ()

Return the Node's internal NodeGraphInterface implementation.  More...

rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr get_node_logging_interface ()

Return the Node's internal NodeLoggingInterface implementation.  More...

rclcpp::node_interfaces::NodeTimersInterface::SharedPtr get_node_timers_interface ()

Return the Node's internal NodeTimersInterface implementation.  More...

rclcpp::node_interfaces::NodeTopicsInterface::SharedPtr get_node_topics_interface ()

Return the Node's internal NodeTopicsInterface implementation.  More...

rclcpp::node_interfaces::NodeServicesInterface::SharedPtr get_node_services_interface ()

Return the Node's internal NodeServicesInterface implementation.  More...

rclcpp::node_interfaces::NodeWaitablesInterface::SharedPtr get_node_waitables_interface ()

Return the Node's internal NodeWaitablesInterface implementation.  More...

rclcpp::node_interfaces::NodeParametersInterface::SharedPtr get_node_parameters_interface ()

Return the Node's internal NodeParametersInterface implementation.  More...

rclcpp::node_interfaces::NodeTimeSourceInterface::SharedPtr get_node_time_source_interface ()

Return the Node's internal NodeTimeSourceInterface implementation.  More...

const std::string & get_sub_namespace () const

Return the sub-namespace, if this is a sub-node, otherwise an empty string.  More...

const std::string & get_effective_namespace () const

Return the effective namespace that is used when creating entities.  More...

rclcpp::Node::SharedPtr create_sub_node (const std::string &sub_namespace)

Create a sub-node, which will extend the namespace of all entities created with it.  More...

const rclcpp::NodeOptions & get_node_options () const

Return the NodeOptions used when creating this node.  More...

template<typename ServiceT >

Client< ServiceT >::SharedPtr create_client (const std::string &service_name, const rmw_qos_profile_t &qos_profile, rclcpp::CallbackGroup::SharedPtr group)

Public Member Functions inherited from std::enable_shared_from_this< Node >

T enable_shared_from_this (T... args)

T operator= (T... args)

T shared_from_this (T... args)

T ~enable_shared_from_this (T... args)

Protected Member Functions

Node (const Node &other, const std::string &sub_namespace)

Construct a sub-node, which will extend the namespace of all entities created with it.  More...

Detailed Description

Node is the single point of entry for creating publishers and subscribers.

Member Typedef Documentation

◆ OnSetParametersCallbackHandle

using rclcpp::Node::OnSetParametersCallbackHandle =  rclcpp::node_interfaces::OnSetParametersCallbackHandle

◆ OnParametersSetCallbackType

using rclcpp::Node::OnParametersSetCallbackType =  rclcpp::node_interfaces::NodeParametersInterface::OnParametersSetCallbackType

Constructor & Destructor Documentation

◆ Node() [1/3]

rclcpp::Node::Node (const std::string & node_name,

const NodeOptions & options = `NodeOptions()`

)

explicit

Create a new node with the specified name.
Parameters

[in]node_nameName of the node.

[in]optionsAdditional options to control creation of the node.

Exceptions

InvalidNamespaceErrorif the namespace is invalid

◆ Node() [2/3]

rclcpp::Node::Node (const std::string & node_name,

const std::string & namespace_,

const NodeOptions & options = `NodeOptions()`

)

explicit

Create a new node with the specified name.
Parameters

[in]node_nameName of the node.

[in]namespace_Namespace of the node.

[in]optionsAdditional options to control creation of the node.

Exceptions

InvalidNamespaceErrorif the namespace is invalid

◆ ~Node()

virtual rclcpp::Node::~Node ()

virtual

◆ Node() [3/3]

rclcpp::Node::Node (const Node & other,

const std::string & sub_namespace

)

protected

Construct a sub-node, which will extend the namespace of all entities created with it.
See alsocreate_sub_node()Parameters

[in]otherThe node from which a new sub-node is created.

[in]sub_namespaceThe sub-namespace of the sub-node.

Member Function Documentation

◆ get_name()

const char* rclcpp::Node::get_name () const

Get the name of the node.
ReturnsThe name of the node.

◆ get_namespace()

const char* rclcpp::Node::get_namespace () const

Get the namespace of the node.

This namespace is the "node's" namespace, and therefore is not affected by any sub-namespace's that may affect entities created with this instance. Use get_effective_namespace() to get the full namespace used by entities.
See alsoget_sub_namespace()get_effective_namespace()ReturnsThe namespace of the node.

◆ get_fully_qualified_name()

const char* rclcpp::Node::get_fully_qualified_name () const

Get the fully-qualified name of the node.

The fully-qualified name includes the local namespace and name of the node.
Returnsfully-qualified name of the node.

◆ get_logger()

rclcpp::Logger rclcpp::Node::get_logger () const

Get the logger of the node.
ReturnsThe logger of the node.

◆ create_callback_group()

rclcpp::CallbackGroup::SharedPtr rclcpp::Node::create_callback_group (rclcpp::CallbackGroupTypegroup_type)

Create and return a callback group.

◆ get_callback_groups()

const std::vector<rclcpp::CallbackGroup::WeakPtr>& rclcpp::Node::get_callback_groups () const

Return the list of callback groups in the node.

◆ create_publisher()

template<typename MessageT , typename AllocatorT , typename PublisherT >

std::shared_ptr< PublisherT > rclcpp::Node::create_publisher (const std::string & topic_name,

const rclcpp::QoS & qos,

const PublisherOptionsWithAllocator< AllocatorT > & options = `PublisherOptionsWithAllocator<AllocatorT>()`

)

Create and return a Publisher.

The rclcpp::QoS has several convenient constructors, including a conversion constructor for size_t, which mimics older API's that allows just a string and size_t to create a publisher.

For example, all of these cases will work:

pub = node->create_publisher<MsgT>("chatter", 10);  // implicitly KeepLast

pub = node->create_publisher<MsgT>("chatter", QoS(10));  // implicitly KeepLast

pub = node->create_publisher<MsgT>("chatter", QoS(KeepLast(10)));

pub = node->create_publisher<MsgT>("chatter", QoS(KeepAll()));

pub = node->create_publisher<MsgT>("chatter", QoS(1).best_effort().volatile());

{

rclcpp::QoS custom_qos(KeepLast(10), rmw_qos_profile_sensor_data);

pub = node->create_publisher<MsgT>("chatter", custom_qos);

}

The publisher options may optionally be passed as the third argument for any of the above cases.
Parameters

[in]topic_nameThe topic for this publisher to publish on.

[in]qosThe Quality of Service settings for the publisher.

[in]optionsAdditional options for the created Publisher.

ReturnsShared pointer to the created publisher.

◆ create_subscription()

template<typename MessageT , typename CallbackT , typename AllocatorT , typename CallbackMessageT , typename SubscriptionT , typename MessageMemoryStrategyT >

std::shared_ptr< SubscriptionT > rclcpp::Node::create_subscription (const std::string & topic_name,

const rclcpp::QoS & qos,

CallbackT && callback,

const SubscriptionOptionsWithAllocator< AllocatorT > & options = `SubscriptionOptionsWithAllocator<AllocatorT>()`,

typename MessageMemoryStrategyT::SharedPtr msg_mem_strat = `(      MessageMemoryStrategyT::create_default()    )`

)

Create and return a Subscription.
Parameters

[in]topic_nameThe topic to subscribe on.

[in]qosQoS profile for Subcription.

[in]callbackThe user-defined callback function to receive a message

[in]optionsAdditional options for the creation of the Subscription.

[in]msg_mem_stratThe message memory strategy to use for allocating messages.

ReturnsShared pointer to the created subscription.

◆ create_wall_timer()

template<typename DurationRepT , typename DurationT , typename CallbackT >

rclcpp::WallTimer< CallbackT >::SharedPtr rclcpp::Node::create_wall_timer (std::chrono::duration< DurationRepT, DurationT > period,

CallbackT callback,

rclcpp::CallbackGroup::SharedPtr group = `nullptr`

)

Create a timer.
Parameters

[in]periodTime interval between triggers of the callback.

[in]callbackUser-defined callback function.

[in]groupCallback group to execute this timer's callback in.

◆ create_client() [1/2]

template<typename ServiceT >

rclcpp::Client<ServiceT>::SharedPtr rclcpp::Node::create_client (const std::string & service_name,

const rmw_qos_profile_t & qos_profile = `rmw_qos_profile_services_default`,

rclcpp::CallbackGroup::SharedPtr group = `nullptr`

)

Create and return a Client.
Parameters

[in]service_nameThe topic to service on.

[in]qos_profilermw_qos_profile_t Quality of service profile for client.

[in]groupCallback group to call the service.

ReturnsShared pointer to the created client.

◆ create_service()

template<typename ServiceT , typename CallbackT >

rclcpp::Service< ServiceT >::SharedPtr rclcpp::Node::create_service (const std::string & service_name,

CallbackT && callback,

const rmw_qos_profile_t & qos_profile = `rmw_qos_profile_services_default`,

rclcpp::CallbackGroup::SharedPtr group = `nullptr`

)

Create and return a Service.
Parameters

[in]service_nameThe topic to service on.

[in]callbackUser-defined callback function.

[in]qos_profilermw_qos_profile_t Quality of service profile for client.

[in]groupCallback group to call the service.

ReturnsShared pointer to the created service.

◆ declare_parameter() [1/2]

const rclcpp::ParameterValue& rclcpp::Node::declare_parameter (const std::string & name,

const rclcpp::ParameterValue & default_value = `rclcpp::ParameterValue()`,

const rcl_interfaces::msg::ParameterDescriptor & parameter_descriptor = `rcl_interfaces::msg::ParameterDescriptor()`,

bool ignore_override = `false`

)

Declare and initialize a parameter, return the effective value.

This method is used to declare that a parameter exists on this node. If, at run-time, the user has provided an initial value then it will be set in this method, otherwise the given default_value will be set. In either case, the resulting value is returned, whether or not it is based on the default value or the user provided initial value.

If no parameter_descriptor is given, then the default values from the message definition will be used, e.g. read_only will be false.

The name and type in the given rcl_interfaces::msg::ParameterDescriptor are ignored, and should be specified using the name argument to this function and the default value's type instead.

If `ignore_override` is `true`, the parameter override will be ignored.

This method, if successful, will result in any callback registered with add_on_set_parameters_callback to be called. If that callback prevents the initial value for the parameter from being set then rclcpp::exceptions::InvalidParameterValueException is thrown.

The returned reference will remain valid until the parameter is undeclared.
Parameters

[in]nameThe name of the parameter.

[in]default_valueAn initial value to be used if at run-time user did not override it.

[in]parameter_descriptorAn optional, custom description for the parameter.

[in]ignore_overrideWhen `true`, the parameter override is ignored. Default to `false`.

ReturnsA const reference to the value of the parameter. Exceptions

rclcpp::exceptions::ParameterAlreadyDeclaredExceptionif parameter has already been declared.

rclcpp::exceptions::InvalidParametersExceptionif a parameter name is invalid.

rclcpp::exceptions::InvalidParameterValueExceptionif initial value fails to be set.

◆ declare_parameter() [2/2]

template<typename ParameterT >

auto rclcpp::Node::declare_parameter (const std::string & name,

const ParameterT & default_value,

const rcl_interfaces::msg::ParameterDescriptor & parameter_descriptor = `rcl_interfaces::msg::ParameterDescriptor()`,

bool ignore_override = `false`

)

Declare and initialize a parameter with a type.

See the non-templated declare_parameter() on this class for details.

If the type of the default value, and therefore also the type of return value, differs from the initial value provided in the node options, then a rclcpp::exceptions::InvalidParameterTypeException may be thrown. To avoid this, use the declare_parameter() method which returns an rclcpp::ParameterValue instead.

Note, this method cannot return a const reference, because extending the lifetime of a temporary only works recursively with member initializers, and cannot be extended to members of a class returned. The return value of this class is a copy of the member of a ParameterValue which is returned by the other version of declare_parameter(). See also:

- https://en.cppreference.com/w/cpp/language/lifetime
- https://herbsutter.com/2008/01/01/gotw-88-a-candidate-for-the-most-important-const/
- https://www.youtube.com/watch?v=uQyT-5iWUow (cppnow 2018 presentation)

◆ declare_parameters() [1/2]

template<typename ParameterT >

std::vector< ParameterT > rclcpp::Node::declare_parameters (const std::string & namespace_,

const std::map< std::string, ParameterT > & parameters,

bool ignore_overrides = `false`

)

Declare and initialize several parameters with the same namespace and type.

For each key in the map, a parameter with a name of "namespace.key" will be set to the value in the map. The resulting value for each declared parameter will be returned.

The name expansion is naive, so if you set the namespace to be "foo.", then the resulting parameter names will be like "foo..key". However, if the namespace is an empty string, then no leading '.' will be placed before each key, which would have been the case when naively expanding "namespace.key". This allows you to declare several parameters at once without a namespace.

The map contains default values for parameters. There is another overload which takes the std::pair with the default value and descriptor.

If `ignore_overrides` is `true`, all the overrides of the parameters declared by the function call will be ignored.

This method, if successful, will result in any callback registered with add_on_set_parameters_callback to be called, once for each parameter. If that callback prevents the initial value for any parameter from being set then rclcpp::exceptions::InvalidParameterValueException is thrown.
Parameters

[in]namespace_The namespace in which to declare the parameters.

[in]parametersThe parameters to set in the given namespace.

[in]ignore_overridesWhen `true`, the parameters overrides are ignored. Default to `false`.

Exceptions

rclcpp::exceptions::ParameterAlreadyDeclaredExceptionif parameter has already been declared.

rclcpp::exceptions::InvalidParametersExceptionif a parameter name is invalid.

rclcpp::exceptions::InvalidParameterValueExceptionif initial value fails to be set.

◆ declare_parameters() [2/2]

template<typename ParameterT >

std::vector< ParameterT > rclcpp::Node::declare_parameters (const std::string & namespace_,

const std::map< std::string, std::pair< ParameterT, rcl_interfaces::msg::ParameterDescriptor > > & parameters,

bool ignore_overrides = `false`

)

Declare and initialize several parameters with the same namespace and type.

This version will take a map where the value is a pair, with the default parameter value as the first item and a parameter descriptor as the second.

See the simpler declare_parameters() on this class for more details.

◆ undeclare_parameter()

void rclcpp::Node::undeclare_parameter (const std::string & name)

Undeclare a previously declared parameter.

This method will not cause a callback registered with add_on_set_parameters_callback to be called.
Parameters

[in]nameThe name of the parameter to be undeclared.

Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif the parameter has not been declared.

rclcpp::exceptions::ParameterImmutableExceptionif the parameter was create as read_only (immutable).

◆ has_parameter()

bool rclcpp::Node::has_parameter (const std::string & name) const

Return true if a given parameter is declared.
Parameters

[in]nameThe name of the parameter to check for being declared.

Returnstrue if the parameter name has been declared, otherwise false.

◆ set_parameter()

rcl_interfaces::msg::SetParametersResult rclcpp::Node::set_parameter (const rclcpp::Parameter & parameter)

Set a single parameter.

Set the given parameter and then return result of the set action.

If the parameter has not been declared this function may throw the rclcpp::exceptions::ParameterNotDeclaredException exception, but only if the node was not created with the rclcpp::NodeOptions::allow_undeclared_parameters set to true. If undeclared parameters are allowed, then the parameter is implicitly declared with the default parameter meta data before being set. Parameter overrides are ignored by set_parameter.

This method will result in any callback registered with add_on_set_parameters_callback to be called. If the callback prevents the parameter from being set, then it will be reflected in the SetParametersResult that is returned, but no exception will be thrown.

If the value type of the parameter is rclcpp::PARAMETER_NOT_SET, and the existing parameter type is something else, then the parameter will be implicitly undeclared. This will result in a parameter event indicating that the parameter was deleted.
Parameters

[in]parameterThe parameter to be set.

ReturnsThe result of the set action. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif the parameter has not been declared and undeclared parameters are not allowed.

◆ set_parameters()

std::vector<rcl_interfaces::msg::SetParametersResult> rclcpp::Node::set_parameters (const std::vector< rclcpp::Parameter > & parameters)

Set one or more parameters, one at a time.

Set the given parameters, one at a time, and then return result of each set action.

Parameters are set in the order they are given within the input vector.

Like set_parameter, if any of the parameters to be set have not first been declared, and undeclared parameters are not allowed (the default), then this method will throw rclcpp::exceptions::ParameterNotDeclaredException.

If setting a parameter fails due to not being declared, then the parameters which have already been set will stay set, and no attempt will be made to set the parameters which come after.

If a parameter fails to be set due to any other reason, like being rejected by the user's callback (basically any reason other than not having been declared beforehand), then that is reflected in the corresponding SetParametersResult in the vector returned by this function.

This method will result in any callback registered with add_on_set_parameters_callback to be called, once for each parameter. If the callback prevents the parameter from being set, then, as mentioned before, it will be reflected in the corresponding SetParametersResult that is returned, but no exception will be thrown.

Like set_parameter() this method will implicitly undeclare parameters with the type rclcpp::PARAMETER_NOT_SET.
Parameters

[in]parametersThe vector of parameters to be set.

ReturnsThe results for each set action as a vector. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif any parameter has not been declared and undeclared parameters are not allowed.

◆ set_parameters_atomically()

rcl_interfaces::msg::SetParametersResult rclcpp::Node::set_parameters_atomically (const std::vector< rclcpp::Parameter > & parameters)

Set one or more parameters, all at once.

Set the given parameters, all at one time, and then aggregate result.

Behaves like set_parameter, except that it sets multiple parameters, failing all if just one of the parameters are unsuccessfully set. Either all of the parameters are set or none of them are set.

Like set_parameter and set_parameters, this method may throw an rclcpp::exceptions::ParameterNotDeclaredException exception if any of the parameters to be set have not first been declared. If the exception is thrown then none of the parameters will have been set.

This method will result in any callback registered with add_on_set_parameters_callback to be called, just one time. If the callback prevents the parameters from being set, then it will be reflected in the SetParametersResult which is returned, but no exception will be thrown.

If you pass multiple rclcpp::Parameter instances with the same name, then only the last one in the vector (forward iteration) will be set.

Like set_parameter() this method will implicitly undeclare parameters with the type rclcpp::PARAMETER_NOT_SET.
Parameters

[in]parametersThe vector of parameters to be set.

ReturnsThe aggregate result of setting all the parameters atomically. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif any parameter has not been declared and undeclared parameters are not allowed.

◆ get_parameter() [1/3]

rclcpp::Parameter rclcpp::Node::get_parameter (const std::string & name) const

Return the parameter by the given name.

If the parameter has not been declared, then this method may throw the rclcpp::exceptions::ParameterNotDeclaredException exception.

If undeclared parameters are allowed, see the node option rclcpp::NodeOptions::allow_undeclared_parameters, then this method will not throw an exception, and instead return a default initialized rclcpp::Parameter, which has a type of rclcpp::ParameterType::PARAMETER_NOT_SET.
Parameters

[in]nameThe name of the parameter to get.

ReturnsThe requested parameter inside of a rclcpp parameter object. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif the parameter has not been declared and undeclared parameters are not allowed.

◆ get_parameter() [2/3]

bool rclcpp::Node::get_parameter (const std::string & name,

rclcpp::Parameter & parameter

) const

Get the value of a parameter by the given name, and return true if it was set.

This method will never throw the rclcpp::exceptions::ParameterNotDeclaredException exception, but will instead return false if the parameter has not be previously declared.

If the parameter was not declared, then the output argument for this method which is called "parameter" will not be assigned a value. If the parameter was declared, and therefore has a value, then it is assigned into the "parameter" argument of this method.
Parameters

[in]nameThe name of the parameter to get.

[out]parameterThe output storage for the parameter being retrieved.

Returnstrue if the parameter was previously declared, otherwise false.

◆ get_parameter() [3/3]

template<typename ParameterT >

bool rclcpp::Node::get_parameter (const std::string & name,

ParameterT & parameter

) const

Get the value of a parameter by the given name, and return true if it was set.

Identical to the non-templated version of this method, except that when assigning the output argument called "parameter", this method will attempt to coerce the parameter value into the type requested by the given template argument, which may fail and throw an exception.

If the parameter has not been declared, it will not attempt to coerce the value into the requested type, as it is known that the type is not set.
Exceptions

rclcpp::ParameterTypeExceptionif the requested type does not match the value of the parameter which is stored.

◆ get_parameter_or()

template<typename ParameterT >

bool rclcpp::Node::get_parameter_or (const std::string & name,

ParameterT & parameter,

const ParameterT & alternative_value

) const

Get the parameter value, or the "alternative_value" if not set, and assign it to "parameter".

If the parameter was not set, then the "parameter" argument is assigned the "alternative_value".

Like the version of get_parameter() which returns a bool, this method will not throw the rclcpp::exceptions::ParameterNotDeclaredException exception.

In all cases, the parameter is never set or declared within the node.
Parameters

[in]nameThe name of the parameter to get.

[out]parameterThe output where the value of the parameter should be assigned.

[in]alternative_valueValue to be stored in output if the parameter was not set.

Returnstrue if the parameter was set, false otherwise.

◆ get_parameters() [1/2]

std::vector<rclcpp::Parameter> rclcpp::Node::get_parameters (const std::vector< std::string > & names) const

Return the parameters by the given parameter names.

Like get_parameters(), this method may throw the rclcpp::exceptions::ParameterNotDeclaredException exception if the requested parameter has not been declared and undeclared parameters are not allowed.

Also like get_parameters(), if undeclared parameters are allowed and the parameter has not been declared, then the corresponding rclcpp::Parameter will be default initialized and therefore have the type rclcpp::ParameterType::PARAMETER_NOT_SET.
Parameters

[in]namesThe names of the parameters to be retrieved.

ReturnsThe parameters that were retrieved. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif any of the parameters have not been declared and undeclared parameters are not allowed.

◆ get_parameters() [2/2]

template<typename ParameterT >

bool rclcpp::Node::get_parameters (const std::string & prefix,

std::map< std::string, ParameterT > & values

) const

Get the parameter values for all parameters that have a given prefix.

The "prefix" argument is used to list the parameters which are prefixed with that prefix, see also list_parameters().

The resulting list of parameter names are used to get the values of the parameters.

The names which are used as keys in the values map have the prefix removed. For example, if you use the prefix "foo" and the parameters "foo.ping" and "foo.pong" exist, then the returned map will have the keys "ping" and "pong".

An empty string for the prefix will match all parameters.

If no parameters with the prefix are found, then the output parameter "values" will be unchanged and false will be returned. Otherwise, the parameter names and values will be stored in the map and true will be returned to indicate "values" was mutated.

This method will never throw the rclcpp::exceptions::ParameterNotDeclaredException exception because the action of listing the parameters is done atomically with getting the values, and therefore they are only listed if already declared and cannot be undeclared before being retrieved.

Like the templated get_parameter() variant, this method will attempt to coerce the parameter values into the type requested by the given template argument, which may fail and throw an exception.
Parameters

[in]prefixThe prefix of the parameters to get.

[out]valuesThe map used to store the parameter names and values, respectively, with one entry per parameter matching prefix.

Returnstrue if output "values" was changed, false otherwise. Exceptions

rclcpp::ParameterTypeExceptionif the requested type does not match the value of the parameter which is stored.

◆ describe_parameter()

rcl_interfaces::msg::ParameterDescriptor rclcpp::Node::describe_parameter (const std::string & name) const

Return the parameter descriptor for the given parameter name.

Like get_parameters(), this method may throw the rclcpp::exceptions::ParameterNotDeclaredException exception if the requested parameter has not been declared and undeclared parameters are not allowed.

If undeclared parameters are allowed, then a default initialized descriptor will be returned.
Parameters

[in]nameThe name of the parameter to describe.

ReturnsThe descriptor for the given parameter name. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif the parameter has not been declared and undeclared parameters are not allowed.

std::runtime_errorif the number of described parameters is more than one

◆ describe_parameters()

std::vector<rcl_interfaces::msg::ParameterDescriptor> rclcpp::Node::describe_parameters (const std::vector< std::string > & names) const

Return a vector of parameter descriptors, one for each of the given names.

Like get_parameters(), this method may throw the rclcpp::exceptions::ParameterNotDeclaredException exception if any of the requested parameters have not been declared and undeclared parameters are not allowed.

If undeclared parameters are allowed, then a default initialized descriptor will be returned for the undeclared parameter's descriptor.

If the names vector is empty, then an empty vector will be returned.
Parameters

[in]namesThe list of parameter names to describe.

ReturnsA list of parameter descriptors, one for each parameter given. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif any of the parameters have not been declared and undeclared parameters are not allowed.

std::runtime_errorif the number of described parameters is more than one

◆ get_parameter_types()

std::vector<uint8_t> rclcpp::Node::get_parameter_types (const std::vector< std::string > & names) const

Return a vector of parameter types, one for each of the given names.

Like get_parameters(), this method may throw the rclcpp::exceptions::ParameterNotDeclaredException exception if any of the requested parameters have not been declared and undeclared parameters are not allowed.

If undeclared parameters are allowed, then the default type rclcpp::ParameterType::PARAMETER_NOT_SET will be returned.
Parameters

[in]namesThe list of parameter names to get the types.

ReturnsA list of parameter types, one for each parameter given. Exceptions

rclcpp::exceptions::ParameterNotDeclaredExceptionif any of the parameters have not been declared and undeclared parameters are not allowed.

◆ list_parameters()

rcl_interfaces::msg::ListParametersResult rclcpp::Node::list_parameters (const std::vector< std::string > & prefixes,

uint64_t depth

) const

Return a list of parameters with any of the given prefixes, up to the given depth.
Todo:: properly document and test this method.

◆ add_on_set_parameters_callback()

RCUTILS_WARN_UNUSED OnSetParametersCallbackHandle::SharedPtr rclcpp::Node::add_on_set_parameters_callback (OnParametersSetCallbackTypecallback)

Add a callback for when parameters are being set.

The callback signature is designed to allow handling of any of the above `set_parameter*` or `declare_parameter*` methods, and so it takes a const reference to a vector of parameters to be set, and returns an instance of rcl_interfaces::msg::SetParametersResult to indicate whether or not the parameter should be set or not, and if not why.

For an example callback:

rcl_interfaces::msg::SetParametersResult

my_callback(conststd::vector<rclcpp::Parameter> & parameters)

{

rcl_interfaces::msg::SetParametersResult result;

result.successful = true;

for (constauto & parameter : parameters) {

if (!some_condition) {

result.successful = false;

result.reason = "the reason it could not be allowed";

}

}

return result;

}

You can see that the SetParametersResult is a boolean flag for success and an optional reason that can be used in error reporting when it fails.

This allows the node developer to control which parameters may be changed.

Note that the callback is called when declare_parameter() and its variants are called, and so you cannot assume the parameter has been set before this callback, so when checking a new value against the existing one, you must account for the case where the parameter is not yet set.

Some constraints like read_only are enforced before the callback is called.

The callback may introspect other already set parameters (by calling any of the {get,list,describe}_parameter() methods), but may not modify other parameters (by calling any of the {set,declare}_parameter() methods) or modify the registered callback itself (by calling the add_on_set_parameters_callback() method). If a callback tries to do any of the latter things, rclcpp::exceptions::ParameterModifiedInCallbackException will be thrown.

The callback functions must remain valid as long as the returned smart pointer is valid. The returned smart pointer can be promoted to a shared version.

Resetting or letting the smart pointer go out of scope unregisters the callback. `remove_on_set_parameters_callback` can also be used.

The registered callbacks are called when a parameter is set. When a callback returns a not successful result, the remaining callbacks aren't called. The order of the callback is the reverse from the registration order.
Parameters

callbackThe callback to register.

ReturnsA shared pointer. The callback is valid as long as the smart pointer is alive. Exceptions

std::bad_allocif the allocation of the OnSetParametersCallbackHandle fails.

◆ remove_on_set_parameters_callback()

void rclcpp::Node::remove_on_set_parameters_callback (const OnSetParametersCallbackHandle *const handler)

Remove a callback registered with `add_on_set_parameters_callback`.

Delete a handler returned by `add_on_set_parameters_callback`.

e.g.:

`remove_on_set_parameters_callback(scoped_callback.get())`

As an alternative, the smart pointer can be reset:

`scoped_callback.reset()`

Supposing that `scoped_callback` was the only owner.

Calling `remove_on_set_parameters_callback` more than once with the same handler, or calling it after the shared pointer has been reset is an error. Resetting or letting the smart pointer go out of scope after calling `remove_on_set_parameters_callback` is not a problem.
Parameters

handlerThe callback handler to remove.

Exceptions

std::runtime_errorif the handler was not created with `add_on_set_parameters_callback`, or if it has been removed before.

◆ set_on_parameters_set_callback()

OnParametersSetCallbackType rclcpp::Node::set_on_parameters_set_callback (rclcpp::Node::OnParametersSetCallbackTypecallback)

Register a callback to be called anytime a parameter is about to be changed.
Deprecated:Use add_on_set_parameters_callback instead. With this method, only one callback can be set at a time. The callback that was previously set by this method is returned or `nullptr` if no callback was previously set.
The callbacks added with `add_on_set_parameters_callback` are stored in a different place. `remove_on_set_parameters_callback` can't be used with the callbacks registered with this method. For removing it, use `set_on_parameters_set_callback(nullptr)`.
Parameters

[in]callbackThe callback to be called when the value for a parameter is about to be set.

ReturnsThe previous callback that was registered, if there was one, otherwise nullptr.

◆ get_node_names()

std::vector<std::string> rclcpp::Node::get_node_names () const

Get the fully-qualified names of all available nodes.

The fully-qualified name includes the local namespace and name of the node.
ReturnsA vector of fully-qualified names of nodes.

◆ get_topic_names_and_types()

std::map<std::string, std::vector<std::string> > rclcpp::Node::get_topic_names_and_types () const

Return a map of existing topic names to list of topic types.
Returnsa map of existing topic names to list of topic types. Exceptions

std::runtime_erroranything that rcl_error can throw

◆ get_service_names_and_types()

std::map<std::string, std::vector<std::string> > rclcpp::Node::get_service_names_and_types () const

Return a map of existing service names to list of service types.
Returnsa map of existing service names to list of service types. Exceptions

std::runtime_erroranything that rcl_error can throw

◆ get_service_names_and_types_by_node()

std::map<std::string, std::vector<std::string> > rclcpp::Node::get_service_names_and_types_by_node (const std::string & node_name,

const std::string & namespace_

) const

Return the number of publishers that are advertised on a given topic.
Parameters

[in]node_namethe node_name on which to count the publishers.

[in]namespace_the namespace of the node associated with the name

Returnsnumber of publishers that are advertised on a given topic. Exceptions

std::runtime_errorif publishers could not be counted

◆ count_publishers()

size_t rclcpp::Node::count_publishers (const std::string & topic_name) const

◆ count_subscribers()

size_t rclcpp::Node::count_subscribers (const std::string & topic_name) const

Return the number of subscribers who have created a subscription for a given topic.
Parameters

[in]topic_namethe topic_name on which to count the subscribers.

Returnsnumber of subscribers who have created a subscription for a given topic. Exceptions

std::runtime_errorif publishers could not be counted

◆ get_publishers_info_by_topic()

std::vector<rclcpp::TopicEndpointInfo> rclcpp::Node::get_publishers_info_by_topic (const std::string & topic_name,

bool no_mangle = `false`

) const

Return the topic endpoint information about publishers on a given topic.

The returned parameter is a list of topic endpoint information, where each item will contain the node name, node namespace, topic type, endpoint type, topic endpoint's GID, and its QoS profile.

When the `no_mangle` parameter is `true`, the provided `topic_name` should be a valid topic name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps). When the `no_mangle` parameter is `false`, the provided `topic_name` should follow ROS topic name conventions.

`topic_name` may be a relative, private, or fully qualified topic name. A relative or private topic will be expanded using this node's namespace and name. The queried `topic_name` is not remapped.
Parameters

[in]topic_namethe topic_name on which to find the publishers.

[in]no_mangleif `true`, `topic_name` needs to be a valid middleware topic name, otherwise it should be a valid ROS topic name. Defaults to `false`.

Returnsa list of TopicEndpointInfo representing all the publishers on this topic. Exceptions

InvalidTopicNameErrorif the given topic_name is invalid.

std::runtime_errorif internal error happens.

◆ get_subscriptions_info_by_topic()

std::vector<rclcpp::TopicEndpointInfo> rclcpp::Node::get_subscriptions_info_by_topic (const std::string & topic_name,

bool no_mangle = `false`

) const

Return the topic endpoint information about subscriptions on a given topic.

The returned parameter is a list of topic endpoint information, where each item will contain the node name, node namespace, topic type, endpoint type, topic endpoint's GID, and its QoS profile.

When the `no_mangle` parameter is `true`, the provided `topic_name` should be a valid topic name for the middleware (useful when combining ROS with native middleware (e.g. DDS) apps). When the `no_mangle` parameter is `false`, the provided `topic_name` should follow ROS topic name conventions.

`topic_name` may be a relative, private, or fully qualified topic name. A relative or private topic will be expanded using this node's namespace and name. The queried `topic_name` is not remapped.
Parameters

[in]topic_namethe topic_name on which to find the subscriptions.

[in]no_mangleif `true`, `topic_name` needs to be a valid middleware topic name, otherwise it should be a valid ROS topic name. Defaults to `false`.

Returnsa list of TopicEndpointInfo representing all the subscriptions on this topic. Exceptions

InvalidTopicNameErrorif the given topic_name is invalid.

std::runtime_errorif internal error happens.

◆ get_graph_event()

rclcpp::Event::SharedPtr rclcpp::Node::get_graph_event ()

Return a graph event, which will be set anytime a graph change occurs.

◆ wait_for_graph_change()

void rclcpp::Node::wait_for_graph_change (rclcpp::Event::SharedPtr event,

std::chrono::nanosecondstimeout

)

Wait for a graph event to occur by waiting on an Event to become set.

The given Event must be acquire through the get_graph_event() method.
Parameters

[in]eventpointer to an Event to wait for

[in]timeoutnanoseconds to wait for the Event to change the state

Exceptions

InvalidEventErrorif the given event is nullptr

EventNotRegisteredErrorif the given event was not acquired with get_graph_event().

◆ get_clock() [1/2]

rclcpp::Clock::SharedPtr rclcpp::Node::get_clock ()

Get a clock as a non-const shared pointer which is managed by the node.
See alsorclcpp::node_interfaces::NodeClock::get_clock

◆ get_clock() [2/2]

rclcpp::Clock::ConstSharedPtr rclcpp::Node::get_clock () const

Get a clock as a const shared pointer which is managed by the node.
See alsorclcpp::node_interfaces::NodeClock::get_clock

◆ now()

Time rclcpp::Node::now () const

Returns current time from the time source specified by clock_type.
See alsorclcpp::Clock::now

◆ get_node_base_interface()

rclcpp::node_interfaces::NodeBaseInterface::SharedPtr rclcpp::Node::get_node_base_interface ()

Return the Node's internal NodeBaseInterface implementation.

◆ get_node_clock_interface()

rclcpp::node_interfaces::NodeClockInterface::SharedPtr rclcpp::Node::get_node_clock_interface ()

Return the Node's internal NodeClockInterface implementation.

◆ get_node_graph_interface()

rclcpp::node_interfaces::NodeGraphInterface::SharedPtr rclcpp::Node::get_node_graph_interface ()

Return the Node's internal NodeGraphInterface implementation.

◆ get_node_logging_interface()

rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr rclcpp::Node::get_node_logging_interface ()

Return the Node's internal NodeLoggingInterface implementation.

◆ get_node_timers_interface()

rclcpp::node_interfaces::NodeTimersInterface::SharedPtr rclcpp::Node::get_node_timers_interface ()

Return the Node's internal NodeTimersInterface implementation.

◆ get_node_topics_interface()

rclcpp::node_interfaces::NodeTopicsInterface::SharedPtr rclcpp::Node::get_node_topics_interface ()

Return the Node's internal NodeTopicsInterface implementation.

◆ get_node_services_interface()

rclcpp::node_interfaces::NodeServicesInterface::SharedPtr rclcpp::Node::get_node_services_interface ()

Return the Node's internal NodeServicesInterface implementation.

◆ get_node_waitables_interface()

rclcpp::node_interfaces::NodeWaitablesInterface::SharedPtr rclcpp::Node::get_node_waitables_interface ()

Return the Node's internal NodeWaitablesInterface implementation.

◆ get_node_parameters_interface()

rclcpp::node_interfaces::NodeParametersInterface::SharedPtr rclcpp::Node::get_node_parameters_interface ()

Return the Node's internal NodeParametersInterface implementation.

◆ get_node_time_source_interface()

rclcpp::node_interfaces::NodeTimeSourceInterface::SharedPtr rclcpp::Node::get_node_time_source_interface ()

Return the Node's internal NodeTimeSourceInterface implementation.

◆ get_sub_namespace()

const std::string& rclcpp::Node::get_sub_namespace () const

Return the sub-namespace, if this is a sub-node, otherwise an empty string.

The returned sub-namespace is either the accumulated sub-namespaces which were given to one-to-many create_sub_node() calls, or an empty string if this is an original node instance, i.e. not a sub-node.

For example, consider:

auto node = std::make_shared<rclcpp::Node>("my_node", "my_ns");

node->get_sub_namespace();  // -> ""

auto sub_node1 = node->create_sub_node("a");

sub_node1->get_sub_namespace();  // -> "a"

auto sub_node2 = sub_node1->create_sub_node("b");

sub_node2->get_sub_namespace();  // -> "a/b"

auto sub_node3 = node->create_sub_node("foo");

sub_node3->get_sub_namespace();  // -> "foo"

node->get_sub_namespace();  // -> ""

get_namespace() will return the original node namespace, and will not include the sub-namespace if one exists. To get that you need to call the get_effective_namespace() method.
See alsoget_namespace()get_effective_namespace()Returnsthe sub-namespace string, not including the node's original namespace

◆ get_effective_namespace()

const std::string& rclcpp::Node::get_effective_namespace () const

Return the effective namespace that is used when creating entities.

The returned namespace is a concatenation of the node namespace and the accumulated sub-namespaces, which is used as the namespace when creating entities which have relative names.

For example, consider:

auto node = std::make_shared<rclcpp::Node>("my_node", "my_ns");

node->get_effective_namespace();  // -> "/my_ns"

auto sub_node1 = node->create_sub_node("a");

sub_node1->get_effective_namespace();  // -> "/my_ns/a"

auto sub_node2 = sub_node1->create_sub_node("b");

sub_node2->get_effective_namespace();  // -> "/my_ns/a/b"

auto sub_node3 = node->create_sub_node("foo");

sub_node3->get_effective_namespace();  // -> "/my_ns/foo"

node->get_effective_namespace();  // -> "/my_ns"

See alsoget_namespace()get_sub_namespace()Returnsthe sub-namespace string, not including the node's original namespace

◆ create_sub_node()

rclcpp::Node::SharedPtr rclcpp::Node::create_sub_node (const std::string & sub_namespace)

Create a sub-node, which will extend the namespace of all entities created with it.

A sub-node (short for subordinate node) is an instance of this class which has been created using an existing instance of this class, but which has an additional sub-namespace (short for subordinate namespace) associated with it. The sub-namespace will extend the node's namespace for the purpose of creating additional entities, such as Publishers, Subscriptions, Service Clients and Servers, and so on.

By default, when an instance of this class is created using one of the public constructors, it has no sub-namespace associated with it, and therefore is not a sub-node. That "normal" node instance may, however, be used to create further instances of this class, based on the original instance, which have an additional sub-namespace associated with them. This may be done by using this method, create_sub_node().

Furthermore, a sub-node may be used to create additional sub-node's, in which case the sub-namespace passed to this function will further extend the sub-namespace of the existing sub-node. See get_sub_namespace() and get_effective_namespace() for examples.

Note that entities which use absolute names are not affected by any namespaces, neither the normal node namespace nor any sub-namespace. Note also that the fully qualified node name is unaffected by a sub-namespace.

The sub-namespace should be relative, and an exception will be thrown if the sub-namespace is absolute, i.e. if it starts with a leading '/'.
See alsoget_sub_namespace()get_effective_namespace()Parameters

[in]sub_namespacesub-namespace of the sub-node.

Returnsnewly created sub-node Exceptions

NameValidationErrorif the sub-namespace is absolute, i.e. starts with a leading '/'.

◆ get_node_options()

const rclcpp::NodeOptions& rclcpp::Node::get_node_options () const

Return the NodeOptions used when creating this node.

◆ create_client() [2/2]

template<typename ServiceT >

Client<ServiceT>::SharedPtr rclcpp::Node::create_client (const std::string & service_name,

const rmw_qos_profile_t & qos_profile,

rclcpp::CallbackGroup::SharedPtr group

)

The documentation for this class was generated from the following files:

- include/rclcpp/node.hpp
- include/rclcpp/node_impl.hpp

std::vector< rclcpp::Parameter >

rclcpp::QoS

Encapsulation of Quality of Service settings.

Definition: qos.hpp:59

Generated by   1.8.17
