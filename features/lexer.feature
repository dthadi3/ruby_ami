Feature: Lexing AMI
  As a RubyAMI user
  I want to lex the AMI protocol
  So that I can control Asterisk asynchronously

  Scenario: Lexing only the initial AMI version header
    Given a new lexer
    And a version header for AMI 2.8.0

    Then the protocol should have lexed without syntax errors
    And the version should be set to 2.8.0

  Scenario: Lexing the initial AMI header and a login attempt
    Given a new lexer
    And a version header for AMI 1.0
    And a normal login success with events

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received

  Scenario: Lexing the initial AMI header and then a Response:Follows section
    Given a new lexer
    And a version header for AMI 1.0
    And a multi-line Response:Follows body of show_channels_from_wayne

    Then the protocol should have lexed without syntax errors
    And the 'follows' body of 1 message received should equal show_channels_from_wayne

  Scenario: Lexing a Response:Follows section with no body
    Given a new lexer
    And a version header for AMI 1.0
    And a multi-line Response:Follows body of empty_String

    Then the protocol should have lexed without syntax errors
    And the 'follows' body of 1 message received should equal empty_string

  Scenario: Lexing a multi-line Response:Follows simulating the "core show channels" command
    Given a new lexer
    And a version header for AMI 1.0
    Given a multi-line Response:Follows body of show_channels_from_wayne

    Then the protocol should have lexed without syntax errors
    And the 'follows' body of 1 message received should equal show_channels_from_wayne

  Scenario: Lexing a multi-line Response:Follows simulating the "core show uptime" command
    Given a new lexer
    And a version header for AMI 1.0
    Given a multi-line Response:Follows response simulating uptime

    Then the protocol should have lexed without syntax errors
    And the first message received should have a key "System uptime" with value "46 minutes, 30 seconds"

  Scenario: Lexing a Response:Follows section which has a colon not on the first line
    Given a new lexer
    And a multi-line Response:Follows body of with_colon_after_first_line

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received
    And the 'follows' body of 1 message received should equal with_colon_after_first_line

  @wip
  Scenario: Lexing an immediate response with a colon in it.
    Given a new lexer
    And an immediate response with text "markq        has 0 calls (max unlimited) in 'ringall' strategy (0s holdtime), W:0, C:0, A:0, SL:0.0% within 0s\r\n   No Members\r\n   No Callers\r\n\r\n\r\n\r\n"

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received
    And 1 message should be an immediate response with text "markq        has 0 calls (max unlimited) in 'ringall' strategy (0s holdtime), W:0, C:0, A:0, SL:0.0% within 0s\r\n   No Members\r\n   No Callers"

  Scenario: Lexing the initial AMI header and then an "Authentication Required" error.
    Given a new lexer
    And a version header for AMI 1.0
    And an Authentication Required error

    Then the protocol should have lexed without syntax errors

  Scenario: Lexing the initial AMI header and then a Response:Follows section
    Given a new lexer
    And a version header for AMI 1.0
    And a multi-line Response:Follows body of show_channels_from_wayne
    And a multi-line Response:Follows body of show_channels_from_wayne

    Then the protocol should have lexed without syntax errors
    And the 'follows' body of 2 messages received should equal show_channels_from_wayne

  Scenario: Lexing a stanza without receiving an AMI header
    Given a new lexer
    And a normal login success with events

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received

  Scenario: Receiving an immediate response as soon as the socket is opened
    Given a new lexer
    And an immediate response with text "Immediate responses are so ridiculous"

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received
    And 1 message should be an immediate response with text "Immediate responses are so ridiculous"

  Scenario: Receiving an immediate message surrounded by real messages
    Given a new lexer
    And a normal login success with events
    And an immediate response with text "No queues have been created."
    And a normal login success with events

    Then the protocol should have lexed without syntax errors
    And 3 messages should have been received
    And 1 message should be an immediate response with text "No queues have been created."

  Scenario: Receiving a Pong after a simulated login
    Given a new lexer
    And a version header for AMI 1.0
    And a normal login success with events
    And a Pong response with an ActionID of randomness

    Then the protocol should have lexed without syntax errors
    And 2 messages should have been received

  Scenario: Ten Pong responses in a row
    Given a new lexer
    And 5 Pong responses without an ActionID
    And 5 Pong responses with an ActionID of randomness

    Then the protocol should have lexed without syntax errors
    And 10 messages should have been received

  Scenario: A Pong with an ActionID
    Given a new lexer
    And a Pong response with an ActionID of 1224469850.61673

    Then the first message received should have a key "ActionID" with value "1224469850.61673"

  Scenario: A response containing a floating point value
    Given a new lexer
    And a custom stanza named "call"
    And the custom stanza named "call" has key "ActionID" with value "1224469850.61673"
    And the custom stanza named "call" has key "Uniqueid" with value "1173223225.10309"

    When the custom stanza named "call" is added to the buffer

    Then the 1st message received should have a key "Uniqueid" with value "1173223225.10309"

  Scenario: Receiving a message with custom key/value pairs
    Given a new lexer
    And a custom stanza named "person"
    And the custom stanza named "person" has key "ActionID" with value "1224469850.61673"
    And the custom stanza named "person" has key "Name" with value "Jay Phillips"
    And the custom stanza named "person" has key "Age" with value "21"
    And the custom stanza named "person" has key "Location" with value "San Francisco, CA"
    And the custom stanza named "person" has key "x-header" with value "<FooBAR>"
    And the custom stanza named "person" has key "Channel" with value "IAX2/127.0.0.1/4569-9904"
    And the custom stanza named "person" has key "I have spaces" with value "i have trailing padding   "

    When the custom stanza named "person" is added to the buffer

    Then the protocol should have lexed without syntax errors
    And the first message received should have a key "Name" with value "Jay Phillips"
    And the first message received should have a key "ActionID" with value "1224469850.61673"
    And the first message received should have a key "Name" with value "Jay Phillips"
    And the first message received should have a key "Age" with value "21"
    And the first message received should have a key "Location" with value "San Francisco, CA"
    And the first message received should have a key "x-header" with value "<FooBAR>"
    And the first message received should have a key "Channel" with value "IAX2/127.0.0.1/4569-9904"
    And the first message received should have a key "I have spaces" with value "i have trailing padding   "

  Scenario: Executing a stanza that was partially received
    Given a new lexer
    And a normal login success with events split into two pieces

    Then the protocol should have lexed without syntax errors
    And 1 message should have been received

  Scenario: Receiving an AMI error followed by a normal event
    Given a new lexer
    And an AMI error whose message is "Missing action in request"
    And a normal login success with events

    Then the protocol should have lexed without syntax errors
    And 1 AMI error should have been received
    And the 1st AMI error should have the message "Missing action in request"
    And 1 message should have been received

  Scenario: Lexing an immediate response
    Given a new lexer
    And a normal login success with events
    And an immediate response with text "Yes, plain English is sent sometimes over AMI."
    And a normal login success with events

    Then the protocol should have lexed without syntax errors
    And 3 messages should have been received
    And 1 message should be an immediate response with text "Yes, plain English is sent sometimes over AMI."

  Scenario: Lexing an AMI event
    Given a new lexer
    And a custom event with name "NewChannelEvent" identified by "this_event"
    And a custom header for event identified by "this_event" whose key is "Foo" and value is "Bar"
    And a custom header for event identified by "this_event" whose key is "Channel" and value is "IAX2/127.0.0.1:4569-9904"
    And a custom header for event identified by "this_event" whose key is "AppData" and value is "agi://localhost"

    When the custom event identified by "this_event" is added to the buffer

    Then the protocol should have lexed without syntax errors
    And 1 event should have been received
    And the 1st event should have the name "NewChannelEvent"
    And the 1st event should have key "Foo" with value "Bar"
    And the 1st event should have key "Channel" with value "IAX2/127.0.0.1:4569-9904"
    And the 1st event should have key "AppData" with value "agi://localhost"

  Scenario: Lexing an immediate packet with a colon in it (syntax error)
    Given a new lexer
    And syntactically invalid immediate_packet_with_colon
    And a stanza break

    Then 0 messages should have been received
    And the protocol should have lexed with 1 syntax error
    And the syntax error fixture named immediate_packet_with_colon should have been encountered
