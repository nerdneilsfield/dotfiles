---
source_url: https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html
fetched_at: 2026-04-18T10:58:27Z
---

*   [](https://docs.ros.org/en/jazzy/index.html)

*   [Concepts](https://docs.ros.org/en/jazzy/Concepts.html)

*   [Basic Concepts](https://docs.ros.org/en/jazzy/Concepts/Basic.html)

*   Interfaces
*   [Edit on GitHub](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Interfaces.rst)


* * *

**You're reading the documentation for an older, but still supported, version of ROS 2. For information on the latest version, please have a look at [Kilted](https://docs.ros.org/en/kilted/Concepts/Basic/About-Interfaces.html)
.**

Interfaces[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#interfaces "Link to this heading")

====================================================================================================================

[Background](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id1)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#background "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ROS applications typically communicate through interfaces of one of three types: [topics](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Topics.html)
, [services](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Services.html)
, or [actions](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Actions.html)
. ROS 2 uses a simplified description language, the interface definition language (IDL), to describe these interfaces. This description makes it easy for ROS tools to automatically generate source code for the interface type in several target languages.

In this document we will describe the supported types:

*   msg: `.msg` files are simple text files that describe the fields of a ROS message. They are used to generate source code for messages in different languages.

*   srv: `.srv` files describe a service. They are composed of two parts: a request and a response. The request and response are message declarations.

*   action: `.action` files describe actions. They are composed of three parts: a goal, a result, and feedback. Each part is a message declaration itself.


[Messages](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id2)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#messages "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Messages are a way for a ROS 2 node to send data on the network to other ROS nodes, with no response expected. For instance, if a ROS 2 node reads temperature data from a sensor, it can then publish that data on the ROS 2 network using a `Temperature` message. Other nodes on the ROS 2 network can subscribe to that data and receive the `Temperature` message.

Messages are described and defined in `.msg` files in the `msg/` directory of a ROS package. `.msg` files are composed of two parts: fields and constants.

### [Fields](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id3)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#fields "Link to this heading")

Each field consists of a type and a name, separated by a space, i.e:

fieldtype1 fieldname1
fieldtype2 fieldname2
fieldtype3 fieldname3

Copy to clipboard

For example:

int32 my\_int
string my\_string

Copy to clipboard

#### [Field types](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id4)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#field-types "Link to this heading")

Field types can be:

*   a built-in-type

*   names of Message descriptions defined on their own, such as “geometry\_msgs/PoseStamped”


_Built-in-types currently supported:_

| Type name | [C++](https://design.ros2.org/articles/generated_interfaces_cpp.html) | [Python](https://design.ros2.org/articles/generated_interfaces_python.html) | [DDS type](https://design.ros2.org/articles/mapping_dds_types.html) |
| --- | --- | --- | --- |
| bool | bool | builtins.bool | boolean |
| byte | uint8\_t | builtins.bytes\* | octet |
| char | char | builtins.int\* | char |
| float32 | float | builtins.float\* | float |
| float64 | double | builtins.float\* | double |
| int8 | int8\_t | builtins.int\* | octet |
| uint8 | uint8\_t | builtins.int\* | octet |
| int16 | int16\_t | builtins.int\* | short |
| uint16 | uint16\_t | builtins.int\* | unsigned short |
| int32 | int32\_t | builtins.int\* | long |
| uint32 | uint32\_t | builtins.int\* | unsigned long |
| int64 | int64\_t | builtins.int\* | long long |
| uint64 | uint64\_t | builtins.int\* | unsigned long long |
| string | std::string | builtins.str | string |
| wstring | std::u16string | builtins.str | wstring |

_Every built-in-type can be used to define arrays:_

| Type name | [C++](https://design.ros2.org/articles/generated_interfaces_cpp.html) | [Python](https://design.ros2.org/articles/generated_interfaces_python.html) | [DDS type](https://design.ros2.org/articles/mapping_dds_types.html) |
| --- | --- | --- | --- |
| static array | std::array<T, N> | builtins.list\* | T\[N\] |
| unbounded dynamic array | std::vector | builtins.list | sequence |
| bounded dynamic array | custom\_class<T, N> | builtins.list\* | sequence<T, N> |
| bounded string | std::string | builtins.str\* | string |

(\*) All types that are more permissive than their ROS definition enforce the ROS constraints in range and length by software.

_Example of message definition using arrays and bounded types:_

int32\[\] unbounded\_integer\_array
int32\[5\] five\_integers\_array
int32\[<\=5\] up\_to\_five\_integers\_array

string string\_of\_unbounded\_size
string<\=10 up\_to\_ten\_characters\_string

string\[<\=5\] up\_to\_five\_unbounded\_strings
string<\=10\[\] unbounded\_array\_of\_strings\_up\_to\_ten\_characters\_each
string<\=10\[<\=5\] up\_to\_five\_strings\_up\_to\_ten\_characters\_each

Copy to clipboard

#### [Field names](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id5)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#field-names "Link to this heading")

Field names must be lowercase alphanumeric characters with underscores for separating words. They must start with an alphabetic character, and they must not end with an underscore or have two consecutive underscores.

#### [Field default value](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id6)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#field-default-value "Link to this heading")

Default values can be set to any field in the message type. Currently default values are not supported for string arrays and complex types (i.e. types not present in the built-in-types table above; that applies to all nested messages).

Defining a default value is done by adding a third element to the field definition line, i.e:

fieldtype fieldname fielddefaultvalue

Copy to clipboard

For example:

uint8 x 42
int16 y \-2000
string full\_name "John Doe"
int32\[\] samples \[\-200, \-100, 0, 100, 200\]

Copy to clipboard

Note

*   string values must be defined in single `'` or double `"` quotes

*   currently string values are not escaped


### [Constants](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id7)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#constants "Link to this heading")

Each constant definition is like a field description with a default value, except that this value can never be changed programmatically. This value assignment is indicated by use of an equal ‘=’ sign, e.g.

constanttype CONSTANTNAME\=constantvalue

Copy to clipboard

For example:

int32 X\=123
int32 Y\=\-123
string FOO\="foo"
string EXAMPLE\='bar'

Copy to clipboard

Note

Constants names have to be UPPERCASE

[Services](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id8)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#services "Link to this heading")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Services are a request/response communication, where the client (requester) is waiting for the server (responder) to make a short computation and return a result.

Services are described and defined in `.srv` files in the `srv/` directory of a ROS package.

A service description file consists of a request and a response msg type, separated by `---`. Any two `.msg` files concatenated with a `---` are a legal service description.

Here is a very simple example of a service that takes in a string and returns a string:

string str
---
string str

Copy to clipboard

We can of course get much more complicated (if you want to refer to a message from the same package you must not mention the package name):

\# request constants
int8 FOO\=1
int8 BAR\=2
\# request fields
int8 foobar
another\_pkg/AnotherMessage msg
---
\# response constants
uint32 SECRET\=123456
\# response fields
another\_pkg/YetAnotherMessage val
CustomMessageDefinedInThisPackage value
uint32 an\_integer

Copy to clipboard

You cannot embed another service inside of a service.

[Actions](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#id9)
[](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html#actions "Link to this heading")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Actions are a long-running request/response communication, where the action client (requester) is waiting for the action server (the responder) to take some action and return a result. In contrast to services, actions can be long-running (many seconds or minutes), provide feedback while they are happening, and can be interrupted.

Action definitions have the following form:

<request\_type\> <request\_fieldname\>
\---
<response\_type\> <response\_fieldname\>
\---
<feedback\_type\> <feedback\_fieldname\>

Copy to clipboard

Like services, the request fields are before and the response fields are after the first triple-dash (`---`), respectively. There is also a third set of fields after the second triple-dash, which is the fields to be sent when sending feedback.

There can be arbitrary numbers of request fields (including zero), arbitrary numbers of response fields (including zero), and arbitrary numbers of feedback fields (including zero).

The `<request_type>`, `<response_type>`, and `<feedback_type>` follow all of the same rules as the `<type>` for a message. The `<request_fieldname>`, `<response_fieldname>`, and `<feedback_fieldname>` follow all of the same rules as the `<fieldname>` for a message.

For instance, the `Fibonacci` action definition contains the following:

int32 order
\---
int32\[\] sequence
\---
int32\[\] sequence

Copy to clipboard

This is an action definition where the action client is sending a single `int32` field representing the number of Fibonacci steps to take, and expecting the action server to produce an array of `int32` containing the complete steps. Along the way, the action server may also provide an intermediate array of `int32` containing the steps accomplished up until a certain point.

Other Versions v: jazzy

Releases

[Kilted (latest)](https://docs.ros.org/en/kilted/Concepts/Basic/About-Interfaces.html)

[Jazzy](https://docs.ros.org/en/jazzy/Concepts/Basic/About-Interfaces.html)

[Iron (EOL)](https://docs.ros.org/en/iron/Concepts/Basic/About-Interfaces.html)

[Humble](https://docs.ros.org/en/humble/Concepts/Basic/About-Interfaces.html)

[Galactic (EOL)](https://docs.ros.org/en/galactic/index.html)

[Foxy (EOL)](https://docs.ros.org/en/foxy/index.html)

[Eloquent (EOL)](https://docs.ros.org/en/eloquent/index.html)

[Dashing (EOL)](https://docs.ros.org/en/dashing/index.html)

[Crystal (EOL)](https://docs.ros.org/en/crystal/index.html)

In Development

[Rolling](https://docs.ros.org/en/rolling/Concepts/Basic/About-Interfaces.html)
