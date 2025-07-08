## Reflection

# Course Topics & Inclusive Design Principles
Identify which of the course topics you applied (e.g. secure data persistence) and describe how you applied them. 

(answer): 
Layout WireFrames and Storyboards:
We dedicated a lot of time designing and perfecting our layout wireframe and storyboard at the beginning of the development process. We thoughtfully considered the layout and all the widgets we needed to use on each screen before we started development. Throughout our development process, we regularly referenced the wireframe, which allowed us to focus just on coding rather than brainstorming design ideas. Since our original design was well thought out and we followed them precisely for each screen/view, we did not need to revisit or change them during development. This significantly sped up our development process and helped ensure there was consistency across all screens/views of our app. 

Stateless and Stateful Widgets:
To develop the app, we used a combination of Stateless and Stateful Widgets based on the functionality of each screen or component. We carefully determined which components needed to manage user inputs or update UI dynamically and defined those as Stateful Widgets. For instance, the LoginScreen, ProfileScreen, and CameraView all needed to manage dynamic states and were therefore defined as stateful widgets. While other components such as the LeaderBoardScreen and HomeScreen displayed static content so we defined them as stateless widgets.

Data Persistence:
We used Isar to store player data, including their ID, username, avatar icon, high score, and monthly score. We thoughtfully considered all the information we needed to store to ensure all of the user’s progress is tracked and saved. Using Isar allowed us to implement reliable data persistence, ensuring that player data remained accurate and consistent across all app sessions.

Providers:
We utilized multiple Providers with our game design, since we are sending multiple streams of data across every view. Most of our views require player information (score), the Weather information, Landmark information, Leaderboard updates, as well as Position updates. Providers helped us manage state and data effectively so our game would work seamlessly. 

APIs:
To catch weather data, we used the Weather API from Weather and FoodFinder assignments to query weather conditions and temperature information. This would place a helpful reminder to users who are playing this game to consider weather conditions, since Husky Hunt is seasonal and depends on good weather to be enjoyed

Internationalization:
We wanted multiple language support for our app, so we followed the steps in the Internationalization lecture to allow for multiple languages and to prevent Localization. This is also part of inclusive design.

# Inclusive Design Principles
In addition to the list of topics enumerated above, you must also describe how your app design reflects what you learned about the design principles we discussed in our Inclusive Design lecture (Lecture 9: Designing for Accessibility)

(answer): 
Don’t Rely on Blue (small objects and older users):
In our design, we intentionally avoided using the color blue as much as possible and stuck to UW's color theme (purple, white, and black) across all screens/views. This helped ensure sufficient contrast for text and icons, making content more legible and accessible to all users.

Manage Expectations: 
For all the places where the app needs time to load before continuing, we informed the user that the app was loading. We implemented this using ScaffoldMessenger, SnackBar, CircularProgressIndicator, and Text Widgets. For instance, there is a SnackBar popup when pressing play for the first time, telling the user that Landmarks are all loading. Once everything loads, the player can proceed to the next screen.


Make UI Changes Obvious (visually and orally):
For all places that required user input, we informed the user if their input was incorrect or if the app was loading. We implemented this using ScaffoldMessenger, SnackBar, and Text Widgets. For instance, when a user attempts to create their player without entering a username or a username that has already been chosen, a popup will appear prompting the user to enter a username or stating that the username is unavailable.


Make Sure Contrast is High Enough:
Throughout all our views, we made sure that contrast levels were high by staying with a simple color scheme, and overlaying black text over a white background, as well as white text over a purple background to help ease-of-use. This was tested and verified through our peer audit.


# Resources

Flutter Docs:
- InteractiveViewer class
- FractionallySizedBox class
- AspectRatio class
- Stack class
- GridView class
- ListView class
- Camera class
- SizedBox class
- ElevatedButton class
- Navigator class
- RoundedRectangleBorder library
- GestureDetector class
- CircularProgressIndicator class

Isar Get Started Guide: Quickstart | Isar Database

We used WeatherProvider and PositionProvider from Food Finder, as well as WeatherChecker and WeatherCondition from Food Finder.

