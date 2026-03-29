//= require action_cable

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
  App.topics = {};
  App.currentSolution = null;

  // Set the current solution (call this on page load)
  // Usage: App.setSolution("my_solution_name")
  App.setSolution = function(solutionName) {
    App.currentSolution = solutionName;
    console.log("ActionCable: Solution set to " + solutionName);
  };

  // Subscribe to solution notifications (call after setSolution)
  App.subscribeNotifications = function(callback) {
    App.notifications = App.cable.subscriptions.create("NotificationChannel", {
      connected: function() {
        console.log("ActionCable: Connected to notifications [" + App.currentSolution + "]");
      },

      disconnected: function() {
        console.log("ActionCable: Disconnected from notifications");
      },

      received: function(data) {
        console.log("ActionCable: Notification", data);
        if (callback) { callback(data); }
      }
    });

    return App.notifications;
  };

  // Subscribe to a topic within the current solution
  // Usage: App.subscribeTopic("chat_room_1", function(data) { console.log(data); })
  App.subscribeTopic = function(topic, callback) {
    var solution = App.currentSolution;
    var key = solution + ":" + topic;

    if (App.topics[key]) {
      console.log("ActionCable: Already subscribed to " + key);
      return App.topics[key];
    }

    App.topics[key] = App.cable.subscriptions.create(
      { channel: "TopicChannel", topic: topic, solution: solution },
      {
        connected: function() {
          console.log("ActionCable: Subscribed to [" + solution + "] topic: " + topic);
        },

        disconnected: function() {
          console.log("ActionCable: Disconnected from [" + solution + "] topic: " + topic);
        },

        received: function(data) {
          console.log("ActionCable: [" + solution + ":" + topic + "]", data);
          if (callback) { callback(data); }
        },

        // Send a message to the topic
        speak: function(message) {
          this.perform("speak", { message: message });
        }
      }
    );

    return App.topics[key];
  };

  // Unsubscribe from a topic
  App.unsubscribeTopic = function(topic) {
    var key = App.currentSolution + ":" + topic;
    if (App.topics[key]) {
      App.cable.subscriptions.remove(App.topics[key]);
      delete App.topics[key];
      console.log("ActionCable: Unsubscribed from " + key);
    }
  };

}).call(this);
