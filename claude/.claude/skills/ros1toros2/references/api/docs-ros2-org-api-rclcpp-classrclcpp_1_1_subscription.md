---
source_url: https://docs.ros2.org/latest/api/rclcpp/classrclcpp_1_1Subscription.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp: rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT > Class Template Reference

rclcpp: rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT > Class Template Reference

rclcpp
master

C++ ROS Client Library API

- rclcpp
- Subscription

Public Types |
Public Member Functions |
Friends |
List of all members

rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT > Class Template Reference

Subscription implementation, templated on the type of message this subscription receives.
More...

`#include <subscription.hpp>`

Inheritance diagram for rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >:

[legend]

Collaboration diagram for rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >:

[legend]

Public Types

using MessageAllocatorTraits = allocator::AllocRebind< CallbackMessageT, AllocatorT >

using MessageAllocator = typename MessageAllocatorTraits::allocator_type

using MessageDeleter = allocator::Deleter< MessageAllocator, CallbackMessageT >

using ConstMessageSharedPtr = std::shared_ptr< const CallbackMessageT >

using MessageUniquePtr = std::unique_ptr< CallbackMessageT, MessageDeleter >

using SubscriptionTopicStatisticsSharedPtr = std::shared_ptr< rclcpp::topic_statistics::SubscriptionTopicStatistics< CallbackMessageT > >

Public Types inherited from rclcpp::SubscriptionBase

using IntraProcessManagerWeakPtr = std::weak_ptr< rclcpp::experimental::IntraProcessManager >

Public Member Functions

Subscription (rclcpp::node_interfaces::NodeBaseInterface *node_base, const rosidl_message_type_support_t &type_support_handle, const std::string &topic_name, const rclcpp::QoS &qos, AnySubscriptionCallback< CallbackMessageT, AllocatorT > callback, const rclcpp::SubscriptionOptionsWithAllocator< AllocatorT > &options, typename MessageMemoryStrategyT::SharedPtr message_memory_strategy, SubscriptionTopicStatisticsSharedPtr subscription_topic_statistics=nullptr)

Default constructor.  More...

void post_init_setup (rclcpp::node_interfaces::NodeBaseInterface *node_base, const rclcpp::QoS &qos, const rclcpp::SubscriptionOptionsWithAllocator< AllocatorT > &options)

Called after construction to continue setup that requires shared_from_this().  More...

bool take (CallbackMessageT &message_out, rclcpp::MessageInfo &message_info_out)

Take the next message from the inter-process subscription.  More...

std::shared_ptr< void > create_message () override

Borrow a new message.  More...

std::shared_ptr< rclcpp::SerializedMessage > create_serialized_message () override

Borrow a new serialized message.  More...

void handle_message (std::shared_ptr< void > &message, const rclcpp::MessageInfo &message_info) override

Check if we need to handle the message, and execute the callback if we do.  More...

void handle_loaned_message (void *loaned_message, const rclcpp::MessageInfo &message_info) override

void return_message (std::shared_ptr< void > &message) override

Return the borrowed message.  More...

void return_serialized_message (std::shared_ptr< rclcpp::SerializedMessage > &message) override

Return the borrowed serialized message.  More...

bool use_take_shared_method () const

Public Member Functions inherited from rclcpp::SubscriptionBase

SubscriptionBase (rclcpp::node_interfaces::NodeBaseInterface *node_base, const rosidl_message_type_support_t &type_support_handle, const std::string &topic_name, const rcl_subscription_options_t &subscription_options, bool is_serialized=false)

Default constructor.  More...

virtual ~SubscriptionBase ()

Default destructor.  More...

const char * get_topic_name () const

Get the topic that this subscription is subscribed on.  More...

std::shared_ptr< rcl_subscription_t > get_subscription_handle ()

std::shared_ptr< const rcl_subscription_t > get_subscription_handle () const

const std::vector< std::shared_ptr< rclcpp::QOSEventHandlerBase > > & get_event_handlers () const

Get all the QoS event handlers associated with this subscription.  More...

rclcpp::QoSget_actual_qos () const

Get the actual QoS settings, after the defaults have been determined.  More...

bool take_type_erased (void *message_out, rclcpp::MessageInfo &message_info_out)

