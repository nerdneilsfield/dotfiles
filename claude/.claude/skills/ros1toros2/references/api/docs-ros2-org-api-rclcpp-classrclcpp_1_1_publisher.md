---
source_url: https://docs.ros2.org/latest/api/rclcpp/classrclcpp_1_1Publisher.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp: rclcpp::Publisher< MessageT, AllocatorT > Class Template Reference

rclcpp: rclcpp::Publisher< MessageT, AllocatorT > Class Template Reference

rclcpp
master

C++ ROS Client Library API

- rclcpp
- Publisher

Public Types |
Public Member Functions |
Protected Member Functions |
Protected Attributes |
List of all members

rclcpp::Publisher< MessageT, AllocatorT > Class Template Reference

A publisher publishes messages of any type to a topic.
More...

`#include <publisher.hpp>`

Inheritance diagram for rclcpp::Publisher< MessageT, AllocatorT >:

[legend]

Collaboration diagram for rclcpp::Publisher< MessageT, AllocatorT >:

[legend]

Public Types

using MessageAllocatorTraits = allocator::AllocRebind< MessageT, AllocatorT >

using MessageAllocator = typename MessageAllocatorTraits::allocator_type

using MessageDeleter = allocator::Deleter< MessageAllocator, MessageT >

using MessageUniquePtr = std::unique_ptr< MessageT, MessageDeleter >

using MessageSharedPtr = std::shared_ptr< const MessageT >

Public Types inherited from rclcpp::PublisherBase

using IntraProcessManagerSharedPtr = std::shared_ptr< rclcpp::experimental::IntraProcessManager >

Public Member Functions

Publisher (rclcpp::node_interfaces::NodeBaseInterface *node_base, const std::string &topic, const rclcpp::QoS &qos, const rclcpp::PublisherOptionsWithAllocator< AllocatorT > &options)

Default constructor.  More...

virtual void post_init_setup (rclcpp::node_interfaces::NodeBaseInterface *node_base, const std::string &topic, const rclcpp::QoS &qos, const rclcpp::PublisherOptionsWithAllocator< AllocatorT > &options)

Called post construction, so that construction may continue after shared_from_this() works.  More...

virtual ~Publisher ()

rclcpp::LoanedMessage< MessageT, AllocatorT > borrow_loaned_message ()

Borrow a loaned ROS message from the middleware.  More...

virtual void publish (std::unique_ptr< MessageT, MessageDeleter > msg)

Send a message to the topic for this publisher.  More...

virtual void publish (const MessageT &msg)

void publish (const rcl_serialized_message_t &serialized_msg)

void publish (const SerializedMessage &serialized_msg)

void publish (rclcpp::LoanedMessage< MessageT, AllocatorT > &&loaned_msg)

Publish an instance of a LoanedMessage.  More...

std::shared_ptr< MessageAllocator > get_allocator () const

Public Member Functions inherited from rclcpp::PublisherBase

PublisherBase (rclcpp::node_interfaces::NodeBaseInterface *node_base, const std::string &topic, const rosidl_message_type_support_t &type_support, const rcl_publisher_options_t &publisher_options)

Default constructor.  More...

virtual ~PublisherBase ()

const char * get_topic_name () const

Get the topic that this publisher publishes on.  More...

size_t get_queue_size () const

Get the queue size for this publisher.  More...

const rmw_gid_t & get_gid () const

Get the global identifier for this publisher (used in rmw and by DDS).  More...

std::shared_ptr< rcl_publisher_t > get_publisher_handle ()

Get the rcl publisher handle.  More...

std::shared_ptr< const rcl_publisher_t > get_publisher_handle () const

Get the rcl publisher handle.  More...

const std::vector< std::shared_ptr< rclcpp::QOSEventHandlerBase > > & get_event_handlers () const

Get all the QoS event handlers associated with this publisher.  More...

size_t get_subscription_count () const

Get subscription count.  More...

size_t get_intra_process_subscription_count () const

Get intraprocess subscription count.  More...

RCUTILS_WARN_UNUSED bool assert_liveliness () const

Manually assert that this Publisher is alive (for RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC).  More...

rclcpp::QoSget_actual_qos () const

