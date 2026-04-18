---
source_url: https://docs.ros2.org/latest/api/rclcpp_action/classrclcpp__action_1_1Server.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp_action: rclcpp_action::Server< ActionT > Class Template Reference

rclcpp_action: rclcpp_action::Server< ActionT > Class Template Reference

rclcpp_action
master

C++ ROS Action Client Library

- rclcpp_action
- Server

Public Types |
Public Member Functions |
Protected Member Functions |
List of all members

rclcpp_action::Server< ActionT > Class Template Reference

Action Server.
More...

`#include <server.hpp>`

Inheritance diagram for rclcpp_action::Server< ActionT >:

[legend]

Collaboration diagram for rclcpp_action::Server< ActionT >:

[legend]

Public Types

using GoalCallback = std::function< GoalResponse(const GoalUUID &, std::shared_ptr< const typename ActionT::Goal >)>

Signature of a callback that accepts or rejects goal requests.  More...

using CancelCallback = std::function< CancelResponse(std::shared_ptr< ServerGoalHandle< ActionT > >)>

Signature of a callback that accepts or rejects requests to cancel a goal.  More...

using AcceptedCallback = std::function< void(std::shared_ptr< ServerGoalHandle< ActionT > >)>

Signature of a callback that is used to notify when the goal has been accepted.  More...

Public Member Functions

Server (rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base, rclcpp::node_interfaces::NodeClockInterface::SharedPtr node_clock, rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging, const std::string &name, const rcl_action_server_options_t &options, GoalCallback handle_goal, CancelCallback handle_cancel, AcceptedCallback handle_accepted)

Construct an action server.  More...

virtual ~Server ()=default

Public Member Functions inherited from rclcpp_action::ServerBase

virtual RCLCPP_ACTION_PUBLIC~ServerBase ()

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_subscriptions () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_timers () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_clients () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_services () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_guard_conditions () override

RCLCPP_ACTION_PUBLIC bool add_to_wait_set (rcl_wait_set_t *wait_set) override

RCLCPP_ACTION_PUBLIC bool is_ready (rcl_wait_set_t *) override

RCLCPP_ACTION_PUBLIC void execute () override

Public Member Functions inherited from rclcpp::Waitable

virtual ~Waitable ()=default

virtual size_t get_number_of_ready_events ()

bool exchange_in_use_by_wait_set_state (bool in_use_state)

Public Member Functions inherited from std::enable_shared_from_this< Server< ActionT > >

T enable_shared_from_this (T... args)

T operator= (T... args)

T shared_from_this (T... args)

T ~enable_shared_from_this (T... args)

Protected Member Functions

std::pair< GoalResponse, std::shared_ptr< void > > call_handle_goal_callback (GoalUUID &uuid, std::shared_ptr< void > message) override

CancelResponsecall_handle_cancel_callback (const GoalUUID &uuid) override

void call_goal_accepted_callback (std::shared_ptr< rcl_action_goal_handle_t > rcl_goal_handle, GoalUUID uuid, std::shared_ptr< void > goal_request_message) override

GoalUUIDget_goal_id_from_goal_request (void *message) override

std::shared_ptr< void > create_goal_request () override

GoalUUIDget_goal_id_from_result_request (void *message) override

std::shared_ptr< void > create_result_request () override

std::shared_ptr< void > create_result_response (decltype(action_msgs::msg::GoalStatus::status) status) override

Protected Member Functions inherited from rclcpp_action::ServerBase

RCLCPP_ACTION_PUBLICServerBase (rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base, rclcpp::node_interfaces::NodeClockInterface::SharedPtr node_clock, rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging, const std::string &name, const rosidl_action_type_support_t *type_support, const rcl_action_server_options_t &options)

RCLCPP_ACTION_PUBLIC void publish_status ()

RCLCPP_ACTION_PUBLIC void notify_goal_terminal_state ()

RCLCPP_ACTION_PUBLIC void publish_result (const GoalUUID &uuid, std::shared_ptr< void > result_msg)

RCLCPP_ACTION_PUBLIC void publish_feedback (std::shared_ptr< void > feedback_msg)

Detailed Description

template<typename ActionT>

class rclcpp_action::Server< ActionT >

Action Server.

This class creates an action server.

Create an instance of this server using `rclcpp_action::create_server()`.

Internally, this class is responsible for:

- coverting between the C++ action type and generic types for `rclcpp_action::ServerBase`, and
- calling user callbacks.

Member Typedef Documentation

◆ GoalCallback

template<typename ActionT >

using rclcpp_action::Server< ActionT >::GoalCallback =  std::function<GoalResponse( const GoalUUID &, std::shared_ptr<const typename ActionT::Goal>)>

Signature of a callback that accepts or rejects goal requests.

◆ CancelCallback

template<typename ActionT >