These sources were helpful for getting the leaderboard to work:
dart - Flutter Isar run build_runner build generate nothing - Stack Overflow
(https://stackoverflow.com/questions/78670077/flutter-isar-run-build-runner-build-generate-nothing) 
How do get a random element from a List in Dart? - Stack Overflow
(https://stackoverflow.com/questions/17476718/how-do-get-a-random-element-from-a-list-in-dart)

Implementing MapScreen using InteractiveViewer:
Flutter InteractiveViewer Widget - GeeksForGeeks
(https://www.geeksforgeeks.org/flutter-interactiveviewer-widget/)

Haversine Distance Formula in Dart
(https://medium.com/@yousafjamil50/calculating-the-distance-between-two-points-on-google-maps-in-flutter-2b46bee1be3b)


# Understanding
Discuss how doing this project challenged and/or deepened each of your understanding of these topics.

(answer):
Nam: This project significantly deepened my understanding and mastery of stateful widgets. Before this project, it was difficult for me to determine when a component needed to be stateful vs stateless. However, after this project and the practice I got defining my own stateful widget classes, it became much clearer to me how to identify which need to be stateful and which do not. The most challenging part of the project was managing multiple files, providers, and Isar. It was sometimes difficult to keep track of each provider’s purpose and how to correctly store and retrieve data using Isar. However, through navigating this challenge, I gained a deeper understanding of not only how to implement the Isar database but also how to define providers to handle Isar write and read methods.

Kevin:  This project allowed me to apply several concepts from class in practical ways. I gained hands on experience working with widgets, such as implementing buttons and navigation controls throughout the application. I also added internationalization features to make the app accessible to users from different linguistic backgrounds. While the initial setup for internationalization was straightforward, the implementation proved more challenging than expected. I had to systematically update every view in the application to support language switching, particularly for Spanish localization. This required extensive code modifications across multiple files to ensure all text elements could be properly translated.


Jayden: Working with Providers and Isar was challenging, including managing multiple fields such as Monthly vs. All-time high scores. I figured out how to call Provider methods correctly and utilize NotifyListeners() to allow correct changes to be made, deepening my understanding of Providers. I also worked with Isar and at first, struggled to get data uploads working properly. My implementation of Monthly scores was using a complex Map(), which turned out hard to update and display in the Leaderboard view. To fix this, rewriting the entire leaderboard to only use two values for high score and monthly high score was done. I learned how parameters and Isar worked extensively for this, allowing me to correct the Leaderboard.


Keyvyn: For me, working with Camera was one of the hardest parts. At first, I struggled with mapping the Camera button with the distance feature, as it required me to understand the PositionProvider and how important it is to this game. I needed to map the button so it only showed when the user is close by. I learned how to manage state with the Position Provider and adapt that behavior to the camera so that the user is able to take photos once they are close by.


# Original Design vs. Final Implementation
Describe what changed from your original concept to your final implementation and explain why your group made those changes from your original design vision. 

(answer): Although we thoroughly planned the design of our app before starting implementation, we overlooked how crucial a login screen was. Once we began development, it quickly became clear that a login feature was necessary for other key components, such as the leaderboard and player profile selection, to function. Without a way for users to create a player profile and set a username, we had no way to display users on the leaderboard or store/retrieve their player profiles from/to the ISAR database. This realization led us to revisit our original layout wireframe and storyboard, and update them to include a login screen that is open immediately upon launching the app.

# Future Work
Describe two areas of future work for your app, including how you could increase the accessibility and usability of this app.

(answer): We could have displayed an actual map API on the MapView screen and implemented the ability for the app to give navigation commands, but given the timeframe, we couldn’t do this. If we could have implemented navigation, it would have also added voice commands to navigate (“turn left here!”). Voice commands would open our app to wider demographic, such as visually impaired users, which would've greatly increased the accessibility and usability of our app.

(answer): A second area a future work is implementing an online multiplayer database, since our current Leaderboard uses Isar, which is offline. We could switch to an online open-source database like Firebase, or figure out how to pull online score parameters into Isar. This would have allowed user data to be synced across multiple devices, which would not only make our app more functional but also more accessible, since it would allow users to use the devices and accessibility tools they are most comfortable with.


# CSE 340 As A Whole
What do you feel was the most valuable thing you learned in CSE 340 that will help you beyond this class, and why?

(answer): The best thing that we learned was how important it was to design for accessibility and inclusiveness, since we don’t know the end user at all. This will help in our futures because by considering the perspectives of other people, we can help design technology that benefits everyone, or at least tries to benefit everyone that uses what we create.

If you could go back and give yourself 2-3 pieces of advice at the beginning of the class, what would you say and why? (Alternatively: what 2-3 pieces of advice would you give to future students who take CSE 340 and why?)
We would tell ourselves two things:

(answer): Providers would become extremely important: We say this because our app used providers in every situation for state management, as well as sending data across all views. Hence, this is one of the most important topics in CSE 340.
Commenting is also extremely important: We want other people to know what we are doing, especially if working across multiple teams. Comments make it easy to explain why we are doing something.

