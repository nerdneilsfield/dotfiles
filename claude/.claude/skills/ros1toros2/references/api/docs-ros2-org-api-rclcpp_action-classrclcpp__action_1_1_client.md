---
source_url: https://docs.ros2.org/latest/api/rclcpp_action/classrclcpp__action_1_1Client.html
fetched_at: 2026-04-18T00:00:00Z
---

# rclcpp_action: rclcpp_action::Client< ActionT > Class Template Reference

rclcpp_action: rclcpp_action::Client< ActionT > Class Template Reference

rclcpp_action
master

C++ ROS Action Client Library

- rclcpp_action
- Client

Classes |
Public Types |
Public Member Functions |
List of all members

rclcpp_action::Client< ActionT > Class Template Reference

Action Client.
More...

`#include <client.hpp>`

Inheritance diagram for rclcpp_action::Client< ActionT >:

[legend]

Collaboration diagram for rclcpp_action::Client< ActionT >:

[legend]

Classes

struct  SendGoalOptions

Options for sending a goal.  More...

Public Types

using Goal = typename ActionT::Goal

using Feedback = typename ActionT::Feedback

using GoalHandle = ClientGoalHandle< ActionT >

using WrappedResult = typename GoalHandle::WrappedResult

using GoalResponseCallback = std::function< void(std::shared_future< typename GoalHandle::SharedPtr >)>

using FeedbackCallback = typename GoalHandle::FeedbackCallback

using ResultCallback = typename GoalHandle::ResultCallback

using CancelRequest = typename ActionT::Impl::CancelGoalService::Request

using CancelResponse = typename ActionT::Impl::CancelGoalService::Response

using CancelCallback = std::function< void(typename CancelResponse::SharedPtr)>

Public Member Functions

Client (rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base, rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph, rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging, const std::string &action_name, const rcl_action_client_options_t client_options=rcl_action_client_get_default_options())

Construct an action client.  More...

std::shared_future< typename GoalHandle::SharedPtr > async_send_goal (const Goal &goal, const SendGoalOptions &options=SendGoalOptions())

Send an action goal and asynchronously get the result.  More...

std::shared_future< WrappedResult > async_get_result (typename GoalHandle::SharedPtr goal_handle, ResultCallback result_callback=nullptr)

Asynchronously get the result for an active goal.  More...

std::shared_future< typename CancelResponse::SharedPtr > async_cancel_goal (typename GoalHandle::SharedPtr goal_handle, CancelCallback cancel_callback=nullptr)

Asynchronously request a goal be canceled.  More...

std::shared_future< typename CancelResponse::SharedPtr > async_cancel_all_goals (CancelCallback cancel_callback=nullptr)

Asynchronously request for all goals to be canceled.  More...

std::shared_future< typename CancelResponse::SharedPtr > async_cancel_goals_before (const rclcpp::Time &stamp, CancelCallback cancel_callback=nullptr)

Asynchronously request all goals at or before a specified time be canceled.  More...

virtual ~Client ()

Public Member Functions inherited from rclcpp_action::ClientBase

virtual RCLCPP_ACTION_PUBLIC~ClientBase ()

RCLCPP_ACTION_PUBLIC bool action_server_is_ready () const

Return true if there is an action server that is ready to take goal requests.  More...

template<typename RepT  = int64_t, typename RatioT  = std::milli>

bool wait_for_action_server (std::chrono::duration< RepT, RatioT > timeout=std::chrono::duration< RepT, RatioT >(-1))

Wait for action_server_is_ready() to become true, or until the given timeout is reached.  More...

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_subscriptions () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_timers () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_clients () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_services () override

RCLCPP_ACTION_PUBLIC size_t get_number_of_ready_guard_conditions () override

RCLCPP_ACTION_PUBLIC bool add_to_wait_set (rcl_wait_set_t *wait_set) override

RCLCPP_ACTION_PUBLIC bool is_ready (rcl_wait_set_t *wait_set) override

RCLCPP_ACTION_PUBLIC void execute () override

Public Member Functions inherited from rclcpp::Waitable

virtual ~Waitable ()=default

virtual size_t get_number_of_ready_events ()

bool exchange_in_use_by_wait_set_state (bool in_use_state)

Additional Inherited Members