Get the actual QoS settings, after the defaults have been determined.  More...

bool can_loan_messages () const

Check if publisher instance can loan messages.  More...

bool operator== (const rmw_gid_t &gid) const

Compare this publisher to a gid.  More...

bool operator== (const rmw_gid_t *gid) const

Compare this publisher to a pointer gid.  More...

void setup_intra_process (uint64_t intra_process_publisher_id, IntraProcessManagerSharedPtr ipm)

Implementation utility function used to setup intra process publishing after creation.  More...

Public Member Functions inherited from std::enable_shared_from_this< PublisherBase >

T enable_shared_from_this (T... args)

T operator= (T... args)

T shared_from_this (T... args)

T ~enable_shared_from_this (T... args)

Protected Member Functions

void do_inter_process_publish (const MessageT &msg)

void do_serialized_publish (const rcl_serialized_message_t *serialized_msg)

void do_loaned_message_publish (MessageT *msg)

void do_intra_process_publish (std::unique_ptr< MessageT, MessageDeleter > msg)

std::shared_ptr< const MessageT > do_intra_process_publish_and_return_shared (std::unique_ptr< MessageT, MessageDeleter > msg)

Protected Member Functions inherited from rclcpp::PublisherBase

template<typename EventCallbackT >

void add_event_handler (const EventCallbackT &callback, const rcl_publisher_event_type_t event_type)

void default_incompatible_qos_callback (QOSOfferedIncompatibleQoSInfo &info) const

Protected Attributes

const rclcpp::PublisherOptionsWithAllocator< AllocatorT > options_

Copy of original options passed during construction.  More...

std::shared_ptr< MessageAllocator > message_allocator_

MessageDeletermessage_deleter_

Protected Attributes inherited from rclcpp::PublisherBase

std::shared_ptr< rcl_node_t > rcl_node_handle_

std::shared_ptr< rcl_publisher_t > publisher_handle_

std::vector< std::shared_ptr< rclcpp::QOSEventHandlerBase > > event_handlers_

bool intra_process_is_enabled_

IntraProcessManagerWeakPtrweak_ipm_

uint64_t intra_process_publisher_id_

rmw_gid_trmw_gid_

Additional Inherited Members

Protected Types inherited from rclcpp::PublisherBase

using IntraProcessManagerWeakPtr = std::weak_ptr< rclcpp::experimental::IntraProcessManager >

Detailed Description

template<typename MessageT, typename AllocatorT = std::allocator<void>>

class rclcpp::Publisher< MessageT, AllocatorT >

A publisher publishes messages of any type to a topic.

Member Typedef Documentation

◆ MessageAllocatorTraits

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

using rclcpp::Publisher< MessageT, AllocatorT >::MessageAllocatorTraits =  allocator::AllocRebind<MessageT, AllocatorT>

◆ MessageAllocator

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

using rclcpp::Publisher< MessageT, AllocatorT >::MessageAllocator =  typename MessageAllocatorTraits::allocator_type

◆ MessageDeleter

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

using rclcpp::Publisher< MessageT, AllocatorT >::MessageDeleter =  allocator::Deleter<MessageAllocator, MessageT>

◆ MessageUniquePtr

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

using rclcpp::Publisher< MessageT, AllocatorT >::MessageUniquePtr =  std::unique_ptr<MessageT, MessageDeleter>

◆ MessageSharedPtr

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

using rclcpp::Publisher< MessageT, AllocatorT >::MessageSharedPtr =  std::shared_ptr<const MessageT>

Constructor & Destructor Documentation

◆ Publisher()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

rclcpp::Publisher< MessageT, AllocatorT >::Publisher(rclcpp::node_interfaces::NodeBaseInterface * node_base,

const std::string & topic,

const rclcpp::QoS & qos,

const rclcpp::PublisherOptionsWithAllocator< AllocatorT > & options

)

inline

Default constructor.

The constructor for a Publisher is almost never called directly. Instead, subscriptions should be instantiated through the function rclcpp::create_publisher().
Parameters

[in]node_baseNodeBaseInterface pointer that is used in part of the setup.

[in]topicName of the topic to publish to.

[in]qosQoS profile for Subcription.

[in]optionsoptions for the subscription.