Take the next inter-process message from the subscription as a type erased pointer.  More...

bool take_serialized (rclcpp::SerializedMessage &message_out, rclcpp::MessageInfo &message_info_out)

Take the next inter-process message, in its serialized form, from the subscription.  More...

const rosidl_message_type_support_t & get_message_type_support_handle () const

bool is_serialized () const

Return if the subscription is serialized.  More...

size_t get_publisher_count () const

Get matching publisher count.  More...

bool can_loan_messages () const

Check if subscription instance can loan messages.  More...

void setup_intra_process (uint64_t intra_process_subscription_id, IntraProcessManagerWeakPtr weak_ipm)

Implemenation detail.  More...

rclcpp::Waitable::SharedPtr get_intra_process_waitable () const

Return the waitable for intra-process.  More...

bool exchange_in_use_by_wait_set_state (void *pointer_to_subscription_part, bool in_use_state)

Exchange state of whether or not a part of the subscription is used by a wait set.  More...

Public Member Functions inherited from std::enable_shared_from_this< SubscriptionBase >

T enable_shared_from_this (T... args)

T operator= (T... args)

T shared_from_this (T... args)

T ~enable_shared_from_this (T... args)

Friends

class rclcpp::node_interfaces::NodeTopicsInterface

Additional Inherited Members

Protected Member Functions inherited from rclcpp::SubscriptionBase

template<typename EventCallbackT >

void add_event_handler (const EventCallbackT &callback, const rcl_subscription_event_type_t event_type)

void default_incompatible_qos_callback (QOSRequestedIncompatibleQoSInfo &info) const

bool matches_any_intra_process_publishers (const rmw_gid_t *sender_gid) const

Protected Attributes inherited from rclcpp::SubscriptionBase

rclcpp::node_interfaces::NodeBaseInterface *const node_base_

std::shared_ptr< rcl_node_t > node_handle_

std::shared_ptr< rcl_subscription_t > subscription_handle_

std::shared_ptr< rcl_subscription_t > intra_process_subscription_handle_

std::vector< std::shared_ptr< rclcpp::QOSEventHandlerBase > > event_handlers_

bool use_intra_process_

IntraProcessManagerWeakPtrweak_ipm_

uint64_t intra_process_subscription_id_

Detailed Description

template<typename CallbackMessageT, typename AllocatorT = std::allocator<void>, typename MessageMemoryStrategyT = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

class rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >

Subscription implementation, templated on the type of message this subscription receives.

Member Typedef Documentation

◆ MessageAllocatorTraits

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::MessageAllocatorTraits =  allocator::AllocRebind<CallbackMessageT, AllocatorT>

◆ MessageAllocator

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::MessageAllocator =  typename MessageAllocatorTraits::allocator_type

◆ MessageDeleter

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::MessageDeleter =  allocator::Deleter<MessageAllocator, CallbackMessageT>

◆ ConstMessageSharedPtr

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::ConstMessageSharedPtr =  std::shared_ptr<const CallbackMessageT>

◆ MessageUniquePtr

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::MessageUniquePtr =  std::unique_ptr<CallbackMessageT, MessageDeleter>

◆ SubscriptionTopicStatisticsSharedPtr

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

using rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::SubscriptionTopicStatisticsSharedPtr =  std::shared_ptr<rclcpp::topic_statistics::SubscriptionTopicStatistics<CallbackMessageT> >

Constructor & Destructor Documentation

◆ Subscription()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::Subscription(rclcpp::node_interfaces::NodeBaseInterface * node_base,

const rosidl_message_type_support_t & type_support_handle,

const std::string & topic_name,

const rclcpp::QoS & qos,

AnySubscriptionCallback< CallbackMessageT, AllocatorT > callback,

const rclcpp::SubscriptionOptionsWithAllocator< AllocatorT > & options,

typename MessageMemoryStrategyT::SharedPtr message_memory_strategy,

SubscriptionTopicStatisticsSharedPtrsubscription_topic_statistics = `nullptr`

)

inline

Default constructor.

The constructor for a subscription is almost never called directly. Instead, subscriptions should be instantiated through the function rclcpp::create_subscription().
Parameters

[in]node_baseNodeBaseInterface pointer that is used in part of the setup.

