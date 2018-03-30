/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * TEXT FIELD MODULE - Header                                                              *
 * by Gunnar Harboe (Snarky), v1.2.0                                                       *
 *                                                                                         *
 * Copyright (c) 2018 Gunnar Harboe                                                        *
 *                                                                                         *
 *                                                                                         *
 * This module provides a one-line text input field, to replace the built-in AGS           *
 * TextInput control. Its main benefit is that it allows you to position the text cursor   *
 * (caret) freely within the input string, using either arrow keys or mouse. It also has   *
 * a notion of focus, which makes it easier to have GUIs with multiple text fields.        *
 * Finally, you can customize the appearance and behavior of the text fields somewhat.     *
 *                                                                                         *
 * To use, you have to set up a GUI Button for each text field you want. The position,     *
 * size, font, and text color of the button will be used to format the text field. Then    *
 * you have to initialize the text field using TextField.Create(), providing the GUI       *
 * button as an argument, like so:                                                         *
 *                                                                                         *
 *   TextField* myTextField = TextField.Create(myButton);                                  *
 *                                                                                         *
 * You would typically do this in game_start(), and in any case before the text field is   *
 * displayed. After you've created the text field, don't set the button properties         *
 * directly!                                                                               *
 *                                                                                         *
 * You also need to hook up the events. Because we lose the TextInput OnActivate event,    *
 * we have to handle activating the field (typically by pressing Return) a little          *
 * differently. There are two alternatives: You can handle it yourself in the game's       *
 * general on_key_press() function:                                                        *
 *                                                                                         *
 *   function on_key_press(eKeyCode keycode)                                               *
 *   {                                                                                     *
 *     if(keycode == eKeyReturn)                                                           *
 *     {                                                                                   *
 *       if(TextField.Focused == myTextField)                                              *
 *       {                                                                                 *
 *         // Activate                                                                     *
 *       }                                                                                 *
 *       else if(TextField.Focused == myOtherTextField)                                    *
 *       {                                                                                 *
 *         // Activate                                                                     *
 *       }                                                                                 *
 *       // ...                                                                            *
 *     }                                                                                   *
 *     else // handle other keys                                                           *
 *   }                                                                                     *
 *                                                                                         *
 * Or the module can handle it, by setting TextField.HandleReturn = true; but then you     *
 * have to check textField.Activated() each game cycle to see if it was activated:         *
 *                                                                                         *
 *   function repeatedly_execute_always()                                                  *
 *   {                                                                                     *
 *     if(myTextField.Activated())                                                         *
 *     {                                                                                   *
 *       // Activate                                                                       *
 *     }                                                                                   *
 *   }                                                                                     *
 *                                                                                         *
 * You should also link the button's OnClick() event to a function to handle clicks in     *
 * the text field. Default behavior (set focus and position the text cursor) is provided,  *
 * so you can just do:                                                                     *
 *                                                                                         *
 *   function myButton_OnClick(GUIControl *control, MouseButton button)                    *
 *   {                                                                                     *
 *     myTextField.HandleMouseClick(button);                                               *
 *   }                                                                                     *
 *                                                                                         *
 * Or, if you want a common function you can use for all the text fields:                  *
 *                                                                                         *
 *   function myTextFieldButtons_OnClick(GUIControl *control, MouseButton button)          *
 *   {                                                                                     *
 *     TextField.HandleMouseClickAny(control, button);                                     *
 *   }                                                                                     *
 *                                                                                         *
 *                                                                                         *
 * This code is offered under multiple licenses. Choose whichever one you like.            *
 *                                                                                         *
 * You may use it under the MIT license:                                                   *
 * https://opensource.org/licenses/MIT                                                     *
 *                                                                                         *
 * You may also use it under the Creative Commons Attribution 4.0 International License.   *
 * https://creativecommons.org/licenses/by/4.0/                                            *
 *                                                                                         *
 * You may also use it under the Artistic License 2.0                                      *
 * https://opensource.org/licenses/Artistic-2.0                                            *
 *                                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#define TEXTFIELD_DEFAULT_COUNT 4   // How many text fields are created by default. If you have many, increasing this number may slightly improve startup performance