◆ ~Publisher()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

virtual rclcpp::Publisher< MessageT, AllocatorT >::~Publisher()

inlinevirtual

Member Function Documentation

◆ post_init_setup()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

virtual void rclcpp::Publisher< MessageT, AllocatorT >::post_init_setup (rclcpp::node_interfaces::NodeBaseInterface * node_base,

const std::string & topic,

const rclcpp::QoS & qos,

const rclcpp::PublisherOptionsWithAllocator< AllocatorT > & options

)

inlinevirtual

Called post construction, so that construction may continue after shared_from_this() works.

◆ borrow_loaned_message()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

rclcpp::LoanedMessage<MessageT, AllocatorT> rclcpp::Publisher< MessageT, AllocatorT >::borrow_loaned_message ()

inline

Borrow a loaned ROS message from the middleware.

If the middleware is capable of loaning memory for a ROS message instance, the loaned message will be directly allocated in the middleware. If not, the message allocator of this rclcpp::Publisher instance is being used.

With a call to
See also`publish` the LoanedMessage instance is being returned to the middleware or free'd accordingly to the allocator. If the message is not being published but processed differently, the destructor of this class will either return the message to the middleware or deallocate it via the internal allocator. rclcpp::LoanedMessage for details of the LoanedMessage class.ReturnsLoanedMessage containing memory for a ROS message of type MessageT

◆ publish() [1/5]

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

virtual void rclcpp::Publisher< MessageT, AllocatorT >::publish (std::unique_ptr< MessageT, MessageDeleter > msg)

inlinevirtual

Send a message to the topic for this publisher.

This function is templated on the input message type, MessageT.
Parameters

[in]msgA shared pointer to the message to send.

◆ publish() [2/5]

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

virtual void rclcpp::Publisher< MessageT, AllocatorT >::publish (const MessageT & msg)

inlinevirtual

◆ publish() [3/5]

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::publish (const rcl_serialized_message_t & serialized_msg)

inline

◆ publish() [4/5]

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::publish (const SerializedMessage & serialized_msg)

inline

◆ publish() [5/5]

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::publish (rclcpp::LoanedMessage< MessageT, AllocatorT > && loaned_msg)

inline

Publish an instance of a LoanedMessage.

When publishing a loaned message, the memory for this ROS message will be deallocated after being published. The instance of the loaned message is no longer valid after this call.
Parameters

loaned_msgThe LoanedMessage instance to be published.

◆ get_allocator()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

std::shared_ptr<MessageAllocator> rclcpp::Publisher< MessageT, AllocatorT >::get_allocator () const

inline

◆ do_inter_process_publish()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::do_inter_process_publish (const MessageT & msg)

inlineprotected

◆ do_serialized_publish()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::do_serialized_publish (const rcl_serialized_message_t * serialized_msg)

inlineprotected

◆ do_loaned_message_publish()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::do_loaned_message_publish (MessageT * msg)

inlineprotected

◆ do_intra_process_publish()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

void rclcpp::Publisher< MessageT, AllocatorT >::do_intra_process_publish (std::unique_ptr< MessageT, MessageDeleter > msg)

inlineprotected

◆ do_intra_process_publish_and_return_shared()

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

std::shared_ptr<const MessageT> rclcpp::Publisher< MessageT, AllocatorT >::do_intra_process_publish_and_return_shared (std::unique_ptr< MessageT, MessageDeleter > msg)

inlineprotected

Member Data Documentation

◆ options_

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

const rclcpp::PublisherOptionsWithAllocator<AllocatorT> rclcpp::Publisher< MessageT, AllocatorT >::options_

protected

Copy of original options passed during construction.

It is important to save a copy of this so that the rmw payload which it may contain is kept alive for the duration of the publisher.

◆ message_allocator_

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

std::shared_ptr<MessageAllocator> rclcpp::Publisher< MessageT, AllocatorT >::message_allocator_

protected

◆ message_deleter_

template<typename MessageT , typename AllocatorT  = std::allocator<void>>

MessageDeleterrclcpp::Publisher< MessageT, AllocatorT >::message_deleter_

protected

The documentation for this class was generated from the following file:

- include/rclcpp/publisher.hpp

Generated by   1.8.17