[in]type_support_handlerosidl type support struct, for the Message type of the topic.

[in]topic_nameName of the topic to subscribe to.

[in]qosQoS profile for Subcription.

[in]callbackUser defined callback to call when a message is received.

[in]optionsoptions for the subscription.

[in]message_memory_strategyThe memory strategy to be used for managing message memory.

[in]subscription_topic_statisticsOptional pointer to a topic statistics subcription.

Exceptions

std::invalid_argumentif the QoS is uncompatible with intra-process (if one of the following conditions are true: qos_profile.history == RMW_QOS_POLICY_HISTORY_KEEP_ALL, qos_profile.depth == 0 or qos_profile.durability != RMW_QOS_POLICY_DURABILITY_VOLATILE).

Member Function Documentation

◆ post_init_setup()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

void rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::post_init_setup (rclcpp::node_interfaces::NodeBaseInterface * node_base,

const rclcpp::QoS & qos,

const rclcpp::SubscriptionOptionsWithAllocator< AllocatorT > & options

)

inline

Called after construction to continue setup that requires shared_from_this().

◆ take()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

bool rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::take (CallbackMessageT & message_out,

rclcpp::MessageInfo & message_info_out

)

inline

Take the next message from the inter-process subscription.

Data may be taken (written) into the message_out and message_info_out even if false is returned. Specifically in the case of dropping redundant intra-process data, where data is received via both intra-process and inter-process (due to the underlying middleware being unabled to avoid this duplicate delivery) and so inter-process data from those intra-process publishers is ignored, but it has to be taken to know if it came from an intra-process publisher or not, and therefore could be dropped.
See alsoSubscriptionBase::take_type_erased()Parameters

[out]message_outThe message into which take will copy the data.

[out]message_info_outThe message info for the taken message.

Returnstrue if data was taken and is valid, otherwise false Exceptions

anyrcl errors from rcl_take,

See alsorclcpp::exceptions::throw_from_rcl_error()

◆ create_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

std::shared_ptr<void> rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::create_message ()

inlineoverridevirtual

Borrow a new message.
ReturnsShared pointer to the fresh message.
Implements rclcpp::SubscriptionBase.

◆ create_serialized_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

std::shared_ptr<rclcpp::SerializedMessage> rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::create_serialized_message ()

inlineoverridevirtual

Borrow a new serialized message.
ReturnsShared pointer to a rcl_message_serialized_t.
Implements rclcpp::SubscriptionBase.

◆ handle_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

void rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::handle_message (std::shared_ptr< void > & message,

const rclcpp::MessageInfo & message_info

)

inlineoverridevirtual

Check if we need to handle the message, and execute the callback if we do.
Parameters

[in]messageShared pointer to the message to handle.

[in]message_infoMetadata associated with this message.

Implements rclcpp::SubscriptionBase.

◆ handle_loaned_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

void rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::handle_loaned_message (void * loaned_message,

const rclcpp::MessageInfo & message_info

)

inlineoverridevirtual

Implements rclcpp::SubscriptionBase.

◆ return_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

void rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::return_message (std::shared_ptr< void > & message)

inlineoverridevirtual

Return the borrowed message.
Parameters

[in,out]messagemessage to be returned

Implements rclcpp::SubscriptionBase.

◆ return_serialized_message()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

void rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::return_serialized_message (std::shared_ptr< rclcpp::SerializedMessage > & message)

inlineoverridevirtual

Return the borrowed serialized message.
Parameters

[in,out]messageserialized message to be returned

Implements rclcpp::SubscriptionBase.

◆ use_take_shared_method()

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

bool rclcpp::Subscription< CallbackMessageT, AllocatorT, MessageMemoryStrategyT >::use_take_shared_method () const

inline

Friends And Related Function Documentation

◆ rclcpp::node_interfaces::NodeTopicsInterface

template<typename CallbackMessageT , typename AllocatorT  = std::allocator<void>, typename MessageMemoryStrategyT  = rclcpp::message_memory_strategy::MessageMemoryStrategy<    CallbackMessageT,    AllocatorT  >>

friend class rclcpp::node_interfaces::NodeTopicsInterface

friend

The documentation for this class was generated from the following file:

- include/rclcpp/subscription.hpp

Generated by   1.8.17