Protected Types inherited from rclcpp_action::ClientBase

using ResponseCallback = std::function< void(std::shared_ptr< void > response)>

Protected Member Functions inherited from rclcpp_action::ClientBase

RCLCPP_ACTION_PUBLICClientBase (rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base, rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph, rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging, const std::string &action_name, const rosidl_action_type_support_t *type_support, const rcl_action_client_options_t &options)

RCLCPP_ACTION_PUBLIC bool wait_for_action_server_nanoseconds (std::chrono::nanoseconds timeout)

Wait for action_server_is_ready() to become true, or until the given timeout is reached.  More...

RCLCPP_ACTION_PUBLICrclcpp::Loggerget_logger ()

virtual RCLCPP_ACTION_PUBLICGoalUUIDgenerate_goal_id ()

virtual RCLCPP_ACTION_PUBLIC void send_goal_request (std::shared_ptr< void > request, ResponseCallback callback)

virtual RCLCPP_ACTION_PUBLIC void send_result_request (std::shared_ptr< void > request, ResponseCallback callback)

virtual RCLCPP_ACTION_PUBLIC void send_cancel_request (std::shared_ptr< void > request, ResponseCallback callback)

virtual RCLCPP_ACTION_PUBLIC void handle_goal_response (const rmw_request_id_t &response_header, std::shared_ptr< void > goal_response)

virtual RCLCPP_ACTION_PUBLIC void handle_result_response (const rmw_request_id_t &response_header, std::shared_ptr< void > result_response)

virtual RCLCPP_ACTION_PUBLIC void handle_cancel_response (const rmw_request_id_t &response_header, std::shared_ptr< void > cancel_response)

Detailed Description

template<typename ActionT>

class rclcpp_action::Client< ActionT >

Action Client.

This class creates an action client.

To create an instance of an action client use `rclcpp_action::create_client()`.

Internally, this class is responsible for:

- coverting between the C++ action type and generic types for `rclcpp_action::ClientBase`, and
- calling user callbacks.

Member Typedef Documentation

◆ Goal

template<typename ActionT >

using rclcpp_action::Client< ActionT >::Goal =  typename ActionT::Goal

◆ Feedback

template<typename ActionT >

using rclcpp_action::Client< ActionT >::Feedback =  typename ActionT::Feedback

◆ GoalHandle

template<typename ActionT >

using rclcpp_action::Client< ActionT >::GoalHandle =  ClientGoalHandle<ActionT>

◆ WrappedResult

template<typename ActionT >

using rclcpp_action::Client< ActionT >::WrappedResult =  typename GoalHandle::WrappedResult

◆ GoalResponseCallback

template<typename ActionT >

using rclcpp_action::Client< ActionT >::GoalResponseCallback =  std::function<void (std::shared_future<typename GoalHandle::SharedPtr>)>

◆ FeedbackCallback

template<typename ActionT >

using rclcpp_action::Client< ActionT >::FeedbackCallback =  typename GoalHandle::FeedbackCallback

◆ ResultCallback

template<typename ActionT >

using rclcpp_action::Client< ActionT >::ResultCallback =  typename GoalHandle::ResultCallback

◆ CancelRequest

template<typename ActionT >

using rclcpp_action::Client< ActionT >::CancelRequest =  typename ActionT::Impl::CancelGoalService::Request

◆ CancelResponse

template<typename ActionT >

using rclcpp_action::Client< ActionT >::CancelResponse =  typename ActionT::Impl::CancelGoalService::Response

◆ CancelCallback

template<typename ActionT >

using rclcpp_action::Client< ActionT >::CancelCallback =  std::function<void (typename CancelResponse::SharedPtr)>

Constructor & Destructor Documentation

◆ Client()

template<typename ActionT >

rclcpp_action::Client< ActionT >::Client(rclcpp::node_interfaces::NodeBaseInterface::SharedPtr node_base,

rclcpp::node_interfaces::NodeGraphInterface::SharedPtr node_graph,

rclcpp::node_interfaces::NodeLoggingInterface::SharedPtr node_logging,

const std::string & action_name,

const rcl_action_client_options_tclient_options = `rcl_action_client_get_default_options()`

)

inline

Construct an action client.