#define TEXTFIELD_BORDER_WIDTH 1    // How wide the border of the text field is
#define TEXTFIELD_CARET_WIDTH 1     // How wide the text cursor/caret is
#define TEXTFIELD_CARET_OFFSET_X -1 // Used to position the caret correctly between characters (depends on font)

/// A replacement for the built-in TextInput control, allowing users to move the text cursor 
managed struct TextField
{
  // STATIC METHODS AND PROPERTIES
  
  /// Create a TextField from a button. Only TextFields created by this function are valid
  import static TextField* Create(Button* textDisplay, String text=0, int paddingLeft=0, int paddingTop=0); // $AUTOCOMPLETESTATICONLY$
  /// Get or set which TextField currently has focus. Null if none.
  import static attribute TextField* Focused;                                                               // $AUTOCOMPLETESTATICONLY$
  
  /// Get or set the delay between text cursor blinks (default 20 game cycles)
  import static attribute int BlinkDelay;                                                                   // $AUTOCOMPLETESTATICONLY$
  /// Get or set whether the TextFields handle the Return key, or pass it along to on_key_press()
  import static attribute bool HandlesReturn;                                                               // $AUTOCOMPLETESTATICONLY$

  /// Passes a mouse click on to the relevant TextField, and performs default behavior (give focus and set cursor position). Returns whether the click was handled. 
  import static bool HandleMouseClickAny(GUIControl *control, MouseButton button);                          // $AUTOCOMPLETESTATICONLY$
  
  /// Find the TextField associated with the provided button. Null if none.
  import static TextField* FindByDisplayButton(Button* textDisplayButton);                                  // $AUTOCOMPLETESTATICONLY$
  /// Find the TextField with the given ID. Null if none.
  import static TextField* FindByID(int id);                                                                // $AUTOCOMPLETESTATICONLY$
  
  // INSTANCE METHODS AND PROPERTIES
  
  /// Get the ID of this TextField
  import readonly attribute int ID;
  /// Get the Button that displays this text field
  import readonly attribute Button* TextDisplayButton;
  
  /// Get or set the text content of this TextField
  import attribute String Text;
  /// Get or set the font of this TextField
  import attribute FontType Font;
  /// Get or set the text color of this TextField (also used for the text cursor and border)
  import attribute int TextColor;
  /// Get or set the max String length of this TextField, 0 for unlimited (content will be truncated to MaxLength)
  import attribute int MaxLength;
  
  /// Get or set whether this TextField is currently enabled (can receive focus)
  import attribute bool Enabled;
  /// Get whether this TextField currently has focus
  import readonly attribute bool HasFocus;
  /// Get or set the current text cursor position, as a String index.
  import attribute int CaretIndex;
  
  /// Set whether this TextField should have focus. Returns whether focus was set.
  import bool SetFocus(bool giveFocus=true);
  /// Position the text cursor to the x,y position. Returns whether the cursor was positioned.
  import bool PositionCaret(int x, int y);
   
  /// Handle a keypress (default behavior: add/delete text input or move text cursor). Returns whether keypress was handled.
  import bool HandleKeyPress(eKeyCode keycode);
  /// Handle a mouse click (default behavior: give focus and set text cursor position). Returns whether mouse click was handled.
  import bool HandleMouseClick(MouseButton button);
  
  /// Whether the control was activated (Return pressed) since the last check. Will only return true once (until activated again).
  import bool Activated();
  /// The transparency the border is drawn with.
  import attribute int BorderTransparency;
  
  // Internal values
  protected int _id;
  protected int _paddingLeft;
  protected int _paddingTop;
  protected int _caretIndex;
  protected int _caretX;
  protected int _caretY;
  protected int _maxLength;
  protected bool _enabled;
  protected int _borderTransparency;
  protected bool _activated;
  
  
  // Input type as bit field (Numeric, Alphabetic, Alphanumeric, Text)
  
  // SelectionStart index
  // SelectionStart x
};