using rclcpp_action::Server< ActionT >::CancelCallback =  std::function<CancelResponse(std::shared_ptr<ServerGoalHandle<ActionT> >)>

Signature of a callback that accepts or rejects requests to cancel a goal.

◆ AcceptedCallback

template<typename ActionT >

using rclcpp_action::Server< ActionT >::AcceptedCallback =  std::function<void (std::shared_ptr<ServerGoalHandle<ActionT> >)>

Signature of a callback that is used to notify when the goal has been accepted.

Constructor & Destructor Documentation

◆ Server()

template<typename ActionT >

rclcpp_action::Server< ActionT >::Server(rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base,

rclcpp::node_interfaces::NodeClockInterface::SharedPtr node_clock,

rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging,

const std::string & name,

const rcl_action_server_options_t & options,

GoalCallbackhandle_goal,

CancelCallbackhandle_cancel,

AcceptedCallbackhandle_accepted

)

inline

Construct an action server.

This constructs an action server, but it will not work until it has been added to a node. Use `rclcpp_action::create_server()` to both construct and add to a node.

Three callbacks must be provided:

- one to accept or reject goals sent to the server,
- one to accept or reject requests to cancel a goal,
- one to receive a goal handle after a goal has been accepted. All callbacks must be non-blocking. The result of a goal should be set using methods on `rclcpp_action::ServerGoalHandle`.
Parameters

[in]node_basea pointer to the base interface of a node.

[in]node_clocka pointer to an interface that allows getting a node's clock.

[in]node_logginga pointer to an interface that allows getting a node's logger.

[in]namethe name of an action. The same name and type must be used by both the action client and action server to communicate.

[in]optionsoptions to pass to the underlying `rcl_action_server_t`.

[in]handle_goala callback that decides if a goal should be accepted or rejected.

[in]handle_cancela callback that decides if a goal should be attemted to be canceled. The return from this callback only indicates if the server will try to cancel a goal. It does not indicate if the goal was actually canceled.

[in]handle_accepteda callback that is called to give the user a handle to the goal. execution.

◆ ~Server()

template<typename ActionT >

virtual rclcpp_action::Server< ActionT >::~Server()

virtualdefault

Member Function Documentation

◆ call_handle_goal_callback()

template<typename ActionT >

std::pair<GoalResponse, std::shared_ptr<void> > rclcpp_action::Server< ActionT >::call_handle_goal_callback (GoalUUID & uuid,

std::shared_ptr< void > message

)

inlineoverrideprotectedvirtual

Implements rclcpp_action::ServerBase.

◆ call_handle_cancel_callback()

template<typename ActionT >

CancelResponserclcpp_action::Server< ActionT >::call_handle_cancel_callback (const GoalUUID & uuid)

inlineoverrideprotectedvirtual

Implements rclcpp_action::ServerBase.

◆ call_goal_accepted_callback()

template<typename ActionT >

void rclcpp_action::Server< ActionT >::call_goal_accepted_callback (std::shared_ptr< rcl_action_goal_handle_t > rcl_goal_handle,

GoalUUIDuuid,

std::shared_ptr< void > goal_request_message

)

inlineoverrideprotectedvirtual

Call user callback to inform them a goal has been accepted.

Implements rclcpp_action::ServerBase.

◆ get_goal_id_from_goal_request()

template<typename ActionT >

GoalUUIDrclcpp_action::Server< ActionT >::get_goal_id_from_goal_request (void * message)

inlineoverrideprotectedvirtual

Given a goal request message, return the UUID contained within.

Implements rclcpp_action::ServerBase.

◆ create_goal_request()

template<typename ActionT >

std::shared_ptr<void> rclcpp_action::Server< ActionT >::create_goal_request ()

inlineoverrideprotectedvirtual

Create an empty goal request message so it can be taken from a lower layer.

Implements rclcpp_action::ServerBase.

◆ get_goal_id_from_result_request()

template<typename ActionT >

GoalUUIDrclcpp_action::Server< ActionT >::get_goal_id_from_result_request (void * message)

inlineoverrideprotectedvirtual

Given a result request message, return the UUID contained within.

Implements rclcpp_action::ServerBase.

◆ create_result_request()

template<typename ActionT >

std::shared_ptr<void> rclcpp_action::Server< ActionT >::create_result_request ()

inlineoverrideprotectedvirtual

Create an empty goal request message so it can be taken from a lower layer.

Implements rclcpp_action::ServerBase.

◆ create_result_response()

template<typename ActionT >

std::shared_ptr<void> rclcpp_action::Server< ActionT >::create_result_response (decltype(action_msgs::msg::GoalStatus::status) status)

inlineoverrideprotectedvirtual

Create an empty goal result message so it can be sent as a reply in a lower layer

Implements rclcpp_action::ServerBase.

The documentation for this class was generated from the following file:

- include/rclcpp_action/server.hpp

Generated by   1.8.17
