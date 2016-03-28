# Hungry Baby
Create easy, nutritious, and varied meal plans for your baby every single week.

**Developed in Xcode 7.3 using Swift 2.**

**Technology Stack**

* Frontend Application
  * Swift/iOS
* Backend Application
  * Google Firebase
* Cocoa Frameworks
  * UIKit
  * CoreData

## Features and Functionality

* Authentication enabled using Google Firebase backend

![Hungry Baby screenshot](/doc/HB1.png)

* View all recipes in a table view. Favorite recipes are marked with a heart.

![Hungry Baby screenshot](/doc/HB2.png)

* Read recipe details. Tap on the "heart" button to mark/unmark recipe as a favorite.

![Hungry Baby screenshot](/doc/HB3.png)

* Generate a weekly meal plan with meals listed by day of the week. Regenerate meal plans with the tap of a button.

![Hungry Baby screenshot](/doc/HB4.png)

* Get a shopping list for your weekly meal plan. Cross-off items from the list with a swipe.

![Hungry Baby screenshot](/doc/HB5.png)

## User Instructions

* **Build**
  * Use Xcode 7.3 or higher to build the app.
  * App is designed to run on iPhone (any model) in portrait orientation.

* **Access**
  * Login using the following credentials or login anonymously.
  * Username: test@example.com
  * Password: password

* **Usage Notes**
  * In "Recipe Detail" view, tap the top-right "heart" button to mark the recipe as a favorite.
  * In "Meal Plan" view, tap the top-right "refresh" button to generate a new meal plan. This will also generate a new shopping list for ingredients from that meal plan.
  * In "Shopping List" view, swipe left on a row to delete/restore the list item. Pressing "delete" will cross-off the item from the list.

## Application Architecture

* **Model** *Collections are denoted by []*
  * Recipe
    * ingredients = [Ingredient]
    * method = [Method Step]
    * nutrition = [Nutrition]
  * MealPlan
    * mealEntries = [MealEntry]
      * recipe = Recipe
  * [ShoppingList]
  * Networking Client
    * APIClient
    * APIConstants
    * ImageCache

* **Controller**
  * LoginVC
  * RecipeListVC
  * RecipeDetailVC
  * MealPlanVC
  * ShoppingListVC

* **View**
  * RecipeCell
  * Storyboard scenes
