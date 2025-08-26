# ContentForge

- Aims to create tools for game designers to comfortably work in editor and programmers being able to pull/create data from that
- Easily define spreadsheets of data that can be moved around
- Game flow editor
- idk

Basically I want designers to be able to whip out contnent easily with no barriers in the game engine like they'd be working in google sheets etc, and these design documents to be able to be directly used in the game.

Probably a very opinionated framework.

Focus on the game content and not on the system.

## Features

### Spreadsheet

- Conditional formatting
- Data validation
    - Data type definition
- Formulas and scripting
- Different views
- Pinning/hiding certain fields
- Joining tables

### Others

- Code generation (generating data structures and editing them from a GUI)
- Support metadata commentary etc
- Support different views
- Support lots of fields

- Easy game flow editor
Being able to say I want this screen to appear, then wait X, then wait for event etc through data rather than hard coding
Probably needs to manage the camera then. Or to avoid this, steps of a game flow should be nodes

- Support hot reload and packaging
I want to be able to modify the data and see real time changes in the game without having to restart.
This means whatever API is reading the data must support either polling or watching and moving the data

- Easy feature flags

- Global game counters and constants are cool

## API

### Retrieve variant number data

You have a column that may be a number, a range, or a list of numbers, you can add valid values in formats such as 
10
10-20
10,20,30,40

And then in the API you do 
```gdscript
var res = getData("B2")

if res.isNumber():
    damage = res.toNumber()
elif res.isRange():
    damage = res.toRange().random()
    damage = res.toRange().remapped(0, 100)
    damage = res.toRange()
```

etc. maybe find a less hardcoded way to do this?
-> TODO: define primary data types 

### Automatic data validation/parsing

Designers can add data validation rules like in GSheets and these rules are guaranteed to be enforced

### Flexible layout definition to edit resources

Eg you have a function on all resources that can return a UI component to display things in a specific way
Something like the unity addon to make easy imperative inspectors

```gd
func _editor_layout():
    return [
        {
            direction: "horizontal",
            content: [
            Label("some_property")
            Input("some_property")
            ]
        }
    ]
```

## Editor

Support for array-like data definition or prefab-like
Support for rigid arrays or loosey spreadsheets
    Loosey spreadsheets should be able to be intelligently baked when packaging the game
Support comments, color coding, 
    In comment you can add a @Someone tag that doesn't do much except you can have a window with all comments containing @Someone

## Summary made using Gemini below

### A Comprehensive Summary of the Project: ContentForge

This is a comprehensive summary of our conversation, detailing the project's vision, features, and a proposed development plan. The project's name is **ContentForge**.

#### **I. Core Vision and Problem Statement**

**ContentForge** is a Godot-based software designed to be a unified, all-in-one work environment for game designers. It addresses the common problem of a disjointed workflow where designers use external tools like Google Sheets or Figma to define game content, leading to:

* **Error-prone manual data entry**: Designers must painfully copy and paste data from spreadsheets into the game engine, which is slow and prone to mistakes.
* **Multiple sources of truth**: The design documents (spreadsheets, wikis) and the in-game data are separate, making it difficult to ensure they are synchronized.
* **Lack of visualization**: Designers cannot easily see how their data affects the actual game without a full development cycle, making balancing and iteration difficult.

**ContentForge** aims to bridge this gap, enabling a workflow where the designer's creative intent is directly reflected in the game. The central idea is that what a designer creates is what is in the game. It will start as a Godot addon, but its ultimate goal is to evolve into a standalone software, powered by the Godot Engine itself, that provides a holistic game creation experience.

#### **II. Key Features**

The project is broken down into a set of distinct, yet interconnected, features that replace a number of disparate tools:

1.  **Integrated Data and Spreadsheet Editor (Replacing Notion/Confluence)**:
    * A custom editor dock or tab within Godot that looks and feels like a spreadsheet.
    * It will store data in a human-readable format like JSON, which is compatible with version control systems (e.g., Git) for easy collaboration and change tracking.
    * **Data Models**: Each column will have a defined data type (e.g., `text`, `integer`, `float`, `boolean`), which enables automatic data validation and prevents errors.
    * **External Compatibility**: The tool will have import and export functionality for CSV and JSON, allowing designers to continue using their preferred external tools while keeping the game data synchronized.

2.  **Project and Task Management (Replacing Jira/Trello/ClickUp)**:
    * A built-in Kanban board system for visualizing and tracking tasks, bugs, and features.
    * **Direct Task Linking**: Tasks can be directly linked to specific rows or data entries in the spreadsheet, or even to nodes in a scene. For example, a task to "balance the Goblin's stats" would link directly to the "Goblin" row in the database.
    * **Activity Logs**: The system will automatically log changes made to data entries, providing a clear history of modifications and who made them.

3.  **Visualization and Analytics (Replacing Figma/et al)**:
    * The tool will include a visualization layer to help designers understand their data.
    * After generating game objects, the tool will be able to display statistical data on their attributes (e.g., average health, min/max damage) in a graphical format like a histogram or bar chart.
    * **UI/UX Mockups**: A long-term goal is to allow designers to create UI mockups and prototypes directly within the tool, which can then be directly converted into Godot UI scenes. This would eliminate the need for an external tool like Figma.

4.  **Unified Content Pipeline**:
    * The spreadsheet will not just contain raw data; it will contain references to other Godot resources. For example, an "Enemy" sheet could have a column that references a `PackedScene` for the enemy's model and another that references a `Texture2D` for its UI icon.
    * The tool will have a system for adding human-readable information, such as designer notes and detailed descriptions, directly alongside the technical data. This eliminates the need for separate documentation.

#### **III. Proposed Development Plan**

The project can be developed in phases:

* **Phase 1: Foundation**: Create the basic Godot editor addon structure. Build a rudimentary UI with `Control` nodes to serve as the spreadsheet grid. Implement a basic save/load function for data persistence (e.g., to a JSON file).
* **Phase 2: Spreadsheet Logic**: Flesh out the spreadsheet functionality. Implement data type validation, the ability to create multiple sheets, and a robust system for handling data relationships and references. Add the import/export functionality for CSV.
* **Phase 3: Game Bridge and Task Management**: Develop the in-engine generation and visualization features. Create the script that reads the addon's data and instantiates game scenes. Build the UI for displaying charts and graphs of the generated data. Simultaneously, build the basic Kanban board and task tracking functionality.
* **Phase 4: Polish and Extensibility**: Refine the user experience. Add the ability to include human-readable notes. Refactor the code to be modular, making it easy for other developers to add new features or data types to the tool. Start exploring the possibility of UI/UX prototyping.

---

### Next Steps for Development

1.  **Project Setup**: Create a new Godot project and an `addons` folder. Create the initial `plugin.cfg` and `plugin.gd` files to define the addon. This is the first step toward making a self-contained application.
2.  **UI Prototyping**: Start building the user interface in a dedicated scene file. Focus on creating the basic grid structure with `Control` nodes like `VBoxContainer` and `LineEdit`.
3.  **Core Data Model**: Define the data structure in a GDScript class. A dictionary for the entire database, with dictionaries for each sheet, is a flexible approach.
4.  **Save/Load Logic**: Implement functions to save the data dictionary to a JSON file and load it back. This is the first critical step for data persistence and version control.
5.  **GitHub Repository**: Create a Git repository to manage your code. This is essential for version control, collaboration, and backing up your work.