This constructs an action client, but it will not work until it has been added to a node. Use `rclcpp_action::create_client()` to both construct and add to a node.
Parameters

[in]node_baseA pointer to the base interface of a node.

[in]node_graphA pointer to an interface that allows getting graph information about a node.

[in]node_loggingA pointer to an interface that allows getting a node's logger.

[in]action_nameThe action name.

[in]client_optionsOptions to pass to the underlying `rcl_action::rcl_action_client_t`.

◆ ~Client()

template<typename ActionT >

virtual rclcpp_action::Client< ActionT >::~Client()

inlinevirtual

Member Function Documentation

◆ async_send_goal()

template<typename ActionT >

std::shared_future<typename GoalHandle::SharedPtr> rclcpp_action::Client< ActionT >::async_send_goal (const Goal & goal,

const SendGoalOptions & options = `SendGoalOptions()`

)

inline

Send an action goal and asynchronously get the result.

If the goal is accepted by an action server, the returned future is set to a `ClientGoalHandle`. If the goal is rejected by an action server, then the future is set to a `nullptr`.

The returned goal handle is used to monitor the status of the goal and get the final result. It is valid as long as you hold a reference to the shared pointer or until the rclcpp_action::Client is destroyed at which point the goal status will become UNKNOWN.
Parameters

[in]goalThe goal request.

[in]optionsOptions for sending the goal request. Contains references to callbacks for the goal response (accepted/rejected), feedback, and the final result.

ReturnsA future that completes when the goal has been accepted or rejected. If the goal is rejected, then the result will be a `nullptr`.

◆ async_get_result()

template<typename ActionT >

std::shared_future<WrappedResult> rclcpp_action::Client< ActionT >::async_get_result (typename GoalHandle::SharedPtr goal_handle,

ResultCallbackresult_callback = `nullptr`

)

inline

Asynchronously get the result for an active goal.
Exceptions

exceptions::UnknownGoalHandleErrorIf the goal unknown or already reached a terminal state.

Parameters

[in]goal_handleThe goal handle for which to get the result.

[in]result_callbackOptional callback that is called when the result is received.

ReturnsA future that is set to the goal result when the goal is finished.

◆ async_cancel_goal()

template<typename ActionT >

std::shared_future<typename CancelResponse::SharedPtr> rclcpp_action::Client< ActionT >::async_cancel_goal (typename GoalHandle::SharedPtr goal_handle,

CancelCallbackcancel_callback = `nullptr`

)

inline

Asynchronously request a goal be canceled.
Exceptions

exceptions::UnknownGoalHandleErrorIf the goal is unknown or already reached a terminal state.

Parameters

[in]goal_handleThe goal handle requesting to be canceled.

[in]cancel_callbackOptional callback that is called when the response is received. The callback takes one parameter: a shared pointer to the CancelResponse message.

ReturnsA future to a CancelResponse message that is set when the request has been acknowledged by an action server. See action_msgs/CancelGoal.srv.

◆ async_cancel_all_goals()

template<typename ActionT >

std::shared_future<typename CancelResponse::SharedPtr> rclcpp_action::Client< ActionT >::async_cancel_all_goals (CancelCallbackcancel_callback = `nullptr`)

inline

Asynchronously request for all goals to be canceled.
Parameters

[in]cancel_callbackOptional callback that is called when the response is received. The callback takes one parameter: a shared pointer to the CancelResponse message.

ReturnsA future to a CancelResponse message that is set when the request has been acknowledged by an action server. See action_msgs/CancelGoal.srv.

◆ async_cancel_goals_before()

template<typename ActionT >

std::shared_future<typename CancelResponse::SharedPtr> rclcpp_action::Client< ActionT >::async_cancel_goals_before (const rclcpp::Time & stamp,

CancelCallbackcancel_callback = `nullptr`

)

inline

Asynchronously request all goals at or before a specified time be canceled.
Parameters

[in]stampThe timestamp for the cancel goal request.

[in]cancel_callbackOptional callback that is called when the response is received. The callback takes one parameter: a shared pointer to the CancelResponse message.

ReturnsA future to a CancelResponse message that is set when the request has been acknowledged by an action server. See action_msgs/CancelGoal.srv.

The documentation for this class was generated from the following file:

- include/rclcpp_action/client.hpp

Generated by   1.8.17
